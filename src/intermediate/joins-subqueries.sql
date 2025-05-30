-- File: /oracle-database-learning/oracle-database-learning/src/intermediate/joins-subqueries.sql

-- SQL statements demonstrating JOIN operations and subqueries

-- Example of INNER JOIN
SELECT 
    employees.first_name, 
    employees.last_name, 
    departments.department_name
FROM 
    employees
INNER JOIN 
    departments ON employees.department_id = departments.id;

-- Example of LEFT JOIN
SELECT 
    employees.first_name, 
    employees.last_name, 
    departments.department_name
FROM 
    employees
LEFT JOIN 
    departments ON employees.department_id = departments.id;

-- Example of RIGHT JOIN
SELECT 
    employees.first_name, 
    employees.last_name, 
    departments.department_name
FROM 
    employees
RIGHT JOIN 
    departments ON employees.department_id = departments.id;

-- Example of a Subquery
SELECT 
    first_name, 
    last_name
FROM 
    employees
WHERE 
    department_id IN (SELECT id FROM departments WHERE department_name = 'Sales');

-- Example of GROUP BY with HAVING clause
SELECT 
    department_id, 
    COUNT(*) AS employee_count
FROM 
    employees
GROUP BY 
    department_id
HAVING 
    COUNT(*) > 5;