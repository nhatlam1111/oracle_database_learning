-- Lesson 4.2: INNER JOINs Practice
-- Oracle Database Learning Project
-- File: inner-joins.sql

-- This file contains comprehensive examples and exercises for INNER JOINs
-- Run these queries after setting up the HR and SALES sample schemas

-- =============================================================================
-- BASIC INNER JOIN EXAMPLES
-- =============================================================================

-- Example 1: Simple Two-Table INNER JOIN
-- Get employee names with their department names
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
ORDER BY d.department_name, e.last_name;

-- Example 2: Using Different JOIN Syntax Styles
-- ANSI Standard (recommended)
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Oracle Traditional Syntax (legacy - for reference only)
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e, hr.departments d
WHERE e.department_id = d.department_id;

-- Example 3: JOIN with Additional Columns
-- Include salary and job information
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.salary,
    d.department_name,
    j.job_title
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.jobs j ON e.job_id = j.job_id
ORDER BY e.salary DESC;

-- =============================================================================
-- INNER JOINS WITH FILTERING
-- =============================================================================

-- Example 4: JOIN with WHERE Clause
-- Find employees in IT department with salary > 5000
SELECT 
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE d.department_name = 'IT'
  AND e.salary > 5000
ORDER BY e.salary DESC;

-- Example 5: JOIN with Date Filtering
-- Employees hired after 2005 with their department info
SELECT 
    e.first_name,
    e.last_name,
    e.hire_date,
    d.department_name,
    j.job_title
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.jobs j ON e.job_id = j.job_id
WHERE e.hire_date >= DATE '2005-01-01'
ORDER BY e.hire_date;

-- Example 6: JOIN with Pattern Matching
-- Find employees whose department name contains 'Sales'
SELECT 
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE d.department_name LIKE '%Sales%'
ORDER BY e.salary DESC;

-- =============================================================================
-- MULTIPLE TABLE INNER JOINS
-- =============================================================================

-- Example 7: Three-Table JOIN
-- Employee, Department, and Location information
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city,
    l.state_province
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id
ORDER BY l.city, d.department_name, e.last_name;

-- Example 8: Four-Table JOIN
-- Complete geographic hierarchy
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city,
    c.country_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id
INNER JOIN hr.countries c ON l.country_id = c.country_id
ORDER BY c.country_name, l.city, e.last_name;

-- Example 9: Five-Table JOIN with Job Information
-- Most comprehensive employee information
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    j.job_title,
    d.department_name,
    l.city,
    c.country_name,
    e.salary,
    e.hire_date
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.jobs j ON e.job_id = j.job_id
INNER JOIN hr.locations l ON d.location_id = l.location_id
INNER JOIN hr.countries c ON l.country_id = c.country_id
ORDER BY c.country_name, l.city, d.department_name, e.last_name;

-- =============================================================================
-- SELF JOINS
-- =============================================================================

-- Example 10: Basic Self JOIN - Employee and Manager
-- Show employees with their direct managers
SELECT 
    emp.employee_id,
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.job_id AS employee_job,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    mgr.job_id AS manager_job
FROM hr.employees emp
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY mgr.last_name, emp.last_name;

-- Example 11: Self JOIN with Department Information
-- Employees, their managers, and department details
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.salary AS employee_salary,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    mgr.salary AS manager_salary,
    d.department_name
FROM hr.employees emp
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id
INNER JOIN hr.departments d ON emp.department_id = d.department_id
ORDER BY d.department_name, mgr.last_name, emp.last_name;

-- Example 12: Self JOIN for Salary Comparisons
-- Find employees who earn more than their managers
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.salary AS employee_salary,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    mgr.salary AS manager_salary,
    (emp.salary - mgr.salary) AS salary_difference
FROM hr.employees emp
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id
WHERE emp.salary > mgr.salary
ORDER BY salary_difference DESC;

-- =============================================================================
-- SALES SCHEMA INNER JOINS
-- =============================================================================

-- Example 13: Customer and Order Information
-- Basic customer-order relationship
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    o.order_id,
    o.order_date,
    o.total_amount,
    o.status
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id
ORDER BY o.order_date DESC, c.last_name;

-- Example 14: Complete Order Details
-- Customer, Order, and Product information
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_id,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
INNER JOIN sales.products p ON oi.product_id = p.product_id
ORDER BY o.order_date DESC, o.order_id, p.product_name;

-- Example 15: Product Sales Analysis
-- Products with their sales performance
SELECT 
    p.product_name,
    p.category,
    p.price AS list_price,
    COUNT(oi.order_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold,
    AVG(oi.unit_price) AS avg_selling_price,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM sales.products p
INNER JOIN sales.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY total_revenue DESC;

-- =============================================================================
-- INNER JOINS WITH AGGREGATE FUNCTIONS
-- =============================================================================

-- Example 16: Department Statistics
-- Employee counts and salary statistics by department
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    AVG(e.salary) AS avg_salary,
    SUM(e.salary) AS total_payroll
FROM hr.departments d
INNER JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_payroll DESC;

-- Example 17: Job Title Analysis
-- Salary ranges by job title with location information
SELECT 
    j.job_title,
    c.country_name,
    COUNT(e.employee_id) AS employee_count,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    AVG(e.salary) AS avg_salary
FROM hr.employees e
INNER JOIN hr.jobs j ON e.job_id = j.job_id
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id
INNER JOIN hr.countries c ON l.country_id = c.country_id
GROUP BY j.job_id, j.job_title, c.country_id, c.country_name
HAVING COUNT(e.employee_id) >= 2
ORDER BY avg_salary DESC;

-- Example 18: Customer Order Summary
-- Customer purchasing behavior analysis
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    c.country,
    COUNT(o.order_id) AS total_orders,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS latest_order,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.country
HAVING COUNT(o.order_id) >= 2
ORDER BY total_spent DESC;

-- =============================================================================
-- ADVANCED INNER JOIN TECHNIQUES
-- =============================================================================

-- Example 19: JOIN with Calculated Fields
-- Employee compensation analysis with calculated fields
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    j.job_title,
    e.salary,
    NVL(e.commission_pct, 0) AS commission_rate,
    e.salary + (e.salary * NVL(e.commission_pct, 0)) AS total_compensation,
    CASE 
        WHEN e.salary < 5000 THEN 'Entry Level'
        WHEN e.salary < 10000 THEN 'Mid Level'
        WHEN e.salary < 15000 THEN 'Senior Level'
        ELSE 'Executive Level'
    END AS salary_grade
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.jobs j ON e.job_id = j.job_id
ORDER BY total_compensation DESC;

-- Example 20: JOIN with Date Functions
-- Employee tenure analysis
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    e.hire_date,
    ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12, 1) AS years_of_service,
    CASE 
        WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12 < 2 THEN 'New Employee'
        WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12 < 5 THEN 'Experienced'
        WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12 < 10 THEN 'Senior'
        ELSE 'Veteran'
    END AS experience_level
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
ORDER BY years_of_service DESC;

-- Example 21: Complex Business Logic with JOINs
-- Find high-performing employees (above department average salary)
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    d.department_name,
    e.salary,
    dept_avg.avg_dept_salary,
    ROUND(((e.salary - dept_avg.avg_dept_salary) / dept_avg.avg_dept_salary) * 100, 2) AS salary_above_avg_pct
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN (
    SELECT 
        department_id,
        AVG(salary) AS avg_dept_salary
    FROM hr.employees
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_dept_salary
ORDER BY salary_above_avg_pct DESC;

-- =============================================================================
-- PERFORMANCE OPTIMIZATION EXAMPLES
-- =============================================================================

-- Example 22: Efficient JOIN with Early Filtering
-- Filter before joining for better performance
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    e.salary
FROM (
    SELECT employee_id, first_name, last_name, department_id, salary
    FROM hr.employees
    WHERE salary > 10000  -- Filter early
) e
INNER JOIN hr.departments d ON e.department_id = d.department_id
ORDER BY e.salary DESC;

-- Example 23: Using EXISTS instead of JOIN for existence checking
-- Sometimes EXISTS is more efficient than JOIN
SELECT 
    d.department_name,
    d.location_id
FROM hr.departments d
WHERE EXISTS (
    SELECT 1 
    FROM hr.employees e 
    WHERE e.department_id = d.department_id
      AND e.salary > 8000
);

-- Example 24: JOIN with Proper Indexing Hints
-- Use hints when you know the optimal execution plan
SELECT /*+ USE_NL(e d) INDEX(e EMP_DEPARTMENT_IX) */
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.department_id IN (10, 20, 30);

-- =============================================================================
-- PRACTICE EXERCISES
-- =============================================================================

-- Exercise 1: Complete Employee Profile
-- Create a comprehensive employee profile showing:
-- - Employee details (name, ID, email, hire date)
-- - Job information (title, salary grade based on job min/max salary)
-- - Department and location details
-- - Manager information
-- - Years of service and experience level
-- Only include employees hired after 2003

-- Your solution here:


-- Exercise 2: Sales Performance Dashboard
-- Create a sales analysis showing:
-- - Product name and category
-- - Number of orders containing the product
-- - Total quantity sold and revenue generated
-- - Average selling price vs list price
-- - Customer countries that bought the product
-- - Best selling month for each product
-- Only include products that have been sold at least 3 times

-- Your solution here:


-- Exercise 3: Organizational Analysis
-- Create an organizational chart showing:
-- - Manager name and their department
-- - Number of direct reports
-- - Total team size (including indirect reports)
-- - Average team salary and experience level
-- - Geographic distribution of team members
-- - Department performance metrics
-- Only include managers with at least 2 direct reports

-- Your solution here:


-- Exercise 4: Customer Segmentation Report
-- Create a customer analysis showing:
-- - Customer details and geographic location
-- - Order frequency and purchasing patterns
-- - Product categories preferred
-- - Average order value and total lifetime value
-- - Seasonality patterns in purchases
-- - Customer risk level (recent vs inactive)
-- Segment customers into VIP, Regular, and At-Risk categories

-- Your solution here:


-- Exercise 5: Cross-Schema Business Intelligence
-- Create a comprehensive business report combining HR and Sales data:
-- - Employee sales performance (if applicable)
-- - Department revenue contribution
-- - Geographic analysis of employees vs customers
-- - Resource allocation efficiency
-- - Growth opportunities and recommendations

-- Your solution here:


-- =============================================================================
-- ADVANCED CHALLENGES
-- =============================================================================

-- Challenge 1: Dynamic Hierarchy Reporting
-- Create a report showing the complete organizational hierarchy
-- with calculated fields for span of control and management levels

-- Your solution here:


-- Challenge 2: Product Profitability Analysis
-- Calculate product profitability considering:
-- - Sales volume and revenue
-- - Seasonal variations
-- - Customer segment preferences
-- - Geographic performance

-- Your solution here:


-- Challenge 3: Employee Career Path Analysis
-- Analyze potential career progression paths by examining:
-- - Job role relationships and typical progression
-- - Salary advancement patterns
-- - Skills and experience requirements
-- - Department transfer patterns

-- Your solution here:


-- =============================================================================
-- COMMON MISTAKES AND SOLUTIONS
-- =============================================================================

-- Mistake 1: Cartesian Product (Missing JOIN Condition)
-- Wrong:
-- SELECT e.first_name, d.department_name
-- FROM hr.employees e, hr.departments d;

-- Correct:
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Mistake 2: Ambiguous Column References
-- Wrong:
-- SELECT employee_id, department_id, department_name
-- FROM hr.employees e
-- INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Correct:
SELECT e.employee_id, d.department_id, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Mistake 3: Inefficient Multiple JOINs
-- Better to filter early and use appropriate join order
SELECT 
    e.first_name,
    d.department_name,
    l.city
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id
WHERE e.salary > 10000  -- Filter applied efficiently
  AND l.country_id = 'US';

-- =============================================================================
-- PERFORMANCE TESTING
-- =============================================================================

-- Test different JOIN approaches for performance
-- Set timing on to see execution times
SET TIMING ON;

-- Approach 1: Standard INNER JOIN
SELECT COUNT(*)
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Approach 2: Using EXISTS
SELECT COUNT(*)
FROM hr.employees e
WHERE EXISTS (
    SELECT 1 FROM hr.departments d 
    WHERE d.department_id = e.department_id
);

-- Approach 3: Traditional Oracle syntax
SELECT COUNT(*)
FROM hr.employees e, hr.departments d
WHERE e.department_id = d.department_id;

SET TIMING OFF;

-- =============================================================================
-- KEY TAKEAWAYS
-- =============================================================================

-- 1. INNER JOINs return only matching records from both tables
-- 2. Always use table aliases for readability and disambiguation
-- 3. JOIN conditions should match foreign key relationships
-- 4. Filter early (WHERE clause) for better performance
-- 5. Use appropriate indexes on JOIN columns
-- 6. Self JOINs are useful for hierarchical data
-- 7. Combine JOINs with aggregates for powerful analysis
-- 8. Consider query execution plans for optimization
-- 9. ANSI JOIN syntax is more readable than traditional Oracle syntax
-- 10. Practice with real business scenarios to master the concepts

-- =============================================================================
-- NEXT STEPS
-- =============================================================================

-- After mastering INNER JOINs, proceed to:
-- 1. OUTER JOINs (LEFT, RIGHT, FULL) - outer-joins.sql
-- 2. Advanced JOIN types (CROSS, specialized conditions)
-- 3. Subqueries and their relationship to JOINs
-- 4. Query optimization and performance tuning
-- 5. Complex business scenarios combining multiple concepts

-- =============================================================================
-- END OF INNER JOINS PRACTICE
-- =============================================================================
