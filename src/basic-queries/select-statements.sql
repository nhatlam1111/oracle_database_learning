-- Lesson 3.1: SELECT Statements Practice
-- Oracle Database Learning Project
-- File: select-statements.sql

-- This file contains practical examples and exercises for SELECT statements
-- Run these queries after setting up the HR and SALES sample schemas

-- =============================================================================
-- BASIC SELECT STATEMENTS
-- =============================================================================

-- Example 1: Select all columns from a table
-- The asterisk (*) selects all columns
SELECT * FROM hr.employees;

-- Example 2: Select specific columns
-- More efficient and cleaner than SELECT *
SELECT employee_id, first_name, last_name, email 
FROM hr.employees;

-- Example 3: Using column aliases for better readability
-- Aliases make output more user-friendly
SELECT 
    employee_id AS "Employee ID",
    first_name AS "First Name", 
    last_name AS "Last Name",
    email AS "Email Address"
FROM hr.employees;

-- Example 4: Combining columns with concatenation
-- Oracle uses || for string concatenation
SELECT 
    employee_id,
    first_name || ' ' || last_name AS "Full Name",
    email || '@company.com' AS "Email Address"
FROM hr.employees;

-- =============================================================================
-- WORKING WITH DIFFERENT DATA TYPES
-- =============================================================================

-- Example 5: Numeric columns and calculations
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    salary,
    salary * 12 AS annual_salary,
    salary * 0.15 AS tax_estimate
FROM hr.employees;

-- Example 6: Date columns and date arithmetic
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    hire_date,
    SYSDATE AS current_date,
    SYSDATE - hire_date AS days_employed,
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS years_employed
FROM hr.employees;

-- Example 7: Working with NULL values
-- Notice how NULLs appear in commission_pct column
SELECT 
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    salary,
    commission_pct,
    salary + (salary * NVL(commission_pct, 0)) AS total_compensation
FROM hr.employees;

-- =============================================================================
-- USING BUILT-IN FUNCTIONS IN SELECT
-- =============================================================================

-- Example 8: String functions
SELECT 
    employee_id,
    UPPER(first_name) AS first_name_upper,
    LOWER(last_name) AS last_name_lower,
    INITCAP(email) AS email_proper_case,
    LENGTH(first_name || last_name) AS name_length
FROM hr.employees;

-- Example 9: Numeric functions
SELECT 
    employee_id,
    salary,
    ROUND(salary, -3) AS salary_rounded_thousands,
    CEIL(salary / 1000) AS salary_ceil_thousands,
    FLOOR(salary / 1000) AS salary_floor_thousands,
    MOD(employee_id, 10) AS employee_id_last_digit
FROM hr.employees;

-- Example 10: Date functions
SELECT 
    employee_id,
    hire_date,
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    EXTRACT(MONTH FROM hire_date) AS hire_month,
    TO_CHAR(hire_date, 'Day, Month DD, YYYY') AS hire_date_formatted,
    MONTHS_BETWEEN(SYSDATE, hire_date) AS months_employed
FROM hr.employees;

-- =============================================================================
-- WORKING WITH SALES SCHEMA
-- =============================================================================

-- Example 11: Product catalog with calculations
SELECT 
    product_id,
    product_name,
    category,
    price,
    price * 1.2 AS price_with_tax,
    CASE 
        WHEN price < 100 THEN 'Budget'
        WHEN price < 500 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_category
FROM sales.products;

-- Example 12: Customer information formatting
SELECT 
    customer_id,
    INITCAP(first_name || ' ' || last_name) AS customer_name,
    UPPER(city) AS city_upper,
    country,
    phone,
    NVL(email, 'No email provided') AS email_status
FROM sales.customers;

-- Example 13: Order summary with date formatting
SELECT 
    order_id,
    customer_id,
    order_date,
    TO_CHAR(order_date, 'MM/DD/YYYY') AS order_date_us,
    TO_CHAR(order_date, 'DD-MON-YYYY') AS order_date_oracle,
    status,
    total_amount,
    TO_CHAR(total_amount, '$999,999.00') AS formatted_amount
FROM sales.orders;

-- =============================================================================
-- ADVANCED SELECT EXAMPLES
-- =============================================================================

-- Example 14: Using DISTINCT to eliminate duplicates
SELECT DISTINCT department_id 
FROM hr.employees;

-- Example 15: DISTINCT with multiple columns
SELECT DISTINCT department_id, job_id 
FROM hr.employees
ORDER BY department_id, job_id;

-- Example 16: Using ROWNUM for limiting results
-- Get first 10 employees (Oracle-specific)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE ROWNUM <= 10;

-- Example 17: Complex expression in SELECT
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary,
    commission_pct,
    CASE 
        WHEN commission_pct IS NULL THEN salary
        ELSE salary + (salary * commission_pct)
    END AS total_compensation,
    CASE 
        WHEN salary < 5000 THEN 'Entry Level'
        WHEN salary < 10000 THEN 'Mid Level'
        WHEN salary < 15000 THEN 'Senior Level'
        ELSE 'Executive Level'
    END AS salary_grade
FROM hr.employees;

-- =============================================================================
-- PRACTICE EXERCISES
-- =============================================================================

-- Exercise 1: Create a query that shows employee information with formatted output
-- Show: Employee ID, Full Name (Last, First), Email in lowercase, 
--       Hire Date formatted as 'Month DD, YYYY', Years of Service (rounded to 1 decimal)

-- Your solution here:


-- Exercise 2: Create a product price analysis query
-- Show: Product Name, Current Price, Price with 8.5% tax, 
--       15% markup price, Price category (Budget/Standard/Premium based on price ranges)

-- Your solution here:


-- Exercise 3: Create a customer contact information query
-- Show: Customer Name (proper case), Complete Address (street, city, state, country),
--       Phone (if available, otherwise 'Not provided'), Email domain (part after @)

-- Your solution here:


-- Exercise 4: Create an employee compensation analysis
-- Show: Employee Name, Department ID, Base Salary, Commission (if any),
--       Total Compensation, Tax Estimate (25% of total compensation)

-- Your solution here:


-- =============================================================================
-- PERFORMANCE TIPS
-- =============================================================================

-- Tip 1: Always specify column names instead of SELECT *
-- Good:
SELECT employee_id, first_name, last_name FROM hr.employees;

-- Avoid in production:
-- SELECT * FROM hr.employees;

-- Tip 2: Use table aliases for readability in complex queries
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM hr.employees e;

-- Tip 3: Be careful with functions in SELECT - they execute for every row
-- This is fine for small result sets:
SELECT employee_id, UPPER(first_name) FROM hr.employees;

-- Tip 4: Use appropriate data types in expressions
-- Oracle automatically converts, but explicit conversion is clearer:
SELECT 
    employee_id,
    TO_CHAR(salary, '$99,999.00') AS formatted_salary
FROM hr.employees;

-- =============================================================================
-- COMMON MISTAKES TO AVOID
-- =============================================================================

-- Mistake 1: Using double quotes for strings (use single quotes)
-- Wrong: SELECT "Hello World" FROM dual;
-- Correct:
SELECT 'Hello World' FROM dual;

-- Mistake 2: Forgetting to handle NULL values in calculations
-- This will return NULL if commission_pct is NULL:
-- SELECT salary + (salary * commission_pct) FROM hr.employees;

-- Correct approach:
SELECT salary + (salary * NVL(commission_pct, 0)) AS total FROM hr.employees;

-- Mistake 3: Not using meaningful aliases
-- Poor readability:
SELECT first_name || ' ' || last_name FROM hr.employees;

-- Better:
SELECT first_name || ' ' || last_name AS full_name FROM hr.employees;

-- =============================================================================
-- END OF SELECT STATEMENTS PRACTICE
-- =============================================================================

-- Next: Practice with WHERE clause filtering (where-filtering.sql)