-- =====================================================
-- SUBQUERIES PRACTICE - Oracle Database Learning
-- =====================================================
-- This file provides comprehensive practice with Oracle subqueries
-- including scalar, single-row, multi-row, and multi-column subqueries

-- =====================================================
-- SECTION 1: SCALAR SUBQUERIES (SINGLE VALUE)
-- =====================================================

-- Basic scalar subquery in WHERE clause
-- Find employees earning more than average salary
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    (SELECT AVG(salary) FROM employees) AS company_avg_salary,
    salary - (SELECT AVG(salary) FROM employees) AS diff_from_avg
FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees)
ORDER BY salary DESC;

-- Scalar subquery in SELECT clause
-- Add department name using subquery
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    (SELECT d.department_name 
     FROM departments d 
     WHERE d.department_id = e.department_id) AS department_name,
    (SELECT COUNT(*) 
     FROM employees e2 
     WHERE e2.department_id = e.department_id) AS dept_employee_count
FROM employees e
WHERE e.employee_id <= 110
ORDER BY e.employee_id;

-- Multiple scalar subqueries for analytics
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    hire_date,
    (SELECT MIN(salary) FROM employees) AS min_company_salary,
    (SELECT MAX(salary) FROM employees) AS max_company_salary,
    (SELECT AVG(salary) FROM employees) AS avg_company_salary,
    (SELECT COUNT(*) FROM employees) AS total_employees,
    ROUND((salary / (SELECT AVG(salary) FROM employees)) * 100, 2) AS salary_vs_avg_pct
FROM employees
WHERE department_id = 50
ORDER BY salary DESC;

-- Scalar subquery with date calculations
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    (SELECT MIN(hire_date) FROM employees) AS first_company_hire,
    hire_date - (SELECT MIN(hire_date) FROM employees) AS days_after_first_hire,
    CASE 
        WHEN hire_date = (SELECT MIN(hire_date) FROM employees) THEN 'Founding Employee'
        WHEN hire_date <= (SELECT MIN(hire_date) FROM employees) + 365 THEN 'Early Employee'
        ELSE 'Regular Employee'
    END AS employee_category
FROM employees
ORDER BY hire_date;

-- =====================================================
-- SECTION 2: SINGLE-ROW SUBQUERIES
-- =====================================================

-- Find employee with highest salary
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    job_id,
    department_id
FROM employees
WHERE salary = (SELECT MAX(salary) FROM employees);

-- Find employees in the same department as a specific employee
SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    job_id
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE employee_id = 100
)
AND employee_id != 100  -- Exclude the reference employee
ORDER BY last_name;

-- Single-row subquery with multiple columns
SELECT 
    employee_id,
    first_name,
    last_name,
    job_id,
    department_id,
    salary
FROM employees
WHERE (job_id, department_id) = (
    SELECT job_id, department_id
    FROM employees
    WHERE employee_id = 200
)
ORDER BY salary DESC;

-- Find most recent hire in each department using single-row subquery
SELECT 
    d.department_id,
    d.department_name,
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date
FROM departments d
JOIN employees e ON d.department_id = e.department_id
WHERE e.hire_date = (
    SELECT MAX(hire_date)
    FROM employees e2
    WHERE e2.department_id = d.department_id
)
ORDER BY d.department_id;

-- =====================================================
-- SECTION 3: MULTI-ROW SUBQUERIES
-- =====================================================

-- Using IN operator with multi-row subquery
-- Find employees in departments located in specific cities
SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    job_id
FROM employees
WHERE department_id IN (
    SELECT d.department_id
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    WHERE l.city IN ('Seattle', 'Toronto', 'London')
)
ORDER BY department_id, last_name;

-- Using ANY operator
-- Find employees earning more than ANY employee in department 50
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    department_id
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 50
)
AND department_id != 50
ORDER BY salary DESC;

-- Using ALL operator
-- Find employees earning more than ALL employees in department 50
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    department_id
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 50
)
ORDER BY salary DESC;

-- Complex multi-row subquery with multiple conditions
-- Find employees whose salary is in the top 3 for their job category
SELECT 
    employee_id,
    first_name,
    last_name,
    job_id,
    salary
FROM employees e1
WHERE salary IN (
    SELECT DISTINCT salary
    FROM (
        SELECT salary
        FROM employees e2
        WHERE e2.job_id = e1.job_id
        ORDER BY salary DESC
    )
    WHERE rownum <= 3
)
ORDER BY job_id, salary DESC;

-- =====================================================
-- SECTION 4: EXISTS AND NOT EXISTS
-- =====================================================

-- EXISTS: Find employees who have job history
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_id AS current_job,
    e.hire_date
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
)
ORDER BY e.employee_id;

-- NOT EXISTS: Find employees with no job history
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_id,
    e.hire_date,
    ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12, 1) AS years_with_company
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
)
ORDER BY e.hire_date;

-- Complex EXISTS with multiple conditions
-- Find departments that have employees earning more than 15000
SELECT 
    d.department_id,
    d.department_name,
    d.manager_id
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
    AND e.salary > 15000
)
ORDER BY d.department_name;

-- NOT EXISTS for finding missing relationships
-- Find departments with no high-salary employees
SELECT 
    d.department_id,
    d.department_name,
    (SELECT AVG(salary) 
     FROM employees e 
     WHERE e.department_id = d.department_id) AS avg_dept_salary
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
    AND e.salary > 15000
)
AND EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
)
ORDER BY avg_dept_salary DESC;

-- =====================================================
-- SECTION 5: INLINE VIEWS (SUBQUERIES IN FROM CLAUSE)
-- =====================================================

-- Basic inline view with aggregation
SELECT 
    dept_summary.department_name,
    dept_summary.employee_count,
    dept_summary.avg_salary,
    dept_summary.total_salary,
    e.first_name,
    e.last_name,
    e.salary
FROM (
    SELECT 
        d.department_id,
        d.department_name,
        COUNT(e.employee_id) AS employee_count,
        AVG(e.salary) AS avg_salary,
        SUM(e.salary) AS total_salary
    FROM departments d
    LEFT JOIN employees e ON d.department_id = e.department_id
    GROUP BY d.department_id, d.department_name
) dept_summary
JOIN employees e ON dept_summary.department_id = e.department_id
WHERE e.salary > dept_summary.avg_salary
ORDER BY dept_summary.department_name, e.salary DESC;

-- Complex inline view with ranking
-- Top 2 highest paid employees per department
SELECT 
    department_name,
    employee_rank,
    employee_id,
    first_name,
    last_name,
    salary,
    dept_avg_salary
FROM (
    SELECT 
        d.department_name,
        e.employee_id,
        e.first_name,
        e.last_name,
        e.salary,
        AVG(e.salary) OVER (PARTITION BY e.department_id) AS dept_avg_salary,
        ROW_NUMBER() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS employee_rank
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
) ranked_employees
WHERE employee_rank <= 2
ORDER BY department_name, employee_rank;

-- Inline view for data transformation
-- Salary distribution analysis
SELECT 
    salary_range,
    employee_count,
    percentage_of_total,
    cumulative_percentage
FROM (
    SELECT 
        salary_range,
        employee_count,
        ROUND((employee_count / SUM(employee_count) OVER ()) * 100, 2) AS percentage_of_total,
        ROUND(SUM(employee_count) OVER (ORDER BY salary_range) / SUM(employee_count) OVER () * 100, 2) AS cumulative_percentage
    FROM (
        SELECT 
            CASE 
                WHEN salary < 5000 THEN '< 5K'
                WHEN salary < 10000 THEN '5K - 10K'
                WHEN salary < 15000 THEN '10K - 15K'
                WHEN salary < 20000 THEN '15K - 20K'
                ELSE '20K+'
            END AS salary_range,
            COUNT(*) AS employee_count
        FROM employees
        GROUP BY 
            CASE 
                WHEN salary < 5000 THEN '< 5K'
                WHEN salary < 10000 THEN '5K - 10K'
                WHEN salary < 15000 THEN '10K - 15K'
                WHEN salary < 20000 THEN '15K - 20K'
                ELSE '20K+'
            END
    )
    ORDER BY 
        CASE salary_range
            WHEN '< 5K' THEN 1
            WHEN '5K - 10K' THEN 2
            WHEN '10K - 15K' THEN 3
            WHEN '15K - 20K' THEN 4
            WHEN '20K+' THEN 5
        END
);

-- =====================================================
-- SECTION 6: NESTED SUBQUERIES
-- =====================================================

-- Multiple levels of nesting
-- Find employees in the department with the highest average salary
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    department_id
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM (
        SELECT 
            department_id,
            AVG(salary) AS avg_salary
        FROM employees
        WHERE department_id IS NOT NULL
        GROUP BY department_id
        ORDER BY avg_salary DESC
    )
    WHERE rownum = 1
);

-- Complex nested subquery for analytics
-- Employees earning above their department's 75th percentile
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id,
    dept_stats.percentile_75
FROM employees e
JOIN (
    SELECT 
        department_id,
        PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY salary) AS percentile_75
    FROM employees
    WHERE department_id IS NOT NULL
    GROUP BY department_id
) dept_stats ON e.department_id = dept_stats.department_id
WHERE e.salary > dept_stats.percentile_75
ORDER BY e.department_id, e.salary DESC;

-- Three-level nested subquery
-- Find employees in departments where the manager earns less than the department average
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.department_id IN (
    SELECT d.department_id
    FROM departments d
    WHERE (
        SELECT salary
        FROM employees mgr
        WHERE mgr.employee_id = d.manager_id
    ) < (
        SELECT AVG(salary)
        FROM employees emp
        WHERE emp.department_id = d.department_id
    )
);

-- =====================================================
-- SECTION 7: SUBQUERIES WITH AGGREGATION
-- =====================================================

-- Subqueries in HAVING clause
-- Departments with average salary above company average
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS dept_avg_salary,
    (SELECT AVG(salary) FROM employees) AS company_avg_salary
FROM employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING AVG(salary) > (
    SELECT AVG(salary)
    FROM employees
)
ORDER BY dept_avg_salary DESC;

-- Complex aggregation with subqueries
-- Department performance metrics
SELECT 
    d.department_id,
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    SUM(e.salary) AS total_salary,
    ROUND(AVG(e.salary) / (SELECT AVG(salary) FROM employees) * 100, 2) AS avg_vs_company_pct,
    CASE 
        WHEN AVG(e.salary) > (SELECT AVG(salary) FROM employees) * 1.2 THEN 'High Paying'
        WHEN AVG(e.salary) > (SELECT AVG(salary) FROM employees) * 0.8 THEN 'Average Paying'
        ELSE 'Low Paying'
    END AS salary_category
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
HAVING COUNT(e.employee_id) > 0
ORDER BY avg_salary DESC;

-- =====================================================
-- SECTION 8: PERFORMANCE COMPARISON
-- =====================================================

-- Compare subquery vs JOIN performance
-- Method 1: Subquery approach
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    (SELECT d.department_name 
     FROM departments d 
     WHERE d.department_id = e.department_id) AS department_name
FROM employees e
WHERE e.employee_id <= 110;

-- Method 2: JOIN approach (usually more efficient)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE e.employee_id <= 110;

-- EXISTS vs IN performance comparison
-- Method 1: EXISTS (generally more efficient)
SELECT COUNT(*) AS exists_count
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- Method 2: IN (can be less efficient with large datasets)
SELECT COUNT(*) AS in_count
FROM employees
WHERE employee_id IN (
    SELECT DISTINCT employee_id
    FROM job_history
);

-- =====================================================
-- SECTION 9: COMMON SUBQUERY PATTERNS
-- =====================================================

-- Pattern 1: Top-N analysis
-- Top 5 highest salaries in the company
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    department_id
FROM employees
WHERE salary IN (
    SELECT DISTINCT salary
    FROM (
        SELECT salary
        FROM employees
        ORDER BY salary DESC
    )
    WHERE rownum <= 5
)
ORDER BY salary DESC;

-- Pattern 2: Running calculations
-- Employees hired before and after company median hire date
WITH hire_date_stats AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hire_date) AS median_hire_date
    FROM employees
)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date,
    hds.median_hire_date,
    CASE 
        WHEN e.hire_date <= hds.median_hire_date THEN 'Early Hire'
        ELSE 'Late Hire'
    END AS hire_timing,
    (SELECT COUNT(*)
     FROM employees e2
     WHERE e2.hire_date <= e.hire_date) AS hire_sequence_number
FROM employees e
CROSS JOIN hire_date_stats hds
ORDER BY e.hire_date;

-- Pattern 3: Data quality checks
-- Find data inconsistencies using subqueries
SELECT 'Data Quality Issues' AS analysis_type;

-- Employees with invalid department_id
SELECT 'Invalid Department IDs:' AS issue_type, COUNT(*) AS issue_count
FROM employees
WHERE department_id NOT IN (
    SELECT department_id 
    FROM departments 
    WHERE department_id IS NOT NULL
)
AND department_id IS NOT NULL;

-- Departments with manager not in employee table
SELECT 'Invalid Manager IDs:' AS issue_type, COUNT(*) AS issue_count
FROM departments
WHERE manager_id NOT IN (
    SELECT employee_id 
    FROM employees 
    WHERE employee_id IS NOT NULL
)
AND manager_id IS NOT NULL;

-- Employees reporting to themselves
SELECT 'Self-Reporting Employees:' AS issue_type, COUNT(*) AS issue_count
FROM employees
WHERE employee_id = manager_id;

-- =====================================================
-- SECTION 10: ADVANCED SUBQUERY SCENARIOS
-- =====================================================

-- Scenario 1: Complex business logic
-- Find employees who earn more than their manager and have been with company longer
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.salary AS employee_salary,
    e.hire_date AS employee_hire_date,
    (SELECT m.first_name || ' ' || m.last_name 
     FROM employees m 
     WHERE m.employee_id = e.manager_id) AS manager_name,
    (SELECT m.salary 
     FROM employees m 
     WHERE m.employee_id = e.manager_id) AS manager_salary,
    (SELECT m.hire_date 
     FROM employees m 
     WHERE m.employee_id = e.manager_id) AS manager_hire_date
FROM employees e
WHERE e.manager_id IS NOT NULL
AND e.salary > (
    SELECT salary
    FROM employees m
    WHERE m.employee_id = e.manager_id
)
AND e.hire_date < (
    SELECT hire_date
    FROM employees m
    WHERE m.employee_id = e.manager_id
)
ORDER BY e.salary DESC;

-- Scenario 2: Time-based analysis
-- Employees with declining career progression (salary decreased in job changes)
SELECT 
    jh.employee_id,
    (SELECT first_name || ' ' || last_name 
     FROM employees e 
     WHERE e.employee_id = jh.employee_id) AS employee_name,
    jh.job_id AS previous_job,
    jh.start_date,
    jh.end_date,
    (SELECT job_id FROM employees e WHERE e.employee_id = jh.employee_id) AS current_job,
    (SELECT min_salary FROM jobs j WHERE j.job_id = jh.job_id) AS prev_job_min_salary,
    (SELECT max_salary FROM jobs j WHERE j.job_id = jh.job_id) AS prev_job_max_salary,
    (SELECT min_salary FROM jobs j WHERE j.job_id = (
        SELECT job_id FROM employees e WHERE e.employee_id = jh.employee_id
    )) AS current_job_min_salary
FROM job_history jh
WHERE (
    SELECT max_salary FROM jobs j WHERE j.job_id = jh.job_id
) > (
    SELECT max_salary FROM jobs j WHERE j.job_id = (
        SELECT job_id FROM employees e WHERE e.employee_id = jh.employee_id
    )
)
ORDER BY jh.employee_id, jh.end_date DESC;

-- Scenario 3: Market analysis simulation
-- Create sample data and analyze with subqueries
WITH sample_sales AS (
    SELECT 
        LEVEL AS sale_id,
        MOD(LEVEL, 10) + 1 AS customer_id,
        SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 365)) AS sale_date,
        ROUND(DBMS_RANDOM.VALUE(100, 5000), 2) AS sale_amount
    FROM dual 
    CONNECT BY LEVEL <= 1000
)
SELECT 
    customer_id,
    COUNT(*) AS total_purchases,
    SUM(sale_amount) AS total_spent,
    AVG(sale_amount) AS avg_purchase,
    MIN(sale_date) AS first_purchase,
    MAX(sale_date) AS last_purchase,
    CASE 
        WHEN SUM(sale_amount) > (
            SELECT PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY customer_total)
            FROM (
                SELECT customer_id, SUM(sale_amount) AS customer_total
                FROM sample_sales
                GROUP BY customer_id
            )
        ) THEN 'VIP Customer'
        WHEN SUM(sale_amount) > (
            SELECT AVG(customer_total)
            FROM (
                SELECT customer_id, SUM(sale_amount) AS customer_total
                FROM sample_sales
                GROUP BY customer_id
            )
        ) THEN 'Premium Customer'
        ELSE 'Regular Customer'
    END AS customer_tier
FROM sample_sales
GROUP BY customer_id
HAVING COUNT(*) >= (
    SELECT AVG(purchase_count)
    FROM (
        SELECT customer_id, COUNT(*) AS purchase_count
        FROM sample_sales
        GROUP BY customer_id
    )
)
ORDER BY total_spent DESC;

-- =====================================================
-- SECTION 11: TROUBLESHOOTING SUBQUERIES
-- =====================================================

-- Common Issue 1: Subquery returns no rows (NULL)
-- Problem demonstration
SELECT 'Subquery returning NULL demonstration:' AS demo;

SELECT 
    employee_id,
    first_name,
    salary,
    (SELECT AVG(salary) 
     FROM employees 
     WHERE department_id = 999) AS non_existent_dept_avg  -- Returns NULL
FROM employees
WHERE employee_id = 100;

-- Solution: Handle NULL cases
SELECT 
    employee_id,
    first_name,
    salary,
    NVL((SELECT AVG(salary) 
         FROM employees 
         WHERE department_id = 999), 0) AS dept_avg_handled
FROM employees
WHERE employee_id = 100;

-- Common Issue 2: Multiple row subquery with single-row operator
-- This will cause an error if uncommented:
/*
SELECT employee_id, first_name
FROM employees
WHERE department_id = (
    SELECT department_id 
    FROM departments 
    WHERE location_id IN (1400, 1700)  -- Returns multiple rows!
);
*/

-- Solution: Use appropriate multi-row operator
SELECT employee_id, first_name, department_id
FROM employees
WHERE department_id IN (
    SELECT department_id 
    FROM departments 
    WHERE location_id IN (1400, 1700)
);

-- Common Issue 3: NOT IN with NULL values
-- Demonstrate the issue
WITH test_data AS (
    SELECT 1 AS id FROM dual UNION ALL
    SELECT 2 FROM dual UNION ALL
    SELECT 3 FROM dual UNION ALL
    SELECT NULL FROM dual
)
SELECT 'NOT IN with NULL test:' AS test_type;

-- This returns no rows due to NULL in the subquery
SELECT 'Main query result count:' AS result_type, COUNT(*) AS row_count
FROM employees
WHERE department_id NOT IN (SELECT id FROM test_data);

-- Solution: Filter out NULLs
SELECT 'Fixed query result count:' AS result_type, COUNT(*) AS row_count
FROM employees
WHERE department_id NOT IN (SELECT id FROM test_data WHERE id IS NOT NULL);

-- =====================================================
-- SECTION 12: PRACTICE EXERCISES
-- =====================================================

-- Exercise 1: Basic Subquery Mastery
-- TODO: Write queries to find:
-- 1. Employees earning more than the median salary in their department
-- 2. Departments with the highest and lowest average salaries
-- 3. The employee who has been with the company the longest in each department

-- Exercise 2: Advanced Subquery Scenarios
-- TODO: Create queries for:
-- 1. Employees who have never changed jobs (not in job_history)
-- 2. Find departments where all employees earn more than the company average
-- 3. Identify the top 3 departments by total salary expenditure

-- Exercise 3: Performance Optimization
-- TODO: For each of these subquery patterns, write an equivalent JOIN version:
-- 1. Scalar subquery in SELECT clause
-- 2. EXISTS subquery for filtering
-- 3. IN subquery with large result set
-- Compare execution plans and identify which performs better

-- Exercise 4: Business Intelligence Queries
-- TODO: Using subqueries, create a management dashboard showing:
-- 1. Department performance metrics (vs company averages)
-- 2. Employee retention analysis (tenure patterns)
-- 3. Salary distribution and outlier identification

-- =====================================================
-- SUMMARY: SUBQUERY BEST PRACTICES
-- =====================================================

/*
SUBQUERY BEST PRACTICES:

1. TYPES AND USAGE:
   - Scalar subqueries: Single value, use anywhere
   - Single-row: One row, use with =, !=, <, >, <=, >=
   - Multi-row: Multiple rows, use with IN, ANY, ALL, EXISTS
   - Multi-column: Multiple columns for complex comparisons

2. PERFORMANCE CONSIDERATIONS:
   - EXISTS usually more efficient than IN for large datasets
   - JOINs often perform better than scalar subqueries in SELECT
   - Consider correlated vs non-correlated subqueries
   - Index subquery filter columns

3. NULL HANDLING:
   - Be careful with NOT IN when NULLs are possible
   - Use NVL/COALESCE for scalar subqueries that might return NULL
   - Test edge cases with empty result sets

4. READABILITY:
   - Format complex subqueries clearly
   - Consider CTEs for complex nested subqueries
   - Document business logic in comments
   - Break down complex problems step by step

5. DEBUGGING:
   - Test subqueries independently first
   - Verify expected result sets
   - Check for single vs multi-row return types
   - Validate NULL handling logic

6. WHEN TO USE SUBQUERIES:
   - Dynamic filtering based on data
   - Aggregated comparisons
   - Existence/non-existence checking
   - Complex analytical calculations
   - When JOINs would create unwanted duplicates

7. ALTERNATIVES TO CONSIDER:
   - JOINs for better performance
   - Window functions for analytical queries
   - CTEs for complex logic
   - Views for frequently used subqueries

REMEMBER: Subqueries are powerful tools for breaking down complex problems
into manageable parts, but always consider performance and maintainability
when choosing between subqueries and alternative approaches.
*/

-- End of subqueries practice file
