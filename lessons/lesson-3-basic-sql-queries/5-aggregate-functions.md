# Aggregate Functions - Summarizing Data

Aggregate functions perform calculations on groups of rows and return a single result. They are essential for data analysis, reporting, and statistical calculations.

## Overview of Aggregate Functions

Aggregate functions operate on sets of rows and return a single value. They are commonly used with GROUP BY to create summary reports.

### Common Aggregate Functions:
- **COUNT()** - Count rows or non-NULL values
- **SUM()** - Calculate total of numeric values
- **AVG()** - Calculate average of numeric values
- **MIN()** - Find minimum value
- **MAX()** - Find maximum value
- **STDDEV()** - Calculate standard deviation
- **VARIANCE()** - Calculate variance

## COUNT Function

### 1. COUNT(*) - Count All Rows
```sql
-- Count total number of employees
SELECT COUNT(*) AS total_employees
FROM hr.employees;

-- Count employees in specific department
SELECT COUNT(*) AS it_employees
FROM hr.employees
WHERE department_id = 60;
```

### 2. COUNT(column) - Count Non-NULL Values
```sql
-- Count employees with commission (excludes NULLs)
SELECT COUNT(commission_pct) AS employees_with_commission
FROM hr.employees;

-- Count employees with phone numbers
SELECT COUNT(phone_number) AS employees_with_phone
FROM hr.employees;

-- Compare total vs non-NULL counts
SELECT 
    COUNT(*) AS total_employees,
    COUNT(commission_pct) AS employees_with_commission,
    COUNT(*) - COUNT(commission_pct) AS employees_without_commission
FROM hr.employees;
```

### 3. COUNT(DISTINCT) - Count Unique Values
```sql
-- Count unique departments
SELECT COUNT(DISTINCT department_id) AS unique_departments
FROM hr.employees;

-- Count unique job types
SELECT COUNT(DISTINCT job_id) AS unique_jobs
FROM hr.employees;

-- Count unique managers
SELECT COUNT(DISTINCT manager_id) AS unique_managers
FROM hr.employees;
```

## SUM Function

### 1. Basic SUM Operations
```sql
-- Total salary expense
SELECT SUM(salary) AS total_salary_expense
FROM hr.employees;

-- Total salary for specific department
SELECT SUM(salary) AS it_department_salary
FROM hr.employees
WHERE department_id = 60;

-- Sum with condition handling
SELECT 
    SUM(salary) AS total_base_salary,
    SUM(salary * NVL(commission_pct, 0)) AS total_commission,
    SUM(salary + (salary * NVL(commission_pct, 0))) AS total_compensation
FROM hr.employees;
```

### 2. Conditional SUM
```sql
-- Sum based on conditions using CASE
SELECT 
    SUM(salary) AS total_salary,
    SUM(CASE WHEN department_id = 60 THEN salary ELSE 0 END) AS it_salary,
    SUM(CASE WHEN department_id = 80 THEN salary ELSE 0 END) AS sales_salary,
    SUM(CASE WHEN commission_pct IS NOT NULL THEN salary ELSE 0 END) AS commissioned_salary
FROM hr.employees;
```

### 3. SUM with Product Tables
```sql
-- Total inventory value
SELECT SUM(unit_price * units_in_stock) AS total_inventory_value
FROM sales.products
WHERE discontinued = 0;

-- Total order value
SELECT SUM(unit_price * quantity) AS total_order_value
FROM sales.order_details;
```

## AVG Function

### 1. Simple Averages
```sql
-- Average salary across all employees
SELECT AVG(salary) AS average_salary
FROM hr.employees;

-- Average salary by department
SELECT 
    department_id,
    AVG(salary) AS avg_dept_salary,
    COUNT(*) AS employee_count
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY avg_dept_salary DESC;
```

### 2. Weighted Averages
```sql
-- Average product price weighted by stock quantity
SELECT 
    AVG(unit_price) AS simple_avg_price,
    SUM(unit_price * units_in_stock) / SUM(units_in_stock) AS weighted_avg_price
FROM sales.products
WHERE units_in_stock > 0;
```

### 3. Filtering with AVG
```sql
-- Employees earning above average salary
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    salary - (SELECT AVG(salary) FROM hr.employees) AS salary_difference
FROM hr.employees
WHERE salary > (SELECT AVG(salary) FROM hr.employees)
ORDER BY salary DESC;
```

## MIN and MAX Functions

### 1. Basic MIN/MAX
```sql
-- Salary range information
SELECT 
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary,
    MAX(salary) - MIN(salary) AS salary_range,
    AVG(salary) AS average_salary
FROM hr.employees;
```

### 2. Date MIN/MAX
```sql
-- Employment date range
SELECT 
    MIN(hire_date) AS earliest_hire_date,
    MAX(hire_date) AS latest_hire_date,
    MAX(hire_date) - MIN(hire_date) AS hiring_span_days
FROM hr.employees;

-- Most recent order information
SELECT 
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    COUNT(*) AS total_orders
FROM sales.orders;
```

### 3. String MIN/MAX
```sql
-- Alphabetical name range
SELECT 
    MIN(last_name) AS first_alphabetically,
    MAX(last_name) AS last_alphabetically
FROM hr.employees;

-- Product name range
SELECT 
    MIN(product_name) AS first_product_alphabetically,
    MAX(product_name) AS last_product_alphabetically
FROM sales.products;
```

## Advanced Aggregate Functions

### 1. Statistical Functions
```sql
-- Salary statistics
SELECT 
    COUNT(*) AS employee_count,
    AVG(salary) AS mean_salary,
    STDDEV(salary) AS salary_std_dev,
    VARIANCE(salary) AS salary_variance,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary
FROM hr.employees;
```

### 2. LISTAGG Function (String Aggregation)
```sql
-- Concatenate employee names by department
SELECT 
    department_id,
    LISTAGG(first_name || ' ' || last_name, ', ') 
        WITHIN GROUP (ORDER BY last_name) AS employee_list
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;

-- Product names by category
SELECT 
    category_id,
    LISTAGG(product_name, '; ') 
        WITHIN GROUP (ORDER BY product_name) AS product_list
FROM sales.products
GROUP BY category_id
ORDER BY category_id;
```

## GROUP BY with Aggregates

### 1. Basic Grouping
```sql
-- Employee count and average salary by department
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS total_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY department_id;
```

### 2. Multiple Column Grouping
```sql
-- Statistics by department and job
SELECT 
    department_id,
    job_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    SUM(salary) AS total_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id, job_id
ORDER BY department_id, job_id;
```

### 3. Grouping with Calculated Fields
```sql
-- Group employees by salary range
SELECT 
    CASE 
        WHEN salary < 5000 THEN 'Low (< 5000)'
        WHEN salary < 10000 THEN 'Medium (5000-9999)'
        WHEN salary < 15000 THEN 'High (10000-14999)'
        ELSE 'Very High (>= 15000)'
    END AS salary_range,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary_in_range,
    MIN(salary) AS min_salary_in_range,
    MAX(salary) AS max_salary_in_range
FROM hr.employees
GROUP BY 
    CASE 
        WHEN salary < 5000 THEN 'Low (< 5000)'
        WHEN salary < 10000 THEN 'Medium (5000-9999)'
        WHEN salary < 15000 THEN 'High (10000-14999)'
        ELSE 'Very High (>= 15000)'
    END
ORDER BY MIN(salary);
```

## HAVING Clause

### 1. Filtering Aggregated Results
```sql
-- Departments with more than 5 employees
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING COUNT(*) > 5
ORDER BY employee_count DESC;
```

### 2. Complex HAVING Conditions
```sql
-- Departments with high average salary and multiple employees
SELECT 
    department_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    SUM(salary) AS total_salary
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
HAVING COUNT(*) >= 3 
   AND AVG(salary) > 8000
ORDER BY avg_salary DESC;
```

### 3. HAVING with Multiple Conditions
```sql
-- Product categories with significant inventory value
SELECT 
    category_id,
    COUNT(*) AS product_count,
    AVG(unit_price) AS avg_price,
    SUM(unit_price * units_in_stock) AS total_inventory_value
FROM sales.products
WHERE discontinued = 0
GROUP BY category_id
HAVING COUNT(*) >= 2
   AND SUM(unit_price * units_in_stock) > 1000
   AND AVG(unit_price) > 15
ORDER BY total_inventory_value DESC;
```

## Combining WHERE and HAVING

```sql
-- Complex filtering example
SELECT 
    department_id,
    job_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MAX(hire_date) AS most_recent_hire
FROM hr.employees
WHERE salary > 3000                    -- WHERE filters individual rows
  AND hire_date >= DATE '1990-01-01'
  AND department_id IS NOT NULL
GROUP BY department_id, job_id
HAVING COUNT(*) >= 2                   -- HAVING filters grouped results
   AND AVG(salary) > 6000
ORDER BY department_id, avg_salary DESC;
```

## Nested Aggregates and Subqueries

### 1. Subqueries with Aggregates
```sql
-- Employees earning above department average
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    e.salary,
    dept_avg.avg_salary,
    e.salary - dept_avg.avg_salary AS difference
FROM hr.employees e
JOIN (
    SELECT 
        department_id,
        AVG(salary) AS avg_salary
    FROM hr.employees
    GROUP BY department_id
) dept_avg ON e.department_id = dept_avg.department_id
WHERE e.salary > dept_avg.avg_salary
ORDER BY e.department_id, difference DESC;
```

### 2. Comparing to Overall Statistics
```sql
-- Departments vs company averages
SELECT 
    department_id,
    COUNT(*) AS dept_employee_count,
    AVG(salary) AS dept_avg_salary,
    (SELECT AVG(salary) FROM hr.employees) AS company_avg_salary,
    AVG(salary) - (SELECT AVG(salary) FROM hr.employees) AS salary_difference,
    ROUND(AVG(salary) / (SELECT AVG(salary) FROM hr.employees) * 100, 2) AS salary_ratio_percent
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY dept_avg_salary DESC;
```

## Real-World Reporting Examples

### 1. Executive Dashboard Summary
```sql
-- Company-wide statistics
SELECT 
    'Employee Summary' AS metric_category,
    COUNT(*) AS total_employees,
    COUNT(DISTINCT department_id) AS total_departments,
    COUNT(DISTINCT job_id) AS total_job_types,
    TO_CHAR(AVG(salary), '$999,999.99') AS avg_salary,
    TO_CHAR(SUM(salary), '$99,999,999.99') AS total_salary_expense,
    COUNT(CASE WHEN commission_pct IS NOT NULL THEN 1 END) AS commissioned_employees
FROM hr.employees

UNION ALL

SELECT 
    'Salary Distribution',
    COUNT(CASE WHEN salary < 5000 THEN 1 END),
    COUNT(CASE WHEN salary BETWEEN 5000 AND 9999 THEN 1 END),
    COUNT(CASE WHEN salary BETWEEN 10000 AND 14999 THEN 1 END),
    COUNT(CASE WHEN salary >= 15000 THEN 1 END),
    NULL,
    NULL
FROM hr.employees;
```

### 2. Sales Performance Report
```sql
-- Product sales summary
SELECT 
    p.product_name,
    COUNT(DISTINCT od.order_id) AS number_of_orders,
    SUM(od.quantity) AS total_quantity_sold,
    AVG(od.quantity) AS avg_quantity_per_order,
    MIN(od.unit_price) AS min_price,
    MAX(od.unit_price) AS max_price,
    AVG(od.unit_price) AS avg_price,
    SUM(od.unit_price * od.quantity) AS total_revenue
FROM sales.products p
JOIN sales.order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
HAVING SUM(od.quantity) >= 10  -- Only products with significant sales
ORDER BY total_revenue DESC;
```

### 3. Department Analysis Report
```sql
-- Comprehensive department analysis
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    TO_CHAR(AVG(e.salary), '$999,999.99') AS avg_salary,
    TO_CHAR(MIN(e.salary), '$999,999.99') AS min_salary,
    TO_CHAR(MAX(e.salary), '$999,999.99') AS max_salary,
    TO_CHAR(SUM(e.salary), '$99,999,999.99') AS total_payroll,
    ROUND(AVG(SYSDATE - e.hire_date) / 365.25, 1) AS avg_years_service,
    COUNT(CASE WHEN e.commission_pct IS NOT NULL THEN 1 END) AS commissioned_count,
    TO_CHAR(AVG(CASE WHEN e.commission_pct IS NOT NULL THEN e.commission_pct END) * 100, '99.9') || '%' AS avg_commission_rate
FROM hr.departments d
LEFT JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY employee_count DESC, avg_salary DESC;
```

## Performance Considerations

### 1. Efficient Aggregate Queries
```sql
-- Good: Use WHERE to filter before aggregating
SELECT 
    department_id,
    COUNT(*) AS active_employee_count,
    AVG(salary) AS avg_salary
FROM hr.employees
WHERE salary > 3000  -- Filter before grouping
GROUP BY department_id;

-- Less efficient: Filter after aggregating when possible
-- Use HAVING only when you need to filter on aggregate results
```

### 2. Index Usage
```sql
-- Aggregates can benefit from indexes on GROUP BY columns
-- CREATE INDEX emp_dept_idx ON hr.employees(department_id);

-- Aggregates on indexed columns are faster
SELECT department_id, COUNT(*)
FROM hr.employees
GROUP BY department_id;  -- Uses index if available
```

## Common Aggregate Patterns

### 1. Running Totals (Preview of Analytic Functions)
```sql
-- Simple cumulative calculation
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    SUM(salary) OVER (ORDER BY employee_id) AS running_total_salary
FROM hr.employees
ORDER BY employee_id;
```

### 2. Percentage Calculations
```sql
-- Department salary as percentage of total
SELECT 
    department_id,
    SUM(salary) AS dept_total_salary,
    ROUND(SUM(salary) * 100.0 / (SELECT SUM(salary) FROM hr.employees), 2) AS percentage_of_total
FROM hr.employees
WHERE department_id IS NOT NULL
GROUP BY department_id
ORDER BY percentage_of_total DESC;
```

### 3. Ranking and Comparison
```sql
-- Top 3 highest paid employees per department
SELECT 
    department_id,
    employee_id,
    first_name,
    last_name,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM hr.employees
WHERE department_id IS NOT NULL
QUALIFY RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) <= 3
ORDER BY department_id, salary_rank;
```

## Exercises

### Exercise 1: Basic Aggregates
```sql
-- Calculate the following for all employees:
-- Total count, average salary, min/max salary, 
-- count of employees with commission, average commission rate
-- Your query here:
```

### Exercise 2: Department Analysis
```sql
-- For each department, show:
-- Department ID, employee count, total payroll, average salary,
-- highest and lowest salary, number of different job types
-- Only include departments with more than 2 employees
-- Your query here:
```

### Exercise 3: Product Inventory Analysis
```sql
-- For each product category, calculate:
-- Number of products, average price, total inventory value,
-- number of discontinued products, percentage of products in stock
-- Order by total inventory value descending
-- Your query here:
```

### Exercise 4: Advanced Analysis
```sql
-- Create a report showing employees who earn more than
-- the average salary in their department, including:
-- Employee details, their salary, department average, difference
-- Your query here:
```

## Best Practices Summary

1. **Use appropriate aggregate functions** for your data type and analysis needs
2. **Handle NULL values** explicitly in aggregate calculations
3. **Use GROUP BY wisely** - include all non-aggregate columns
4. **Apply HAVING** only when filtering on aggregate results
5. **Filter early** with WHERE before aggregating when possible
6. **Consider performance** - use indexes on GROUP BY columns
7. **Format output** appropriately for reports
8. **Test with edge cases** including NULL values and empty groups

## Common Mistakes to Avoid

1. **Forgetting GROUP BY** when mixing aggregates with regular columns
2. **Using WHERE instead of HAVING** for aggregate conditions
3. **Not handling NULL values** in calculations
4. **Mixing aggregate and non-aggregate columns** incorrectly
5. **Using aggregates in WHERE clause** (use HAVING instead)
6. **Not considering performance** impact of complex aggregations
7. **Forgetting to test** with empty groups or NULL values

## Next Steps

Master aggregate functions before moving to:
1. **Joins** - Combine data from multiple tables
2. **Subqueries** - Use aggregates in complex queries  
3. **Analytic Functions** - Advanced windowing and ranking
4. **Data Warehousing** - Advanced aggregation techniques

Aggregate functions are fundamental to data analysis and reporting, so practice extensively with different scenarios!
