-- Lesson 4.1: Table Relationships Practice
-- Oracle Database Learning Project
-- File: table-relationships.sql

-- This file contains practical examples for understanding table relationships
-- Run these queries after setting up the HR and SALES sample schemas

-- =============================================================================
-- EXPLORING TABLE RELATIONSHIPS IN HR SCHEMA
-- =============================================================================

-- Example 1: Examine table structures and relationships
-- Check the structure of main HR tables
DESCRIBE hr.employees;
DESCRIBE hr.departments;
DESCRIBE hr.jobs;
DESCRIBE hr.locations;
DESCRIBE hr.countries;

-- Example 2: Identify Primary Keys
-- Primary keys are the unique identifiers for each table
SELECT 
    table_name,
    column_name,
    constraint_name,
    constraint_type
FROM user_constraints uc
JOIN user_cons_columns ucc ON uc.constraint_name = ucc.constraint_name
WHERE uc.constraint_type = 'P'
  AND uc.table_name IN ('EMPLOYEES', 'DEPARTMENTS', 'JOBS', 'LOCATIONS', 'COUNTRIES')
ORDER BY table_name, position;

-- Example 3: Identify Foreign Key Relationships
-- Foreign keys establish relationships between tables
SELECT 
    uc.table_name AS child_table,
    ucc.column_name AS fk_column,
    uc.constraint_name,
    uc.r_constraint_name AS referenced_constraint,
    rt.table_name AS parent_table,
    rcc.column_name AS referenced_column
FROM user_constraints uc
JOIN user_cons_columns ucc ON uc.constraint_name = ucc.constraint_name
JOIN user_constraints rt ON uc.r_constraint_name = rt.constraint_name
JOIN user_cons_columns rcc ON rt.constraint_name = rcc.constraint_name
WHERE uc.constraint_type = 'R'
  AND uc.table_name IN ('EMPLOYEES', 'DEPARTMENTS', 'LOCATIONS')
ORDER BY uc.table_name, ucc.position;

-- =============================================================================
-- ONE-TO-MANY RELATIONSHIP EXAMPLES
-- =============================================================================

-- Example 4: Departments to Employees (1:M)
-- One department can have many employees
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM hr.departments d
LEFT JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC;

-- Example 5: Jobs to Employees (1:M)
-- One job title can be held by many employees
SELECT 
    j.job_title,
    COUNT(e.employee_id) AS employee_count,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary,
    AVG(e.salary) AS avg_salary
FROM hr.jobs j
LEFT JOIN hr.employees e ON j.job_id = e.job_id
GROUP BY j.job_id, j.job_title
ORDER BY employee_count DESC;

-- Example 6: Countries to Locations (1:M)
-- One country can have multiple office locations
SELECT 
    c.country_name,
    COUNT(l.location_id) AS location_count,
    LISTAGG(l.city, ', ') WITHIN GROUP (ORDER BY l.city) AS cities
FROM hr.countries c
LEFT JOIN hr.locations l ON c.country_id = l.country_id
GROUP BY c.country_id, c.country_name
ORDER BY location_count DESC;

-- =============================================================================
-- SELF-REFERENCING RELATIONSHIP EXAMPLES
-- =============================================================================

-- Example 7: Employee Management Hierarchy
-- Employees can manage other employees (self-reference)
SELECT 
    emp.employee_id,
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.manager_id,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    LEVEL AS hierarchy_level
FROM hr.employees emp
LEFT JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id
START WITH emp.manager_id IS NULL  -- Start with top-level managers
CONNECT BY PRIOR emp.employee_id = emp.manager_id
ORDER BY LEVEL, emp.last_name;

-- Example 8: Count Direct Reports
-- How many direct reports does each manager have?
SELECT 
    mgr.employee_id AS manager_id,
    mgr.first_name || ' ' || mgr.last_name AS manager_name,
    COUNT(emp.employee_id) AS direct_reports
FROM hr.employees mgr
LEFT JOIN hr.employees emp ON mgr.employee_id = emp.manager_id
GROUP BY mgr.employee_id, mgr.first_name, mgr.last_name
HAVING COUNT(emp.employee_id) > 0
ORDER BY direct_reports DESC;

-- =============================================================================
-- EXPLORING SALES SCHEMA RELATIONSHIPS
-- =============================================================================

-- Example 9: Sales Schema Table Structures
DESCRIBE sales.customers;
DESCRIBE sales.orders;
DESCRIBE sales.order_items;
DESCRIBE sales.products;

-- Example 10: Customer to Orders Relationship (1:M)
-- One customer can have multiple orders
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.total_amount) AS total_spent,
    MIN(o.order_date) AS first_order,
    MAX(o.order_date) AS latest_order
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC NULLS LAST;

-- Example 11: Orders to Order Items Relationship (1:M)
-- One order can have multiple line items
SELECT 
    o.order_id,
    o.order_date,
    o.total_amount,
    COUNT(oi.product_id) AS item_count,
    SUM(oi.quantity) AS total_quantity
FROM sales.orders o
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, o.total_amount
ORDER BY item_count DESC;

-- =============================================================================
-- MANY-TO-MANY RELATIONSHIP EXAMPLES
-- =============================================================================

-- Example 12: Products to Orders (M:M through ORDER_ITEMS)
-- Products can appear in multiple orders, orders can contain multiple products
SELECT 
    p.product_name,
    COUNT(DISTINCT oi.order_id) AS orders_count,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) AS total_revenue
FROM sales.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC NULLS LAST;

-- Example 13: Product Categories Analysis
-- Analyze the many-to-many relationship resolution
SELECT 
    p.category,
    COUNT(DISTINCT p.product_id) AS products_in_category,
    COUNT(DISTINCT oi.order_id) AS orders_with_category,
    SUM(oi.quantity) AS total_units_sold,
    AVG(oi.unit_price) AS avg_selling_price
FROM sales.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
GROUP BY p.category
ORDER BY total_units_sold DESC NULLS LAST;

-- =============================================================================
-- REFERENTIAL INTEGRITY EXAMPLES
-- =============================================================================

-- Example 14: Check for Orphaned Records
-- Find employees without valid departments
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id
FROM hr.employees e
WHERE e.department_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 
    FROM hr.departments d 
    WHERE d.department_id = e.department_id
  );

-- Example 15: Find Departments Without Employees
-- These are valid but might indicate unused departments
SELECT 
    d.department_id,
    d.department_name,
    d.location_id
FROM hr.departments d
WHERE NOT EXISTS (
    SELECT 1 
    FROM hr.employees e 
    WHERE e.department_id = d.department_id
  );

-- Example 16: Check Sales Data Integrity
-- Find order items without valid products
SELECT 
    oi.order_id,
    oi.product_id,
    oi.quantity,
    oi.unit_price
FROM sales.order_items oi
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales.products p 
    WHERE p.product_id = oi.product_id
  );

-- =============================================================================
-- RELATIONSHIP CARDINALITY ANALYSIS
-- =============================================================================

-- Example 17: Analyze Employee Distribution
-- Understanding the actual cardinality in our data
SELECT 
    'Employees per Department' AS relationship_type,
    AVG(emp_count) AS avg_cardinality,
    MIN(emp_count) AS min_cardinality,
    MAX(emp_count) AS max_cardinality,
    STDDEV(emp_count) AS std_deviation
FROM (
    SELECT COUNT(employee_id) AS emp_count
    FROM hr.employees
    GROUP BY department_id
);

-- Example 18: Product-Order Relationship Analysis
SELECT 
    'Products per Order' AS relationship_type,
    AVG(product_count) AS avg_products_per_order,
    MIN(product_count) AS min_products,
    MAX(product_count) AS max_products
FROM (
    SELECT COUNT(product_id) AS product_count
    FROM sales.order_items
    GROUP BY order_id
)
UNION ALL
SELECT 
    'Orders per Product' AS relationship_type,
    AVG(order_count) AS avg_orders_per_product,
    MIN(order_count) AS min_orders,
    MAX(order_count) AS max_orders
FROM (
    SELECT COUNT(DISTINCT order_id) AS order_count
    FROM sales.order_items
    GROUP BY product_id
);

-- =============================================================================
-- CREATING RELATIONSHIP VIEWS
-- =============================================================================

-- Example 19: Create a Complete Employee View
-- Combines multiple related tables for easy reporting
CREATE OR REPLACE VIEW employee_details AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.salary,
    e.hire_date,
    d.department_name,
    j.job_title,
    l.city AS office_city,
    c.country_name AS office_country,
    mgr.first_name || ' ' || mgr.last_name AS manager_name
FROM hr.employees e
LEFT JOIN hr.departments d ON e.department_id = d.department_id
LEFT JOIN hr.jobs j ON e.job_id = j.job_id
LEFT JOIN hr.locations l ON d.location_id = l.location_id
LEFT JOIN hr.countries c ON l.country_id = c.country_id
LEFT JOIN hr.employees mgr ON e.manager_id = mgr.employee_id;

-- Test the view
SELECT * FROM employee_details WHERE employee_id <= 110;

-- Example 20: Create a Customer Order Summary View
CREATE OR REPLACE VIEW customer_order_summary AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.city,
    c.country,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_spent,
    AVG(o.total_amount) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.city, c.country;

-- Test the view
SELECT * FROM customer_order_summary ORDER BY total_spent DESC;

-- =============================================================================
-- PRACTICE EXERCISES
-- =============================================================================

-- Exercise 1: Hierarchical Analysis
-- Create a query that shows the complete organizational hierarchy
-- Include: Employee level, Department, Manager chain up to CEO
-- Show span of control (number of people in the hierarchy below each person)

-- Your solution here:


-- Exercise 2: Product Performance by Category
-- Analyze the relationship between product categories and sales performance
-- Include: Category, number of products, sales performance, order frequency
-- Identify categories that might need attention

-- Your solution here:


-- Exercise 3: Geographic Business Analysis
-- Use the location relationships to analyze business distribution
-- Include: Countries, cities, departments, employee counts, revenue if available
-- Identify expansion opportunities or consolidation needs

-- Your solution here:


-- Exercise 4: Relationship Integrity Audit
-- Create comprehensive checks for data integrity across all relationships
-- Include: Missing relationships, orphaned records, constraint violations
-- Provide recommendations for data cleanup

-- Your solution here:


-- =============================================================================
-- ADVANCED RELATIONSHIP CONCEPTS
-- =============================================================================

-- Example 21: Recursive Relationship Depth Analysis
-- How deep is our management hierarchy?
WITH hierarchy_depth AS (
    SELECT 
        employee_id,
        manager_id,
        1 AS level
    FROM hr.employees
    WHERE manager_id IS NULL
    
    UNION ALL
    
    SELECT 
        e.employee_id,
        e.manager_id,
        hd.level + 1
    FROM hr.employees e
    JOIN hierarchy_depth hd ON e.manager_id = hd.employee_id
)
SELECT 
    level AS hierarchy_level,
    COUNT(*) AS employees_at_level
FROM hierarchy_depth
GROUP BY level
ORDER BY level;

-- Example 22: Relationship Strength Analysis
-- Analyze how "connected" our data is
SELECT 
    'HR Schema Connectivity' AS analysis,
    (SELECT COUNT(*) FROM hr.employees WHERE department_id IS NOT NULL) AS connected_employees,
    (SELECT COUNT(*) FROM hr.employees) AS total_employees,
    ROUND(
        (SELECT COUNT(*) FROM hr.employees WHERE department_id IS NOT NULL) * 100.0 / 
        (SELECT COUNT(*) FROM hr.employees), 2
    ) AS connectivity_percentage;

-- =============================================================================
-- PERFORMANCE IMPLICATIONS OF RELATIONSHIPS
-- =============================================================================

-- Example 23: Analyze Query Performance with Relationships
-- Explain plan for simple vs complex relationship queries

-- Simple relationship query
EXPLAIN PLAN FOR
SELECT e.first_name, d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Complex multi-table relationship query
EXPLAIN PLAN FOR
SELECT 
    e.first_name,
    d.department_name,
    j.job_title,
    l.city,
    c.country_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.jobs j ON e.job_id = j.job_id
JOIN hr.locations l ON d.location_id = l.location_id
JOIN hr.countries c ON l.country_id = c.country_id;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- =============================================================================
-- CLEANUP
-- =============================================================================

-- Clean up views created during practice
-- DROP VIEW employee_details;
-- DROP VIEW customer_order_summary;

-- =============================================================================
-- KEY TAKEAWAYS
-- =============================================================================

-- 1. Relationships define how tables connect and share data
-- 2. Primary keys uniquely identify records
-- 3. Foreign keys establish and enforce relationships
-- 4. One-to-many is the most common relationship type
-- 5. Many-to-many requires junction/bridge tables
-- 6. Self-referencing tables handle hierarchical data
-- 7. Referential integrity prevents data inconsistencies
-- 8. Understanding relationships is crucial for effective JOINs
-- 9. Complex relationships can impact query performance
-- 10. Views can simplify complex relationship queries

-- =============================================================================
-- NEXT STEPS
-- =============================================================================

-- Now that you understand relationships, you're ready to:
-- 1. Practice INNER JOINs (inner-joins.sql)
-- 2. Learn OUTER JOINs for including unmatched records
-- 3. Master complex multi-table JOIN scenarios
-- 4. Optimize JOIN performance with proper indexing

-- =============================================================================
-- END OF TABLE RELATIONSHIPS PRACTICE
-- =============================================================================
