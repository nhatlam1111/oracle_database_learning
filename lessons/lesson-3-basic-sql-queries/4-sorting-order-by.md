# Sorting with ORDER BY

The ORDER BY clause allows you to sort query results in ascending or descending order based on one or more columns. Proper sorting makes data analysis and presentation much more effective.

## Basic ORDER BY Syntax

```sql
SELECT column1, column2, ...
FROM table_name
[WHERE condition]
ORDER BY column1 [ASC|DESC], column2 [ASC|DESC], ...;
```

## Single Column Sorting

### 1. Ascending Order (Default)
```sql
-- Sort employees by last name (A to Z)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY last_name;

-- Explicitly specify ASC (same result as above)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY last_name ASC;
```

### 2. Descending Order
```sql
-- Sort employees by salary (highest to lowest)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC;

-- Sort by hire date (most recent first)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date DESC;
```

## Multiple Column Sorting

### 1. Primary and Secondary Sort
```sql
-- Sort by department first, then by salary within each department
SELECT employee_id, first_name, last_name, department_id, salary
FROM hr.employees
ORDER BY department_id ASC, salary DESC;

-- Sort by job_id, then by last name, then by first name
SELECT employee_id, first_name, last_name, job_id, salary
FROM hr.employees
ORDER BY job_id, last_name, first_name;
```

### 2. Mixed Sort Orders
```sql
-- Department ascending, salary descending, hire date ascending
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    department_id, 
    salary, 
    hire_date
FROM hr.employees
ORDER BY 
    department_id ASC,
    salary DESC,
    hire_date ASC;
```

## Sorting by Different Data Types

### 1. Numeric Sorting
```sql
-- Sort by salary (numeric)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary IS NOT NULL
ORDER BY salary DESC;

-- Sort by employee ID
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY employee_id;
```

### 2. String Sorting
```sql
-- Alphabetical sorting (case-sensitive in Oracle)
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY last_name, first_name;

-- Case-insensitive sorting
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY UPPER(last_name), UPPER(first_name);

-- Sort by string length
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY LENGTH(last_name) DESC, last_name;
```

### 3. Date Sorting
```sql
-- Sort by hire date (oldest first)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date ASC;

-- Sort by hire date (newest first)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date DESC;

-- Sort by month of hire date
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY EXTRACT(MONTH FROM hire_date), hire_date;
```

## Sorting with Expressions and Functions

### 1. Calculated Columns
```sql
-- Sort by calculated annual salary
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    salary * 12 AS annual_salary
FROM hr.employees
ORDER BY salary * 12 DESC;

-- Sort by total compensation (salary + commission)
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    commission_pct,
    salary + (salary * NVL(commission_pct, 0)) AS total_compensation
FROM hr.employees
ORDER BY salary + (salary * NVL(commission_pct, 0)) DESC;
```

### 2. Function-Based Sorting
```sql
-- Sort by years of service
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    hire_date,
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS years_service
FROM hr.employees
ORDER BY (SYSDATE - hire_date) DESC;

-- Sort by full name
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY first_name || ' ' || last_name;

-- Sort by absolute difference from average salary
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    ABS(salary - (SELECT AVG(salary) FROM hr.employees)) AS salary_diff
FROM hr.employees
ORDER BY ABS(salary - (SELECT AVG(salary) FROM hr.employees));
```

## Sorting with Aliases

### 1. Using Column Aliases
```sql
-- Sort by alias name
SELECT 
    employee_id AS emp_id,
    first_name || ' ' || last_name AS full_name,
    salary * 12 AS annual_salary
FROM hr.employees
ORDER BY annual_salary DESC, full_name;

-- Note: You can use aliases in ORDER BY that are defined in SELECT
```

### 2. Column Position Numbers
```sql
-- Sort by column position (not recommended for production)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY 4 DESC, 3, 2;  -- 4=salary, 3=last_name, 2=first_name

-- Better to use column names for clarity
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
ORDER BY salary DESC, last_name, first_name;
```

## Handling NULL Values in Sorting

### 1. Default NULL Behavior
```sql
-- In Oracle, NULLs sort last in ASC, first in DESC by default
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct ASC;  -- NULLs appear last

SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct DESC; -- NULLs appear first
```

### 2. Controlling NULL Position
```sql
-- Force NULLs to appear first in ascending sort
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct NULLS FIRST;

-- Force NULLs to appear last in descending sort
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY commission_pct DESC NULLS LAST;

-- Complex example with multiple columns
SELECT employee_id, first_name, last_name, manager_id, commission_pct
FROM hr.employees
ORDER BY 
    manager_id NULLS LAST,
    commission_pct DESC NULLS LAST,
    last_name;
```

### 3. Alternative NULL Handling
```sql
-- Replace NULL with a value for sorting
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY NVL(commission_pct, -1) DESC;

-- Sort NULLs as if they were zero
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY NVL(commission_pct, 0), last_name;
```

## CASE-Based Sorting

### 1. Custom Sort Orders
```sql
-- Sort departments in custom order
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
ORDER BY 
    CASE department_id
        WHEN 90 THEN 1  -- Executive first
        WHEN 60 THEN 2  -- IT second
        WHEN 80 THEN 3  -- Sales third
        ELSE 4          -- All others last
    END,
    last_name;
```

### 2. Priority-Based Sorting
```sql
-- Sort by salary category priority
SELECT 
    employee_id, 
    first_name, 
    last_name, 
    salary,
    CASE 
        WHEN salary >= 15000 THEN 'High'
        WHEN salary >= 8000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_category
FROM hr.employees
ORDER BY 
    CASE 
        WHEN salary >= 15000 THEN 1
        WHEN salary >= 8000 THEN 2
        ELSE 3
    END,
    salary DESC;
```

### 3. Boolean-Style Sorting
```sql
-- Sort by commission status (has commission first)
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
ORDER BY 
    CASE WHEN commission_pct IS NOT NULL THEN 0 ELSE 1 END,
    commission_pct DESC,
    last_name;
```

## Advanced Sorting Techniques

### 1. Natural Sorting for Alphanumeric Data
```sql
-- For data like 'Item1', 'Item2', 'Item10' to sort naturally
-- This is a simplified example - real natural sorting is more complex
SELECT product_id, product_name
FROM sales.products
ORDER BY 
    LENGTH(product_name),
    product_name;
```

### 2. Sorting by Multiple Criteria with Weights
```sql
-- Weighted scoring for employee ranking
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS years_service,
    -- Weighted score: 70% salary, 30% experience
    (salary * 0.7) + (ROUND((SYSDATE - hire_date) / 365.25, 1) * 1000 * 0.3) AS weighted_score
FROM hr.employees
ORDER BY (salary * 0.7) + (ROUND((SYSDATE - hire_date) / 365.25, 1) * 1000 * 0.3) DESC;
```

### 3. Random Sorting
```sql
-- Random order (useful for sampling)
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY DBMS_RANDOM.VALUE;

-- Random sample of 5 employees
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE ROWNUM <= 5
ORDER BY DBMS_RANDOM.VALUE;
```

## Performance Considerations

### 1. Index-Friendly Sorting
```sql
-- Good: Sorting by indexed columns
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY employee_id;  -- Primary key, automatically indexed

-- Consider creating indexes for frequently sorted columns
-- CREATE INDEX emp_lastname_idx ON hr.employees(last_name);
SELECT employee_id, first_name, last_name
FROM hr.employees
ORDER BY last_name;
```

### 2. Limiting Results with Sorting
```sql
-- Top N queries - more efficient than sorting all rows
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE ROWNUM <= 10
ORDER BY salary DESC;

-- Better approach using analytic functions (Oracle 12c+)
SELECT employee_id, first_name, last_name, salary
FROM (
    SELECT employee_id, first_name, last_name, salary
    FROM hr.employees
    ORDER BY salary DESC
)
WHERE ROWNUM <= 10;
```

### 3. Avoiding Expensive Operations
```sql
-- Expensive: Function on every row
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY EXTRACT(YEAR FROM hire_date);

-- Better: Consider adding computed column or function-based index
-- If this query is frequent, create function-based index:
-- CREATE INDEX emp_hire_year_idx ON hr.employees(EXTRACT(YEAR FROM hire_date));
```

## Real-World Examples

### 1. Employee Directory
```sql
-- Employee directory sorted by department and name
SELECT 
    d.department_name,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.phone_number,
    j.job_title
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.jobs j ON e.job_id = j.job_id
ORDER BY 
    d.department_name,
    e.last_name,
    e.first_name;
```

### 2. Sales Report
```sql
-- Top selling products by revenue
SELECT 
    p.product_name,
    SUM(od.quantity) AS total_quantity,
    SUM(od.unit_price * od.quantity) AS total_revenue
FROM sales.products p
JOIN sales.order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.product_name
ORDER BY 
    SUM(od.unit_price * od.quantity) DESC,
    SUM(od.quantity) DESC,
    p.product_name;
```

### 3. Payroll Report
```sql
-- Payroll report sorted by department and salary
SELECT 
    d.department_name,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    j.job_title,
    e.salary,
    NVL(e.commission_pct, 0) AS commission_rate,
    e.salary + (e.salary * NVL(e.commission_pct, 0)) AS total_compensation
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id
JOIN hr.jobs j ON e.job_id = j.job_id
ORDER BY 
    d.department_name,
    e.salary + (e.salary * NVL(e.commission_pct, 0)) DESC,
    e.last_name;
```

## Common ORDER BY Patterns

### 1. Chronological Reports
```sql
-- Recent activity first
SELECT order_id, customer_id, order_date, freight
FROM sales.orders
ORDER BY order_date DESC, order_id DESC;

-- Historical analysis (oldest first)
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
ORDER BY hire_date ASC, employee_id ASC;
```

### 2. Hierarchical Data
```sql
-- Manager-employee hierarchy
SELECT 
    LEVEL,
    employee_id,
    first_name || ' ' || last_name AS employee_name,
    manager_id,
    job_id
FROM hr.employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id
ORDER SIBLINGS BY last_name, first_name;
```

### 3. Statistical Ordering
```sql
-- Quartile-based ordering
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM hr.employees
ORDER BY salary_quartile, salary DESC;
```

## Exercises

### Exercise 1: Basic Sorting
```sql
-- Sort all employees by hire date (newest first), 
-- then by last name alphabetically
-- Your query here:
```

### Exercise 2: Complex Sorting
```sql
-- Create a report showing products sorted by:
-- 1. Stock status (out of stock first, then low stock, then normal)
-- 2. Category ID
-- 3. Unit price (highest first)
-- 4. Product name alphabetically
-- Your query here:
```

### Exercise 3: Custom Sort Order
```sql
-- Sort employees with this priority:
-- 1. Executives (job_id starting with 'AD_') first
-- 2. Managers (job_id ending with '_MGR' or '_MAN') second  
-- 3. All others third
-- Within each group, sort by salary descending
-- Your query here:
```

### Exercise 4: NULL Handling
```sql
-- Show all employees sorted by commission_pct descending,
-- but put employees without commission at the end,
-- then sort by salary descending
-- Your query here:
```

## Best Practices Summary

1. **Always specify sort direction** explicitly (ASC/DESC) for clarity
2. **Use meaningful column names** rather than position numbers
3. **Consider NULL handling** explicitly when needed
4. **Sort by indexed columns** when possible for performance
5. **Use aliases** for complex expressions in ORDER BY
6. **Limit results** when possible to improve performance
7. **Test with real data** to ensure sort order meets requirements
8. **Document complex sorting logic** with comments

## Common Mistakes to Avoid

1. **Relying on default sort order** without ORDER BY
2. **Using column positions** instead of names (reduces readability)
3. **Ignoring NULL behavior** when it matters
4. **Sorting by functions** without considering performance impact
5. **Not considering case sensitivity** in string sorting
6. **Forgetting that ORDER BY comes last** in SQL statement structure
7. **Mixing data types** in sort expressions

## Performance Tips

1. **Create indexes** on frequently sorted columns
2. **Use ROWNUM or FETCH FIRST** to limit results
3. **Avoid functions** in ORDER BY when possible
4. **Consider composite indexes** for multi-column sorts
5. **Use analytic functions** for ranking queries
6. **Test performance** with realistic data volumes

## Next Steps

Master ORDER BY sorting before moving to:
1. **Aggregate Functions** - Summarize your sorted data
2. **GROUP BY** - Group data before sorting
3. **Analytic Functions** - Advanced sorting and ranking
4. **Performance Tuning** - Optimize sort operations

Sorting is essential for data presentation and analysis, so practice with various scenarios and data types!
