# INNER JOINs - Combining Matching Data

INNER JOINs are the most commonly used type of join in SQL. They return only the rows that have matching values in both tables being joined. This lesson covers everything you need to know about INNER JOINs, from basic syntax to complex multi-table scenarios.

## Table of Contents
1. [Understanding INNER JOINs](#understanding-inner-joins)
2. [Basic INNER JOIN Syntax](#basic-inner-join-syntax)
3. [Join Conditions and Relationships](#join-conditions-and-relationships)
4. [Table Aliases and Readability](#table-aliases-and-readability)
5. [Multiple Table JOINs](#multiple-table-joins)
6. [Advanced JOIN Techniques](#advanced-join-techniques)
7. [Performance Considerations](#performance-considerations)
8. [Common Patterns and Use Cases](#common-patterns-and-use-cases)

## Understanding INNER JOINs

### What is an INNER JOIN?

An INNER JOIN combines rows from two or more tables based on a related column between them. It returns only the rows where there is a match in both tables.

### Visual Representation

```
Table A         Table B         INNER JOIN Result
┌─────┬─────┐   ┌─────┬─────┐   ┌─────┬─────┬─────┐
│ ID  │Name │   │ ID  │City │   │ ID  │Name │City │
├─────┼─────┤   ├─────┼─────┤   ├─────┼─────┼─────┤
│  1  │John │   │  1  │NYC  │   │  1  │John │NYC  │
│  2  │Jane │   │  2  │LA   │   │  2  │Jane │LA   │
│  3  │Bob  │   │  4  │SF   │   └─────┴─────┴─────┘
└─────┴─────┘   └─────┴─────┘   
```

Note: Row 3 (Bob) and Row 4 (SF) don't appear in the result because there's no matching ID.

### When to Use INNER JOINs

- When you need data that exists in both tables
- For master-detail relationships (orders and order items)
- When you want to exclude records without relationships
- For data validation and reporting

## Basic INNER JOIN Syntax

### ANSI Standard Syntax (Recommended)

```sql
SELECT column1, column2, ...
FROM table1
INNER JOIN table2 ON table1.column = table2.column;
```

### Oracle Traditional Syntax (Legacy)

```sql
SELECT column1, column2, ...
FROM table1, table2
WHERE table1.column = table2.column;
```

### Simple Example

```sql
-- Get employee names with their department names
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Join Conditions and Relationships

### Equality Joins (Equi-Joins)

Most common type using the equality operator (=).

```sql
-- Employees with their job titles
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    j.job_title
FROM hr.employees e
INNER JOIN hr.jobs j ON e.job_id = j.job_id;
```

### Multiple Column Joins

When the relationship requires multiple columns.

```sql
-- Example with composite key
SELECT 
    oi.order_id,
    oi.product_id,
    p.product_name,
    oi.quantity
FROM sales.order_items oi
INNER JOIN sales.products p ON oi.product_id = p.product_id;
```

### Join Conditions with Functions

```sql
-- Case-insensitive join
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d 
    ON UPPER(e.department_name) = UPPER(d.department_name);
```

## Table Aliases and Readability

### Why Use Aliases?

1. **Shorter queries**: Less typing and easier to read
2. **Disambiguation**: Clear which table each column comes from
3. **Required for self-joins**: Must use aliases when joining table to itself

### Alias Best Practices

```sql
-- Good: Meaningful aliases
SELECT 
    emp.first_name,
    emp.last_name,
    dept.department_name,
    mgr.first_name AS manager_first_name
FROM hr.employees emp
INNER JOIN hr.departments dept ON emp.department_id = dept.department_id
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id;

-- Avoid: Unclear aliases
SELECT e.first_name, d.department_name
FROM hr.employees x
INNER JOIN hr.departments y ON x.department_id = y.department_id;
```

### Column Disambiguation

```sql
-- Required when column names exist in multiple tables
SELECT 
    e.employee_id,        -- Clear which table
    e.first_name,
    e.last_name,
    d.department_id,      -- Both tables have department_id
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Multiple Table JOINs

### Three Table JOIN

```sql
-- Employees with department and location information
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city,
    l.country_id
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id;
```

### Four Table JOIN

```sql
-- Complete employee location hierarchy
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    l.city,
    c.country_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.locations l ON d.location_id = l.location_id
INNER JOIN hr.countries c ON l.country_id = c.country_id;
```

### Complex Sales Analysis

```sql
-- Complete order information
SELECT 
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_date,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS line_total
FROM sales.customers c
INNER JOIN sales.orders o ON c.customer_id = o.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
INNER JOIN sales.products p ON oi.product_id = p.product_id
ORDER BY o.order_date, c.last_name;
```

## Advanced JOIN Techniques

### JOINs with WHERE Clauses

```sql
-- Filter before or after joining
SELECT 
    e.first_name,
    e.last_name,
    d.department_name,
    e.salary
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.salary > 10000
  AND d.department_name LIKE '%Sales%';
```

### JOINs with Aggregate Functions

```sql
-- Department statistics
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    SUM(e.salary) AS total_payroll
FROM hr.departments d
INNER JOIN hr.employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY average_salary DESC;
```

### JOINs with Subqueries

```sql
-- Employees in departments with above-average headcount
SELECT 
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE d.department_id IN (
    SELECT department_id
    FROM hr.employees
    GROUP BY department_id
    HAVING COUNT(*) > (
        SELECT AVG(emp_count)
        FROM (
            SELECT COUNT(*) AS emp_count
            FROM hr.employees
            GROUP BY department_id
        )
    )
);
```

## Performance Considerations

### Index Usage

```sql
-- Ensure indexes exist on join columns
CREATE INDEX idx_emp_dept_id ON hr.employees(department_id);
CREATE INDEX idx_dept_location_id ON hr.departments(location_id);

-- Query optimizer can use these indexes for faster joins
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Join Order Optimization

```sql
-- Oracle's cost-based optimizer usually handles this automatically
-- But understanding helps with manual optimization

-- Generally: Join smaller tables first, filter early
SELECT /*+ USE_NL(e d) */ 
    e.first_name, 
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.salary > 15000;  -- Filter reduces result set early
```

### Avoiding Cartesian Products

```sql
-- Wrong: Missing join condition creates Cartesian product
SELECT e.first_name, d.department_name
FROM hr.employees e, hr.departments d;  -- Results in employee_count * dept_count rows

-- Correct: Proper join condition
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Common Patterns and Use Cases

### 1. Master-Detail Reporting

```sql
-- Order summary with line items
SELECT 
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer,
    COUNT(oi.product_id) AS item_count,
    SUM(oi.quantity * oi.unit_price) AS order_total
FROM sales.orders o
INNER JOIN sales.customers c ON o.customer_id = c.customer_id
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_date, c.first_name, c.last_name
ORDER BY o.order_date DESC;
```

### 2. Hierarchical Data

```sql
-- Employee manager relationships
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee,
    mgr.first_name || ' ' || mgr.last_name AS manager,
    emp.salary,
    mgr.salary AS manager_salary
FROM hr.employees emp
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY mgr.last_name, emp.last_name;
```

### 3. Data Validation

```sql
-- Find orders with invalid product references
SELECT DISTINCT o.order_id
FROM sales.orders o
INNER JOIN sales.order_items oi ON o.order_id = oi.order_id
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales.products p 
    WHERE p.product_id = oi.product_id
);
```

### 4. Cross-Reference Queries

```sql
-- Products never ordered
SELECT p.product_id, p.product_name
FROM sales.products p
WHERE NOT EXISTS (
    SELECT 1 
    FROM sales.order_items oi 
    WHERE oi.product_id = p.product_id
);
```

### 5. Statistical Analysis

```sql
-- Employee performance by department and job
SELECT 
    d.department_name,
    j.job_title,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS avg_salary,
    MIN(e.hire_date) AS earliest_hire,
    MAX(e.hire_date) AS latest_hire
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
INNER JOIN hr.jobs j ON e.job_id = j.job_id
GROUP BY d.department_name, j.job_title
HAVING COUNT(e.employee_id) > 1
ORDER BY d.department_name, avg_salary DESC;
```

## Best Practices

### 1. Always Use Table Aliases

```sql
-- Good
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Avoid
SELECT first_name, department_name
FROM hr.employees
INNER JOIN hr.departments ON employees.department_id = departments.department_id;
```

### 2. Qualify All Column Names

```sql
-- Good: Clear column source
SELECT 
    e.employee_id,
    e.first_name,
    d.department_id,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### 3. Use Meaningful Aliases

```sql
-- Good: Descriptive aliases
FROM hr.employees emp
INNER JOIN hr.departments dept ON emp.department_id = dept.department_id
INNER JOIN hr.employees mgr ON emp.manager_id = mgr.employee_id;
```

### 4. Format for Readability

```sql
-- Good formatting
SELECT 
    emp.employee_id,
    emp.first_name,
    emp.last_name,
    dept.department_name,
    job.job_title
FROM hr.employees emp
    INNER JOIN hr.departments dept 
        ON emp.department_id = dept.department_id
    INNER JOIN hr.jobs job 
        ON emp.job_id = job.job_id
WHERE emp.salary > 5000
ORDER BY dept.department_name, emp.last_name;
```

### 5. Filter Early and Appropriately

```sql
-- Filter before join when possible
SELECT e.first_name, d.department_name
FROM (
    SELECT employee_id, first_name, department_id
    FROM hr.employees
    WHERE salary > 10000
) e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Common Errors and Solutions

### Error 1: Ambiguous Column Names

```sql
-- Error: column ambiguously defined
SELECT employee_id, department_id
FROM hr.employees
INNER JOIN hr.departments ON employees.department_id = departments.department_id;

-- Solution: Use table aliases
SELECT e.employee_id, d.department_id
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Error 2: Missing Join Conditions

```sql
-- Wrong: Cartesian product
SELECT e.first_name, d.department_name
FROM hr.employees e, hr.departments d;

-- Correct: Proper join condition
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

### Error 3: Data Type Mismatches

```sql
-- Potential issue: Implicit conversion
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = TO_CHAR(d.department_id);

-- Better: Ensure matching data types
SELECT e.first_name, d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;
```

## Testing and Validation

### Verify Join Results

```sql
-- Check record counts before and after join
SELECT COUNT(*) AS employee_count FROM hr.employees;
SELECT COUNT(*) AS department_count FROM hr.departments;

-- Compare with join result
SELECT COUNT(*) AS join_result_count
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id;

-- Investigate discrepancies
SELECT COUNT(*) AS employees_without_dept
FROM hr.employees
WHERE department_id IS NULL;
```

### Validate Business Logic

```sql
-- Ensure join makes business sense
SELECT 
    e.first_name,
    e.last_name,
    e.department_id AS emp_dept_id,
    d.department_id AS dept_dept_id,
    d.department_name
FROM hr.employees e
INNER JOIN hr.departments d ON e.department_id = d.department_id
WHERE e.department_id != d.department_id;  -- Should return no rows
```

## Next Steps

After mastering INNER JOINs, you should:

1. **Practice with multiple tables**: Try joining 3-4 tables together
2. **Understand performance**: Learn about execution plans and optimization
3. **Move to OUTER JOINs**: Learn when you need to include unmatched records
4. **Combine with other SQL features**: Use JOINs with window functions, CTEs, etc.

INNER JOINs form the foundation of relational query writing. Practice extensively with different scenarios before moving to more complex join types.

---

**Key Takeaway**: INNER JOINs return only matching records from both tables. Always ensure your join conditions accurately reflect the business relationships between your tables.
