# Functions và Packages trong Oracle Database

## Mục Tiêu Học Tập
Sau khi hoàn thành bài học này, bạn sẽ có thể:
- Tạo và sử dụng các loại Oracle functions khác nhau
- Hiểu sự khác biệt giữa functions và procedures
- Thiết kế và triển khai database packages
- Triển khai package specifications và bodies
- Sử dụng các built-in Oracle functions hiệu quả
- Áp dụng thực hành tốt cho việc phát triển function và package

## Điều Kiện Tiên Quyết
- Hoàn thành bài học stored procedures
- Hiểu cơ bản về PL/SQL
- Kiến thức về Oracle data types và variables
- Quen thuộc với SQL và các khái niệm lập trình cơ bản

## 1. Giới thiệu về Functions

### Functions là gì?
Functions trong Oracle là các PL/SQL blocks có tên trả về một giá trị duy nhất. Khác với procedures, functions phải trả về một giá trị và có thể được sử dụng trong các biểu thức SQL, mệnh đề WHERE và câu lệnh SELECT.

### Đặc điểm Chính:
- **Giá trị Trả về**: Phải trả về chính xác một giá trị
- **Deterministic**: Nên tạo ra cùng kết quả cho cùng đầu vào
- **Tích hợp SQL**: Có thể được gọi từ các câu lệnh SQL
- **Hiệu suất**: Có thể được tối ưu hóa bởi Oracle optimizer

### So sánh Function vs Procedure:
```sql
-- Ví dụ Function
CREATE OR REPLACE FUNCTION calculate_bonus(salary NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN salary * 0.10;
END;

-- Ví dụ Procedure  
CREATE OR REPLACE PROCEDURE update_employee_bonus(emp_id NUMBER)
IS
    bonus_amount NUMBER;
BEGIN
    bonus_amount := calculate_bonus(get_salary(emp_id));
    UPDATE employees SET bonus = bonus_amount WHERE employee_id = emp_id;
END;
```

## 2. Các loại Functions

### 2.1 Scalar Functions
Trả về một giá trị nguyên tử duy nhất (number, string, date, v.v.)

```sql
CREATE OR REPLACE FUNCTION format_phone(phone_number VARCHAR2)
RETURN VARCHAR2
IS
    formatted_phone VARCHAR2(20);
BEGIN
    -- Loại bỏ tất cả ký tự không phải số
    formatted_phone := REGEXP_REPLACE(phone_number, '[^0-9]', '');
    
    -- Định dạng thành (xxx) xxx-xxxx
    IF LENGTH(formatted_phone) = 10 THEN
        RETURN '(' || SUBSTR(formatted_phone, 1, 3) || ') ' ||
               SUBSTR(formatted_phone, 4, 3) || '-' ||
               SUBSTR(formatted_phone, 7, 4);
    ELSE
        RETURN phone_number; -- Trả về bản gốc nếu không hợp lệ
    END IF;
END format_phone;
```

### 2.2 Table Functions
Trả về một collection có thể được sử dụng trong mệnh đề FROM

```sql
-- Định nghĩa object type cho dữ liệu employee
CREATE OR REPLACE TYPE emp_obj AS OBJECT (
    employee_id NUMBER,
    full_name VARCHAR2(100),
    department VARCHAR2(50),
    salary NUMBER
);

-- Định nghĩa table type
CREATE OR REPLACE TYPE emp_table AS TABLE OF emp_obj;

-- Tạo table function
CREATE OR REPLACE FUNCTION get_department_employees(dept_name VARCHAR2)
RETURN emp_table PIPELINED
IS
    emp_rec emp_obj;
BEGIN
    FOR rec IN (
        SELECT e.employee_id, 
               e.first_name || ' ' || e.last_name as full_name,
               d.department_name,
               e.salary
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        WHERE d.department_name = dept_name
    ) LOOP
        emp_rec := emp_obj(rec.employee_id, rec.full_name, 
                          rec.department_name, rec.salary);
        PIPE ROW(emp_rec);
    END LOOP;
    RETURN;
END get_department_employees;
```

### 2.3 Aggregate Functions
Custom functions that work with GROUP BY

```sql
-- Create aggregate function for custom calculations
CREATE OR REPLACE TYPE variance_impl AS OBJECT (
    sum_x NUMBER,
    sum_x2 NUMBER,
    num_rows NUMBER,
    
    STATIC FUNCTION ODCIAggregateInitialize(ctx IN OUT variance_impl)
        RETURN NUMBER,
    
    MEMBER FUNCTION ODCIAggregateIterate(self IN OUT variance_impl, 
                                       value IN NUMBER) 
        RETURN NUMBER,
        
    MEMBER FUNCTION ODCIAggregateTerminate(self IN variance_impl,
                                         returnValue OUT NUMBER,
                                         flags IN NUMBER)
        RETURN NUMBER,
        
    MEMBER FUNCTION ODCIAggregateMerge(self IN OUT variance_impl,
                                     ctx2 IN variance_impl)
        RETURN NUMBER
);
```

## 3. Function Parameters and Return Types

### 3.1 Parameter Modes
```sql
CREATE OR REPLACE FUNCTION complex_calculation(
    -- IN parameters (default)
    input_value IN NUMBER,
    multiplier IN NUMBER DEFAULT 1,
    
    -- OUT parameters (rare in functions)
    calculation_steps OUT VARCHAR2
) RETURN NUMBER
IS
    result NUMBER;
BEGIN
    calculation_steps := 'Step 1: Multiply by ' || multiplier;
    result := input_value * multiplier;
    
    calculation_steps := calculation_steps || '; Step 2: Add 100';
    result := result + 100;
    
    RETURN result;
END complex_calculation;
```

### 3.2 Return Types
```sql
-- Scalar return types
CREATE OR REPLACE FUNCTION get_employee_name(emp_id NUMBER)
RETURN VARCHAR2 IS ...

-- Record return types
CREATE OR REPLACE FUNCTION get_employee_details(emp_id NUMBER)
RETURN employees%ROWTYPE IS ...

-- Collection return types
CREATE OR REPLACE FUNCTION get_employee_skills(emp_id NUMBER)
RETURN sys.odcivarchar2list IS ...
```

## 4. Advanced Function Features

### 4.1 Deterministic Functions
```sql
CREATE OR REPLACE FUNCTION calculate_tax(salary NUMBER)
RETURN NUMBER
DETERMINISTIC -- Optimizer can cache results
IS
BEGIN
    RETURN CASE 
        WHEN salary <= 50000 THEN salary * 0.15
        WHEN salary <= 100000 THEN salary * 0.25
        ELSE salary * 0.35
    END;
END calculate_tax;
```

### 4.2 Parallel Enabled Functions
```sql
CREATE OR REPLACE FUNCTION calculate_commission(sales_amount NUMBER)
RETURN NUMBER
PARALLEL_ENABLE -- Can be used in parallel queries
IS
BEGIN
    RETURN sales_amount * 0.05;
END calculate_commission;
```

### 4.3 Result Cache Functions
```sql
CREATE OR REPLACE FUNCTION get_exchange_rate(currency_code VARCHAR2)
RETURN NUMBER
RESULT_CACHE -- Cache results for performance
IS
    rate NUMBER;
BEGIN
    SELECT exchange_rate INTO rate
    FROM currency_rates
    WHERE currency = currency_code
    AND rate_date = TRUNC(SYSDATE);
    
    RETURN rate;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 1; -- Default rate
END get_exchange_rate;
```

## 5. Introduction to Packages

### What are Packages?
Packages are collections of related functions, procedures, variables, and other program constructs grouped together as a logical unit. They provide:

- **Encapsulation**: Hide implementation details
- **Namespace Management**: Avoid naming conflicts
- **Performance**: Loaded once per session
- **Security**: Control access to functionality

### Package Structure:
1. **Package Specification**: Public interface (header)
2. **Package Body**: Implementation details (body)

## 6. Package Specifications

### Basic Package Specification:
```sql
CREATE OR REPLACE PACKAGE employee_management AS
    -- Public constants
    MAX_SALARY CONSTANT NUMBER := 200000;
    MIN_SALARY CONSTANT NUMBER := 30000;
    
    -- Public variables
    g_department_id NUMBER;
    
    -- Public exceptions
    invalid_salary_exception EXCEPTION;
    employee_not_found_exception EXCEPTION;
    
    -- Public function declarations
    FUNCTION get_employee_salary(p_emp_id NUMBER) RETURN NUMBER;
    
    FUNCTION calculate_annual_bonus(
        p_emp_id NUMBER,
        p_performance_rating NUMBER DEFAULT 3
    ) RETURN NUMBER;
    
    FUNCTION is_eligible_for_promotion(p_emp_id NUMBER) RETURN BOOLEAN;
    
    -- Public procedure declarations
    PROCEDURE hire_employee(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_email VARCHAR2,
        p_salary NUMBER,
        p_department_id NUMBER,
        p_employee_id OUT NUMBER
    );
    
    PROCEDURE update_salary(
        p_emp_id NUMBER,
        p_new_salary NUMBER
    );
    
    PROCEDURE terminate_employee(p_emp_id NUMBER);
    
    -- Public cursor declarations
    CURSOR high_performers(p_rating NUMBER) IS
        SELECT employee_id, first_name, last_name, salary
        FROM employees
        WHERE performance_rating >= p_rating;

END employee_management;
```

## 7. Package Bodies

### Complete Package Body Implementation:
```sql
CREATE OR REPLACE PACKAGE BODY employee_management AS
    
    -- Private variables
    g_last_employee_id NUMBER := 0;
    g_audit_enabled BOOLEAN := TRUE;
    
    -- Private procedures/functions
    PROCEDURE log_activity(
        p_activity VARCHAR2,
        p_employee_id NUMBER DEFAULT NULL
    ) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        IF g_audit_enabled THEN
            INSERT INTO employee_audit_log (
                log_date, activity, employee_id, user_name
            ) VALUES (
                SYSDATE, p_activity, p_employee_id, USER
            );
            COMMIT;
        END IF;
    END log_activity;
    
    FUNCTION validate_salary(p_salary NUMBER) RETURN BOOLEAN IS
    BEGIN
        RETURN p_salary BETWEEN MIN_SALARY AND MAX_SALARY;
    END validate_salary;
    
    -- Public function implementations
    FUNCTION get_employee_salary(p_emp_id NUMBER) RETURN NUMBER IS
        v_salary NUMBER;
    BEGIN
        SELECT salary INTO v_salary
        FROM employees
        WHERE employee_id = p_emp_id;
        
        RETURN v_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE employee_not_found_exception;
    END get_employee_salary;
    
    FUNCTION calculate_annual_bonus(
        p_emp_id NUMBER,
        p_performance_rating NUMBER DEFAULT 3
    ) RETURN NUMBER IS
        v_salary NUMBER;
        v_bonus_percentage NUMBER;
    BEGIN
        v_salary := get_employee_salary(p_emp_id);
        
        v_bonus_percentage := CASE p_performance_rating
            WHEN 5 THEN 0.20  -- Exceptional
            WHEN 4 THEN 0.15  -- Exceeds expectations
            WHEN 3 THEN 0.10  -- Meets expectations
            WHEN 2 THEN 0.05  -- Below expectations
            ELSE 0            -- Poor performance
        END;
        
        RETURN v_salary * v_bonus_percentage;
    END calculate_annual_bonus;
    
    FUNCTION is_eligible_for_promotion(p_emp_id NUMBER) RETURN BOOLEAN IS
        v_years_service NUMBER;
        v_performance_rating NUMBER;
    BEGIN
        SELECT FLOOR(MONTHS_BETWEEN(SYSDATE, hire_date) / 12),
               performance_rating
        INTO v_years_service, v_performance_rating
        FROM employees
        WHERE employee_id = p_emp_id;
        
        RETURN (v_years_service >= 2 AND v_performance_rating >= 4);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE employee_not_found_exception;
    END is_eligible_for_promotion;
    
    -- Public procedure implementations
    PROCEDURE hire_employee(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_email VARCHAR2,
        p_salary NUMBER,
        p_department_id NUMBER,
        p_employee_id OUT NUMBER
    ) IS
    BEGIN
        -- Validate salary
        IF NOT validate_salary(p_salary) THEN
            RAISE invalid_salary_exception;
        END IF;
        
        -- Generate new employee ID
        SELECT employee_seq.NEXTVAL INTO p_employee_id FROM dual;
        
        -- Insert new employee
        INSERT INTO employees (
            employee_id, first_name, last_name, email,
            salary, department_id, hire_date
        ) VALUES (
            p_employee_id, p_first_name, p_last_name, p_email,
            p_salary, p_department_id, SYSDATE
        );
        
        -- Log the activity
        log_activity('HIRE', p_employee_id);
        
        -- Update package variable
        g_last_employee_id := p_employee_id;
        
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            RAISE_APPLICATION_ERROR(-20001, 'Email already exists');
    END hire_employee;
    
    PROCEDURE update_salary(
        p_emp_id NUMBER,
        p_new_salary NUMBER
    ) IS
        v_old_salary NUMBER;
    BEGIN
        -- Validate new salary
        IF NOT validate_salary(p_new_salary) THEN
            RAISE invalid_salary_exception;
        END IF;
        
        -- Get current salary for logging
        v_old_salary := get_employee_salary(p_emp_id);
        
        -- Update salary
        UPDATE employees
        SET salary = p_new_salary,
            last_modified = SYSDATE
        WHERE employee_id = p_emp_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE employee_not_found_exception;
        END IF;
        
        -- Log the activity
        log_activity('SALARY_UPDATE: ' || v_old_salary || ' -> ' || p_new_salary, p_emp_id);
        
    END update_salary;
    
    PROCEDURE terminate_employee(p_emp_id NUMBER) IS
    BEGIN
        -- Update employee record
        UPDATE employees
        SET status = 'TERMINATED',
            termination_date = SYSDATE,
            last_modified = SYSDATE
        WHERE employee_id = p_emp_id;
        
        IF SQL%ROWCOUNT = 0 THEN
            RAISE employee_not_found_exception;
        END IF;
        
        -- Log the activity
        log_activity('TERMINATION', p_emp_id);
        
    END terminate_employee;
    
    -- Package initialization block
BEGIN
    -- Initialize package variables
    g_department_id := 0;
    g_audit_enabled := TRUE;
    
    -- Log package initialization
    log_activity('PACKAGE_INITIALIZED');
    
END employee_management;
```

## 8. Package Usage and Best Practices

### 8.1 Using Package Components:
```sql
-- Call package functions
DECLARE
    v_salary NUMBER;
    v_bonus NUMBER;
    v_new_emp_id NUMBER;
BEGIN
    -- Use package constants
    DBMS_OUTPUT.PUT_LINE('Max Salary: ' || employee_management.MAX_SALARY);
    
    -- Call package functions
    v_salary := employee_management.get_employee_salary(100);
    v_bonus := employee_management.calculate_annual_bonus(100, 5);
    
    -- Call package procedures
    employee_management.hire_employee(
        p_first_name => 'John',
        p_last_name => 'Smith',
        p_email => 'john.smith@company.com',
        p_salary => 75000,
        p_department_id => 10,
        p_employee_id => v_new_emp_id
    );
    
    -- Use package cursor
    FOR rec IN employee_management.high_performers(4) LOOP
        DBMS_OUTPUT.PUT_LINE(rec.first_name || ' ' || rec.last_name);
    END LOOP;
    
EXCEPTION
    WHEN employee_management.invalid_salary_exception THEN
        DBMS_OUTPUT.PUT_LINE('Invalid salary amount');
    WHEN employee_management.employee_not_found_exception THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
END;
```

### 8.2 Package Best Practices:

#### Design Principles:
1. **Cohesion**: Related functionality in one package
2. **Minimal Interface**: Expose only what's necessary
3. **Documentation**: Comment all public interfaces
4. **Error Handling**: Consistent exception handling
5. **Security**: Use definer's rights appropriately

#### Performance Considerations:
```sql
-- Use package variables for caching
CREATE OR REPLACE PACKAGE BODY performance_pkg AS
    
    -- Cache for expensive calculations
    TYPE lookup_cache_t IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    g_lookup_cache lookup_cache_t;
    
    FUNCTION expensive_calculation(p_key VARCHAR2) RETURN NUMBER IS
        v_result NUMBER;
    BEGIN
        -- Check cache first
        IF g_lookup_cache.EXISTS(p_key) THEN
            RETURN g_lookup_cache(p_key);
        END IF;
        
        -- Perform expensive calculation
        SELECT complex_formula(data)
        INTO v_result
        FROM reference_table
        WHERE key_value = p_key;
        
        -- Cache the result
        g_lookup_cache(p_key) := v_result;
        
        RETURN v_result;
    END expensive_calculation;
    
END performance_pkg;
```

## 9. Built-in Oracle Functions

### 9.1 String Functions:
```sql
-- Common string manipulation
SELECT 
    UPPER('oracle database') as upper_case,
    LOWER('ORACLE DATABASE') as lower_case,
    INITCAP('oracle database') as proper_case,
    LENGTH('Oracle') as string_length,
    SUBSTR('Oracle Database', 1, 6) as substring,
    INSTR('Oracle Database', 'Data') as position,
    REPLACE('Oracle Database', 'Database', 'DB') as replaced,
    TRIM('  Oracle  ') as trimmed,
    LPAD('123', 10, '0') as left_padded,
    RPAD('123', 10, '0') as right_padded
FROM dual;
```

### 9.2 Numeric Functions:
```sql
-- Mathematical operations
SELECT 
    ROUND(123.456, 2) as rounded,
    TRUNC(123.456, 1) as truncated,
    CEIL(123.1) as ceiling,
    FLOOR(123.9) as floor,
    MOD(10, 3) as modulo,
    POWER(2, 3) as power,
    SQRT(16) as square_root,
    ABS(-123) as absolute_value
FROM dual;
```

### 9.3 Date Functions:
```sql
-- Date manipulation
SELECT 
    SYSDATE as current_date,
    ADD_MONTHS(SYSDATE, 6) as six_months_later,
    MONTHS_BETWEEN(SYSDATE, DATE '2023-01-01') as months_diff,
    LAST_DAY(SYSDATE) as last_day_of_month,
    NEXT_DAY(SYSDATE, 'MONDAY') as next_monday,
    EXTRACT(YEAR FROM SYSDATE) as current_year,
    TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') as formatted_date
FROM dual;
```

## 10. Error Handling in Functions and Packages

### 10.1 Exception Handling Patterns:
```sql
CREATE OR REPLACE FUNCTION safe_divide(
    p_numerator NUMBER,
    p_denominator NUMBER
) RETURN NUMBER IS
    v_result NUMBER;
BEGIN
    IF p_denominator = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Division by zero not allowed');
    END IF;
    
    v_result := p_numerator / p_denominator;
    RETURN v_result;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error details
        INSERT INTO error_log (
            error_date, error_code, error_message, 
            function_name, parameters
        ) VALUES (
            SYSDATE, SQLCODE, SQLERRM,
            'safe_divide', p_numerator || ',' || p_denominator
        );
        
        -- Re-raise or return default
        RAISE;
END safe_divide;
```

## 11. Testing Functions and Packages

### 11.1 Unit Testing Framework:
```sql
-- Simple testing package
CREATE OR REPLACE PACKAGE test_employee_management AS
    PROCEDURE run_all_tests;
    PROCEDURE test_salary_calculation;
    PROCEDURE test_bonus_calculation;
    PROCEDURE test_promotion_eligibility;
END test_employee_management;

CREATE OR REPLACE PACKAGE BODY test_employee_management AS
    
    PROCEDURE assert_equals(        p_expected NUMBER,
        p_actual NUMBER,
        p_test_name VARCHAR2
    ) IS
    BEGIN
        IF p_expected = p_actual THEN
            DBMS_OUTPUT.PUT_LINE('PASS: ' || p_test_name);
        ELSE
            DBMS_OUTPUT.PUT_LINE('FAIL: ' || p_test_name || 
                               ' - Expected: ' || p_expected || 
                               ', Actual: ' || p_actual);
        END IF;
    END assert_equals;
    
    PROCEDURE test_bonus_calculation IS
        v_bonus NUMBER;
    BEGIN
        -- Test với performance rating 5
        v_bonus := employee_management.calculate_annual_bonus(100, 5);
        assert_equals(10000, v_bonus, 'High performer bonus');
        
        -- Test với performance rating 3
        v_bonus := employee_management.calculate_annual_bonus(100, 3);
        assert_equals(5000, v_bonus, 'Average performer bonus');
        
    END test_bonus_calculation;
    
    PROCEDURE run_all_tests IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Chạy Employee Management Tests...');
        test_bonus_calculation;
        -- Thêm các test procedures khác ở đây
        DBMS_OUTPUT.PUT_LINE('Tests hoàn thành.');
    END run_all_tests;
    
END test_employee_management;
```

## Tóm Tắt

Functions và packages là các tính năng mạnh mẽ của Oracle Database cho phép:

1. **Khả năng Tái sử dụng Code**: Viết một lần, sử dụng nhiều lần
2. **Tính Modular**: Tổ chức code thành các đơn vị logic
3. **Hiệu suất**: Cached execution và optimization
4. **Bảo mật**: Kiểm soát truy cập đến functionality
5. **Khả năng Bảo trì**: Logic business tập trung

Điểm chính:
- Functions trả về giá trị và có thể được sử dụng trong SQL
- Packages cung cấp encapsulation và namespace management
- Xử lý lỗi phù hợp là quan trọng cho các ứng dụng robust
- Testing đảm bảo chất lượng và độ tin cậy của code
- Built-in functions cung cấp functionality mở rộng

## Bước Tiếp Theo
- Thực hành tạo các loại functions khác nhau
- Thiết kế và triển khai packages của riêng bạn
- Khám phá các tính năng package nâng cao như object types
- Học về package dependencies và compilation
- Nghiên cứu các built-in packages của Oracle (DBMS_*)
