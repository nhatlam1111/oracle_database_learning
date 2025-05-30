# Subqueries in Oracle Database

## Learning Objectives
By the end of this section, you will understand:
- Different types of subqueries (scalar, single-row, multi-row, multi-column)
- Where subqueries can be used (SELECT, FROM, WHERE, HAVING)
- Single-row vs multi-row subqueries
- Performance considerations and optimization
- When to use subqueries vs joins

## Introduction to Subqueries

A subquery is a query nested inside another query. Subqueries enable you to:
- Break complex problems into manageable parts
- Use results from one query as input to another
- Perform comparisons against aggregated data
- Create dynamic, data-driven conditions

### Basic Subquery Structure
```sql
SELECT column1, column2
FROM table1
WHERE column1 operator (
    SELECT column1
    FROM table2
    WHERE condition
);
```

## Types of Subqueries

### 1. Scalar Subqueries (Single Value)

Returns exactly one row and one column. Can be used anywhere a single value is expected.

```sql
-- Find employees earning more than the average salary
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

-- Use in SELECT clause
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    salary - (SELECT AVG(salary) FROM employees) AS salary_diff_from_avg
FROM employees
ORDER BY salary_diff_from_avg DESC;
```

### 2. Single-Row Subqueries

Returns one row but may have multiple columns. Use with single-row operators (=, !=, <, >, <=, >=).

```sql
-- Find employee with the highest salary
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
);

-- Find employees in the same department as 'John'
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE first_name = 'John'
    AND rownum = 1  -- Ensure single row if multiple Johns exist
);
```

### 3. Multi-Row Subqueries

Returns multiple rows. Use with multi-row operators (IN, NOT IN, ANY, ALL, EXISTS).

```sql
-- Find employees in departments located in 'Seattle' or 'London'
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id IN (
    SELECT d.department_id
    FROM departments d
    JOIN locations l ON d.location_id = l.location_id
    WHERE l.city IN ('Seattle', 'London')
);

-- Find employees earning more than ANY employee in department 50
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);

-- Find employees earning more than ALL employees in department 50
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);
```

### 4. Multi-Column Subqueries

Returns multiple columns. Used for complex comparisons.

```sql
-- Find employees with same job and department as specific employee
SELECT employee_id, first_name, last_name, job_id, department_id
FROM employees
WHERE (job_id, department_id) = (
    SELECT job_id, department_id
    FROM employees
    WHERE employee_id = 100
);

-- Find employees with maximum salary in their department
SELECT employee_id, first_name, last_name, salary, department_id
FROM employees
WHERE (department_id, salary) IN (
    SELECT department_id, MAX(salary)
    FROM employees
    GROUP BY department_id
);
```

## Subquery Locations

### 1. In SELECT Clause (Scalar Subqueries)
```sql
SELECT 
    employee_id,
    first_name,
    last_name,
    (SELECT department_name 
     FROM departments d 
     WHERE d.department_id = e.department_id) AS department_name,
    (SELECT COUNT(*) 
     FROM employees e2 
     WHERE e2.department_id = e.department_id) AS dept_employee_count
FROM employees e
ORDER BY department_name, last_name;
```

### 2. In FROM Clause (Inline Views)
```sql
-- Use subquery as a table (inline view)
SELECT dept_summary.department_name, dept_summary.avg_salary, e.first_name, e.salary
FROM (
    SELECT d.department_id, d.department_name, AVG(e.salary) AS avg_salary
    FROM departments d
    JOIN employees e ON d.department_id = e.department_id
    GROUP BY d.department_id, d.department_name
) dept_summary
JOIN employees e ON dept_summary.department_id = e.department_id
WHERE e.salary > dept_summary.avg_salary
ORDER BY dept_summary.department_name, e.salary DESC;
```

### 3. In WHERE Clause
```sql
-- Most common location for subqueries
SELECT employee_id, first_name, last_name, hire_date
FROM employees
WHERE hire_date > (
    SELECT hire_date
    FROM employees
    WHERE employee_id = 100
)
AND department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
);
```

### 4. In HAVING Clause
```sql
-- Filter groups based on subquery results
SELECT department_id, AVG(salary) AS avg_salary
FROM employees
GROUP BY department_id
HAVING AVG(salary) > (
    SELECT AVG(salary)
    FROM employees
);
```

## Multi-Row Subquery Operators

### 1. IN Operator
```sql
-- Find employees in specific departments
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id IN (1400, 1500, 1700)
);
```

### 2. NOT IN Operator
```sql
-- Find employees NOT in specific departments
-- CAUTION: NOT IN with NULL values can return unexpected results
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
    AND department_id IS NOT NULL  -- Important when using NOT IN
);
```

### 3. ANY/SOME Operator
```sql
-- Find employees earning more than ANY manager
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE job_id LIKE '%MGR%'
)
AND job_id NOT LIKE '%MGR%';

-- SOME is synonym for ANY
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > SOME (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);
```

### 4. ALL Operator
```sql
-- Find employees earning more than ALL employees in department 50
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary > ALL (
    SELECT salary
    FROM employees
    WHERE department_id = 50
);

-- Find departments with ALL employees earning > 5000
SELECT department_id, department_name
FROM departments d
WHERE 5000 < ALL (
    SELECT salary
    FROM employees e
    WHERE e.department_id = d.department_id
);
```

## EXISTS and NOT EXISTS

### EXISTS Operator
Tests for the existence of rows in a subquery. More efficient than IN for many scenarios.

```sql
-- Find employees who have job history
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- Find departments with employees
SELECT d.department_id, d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);
```

### NOT EXISTS Operator
```sql
-- Find employees with no job history
SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- Find departments with no employees
SELECT d.department_id, d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
);
```

## Complex Subquery Examples

### 1. Nested Subqueries
```sql
-- Find employees in departments with the highest average salary
SELECT employee_id, first_name, last_name, department_id, salary
FROM employees
WHERE department_id = (
    SELECT department_id
    FROM (
        SELECT department_id, AVG(salary) AS avg_sal
        FROM employees
        GROUP BY department_id
        ORDER BY avg_sal DESC
    )
    WHERE rownum = 1
);
```

### 2. Subqueries with Analytical Functions
```sql
-- Find employees whose salary is above their department median
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id,
    dept_median.median_salary
FROM employees e
JOIN (
    SELECT 
        department_id,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary
    FROM employees
    GROUP BY department_id
) dept_median ON e.department_id = dept_median.department_id
WHERE e.salary > dept_median.median_salary
ORDER BY e.department_id, e.salary DESC;
```

### 3. Subqueries for Data Validation
```sql
-- Find inconsistencies: employees with invalid department_id
SELECT employee_id, first_name, last_name, department_id
FROM employees
WHERE department_id NOT IN (
    SELECT department_id
    FROM departments
    WHERE department_id IS NOT NULL
)
AND department_id IS NOT NULL;

-- Find orphaned records
SELECT 'EMPLOYEES' AS table_name, COUNT(*) AS orphaned_count
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d WHERE d.department_id = e.department_id
)
UNION ALL
SELECT 'DEPARTMENTS', COUNT(*)
FROM departments d
WHERE NOT EXISTS (
    SELECT 1 FROM locations l WHERE l.location_id = d.location_id
);
```

## Performance Considerations

### 1. Subqueries vs Joins
```sql
-- Subquery approach
SELECT employee_id, first_name, last_name
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM departments
    WHERE location_id = 1700
);

-- Equivalent JOIN approach (often more efficient)
SELECT DISTINCT e.employee_id, e.first_name, e.last_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE d.location_id = 1700;
```

### 2. EXISTS vs IN Performance
```sql
-- EXISTS is often more efficient, especially with large datasets
-- EXISTS stops at first match
SELECT e.employee_id, e.first_name
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM job_history jh
    WHERE jh.employee_id = e.employee_id
);

-- IN processes all values (less efficient for large result sets)
SELECT employee_id, first_name
FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM job_history
);
```

### 3. Avoiding Unnecessary Subqueries
```sql
-- INEFFICIENT: Subquery for simple lookup
SELECT 
    employee_id,
    first_name,
    (SELECT department_name FROM departments WHERE department_id = e.department_id) AS dept_name
FROM employees e;

-- EFFICIENT: Simple join
SELECT e.employee_id, e.first_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

## Common Subquery Patterns

### 1. Top-N Analysis
```sql
-- Top 5 highest paid employees
SELECT employee_id, first_name, last_name, salary
FROM employees
WHERE salary IN (
    SELECT salary
    FROM (
        SELECT DISTINCT salary
        FROM employees
        ORDER BY salary DESC
    )
    WHERE rownum <= 5
)
ORDER BY salary DESC;

-- Alternative with window functions (more efficient)
SELECT employee_id, first_name, last_name, salary
FROM (
    SELECT 
        employee_id, first_name, last_name, salary,
        RANK() OVER (ORDER BY salary DESC) AS salary_rank
    FROM employees
)
WHERE salary_rank <= 5;
```

### 2. Running Totals and Comparisons
```sql
-- Employees earning above running average of their hire order
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.salary,
    e.hire_date,
    (SELECT AVG(salary)
     FROM employees e2
     WHERE e2.hire_date <= e.hire_date) AS running_avg_salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM employees e2
    WHERE e2.hire_date <= e.hire_date
)
ORDER BY e.hire_date;
```

### 3. Data Reconciliation
```sql
-- Find departments where total salaries don't match summary table
SELECT 
    d.department_id,
    d.department_name,
    calc_total.calculated_total,
    summary.summary_total
FROM departments d
CROSS JOIN (
    SELECT SUM(salary) AS calculated_total
    FROM employees
    WHERE department_id = d.department_id
) calc_total
LEFT JOIN salary_summary summary ON d.department_id = summary.department_id
WHERE ABS(calc_total.calculated_total - NVL(summary.summary_total, 0)) > 0.01;
```

## Subquery Optimization Tips

### 1. Use Indexes on Subquery Columns
```sql
-- Ensure subquery filter columns are indexed
CREATE INDEX idx_emp_dept_id ON employees(department_id);
CREATE INDEX idx_emp_hire_date ON employees(hire_date);
```

### 2. Minimize Subquery Executions
```sql
-- INEFFICIENT: Subquery executes for each row
SELECT employee_id, first_name,
    CASE WHEN salary > (SELECT AVG(salary) FROM employees) 
         THEN 'Above Average' 
         ELSE 'Below Average' 
    END AS salary_category
FROM employees;

-- EFFICIENT: Calculate once using WITH clause
WITH avg_salary AS (
    SELECT AVG(salary) AS avg_sal FROM employees
)
SELECT e.employee_id, e.first_name,
    CASE WHEN e.salary > a.avg_sal 
         THEN 'Above Average' 
         ELSE 'Below Average' 
    END AS salary_category
FROM employees e
CROSS JOIN avg_salary a;
```

### 3. Use Appropriate Subquery Type
```sql
-- For existence checking, use EXISTS instead of IN
-- EXISTS (better performance)
SELECT d.department_name
FROM departments d
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department_id = d.department_id
);

-- IN (potentially slower)
SELECT department_name
FROM departments
WHERE department_id IN (
    SELECT DISTINCT department_id FROM employees
);
```

## Common Subquery Mistakes

### 1. NULL Handling with NOT IN
```sql
-- WRONG: NOT IN with NULL values
SELECT employee_id, first_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id FROM departments WHERE location_id = 1700
);
-- If any department_id is NULL, this returns no rows!

-- CORRECT: Handle NULLs explicitly
SELECT employee_id, first_name
FROM employees
WHERE department_id NOT IN (
    SELECT department_id 
    FROM departments 
    WHERE location_id = 1700 
    AND department_id IS NOT NULL
);

-- OR use NOT EXISTS (preferred)
SELECT e.employee_id, e.first_name
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 FROM departments d 
    WHERE d.department_id = e.department_id 
    AND d.location_id = 1700
);
```

### 2. Subquery Returns Multiple Rows
```sql
-- WRONG: Single-row operator with multi-row subquery
SELECT employee_id, first_name
FROM employees
WHERE department_id = (
    SELECT department_id FROM departments WHERE location_id IN (1400, 1700)
);
-- ERROR: ORA-01427: single-row subquery returns more than one row

-- CORRECT: Use multi-row operator
SELECT employee_id, first_name
FROM employees
WHERE department_id IN (
    SELECT department_id FROM departments WHERE location_id IN (1400, 1700)
);
```

### 3. Inefficient Correlated Subqueries
```sql
-- INEFFICIENT: Correlated subquery in SELECT
SELECT 
    e.employee_id,
    e.first_name,
    (SELECT COUNT(*) FROM employees e2 WHERE e2.department_id = e.department_id) AS dept_count
FROM employees e;

-- EFFICIENT: Use window function
SELECT 
    employee_id,
    first_name,
    COUNT(*) OVER (PARTITION BY department_id) AS dept_count
FROM employees;
```

## Practice Exercises

### Exercise 1: Basic Subqueries
1. Find employees earning more than the average salary in their department
2. List departments with more than 5 employees
3. Find the employee with the second-highest salary

### Exercise 2: Advanced Subqueries
1. Find employees who have changed jobs (use job_history table)
2. List products that have never been ordered
3. Find customers who have placed orders in consecutive months

### Exercise 3: Performance Optimization
1. Rewrite a correlated subquery using window functions
2. Compare execution plans for EXISTS vs IN vs JOIN
3. Optimize a complex nested subquery

## Summary

Subqueries are powerful tools for:
- Breaking complex problems into simpler parts
- Dynamic data-driven conditions
- Analytical and reporting queries
- Data validation and quality checks

Key concepts:
- **Scalar subqueries**: Single value, use anywhere
- **Multi-row subqueries**: Use with IN, ANY, ALL, EXISTS
- **Correlated subqueries**: Reference outer query
- **Performance**: Consider joins and window functions as alternatives
- **NULL handling**: Be careful with NOT IN and NULL values

Choose the right approach based on:
- Query complexity and readability
- Performance requirements
- Data volume and indexes
- Maintenance considerations

Next, we'll explore correlated subqueries in detail, which provide even more sophisticated querying capabilities.
