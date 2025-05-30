/*
==============================================================================
ORACLE DATABASE LEARNING PROJECT
Lesson 5: Advanced SQL Techniques - Error Handling & Debugging
==============================================================================

File: error-handling.sql
Author: Oracle Database Learning Team
Created: May 28, 2025
Purpose: Comprehensive guide to production-grade error handling in Oracle PL/SQL

Topics Covered:
1. Exception Types and Hierarchy
2. Built-in Oracle Exceptions
3. User-Defined Exceptions
4. Exception Propagation and Re-raising
5. Logging and Debugging Techniques
6. PRAGMA EXCEPTION_INIT
7. Advanced Error Handling Patterns
8. Production Error Management
9. Performance Considerations
10. Best Practices and Guidelines

Learning Objectives:
- Master Oracle's exception handling mechanisms
- Implement robust error management strategies
- Create comprehensive logging systems
- Debug complex PL/SQL applications
- Apply production-grade error handling patterns

Prerequisites:
- Completed Lesson 4 (Intermediate SQL)
- Understanding of PL/SQL basics
- Familiarity with stored procedures and functions

==============================================================================
*/

-- Enable serveroutput for debugging
SET SERVEROUTPUT ON SIZE 1000000;

/*
==============================================================================
SECTION 1: BASIC EXCEPTION HANDLING
==============================================================================
*/

PROMPT 'Section 1: Basic Exception Handling'
PROMPT '======================================'

-- Example 1.1: Basic Exception Handling Structure
DECLARE
    v_employee_id employees.employee_id%TYPE := 999;
    v_employee_name employees.first_name%TYPE;
    v_salary employees.salary%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Basic Exception Handling Demo ===');
    
    -- This will raise NO_DATA_FOUND exception
    SELECT first_name, salary 
    INTO v_employee_name, v_salary
    FROM employees 
    WHERE employee_id = v_employee_id;
    
    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_employee_name || ', Salary: ' || v_salary);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Employee ID ' || v_employee_id || ' not found');
        DBMS_OUTPUT.PUT_LINE('Action: Please verify the employee ID and try again');
    
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Query returned multiple rows');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Unexpected error occurred');
        DBMS_OUTPUT.PUT_LINE('SQL Error Code: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQL Error Message: ' || SQLERRM);
END;
/

-- Example 1.2: Multiple Exception Handlers
DECLARE
    v_department_id departments.department_id%TYPE := 10;
    v_department_name departments.department_name%TYPE;
    v_manager_id departments.manager_id%TYPE;
    v_location_id departments.location_id%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Multiple Exception Handlers Demo ===');
    
    SELECT department_name, manager_id, location_id
    INTO v_department_name, v_manager_id, v_location_id
    FROM departments
    WHERE department_id = v_department_id;
    
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_department_name);
    DBMS_OUTPUT.PUT_LINE('Manager ID: ' || NVL(TO_CHAR(v_manager_id), 'None'));
    DBMS_OUTPUT.PUT_LINE('Location ID: ' || v_location_id);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Department not found');
        
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Data type conversion error');
        
    WHEN INVALID_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('Invalid number conversion');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/

/*
==============================================================================
SECTION 2: BUILT-IN ORACLE EXCEPTIONS
==============================================================================
*/

PROMPT 'Section 2: Built-in Oracle Exceptions'
PROMPT '====================================='

-- Example 2.1: Common Oracle Exceptions Demo
CREATE OR REPLACE PROCEDURE demo_builtin_exceptions AS
    v_result NUMBER;
    v_name VARCHAR2(10);
    TYPE t_numbers IS TABLE OF NUMBER;
    v_numbers t_numbers := t_numbers(1, 2, 3);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Built-in Oracle Exceptions Demo ===');
    
    -- Demonstrate various built-in exceptions
    BEGIN
        -- ZERO_DIVIDE
        v_result := 10 / 0;
    EXCEPTION
        WHEN ZERO_DIVIDE THEN
            DBMS_OUTPUT.PUT_LINE('1. ZERO_DIVIDE: Cannot divide by zero');
    END;
    
    BEGIN
        -- VALUE_ERROR (string too large)
        v_name := 'This string is too long for the variable';
    EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('2. VALUE_ERROR: String too large for variable');
    END;
    
    BEGIN
        -- SUBSCRIPT_OUT_OF_RANGE
        DBMS_OUTPUT.PUT_LINE('Accessing element: ' || v_numbers(10));
    EXCEPTION
        WHEN SUBSCRIPT_OUT_OF_RANGE THEN
            DBMS_OUTPUT.PUT_LINE('3. SUBSCRIPT_OUT_OF_RANGE: Array index out of bounds');
    END;
    
    BEGIN
        -- INVALID_NUMBER
        v_result := TO_NUMBER('ABC');
    EXCEPTION
        WHEN INVALID_NUMBER THEN
            DBMS_OUTPUT.PUT_LINE('4. INVALID_NUMBER: Cannot convert string to number');
    END;
    
END demo_builtin_exceptions;
/

-- Execute the demo
BEGIN
    demo_builtin_exceptions;
END;
/

/*
==============================================================================
SECTION 3: USER-DEFINED EXCEPTIONS
==============================================================================
*/

PROMPT 'Section 3: User-Defined Exceptions'
PROMPT '=================================='

-- Example 3.1: Custom Exception Declaration and Usage
CREATE OR REPLACE PROCEDURE process_salary_increase(
    p_employee_id IN employees.employee_id%TYPE,
    p_increase_percentage IN NUMBER
) AS
    -- User-defined exceptions
    e_employee_not_found EXCEPTION;
    e_invalid_percentage EXCEPTION;
    e_salary_too_high EXCEPTION;
    
    v_current_salary employees.salary%TYPE;
    v_new_salary employees.salary%TYPE;
    v_max_salary NUMBER := 50000;
    v_employee_count NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Processing Salary Increase ===');
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || p_employee_id);
    DBMS_OUTPUT.PUT_LINE('Increase %: ' || p_increase_percentage);
    
    -- Validation: Check if employee exists
    SELECT COUNT(*)
    INTO v_employee_count
    FROM employees
    WHERE employee_id = p_employee_id;
    
    IF v_employee_count = 0 THEN
        RAISE e_employee_not_found;
    END IF;
    
    -- Validation: Check percentage range
    IF p_increase_percentage <= 0 OR p_increase_percentage > 100 THEN
        RAISE e_invalid_percentage;
    END IF;
    
    -- Get current salary
    SELECT salary
    INTO v_current_salary
    FROM employees
    WHERE employee_id = p_employee_id;
    
    -- Calculate new salary
    v_new_salary := v_current_salary * (1 + p_increase_percentage / 100);
    
    -- Check if new salary exceeds maximum
    IF v_new_salary > v_max_salary THEN
        RAISE e_salary_too_high;
    END IF;
    
    -- Update salary
    UPDATE employees
    SET salary = v_new_salary
    WHERE employee_id = p_employee_id;
    
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Salary updated from ' || v_current_salary || 
                        ' to ' || v_new_salary);
    COMMIT;
    
EXCEPTION
    WHEN e_employee_not_found THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Employee ID ' || p_employee_id || ' not found');
        
    WHEN e_invalid_percentage THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid percentage. Must be between 0 and 100');
        
    WHEN e_salary_too_high THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: New salary (' || v_new_salary || 
                            ') exceeds maximum allowed (' || v_max_salary || ')');
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Unexpected error - ' || SQLERRM);
        ROLLBACK;
END process_salary_increase;
/

-- Test the custom exceptions
BEGIN
    -- Test 1: Valid case
    process_salary_increase(100, 10);
    
    -- Test 2: Employee not found
    process_salary_increase(99999, 10);
    
    -- Test 3: Invalid percentage
    process_salary_increase(100, -5);
    
    -- Test 4: Salary too high
    process_salary_increase(100, 500);
END;
/

/*
==============================================================================
SECTION 4: PRAGMA EXCEPTION_INIT
==============================================================================
*/

PROMPT 'Section 4: PRAGMA EXCEPTION_INIT'
PROMPT '================================='

-- Example 4.1: Mapping Oracle Error Codes to Named Exceptions
CREATE OR REPLACE PROCEDURE demo_pragma_exception AS
    -- Map Oracle error codes to meaningful exception names
    e_check_constraint_violated EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_check_constraint_violated, -2290);
    
    e_unique_constraint_violated EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_unique_constraint_violated, -1);
    
    e_foreign_key_violated EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_foreign_key_violated, -2291);
    
    e_parent_key_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_parent_key_not_found, -2291);
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== PRAGMA EXCEPTION_INIT Demo ===');
    
    -- Try to insert invalid data to trigger constraint violations
    BEGIN
        INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id, salary)
        VALUES (1, 'John', 'Doe', 'john.doe@company.com', SYSDATE, 'IT_PROG', -1000);
    EXCEPTION
        WHEN e_check_constraint_violated THEN
            DBMS_OUTPUT.PUT_LINE('Check constraint violation: Salary cannot be negative');
        WHEN e_unique_constraint_violated THEN
            DBMS_OUTPUT.PUT_LINE('Unique constraint violation: Employee ID already exists');
    END;
    
    BEGIN
        INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_id)
        VALUES (999, 'Jane', 'Smith', 'john.doe@company.com', SYSDATE, 'IT_PROG');
    EXCEPTION
        WHEN e_unique_constraint_violated THEN
            DBMS_OUTPUT.PUT_LINE('Unique constraint violation: Email already exists');
    END;
    
END demo_pragma_exception;
/

-- Execute the demo
BEGIN
    demo_pragma_exception;
END;
/

/*
==============================================================================
SECTION 5: ADVANCED ERROR HANDLING PATTERNS
==============================================================================
*/

PROMPT 'Section 5: Advanced Error Handling Patterns'
PROMPT '============================================'

-- Example 5.1: Exception Propagation and Re-raising
CREATE OR REPLACE PACKAGE error_handling_patterns AS
    -- Custom exception types
    e_business_rule_violation EXCEPTION;
    e_data_integrity_error EXCEPTION;
    e_external_service_error EXCEPTION;
    
    PROCEDURE inner_procedure(p_value IN NUMBER);
    PROCEDURE middle_procedure(p_value IN NUMBER);
    PROCEDURE outer_procedure(p_value IN NUMBER);
END error_handling_patterns;
/

CREATE OR REPLACE PACKAGE BODY error_handling_patterns AS
    
    PROCEDURE inner_procedure(p_value IN NUMBER) AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Inner procedure called with value: ' || p_value);
        
        IF p_value < 0 THEN
            RAISE e_business_rule_violation;
        ELSIF p_value = 0 THEN
            RAISE ZERO_DIVIDE;
        ELSIF p_value > 100 THEN
            RAISE e_data_integrity_error;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Inner procedure completed successfully');
    END inner_procedure;
    
    PROCEDURE middle_procedure(p_value IN NUMBER) AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Middle procedure called');
        
        BEGIN
            inner_procedure(p_value);
        EXCEPTION
            WHEN e_business_rule_violation THEN
                DBMS_OUTPUT.PUT_LINE('Middle: Caught business rule violation, logging and re-raising');
                -- Log the error (in real scenario, write to error log table)
                RAISE; -- Re-raise the same exception
            WHEN ZERO_DIVIDE THEN
                DBMS_OUTPUT.PUT_LINE('Middle: Caught zero divide, converting to business exception');
                RAISE e_business_rule_violation; -- Raise different exception
        END;
        
        DBMS_OUTPUT.PUT_LINE('Middle procedure completed');
    END middle_procedure;
    
    PROCEDURE outer_procedure(p_value IN NUMBER) AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Exception Propagation Demo (Value: ' || p_value || ') ===');
        
        BEGIN
            middle_procedure(p_value);
            DBMS_OUTPUT.PUT_LINE('Outer procedure completed successfully');
        EXCEPTION
            WHEN e_business_rule_violation THEN
                DBMS_OUTPUT.PUT_LINE('Outer: Final handling of business rule violation');
            WHEN e_data_integrity_error THEN
                DBMS_OUTPUT.PUT_LINE('Outer: Final handling of data integrity error');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Outer: Unexpected error - ' || SQLERRM);
        END;
    END outer_procedure;
    
END error_handling_patterns;
/

-- Test exception propagation
BEGIN
    error_handling_patterns.outer_procedure(50);   -- Success case
    error_handling_patterns.outer_procedure(-10);  -- Business rule violation
    error_handling_patterns.outer_procedure(0);    -- Zero divide converted
    error_handling_patterns.outer_procedure(150);  -- Data integrity error
END;
/

/*
==============================================================================
SECTION 6: COMPREHENSIVE LOGGING SYSTEM
==============================================================================
*/

PROMPT 'Section 6: Comprehensive Logging System'
PROMPT '======================================='

-- Example 6.1: Error Logging Infrastructure
CREATE TABLE error_log (
    log_id NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    error_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    error_level VARCHAR2(20),
    procedure_name VARCHAR2(100),
    error_code NUMBER,
    error_message VARCHAR2(4000),
    stack_trace CLOB,
    session_info VARCHAR2(500),
    additional_info CLOB
);

-- Create logging package
CREATE OR REPLACE PACKAGE error_logger AS
    -- Log levels
    LEVEL_DEBUG CONSTANT VARCHAR2(20) := 'DEBUG';
    LEVEL_INFO CONSTANT VARCHAR2(20) := 'INFO';
    LEVEL_WARNING CONSTANT VARCHAR2(20) := 'WARNING';
    LEVEL_ERROR CONSTANT VARCHAR2(20) := 'ERROR';
    LEVEL_FATAL CONSTANT VARCHAR2(20) := 'FATAL';
    
    PROCEDURE log_error(
        p_level IN VARCHAR2,
        p_procedure_name IN VARCHAR2,
        p_error_code IN NUMBER DEFAULT NULL,
        p_error_message IN VARCHAR2,
        p_additional_info IN CLOB DEFAULT NULL
    );
    
    PROCEDURE log_exception(
        p_procedure_name IN VARCHAR2,
        p_additional_info IN CLOB DEFAULT NULL
    );
    
    FUNCTION get_session_info RETURN VARCHAR2;
    
END error_logger;
/

CREATE OR REPLACE PACKAGE BODY error_logger AS
    
    FUNCTION get_session_info RETURN VARCHAR2 AS
        v_session_info VARCHAR2(500);
    BEGIN
        SELECT 'SID: ' || SID || ', Serial#: ' || SERIAL# || 
               ', User: ' || USERNAME || ', Program: ' || PROGRAM
        INTO v_session_info
        FROM v$session
        WHERE SID = SYS_CONTEXT('USERENV', 'SID');
        
        RETURN v_session_info;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 'Session info unavailable';
    END get_session_info;
    
    PROCEDURE log_error(
        p_level IN VARCHAR2,
        p_procedure_name IN VARCHAR2,
        p_error_code IN NUMBER DEFAULT NULL,
        p_error_message IN VARCHAR2,
        p_additional_info IN CLOB DEFAULT NULL
    ) AS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO error_log (
            error_level,
            procedure_name,
            error_code,
            error_message,
            stack_trace,
            session_info,
            additional_info
        ) VALUES (
            p_level,
            p_procedure_name,
            p_error_code,
            p_error_message,
            DBMS_UTILITY.FORMAT_ERROR_BACKTRACE,
            get_session_info,
            p_additional_info
        );
        
        COMMIT;
    END log_error;
    
    PROCEDURE log_exception(
        p_procedure_name IN VARCHAR2,
        p_additional_info IN CLOB DEFAULT NULL
    ) AS
    BEGIN
        log_error(
            LEVEL_ERROR,
            p_procedure_name,
            SQLCODE,
            SQLERRM,
            p_additional_info
        );
    END log_exception;
    
END error_logger;
/

-- Example 6.2: Business Process with Comprehensive Error Handling
CREATE OR REPLACE PROCEDURE process_employee_bonus(
    p_employee_id IN employees.employee_id%TYPE,
    p_bonus_percentage IN NUMBER
) AS
    -- Local variables
    v_employee_name VARCHAR2(100);
    v_current_salary employees.salary%TYPE;
    v_bonus_amount NUMBER;
    v_new_salary NUMBER;
    
    -- Custom exceptions
    e_invalid_employee EXCEPTION;
    e_invalid_bonus_rate EXCEPTION;
    e_salary_limit_exceeded EXCEPTION;
    
    -- Constants
    c_procedure_name CONSTANT VARCHAR2(100) := 'process_employee_bonus';
    c_max_salary CONSTANT NUMBER := 100000;
    c_max_bonus_rate CONSTANT NUMBER := 50;
    
BEGIN
    -- Log procedure start
    error_logger.log_error(
        error_logger.LEVEL_INFO,
        c_procedure_name,
        NULL,
        'Processing bonus for employee ID: ' || p_employee_id || 
        ', Bonus rate: ' || p_bonus_percentage || '%'
    );
    
    -- Input validation
    IF p_employee_id IS NULL OR p_employee_id <= 0 THEN
        RAISE e_invalid_employee;
    END IF;
    
    IF p_bonus_percentage IS NULL OR p_bonus_percentage < 0 OR p_bonus_percentage > c_max_bonus_rate THEN
        RAISE e_invalid_bonus_rate;
    END IF;
    
    -- Get employee information
    BEGIN
        SELECT first_name || ' ' || last_name, salary
        INTO v_employee_name, v_current_salary
        FROM employees
        WHERE employee_id = p_employee_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE e_invalid_employee;
    END;
    
    -- Calculate bonus and new salary
    v_bonus_amount := v_current_salary * (p_bonus_percentage / 100);
    v_new_salary := v_current_salary + v_bonus_amount;
    
    -- Business rule validation
    IF v_new_salary > c_max_salary THEN
        RAISE e_salary_limit_exceeded;
    END IF;
    
    -- Update employee salary
    UPDATE employees
    SET salary = v_new_salary
    WHERE employee_id = p_employee_id;
    
    -- Log success
    error_logger.log_error(
        error_logger.LEVEL_INFO,
        c_procedure_name,
        NULL,
        'Bonus processed successfully for ' || v_employee_name || 
        '. Bonus: ' || v_bonus_amount || ', New salary: ' || v_new_salary
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('SUCCESS: Bonus processed for ' || v_employee_name);
    DBMS_OUTPUT.PUT_LINE('Bonus amount: ' || v_bonus_amount);
    DBMS_OUTPUT.PUT_LINE('New salary: ' || v_new_salary);
    
EXCEPTION
    WHEN e_invalid_employee THEN
        error_logger.log_error(
            error_logger.LEVEL_ERROR,
            c_procedure_name,
            -20001,
            'Invalid employee ID: ' || NVL(TO_CHAR(p_employee_id), 'NULL'),
            'Employee validation failed'
        );
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid employee ID');
        ROLLBACK;
        
    WHEN e_invalid_bonus_rate THEN
        error_logger.log_error(
            error_logger.LEVEL_ERROR,
            c_procedure_name,
            -20002,
            'Invalid bonus rate: ' || NVL(TO_CHAR(p_bonus_percentage), 'NULL') || 
            '. Must be between 0 and ' || c_max_bonus_rate,
            'Bonus rate validation failed'
        );
        DBMS_OUTPUT.PUT_LINE('ERROR: Invalid bonus rate');
        ROLLBACK;
        
    WHEN e_salary_limit_exceeded THEN
        error_logger.log_error(
            error_logger.LEVEL_ERROR,
            c_procedure_name,
            -20003,
            'Salary limit exceeded. New salary: ' || v_new_salary || 
            ', Limit: ' || c_max_salary,
            'Employee: ' || v_employee_name || ', Current salary: ' || v_current_salary
        );
        DBMS_OUTPUT.PUT_LINE('ERROR: Salary limit exceeded');
        ROLLBACK;
        
    WHEN OTHERS THEN
        error_logger.log_exception(
            c_procedure_name,
            'Employee ID: ' || p_employee_id || ', Bonus rate: ' || p_bonus_percentage
        );
        DBMS_OUTPUT.PUT_LINE('ERROR: Unexpected error - ' || SQLERRM);
        ROLLBACK;
        RAISE; -- Re-raise for higher level handling
END process_employee_bonus;
/

-- Test the comprehensive error handling
BEGIN
    process_employee_bonus(100, 10);    -- Success case
    process_employee_bonus(99999, 10);  -- Invalid employee
    process_employee_bonus(100, -5);    -- Invalid bonus rate
    process_employee_bonus(100, 60);    -- Bonus rate too high
END;
/

-- Check error log
SELECT log_id, error_date, error_level, procedure_name, error_message
FROM error_log
ORDER BY log_id DESC;

/*
==============================================================================
SECTION 7: PERFORMANCE MONITORING AND DEBUGGING
==============================================================================
*/

PROMPT 'Section 7: Performance Monitoring and Debugging'
PROMPT '==============================================='

-- Example 7.1: Performance Monitoring with Error Handling
CREATE OR REPLACE PACKAGE performance_monitor AS
    
    TYPE timing_record IS RECORD (
        operation_name VARCHAR2(100),
        start_time TIMESTAMP,
        end_time TIMESTAMP,
        duration_ms NUMBER,
        status VARCHAR2(20)
    );
    
    TYPE timing_table IS TABLE OF timing_record;
    
    PROCEDURE start_timing(p_operation_name IN VARCHAR2);
    PROCEDURE end_timing(p_operation_name IN VARCHAR2, p_status IN VARCHAR2 DEFAULT 'SUCCESS');
    PROCEDURE show_timings;
    PROCEDURE clear_timings;
    
END performance_monitor;
/

CREATE OR REPLACE PACKAGE BODY performance_monitor AS
    
    g_timings timing_table := timing_table();
    
    PROCEDURE start_timing(p_operation_name IN VARCHAR2) AS
        v_timing timing_record;
    BEGIN
        v_timing.operation_name := p_operation_name;
        v_timing.start_time := SYSTIMESTAMP;
        v_timing.status := 'RUNNING';
        
        g_timings.EXTEND;
        g_timings(g_timings.COUNT) := v_timing;
    END start_timing;
    
    PROCEDURE end_timing(p_operation_name IN VARCHAR2, p_status IN VARCHAR2 DEFAULT 'SUCCESS') AS
        v_end_time TIMESTAMP := SYSTIMESTAMP;
    BEGIN
        FOR i IN 1..g_timings.COUNT LOOP
            IF g_timings(i).operation_name = p_operation_name AND 
               g_timings(i).status = 'RUNNING' THEN
                g_timings(i).end_time := v_end_time;
                g_timings(i).duration_ms := EXTRACT(SECOND FROM (v_end_time - g_timings(i).start_time)) * 1000;
                g_timings(i).status := p_status;
                EXIT;
            END IF;
        END LOOP;
    END end_timing;
    
    PROCEDURE show_timings AS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Performance Timing Report ===');
        DBMS_OUTPUT.PUT_LINE(RPAD('Operation', 30) || RPAD('Duration (ms)', 15) || 'Status');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 30, '-') || RPAD('-', 15, '-') || RPAD('-', 10, '-'));
        
        FOR i IN 1..g_timings.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(g_timings(i).operation_name, 30) ||
                RPAD(NVL(TO_CHAR(g_timings(i).duration_ms, '999990.99'), 'N/A'), 15) ||
                g_timings(i).status
            );
        END LOOP;
    END show_timings;
    
    PROCEDURE clear_timings AS
    BEGIN
        g_timings := timing_table();
    END clear_timings;
    
END performance_monitor;
/

-- Example 7.2: Complex Business Process with Monitoring
CREATE OR REPLACE PROCEDURE process_monthly_reports AS
    v_start_date DATE := TRUNC(SYSDATE, 'MM');
    v_end_date DATE := LAST_DAY(SYSDATE);
    v_report_count NUMBER := 0;
    
    -- Custom exceptions
    e_no_data_to_process EXCEPTION;
    e_report_generation_failed EXCEPTION;
    
BEGIN
    performance_monitor.clear_timings;
    performance_monitor.start_timing('Monthly Report Generation');
    
    DBMS_OUTPUT.PUT_LINE('=== Monthly Report Processing ===');
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(v_start_date, 'DD-MON-YYYY') || 
                        ' to ' || TO_CHAR(v_end_date, 'DD-MON-YYYY'));
    
    -- Step 1: Data validation
    performance_monitor.start_timing('Data Validation');
    BEGIN
        SELECT COUNT(*)
        INTO v_report_count
        FROM employees
        WHERE hire_date BETWEEN v_start_date AND v_end_date;
        
        IF v_report_count = 0 THEN
            RAISE e_no_data_to_process;
        END IF;
        
        performance_monitor.end_timing('Data Validation');
        DBMS_OUTPUT.PUT_LINE('Data validation completed: ' || v_report_count || ' records found');
        
    EXCEPTION
        WHEN e_no_data_to_process THEN
            performance_monitor.end_timing('Data Validation', 'ERROR');
            error_logger.log_error(
                error_logger.LEVEL_WARNING,
                'process_monthly_reports',
                -20001,
                'No data found for the specified period'
            );
            DBMS_OUTPUT.PUT_LINE('WARNING: No data to process for this period');
            RETURN;
        WHEN OTHERS THEN
            performance_monitor.end_timing('Data Validation', 'ERROR');
            error_logger.log_exception('process_monthly_reports');
            RAISE;
    END;
    
    -- Step 2: Generate department summary
    performance_monitor.start_timing('Department Summary');
    BEGIN
        -- Simulate report generation with potential error
        DBMS_LOCK.SLEEP(0.1); -- Simulate processing time
        
        -- Simulate random error (10% chance)
        IF MOD(DBMS_RANDOM.VALUE(1, 10), 10) = 1 THEN
            RAISE e_report_generation_failed;
        END IF;
        
        performance_monitor.end_timing('Department Summary');
        DBMS_OUTPUT.PUT_LINE('Department summary generated successfully');
        
    EXCEPTION
        WHEN e_report_generation_failed THEN
            performance_monitor.end_timing('Department Summary', 'ERROR');
            error_logger.log_error(
                error_logger.LEVEL_ERROR,
                'process_monthly_reports',
                -20002,
                'Department summary generation failed'
            );
            DBMS_OUTPUT.PUT_LINE('ERROR: Department summary generation failed');
            RAISE;
    END;
    
    -- Step 3: Generate employee statistics
    performance_monitor.start_timing('Employee Statistics');
    BEGIN
        DBMS_LOCK.SLEEP(0.05); -- Simulate processing time
        performance_monitor.end_timing('Employee Statistics');
        DBMS_OUTPUT.PUT_LINE('Employee statistics generated successfully');
    EXCEPTION
        WHEN OTHERS THEN
            performance_monitor.end_timing('Employee Statistics', 'ERROR');
            error_logger.log_exception('process_monthly_reports');
            RAISE;
    END;
    
    -- Step 4: Finalize report
    performance_monitor.start_timing('Report Finalization');
    BEGIN
        DBMS_LOCK.SLEEP(0.02); -- Simulate processing time
        performance_monitor.end_timing('Report Finalization');
        DBMS_OUTPUT.PUT_LINE('Report finalization completed');
    EXCEPTION
        WHEN OTHERS THEN
            performance_monitor.end_timing('Report Finalization', 'ERROR');
            error_logger.log_exception('process_monthly_reports');
            RAISE;
    END;
    
    performance_monitor.end_timing('Monthly Report Generation');
    
    DBMS_OUTPUT.PUT_LINE('=== Monthly report processing completed successfully ===');
    performance_monitor.show_timings;
    
EXCEPTION
    WHEN OTHERS THEN
        performance_monitor.end_timing('Monthly Report Generation', 'ERROR');
        error_logger.log_exception('process_monthly_reports');
        DBMS_OUTPUT.PUT_LINE('=== Monthly report processing failed ===');
        performance_monitor.show_timings;
        RAISE;
END process_monthly_reports;
/

-- Test the monitoring system
BEGIN
    -- Run multiple times to see different outcomes
    FOR i IN 1..3 LOOP
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('=== Run #' || i || ' ===');
        BEGIN
            process_monthly_reports;
        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Run #' || i || ' failed: ' || SQLERRM);
        END;
    END LOOP;
END;
/

/*
==============================================================================
SECTION 8: PRODUCTION ERROR HANDLING BEST PRACTICES
==============================================================================
*/

PROMPT 'Section 8: Production Error Handling Best Practices'
PROMPT '==================================================='

-- Example 8.1: Centralized Error Handler
CREATE OR REPLACE PACKAGE error_handler AS
    
    -- Error severity levels
    SEVERITY_LOW CONSTANT NUMBER := 1;
    SEVERITY_MEDIUM CONSTANT NUMBER := 2;
    SEVERITY_HIGH CONSTANT NUMBER := 3;
    SEVERITY_CRITICAL CONSTANT NUMBER := 4;
    
    PROCEDURE handle_error(
        p_error_code IN NUMBER,
        p_error_message IN VARCHAR2,
        p_procedure_name IN VARCHAR2,
        p_severity IN NUMBER DEFAULT SEVERITY_MEDIUM,
        p_additional_info IN CLOB DEFAULT NULL,
        p_notify_admin IN BOOLEAN DEFAULT FALSE
    );
    
    FUNCTION format_error_message(
        p_error_code IN NUMBER,
        p_error_message IN VARCHAR2,
        p_procedure_name IN VARCHAR2
    ) RETURN VARCHAR2;
    
    PROCEDURE cleanup_old_logs(p_days_to_keep IN NUMBER DEFAULT 30);
    
END error_handler;
/

CREATE OR REPLACE PACKAGE BODY error_handler AS
    
    PROCEDURE handle_error(
        p_error_code IN NUMBER,
        p_error_message IN VARCHAR2,
        p_procedure_name IN VARCHAR2,
        p_severity IN NUMBER DEFAULT SEVERITY_MEDIUM,
        p_additional_info IN CLOB DEFAULT NULL,
        p_notify_admin IN BOOLEAN DEFAULT FALSE
    ) AS
        v_formatted_message VARCHAR2(4000);
        v_log_level VARCHAR2(20);
    BEGIN
        -- Determine log level based on severity
        CASE p_severity
            WHEN SEVERITY_LOW THEN v_log_level := error_logger.LEVEL_WARNING;
            WHEN SEVERITY_MEDIUM THEN v_log_level := error_logger.LEVEL_ERROR;
            WHEN SEVERITY_HIGH THEN v_log_level := error_logger.LEVEL_ERROR;
            WHEN SEVERITY_CRITICAL THEN v_log_level := error_logger.LEVEL_FATAL;
            ELSE v_log_level := error_logger.LEVEL_ERROR;
        END CASE;
        
        -- Format error message
        v_formatted_message := format_error_message(p_error_code, p_error_message, p_procedure_name);
        
        -- Log the error
        error_logger.log_error(
            v_log_level,
            p_procedure_name,
            p_error_code,
            v_formatted_message,
            p_additional_info
        );
        
        -- Output to console for immediate feedback
        DBMS_OUTPUT.PUT_LINE('ERROR [' || v_log_level || ']: ' || v_formatted_message);
        
        -- Notify administrator for critical errors
        IF p_notify_admin OR p_severity >= SEVERITY_CRITICAL THEN
            -- In production, this would send email, SMS, or other notification
            DBMS_OUTPUT.PUT_LINE('ALERT: Administrator notification would be sent');
        END IF;
        
    END handle_error;
    
    FUNCTION format_error_message(
        p_error_code IN NUMBER,
        p_error_message IN VARCHAR2,
        p_procedure_name IN VARCHAR2
    ) RETURN VARCHAR2 AS
    BEGIN
        RETURN '[' || p_procedure_name || '] Code: ' || p_error_code || ' - ' || p_error_message;
    END format_error_message;
    
    PROCEDURE cleanup_old_logs(p_days_to_keep IN NUMBER DEFAULT 30) AS
        v_deleted_count NUMBER;
    BEGIN
        DELETE FROM error_log
        WHERE error_date < SYSDATE - p_days_to_keep;
        
        v_deleted_count := SQL%ROWCOUNT;
        COMMIT;
        
        DBMS_OUTPUT.PUT_LINE('Cleaned up ' || v_deleted_count || ' old log entries');
    END cleanup_old_logs;
    
END error_handler;
/

-- Example 8.2: Robust Data Processing with Complete Error Handling
CREATE OR REPLACE PROCEDURE process_employee_data_batch(
    p_batch_id IN NUMBER,
    p_department_id IN NUMBER DEFAULT NULL
) AS
    
    CURSOR c_employees IS
        SELECT employee_id, first_name, last_name, salary, department_id
        FROM employees
        WHERE (p_department_id IS NULL OR department_id = p_department_id)
        ORDER BY employee_id;
    
    v_processed_count NUMBER := 0;
    v_error_count NUMBER := 0;
    v_start_time TIMESTAMP := SYSTIMESTAMP;
    v_employee_rec c_employees%ROWTYPE;
    
    -- Custom exceptions with proper error codes
    e_invalid_batch_id EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_batch_id, -20001);
    
    e_department_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_department_not_found, -20002);
    
    e_processing_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_processing_failed, -20003);
    
BEGIN
    -- Input validation
    IF p_batch_id IS NULL OR p_batch_id <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid batch ID provided');
    END IF;
    
    -- Validate department if provided
    IF p_department_id IS NOT NULL THEN
        DECLARE
            v_dept_count NUMBER;
        BEGIN
            SELECT COUNT(*)
            INTO v_dept_count
            FROM departments
            WHERE department_id = p_department_id;
            
            IF v_dept_count = 0 THEN
                RAISE_APPLICATION_ERROR(-20002, 'Department ID ' || p_department_id || ' not found');
            END IF;
        END;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('=== Starting Employee Data Batch Processing ===');
    DBMS_OUTPUT.PUT_LINE('Batch ID: ' || p_batch_id);
    DBMS_OUTPUT.PUT_LINE('Department Filter: ' || NVL(TO_CHAR(p_department_id), 'All Departments'));
    DBMS_OUTPUT.PUT_LINE('Start Time: ' || TO_CHAR(v_start_time, 'DD-MON-YYYY HH24:MI:SS.FF3'));
    
    -- Process each employee
    FOR emp_rec IN c_employees LOOP
        BEGIN
            -- Simulate data processing
            v_employee_rec := emp_rec;
            
            -- Business logic simulation with potential errors
            IF v_employee_rec.salary < 0 THEN
                RAISE_APPLICATION_ERROR(-20003, 'Invalid salary detected for employee ' || v_employee_rec.employee_id);
            END IF;
            
            -- Simulate random processing errors (5% chance)
            IF MOD(DBMS_RANDOM.VALUE(1, 20), 20) = 1 THEN
                RAISE_APPLICATION_ERROR(-20003, 'Random processing error for employee ' || v_employee_rec.employee_id);
            END IF;
            
            -- Process successful
            v_processed_count := v_processed_count + 1;
            
            -- Log progress every 50 records
            IF MOD(v_processed_count, 50) = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Processed ' || v_processed_count || ' employees...');
            END IF;
            
        EXCEPTION
            WHEN e_processing_failed THEN
                v_error_count := v_error_count + 1;
                error_handler.handle_error(
                    SQLCODE,
                    SQLERRM,
                    'process_employee_data_batch',
                    error_handler.SEVERITY_MEDIUM,
                    'Employee ID: ' || v_employee_rec.employee_id || 
                    ', Batch ID: ' || p_batch_id
                );
                
            WHEN OTHERS THEN
                v_error_count := v_error_count + 1;
                error_handler.handle_error(
                    SQLCODE,
                    SQLERRM,
                    'process_employee_data_batch',
                    error_handler.SEVERITY_HIGH,
                    'Employee ID: ' || v_employee_rec.employee_id || 
                    ', Batch ID: ' || p_batch_id
                );
        END;
    END LOOP;
    
    -- Final reporting
    DECLARE
        v_end_time TIMESTAMP := SYSTIMESTAMP;
        v_duration_seconds NUMBER;
    BEGIN
        v_duration_seconds := EXTRACT(SECOND FROM (v_end_time - v_start_time));
        
        DBMS_OUTPUT.PUT_LINE('=== Batch Processing Completed ===');
        DBMS_OUTPUT.PUT_LINE('Processed Records: ' || v_processed_count);
        DBMS_OUTPUT.PUT_LINE('Error Records: ' || v_error_count);
        DBMS_OUTPUT.PUT_LINE('Total Duration: ' || ROUND(v_duration_seconds, 3) || ' seconds');
        DBMS_OUTPUT.PUT_LINE('End Time: ' || TO_CHAR(v_end_time, 'DD-MON-YYYY HH24:MI:SS.FF3'));
        
        -- Log batch completion
        error_logger.log_error(
            error_logger.LEVEL_INFO,
            'process_employee_data_batch',
            NULL,
            'Batch processing completed. Processed: ' || v_processed_count || 
            ', Errors: ' || v_error_count || ', Duration: ' || ROUND(v_duration_seconds, 3) || 's',
            'Batch ID: ' || p_batch_id || ', Department: ' || NVL(TO_CHAR(p_department_id), 'ALL')
        );
    END;
    
EXCEPTION
    WHEN e_invalid_batch_id THEN
        error_handler.handle_error(
            SQLCODE,
            SQLERRM,
            'process_employee_data_batch',
            error_handler.SEVERITY_HIGH,
            'Invalid batch ID: ' || NVL(TO_CHAR(p_batch_id), 'NULL'),
            TRUE
        );
        RAISE;
        
    WHEN e_department_not_found THEN
        error_handler.handle_error(
            SQLCODE,
            SQLERRM,
            'process_employee_data_batch',
            error_handler.SEVERITY_HIGH,
            'Department validation failed: ' || NVL(TO_CHAR(p_department_id), 'NULL'),
            TRUE
        );
        RAISE;
        
    WHEN OTHERS THEN
        error_handler.handle_error(
            SQLCODE,
            SQLERRM,
            'process_employee_data_batch',
            error_handler.SEVERITY_CRITICAL,
            'Batch ID: ' || NVL(TO_CHAR(p_batch_id), 'NULL') || 
            ', Department: ' || NVL(TO_CHAR(p_department_id), 'NULL'),
            TRUE
        );
        RAISE;
END process_employee_data_batch;
/

-- Test the robust error handling
BEGIN
    -- Test successful processing
    process_employee_data_batch(1001, 10);
    
    -- Test with invalid inputs
    BEGIN
        process_employee_data_batch(-1, 10);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Expected error caught: ' || SQLERRM);
    END;
    
    BEGIN
        process_employee_data_batch(1002, 99999);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Expected error caught: ' || SQLERRM);
    END;
END;
/

/*
==============================================================================
SECTION 9: ERROR HANDLING SUMMARY AND CLEANUP
==============================================================================
*/

PROMPT 'Section 9: Error Handling Summary'
PROMPT '================================='

-- Example 9.1: Error Log Analysis
CREATE OR REPLACE PROCEDURE analyze_error_patterns AS
    CURSOR c_error_summary IS
        SELECT 
            error_level,
            procedure_name,
            COUNT(*) as error_count,
            MIN(error_date) as first_occurrence,
            MAX(error_date) as last_occurrence
        FROM error_log
        WHERE error_date >= SYSDATE - 7 -- Last 7 days
        GROUP BY error_level, procedure_name
        ORDER BY error_count DESC, error_level;
        
    v_total_errors NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Error Pattern Analysis (Last 7 Days) ===');
    
    SELECT COUNT(*)
    INTO v_total_errors
    FROM error_log
    WHERE error_date >= SYSDATE - 7;
    
    DBMS_OUTPUT.PUT_LINE('Total Errors: ' || v_total_errors);
    DBMS_OUTPUT.PUT_LINE('');
    
    IF v_total_errors > 0 THEN
        DBMS_OUTPUT.PUT_LINE(RPAD('Procedure', 30) || RPAD('Level', 10) || 
                            RPAD('Count', 8) || RPAD('First', 20) || 'Last');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 30, '-') || RPAD('-', 10, '-') || 
                            RPAD('-', 8, '-') || RPAD('-', 20, '-') || RPAD('-', 20, '-'));
        
        FOR rec IN c_error_summary LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(NVL(rec.procedure_name, 'Unknown'), 30) ||
                RPAD(rec.error_level, 10) ||
                RPAD(rec.error_count, 8) ||
                RPAD(TO_CHAR(rec.first_occurrence, 'DD-MON HH24:MI'), 20) ||
                TO_CHAR(rec.last_occurrence, 'DD-MON HH24:MI')
            );
        END LOOP;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No errors found in the last 7 days.');
    END IF;
END analyze_error_patterns;
/

-- Run error analysis
BEGIN
    analyze_error_patterns;
END;
/

-- Example 9.2: Best Practices Summary
PROMPT ''
PROMPT '=== ERROR HANDLING BEST PRACTICES SUMMARY ==='
PROMPT '1. Always handle specific exceptions before OTHERS'
PROMPT '2. Use meaningful exception names with PRAGMA EXCEPTION_INIT'
PROMPT '3. Log errors with appropriate severity levels'
PROMPT '4. Include context information in error messages'
PROMPT '5. Use autonomous transactions for error logging'
PROMPT '6. Implement proper cleanup in exception handlers'
PROMPT '7. Consider exception propagation carefully'
PROMPT '8. Monitor and analyze error patterns regularly'
PROMPT '9. Use performance monitoring for debugging'
PROMPT '10. Document error handling strategies'

/*
==============================================================================
CLEANUP SECTION
==============================================================================
*/

PROMPT ''
PROMPT 'Cleanup Section'
PROMPT '==============='
PROMPT 'The following objects were created during this lesson:'
PROMPT '- error_log table (for logging errors)'
PROMPT '- error_logger package (logging utilities)'
PROMPT '- error_handling_patterns package (exception examples)'
PROMPT '- performance_monitor package (timing utilities)'
PROMPT '- error_handler package (centralized error handling)'
PROMPT '- Various procedures demonstrating error handling patterns'
PROMPT ''
PROMPT 'To clean up (optional):'
PROMPT 'DROP TABLE error_log;'
PROMPT 'DROP PACKAGE error_logger;'
PROMPT 'DROP PACKAGE error_handling_patterns;'
PROMPT 'DROP PACKAGE performance_monitor;'
PROMPT 'DROP PACKAGE error_handler;'
PROMPT 'DROP PROCEDURE demo_builtin_exceptions;'
PROMPT 'DROP PROCEDURE process_salary_increase;'
PROMPT 'DROP PROCEDURE demo_pragma_exception;'
PROMPT 'DROP PROCEDURE process_employee_bonus;'
PROMPT 'DROP PROCEDURE process_monthly_reports;'
PROMPT 'DROP PROCEDURE process_employee_data_batch;'
PROMPT 'DROP PROCEDURE analyze_error_patterns;'
PROMPT ''

/*
==============================================================================
LESSON COMPLETION
==============================================================================
*/

PROMPT '===================================================='
PROMPT 'LESSON 5 - ERROR HANDLING & DEBUGGING COMPLETED!'
PROMPT '===================================================='
PROMPT ''
PROMPT 'You have successfully completed comprehensive error handling training!'
PROMPT ''
PROMPT 'Key skills learned:'
PROMPT '✓ Exception handling mechanisms'
PROMPT '✓ Custom exception creation'
PROMPT '✓ Error logging and monitoring'
PROMPT '✓ Performance debugging'
PROMPT '✓ Production error management'
PROMPT '✓ Best practices implementation'
PROMPT ''
PROMPT 'Next steps:'
PROMPT '- Practice implementing error handling in your own procedures'
PROMPT '- Set up error monitoring in development environments'
PROMPT '- Review and enhance existing code with proper error handling'
PROMPT '- Study Oracle documentation for advanced error handling features'
PROMPT ''
PROMPT 'Happy coding with robust error handling!'
PROMPT '===================================================='
