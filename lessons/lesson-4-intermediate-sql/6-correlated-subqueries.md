# Correlated Subqueries in Oracle Database

## Learning Objectives
By the end of this section, you will understand:
- What correlated subqueries are and how they differ from regular subqueries
- When to use correlated subqueries effectively
- Performance implications and optimization strategies
- Advanced patterns using correlated subqueries
- Alternatives to correlated subqueries

## Introduction to Correlated Subqueries

A correlated subquery is a subquery that references columns from the outer (main) query. Unlike regular subqueries that execute once and return a result set, correlated subqueries execute once for each row of the outer query, making them more powerful but potentially less efficient.

### Basic Structure
```sql
SELECT outer_table.column1, outer_table.column2
FROM outer_table
WHERE outer_table.column3 operator (
    SELECT inner_table.column1
    FROM inner_table
    WHERE inner_table.column2 = outer_table.column2  -- Correlation
);
```

### Key Characteristics
- References outer query columns
- Executes for each row of outer query
- Cannot be executed independently
- Often used with EXISTS, NOT EXISTS
- Useful for row-by-row comparisons

## Basic Correlated Subquery Examples

### 1. Employee Salary Comparison
```sql
-- Find employees earning more than average in their department
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id  -- Correlation with outer query
);
```

### 2. Latest Record Per Group
```sql
-- Find each employee's most recent job change
SELECT 
    jh.employee_id,
    jh.start_date,
    jh.end_date,
    jh.job_id,
    jh.department_id
FROM job_history jh
WHERE jh.start_date = (
    SELECT MAX(start_date)
    FROM job_history jh2
    WHERE jh2.employee_id = jh.employee_id  -- Correlation
);
```

### 3. Existence Checking
```sql
-- Find employees who have job history records
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id  -- Correlation
);
```

## Advanced Correlated Subquery Patterns

### 1. Running Calculations
```sql
-- Calculate running total of salaries by hire date
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.hire_date,
    e.salary,
    (SELECT SUM(e2.salary)
     FROM employees e2
     WHERE e2.hire_date <= e.hire_date) AS running_total_salary
FROM employees e
ORDER BY e.hire_date;

-- Running count of employees hired before each employee
SELECT 
    e.employee_id,
    e.first_name,
    e.hire_date,
    (SELECT COUNT(*)
     FROM employees e2
     WHERE e2.hire_date < e.hire_date) AS employees_hired_before
FROM employees e
ORDER BY e.hire_date;
```

### 2. Ranking and Top-N
```sql
-- Find top 3 highest paid employees in each department
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE (
    SELECT COUNT(*)
    FROM employees e2
    WHERE e2.department_id = e.department_id
    AND e2.salary > e.salary
) < 3
ORDER BY e.department_id, e.salary DESC;

-- Alternative: Find employees with salary in top 3 for their department
SELECT 
    e.employee_id,
    e.first_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary IN (
    SELECT DISTINCT salary
    FROM (
        SELECT salary
        FROM employees e2
        WHERE e2.department_id = e.department_id
        ORDER BY salary DESC
    )
    WHERE rownum <= 3
);
```

### 3. Data Quality and Validation
```sql
-- Find employees with salary higher than their manager
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.manager_id
FROM employees e
WHERE e.salary > (
    SELECT m.salary
    FROM employees m
    WHERE m.employee_id = e.manager_id  -- Correlation
)
AND e.manager_id IS NOT NULL;

-- Find departments where all employees earn more than 5000
SELECT d.department_id, d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id  -- Correlation
    AND e.salary <= 5000
)
AND EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id  -- At least one employee
);
```

### 4. Sequential Data Analysis
```sql
-- Find employees hired immediately after another employee left
SELECT 
    e.employee_id,
    e.first_name,
    e.hire_date,
    e.department_id
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.department_id = e.department_id  -- Same department
    AND jh.end_date = e.hire_date - 1  -- Hired day after someone left
);

-- Find gaps in employee ID sequence
SELECT 
    e1.employee_id AS current_id,
    e1.employee_id + 1 AS missing_id
FROM employees e1
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e2
    WHERE e2.employee_id = e1.employee_id + 1  -- Next ID doesn't exist
)
AND e1.employee_id < (SELECT MAX(employee_id) FROM employees)
ORDER BY e1.employee_id;
```

## Complex Business Scenarios

### 1. Customer Analysis
```sql
-- Find customers whose last order was more than 6 months ago
SELECT 
    c.customer_id,
    c.customer_name,
    c.email,
    (SELECT MAX(o.order_date)
     FROM orders o
     WHERE o.customer_id = c.customer_id) AS last_order_date
FROM customers c
WHERE (
    SELECT MAX(o.order_date)
    FROM orders o
    WHERE o.customer_id = c.customer_id
) < SYSDATE - 180
OR NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Find customers who have ordered every product in a category
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (
    -- Find products in category 'Electronics' not ordered by this customer
    SELECT 1
    FROM products p
    WHERE p.category = 'Electronics'
    AND NOT EXISTS (
        SELECT 1
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        WHERE o.customer_id = c.customer_id
        AND oi.product_id = p.product_id
    )
);
```

### 2. Inventory and Sales Analysis
```sql
-- Find products with declining sales trend (last 3 months vs previous 3)
SELECT 
    p.product_id,
    p.product_name,
    (SELECT NVL(SUM(oi.quantity), 0)
     FROM order_items oi
     JOIN orders o ON oi.order_id = o.order_id
     WHERE oi.product_id = p.product_id
     AND o.order_date >= SYSDATE - 90) AS recent_sales,
    (SELECT NVL(SUM(oi.quantity), 0)
     FROM order_items oi
     JOIN orders o ON oi.order_id = o.order_id
     WHERE oi.product_id = p.product_id
     AND o.order_date BETWEEN SYSDATE - 180 AND SYSDATE - 91) AS previous_sales
FROM products p
WHERE (
    SELECT NVL(SUM(oi.quantity), 0)
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
    AND o.order_date >= SYSDATE - 90
) < (
    SELECT NVL(SUM(oi.quantity), 0)
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.product_id = p.product_id
    AND o.order_date BETWEEN SYSDATE - 180 AND SYSDATE - 91
)
ORDER BY recent_sales;
```

### 3. Hierarchical Data Processing
```sql
-- Find managers who have more direct reports than their own manager
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS manager_name,
    (SELECT COUNT(*)
     FROM employees e2
     WHERE e2.manager_id = e.employee_id) AS direct_reports,
    (SELECT COUNT(*)
     FROM employees e3
     WHERE e3.manager_id = (
         SELECT manager_id FROM employees WHERE employee_id = e.employee_id
     )) AS peer_count
FROM employees e
WHERE (
    SELECT COUNT(*)
    FROM employees e2
    WHERE e2.manager_id = e.employee_id
) > (
    SELECT COUNT(*)
    FROM employees e3
    WHERE e3.manager_id = (
        SELECT manager_id FROM employees WHERE employee_id = e.employee_id
    )
)
AND e.manager_id IS NOT NULL;
```

## Performance Considerations

### 1. Understanding Execution
```sql
-- Correlated subquery executes for each outer row
-- This query could execute the subquery 107 times (once per employee)
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- Better approach using window functions
SELECT employee_id, first_name, salary
FROM (
    SELECT 
        employee_id,
        first_name,
        salary,
        AVG(salary) OVER (PARTITION BY department_id) AS dept_avg_salary
    FROM employees
)
WHERE salary > dept_avg_salary;
```

### 2. Index Optimization
```sql
-- Ensure correlated columns are indexed
CREATE INDEX idx_emp_dept_id ON employees(department_id);
CREATE INDEX idx_jobhist_emp_id ON job_history(employee_id);
CREATE INDEX idx_orders_cust_id ON orders(customer_id);

-- Composite indexes for multiple correlations
CREATE INDEX idx_emp_dept_mgr ON employees(department_id, manager_id);
```

### 3. Avoiding Repeated Calculations
```sql
-- INEFFICIENT: Multiple correlated subqueries
SELECT 
    e.employee_id,
    e.first_name,
    (SELECT AVG(salary) FROM employees e2 WHERE e2.department_id = e.department_id) AS dept_avg,
    (SELECT COUNT(*) FROM employees e2 WHERE e2.department_id = e.department_id) AS dept_count
FROM employees e;

-- EFFICIENT: Single join with aggregation
SELECT 
    e.employee_id,
    e.first_name,
    ds.dept_avg,
    ds.dept_count
FROM employees e
JOIN (
    SELECT 
        department_id,
        AVG(salary) AS dept_avg,
        COUNT(*) AS dept_count
    FROM employees
    GROUP BY department_id
) ds ON e.department_id = ds.department_id;
```

## Alternative Approaches

### 1. Window Functions vs Correlated Subqueries
```sql
-- Correlated subquery approach
SELECT 
    e.employee_id,
    e.salary,
    (SELECT COUNT(*)
     FROM employees e2
     WHERE e2.department_id = e.department_id
     AND e2.salary > e.salary) + 1 AS salary_rank
FROM employees e;

-- Window function approach (more efficient)
SELECT 
    employee_id,
    salary,
    RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) AS salary_rank
FROM employees;
```

### 2. Common Table Expressions (CTEs)
```sql
-- Complex correlated subquery
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- CTE approach (clearer, potentially more efficient)
WITH dept_averages AS (
    SELECT department_id, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
JOIN dept_averages da ON e.department_id = da.department_id
WHERE e.salary > da.avg_salary;
```

### 3. EXISTS vs IN Performance
```sql
-- EXISTS (usually more efficient for correlated scenarios)
SELECT c.customer_id, c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_date >= SYSDATE - 365
);

-- IN (processes all values, less efficient for large datasets)
SELECT customer_id, customer_name
FROM customers
WHERE customer_id IN (
    SELECT DISTINCT customer_id
    FROM orders
    WHERE order_date >= SYSDATE - 365
);
```

## Debugging and Troubleshooting

### 1. Testing Correlated Logic
```sql
-- Test the correlation logic separately
-- First, test outer query
SELECT employee_id, first_name, salary, department_id
FROM employees
WHERE employee_id = 100;

-- Then test inner query with specific correlation value
SELECT AVG(salary)
FROM employees
WHERE department_id = 90;  -- Use actual department_id from above

-- Finally, combine
SELECT e.employee_id, e.first_name, e.salary
FROM employees e
WHERE e.employee_id = 100
AND e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);
```

### 2. Performance Analysis
```sql
-- Check execution plan
EXPLAIN PLAN FOR
SELECT e.employee_id, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- View the plan
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Look for:
-- - Nested loops (common with correlated subqueries)
-- - Index usage on correlation columns
-- - Filter operations
```

### 3. Common Issues and Solutions
```sql
-- Issue: Subquery returns no rows (NULL comparison)
-- Problem query
SELECT e.employee_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = 999  -- Non-existent department
);

-- Solution: Handle NULL case
SELECT e.employee_id
FROM employees e
WHERE e.salary > NVL((
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
), 0);
```

## Best Practices

### 1. Code Organization
```sql
-- Format correlated subqueries for readability
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id  -- Clear correlation
      AND e2.hire_date <= e.hire_date         -- Additional conditions
);
```

### 2. Performance Guidelines
- Use indexes on correlated columns
- Consider window functions for aggregations
- Test with realistic data volumes
- Monitor execution plans
- Consider materializing complex subqueries

### 3. When to Use Correlated Subqueries
**Good Use Cases:**
- Row-by-row comparisons
- Existence checking
- Finding latest/earliest records per group
- Complex conditional logic

**Consider Alternatives When:**
- Simple aggregations (use window functions)
- Large result sets (consider joins)
- Multiple correlations (use CTEs)
- Performance is critical

## Practice Exercises

### Exercise 1: Basic Correlations
1. Find employees earning more than the median salary in their job category
2. List customers who haven't ordered in the last 6 months
3. Find products that have been ordered more than the average for their category

### Exercise 2: Advanced Scenarios
1. Identify employees whose current salary is lower than their historical maximum
2. Find departments where the manager earns less than the department average
3. List products with consistently increasing monthly sales over the last year

### Exercise 3: Performance Optimization
1. Convert a slow correlated subquery to use window functions
2. Optimize a multiple-correlation subquery using CTEs
3. Compare execution plans for different approaches to the same problem

## Common Patterns Summary

| Pattern | Use Case | Example |
|---------|----------|---------|
| EXISTS | Existence checking | Find customers with orders |
| NOT EXISTS | Anti-join | Find customers without orders |
| Scalar correlation | Value comparison | Salary > department average |
| Aggregation correlation | Group statistics | Count per category |
| Sequential comparison | Time-based analysis | Latest record per group |
| Ranking correlation | Top-N per group | Top 3 employees per department |

## Summary

Correlated subqueries provide powerful capabilities for:
- Row-by-row processing and comparisons
- Complex conditional logic
- Existence and non-existence checking
- Hierarchical and sequential data analysis

Key considerations:
- **Performance**: Execute once per outer row
- **Indexing**: Critical for correlation columns
- **Alternatives**: Window functions, CTEs, joins
- **Debugging**: Test correlation logic separately
- **Readability**: Format clearly with proper indentation

Choose correlated subqueries when:
- Logic requires row-by-row evaluation
- EXISTS/NOT EXISTS semantics are needed
- Alternative approaches are more complex
- Performance is acceptable for data volume

This completes our comprehensive coverage of subqueries. Next, we'll move on to advanced SQL techniques including stored procedures, functions, and triggers.
