# WHERE Clause and Filtering Data

The WHERE clause is used to filter records and retrieve only those that meet specific conditions. It's one of the most important parts of SQL for data analysis and reporting.

## Basic WHERE Clause Syntax

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

## Comparison Operators

### 1. Equality and Inequality
```sql
-- Exact match
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id = 60;

-- Not equal (multiple ways)
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE department_id != 60;

-- Alternative not equal operators
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE department_id <> 60;

SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE NOT department_id = 60;
```

### 2. Numeric Comparisons
```sql
-- Greater than
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary > 10000;

-- Greater than or equal
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary >= 10000;

-- Less than
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary < 5000;

-- Less than or equal
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary <= 5000;
```

### 3. Date Comparisons
```sql
-- Employees hired after a specific date
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date > DATE '1995-01-01';

-- Employees hired in the last 10 years
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date >= ADD_MONTHS(SYSDATE, -120);

-- Employees hired on a specific date
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date = DATE '1987-06-17';
```

## String Pattern Matching

### 1. LIKE Operator
The LIKE operator is used for pattern matching with wildcards:
- `%` - matches any sequence of characters (including zero characters)
- `_` - matches exactly one character

```sql
-- Names starting with 'S'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE 'S%';

-- Names ending with 'n'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE '%n';

-- Names containing 'an'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE '%an%';

-- Names with exactly 4 characters
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name LIKE '____';

-- Email addresses from specific domain
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE email LIKE '%@company.com';
```

### 2. Case-Insensitive Searches
```sql
-- Using UPPER function for case-insensitive search
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE UPPER(first_name) LIKE 'STEVEN%';

-- Using LOWER function
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE LOWER(first_name) LIKE 'steven%';
```

### 3. NOT LIKE
```sql
-- Names not starting with 'S'
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name NOT LIKE 'S%';

-- Email addresses not from specific domain
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE email NOT LIKE '%@oldcompany.com';
```

## Range and List Filtering

### 1. BETWEEN Operator
```sql
-- Salary range
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary BETWEEN 5000 AND 10000;

-- Date range
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE hire_date BETWEEN DATE '1990-01-01' AND DATE '1999-12-31';

-- NOT BETWEEN
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE salary NOT BETWEEN 5000 AND 10000;
```

### 2. IN Operator
```sql
-- Specific departments
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id IN (10, 20, 30);

-- Specific job IDs
SELECT employee_id, first_name, last_name, job_id
FROM hr.employees
WHERE job_id IN ('IT_PROG', 'SA_REP', 'FI_ACCOUNT');

-- NOT IN
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE department_id NOT IN (10, 20, 30);

-- String values with IN
SELECT product_id, product_name, category_id
FROM sales.products
WHERE product_name IN ('Chai', 'Chang', 'Aniseed Syrup');
```

## NULL Value Handling

### 1. IS NULL
```sql
-- Employees without commission
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
WHERE commission_pct IS NULL;

-- Employees without managers
SELECT employee_id, first_name, last_name, manager_id
FROM hr.employees
WHERE manager_id IS NULL;
```

### 2. IS NOT NULL
```sql
-- Employees with commission
SELECT employee_id, first_name, last_name, commission_pct
FROM hr.employees
WHERE commission_pct IS NOT NULL;

-- Products with reorder level set
SELECT product_id, product_name, reorder_level
FROM sales.products
WHERE reorder_level IS NOT NULL;
```

### 3. Important NULL Considerations
```sql
-- NULL comparisons always return FALSE
-- These queries return no results even if NULL values exist:
SELECT * FROM hr.employees WHERE commission_pct = NULL;  -- Wrong!
SELECT * FROM hr.employees WHERE commission_pct != NULL; -- Wrong!

-- Correct way to check for NULL:
SELECT * FROM hr.employees WHERE commission_pct IS NULL;     -- Correct
SELECT * FROM hr.employees WHERE commission_pct IS NOT NULL; -- Correct
```

## Logical Operators

### 1. AND Operator
```sql
-- Multiple conditions must be true
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE salary > 8000 AND department_id = 60;

-- Three conditions
SELECT employee_id, first_name, last_name, salary, hire_date
FROM hr.employees
WHERE salary > 5000 
  AND department_id IN (10, 20, 30)
  AND hire_date > DATE '1990-01-01';
```

### 2. OR Operator
```sql
-- Any condition can be true
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE salary > 15000 OR department_id = 90;

-- Multiple OR conditions
SELECT employee_id, first_name, last_name, job_id
FROM hr.employees
WHERE job_id = 'IT_PROG' 
   OR job_id = 'SA_REP' 
   OR job_id = 'FI_ACCOUNT';
```

### 3. NOT Operator
```sql
-- Negate conditions
SELECT employee_id, first_name, last_name, department_id
FROM hr.employees
WHERE NOT department_id = 60;

-- NOT with complex conditions
SELECT employee_id, first_name, last_name, salary, commission_pct
FROM hr.employees
WHERE NOT (salary < 5000 OR commission_pct IS NULL);
```

## Operator Precedence and Parentheses

### 1. Understanding Precedence
```sql
-- Without parentheses (AND has higher precedence than OR)
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE department_id = 60 OR department_id = 90 AND salary > 15000;
-- This is interpreted as: department_id = 60 OR (department_id = 90 AND salary > 15000)

-- With parentheses for clarity
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE (department_id = 60 OR department_id = 90) AND salary > 15000;
```

### 2. Complex Conditions with Parentheses
```sql
-- Complex business logic
SELECT employee_id, first_name, last_name, salary, department_id, commission_pct
FROM hr.employees
WHERE (department_id IN (80, 90) AND salary > 10000)
   OR (commission_pct IS NOT NULL AND salary > 8000)
   OR (department_id = 60 AND hire_date < DATE '1995-01-01');
```

## Advanced Filtering Techniques

### 1. Regular Expressions (Oracle Specific)
```sql
-- Using REGEXP_LIKE for complex pattern matching
SELECT employee_id, first_name, last_name, phone_number
FROM hr.employees
WHERE REGEXP_LIKE(phone_number, '^[0-9]{3}\.[0-9]{3}\.[0-9]{4}$');

-- Email validation with regex
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE REGEXP_LIKE(email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

-- Names starting with vowels
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE REGEXP_LIKE(first_name, '^[AEIOU]', 'i');
```

### 2. EXISTS Operator (Preview)
```sql
-- Employees who have job history (preview of subqueries)
SELECT e.employee_id, e.first_name, e.last_name
FROM hr.employees e
WHERE EXISTS (
    SELECT 1 
    FROM hr.job_history jh 
    WHERE jh.employee_id = e.employee_id
);
```

## Filtering with Functions

### 1. Date Functions in WHERE
```sql
-- Employees hired in specific year
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE EXTRACT(YEAR FROM hire_date) = 1987;

-- Employees hired in current month
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE EXTRACT(MONTH FROM hire_date) = EXTRACT(MONTH FROM SYSDATE);

-- Employees with service anniversary this month
SELECT employee_id, first_name, last_name, hire_date
FROM hr.employees
WHERE EXTRACT(MONTH FROM hire_date) = EXTRACT(MONTH FROM SYSDATE)
  AND EXTRACT(DAY FROM hire_date) = EXTRACT(DAY FROM SYSDATE);
```

### 2. String Functions in WHERE
```sql
-- Filter by string length
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE LENGTH(first_name) > 6;

-- Filter by substring
SELECT employee_id, first_name, last_name, email
FROM hr.employees
WHERE SUBSTR(email, 1, 1) = UPPER(SUBSTR(first_name, 1, 1));
```

### 3. Numeric Functions in WHERE
```sql
-- Round salary to nearest thousand
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE MOD(salary, 1000) = 0;

-- Employees with salary ending in 00
SELECT employee_id, first_name, last_name, salary
FROM hr.employees
WHERE MOD(salary, 100) = 0;
```

## Performance Considerations

### 1. Index-Friendly Queries
```sql
-- Good: Direct column comparison (can use index)
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE employee_id = 100;

-- Less efficient: Function on column (may not use index)
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE UPPER(first_name) = 'STEVEN';

-- Better: Store data in consistent case or use function-based index
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE first_name = 'Steven';
```

### 2. Selective Filtering
```sql
-- More selective condition first
SELECT employee_id, first_name, last_name, salary, department_id
FROM hr.employees
WHERE salary > 15000        -- More selective
  AND department_id = 60;   -- Less selective

-- Use specific conditions when possible
SELECT employee_id, first_name, last_name
FROM hr.employees
WHERE employee_id BETWEEN 100 AND 110;  -- Range scan
```

## Real-World Examples

### 1. Employee Search System
```sql
-- Comprehensive employee search
SELECT 
    employee_id,
    first_name || ' ' || last_name AS full_name,
    email,
    phone_number,
    hire_date,
    salary,
    department_id
FROM hr.employees
WHERE (first_name LIKE '%ohn%' OR last_name LIKE '%ohn%')  -- Name search
  AND salary BETWEEN 5000 AND 15000                        -- Salary range
  AND hire_date >= DATE '1990-01-01'                       -- Hire date filter
  AND commission_pct IS NOT NULL;                          -- Has commission
```

### 2. Product Inventory Report
```sql
-- Products needing attention
SELECT 
    product_id,
    product_name,
    unit_price,
    units_in_stock,
    reorder_level,
    discontinued
FROM sales.products
WHERE (units_in_stock <= reorder_level OR units_in_stock = 0)  -- Low stock or out of stock
  AND discontinued = 0                                         -- Active products only
  AND unit_price > 10                                          -- Higher value items
ORDER BY units_in_stock ASC;
```

### 3. Sales Analysis
```sql
-- High-value recent orders
SELECT 
    o.order_id,
    o.customer_id,
    o.order_date,
    o.freight
FROM sales.orders o
WHERE o.order_date >= ADD_MONTHS(SYSDATE, -6)  -- Last 6 months
  AND o.freight > 50                           -- High shipping cost
  AND o.shipped_date IS NOT NULL;              -- Already shipped
```

## Common WHERE Clause Patterns

### 1. Data Quality Checks
```sql
-- Find potential data quality issues
SELECT employee_id, first_name, last_name, email, phone_number
FROM hr.employees
WHERE email IS NULL                          -- Missing email
   OR phone_number IS NULL                   -- Missing phone
   OR LENGTH(first_name) < 2                 -- Very short names
   OR salary <= 0                            -- Invalid salary
   OR hire_date > SYSDATE;                   -- Future hire date
```

### 2. Business Rule Validation
```sql
-- Employees violating business rules
SELECT employee_id, first_name, last_name, salary, commission_pct
FROM hr.employees
WHERE (job_id LIKE 'SA_%' AND commission_pct IS NULL)     -- Sales without commission
   OR (job_id NOT LIKE 'SA_%' AND commission_pct IS NOT NULL) -- Non-sales with commission
   OR (salary < 2000)                                     -- Below minimum wage
   OR (salary > 50000 AND job_id LIKE '%CLERK%');         -- Clerk with high salary
```

### 3. Reporting Filters
```sql
-- Monthly report filters
SELECT 
    employee_id,
    first_name,
    last_name,
    department_id,
    salary
FROM hr.employees
WHERE department_id IN (10, 20, 30, 40, 50)              -- Specific departments
  AND salary BETWEEN 3000 AND 20000                      -- Salary range
  AND hire_date BETWEEN DATE '2020-01-01' AND DATE '2023-12-31'  -- Date range
  AND (commission_pct IS NULL OR commission_pct < 0.3);   -- Commission filter
```

## Exercises

### Exercise 1: Basic Filtering
```sql
-- Find all IT programmers with salary greater than 5000
-- Your query here:
```

### Exercise 2: Complex Conditions
```sql
-- Find employees who either:
-- 1. Work in department 60 with salary > 8000, OR
-- 2. Have commission and salary > 10000, OR  
-- 3. Are managers (manager_id IS NULL) in department 90
-- Your query here:
```

### Exercise 3: String Pattern Matching
```sql
-- Find all products whose names contain 'ch' (case insensitive)
-- and are not discontinued
-- Your query here:
```

### Exercise 4: Date Filtering
```sql
-- Find employees hired in the 1990s who still work in their original department
-- (hint: check if they don't appear in job_history table)
-- Your query here:
```

## Best Practices Summary

1. **Use appropriate operators** for each data type
2. **Handle NULL values** explicitly with IS NULL/IS NOT NULL
3. **Use parentheses** to clarify complex conditions
4. **Be mindful of performance** when using functions on columns
5. **Use specific conditions** rather than broad ranges when possible
6. **Test edge cases** including NULL, empty strings, and boundary values
7. **Consider case sensitivity** for string comparisons
8. **Use indexes effectively** by avoiding functions on indexed columns

## Common Mistakes to Avoid

1. **Using = or != with NULL** values (use IS NULL/IS NOT NULL)
2. **Forgetting operator precedence** (use parentheses for clarity)
3. **Case sensitivity issues** in string comparisons
4. **Incorrect date formats** (use DATE literal or TO_DATE function)
5. **Using LIKE without wildcards** (use = instead)
6. **Not considering NULL** in NOT IN conditions
7. **Overusing functions** on columns in WHERE clauses

## Next Steps

Master WHERE clause filtering before moving to:
1. **ORDER BY** - Learn to sort your filtered results
2. **Aggregate Functions** - Summarize your filtered data
3. **GROUP BY and HAVING** - Group and filter aggregated data

The WHERE clause is fundamental to all SQL queries, so practice extensively with different conditions and data types!
