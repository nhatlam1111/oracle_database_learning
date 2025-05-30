-- Financial Management System - Stored Procedures and Functions
-- Business logic for financial operations
-- Part of Lesson 6: Practice and Application

-- Set proper formatting for output
SET LINESIZE 200
SET PAGESIZE 100
SET ECHO ON
SET FEEDBACK ON
SET SERVEROUTPUT ON SIZE 1000000

PROMPT Creating Financial Management Procedures and Functions...

-- =============================================================================
-- UTILITY FUNCTIONS
-- =============================================================================

-- Function to get next journal entry number
CREATE OR REPLACE FUNCTION get_next_journal_number(
    p_company_id IN NUMBER,
    p_prefix IN VARCHAR2 DEFAULT 'JE'
) RETURN VARCHAR2 IS
    v_next_number NUMBER;
    v_year VARCHAR2(4);
BEGIN
    v_year := TO_CHAR(SYSDATE, 'YYYY');
    
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(journal_number, -3))), 0) + 1
    INTO v_next_number
    FROM fin_journal_entries
    WHERE company_id = p_company_id
    AND journal_number LIKE p_prefix || '-' || v_year || '-%';
    
    RETURN p_prefix || '-' || v_year || '-' || LPAD(v_next_number, 3, '0');
END get_next_journal_number;
/

-- Function to validate journal entry balance
CREATE OR REPLACE FUNCTION validate_je_balance(p_journal_entry_id IN NUMBER) 
RETURN BOOLEAN IS
    v_debit_total NUMBER := 0;
    v_credit_total NUMBER := 0;
BEGIN
    SELECT 
        NVL(SUM(debit_amount), 0),
        NVL(SUM(credit_amount), 0)
    INTO v_debit_total, v_credit_total
    FROM fin_journal_entry_lines
    WHERE journal_entry_id = p_journal_entry_id;
    
    RETURN ABS(v_debit_total - v_credit_total) < 0.01; -- Allow for minor rounding differences
END validate_je_balance;
/

-- Function to get account balance
CREATE OR REPLACE FUNCTION get_account_balance(
    p_account_id IN NUMBER,
    p_as_of_date IN DATE DEFAULT SYSDATE
) RETURN NUMBER IS
    v_balance NUMBER := 0;
    v_normal_balance VARCHAR2(6);
BEGIN
    -- Get normal balance type
    SELECT normal_balance
    INTO v_normal_balance
    FROM fin_chart_of_accounts
    WHERE account_id = p_account_id;
    
    -- Calculate balance from journal entries
    SELECT 
        CASE v_normal_balance
            WHEN 'DEBIT' THEN NVL(SUM(debit_amount - credit_amount), 0)
            WHEN 'CREDIT' THEN NVL(SUM(credit_amount - debit_amount), 0)
        END
    INTO v_balance
    FROM fin_journal_entry_lines jel
    JOIN fin_journal_entries je ON jel.journal_entry_id = je.journal_entry_id
    WHERE jel.account_id = p_account_id
    AND je.status = 'POSTED'
    AND je.entry_date <= p_as_of_date;
    
    RETURN NVL(v_balance, 0);
END get_account_balance;
/

-- =============================================================================
-- JOURNAL ENTRY PROCEDURES
-- =============================================================================

-- Create journal entry header
CREATE OR REPLACE PROCEDURE create_journal_entry(
    p_company_id IN NUMBER,
    p_description IN VARCHAR2,
    p_entry_date IN DATE DEFAULT SYSDATE,
    p_entry_type IN VARCHAR2 DEFAULT 'MANUAL',
    p_source_module IN VARCHAR2 DEFAULT 'GL',
    p_reference_number IN VARCHAR2 DEFAULT NULL,
    p_journal_entry_id OUT NUMBER,
    p_journal_number OUT VARCHAR2,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_journal_number VARCHAR2(20);
BEGIN
    -- Generate journal number
    v_journal_number := get_next_journal_number(p_company_id);
    
    -- Insert journal entry header
    INSERT INTO fin_journal_entries (
        journal_entry_id, company_id, journal_number, entry_date,
        description, entry_type, source_module, reference_number,
        status, created_date, created_by
    ) VALUES (
        fin_journal_entry_seq.NEXTVAL, p_company_id, v_journal_number, p_entry_date,
        p_description, p_entry_type, p_source_module, p_reference_number,
        'DRAFT', CURRENT_TIMESTAMP, USER
    ) RETURNING journal_entry_id INTO p_journal_entry_id;
    
    p_journal_number := v_journal_number;
    p_status := 'SUCCESS';
    p_message := 'Journal entry created successfully: ' || v_journal_number;
    
    DBMS_OUTPUT.PUT_LINE('Created journal entry: ' || v_journal_number);
    
EXCEPTION
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Error creating journal entry: ' || SQLERRM;
        p_journal_entry_id := NULL;
        p_journal_number := NULL;
        ROLLBACK;
END create_journal_entry;
/

-- Add journal entry line
CREATE OR REPLACE PROCEDURE add_journal_entry_line(
    p_journal_entry_id IN NUMBER,
    p_account_id IN NUMBER,
    p_debit_amount IN NUMBER DEFAULT 0,
    p_credit_amount IN NUMBER DEFAULT 0,
    p_description IN VARCHAR2 DEFAULT NULL,
    p_cost_center_id IN NUMBER DEFAULT NULL,
    p_reference_number IN VARCHAR2 DEFAULT NULL,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_line_number NUMBER;
    v_je_status VARCHAR2(10);
BEGIN
    -- Validate journal entry status
    SELECT status INTO v_je_status
    FROM fin_journal_entries
    WHERE journal_entry_id = p_journal_entry_id;
    
    IF v_je_status != 'DRAFT' THEN
        p_status := 'ERROR';
        p_message := 'Cannot add lines to posted journal entry';
        RETURN;
    END IF;
    
    -- Validate amounts
    IF p_debit_amount < 0 OR p_credit_amount < 0 THEN
        p_status := 'ERROR';
        p_message := 'Amounts cannot be negative';
        RETURN;
    END IF;
    
    IF (p_debit_amount > 0 AND p_credit_amount > 0) OR 
       (p_debit_amount = 0 AND p_credit_amount = 0) THEN
        p_status := 'ERROR';
        p_message := 'Must specify either debit or credit amount, not both or neither';
        RETURN;
    END IF;
    
    -- Get next line number
    SELECT NVL(MAX(line_number), 0) + 1
    INTO v_line_number
    FROM fin_journal_entry_lines
    WHERE journal_entry_id = p_journal_entry_id;
    
    -- Insert journal entry line
    INSERT INTO fin_journal_entry_lines (
        line_id, journal_entry_id, line_number, account_id,
        debit_amount, credit_amount, description, cost_center_id,
        reference_number, created_date, created_by
    ) VALUES (
        v_line_number, p_journal_entry_id, v_line_number, p_account_id,
        p_debit_amount, p_credit_amount, p_description, p_cost_center_id,
        p_reference_number, CURRENT_TIMESTAMP, USER
    );
    
    p_status := 'SUCCESS';
    p_message := 'Journal entry line added successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Error adding journal entry line: ' || SQLERRM;
        ROLLBACK;
END add_journal_entry_line;
/

-- Post journal entry
CREATE OR REPLACE PROCEDURE post_journal_entry(
    p_journal_entry_id IN NUMBER,
    p_posting_date IN DATE DEFAULT SYSDATE,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_total_debit NUMBER := 0;
    v_total_credit NUMBER := 0;
    v_je_status VARCHAR2(10);
    v_company_id NUMBER;
    v_period_year NUMBER;
    v_period_month NUMBER;
    v_period_status VARCHAR2(10);
BEGIN
    -- Validate journal entry exists and is in draft status
    SELECT status, company_id
    INTO v_je_status, v_company_id
    FROM fin_journal_entries
    WHERE journal_entry_id = p_journal_entry_id;
    
    IF v_je_status != 'DRAFT' THEN
        p_status := 'ERROR';
        p_message := 'Journal entry is not in draft status';
        RETURN;
    END IF;
    
    -- Check if period is open
    v_period_year := EXTRACT(YEAR FROM p_posting_date);
    v_period_month := EXTRACT(MONTH FROM p_posting_date);
    
    BEGIN
        SELECT status INTO v_period_status
        FROM fin_period_control
        WHERE company_id = v_company_id
        AND period_year = v_period_year
        AND period_month = v_period_month;
        
        IF v_period_status != 'OPEN' THEN
            p_status := 'ERROR';
            p_message := 'Period ' || v_period_month || '/' || v_period_year || ' is closed';
            RETURN;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Period doesn't exist, create it as open
            INSERT INTO fin_period_control (
                control_id, company_id, period_year, period_month, status
            ) VALUES (
                v_period_year * 100 + v_period_month, v_company_id, 
                v_period_year, v_period_month, 'OPEN'
            );
    END;
    
    -- Validate journal entry balance
    IF NOT validate_je_balance(p_journal_entry_id) THEN
        p_status := 'ERROR';
        p_message := 'Journal entry is not in balance';
        RETURN;
    END IF;
    
    -- Calculate totals
    SELECT 
        NVL(SUM(debit_amount), 0),
        NVL(SUM(credit_amount), 0)
    INTO v_total_debit, v_total_credit
    FROM fin_journal_entry_lines
    WHERE journal_entry_id = p_journal_entry_id;
    
    -- Update journal entry header
    UPDATE fin_journal_entries
    SET status = 'POSTED',
        posting_date = p_posting_date,
        posted_date = CURRENT_TIMESTAMP,
        posted_by = USER,
        total_debit = v_total_debit,
        total_credit = v_total_credit
    WHERE journal_entry_id = p_journal_entry_id;
    
    -- Update general ledger balances
    update_gl_balances(p_journal_entry_id, p_posting_date);
    
    p_status := 'SUCCESS';
    p_message := 'Journal entry posted successfully';
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Error posting journal entry: ' || SQLERRM;
        ROLLBACK;
END post_journal_entry;
/

-- Update general ledger balances
CREATE OR REPLACE PROCEDURE update_gl_balances(
    p_journal_entry_id IN NUMBER,
    p_posting_date IN DATE
) IS
    v_company_id NUMBER;
    v_period_year NUMBER;
    v_period_month NUMBER;
    
    CURSOR je_lines IS
        SELECT account_id, cost_center_id, debit_amount, credit_amount
        FROM fin_journal_entry_lines
        WHERE journal_entry_id = p_journal_entry_id;
BEGIN
    -- Get company and period info
    SELECT company_id INTO v_company_id
    FROM fin_journal_entries
    WHERE journal_entry_id = p_journal_entry_id;
    
    v_period_year := EXTRACT(YEAR FROM p_posting_date);
    v_period_month := EXTRACT(MONTH FROM p_posting_date);
    
    -- Process each journal entry line
    FOR line_rec IN je_lines LOOP
        -- Update or insert GL balance
        MERGE INTO fin_general_ledger gl
        USING (
            SELECT 
                v_company_id AS company_id,
                line_rec.account_id AS account_id,
                line_rec.cost_center_id AS cost_center_id,
                v_period_year AS period_year,
                v_period_month AS period_month,
                line_rec.debit_amount AS debit_amount,
                line_rec.credit_amount AS credit_amount
            FROM dual
        ) src ON (
            gl.company_id = src.company_id
            AND gl.account_id = src.account_id
            AND NVL(gl.cost_center_id, -1) = NVL(src.cost_center_id, -1)
            AND gl.period_year = src.period_year
            AND gl.period_month = src.period_month
        )
        WHEN MATCHED THEN
            UPDATE SET
                period_debit = period_debit + src.debit_amount,
                period_credit = period_credit + src.credit_amount,
                ending_balance = beginning_balance + period_debit + src.debit_amount 
                                - period_credit - src.credit_amount,
                last_updated = CURRENT_TIMESTAMP
        WHEN NOT MATCHED THEN
            INSERT (
                gl_id, company_id, account_id, cost_center_id,
                period_year, period_month, beginning_balance,
                period_debit, period_credit, ending_balance
            ) VALUES (
                v_company_id * 100000 + line_rec.account_id * 100 + v_period_year,
                v_company_id, line_rec.account_id, line_rec.cost_center_id,
                v_period_year, v_period_month, 0,
                line_rec.debit_amount, line_rec.credit_amount,
                line_rec.debit_amount - line_rec.credit_amount
            );
    END LOOP;
END update_gl_balances;
/

-- =============================================================================
-- ACCOUNTS PAYABLE PROCEDURES
-- =============================================================================

-- Create vendor invoice
CREATE OR REPLACE PROCEDURE create_ap_invoice(
    p_company_id IN NUMBER,
    p_vendor_id IN NUMBER,
    p_vendor_invoice_num IN VARCHAR2,
    p_invoice_date IN DATE,
    p_due_date IN DATE,
    p_invoice_amount IN NUMBER,
    p_tax_amount IN NUMBER DEFAULT 0,
    p_description IN VARCHAR2,
    p_cost_center_id IN NUMBER DEFAULT NULL,
    p_invoice_id OUT NUMBER,
    p_invoice_number OUT VARCHAR2,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_invoice_number VARCHAR2(50);
    v_total_amount NUMBER;
    v_je_id NUMBER;
    v_je_number VARCHAR2(20);
    v_je_status VARCHAR2(20);
    v_je_message VARCHAR2(500);
    v_ap_account_id NUMBER;
    v_expense_account_id NUMBER;
BEGIN
    -- Generate invoice number
    SELECT 'AP-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
           LPAD(fin_invoice_seq.NEXTVAL, 3, '0')
    INTO v_invoice_number FROM dual;
    
    v_total_amount := p_invoice_amount + p_tax_amount;
    
    -- Get account IDs
    SELECT account_id INTO v_ap_account_id
    FROM fin_chart_of_accounts
    WHERE company_id = p_company_id AND account_code = '2110';
    
    SELECT account_id INTO v_expense_account_id
    FROM fin_chart_of_accounts
    WHERE company_id = p_company_id AND account_code = '6800'; -- Professional Services
    
    -- Create journal entry for the invoice
    create_journal_entry(
        p_company_id => p_company_id,
        p_description => 'AP Invoice: ' || v_invoice_number || ' - ' || p_description,
        p_entry_date => p_invoice_date,
        p_entry_type => 'AUTOMATIC',
        p_source_module => 'AP',
        p_reference_number => v_invoice_number,
        p_journal_entry_id => v_je_id,
        p_journal_number => v_je_number,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    IF v_je_status != 'SUCCESS' THEN
        p_status := 'ERROR';
        p_message := 'Failed to create journal entry: ' || v_je_message;
        RETURN;
    END IF;
    
    -- Add journal entry lines
    -- Debit: Expense
    add_journal_entry_line(
        p_journal_entry_id => v_je_id,
        p_account_id => v_expense_account_id,
        p_debit_amount => v_total_amount,
        p_description => p_description,
        p_cost_center_id => p_cost_center_id,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Credit: Accounts Payable
    add_journal_entry_line(
        p_journal_entry_id => v_je_id,
        p_account_id => v_ap_account_id,
        p_credit_amount => v_total_amount,
        p_description => 'Vendor: ' || p_vendor_id,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Post the journal entry
    post_journal_entry(
        p_journal_entry_id => v_je_id,
        p_posting_date => p_invoice_date,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Insert AP invoice record
    INSERT INTO fin_ap_invoices (
        invoice_id, company_id, vendor_id, invoice_number,
        vendor_invoice_num, invoice_date, due_date, invoice_amount,
        tax_amount, total_amount, description, cost_center_id,
        journal_entry_id, status, created_date, created_by
    ) VALUES (
        fin_invoice_seq.NEXTVAL, p_company_id, p_vendor_id, v_invoice_number,
        p_vendor_invoice_num, p_invoice_date, p_due_date, p_invoice_amount,
        p_tax_amount, v_total_amount, p_description, p_cost_center_id,
        v_je_id, 'OPEN', CURRENT_TIMESTAMP, USER
    ) RETURNING invoice_id INTO p_invoice_id;
    
    p_invoice_number := v_invoice_number;
    p_status := 'SUCCESS';
    p_message := 'AP invoice created successfully: ' || v_invoice_number;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Error creating AP invoice: ' || SQLERRM;
        p_invoice_id := NULL;
        p_invoice_number := NULL;
        ROLLBACK;
END create_ap_invoice;
/

-- Process vendor payment
CREATE OR REPLACE PROCEDURE process_vendor_payment(
    p_company_id IN NUMBER,
    p_vendor_id IN NUMBER,
    p_payment_amount IN NUMBER,
    p_payment_date IN DATE DEFAULT SYSDATE,
    p_payment_method IN VARCHAR2 DEFAULT 'CHECK',
    p_bank_account_id IN NUMBER,
    p_check_number IN VARCHAR2 DEFAULT NULL,
    p_memo IN VARCHAR2 DEFAULT NULL,
    p_invoice_ids IN SYS.ODCINUMBERLIST DEFAULT NULL,
    p_payment_id OUT NUMBER,
    p_payment_number OUT VARCHAR2,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_payment_number VARCHAR2(30);
    v_je_id NUMBER;
    v_je_number VARCHAR2(20);
    v_je_status VARCHAR2(20);
    v_je_message VARCHAR2(500);
    v_ap_account_id NUMBER;
    v_cash_account_id NUMBER;
    v_remaining_amount NUMBER;
BEGIN
    -- Generate payment number
    SELECT 'PAY-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
           LPAD(fin_payment_seq.NEXTVAL, 4, '0')
    INTO v_payment_number FROM dual;
    
    -- Get account IDs
    SELECT account_id INTO v_ap_account_id
    FROM fin_chart_of_accounts
    WHERE company_id = p_company_id AND account_code = '2110';
    
    SELECT gl_account_id INTO v_cash_account_id
    FROM fin_bank_accounts
    WHERE bank_account_id = p_bank_account_id;
    
    -- Create journal entry for payment
    create_journal_entry(
        p_company_id => p_company_id,
        p_description => 'Vendor Payment: ' || v_payment_number,
        p_entry_date => p_payment_date,
        p_entry_type => 'AUTOMATIC',
        p_source_module => 'AP',
        p_reference_number => v_payment_number,
        p_journal_entry_id => v_je_id,
        p_journal_number => v_je_number,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Add journal entry lines
    -- Debit: Accounts Payable
    add_journal_entry_line(
        p_journal_entry_id => v_je_id,
        p_account_id => v_ap_account_id,
        p_debit_amount => p_payment_amount,
        p_description => 'Payment to vendor ' || p_vendor_id,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Credit: Cash
    add_journal_entry_line(
        p_journal_entry_id => v_je_id,
        p_account_id => v_cash_account_id,
        p_credit_amount => p_payment_amount,
        p_description => 'Payment via ' || p_payment_method,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Post journal entry
    post_journal_entry(
        p_journal_entry_id => v_je_id,
        p_posting_date => p_payment_date,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Insert payment record
    INSERT INTO fin_ap_payments (
        payment_id, company_id, vendor_id, payment_number,
        payment_date, payment_method, check_number, bank_account_id,
        payment_amount, memo, journal_entry_id, status
    ) VALUES (
        fin_payment_seq.NEXTVAL, p_company_id, p_vendor_id, v_payment_number,
        p_payment_date, p_payment_method, p_check_number, p_bank_account_id,
        p_payment_amount, p_memo, v_je_id, 'ISSUED'
    ) RETURNING payment_id INTO p_payment_id;
    
    -- Allocate payment to invoices if specified
    IF p_invoice_ids IS NOT NULL AND p_invoice_ids.COUNT > 0 THEN
        v_remaining_amount := p_payment_amount;
        
        FOR i IN 1..p_invoice_ids.COUNT LOOP
            EXIT WHEN v_remaining_amount <= 0;
            
            DECLARE
                v_invoice_balance NUMBER;
                v_allocation_amount NUMBER;
            BEGIN
                -- Get invoice balance
                SELECT total_amount - paid_amount
                INTO v_invoice_balance
                FROM fin_ap_invoices
                WHERE invoice_id = p_invoice_ids(i);
                
                -- Calculate allocation amount
                v_allocation_amount := LEAST(v_remaining_amount, v_invoice_balance);
                
                -- Create allocation record
                INSERT INTO fin_ap_payment_allocations (
                    allocation_id, payment_id, invoice_id, allocated_amount
                ) VALUES (
                    p_payment_id * 1000 + i, p_payment_id, p_invoice_ids(i), v_allocation_amount
                );
                
                -- Update invoice paid amount
                UPDATE fin_ap_invoices
                SET paid_amount = paid_amount + v_allocation_amount,
                    status = CASE 
                        WHEN paid_amount + v_allocation_amount >= total_amount THEN 'PAID'
                        WHEN paid_amount + v_allocation_amount > 0 THEN 'PARTIAL'
                        ELSE status
                    END
                WHERE invoice_id = p_invoice_ids(i);
                
                v_remaining_amount := v_remaining_amount - v_allocation_amount;
            END;
        END LOOP;
    END IF;
    
    p_payment_number := v_payment_number;
    p_status := 'SUCCESS';
    p_message := 'Payment processed successfully: ' || v_payment_number;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Error processing payment: ' || SQLERRM;
        p_payment_id := NULL;
        p_payment_number := NULL;
        ROLLBACK;
END process_vendor_payment;
/

-- =============================================================================
-- ACCOUNTS RECEIVABLE PROCEDURES
-- =============================================================================

-- Create customer invoice
CREATE OR REPLACE PROCEDURE create_ar_invoice(
    p_company_id IN NUMBER,
    p_customer_id IN NUMBER,
    p_invoice_date IN DATE,
    p_due_date IN DATE,
    p_subtotal_amount IN NUMBER,
    p_tax_amount IN NUMBER DEFAULT 0,
    p_description IN VARCHAR2,
    p_invoice_id OUT NUMBER,
    p_invoice_number OUT VARCHAR2,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
) IS
    v_invoice_number VARCHAR2(50);
    v_total_amount NUMBER;
    v_je_id NUMBER;
    v_je_number VARCHAR2(20);
    v_je_status VARCHAR2(20);
    v_je_message VARCHAR2(500);
    v_ar_account_id NUMBER;
    v_revenue_account_id NUMBER;
    v_tax_account_id NUMBER;
BEGIN
    -- Generate invoice number
    SELECT 'INV-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || 
           LPAD(fin_invoice_seq.NEXTVAL, 3, '0')
    INTO v_invoice_number FROM dual;
    
    v_total_amount := p_subtotal_amount + p_tax_amount;
    
    -- Get account IDs
    SELECT account_id INTO v_ar_account_id
    FROM fin_chart_of_accounts
    WHERE company_id = p_company_id AND account_code = '1130';
    
    SELECT account_id INTO v_revenue_account_id
    FROM fin_chart_of_accounts
    WHERE company_id = p_company_id AND account_code = '4100';
    
    SELECT account_id INTO v_tax_account_id
    FROM fin_chart_of_accounts
    WHERE company_id = p_company_id AND account_code = '2130';
    
    -- Create journal entry
    create_journal_entry(
        p_company_id => p_company_id,
        p_description => 'AR Invoice: ' || v_invoice_number || ' - ' || p_description,
        p_entry_date => p_invoice_date,
        p_entry_type => 'AUTOMATIC',
        p_source_module => 'AR',
        p_reference_number => v_invoice_number,
        p_journal_entry_id => v_je_id,
        p_journal_number => v_je_number,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Add journal entry lines
    -- Debit: Accounts Receivable
    add_journal_entry_line(
        p_journal_entry_id => v_je_id,
        p_account_id => v_ar_account_id,
        p_debit_amount => v_total_amount,
        p_description => 'Customer: ' || p_customer_id,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Credit: Revenue
    add_journal_entry_line(
        p_journal_entry_id => v_je_id,
        p_account_id => v_revenue_account_id,
        p_credit_amount => p_subtotal_amount,
        p_description => p_description,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Credit: Sales Tax (if applicable)
    IF p_tax_amount > 0 THEN
        add_journal_entry_line(
            p_journal_entry_id => v_je_id,
            p_account_id => v_tax_account_id,
            p_credit_amount => p_tax_amount,
            p_description => 'Sales tax',
            p_status => v_je_status,
            p_message => v_je_message
        );
    END IF;
    
    -- Post journal entry
    post_journal_entry(
        p_journal_entry_id => v_je_id,
        p_posting_date => p_invoice_date,
        p_status => v_je_status,
        p_message => v_je_message
    );
    
    -- Insert AR invoice record
    INSERT INTO fin_ar_invoices (
        invoice_id, company_id, customer_id, invoice_number,
        invoice_date, due_date, subtotal_amount, tax_amount,
        total_amount, description, journal_entry_id, status
    ) VALUES (
        fin_invoice_seq.NEXTVAL, p_company_id, p_customer_id, v_invoice_number,
        p_invoice_date, p_due_date, p_subtotal_amount, p_tax_amount,
        v_total_amount, p_description, v_je_id, 'OPEN'
    ) RETURNING invoice_id INTO p_invoice_id;
    
    p_invoice_number := v_invoice_number;
    p_status := 'SUCCESS';
    p_message := 'AR invoice created successfully: ' || v_invoice_number;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Error creating AR invoice: ' || SQLERRM;
        ROLLBACK;
END create_ar_invoice;
/

-- =============================================================================
-- REPORTING FUNCTIONS
-- =============================================================================

-- Generate trial balance
CREATE OR REPLACE FUNCTION generate_trial_balance(
    p_company_id IN NUMBER,
    p_as_of_date IN DATE DEFAULT SYSDATE
) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT 
            coa.account_code,
            coa.account_name,
            coa.account_type,
            coa.normal_balance,
            NVL(SUM(CASE WHEN coa.normal_balance = 'DEBIT' 
                        THEN jel.debit_amount - jel.credit_amount
                        ELSE jel.credit_amount - jel.debit_amount END), 0) AS balance,
            CASE WHEN NVL(SUM(CASE WHEN coa.normal_balance = 'DEBIT' 
                              THEN jel.debit_amount - jel.credit_amount
                              ELSE jel.credit_amount - jel.debit_amount END), 0) >= 0
                 THEN NVL(SUM(CASE WHEN coa.normal_balance = 'DEBIT' 
                              THEN jel.debit_amount - jel.credit_amount
                              ELSE jel.credit_amount - jel.debit_amount END), 0)
                 ELSE 0 END AS debit_balance,
            CASE WHEN NVL(SUM(CASE WHEN coa.normal_balance = 'DEBIT' 
                              THEN jel.debit_amount - jel.credit_amount
                              ELSE jel.credit_amount - jel.debit_amount END), 0) < 0
                 THEN ABS(NVL(SUM(CASE WHEN coa.normal_balance = 'DEBIT' 
                                  THEN jel.debit_amount - jel.credit_amount
                                  ELSE jel.credit_amount - jel.debit_amount END), 0))
                 ELSE 0 END AS credit_balance
        FROM fin_chart_of_accounts coa
        LEFT JOIN fin_journal_entry_lines jel ON coa.account_id = jel.account_id
        LEFT JOIN fin_journal_entries je ON jel.journal_entry_id = je.journal_entry_id
            AND je.status = 'POSTED'
            AND je.entry_date <= p_as_of_date
        WHERE coa.company_id = p_company_id
        AND coa.is_active = 'Y'
        GROUP BY coa.account_code, coa.account_name, coa.account_type, coa.normal_balance
        ORDER BY coa.account_code;
        
    RETURN v_cursor;
END generate_trial_balance;
/

-- Generate aging report
CREATE OR REPLACE FUNCTION generate_ar_aging(
    p_company_id IN NUMBER,
    p_as_of_date IN DATE DEFAULT SYSDATE
) RETURN SYS_REFCURSOR IS
    v_cursor SYS_REFCURSOR;
BEGIN
    OPEN v_cursor FOR
        SELECT 
            c.customer_name,
            i.invoice_number,
            i.invoice_date,
            i.due_date,
            i.total_amount - i.paid_amount AS outstanding_amount,
            p_as_of_date - i.due_date AS days_overdue,
            CASE 
                WHEN p_as_of_date <= i.due_date THEN i.total_amount - i.paid_amount
                ELSE 0 
            END AS current_amount,
            CASE 
                WHEN p_as_of_date - i.due_date BETWEEN 1 AND 30 THEN i.total_amount - i.paid_amount
                ELSE 0 
            END AS days_1_30,
            CASE 
                WHEN p_as_of_date - i.due_date BETWEEN 31 AND 60 THEN i.total_amount - i.paid_amount
                ELSE 0 
            END AS days_31_60,
            CASE 
                WHEN p_as_of_date - i.due_date BETWEEN 61 AND 90 THEN i.total_amount - i.paid_amount
                ELSE 0 
            END AS days_61_90,
            CASE 
                WHEN p_as_of_date - i.due_date > 90 THEN i.total_amount - i.paid_amount
                ELSE 0 
            END AS days_over_90
        FROM fin_ar_invoices i
        JOIN fin_customers c ON i.customer_id = c.customer_id
        WHERE i.company_id = p_company_id
        AND i.total_amount - i.paid_amount > 0
        AND i.status IN ('OPEN', 'PARTIAL')
        ORDER BY c.customer_name, i.due_date;
        
    RETURN v_cursor;
END generate_ar_aging;
/

PROMPT Financial Management Procedures created successfully!
PROMPT =====================================================

-- Display procedure summary
SELECT 
    object_name,
    object_type,
    status,
    created
FROM user_objects 
WHERE object_name LIKE 'CREATE_%' 
   OR object_name LIKE 'PROCESS_%'
   OR object_name LIKE 'GENERATE_%'
   OR object_name LIKE 'GET_%'
   OR object_name LIKE 'VALIDATE_%'
   OR object_name LIKE 'UPDATE_%'
   OR object_name LIKE 'ADD_%'
   OR object_name LIKE 'POST_%'
ORDER BY object_type, object_name;

PROMPT
PROMPT Financial Management Procedures Summary:
PROMPT - Journal entry creation and posting
PROMPT - General ledger balance updates
PROMPT - Accounts payable invoice and payment processing
PROMPT - Accounts receivable invoice creation
PROMPT - Trial balance generation
PROMPT - Accounts receivable aging reports
PROMPT - Comprehensive error handling and validation
PROMPT
PROMPT All procedures ready for use in financial operations!
