/*
===============================================================================
CORRELATED SUBQUERIES PRACTICE - Oracle Database Learning
===============================================================================
File: correlated-subqueries.sql
Purpose: Comprehensive practice with correlated subqueries in Oracle
Author: Oracle Database Learning Project
Created: 2025

This file contains extensive examples and exercises for mastering correlated 
subqueries, including performance optimization, business scenarios, and 
advanced patterns.

Prerequisites:
- Basic understanding of subqueries
- Knowledge of JOIN operations
- HR and SALES sample schemas loaded
- Understanding of EXISTS and NOT EXISTS operators

Learning Objectives:
- Master correlated subquery syntax and execution
- Understand performance implications and optimization
- Learn when to use correlated vs non-correlated subqueries
- Practice with EXISTS, NOT EXISTS, and comparison operators
- Apply correlated subqueries to real business scenarios
===============================================================================
*/

-- Set environment for better output
SET PAGESIZE 50
SET LINESIZE 120
SET SERVEROUTPUT ON

PROMPT ===============================================================================
PROMPT SECTION 1: BASIC CORRELATED SUBQUERIES
PROMPT ===============================================================================

-- Correlated subqueries reference columns from the outer query
-- They execute once for each row processed by the outer query

-- Example 1: Find employees who earn more than the average in their department
PROMPT 
PROMPT Example 1: Employees earning more than department average
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees e1
WHERE salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
)
ORDER BY department_id, salary DESC;

-- Example 2: Find departments with more than 5 employees
PROMPT 
PROMPT Example 2: Departments with more than 5 employees
SELECT department_id, department_name
FROM departments d
WHERE (
    SELECT COUNT(*)
    FROM employees e
    WHERE e.department_id = d.department_id
) > 5
ORDER BY department_id;

-- Example 3: Find employees with the highest salary in their department
PROMPT 
PROMPT Example 3: Highest paid employee in each department
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees e1
WHERE salary = (
    SELECT MAX(salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
)
ORDER BY department_id;

-- Example 4: Find customers who have placed orders
PROMPT 
PROMPT Example 4: Customers who have placed orders (using EXISTS)
SELECT customer_id, customer_name, city
FROM sales.customers c
WHERE EXISTS (
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
)
ORDER BY customer_name;

PROMPT ===============================================================================
PROMPT SECTION 2: EXISTS AND NOT EXISTS PATTERNS
PROMPT ===============================================================================

-- EXISTS is very efficient for correlated subqueries
-- It returns TRUE as soon as the first matching row is found

-- Example 5: Products that have been ordered
PROMPT 
PROMPT Example 5: Products that have been ordered
SELECT product_id, product_name, category_id, unit_price
FROM sales.products p
WHERE EXISTS (
    SELECT 1
    FROM sales.order_items oi
    WHERE oi.product_id = p.product_id
)
ORDER BY category_id, product_name;

-- Example 6: Products that have NEVER been ordered
PROMPT 
PROMPT Example 6: Products that have never been ordered
SELECT product_id, product_name, category_id, unit_price
FROM sales.products p
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.order_items oi
    WHERE oi.product_id = p.product_id
)
ORDER BY category_id, product_name;

-- Example 7: Employees without direct reports
PROMPT 
PROMPT Example 7: Employees without direct reports
SELECT employee_id, first_name, last_name, job_id
FROM employees e1
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e2
    WHERE e2.manager_id = e1.employee_id
)
ORDER BY last_name, first_name;

-- Example 8: Customers who haven't placed orders in 2023
PROMPT 
PROMPT Example 8: Customers with no orders in 2023
SELECT customer_id, customer_name, city, country
FROM sales.customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
    AND EXTRACT(YEAR FROM o.order_date) = 2023
)
ORDER BY country, customer_name;

PROMPT ===============================================================================
PROMPT SECTION 3: COMPARISON OPERATORS WITH CORRELATED SUBQUERIES
PROMPT ===============================================================================

-- Using =, <, >, <=, >=, <> with correlated subqueries

-- Example 9: Employees earning less than department average
PROMPT 
PROMPT Example 9: Employees earning less than department average
SELECT employee_id, first_name, last_name, salary, department_id,
       (SELECT ROUND(AVG(salary), 2) 
        FROM employees e2 
        WHERE e2.department_id = e1.department_id) as dept_avg
FROM employees e1
WHERE salary < (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
)
ORDER BY department_id, salary;

-- Example 10: Products with price higher than category average
PROMPT 
PROMPT Example 10: Products priced above category average
SELECT product_id, product_name, unit_price, category_id,
       (SELECT ROUND(AVG(unit_price), 2) 
        FROM sales.products p2 
        WHERE p2.category_id = p1.category_id) as category_avg
FROM sales.products p1
WHERE unit_price > (
    SELECT AVG(unit_price)
    FROM sales.products p2
    WHERE p2.category_id = p1.category_id
)
ORDER BY category_id, unit_price DESC;

-- Example 11: Orders with total higher than customer's average order
PROMPT 
PROMPT Example 11: Orders above customer's average order value
SELECT o.order_id, o.customer_id, o.order_date,
       (SELECT SUM(oi.quantity * oi.unit_price)
        FROM sales.order_items oi
        WHERE oi.order_id = o.order_id) as order_total,
       (SELECT ROUND(AVG(
            (SELECT SUM(oi2.quantity * oi2.unit_price)
             FROM sales.order_items oi2
             WHERE oi2.order_id = o2.order_id)
        ), 2)
        FROM sales.orders o2
        WHERE o2.customer_id = o.customer_id) as customer_avg
FROM sales.orders o
WHERE (
    SELECT SUM(oi.quantity * oi.unit_price)
    FROM sales.order_items oi
    WHERE oi.order_id = o.order_id
) > (
    SELECT AVG(
        (SELECT SUM(oi2.quantity * oi2.unit_price)
         FROM sales.order_items oi2
         WHERE oi2.order_id = o2.order_id)
    )
    FROM sales.orders o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY o.customer_id, o.order_date;

PROMPT ===============================================================================
PROMPT SECTION 4: MULTIPLE CORRELATED SUBQUERIES
PROMPT ===============================================================================

-- Using multiple correlated subqueries in the same query

-- Example 12: Employee analysis with multiple metrics
PROMPT 
PROMPT Example 12: Employee analysis with department comparisons
SELECT 
    e1.employee_id,
    e1.first_name || ' ' || e1.last_name as name,
    e1.salary,
    e1.department_id,
    (SELECT COUNT(*) 
     FROM employees e2 
     WHERE e2.department_id = e1.department_id) as dept_employees,
    (SELECT ROUND(AVG(salary), 2) 
     FROM employees e3 
     WHERE e3.department_id = e1.department_id) as dept_avg_salary,
    (SELECT MAX(salary) 
     FROM employees e4 
     WHERE e4.department_id = e1.department_id) as dept_max_salary,
    CASE 
        WHEN e1.salary = (SELECT MAX(salary) 
                         FROM employees e5 
                         WHERE e5.department_id = e1.department_id) 
        THEN 'Highest Paid'
        WHEN e1.salary > (SELECT AVG(salary) 
                         FROM employees e6 
                         WHERE e6.department_id = e1.department_id) 
        THEN 'Above Average'
        ELSE 'Below Average'
    END as salary_position
FROM employees e1
WHERE department_id IS NOT NULL
ORDER BY department_id, salary DESC;

-- Example 13: Product performance analysis
PROMPT 
PROMPT Example 13: Product performance with category comparisons
SELECT 
    p.product_id,
    p.product_name,
    p.unit_price,
    p.category_id,
    (SELECT COUNT(*) 
     FROM sales.order_items oi 
     WHERE oi.product_id = p.product_id) as times_ordered,
    (SELECT COALESCE(SUM(oi.quantity), 0) 
     FROM sales.order_items oi 
     WHERE oi.product_id = p.product_id) as total_quantity_sold,
    (SELECT COALESCE(SUM(oi.quantity * oi.unit_price), 0) 
     FROM sales.order_items oi 
     WHERE oi.product_id = p.product_id) as total_revenue,
    (SELECT ROUND(AVG(unit_price), 2) 
     FROM sales.products p2 
     WHERE p2.category_id = p.category_id) as category_avg_price
FROM sales.products p
ORDER BY p.category_id, total_revenue DESC NULLS LAST;

PROMPT ===============================================================================
PROMPT SECTION 5: CORRELATED SUBQUERIES IN UPDATE AND DELETE
PROMPT ===============================================================================

-- Correlated subqueries can be used in UPDATE and DELETE statements
-- NOTE: These are examples only - uncomment to actually execute

-- Example 14: Update employee salaries based on department performance
PROMPT 
PROMPT Example 14: Update salaries based on department performance (EXAMPLE ONLY)
/*
UPDATE employees e1
SET salary = salary * 1.05
WHERE department_id IN (
    SELECT department_id
    FROM departments d
    WHERE EXISTS (
        SELECT 1
        FROM employees e2
        WHERE e2.department_id = d.department_id
        GROUP BY e2.department_id
        HAVING AVG(e2.salary) > (
            SELECT AVG(salary)
            FROM employees
        )
    )
);
*/

-- Example 15: Delete orders with no order items
PROMPT 
PROMPT Example 15: Delete orders with no items (EXAMPLE ONLY)
/*
DELETE FROM sales.orders o
WHERE NOT EXISTS (
    SELECT 1
    FROM sales.order_items oi
    WHERE oi.order_id = o.order_id
);
*/

PROMPT ===============================================================================
PROMPT SECTION 6: PERFORMANCE OPTIMIZATION TECHNIQUES
PROMPT ===============================================================================

-- Understanding and optimizing correlated subquery performance

-- Example 16: Compare correlated subquery vs JOIN performance
PROMPT 
PROMPT Example 16a: Using correlated subquery (potentially slower)
SELECT customer_id, customer_name
FROM sales.customers c
WHERE EXISTS (
    SELECT 1
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
    AND EXTRACT(YEAR FROM o.order_date) = 2023
);

PROMPT 
PROMPT Example 16b: Using JOIN (often faster for large datasets)
SELECT DISTINCT c.customer_id, c.customer_name
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2023;

-- Example 17: Optimizing with indexes (conceptual)
PROMPT 
PROMPT Example 17: Index optimization suggestions
PROMPT For better performance on correlated subqueries, consider these indexes:
PROMPT CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
PROMPT CREATE INDEX idx_orders_customer_date ON sales.orders(customer_id, order_date);
PROMPT CREATE INDEX idx_order_items_product ON sales.order_items(product_id);

-- Example 18: Using analytical functions as alternative
PROMPT 
PROMPT Example 18a: Correlated subquery approach
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees e1
WHERE salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e1.department_id
)
ORDER BY department_id, salary DESC;

PROMPT 
PROMPT Example 18b: Analytical function approach (often more efficient)
SELECT employee_id, first_name, last_name, salary, department_id
FROM (
    SELECT employee_id, first_name, last_name, salary, department_id,
           AVG(salary) OVER (PARTITION BY department_id) as dept_avg
    FROM employees
) 
WHERE salary > dept_avg
ORDER BY department_id, salary DESC;

PROMPT ===============================================================================
PROMPT SECTION 7: ADVANCED CORRELATED SUBQUERY PATTERNS
PROMPT ===============================================================================

-- Complex patterns and business scenarios

-- Example 19: Finding gaps in sequences
PROMPT 
PROMPT Example 19: Find missing employee IDs in sequence
SELECT level + 99 as missing_employee_id
FROM dual
CONNECT BY level <= 100
MINUS
SELECT employee_id - 99
FROM employees
WHERE employee_id BETWEEN 100 AND 199
ORDER BY 1;

-- Example 20: Hierarchical analysis with correlated subqueries
PROMPT 
PROMPT Example 20: Manager span of control analysis
SELECT 
    m.employee_id as manager_id,
    m.first_name || ' ' || m.last_name as manager_name,
    (SELECT COUNT(*) 
     FROM employees e 
     WHERE e.manager_id = m.employee_id) as direct_reports,
    (SELECT COUNT(*) 
     FROM employees e 
     WHERE e.manager_id = m.employee_id
     AND EXISTS (
         SELECT 1 
         FROM employees e2 
         WHERE e2.manager_id = e.employee_id
     )) as manager_reports,
    (SELECT ROUND(AVG(salary), 2) 
     FROM employees e 
     WHERE e.manager_id = m.employee_id) as avg_team_salary
FROM employees m
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.manager_id = m.employee_id
)
ORDER BY direct_reports DESC;

-- Example 21: Running totals with correlated subqueries
PROMPT 
PROMPT Example 21: Running total of orders by customer
SELECT 
    o1.order_id,
    o1.customer_id,
    o1.order_date,
    (SELECT SUM(oi.quantity * oi.unit_price)
     FROM sales.order_items oi
     WHERE oi.order_id = o1.order_id) as order_total,
    (SELECT SUM(
        (SELECT SUM(oi2.quantity * oi2.unit_price)
         FROM sales.order_items oi2
         WHERE oi2.order_id = o2.order_id)
     )
     FROM sales.orders o2
     WHERE o2.customer_id = o1.customer_id
     AND o2.order_date <= o1.order_date) as running_total
FROM sales.orders o1
WHERE o1.customer_id = 1
ORDER BY o1.order_date;

PROMPT ===============================================================================
PROMPT SECTION 8: BUSINESS SCENARIO EXERCISES
PROMPT ===============================================================================

-- Real-world business problems solved with correlated subqueries

-- Exercise 1: Customer Loyalty Analysis
PROMPT 
PROMPT Exercise 1: Find loyal customers (multiple orders, high value)
SELECT 
    c.customer_id,
    c.customer_name,
    (SELECT COUNT(*) 
     FROM sales.orders o 
     WHERE o.customer_id = c.customer_id) as order_count,
    (SELECT COALESCE(SUM(
        (SELECT SUM(oi.quantity * oi.unit_price)
         FROM sales.order_items oi
         WHERE oi.order_id = o.order_id)
     ), 0)
     FROM sales.orders o
     WHERE o.customer_id = c.customer_id) as total_spent,
    (SELECT MAX(o.order_date) 
     FROM sales.orders o 
     WHERE o.customer_id = c.customer_id) as last_order_date
FROM sales.customers c
WHERE (
    SELECT COUNT(*) 
    FROM sales.orders o 
    WHERE o.customer_id = c.customer_id
) >= 3
AND (
    SELECT COALESCE(SUM(
        (SELECT SUM(oi.quantity * oi.unit_price)
         FROM sales.order_items oi
         WHERE oi.order_id = o.order_id)
     ), 0)
     FROM sales.orders o
     WHERE o.customer_id = c.customer_id
) > 1000
ORDER BY total_spent DESC;

-- Exercise 2: Product Recommendation Engine
PROMPT 
PROMPT Exercise 2: Products frequently bought together
SELECT DISTINCT
    p1.product_id,
    p1.product_name,
    p2.product_id as recommended_product_id,
    p2.product_name as recommended_product,
    (SELECT COUNT(*)
     FROM sales.order_items oi1
     JOIN sales.order_items oi2 ON oi1.order_id = oi2.order_id
     WHERE oi1.product_id = p1.product_id
     AND oi2.product_id = p2.product_id
     AND oi1.product_id != oi2.product_id) as times_bought_together
FROM sales.products p1, sales.products p2
WHERE p1.product_id != p2.product_id
AND EXISTS (
    SELECT 1
    FROM sales.order_items oi1
    JOIN sales.order_items oi2 ON oi1.order_id = oi2.order_id
    WHERE oi1.product_id = p1.product_id
    AND oi2.product_id = p2.product_id
    AND oi1.product_id != oi2.product_id
)
AND (
    SELECT COUNT(*)
    FROM sales.order_items oi1
    JOIN sales.order_items oi2 ON oi1.order_id = oi2.order_id
    WHERE oi1.product_id = p1.product_id
    AND oi2.product_id = p2.product_id
    AND oi1.product_id != oi2.product_id
) >= 2
ORDER BY p1.product_id, times_bought_together DESC;

-- Exercise 3: Employee Career Path Analysis
PROMPT 
PROMPT Exercise 3: Employees ready for promotion
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.job_id,
    e.hire_date,
    MONTHS_BETWEEN(SYSDATE, e.hire_date) as tenure_months,
    e.salary,
    (SELECT ROUND(AVG(salary), 2) 
     FROM employees e2 
     WHERE e2.job_id = e.job_id) as job_avg_salary,
    (SELECT COUNT(*) 
     FROM employees e3 
     WHERE e3.manager_id = e.employee_id) as direct_reports,
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM employees e4 
            WHERE e4.manager_id = e.employee_id
        ) THEN 'Current Manager'
        ELSE 'Individual Contributor'
    END as current_role_type
FROM employees e
WHERE MONTHS_BETWEEN(SYSDATE, e.hire_date) >= 24  -- At least 2 years tenure
AND e.salary >= (
    SELECT AVG(salary) * 1.1  -- Above average performer
    FROM employees e2
    WHERE e2.job_id = e.job_id
)
AND NOT EXISTS (
    SELECT 1
    FROM employees e3
    WHERE e3.employee_id = e.employee_id
    AND e3.salary >= (
        SELECT MAX(salary) * 0.95  -- Not already at top salary
        FROM employees e4
        WHERE e4.job_id = e3.job_id
    )
)
ORDER BY tenure_months DESC, salary DESC;

PROMPT ===============================================================================
PROMPT SECTION 9: TROUBLESHOOTING AND COMMON MISTAKES
PROMPT ===============================================================================

-- Common issues and how to avoid them

PROMPT 
PROMPT Common Correlated Subquery Mistakes and Solutions:
PROMPT 
PROMPT 1. Performance Issues:
PROMPT    - Problem: Subquery executes for every outer row
PROMPT    - Solution: Consider JOINs or analytical functions
PROMPT    - Use: EXPLAIN PLAN to analyze performance
PROMPT 
PROMPT 2. Null Handling:
PROMPT    - Problem: Unexpected results with NULL values
PROMPT    - Solution: Use COALESCE or NVL functions
PROMPT 
PROMPT 3. Aggregation Errors:
PROMPT    - Problem: Subquery returns multiple rows for scalar context
PROMPT    - Solution: Ensure subquery returns single value
PROMPT 
PROMPT 4. Correlation Reference Errors:
PROMPT    - Problem: Incorrect table aliases in correlation
PROMPT    - Solution: Use clear, distinct aliases

-- Example 22: Proper NULL handling
PROMPT 
PROMPT Example 22: Proper NULL handling in correlated subqueries
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.commission_pct,
    COALESCE(
        (SELECT AVG(commission_pct) 
         FROM employees e2 
         WHERE e2.department_id = e.department_id
         AND e2.commission_pct IS NOT NULL), 
        0
    ) as dept_avg_commission
FROM employees e
WHERE e.department_id IS NOT NULL
ORDER BY e.department_id, e.employee_id;

-- Example 23: Avoiding cartesian products
PROMPT 
PROMPT Example 23: Proper correlation to avoid cartesian products
-- WRONG: This could cause performance issues
/*
SELECT c.customer_name, o.order_date
FROM sales.customers c, sales.orders o
WHERE EXISTS (
    SELECT 1 
    FROM sales.order_items oi 
    WHERE oi.order_id = o.order_id
);
*/

-- CORRECT: Proper correlation
SELECT c.customer_name, 
       (SELECT MIN(o.order_date) 
        FROM sales.orders o 
        WHERE o.customer_id = c.customer_id) as first_order_date
FROM sales.customers c
WHERE EXISTS (
    SELECT 1 
    FROM sales.orders o 
    WHERE o.customer_id = c.customer_id
);

PROMPT ===============================================================================
PROMPT SECTION 10: PRACTICE EXERCISES
PROMPT ===============================================================================

PROMPT 
PROMPT Practice Exercise Solutions:
PROMPT Try to solve these before looking at the solutions below!
PROMPT 
PROMPT Exercise A: Find departments where all employees earn more than $5000
PROMPT Exercise B: Find products that are more expensive than ALL products in category 1
PROMPT Exercise C: Find customers whose average order value is above company average
PROMPT Exercise D: Find employees who joined after their manager
PROMPT Exercise E: Find products that have been ordered in every month of 2023

PROMPT 
PROMPT ===============================================================================
PROMPT SOLUTIONS TO PRACTICE EXERCISES
PROMPT ===============================================================================

-- Solution A: Departments where all employees earn more than $5000
PROMPT 
PROMPT Solution A: Departments where all employees earn > $5000
SELECT d.department_id, d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
    AND e.salary <= 5000
)
AND EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);

-- Solution B: Products more expensive than ALL products in category 1
PROMPT 
PROMPT Solution B: Products more expensive than ALL category 1 products
SELECT product_id, product_name, unit_price, category_id
FROM sales.products p1
WHERE unit_price > ALL (
    SELECT unit_price
    FROM sales.products p2
    WHERE p2.category_id = 1
    AND p2.unit_price IS NOT NULL
)
ORDER BY unit_price;

-- Solution C: Customers with above-average order values
PROMPT 
PROMPT Solution C: Customers with above-average order values
SELECT c.customer_id, c.customer_name,
       (SELECT ROUND(AVG(
            (SELECT SUM(oi.quantity * oi.unit_price)
             FROM sales.order_items oi
             WHERE oi.order_id = o.order_id)
        ), 2)
        FROM sales.orders o
        WHERE o.customer_id = c.customer_id) as customer_avg_order
FROM sales.customers c
WHERE (
    SELECT AVG(
        (SELECT SUM(oi.quantity * oi.unit_price)
         FROM sales.order_items oi
         WHERE oi.order_id = o.order_id)
    )
    FROM sales.orders o
    WHERE o.customer_id = c.customer_id
) > (
    SELECT AVG(
        (SELECT SUM(oi.quantity * oi.unit_price)
         FROM sales.order_items oi
         WHERE oi.order_id = o.order_id)
    )
    FROM sales.orders o
)
ORDER BY customer_avg_order DESC;

-- Solution D: Employees who joined after their manager
PROMPT 
PROMPT Solution D: Employees who joined after their manager
SELECT e.employee_id, e.first_name, e.last_name, e.hire_date, e.manager_id
FROM employees e
WHERE e.manager_id IS NOT NULL
AND e.hire_date > (
    SELECT m.hire_date
    FROM employees m
    WHERE m.employee_id = e.manager_id
)
ORDER BY e.hire_date;

-- Solution E: Products ordered in every month of 2023
PROMPT 
PROMPT Solution E: Products ordered in every month of 2023
SELECT p.product_id, p.product_name
FROM sales.products p
WHERE NOT EXISTS (
    SELECT level as month_num
    FROM dual
    CONNECT BY level <= 12
    MINUS
    SELECT DISTINCT EXTRACT(MONTH FROM o.order_date)
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE oi.product_id = p.product_id
    AND EXTRACT(YEAR FROM o.order_date) = 2023
)
AND EXISTS (
    SELECT 1
    FROM sales.orders o
    JOIN sales.order_items oi ON o.order_id = oi.order_id
    WHERE oi.product_id = p.product_id
    AND EXTRACT(YEAR FROM o.order_date) = 2023
)
ORDER BY p.product_id;

PROMPT ===============================================================================
PROMPT CORRELATED SUBQUERIES PRACTICE COMPLETE
PROMPT ===============================================================================
PROMPT 
PROMPT Key Takeaways:
PROMPT 1. Correlated subqueries execute once for each outer query row
PROMPT 2. EXISTS/NOT EXISTS are highly efficient for existence checks
PROMPT 3. Consider JOINs or analytical functions for better performance
PROMPT 4. Always handle NULL values appropriately
PROMPT 5. Use proper table aliases to avoid ambiguity
PROMPT 6. Test performance with realistic data volumes
PROMPT 7. Consider indexing strategies for optimization
PROMPT 
PROMPT Next Steps:
PROMPT - Practice with your own business scenarios
PROMPT - Compare execution plans of different approaches
PROMPT - Learn about Oracle's cost-based optimizer
PROMPT - Study advanced SQL techniques like window functions
PROMPT 
PROMPT Happy Learning!
PROMPT ===============================================================================

-- End of file
