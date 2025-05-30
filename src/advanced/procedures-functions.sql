-- This file contains advanced SQL techniques, including stored procedures, functions, and triggers.

-- Stored Procedures
-- A stored procedure is a set of SQL statements that can be stored in the database and executed as a single unit. 
-- They can accept parameters and return values, making them useful for encapsulating business logic.

CREATE OR REPLACE PROCEDURE example_procedure (p_id IN NUMBER) IS
    v_name VARCHAR2(100);
BEGIN
    SELECT name INTO v_name FROM employees WHERE id = p_id;
    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_name);
END example_procedure;
/

-- Functions
-- A function is similar to a stored procedure but is designed to return a single value. 
-- Functions can be used in SQL statements, making them versatile for calculations and data manipulation.

CREATE OR REPLACE FUNCTION get_employee_name (p_id IN NUMBER) RETURN VARCHAR2 IS
    v_name VARCHAR2(100);
BEGIN
    SELECT name INTO v_name FROM employees WHERE id = p_id;
    RETURN v_name;
END get_employee_name;
/

-- Triggers
-- A trigger is a special type of stored procedure that automatically executes in response to certain events on a table or view. 
-- Triggers can be used for auditing, enforcing business rules, and maintaining data integrity.

CREATE OR REPLACE TRIGGER before_insert_employee
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :new.created_at := SYSDATE; -- Automatically set the creation date
END before_insert_employee;
/

-- Error Handling in PL/SQL
-- PL/SQL provides a robust error handling mechanism using the EXCEPTION block. 
-- This allows developers to manage exceptions gracefully and maintain application stability.

BEGIN
    -- Code that may raise an exception
    NULL; -- Placeholder for actual code
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found for the given criteria.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An unexpected error occurred: ' || SQLERRM);
END;