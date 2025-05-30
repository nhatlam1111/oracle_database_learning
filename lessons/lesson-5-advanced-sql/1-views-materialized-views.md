# Views and Materialized Views

Views are one of the most important concepts in database design, providing data abstraction, security, and simplified access to complex queries. Materialized views take this concept further by physically storing query results for improved performance.

## 🎯 Learning Objectives

By the end of this section, you will understand:

1. **View Fundamentals**: What views are and why they're essential
2. **View Creation and Management**: Creating, modifying, and dropping views
3. **View Types**: Simple views vs complex views
4. **Materialized Views**: Performance benefits and use cases
5. **View Security**: Using views for data access control
6. **Performance Considerations**: When and how to use views effectively

## 📖 Table of Contents

1. [Understanding Views](#understanding-views)
2. [Creating Simple Views](#creating-simple-views)
3. [Complex Views](#complex-views)
4. [Updatable Views](#updatable-views)
5. [Materialized Views](#materialized-views)
6. [View Security](#view-security)
7. [Performance Considerations](#performance-considerations)
8. [Best Practices](#best-practices)

---

## Understanding Views

### What is a View?

A **view** is a virtual table that is based on the result set of a SELECT statement. Views don't store data themselves; they dynamically retrieve data from underlying tables when queried.

**Key Characteristics:**
- **Virtual Table**: No physical storage of data
- **Dynamic**: Always shows current data from base tables
- **Simplified Access**: Hide complex queries behind simple interfaces
- **Security Layer**: Control access to sensitive data
- **Data Abstraction**: Present data in different formats

### Types of Views

#### 1. Simple Views
- Based on a single table
- No functions or calculations
- Usually updatable

#### 2. Complex Views
- Based on multiple tables
- May include JOINs, functions, GROUP BY
- Usually read-only

#### 3. Materialized Views
- Physical storage of query results
- Refreshed periodically or on-demand
- Significant performance benefits

### Benefits of Using Views

#### **Data Security**
```sql
-- Hide sensitive salary information
CREATE VIEW employee_public_info AS
SELECT employee_id, first_name, last_name, email, hire_date, department_id
FROM employees;
-- Salary column is not exposed
```

#### **Query Simplification**
```sql
-- Complex query simplified into a view
CREATE VIEW employee_department_summary AS
SELECT 
    d.department_name,
    COUNT(e.employee_id) as employee_count,
    ROUND(AVG(e.salary), 2) as avg_salary,
    MIN(e.hire_date) as oldest_hire_date
FROM employees e
JOIN departments d ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name;

-- Now users can simply query:
SELECT * FROM employee_department_summary;
```

#### **Data Abstraction**
```sql
-- Present data in business-friendly format
CREATE VIEW sales_summary AS
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') as sales_month,
    COUNT(o.order_id) as total_orders,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    COUNT(DISTINCT o.customer_id) as unique_customers
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY sales_month;
```

---

## Creating Simple Views

### Basic Syntax

```sql
CREATE [OR REPLACE] VIEW view_name AS
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
[WITH CHECK OPTION]
[WITH READ ONLY];
```

### Simple View Examples

#### Example 1: Basic Employee View
```sql
-- Create a simple view showing active employees
CREATE OR REPLACE VIEW active_employees AS
SELECT employee_id, first_name, last_name, email, hire_date, department_id
FROM employees
WHERE hire_date <= SYSDATE;

-- Query the view
SELECT * FROM active_employees WHERE department_id = 20;
```

#### Example 2: Filtered Product View
```sql
-- View showing only products in stock
CREATE OR REPLACE VIEW products_in_stock AS
SELECT product_id, product_name, category_id, unit_price
FROM sales.products
WHERE units_in_stock > 0
WITH READ ONLY;
```

#### Example 3: Renamed Column View
```sql
-- View with user-friendly column names
CREATE OR REPLACE VIEW customer_list AS
SELECT 
    customer_id as "Customer ID",
    customer_name as "Customer Name", 
    city as "City",
    country as "Country",
    phone as "Phone Number"
FROM sales.customers
ORDER BY customer_name;
```

### View Metadata

```sql
-- Check view definition
SELECT text FROM user_views WHERE view_name = 'ACTIVE_EMPLOYEES';

-- List all views owned by current user
SELECT view_name, text FROM user_views ORDER BY view_name;

-- Check view columns
SELECT column_name, data_type, nullable 
FROM user_tab_columns 
WHERE table_name = 'ACTIVE_EMPLOYEES';
```

---

## Complex Views

Complex views involve multiple tables, functions, and advanced SQL features.

### Multi-Table Views

#### Example 1: Employee Department View
```sql
CREATE OR REPLACE VIEW employee_details AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as full_name,
    e.email,
    e.hire_date,
    e.salary,
    d.department_name,
    l.city || ', ' || l.country as location,
    j.job_title,
    m.first_name || ' ' || m.last_name as manager_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN locations l ON d.location_id = l.location_id
LEFT JOIN jobs j ON e.job_id = j.job_id
LEFT JOIN employees m ON e.manager_id = m.employee_id;
```

#### Example 2: Sales Analysis View
```sql
CREATE OR REPLACE VIEW sales_analysis AS
SELECT 
    c.customer_name,
    c.city,
    c.country,
    COUNT(o.order_id) as total_orders,
    MIN(o.order_date) as first_order,
    MAX(o.order_date) as last_order,
    SUM(oi.quantity * oi.unit_price) as total_spent,
    ROUND(AVG(oi.quantity * oi.unit_price), 2) as avg_order_value,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) as customer_rank
FROM sales.customers c
LEFT JOIN sales.orders o ON c.customer_id = o.customer_id
LEFT JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name, c.city, c.country;
```

### Views with Calculations

#### Example 3: Employee Performance Metrics
```sql
CREATE OR REPLACE VIEW employee_performance AS
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name as employee_name,
    e.hire_date,
    MONTHS_BETWEEN(SYSDATE, e.hire_date) as tenure_months,
    e.salary,
    CASE 
        WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) < 12 THEN 'New Employee'
        WHEN MONTHS_BETWEEN(SYSDATE, e.hire_date) < 60 THEN 'Experienced'
        ELSE 'Veteran'
    END as experience_level,
    ROUND((e.salary / dept_avg.avg_salary) * 100, 2) as salary_vs_dept_avg,
    CASE 
        WHEN e.commission_pct IS NOT NULL THEN 'Commission'
        ELSE 'Salary Only'
    END as compensation_type
FROM employees e
JOIN (
    SELECT department_id, AVG(salary) as avg_salary
    FROM employees
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id;
```

### Hierarchical Views

#### Example 4: Organizational Hierarchy
```sql
CREATE OR REPLACE VIEW org_hierarchy AS
SELECT 
    employee_id,
    first_name || ' ' || last_name as employee_name,
    manager_id,
    LEVEL as hierarchy_level,
    SYS_CONNECT_BY_PATH(first_name || ' ' || last_name, ' -> ') as hierarchy_path,
    CONNECT_BY_ROOT (first_name || ' ' || last_name) as top_manager
FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name, first_name;
```

---

## Updatable Views

Not all views can be updated. Oracle has specific rules for when a view is updatable.

### Rules for Updatable Views

A view is updatable if:
1. **Single Table**: Based on a single table
2. **No Aggregate Functions**: No GROUP BY, HAVING, DISTINCT
3. **No Set Operations**: No UNION, INTERSECT, MINUS
4. **No Subqueries**: In SELECT or WHERE clauses
5. **All Required Columns**: All NOT NULL columns are included

### Example: Updatable Employee View

```sql
-- Create an updatable view
CREATE OR REPLACE VIEW dept_20_employees AS
SELECT employee_id, first_name, last_name, email, salary, department_id
FROM employees
WHERE department_id = 20
WITH CHECK OPTION;

-- This will work - INSERT
INSERT INTO dept_20_employees 
VALUES (999, 'John', 'Doe', 'jdoe@company.com', 5000, 20);

-- This will work - UPDATE
UPDATE dept_20_employees 
SET salary = 5500 
WHERE employee_id = 999;

-- This will fail due to CHECK OPTION
UPDATE dept_20_employees 
SET department_id = 30 
WHERE employee_id = 999;
-- Error: view WITH CHECK OPTION where-clause violation

-- This will work - DELETE
DELETE FROM dept_20_employees WHERE employee_id = 999;
```

### WITH CHECK OPTION

Ensures that INSERT and UPDATE operations satisfy the view's WHERE clause:

```sql
CREATE OR REPLACE VIEW high_salary_employees AS
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees
WHERE salary > 10000
WITH CHECK OPTION;

-- This will fail
INSERT INTO high_salary_employees 
VALUES (998, 'Jane', 'Smith', 8000, 20);
-- Error: CHECK OPTION constraint violated
```

### INSTEAD OF Triggers for Complex Views

For complex views that aren't naturally updatable:

```sql
-- Create a complex view
CREATE OR REPLACE VIEW employee_department_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Create INSTEAD OF trigger for updates
CREATE OR REPLACE TRIGGER employee_dept_update_trigger
INSTEAD OF UPDATE ON employee_department_view
FOR EACH ROW
BEGIN
    UPDATE employees
    SET first_name = :NEW.first_name,
        last_name = :NEW.last_name,
        salary = :NEW.salary
    WHERE employee_id = :NEW.employee_id;
END;
```

---

## Materialized Views

Materialized views physically store the result set, providing significant performance benefits for complex queries.

### Creating Materialized Views

#### Basic Syntax
```sql
CREATE MATERIALIZED VIEW mv_name
[BUILD IMMEDIATE | BUILD DEFERRED]
[REFRESH FAST | COMPLETE | FORCE]
[ON DEMAND | ON COMMIT]
[ENABLE | DISABLE QUERY REWRITE]
AS
SELECT ...;
```

#### Example 1: Basic Materialized View
```sql
-- Create materialized view for monthly sales summary
CREATE MATERIALIZED VIEW mv_monthly_sales
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
AS
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') as sales_month,
    COUNT(o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.quantity * oi.unit_price) as avg_order_value
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM');

-- Query the materialized view (very fast)
SELECT * FROM mv_monthly_sales ORDER BY sales_month;
```

#### Example 2: Product Performance Materialized View
```sql
CREATE MATERIALIZED VIEW mv_product_performance
BUILD IMMEDIATE
REFRESH COMPLETE ON DEMAND
ENABLE QUERY REWRITE
AS
SELECT 
    p.product_id,
    p.product_name,
    p.category_id,
    COUNT(oi.order_id) as times_ordered,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.quantity * oi.unit_price) as total_revenue,
    AVG(oi.unit_price) as avg_selling_price,
    MAX(o.order_date) as last_order_date
FROM sales.products p
LEFT JOIN sales.order_items oi ON p.product_id = oi.product_id
LEFT JOIN sales.orders o ON oi.order_id = o.order_id
GROUP BY p.product_id, p.product_name, p.category_id;
```

### Refresh Options

#### ON DEMAND Refresh
```sql
-- Manual refresh
EXEC DBMS_MVIEW.REFRESH('MV_MONTHLY_SALES', 'C');

-- Refresh multiple materialized views
EXEC DBMS_MVIEW.REFRESH_ALL_MVIEWS();
```

#### ON COMMIT Refresh (for fast refresh)
```sql
-- Create materialized view log for fast refresh
CREATE MATERIALIZED VIEW LOG ON sales.orders;
CREATE MATERIALIZED VIEW LOG ON sales.order_items;

-- Create fast refresh materialized view
CREATE MATERIALIZED VIEW mv_daily_sales
BUILD IMMEDIATE
REFRESH FAST ON COMMIT
AS
SELECT 
    TRUNC(o.order_date) as order_date,
    COUNT(*) as order_count,
    SUM(oi.quantity * oi.unit_price) as daily_revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY TRUNC(o.order_date);
```

### Materialized View Management

```sql
-- Check materialized view status
SELECT mview_name, refresh_mode, refresh_method, last_refresh_date
FROM user_mviews;

-- Check refresh history
SELECT mview_name, refresh_date, refresh_method 
FROM user_mview_refresh_times
ORDER BY refresh_date DESC;

-- Drop materialized view
DROP MATERIALIZED VIEW mv_monthly_sales;
```

---

## View Security

Views are powerful tools for implementing database security by controlling data access.

### Column-Level Security

```sql
-- Hide sensitive employee data
CREATE OR REPLACE VIEW employee_public AS
SELECT 
    employee_id,
    first_name,
    last_name,
    email,
    hire_date,
    department_id
    -- salary, ssn, and other sensitive fields excluded
FROM employees;

-- Grant access to the view instead of the table
GRANT SELECT ON employee_public TO hr_users;
```

### Row-Level Security

```sql
-- Department managers can only see their department's employees
CREATE OR REPLACE VIEW manager_employee_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.department_id = (
    SELECT department_id 
    FROM employees 
    WHERE employee_id = USER  -- Assuming USER contains employee_id
    AND job_id LIKE '%MANAGER%'
);
```

### Application Context Security

```sql
-- Using application context for dynamic security
CREATE OR REPLACE VIEW secure_employee_view AS
SELECT 
    employee_id,
    first_name,
    last_name,
    CASE 
        WHEN SYS_CONTEXT('HR_CONTEXT', 'ROLE') = 'MANAGER' THEN salary
        ELSE NULL
    END as salary,
    department_id
FROM employees;
```

---

## Performance Considerations

### When to Use Views

#### **Good Use Cases:**
- **Frequently Used Complex Queries**: Save development time
- **Data Security**: Control access to sensitive information  
- **Data Abstraction**: Hide complexity from end users
- **Standardization**: Ensure consistent business logic

#### **Performance Considerations:**
- **Simple Views**: Minimal performance impact
- **Complex Views**: May impact performance, consider materialized views
- **Nested Views**: Avoid views based on other views (performance killer)

### View Performance Tips

#### 1. Use Indexes on Base Tables
```sql
-- Ensure base tables have appropriate indexes
CREATE INDEX idx_employees_dept_salary ON employees(department_id, salary);
CREATE INDEX idx_orders_customer_date ON sales.orders(customer_id, order_date);
```

#### 2. Avoid SELECT *
```sql
-- BAD: Uses all columns
CREATE VIEW all_employee_data AS
SELECT * FROM employees e JOIN departments d ON e.department_id = d.department_id;

-- GOOD: Only necessary columns
CREATE VIEW employee_summary AS
SELECT e.employee_id, e.first_name, e.last_name, d.department_name
FROM employees e JOIN departments d ON e.department_id = d.department_id;
```

#### 3. Consider Materialized Views for Heavy Aggregations
```sql
-- Heavy aggregation - good candidate for materialized view
CREATE MATERIALIZED VIEW sales_summary_mv AS
SELECT 
    p.category_id,
    EXTRACT(YEAR FROM o.order_date) as sales_year,
    EXTRACT(MONTH FROM o.order_date) as sales_month,
    COUNT(DISTINCT o.customer_id) as customers,
    SUM(oi.quantity * oi.unit_price) as revenue
FROM sales.orders o
JOIN sales.order_items oi ON o.order_id = oi.order_id  
JOIN sales.products p ON oi.product_id = p.product_id
GROUP BY p.category_id, EXTRACT(YEAR FROM o.order_date), EXTRACT(MONTH FROM o.order_date);
```

---

## Best Practices

### 1. Naming Conventions

```sql
-- Use clear, descriptive names
CREATE VIEW vw_employee_department_summary AS ...     -- Good
CREATE VIEW emp_dept AS ...                           -- Poor

-- Prefix materialized views
CREATE MATERIALIZED VIEW mv_monthly_sales AS ...      -- Good
CREATE MATERIALIZED VIEW monthly_sales AS ...         -- Unclear
```

### 2. Documentation

```sql
-- Document complex views with comments
CREATE OR REPLACE VIEW employee_performance_metrics AS
-- Purpose: Provides comprehensive employee performance analysis
-- Created: 2025-01-15
-- Author: HR Analytics Team
-- Dependencies: employees, departments, jobs tables
-- Refresh: Real-time (regular view)
-- Notes: Includes tenure calculation and salary ranking
SELECT 
    e.employee_id,
    -- ... rest of query
```

### 3. Error Handling

```sql
-- Handle potential NULL values
CREATE OR REPLACE VIEW safe_employee_metrics AS
SELECT 
    employee_id,
    COALESCE(salary, 0) as salary,
    COALESCE(commission_pct, 0) as commission_pct,
    ROUND(COALESCE(salary, 0) * (1 + COALESCE(commission_pct, 0)), 2) as total_compensation
FROM employees;
```

### 4. Testing and Validation

```sql
-- Test view performance
EXPLAIN PLAN FOR SELECT * FROM employee_department_summary;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Validate view results
SELECT COUNT(*) FROM employee_department_summary;  -- Should match expectations
SELECT MAX(salary), MIN(salary) FROM employee_department_summary;  -- Check ranges
```

### 5. Maintenance

```sql
-- Regular maintenance tasks
-- 1. Monitor view usage
SELECT view_name, num_rows FROM user_tables WHERE table_name LIKE 'VW_%';

-- 2. Update materialized views
EXEC DBMS_MVIEW.REFRESH_ALL_MVIEWS();

-- 3. Check for invalid views
SELECT object_name, status FROM user_objects WHERE object_type = 'VIEW' AND status = 'INVALID';

-- 4. Recompile invalid views
ALTER VIEW invalid_view_name COMPILE;
```

---

## Summary

Views and materialized views are essential tools for:

- **Data Security**: Controlling access to sensitive information
- **Query Simplification**: Hiding complex logic behind simple interfaces  
- **Performance Optimization**: Pre-calculating complex aggregations
- **Data Abstraction**: Presenting data in business-friendly formats
- **Standardization**: Ensuring consistent business logic across applications

### Key Takeaways:

1. **Regular Views**: Virtual tables, no storage, real-time data
2. **Materialized Views**: Physical storage, periodic refresh, high performance
3. **Security**: Views provide excellent column and row-level security
4. **Performance**: Consider materialized views for complex aggregations
5. **Maintenance**: Regular monitoring and refresh strategies are essential

### Next Steps:

- Practice creating views for your specific business requirements
- Experiment with materialized view refresh strategies
- Implement view-based security in your applications
- Monitor and optimize view performance

**Practice File**: Work through `src/advanced/views-materialized-views.sql` for hands-on examples and exercises.
