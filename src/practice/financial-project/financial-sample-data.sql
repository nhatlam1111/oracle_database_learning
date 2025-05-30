-- Financial Management System - Sample Data
-- Comprehensive test data for financial system
-- Part of Lesson 6: Practice and Application

-- Set proper formatting for output
SET LINESIZE 200
SET PAGESIZE 100
SET ECHO ON
SET FEEDBACK ON
SET AUTOCOMMIT OFF

PROMPT Loading Financial Management Sample Data...

-- =============================================================================
-- COMPANY SETUP
-- =============================================================================

-- Insert sample company
INSERT INTO fin_companies (
    company_id, company_code, company_name, legal_name, tax_id,
    address_line1, city, state_province, postal_code, country,
    phone, email, website, base_currency
) VALUES (
    fin_company_seq.NEXTVAL, 'ABC001', 'ABC Manufacturing Inc.',
    'ABC Manufacturing Incorporated', '12-3456789',
    '123 Industrial Drive', 'Springfield', 'IL', '62701', 'US',
    '217-555-0100', 'info@abcmanufacturing.com', 'www.abcmanufacturing.com', 'USD'
);

-- Get company_id for reference
DECLARE
    v_company_id NUMBER;
BEGIN
    SELECT company_id INTO v_company_id FROM fin_companies WHERE company_code = 'ABC001';
    DBMS_OUTPUT.PUT_LINE('Company ID: ' || v_company_id);
END;
/

-- =============================================================================
-- CHART OF ACCOUNTS
-- =============================================================================

-- Define Chart of Accounts structure
INSERT ALL
    -- ASSETS
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1000', 'ASSETS', 'ASSET', 'DEBIT', 'Total Assets')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1100', 'CURRENT ASSETS', 'ASSET', 'DEBIT', 'Current Assets')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1110', 'Cash - Operating Account', 'ASSET', 'DEBIT', 'Main operating cash account')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1120', 'Cash - Payroll Account', 'ASSET', 'DEBIT', 'Dedicated payroll cash account')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1130', 'Accounts Receivable', 'ASSET', 'DEBIT', 'Customer receivables')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1140', 'Inventory - Raw Materials', 'ASSET', 'DEBIT', 'Raw materials inventory')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1150', 'Inventory - Finished Goods', 'ASSET', 'DEBIT', 'Finished goods inventory')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1160', 'Prepaid Expenses', 'ASSET', 'DEBIT', 'Prepaid expenses and deposits')
    
    -- FIXED ASSETS
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1200', 'FIXED ASSETS', 'ASSET', 'DEBIT', 'Fixed Assets')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1210', 'Equipment', 'ASSET', 'DEBIT', 'Manufacturing equipment')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1220', 'Accumulated Depreciation - Equipment', 'CONTRA', 'CREDIT', 'Accumulated depreciation on equipment')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1230', 'Buildings', 'ASSET', 'DEBIT', 'Buildings and structures')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '1240', 'Accumulated Depreciation - Buildings', 'CONTRA', 'CREDIT', 'Accumulated depreciation on buildings')
    
    -- LIABILITIES
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2000', 'LIABILITIES', 'LIABILITY', 'CREDIT', 'Total Liabilities')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2100', 'CURRENT LIABILITIES', 'LIABILITY', 'CREDIT', 'Current Liabilities')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2110', 'Accounts Payable', 'LIABILITY', 'CREDIT', 'Vendor payables')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2120', 'Accrued Payroll', 'LIABILITY', 'CREDIT', 'Accrued payroll and benefits')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2130', 'Sales Tax Payable', 'LIABILITY', 'CREDIT', 'Sales tax collected')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2140', 'Income Tax Payable', 'LIABILITY', 'CREDIT', 'Income taxes payable')
    
    -- LONG-TERM LIABILITIES
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2200', 'LONG-TERM LIABILITIES', 'LIABILITY', 'CREDIT', 'Long-term Liabilities')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2210', 'Equipment Loan', 'LIABILITY', 'CREDIT', 'Equipment financing loan')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '2220', 'Building Mortgage', 'LIABILITY', 'CREDIT', 'Building mortgage loan')
    
    -- EQUITY
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '3000', 'EQUITY', 'EQUITY', 'CREDIT', 'Total Equity')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '3100', 'Common Stock', 'EQUITY', 'CREDIT', 'Common stock issued')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '3200', 'Retained Earnings', 'EQUITY', 'CREDIT', 'Accumulated retained earnings')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '3300', 'Current Year Earnings', 'EQUITY', 'CREDIT', 'Current year net income')
    
    -- REVENUE
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '4000', 'REVENUE', 'REVENUE', 'CREDIT', 'Total Revenue')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '4100', 'Product Sales', 'REVENUE', 'CREDIT', 'Product sales revenue')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '4200', 'Service Revenue', 'REVENUE', 'CREDIT', 'Service revenue')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '4300', 'Interest Income', 'REVENUE', 'CREDIT', 'Interest earned on deposits')
    
    -- EXPENSES
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '5000', 'COST OF GOODS SOLD', 'EXPENSE', 'DEBIT', 'Cost of Goods Sold')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '5100', 'Materials Cost', 'EXPENSE', 'DEBIT', 'Raw materials cost')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '5200', 'Direct Labor', 'EXPENSE', 'DEBIT', 'Direct manufacturing labor')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '5300', 'Manufacturing Overhead', 'EXPENSE', 'DEBIT', 'Manufacturing overhead costs')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6000', 'OPERATING EXPENSES', 'EXPENSE', 'DEBIT', 'Operating Expenses')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6100', 'Salaries and Wages', 'EXPENSE', 'DEBIT', 'Administrative salaries')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6200', 'Employee Benefits', 'EXPENSE', 'DEBIT', 'Employee benefits and insurance')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6300', 'Rent Expense', 'EXPENSE', 'DEBIT', 'Office and warehouse rent')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6400', 'Utilities', 'EXPENSE', 'DEBIT', 'Electricity, gas, water')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6500', 'Insurance Expense', 'EXPENSE', 'DEBIT', 'Business insurance premiums')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6600', 'Depreciation Expense', 'EXPENSE', 'DEBIT', 'Depreciation of fixed assets')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6700', 'Interest Expense', 'EXPENSE', 'DEBIT', 'Interest on loans and debt')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6800', 'Professional Services', 'EXPENSE', 'DEBIT', 'Legal, accounting, consulting')
    
    INTO fin_chart_of_accounts (account_id, company_id, account_code, account_name, account_type, normal_balance, description)
    VALUES (fin_account_seq.NEXTVAL, 1, '6900', 'Office Expenses', 'EXPENSE', 'DEBIT', 'Office supplies and expenses')
SELECT * FROM dual;

-- =============================================================================
-- COST CENTERS
-- =============================================================================

INSERT ALL
    INTO fin_cost_centers (cost_center_id, company_id, cost_center_code, cost_center_name, manager_name, manager_email, budget_amount)
    VALUES (1, 1, 'ADMIN', 'Administration', 'John Smith', 'john.smith@abcmfg.com', 500000)
    
    INTO fin_cost_centers (cost_center_id, company_id, cost_center_code, cost_center_name, manager_name, manager_email, budget_amount)
    VALUES (2, 1, 'PROD', 'Production', 'Mary Johnson', 'mary.johnson@abcmfg.com', 1200000)
    
    INTO fin_cost_centers (cost_center_id, company_id, cost_center_code, cost_center_name, manager_name, manager_email, budget_amount)
    VALUES (3, 1, 'SALES', 'Sales & Marketing', 'David Wilson', 'david.wilson@abcmfg.com', 750000)
    
    INTO fin_cost_centers (cost_center_id, company_id, cost_center_code, cost_center_name, manager_name, manager_email, budget_amount)
    VALUES (4, 1, 'IT', 'Information Technology', 'Sarah Davis', 'sarah.davis@abcmfg.com', 300000)
    
    INTO fin_cost_centers (cost_center_id, company_id, cost_center_code, cost_center_name, manager_name, manager_email, budget_amount)
    VALUES (5, 1, 'QA', 'Quality Assurance', 'Michael Brown', 'michael.brown@abcmfg.com', 200000)
SELECT * FROM dual;

-- =============================================================================
-- CUSTOMERS
-- =============================================================================

INSERT ALL
    INTO fin_customers (customer_id, company_id, customer_code, customer_name, customer_type, contact_person, email, phone, payment_terms, credit_limit)
    VALUES (fin_customer_seq.NEXTVAL, 1, 'CUST001', 'TechCorp Industries', 'PREFERRED', 'Alice Johnson', 'alice@techcorp.com', '555-0101', 'NET30', 100000)
    
    INTO fin_customers (customer_id, company_id, customer_code, customer_name, customer_type, contact_person, email, phone, payment_terms, credit_limit)
    VALUES (fin_customer_seq.NEXTVAL, 1, 'CUST002', 'Global Manufacturing Ltd', 'VIP', 'Bob Chen', 'bob@globalmfg.com', '555-0102', 'NET15', 250000)
    
    INTO fin_customers (customer_id, company_id, customer_code, customer_name, customer_type, contact_person, email, phone, payment_terms, credit_limit)
    VALUES (fin_customer_seq.NEXTVAL, 1, 'CUST003', 'Regional Distributors Inc', 'WHOLESALE', 'Carol Martinez', 'carol@regionaldist.com', '555-0103', 'NET45', 150000)
    
    INTO fin_customers (customer_id, company_id, customer_code, customer_name, customer_type, contact_person, email, phone, payment_terms, credit_limit)
    VALUES (fin_customer_seq.NEXTVAL, 1, 'CUST004', 'Metro Retail Chain', 'RETAIL', 'Dan Kim', 'dan@metroretail.com', '555-0104', 'NET30', 75000)
    
    INTO fin_customers (customer_id, company_id, customer_code, customer_name, customer_type, contact_person, email, phone, payment_terms, credit_limit)
    VALUES (fin_customer_seq.NEXTVAL, 1, 'CUST005', 'Premier Solutions LLC', 'STANDARD', 'Eva Rodriguez', 'eva@premiersol.com', '555-0105', 'NET30', 50000)
SELECT * FROM dual;

-- =============================================================================
-- VENDORS
-- =============================================================================

INSERT ALL
    INTO fin_vendors (vendor_id, company_id, vendor_code, vendor_name, vendor_type, contact_person, email, phone, payment_terms, tax_id)
    VALUES (fin_vendor_seq.NEXTVAL, 1, 'VEND001', 'Steel Supply Co', 'SUPPLIER', 'Frank Wilson', 'frank@steelsupply.com', '555-0201', 'NET30', '12-3456789')
    
    INTO fin_vendors (vendor_id, company_id, vendor_code, vendor_name, vendor_type, contact_person, email, phone, payment_terms, tax_id)
    VALUES (fin_vendor_seq.NEXTVAL, 1, 'VEND002', 'Industrial Equipment Corp', 'SUPPLIER', 'Grace Lee', 'grace@indequip.com', '555-0202', 'NET45', '23-4567890')
    
    INTO fin_vendors (vendor_id, company_id, vendor_code, vendor_name, vendor_type, contact_person, email, phone, payment_terms, tax_id, is_1099_vendor)
    VALUES (fin_vendor_seq.NEXTVAL, 1, 'VEND003', 'ABC Consulting Services', 'SERVICE', 'Henry Park', 'henry@abcconsult.com', '555-0203', 'NET15', '34-5678901', 'Y')
    
    INTO fin_vendors (vendor_id, company_id, vendor_code, vendor_name, vendor_type, contact_person, email, phone, payment_terms, tax_id)
    VALUES (fin_vendor_seq.NEXTVAL, 1, 'VEND004', 'City Electric Utility', 'UTILITY', 'Iris Thompson', 'iris@cityelectric.gov', '555-0204', 'NET10', '45-6789012')
    
    INTO fin_vendors (vendor_id, company_id, vendor_code, vendor_name, vendor_type, contact_person, email, phone, payment_terms, tax_id)
    VALUES (fin_vendor_seq.NEXTVAL, 1, 'VEND005', 'Office Supplies Plus', 'SUPPLIER', 'Jack Brown', 'jack@officesupplies.com', '555-0205', 'NET30', '56-7890123')
    
    INTO fin_vendors (vendor_id, company_id, vendor_code, vendor_name, vendor_type, contact_person, email, phone, payment_terms, tax_id, is_1099_vendor)
    VALUES (fin_vendor_seq.NEXTVAL, 1, 'VEND006', 'Legal Associates LLP', 'SERVICE', 'Karen Davis', 'karen@legalassoc.com', '555-0206', 'NET15', '67-8901234', 'Y')
SELECT * FROM dual;

-- =============================================================================
-- BANK ACCOUNTS
-- =============================================================================

-- Get account IDs for bank GL accounts
DECLARE
    v_cash_operating_id NUMBER;
    v_cash_payroll_id NUMBER;
BEGIN
    SELECT account_id INTO v_cash_operating_id FROM fin_chart_of_accounts WHERE account_code = '1110' AND company_id = 1;
    SELECT account_id INTO v_cash_payroll_id FROM fin_chart_of_accounts WHERE account_code = '1120' AND company_id = 1;
    
    INSERT INTO fin_bank_accounts (bank_account_id, company_id, account_name, account_number, bank_name, bank_routing, account_type, gl_account_id, current_balance)
    VALUES (1, 1, 'Operating Account', '123456789', 'First National Bank', '121000248', 'CHECKING', v_cash_operating_id, 250000);
    
    INSERT INTO fin_bank_accounts (bank_account_id, company_id, account_name, account_number, bank_name, bank_routing, account_type, gl_account_id, current_balance)
    VALUES (2, 1, 'Payroll Account', '987654321', 'First National Bank', '121000248', 'CHECKING', v_cash_payroll_id, 50000);
    
    INSERT INTO fin_bank_accounts (bank_account_id, company_id, account_name, account_number, bank_name, bank_routing, account_type, gl_account_id, current_balance)
    VALUES (3, 1, 'Savings Account', '555666777', 'First National Bank', '121000248', 'SAVINGS', v_cash_operating_id, 100000);
END;
/

-- =============================================================================
-- JOURNAL ENTRIES AND TRANSACTIONS
-- =============================================================================

-- Opening Balance Journal Entry
DECLARE
    v_je_id NUMBER;
    v_cash_acct NUMBER;
    v_ar_acct NUMBER;
    v_inventory_rm_acct NUMBER;
    v_inventory_fg_acct NUMBER;
    v_equipment_acct NUMBER;
    v_building_acct NUMBER;
    v_ap_acct NUMBER;
    v_loan_acct NUMBER;
    v_mortgage_acct NUMBER;
    v_stock_acct NUMBER;
    v_retained_acct NUMBER;
BEGIN
    -- Get account IDs
    SELECT account_id INTO v_cash_acct FROM fin_chart_of_accounts WHERE account_code = '1110' AND company_id = 1;
    SELECT account_id INTO v_ar_acct FROM fin_chart_of_accounts WHERE account_code = '1130' AND company_id = 1;
    SELECT account_id INTO v_inventory_rm_acct FROM fin_chart_of_accounts WHERE account_code = '1140' AND company_id = 1;
    SELECT account_id INTO v_inventory_fg_acct FROM fin_chart_of_accounts WHERE account_code = '1150' AND company_id = 1;
    SELECT account_id INTO v_equipment_acct FROM fin_chart_of_accounts WHERE account_code = '1210' AND company_id = 1;
    SELECT account_id INTO v_building_acct FROM fin_chart_of_accounts WHERE account_code = '1230' AND company_id = 1;
    SELECT account_id INTO v_ap_acct FROM fin_chart_of_accounts WHERE account_code = '2110' AND company_id = 1;
    SELECT account_id INTO v_loan_acct FROM fin_chart_of_accounts WHERE account_code = '2210' AND company_id = 1;
    SELECT account_id INTO v_mortgage_acct FROM fin_chart_of_accounts WHERE account_code = '2220' AND company_id = 1;
    SELECT account_id INTO v_stock_acct FROM fin_chart_of_accounts WHERE account_code = '3100' AND company_id = 1;
    SELECT account_id INTO v_retained_acct FROM fin_chart_of_accounts WHERE account_code = '3200' AND company_id = 1;
    
    -- Create opening balance journal entry
    INSERT INTO fin_journal_entries (
        journal_entry_id, company_id, journal_number, entry_date, description, 
        entry_type, total_debit, total_credit, status, posted_date, posted_by
    ) VALUES (
        fin_journal_entry_seq.NEXTVAL, 1, 'OB-2024-001', DATE '2024-01-01', 
        'Opening balances for fiscal year 2024', 'MANUAL', 1740000, 1740000, 
        'POSTED', SYSDATE, 'SYSTEM'
    ) RETURNING journal_entry_id INTO v_je_id;
    
    -- Insert journal entry lines (DEBITS)
    INSERT ALL
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, debit_amount, description)
        VALUES (1, v_je_id, 1, v_cash_acct, 250000, 'Opening cash balance')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, debit_amount, description)
        VALUES (2, v_je_id, 2, v_ar_acct, 150000, 'Opening accounts receivable')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, debit_amount, description)
        VALUES (3, v_je_id, 3, v_inventory_rm_acct, 75000, 'Opening raw materials inventory')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, debit_amount, description)
        VALUES (4, v_je_id, 4, v_inventory_fg_acct, 125000, 'Opening finished goods inventory')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, debit_amount, description)
        VALUES (5, v_je_id, 5, v_equipment_acct, 800000, 'Opening equipment balance')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, debit_amount, description)
        VALUES (6, v_je_id, 6, v_building_acct, 340000, 'Opening building balance')
    SELECT * FROM dual;
    
    -- Insert journal entry lines (CREDITS)
    INSERT ALL
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, credit_amount, description)
        VALUES (7, v_je_id, 7, v_ap_acct, 85000, 'Opening accounts payable')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, credit_amount, description)
        VALUES (8, v_je_id, 8, v_loan_acct, 200000, 'Opening equipment loan balance')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, credit_amount, description)
        VALUES (9, v_je_id, 9, v_mortgage_acct, 180000, 'Opening building mortgage balance')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, credit_amount, description)
        VALUES (10, v_je_id, 10, v_stock_acct, 500000, 'Opening common stock balance')
        
        INTO fin_journal_entry_lines (line_id, journal_entry_id, line_number, account_id, credit_amount, description)
        VALUES (11, v_je_id, 11, v_retained_acct, 775000, 'Opening retained earnings balance')
    SELECT * FROM dual;
END;
/

-- =============================================================================
-- ACCOUNTS PAYABLE INVOICES
-- =============================================================================

-- Sample AP Invoices
INSERT ALL
    INTO fin_ap_invoices (invoice_id, company_id, vendor_id, invoice_number, vendor_invoice_num, invoice_date, due_date, invoice_amount, tax_amount, total_amount, cost_center_id, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 1000, 'AP-2024-001', 'SS-12345', DATE '2024-01-15', DATE '2024-02-14', 25000, 0, 25000, 2, 'Steel materials for production')
    
    INTO fin_ap_invoices (invoice_id, company_id, vendor_id, invoice_number, vendor_invoice_num, invoice_date, due_date, invoice_amount, tax_amount, total_amount, cost_center_id, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 1001, 'AP-2024-002', 'IE-67890', DATE '2024-01-20', DATE '2024-03-05', 15000, 1200, 16200, 2, 'Equipment maintenance parts')
    
    INTO fin_ap_invoices (invoice_id, company_id, vendor_id, invoice_number, vendor_invoice_num, invoice_date, due_date, invoice_amount, tax_amount, total_amount, cost_center_id, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 1002, 'AP-2024-003', 'ABC-2024-01', DATE '2024-01-25', DATE '2024-02-09', 8500, 0, 8500, 1, 'IT consulting services')
    
    INTO fin_ap_invoices (invoice_id, company_id, vendor_id, invoice_number, vendor_invoice_num, invoice_date, due_date, invoice_amount, tax_amount, total_amount, cost_center_id, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 1003, 'AP-2024-004', 'UTIL-JAN24', DATE '2024-01-31', DATE '2024-02-10', 3200, 0, 3200, 1, 'January electricity bill')
    
    INTO fin_ap_invoices (invoice_id, company_id, vendor_id, invoice_number, vendor_invoice_num, invoice_date, due_date, invoice_amount, tax_amount, total_amount, cost_center_id, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 1004, 'AP-2024-005', 'OSP-5567', DATE '2024-02-01', DATE '2024-03-02', 1250, 100, 1350, 1, 'Office supplies order')
SELECT * FROM dual;

-- =============================================================================
-- ACCOUNTS RECEIVABLE INVOICES
-- =============================================================================

-- Sample AR Invoices
INSERT ALL
    INTO fin_ar_invoices (invoice_id, company_id, customer_id, invoice_number, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 2000, 'INV-2024-001', DATE '2024-01-10', DATE '2024-02-09', 45000, 3600, 48600, 'Custom manufacturing order #1001')
    
    INTO fin_ar_invoices (invoice_id, company_id, customer_id, invoice_number, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 2001, 'INV-2024-002', DATE '2024-01-15', DATE '2024-01-30', 78000, 6240, 84240, 'Bulk order for Q1 requirements')
    
    INTO fin_ar_invoices (invoice_id, company_id, customer_id, invoice_number, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 2002, 'INV-2024-003', DATE '2024-01-20', DATE '2024-03-05', 32000, 2560, 34560, 'Distribution agreement - January delivery')
    
    INTO fin_ar_invoices (invoice_id, company_id, customer_id, invoice_number, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 2003, 'INV-2024-004', DATE '2024-01-25', DATE '2024-02-24', 18500, 1480, 19980, 'Retail products - January shipment')
    
    INTO fin_ar_invoices (invoice_id, company_id, customer_id, invoice_number, invoice_date, due_date, subtotal_amount, tax_amount, total_amount, description)
    VALUES (fin_invoice_seq.NEXTVAL, 1, 2004, 'INV-2024-005', DATE '2024-02-01', DATE '2024-03-02', 12750, 1020, 13770, 'Custom solutions implementation')
SELECT * FROM dual;

-- =============================================================================
-- SAMPLE PAYMENTS
-- =============================================================================

-- AP Payments
INSERT ALL
    INTO fin_ap_payments (payment_id, company_id, vendor_id, payment_number, payment_date, payment_method, check_number, bank_account_id, payment_amount, status)
    VALUES (fin_payment_seq.NEXTVAL, 1, 1002, 'PAY-2024-001', DATE '2024-02-08', 'CHECK', '1001', 1, 8500, 'CLEARED')
    
    INTO fin_ap_payments (payment_id, company_id, vendor_id, payment_number, payment_date, payment_method, check_number, bank_account_id, payment_amount, status)
    VALUES (fin_payment_seq.NEXTVAL, 1, 1003, 'PAY-2024-002', 'DATE 2024-02-09', 'ACH', NULL, 1, 3200, 'CLEARED')
SELECT * FROM dual;

-- AR Payments
INSERT ALL
    INTO fin_ar_payments (payment_id, company_id, customer_id, payment_number, payment_date, payment_method, reference_number, bank_account_id, payment_amount, status)
    VALUES (fin_payment_seq.NEXTVAL, 1, 2000, 'REC-2024-001', DATE '2024-02-08', 'CHECK', 'TC-5678', 1, 48600, 'DEPOSITED')
    
    INTO fin_ar_payments (payment_id, company_id, customer_id, payment_number, payment_date, payment_method, reference_number, bank_account_id, payment_amount, status)
    VALUES (fin_payment_seq.NEXTVAL, 1, 2001, 'REC-2024-002', DATE '2024-01-29', 'ACH', 'GM-WIRE-001', 1, 84240, 'DEPOSITED')
SELECT * FROM dual;

-- =============================================================================
-- BUDGET DATA
-- =============================================================================

-- Create annual budget
DECLARE
    v_budget_id NUMBER;
BEGIN
    INSERT INTO fin_budgets (budget_id, company_id, budget_name, budget_year, budget_type, status, approved_by, approved_date)
    VALUES (fin_budget_seq.NEXTVAL, 1, '2024 Annual Operating Budget', 2024, 'ANNUAL', 'APPROVED', 'CFO', DATE '2023-12-15')
    RETURNING budget_id INTO v_budget_id;
    
    -- Budget details for key accounts (quarterly)
    INSERT ALL
        -- Revenue budget
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, period_year, period_month, budgeted_amount)
        VALUES (1, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '4100'), 2024, 1, 200000)
        
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, period_year, period_month, budgeted_amount)
        VALUES (2, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '4100'), 2024, 2, 220000)
        
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, period_year, period_month, budgeted_amount)
        VALUES (3, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '4100'), 2024, 3, 250000)
        
        -- Cost of goods sold budget
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, period_year, period_month, budgeted_amount)
        VALUES (4, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '5100'), 2024, 1, 80000)
        
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, period_year, period_month, budgeted_amount)
        VALUES (5, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '5100'), 2024, 2, 88000)
        
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, period_year, period_month, budgeted_amount)
        VALUES (6, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '5100'), 2024, 3, 100000)
        
        -- Operating expenses budget
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, cost_center_id, period_year, period_month, budgeted_amount)
        VALUES (7, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '6100'), 1, 2024, 1, 45000)
        
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, cost_center_id, period_year, period_month, budgeted_amount)
        VALUES (8, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '6100'), 1, 2024, 2, 45000)
        
        INTO fin_budget_details (budget_detail_id, budget_id, account_id, cost_center_id, period_year, period_month, budgeted_amount)
        VALUES (9, v_budget_id, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '6100'), 1, 2024, 3, 47000)
    SELECT * FROM dual;
END;
/

-- =============================================================================
-- GENERAL LEDGER MONTHLY SUMMARIES
-- =============================================================================

-- Initialize GL summaries for January 2024
INSERT ALL
    -- Cash account
    INTO fin_general_ledger (gl_id, company_id, account_id, period_year, period_month, beginning_balance, period_debit, period_credit, ending_balance)
    VALUES (1, 1, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '1110'), 2024, 1, 250000, 132840, 11700, 371140)
    
    -- Accounts Receivable
    INTO fin_general_ledger (gl_id, company_id, account_id, period_year, period_month, beginning_balance, period_debit, period_credit, ending_balance)
    VALUES (2, 1, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '1130'), 2024, 1, 150000, 200950, 132840, 218110)
    
    -- Accounts Payable
    INTO fin_general_ledger (gl_id, company_id, account_id, period_year, period_month, beginning_balance, period_debit, period_credit, ending_balance)
    VALUES (3, 1, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '2110'), 2024, 1, 85000, 11700, 54050, 127350)
    
    -- Product Sales Revenue
    INTO fin_general_ledger (gl_id, company_id, account_id, period_year, period_month, beginning_balance, period_debit, period_credit, ending_balance)
    VALUES (4, 1, (SELECT account_id FROM fin_chart_of_accounts WHERE account_code = '4100'), 2024, 1, 0, 0, 186250, 186250)
SELECT * FROM dual;

-- =============================================================================
-- PERIOD CONTROL
-- =============================================================================

-- Set up period control for 2024
INSERT ALL
    INTO fin_period_control (control_id, company_id, period_year, period_month, status)
    VALUES (1, 1, 2024, 1, 'CLOSED')
    
    INTO fin_period_control (control_id, company_id, period_year, period_month, status)
    VALUES (2, 1, 2024, 2, 'OPEN')
    
    INTO fin_period_control (control_id, company_id, period_year, period_month, status)
    VALUES (3, 1, 2024, 3, 'OPEN')
SELECT * FROM dual;

-- Commit all changes
COMMIT;

PROMPT Financial Management Sample Data loaded successfully!
PROMPT ========================================================

-- Display data summary
SELECT 'Chart of Accounts' AS entity, COUNT(*) AS count FROM fin_chart_of_accounts WHERE company_id = 1
UNION ALL
SELECT 'Customers', COUNT(*) FROM fin_customers WHERE company_id = 1
UNION ALL
SELECT 'Vendors', COUNT(*) FROM fin_vendors WHERE company_id = 1
UNION ALL
SELECT 'AP Invoices', COUNT(*) FROM fin_ap_invoices WHERE company_id = 1
UNION ALL
SELECT 'AR Invoices', COUNT(*) FROM fin_ar_invoices WHERE company_id = 1
UNION ALL
SELECT 'Journal Entries', COUNT(*) FROM fin_journal_entries WHERE company_id = 1
UNION ALL
SELECT 'Budget Details', COUNT(*) FROM fin_budget_details
UNION ALL
SELECT 'Bank Accounts', COUNT(*) FROM fin_bank_accounts WHERE company_id = 1;

PROMPT
PROMPT Sample data includes:
PROMPT - Complete chart of accounts (40+ accounts)
PROMPT - 5 customers and 6 vendors
PROMPT - Opening balance journal entry
PROMPT - 5 AP invoices and 5 AR invoices
PROMPT - Sample payments and allocations
PROMPT - 2024 annual budget with quarterly details
PROMPT - General ledger monthly summaries
PROMPT - Period control setup
PROMPT
PROMPT Financial system ready for testing and procedures!
