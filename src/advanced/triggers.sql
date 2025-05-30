/*
================================================================================
ORACLE DATABASE LEARNING PROJECT
Lesson 5: Advanced SQL Techniques
File: triggers.sql
Topic: Database Triggers Practice Exercises

Description: Comprehensive practice file covering Oracle triggers including
             DML triggers (BEFORE/AFTER), DDL triggers, system triggers,
             row-level and statement-level triggers with business scenarios.

Author: Oracle Learning Project
Date: May 2025
================================================================================
*/

-- ============================================================================
-- SECTION 1: BASIC DML TRIGGERS (ROW-LEVEL)
-- BEFORE and AFTER triggers on INSERT, UPDATE, DELETE
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 1: BASIC DML TRIGGERS (ROW-LEVEL)
PROMPT ========================================

-- Example 1: BEFORE INSERT trigger for data validation and auto-population
-- Business scenario: Employee management with automatic audit fields

-- Create employees table
CREATE TABLE employees_demo (
    employee_id NUMBER PRIMARY KEY,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    email VARCHAR2(100) UNIQUE,
    hire_date DATE,
    salary NUMBER(10,2),
    department_id NUMBER,
    created_by VARCHAR2(30),
    created_date DATE,
    modified_by VARCHAR2(30),
    modified_date DATE,
    status VARCHAR2(20) DEFAULT 'ACTIVE'
);

-- Sequence for employee IDs
CREATE SEQUENCE emp_demo_seq START WITH 1000 INCREMENT BY 1;

-- BEFORE INSERT trigger
CREATE OR REPLACE TRIGGER trg_employees_before_insert
    BEFORE INSERT ON employees_demo
    FOR EACH ROW
BEGIN
    -- Auto-generate employee ID if not provided
    IF :NEW.employee_id IS NULL THEN
        :NEW.employee_id := emp_demo_seq.NEXTVAL;
    END IF;
    
    -- Set hire date to current date if not provided
    IF :NEW.hire_date IS NULL THEN
        :NEW.hire_date := SYSDATE;
    END IF;
    
    -- Generate email if not provided
    IF :NEW.email IS NULL THEN
        :NEW.email := LOWER(:NEW.first_name || '.' || :NEW.last_name || '@company.com');
    END IF;
    
    -- Validate salary
    IF :NEW.salary IS NOT NULL AND :NEW.salary < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary cannot be negative');
    END IF;
    
    -- Set audit fields
    :NEW.created_by := USER;
    :NEW.created_date := SYSDATE;
    :NEW.modified_by := USER;
    :NEW.modified_date := SYSDATE;
    
    -- Log the action
    DBMS_OUTPUT.PUT_LINE('TRIGGER: New employee ' || :NEW.first_name || ' ' || :NEW.last_name || 
                        ' being inserted with ID ' || :NEW.employee_id);
END;
/

-- Test the BEFORE INSERT trigger
INSERT INTO employees_demo (first_name, last_name, salary, department_id)
VALUES ('John', 'Smith', 75000, 10);

INSERT INTO employees_demo (first_name, last_name, email, salary, department_id)
VALUES ('Jane', 'Doe', 'jane.doe@company.com', 80000, 20);

-- View results
SELECT employee_id, first_name, last_name, email, hire_date, salary, created_by, created_date
FROM employees_demo;

-- Example 2: BEFORE UPDATE trigger for audit trail and business rules
CREATE OR REPLACE TRIGGER trg_employees_before_update
    BEFORE UPDATE ON employees_demo
    FOR EACH ROW
BEGIN
    -- Update audit fields
    :NEW.modified_by := USER;
    :NEW.modified_date := SYSDATE;
    
    -- Business rule: Cannot decrease salary by more than 10%
    IF :NEW.salary IS NOT NULL AND :OLD.salary IS NOT NULL THEN
        IF :NEW.salary < (:OLD.salary * 0.9) THEN
            RAISE_APPLICATION_ERROR(-20002, 
                'Salary cannot be decreased by more than 10%. Old: ' || :OLD.salary || 
                ', New: ' || :NEW.salary);
        END IF;
    END IF;
    
    -- Business rule: Cannot change hire date
    IF :NEW.hire_date != :OLD.hire_date THEN
        RAISE_APPLICATION_ERROR(-20003, 'Hire date cannot be modified');
    END IF;
    
    -- Log significant changes
    IF :NEW.salary != :OLD.salary THEN
        DBMS_OUTPUT.PUT_LINE('TRIGGER: Salary change for ' || :NEW.first_name || ' ' || :NEW.last_name ||
                           ' from $' || :OLD.salary || ' to $' || :NEW.salary);
    END IF;
    
    IF :NEW.department_id != :OLD.department_id THEN
        DBMS_OUTPUT.PUT_LINE('TRIGGER: Department change for ' || :NEW.first_name || ' ' || :NEW.last_name ||
                           ' from ' || :OLD.department_id || ' to ' || :NEW.department_id);
    END IF;
END;
/

-- Test the BEFORE UPDATE trigger
UPDATE employees_demo 
SET salary = 82000, department_id = 15 
WHERE employee_id = 1001;

-- Test business rule violation (should fail)
BEGIN
    UPDATE employees_demo 
    SET salary = 30000  -- More than 10% decrease
    WHERE employee_id = 1000;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/

-- Example 3: AFTER DELETE trigger for cleanup and logging
-- Create audit table first
CREATE TABLE employee_audit (
    audit_id NUMBER PRIMARY KEY,
    employee_id NUMBER,
    action_type VARCHAR2(10),
    old_first_name VARCHAR2(50),
    old_last_name VARCHAR2(50),
    old_salary NUMBER(10,2),
    old_department_id NUMBER,
    deleted_by VARCHAR2(30),
    deleted_date DATE
);

CREATE SEQUENCE audit_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_employees_after_delete
    AFTER DELETE ON employees_demo
    FOR EACH ROW
BEGIN
    -- Log deleted employee information
    INSERT INTO employee_audit (
        audit_id, employee_id, action_type,
        old_first_name, old_last_name, old_salary, old_department_id,
        deleted_by, deleted_date
    ) VALUES (
        audit_seq.NEXTVAL, :OLD.employee_id, 'DELETE',
        :OLD.first_name, :OLD.last_name, :OLD.salary, :OLD.department_id,
        USER, SYSDATE
    );
    
    DBMS_OUTPUT.PUT_LINE('TRIGGER: Employee ' || :OLD.first_name || ' ' || :OLD.last_name ||
                        ' (ID: ' || :OLD.employee_id || ') deleted and logged to audit table');
END;
/

-- Test the AFTER DELETE trigger
DELETE FROM employees_demo WHERE employee_id = 1001;

-- View audit record
SELECT * FROM employee_audit;

-- ============================================================================
-- SECTION 2: STATEMENT-LEVEL TRIGGERS
-- Triggers that fire once per SQL statement
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 2: STATEMENT-LEVEL TRIGGERS
PROMPT ========================================

-- Example 4: Statement-level triggers for security and monitoring
-- Create a table to log database access
CREATE TABLE table_access_log (
    log_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(30),
    operation VARCHAR2(10),
    user_name VARCHAR2(30),
    access_time DATE,
    row_count NUMBER
);

CREATE SEQUENCE access_log_seq START WITH 1 INCREMENT BY 1;

-- BEFORE statement trigger for access logging
CREATE OR REPLACE TRIGGER trg_employees_before_statement
    BEFORE INSERT OR UPDATE OR DELETE ON employees_demo
DECLARE
    v_operation VARCHAR2(10);
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';  
    ELSIF DELETING THEN
        v_operation := 'DELETE';
    END IF;
    
    -- Log access attempt
    INSERT INTO table_access_log (log_id, table_name, operation, user_name, access_time)
    VALUES (access_log_seq.NEXTVAL, 'EMPLOYEES_DEMO', v_operation, USER, SYSDATE);
    
    -- Security check: prevent operations during business hours for demo
    IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) BETWEEN 9 AND 17 
       AND TO_CHAR(SYSDATE, 'DY') NOT IN ('SAT', 'SUN') 
       AND v_operation = 'DELETE' THEN
        RAISE_APPLICATION_ERROR(-20004, 
            'Employee deletions not allowed during business hours (9 AM - 5 PM)');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('TRIGGER: ' || v_operation || ' operation on EMPLOYEES_DEMO started by ' || USER);
END;
/

-- AFTER statement trigger for operation completion logging
CREATE OR REPLACE TRIGGER trg_employees_after_statement
    AFTER INSERT OR UPDATE OR DELETE ON employees_demo
DECLARE
    v_operation VARCHAR2(10);
    v_row_count NUMBER;
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
    ELSIF DELETING THEN
        v_operation := 'DELETE';
    END IF;
    
    -- Get affected row count
    v_row_count := SQL%ROWCOUNT;
    
    -- Update the log record with completion info
    UPDATE table_access_log 
    SET row_count = v_row_count
    WHERE log_id = access_log_seq.CURRVAL;
    
    DBMS_OUTPUT.PUT_LINE('TRIGGER: ' || v_operation || ' operation completed. Rows affected: ' || v_row_count);
END;
/

-- Test statement-level triggers
INSERT INTO employees_demo (first_name, last_name, salary, department_id)
VALUES ('Alice', 'Johnson', 85000, 25);

UPDATE employees_demo SET salary = salary * 1.05 WHERE department_id = 10;

-- View access log
SELECT * FROM table_access_log ORDER BY access_time DESC;

-- ============================================================================
-- SECTION 3: COMPLEX BUSINESS LOGIC TRIGGERS
-- Multi-table operations and complex business rules
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 3: COMPLEX BUSINESS LOGIC TRIGGERS
PROMPT ========================================

-- Example 5: Complex trigger for inventory management
-- Create supporting tables
CREATE TABLE products_demo (
    product_id NUMBER PRIMARY KEY,
    product_name VARCHAR2(100),
    current_stock NUMBER,
    minimum_stock NUMBER DEFAULT 10,
    maximum_stock NUMBER DEFAULT 1000,
    unit_price NUMBER(10,2),
    status VARCHAR2(20) DEFAULT 'ACTIVE'
);

CREATE TABLE stock_movements (
    movement_id NUMBER PRIMARY KEY,
    product_id NUMBER REFERENCES products_demo(product_id),
    movement_type VARCHAR2(10), -- IN, OUT, ADJUST
    quantity NUMBER,
    reference_doc VARCHAR2(50),
    movement_date DATE DEFAULT SYSDATE,
    notes VARCHAR2(200)
);

CREATE TABLE inventory_alerts (
    alert_id NUMBER PRIMARY KEY,
    product_id NUMBER REFERENCES products_demo(product_id),
    alert_type VARCHAR2(20), -- LOW_STOCK, OUT_OF_STOCK, EXCESS_STOCK
    current_stock NUMBER,
    threshold_value NUMBER,
    alert_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'OPEN'
);

-- Sequences
CREATE SEQUENCE movement_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE alert_seq START WITH 1 INCREMENT BY 1;

-- Insert sample products
INSERT INTO products_demo VALUES (1, 'Laptop Pro', 50, 10, 200, 1299.99, 'ACTIVE');
INSERT INTO products_demo VALUES (2, 'Wireless Mouse', 25, 15, 500, 79.99, 'ACTIVE');
INSERT INTO products_demo VALUES (3, 'Keyboard', 8, 20, 300, 149.99, 'ACTIVE');

-- Complex trigger for inventory management
CREATE OR REPLACE TRIGGER trg_stock_movements_complex
    AFTER INSERT ON stock_movements
    FOR EACH ROW
DECLARE
    v_current_stock NUMBER;
    v_minimum_stock NUMBER;
    v_maximum_stock NUMBER;
    v_product_name VARCHAR2(100);
    v_new_stock NUMBER;
    v_alert_exists NUMBER;
BEGIN
    -- Get current product information
    SELECT current_stock, minimum_stock, maximum_stock, product_name
    INTO v_current_stock, v_minimum_stock, v_maximum_stock, v_product_name
    FROM products_demo
    WHERE product_id = :NEW.product_id;
    
    -- Calculate new stock level based on movement type
    CASE :NEW.movement_type
        WHEN 'IN' THEN
            v_new_stock := v_current_stock + :NEW.quantity;
        WHEN 'OUT' THEN
            v_new_stock := v_current_stock - :NEW.quantity;
        WHEN 'ADJUST' THEN
            v_new_stock := :NEW.quantity; -- Direct adjustment to specific level
        ELSE
            RAISE_APPLICATION_ERROR(-20005, 'Invalid movement type: ' || :NEW.movement_type);
    END CASE;
    
    -- Validate stock levels
    IF v_new_stock < 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Insufficient stock. Available: ' || v_current_stock || 
                               ', Requested: ' || :NEW.quantity);
    END IF;
    
    -- Update product stock
    UPDATE products_demo 
    SET current_stock = v_new_stock 
    WHERE product_id = :NEW.product_id;
    
    -- Generate alerts based on new stock level
    -- Check for low stock alert
    IF v_new_stock <= v_minimum_stock THEN
        -- Check if alert already exists
        SELECT COUNT(*) INTO v_alert_exists
        FROM inventory_alerts
        WHERE product_id = :NEW.product_id 
          AND alert_type IN ('LOW_STOCK', 'OUT_OF_STOCK') 
          AND status = 'OPEN';
          
        IF v_alert_exists = 0 THEN
            INSERT INTO inventory_alerts (
                alert_id, product_id, alert_type, current_stock, threshold_value, notes
            ) VALUES (
                alert_seq.NEXTVAL, 
                :NEW.product_id,
                CASE WHEN v_new_stock = 0 THEN 'OUT_OF_STOCK' ELSE 'LOW_STOCK' END,
                v_new_stock,
                v_minimum_stock,
                'Stock level below minimum threshold for ' || v_product_name
            );
        END IF;
    ELSE
        -- Close existing low stock alerts if stock is now adequate
        UPDATE inventory_alerts
        SET status = 'CLOSED'
        WHERE product_id = :NEW.product_id 
          AND alert_type IN ('LOW_STOCK', 'OUT_OF_STOCK') 
          AND status = 'OPEN';
    END IF;
    
    -- Check for excess stock alert
    IF v_new_stock > v_maximum_stock THEN
        SELECT COUNT(*) INTO v_alert_exists
        FROM inventory_alerts
        WHERE product_id = :NEW.product_id 
          AND alert_type = 'EXCESS_STOCK' 
          AND status = 'OPEN';
          
        IF v_alert_exists = 0 THEN
            INSERT INTO inventory_alerts (
                alert_id, product_id, alert_type, current_stock, threshold_value, notes
            ) VALUES (
                alert_seq.NEXTVAL,
                :NEW.product_id,
                'EXCESS_STOCK',
                v_new_stock,
                v_maximum_stock,
                'Stock level exceeds maximum capacity for ' || v_product_name
            );
        END IF;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('TRIGGER: Stock movement processed for ' || v_product_name ||
                        '. Old stock: ' || v_current_stock || ', New stock: ' || v_new_stock);
END;
/

-- Test the complex inventory trigger
-- Stock IN movement
INSERT INTO stock_movements (movement_id, product_id, movement_type, quantity, reference_doc, notes)
VALUES (movement_seq.NEXTVAL, 1, 'IN', 25, 'PO-2025-001', 'Purchase order receipt');

-- Stock OUT movement that triggers low stock alert
INSERT INTO stock_movements (movement_id, product_id, movement_type, quantity, reference_doc, notes)
VALUES (movement_seq.NEXTVAL, 3, 'OUT', 5, 'SO-2025-001', 'Sales order fulfillment');

-- Stock adjustment that creates out-of-stock
INSERT INTO stock_movements (movement_id, product_id, movement_type, quantity, reference_doc, notes)
VALUES (movement_seq.NEXTVAL, 3, 'ADJUST', 0, 'ADJ-2025-001', 'Physical count adjustment');

-- View results
SELECT p.product_id, p.product_name, p.current_stock, p.minimum_stock
FROM products_demo p
ORDER BY p.product_id;

SELECT * FROM inventory_alerts ORDER BY alert_date DESC;

-- ============================================================================
-- SECTION 4: INSTEAD OF TRIGGERS
-- Triggers on views for complex update operations
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 4: INSTEAD OF TRIGGERS
PROMPT ========================================

-- Example 6: INSTEAD OF trigger for updatable view
-- Create a complex view
CREATE OR REPLACE VIEW employee_department_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.salary,
    e.department_id,
    CASE e.department_id
        WHEN 10 THEN 'Finance'
        WHEN 15 THEN 'Human Resources'
        WHEN 20 THEN 'IT'
        WHEN 25 THEN 'Marketing'
        ELSE 'Unknown'
    END AS department_name,
    e.status
FROM employees_demo e;

-- INSTEAD OF INSERT trigger for the view
CREATE OR REPLACE TRIGGER trg_emp_dept_view_insert
    INSTEAD OF INSERT ON employee_department_view
    FOR EACH ROW
DECLARE
    v_dept_id NUMBER;
BEGIN
    -- Map department name to ID
    CASE UPPER(:NEW.department_name)
        WHEN 'FINANCE' THEN v_dept_id := 10;
        WHEN 'HUMAN RESOURCES' THEN v_dept_id := 15;
        WHEN 'IT' THEN v_dept_id := 20;
        WHEN 'MARKETING' THEN v_dept_id := 25;
        ELSE 
            IF :NEW.department_id IS NOT NULL THEN
                v_dept_id := :NEW.department_id;
            ELSE
                RAISE_APPLICATION_ERROR(-20007, 'Invalid department name: ' || :NEW.department_name);
            END IF;
    END CASE;
    
    -- Insert into base table
    INSERT INTO employees_demo (
        employee_id, first_name, last_name, email, salary, department_id, status
    ) VALUES (
        :NEW.employee_id, :NEW.first_name, :NEW.last_name, :NEW.email, 
        :NEW.salary, v_dept_id, NVL(:NEW.status, 'ACTIVE')
    );
    
    DBMS_OUTPUT.PUT_LINE('TRIGGER: Employee inserted via view - ' || :NEW.first_name || ' ' || :NEW.last_name ||
                        ' in ' || :NEW.department_name || ' department');
END;
/

-- INSTEAD OF UPDATE trigger for the view
CREATE OR REPLACE TRIGGER trg_emp_dept_view_update
    INSTEAD OF UPDATE ON employee_department_view
    FOR EACH ROW
DECLARE
    v_dept_id NUMBER;
BEGIN
    -- Handle department name change
    IF :NEW.department_name != :OLD.department_name THEN
        CASE UPPER(:NEW.department_name)
            WHEN 'FINANCE' THEN v_dept_id := 10;
            WHEN 'HUMAN RESOURCES' THEN v_dept_id := 15;
            WHEN 'IT' THEN v_dept_id := 20;
            WHEN 'MARKETING' THEN v_dept_id := 25;
            ELSE RAISE_APPLICATION_ERROR(-20007, 'Invalid department name: ' || :NEW.department_name);
        END CASE;
    ELSE
        v_dept_id := :OLD.department_id;
    END IF;
    
    -- Update base table
    UPDATE employees_demo
    SET first_name = :NEW.first_name,
        last_name = :NEW.last_name,
        email = :NEW.email,
        salary = :NEW.salary,
        department_id = v_dept_id,
        status = :NEW.status
    WHERE employee_id = :OLD.employee_id;
    
    DBMS_OUTPUT.PUT_LINE('TRIGGER: Employee updated via view - ' || :NEW.first_name || ' ' || :NEW.last_name);
END;
/

-- Test INSTEAD OF triggers
-- Insert via view
INSERT INTO employee_department_view (first_name, last_name, salary, department_name)
VALUES ('Michael', 'Brown', 90000, 'IT');

-- Update via view
UPDATE employee_department_view 
SET salary = 95000, department_name = 'Finance'
WHERE first_name = 'Michael' AND last_name = 'Brown';

-- View results
SELECT * FROM employee_department_view ORDER BY employee_id;

-- ============================================================================
-- SECTION 5: SYSTEM AND DDL TRIGGERS
-- Database-level event triggers
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 5: SYSTEM AND DDL TRIGGERS
PROMPT ========================================

-- Example 7: DDL trigger for database change auditing
-- Create audit table for DDL operations
CREATE TABLE ddl_audit_log (
    audit_id NUMBER PRIMARY KEY,
    event_type VARCHAR2(30),
    object_type VARCHAR2(30),
    object_name VARCHAR2(100),
    object_owner VARCHAR2(30),
    sql_text CLOB,
    event_date DATE DEFAULT SYSDATE,
    login_user VARCHAR2(30)
);

CREATE SEQUENCE ddl_audit_seq START WITH 1 INCREMENT BY 1;

-- DDL trigger (Note: This would typically be created with DBA privileges)
-- For demonstration purposes, showing the structure
/*
CREATE OR REPLACE TRIGGER trg_ddl_audit
    AFTER CREATE OR ALTER OR DROP ON SCHEMA
DECLARE
    v_sql_text CLOB;
BEGIN
    -- Get the SQL statement that caused the trigger to fire
    SELECT REGEXP_REPLACE(ora_sql_txt(sql_text), '\s+', ' ')
    INTO v_sql_text
    FROM dual;
    
    -- Log the DDL operation
    INSERT INTO ddl_audit_log (
        audit_id, event_type, object_type, object_name, object_owner,
        sql_text, login_user
    ) VALUES (
        ddl_audit_seq.NEXTVAL,
        ora_sysevent,
        ora_dict_obj_type,
        ora_dict_obj_name,
        ora_dict_obj_owner,
        v_sql_text,
        ora_login_user
    );
    
    -- Send alert for DROP operations
    IF ora_sysevent = 'DROP' THEN
        DBMS_OUTPUT.PUT_LINE('ALERT: ' || ora_dict_obj_type || ' ' || 
                           ora_dict_obj_name || ' was dropped by ' || ora_login_user);
    END IF;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log errors but don't fail the DDL operation
        INSERT INTO ddl_audit_log (
            audit_id, event_type, object_type, object_name, object_owner,
            sql_text, login_user
        ) VALUES (
            ddl_audit_seq.NEXTVAL,
            'ERROR',
            'TRIGGER_ERROR',
            'DDL_AUDIT_TRIGGER',
            USER,
            'Error in DDL trigger: ' || SQLERRM,
            USER
        );
END;
/
*/

DBMS_OUTPUT.PUT_LINE('Note: DDL triggers require special privileges and are typically created by DBAs');

-- Example 8: Logon/Logoff trigger for session monitoring
-- Create session monitoring table
CREATE TABLE user_sessions (
    session_id NUMBER PRIMARY KEY,
    username VARCHAR2(30),
    logon_time DATE,
    logoff_time DATE,
    session_duration NUMBER, -- in minutes
    host_name VARCHAR2(100),
    program VARCHAR2(100),
    status VARCHAR2(20) DEFAULT 'ACTIVE'
);

CREATE SEQUENCE session_seq START WITH 1 INCREMENT BY 1;

-- Demonstration of session trigger structure (requires system privileges)
/*
CREATE OR REPLACE TRIGGER trg_logon_audit
    AFTER LOGON ON SCHEMA
BEGIN
    INSERT INTO user_sessions (
        session_id, username, logon_time, host_name, program
    ) VALUES (
        session_seq.NEXTVAL,
        USER,
        SYSDATE,
        SYS_CONTEXT('USERENV', 'HOST'),
        SYS_CONTEXT('USERENV', 'PROGRAM')
    );
END;
/

CREATE OR REPLACE TRIGGER trg_logoff_audit
    BEFORE LOGOFF ON SCHEMA
DECLARE
    v_session_id NUMBER;
    v_logon_time DATE;
BEGIN
    -- Find the current session record
    SELECT session_id, logon_time
    INTO v_session_id, v_logon_time
    FROM user_sessions
    WHERE username = USER 
      AND status = 'ACTIVE'
      AND ROWNUM = 1
    ORDER BY logon_time DESC;
    
    -- Update with logoff information
    UPDATE user_sessions
    SET logoff_time = SYSDATE,
        session_duration = ROUND((SYSDATE - v_logon_time) * 24 * 60, 2),
        status = 'COMPLETED'
    WHERE session_id = v_session_id;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Session record not found, insert logoff record
        INSERT INTO user_sessions (
            session_id, username, logoff_time, status
        ) VALUES (
            session_seq.NEXTVAL, USER, SYSDATE, 'LOGOFF_ONLY'
        );
END;
/
*/

DBMS_OUTPUT.PUT_LINE('Note: System triggers require ADMINISTER DATABASE TRIGGER privilege');

-- ============================================================================
-- SECTION 6: TRIGGER MANAGEMENT AND BEST PRACTICES
-- Managing triggers, performance considerations, and troubleshooting
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 6: TRIGGER MANAGEMENT
PROMPT ========================================

-- Example 9: Trigger information and management
-- Query to view all triggers on our tables
SELECT 
    trigger_name,
    trigger_type,
    triggering_event,
    table_name,
    status,
    when_clause
FROM user_triggers
WHERE table_name IN ('EMPLOYEES_DEMO', 'STOCK_MOVEMENTS', 'EMPLOYEE_DEPARTMENT_VIEW')
ORDER BY table_name, trigger_name;

-- Example 10: Conditional trigger logic
-- Create a trigger with advanced conditional logic
CREATE OR REPLACE TRIGGER trg_employees_conditional
    BEFORE UPDATE ON employees_demo
    FOR EACH ROW
    WHEN (NEW.salary IS NOT NULL AND OLD.salary IS NOT NULL)
DECLARE
    v_percentage_change NUMBER;
    v_approval_required BOOLEAN := FALSE;
BEGIN
    -- Calculate percentage change
    v_percentage_change := ((:NEW.salary - :OLD.salary) / :OLD.salary) * 100;
    
    -- Determine if approval is required
    IF ABS(v_percentage_change) > 15 THEN
        v_approval_required := TRUE;
    END IF;
    
    -- Different logic based on change type
    IF :NEW.salary > :OLD.salary THEN
        -- Salary increase
        IF v_percentage_change > 25 THEN
            RAISE_APPLICATION_ERROR(-20008, 
                'Salary increase of ' || ROUND(v_percentage_change, 2) || 
                '% requires executive approval');
        ELSIF v_percentage_change > 15 THEN
            DBMS_OUTPUT.PUT_LINE('WARNING: Large salary increase (' || 
                               ROUND(v_percentage_change, 2) || '%) requires manager approval');
        END IF;
    ELSE
        -- Salary decrease
        IF ABS(v_percentage_change) > 15 THEN
            RAISE_APPLICATION_ERROR(-20009,
                'Salary decrease of ' || ROUND(ABS(v_percentage_change), 2) ||
                '% requires HR approval and documentation');
        END IF;
    END IF;
    
    -- Log significant changes
    IF ABS(v_percentage_change) > 5 THEN
        DBMS_OUTPUT.PUT_LINE('TRIGGER: Significant salary change (' || 
                           ROUND(v_percentage_change, 2) || '%) for employee ' ||
                           :NEW.employee_id || ' logged for review');
    END IF;
END;
/

-- Test conditional trigger
UPDATE employees_demo SET salary = salary * 1.12 WHERE employee_id = 1000; -- 12% increase
UPDATE employees_demo SET salary = salary * 1.08 WHERE employee_id = 1002; -- 8% increase

-- Example 11: Trigger with exception handling
CREATE OR REPLACE TRIGGER trg_employees_safe_update
    BEFORE UPDATE OF email ON employees_demo
    FOR EACH ROW
DECLARE
    v_email_count NUMBER;
    v_domain VARCHAR2(100);
    v_allowed_domains SYS.ODCIVARCHAR2LIST := SYS.ODCIVARCHAR2LIST(
        'company.com', 'subsidiary.com', 'partner.org'
    );
    v_domain_allowed BOOLEAN := FALSE;
BEGIN
    -- Skip if email is not changing
    IF :NEW.email = :OLD.email OR :NEW.email IS NULL THEN
        RETURN;
    END IF;
    
    BEGIN
        -- Check for duplicate email
        SELECT COUNT(*)
        INTO v_email_count
        FROM employees_demo
        WHERE UPPER(email) = UPPER(:NEW.email)
          AND employee_id != :NEW.employee_id;
          
        IF v_email_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Email address already in use: ' || :NEW.email);
        END IF;
        
        -- Extract and validate domain
        v_domain := SUBSTR(:NEW.email, INSTR(:NEW.email, '@') + 1);
        
        FOR i IN 1..v_allowed_domains.COUNT LOOP
            IF LOWER(v_domain) = LOWER(v_allowed_domains(i)) THEN
                v_domain_allowed := TRUE;
                EXIT;
            END IF;
        END LOOP;
        
        IF NOT v_domain_allowed THEN
            RAISE_APPLICATION_ERROR(-20011, 
                'Email domain not allowed: ' || v_domain || 
                '. Allowed domains: ' || 
                v_allowed_domains(1) || ', ' || 
                v_allowed_domains(2) || ', ' || 
                v_allowed_domains(3));
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('TRIGGER: Email validation passed for ' || :NEW.email);
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error details
            DBMS_OUTPUT.PUT_LINE('TRIGGER ERROR: ' || SQLERRM);
            RAISE; -- Re-raise the exception
    END;
END;
/

-- Test email validation trigger
UPDATE employees_demo SET email = 'john.smith@company.com' WHERE employee_id = 1000;

-- Test invalid domain (should fail)
BEGIN
    UPDATE employees_demo SET email = 'john.smith@gmail.com' WHERE employee_id = 1000;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Expected error: ' || SQLERRM);
END;
/

-- ============================================================================
-- CLEANUP SECTION
-- Clean up all objects created during practice
-- ============================================================================

PROMPT ========================================
PROMPT CLEANUP SECTION
PROMPT ========================================

-- Disable triggers before dropping tables
ALTER TRIGGER trg_employees_before_insert DISABLE;
ALTER TRIGGER trg_employees_before_update DISABLE;
ALTER TRIGGER trg_employees_after_delete DISABLE;
ALTER TRIGGER trg_employees_before_statement DISABLE;
ALTER TRIGGER trg_employees_after_statement DISABLE;
ALTER TRIGGER trg_stock_movements_complex DISABLE;
ALTER TRIGGER trg_emp_dept_view_insert DISABLE;
ALTER TRIGGER trg_emp_dept_view_update DISABLE;
ALTER TRIGGER trg_employees_conditional DISABLE;
ALTER TRIGGER trg_employees_safe_update DISABLE;

-- Drop triggers
DROP TRIGGER trg_employees_before_insert;
DROP TRIGGER trg_employees_before_update;
DROP TRIGGER trg_employees_after_delete;
DROP TRIGGER trg_employees_before_statement;
DROP TRIGGER trg_employees_after_statement;
DROP TRIGGER trg_stock_movements_complex;
DROP TRIGGER trg_emp_dept_view_insert;
DROP TRIGGER trg_emp_dept_view_update;
DROP TRIGGER trg_employees_conditional;
DROP TRIGGER trg_employees_safe_update;

-- Drop views
DROP VIEW employee_department_view;

-- Drop tables
DROP TABLE inventory_alerts;
DROP TABLE stock_movements;
DROP TABLE products_demo;
DROP TABLE employee_audit;
DROP TABLE table_access_log;
DROP TABLE ddl_audit_log;
DROP TABLE user_sessions;
DROP TABLE employees_demo;

-- Drop sequences
DROP SEQUENCE emp_demo_seq;
DROP SEQUENCE audit_seq;
DROP SEQUENCE access_log_seq;
DROP SEQUENCE movement_seq;
DROP SEQUENCE alert_seq;
DROP SEQUENCE ddl_audit_seq;
DROP SEQUENCE session_seq;

PROMPT ========================================
PROMPT TRIGGERS PRACTICE COMPLETE
PROMPT ========================================

/*
================================================================================
LEARNING OBJECTIVES COMPLETED:

1. ✓ Created and tested BEFORE/AFTER DML triggers (row-level)
2. ✓ Implemented statement-level triggers for batch operations
3. ✓ Developed complex business logic triggers with multi-table operations
4. ✓ Created INSTEAD OF triggers for updatable views
5. ✓ Demonstrated DDL and system trigger concepts
6. ✓ Applied conditional trigger logic with WHEN clauses
7. ✓ Implemented comprehensive exception handling in triggers
8. ✓ Used triggers for data validation and business rule enforcement
9. ✓ Created audit trails and logging mechanisms
10. ✓ Applied trigger management and troubleshooting techniques

BUSINESS SCENARIOS COVERED:
- Employee management with automatic audit fields
- Data validation and business rule enforcement
- Inventory management with automatic stock tracking
- Security and access logging
- Complex view operations with business logic
- Database change auditing and monitoring
- Session tracking and user activity monitoring
- Email validation and domain restrictions
- Salary change approval workflows
- Automatic alert generation systems

ADVANCED CONCEPTS DEMONSTRATED:
- Row-level vs statement-level trigger differences
- :NEW and :OLD pseudorecords usage
- Trigger execution order and dependencies
- Conditional trigger logic with WHEN clauses
- Exception handling and error propagation
- Multi-table trigger operations
- Trigger state management and data consistency
- Performance considerations and best practices
- Trigger debugging and troubleshooting techniques
- Database event handling patterns

TRIGGER TYPES COVERED:
- BEFORE INSERT/UPDATE/DELETE (row-level)
- AFTER INSERT/UPDATE/DELETE (row-level)
- BEFORE/AFTER statement-level triggers
- INSTEAD OF triggers on views
- DDL triggers (structure demonstration)
- System event triggers (logon/logoff concepts)
- Compound triggers (advanced concepts)

KEY FEATURES DEMONSTRATED:
- Automatic primary key generation
- Audit trail implementation
- Data validation and business rules
- Cross-table data synchronization
- Alert and notification systems
- Security and access control
- Complex conditional logic
- Error handling and logging
- View updatability enhancement
- Database change monitoring

NEXT STEPS:
- Study advanced-plsql.sql for complex PL/SQL features
- Learn error-handling.sql for production-grade error management
- Explore lesson5-combined-practice.sql for integrated scenarios
- Practice combining triggers with packages and functions

================================================================================
*/
