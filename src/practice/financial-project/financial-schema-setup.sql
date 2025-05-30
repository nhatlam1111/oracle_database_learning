-- Financial Management System - Database Schema
-- Complete accounting and financial management database
-- Part of Lesson 6: Practice and Application

-- Set proper formatting for output
SET LINESIZE 200
SET PAGESIZE 100
SET ECHO ON
SET FEEDBACK ON

-- Clean up existing objects
PROMPT Cleaning up existing financial schema objects...
BEGIN
    -- Drop tables in reverse dependency order
    FOR t IN (
        SELECT table_name FROM user_tables 
        WHERE table_name LIKE 'FIN_%' 
        ORDER BY table_name DESC
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
            DBMS_OUTPUT.PUT_LINE('Dropped table: ' || t.table_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Could not drop ' || t.table_name || ': ' || SQLERRM);
        END;
    END LOOP;
    
    -- Drop sequences
    FOR s IN (
        SELECT sequence_name FROM user_sequences 
        WHERE sequence_name LIKE 'FIN_%'
    ) LOOP
        BEGIN
            EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
            DBMS_OUTPUT.PUT_LINE('Dropped sequence: ' || s.sequence_name);
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Could not drop ' || s.sequence_name || ': ' || SQLERRM);
        END;
    END LOOP;
END;
/

PROMPT Creating Financial Management System Schema...

-- =============================================================================
-- SEQUENCES
-- =============================================================================

CREATE SEQUENCE fin_company_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_account_seq START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_transaction_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_journal_entry_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_invoice_seq START WITH 10000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_payment_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_budget_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_report_seq START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_vendor_seq START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_customer_seq START WITH 2000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_product_seq START WITH 5000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE fin_audit_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- =============================================================================
-- CORE MASTER DATA TABLES
-- =============================================================================

-- Company/Entity Information
CREATE TABLE fin_companies (
    company_id          NUMBER PRIMARY KEY,
    company_code        VARCHAR2(10) UNIQUE NOT NULL,
    company_name        VARCHAR2(100) NOT NULL,
    legal_name          VARCHAR2(150),
    tax_id              VARCHAR2(20),
    registration_number VARCHAR2(30),
    address_line1       VARCHAR2(100),
    address_line2       VARCHAR2(100),
    city                VARCHAR2(50),
    state_province      VARCHAR2(50),
    postal_code         VARCHAR2(20),
    country             VARCHAR2(50) DEFAULT 'US',
    phone               VARCHAR2(20),
    email               VARCHAR2(100),
    website             VARCHAR2(100),
    fiscal_year_start   DATE DEFAULT TRUNC(SYSDATE, 'YYYY'),
    base_currency       VARCHAR2(3) DEFAULT 'USD',
    status              VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    last_updated        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR2(50) DEFAULT USER
);

-- Chart of Accounts
CREATE TABLE fin_chart_of_accounts (
    account_id          NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    account_code        VARCHAR2(20) NOT NULL,
    account_name        VARCHAR2(100) NOT NULL,
    account_type        VARCHAR2(20) NOT NULL CHECK (account_type IN 
        ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE', 'CONTRA')),
    account_subtype     VARCHAR2(30),
    parent_account_id   NUMBER,
    account_level       NUMBER DEFAULT 1,
    is_active           CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    is_posting_account  CHAR(1) DEFAULT 'Y' CHECK (is_posting_account IN ('Y', 'N')),
    normal_balance      VARCHAR2(6) CHECK (normal_balance IN ('DEBIT', 'CREDIT')),
    description         VARCHAR2(500),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    last_updated        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    FOREIGN KEY (parent_account_id) REFERENCES fin_chart_of_accounts(account_id),
    UNIQUE (company_id, account_code)
);

-- Cost Centers/Departments
CREATE TABLE fin_cost_centers (
    cost_center_id      NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    cost_center_code    VARCHAR2(20) NOT NULL,
    cost_center_name    VARCHAR2(100) NOT NULL,
    manager_name        VARCHAR2(100),
    manager_email       VARCHAR2(100),
    budget_amount       NUMBER(15,2),
    is_active           CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    UNIQUE (company_id, cost_center_code)
);

-- =============================================================================
-- CUSTOMER AND VENDOR MANAGEMENT
-- =============================================================================

-- Customers
CREATE TABLE fin_customers (
    customer_id         NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    customer_code       VARCHAR2(20) NOT NULL,
    customer_name       VARCHAR2(100) NOT NULL,
    customer_type       VARCHAR2(20) DEFAULT 'STANDARD' CHECK (customer_type IN 
        ('STANDARD', 'PREFERRED', 'VIP', 'WHOLESALE', 'RETAIL')),
    contact_person      VARCHAR2(100),
    email               VARCHAR2(100),
    phone               VARCHAR2(20),
    billing_address     VARCHAR2(500),
    shipping_address    VARCHAR2(500),
    payment_terms       VARCHAR2(20) DEFAULT 'NET30',
    credit_limit        NUMBER(15,2) DEFAULT 0,
    tax_exempt          CHAR(1) DEFAULT 'N' CHECK (tax_exempt IN ('Y', 'N')),
    status              VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    UNIQUE (company_id, customer_code)
);

-- Vendors/Suppliers
CREATE TABLE fin_vendors (
    vendor_id           NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    vendor_code         VARCHAR2(20) NOT NULL,
    vendor_name         VARCHAR2(100) NOT NULL,
    vendor_type         VARCHAR2(20) DEFAULT 'SUPPLIER' CHECK (vendor_type IN 
        ('SUPPLIER', 'SERVICE', 'CONTRACTOR', 'UTILITY', 'OTHER')),
    contact_person      VARCHAR2(100),
    email               VARCHAR2(100),
    phone               VARCHAR2(20),
    address             VARCHAR2(500),
    payment_terms       VARCHAR2(20) DEFAULT 'NET30',
    tax_id              VARCHAR2(20),
    is_1099_vendor      CHAR(1) DEFAULT 'N' CHECK (is_1099_vendor IN ('Y', 'N')),
    status              VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    UNIQUE (company_id, vendor_code)
);

-- =============================================================================
-- TRANSACTION TABLES
-- =============================================================================

-- Journal Entries Header
CREATE TABLE fin_journal_entries (
    journal_entry_id    NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    journal_number      VARCHAR2(20) NOT NULL,
    entry_date          DATE NOT NULL,
    posting_date        DATE,
    reference_number    VARCHAR2(50),
    description         VARCHAR2(500),
    entry_type          VARCHAR2(20) DEFAULT 'MANUAL' CHECK (entry_type IN 
        ('MANUAL', 'AUTOMATIC', 'ADJUSTING', 'CLOSING', 'REVERSING')),
    source_module       VARCHAR2(20) DEFAULT 'GL' CHECK (source_module IN 
        ('GL', 'AP', 'AR', 'FA', 'PR', 'INV', 'BANK')),
    total_debit         NUMBER(15,2) DEFAULT 0,
    total_credit        NUMBER(15,2) DEFAULT 0,
    status              VARCHAR2(10) DEFAULT 'DRAFT' CHECK (status IN 
        ('DRAFT', 'POSTED', 'REVERSED')),
    posted_by           VARCHAR2(50),
    posted_date         TIMESTAMP,
    reversed_by         VARCHAR2(50),
    reversed_date       TIMESTAMP,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    UNIQUE (company_id, journal_number)
);

-- Journal Entry Lines/Details
CREATE TABLE fin_journal_entry_lines (
    line_id             NUMBER PRIMARY KEY,
    journal_entry_id    NUMBER NOT NULL,
    line_number         NUMBER NOT NULL,
    account_id          NUMBER NOT NULL,
    cost_center_id      NUMBER,
    debit_amount        NUMBER(15,2) DEFAULT 0,
    credit_amount       NUMBER(15,2) DEFAULT 0,
    description         VARCHAR2(500),
    reference_number    VARCHAR2(50),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (journal_entry_id) REFERENCES fin_journal_entries(journal_entry_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES fin_chart_of_accounts(account_id),
    FOREIGN KEY (cost_center_id) REFERENCES fin_cost_centers(cost_center_id),
    UNIQUE (journal_entry_id, line_number),
    CHECK (debit_amount >= 0 AND credit_amount >= 0),
    CHECK (debit_amount = 0 OR credit_amount = 0)
);

-- General Ledger (summarized transactions)
CREATE TABLE fin_general_ledger (
    gl_id               NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    account_id          NUMBER NOT NULL,
    cost_center_id      NUMBER,
    period_year         NUMBER(4) NOT NULL,
    period_month        NUMBER(2) NOT NULL,
    beginning_balance   NUMBER(15,2) DEFAULT 0,
    period_debit        NUMBER(15,2) DEFAULT 0,
    period_credit       NUMBER(15,2) DEFAULT 0,
    ending_balance      NUMBER(15,2) DEFAULT 0,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    FOREIGN KEY (account_id) REFERENCES fin_chart_of_accounts(account_id),
    FOREIGN KEY (cost_center_id) REFERENCES fin_cost_centers(cost_center_id),
    UNIQUE (company_id, account_id, cost_center_id, period_year, period_month)
);

-- =============================================================================
-- ACCOUNTS PAYABLE
-- =============================================================================

-- Vendor Invoices
CREATE TABLE fin_ap_invoices (
    invoice_id          NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    vendor_id           NUMBER NOT NULL,
    invoice_number      VARCHAR2(50) NOT NULL,
    vendor_invoice_num  VARCHAR2(50),
    invoice_date        DATE NOT NULL,
    due_date            DATE NOT NULL,
    payment_terms       VARCHAR2(20),
    invoice_amount      NUMBER(15,2) NOT NULL,
    tax_amount          NUMBER(15,2) DEFAULT 0,
    total_amount        NUMBER(15,2) NOT NULL,
    paid_amount         NUMBER(15,2) DEFAULT 0,
    discount_amount     NUMBER(15,2) DEFAULT 0,
    status              VARCHAR2(20) DEFAULT 'OPEN' CHECK (status IN 
        ('OPEN', 'PARTIAL', 'PAID', 'CANCELLED', 'ON_HOLD')),
    description         VARCHAR2(500),
    cost_center_id      NUMBER,
    journal_entry_id    NUMBER,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    FOREIGN KEY (vendor_id) REFERENCES fin_vendors(vendor_id),
    FOREIGN KEY (cost_center_id) REFERENCES fin_cost_centers(cost_center_id),
    FOREIGN KEY (journal_entry_id) REFERENCES fin_journal_entries(journal_entry_id),
    UNIQUE (company_id, invoice_number)
);

-- Vendor Payments
CREATE TABLE fin_ap_payments (
    payment_id          NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    vendor_id           NUMBER NOT NULL,
    payment_number      VARCHAR2(30) NOT NULL,
    payment_date        DATE NOT NULL,
    payment_method      VARCHAR2(20) DEFAULT 'CHECK' CHECK (payment_method IN 
        ('CHECK', 'ACH', 'WIRE', 'CREDIT_CARD', 'CASH', 'OTHER')),
    check_number        VARCHAR2(20),
    bank_account_id     NUMBER,
    payment_amount      NUMBER(15,2) NOT NULL,
    discount_taken      NUMBER(15,2) DEFAULT 0,
    status              VARCHAR2(20) DEFAULT 'ISSUED' CHECK (status IN 
        ('ISSUED', 'CLEARED', 'VOIDED', 'OUTSTANDING')),
    memo                VARCHAR2(500),
    journal_entry_id    NUMBER,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    FOREIGN KEY (vendor_id) REFERENCES fin_vendors(vendor_id),
    FOREIGN KEY (journal_entry_id) REFERENCES fin_journal_entries(journal_entry_id),
    UNIQUE (company_id, payment_number)
);

-- Payment-Invoice Allocation
CREATE TABLE fin_ap_payment_allocations (
    allocation_id       NUMBER PRIMARY KEY,
    payment_id          NUMBER NOT NULL,
    invoice_id          NUMBER NOT NULL,
    allocated_amount    NUMBER(15,2) NOT NULL,
    discount_amount     NUMBER(15,2) DEFAULT 0,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES fin_ap_payments(payment_id) ON DELETE CASCADE,
    FOREIGN KEY (invoice_id) REFERENCES fin_ap_invoices(invoice_id),
    UNIQUE (payment_id, invoice_id)
);

-- =============================================================================
-- ACCOUNTS RECEIVABLE
-- =============================================================================

-- Customer Invoices
CREATE TABLE fin_ar_invoices (
    invoice_id          NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    customer_id         NUMBER NOT NULL,
    invoice_number      VARCHAR2(50) NOT NULL,
    invoice_date        DATE NOT NULL,
    due_date            DATE NOT NULL,
    payment_terms       VARCHAR2(20),
    subtotal_amount     NUMBER(15,2) NOT NULL,
    tax_amount          NUMBER(15,2) DEFAULT 0,
    total_amount        NUMBER(15,2) NOT NULL,
    paid_amount         NUMBER(15,2) DEFAULT 0,
    status              VARCHAR2(20) DEFAULT 'OPEN' CHECK (status IN 
        ('OPEN', 'PARTIAL', 'PAID', 'CANCELLED', 'OVERDUE')),
    description         VARCHAR2(500),
    journal_entry_id    NUMBER,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    FOREIGN KEY (customer_id) REFERENCES fin_customers(customer_id),
    FOREIGN KEY (journal_entry_id) REFERENCES fin_journal_entries(journal_entry_id),
    UNIQUE (company_id, invoice_number)
);

-- Customer Payments
CREATE TABLE fin_ar_payments (
    payment_id          NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    customer_id         NUMBER NOT NULL,
    payment_number      VARCHAR2(30) NOT NULL,
    payment_date        DATE NOT NULL,
    payment_method      VARCHAR2(20) DEFAULT 'CHECK' CHECK (payment_method IN 
        ('CHECK', 'ACH', 'WIRE', 'CREDIT_CARD', 'CASH', 'OTHER')),
    reference_number    VARCHAR2(50),
    bank_account_id     NUMBER,
    payment_amount      NUMBER(15,2) NOT NULL,
    status              VARCHAR2(20) DEFAULT 'RECEIVED' CHECK (status IN 
        ('RECEIVED', 'DEPOSITED', 'RETURNED', 'VOIDED')),
    memo                VARCHAR2(500),
    journal_entry_id    NUMBER,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    FOREIGN KEY (customer_id) REFERENCES fin_customers(customer_id),
    FOREIGN KEY (journal_entry_id) REFERENCES fin_journal_entries(journal_entry_id),
    UNIQUE (company_id, payment_number)
);

-- =============================================================================
-- BUDGETING AND PLANNING
-- =============================================================================

-- Budget Headers
CREATE TABLE fin_budgets (
    budget_id           NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    budget_name         VARCHAR2(100) NOT NULL,
    budget_year         NUMBER(4) NOT NULL,
    budget_type         VARCHAR2(20) DEFAULT 'ANNUAL' CHECK (budget_type IN 
        ('ANNUAL', 'QUARTERLY', 'MONTHLY', 'PROJECT')),
    status              VARCHAR2(20) DEFAULT 'DRAFT' CHECK (status IN 
        ('DRAFT', 'APPROVED', 'ACTIVE', 'CLOSED')),
    approved_by         VARCHAR2(50),
    approved_date       DATE,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    UNIQUE (company_id, budget_name, budget_year)
);

-- Budget Details
CREATE TABLE fin_budget_details (
    budget_detail_id    NUMBER PRIMARY KEY,
    budget_id           NUMBER NOT NULL,
    account_id          NUMBER NOT NULL,
    cost_center_id      NUMBER,
    period_year         NUMBER(4) NOT NULL,
    period_month        NUMBER(2) NOT NULL,
    budgeted_amount     NUMBER(15,2) DEFAULT 0,
    revised_amount      NUMBER(15,2),
    notes               VARCHAR2(500),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (budget_id) REFERENCES fin_budgets(budget_id) ON DELETE CASCADE,
    FOREIGN KEY (account_id) REFERENCES fin_chart_of_accounts(account_id),
    FOREIGN KEY (cost_center_id) REFERENCES fin_cost_centers(cost_center_id),
    UNIQUE (budget_id, account_id, cost_center_id, period_year, period_month)
);

-- =============================================================================
-- BANKING AND CASH MANAGEMENT
-- =============================================================================

-- Bank Accounts
CREATE TABLE fin_bank_accounts (
    bank_account_id     NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    account_name        VARCHAR2(100) NOT NULL,
    account_number      VARCHAR2(50),
    bank_name           VARCHAR2(100),
    bank_routing        VARCHAR2(20),
    account_type        VARCHAR2(20) DEFAULT 'CHECKING' CHECK (account_type IN 
        ('CHECKING', 'SAVINGS', 'MONEY_MARKET', 'CREDIT_LINE')),
    gl_account_id       NUMBER NOT NULL,
    current_balance     NUMBER(15,2) DEFAULT 0,
    is_active           CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    FOREIGN KEY (gl_account_id) REFERENCES fin_chart_of_accounts(account_id)
);

-- Bank Transactions
CREATE TABLE fin_bank_transactions (
    transaction_id      NUMBER PRIMARY KEY,
    bank_account_id     NUMBER NOT NULL,
    transaction_date    DATE NOT NULL,
    transaction_type    VARCHAR2(20) NOT NULL CHECK (transaction_type IN 
        ('DEPOSIT', 'WITHDRAWAL', 'TRANSFER', 'FEE', 'INTEREST', 'ADJUSTMENT')),
    reference_number    VARCHAR2(50),
    description         VARCHAR2(500),
    amount              NUMBER(15,2) NOT NULL,
    running_balance     NUMBER(15,2),
    reconciled          CHAR(1) DEFAULT 'N' CHECK (reconciled IN ('Y', 'N')),
    reconciled_date     DATE,
    journal_entry_id    NUMBER,
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by          VARCHAR2(50) DEFAULT USER,
    FOREIGN KEY (bank_account_id) REFERENCES fin_bank_accounts(bank_account_id),
    FOREIGN KEY (journal_entry_id) REFERENCES fin_journal_entries(journal_entry_id)
);

-- =============================================================================
-- AUDIT AND CONTROL TABLES
-- =============================================================================

-- Financial Audit Log
CREATE TABLE fin_audit_log (
    audit_id            NUMBER PRIMARY KEY,
    table_name          VARCHAR2(50) NOT NULL,
    operation_type      VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id           NUMBER,
    company_id          NUMBER,
    old_values          CLOB,
    new_values          CLOB,
    changed_by          VARCHAR2(50) DEFAULT USER,
    change_date         TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    session_id          VARCHAR2(50),
    client_info         VARCHAR2(100)
);

-- Financial Period Control
CREATE TABLE fin_period_control (
    control_id          NUMBER PRIMARY KEY,
    company_id          NUMBER NOT NULL,
    period_year         NUMBER(4) NOT NULL,
    period_month        NUMBER(2) NOT NULL,
    status              VARCHAR2(10) DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'CLOSED', 'LOCKED')),
    closed_by           VARCHAR2(50),
    closed_date         TIMESTAMP,
    ap_closed           CHAR(1) DEFAULT 'N' CHECK (ap_closed IN ('Y', 'N')),
    ar_closed           CHAR(1) DEFAULT 'N' CHECK (ar_closed IN ('Y', 'N')),
    gl_closed           CHAR(1) DEFAULT 'N' CHECK (gl_closed IN ('Y', 'N')),
    created_date        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (company_id) REFERENCES fin_companies(company_id),
    UNIQUE (company_id, period_year, period_month)
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Chart of Accounts indexes
CREATE INDEX idx_fin_coa_company_type ON fin_chart_of_accounts(company_id, account_type);
CREATE INDEX idx_fin_coa_parent ON fin_chart_of_accounts(parent_account_id);

-- Journal Entry indexes
CREATE INDEX idx_fin_je_company_date ON fin_journal_entries(company_id, entry_date);
CREATE INDEX idx_fin_je_status ON fin_journal_entries(status);
CREATE INDEX idx_fin_jel_account ON fin_journal_entry_lines(account_id);
CREATE INDEX idx_fin_jel_costcenter ON fin_journal_entry_lines(cost_center_id);

-- General Ledger indexes
CREATE INDEX idx_fin_gl_account_period ON fin_general_ledger(account_id, period_year, period_month);
CREATE INDEX idx_fin_gl_company_period ON fin_general_ledger(company_id, period_year, period_month);

-- AP indexes
CREATE INDEX idx_fin_ap_inv_vendor_date ON fin_ap_invoices(vendor_id, invoice_date);
CREATE INDEX idx_fin_ap_inv_due_date ON fin_ap_invoices(due_date);
CREATE INDEX idx_fin_ap_inv_status ON fin_ap_invoices(status);

-- AR indexes
CREATE INDEX idx_fin_ar_inv_customer_date ON fin_ar_invoices(customer_id, invoice_date);
CREATE INDEX idx_fin_ar_inv_due_date ON fin_ar_invoices(due_date);
CREATE INDEX idx_fin_ar_inv_status ON fin_ar_invoices(status);

-- Audit indexes
CREATE INDEX idx_fin_audit_table_date ON fin_audit_log(table_name, change_date);
CREATE INDEX idx_fin_audit_user_date ON fin_audit_log(changed_by, change_date);

PROMPT Financial Management Schema created successfully!
PROMPT ================================================

-- Display table summary
SELECT 
    table_name,
    num_rows,
    ROUND(blocks * 8192 / 1024, 2) AS size_kb
FROM user_tables 
WHERE table_name LIKE 'FIN_%'
ORDER BY table_name;

PROMPT
PROMPT Financial Management System Components:
PROMPT - Company and Chart of Accounts setup
PROMPT - Customer and Vendor management
PROMPT - General Ledger with journal entries
PROMPT - Accounts Payable and Receivable
PROMPT - Banking and Cash management
PROMPT - Budgeting and Planning
PROMPT - Audit trails and Period controls
PROMPT
PROMPT Schema is ready for sample data and procedures!
