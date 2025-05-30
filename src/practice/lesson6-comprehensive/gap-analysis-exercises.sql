
/*
===========================================
ORACLE DATABASE GAP ANALYSIS EXERCISES
===========================================

This file contains targeted exercises to identify and improve specific skill gaps
in Oracle Database development. Complete each section to assess your proficiency
and focus on areas needing improvement.

Skills Assessment Areas:
1. Basic SQL Query Optimization
2. Advanced JOIN Operations
3. PL/SQL Programming
4. Database Design Principles
5. Performance Tuning
6. Security Implementation
7. Error Handling & Debugging
8. Real-world Problem Solving

Instructions:
- Attempt each exercise before looking at the solution
- Rate your confidence (1-5) for each area
- Focus additional study on low-confidence areas
- Use these exercises for interview preparation
*/

-- ===========================================
-- SECTION 1: BASIC SQL PROFICIENCY CHECK
-- ===========================================

/*
Exercise 1.1: Query Optimization Analysis
Analyze and improve the following inefficient query:

Original Query:
SELECT * FROM employees e, departments d, locations l, countries c
WHERE e.department_id = d.department_id
AND d.location_id = l.location_id
AND l.country_id = c.country_id
AND e.salary > (SELECT AVG(salary) FROM employees)
ORDER BY e.last_name;

Tasks:
a) Rewrite using modern JOIN syntax
b) Add appropriate indexes
c) Optimize the subquery
d) Explain why your version is better
*/

-- Your Solution 1.1:
-- (Write your improved query here)

-- ===========================================
-- SOLUTION 1.1: Modern JOIN with Optimization
-- ===========================================
/*
WITH avg_salary AS (
    SELECT AVG(salary) AS avg_sal FROM employees
)
SELECT e.employee_id, e.first_name, e.last_name, e.salary,
       d.department_name, l.city, c.country_name
FROM employees e
    INNER JOIN departments d ON e.department_id = d.department_id
    INNER JOIN locations l ON d.location_id = l.location_id
    INNER JOIN countries c ON l.country_id = c.country_id
    CROSS JOIN avg_salary a
WHERE e.salary > a.avg_sal
ORDER BY e.last_name;

-- Recommended Indexes:
CREATE INDEX idx_emp_dept_salary ON employees(department_id, salary);
CREATE INDEX idx_dept_location ON departments(location_id);
CREATE INDEX idx_loc_country ON locations(country_id);

Improvements:
- Modern JOIN syntax for clarity
- CTE eliminates correlated subquery
- Specific column selection instead of SELECT *
- Proper indexing strategy for JOIN conditions
*/

/*
Exercise 1.2: Complex Aggregation Challenge
Create a query that shows:
- Each department's employee count
- Average salary by department
- Department ranking by total payroll
- Percentage of company's total payroll
- Only departments with > 5 employees

Your Solution 1.2:
*/

-- Write your query here

-- ===========================================
-- SOLUTION 1.2: Advanced Aggregation
-- ===========================================
WITH dept_stats AS (
    SELECT 
        d.department_id,
        d.department_name,
        COUNT(e.employee_id) as emp_count,
        AVG(e.salary) as avg_salary,
        SUM(e.salary) as total_payroll
    FROM departments d
        LEFT JOIN employees e ON d.department_id = e.department_id
    WHERE e.employee_id IS NOT NULL  -- Only departments with employees
    GROUP BY d.department_id, d.department_name
    HAVING COUNT(e.employee_id) > 5
),
company_totals AS (
    SELECT SUM(total_payroll) as company_payroll FROM dept_stats
)
SELECT 
    ds.department_name,
    ds.emp_count,
    ROUND(ds.avg_salary, 2) as avg_salary,
    ds.total_payroll,
    RANK() OVER (ORDER BY ds.total_payroll DESC) as payroll_rank,
    ROUND((ds.total_payroll / ct.company_payroll) * 100, 2) as payroll_percentage
FROM dept_stats ds
    CROSS JOIN company_totals ct
ORDER BY ds.total_payroll DESC;

-- ===========================================
-- SECTION 2: ADVANCED JOIN MASTERY
-- ===========================================

/*
Exercise 2.1: Complex Multi-Table JOIN
Write a query to find employees who:
- Work in departments located in the same country as their manager's department
- Have a salary within 20% of their department's average
- Have been employed for more than 2 years
- Include employee details, manager details, and department info

Your Solution 2.1:
*/

-- Write your complex JOIN query here

-- ===========================================
-- SOLUTION 2.1: Multi-Table JOIN with Complex Logic
-- ===========================================
WITH dept_avg_salary AS (
    SELECT 
        department_id,
        AVG(salary) as dept_avg_sal
    FROM employees
    GROUP BY department_id
)
SELECT DISTINCT
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.salary,
    e.hire_date,
    m.first_name || ' ' || m.last_name as manager_name,
    d.department_name,
    l.city,
    c.country_name,
    das.dept_avg_sal,
    ROUND(ABS(e.salary - das.dept_avg_sal) / das.dept_avg_sal * 100, 2) as salary_variance_pct
FROM employees e
    INNER JOIN departments d ON e.department_id = d.department_id
    INNER JOIN locations l ON d.location_id = l.location_id
    INNER JOIN countries c ON l.country_id = c.country_id
    INNER JOIN employees m ON e.manager_id = m.employee_id
    INNER JOIN departments md ON m.department_id = md.department_id
    INNER JOIN locations ml ON md.location_id = ml.location_id
    INNER JOIN countries mc ON ml.country_id = mc.country_id
    INNER JOIN dept_avg_salary das ON e.department_id = das.department_id
WHERE c.country_id = mc.country_id  -- Same country as manager
    AND ABS(e.salary - das.dept_avg_sal) / das.dept_avg_sal <= 0.20  -- Within 20%
    AND e.hire_date <= ADD_MONTHS(SYSDATE, -24)  -- More than 2 years
ORDER BY e.last_name;

-- ===========================================
-- SECTION 3: PL/SQL PROGRAMMING PROFICIENCY
-- ===========================================

/*
Exercise 3.1: Comprehensive Stored Procedure
Create a procedure that processes employee salary increases with:
- Input: department_id, increase_percentage, effective_date
- Business logic: Different rules for different salary ranges
- Error handling: Invalid inputs, constraint violations
- Audit trail: Log all changes with timestamps
- Return: Summary of changes made

Your Solution 3.1:
*/

-- Write your stored procedure here

-- ===========================================
-- SOLUTION 3.1: Complex Salary Processing Procedure
-- ===========================================

-- First create audit table
CREATE TABLE salary_audit (
    audit_id NUMBER PRIMARY KEY,
    employee_id NUMBER,
    old_salary NUMBER(8,2),
    new_salary NUMBER(8,2),
    increase_pct NUMBER(5,2),
    effective_date DATE,
    processed_by VARCHAR2(50),
    processed_date DATE DEFAULT SYSDATE
);

CREATE SEQUENCE salary_audit_seq START WITH 1;

CREATE OR REPLACE PROCEDURE process_salary_increases (
    p_department_id IN NUMBER,
    p_increase_pct IN NUMBER,
    p_effective_date IN DATE DEFAULT SYSDATE,
    p_summary_message OUT VARCHAR2
) AS
    v_emp_count NUMBER := 0;
    v_total_increase NUMBER := 0;
    v_max_salary NUMBER := 50000;  -- Company salary cap
    v_processed_count NUMBER := 0;
    v_skipped_count NUMBER := 0;
    
    -- Exception definitions
    invalid_department EXCEPTION;
    invalid_percentage EXCEPTION;
    future_date_error EXCEPTION;
    
    -- Cursor for employees to process
    CURSOR emp_cursor IS
        SELECT employee_id, first_name, last_name, salary
        FROM employees
        WHERE department_id = p_department_id
        AND employment_status = 'ACTIVE'
        FOR UPDATE;
        
BEGIN
    -- Input validation
    IF p_department_id IS NULL OR p_department_id <= 0 THEN
        RAISE invalid_department;
    END IF;
    
    IF p_increase_pct IS NULL OR p_increase_pct < 0 OR p_increase_pct > 50 THEN
        RAISE invalid_percentage;
    END IF;
    
    IF p_effective_date > SYSDATE THEN
        RAISE future_date_error;
    END IF;
    
    -- Check if department exists
    SELECT COUNT(*) INTO v_emp_count
    FROM departments
    WHERE department_id = p_department_id;
    
    IF v_emp_count = 0 THEN
        RAISE invalid_department;
    END IF;
    
    -- Process each employee
    FOR emp_rec IN emp_cursor LOOP
        DECLARE
            v_new_salary NUMBER;
            v_actual_increase NUMBER;
        BEGIN
            -- Calculate new salary with business rules
            v_new_salary := emp_rec.salary * (1 + p_increase_pct / 100);
            
            -- Apply salary cap
            IF v_new_salary > v_max_salary THEN
                v_new_salary := v_max_salary;
            END IF;
            
            v_actual_increase := v_new_salary - emp_rec.salary;
            
            -- Only process if there's an actual increase
            IF v_actual_increase > 0 THEN
                -- Update employee salary
                UPDATE employees
                SET salary = v_new_salary,
                    last_salary_review = p_effective_date,
                    updated_date = SYSDATE
                WHERE employee_id = emp_rec.employee_id;
                
                -- Create audit record
                INSERT INTO salary_audit (
                    audit_id, employee_id, old_salary, new_salary,
                    increase_pct, effective_date, processed_by
                ) VALUES (
                    salary_audit_seq.NEXTVAL, emp_rec.employee_id,
                    emp_rec.salary, v_new_salary,
                    (v_actual_increase / emp_rec.salary) * 100,
                    p_effective_date, USER
                );
                
                v_processed_count := v_processed_count + 1;
                v_total_increase := v_total_increase + v_actual_increase;
            ELSE
                v_skipped_count := v_skipped_count + 1;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                -- Log error but continue processing
                DBMS_OUTPUT.PUT_LINE('Error processing employee ' || emp_rec.employee_id || ': ' || SQLERRM);
                v_skipped_count := v_skipped_count + 1;
        END;
    END LOOP;
    
    -- Commit all changes
    COMMIT;
    
    -- Create summary message
    p_summary_message := 'Salary increase processing completed. ' ||
                        'Processed: ' || v_processed_count || ' employees. ' ||
                        'Skipped: ' || v_skipped_count || ' employees. ' ||
                        'Total increase amount: $' || ROUND(v_total_increase, 2);
    
EXCEPTION
    WHEN invalid_department THEN
        ROLLBACK;
        p_summary_message := 'ERROR: Invalid or non-existent department ID';
    WHEN invalid_percentage THEN
        ROLLBACK;
        p_summary_message := 'ERROR: Increase percentage must be between 0 and 50';
    WHEN future_date_error THEN
        ROLLBACK;
        p_summary_message := 'ERROR: Effective date cannot be in the future';
    WHEN OTHERS THEN
        ROLLBACK;
        p_summary_message := 'ERROR: ' || SQLERRM;
END process_salary_increases;
/

/*
Exercise 3.2: Advanced Function with Error Handling
Create a function that calculates an employee's bonus based on:
- Performance rating (1-5 scale)
- Years of service
- Department budget availability
- Company profitability
- Return detailed calculation breakdown

Your Solution 3.2:
*/

-- Write your function here

-- ===========================================
-- SOLUTION 3.2: Complex Bonus Calculation Function
-- ===========================================

CREATE OR REPLACE TYPE bonus_breakdown AS OBJECT (
    base_bonus NUMBER(8,2),
    performance_multiplier NUMBER(3,2),
    service_bonus NUMBER(8,2),
    department_factor NUMBER(3,2),
    company_factor NUMBER(3,2),
    final_bonus NUMBER(8,2),
    calculation_notes VARCHAR2(500)
);
/

CREATE OR REPLACE FUNCTION calculate_employee_bonus (
    p_employee_id IN NUMBER,
    p_performance_rating IN NUMBER,
    p_evaluation_period IN VARCHAR2 DEFAULT 'ANNUAL'
) RETURN bonus_breakdown AS
    
    v_result bonus_breakdown;
    v_salary NUMBER;
    v_hire_date DATE;
    v_dept_id NUMBER;
    v_years_service NUMBER;
    v_dept_budget NUMBER;
    v_dept_used_budget NUMBER;
    v_company_profit_margin NUMBER;
    v_base_bonus_pct NUMBER := 0.05;  -- 5% base bonus
    
    -- Exception definitions
    employee_not_found EXCEPTION;
    invalid_rating EXCEPTION;
    insufficient_service EXCEPTION;
    
BEGIN
    -- Initialize result object
    v_result := bonus_breakdown(0, 0, 0, 0, 0, 0, '');
    
    -- Input validation
    IF p_performance_rating < 1 OR p_performance_rating > 5 THEN
        RAISE invalid_rating;
    END IF;
    
    -- Get employee information
    BEGIN
        SELECT salary, hire_date, department_id
        INTO v_salary, v_hire_date, v_dept_id
        FROM employees
        WHERE employee_id = p_employee_id
        AND employment_status = 'ACTIVE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE employee_not_found;
    END;
    
    -- Calculate years of service
    v_years_service := MONTHS_BETWEEN(SYSDATE, v_hire_date) / 12;
    
    IF v_years_service < 1 THEN
        RAISE insufficient_service;
    END IF;
    
    -- Calculate base bonus
    v_result.base_bonus := v_salary * v_base_bonus_pct;
    
    -- Performance multiplier (1-5 rating maps to 0.5-2.0 multiplier)
    v_result.performance_multiplier := 0.5 + (p_performance_rating - 1) * 0.375;
    
    -- Service bonus (additional 1% per year, capped at 10%)
    v_result.service_bonus := v_salary * LEAST(v_years_service * 0.01, 0.10);
    
    -- Department budget factor (check available budget)
    BEGIN
        SELECT annual_budget, 
               NVL((SELECT SUM(bonus_amount) 
                    FROM employee_bonuses 
                    WHERE department_id = d.department_id 
                    AND EXTRACT(YEAR FROM bonus_date) = EXTRACT(YEAR FROM SYSDATE)), 0)
        INTO v_dept_budget, v_dept_used_budget
        FROM departments d
        WHERE d.department_id = v_dept_id;
        
        -- Calculate remaining budget factor
        IF v_dept_budget > 0 THEN
            v_result.department_factor := GREATEST(0.5, 
                LEAST(1.2, (v_dept_budget - v_dept_used_budget) / v_dept_budget));
        ELSE
            v_result.department_factor := 0.5;  -- Minimal bonus if no budget data
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_result.department_factor := 0.8;  -- Default factor
    END;
    
    -- Company profitability factor
    BEGIN
        SELECT profit_margin_pct / 100
        INTO v_company_profit_margin
        FROM company_financials
        WHERE fiscal_year = EXTRACT(YEAR FROM SYSDATE);
        
        -- Map profit margin to bonus factor (0% = 0.7, 10%+ = 1.3)
        v_result.company_factor := 0.7 + LEAST(0.6, v_company_profit_margin * 6);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_result.company_factor := 1.0;  -- Neutral factor if no data
    END;
    
    -- Calculate final bonus
    v_result.final_bonus := ROUND(
        (v_result.base_bonus + v_result.service_bonus) *
        v_result.performance_multiplier *
        v_result.department_factor *
        v_result.company_factor, 2);
    
    -- Create calculation notes
    v_result.calculation_notes := 
        'Base: $' || ROUND(v_result.base_bonus, 2) ||
        ', Service: $' || ROUND(v_result.service_bonus, 2) ||
        ', Performance: ' || v_result.performance_multiplier || 'x' ||
        ', Dept Factor: ' || v_result.department_factor ||
        ', Company Factor: ' || v_result.company_factor ||
        ', Years Service: ' || ROUND(v_years_service, 1);
    
    RETURN v_result;
    
EXCEPTION
    WHEN employee_not_found THEN
        v_result.calculation_notes := 'ERROR: Employee not found or inactive';
        RETURN v_result;
    WHEN invalid_rating THEN
        v_result.calculation_notes := 'ERROR: Performance rating must be between 1 and 5';
        RETURN v_result;
    WHEN insufficient_service THEN
        v_result.calculation_notes := 'ERROR: Employee must have at least 1 year of service';
        RETURN v_result;
    WHEN OTHERS THEN
        v_result.calculation_notes := 'ERROR: ' || SQLERRM;
        RETURN v_result;
END calculate_employee_bonus;
/

-- ===========================================
-- SECTION 4: PERFORMANCE TUNING CHALLENGES
-- ===========================================

/*
Exercise 4.1: Query Performance Analysis
Given this slow-performing query, identify bottlenecks and optimize:

SELECT e.first_name, e.last_name, d.department_name,
       (SELECT COUNT(*) FROM employees e2 WHERE e2.manager_id = e.employee_id) as direct_reports,
       (SELECT AVG(salary) FROM employees e3 WHERE e3.department_id = e.department_id) as dept_avg_salary
FROM employees e, departments d
WHERE e.department_id = d.department_id
  AND e.hire_date > '01-JAN-2020'
  AND e.salary > (SELECT AVG(salary) * 1.2 FROM employees e4 WHERE e4.department_id = e.department_id)
ORDER BY e.last_name;

Your Analysis and Solution 4.1:
*/

-- Performance Issues Identified:
-- 1. Correlated subqueries in SELECT clause (executed for each row)
-- 2. Old-style comma JOIN syntax
-- 3. Correlated subquery in WHERE clause
-- 4. No indexes on critical columns
-- 5. String literal date format (not portable)

-- Optimized Solution:
WITH dept_stats AS (
    SELECT 
        department_id,
        AVG(salary) as avg_salary,
        AVG(salary) * 1.2 as high_salary_threshold
    FROM employees
    GROUP BY department_id
),
manager_reports AS (
    SELECT 
        manager_id,
        COUNT(*) as direct_reports
    FROM employees
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
)
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    NVL(mr.direct_reports, 0) as direct_reports,
    ROUND(ds.avg_salary, 2) as dept_avg_salary
FROM employees e
    INNER JOIN departments d ON e.department_id = d.department_id
    INNER JOIN dept_stats ds ON e.department_id = ds.department_id
    LEFT JOIN manager_reports mr ON e.employee_id = mr.manager_id
WHERE e.hire_date > DATE '2020-01-01'
    AND e.salary > ds.high_salary_threshold
ORDER BY e.last_name;

-- Recommended indexes:
CREATE INDEX idx_emp_dept_hire_salary ON employees(department_id, hire_date, salary);
CREATE INDEX idx_emp_manager ON employees(manager_id);

/*
Exercise 4.2: Index Strategy Design
Design an optimal indexing strategy for this query workload:

Query 1: Find employees by last name and department
Query 2: Get salary history for an employee by date range
Query 3: Find all employees hired in a specific month/year
Query 4: Manager reports with employee counts
Query 5: Department salary statistics

Your Indexing Strategy 4.2:
*/

-- Comprehensive Indexing Strategy:

-- 1. Employee lookup by name and department
CREATE INDEX idx_emp_name_dept ON employees(last_name, first_name, department_id);

-- 2. Salary history queries (assuming salary_history table exists)
CREATE INDEX idx_sal_hist_emp_date ON salary_history(employee_id, effective_date, salary);

-- 3. Hire date queries with flexible date range searching
CREATE INDEX idx_emp_hire_date ON employees(hire_date, employee_id);
CREATE INDEX idx_emp_hire_year_month ON employees(EXTRACT(YEAR FROM hire_date), EXTRACT(MONTH FROM hire_date));

-- 4. Manager-employee relationships
CREATE INDEX idx_emp_manager_dept ON employees(manager_id, department_id, employee_id);

-- 5. Department salary analysis
CREATE INDEX idx_emp_dept_salary_status ON employees(department_id, salary, employment_status);

-- 6. Composite index for common WHERE clause combinations
CREATE INDEX idx_emp_status_dept_hire ON employees(employment_status, department_id, hire_date);

-- 7. Covering index for frequently accessed employee data
CREATE INDEX idx_emp_covering ON employees(employee_id, first_name, last_name, department_id, salary, hire_date);

-- ===========================================
-- SECTION 5: REAL-WORLD PROBLEM SOLVING
-- ===========================================

/*
Exercise 5.1: Data Migration Challenge
You need to migrate employee data from a legacy system with these challenges:
- Inconsistent date formats
- Mixed case names that need standardization
- Duplicate records that need deduplication
- Invalid email addresses that need correction
- Salary data in different currencies

Create a comprehensive migration procedure.

Your Solution 5.1:
*/

-- Data Migration Procedure with Error Handling and Logging

-- Create staging and log tables
CREATE TABLE employee_staging (
    staging_id NUMBER PRIMARY KEY,
    legacy_emp_id VARCHAR2(50),
    raw_first_name VARCHAR2(100),
    raw_last_name VARCHAR2(100),
    raw_email VARCHAR2(200),
    raw_hire_date VARCHAR2(50),
    raw_salary VARCHAR2(50),
    raw_currency VARCHAR2(10),
    raw_department VARCHAR2(100),
    import_date DATE DEFAULT SYSDATE,
    processing_status VARCHAR2(20) DEFAULT 'PENDING',
    error_message VARCHAR2(500)
);

CREATE TABLE migration_log (
    log_id NUMBER PRIMARY KEY,
    operation_type VARCHAR2(50),
    record_count NUMBER,
    success_count NUMBER,
    error_count NUMBER,
    operation_date DATE DEFAULT SYSDATE,
    details CLOB
);

CREATE SEQUENCE staging_seq START WITH 1;
CREATE SEQUENCE migration_log_seq START WITH 1;

CREATE OR REPLACE PROCEDURE migrate_employee_data AS
    v_processed_count NUMBER := 0;
    v_success_count NUMBER := 0;
    v_error_count NUMBER := 0;
    v_duplicate_count NUMBER := 0;
    
    -- Currency conversion rates (simplified)
    TYPE currency_rates_type IS TABLE OF NUMBER INDEX BY VARCHAR2(3);
    v_currency_rates currency_rates_type;
    
    -- Cursor for processing staging records
    CURSOR staging_cursor IS
        SELECT * FROM employee_staging
        WHERE processing_status = 'PENDING'
        FOR UPDATE;
        
BEGIN
    -- Initialize currency conversion rates
    v_currency_rates('USD') := 1.0;
    v_currency_rates('EUR') := 1.18;
    v_currency_rates('GBP') := 1.37;
    v_currency_rates('CAD') := 0.79;
    
    -- Process each staging record
    FOR stage_rec IN staging_cursor LOOP
        DECLARE
            v_clean_first_name VARCHAR2(50);
            v_clean_last_name VARCHAR2(50);
            v_clean_email VARCHAR2(100);
            v_hire_date DATE;
            v_salary NUMBER;
            v_dept_id NUMBER;
            v_duplicate_check NUMBER;
            v_error_msg VARCHAR2(500) := '';
            
        BEGIN
            v_processed_count := v_processed_count + 1;
            
            -- Clean and standardize names
            v_clean_first_name := INITCAP(TRIM(stage_rec.raw_first_name));
            v_clean_last_name := INITCAP(TRIM(stage_rec.raw_last_name));
            
            -- Validate and clean email
            v_clean_email := LOWER(TRIM(stage_rec.raw_email));
            IF NOT REGEXP_LIKE(v_clean_email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
                -- Try to fix common email issues
                v_clean_email := REPLACE(v_clean_email, ' ', '');
                v_clean_email := REPLACE(v_clean_email, '..', '.');
                IF INSTR(v_clean_email, '@') = 0 THEN
                    v_clean_email := v_clean_email || '@company.com';  -- Default domain
                END IF;
            END IF;
            
            -- Parse hire date (try multiple formats)
            BEGIN
                v_hire_date := TO_DATE(stage_rec.raw_hire_date, 'DD-MON-YYYY');
            EXCEPTION
                WHEN OTHERS THEN
                    BEGIN
                        v_hire_date := TO_DATE(stage_rec.raw_hire_date, 'MM/DD/YYYY');
                    EXCEPTION
                        WHEN OTHERS THEN
                            BEGIN
                                v_hire_date := TO_DATE(stage_rec.raw_hire_date, 'YYYY-MM-DD');
                            EXCEPTION
                                WHEN OTHERS THEN
                                    v_error_msg := v_error_msg || 'Invalid hire date format; ';
                                    v_hire_date := SYSDATE;  -- Default to today
                            END;
                    END;
            END;
            
            -- Convert salary to USD
            BEGIN
                v_salary := TO_NUMBER(REGEXP_REPLACE(stage_rec.raw_salary, '[^0-9.]', ''));
                IF v_currency_rates.EXISTS(NVL(stage_rec.raw_currency, 'USD')) THEN
                    v_salary := v_salary * v_currency_rates(NVL(stage_rec.raw_currency, 'USD'));
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    v_error_msg := v_error_msg || 'Invalid salary format; ';
                    v_salary := 0;
            END;
            
            -- Find department ID
            BEGIN
                SELECT department_id INTO v_dept_id
                FROM departments
                WHERE UPPER(department_name) = UPPER(TRIM(stage_rec.raw_department));
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_error_msg := v_error_msg || 'Department not found; ';
                    v_dept_id := 1;  -- Default department
                WHEN TOO_MANY_ROWS THEN
                    v_error_msg := v_error_msg || 'Multiple departments match; ';
                    v_dept_id := 1;  -- Default department
            END;
            
            -- Check for duplicates
            SELECT COUNT(*) INTO v_duplicate_check
            FROM employees
            WHERE UPPER(first_name) = UPPER(v_clean_first_name)
                AND UPPER(last_name) = UPPER(v_clean_last_name)
                AND (email = v_clean_email OR hire_date = v_hire_date);
            
            IF v_duplicate_check > 0 THEN
                v_error_msg := v_error_msg || 'Potential duplicate found; ';
                v_duplicate_count := v_duplicate_count + 1;
                
                -- Update staging record as duplicate
                UPDATE employee_staging
                SET processing_status = 'DUPLICATE',
                    error_message = v_error_msg
                WHERE staging_id = stage_rec.staging_id;
            ELSE
                -- Insert into employees table
                INSERT INTO employees (
                    employee_id, first_name, last_name, email,
                    hire_date, salary, department_id,
                    employment_status, created_date
                ) VALUES (
                    employee_seq.NEXTVAL, v_clean_first_name, v_clean_last_name,
                    v_clean_email, v_hire_date, v_salary, v_dept_id,
                    'ACTIVE', SYSDATE
                );
                
                v_success_count := v_success_count + 1;
                
                -- Update staging record as successful
                UPDATE employee_staging
                SET processing_status = 'SUCCESS',
                    error_message = CASE WHEN v_error_msg IS NOT NULL 
                                        THEN 'Processed with warnings: ' || v_error_msg 
                                        ELSE NULL END
                WHERE staging_id = stage_rec.staging_id;
            END IF;
            
        EXCEPTION
            WHEN OTHERS THEN
                v_error_count := v_error_count + 1;
                
                -- Update staging record as failed
                UPDATE employee_staging
                SET processing_status = 'FAILED',
                    error_message = 'Processing error: ' || SQLERRM
                WHERE staging_id = stage_rec.staging_id;
        END;
    END LOOP;
    
    -- Log migration results
    INSERT INTO migration_log (
        log_id, operation_type, record_count, success_count, error_count,
        details
    ) VALUES (
        migration_log_seq.NEXTVAL, 'EMPLOYEE_MIGRATION',
        v_processed_count, v_success_count, v_error_count,
        'Migration completed. Processed: ' || v_processed_count ||
        ', Success: ' || v_success_count ||
        ', Errors: ' || v_error_count ||
        ', Duplicates: ' || v_duplicate_count
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Migration completed successfully!');
    DBMS_OUTPUT.PUT_LINE('Total processed: ' || v_processed_count);
    DBMS_OUTPUT.PUT_LINE('Successful: ' || v_success_count);
    DBMS_OUTPUT.PUT_LINE('Errors: ' || v_error_count);
    DBMS_OUTPUT.PUT_LINE('Duplicates: ' || v_duplicate_count);
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        
        INSERT INTO migration_log (
            log_id, operation_type, record_count, success_count, error_count,
            details
        ) VALUES (
            migration_log_seq.NEXTVAL, 'EMPLOYEE_MIGRATION_ERROR',
            v_processed_count, v_success_count, v_error_count,
            'Migration failed with error: ' || SQLERRM
        );
        
        COMMIT;
        RAISE;
END migrate_employee_data;
/

-- ===========================================
-- CONFIDENCE ASSESSMENT CHECKLIST
-- ===========================================

/*
Rate your confidence level (1-5) for each area after completing these exercises:

□ Basic SQL Query Writing and Optimization: ___/5
□ Advanced JOIN Operations and Complex Logic: ___/5
□ PL/SQL Programming (Procedures, Functions, Packages): ___/5
□ Database Design and Normalization: ___/5
□ Performance Tuning and Index Optimization: ___/5
□ Error Handling and Exception Management: ___/5
□ Real-world Problem Solving and Data Migration: ___/5
□ Security Implementation and Best Practices: ___/5

Areas needing improvement (confidence < 4):
_________________________________________________
_________________________________________________
_________________________________________________

Recommended next steps for improvement:
□ Review specific lesson materials for low-confidence areas
□ Practice additional exercises in weak areas
□ Study Oracle documentation for advanced features
□ Work on real-world projects to gain experience
□ Consider Oracle certification preparation
□ Join Oracle community forums for peer learning

OVERALL READINESS FOR PROFESSIONAL ORACLE DEVELOPMENT: ___/5
*/

-- ===========================================
-- ADDITIONAL PRACTICE SCENARIOS
-- ===========================================

/*
Continue your learning with these additional challenges:

1. Build a complete audit system with triggers and procedures
2. Implement a data archiving strategy with partitioning
3. Create a comprehensive reporting system with materialized views
4. Design a multi-tenant database architecture
5. Implement advanced security with VPD and encryption
6. Build automated monitoring and alerting systems
7. Create data validation and quality checking procedures
8. Implement change management and version control processes

Remember: Continuous learning and practical application are key to mastering Oracle Database development!
*/
