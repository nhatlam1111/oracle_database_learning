# Error Handling và Debugging trong Oracle PL/SQL

## Mục Tiêu Học Tập
Sau khi hoàn thành bài học này, bạn sẽ có thể:
- Triển khai chiến lược xử lý lỗi toàn diện
- Sử dụng cơ chế exception handling của Oracle hiệu quả
- Debug PL/SQL code sử dụng nhiều kỹ thuật và công cụ khác nhau
- Áp dụng thực hành tốt cho logging và monitoring
- Xử lý các loại lỗi khác nhau một cách phù hợp
- Tạo các ứng dụng PL/SQL robust, sẵn sàng production

## Điều Kiện Tiên Quyết
- Hiểu vững về PL/SQL fundamentals
- Kinh nghiệm với procedures, functions và packages
- Kiến thức về kiến trúc Oracle database
- Quen thuộc với SQL*Plus và development tools

## 1. Hiểu về Oracle Errors

### 1.1 Các loại Errors

#### Compilation Errors
```sql
-- Ví dụ về compilation errors
CREATE OR REPLACE PROCEDURE bad_syntax_example IS
    v_count NUMER; -- Sai data type
BEGIN
    SELCT COUNT(*) INTO v_count FROM employees; -- Lỗi chính tả trong SELECT
    IF v_count > 0
        DBMS_OUTPUT.PUT_LINE('Found employees'); -- Thiếu THEN
    END IF
END; -- Thiếu dấu chấm phẩy

-- Xem compilation errors
SHOW ERRORS PROCEDURE bad_syntax_example;

-- Hoặc truy vấn user_errors
SELECT line, position, text
FROM user_errors
WHERE name = 'BAD_SYNTAX_EXAMPLE'
AND type = 'PROCEDURE'
ORDER BY sequence;
```

#### Runtime Errors
```sql
CREATE OR REPLACE PROCEDURE runtime_error_examples IS
    v_salary NUMBER;
    v_name VARCHAR2(10);
    v_result NUMBER;
BEGIN
    -- NO_DATA_FOUND error
    SELECT salary INTO v_salary
    FROM employees
    WHERE employee_id = 99999; -- Non-existent employee
    
    -- VALUE_ERROR
    v_name := 'This string is too long for the variable';
    
    -- ZERO_DIVIDE error
    v_result := 100 / 0;
    
    -- INVALID_NUMBER
    v_result := TO_NUMBER('ABC');
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Value error occurred');
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Division by zero');
    WHEN INVALID_NUMBER THEN
        DBMS_OUTPUT.PUT_LINE('Invalid number conversion');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END runtime_error_examples;
```

#### Logic Errors
```sql
-- Example of logic errors (harder to detect)
CREATE OR REPLACE FUNCTION calculate_bonus_with_logic_error(
    p_salary NUMBER,
    p_performance_rating NUMBER
) RETURN NUMBER IS
    v_bonus NUMBER;
BEGIN
    -- Logic error: should be >= for rating 4 and 5
    IF p_performance_rating > 4 THEN
        v_bonus := p_salary * 0.15;
    ELSIF p_performance_rating > 3 THEN
        v_bonus := p_salary * 0.10;
    ELSE
        v_bonus := p_salary * 0.05;
    END IF;
    
    -- Another logic error: should be positive
    RETURN ABS(v_bonus); -- Masking potential negative values
END calculate_bonus_with_logic_error;
```

## 2. Exception Handling Fundamentals

### 2.1 Built-in Exceptions
```sql
CREATE OR REPLACE PROCEDURE handle_builtin_exceptions IS
    v_emp_count NUMBER;
    v_salary NUMBER;
    v_name VARCHAR2(50);
    v_date DATE;
    
    -- Custom cursor
    CURSOR emp_cursor IS
        SELECT employee_id, first_name, salary
        FROM employees
        WHERE department_id = 10;
    
BEGIN
    -- Handle TOO_MANY_ROWS
    BEGIN
        SELECT salary INTO v_salary
        FROM employees
        WHERE department_id = 10; -- Multiple rows expected
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            DBMS_OUTPUT.PUT_LINE('Multiple employees found, using cursor instead');
            
            FOR emp_rec IN emp_cursor LOOP
                DBMS_OUTPUT.PUT_LINE(emp_rec.first_name || ': $' || emp_rec.salary);
            END LOOP;
    END;
    
    -- Handle INVALID_CURSOR
    BEGIN
        FETCH emp_cursor INTO v_emp_count, v_name, v_salary; -- Cursor not open
    EXCEPTION
        WHEN INVALID_CURSOR THEN
            DBMS_OUTPUT.PUT_LINE('Cursor operation error - cursor not open');
    END;
    
    -- Handle DUP_VAL_ON_INDEX
    BEGIN
        INSERT INTO departments (department_id, department_name)
        VALUES (10, 'Test Department'); -- Duplicate primary key
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Department already exists');
    END;
    
    -- Handle CASE_NOT_FOUND
    BEGIN
        v_name := CASE 999
            WHEN 1 THEN 'One'
            WHEN 2 THEN 'Two'
            WHEN 3 THEN 'Three'
        END; -- No ELSE clause and no match
    EXCEPTION
        WHEN CASE_NOT_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No matching CASE found');
            v_name := 'Unknown';
    END;
    
    -- Handle CURSOR_ALREADY_OPEN
    BEGIN
        OPEN emp_cursor;
        OPEN emp_cursor; -- Trying to open already open cursor
    EXCEPTION
        WHEN CURSOR_ALREADY_OPEN THEN
            DBMS_OUTPUT.PUT_LINE('Cursor is already open');
    FINALLY
        IF emp_cursor%ISOPEN THEN
            CLOSE emp_cursor;
        END IF;
    END;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error in procedure: ' || SQLERRM);
        -- Cleanup code
        IF emp_cursor%ISOPEN THEN
            CLOSE emp_cursor;
        END IF;
        RAISE; -- Re-raise the exception
END handle_builtin_exceptions;
```

### 2.2 User-Defined Exceptions
```sql
CREATE OR REPLACE PACKAGE employee_exceptions AS
    -- Define custom exceptions
    invalid_salary_exception EXCEPTION;
    employee_not_found_exception EXCEPTION;
    department_full_exception EXCEPTION;
    invalid_performance_rating_exception EXCEPTION;
    
    -- Associate error codes with exceptions
    PRAGMA EXCEPTION_INIT(invalid_salary_exception, -20001);
    PRAGMA EXCEPTION_INIT(employee_not_found_exception, -20002);
    PRAGMA EXCEPTION_INIT(department_full_exception, -20003);
    PRAGMA EXCEPTION_INIT(invalid_performance_rating_exception, -20004);
    
END employee_exceptions;

CREATE OR REPLACE PROCEDURE comprehensive_employee_validation(
    p_employee_id NUMBER,
    p_salary NUMBER,
    p_department_id NUMBER,
    p_performance_rating NUMBER DEFAULT NULL
) IS
    v_emp_count NUMBER;
    v_dept_count NUMBER;
    v_dept_max_employees NUMBER;
    v_current_emp_count NUMBER;
    
BEGIN
    -- Validate employee exists
    SELECT COUNT(*) INTO v_emp_count
    FROM employees
    WHERE employee_id = p_employee_id;
    
    IF v_emp_count = 0 THEN
        RAISE employee_exceptions.employee_not_found_exception;
    END IF;
    
    -- Validate salary range
    IF p_salary < 30000 OR p_salary > 200000 THEN
        RAISE employee_exceptions.invalid_salary_exception;
    END IF;
    
    -- Validate department capacity
    SELECT COUNT(*), NVL(max_employees, 999)
    INTO v_current_emp_count, v_dept_max_employees
    FROM departments d
    LEFT JOIN (SELECT department_id, COUNT(*) as current_count 
               FROM employees GROUP BY department_id) e
        ON d.department_id = e.department_id
    WHERE d.department_id = p_department_id;
    
    IF v_current_emp_count >= v_dept_max_employees THEN
        RAISE employee_exceptions.department_full_exception;
    END IF;
    
    -- Validate performance rating
    IF p_performance_rating IS NOT NULL AND 
       (p_performance_rating < 1 OR p_performance_rating > 5) THEN
        RAISE employee_exceptions.invalid_performance_rating_exception;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('All validations passed');
    
EXCEPTION
    WHEN employee_exceptions.employee_not_found_exception THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Employee ID ' || p_employee_id || ' not found');
            
    WHEN employee_exceptions.invalid_salary_exception THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Salary must be between $30,000 and $200,000. Provided: $' || p_salary);
            
    WHEN employee_exceptions.department_full_exception THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'Department ' || p_department_id || ' has reached maximum capacity');
            
    WHEN employee_exceptions.invalid_performance_rating_exception THEN
        RAISE_APPLICATION_ERROR(-20004, 
            'Performance rating must be between 1 and 5. Provided: ' || p_performance_rating);
            
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 
            'Validation error: ' || SQLERRM);
END comprehensive_employee_validation;
```

### 2.3 Exception Propagation and Re-raising
```sql
CREATE OR REPLACE PACKAGE error_propagation_demo AS
    
    PROCEDURE level_3_procedure(p_value NUMBER);
    PROCEDURE level_2_procedure(p_value NUMBER);
    PROCEDURE level_1_procedure(p_value NUMBER);
    
END error_propagation_demo;

CREATE OR REPLACE PACKAGE BODY error_propagation_demo AS
    
    PROCEDURE level_3_procedure(p_value NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Level 3: Processing value ' || p_value);
        
        IF p_value = 0 THEN
            RAISE_APPLICATION_ERROR(-20100, 'Level 3: Zero value not allowed');
        ELSIF p_value < 0 THEN
            RAISE VALUE_ERROR;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Level 3: Processing completed successfully');
        
    EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('Level 3: Handling VALUE_ERROR');
            RAISE_APPLICATION_ERROR(-20101, 'Level 3: Negative value encountered');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Level 3: Unexpected error - ' || SQLERRM);
            RAISE; -- Re-raise the exception
    END level_3_procedure;
    
    PROCEDURE level_2_procedure(p_value NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Level 2: Calling level 3');
        
        level_3_procedure(p_value);
        
        DBMS_OUTPUT.PUT_LINE('Level 2: Level 3 completed successfully');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Level 2: Caught error - ' || SQLERRM);
            
            -- Log the error but continue propagation
            INSERT INTO error_log (
                error_date, error_code, error_message, 
                procedure_name, input_parameters
            ) VALUES (
                SYSDATE, SQLCODE, SQLERRM,
                'level_2_procedure', 'p_value=' || p_value
            );
            
            RAISE; -- Re-raise to level 1
    END level_2_procedure;
    
    PROCEDURE level_1_procedure(p_value NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Level 1: Starting processing');
        
        level_2_procedure(p_value);
        
        DBMS_OUTPUT.PUT_LINE('Level 1: All processing completed');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Level 1: Final error handler - ' || SQLERRM);
            
            -- Final cleanup and user-friendly error
            RAISE_APPLICATION_ERROR(-20000, 
                'Processing failed. Please contact system administrator. ' ||
                'Error details: ' || SQLERRM);
    END level_1_procedure;
    
END error_propagation_demo;

-- Test the error propagation
BEGIN
    error_propagation_demo.level_1_procedure(0);   -- Will cause application error
    error_propagation_demo.level_1_procedure(-5);  -- Will cause VALUE_ERROR
    error_propagation_demo.level_1_procedure(10);  -- Will succeed
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Final handler: ' || SQLERRM);
END;
```

## 3. Advanced Error Handling Patterns

### 3.1 Error Logging Framework
```sql
-- Create error logging table
CREATE TABLE error_log (
    error_id NUMBER GENERATED ALWAYS AS IDENTITY,
    error_date DATE DEFAULT SYSDATE,
    username VARCHAR2(100) DEFAULT USER,
    error_code NUMBER,
    error_message VARCHAR2(4000),
    error_stack CLOB,
    error_backtrace CLOB,
    procedure_name VARCHAR2(100),
    input_parameters CLOB,
    session_id NUMBER DEFAULT SYS_CONTEXT('USERENV', 'SESSIONID'),
    client_info VARCHAR2(4000) DEFAULT SYS_CONTEXT('USERENV', 'CLIENT_INFO')
);

-- Error logging package
CREATE OR REPLACE PACKAGE error_logger AS
    
    -- Log error with full context
    PROCEDURE log_error(
        p_procedure_name VARCHAR2,
        p_input_parameters VARCHAR2 DEFAULT NULL,
        p_additional_info VARCHAR2 DEFAULT NULL
    );
    
    -- Log custom error
    PROCEDURE log_custom_error(
        p_error_code NUMBER,
        p_error_message VARCHAR2,
        p_procedure_name VARCHAR2,
        p_input_parameters VARCHAR2 DEFAULT NULL
    );
    
    -- Get error statistics
    FUNCTION get_error_count(
        p_procedure_name VARCHAR2 DEFAULT NULL,
        p_hours_back NUMBER DEFAULT 24
    ) RETURN NUMBER;
    
END error_logger;

CREATE OR REPLACE PACKAGE BODY error_logger AS
    
    PROCEDURE log_error(
        p_procedure_name VARCHAR2,
        p_input_parameters VARCHAR2 DEFAULT NULL,
        p_additional_info VARCHAR2 DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_error_stack CLOB;
        v_error_backtrace CLOB;
    BEGIN
        -- Get detailed error information
        v_error_stack := DBMS_UTILITY.FORMAT_ERROR_STACK;
        v_error_backtrace := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        
        INSERT INTO error_log (
            error_code, error_message, error_stack, error_backtrace,
            procedure_name, input_parameters
        ) VALUES (
            SQLCODE, 
            SQLERRM || CASE WHEN p_additional_info IS NOT NULL 
                           THEN CHR(10) || 'Additional Info: ' || p_additional_info 
                           ELSE NULL END,
            v_error_stack,
            v_error_backtrace,
            p_procedure_name,
            p_input_parameters
        );
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- If logging fails, write to alert log
            DBMS_SYSTEM.KSDWRT(2, 'Error Logger Failed: ' || SQLERRM);
            ROLLBACK;
    END log_error;
    
    PROCEDURE log_custom_error(
        p_error_code NUMBER,
        p_error_message VARCHAR2,
        p_procedure_name VARCHAR2,
        p_input_parameters VARCHAR2 DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO error_log (
            error_code, error_message, procedure_name, input_parameters
        ) VALUES (
            p_error_code, p_error_message, p_procedure_name, p_input_parameters
        );
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_SYSTEM.KSDWRT(2, 'Custom Error Logger Failed: ' || SQLERRM);
            ROLLBACK;
    END log_custom_error;
    
    FUNCTION get_error_count(
        p_procedure_name VARCHAR2 DEFAULT NULL,
        p_hours_back NUMBER DEFAULT 24
    ) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM error_log
        WHERE error_date >= SYSDATE - (p_hours_back / 24)
        AND (p_procedure_name IS NULL OR procedure_name = p_procedure_name);
        
        RETURN v_count;
    END get_error_count;
    
END error_logger;
```

### 3.2 Comprehensive Error Handling Procedure
```sql
CREATE OR REPLACE PROCEDURE process_employee_data(
    p_employee_id NUMBER,
    p_operation VARCHAR2,
    p_data VARCHAR2
) IS
    -- Local variables
    v_emp_count NUMBER;
    v_processed_data VARCHAR2(4000);
    v_start_time DATE := SYSDATE;
    
    -- Local exceptions
    invalid_operation_exception EXCEPTION;
    
    -- Input validation procedure
    PROCEDURE validate_inputs IS
    BEGIN
        -- Validate employee ID
        IF p_employee_id IS NULL OR p_employee_id <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid employee ID: ' || p_employee_id);
        END IF;
        
        -- Check if employee exists
        SELECT COUNT(*) INTO v_emp_count
        FROM employees
        WHERE employee_id = p_employee_id;
        
        IF v_emp_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Employee not found: ' || p_employee_id);
        END IF;
        
        -- Validate operation
        IF p_operation NOT IN ('UPDATE', 'DELETE', 'ARCHIVE') THEN
            RAISE invalid_operation_exception;
        END IF;
    END validate_inputs;
    
    -- Data processing procedure
    PROCEDURE process_data IS
    BEGIN
        CASE p_operation
            WHEN 'UPDATE' THEN
                -- Update logic
                UPDATE employees 
                SET last_modified = SYSDATE,
                    notes = p_data
                WHERE employee_id = p_employee_id;
                
                v_processed_data := 'Updated employee ' || p_employee_id;
                
            WHEN 'DELETE' THEN
                -- Soft delete logic
                UPDATE employees 
                SET status = 'INACTIVE',
                    termination_date = SYSDATE,
                    termination_reason = p_data
                WHERE employee_id = p_employee_id;
                
                v_processed_data := 'Deactivated employee ' || p_employee_id;
                
            WHEN 'ARCHIVE' THEN
                -- Archive logic
                INSERT INTO employee_archive 
                SELECT *, SYSDATE as archive_date 
                FROM employees 
                WHERE employee_id = p_employee_id;
                
                v_processed_data := 'Archived employee ' || p_employee_id;
        END CASE;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'No rows affected by operation');
        END IF;
    END process_data;
    
BEGIN
    -- Main processing
    DBMS_OUTPUT.PUT_LINE('Starting employee processing...');
    
    -- Step 1: Validate inputs
    BEGIN
        validate_inputs;
        DBMS_OUTPUT.PUT_LINE('Input validation completed');
    EXCEPTION
        WHEN invalid_operation_exception THEN
            RAISE_APPLICATION_ERROR(-20004, 
                'Invalid operation: ' || p_operation || 
                '. Allowed operations: UPDATE, DELETE, ARCHIVE');
        WHEN OTHERS THEN
            error_logger.log_error(
                'process_employee_data.validate_inputs',
                'emp_id=' || p_employee_id || ', operation=' || p_operation
            );
            RAISE;
    END;
    
    -- Step 2: Process data
    BEGIN
        process_data;
        DBMS_OUTPUT.PUT_LINE('Data processing completed: ' || v_processed_data);
    EXCEPTION
        WHEN OTHERS THEN
            error_logger.log_error(
                'process_employee_data.process_data',
                'emp_id=' || p_employee_id || ', operation=' || p_operation || ', data=' || p_data
            );
            RAISE;
    END;
    
    -- Step 3: Commit transaction
    COMMIT;
    
    -- Log successful completion
    DBMS_OUTPUT.PUT_LINE('Employee processing completed successfully in ' || 
                        ROUND((SYSDATE - v_start_time) * 24 * 60 * 60, 2) || ' seconds');
    
EXCEPTION
    -- Handle specific application errors
    WHEN OTHERS THEN
        -- Rollback transaction
        ROLLBACK;
        
        -- Log the error with full context
        error_logger.log_error(
            'process_employee_data',
            'emp_id=' || p_employee_id || ', operation=' || p_operation || ', data=' || p_data,
            'Processing time: ' || ROUND((SYSDATE - v_start_time) * 24 * 60 * 60, 2) || ' seconds'
        );
        
        -- Provide user-friendly error message
        CASE SQLCODE
            WHEN -20001 THEN
                DBMS_OUTPUT.PUT_LINE('Error: Invalid employee ID provided');
            WHEN -20002 THEN
                DBMS_OUTPUT.PUT_LINE('Error: Employee not found in system');
            WHEN -20003 THEN
                DBMS_OUTPUT.PUT_LINE('Error: Operation had no effect');
            WHEN -20004 THEN
                DBMS_OUTPUT.PUT_LINE('Error: Invalid operation specified');
            WHEN -1 THEN
                DBMS_OUTPUT.PUT_LINE('Error: Duplicate value constraint violation');
            WHEN -1400 THEN
                DBMS_OUTPUT.PUT_LINE('Error: Required field cannot be null');
            ELSE
                DBMS_OUTPUT.PUT_LINE('Error: Unexpected system error occurred');
        END CASE;
        
        -- Re-raise for calling program
        RAISE;
END process_employee_data;
```

## 4. Debugging Techniques

### 4.1 DBMS_OUTPUT Debugging
```sql
CREATE OR REPLACE PROCEDURE debug_with_output(p_dept_id NUMBER) IS
    v_emp_count NUMBER;
    v_total_salary NUMBER;
    v_avg_salary NUMBER;
    
    -- Debug flag
    c_debug CONSTANT BOOLEAN := TRUE;
    
    PROCEDURE debug_print(p_message VARCHAR2) IS
    BEGIN
        IF c_debug THEN
            DBMS_OUTPUT.PUT_LINE('[DEBUG ' || TO_CHAR(SYSDATE, 'HH24:MI:SS') || '] ' || p_message);
        END IF;
    END debug_print;
    
BEGIN
    debug_print('Starting debug_with_output for department: ' || p_dept_id);
    
    -- Step 1: Count employees
    debug_print('Counting employees in department...');
    SELECT COUNT(*) INTO v_emp_count
    FROM employees
    WHERE department_id = p_dept_id;
    debug_print('Found ' || v_emp_count || ' employees');
    
    IF v_emp_count = 0 THEN
        debug_print('No employees found, exiting');
        RETURN;
    END IF;
    
    -- Step 2: Calculate total salary
    debug_print('Calculating total salary...');
    SELECT SUM(salary) INTO v_total_salary
    FROM employees
    WHERE department_id = p_dept_id;
    debug_print('Total salary: $' || v_total_salary);
    
    -- Step 3: Calculate average
    debug_print('Calculating average salary...');
    v_avg_salary := v_total_salary / v_emp_count;
    debug_print('Average salary: $' || ROUND(v_avg_salary, 2));
    
    -- Final result
    DBMS_OUTPUT.PUT_LINE('Department ' || p_dept_id || 
                        ': ' || v_emp_count || ' employees, ' ||
                        'Average salary: $' || ROUND(v_avg_salary, 2));
    
    debug_print('Procedure completed successfully');
    
EXCEPTION
    WHEN OTHERS THEN
        debug_print('ERROR: ' || SQLERRM);
        debug_print('Error occurred at: ' || DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
        RAISE;
END debug_with_output;
```

### 4.2 Profiling and Performance Debugging
```sql
-- Performance monitoring package
CREATE OR REPLACE PACKAGE performance_monitor AS
    
    TYPE timing_rec_t IS RECORD (
        operation_name VARCHAR2(100),
        start_time NUMBER,
        end_time NUMBER,
        duration_ms NUMBER
    );
    
    TYPE timing_list_t IS TABLE OF timing_rec_t;
    g_timings timing_list_t := timing_list_t();
    
    PROCEDURE start_timer(p_operation_name VARCHAR2);
    PROCEDURE end_timer(p_operation_name VARCHAR2);
    PROCEDURE print_timings;
    PROCEDURE clear_timings;
    
END performance_monitor;

CREATE OR REPLACE PACKAGE BODY performance_monitor AS
    
    PROCEDURE start_timer(p_operation_name VARCHAR2) IS
        v_timing timing_rec_t;
    BEGIN
        v_timing.operation_name := p_operation_name;
        v_timing.start_time := DBMS_UTILITY.GET_TIME;
        
        g_timings.EXTEND;
        g_timings(g_timings.COUNT) := v_timing;
    END start_timer;
    
    PROCEDURE end_timer(p_operation_name VARCHAR2) IS
    BEGIN
        FOR i IN REVERSE 1 .. g_timings.COUNT LOOP
            IF g_timings(i).operation_name = p_operation_name AND 
               g_timings(i).end_time IS NULL THEN
                
                g_timings(i).end_time := DBMS_UTILITY.GET_TIME;
                g_timings(i).duration_ms := (g_timings(i).end_time - g_timings(i).start_time) * 10;
                EXIT;
            END IF;
        END LOOP;
    END end_timer;
    
    PROCEDURE print_timings IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Performance Timings ===');
        FOR i IN 1 .. g_timings.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE(
                RPAD(g_timings(i).operation_name, 30) || ': ' ||
                LPAD(g_timings(i).duration_ms || ' ms', 10)
            );
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('===========================');
    END print_timings;
    
    PROCEDURE clear_timings IS
    BEGIN
        g_timings.DELETE;
    END clear_timings;
    
END performance_monitor;

-- Example procedure using performance monitoring
CREATE OR REPLACE PROCEDURE performance_test_procedure IS
    v_count NUMBER;
    v_sum NUMBER;
BEGIN
    performance_monitor.clear_timings;
    
    -- Test 1: Simple count
    performance_monitor.start_timer('Employee Count');
    SELECT COUNT(*) INTO v_count FROM employees;
    performance_monitor.end_timer('Employee Count');
    
    -- Test 2: Complex aggregation
    performance_monitor.start_timer('Salary Aggregation');
    SELECT SUM(salary) INTO v_sum
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.hire_date >= ADD_MONTHS(SYSDATE, -12);
    performance_monitor.end_timer('Salary Aggregation');
    
    -- Test 3: Bulk operation
    performance_monitor.start_timer('Bulk Update');
    UPDATE employees 
    SET last_modified = SYSDATE 
    WHERE department_id IN (10, 20, 30);
    performance_monitor.end_timer('Bulk Update');
    
    -- Print results
    performance_monitor.print_timings;
    
END performance_test_procedure;
```

### 4.3 Using DBMS_HPROF for Code Profiling
```sql
-- Profiling example
CREATE OR REPLACE PROCEDURE profile_example IS
    v_result NUMBER;
    
    FUNCTION slow_function(p_input NUMBER) RETURN NUMBER IS
        v_total NUMBER := 0;
    BEGIN
        FOR i IN 1 .. p_input LOOP
            v_total := v_total + SQRT(i);
            -- Simulate processing time
            NULL;
        END LOOP;
        RETURN v_total;
    END slow_function;
    
    FUNCTION fast_function(p_input NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_input * (p_input + 1) / 2;
    END fast_function;
    
BEGIN
    -- Start profiling
    DBMS_HPROF.START_PROFILING('PLSQL_VM', 'profile_test.txt');
    
    -- Call functions multiple times
    FOR i IN 1 .. 100 LOOP
        v_result := slow_function(1000);
        v_result := fast_function(1000);
    END LOOP;
    
    -- Stop profiling
    DBMS_HPROF.STOP_PROFILING;
    
    DBMS_OUTPUT.PUT_LINE('Profiling completed. Check profile_test.txt');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_HPROF.STOP_PROFILING;
        RAISE;
END profile_example;
```

## 5. Testing and Quality Assurance

### 5.1 Unit Testing Framework
```sql
-- Simple unit testing package
CREATE OR REPLACE PACKAGE unit_test_framework AS
    
    -- Test results
    TYPE test_result_t IS RECORD (
        test_name VARCHAR2(100),
        status VARCHAR2(10), -- PASS/FAIL
        message VARCHAR2(4000),
        execution_time NUMBER
    );
    
    TYPE test_results_t IS TABLE OF test_result_t;
    g_test_results test_results_t := test_results_t();
    
    -- Test procedures
    PROCEDURE assert_equals(
        p_expected VARCHAR2,
        p_actual VARCHAR2,
        p_test_name VARCHAR2
    );
    
    PROCEDURE assert_not_null(
        p_value VARCHAR2,
        p_test_name VARCHAR2
    );
    
    PROCEDURE assert_true(
        p_condition BOOLEAN,
        p_test_name VARCHAR2
    );
    
    PROCEDURE run_test(
        p_test_name VARCHAR2,
        p_test_procedure VARCHAR2
    );
    
    PROCEDURE print_results;
    PROCEDURE clear_results;
    
END unit_test_framework;

CREATE OR REPLACE PACKAGE BODY unit_test_framework AS
    
    PROCEDURE add_result(
        p_test_name VARCHAR2,
        p_status VARCHAR2,
        p_message VARCHAR2 DEFAULT NULL,
        p_execution_time NUMBER DEFAULT NULL
    ) IS
        v_result test_result_t;
    BEGIN
        v_result.test_name := p_test_name;
        v_result.status := p_status;
        v_result.message := p_message;
        v_result.execution_time := p_execution_time;
        
        g_test_results.EXTEND;
        g_test_results(g_test_results.COUNT) := v_result;
    END add_result;
    
    PROCEDURE assert_equals(
        p_expected VARCHAR2,
        p_actual VARCHAR2,
        p_test_name VARCHAR2
    ) IS
    BEGIN
        IF NVL(p_expected, 'NULL') = NVL(p_actual, 'NULL') THEN
            add_result(p_test_name, 'PASS');
        ELSE
            add_result(p_test_name, 'FAIL', 
                      'Expected: ' || NVL(p_expected, 'NULL') || 
                      ', Actual: ' || NVL(p_actual, 'NULL'));
        END IF;
    END assert_equals;
    
    PROCEDURE assert_not_null(
        p_value VARCHAR2,
        p_test_name VARCHAR2
    ) IS
    BEGIN
        IF p_value IS NOT NULL THEN
            add_result(p_test_name, 'PASS');
        ELSE
            add_result(p_test_name, 'FAIL', 'Value is NULL');
        END IF;
    END assert_not_null;
    
    PROCEDURE assert_true(
        p_condition BOOLEAN,
        p_test_name VARCHAR2
    ) IS
    BEGIN
        IF p_condition THEN
            add_result(p_test_name, 'PASS');
        ELSE
            add_result(p_test_name, 'FAIL', 'Condition is FALSE');
        END IF;
    END assert_true;
    
    PROCEDURE run_test(
        p_test_name VARCHAR2,
        p_test_procedure VARCHAR2
    ) IS
        v_start_time NUMBER;
        v_end_time NUMBER;
        v_sql VARCHAR2(4000);
    BEGIN
        v_start_time := DBMS_UTILITY.GET_TIME;
        
        v_sql := 'BEGIN ' || p_test_procedure || '; END;';
        
        EXECUTE IMMEDIATE v_sql;
        
        v_end_time := DBMS_UTILITY.GET_TIME;
        
        add_result(p_test_name, 'PASS', 'Test procedure executed successfully',
                  (v_end_time - v_start_time) * 10);
        
    EXCEPTION
        WHEN OTHERS THEN
            v_end_time := DBMS_UTILITY.GET_TIME;
            add_result(p_test_name, 'FAIL', 'Error: ' || SQLERRM,
                      (v_end_time - v_start_time) * 10);
    END run_test;
    
    PROCEDURE print_results IS
        v_total NUMBER := 0;
        v_passed NUMBER := 0;
        v_failed NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Unit Test Results ===');
        DBMS_OUTPUT.PUT_LINE(RPAD('Test Name', 40) || ' ' || 
                           RPAD('Status', 8) || ' ' ||
                           RPAD('Time(ms)', 10) || ' ' ||
                           'Message');
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
        
        FOR i IN 1 .. g_test_results.COUNT LOOP
            v_total := v_total + 1;
            
            IF g_test_results(i).status = 'PASS' THEN
                v_passed := v_passed + 1;
            ELSE
                v_failed := v_failed + 1;
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(
                RPAD(g_test_results(i).test_name, 40) || ' ' ||
                RPAD(g_test_results(i).status, 8) || ' ' ||
                RPAD(NVL(TO_CHAR(g_test_results(i).execution_time), ''), 10) || ' ' ||
                NVL(g_test_results(i).message, '')
            );
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE(RPAD('-', 100, '-'));
        DBMS_OUTPUT.PUT_LINE('Total: ' || v_total || 
                           ', Passed: ' || v_passed || 
                           ', Failed: ' || v_failed ||
                           ', Success Rate: ' || ROUND((v_passed/v_total)*100, 1) || '%');
        DBMS_OUTPUT.PUT_LINE('========================');
    END print_results;
    
    PROCEDURE clear_results IS
    BEGIN
        g_test_results.DELETE;
    END clear_results;
    
END unit_test_framework;

-- Example test suite
CREATE OR REPLACE PROCEDURE test_employee_functions IS
BEGIN
    unit_test_framework.clear_results;
    
    -- Test 1: Employee name formatting
    unit_test_framework.assert_equals(
        'Smith, John',
        format_employee_name('John', 'Smith'),
        'Employee Name Format Test'
    );
    
    -- Test 2: Salary calculation
    unit_test_framework.assert_equals(
        '7500',
        TO_CHAR(calculate_bonus(50000, 15)),
        'Bonus Calculation Test'
    );
    
    -- Test 3: Null handling
    unit_test_framework.assert_not_null(
        get_employee_email(100),
        'Employee Email Not Null Test'
    );
    
    -- Test 4: Business logic
    unit_test_framework.assert_true(
        is_eligible_for_promotion(100),
        'Promotion Eligibility Test'
    );
    
    -- Print all results
    unit_test_framework.print_results;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Test suite failed: ' || SQLERRM);
        unit_test_framework.print_results;
END test_employee_functions;
```

## 6. Production-Ready Error Handling

### 6.1 Enterprise Error Management Package
```sql
CREATE OR REPLACE PACKAGE enterprise_error_mgmt AS
    
    -- Error severity levels
    SUBTYPE severity_level_t IS VARCHAR2(10);
    c_severity_low CONSTANT severity_level_t := 'LOW';
    c_severity_medium CONSTANT severity_level_t := 'MEDIUM';
    c_severity_high CONSTANT severity_level_t := 'HIGH';
    c_severity_critical CONSTANT severity_level_t := 'CRITICAL';
    
    -- Enhanced error logging
    PROCEDURE log_error(
        p_procedure_name VARCHAR2,
        p_severity severity_level_t DEFAULT c_severity_medium,
        p_error_category VARCHAR2 DEFAULT 'GENERAL',
        p_input_parameters CLOB DEFAULT NULL,
        p_additional_context CLOB DEFAULT NULL,
        p_notify_admin BOOLEAN DEFAULT FALSE
    );
    
    -- Error metrics
    FUNCTION get_error_rate(
        p_hours_back NUMBER DEFAULT 24,
        p_procedure_name VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER;
    
    -- Error notification
    PROCEDURE notify_administrators(
        p_error_id NUMBER,
        p_severity severity_level_t
    );
    
    -- Error reporting
    PROCEDURE generate_error_report(
        p_start_date DATE DEFAULT SYSDATE - 7,
        p_end_date DATE DEFAULT SYSDATE
    );
    
END enterprise_error_mgmt;

CREATE OR REPLACE PACKAGE BODY enterprise_error_mgmt AS
    
    PROCEDURE log_error(
        p_procedure_name VARCHAR2,
        p_severity severity_level_t DEFAULT c_severity_medium,
        p_error_category VARCHAR2 DEFAULT 'GENERAL',
        p_input_parameters CLOB DEFAULT NULL,
        p_additional_context CLOB DEFAULT NULL,
        p_notify_admin BOOLEAN DEFAULT FALSE
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_error_id NUMBER;
        v_call_stack CLOB;
        v_error_stack CLOB;
        v_error_backtrace CLOB;
    BEGIN
        -- Get comprehensive error information
        v_call_stack := DBMS_UTILITY.FORMAT_CALL_STACK;
        v_error_stack := DBMS_UTILITY.FORMAT_ERROR_STACK;
        v_error_backtrace := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
        
        -- Insert comprehensive error log
        INSERT INTO enterprise_error_log (
            error_date, username, session_id, client_info,
            error_code, error_message, error_stack, error_backtrace, call_stack,
            procedure_name, severity_level, error_category,
            input_parameters, additional_context,
            database_name, instance_name, host_name
        ) VALUES (
            SYSDATE, USER, SYS_CONTEXT('USERENV', 'SESSIONID'),
            SYS_CONTEXT('USERENV', 'CLIENT_INFO'),
            SQLCODE, SQLERRM, v_error_stack, v_error_backtrace, v_call_stack,
            p_procedure_name, p_severity, p_error_category,
            p_input_parameters, p_additional_context,
            SYS_CONTEXT('USERENV', 'DB_NAME'),
            SYS_CONTEXT('USERENV', 'INSTANCE_NAME'),
            SYS_CONTEXT('USERENV', 'SERVER_HOST')
        ) RETURNING error_id INTO v_error_id;
        
        COMMIT;
        
        -- Send notification for critical errors
        IF p_notify_admin OR p_severity = c_severity_critical THEN
            notify_administrators(v_error_id, p_severity);
        END IF;
        
    EXCEPTION
        WHEN OTHERS THEN
            -- Ultimate fallback - write to alert log
            DBMS_SYSTEM.KSDWRT(2, 
                'CRITICAL: Enterprise Error Management Failed - ' ||
                p_procedure_name || ': ' || SQLERRM);
            ROLLBACK;
    END log_error;
    
    FUNCTION get_error_rate(
        p_hours_back NUMBER DEFAULT 24,
        p_procedure_name VARCHAR2 DEFAULT NULL
    ) RETURN NUMBER IS
        v_error_count NUMBER;
        v_total_calls NUMBER;
    BEGIN
        -- Get error count
        SELECT COUNT(*)
        INTO v_error_count
        FROM enterprise_error_log
        WHERE error_date >= SYSDATE - (p_hours_back / 24)
        AND (p_procedure_name IS NULL OR procedure_name = p_procedure_name);
        
        -- Get total procedure calls (if available from performance schema)
        -- This is a simplified example
        v_total_calls := GREATEST(v_error_count * 10, 1); -- Estimate
        
        RETURN ROUND((v_error_count / v_total_calls) * 100, 2);
    END get_error_rate;
    
    PROCEDURE notify_administrators(
        p_error_id NUMBER,
        p_severity severity_level_t
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
        v_subject VARCHAR2(200);
        v_message CLOB;
    BEGIN
        -- Prepare notification message
        v_subject := 'Database Error Alert - Severity: ' || p_severity;
        
        SELECT 'Error ID: ' || error_id || CHR(10) ||
               'Time: ' || TO_CHAR(error_date, 'YYYY-MM-DD HH24:MI:SS') || CHR(10) ||
               'Procedure: ' || procedure_name || CHR(10) ||
               'Error: ' || error_message || CHR(10) ||
               'User: ' || username || CHR(10) ||
               'Database: ' || database_name
        INTO v_message
        FROM enterprise_error_log
        WHERE error_id = p_error_id;
        
        -- Insert into notification queue
        INSERT INTO admin_notifications (
            notification_date, notification_type, severity,
            subject, message, status
        ) VALUES (
            SYSDATE, 'ERROR_ALERT', p_severity,
            v_subject, v_message, 'PENDING'
        );
        
        COMMIT;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
    END notify_administrators;
    
    PROCEDURE generate_error_report(
        p_start_date DATE DEFAULT SYSDATE - 7,
        p_end_date DATE DEFAULT SYSDATE
    ) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== Error Report ===');
        DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(p_start_date, 'YYYY-MM-DD') || 
                           ' to ' || TO_CHAR(p_end_date, 'YYYY-MM-DD'));
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Error summary by procedure
        DBMS_OUTPUT.PUT_LINE('Errors by Procedure:');
        FOR rec IN (
            SELECT procedure_name, COUNT(*) as error_count,
                   MAX(error_date) as last_error
            FROM enterprise_error_log
            WHERE error_date BETWEEN p_start_date AND p_end_date
            GROUP BY procedure_name
            ORDER BY error_count DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || RPAD(rec.procedure_name, 30) || 
                               ': ' || rec.error_count || ' errors, ' ||
                               'Last: ' || TO_CHAR(rec.last_error, 'MM-DD HH24:MI'));
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        
        -- Error summary by severity
        DBMS_OUTPUT.PUT_LINE('Errors by Severity:');
        FOR rec IN (
            SELECT severity_level, COUNT(*) as error_count
            FROM enterprise_error_log
            WHERE error_date BETWEEN p_start_date AND p_end_date
            GROUP BY severity_level
            ORDER BY error_count DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || RPAD(rec.severity_level, 15) || 
                               ': ' || rec.error_count || ' errors');
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('==================');
    END generate_error_report;
    
END enterprise_error_mgmt;
```

## Summary

Effective error handling and debugging in Oracle PL/SQL requires:

1. **Comprehensive Exception Handling**: Handle both expected and unexpected errors
2. **Proper Error Logging**: Maintain detailed logs for troubleshooting
3. **Debugging Techniques**: Use various tools and methods for identifying issues
4. **Testing Framework**: Implement systematic testing procedures
5. **Performance Monitoring**: Track and optimize code performance
6. **Production Readiness**: Implement enterprise-grade error management

Key best practices:
- Always handle exceptions appropriately
- Log errors with sufficient context
- Use debugging tools effectively
- Implement comprehensive testing
- Monitor application performance
- Plan for production error scenarios

## Next Steps
- Implement error handling in your existing procedures
- Set up comprehensive logging framework
- Practice debugging techniques
- Create unit tests for your code
- Learn about Oracle debugging tools (SQL Developer, TOAD, etc.)
- Study Oracle performance tuning and monitoring
