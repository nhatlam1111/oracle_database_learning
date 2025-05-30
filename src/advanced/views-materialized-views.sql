/*
===============================================================================
VIEWS AND MATERIALIZED VIEWS PRACTICE - Oracle Database Learning
===============================================================================
File: views-materialized-views.sql
Purpose: Comprehensive practice with views and materialized views in Oracle
Author: Oracle Database Learning Project
Created: 2025

This file contains extensive examples and exercises for mastering views and 
materialized views, including creation, management, security, and performance
optimization.

Prerequisites:
- HR and SALES sample schemas loaded
- Understanding of JOIN operations and aggregate functions
- Knowledge of basic SQL syntax and functions

Learning Objectives:
- Master view creation and management
- Understand materialized view benefits and usage
- Implement view-based security strategies
- Practice performance optimization techniques
- Learn view maintenance and troubleshooting
===============================================================================
*/

-- Set environment for better output
SET PAGESIZE 50
SET LINESIZE 120
SET SERVEROUTPUT ON

PROMPT ===============================================================================
PROMPT SECTION 1: SIMPLE VIEWS - GETTING STARTED
PROMPT ===============================================================================

-- Simple views are based on single tables and are usually updatable

-- Example 1: Basic employee information view
PROMPT 
PROMPT Example 1: Creating a basic employee view
CREATE OR REPLACE VIEW employee_basic AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    phone_number,
    hire_date,
    job_id,
    department_id
FROM employees
ORDER BY last_name, first_name;

-- Query the view
SELECT * FROM employee_basic WHERE department_id = 20;

-- Example 2: Active products view with filtering
PROMPT 
PROMPT Example 2: Active products view
CREATE OR REPLACE VIEW active_products AS
SELECT 
    product_id,
    product_name,
    category_id,
    unit_price,
    units_in_stock,
    discontinued
FROM sales.products
WHERE discontinued = 'N'
AND units_in_stock > 0
WITH READ ONLY;

-- Test the view
SELECT product_name, unit_price, units_in_stock 
FROM active_products 
WHERE category_id = 1
ORDER BY unit_price DESC;

-- Example 3: Customer contact view with renamed columns
PROMPT 
PROMPT Example 3: Customer contact information
CREATE OR REPLACE VIEW customer_contacts AS
SELECT 
    customer_id as "Customer ID",
    customer_name as "Company Name",
    contact_name as "Contact Person",
    phone as "Phone Number",
    email as "Email Address",
    city as "City",
    country as "Country"
FROM sales.customers
ORDER BY customer_name;

-- Query with user-friendly column names
SELECT "Company Name", "Contact Person", "City", "Country"
FROM customer_contacts 
WHERE "Country" = 'USA'
FETCH FIRST 10 ROWS ONLY;

PROMPT ===============================================================================
PROMPT SECTION 2: COMPLEX VIEWS - MULTIPLE TABLES AND CALCULATIONS
PROMPT ===============================================================================

-- Complex views involve JOINs, calculations, and advanced SQL features

-- Example 4: Employee department details view
PROMPT 
PROMPT Example 4: Employee with department and location details
CREATE OR REPLACE VIEW employee_full_details AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    e.email,
    e.phone_number,
    e.hire_date,
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12, 1) as years_employed,
    e.salary,
    CASE 
        WHEN e.salary >= 15000 THEN 'Executive'
        WHEN e.salary >= 10000 THEN 'Senior'
        WHEN e.salary >= 5000 THEN 'Mid-Level'
        ELSE 'Entry-Level'
    END as salary_grade,
    j.job_title,
    d.department_name,
    l.city || ', ' || l.state_province || ', ' || l.country_id as location,
    m.first_name || ' ' || m.last_name as manager_name,
    CASE 
        WHEN e.commission_pct IS NOT NULL THEN 'Commission-Based'
        ELSE 'Salary-Only'
    END as compensation_type
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- Test the complex view
SELECT full_name, salary_grade, department_name, years_employed, manager_name
FROM employee_full_details
WHERE department_name LIKE '%Sales%'
ORDER BY salary DESC;

-- Example 5: Sales performance analysis view
PROMPT 
PROMPT Example 5: Comprehensive sales analysis view
CREATE OR REPLACE VIEW sales_performance_analysis AS
SELECT 
    c.customer_id,
    c.customer_name,
    c.city,
    c.country,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT oi.product_id) as unique_products_ordered,
    MIN(o.order_date) as first_order_date,
    MAX(o.order_date) as last_order_date,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) as avg_order_line_value,
    SUM(oi.quantity) as total_quantity_purchased,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) as avg_order_value,
    CASE 
        WHEN COUNT(DISTINCT o.order_id) >= 10 THEN 'VIP Customer'
        WHEN COUNT(DISTINCT o.order_id) >= 5 THEN 'Regular Customer'
        WHEN COUNT(DISTINCT o.order_id) >= 2 THEN 'Occasional Customer'
        ELSE 'New Customer'
    END as customer_tier,
    CASE 
        WHEN MAX(o.order_date) >= ADD_MONTHS(SYSDATE, -3) THEN 'Active'
        WHEN MAX(o.order_date) >= ADD_MONTHS(SYSDATE, -12) THEN 'Inactive'
        ELSE 'Dormant'
    END as customer_status
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.city, c.country;

-- Analyze customer performance
SELECT customer_name, customer_tier, customer_status, total_orders, total_revenue
FROM sales_performance_analysis
WHERE customer_tier IN ('VIP Customer', 'Regular Customer')
ORDER BY total_revenue DESC
FETCH FIRST 15 ROWS ONLY;

-- Example 6: Product profitability view
PROMPT 
PROMPT Example 6: Product profitability analysis
CREATE OR REPLACE VIEW product_profitability AS
SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    p.unit_price as list_price,
    p.units_in_stock,
    COUNT(oi.order_id) as times_ordered,
    COALESCE(SUM(oi.quantity), 0) as total_quantity_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) as total_revenue,
    COALESCE(ROUND(AVG(oi.unit_price), 2), p.unit_price) as avg_selling_price,
    CASE 
        WHEN COUNT(oi.order_id) = 0 THEN 'Never Ordered'
        WHEN COUNT(oi.order_id) >= 50 THEN 'Best Seller'
        WHEN COUNT(oi.order_id) >= 20 THEN 'Popular'
        WHEN COUNT(oi.order_id) >= 5 THEN 'Moderate'
        ELSE 'Slow Moving'
    END as sales_performance,
    RANK() OVER (PARTITION BY p.category_id ORDER BY COALESCE(SUM(oi.quantity * oi.unit_price), 0) DESC) as category_rank,
    CASE 
        WHEN p.units_in_stock = 0 THEN 'Out of Stock'
        WHEN p.units_in_stock <= 10 THEN 'Low Stock'
        WHEN p.units_in_stock <= 50 THEN 'Normal Stock'
        ELSE 'High Stock'
    END as stock_status
FROM sales.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category_id, p.unit_price, p.units_in_stock;

-- Find top performers by category
SELECT product_name, category_id, sales_performance, total_revenue, category_rank
FROM product_profitability
WHERE category_rank <= 3
ORDER BY category_id, category_rank;

PROMPT ===============================================================================
PROMPT SECTION 3: UPDATABLE VIEWS AND WITH CHECK OPTION
PROMPT ===============================================================================

-- Understanding when views can be updated and how to control updates

-- Example 7: Simple updatable view
PROMPT 
PROMPT Example 7: Updatable employee view for department 20
CREATE OR REPLACE VIEW dept_20_employees AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    phone_number,
    hire_date,
    job_id,
    salary,
    commission_pct,
    department_id
FROM employees
WHERE department_id = 20
WITH CHECK OPTION CONSTRAINT dept_20_check;

-- Test updatability (these operations would work in a real scenario)
PROMPT 
PROMPT Testing view updatability (examples - would work with proper permissions):

-- This would work - updating within the same department
/*
UPDATE dept_20_employees 
SET salary = salary * 1.05 
WHERE employee_id = (SELECT MIN(employee_id) FROM dept_20_employees);
*/

-- This would fail due to CHECK OPTION - moving to different department
/*
UPDATE dept_20_employees 
SET department_id = 30 
WHERE employee_id = (SELECT MIN(employee_id) FROM dept_20_employees);
-- ORA-01402: view WITH CHECK OPTION where-clause violation
*/

-- This would work - inserting into department 20
/*
INSERT INTO dept_20_employees (
    employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id
) VALUES (
    999, 'Test', 'Employee', 'test@company.com', SYSDATE, 'IT_PROG', 5000, 20
);
*/

-- This would fail - inserting into different department
/*
INSERT INTO dept_20_employees (
    employee_id, first_name, last_name, email, hire_date, job_id, salary, department_id
) VALUES (
    998, 'Test2', 'Employee2', 'test2@company.com', SYSDATE, 'IT_PROG', 5000, 30
);
-- ORA-01402: view WITH CHECK OPTION where-clause violation
*/

-- Example 8: Read-only view for security
PROMPT 
PROMPT Example 8: Read-only salary information view
CREATE OR REPLACE VIEW employee_salary_summary AS
SELECT 
    d.department_name,
    COUNT(*) as employee_count,
    MIN(e.salary) as min_salary,
    MAX(e.salary) as max_salary,
    ROUND(AVG(e.salary), 2) as avg_salary,
    SUM(e.salary) as total_salary
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name
WITH READ ONLY;

-- This view cannot be updated (INSERT/UPDATE/DELETE will fail)
SELECT * FROM employee_salary_summary ORDER BY avg_salary DESC;

PROMPT ===============================================================================
PROMPT SECTION 4: MATERIALIZED VIEWS - PERFORMANCE OPTIMIZATION
PROMPT ===============================================================================

-- Materialized views store results physically for improved performance

-- Example 9: Monthly sales summary materialized view
PROMPT 
PROMPT Example 9: Creating monthly sales summary materialized view
CREATE MATERIALIZED VIEW mv_monthly_sales_summary
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT 
    EXTRACT(YEAR FROM o.order_date) as sales_year,
    EXTRACT(MONTH FROM o.order_date) as sales_month,
    TO_CHAR(o.order_date, 'YYYY-MM') as year_month,
    TO_CHAR(o.order_date, 'Month YYYY') as month_name,
    COUNT(DISTINCT o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    COUNT(DISTINCT oi.product_id) as unique_products,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) as avg_line_value,
    ROUND(SUM(oi.quantity * oi.unit_price) / COUNT(DISTINCT o.order_id), 2) as avg_order_value
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY 
    EXTRACT(YEAR FROM o.order_date),
    EXTRACT(MONTH FROM o.order_date),
    TO_CHAR(o.order_date, 'YYYY-MM'),
    TO_CHAR(o.order_date, 'Month YYYY');

-- Query the materialized view (very fast)
SELECT year_month, month_name, total_orders, unique_customers, total_revenue
FROM mv_monthly_sales_summary
ORDER BY sales_year, sales_month;

-- Example 10: Product category performance materialized view
PROMPT 
PROMPT Example 10: Product category performance materialized view
CREATE MATERIALIZED VIEW mv_category_performance
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    p.category_id,
    COUNT(DISTINCT p.product_id) as products_in_category,
    COUNT(DISTINCT oi.order_id) as orders_with_category,
    COUNT(DISTINCT o.customer_id) as customers_buying_category,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as total_category_revenue,
    ROUND(AVG(oi.unit_price), 2) as avg_selling_price,
    MIN(oi.unit_price) as min_selling_price,
    MAX(oi.unit_price) as max_selling_price,
    ROUND(SUM(oi.quantity * oi.unit_price) / NULLIF(COUNT(DISTINCT oi.order_id), 0), 2) as revenue_per_order,
    ROUND(SUM(oi.quantity) / NULLIF(COUNT(DISTINCT oi.order_id), 0), 2) as avg_quantity_per_order
FROM sales.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
LEFT JOIN sales.orders o ON oi.order_id = o.order_id
GROUP BY p.category_id;

-- Analyze category performance
SELECT * FROM mv_category_performance 
ORDER BY total_category_revenue DESC NULLS LAST;

-- Example 11: Customer geographic analysis materialized view
PROMPT 
PROMPT Example 11: Customer geographic distribution materialized view
CREATE MATERIALIZED VIEW mv_geographic_analysis
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    c.country,
    c.city,
    COUNT(DISTINCT c.customer_id) as total_customers,
    COUNT(DISTINCT o.order_id) as total_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) as total_revenue,
    ROUND(COALESCE(AVG(oi.quantity * oi.unit_price), 0), 2) as avg_order_line_value,
    COUNT(DISTINCT CASE WHEN o.order_date >= ADD_MONTHS(SYSDATE, -12) THEN o.order_id END) as orders_last_12_months,
    COALESCE(SUM(CASE WHEN o.order_date >= ADD_MONTHS(SYSDATE, -12) 
                     THEN oi.quantity * oi.unit_price END), 0) as revenue_last_12_months
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.country, c.city;

-- Geographic performance analysis
SELECT country, 
       SUM(total_customers) as customers_by_country,
       SUM(total_revenue) as revenue_by_country,
       COUNT(DISTINCT city) as cities_in_country
FROM mv_geographic_analysis
GROUP BY country
ORDER BY revenue_by_country DESC NULLS LAST;

PROMPT ===============================================================================
PROMPT SECTION 5: MATERIALIZED VIEW MANAGEMENT
PROMPT ===============================================================================

-- Managing materialized view refresh and monitoring

-- Check materialized view information
PROMPT 
PROMPT Materialized View Information:
SELECT 
    mview_name,
    refresh_mode,
    refresh_method,
    build_mode,
    last_refresh_date,
    staleness,
    compile_state
FROM user_mviews
ORDER BY mview_name;

-- Manual refresh example
PROMPT 
PROMPT Manual refresh of materialized views:
-- Note: These commands would work in a real environment
-- EXEC DBMS_MVIEW.REFRESH('MV_MONTHLY_SALES_SUMMARY', 'C');
-- EXEC DBMS_MVIEW.REFRESH('MV_CATEGORY_PERFORMANCE', 'C');
-- EXEC DBMS_MVIEW.REFRESH('MV_GEOGRAPHIC_ANALYSIS', 'C');

-- Check refresh history
PROMPT 
PROMPT Materialized View Refresh History:
SELECT 
    mview_name,
    refresh_date,
    refresh_method,
    refresh_complete
FROM user_mview_refresh_times
WHERE refresh_date >= SYSDATE - 7  -- Last 7 days
ORDER BY refresh_date DESC;

PROMPT ===============================================================================
PROMPT SECTION 6: VIEW-BASED SECURITY EXAMPLES
PROMPT ===============================================================================

-- Using views to implement security and data access control

-- Example 12: Column-level security view
PROMPT 
PROMPT Example 12: Public employee information (hiding sensitive data)
CREATE OR REPLACE VIEW employee_public_info AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    hire_date,
    job_id,
    department_id,
    -- Salary and sensitive information excluded
    CASE 
        WHEN MONTHS_BETWEEN(SYSDATE, hire_date) >= 60 THEN 'Veteran'
        WHEN MONTHS_BETWEEN(SYSDATE, hire_date) >= 24 THEN 'Experienced'
        ELSE 'New'
    END as experience_level
FROM employees
WITH READ ONLY;

-- Users can access this view instead of the full employees table
SELECT * FROM employee_public_info WHERE department_id = 20;

-- Example 13: Row-level security view
PROMPT 
PROMPT Example 13: Department manager view (row-level security)
CREATE OR REPLACE VIEW manager_department_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.hire_date,
    e.department_id,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.department_id IN (
    -- This would typically use application context or user functions
    -- For demo, showing employees in departments 20, 50, 80
    20, 50, 80
)
WITH READ ONLY;

-- Example 14: Time-based security view
PROMPT 
PROMPT Example 14: Current period data only
CREATE OR REPLACE VIEW current_period_orders AS
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.shipped_date,
    o.status,
    SUM(oi.quantity * oi.unit_price) as order_total
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE o.order_date >= TRUNC(SYSDATE, 'YEAR')  -- Current year only
GROUP BY o.order_id, o.customer_id, o.order_date, o.shipped_date, o.status
WITH READ ONLY;

-- Users can only see current year data
SELECT * FROM current_period_orders ORDER BY order_date DESC FETCH FIRST 10 ROWS ONLY;

PROMPT ===============================================================================
PROMPT SECTION 7: PERFORMANCE COMPARISON AND OPTIMIZATION
PROMPT ===============================================================================

-- Comparing view performance and optimization techniques

-- Example 15: Performance comparison - View vs Materialized View
PROMPT 
PROMPT Example 15: Performance comparison setup

-- Regular view (recalculates every time)
CREATE OR REPLACE VIEW view_sales_summary AS
SELECT 
    p.category_id,
    COUNT(*) as order_lines,
    SUM(oi.quantity) as total_quantity,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    ROUND(AVG(oi.unit_price), 2) as avg_price
FROM sales.order_items oi
JOIN sales.products p ON oi.product_id = p.product_id
GROUP BY p.category_id;

-- Compare execution time (in a real environment, you would use timing)
PROMPT 
PROMPT Regular view query (recalculates each time):
SELECT * FROM view_sales_summary ORDER BY total_revenue DESC;

PROMPT 
PROMPT Materialized view query (pre-calculated):
SELECT 
    category_id,
    total_quantity_sold as total_quantity,
    total_category_revenue as total_revenue,
    avg_selling_price as avg_price
FROM mv_category_performance
WHERE total_category_revenue IS NOT NULL
ORDER BY total_category_revenue DESC;

-- Example 16: View optimization with proper indexing
PROMPT 
PROMPT Example 16: Index recommendations for view performance
PROMPT 
PROMPT Consider creating these indexes for better view performance:
PROMPT -- For employee views
PROMPT CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
PROMPT CREATE INDEX idx_employees_hire_date ON employees(hire_date);
PROMPT 
PROMPT -- For sales analysis views  
PROMPT CREATE INDEX idx_orders_customer_date ON sales.orders(customer_id, order_date);
PROMPT CREATE INDEX idx_order_items_product ON sales.order_items(product_id);
PROMPT CREATE INDEX idx_products_category ON sales.products(category_id);

PROMPT ===============================================================================
PROMPT SECTION 8: ADVANCED VIEW TECHNIQUES
PROMPT ===============================================================================

-- Advanced patterns and techniques with views

-- Example 17: Hierarchical view with CONNECT BY
PROMPT 
PROMPT Example 17: Employee hierarchy view
CREATE OR REPLACE VIEW employee_hierarchy AS
SELECT 
    employee_id,
    first_name || ' ' || last_name as employee_name,
    manager_id,
    LEVEL as hierarchy_level,
    SYS_CONNECT_BY_PATH(first_name || ' ' || last_name, ' > ') as hierarchy_path,
    CONNECT_BY_ROOT (first_name || ' ' || last_name) as top_manager,
    CONNECT_BY_ISLEAF as is_leaf_node
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name, first_name;

-- Show organizational structure
SELECT 
    LPAD(' ', (hierarchy_level - 1) * 2) || employee_name as org_chart,
    hierarchy_level,
    CASE WHEN is_leaf_node = 1 THEN 'Individual Contributor' ELSE 'Manager' END as role_type
FROM employee_hierarchy
WHERE hierarchy_level <= 4  -- Limit depth for readability
ORDER BY hierarchy_path;

-- Example 18: Pivot-style view for reporting
PROMPT 
PROMPT Example 18: Monthly sales pivot view
CREATE OR REPLACE VIEW monthly_sales_pivot AS
SELECT 
    sales_year,
    SUM(CASE WHEN sales_month = 1 THEN total_revenue END) as "Jan",
    SUM(CASE WHEN sales_month = 2 THEN total_revenue END) as "Feb", 
    SUM(CASE WHEN sales_month = 3 THEN total_revenue END) as "Mar",
    SUM(CASE WHEN sales_month = 4 THEN total_revenue END) as "Apr",
    SUM(CASE WHEN sales_month = 5 THEN total_revenue END) as "May",
    SUM(CASE WHEN sales_month = 6 THEN total_revenue END) as "Jun",
    SUM(CASE WHEN sales_month = 7 THEN total_revenue END) as "Jul",
    SUM(CASE WHEN sales_month = 8 THEN total_revenue END) as "Aug",
    SUM(CASE WHEN sales_month = 9 THEN total_revenue END) as "Sep",
    SUM(CASE WHEN sales_month = 10 THEN total_revenue END) as "Oct",
    SUM(CASE WHEN sales_month = 11 THEN total_revenue END) as "Nov",
    SUM(CASE WHEN sales_month = 12 THEN total_revenue END) as "Dec",
    SUM(total_revenue) as "Total"
FROM mv_monthly_sales_summary
GROUP BY sales_year
ORDER BY sales_year;

-- Show yearly sales by month
SELECT * FROM monthly_sales_pivot;

-- Example 19: Union view combining multiple sources
PROMPT 
PROMPT Example 19: Combined employee contact information
CREATE OR REPLACE VIEW all_employee_contacts AS
-- Current employees
SELECT 
    'EMPLOYEE' as contact_type,
    employee_id as id,
    first_name || ' ' || last_name as name,
    email,
    phone_number as phone,
    'ACTIVE' as status,
    hire_date as start_date,
    department_id
FROM employees
UNION ALL
-- Former employees (if we had such a table)
SELECT 
    'FORMER_EMPLOYEE' as contact_type,
    employee_id as id,
    first_name || ' ' || last_name as name,
    email,
    phone_number as phone,
    'INACTIVE' as status,
    hire_date as start_date,
    department_id
FROM employees
WHERE 1 = 0  -- Placeholder - no actual former employee table
UNION ALL
-- Emergency contacts (if we had such data)
SELECT 
    'EMERGENCY_CONTACT' as contact_type,
    employee_id as id,
    'Emergency Contact' as name,
    NULL as email,
    phone_number as phone,
    'EMERGENCY' as status,
    NULL as start_date,
    NULL as department_id
FROM employees
WHERE 1 = 0;  -- Placeholder

PROMPT ===============================================================================
PROMPT SECTION 9: VIEW MAINTENANCE AND TROUBLESHOOTING
PROMPT ===============================================================================

-- Monitoring and maintaining views

-- Example 20: View health check queries
PROMPT 
PROMPT Example 20: View health check and maintenance queries

-- Check view compilation status
PROMPT 
PROMPT Checking view compilation status:
SELECT 
    object_name as view_name,
    object_type,
    status,
    created,
    last_ddl_time
FROM user_objects 
WHERE object_type = 'VIEW'
ORDER BY object_name;

-- Check for invalid views
PROMPT 
PROMPT Checking for invalid views:
SELECT 
    object_name as invalid_view,
    status,
    created,
    last_ddl_time
FROM user_objects 
WHERE object_type = 'VIEW' 
AND status = 'INVALID'
ORDER BY object_name;

-- View dependencies
PROMPT 
PROMPT View dependencies:
SELECT 
    name as view_name,
    type,
    referenced_name,
    referenced_type
FROM user_dependencies 
WHERE type = 'VIEW'
ORDER BY name, referenced_name;

-- Check materialized view space usage
PROMPT 
PROMPT Materialized view space usage:
SELECT 
    segment_name as mview_name,
    segment_type,
    bytes / 1024 / 1024 as size_mb,
    blocks,
    extents
FROM user_segments 
WHERE segment_type = 'TABLE'
AND segment_name LIKE 'MV_%'
ORDER BY bytes DESC;

PROMPT ===============================================================================
PROMPT SECTION 10: PRACTICAL EXERCISES AND BUSINESS SCENARIOS
PROMPT ===============================================================================

-- Real-world view applications

-- Exercise 1: Create a comprehensive dashboard view
PROMPT 
PROMPT Exercise 1: Executive dashboard view
CREATE OR REPLACE VIEW executive_dashboard AS
SELECT 
    'EMPLOYEES' as metric_category,
    'Total Employees' as metric_name,
    COUNT(*) as metric_value,
    'COUNT' as metric_type,
    SYSDATE as last_updated
FROM employees
UNION ALL
SELECT 
    'EMPLOYEES' as metric_category,
    'Average Salary' as metric_name,
    ROUND(AVG(salary), 2) as metric_value,
    'CURRENCY' as metric_type,
    SYSDATE as last_updated
FROM employees
UNION ALL
SELECT 
    'SALES' as metric_category,
    'Total Orders' as metric_name,
    COUNT(*) as metric_value,
    'COUNT' as metric_type,
    SYSDATE as last_updated
FROM sales.orders
UNION ALL
SELECT 
    'SALES' as metric_category,
    'Total Revenue' as metric_name,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) as metric_value,
    'CURRENCY' as metric_type,
    SYSDATE as last_updated
FROM sales.orders o
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
UNION ALL
SELECT 
    'PRODUCTS' as metric_category,
    'Active Products' as metric_name,
    COUNT(*) as metric_value,
    'COUNT' as metric_type,
    SYSDATE as last_updated
FROM sales.products
WHERE discontinued = 'N';

-- Display executive dashboard
SELECT 
    metric_category,
    metric_name,
    CASE 
        WHEN metric_type = 'CURRENCY' THEN '$' || TO_CHAR(metric_value, '999,999,999.99')
        ELSE TO_CHAR(metric_value, '999,999,999')
    END as formatted_value
FROM executive_dashboard
ORDER BY metric_category, metric_name;

-- Exercise 2: Customer segmentation view
PROMPT 
PROMPT Exercise 2: Customer segmentation view
CREATE OR REPLACE VIEW customer_segmentation AS
WITH customer_metrics AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.country,
        COUNT(DISTINCT o.order_id) as order_count,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) as total_spent,
        COALESCE(MAX(o.order_date), c.created_date) as last_activity,
        MONTHS_BETWEEN(SYSDATE, COALESCE(MAX(o.order_date), c.created_date)) as months_since_activity
    FROM sales.customers c
    LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
    LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, c.customer_name, c.country, c.created_date
)
SELECT 
    customer_id,
    customer_name,
    country,
    order_count,
    total_spent,
    last_activity,
    months_since_activity,
    CASE 
        WHEN total_spent >= 5000 AND order_count >= 10 THEN 'VIP'
        WHEN total_spent >= 2000 AND order_count >= 5 THEN 'Premium'
        WHEN total_spent >= 500 AND order_count >= 2 THEN 'Standard'
        WHEN order_count >= 1 THEN 'Basic'
        ELSE 'Prospect'
    END as customer_segment,
    CASE 
        WHEN months_since_activity <= 3 THEN 'Active'
        WHEN months_since_activity <= 12 THEN 'Inactive'
        ELSE 'Dormant'
    END as activity_status,
    CASE 
        WHEN total_spent >= 5000 AND months_since_activity <= 3 THEN 'Retain'
        WHEN total_spent >= 2000 AND months_since_activity > 6 THEN 'Win Back'
        WHEN total_spent < 500 AND months_since_activity <= 6 THEN 'Grow'
        WHEN order_count = 0 THEN 'Convert'
        ELSE 'Monitor'
    END as recommended_action
FROM customer_metrics;

-- Analyze customer segments
SELECT 
    customer_segment,
    activity_status,
    COUNT(*) as customer_count,
    ROUND(AVG(total_spent), 2) as avg_spent,
    ROUND(AVG(order_count), 1) as avg_orders
FROM customer_segmentation
GROUP BY customer_segment, activity_status
ORDER BY customer_segment, activity_status;

PROMPT ===============================================================================
PROMPT VIEWS AND MATERIALIZED VIEWS PRACTICE COMPLETE
PROMPT ===============================================================================
PROMPT 
PROMPT Key Takeaways:
PROMPT 1. Simple views provide data abstraction and security
PROMPT 2. Complex views can combine multiple tables and calculations
PROMPT 3. Materialized views offer significant performance benefits
PROMPT 4. Views are excellent for implementing security policies
PROMPT 5. Proper indexing is crucial for view performance
PROMPT 6. Regular maintenance and monitoring keep views healthy
PROMPT 7. Views enable flexible reporting and analytics
PROMPT 
PROMPT Best Practices Applied:
PROMPT - Used clear, descriptive view names
PROMPT - Implemented proper security with READ ONLY and CHECK OPTION
PROMPT - Created materialized views for performance-critical queries
PROMPT - Documented view purposes and dependencies
PROMPT - Included error handling and validation
PROMPT - Designed views for maintainability and reusability
PROMPT 
PROMPT Next Steps:
PROMPT - Practice creating views for your specific business needs
PROMPT - Experiment with materialized view refresh strategies
PROMPT - Implement view-based security in your applications
PROMPT - Monitor view performance and optimize as needed
PROMPT - Learn about Oracle's automatic query rewrite features
PROMPT 
PROMPT Happy Learning!
PROMPT ===============================================================================

-- End of file
