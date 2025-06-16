# Stored Procedures

Stored procedures là nền tảng của lập trình cơ sở dữ liệu, cho phép bạn đóng gói logic business phức tạp trực tiếp trong cơ sở dữ liệu. Chúng cung cấp lợi ích hiệu suất, ưu thế bảo mật và khả năng tái sử dụng code, làm cho chúng thiết yếu cho các ứng dụng doanh nghiệp.

## 🎯 Mục Tiêu Học Tập

Sau khi hoàn thành phần này, bạn sẽ hiểu được:

1. **Cơ bản về Procedure**: Procedure là gì và lợi ích của chúng
2. **Cơ bản PL/SQL**: Hiểu ngôn ngữ thủ tục của Oracle
3. **Xử lý Tham số**: Tham số IN, OUT và IN OUT
4. **Cấu trúc Điều khiển**: Logic điều kiện và vòng lặp trong procedures
5. **Xử lý Exception**: Quản lý lỗi chuyên nghiệp
6. **Tối ưu hóa Hiệu suất**: Viết code thủ tục hiệu quả
7. **Kỹ thuật Debug**: Testing và troubleshooting procedures

## 📖 Mục Lục

1. [Hiểu về Stored Procedures](#understanding-stored-procedures)
2. [Cơ bản PL/SQL](#plsql-basics)
3. [Tạo Simple Procedures](#creating-simple-procedures)
4. [Tham số và Biến](#parameters-and-variables)
5. [Cấu trúc Điều khiển](#control-structures)
6. [Xử lý Exception](#exception-handling)
7. [Kỹ thuật Procedure Nâng cao](#advanced-procedure-techniques)
8. [Hiệu suất và Tối ưu hóa](#performance-and-optimization)
9. [Thực hành Tốt](#best-practices)

---

## Hiểu về Stored Procedures

### Stored Procedure là gì?

**Stored procedure** là một tập hợp có tên các câu lệnh SQL và PL/SQL được lưu trữ trong cơ sở dữ liệu. Procedures đóng gói logic business và có thể được thực thi bởi các ứng dụng hoặc các chương trình cơ sở dữ liệu khác.

### Lợi ích của Stored Procedures

#### **Lợi ích Hiệu suất**
- **Code Được Biên dịch Trước**: Procedures được biên dịch và lưu trữ ở dạng đã phân tích
- **Giảm Network Traffic**: Một lần gọi procedure thay vì nhiều câu lệnh SQL
- **Tái sử dụng Execution Plan**: Oracle cache các execution plans
- **Hiệu quả Bộ nhớ**: Chia sẻ giữa nhiều sessions

#### **Lợi ích Bảo mật**
- **Kiểm soát Truy cập**: Cấp quyền execute thay vì quyền truy cập table
- **Ngăn chặn SQL Injection**: Tham số được xử lý đúng cách
- **Bảo vệ Business Logic**: Code nằm an toàn trong database
- **Audit Trail**: Việc thực thi procedure có thể được ghi log

#### **Lợi ích Khả năng Bảo trì**
- **Logic Tập trung**: Quy tắc business ở một vị trí
- **Khả năng Tái sử dụng Code**: Được gọi từ nhiều ứng dụng
- **Triển khai Nhất quán**: Cùng logic trên tất cả ứng dụng
- **Kiểm soát Phiên bản**: Thay đổi được quản lý trong database

### Procedure vs Function vs Package

| Tính năng | Procedure | Function | Package |
|---------|-----------|----------|---------|
| **Trả về Giá trị** | Không (sử dụng OUT parameters) | Có (giá trị đơn) | Chứa cả hai |
| **Cách sử dụng** | Câu lệnh EXECUTE | Trong câu lệnh SELECT | Tổ chức code liên quan |
| **Mục đích** | Thực hiện hành động | Tính toán giá trị | Nhóm các objects liên quan |
| **Tham số** | IN, OUT, IN OUT | IN, RETURN | Nhiều procedures/functions |

---

## Cơ bản PL/SQL

### Cấu trúc PL/SQL Block

```sql
-- Cấu trúc PL/SQL block cơ bản
DECLARE
    -- Khai báo biến (tùy chọn)
    v_variable_name datatype;
BEGIN
    -- Câu lệnh thực thi (bắt buộc)
    NULL; -- Ít nhất một câu lệnh được yêu cầu
EXCEPTION
    -- Xử lý exception (tùy chọn)
    WHEN exception_name THEN
        -- Xử lý exception
END;
/
```

### Khai báo Biến

```sql
DECLARE
    -- Các loại biến cơ bản
    v_employee_id     NUMBER(6);
    v_employee_name   VARCHAR2(100);
    v_hire_date       DATE;
    v_salary          NUMBER(8,2);
    v_is_manager      BOOLEAN := FALSE;
    
    -- Sử dụng %TYPE cho các loại dựa trên cột
    v_dept_id         employees.department_id%TYPE;
    v_job_title       employees.job_id%TYPE;
    
    -- Constants
    c_max_salary      CONSTANT NUMBER := 100000;
    c_company_name    CONSTANT VARCHAR2(50) := 'ACME Corp';
    
    -- Record types
    v_employee_rec    employees%ROWTYPE;
    
BEGIN
    -- Sử dụng biến
    v_employee_id := 100;
    v_employee_name := 'John Doe';
    v_hire_date := SYSDATE;
    
    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_employee_name);
END;
/
```

### Câu lệnh PL/SQL Cơ bản

```sql
-- Câu lệnh gán
v_total := v_price * v_quantity;
v_discount := CASE 
    WHEN v_total > 1000 THEN 0.10
    WHEN v_total > 500 THEN 0.05
    ELSE 0
END;

-- Câu lệnh SQL trong PL/SQL
SELECT first_name, last_name, salary
INTO v_first_name, v_last_name, v_salary
FROM employees
WHERE employee_id = v_emp_id;

-- Câu lệnh DML
INSERT INTO audit_log (user_name, action_date, action)
VALUES (USER, SYSDATE, 'Procedure executed');

UPDATE employees
SET salary = salary * 1.05
WHERE department_id = v_dept_id;

DELETE FROM temp_data WHERE session_id = v_session_id;
```

---

## Tạo Simple Procedures

### Cú pháp Procedure Cơ bản

```sql
CREATE [OR REPLACE] PROCEDURE procedure_name
[
    parameter1 [IN | OUT | IN OUT] datatype,
    parameter2 [IN | OUT | IN OUT] datatype,
    ...
]
IS | AS
    -- Phần khai báo
    variable_name datatype;
BEGIN
    -- Phần thực thi
    statement1;
    statement2;
    ...
EXCEPTION
    -- Phần xử lý exception
    WHEN exception_name THEN
        statement;
END [procedure_name];
/
```

### Ví dụ 1: Simple Procedure Không có Tham số

```sql
-- Tạo procedure đơn giản để hiển thị thông tin công ty
CREATE OR REPLACE PROCEDURE show_company_info
IS
    v_total_employees NUMBER;
    v_total_departments NUMBER;
    v_avg_salary NUMBER(10,2);
BEGIN
    -- Lấy thống kê công ty
    SELECT COUNT(*)
    INTO v_total_employees
    FROM employees;
    
    SELECT COUNT(*)
    INTO v_total_departments
    FROM departments;
    
    SELECT ROUND(AVG(salary), 2)
    INTO v_avg_salary
    FROM employees;
    
    -- Hiển thị thông tin
    DBMS_OUTPUT.PUT_LINE('=== THÔNG TIN CÔNG TY ===');
    DBMS_OUTPUT.PUT_LINE('Tổng số Nhân viên: ' || v_total_employees);
    DBMS_OUTPUT.PUT_LINE('Tổng số Phòng ban: ' || v_total_departments);
    DBMS_OUTPUT.PUT_LINE('Lương Trung bình: $' || v_avg_salary);
    
    -- Ghi log việc thực thi procedure
    INSERT INTO audit_log (procedure_name, execution_date, executed_by)
    VALUES ('show_company_info', SYSDATE, USER);
    
    COMMIT;
END show_company_info;
/

-- Thực thi procedure
EXECUTE show_company_info;
-- Hoặc
BEGIN
    show_company_info;
END;
/
```

### Ví dụ 2: Procedure với Tham số IN

```sql
-- Tạo procedure để tăng lương cho phòng ban
CREATE OR REPLACE PROCEDURE give_department_raise(
    p_department_id IN NUMBER,
    p_raise_percent IN NUMBER
)
IS
    v_employee_count NUMBER;
    v_total_old_salary NUMBER;
    v_total_new_salary NUMBER;
BEGIN
    -- Xác thực tham số
    IF p_department_id IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Department ID không thể null');
    END IF;
    
    IF p_raise_percent <= 0 OR p_raise_percent > 50 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Phần trăm tăng lương phải từ 0 đến 50');
    END IF;
    
    -- Kiểm tra xem phòng ban có tồn tại không
    SELECT COUNT(*)
    INTO v_employee_count
    FROM employees
    WHERE department_id = p_department_id;
    
    IF v_employee_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'No employees found in department ' || p_department_id);
    END IF;
    
    -- Calculate current total salary
    SELECT SUM(salary)
    INTO v_total_old_salary
    FROM employees
    WHERE department_id = p_department_id;
    
    -- Apply the raise
    UPDATE employees
    SET salary = salary * (1 + p_raise_percent / 100),
        last_modified_date = SYSDATE,
        last_modified_by = USER
    WHERE department_id = p_department_id;
    
    -- Calculate new total salary
    SELECT SUM(salary)
    INTO v_total_new_salary
    FROM employees
    WHERE department_id = p_department_id;
    
    -- Log the action
    INSERT INTO salary_audit (
        department_id, 
        raise_percent, 
        employees_affected,
        old_total_salary,
        new_total_salary,
        action_date,
        action_by
    ) VALUES (
        p_department_id,
        p_raise_percent,
        v_employee_count,
        v_total_old_salary,
        v_total_new_salary,
        SYSDATE,
        USER
    );
    
    COMMIT;
    
    -- Display results
    DBMS_OUTPUT.PUT_LINE('Salary raise completed successfully:');
    DBMS_OUTPUT.PUT_LINE('Department: ' || p_department_id);
    DBMS_OUTPUT.PUT_LINE('Employees affected: ' || v_employee_count);
    DBMS_OUTPUT.PUT_LINE('Raise percentage: ' || p_raise_percent || '%');
    DBMS_OUTPUT.PUT_LINE('Total salary increase: $' || 
                        TO_CHAR(v_total_new_salary - v_total_old_salary, '999,999.99'));
                        
END give_department_raise;
/

-- Execute the procedure
EXECUTE give_department_raise(20, 5);  -- 5% raise for department 20
```

---

## Parameters and Variables

### Parameter Types

#### **IN Parameters** (Default)
- Pass values INTO the procedure
- Cannot be modified within the procedure
- Can have default values

```sql
CREATE OR REPLACE PROCEDURE employee_report(
    p_department_id IN NUMBER DEFAULT NULL,
    p_min_salary    IN NUMBER DEFAULT 0,
    p_format        IN VARCHAR2 DEFAULT 'SUMMARY'
)
IS
BEGIN
    IF p_format = 'DETAILED' THEN
        -- Detailed report logic
        FOR emp_rec IN (
            SELECT employee_id, first_name, last_name, salary
            FROM employees
            WHERE (department_id = p_department_id OR p_department_id IS NULL)
            AND salary >= p_min_salary
            ORDER BY salary DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE(emp_rec.employee_id || ': ' || 
                               emp_rec.first_name || ' ' || emp_rec.last_name || 
                               ' - $' || emp_rec.salary);
        END LOOP;
    ELSE
        -- Summary report logic
        SELECT COUNT(*), AVG(salary), MAX(salary), MIN(salary)
        INTO v_count, v_avg, v_max, v_min
        FROM employees
        WHERE (department_id = p_department_id OR p_department_id IS NULL)
        AND salary >= p_min_salary;
        
        DBMS_OUTPUT.PUT_LINE('Employee Summary:');
        DBMS_OUTPUT.PUT_LINE('Count: ' || v_count);
        DBMS_OUTPUT.PUT_LINE('Average Salary: $' || ROUND(v_avg, 2));
    END IF;
END employee_report;
/

-- Various ways to call with default parameters
EXECUTE employee_report;                              -- All defaults
EXECUTE employee_report(20);                         -- Specific department
EXECUTE employee_report(p_format => 'DETAILED');     -- Named parameter
EXECUTE employee_report(20, 5000, 'DETAILED');       -- All parameters
```

#### **OUT Parameters**
- Return values FROM the procedure
- Must be assigned within the procedure
- Cannot have default values

```sql
CREATE OR REPLACE PROCEDURE get_employee_stats(
    p_department_id IN NUMBER,
    p_employee_count OUT NUMBER,
    p_avg_salary OUT NUMBER,
    p_max_salary OUT NUMBER,
    p_min_salary OUT NUMBER
)
IS
BEGIN
    SELECT COUNT(*), 
           ROUND(AVG(salary), 2), 
           MAX(salary), 
           MIN(salary)
    INTO p_employee_count, p_avg_salary, p_max_salary, p_min_salary
    FROM employees
    WHERE department_id = p_department_id;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_employee_count := 0;
        p_avg_salary := 0;
        p_max_salary := 0;
        p_min_salary := 0;
END get_employee_stats;
/

-- Usage with OUT parameters
DECLARE
    v_count NUMBER;
    v_avg NUMBER;
    v_max NUMBER;
    v_min NUMBER;
BEGIN
    get_employee_stats(
        p_department_id => 20,
        p_employee_count => v_count,
        p_avg_salary => v_avg,
        p_max_salary => v_max,
        p_min_salary => v_min
    );
    
    DBMS_OUTPUT.PUT_LINE('Department 20 Statistics:');
    DBMS_OUTPUT.PUT_LINE('Employees: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('Average Salary: $' || v_avg);
    DBMS_OUTPUT.PUT_LINE('Salary Range: $' || v_min || ' - $' || v_max);
END;
/
```

#### **IN OUT Parameters**
- Pass values both IN and OUT
- Can be modified within the procedure
- Initial value is available inside procedure

```sql
CREATE OR REPLACE PROCEDURE format_employee_name(
    p_name IN OUT VARCHAR2,
    p_format IN VARCHAR2 DEFAULT 'PROPER'
)
IS
BEGIN
    CASE UPPER(p_format)
        WHEN 'UPPER' THEN
            p_name := UPPER(p_name);
        WHEN 'LOWER' THEN
            p_name := LOWER(p_name);
        WHEN 'PROPER' THEN
            p_name := INITCAP(p_name);
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Invalid format: ' || p_format);
    END CASE;
    
    -- Remove extra spaces
    p_name := REGEXP_REPLACE(p_name, '\s+', ' ');
    p_name := TRIM(p_name);
END format_employee_name;
/

-- Usage with IN OUT parameter
DECLARE
    v_name VARCHAR2(100) := 'john   DOE';
BEGIN
    DBMS_OUTPUT.PUT_LINE('Original: "' || v_name || '"');
    
    format_employee_name(v_name, 'PROPER');
    DBMS_OUTPUT.PUT_LINE('Formatted: "' || v_name || '"');
END;
/
```

---

## Control Structures

### Conditional Statements

#### **IF-THEN-ELSE**
```sql
CREATE OR REPLACE PROCEDURE categorize_employee(
    p_employee_id IN NUMBER
)
IS
    v_salary NUMBER;
    v_hire_date DATE;
    v_category VARCHAR2(50);
    v_experience_years NUMBER;
BEGIN
    -- Get employee data
    SELECT salary, hire_date
    INTO v_salary, v_hire_date
    FROM employees
    WHERE employee_id = p_employee_id;
    
    v_experience_years := ROUND(MONTHS_BETWEEN(SYSDATE, v_hire_date) / 12, 1);
    
    -- Categorize by salary and experience
    IF v_salary >= 10000 THEN
        IF v_experience_years >= 10 THEN
            v_category := 'Senior Executive';
        ELSIF v_experience_years >= 5 THEN
            v_category := 'Mid-Level Executive';
        ELSE
            v_category := 'Junior Executive';
        END IF;
    ELSIF v_salary >= 5000 THEN
        IF v_experience_years >= 10 THEN
            v_category := 'Senior Professional';
        ELSIF v_experience_years >= 3 THEN
            v_category := 'Mid-Level Professional';
        ELSE
            v_category := 'Junior Professional';
        END IF;
    ELSE
        IF v_experience_years >= 5 THEN
            v_category := 'Senior Associate';
        ELSE
            v_category := 'Associate';
        END IF;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || p_employee_id);
    DBMS_OUTPUT.PUT_LINE('Salary: $' || v_salary);
    DBMS_OUTPUT.PUT_LINE('Experience: ' || v_experience_years || ' years');
    DBMS_OUTPUT.PUT_LINE('Category: ' || v_category);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee ID ' || p_employee_id || ' not found');
END categorize_employee;
/
```

#### **CASE Statements**
```sql
CREATE OR REPLACE PROCEDURE calculate_bonus(
    p_employee_id IN NUMBER,
    p_performance_rating IN VARCHAR2,
    p_bonus_amount OUT NUMBER
)
IS
    v_salary NUMBER;
    v_job_id VARCHAR2(10);
    v_base_bonus_pct NUMBER;
BEGIN
    -- Get employee salary and job
    SELECT salary, job_id
    INTO v_salary, v_job_id
    FROM employees
    WHERE employee_id = p_employee_id;
    
    -- Determine base bonus percentage by job level
    v_base_bonus_pct := CASE 
        WHEN v_job_id LIKE '%_MGR' OR v_job_id LIKE '%_MAN' THEN 0.15  -- Managers
        WHEN v_job_id LIKE 'SA_%' THEN 0.12                            -- Sales
        WHEN v_job_id LIKE 'IT_%' THEN 0.10                           -- IT
        WHEN v_job_id LIKE 'FI_%' THEN 0.08                           -- Finance
        ELSE 0.05                                                      -- Others
    END;
    
    -- Adjust by performance rating
    p_bonus_amount := v_salary * v_base_bonus_pct * 
        CASE UPPER(p_performance_rating)
            WHEN 'EXCELLENT' THEN 1.5
            WHEN 'GOOD' THEN 1.2
            WHEN 'SATISFACTORY' THEN 1.0
            WHEN 'NEEDS_IMPROVEMENT' THEN 0.5
            WHEN 'POOR' THEN 0.0
            ELSE 
                RAISE_APPLICATION_ERROR(-20001, 'Invalid performance rating: ' || p_performance_rating)
        END;
    
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || p_employee_id);
    DBMS_OUTPUT.PUT_LINE('Base Salary: $' || v_salary);
    DBMS_OUTPUT.PUT_LINE('Performance: ' || p_performance_rating);
    DBMS_OUTPUT.PUT_LINE('Bonus Amount: $' || ROUND(p_bonus_amount, 2));
    
END calculate_bonus;
/
```

### Loop Structures

#### **Basic LOOP**
```sql
CREATE OR REPLACE PROCEDURE generate_employee_reports
IS
    v_dept_id NUMBER := 10;
    v_max_dept_id NUMBER := 100;
    v_employee_count NUMBER;
BEGIN
    LOOP
        -- Check if department has employees
        SELECT COUNT(*)
        INTO v_employee_count
        FROM employees
        WHERE department_id = v_dept_id;
        
        IF v_employee_count > 0 THEN
            DBMS_OUTPUT.PUT_LINE('Department ' || v_dept_id || 
                               ' has ' || v_employee_count || ' employees');
        END IF;
        
        v_dept_id := v_dept_id + 10;
        
        -- Exit condition
        EXIT WHEN v_dept_id > v_max_dept_id;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Report generation completed');
END generate_employee_reports;
/
```

#### **WHILE LOOP**
```sql
CREATE OR REPLACE PROCEDURE process_pending_orders
IS
    v_order_id NUMBER;
    v_processed_count NUMBER := 0;
    
    CURSOR pending_orders_cur IS
        SELECT order_id
        FROM sales.orders
        WHERE status = 'PENDING'
        ORDER BY order_date;
BEGIN
    OPEN pending_orders_cur;
    
    WHILE pending_orders_cur%FOUND OR pending_orders_cur%NOTFOUND IS NULL LOOP
        FETCH pending_orders_cur INTO v_order_id;
        
        EXIT WHEN pending_orders_cur%NOTFOUND;
        
        -- Process the order (simplified)
        UPDATE sales.orders
        SET status = 'PROCESSING',
            processed_date = SYSDATE
        WHERE order_id = v_order_id;
        
        v_processed_count := v_processed_count + 1;
        
        -- Commit every 100 orders
        IF MOD(v_processed_count, 100) = 0 THEN
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Processed ' || v_processed_count || ' orders so far...');
        END IF;
    END LOOP;
    
    CLOSE pending_orders_cur;
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Total orders processed: ' || v_processed_count);
END process_pending_orders;
/
```

#### **FOR LOOP - Numeric**
```sql
CREATE OR REPLACE PROCEDURE create_monthly_summaries(
    p_year IN NUMBER
)
IS
    v_month_name VARCHAR2(20);
    v_order_count NUMBER;
    v_total_revenue NUMBER;
BEGIN
    FOR month_num IN 1..12 LOOP
        -- Get month name
        v_month_name := TO_CHAR(TO_DATE(month_num, 'MM'), 'Month');
        
        -- Calculate monthly statistics
        SELECT COUNT(*), COALESCE(SUM(oi.quantity * oi.unit_price), 0)
        INTO v_order_count, v_total_revenue
        FROM sales.orders o
        LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
        WHERE EXTRACT(YEAR FROM o.order_date) = p_year
        AND EXTRACT(MONTH FROM o.order_date) = month_num;
        
        -- Insert summary record
        INSERT INTO monthly_summaries (
            summary_year,
            summary_month,
            month_name,
            order_count,
            total_revenue,
            created_date
        ) VALUES (
            p_year,
            month_num,
            TRIM(v_month_name),
            v_order_count,
            v_total_revenue,
            SYSDATE
        );
        
        DBMS_OUTPUT.PUT_LINE(TRIM(v_month_name) || ' ' || p_year || 
                           ': ' || v_order_count || ' orders, $' || 
                           ROUND(v_total_revenue, 2) || ' revenue');
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Monthly summaries created for year ' || p_year);
END create_monthly_summaries;
/
```

#### **FOR LOOP - Cursor**
```sql
CREATE OR REPLACE PROCEDURE annual_performance_review
IS
    -- Cursor for all employees
    CURSOR employee_cur IS
        SELECT 
            e.employee_id,
            e.first_name,
            e.last_name,
            e.hire_date,
            e.salary,
            e.department_id,
            d.department_name
        FROM employees e
        LEFT JOIN departments d ON e.department_id = d.department_id
        ORDER BY e.department_id, e.last_name;
        
    v_years_service NUMBER;
    v_performance_score NUMBER;
    v_recommended_raise NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== ANNUAL PERFORMANCE REVIEW ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR emp_rec IN employee_cur LOOP
        -- Calculate years of service
        v_years_service := ROUND(MONTHS_BETWEEN(SYSDATE, emp_rec.hire_date) / 12, 1);
        
        -- Calculate performance score (simplified algorithm)
        v_performance_score := CASE
            WHEN v_years_service >= 10 THEN 85 + DBMS_RANDOM.VALUE(0, 15)
            WHEN v_years_service >= 5 THEN 75 + DBMS_RANDOM.VALUE(0, 20)
            WHEN v_years_service >= 2 THEN 70 + DBMS_RANDOM.VALUE(0, 25)
            ELSE 65 + DBMS_RANDOM.VALUE(0, 30)
        END;
        
        -- Recommend salary increase
        v_recommended_raise := CASE
            WHEN v_performance_score >= 90 THEN 0.08  -- 8%
            WHEN v_performance_score >= 80 THEN 0.06  -- 6%
            WHEN v_performance_score >= 70 THEN 0.04  -- 4%
            WHEN v_performance_score >= 60 THEN 0.02  -- 2%
            ELSE 0                                     -- No raise
        END;
        
        -- Insert performance record
        INSERT INTO performance_reviews (
            employee_id,
            review_year,
            performance_score,
            years_service,
            current_salary,
            recommended_raise_pct,
            recommended_new_salary,
            review_date,
            reviewed_by
        ) VALUES (
            emp_rec.employee_id,
            EXTRACT(YEAR FROM SYSDATE),
            ROUND(v_performance_score, 1),
            v_years_service,
            emp_rec.salary,
            v_recommended_raise,
            ROUND(emp_rec.salary * (1 + v_recommended_raise), 2),
            SYSDATE,
            USER
        );
        
        -- Display review summary
        DBMS_OUTPUT.PUT_LINE(emp_rec.first_name || ' ' || emp_rec.last_name || 
                           ' (' || emp_rec.department_name || ')');
        DBMS_OUTPUT.PUT_LINE('  Performance Score: ' || ROUND(v_performance_score, 1));
        DBMS_OUTPUT.PUT_LINE('  Recommended Raise: ' || (v_recommended_raise * 100) || '%');
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Performance reviews completed for all employees');
END annual_performance_review;
/
```

---

## Exception Handling

Exception handling is crucial for robust stored procedures that can handle errors gracefully.

### Predefined Exceptions

```sql
CREATE OR REPLACE PROCEDURE safe_employee_lookup(
    p_employee_id IN NUMBER,
    p_employee_name OUT VARCHAR2,
    p_salary OUT NUMBER
)
IS
BEGIN
    SELECT first_name || ' ' || last_name, salary
    INTO p_employee_name, p_salary
    FROM employees
    WHERE employee_id = p_employee_id;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_employee_name := 'Employee not found';
        p_salary := 0;
        DBMS_OUTPUT.PUT_LINE('No employee found with ID: ' || p_employee_id);
        
    WHEN TOO_MANY_ROWS THEN
        p_employee_name := 'Multiple employees found';
        p_salary := 0;
        DBMS_OUTPUT.PUT_LINE('Multiple employees found with ID: ' || p_employee_id);
        
    WHEN VALUE_ERROR THEN
        p_employee_name := 'Invalid data type';
        p_salary := 0;
        DBMS_OUTPUT.PUT_LINE('Invalid employee ID format: ' || p_employee_id);
        
    WHEN OTHERS THEN
        p_employee_name := 'Unknown error';
        p_salary := 0;
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Error code: ' || SQLCODE);
END safe_employee_lookup;
/
```

### User-Defined Exceptions

```sql
CREATE OR REPLACE PROCEDURE transfer_employee(
    p_employee_id IN NUMBER,
    p_new_department_id IN NUMBER,
    p_effective_date IN DATE DEFAULT SYSDATE
)
IS
    -- User-defined exceptions
    invalid_employee EXCEPTION;
    invalid_department EXCEPTION;
    future_date_error EXCEPTION;
    same_department EXCEPTION;
    
    -- Variables
    v_current_dept_id NUMBER;
    v_dept_exists NUMBER;
    v_employee_name VARCHAR2(100);
    
BEGIN
    -- Validate effective date
    IF p_effective_date > SYSDATE THEN
        RAISE future_date_error;
    END IF;
    
    -- Check if employee exists and get current department
    BEGIN
        SELECT department_id, first_name || ' ' || last_name
        INTO v_current_dept_id, v_employee_name
        FROM employees
        WHERE employee_id = p_employee_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE invalid_employee;
    END;
    
    -- Check if new department exists
    SELECT COUNT(*)
    INTO v_dept_exists
    FROM departments
    WHERE department_id = p_new_department_id;
    
    IF v_dept_exists = 0 THEN
        RAISE invalid_department;
    END IF;
    
    -- Check if it's the same department
    IF v_current_dept_id = p_new_department_id THEN
        RAISE same_department;
    END IF;
    
    -- Perform the transfer
    UPDATE employees
    SET department_id = p_new_department_id,
        last_modified_date = SYSDATE,
        last_modified_by = USER
    WHERE employee_id = p_employee_id;
    
    -- Log the transfer
    INSERT INTO employee_transfers (
        employee_id,
        from_department_id,
        to_department_id,
        transfer_date,
        transferred_by,
        transfer_reason
    ) VALUES (
        p_employee_id,
        v_current_dept_id,
        p_new_department_id,
        p_effective_date,
        USER,
        'Administrative Transfer'
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Employee transfer completed successfully:');
    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_employee_name);
    DBMS_OUTPUT.PUT_LINE('From Department: ' || v_current_dept_id);
    DBMS_OUTPUT.PUT_LINE('To Department: ' || p_new_department_id);
    
EXCEPTION
    WHEN invalid_employee THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20001, 'Invalid employee ID: ' || p_employee_id);
        
    WHEN invalid_department THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20002, 'Invalid department ID: ' || p_new_department_id);
        
    WHEN future_date_error THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20003, 'Effective date cannot be in the future');
        
    WHEN same_department THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20004, 'Employee is already in department ' || p_new_department_id);
        
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Unexpected error during transfer: ' || SQLERRM);
        RAISE; -- Re-raise the exception
END transfer_employee;
/
```

### Exception Propagation and Logging

```sql
CREATE OR REPLACE PROCEDURE comprehensive_error_handling(
    p_employee_id IN NUMBER
)
IS
    -- Custom exception
    business_rule_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(business_rule_violation, -20999);
    
    v_procedure_name VARCHAR2(50) := 'comprehensive_error_handling';
    v_error_message VARCHAR2(4000);
    v_error_code NUMBER;
    
BEGIN
    -- Savepoint for partial rollback
    SAVEPOINT before_processing;
    
    -- Some business logic that might fail
    UPDATE employees
    SET salary = salary * 1.10
    WHERE employee_id = p_employee_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE NO_DATA_FOUND;
    END IF;
    
    -- More processing...
    INSERT INTO audit_log (procedure_name, employee_id, action, action_date)
    VALUES (v_procedure_name, p_employee_id, 'SALARY_UPDATE', SYSDATE);
    
    COMMIT;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        ROLLBACK TO before_processing;
        v_error_message := 'Employee not found: ' || p_employee_id;
        v_error_code := SQLCODE;
        
        -- Log error
        INSERT INTO error_log (
            procedure_name,
            error_code,
            error_message,
            input_parameters,
            error_date,
            user_name
        ) VALUES (
            v_procedure_name,
            v_error_code,
            v_error_message,
            'employee_id=' || p_employee_id,
            SYSDATE,
            USER
        );
        COMMIT;
        
        -- Re-raise with custom message
        RAISE_APPLICATION_ERROR(-20100, v_error_message);
        
    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO before_processing;
        v_error_message := 'Duplicate value error in procedure: ' || v_procedure_name;
        
        -- Log and re-raise        INSERT INTO error_log (
            procedure_name, error_code, error_message, 
            input_parameters, error_date, user_name
        ) VALUES (
            v_procedure_name, SQLCODE, v_error_message,
            'employee_id=' || p_employee_id, SYSDATE, USER
        );
        COMMIT;
        
        RAISE_APPLICATION_ERROR(-20101, v_error_message);
        
    WHEN OTHERS THEN
        ROLLBACK TO before_processing;
        v_error_code := SQLCODE;
        v_error_message := SQLERRM;
        
        -- Ghi log các lỗi không mong muốn
        INSERT INTO error_log (
            procedure_name, error_code, error_message,
            input_parameters, error_date, user_name
        ) VALUES (
            v_procedure_name, v_error_code, v_error_message,
            'employee_id=' || p_employee_id, SYSDATE, USER
        );
        COMMIT;
        
        -- Ghi log vào application log
        DBMS_OUTPUT.PUT_LINE('LỖI NGHIÊM TRỌNG trong ' || v_procedure_name);
        DBMS_OUTPUT.PUT_LINE('Mã lỗi: ' || v_error_code);
        DBMS_OUTPUT.PUT_LINE('Thông điệp lỗi: ' || v_error_message);
        
        -- Ném lại exception gốc
        RAISE;
END comprehensive_error_handling;
/
```

---

## Tóm Tắt

Stored procedures là công cụ mạnh mẽ cho:

### **Đóng gói Logic Business**
- Tập trung quy tắc business trong database
- Triển khai nhất quán trên các ứng dụng
- Bảo vệ logic business

### **Lợi ích Hiệu suất**
- Execution plans được biên dịch trước
- Giảm network traffic
- Sử dụng bộ nhớ hiệu quả

### **Ưu thế Bảo mật**
- Kiểm soát truy cập dữ liệu thông qua procedures
- Ngăn chặn các cuộc tấn công SQL injection
- Khả năng audit trail

### Điểm Chính:

1. **Cấu trúc**: Tuân theo cấu trúc DECLARE-BEGIN-EXCEPTION-END nhất quán
2. **Tham số**: Sử dụng các loại tham số IN, OUT, IN OUT phù hợp
3. **Control Flow**: Thành thạo các cấu trúc IF-THEN-ELSE, CASE và LOOP
4. **Exception Handling**: Luôn bao gồm xử lý lỗi phù hợp
5. **Hiệu suất**: Cân nhắc việc sử dụng cursor và chiến lược commit
6. **Bảo mật**: Xác thực kỹ lưỡng tất cả tham số đầu vào

### Bước Tiếp Theo:

- Thực hành tạo procedures cho yêu cầu business của bạn
- Học các tính năng PL/SQL nâng cao như collections và dynamic SQL
- Nghiên cứu việc tạo package để tổ chức các procedures liên quan
- Thành thạo kỹ thuật debugging cho các procedures phức tạp

**Tệp Thực hành**: Làm việc thông qua `src/advanced/stored-procedures.sql` để có ví dụ và bài tập thực hành.
