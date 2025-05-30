-- Lesson 3.3: ORDER BY Sorting Practice
-- Oracle Database Learning Project
-- File: sorting-examples.sql

-- This file contains practical examples and exercises for ORDER BY sorting
-- Run these queries after setting up the HR and SALES sample schemas

-- =============================================================================
-- BASIC SORTING CONCEPTS
-- =============================================================================

-- Example 1: Single column sorting - Ascending (default)
-- Sort employees by last name alphabetically
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY last_name;

-- Example 2: Single column sorting - Descending
-- Sort employees by salary from highest to lowest
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC;

-- Example 3: Explicit ascending sort
-- Same as Example 1, but explicitly specified
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY last_name ASC;

-- =============================================================================
-- MULTIPLE COLUMN SORTING
-- =============================================================================

-- Example 4: Multiple column sorting
-- Sort by department first, then by salary within each department
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
ORDER BY department_id, salary DESC;

-- Example 5: Mixed sort directions
-- Sort by department ascending, then salary descending
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
ORDER BY department_id ASC, salary DESC;

-- Example 6: Three-level sorting
-- Sort by department, then job_id, then salary
SELECT employee_id, first_name, last_name, department_id, job_id, salary
FROM hr.employees
ORDER BY department_id, job_id, salary DESC;

-- =============================================================================
-- SORTING BY COLUMN POSITIONS
-- =============================================================================

-- Example 7: Sort by column position numbers
-- Sort by 4th column (department_id), then 5th column (salary)
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
ORDER BY 4, 5 DESC;

-- Note: Column positions start from 1, not 0
-- Position 1 = employee_id, Position 2 = first_name, etc.

-- =============================================================================
-- SORTING BY ALIASES
-- =============================================================================

-- Example 8: Sort by column aliases
-- Create calculated columns and sort by their aliases
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    salary,
    salary * 12 AS annual_salary
FROM hr.employees
ORDER BY full_name, annual_salary DESC;

-- Example 9: Sort by complex expressions using aliases
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    CASE 
        WHEN salary < 5000 THEN 'Low'
        WHEN salary < 10000 THEN 'Medium'
        ELSE 'High'
    END AS salary_grade
FROM hr.employees
ORDER BY salary_grade, salary;

-- =============================================================================
-- HANDLING NULL VALUES IN SORTING
-- =============================================================================

-- Example 10: Default NULL handling
-- By default, NULLs appear last in ascending sort, first in descending sort
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct;

-- Example 11: NULLS FIRST
-- Force NULL values to appear first
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct NULLS FIRST;

-- Example 12: NULLS LAST
-- Force NULL values to appear last
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct DESC NULLS LAST;

-- Example 13: Multiple columns with NULL handling
SELECT employee_id, first_name, last_name, department_id, commission_pct
FROM hr.employees
ORDER BY department_id NULLS FIRST, commission_pct NULLS LAST;

-- =============================================================================
-- SORTING WITH DATE COLUMNS
-- =============================================================================

-- Example 14: Sort by date - oldest first
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date;

-- Example 15: Sort by date - newest first
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date DESC;

-- Example 16: Sort by date parts
-- Sort by hire year, then by hire month
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    hire_date,
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    EXTRACT(MONTH FROM hire_date) AS hire_month
FROM hr.employees
ORDER BY EXTRACT(YEAR FROM hire_date), EXTRACT(MONTH FROM hire_date);

-- =============================================================================
-- SORTING WITH FUNCTIONS AND EXPRESSIONS
-- =============================================================================

-- Example 17: Sort by string functions
-- Sort by length of last name, then alphabetically
SELECT employee_id, first_name, last_name, LENGTH(last_name) AS name_length
FROM hr.employees
ORDER BY LENGTH(last_name), last_name;

-- Example 18: Sort by mathematical expressions
-- Sort by total compensation (salary + commission)
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    commission_pct,
    salary + (salary * NVL(commission_pct, 0)) AS total_compensation
FROM hr.employees
ORDER BY salary + (salary * NVL(commission_pct, 0)) DESC;

-- Example 19: Sort by CASE expressions
-- Custom sort order for job titles
SELECT employee_id, first_name, last_name, job_id
FROM hr.employees
ORDER BY 
    CASE job_id
        WHEN 'AD_PRES' THEN 1
        WHEN 'AD_VP' THEN 2
        WHEN 'IT_PROG' THEN 3
        WHEN 'SA_REP' THEN 4
        ELSE 5
    END,
    last_name;

-- =============================================================================
-- WORKING WITH SALES SCHEMA
-- =============================================================================

-- Example 20: Sort products by category and price
SELECT product_id, product_name, category, price
FROM sales.products
ORDER BY category, price DESC;

-- Example 21: Sort customers by country and name
SELECT customer_id, first_name, last_name, city, country
FROM sales.customers
ORDER BY country, last_name, first_name;

-- Example 22: Sort orders by date and amount
SELECT order_id, customer_id, order_date, total_amount, status
FROM sales.orders
ORDER BY order_date DESC, total_amount DESC;

-- Example 23: Complex product sorting
-- Sort by category, then by price descending, then by name
SELECT 
    product_id,
    product_name,
    category,
    price,
    CASE 
        WHEN price < 100 THEN 'Budget'
        WHEN price < 500 THEN 'Mid-Range'
        ELSE 'Premium'
    END AS price_tier
FROM sales.products
ORDER BY category, price DESC, product_name;

-- =============================================================================
-- COMBINING SORTING WITH FILTERING
-- =============================================================================

-- Example 24: Filter and sort employees
-- Find IT employees, sort by salary descending
SELECT employee_id, first_name, last_name, job_id, salary
FROM hr.employees
WHERE job_id LIKE 'IT_%'
ORDER BY salary DESC;

-- Example 25: Filter and complex sort
-- Find employees with commission, sort by total compensation
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    commission_pct,
    salary + (salary * commission_pct) AS total_compensation
FROM hr.employees
WHERE commission_pct IS NOT NULL
ORDER BY salary + (salary * commission_pct) DESC;

-- Example 26: Filter products and sort by multiple criteria
-- Find expensive products, sort by category then price
SELECT product_id, product_name, category, price
FROM sales.products
WHERE price > 200
ORDER BY category, price DESC;

-- =============================================================================
-- SORTING WITH LIMITS (TOP-N QUERIES)
-- =============================================================================

-- Example 27: Top 5 highest paid employees
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC
FETCH FIRST 5 ROWS ONLY;

-- Example 28: Using ROWNUM for limiting (Oracle traditional method)
SELECT employee_id, first_name, last_name, salary
FROM (
    SELECT employee_id, first_name, last_name, salary
    FROM hr.employees
    ORDER BY salary DESC
)
WHERE ROWNUM <= 5;

-- Example 29: Bottom 5 salaries
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary ASC
FETCH FIRST 5 ROWS ONLY;

-- Example 30: Top 10 most expensive products
SELECT product_id, product_name, category, price
FROM sales.products
ORDER BY price DESC
FETCH FIRST 10 ROWS ONLY;

-- =============================================================================
-- ADVANCED SORTING TECHNIQUES
-- =============================================================================

-- Example 31: Custom sort order with DECODE
-- Sort employees with custom department priority
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
ORDER BY 
    DECODE(department_id, 90, 1, 60, 2, 100, 3, 4),
    last_name;

-- Example 32: Sort by substring
-- Sort by last 3 characters of last name
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY SUBSTR(last_name, -3);

-- Example 33: Sort by day of week for hire date
-- Sort by the day of week they were hired
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    TO_CHAR(hire_date, 'Day') AS hire_day
FROM hr.employees
ORDER BY TO_CHAR(hire_date, 'D');

-- =============================================================================
-- PRACTICE EXERCISES
-- =============================================================================

-- Exercise 1: Employee Ranking
-- Create a query that shows all employees sorted by:
-- 1. Department ID (ascending)
-- 2. Job ID (ascending)  
-- 3. Salary (descending)
-- 4. Last name (ascending)
-- Include: employee_id, full_name, department_id, job_id, salary

-- Your solution here:


-- Exercise 2: Product Catalog Sorting
-- Create a query that shows products sorted by:
-- 1. Category (ascending)
-- 2. Price tier (Premium, Mid-Range, Budget)
-- 3. Product name (ascending)
-- Include: product_id, product_name, category, price, price_tier

-- Your solution here:


-- Exercise 3: Customer Analysis
-- Create a query that shows customers sorted by:
-- 1. Country (ascending)
-- 2. Total orders (if available - descending)
-- 3. Last name, first name (ascending)
-- Handle NULL values appropriately

-- Your solution here:


-- Exercise 4: Complex Order Analysis
-- Create a query showing orders sorted by:
-- 1. Order year (descending)
-- 2. Status priority (Completed, Shipped, Processing, Pending, Cancelled)
-- 3. Total amount (descending)
-- Include formatted date and status priority in output

-- Your solution here:


-- =============================================================================
-- PERFORMANCE CONSIDERATIONS
-- =============================================================================

-- Performance Tip 1: Use indexes on frequently sorted columns
-- Columns used in ORDER BY should have indexes for better performance

-- Performance Tip 2: Avoid sorting by functions when possible
-- Slower (can't use index efficiently):
SELECT * FROM hr.employees ORDER BY UPPER(last_name);

-- Faster (can use index):
SELECT * FROM hr.employees ORDER BY last_name;

-- Performance Tip 3: Limit results when possible
-- Use FETCH FIRST or ROWNUM to limit results
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC
FETCH FIRST 10 ROWS ONLY;

-- Performance Tip 4: Consider sort memory usage
-- Large sorts may require more memory
-- Monitor sort operations in production environments

-- =============================================================================
-- COMMON MISTAKES TO AVOID
-- =============================================================================

-- Mistake 1: Forgetting ORDER BY in queries that need sorted results
-- SQL doesn't guarantee order without ORDER BY clause

-- Mistake 2: Using ORDER BY with column positions incorrectly
-- Wrong column position:
-- SELECT first_name, last_name FROM hr.employees ORDER BY 3;  -- Error: only 2 columns

-- Mistake 3: Not handling NULLs appropriately
-- Consider whether NULLs should be first or last in your business logic

-- Mistake 4: Overusing complex expressions in ORDER BY
-- Simple sorts are more efficient than complex calculated sorts

-- Mistake 5: Not considering case sensitivity in string sorts
-- 'Apple' comes before 'banana' in ASCII sort
-- Use UPPER() or LOWER() for case-insensitive sorting:
SELECT * FROM sales.products ORDER BY UPPER(product_name);

-- =============================================================================
-- SORT STABILITY AND DETERMINISTIC RESULTS
-- =============================================================================

-- Example 34: Ensuring deterministic sorts
-- When multiple rows have same sort values, add unique column for consistency
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC, employee_id;  -- employee_id ensures deterministic order

-- Example 35: Multiple sort criteria for stable results
SELECT product_id, product_name, category, price
FROM sales.products
ORDER BY category, price DESC, product_id;  -- product_id as tiebreaker

-- =============================================================================
-- END OF ORDER BY SORTING PRACTICE
-- =============================================================================

-- Next: Practice with aggregate functions (aggregate-examples.sql)
