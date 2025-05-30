-- =====================================================
-- ADVANCED JOINS PRACTICE - Oracle Database Learning
-- =====================================================
-- This file covers CROSS JOINs, NATURAL JOINs, Self-joins, 
-- Anti-joins, Semi-joins, and complex multi-table scenarios

-- =====================================================
-- SECTION 1: CROSS JOIN (CARTESIAN PRODUCT)
-- =====================================================

-- Basic CROSS JOIN example
-- Generate all possible employee-department combinations
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_id,
    d.department_name
FROM employees e
CROSS JOIN departments d
WHERE e.employee_id <= 105  -- Limit results for demo
  AND d.department_id <= 30
ORDER BY e.employee_id, d.department_id;

-- Practical CROSS JOIN: Product-Size Matrix
-- Create a matrix of all possible product-size combinations
WITH product_sizes AS (
    SELECT 'Small' AS size_name, 0.8 AS price_multiplier, 1 AS size_order FROM dual UNION ALL
    SELECT 'Medium', 1.0, 2 FROM dual UNION ALL
    SELECT 'Large', 1.3, 3 FROM dual UNION ALL
    SELECT 'X-Large', 1.5, 4 FROM dual
),
sample_products AS (
    SELECT 1 AS product_id, 'T-Shirt' AS product_name, 25.00 AS base_price FROM dual UNION ALL
    SELECT 2, 'Jeans', 75.00 FROM dual UNION ALL
    SELECT 3, 'Jacket', 120.00 FROM dual UNION ALL
    SELECT 4, 'Shoes', 95.00 FROM dual
)
SELECT 
    p.product_id,
    p.product_name,
    s.size_name,
    p.base_price,
    s.price_multiplier,
    ROUND(p.base_price * s.price_multiplier, 2) AS final_price,
    'SKU-' || p.product_id || '-' || SUBSTR(s.size_name, 1, 1) AS sku
FROM sample_products p
CROSS JOIN product_sizes s
ORDER BY p.product_name, s.size_order;

-- Time-based CROSS JOIN: Calendar generation
-- Generate monthly sales targets for all departments
WITH months AS (
    SELECT 1 AS month_num, 'January' AS month_name FROM dual UNION ALL
    SELECT 2, 'February' FROM dual UNION ALL
    SELECT 3, 'March' FROM dual UNION ALL
    SELECT 4, 'April' FROM dual UNION ALL
    SELECT 5, 'May' FROM dual UNION ALL
    SELECT 6, 'June' FROM dual
),
dept_targets AS (
    SELECT department_id, department_name
    FROM departments
    WHERE department_id IN (10, 20, 30, 50)
)
SELECT 
    dt.department_id,
    dt.department_name,
    m.month_num,
    m.month_name,
    CASE 
        WHEN m.month_num IN (1, 7) THEN 150000  -- High season
        WHEN m.month_num IN (12, 6) THEN 120000 -- Medium season
        ELSE 100000                             -- Regular season
    END AS monthly_target,
    TO_DATE('2024-' || LPAD(m.month_num, 2, '0') || '-01', 'YYYY-MM-DD') AS target_month
FROM dept_targets dt
CROSS JOIN months m
ORDER BY dt.department_id, m.month_num;

-- WARNING: CROSS JOIN with large tables
-- Demonstrate potential issues
SELECT 'CROSS JOIN can create massive result sets!' AS warning;
SELECT 'Table 1: ' || COUNT(*) || ' rows' AS table1_size FROM employees;
SELECT 'Table 2: ' || COUNT(*) || ' rows' AS table2_size FROM departments;
SELECT 'CROSS JOIN would produce: ' || 
       (SELECT COUNT(*) FROM employees) * (SELECT COUNT(*) FROM departments) || 
       ' rows' AS potential_cartesian_size;

-- =====================================================
-- SECTION 2: NATURAL JOIN EXAMPLES
-- =====================================================

-- Basic NATURAL JOIN (use with caution)
-- Automatically joins on columns with same name and type
SELECT employee_id, first_name, last_name, department_name
FROM employees 
NATURAL JOIN departments
WHERE employee_id <= 110
ORDER BY employee_id;

-- NATURAL JOIN equivalent to explicit JOIN
-- Show what NATURAL JOIN is doing behind the scenes
SELECT 'NATURAL JOIN result:' AS comparison;
SELECT COUNT(*) AS natural_join_count
FROM employees NATURAL JOIN departments;

SELECT 'Equivalent explicit JOIN:' AS comparison;
SELECT COUNT(*) AS explicit_join_count
FROM employees e
JOIN departments d ON e.department_id = d.department_id
                  AND e.manager_id = d.manager_id;  -- Natural join found 2 matching columns!

-- Safer approach: Use USING clause for specific columns
SELECT employee_id, first_name, last_name, department_name
FROM employees 
JOIN departments USING (department_id)
WHERE employee_id <= 110
ORDER BY employee_id;

-- NATURAL JOIN pitfalls demonstration
-- Show how NATURAL JOIN can break with schema changes
CREATE TABLE temp_employees AS 
SELECT employee_id, first_name, last_name, department_id, manager_id, 'temp' AS status
FROM employees WHERE rownum <= 5;

CREATE TABLE temp_departments AS 
SELECT department_id, department_name, manager_id, 'active' AS status
FROM departments WHERE department_id <= 50;

-- NATURAL JOIN finds multiple matching columns
SELECT 'Natural join with unexpected column matches:' AS demo;
SELECT *
FROM temp_employees NATURAL JOIN temp_departments;

-- Clean up temp tables
DROP TABLE temp_employees;
DROP TABLE temp_departments;

-- =====================================================
-- SECTION 3: SELF-JOINS
-- =====================================================

-- Basic self-join: Employee-Manager relationships
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_id AS employee_job,
    e.salary AS employee_salary,
    m.employee_id AS manager_id,
    m.first_name || ' ' || m.last_name AS manager_name,
    m.job_id AS manager_job,
    m.salary AS manager_salary
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY e.employee_id;

-- Self-join: Find employees earning more than their manager
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.salary AS employee_salary,
    m.first_name || ' ' || m.last_name AS manager_name,
    m.salary AS manager_salary,
    e.salary - m.salary AS salary_difference
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary
ORDER BY salary_difference DESC;

-- Hierarchical self-join: Organization levels
WITH employee_hierarchy AS (
    -- Top level (no manager)
    SELECT 
        employee_id,
        first_name || ' ' || last_name AS name,
        manager_id,
        1 AS level,
        first_name || ' ' || last_name AS hierarchy_path
    FROM employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    -- Recursive part
    SELECT 
        e.employee_id,
        e.first_name || ' ' || e.last_name,
        e.manager_id,
        eh.level + 1,
        eh.hierarchy_path || ' -> ' || e.first_name || ' ' || e.last_name
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
    WHERE eh.level < 5  -- Prevent infinite recursion
)
SELECT 
    level,
    LPAD(' ', (level - 1) * 4) || name AS org_chart,
    hierarchy_path
FROM employee_hierarchy
ORDER BY hierarchy_path;

-- Self-join: Find colleagues (same manager, different employee)
SELECT 
    e1.employee_id AS emp1_id,
    e1.first_name || ' ' || e1.last_name AS emp1_name,
    e2.employee_id AS emp2_id,
    e2.first_name || ' ' || e2.last_name AS emp2_name,
    m.first_name || ' ' || m.last_name AS shared_manager,
    e1.department_id
FROM employees e1
JOIN employees e2 ON e1.manager_id = e2.manager_id
JOIN employees m ON e1.manager_id = m.employee_id
WHERE e1.employee_id < e2.employee_id  -- Avoid duplicates
  AND e1.manager_id IS NOT NULL
ORDER BY shared_manager, e1.employee_id;

-- Self-join: Compare employees hired in same year
SELECT 
    e1.employee_id AS emp1_id,
    e1.first_name || ' ' || e1.last_name AS emp1_name,
    e1.hire_date AS emp1_hire_date,
    e2.employee_id AS emp2_id,
    e2.first_name || ' ' || e2.last_name AS emp2_name,
    e2.hire_date AS emp2_hire_date,
    EXTRACT(YEAR FROM e1.hire_date) AS hire_year,
    ABS(e1.hire_date - e2.hire_date) AS days_apart
FROM employees e1
JOIN employees e2 ON EXTRACT(YEAR FROM e1.hire_date) = EXTRACT(YEAR FROM e2.hire_date)
WHERE e1.employee_id < e2.employee_id
  AND ABS(e1.hire_date - e2.hire_date) <= 30  -- Hired within 30 days
ORDER BY hire_year, days_apart;

-- =====================================================
-- SECTION 4: ANTI-JOINS (NOT EXISTS / NOT IN)
-- =====================================================

-- Anti-join: Find employees with no job history
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date,
    e.job_id AS current_job
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- Anti-join: Departments with no employees
SELECT 
    d.department_id,
    d.department_name,
    d.manager_id,
    l.city AS location
FROM departments d
LEFT JOIN locations l ON d.location_id = l.location_id
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);

-- Anti-join: Products never ordered
WITH sample_products AS (
    SELECT level AS product_id, 
           'Product ' || level AS product_name,
           ROUND(DBMS_RANDOM.VALUE(10, 100), 2) AS unit_price
    FROM dual CONNECT BY level <= 20
),
sample_orders AS (
    SELECT TRUNC(DBMS_RANDOM.VALUE(1, 15)) AS product_id,
           SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 365)) AS order_date,
           TRUNC(DBMS_RANDOM.VALUE(1, 10)) AS quantity
    FROM dual CONNECT BY level <= 50
)
SELECT 
    p.product_id,
    p.product_name,
    p.unit_price
FROM sample_products p
WHERE NOT EXISTS (
    SELECT 1
    FROM sample_orders o
    WHERE o.product_id = p.product_id
)
ORDER BY p.product_id;

-- Anti-join comparison: NOT EXISTS vs NOT IN vs LEFT JOIN
-- Method 1: NOT EXISTS (preferred for performance)
SELECT 'Method 1: NOT EXISTS' AS method, COUNT(*) AS result_count
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM job_history jh WHERE jh.employee_id = e.employee_id
);

-- Method 2: NOT IN (careful with NULLs!)
SELECT 'Method 2: NOT IN' AS method, COUNT(*) AS result_count
FROM employees
WHERE employee_id NOT IN (
    SELECT employee_id FROM job_history WHERE employee_id IS NOT NULL
);

-- Method 3: LEFT JOIN with IS NULL
SELECT 'Method 3: LEFT JOIN IS NULL' AS method, COUNT(*) AS result_count
FROM employees e
LEFT JOIN job_history jh ON e.employee_id = jh.employee_id
WHERE jh.employee_id IS NULL;

-- =====================================================
-- SECTION 5: SEMI-JOINS (EXISTS / IN)
-- =====================================================

-- Semi-join: Find employees who have job history
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.current_job_title,
    e.hire_date
FROM (
    SELECT 
        employee_id,
        first_name,
        last_name,
        job_id AS current_job_title,
        hire_date
    FROM employees
) e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- Semi-join: Departments that have employees
SELECT 
    d.department_id,
    d.department_name,
    d.manager_id
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
)
ORDER BY d.department_name;

-- Semi-join with conditions: High-performing departments
-- Departments with at least one employee earning > 15000
SELECT 
    d.department_id,
    d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
    AND e.salary > 15000
);

-- Complex semi-join: Customers who ordered specific product categories
WITH sample_customers AS (
    SELECT level AS customer_id, 
           'Customer ' || level AS customer_name
    FROM dual CONNECT BY level <= 10
),
sample_orders AS (
    SELECT TRUNC(DBMS_RANDOM.VALUE(1, 10)) AS customer_id,
           level AS order_id,
           SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 365)) AS order_date
    FROM dual CONNECT BY level <= 30
),
sample_order_items AS (
    SELECT order_id,
           TRUNC(DBMS_RANDOM.VALUE(1, 20)) AS product_id,
           CASE TRUNC(DBMS_RANDOM.VALUE(1, 4))
               WHEN 1 THEN 'Electronics'
               WHEN 2 THEN 'Clothing'
               WHEN 3 THEN 'Books'
               ELSE 'Home'
           END AS category
    FROM sample_orders
)
SELECT 
    c.customer_id,
    c.customer_name
FROM sample_customers c
WHERE EXISTS (
    SELECT 1
    FROM sample_orders o
    JOIN sample_order_items oi ON o.order_id = oi.order_id
    WHERE o.customer_id = c.customer_id
    AND oi.category = 'Electronics'
);

-- =====================================================
-- SECTION 6: COMPLEX MULTI-TABLE JOINS
-- =====================================================

-- Comprehensive employee information query
-- Combines multiple join types for complete picture
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.email,
    e.phone_number,
    e.hire_date,
    e.salary,
    j.job_title,
    j.min_salary,
    j.max_salary,
    d.department_name,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    l.street_address,
    l.city,
    l.state_province,
    c.country_name,
    r.region_name,
    CASE 
        WHEN e.salary < j.min_salary THEN 'Below Range'
        WHEN e.salary > j.max_salary THEN 'Above Range'
        ELSE 'In Range'
    END AS salary_status,
    ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12, 1) AS years_employed
FROM employees e
JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees mgr ON e.manager_id = mgr.employee_id
LEFT JOIN locations l ON d.location_id = l.location_id
LEFT JOIN countries c ON l.country_id = c.country_id
LEFT JOIN regions r ON c.region_id = r.region_id
WHERE e.employee_id <= 115
ORDER BY r.region_name, c.country_name, l.city, d.department_name, e.last_name;

-- Complex join with conditional logic
-- Different join behavior based on data conditions
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date,
    e.salary,
    CASE 
        WHEN e.hire_date >= DATE '2020-01-01' THEN 'New Employee'
        ELSE 'Veteran Employee'
    END AS employee_category,
    d.department_name,
    -- Conditional join: recent hires get current manager, veterans get original manager
    CASE 
        WHEN e.hire_date >= DATE '2020-01-01' THEN current_mgr.first_name || ' ' || current_mgr.last_name
        ELSE COALESCE(original_mgr.first_name || ' ' || original_mgr.last_name, 'Unknown')
    END AS relevant_manager
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees current_mgr ON e.manager_id = current_mgr.employee_id
LEFT JOIN (
    -- Simulate original manager lookup
    SELECT employee_id, first_name, last_name
    FROM employees
    WHERE job_id LIKE '%MGR%'
) original_mgr ON e.department_id = original_mgr.employee_id  -- Simplified logic
ORDER BY employee_category, e.hire_date;

-- Recursive hierarchical join using CONNECT BY PRIOR
SELECT 
    LEVEL AS hierarchy_level,
    LPAD(' ', (LEVEL - 1) * 4) || first_name || ' ' || last_name AS org_chart,
    employee_id,
    manager_id,
    job_id,
    salary,
    SYS_CONNECT_BY_PATH(first_name || ' ' || last_name, ' -> ') AS path_from_top
FROM employees
START WITH manager_id IS NULL  -- Start with top-level managers
CONNECT BY PRIOR employee_id = manager_id  -- Connect children to parents
ORDER SIBLINGS BY last_name;  -- Order siblings alphabetically

-- =====================================================
-- SECTION 7: PERFORMANCE OPTIMIZATION EXAMPLES
-- =====================================================

-- Optimization 1: Join order matters
-- Small table first, large table second (Oracle optimizer usually handles this)
SELECT /*+ ORDERED */ 
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM departments d  -- Smaller table first
LEFT JOIN employees e ON d.department_id = e.department_id  -- Larger table second
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC;

-- Optimization 2: Using hints for join methods
-- Force hash join for large datasets
SELECT /*+ USE_HASH(e d) */ 
    e.employee_id,
    e.first_name,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.salary > 10000;

-- Optimization 3: Covering indexes concept
-- Show what columns would benefit from covering indexes
SELECT 'Covering index suggestion:' AS optimization_tip;
SELECT 'CREATE INDEX idx_emp_covering ON employees(department_id, employee_id, first_name, last_name, salary);' AS suggested_index;

-- Optimization 4: Efficient anti-join
-- EXISTS is usually more efficient than NOT IN for anti-joins
EXPLAIN PLAN FOR
SELECT e.employee_id, e.first_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM job_history jh WHERE jh.employee_id = e.employee_id
);

-- View execution plan (uncomment to use)
-- SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- =====================================================
-- SECTION 8: ADVANCED JOIN PATTERNS
-- =====================================================

-- Pattern 1: Latest record per group using window functions
WITH ranked_job_changes AS (
    SELECT 
        jh.*,
        ROW_NUMBER() OVER (PARTITION BY employee_id ORDER BY start_date DESC) AS rn
    FROM job_history jh
)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_id AS current_job,
    rjc.job_id AS previous_job,
    rjc.start_date AS previous_job_start,
    rjc.end_date AS previous_job_end,
    rjc.department_id AS previous_department
FROM employees e
LEFT JOIN ranked_job_changes rjc ON e.employee_id = rjc.employee_id 
    AND rjc.rn = 1  -- Most recent job change
ORDER BY e.employee_id;

-- Pattern 2: Pivot-like operation using conditional aggregation
SELECT 
    d.department_name,
    COUNT(CASE WHEN e.salary < 5000 THEN 1 END) AS low_salary_count,
    COUNT(CASE WHEN e.salary BETWEEN 5000 AND 10000 THEN 1 END) AS medium_salary_count,
    COUNT(CASE WHEN e.salary > 10000 THEN 1 END) AS high_salary_count,
    AVG(e.salary) AS avg_salary
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY d.department_name;

-- Pattern 3: Gap analysis using self-join
-- Find missing employee IDs in sequence
SELECT 
    e1.employee_id AS current_id,
    e1.employee_id + 1 AS potential_next_id,
    CASE 
        WHEN e2.employee_id IS NULL THEN 'Gap Found'
        ELSE 'Continuous'
    END AS sequence_status
FROM employees e1
LEFT JOIN employees e2 ON e1.employee_id + 1 = e2.employee_id
WHERE e1.employee_id < (SELECT MAX(employee_id) FROM employees)
  AND e2.employee_id IS NULL  -- Only show gaps
ORDER BY e1.employee_id;

-- Pattern 4: Running totals with self-join
SELECT 
    e1.employee_id,
    e1.first_name,
    e1.hire_date,
    e1.salary,
    SUM(e2.salary) AS running_total_salary,
    COUNT(e2.employee_id) AS employees_hired_through_date
FROM employees e1
JOIN employees e2 ON e2.hire_date <= e1.hire_date
GROUP BY e1.employee_id, e1.first_name, e1.hire_date, e1.salary
ORDER BY e1.hire_date, e1.employee_id;

-- =====================================================
-- SECTION 9: PRACTICE EXERCISES
-- =====================================================

-- Exercise 1: Self-Join Mastery
-- TODO: Find all employee pairs who:
-- 1. Work in the same department
-- 2. Have the same job title
-- 3. Were hired within 90 days of each other
-- Show both employee details and the days difference

-- Exercise 2: Anti-Join Analysis
-- TODO: Create a comprehensive "gaps analysis" report showing:
-- 1. Departments with no employees
-- 2. Employees with no manager assigned (except top executives)
-- 3. Job titles that no employee currently holds
-- 4. Locations with no departments

-- Exercise 3: Complex Multi-Table Join
-- TODO: Create an "executive dashboard" query that shows:
-- For each department:
-- - Department info (name, location, manager)
-- - Employee statistics (count, avg salary, salary range)
-- - Latest hire information
-- - Performance indicators (departments with all high earners, etc.)

-- Exercise 4: Hierarchical Analysis
-- TODO: Using CONNECT BY PRIOR, create a query showing:
-- - Complete organizational hierarchy
-- - Level of each employee
-- - Number of subordinates (direct and indirect)
-- - Total salary cost for each manager's organization

-- Exercise 5: Performance Optimization
-- TODO: Take the complex dashboard query from Exercise 3 and:
-- 1. Analyze its execution plan
-- 2. Identify potential performance bottlenecks
-- 3. Suggest index optimizations
-- 4. Rewrite using different join approaches if beneficial

-- =====================================================
-- SECTION 10: ADVANCED TROUBLESHOOTING
-- =====================================================

-- Troubleshooting 1: Unexpected Cartesian Products
-- Identify potential Cartesian products in complex joins
WITH join_cardinality_check AS (
    SELECT 
        'employees' AS table_name,
        COUNT(*) AS row_count
    FROM employees
    UNION ALL
    SELECT 'departments', COUNT(*) FROM departments
    UNION ALL
    SELECT 'locations', COUNT(*) FROM locations
    UNION ALL
    SELECT 'countries', COUNT(*) FROM countries
)
SELECT 
    table_name,
    row_count,
    row_count * LAG(row_count) OVER (ORDER BY table_name) AS potential_cartesian_size
FROM join_cardinality_check;

-- Troubleshooting 2: Join condition validation
-- Verify join conditions produce expected results
SELECT 'Join Condition Analysis' AS analysis_type;

SELECT 'Employee-Department join coverage:' AS metric,
       COUNT(*) AS total_employees,
       COUNT(d.department_id) AS employees_with_dept,
       COUNT(*) - COUNT(d.department_id) AS employees_without_dept
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;

SELECT 'Department-Employee join coverage:' AS metric,
       COUNT(*) AS total_departments,
       COUNT(e.employee_id) AS departments_with_employees,
       COUNT(*) - COUNT(e.employee_id) AS empty_departments
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id;

-- =====================================================
-- SUMMARY: ADVANCED JOIN PATTERNS AND BEST PRACTICES
-- =====================================================

/*
ADVANCED JOIN BEST PRACTICES:

1. CROSS JOIN:
   - Use sparingly and with caution
   - Always limit result sets when testing
   - Perfect for generating combinations, matrices, calendars
   - Monitor result set size: rows1 × rows2

2. NATURAL JOIN:
   - Avoid in production code
   - Schema changes can break logic
   - Use explicit JOIN conditions or USING clause instead
   - Good for quick ad-hoc queries only

3. SELF-JOIN:
   - Essential for hierarchical data
   - Always use different aliases for clarity
   - Consider CONNECT BY PRIOR for Oracle hierarchical queries
   - Watch for performance with large datasets

4. ANTI-JOIN (NOT EXISTS/NOT IN):
   - NOT EXISTS generally more efficient
   - Handle NULLs carefully with NOT IN
   - Use for finding missing/orphaned records
   - LEFT JOIN with IS NULL is alternative approach

5. SEMI-JOIN (EXISTS/IN):
   - EXISTS stops at first match (efficient)
   - Use for existence checking without duplicating main table data
   - Often more readable than complex JOIN conditions

6. PERFORMANCE CONSIDERATIONS:
   - Index all join columns
   - Consider join order (small to large tables)
   - Use hints when optimizer needs guidance
   - Monitor execution plans regularly
   - Consider materialized views for complex multi-table joins

7. COMPLEX SCENARIOS:
   - Break complex queries into CTEs for readability
   - Use window functions instead of self-joins when possible
   - Consider creating views for frequently used join patterns
   - Document business logic clearly

8. TROUBLESHOOTING:
   - Verify join conditions with small datasets
   - Check for unintended Cartesian products
   - Validate NULL handling logic
   - Test with edge cases (empty tables, missing data)

REMEMBER: Advanced joins are powerful tools, but with power comes responsibility.
Always consider performance, maintainability, and clarity when designing
complex join scenarios.
*/

-- End of advanced joins practice file
