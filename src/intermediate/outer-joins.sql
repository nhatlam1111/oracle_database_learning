-- =====================================================
-- OUTER JOINS PRACTICE - Oracle Database Learning
-- =====================================================
-- This file provides comprehensive practice with Oracle outer joins
-- including LEFT, RIGHT, FULL OUTER JOINs and Oracle's (+) syntax

-- =====================================================
-- SECTION 1: LEFT OUTER JOIN EXAMPLES
-- =====================================================

-- Basic LEFT JOIN: All employees with their department names
-- Shows employees even if they don't have a department assigned
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
ORDER BY e.employee_id;

-- LEFT JOIN with NULL handling
-- Display "Unassigned" for employees without departments
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    NVL(d.department_name, 'Unassigned') AS department_name,
    NVL2(d.department_id, 'Assigned', 'Needs Assignment') AS assignment_status
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_name NULLS LAST, e.last_name;

-- Complex LEFT JOIN: Employees with location information
-- Shows all employees even if location data is missing
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    NVL(d.department_name, 'No Department') AS department,
    NVL(l.city, 'Unknown') AS city,
    NVL(l.state_province, 'Unknown') AS state,
    NVL(c.country_name, 'Unknown') AS country
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
LEFT JOIN countries c ON l.country_id = c.country_id
ORDER BY e.employee_id;

-- LEFT JOIN with aggregation
-- Count of employees per department (including departments with 0 employees)
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MIN(e.hire_date) AS earliest_hire,
    MAX(e.hire_date) AS latest_hire
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC, d.department_name;

-- =====================================================
-- SECTION 2: RIGHT OUTER JOIN EXAMPLES
-- =====================================================

-- Basic RIGHT JOIN: All departments with their employees
-- Shows departments even if they have no employees
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_id,
    d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
ORDER BY d.department_id, e.employee_id;

-- RIGHT JOIN to find empty departments
SELECT 
    d.department_id,
    d.department_name,
    d.manager_id,
    CASE 
        WHEN e.employee_id IS NULL THEN 'Empty Department'
        ELSE 'Has Employees'
    END AS department_status
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id IS NULL
ORDER BY d.department_name;

-- RIGHT JOIN with multiple conditions
-- All departments with high-salary employees (or no employees)
SELECT 
    d.department_id,
    d.department_name,
    e.employee_id,
    e.first_name,
    e.salary,
    CASE 
        WHEN e.salary IS NULL THEN 'No Employees'
        WHEN e.salary >= 10000 THEN 'High Salary Employee'
        ELSE 'Regular Employee'
    END AS salary_category
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id 
    AND e.salary >= 10000  -- Additional condition in JOIN
ORDER BY d.department_name, e.salary DESC NULLS LAST;

-- =====================================================
-- SECTION 3: FULL OUTER JOIN EXAMPLES
-- =====================================================

-- Basic FULL OUTER JOIN: Complete employee-department picture
SELECT 
    COALESCE(e.employee_id, 0) AS employee_id,
    COALESCE(e.first_name, 'N/A') AS first_name,
    COALESCE(e.last_name, 'N/A') AS last_name,
    COALESCE(d.department_id, 0) AS department_id,
    COALESCE(d.department_name, 'N/A') AS department_name,
    CASE 
        WHEN e.employee_id IS NULL THEN 'Empty Department'
        WHEN d.department_id IS NULL THEN 'Unassigned Employee'
        ELSE 'Matched'
    END AS match_status
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id
ORDER BY match_status, d.department_name, e.last_name;

-- FULL OUTER JOIN for data reconciliation
-- Compare actual employees vs budgeted headcount by department
WITH department_budget AS (
    SELECT 1 AS department_id, 5 AS budgeted_headcount FROM dual UNION ALL
    SELECT 2, 8 FROM dual UNION ALL
    SELECT 3, 12 FROM dual UNION ALL
    SELECT 4, 6 FROM dual UNION ALL
    SELECT 5, 15 FROM dual UNION ALL
    SELECT 6, 4 FROM dual
),
actual_headcount AS (
    SELECT 
        department_id,
        COUNT(*) AS actual_count
    FROM employees
    WHERE department_id IS NOT NULL
    GROUP BY department_id
)
SELECT 
    COALESCE(d.department_name, 'Unknown Dept') AS department_name,
    COALESCE(b.budgeted_headcount, 0) AS budgeted,
    COALESCE(a.actual_count, 0) AS actual,
    COALESCE(a.actual_count, 0) - COALESCE(b.budgeted_headcount, 0) AS variance,
    CASE 
        WHEN b.budgeted_headcount IS NULL THEN 'Not in Budget'
        WHEN a.actual_count IS NULL THEN 'No Employees'
        WHEN a.actual_count > b.budgeted_headcount THEN 'Over Budget'
        WHEN a.actual_count < b.budgeted_headcount THEN 'Under Budget'
        ELSE 'On Target'
    END AS status
FROM department_budget b
FULL OUTER JOIN actual_headcount a ON b.department_id = a.department_id
FULL OUTER JOIN departments d ON COALESCE(b.department_id, a.department_id) = d.department_id
ORDER BY variance DESC;

-- =====================================================
-- SECTION 4: ORACLE (+) SYNTAX EXAMPLES
-- =====================================================

-- Oracle traditional LEFT OUTER JOIN syntax
-- Find all employees with department info (using (+) operator)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e, departments d
WHERE e.department_id = d.department_id(+)  -- (+) on the optional side
ORDER BY e.employee_id;

-- Oracle traditional RIGHT OUTER JOIN syntax
-- Find all departments with employee info
SELECT 
    e.employee_id,
    e.first_name,
    d.department_id,
    d.department_name
FROM employees e, departments d
WHERE e.department_id(+) = d.department_id  -- (+) on the optional side
ORDER BY d.department_id, e.employee_id;

-- Multiple table outer joins with (+) syntax
SELECT 
    e.employee_id,
    e.first_name,
    d.department_name,
    l.city
FROM employees e, departments d, locations l
WHERE e.department_id = d.department_id(+)
  AND d.location_id = l.location_id(+)
ORDER BY e.employee_id;

-- Comparison: ANSI vs Oracle syntax
-- ANSI SQL (preferred)
SELECT e.first_name, d.department_name, l.city
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
WHERE e.employee_id < 110;

-- Oracle traditional syntax (equivalent)
SELECT e.first_name, d.department_name, l.city
FROM employees e, departments d, locations l
WHERE e.department_id = d.department_id(+)
  AND d.location_id = l.location_id(+)
  AND e.employee_id < 110;

-- =====================================================
-- SECTION 5: PRACTICAL BUSINESS SCENARIOS
-- =====================================================

-- Scenario 1: Sales Report with All Products
-- Show sales data for all products, including those never sold
WITH monthly_sales AS (
    SELECT 
        oi.product_id,
        EXTRACT(YEAR FROM o.order_date) AS sales_year,
        EXTRACT(MONTH FROM o.order_date) AS sales_month,
        SUM(oi.quantity * oi.unit_price) AS monthly_revenue,
        SUM(oi.quantity) AS units_sold
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_date >= DATE '2024-01-01'
    GROUP BY oi.product_id, 
             EXTRACT(YEAR FROM o.order_date), 
             EXTRACT(MONTH FROM o.order_date)
)
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.unit_price AS list_price,
    NVL(ms.sales_year, 2024) AS year,
    NVL(ms.sales_month, 0) AS month,
    NVL(ms.monthly_revenue, 0) AS revenue,
    NVL(ms.units_sold, 0) AS units_sold,
    CASE 
        WHEN ms.product_id IS NULL THEN 'No Sales'
        WHEN ms.monthly_revenue > 10000 THEN 'High Performer'
        WHEN ms.monthly_revenue > 5000 THEN 'Medium Performer'
        ELSE 'Low Performer'
    END AS performance_category
FROM products p
LEFT JOIN monthly_sales ms ON p.product_id = ms.product_id
ORDER BY p.category, performance_category, p.product_name;

-- Scenario 2: Customer Loyalty Analysis
-- Analyze customer behavior including inactive customers
WITH customer_stats AS (
    SELECT 
        o.customer_id,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_spent,
        MIN(o.order_date) AS first_order,
        MAX(o.order_date) AS last_order,
        AVG(o.total_amount) AS avg_order_value
    FROM orders o
    GROUP BY o.customer_id
)
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    c.registration_date,
    NVL(cs.total_orders, 0) AS order_count,
    NVL(cs.total_spent, 0) AS lifetime_value,
    cs.first_order,
    cs.last_order,
    NVL(cs.avg_order_value, 0) AS avg_order,
    CASE 
        WHEN cs.customer_id IS NULL THEN 'Never Ordered'
        WHEN cs.last_order >= SYSDATE - 30 THEN 'Active'
        WHEN cs.last_order >= SYSDATE - 90 THEN 'Recent'
        WHEN cs.last_order >= SYSDATE - 365 THEN 'Dormant'
        ELSE 'Inactive'
    END AS customer_status,
    CASE 
        WHEN cs.total_spent >= 10000 THEN 'VIP'
        WHEN cs.total_spent >= 5000 THEN 'Premium'
        WHEN cs.total_spent >= 1000 THEN 'Regular'
        WHEN cs.total_spent > 0 THEN 'Occasional'
        ELSE 'Prospect'
    END AS customer_tier
FROM customers c
LEFT JOIN customer_stats cs ON c.customer_id = cs.customer_id
ORDER BY customer_status, lifetime_value DESC;

-- Scenario 3: Employee Hierarchy with Gaps
-- Show complete organizational structure including missing relationships
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_id,
    e.salary,
    NVL(m.first_name || ' ' || m.last_name, 'No Manager') AS manager_name,
    NVL(d.department_name, 'No Department') AS department,
    NVL(l.city, 'Unknown Location') AS work_location,
    CASE 
        WHEN e.manager_id IS NULL THEN 'Top Executive'
        WHEN m.employee_id IS NULL THEN 'Orphaned Employee'
        WHEN d.department_id IS NULL THEN 'Unassigned'
        ELSE 'Normal'
    END AS employment_status
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
ORDER BY employment_status, d.department_name, e.last_name;

-- =====================================================
-- SECTION 6: PERFORMANCE COMPARISON
-- =====================================================

-- Performance test: EXISTS vs LEFT JOIN with IS NULL
-- Find customers who haven't placed orders

-- Method 1: NOT EXISTS (usually more efficient)
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);

-- Method 2: LEFT JOIN with IS NULL
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.customer_id IS NULL;

-- Method 3: NOT IN (be careful with NULLs!)
SELECT customer_id, customer_name
FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id 
    FROM orders 
    WHERE customer_id IS NOT NULL  -- Important!
);

-- Performance comparison with execution plan
-- Use EXPLAIN PLAN to compare these approaches:
/*
EXPLAIN PLAN FOR
-- Insert one of the above queries here

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);
*/

-- =====================================================
-- SECTION 7: TROUBLESHOOTING COMMON ISSUES
-- =====================================================

-- Issue 1: Unexpected NULL results with NOT IN
-- Problem: NOT IN with NULLs returns no results
SELECT 'Problem Query - Returns nothing if any department_id is NULL' AS issue;

SELECT employee_id, first_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id 
    FROM departments 
    WHERE location_id = 1700
    -- If any department_id is NULL, this returns no rows!
);

-- Solution: Filter out NULLs or use NOT EXISTS
SELECT 'Solution 1 - Filter NULLs' AS solution;
SELECT employee_id, first_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id 
    FROM departments 
    WHERE location_id = 1700 
    AND department_id IS NOT NULL
);

SELECT 'Solution 2 - Use NOT EXISTS' AS solution;
SELECT e.employee_id, e.first_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 
    FROM departments d 
    WHERE d.department_id = e.department_id 
    AND d.location_id = 1700
);

-- Issue 2: Cartesian product due to missing JOIN condition
-- Problem: Missing JOIN condition creates Cartesian product
SELECT 'Demonstrate Cartesian Product (LIMITED!)' AS demo;
SELECT e.first_name, d.department_name
FROM employees e, departments d
WHERE rownum <= 20;  -- Limited to prevent huge result set

-- Solution: Always include proper JOIN conditions
SELECT 'Proper JOIN Solution' AS solution;
SELECT e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE rownum <= 20;

-- =====================================================
-- SECTION 8: ADVANCED OUTER JOIN PATTERNS
-- =====================================================

-- Pattern 1: Coalesce multiple outer joins
-- Create comprehensive employee contact info
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    COALESCE(e.email, e.phone_number, 'No Contact Info') AS primary_contact,
    COALESCE(d.department_name, 'Unassigned') AS department,
    COALESCE(l.city || ', ' || l.state_province, l.city, 'Unknown Location') AS location
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
ORDER BY e.employee_id;

-- Pattern 2: Conditional outer joins
-- Different join logic based on data conditions
SELECT 
    e.employee_id,
    e.first_name,
    e.hire_date,
    CASE 
        WHEN e.hire_date >= DATE '2020-01-01' THEN 'Recent Hire'
        ELSE 'Veteran Employee'
    END AS employee_type,
    d.department_name,
    l.city
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
    AND (
        CASE 
            WHEN e.hire_date >= DATE '2020-01-01' THEN 1  -- Recent hires get location
            WHEN e.salary >= 15000 THEN 1                -- High earners get location
            ELSE 0                                        -- Others don't
        END
    ) = 1
ORDER BY e.hire_date DESC;

-- Pattern 3: Aggregation with outer joins and ROLLUP
-- Department summary with totals
SELECT 
    COALESCE(d.department_name, 'Unknown Department') AS department,
    COALESCE(l.city, 'Unknown City') AS city,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    SUM(e.salary) AS total_salary,
    MIN(e.hire_date) AS earliest_hire,
    MAX(e.hire_date) AS latest_hire
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
GROUP BY ROLLUP(d.department_name, l.city)
ORDER BY department, city;

-- =====================================================
-- SECTION 9: PRACTICE EXERCISES
-- =====================================================

-- Exercise 1: Basic Outer Joins
-- TODO: Write a query to list all departments with their manager names
-- Include departments without managers
-- Expected columns: department_id, department_name, manager_name

-- Exercise 2: Complex Scenario
-- TODO: Create a comprehensive employee report showing:
-- - Employee info (id, name, salary, hire_date)
-- - Department info (name, location)
-- - Manager info (name, title)
-- - Include employees even if any related data is missing
-- Use appropriate NULL handling

-- Exercise 3: Data Analysis
-- TODO: Find departments that have:
-- a) No employees at all
-- b) No high-salary employees (salary > 10000)
-- c) Employees but no manager assigned
-- Show department details for each category

-- Exercise 4: Performance Optimization
-- TODO: Compare the performance of these equivalent queries:
-- 1. LEFT JOIN with WHERE IS NULL
-- 2. NOT EXISTS subquery
-- 3. NOT IN subquery (with proper NULL handling)
-- Use EXPLAIN PLAN to analyze execution plans

-- =====================================================
-- SECTION 10: SUMMARY AND BEST PRACTICES
-- =====================================================

/*
OUTER JOIN BEST PRACTICES:

1. CLARITY:
   - Use ANSI SQL syntax (LEFT/RIGHT/FULL JOIN) instead of (+)
   - Be explicit about join types for better readability
   - Use meaningful table aliases

2. NULL HANDLING:
   - Always consider NULL values in outer join results
   - Use NVL, NVL2, COALESCE, or CASE for appropriate defaults
   - Be cautious with NOT IN when NULLs are possible

3. PERFORMANCE:
   - Index join columns appropriately
   - Consider EXISTS/NOT EXISTS vs outer joins for existence checks
   - Use EXPLAIN PLAN to analyze query performance
   - Filter conditions in WHERE vs ON clause impact results

4. COMMON PATTERNS:
   - LEFT JOIN: Include all from left table
   - RIGHT JOIN: Include all from right table  
   - FULL OUTER JOIN: Include all from both tables
   - Use for finding missing data, generating reports, data reconciliation

5. TROUBLESHOOTING:
   - Check for missing JOIN conditions (Cartesian products)
   - Verify NULL handling logic
   - Test with edge cases (empty tables, all NULLs)
   - Validate business logic with stakeholders

REMEMBER: Outer joins preserve data from one or both sides of the join,
making them powerful for comprehensive reporting and analysis where
you need to see the complete picture, not just matching records.
*/

-- End of outer joins practice file
