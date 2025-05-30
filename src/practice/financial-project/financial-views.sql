-- Financial Management System - Views
-- Views for reporting, analysis, and data presentation
-- Part of Lesson 6: Practice and Application

-- Set proper formatting for output
SET LINESIZE 200
SET PAGESIZE 100
SET ECHO ON
SET FEEDBACK ON

-- Clean up existing views
PROMPT Dropping existing financial views...
BEGIN
    FOR v IN (SELECT view_name FROM user_views WHERE view_name LIKE 'V_FIN_%') LOOP
        EXECUTE IMMEDIATE 'DROP VIEW ' || v.view_name;
    END LOOP;
END;
/

PROMPT Creating Financial Management Views...

-- =============================================================================
-- CHART OF ACCOUNTS AND GENERAL LEDGER VIEWS
-- =============================================================================

-- Enhanced Chart of Accounts view
CREATE OR REPLACE VIEW V_FIN_CHART_OF_ACCOUNTS AS
SELECT 
    coa.account_id,
    coa.company_id,
    c.company_name,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    coa.account_subtype,
    coa.normal_balance,
    coa.is_active,
    coa.is_posting_account,
    coa.description,
    parent.account_code AS parent_account_code,
    parent.account_name AS parent_account_name,
    coa.account_level,
    CASE 
        WHEN coa.account_type = 'ASSET' THEN 1
        WHEN coa.account_type = 'LIABILITY' THEN 2
        WHEN coa.account_type = 'EQUITY' THEN 3
        WHEN coa.account_type = 'REVENUE' THEN 4
        WHEN coa.account_type = 'EXPENSE' THEN 5
        WHEN coa.account_type = 'CONTRA' THEN 6
    END AS sort_order
FROM fin_chart_of_accounts coa
JOIN fin_companies c ON coa.company_id = c.company_id
LEFT JOIN fin_chart_of_accounts parent ON coa.parent_account_id = parent.account_id
WHERE coa.is_active = 'Y'
ORDER BY sort_order, coa.account_code;

COMMENT ON VIEW V_FIN_CHART_OF_ACCOUNTS IS 'Enhanced chart of accounts with hierarchy and company information';

-- General Ledger balances view
CREATE OR REPLACE VIEW V_FIN_GL_BALANCES AS
SELECT 
    gl.company_id,
    c.company_name,
    gl.account_id,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    coa.normal_balance,
    gl.cost_center_id,
    cc.cost_center_name,
    gl.period_year,
    gl.period_month,
    TO_DATE(gl.period_year || '-' || LPAD(gl.period_month, 2, '0') || '-01', 'YYYY-MM-DD') AS period_date,
    gl.beginning_balance,
    gl.period_debit,
    gl.period_credit,
    gl.ending_balance,
    CASE coa.normal_balance
        WHEN 'DEBIT' THEN gl.ending_balance
        WHEN 'CREDIT' THEN gl.ending_balance * -1
    END AS natural_balance
FROM fin_general_ledger gl
JOIN fin_companies c ON gl.company_id = c.company_id
JOIN fin_chart_of_accounts coa ON gl.account_id = coa.account_id
LEFT JOIN fin_cost_centers cc ON gl.cost_center_id = cc.cost_center_id
ORDER BY gl.period_year DESC, gl.period_month DESC, coa.account_code;

COMMENT ON VIEW V_FIN_GL_BALANCES IS 'General ledger balances with account and cost center details';

-- Account activity summary
CREATE OR REPLACE VIEW V_FIN_ACCOUNT_ACTIVITY AS
SELECT 
    coa.company_id,
    coa.account_id,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    COUNT(jel.line_id) AS transaction_count,
    MIN(je.entry_date) AS first_transaction_date,
    MAX(je.entry_date) AS last_transaction_date,
    SUM(jel.debit_amount) AS total_debits,
    SUM(jel.credit_amount) AS total_credits,
    CASE coa.normal_balance
        WHEN 'DEBIT' THEN SUM(jel.debit_amount - jel.credit_amount)
        WHEN 'CREDIT' THEN SUM(jel.credit_amount - jel.debit_amount)
    END AS current_balance
FROM fin_chart_of_accounts coa
LEFT JOIN fin_journal_entry_lines jel ON coa.account_id = jel.account_id
LEFT JOIN fin_journal_entries je ON jel.journal_entry_id = je.journal_entry_id 
    AND je.status = 'POSTED'
WHERE coa.is_active = 'Y'
GROUP BY coa.company_id, coa.account_id, coa.account_code, coa.account_name, 
         coa.account_type, coa.normal_balance
ORDER BY coa.account_code;

COMMENT ON VIEW V_FIN_ACCOUNT_ACTIVITY IS 'Account activity summary with transaction counts and balances';

-- =============================================================================
-- ACCOUNTS PAYABLE VIEWS
-- =============================================================================

-- AP Invoice summary
CREATE OR REPLACE VIEW V_FIN_AP_INVOICES AS
SELECT 
    i.invoice_id,
    i.company_id,
    c.company_name,
    i.vendor_id,
    v.vendor_name,
    v.vendor_type,
    v.payment_terms,
    i.invoice_number,
    i.vendor_invoice_num,
    i.invoice_date,
    i.due_date,
    CASE 
        WHEN i.due_date < SYSDATE AND i.status IN ('OPEN', 'PARTIAL') THEN 'OVERDUE'
        ELSE i.status
    END AS invoice_status,
    i.invoice_amount,
    i.tax_amount,
    i.total_amount,
    i.paid_amount,
    i.total_amount - i.paid_amount AS outstanding_amount,
    SYSDATE - i.due_date AS days_outstanding,
    CASE 
        WHEN i.due_date >= SYSDATE THEN 'Current'
        WHEN SYSDATE - i.due_date BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN SYSDATE - i.due_date BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN SYSDATE - i.due_date BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN SYSDATE - i.due_date > 90 THEN 'Over 90 Days'
    END AS aging_bucket,
    i.description,
    cc.cost_center_name,
    i.created_date,
    i.created_by
FROM fin_ap_invoices i
JOIN fin_companies c ON i.company_id = c.company_id
JOIN fin_vendors v ON i.vendor_id = v.vendor_id
LEFT JOIN fin_cost_centers cc ON i.cost_center_id = cc.cost_center_id
ORDER BY i.invoice_date DESC;

COMMENT ON VIEW V_FIN_AP_INVOICES IS 'Comprehensive AP invoice information with aging and status';

-- AP Aging summary
CREATE OR REPLACE VIEW V_FIN_AP_AGING_SUMMARY AS
SELECT 
    company_id,
    vendor_id,
    vendor_name,
    COUNT(*) AS invoice_count,
    SUM(outstanding_amount) AS total_outstanding,
    SUM(CASE WHEN aging_bucket = 'Current' THEN outstanding_amount ELSE 0 END) AS current_amount,
    SUM(CASE WHEN aging_bucket = '1-30 Days' THEN outstanding_amount ELSE 0 END) AS days_1_30,
    SUM(CASE WHEN aging_bucket = '31-60 Days' THEN outstanding_amount ELSE 0 END) AS days_31_60,
    SUM(CASE WHEN aging_bucket = '61-90 Days' THEN outstanding_amount ELSE 0 END) AS days_61_90,
    SUM(CASE WHEN aging_bucket = 'Over 90 Days' THEN outstanding_amount ELSE 0 END) AS over_90_days,
    ROUND(AVG(days_outstanding), 1) AS avg_days_outstanding
FROM V_FIN_AP_INVOICES
WHERE outstanding_amount > 0
GROUP BY company_id, vendor_id, vendor_name
ORDER BY total_outstanding DESC;

COMMENT ON VIEW V_FIN_AP_AGING_SUMMARY IS 'AP aging summary by vendor with bucket analysis';

-- AP Payment history
CREATE OR REPLACE VIEW V_FIN_AP_PAYMENTS AS
SELECT 
    p.payment_id,
    p.company_id,
    c.company_name,
    p.vendor_id,
    v.vendor_name,
    p.payment_number,
    p.payment_date,
    p.payment_method,
    p.check_number,
    ba.account_name AS bank_account_name,
    p.payment_amount,
    p.discount_taken,
    p.status AS payment_status,
    p.memo,
    COUNT(pa.allocation_id) AS invoices_paid,
    SUM(pa.allocated_amount) AS total_allocated,
    p.payment_amount - NVL(SUM(pa.allocated_amount), 0) AS unallocated_amount,
    p.created_date,
    p.created_by
FROM fin_ap_payments p
JOIN fin_companies c ON p.company_id = c.company_id
JOIN fin_vendors v ON p.vendor_id = v.vendor_id
LEFT JOIN fin_bank_accounts ba ON p.bank_account_id = ba.bank_account_id
LEFT JOIN fin_ap_payment_allocations pa ON p.payment_id = pa.payment_id
GROUP BY p.payment_id, p.company_id, c.company_name, p.vendor_id, v.vendor_name,
         p.payment_number, p.payment_date, p.payment_method, p.check_number,
         ba.account_name, p.payment_amount, p.discount_taken, p.status,
         p.memo, p.created_date, p.created_by
ORDER BY p.payment_date DESC;

COMMENT ON VIEW V_FIN_AP_PAYMENTS IS 'AP payment history with allocation details';

-- =============================================================================
-- ACCOUNTS RECEIVABLE VIEWS
-- =============================================================================

-- AR Invoice summary
CREATE OR REPLACE VIEW V_FIN_AR_INVOICES AS
SELECT 
    i.invoice_id,
    i.company_id,
    co.company_name,
    i.customer_id,
    c.customer_name,
    c.customer_type,
    c.payment_terms,
    c.credit_limit,
    i.invoice_number,
    i.invoice_date,
    i.due_date,
    CASE 
        WHEN i.due_date < SYSDATE AND i.status IN ('OPEN', 'PARTIAL') THEN 'OVERDUE'
        ELSE i.status
    END AS invoice_status,
    i.subtotal_amount,
    i.tax_amount,
    i.total_amount,
    i.paid_amount,
    i.total_amount - i.paid_amount AS outstanding_amount,
    SYSDATE - i.due_date AS days_outstanding,
    CASE 
        WHEN i.due_date >= SYSDATE THEN 'Current'
        WHEN SYSDATE - i.due_date BETWEEN 1 AND 30 THEN '1-30 Days'
        WHEN SYSDATE - i.due_date BETWEEN 31 AND 60 THEN '31-60 Days'
        WHEN SYSDATE - i.due_date BETWEEN 61 AND 90 THEN '61-90 Days'
        WHEN SYSDATE - i.due_date > 90 THEN 'Over 90 Days'
    END AS aging_bucket,
    i.description,
    i.created_date,
    i.created_by
FROM fin_ar_invoices i
JOIN fin_companies co ON i.company_id = co.company_id
JOIN fin_customers c ON i.customer_id = c.customer_id
ORDER BY i.invoice_date DESC;

COMMENT ON VIEW V_FIN_AR_INVOICES IS 'Comprehensive AR invoice information with aging and customer details';

-- AR Aging summary
CREATE OR REPLACE VIEW V_FIN_AR_AGING_SUMMARY AS
SELECT 
    company_id,
    customer_id,
    customer_name,
    customer_type,
    credit_limit,
    COUNT(*) AS invoice_count,
    SUM(outstanding_amount) AS total_outstanding,
    SUM(CASE WHEN aging_bucket = 'Current' THEN outstanding_amount ELSE 0 END) AS current_amount,
    SUM(CASE WHEN aging_bucket = '1-30 Days' THEN outstanding_amount ELSE 0 END) AS days_1_30,
    SUM(CASE WHEN aging_bucket = '31-60 Days' THEN outstanding_amount ELSE 0 END) AS days_31_60,
    SUM(CASE WHEN aging_bucket = '61-90 Days' THEN outstanding_amount ELSE 0 END) AS days_61_90,
    SUM(CASE WHEN aging_bucket = 'Over 90 Days' THEN outstanding_amount ELSE 0 END) AS over_90_days,
    ROUND(AVG(days_outstanding), 1) AS avg_days_outstanding,
    ROUND((SUM(outstanding_amount) / NULLIF(credit_limit, 0)) * 100, 2) AS credit_utilization_pct
FROM V_FIN_AR_INVOICES
WHERE outstanding_amount > 0
GROUP BY company_id, customer_id, customer_name, customer_type, credit_limit
ORDER BY total_outstanding DESC;

COMMENT ON VIEW V_FIN_AR_AGING_SUMMARY IS 'AR aging summary by customer with credit utilization analysis';

-- Customer payment history
CREATE OR REPLACE VIEW V_FIN_AR_PAYMENTS AS
SELECT 
    p.payment_id,
    p.company_id,
    co.company_name,
    p.customer_id,
    c.customer_name,
    p.payment_number,
    p.payment_date,
    p.payment_method,
    p.reference_number,
    ba.account_name AS bank_account_name,
    p.payment_amount,
    p.status AS payment_status,
    p.memo,
    p.created_date,
    p.created_by
FROM fin_ar_payments p
JOIN fin_companies co ON p.company_id = co.company_id
JOIN fin_customers c ON p.customer_id = c.customer_id
LEFT JOIN fin_bank_accounts ba ON p.bank_account_id = ba.bank_account_id
ORDER BY p.payment_date DESC;

COMMENT ON VIEW V_FIN_AR_PAYMENTS IS 'AR payment history with customer and bank account details';

-- =============================================================================
-- CASH FLOW AND BANKING VIEWS
-- =============================================================================

-- Bank account summary
CREATE OR REPLACE VIEW V_FIN_BANK_ACCOUNTS AS
SELECT 
    ba.bank_account_id,
    ba.company_id,
    c.company_name,
    ba.account_name,
    ba.account_number,
    ba.bank_name,
    ba.account_type,
    coa.account_code AS gl_account_code,
    coa.account_name AS gl_account_name,
    ba.current_balance,
    ba.is_active,
    COUNT(bt.transaction_id) AS transaction_count,
    MAX(bt.transaction_date) AS last_transaction_date,
    SUM(CASE WHEN bt.transaction_type IN ('DEPOSIT', 'INTEREST') THEN bt.amount ELSE 0 END) AS total_deposits,
    SUM(CASE WHEN bt.transaction_type IN ('WITHDRAWAL', 'FEE') THEN bt.amount ELSE 0 END) AS total_withdrawals
FROM fin_bank_accounts ba
JOIN fin_companies c ON ba.company_id = c.company_id
JOIN fin_chart_of_accounts coa ON ba.gl_account_id = coa.account_id
LEFT JOIN fin_bank_transactions bt ON ba.bank_account_id = bt.bank_account_id
GROUP BY ba.bank_account_id, ba.company_id, c.company_name, ba.account_name,
         ba.account_number, ba.bank_name, ba.account_type, coa.account_code,
         coa.account_name, ba.current_balance, ba.is_active
ORDER BY ba.account_name;

COMMENT ON VIEW V_FIN_BANK_ACCOUNTS IS 'Bank account summary with transaction statistics';

-- Cash flow analysis
CREATE OR REPLACE VIEW V_FIN_CASH_FLOW AS
SELECT 
    TO_CHAR(transaction_date, 'YYYY-MM') AS period,
    EXTRACT(YEAR FROM transaction_date) AS year,
    EXTRACT(MONTH FROM transaction_date) AS month,
    bank_account_id,
    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN transaction_type IN ('DEPOSIT', 'INTEREST') THEN amount ELSE 0 END) AS cash_inflows,
    SUM(CASE WHEN transaction_type IN ('WITHDRAWAL', 'FEE') THEN amount ELSE 0 END) AS cash_outflows
FROM fin_bank_transactions
WHERE transaction_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY TO_CHAR(transaction_date, 'YYYY-MM'), EXTRACT(YEAR FROM transaction_date),
         EXTRACT(MONTH FROM transaction_date), bank_account_id, transaction_type
ORDER BY year DESC, month DESC, bank_account_id;

COMMENT ON VIEW V_FIN_CASH_FLOW IS 'Monthly cash flow analysis by bank account and transaction type';

-- =============================================================================
-- BUDGET AND VARIANCE ANALYSIS VIEWS
-- =============================================================================

-- Budget vs Actual comparison
CREATE OR REPLACE VIEW V_FIN_BUDGET_VARIANCE AS
SELECT 
    bd.budget_id,
    b.budget_name,
    bd.account_id,
    coa.account_code,
    coa.account_name,
    coa.account_type,
    bd.cost_center_id,
    cc.cost_center_name,
    bd.period_year,
    bd.period_month,
    bd.budgeted_amount,
    bd.revised_amount,
    NVL(bd.revised_amount, bd.budgeted_amount) AS final_budget,
    gl.period_debit - gl.period_credit AS actual_amount,
    (gl.period_debit - gl.period_credit) - NVL(bd.revised_amount, bd.budgeted_amount) AS variance_amount,
    CASE 
        WHEN NVL(bd.revised_amount, bd.budgeted_amount) != 0 THEN
            ROUND(((gl.period_debit - gl.period_credit) - NVL(bd.revised_amount, bd.budgeted_amount)) / 
                  NVL(bd.revised_amount, bd.budgeted_amount) * 100, 2)
        ELSE 0
    END AS variance_percentage,
    CASE 
        WHEN coa.account_type IN ('REVENUE') THEN
            CASE WHEN (gl.period_debit - gl.period_credit) > NVL(bd.revised_amount, bd.budgeted_amount) THEN 'Favorable'
                 ELSE 'Unfavorable' END
        WHEN coa.account_type IN ('EXPENSE') THEN
            CASE WHEN (gl.period_debit - gl.period_credit) < NVL(bd.revised_amount, bd.budgeted_amount) THEN 'Favorable'
                 ELSE 'Unfavorable' END
        ELSE 'N/A'
    END AS variance_type
FROM fin_budget_details bd
JOIN fin_budgets b ON bd.budget_id = b.budget_id
JOIN fin_chart_of_accounts coa ON bd.account_id = coa.account_id
LEFT JOIN fin_cost_centers cc ON bd.cost_center_id = cc.cost_center_id
LEFT JOIN fin_general_ledger gl ON bd.account_id = gl.account_id
    AND NVL(bd.cost_center_id, -1) = NVL(gl.cost_center_id, -1)
    AND bd.period_year = gl.period_year
    AND bd.period_month = gl.period_month
WHERE b.status = 'ACTIVE'
ORDER BY bd.period_year, bd.period_month, coa.account_code;

COMMENT ON VIEW V_FIN_BUDGET_VARIANCE IS 'Budget vs actual variance analysis with favorable/unfavorable indicators';

-- =============================================================================
-- FINANCIAL REPORTING VIEWS
-- =============================================================================

-- Income Statement data
CREATE OR REPLACE VIEW V_FIN_INCOME_STATEMENT AS
SELECT 
    coa.company_id,
    EXTRACT(YEAR FROM je.entry_date) AS fiscal_year,
    EXTRACT(MONTH FROM je.entry_date) AS fiscal_month,
    coa.account_type,
    coa.account_code,
    coa.account_name,
    SUM(CASE 
        WHEN coa.account_type = 'REVENUE' THEN jel.credit_amount - jel.debit_amount
        WHEN coa.account_type = 'EXPENSE' THEN jel.debit_amount - jel.credit_amount
        ELSE 0
    END) AS net_amount
FROM fin_chart_of_accounts coa
JOIN fin_journal_entry_lines jel ON coa.account_id = jel.account_id
JOIN fin_journal_entries je ON jel.journal_entry_id = je.journal_entry_id
WHERE je.status = 'POSTED'
AND coa.account_type IN ('REVENUE', 'EXPENSE')
AND je.entry_date >= TRUNC(SYSDATE, 'YYYY') -- Current fiscal year
GROUP BY coa.company_id, EXTRACT(YEAR FROM je.entry_date), 
         EXTRACT(MONTH FROM je.entry_date), coa.account_type,
         coa.account_code, coa.account_name
ORDER BY fiscal_year, fiscal_month, coa.account_code;

COMMENT ON VIEW V_FIN_INCOME_STATEMENT IS 'Income statement data by month and account';

-- Balance Sheet data
CREATE OR REPLACE VIEW V_FIN_BALANCE_SHEET AS
SELECT 
    coa.company_id,
    coa.account_type,
    coa.account_code,
    coa.account_name,
    SUM(CASE coa.normal_balance
        WHEN 'DEBIT' THEN jel.debit_amount - jel.credit_amount
        WHEN 'CREDIT' THEN jel.credit_amount - jel.debit_amount
    END) AS balance_amount,
    CASE 
        WHEN coa.account_type = 'ASSET' THEN 1
        WHEN coa.account_type = 'LIABILITY' THEN 2
        WHEN coa.account_type = 'EQUITY' THEN 3
        WHEN coa.account_type = 'CONTRA' THEN 4
    END AS sort_order
FROM fin_chart_of_accounts coa
JOIN fin_journal_entry_lines jel ON coa.account_id = jel.account_id
JOIN fin_journal_entries je ON jel.journal_entry_id = je.journal_entry_id
WHERE je.status = 'POSTED'
AND coa.account_type IN ('ASSET', 'LIABILITY', 'EQUITY', 'CONTRA')
GROUP BY coa.company_id, coa.account_type, coa.account_code, 
         coa.account_name, coa.normal_balance
HAVING SUM(CASE coa.normal_balance
    WHEN 'DEBIT' THEN jel.debit_amount - jel.credit_amount
    WHEN 'CREDIT' THEN jel.credit_amount - jel.debit_amount
END) != 0
ORDER BY sort_order, coa.account_code;

COMMENT ON VIEW V_FIN_BALANCE_SHEET IS 'Balance sheet data with account balances';

-- =============================================================================
-- EXECUTIVE DASHBOARD VIEWS
-- =============================================================================

-- Financial KPIs dashboard
CREATE OR REPLACE VIEW V_FIN_EXECUTIVE_DASHBOARD AS
SELECT 
    'Total Assets' AS metric_name,
    TO_CHAR(SUM(balance_amount), 'FM$999,999,999') AS metric_value,
    'Current total assets' AS description
FROM V_FIN_BALANCE_SHEET
WHERE account_type = 'ASSET'
UNION ALL
SELECT 
    'Total Liabilities' AS metric_name,
    TO_CHAR(SUM(balance_amount), 'FM$999,999,999') AS metric_value,
    'Current total liabilities' AS description
FROM V_FIN_BALANCE_SHEET
WHERE account_type = 'LIABILITY'
UNION ALL
SELECT 
    'Accounts Receivable' AS metric_name,
    TO_CHAR(SUM(outstanding_amount), 'FM$999,999,999') AS metric_value,
    'Total outstanding receivables' AS description
FROM V_FIN_AR_INVOICES
WHERE outstanding_amount > 0
UNION ALL
SELECT 
    'Accounts Payable' AS metric_name,
    TO_CHAR(SUM(outstanding_amount), 'FM$999,999,999') AS metric_value,
    'Total outstanding payables' AS description
FROM V_FIN_AP_INVOICES
WHERE outstanding_amount > 0
UNION ALL
SELECT 
    'Cash Balance' AS metric_name,
    TO_CHAR(SUM(current_balance), 'FM$999,999,999') AS metric_value,
    'Total cash in all bank accounts' AS description
FROM V_FIN_BANK_ACCOUNTS
WHERE is_active = 'Y'
UNION ALL
SELECT 
    'Monthly Revenue' AS metric_name,
    TO_CHAR(SUM(net_amount), 'FM$999,999,999') AS metric_value,
    'Current month revenue' AS description
FROM V_FIN_INCOME_STATEMENT
WHERE account_type = 'REVENUE'
AND fiscal_month = EXTRACT(MONTH FROM SYSDATE)
AND fiscal_year = EXTRACT(YEAR FROM SYSDATE);

COMMENT ON VIEW V_FIN_EXECUTIVE_DASHBOARD IS 'Key financial metrics for executive dashboard';

-- Monthly financial summary
CREATE OR REPLACE VIEW V_FIN_MONTHLY_SUMMARY AS
SELECT 
    fiscal_year,
    fiscal_month,
    TO_DATE(fiscal_year || '-' || LPAD(fiscal_month, 2, '0') || '-01', 'YYYY-MM-DD') AS period_date,
    SUM(CASE WHEN account_type = 'REVENUE' THEN net_amount ELSE 0 END) AS total_revenue,
    SUM(CASE WHEN account_type = 'EXPENSE' THEN net_amount ELSE 0 END) AS total_expenses,
    SUM(CASE WHEN account_type = 'REVENUE' THEN net_amount ELSE 0 END) -
    SUM(CASE WHEN account_type = 'EXPENSE' THEN net_amount ELSE 0 END) AS net_income,
    LAG(SUM(CASE WHEN account_type = 'REVENUE' THEN net_amount ELSE 0 END) -
        SUM(CASE WHEN account_type = 'EXPENSE' THEN net_amount ELSE 0 END), 1) 
        OVER (ORDER BY fiscal_year, fiscal_month) AS prior_month_net_income
FROM V_FIN_INCOME_STATEMENT
GROUP BY fiscal_year, fiscal_month
ORDER BY fiscal_year DESC, fiscal_month DESC;

COMMENT ON VIEW V_FIN_MONTHLY_SUMMARY IS 'Monthly financial performance summary with prior period comparison';

PROMPT Financial Views created successfully!
PROMPT ====================================

-- Display summary of created views
SELECT 
    view_name,
    SUBSTR(comments, 1, 50) AS description
FROM user_tab_comments 
WHERE table_name LIKE 'V_FIN_%' 
AND table_type = 'VIEW'
ORDER BY view_name;

PROMPT
PROMPT Financial Management Views Summary:
PROMPT - Chart of accounts and general ledger views
PROMPT - Accounts payable and receivable reporting
PROMPT - Cash flow and banking analysis
PROMPT - Budget variance and performance analysis
PROMPT - Financial statement preparation views
PROMPT - Executive dashboard and KPI views
PROMPT
PROMPT Total Views Created: 15+
PROMPT Views are ready for financial reporting and analysis!
