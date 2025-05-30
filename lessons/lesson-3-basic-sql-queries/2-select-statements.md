# SELECT Statements - The Foundation of SQL

The SELECT statement is the most fundamental and frequently used SQL command. It allows you to retrieve data from one or more tables in your database.

## Basic SELECT Syntax

### Simple SELECT Structure
```sql
SELECT column1, column2, ...
FROM table_name;
```

### Universal Query Pattern
```sql
SELECT [DISTINCT] column_list
FROM table_name
[WHERE condition]
[ORDER BY column_list]
[GROUP BY column_list]
[HAVING condition];
```

## Basic SELECT Operations

### 1. Select All Columns
Use the asterisk (*) to select all columns from a table:

```sql
-- Select all columns from employees table
SELECT * FROM hr.employees;

-- Select all columns from departments table  
SELECT * FROM hr.departments;
```

**Best Practice**: Avoid using `SELECT *` in production code. Always specify the columns you need.

### 2. Select Specific Columns
Specify only the columns you need:

```sql
-- Select specific employee information
SELECT employee_id, first_name, last_name, email
FROM hr.employees;

-- Select department basic info
SELECT department_id, department_name
FROM hr.departments;
```

### 3. Column Aliases
Use aliases to provide meaningful names for columns:

```sql
-- Using AS keyword (recommended)
SELECT 
    employee_id AS "Employee ID",
    first_name AS "First Name",
    last_name AS "Last Name",
    salary AS "Monthly Salary"
FROM hr.employees;

-- Without AS keyword (also valid)
SELECT 
    employee_id "Employee ID",
    first_name "First Name",
    last_name "Last Name", 
    salary "Monthly Salary"
FROM hr.employees;

-- Simple aliases without quotes
SELECT 
    employee_id emp_id,
    first_name fname,
    last_name lname,
    salary monthly_salary
FROM hr.employees;
```

## String Operations and Concatenation

### 1. String Concatenation
Oracle provides multiple ways to concatenate strings:

```sql
-- Using || operator (Oracle standard)
SELECT 
    first_name || ' ' || last_name AS full_name,
    'Employee: ' || first_name || ' ' || last_name AS employee_label
FROM hr.employees;

-- Using CONCAT function (limited to 2 arguments)
SELECT 
    CONCAT(first_name, last_name) AS name_no_space,
    CONCAT(CONCAT(first_name, ' '), last_name) AS full_name
FROM hr.employees;
```

### 2. String Functions
```sql
-- Common string functions
SELECT 
    employee_id,
    UPPER(first_name) AS first_name_upper,
    LOWER(last_name) AS last_name_lower,
    INITCAP(email) AS email_proper_case,
    LENGTH(first_name) AS name_length,
    SUBSTR(first_name, 1, 3) AS first_three_chars
FROM hr.employees;
```

## Arithmetic Operations

### 1. Basic Arithmetic
```sql
-- Calculate annual salary and bonus
SELECT 
    employee_id,
    first_name,
    last_name,
    salary AS monthly_salary,
    salary * 12 AS annual_salary,
    salary * 0.1 AS monthly_bonus,
    (salary * 12) + (salary * 0.1 * 12) AS total_annual_compensation
FROM hr.employees;
```

### 2. Handling NULL Values
```sql
-- Using NVL to handle NULL values
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    commission_pct,
    -- Handle NULL commission
    NVL(commission_pct, 0) AS commission_safe,
    -- Calculate total compensation
    salary + (salary * NVL(commission_pct, 0)) AS total_compensation
FROM hr.employees;

-- Using NVL2 for more complex NULL handling
SELECT 
    employee_id,
    first_name,
    last_name,
    commission_pct,
    NVL2(commission_pct, 'Has Commission', 'No Commission') AS commission_status
FROM hr.employees;
```

## Working with Dates

### 1. Date Functions
```sql
-- Common date operations
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    SYSDATE AS current_date,
    SYSDATE - hire_date AS days_employed,
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS years_employed,
    ADD_MONTHS(hire_date, 12) AS first_anniversary
FROM hr.employees;
```

### 2. Date Formatting
```sql
-- Format dates for display
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    TO_CHAR(hire_date, 'DD-MON-YYYY') AS hire_date_formatted,
    TO_CHAR(hire_date, 'Month DD, YYYY') AS hire_date_long,
    TO_CHAR(hire_date, 'DY') AS hire_day_of_week,
    EXTRACT(YEAR FROM hire_date) AS hire_year
FROM hr.employees;
```

## Data Type Conversions

### 1. Number to String Conversion
```sql
-- Converting numbers to formatted strings
SELECT 
    employee_id,
    first_name,
    salary,
    TO_CHAR(salary, '$999,999.99') AS salary_formatted,
    TO_CHAR(salary, 'L999,999.99') AS salary_with_currency,
    TO_CHAR(salary * 12, '$9,999,999.99') AS annual_salary_formatted
FROM hr.employees;
```

### 2. String to Number/Date Conversion
```sql
-- Converting strings to numbers and dates
SELECT 
    TO_NUMBER('12345') AS string_to_number,
    TO_NUMBER('$1,234.56', '$9,999.99') AS formatted_string_to_number,
    TO_DATE('2023-12-25', 'YYYY-MM-DD') AS string_to_date,
    TO_DATE('December 25, 2023', 'Month DD, YYYY') AS long_string_to_date
FROM dual;
```

## DISTINCT Keyword

### 1. Remove Duplicates
```sql
-- Get unique department IDs
SELECT DISTINCT department_id
FROM hr.employees
ORDER BY department_id;

-- Get unique job titles
SELECT DISTINCT job_id
FROM hr.employees
ORDER BY job_id;

-- Multiple column DISTINCT
SELECT DISTINCT department_id, job_id
FROM hr.employees
ORDER BY department_id, job_id;
```

### 2. Count Distinct Values
```sql
-- Count unique values
SELECT 
    COUNT(*) AS total_employees,
    COUNT(DISTINCT department_id) AS unique_departments,
    COUNT(DISTINCT job_id) AS unique_jobs,
    COUNT(DISTINCT manager_id) AS unique_managers
FROM hr.employees;
```

## Conditional Logic with CASE

### 1. Simple CASE Expressions
```sql
-- Categorize employees by salary
SELECT 
    employee_id,
    first_name,
    last_name,
    salary,
    CASE 
        WHEN salary >= 15000 THEN 'High'
        WHEN salary >= 8000 THEN 'Medium'
        WHEN salary >= 4000 THEN 'Low'
        ELSE 'Entry Level'
    END AS salary_category
FROM hr.employees;
```

### 2. Complex CASE Logic
```sql
-- Employee status based on multiple factors
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    salary,
    CASE 
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 10 AND salary >= 10000 THEN 'Senior High Earner'
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 10 THEN 'Senior Employee'
        WHEN salary >= 10000 THEN 'High Earner'
        WHEN ROUND((SYSDATE - hire_date) / 365.25) >= 5 THEN 'Mid-Level'
        ELSE 'Junior Employee'
    END AS employee_category
FROM hr.employees;
```

## Working with Multiple Tables (Preview)

### 1. Cartesian Product (Not Recommended)
```sql
-- This creates a cartesian product - generally not what you want
SELECT e.first_name, e.last_name, d.department_name
FROM hr.employees e, hr.departments d;
```

### 2. Proper JOIN Preview
```sql
-- Preview of JOIN (covered in detail in Lesson 4)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    d.department_name
FROM hr.employees e
JOIN hr.departments d ON e.department_id = d.department_id;
```

## Common Functions Reference

### 1. String Functions
```sql
SELECT 
    'Oracle Database' AS original,
    UPPER('Oracle Database') AS upper_case,
    LOWER('Oracle Database') AS lower_case,
    INITCAP('oracle database') AS proper_case,
    LENGTH('Oracle Database') AS string_length,
    SUBSTR('Oracle Database', 1, 6) AS substring,
    REPLACE('Oracle Database', 'Oracle', 'MySQL') AS replaced,
    TRIM('  Oracle Database  ') AS trimmed,
    LPAD('123', 6, '0') AS left_padded,
    RPAD('123', 6, '0') AS right_padded
FROM dual;
```

### 2. Numeric Functions
```sql
SELECT 
    ABS(-15) AS absolute_value,
    CEIL(15.7) AS ceiling,
    FLOOR(15.7) AS floor_value,
    ROUND(15.789, 2) AS rounded,
    TRUNC(15.789, 1) AS truncated,
    MOD(17, 5) AS modulus,
    POWER(2, 3) AS power,
    SQRT(16) AS square_root
FROM dual;
```

### 3. Date Functions
```sql
SELECT 
    SYSDATE AS current_date,
    ADD_MONTHS(SYSDATE, 6) AS six_months_later,
    NEXT_DAY(SYSDATE, 'MONDAY') AS next_monday,
    LAST_DAY(SYSDATE) AS last_day_of_month,
    MONTHS_BETWEEN(SYSDATE, DATE '2023-01-01') AS months_since_new_year,
    EXTRACT(YEAR FROM SYSDATE) AS current_year,
    EXTRACT(MONTH FROM SYSDATE) AS current_month
FROM dual;
```

## Performance Considerations

### 1. Column Selection
```sql
-- Good: Select only needed columns
SELECT employee_id, first_name, last_name
FROM hr.employees;

-- Avoid: Using SELECT * unnecessarily
-- SELECT * FROM hr.employees;
```

### 2. Function Usage
```sql
-- Efficient: Use functions on constants when possible
SELECT employee_id, first_name, salary
FROM hr.employees
WHERE salary > 10000;

-- Less efficient: Using functions on columns in WHERE clause
-- SELECT employee_id, first_name, salary
-- FROM hr.employees
-- WHERE UPPER(first_name) = 'JOHN';
```

## Practical Examples

### 1. Employee Information Report
```sql
-- Comprehensive employee report
SELECT 
    employee_id AS "ID",
    first_name || ' ' || last_name AS "Full Name",
    UPPER(email) AS "Email",
    TO_CHAR(hire_date, 'Month DD, YYYY') AS "Hire Date",
    ROUND((SYSDATE - hire_date) / 365.25, 1) AS "Years of Service",
    TO_CHAR(salary, '$999,999') AS "Monthly Salary",
    TO_CHAR(salary * 12, '$9,999,999') AS "Annual Salary",
    CASE 
        WHEN commission_pct IS NOT NULL THEN 'Yes'
        ELSE 'No'
    END AS "Has Commission"
FROM hr.employees
ORDER BY employee_id;
```

### 2. Product Catalog Display
```sql
-- Product information for catalog
SELECT 
    product_id AS "Product ID",
    INITCAP(product_name) AS "Product Name",
    TO_CHAR(unit_price, '$999.99') AS "Unit Price",
    units_in_stock AS "In Stock",
    CASE 
        WHEN units_in_stock = 0 THEN 'Out of Stock'
        WHEN units_in_stock <= reorder_level THEN 'Low Stock'
        ELSE 'In Stock'
    END AS "Stock Status",
    CASE 
        WHEN discontinued = 1 THEN 'Discontinued'
        ELSE 'Active'
    END AS "Product Status"
FROM sales.products
ORDER BY category_id, product_name;
```

## Exercises

### Exercise 1: Basic Employee Information
```sql
-- Write a query to display employee ID, full name (first + last),
-- email in lowercase, and hire date formatted as 'DD-MON-YYYY'
-- Your query here:
```

### Exercise 2: Salary Analysis
```sql
-- Create a query showing employee ID, full name, monthly salary,
-- annual salary, and salary category (High/Medium/Low based on your criteria)
-- Your query here:
```

### Exercise 3: Product Information
```sql
-- Display product name in proper case, formatted unit price,
-- stock status, and whether the product is active or discontinued
-- Your query here:
```

## Best Practices Summary

1. **Always specify column names** instead of using SELECT *
2. **Use meaningful aliases** for better readability
3. **Handle NULL values** appropriately with NVL/NVL2
4. **Format output** for better presentation using TO_CHAR
5. **Use CASE statements** for conditional logic
6. **Comment your queries** for documentation
7. **Test with small datasets** first
8. **Consider performance** when using functions

## Common Mistakes to Avoid

1. **Forgetting semicolons** at the end of statements
2. **Incorrect quotation marks** for aliases (use double quotes for spaces)
3. **Not handling NULL values** in calculations
4. **Using functions unnecessarily** in WHERE clauses
5. **Mixing single and double quotes** incorrectly
6. **Forgetting table aliases** when column names are ambiguous

## Next Steps

Now that you understand SELECT statements, proceed to:
1. **WHERE Clause and Filtering** - Learn to filter your data
2. **ORDER BY** - Sort your results effectively
3. **Aggregate Functions** - Summarize your data
4. Practice with the provided exercises

Master these fundamentals before moving to joins and subqueries in Lesson 4!
