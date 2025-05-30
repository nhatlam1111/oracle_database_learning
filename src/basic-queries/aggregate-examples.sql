-- Lesson 3.4: Aggregate Functions Practice
-- Oracle Database Learning Project
-- File: aggregate-examples.sql

-- This file contains practical examples and exercises for aggregate functions
-- Run these queries after setting up the HR and SALES sample schemas

-- =============================================================================
-- BASIC AGGREGATE FUNCTIONS
-- =============================================================================

-- Example 1: COUNT function - Count all rows
-- Count total number of employees
SELECT COUNT(*) AS total_employees
FROM hr.employees;

-- Example 2: COUNT with column name - Counts non-NULL values only
-- Count employees who have commission (excludes NULLs)
SELECT COUNT(commission_pct) AS employees_with_commission
FROM hr.employees;

-- Example 3: COUNT DISTINCT - Count unique values
-- Count how many different departments have employees
SELECT COUNT(DISTINCT department_id) AS number_of_departments
FROM hr.employees;

-- Example 4: SUM function - Add up numeric values
-- Calculate total salary cost for all employees
SELECT SUM(salary) AS total_salary_cost
FROM hr.employees;

-- Example 5: AVG function - Calculate average
-- Calculate average salary across all employees
SELECT AVG(salary) AS average_salary
FROM hr.employees;

-- Example 6: MIN and MAX functions
-- Find lowest and highest salaries
SELECT 
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM hr.employees;

-- Example 7: Multiple aggregates in one query
-- Comprehensive salary statistics
SELECT 
    COUNT(*) AS total_employees,
    COUNT(commission_pct) AS employees_with_commission,
    SUM(salary) AS total_salary_cost,
    AVG(salary) AS average_salary,
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary,
    STDDEV(salary) AS salary_std_deviation,
    VARIANCE(salary) AS salary_variance
FROM hr.employees;

-- =============================================================================
-- GROUP BY FUNDAMENTALS
-- =============================================================================

-- Example 8: Basic GROUP BY
-- Count employees by department
SELECT 
    department_id,
    COUNT(*) AS employee_count
FROM hr.employees
GROUP BY department_id
ORDER BY department_id;

-- Example 9: GROUP BY with multiple aggregates
-- Department salary statistics
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    SUM(salary) AS total_department_salary,
    AVG(salary) AS average_department_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary
FROM hr.employees
GROUP BY department_id
ORDER BY department_id;

-- Example 10: GROUP BY with multiple columns
-- Statistics by department and job
SELECT 
    department_id,
    job_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM hr.employees
GROUP BY department_id, job_id
ORDER BY department_id, job_id;

-- Example 11: GROUP BY with calculated columns
-- Salary statistics by hire year
SELECT 
    EXTRACT(YEAR FROM hire_date) AS hire_year,
    COUNT(*) AS employees_hired,
    AVG(salary) AS average_salary,
    MIN(hire_date) AS first_hire_date,
    MAX(hire_date) AS last_hire_date
FROM hr.employees
GROUP BY EXTRACT(YEAR FROM hire_date)
ORDER BY hire_year;

-- =============================================================================
-- HAVING CLAUSE FOR FILTERING GROUPS
-- =============================================================================

-- Example 12: Basic HAVING clause
-- Find departments with more than 5 employees
SELECT 
    department_id,
    COUNT(*) AS employee_count
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 5
ORDER BY employee_count DESC;

-- Example 13: HAVING with multiple conditions
-- Find departments with more than 3 employees AND average salary > 6000
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM hr.employees
GROUP BY department_id
HAVING COUNT(*) > 3 AND AVG(salary) > 6000
ORDER BY average_salary DESC;

-- Example 14: HAVING vs WHERE
-- WHERE filters rows before grouping, HAVING filters groups after grouping

-- This filters employees first, then groups:
SELECT 
    department_id,
    COUNT(*) AS high_earners_count,
    AVG(salary) AS average_salary
FROM hr.employees
WHERE salary > 5000  -- Filter individual employees
GROUP BY department_id
HAVING COUNT(*) >= 2  -- Filter the resulting groups
ORDER BY average_salary DESC;

-- =============================================================================
-- WORKING WITH SALES SCHEMA
-- =============================================================================

-- Example 15: Product statistics by category
SELECT 
    category,
    COUNT(*) AS product_count,
    AVG(price) AS average_price,
    MIN(price) AS cheapest_price,
    MAX(price) AS most_expensive_price,
    SUM(stock_quantity) AS total_stock
FROM sales.products
GROUP BY category
ORDER BY average_price DESC;

-- Example 16: Customer statistics by country
SELECT 
    country,
    COUNT(*) AS customer_count,
    COUNT(email) AS customers_with_email,
    COUNT(phone) AS customers_with_phone
FROM sales.customers
GROUP BY country
HAVING COUNT(*) >= 5  -- Only countries with 5+ customers
ORDER BY customer_count DESC;

-- Example 17: Order analysis by status
SELECT 
    status,
    COUNT(*) AS order_count,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS average_order_value,
    MIN(total_amount) AS smallest_order,
    MAX(total_amount) AS largest_order
FROM sales.orders
GROUP BY status
ORDER BY total_revenue DESC;

-- Example 18: Monthly order analysis
SELECT 
    EXTRACT(YEAR FROM order_date) AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    COUNT(*) AS orders_count,
    SUM(total_amount) AS monthly_revenue,
    AVG(total_amount) AS average_order_value
FROM sales.orders
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY order_year, order_month;

-- =============================================================================
-- ADVANCED AGGREGATE TECHNIQUES
-- =============================================================================

-- Example 19: Conditional aggregation with CASE
-- Count employees by salary ranges
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(CASE WHEN salary < 5000 THEN 1 END) AS low_salary_count,
    COUNT(CASE WHEN salary BETWEEN 5000 AND 10000 THEN 1 END) AS mid_salary_count,
    COUNT(CASE WHEN salary > 10000 THEN 1 END) AS high_salary_count
FROM hr.employees
GROUP BY department_id
ORDER BY department_id;

-- Example 20: Percentage calculations
-- Calculate commission percentage by department
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(commission_pct) AS employees_with_commission,
    ROUND(COUNT(commission_pct) * 100.0 / COUNT(*), 2) AS commission_percentage
FROM hr.employees
GROUP BY department_id
ORDER BY commission_percentage DESC;

-- Example 21: Using FILTER clause (Oracle 12c+)
-- Alternative to CASE for conditional aggregation
SELECT 
    department_id,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE salary < 5000) AS low_salary_count,
    COUNT(*) FILTER (WHERE salary BETWEEN 5000 AND 10000) AS mid_salary_count,
    COUNT(*) FILTER (WHERE salary > 10000) AS high_salary_count
FROM hr.employees
GROUP BY department_id
ORDER BY department_id;

-- Example 22: String aggregation with LISTAGG
-- List all job IDs in each department
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    LISTAGG(job_id, ', ') WITHIN GROUP (ORDER BY job_id) AS job_list
FROM hr.employees
GROUP BY department_id
ORDER BY department_id;

-- =============================================================================
-- ANALYTICAL FUNCTIONS WITH AGGREGATES
-- =============================================================================

-- Example 23: ROLLUP for subtotals
-- Department totals with grand total
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    SUM(salary) AS total_salary
FROM hr.employees
GROUP BY ROLLUP(department_id)
ORDER BY department_id NULLS LAST;

-- Example 24: CUBE for cross-tabulation
-- Totals by department and job combinations
SELECT 
    department_id,
    job_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM hr.employees
GROUP BY CUBE(department_id, job_id)
ORDER BY department_id NULLS LAST, job_id NULLS LAST;

-- Example 25: GROUPING SETS for custom groupings
-- Multiple grouping combinations in one query
SELECT 
    department_id,
    job_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary
FROM hr.employees
GROUP BY GROUPING SETS (
    (department_id),      -- Group by department only
    (job_id),            -- Group by job only  
    (department_id, job_id), -- Group by both
    ()                   -- Grand total
)
ORDER BY department_id NULLS LAST, job_id NULLS LAST;

-- =============================================================================
-- COMBINING AGGREGATES WITH JOINS
-- =============================================================================

-- Example 26: Aggregates with table joins
-- Department statistics with department names
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    SUM(e.salary) AS total_salary
FROM hr.departments d
LEFT JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC;

-- =============================================================================
-- NESTED AGGREGATES AND SUBQUERIES
-- =============================================================================

-- Example 27: Using aggregates in subqueries
-- Find departments with above-average salaries
SELECT 
    department_id,
    AVG(salary) AS dept_average_salary
FROM hr.employees
GROUP BY department_id
HAVING AVG(salary) > (
    SELECT AVG(salary) FROM hr.employees
)
ORDER BY dept_average_salary DESC;

-- Example 28: Ranking departments by average salary
SELECT 
    department_id,
    employee_count,
    average_salary,
    RANK() OVER (ORDER BY average_salary DESC) AS salary_rank
FROM (
    SELECT 
        department_id,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary
    FROM hr.employees
    GROUP BY department_id
);

-- =============================================================================
-- PRACTICE EXERCISES
-- =============================================================================

-- Exercise 1: Employee Analysis by Department
-- Create a comprehensive department analysis showing:
-- - Department ID and name (use join)
-- - Total employees
-- - Employees with and without commission
-- - Average, minimum, and maximum salary
-- - Total payroll cost
-- - Only show departments with more than 2 employees

-- Your solution here:


-- Exercise 2: Product Category Performance
-- Analyze product categories showing:
-- - Category name
-- - Number of products
-- - Price statistics (min, max, average)
-- - Total inventory value (price * stock_quantity)
-- - Products in different price ranges (budget <100, mid 100-500, premium >500)
-- Sort by total inventory value descending

-- Your solution here:


-- Exercise 3: Customer Order Analysis
-- Create a customer behavior analysis showing:
-- - Customer country
-- - Number of customers
-- - Number of orders placed
-- - Total revenue generated
-- - Average order value
-- - Only include countries with at least 3 customers
-- Sort by total revenue descending

-- Your solution here:


-- Exercise 4: Time-Based Sales Analysis
-- Create a quarterly sales report showing:
-- - Year and quarter
-- - Number of orders
-- - Total revenue
-- - Average order value
-- - Growth compared to previous quarter (if possible)
-- Include only completed orders

-- Your solution here:


-- Exercise 5: Employee Tenure Analysis
-- Analyze employee tenure by creating groups:
-- - Tenure groups: 0-2 years, 2-5 years, 5-10 years, 10+ years
-- - Count of employees in each group
-- - Average salary for each group
-- - Department distribution within each group
-- Use CASE statements for grouping

-- Your solution here:


-- =============================================================================
-- PERFORMANCE OPTIMIZATION TIPS
-- =============================================================================

-- Tip 1: Use indexes on GROUP BY columns
-- Columns frequently used in GROUP BY should have indexes

-- Tip 2: Consider partitioning for large tables
-- Partition pruning can significantly improve aggregate performance

-- Tip 3: Use appropriate data types
-- Smaller data types aggregate faster than larger ones

-- Tip 4: Avoid unnecessary DISTINCT in aggregates
-- COUNT(DISTINCT column) is more expensive than COUNT(*)

-- Tip 5: Use HAVING efficiently
-- HAVING conditions should be as selective as possible

-- =============================================================================
-- COMMON MISTAKES TO AVOID
-- =============================================================================

-- Mistake 1: Using non-aggregated columns without GROUP BY
-- This will cause an error:
-- SELECT department_id, COUNT(*) FROM hr.employees;

-- Correct version:
SELECT department_id, COUNT(*) FROM hr.employees GROUP BY department_id;

-- Mistake 2: Confusing WHERE and HAVING
-- WHERE filters rows before grouping
-- HAVING filters groups after aggregation

-- Mistake 3: Not handling NULLs in aggregates
-- COUNT(*) counts all rows including NULLs
-- COUNT(column) counts only non-NULL values
-- SUM(), AVG(), MIN(), MAX() ignore NULLs

-- Mistake 4: Forgetting about empty groups
-- LEFT JOIN with GROUP BY can create groups with zero counts
-- Be aware of this when interpreting results

-- Mistake 5: Using aggregates in WHERE clause
-- This is wrong:
-- SELECT * FROM hr.employees WHERE COUNT(*) > 5;

-- Use HAVING for aggregate conditions:
-- SELECT department_id FROM hr.employees GROUP BY department_id HAVING COUNT(*) > 5;

-- =============================================================================
-- AGGREGATE FUNCTION REFERENCE
-- =============================================================================

-- Basic Aggregates:
-- COUNT(*) - Count all rows
-- COUNT(column) - Count non-NULL values
-- COUNT(DISTINCT column) - Count unique non-NULL values
-- SUM(column) - Sum of all non-NULL values
-- AVG(column) - Average of all non-NULL values
-- MIN(column) - Minimum value
-- MAX(column) - Maximum value

-- Statistical Aggregates:
-- STDDEV(column) - Standard deviation
-- VARIANCE(column) - Variance
-- MEDIAN(column) - Median value

-- String Aggregates:
-- LISTAGG(column, delimiter) - Concatenate values

-- Advanced Grouping:
-- ROLLUP - Hierarchical subtotals
-- CUBE - Cross-tabulation
-- GROUPING SETS - Custom grouping combinations

-- =============================================================================
-- END OF AGGREGATE FUNCTIONS PRACTICE
-- =============================================================================

-- Next: Proceed to Lesson 4 for intermediate SQL concepts (Joins and Subqueries)
