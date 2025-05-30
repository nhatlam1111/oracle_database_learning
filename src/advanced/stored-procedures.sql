/*
================================================================================
ORACLE DATABASE LEARNING PROJECT
Lesson 5: Advanced SQL Techniques
File: stored-procedures.sql
Topic: Stored Procedures and PL/SQL Practice Exercises

Description: Comprehensive practice file covering Oracle stored procedures,
             PL/SQL basics, parameters, control structures, and exception handling.

Author: Oracle Learning Project
Date: May 2025
================================================================================
*/

-- ============================================================================
-- SECTION 1: BASIC PL/SQL BLOCKS
-- Understanding PL/SQL structure and anonymous blocks
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 1: BASIC PL/SQL BLOCKS
PROMPT ========================================

-- Example 1: Simple anonymous PL/SQL block
-- Business scenario: Basic data processing
BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE('Welcome to Oracle PL/SQL!');
    DBMS_OUTPUT.PUT_LINE('Current date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
END;
/

-- Example 2: PL/SQL block with variables
-- Business scenario: Calculate employee bonus
DECLARE
    v_employee_id NUMBER := 101;
    v_salary NUMBER := 5000;
    v_bonus_rate NUMBER := 0.15;
    v_bonus NUMBER;
    v_total_compensation NUMBER;
BEGIN
    -- Calculate bonus
    v_bonus := v_salary * v_bonus_rate;
    v_total_compensation := v_salary + v_bonus;
    
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_employee_id);
    DBMS_OUTPUT.PUT_LINE('Base Salary: $' || TO_CHAR(v_salary, '99,999.99'));
    DBMS_OUTPUT.PUT_LINE('Bonus (15%): $' || TO_CHAR(v_bonus, '99,999.99'));
    DBMS_OUTPUT.PUT_LINE('Total Compensation: $' || TO_CHAR(v_total_compensation, '99,999.99'));
END;
/

-- Example 3: PL/SQL block with database interaction
-- Business scenario: Customer data processing
DECLARE
    v_customer_count NUMBER;
    v_avg_order_amount NUMBER;
BEGIN
    -- Create sample data first
    EXECUTE IMMEDIATE 'CREATE TABLE temp_customers (
        customer_id NUMBER PRIMARY KEY,
        customer_name VARCHAR2(100),
        order_amount NUMBER
    )';
    
    -- Insert sample data
    INSERT INTO temp_customers VALUES (1, 'John Smith', 1500);
    INSERT INTO temp_customers VALUES (2, 'Jane Doe', 2300);
    INSERT INTO temp_customers VALUES (3, 'Bob Johnson', 850);
    COMMIT;
    
    -- Process data
    SELECT COUNT(*), AVG(order_amount)
    INTO v_customer_count, v_avg_order_amount
    FROM temp_customers;
    
    DBMS_OUTPUT.PUT_LINE('Customer Analysis Report');
    DBMS_OUTPUT.PUT_LINE('========================');
    DBMS_OUTPUT.PUT_LINE('Total Customers: ' || v_customer_count);
    DBMS_OUTPUT.PUT_LINE('Average Order Amount: $' || TO_CHAR(v_avg_order_amount, '99,999.99'));
    
    -- Cleanup
    EXECUTE IMMEDIATE 'DROP TABLE temp_customers';
END;
/

-- ============================================================================
-- SECTION 2: SIMPLE STORED PROCEDURES
-- Creating and executing basic stored procedures
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 2: SIMPLE STORED PROCEDURES
PROMPT ========================================

-- Example 4: Simple procedure without parameters
-- Business scenario: System maintenance procedure
CREATE OR REPLACE PROCEDURE display_system_info
IS
    v_database_name VARCHAR2(100);
    v_current_user VARCHAR2(100);
    v_session_count NUMBER;
BEGIN
    -- Get system information
    SELECT name INTO v_database_name FROM v$database;
    SELECT USER INTO v_current_user FROM dual;
    SELECT COUNT(*) INTO v_session_count FROM v$session WHERE status = 'ACTIVE';
    
    DBMS_OUTPUT.PUT_LINE('=== SYSTEM INFORMATION ===');
    DBMS_OUTPUT.PUT_LINE('Database Name: ' || v_database_name);
    DBMS_OUTPUT.PUT_LINE('Current User: ' || v_current_user);
    DBMS_OUTPUT.PUT_LINE('Active Sessions: ' || v_session_count);
    DBMS_OUTPUT.PUT_LINE('Current Time: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error retrieving system info: ' || SQLERRM);
END display_system_info;
/

-- Execute the procedure
EXEC display_system_info;

-- Example 5: Procedure with IN parameters
-- Business scenario: Employee salary calculator
CREATE OR REPLACE PROCEDURE calculate_annual_salary(
    p_monthly_salary IN NUMBER,
    p_bonus_months IN NUMBER DEFAULT 2
)
IS
    v_annual_salary NUMBER;
    v_total_with_bonus NUMBER;
BEGIN
    -- Input validation
    IF p_monthly_salary <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Monthly salary must be positive');
    END IF;
    
    -- Calculate values
    v_annual_salary := p_monthly_salary * 12;
    v_total_with_bonus := v_annual_salary + (p_monthly_salary * p_bonus_months);
    
    DBMS_OUTPUT.PUT_LINE('=== SALARY CALCULATION ===');
    DBMS_OUTPUT.PUT_LINE('Monthly Salary: $' || TO_CHAR(p_monthly_salary, '99,999.99'));
    DBMS_OUTPUT.PUT_LINE('Annual Salary: $' || TO_CHAR(v_annual_salary, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('Bonus Months: ' || p_bonus_months);
    DBMS_OUTPUT.PUT_LINE('Total with Bonus: $' || TO_CHAR(v_total_with_bonus, '999,999.99'));
END calculate_annual_salary;
/

-- Test the procedure
EXEC calculate_annual_salary(5000);
EXEC calculate_annual_salary(7500, 3);

-- ============================================================================
-- SECTION 3: PROCEDURES WITH OUT PARAMETERS
-- Returning values from procedures
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 3: PROCEDURES WITH OUT PARAMETERS
PROMPT ========================================

-- Example 6: Procedure with OUT parameters
-- Business scenario: Customer credit scoring
CREATE OR REPLACE PROCEDURE assess_customer_credit(
    p_customer_income IN NUMBER,
    p_existing_debt IN NUMBER,
    p_years_employed IN NUMBER,
    p_credit_score OUT NUMBER,
    p_credit_rating OUT VARCHAR2,
    p_max_loan_amount OUT NUMBER
)
IS
    v_debt_to_income_ratio NUMBER;
    v_base_score NUMBER := 300; -- Starting credit score
BEGIN
    -- Calculate debt-to-income ratio
    v_debt_to_income_ratio := p_existing_debt / p_customer_income;
    
    -- Calculate credit score based on factors
    p_credit_score := v_base_score;
    
    -- Income factor (max 200 points)
    IF p_customer_income >= 100000 THEN
        p_credit_score := p_credit_score + 200;
    ELSIF p_customer_income >= 50000 THEN
        p_credit_score := p_credit_score + 150;
    ELSIF p_customer_income >= 30000 THEN
        p_credit_score := p_credit_score + 100;
    ELSE
        p_credit_score := p_credit_score + 50;
    END IF;
    
    -- Debt ratio factor (max 200 points)
    IF v_debt_to_income_ratio <= 0.1 THEN
        p_credit_score := p_credit_score + 200;
    ELSIF v_debt_to_income_ratio <= 0.3 THEN
        p_credit_score := p_credit_score + 150;
    ELSIF v_debt_to_income_ratio <= 0.5 THEN
        p_credit_score := p_credit_score + 100;
    ELSE
        p_credit_score := p_credit_score + 50;
    END IF;
    
    -- Employment factor (max 150 points)
    IF p_years_employed >= 10 THEN
        p_credit_score := p_credit_score + 150;
    ELSIF p_years_employed >= 5 THEN
        p_credit_score := p_credit_score + 100;
    ELSIF p_years_employed >= 2 THEN
        p_credit_score := p_credit_score + 75;
    ELSE
        p_credit_score := p_credit_score + 25;
    END IF;
    
    -- Determine credit rating
    IF p_credit_score >= 750 THEN
        p_credit_rating := 'EXCELLENT';
        p_max_loan_amount := p_customer_income * 5;
    ELSIF p_credit_score >= 700 THEN
        p_credit_rating := 'GOOD';
        p_max_loan_amount := p_customer_income * 4;
    ELSIF p_credit_score >= 650 THEN
        p_credit_rating := 'FAIR';
        p_max_loan_amount := p_customer_income * 3;
    ELSIF p_credit_score >= 600 THEN
        p_credit_rating := 'POOR';
        p_max_loan_amount := p_customer_income * 2;
    ELSE
        p_credit_rating := 'BAD';
        p_max_loan_amount := p_customer_income * 1;
    END IF;
    
END assess_customer_credit;
/

-- Test the procedure with different scenarios
DECLARE
    v_score NUMBER;
    v_rating VARCHAR2(20);
    v_max_loan NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== CREDIT ASSESSMENT TESTS ===');
    
    -- Test case 1: High income, low debt, long employment
    assess_customer_credit(120000, 5000, 15, v_score, v_rating, v_max_loan);
    DBMS_OUTPUT.PUT_LINE('Test 1 - High Income Customer:');
    DBMS_OUTPUT.PUT_LINE('Score: ' || v_score || ', Rating: ' || v_rating || 
                        ', Max Loan: $' || TO_CHAR(v_max_loan, '999,999'));
    
    -- Test case 2: Medium income, medium debt, short employment
    assess_customer_credit(45000, 15000, 2, v_score, v_rating, v_max_loan);
    DBMS_OUTPUT.PUT_LINE('Test 2 - Medium Income Customer:');
    DBMS_OUTPUT.PUT_LINE('Score: ' || v_score || ', Rating: ' || v_rating || 
                        ', Max Loan: $' || TO_CHAR(v_max_loan, '999,999'));
    
    -- Test case 3: Low income, high debt, new employment
    assess_customer_credit(25000, 20000, 1, v_score, v_rating, v_max_loan);
    DBMS_OUTPUT.PUT_LINE('Test 3 - Low Income Customer:');
    DBMS_OUTPUT.PUT_LINE('Score: ' || v_score || ', Rating: ' || v_rating || 
                        ', Max Loan: $' || TO_CHAR(v_max_loan, '999,999'));
END;
/

-- ============================================================================
-- SECTION 4: PROCEDURES WITH IN OUT PARAMETERS
-- Modifying parameters within procedures
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 4: PROCEDURES WITH IN OUT PARAMETERS
PROMPT ========================================

-- Example 7: Procedure with IN OUT parameters
-- Business scenario: Data cleaning and standardization
CREATE OR REPLACE PROCEDURE standardize_phone_number(
    p_phone_number IN OUT VARCHAR2,
    p_format_applied OUT VARCHAR2,
    p_is_valid OUT BOOLEAN
)
IS
    v_clean_number VARCHAR2(20);
    v_length NUMBER;
BEGIN
    -- Remove all non-numeric characters
    v_clean_number := REGEXP_REPLACE(p_phone_number, '[^0-9]', '');
    v_length := LENGTH(v_clean_number);
    
    -- Validate and format based on length
    IF v_length = 10 THEN
        -- US domestic format
        p_phone_number := '(' || SUBSTR(v_clean_number, 1, 3) || ') ' ||
                         SUBSTR(v_clean_number, 4, 3) || '-' ||
                         SUBSTR(v_clean_number, 7, 4);
        p_format_applied := 'US_DOMESTIC';
        p_is_valid := TRUE;
    ELSIF v_length = 11 AND SUBSTR(v_clean_number, 1, 1) = '1' THEN
        -- US international format
        p_phone_number := '+1 (' || SUBSTR(v_clean_number, 2, 3) || ') ' ||
                         SUBSTR(v_clean_number, 5, 3) || '-' ||
                         SUBSTR(v_clean_number, 8, 4);
        p_format_applied := 'US_INTERNATIONAL';
        p_is_valid := TRUE;
    ELSE
        -- Invalid format
        p_phone_number := 'INVALID: ' || p_phone_number;
        p_format_applied := 'NONE';
        p_is_valid := FALSE;
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        p_phone_number := 'ERROR: ' || p_phone_number;
        p_format_applied := 'ERROR';
        p_is_valid := FALSE;
END standardize_phone_number;
/

-- Test the procedure
DECLARE
    v_phone VARCHAR2(50);
    v_format VARCHAR2(20);
    v_valid BOOLEAN;
    
    PROCEDURE test_phone(p_input VARCHAR2) IS
    BEGIN
        v_phone := p_input;
        standardize_phone_number(v_phone, v_format, v_valid);
        DBMS_OUTPUT.PUT_LINE('Input: ' || p_input);
        DBMS_OUTPUT.PUT_LINE('Output: ' || v_phone);
        DBMS_OUTPUT.PUT_LINE('Format: ' || v_format);
        DBMS_OUTPUT.PUT_LINE('Valid: ' || CASE WHEN v_valid THEN 'YES' ELSE 'NO' END);
        DBMS_OUTPUT.PUT_LINE('---');
    END;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PHONE NUMBER STANDARDIZATION TESTS ===');
    test_phone('555-123-4567');
    test_phone('(555) 123-4567');
    test_phone('5551234567');
    test_phone('1-555-123-4567');
    test_phone('15551234567');
    test_phone('555-123-456');  -- Invalid
END;
/

-- ============================================================================
-- SECTION 5: CONTROL STRUCTURES
-- IF statements, loops, and conditional logic
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 5: CONTROL STRUCTURES
PROMPT ========================================

-- Example 8: Procedure with complex IF-ELSIF logic
-- Business scenario: Employee performance rating
CREATE OR REPLACE PROCEDURE calculate_performance_rating(
    p_employee_id IN NUMBER,
    p_sales_target IN NUMBER,
    p_actual_sales IN NUMBER,
    p_customer_satisfaction IN NUMBER, -- 1-10 scale
    p_attendance_percent IN NUMBER     -- 0-100 percentage
)
IS
    v_sales_performance NUMBER;
    v_overall_score NUMBER;
    v_rating VARCHAR2(20);
    v_bonus_percent NUMBER;
    v_comments VARCHAR2(500);
BEGIN
    -- Calculate sales performance percentage
    v_sales_performance := (p_actual_sales / p_sales_target) * 100;
    
    -- Calculate overall score (weighted average)
    v_overall_score := (v_sales_performance * 0.5) + 
                      (p_customer_satisfaction * 10 * 0.3) + 
                      (p_attendance_percent * 0.2);
    
    -- Determine rating and bonus based on performance
    IF v_overall_score >= 90 THEN
        v_rating := 'OUTSTANDING';
        v_bonus_percent := 15;
        v_comments := 'Exceptional performance in all areas. Recommend for promotion.';
    ELSIF v_overall_score >= 80 THEN
        v_rating := 'EXCEEDS EXPECTATIONS';
        v_bonus_percent := 10;
        v_comments := 'Strong performance with room for minor improvements.';
    ELSIF v_overall_score >= 70 THEN
        v_rating := 'MEETS EXPECTATIONS';
        v_bonus_percent := 5;
        v_comments := 'Satisfactory performance meeting job requirements.';
    ELSIF v_overall_score >= 60 THEN
        v_rating := 'BELOW EXPECTATIONS';
        v_bonus_percent := 0;
        v_comments := 'Performance improvement needed. Recommend training.';
    ELSE
        v_rating := 'UNSATISFACTORY';
        v_bonus_percent := 0;
        v_comments := 'Significant performance issues. Immediate action required.';
    END IF;
    
    -- Additional comments based on specific metrics
    IF p_customer_satisfaction < 5 THEN
        v_comments := v_comments || ' Customer service training recommended.';
    END IF;
    
    IF p_attendance_percent < 85 THEN
        v_comments := v_comments || ' Attendance improvement required.';
    END IF;
    
    -- Display results
    DBMS_OUTPUT.PUT_LINE('=== PERFORMANCE REVIEW: Employee ' || p_employee_id || ' ===');
    DBMS_OUTPUT.PUT_LINE('Sales Target: $' || TO_CHAR(p_sales_target, '999,999'));
    DBMS_OUTPUT.PUT_LINE('Actual Sales: $' || TO_CHAR(p_actual_sales, '999,999'));
    DBMS_OUTPUT.PUT_LINE('Sales Performance: ' || TO_CHAR(v_sales_performance, '999.9') || '%');
    DBMS_OUTPUT.PUT_LINE('Customer Satisfaction: ' || p_customer_satisfaction || '/10');
    DBMS_OUTPUT.PUT_LINE('Attendance: ' || p_attendance_percent || '%');
    DBMS_OUTPUT.PUT_LINE('Overall Score: ' || TO_CHAR(v_overall_score, '999.9'));
    DBMS_OUTPUT.PUT_LINE('Rating: ' || v_rating);
    DBMS_OUTPUT.PUT_LINE('Bonus Percentage: ' || v_bonus_percent || '%');
    DBMS_OUTPUT.PUT_LINE('Comments: ' || v_comments);
    DBMS_OUTPUT.PUT_LINE('');
END calculate_performance_rating;
/

-- Test with different performance scenarios
BEGIN
    calculate_performance_rating(101, 100000, 120000, 9, 98);  -- Outstanding
    calculate_performance_rating(102, 80000, 75000, 7, 88);    -- Meets expectations
    calculate_performance_rating(103, 90000, 60000, 4, 75);    -- Below expectations
END;
/

-- Example 9: Procedure with loops
-- Business scenario: Inventory level monitoring
CREATE OR REPLACE PROCEDURE generate_inventory_alerts
IS
    CURSOR c_low_inventory IS
        SELECT product_id, product_name, current_stock, minimum_stock, reorder_quantity
        FROM (
            -- Simulate inventory table
            SELECT 1001 AS product_id, 'Laptop Pro' AS product_name, 5 AS current_stock, 10 AS minimum_stock, 25 AS reorder_quantity FROM dual
            UNION ALL SELECT 1002, 'Wireless Mouse', 2, 15, 50 FROM dual
            UNION ALL SELECT 1003, 'Monitor 24"', 8, 5, 20 FROM dual
            UNION ALL SELECT 1004, 'Keyboard', 0, 10, 30 FROM dual
            UNION ALL SELECT 1005, 'USB Cable', 25, 20, 100 FROM dual
        ) 
        WHERE current_stock <= minimum_stock;
    
    v_alert_count NUMBER := 0;
    v_critical_count NUMBER := 0;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INVENTORY ALERT REPORT ===');
    DBMS_OUTPUT.PUT_LINE('Generated on: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Loop through low inventory items
    FOR rec IN c_low_inventory LOOP
        v_alert_count := v_alert_count + 1;
        
        IF rec.current_stock = 0 THEN
            v_critical_count := v_critical_count + 1;
            DBMS_OUTPUT.PUT_LINE('*** CRITICAL *** Product: ' || rec.product_name || 
                               ' (ID: ' || rec.product_id || ') - OUT OF STOCK!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('*** WARNING *** Product: ' || rec.product_name || 
                               ' (ID: ' || rec.product_id || ') - Low Stock: ' || 
                               rec.current_stock || ' (Min: ' || rec.minimum_stock || ')');
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('    Recommended reorder quantity: ' || rec.reorder_quantity);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    -- Summary
    IF v_alert_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No inventory alerts. All products adequately stocked.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('=== SUMMARY ===');
        DBMS_OUTPUT.PUT_LINE('Total alerts: ' || v_alert_count);
        DBMS_OUTPUT.PUT_LINE('Critical (out of stock): ' || v_critical_count);
        DBMS_OUTPUT.PUT_LINE('Warnings (low stock): ' || (v_alert_count - v_critical_count));
    END IF;
END generate_inventory_alerts;
/

-- Execute the inventory alert procedure
EXEC generate_inventory_alerts;

-- ============================================================================
-- SECTION 6: EXCEPTION HANDLING
-- Handling errors and exceptions in procedures
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 6: EXCEPTION HANDLING
PROMPT ========================================

-- Example 10: Procedure with comprehensive exception handling
-- Business scenario: Bank account transaction processing
CREATE OR REPLACE PROCEDURE process_bank_transfer(
    p_from_account IN VARCHAR2,
    p_to_account IN VARCHAR2,
    p_amount IN NUMBER,
    p_transaction_id OUT NUMBER,
    p_status OUT VARCHAR2,
    p_error_message OUT VARCHAR2
)
IS
    v_from_balance NUMBER;
    v_to_balance NUMBER;
    v_transaction_id NUMBER;
    
    -- Custom exceptions
    insufficient_funds EXCEPTION;
    invalid_account EXCEPTION;
    invalid_amount EXCEPTION;
    
    PRAGMA EXCEPTION_INIT(insufficient_funds, -20001);
    PRAGMA EXCEPTION_INIT(invalid_account, -20002);
    PRAGMA EXCEPTION_INIT(invalid_amount, -20003);
    
BEGIN
    -- Initialize output parameters
    p_status := 'PROCESSING';
    p_error_message := NULL;
    
    -- Input validation
    IF p_amount <= 0 THEN
        RAISE invalid_amount;
    END IF;
    
    IF p_from_account IS NULL OR p_to_account IS NULL THEN
        RAISE invalid_account;
    END IF;
    
    IF p_from_account = p_to_account THEN
        RAISE_APPLICATION_ERROR(-20004, 'Cannot transfer to the same account');
    END IF;
    
    -- Simulate account balance lookup
    -- In real scenario, this would query actual account tables
    CASE p_from_account
        WHEN 'ACC001' THEN v_from_balance := 5000;
        WHEN 'ACC002' THEN v_from_balance := 1200;
        WHEN 'ACC003' THEN v_from_balance := 800;
        ELSE RAISE invalid_account;
    END CASE;
    
    CASE p_to_account
        WHEN 'ACC001' THEN v_to_balance := 5000;
        WHEN 'ACC002' THEN v_to_balance := 1200;
        WHEN 'ACC003' THEN v_to_balance := 800;
        WHEN 'ACC004' THEN v_to_balance := 2500;
        ELSE RAISE invalid_account;
    END CASE;
    
    -- Check sufficient funds
    IF v_from_balance < p_amount THEN
        RAISE insufficient_funds;
    END IF;
    
    -- Generate transaction ID
    SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) INTO v_transaction_id FROM dual;
    
    -- Process transaction (simulate)
    -- In real scenario, this would update account balances
    DBMS_OUTPUT.PUT_LINE('Processing transfer...');
    DBMS_OUTPUT.PUT_LINE('From Account: ' || p_from_account || ' (Balance: $' || v_from_balance || ')');
    DBMS_OUTPUT.PUT_LINE('To Account: ' || p_to_account || ' (Balance: $' || v_to_balance || ')');
    DBMS_OUTPUT.PUT_LINE('Amount: $' || p_amount);
    
    -- Simulate processing delay
    DBMS_LOCK.SLEEP(1);
    
    -- Success
    p_transaction_id := v_transaction_id;
    p_status := 'COMPLETED';
    p_error_message := NULL;
    
    DBMS_OUTPUT.PUT_LINE('Transfer completed successfully!');
    DBMS_OUTPUT.PUT_LINE('Transaction ID: ' || p_transaction_id);
    
EXCEPTION
    WHEN insufficient_funds THEN
        p_status := 'FAILED';
        p_error_message := 'Insufficient funds. Available balance: $' || v_from_balance;
        p_transaction_id := NULL;
        
    WHEN invalid_account THEN
        p_status := 'FAILED';
        p_error_message := 'Invalid account number provided';
        p_transaction_id := NULL;
        
    WHEN invalid_amount THEN
        p_status := 'FAILED';
        p_error_message := 'Transfer amount must be positive';
        p_transaction_id := NULL;
        
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_error_message := 'System error: ' || SQLERRM;
        p_transaction_id := NULL;
        
        -- Log error for investigation
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('BACKTRACE: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END process_bank_transfer;
/

-- Test the transfer procedure with various scenarios
DECLARE
    v_transaction_id NUMBER;
    v_status VARCHAR2(20);
    v_error_message VARCHAR2(500);
    
    PROCEDURE test_transfer(
        p_from IN VARCHAR2, 
        p_to IN VARCHAR2, 
        p_amount IN NUMBER,
        p_description IN VARCHAR2
    ) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== ' || p_description || ' ===');
        process_bank_transfer(p_from, p_to, p_amount, v_transaction_id, v_status, v_error_message);
        DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
        IF v_error_message IS NOT NULL THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        END IF;
        DBMS_OUTPUT.PUT_LINE('');
    END;
    
BEGIN
    test_transfer('ACC001', 'ACC002', 1000, 'Valid Transfer');
    test_transfer('ACC002', 'ACC003', 2000, 'Insufficient Funds');
    test_transfer('ACC999', 'ACC001', 500, 'Invalid From Account');
    test_transfer('ACC001', 'ACC999', 500, 'Invalid To Account');
    test_transfer('ACC001', 'ACC002', -100, 'Invalid Amount');
    test_transfer('ACC001', 'ACC001', 500, 'Same Account Transfer');
END;
/

-- ============================================================================
-- SECTION 7: REAL-WORLD BUSINESS PROCEDURES
-- Complete business scenarios with complex logic
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 7: REAL-WORLD BUSINESS PROCEDURES
PROMPT ========================================

-- Example 11: Complex business procedure - Order processing system
-- Business scenario: E-commerce order fulfillment
CREATE OR REPLACE PROCEDURE process_customer_order(
    p_customer_id IN NUMBER,
    p_product_codes IN VARCHAR2, -- Comma-separated list
    p_quantities IN VARCHAR2,    -- Comma-separated list
    p_order_id OUT NUMBER,
    p_total_amount OUT NUMBER,
    p_status OUT VARCHAR2,
    p_message OUT VARCHAR2
)
IS
    TYPE t_product_array IS TABLE OF VARCHAR2(20) INDEX BY PLS_INTEGER;
    TYPE t_quantity_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    TYPE t_price_array IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    
    v_products t_product_array;
    v_quantities t_quantity_array;
    v_prices t_price_array;
    
    v_product_count NUMBER := 0;
    v_item_total NUMBER;
    v_discount_rate NUMBER := 0;
    v_tax_rate NUMBER := 0.08; -- 8% tax
    v_shipping_cost NUMBER := 10; -- Base shipping
    v_subtotal NUMBER := 0;
    v_discount_amount NUMBER := 0;
    v_tax_amount NUMBER := 0;
    
    -- Simulate product catalog
    TYPE t_catalog_rec IS RECORD (
        product_code VARCHAR2(20),
        product_name VARCHAR2(100),
        unit_price NUMBER,
        stock_quantity NUMBER
    );
    TYPE t_catalog_array IS TABLE OF t_catalog_rec INDEX BY VARCHAR2(20);
    v_catalog t_catalog_array;
    
    customer_not_found EXCEPTION;
    product_not_found EXCEPTION;
    insufficient_stock EXCEPTION;
    
BEGIN
    -- Initialize catalog (simulate database lookup)
    v_catalog('LAPTOP001').product_code := 'LAPTOP001';
    v_catalog('LAPTOP001').product_name := 'Gaming Laptop Pro';
    v_catalog('LAPTOP001').unit_price := 1299.99;
    v_catalog('LAPTOP001').stock_quantity := 10;
    
    v_catalog('MOUSE001').product_code := 'MOUSE001';
    v_catalog('MOUSE001').product_name := 'Wireless Gaming Mouse';
    v_catalog('MOUSE001').unit_price := 79.99;
    v_catalog('MOUSE001').stock_quantity := 25;
    
    v_catalog('KEYBOARD001').product_code := 'KEYBOARD001';
    v_catalog('KEYBOARD001').product_name := 'Mechanical Keyboard';
    v_catalog('KEYBOARD001').unit_price := 149.99;
    v_catalog('KEYBOARD001').stock_quantity := 15;
    
    -- Validate customer (simulate)
    IF p_customer_id NOT IN (1001, 1002, 1003) THEN
        RAISE customer_not_found;
    END IF;
    
    -- Parse product codes and quantities
    SELECT REGEXP_COUNT(p_product_codes, ',') + 1 INTO v_product_count FROM dual;
    
    FOR i IN 1..v_product_count LOOP
        v_products(i) := TRIM(REGEXP_SUBSTR(p_product_codes, '[^,]+', 1, i));
        v_quantities(i) := TO_NUMBER(TRIM(REGEXP_SUBSTR(p_quantities, '[^,]+', 1, i)));
        
        -- Validate product exists
        IF NOT v_catalog.EXISTS(v_products(i)) THEN
            RAISE product_not_found;
        END IF;
        
        -- Check stock availability
        IF v_quantities(i) > v_catalog(v_products(i)).stock_quantity THEN
            RAISE insufficient_stock;
        END IF;
        
        -- Get price
        v_prices(i) := v_catalog(v_products(i)).unit_price;
    END LOOP;
    
    -- Calculate order totals
    DBMS_OUTPUT.PUT_LINE('=== ORDER CALCULATION ===');
    DBMS_OUTPUT.PUT_LINE('Customer ID: ' || p_customer_id);
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR i IN 1..v_product_count LOOP
        v_item_total := v_quantities(i) * v_prices(i);
        v_subtotal := v_subtotal + v_item_total;
        
        DBMS_OUTPUT.PUT_LINE(v_catalog(v_products(i)).product_name);
        DBMS_OUTPUT.PUT_LINE('  Code: ' || v_products(i) || ', Qty: ' || v_quantities(i) || 
                           ', Unit Price: $' || TO_CHAR(v_prices(i), '999.99') ||
                           ', Total: $' || TO_CHAR(v_item_total, '9,999.99'));
    END LOOP;
    
    -- Apply volume discount
    IF v_subtotal >= 1000 THEN
        v_discount_rate := 0.10; -- 10% discount
    ELSIF v_subtotal >= 500 THEN
        v_discount_rate := 0.05; -- 5% discount
    END IF;
    
    v_discount_amount := v_subtotal * v_discount_rate;
    
    -- Calculate tax on discounted amount
    v_tax_amount := (v_subtotal - v_discount_amount) * v_tax_rate;
    
    -- Free shipping for orders over $100
    IF (v_subtotal - v_discount_amount) >= 100 THEN
        v_shipping_cost := 0;
    END IF;
    
    -- Calculate final total
    p_total_amount := v_subtotal - v_discount_amount + v_tax_amount + v_shipping_cost;
    
    -- Generate order ID
    SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) INTO p_order_id FROM dual;
    
    -- Display order summary
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== ORDER SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('Order ID: ' || p_order_id);
    DBMS_OUTPUT.PUT_LINE('Subtotal: $' || TO_CHAR(v_subtotal, '9,999.99'));
    IF v_discount_rate > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Discount (' || (v_discount_rate * 100) || '%): -$' || 
                           TO_CHAR(v_discount_amount, '9,999.99'));
    END IF;
    DBMS_OUTPUT.PUT_LINE('Tax (' || (v_tax_rate * 100) || '%): $' || TO_CHAR(v_tax_amount, '9,999.99'));
    DBMS_OUTPUT.PUT_LINE('Shipping: $' || TO_CHAR(v_shipping_cost, '999.99'));
    DBMS_OUTPUT.PUT_LINE('TOTAL: $' || TO_CHAR(p_total_amount, '9,999.99'));
    
    p_status := 'SUCCESS';
    p_message := 'Order processed successfully';
    
EXCEPTION
    WHEN customer_not_found THEN
        p_status := 'FAILED';
        p_message := 'Customer not found: ' || p_customer_id;
        p_order_id := NULL;
        p_total_amount := 0;
        
    WHEN product_not_found THEN
        p_status := 'FAILED';
        p_message := 'Product not found in catalog';
        p_order_id := NULL;
        p_total_amount := 0;
        
    WHEN insufficient_stock THEN
        p_status := 'FAILED';
        p_message := 'Insufficient stock for requested quantities';
        p_order_id := NULL;
        p_total_amount := 0;
        
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'System error: ' || SQLERRM;
        p_order_id := NULL;
        p_total_amount := 0;
END process_customer_order;
/

-- Test the order processing procedure
DECLARE
    v_order_id NUMBER;
    v_total NUMBER;
    v_status VARCHAR2(20);
    v_message VARCHAR2(500);
BEGIN
    -- Test successful order
    process_customer_order(
        p_customer_id => 1001,
        p_product_codes => 'LAPTOP001,MOUSE001',
        p_quantities => '1,2',
        p_order_id => v_order_id,
        p_total_amount => v_total,
        p_status => v_status,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Final Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test large order with discount
    process_customer_order(
        p_customer_id => 1002,
        p_product_codes => 'LAPTOP001,KEYBOARD001,MOUSE001',
        p_quantities => '2,1,3',
        p_order_id => v_order_id,
        p_total_amount => v_total,
        p_status => v_status,
        p_message => v_message
    );
    
    DBMS_OUTPUT.PUT_LINE('Final Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Message: ' || v_message);
END;
/

-- ============================================================================
-- CLEANUP SECTION
-- Clean up procedures created during practice
-- ============================================================================

PROMPT ========================================
PROMPT CLEANUP SECTION
PROMPT ========================================

-- Drop all procedures created
DROP PROCEDURE display_system_info;
DROP PROCEDURE calculate_annual_salary;
DROP PROCEDURE assess_customer_credit;
DROP PROCEDURE standardize_phone_number;
DROP PROCEDURE calculate_performance_rating;
DROP PROCEDURE generate_inventory_alerts;
DROP PROCEDURE process_bank_transfer;
DROP PROCEDURE process_customer_order;

PROMPT ========================================
PROMPT STORED PROCEDURES PRACTICE COMPLETE
PROMPT ========================================

/*
================================================================================
LEARNING OBJECTIVES COMPLETED:

1. ✓ Created and executed basic PL/SQL anonymous blocks
2. ✓ Developed simple stored procedures without parameters
3. ✓ Implemented procedures with IN parameters and default values
4. ✓ Created procedures with OUT parameters for returning values
5. ✓ Built procedures with IN OUT parameters for data modification
6. ✓ Applied complex control structures (IF-ELSIF, loops, cursors)
7. ✓ Implemented comprehensive exception handling patterns
8. ✓ Developed real-world business logic procedures
9. ✓ Integrated multiple advanced concepts in complex scenarios
10. ✓ Applied best practices for procedure design and error handling

BUSINESS SCENARIOS COVERED:
- Employee compensation calculations
- Customer credit assessment systems
- Data standardization and cleanup procedures
- Performance evaluation systems
- Inventory management and alerting
- Banking transaction processing
- E-commerce order fulfillment systems
- Multi-step business process automation

ADVANCED CONCEPTS DEMONSTRATED:
- Parameter validation and business rule enforcement
- Complex scoring algorithms and rating systems
- Data transformation and standardization
- Cursor-based data processing
- Custom exception handling
- Transaction simulation and error recovery
- Multi-step calculation workflows
- Dynamic business logic implementation

NEXT STEPS:
- Study functions-packages.sql for function development
- Explore triggers.sql for event-driven programming
- Practice advanced-plsql.sql for complex PL/SQL features
- Learn error-handling.sql for production-grade error management

================================================================================
*/
