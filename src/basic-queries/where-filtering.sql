-- Lesson 3.2: WHERE Clause Filtering Practice
-- Oracle Database Learning Project
-- File: where-filtering.sql

-- This file contains practical examples and exercises for WHERE clause filtering
-- Run these queries after setting up the HR and SALES sample schemas

-- =============================================================================
-- BASIC COMPARISON OPERATORS
-- =============================================================================

-- Example 1: Equality operator (=)
-- Find employees in department 60
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id = 60;

-- Example 2: Inequality operators (!= or <>)
-- Find employees NOT in department 60
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id != 60;

-- Alternative syntax:
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id <> 60;

-- Example 3: Comparison operators (<, >, <=, >=)
-- Find employees with salary greater than 10000
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary > 10000;

-- Find employees with salary less than or equal to 5000
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary <= 5000;

-- Example 4: Date comparisons
-- Find employees hired after January 1, 2005
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date > DATE '2005-01-01';

-- Find employees hired in 2007
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date >= DATE '2007-01-01' 
  AND hire_date < DATE '2008-01-01';

-- =============================================================================
-- LOGICAL OPERATORS (AND, OR, NOT)
-- =============================================================================

-- Example 5: AND operator
-- Find employees in department 60 with salary > 5000
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
WHERE department_id = 60 AND salary > 5000;

-- Example 6: OR operator
-- Find employees in department 60 OR 90
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id = 60 OR department_id = 90;

-- Example 7: NOT operator
-- Find employees NOT in department 60
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE NOT (department_id = 60);

-- Example 8: Complex logical combinations
-- Find employees in departments 60 or 90 with salary > 6000
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
WHERE (department_id = 60 OR department_id = 90) 
  AND salary > 6000;

-- =============================================================================
-- RANGE FILTERING WITH BETWEEN
-- =============================================================================

-- Example 9: BETWEEN operator for numeric ranges
-- Find employees with salary between 5000 and 10000 (inclusive)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary BETWEEN 5000 AND 10000;

-- Equivalent to:
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary >= 5000 AND salary <= 10000;

-- Example 10: NOT BETWEEN
-- Find employees with salary NOT between 5000 and 10000
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary NOT BETWEEN 5000 AND 10000;

-- Example 11: BETWEEN with dates
-- Find employees hired between 2005 and 2007
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date BETWEEN DATE '2005-01-01' AND DATE '2007-12-31';

-- =============================================================================
-- LIST FILTERING WITH IN AND NOT IN
-- =============================================================================

-- Example 12: IN operator
-- Find employees in specific departments
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id IN (10, 20, 30);

-- Equivalent to:
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id = 10 OR department_id = 20 OR department_id = 30;

-- Example 13: NOT IN operator
-- Find employees NOT in specific departments
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id NOT IN (10, 20, 30);

-- Example 14: IN with strings
-- Find employees with specific job IDs
SELECT employee_id, first_name, last_name, job_id
FROM hr.employees
WHERE job_id IN ('IT_PROG', 'SA_REP', 'ST_CLERK');

-- =============================================================================
-- PATTERN MATCHING WITH LIKE
-- =============================================================================

-- Example 15: Basic LIKE patterns
-- Find employees whose first name starts with 'S'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE 'S%';

-- Find employees whose last name ends with 'son'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE last_name LIKE '%son';

-- Find employees whose first name contains 'an'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE '%an%';

-- Example 16: Single character wildcards
-- Find employees with first name like 'J_n' (Jon, Jan, Jin, etc.)
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE 'J_n';

-- Example 17: NOT LIKE
-- Find employees whose last name does NOT start with 'S'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE last_name NOT LIKE 'S%';

-- Example 18: Case-sensitive vs case-insensitive searches
-- Case-sensitive (exact match)
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE 'steven';

-- Case-insensitive using UPPER
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE UPPER(first_name) LIKE 'STEVEN';

-- =============================================================================
-- NULL VALUE HANDLING
-- =============================================================================

-- Example 19: IS NULL
-- Find employees without commission
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
WHERE commission_pct IS NULL;

-- Example 20: IS NOT NULL
-- Find employees with commission
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
WHERE commission_pct IS NOT NULL;

-- Example 21: Important note about NULL comparisons
-- This will NOT work (returns no results even if commission_pct has NULL values):
-- SELECT * FROM hr.employees WHERE commission_pct = NULL;

-- This is correct:
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
WHERE commission_pct IS NULL;

-- =============================================================================
-- WORKING WITH SALES SCHEMA
-- =============================================================================

-- Example 22: Product filtering
-- Find products in specific categories
SELECT product_id, product_name, category, price
FROM sales.products
WHERE category IN ('Electronics', 'Books', 'Clothing');

-- Find expensive products
SELECT product_id, product_name, category, price
FROM sales.products
WHERE price > 500;

-- Example 23: Customer filtering
-- Find customers from specific countries
SELECT customer_id, first_name, last_name, country
FROM sales.customers
WHERE country IN ('USA', 'Canada', 'UK');

-- Find customers with email addresses
SELECT customer_id, first_name, last_name, email
FROM sales.customers
WHERE email IS NOT NULL;

-- Example 24: Order filtering
-- Find recent orders
SELECT order_id, customer_id, order_date, status, total_amount
FROM sales.orders
WHERE order_date >= DATE '2024-01-01';

-- Find large orders
SELECT order_id, customer_id, order_date, total_amount
FROM sales.orders
WHERE total_amount > 1000;

-- Find orders with specific status
SELECT order_id, customer_id, order_date, status
FROM sales.orders
WHERE status IN ('Pending', 'Processing');

-- =============================================================================
-- COMPLEX FILTERING EXAMPLES
-- =============================================================================

-- Example 25: Multiple conditions with different operators
-- Find senior, well-paid IT employees
SELECT employee_id, first_name, last_name, job_id, salary, hire_date
FROM hr.employees
WHERE job_id LIKE 'IT_%'
  AND salary > 6000
  AND hire_date < DATE '2006-01-01';

-- Example 26: Complex business logic
-- Find employees eligible for bonus (hired before 2006, salary < 8000, has commission)
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary, 
    commission_pct, 
    hire_date
FROM hr.employees
WHERE hire_date < DATE '2006-01-01'
  AND salary < 8000
  AND commission_pct IS NOT NULL;

-- Example 27: String pattern combinations
-- Find products with 'Pro' in name or description, not in 'Basic' category
SELECT product_id, product_name, category, price
FROM sales.products
WHERE (product_name LIKE '%Pro%' OR description LIKE '%Pro%')
  AND category NOT LIKE '%Basic%';

-- =============================================================================
-- PRACTICE EXERCISES
-- =============================================================================

-- Exercise 1: Employee Analysis
-- Find all employees who:
-- - Work in departments 20, 50, or 80
-- - Have salary between 3000 and 12000
-- - Were hired after 2005
-- - Have a first name starting with 'A', 'S', or 'J'

-- Your solution here:


-- Exercise 2: Product Search
-- Find all products that:
-- - Are in 'Electronics' or 'Computers' category
-- - Have price less than 800 or greater than 1500
-- - Product name contains 'Pro' or 'Max'
-- - Are currently in stock (stock_quantity > 0)

-- Your solution here:


-- Exercise 3: Customer Segmentation
-- Find customers who:
-- - Live in 'USA', 'Canada', or 'Australia'
-- - Have provided an email address
-- - Have a phone number starting with '+1' or '+61'
-- - Last name does not start with 'X', 'Y', or 'Z'

-- Your solution here:


-- Exercise 4: Order Analysis
-- Find orders that:
-- - Were placed in 2024
-- - Have total amount between 100 and 2000
-- - Status is NOT 'Cancelled' or 'Refunded'
-- - Customer ID is less than 1000

-- Your solution here:


-- =============================================================================
-- PERFORMANCE TIPS
-- =============================================================================

-- Tip 1: Use indexes for better performance on filtered columns
-- Commonly filtered columns should have indexes

-- Tip 2: Avoid functions on columns in WHERE clause when possible
-- Slower:
SELECT * FROM hr.employees WHERE UPPER(first_name) = 'JOHN';

-- Faster (if you know the exact case):
SELECT * FROM hr.employees WHERE first_name = 'John';

-- Tip 3: Use specific conditions before general ones
-- Oracle processes conditions left to right, put most selective first
SELECT * FROM hr.employees 
WHERE employee_id = 100  -- Very specific
  AND department_id = 60; -- Less specific

-- Tip 4: Be careful with NOT IN when NULLs are possible
-- This might not work as expected if department_id contains NULLs:
-- SELECT * FROM hr.employees WHERE department_id NOT IN (SELECT department_id FROM some_table);

-- Better approach:
SELECT * FROM hr.employees 
WHERE department_id NOT IN (
    SELECT department_id 
    FROM some_table 
    WHERE department_id IS NOT NULL
);

-- =============================================================================
-- COMMON MISTAKES TO AVOID
-- =============================================================================

-- Mistake 1: Incorrect NULL handling
-- Wrong: WHERE commission_pct = NULL
-- Correct: WHERE commission_pct IS NULL

-- Mistake 2: Missing parentheses in complex conditions
-- This might not work as expected:
-- WHERE salary > 5000 OR department_id = 60 AND job_id = 'IT_PROG'

-- Clear with parentheses:
-- WHERE salary > 5000 OR (department_id = 60 AND job_id = 'IT_PROG')

-- Mistake 3: Inefficient LIKE patterns
-- Avoid leading wildcards when possible (they can't use indexes efficiently):
-- WHERE last_name LIKE '%son'  -- Slower

-- Prefer trailing wildcards:
-- WHERE last_name LIKE 'John%'  -- Faster

-- Mistake 4: Not considering case sensitivity
-- Oracle is case-sensitive by default
-- WHERE first_name = 'john'  -- Won't match 'John'
-- WHERE UPPER(first_name) = 'JOHN'  -- Will match 'John', 'JOHN', 'john'

-- =============================================================================
-- END OF WHERE CLAUSE FILTERING PRACTICE
-- =============================================================================

-- Next: Practice with ORDER BY sorting (sorting-examples.sql)
