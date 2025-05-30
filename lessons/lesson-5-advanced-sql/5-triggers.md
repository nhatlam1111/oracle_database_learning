# Triggers in Oracle Database

## Learning Objectives
By the end of this lesson, you will be able to:
- Understand what database triggers are and when to use them
- Create different types of triggers (DML, DDL, System)
- Implement business logic using triggers
- Handle trigger timing and events effectively
- Apply best practices for trigger development
- Debug and troubleshoot trigger issues

## Prerequisites
- Understanding of PL/SQL basics
- Knowledge of DML operations (INSERT, UPDATE, DELETE)
- Familiarity with database tables and constraints
- Completion of stored procedures and functions lessons

## 1. Introduction to Triggers

### What are Triggers?
Triggers are special PL/SQL programs that execute automatically in response to specific database events. They cannot be explicitly called - they "fire" automatically when their triggering event occurs.

### Key Characteristics:
- **Automatic Execution**: Fire automatically on events
- **Event-Driven**: Respond to specific database operations
- **Transparent**: Users are unaware of their execution
- **Powerful**: Can enforce complex business rules
- **Dangerous**: Can impact performance if poorly designed

### Common Use Cases:
- **Auditing**: Track data changes
- **Security**: Enforce access controls
- **Business Rules**: Implement complex constraints
- **Data Validation**: Ensure data integrity
- **Automatic Calculations**: Update derived data
- **Logging**: Track system events

## 2. Types of Triggers

### 2.1 DML Triggers (Data Manipulation Language)
Fire in response to INSERT, UPDATE, or DELETE operations.

#### Timing Options:
- **BEFORE**: Execute before the triggering event
- **AFTER**: Execute after the triggering event
- **INSTEAD OF**: Replace the triggering event (views only)

#### Event Options:
- **INSERT**: New rows added
- **UPDATE**: Existing rows modified
- **DELETE**: Rows removed

### 2.2 DDL Triggers (Data Definition Language)
Fire in response to CREATE, ALTER, DROP operations.

### 2.3 System Triggers
Fire in response to database system events like logon, logoff, startup, shutdown.

## 3. DML Triggers in Detail

### 3.1 Basic Trigger Syntax:
```sql
CREATE [OR REPLACE] TRIGGER trigger_name
{BEFORE | AFTER | INSTEAD OF}
{INSERT | UPDATE | DELETE} [OR INSERT | UPDATE | DELETE...]
ON table_name
[FOR EACH ROW]
[WHEN (condition)]
DECLARE
    -- Variable declarations
BEGIN
    -- Trigger logic
EXCEPTION
    -- Error handling
END;
```

### 3.2 Row-Level vs Statement-Level Triggers

#### Row-Level Trigger (FOR EACH ROW):
```sql
-- Fires once for each affected row
CREATE OR REPLACE TRIGGER trg_employee_audit_row
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    -- This fires for each row being updated
    INSERT INTO employee_audit (
        employee_id, old_salary, new_salary, 
        change_date, changed_by
    ) VALUES (
        :NEW.employee_id, :OLD.salary, :NEW.salary,
        SYSDATE, USER
    );
END;
```

#### Statement-Level Trigger:
```sql
-- Fires once for the entire statement
CREATE OR REPLACE TRIGGER trg_employee_audit_stmt
AFTER UPDATE ON employees
BEGIN
    -- This fires once regardless of rows affected
    INSERT INTO audit_summary (
        table_name, operation, rows_affected, 
        operation_date, user_name
    ) VALUES (
        'EMPLOYEES', 'UPDATE', SQL%ROWCOUNT,
        SYSDATE, USER
    );
END;
```

### 3.3 Using :OLD and :NEW Pseudo-Records

These special records provide access to column values:

```sql
CREATE OR REPLACE TRIGGER trg_salary_change_validation
BEFORE UPDATE OF salary ON employees
FOR EACH ROW
WHEN (NEW.salary != OLD.salary)
DECLARE
    v_max_increase NUMBER := 0.50; -- 50% max increase
BEGIN
    -- Validate salary increase
    IF :NEW.salary > :OLD.salary * (1 + v_max_increase) THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'Salary increase cannot exceed ' || (v_max_increase * 100) || '%');
    END IF;
    
    -- Validate minimum salary
    IF :NEW.salary < 30000 THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'Salary cannot be less than $30,000');
    END IF;
    
    -- Automatically update last_modified
    :NEW.last_modified := SYSDATE;
    :NEW.modified_by := USER;
    
    -- Log the change
    INSERT INTO salary_changes (
        employee_id, old_salary, new_salary, 
        change_date, changed_by, reason
    ) VALUES (
        :NEW.employee_id, :OLD.salary, :NEW.salary,
        SYSDATE, USER, 'Salary Update'
    );
END;
```

## 4. Comprehensive Trigger Examples

### 4.1 Audit Trail Trigger
```sql
-- Create audit table first
CREATE TABLE employee_audit_trail (
    audit_id NUMBER GENERATED ALWAYS AS IDENTITY,
    employee_id NUMBER,
    operation VARCHAR2(10),
    old_values CLOB,
    new_values CLOB,
    change_date DATE DEFAULT SYSDATE,
    changed_by VARCHAR2(100) DEFAULT USER,
    session_id NUMBER,
    ip_address VARCHAR2(50)
);

-- Comprehensive audit trigger
CREATE OR REPLACE TRIGGER trg_employee_comprehensive_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_session_id NUMBER;
    v_ip_address VARCHAR2(50);
BEGIN
    -- Determine operation type
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_old_values := NULL;
        v_new_values := 'ID:' || :NEW.employee_id || 
                       '|NAME:' || :NEW.first_name || ' ' || :NEW.last_name ||
                       '|EMAIL:' || :NEW.email || 
                       '|SALARY:' || :NEW.salary ||
                       '|DEPT:' || :NEW.department_id;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := 'ID:' || :OLD.employee_id || 
                       '|NAME:' || :OLD.first_name || ' ' || :OLD.last_name ||
                       '|EMAIL:' || :OLD.email || 
                       '|SALARY:' || :OLD.salary ||
                       '|DEPT:' || :OLD.department_id;
        v_new_values := 'ID:' || :NEW.employee_id || 
                       '|NAME:' || :NEW.first_name || ' ' || :NEW.last_name ||
                       '|EMAIL:' || :NEW.email || 
                       '|SALARY:' || :NEW.salary ||
                       '|DEPT:' || :NEW.department_id;
    ELSIF DELETING THEN
        v_operation := 'DELETE';
        v_old_values := 'ID:' || :OLD.employee_id || 
                       '|NAME:' || :OLD.first_name || ' ' || :OLD.last_name ||
                       '|EMAIL:' || :OLD.email || 
                       '|SALARY:' || :OLD.salary ||
                       '|DEPT:' || :OLD.department_id;
        v_new_values := NULL;
    END IF;
    
    -- Get session information
    SELECT SYS_CONTEXT('USERENV', 'SESSIONID'),
           SYS_CONTEXT('USERENV', 'IP_ADDRESS')
    INTO v_session_id, v_ip_address
    FROM dual;
    
    -- Insert audit record
    INSERT INTO employee_audit_trail (
        employee_id, operation, old_values, new_values,
        session_id, ip_address
    ) VALUES (
        COALESCE(:NEW.employee_id, :OLD.employee_id),
        v_operation, v_old_values, v_new_values,
        v_session_id, v_ip_address
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Log error but don't fail the main operation
        INSERT INTO trigger_error_log (
            trigger_name, error_date, error_message
        ) VALUES (
            'trg_employee_comprehensive_audit', 
            SYSDATE, 
            SQLERRM
        );
END;
```

### 4.2 Business Logic Enforcement Trigger
```sql
CREATE OR REPLACE TRIGGER trg_employee_business_rules
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
    v_dept_count NUMBER;
    v_max_salary NUMBER;
    v_manager_count NUMBER;
BEGIN
    -- Ensure email is lowercase
    :NEW.email := LOWER(:NEW.email);
    
    -- Validate email format
    IF NOT REGEXP_LIKE(:NEW.email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid email format');
    END IF;
    
    -- Check department exists and get max salary
    SELECT COUNT(*), NVL(MAX(max_salary), 999999)
    INTO v_dept_count, v_max_salary
    FROM departments 
    WHERE department_id = :NEW.department_id;
    
    IF v_dept_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid department ID');
    END IF;
    
    -- Validate salary against department maximum
    IF :NEW.salary > v_max_salary THEN
        RAISE_APPLICATION_ERROR(-20005, 
            'Salary exceeds department maximum of ' || v_max_salary);
    END IF;
    
    -- Limit managers per department
    IF :NEW.job_title LIKE '%Manager%' OR :NEW.job_title LIKE '%Director%' THEN
        SELECT COUNT(*)
        INTO v_manager_count
        FROM employees
        WHERE department_id = :NEW.department_id
        AND (job_title LIKE '%Manager%' OR job_title LIKE '%Director%')
        AND employee_id != NVL(:NEW.employee_id, 0);
        
        IF v_manager_count >= 3 THEN
            RAISE_APPLICATION_ERROR(-20006, 
                'Department cannot have more than 3 managers/directors');
        END IF;
    END IF;
    
    -- Auto-generate employee number if not provided
    IF :NEW.employee_number IS NULL THEN
        :NEW.employee_number := 'EMP' || LPAD(:NEW.employee_id, 6, '0');
    END IF;
    
    -- Set default values
    IF INSERTING THEN
        :NEW.hire_date := NVL(:NEW.hire_date, SYSDATE);
        :NEW.status := NVL(:NEW.status, 'ACTIVE');
        :NEW.created_date := SYSDATE;
        :NEW.created_by := USER;
    END IF;
    
    :NEW.last_modified := SYSDATE;
    :NEW.modified_by := USER;
END;
```

### 4.3 Automatic Calculation Trigger
```sql
-- Create tables for this example
CREATE TABLE orders (
    order_id NUMBER PRIMARY KEY,
    customer_id NUMBER,
    order_date DATE,
    subtotal NUMBER(10,2),
    tax_amount NUMBER(10,2),
    shipping_cost NUMBER(10,2),
    total_amount NUMBER(10,2),
    last_modified DATE
);

CREATE TABLE order_items (
    item_id NUMBER PRIMARY KEY,
    order_id NUMBER REFERENCES orders(order_id),
    product_id NUMBER,
    quantity NUMBER,
    unit_price NUMBER(10,2),
    line_total NUMBER(10,2)
);

-- Trigger to calculate line totals
CREATE OR REPLACE TRIGGER trg_order_item_calculations
BEFORE INSERT OR UPDATE ON order_items
FOR EACH ROW
BEGIN
    -- Calculate line total
    :NEW.line_total := :NEW.quantity * :NEW.unit_price;
END;

-- Trigger to update order totals
CREATE OR REPLACE TRIGGER trg_order_total_calculations
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW
DECLARE
    v_order_id NUMBER;
    v_subtotal NUMBER;
    v_tax_rate NUMBER := 0.08; -- 8% tax rate
    v_shipping_cost NUMBER;
BEGIN
    -- Get the order ID
    v_order_id := COALESCE(:NEW.order_id, :OLD.order_id);
    
    -- Calculate subtotal
    SELECT NVL(SUM(line_total), 0)
    INTO v_subtotal
    FROM order_items
    WHERE order_id = v_order_id;
    
    -- Calculate shipping cost (free shipping over $100)
    v_shipping_cost := CASE 
        WHEN v_subtotal >= 100 THEN 0
        ELSE 15.00
    END;
    
    -- Update order totals
    UPDATE orders
    SET subtotal = v_subtotal,
        tax_amount = v_subtotal * v_tax_rate,
        shipping_cost = v_shipping_cost,
        total_amount = v_subtotal + (v_subtotal * v_tax_rate) + v_shipping_cost,
        last_modified = SYSDATE
    WHERE order_id = v_order_id;
END;
```

## 5. INSTEAD OF Triggers (Views)

INSTEAD OF triggers are used with views to make them updatable:

```sql
-- Create a complex view
CREATE VIEW employee_department_view AS
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.email,
    e.salary,
    d.department_id,
    d.department_name,
    d.location
FROM employees e
JOIN departments d ON e.department_id = d.department_id;

-- Make the view updatable with INSTEAD OF trigger
CREATE OR REPLACE TRIGGER trg_employee_dept_view_update
INSTEAD OF UPDATE ON employee_department_view
FOR EACH ROW
BEGIN
    -- Update employee table
    UPDATE employees
    SET first_name = :NEW.first_name,
        last_name = :NEW.last_name,
        email = :NEW.email,
        salary = :NEW.salary,
        department_id = :NEW.department_id,
        last_modified = SYSDATE
    WHERE employee_id = :OLD.employee_id;
    
    -- Update department table if department info changed
    IF :NEW.department_name != :OLD.department_name OR 
       :NEW.location != :OLD.location THEN
        UPDATE departments
        SET department_name = :NEW.department_name,
            location = :NEW.location,
            last_modified = SYSDATE
        WHERE department_id = :NEW.department_id;
    END IF;
END;

-- INSTEAD OF INSERT trigger
CREATE OR REPLACE TRIGGER trg_employee_dept_view_insert
INSTEAD OF INSERT ON employee_department_view
FOR EACH ROW
DECLARE
    v_emp_id NUMBER;
    v_dept_id NUMBER;
BEGIN
    -- Check if department exists
    SELECT department_id INTO v_dept_id
    FROM departments
    WHERE department_name = :NEW.department_name;
    
    -- Generate new employee ID
    SELECT employee_seq.NEXTVAL INTO v_emp_id FROM dual;
    
    -- Insert employee
    INSERT INTO employees (
        employee_id, first_name, last_name, email,
        salary, department_id, hire_date
    ) VALUES (
        v_emp_id, :NEW.first_name, :NEW.last_name, :NEW.email,
        :NEW.salary, v_dept_id, SYSDATE
    );
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20007, 
            'Department "' || :NEW.department_name || '" does not exist');
END;
```

## 6. DDL Triggers

DDL triggers fire in response to Data Definition Language events:

```sql
-- Create table to log DDL operations
CREATE TABLE ddl_audit_log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY,
    username VARCHAR2(100),
    operation VARCHAR2(100),
    object_type VARCHAR2(100),
    object_name VARCHAR2(128),
    sql_text CLOB,
    event_date DATE DEFAULT SYSDATE,
    client_info VARCHAR2(4000)
);

-- DDL trigger to audit schema changes
CREATE OR REPLACE TRIGGER trg_ddl_audit
AFTER CREATE OR ALTER OR DROP ON SCHEMA
DECLARE
    v_sql_text CLOB;
BEGIN
    -- Get the SQL statement (first 4000 characters)
    SELECT SUBSTR(sql_text, 1, 4000) INTO v_sql_text
    FROM (
        SELECT sql_text
        FROM v$sql
        WHERE sql_id = SYS_CONTEXT('USERENV', 'CURRENT_SQL_ID')
        ORDER BY last_active_time DESC
    )
    WHERE ROWNUM = 1;
    
    -- Log the DDL operation
    INSERT INTO ddl_audit_log (
        username, operation, object_type, object_name,
        sql_text, client_info
    ) VALUES (
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYS.DICTIONARY_OBJ_TYPE,
        SYS.DICTIONARY_OBJ_TYPE,
        SYS.DICTIONARY_OBJ_NAME,
        v_sql_text,
        SYS_CONTEXT('USERENV', 'CLIENT_INFO')
    );
    
EXCEPTION
    WHEN OTHERS THEN
        -- Don't fail DDL operations due to audit issues
        NULL;
END;
```

## 7. System Triggers

System triggers respond to database events:

```sql
-- Create table for logon/logoff tracking
CREATE TABLE user_sessions (
    session_id NUMBER,
    username VARCHAR2(100),
    logon_time DATE,
    logoff_time DATE,
    client_program VARCHAR2(100),
    client_machine VARCHAR2(100),
    client_ip VARCHAR2(50)
);

-- Logon trigger
CREATE OR REPLACE TRIGGER trg_user_logon
AFTER LOGON ON DATABASE
BEGIN
    INSERT INTO user_sessions (
        session_id, username, logon_time,
        client_program, client_machine, client_ip
    ) VALUES (
        SYS_CONTEXT('USERENV', 'SESSIONID'),
        SYS_CONTEXT('USERENV', 'SESSION_USER'),
        SYSDATE,
        SYS_CONTEXT('USERENV', 'MODULE'),
        SYS_CONTEXT('USERENV', 'HOST'),
        SYS_CONTEXT('USERENV', 'IP_ADDRESS')
    );
    
    -- Set session parameters
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMAT = ''YYYY-MM-DD HH24:MI:SS''';
    
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Don't prevent login due to audit issues
END;

-- Logoff trigger
CREATE OR REPLACE TRIGGER trg_user_logoff
BEFORE LOGOFF ON DATABASE
BEGIN
    UPDATE user_sessions
    SET logoff_time = SYSDATE
    WHERE session_id = SYS_CONTEXT('USERENV', 'SESSIONID')
    AND logoff_time IS NULL;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        NULL; -- Don't prevent logoff
END;
```

## 8. Compound Triggers

Compound triggers allow multiple timing points in a single trigger:

```sql
CREATE OR REPLACE TRIGGER trg_employee_compound
FOR INSERT OR UPDATE OR DELETE ON employees
COMPOUND TRIGGER
    
    -- Declare variables that persist across timing points
    TYPE emp_id_list_t IS TABLE OF NUMBER;
    g_inserted_ids emp_id_list_t := emp_id_list_t();
    g_updated_ids emp_id_list_t := emp_id_list_t();
    g_deleted_ids emp_id_list_t := emp_id_list_t();
    
    -- BEFORE STATEMENT
    BEFORE STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Starting DML operation on employees table');
        -- Initialize collections
        g_inserted_ids.DELETE;
        g_updated_ids.DELETE;
        g_deleted_ids.DELETE;
    END BEFORE STATEMENT;
    
    -- BEFORE EACH ROW
    BEFORE EACH ROW IS
    BEGIN
        IF INSERTING THEN
            :NEW.created_date := SYSDATE;
            :NEW.created_by := USER;
        END IF;
        
        :NEW.last_modified := SYSDATE;
        :NEW.modified_by := USER;
    END BEFORE EACH ROW;
    
    -- AFTER EACH ROW
    AFTER EACH ROW IS
    BEGIN
        IF INSERTING THEN
            g_inserted_ids.EXTEND;
            g_inserted_ids(g_inserted_ids.COUNT) := :NEW.employee_id;
        ELSIF UPDATING THEN
            g_updated_ids.EXTEND;
            g_updated_ids(g_updated_ids.COUNT) := :NEW.employee_id;
        ELSIF DELETING THEN
            g_deleted_ids.EXTEND;
            g_deleted_ids(g_deleted_ids.COUNT) := :OLD.employee_id;
        END IF;
    END AFTER EACH ROW;
    
    -- AFTER STATEMENT
    AFTER STATEMENT IS
    BEGIN
        -- Process all collected IDs
        FOR i IN 1 .. g_inserted_ids.COUNT LOOP
            -- Send welcome email or perform other bulk operations
            DBMS_OUTPUT.PUT_LINE('New employee ID: ' || g_inserted_ids(i));
        END LOOP;
        
        FOR i IN 1 .. g_updated_ids.COUNT LOOP
            -- Update related systems
            DBMS_OUTPUT.PUT_LINE('Updated employee ID: ' || g_updated_ids(i));
        END LOOP;
        
        FOR i IN 1 .. g_deleted_ids.COUNT LOOP
            -- Archive or cleanup related data
            DBMS_OUTPUT.PUT_LINE('Deleted employee ID: ' || g_deleted_ids(i));
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('DML operation completed');
    END AFTER STATEMENT;
    
END trg_employee_compound;
```

## 9. Trigger Best Practices

### 9.1 Performance Considerations:
```sql
-- Good: Efficient trigger with minimal logic
CREATE OR REPLACE TRIGGER trg_employee_efficient
BEFORE UPDATE ON employees
FOR EACH ROW
WHEN (NEW.salary != OLD.salary) -- Use WHEN clause to filter
BEGIN
    -- Simple, fast operations only
    :NEW.last_modified := SYSDATE;
    
    -- Avoid complex queries in triggers
    -- Use autonomous transactions sparingly
END;

-- Avoid: Heavy processing in triggers
CREATE OR REPLACE TRIGGER trg_employee_inefficient
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- DON'T DO THIS: Complex calculations
    FOR rec IN (SELECT * FROM complex_view WHERE dept_id = :NEW.department_id) LOOP
        -- Heavy processing for each row
        UPDATE other_table SET value = complex_function(rec.data);
    END LOOP;
    
    -- DON'T DO THIS: External calls
    send_email(:NEW.email, 'Salary Updated');
END;
```

### 9.2 Error Handling:
```sql
CREATE OR REPLACE TRIGGER trg_employee_safe
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
    v_error_msg VARCHAR2(4000);
BEGIN
    -- Validate data
    IF :NEW.salary <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Salary must be positive');
    END IF;
    
    -- Safe operations with error handling
    BEGIN
        -- Log to audit table
        INSERT INTO employee_changes (
            employee_id, change_type, change_date
        ) VALUES (
            :NEW.employee_id, 'MODIFY', SYSDATE
        );
    EXCEPTION
        WHEN OTHERS THEN
            -- Log error but don't fail main operation
            v_error_msg := 'Audit logging failed: ' || SQLERRM;
            INSERT INTO trigger_errors (
                trigger_name, error_message, error_date
            ) VALUES (
                'trg_employee_safe', v_error_msg, SYSDATE
            );
    END;
    
EXCEPTION
    WHEN OTHERS THEN
        -- Handle unexpected errors
        RAISE_APPLICATION_ERROR(-20999, 
            'Employee trigger error: ' || SQLERRM);
END;
```

### 9.3 Avoiding Mutating Table Errors:
```sql
-- Problem: Mutating table error
CREATE OR REPLACE TRIGGER trg_mutating_problem
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    -- This will cause ORA-04091: table EMPLOYEES is mutating
    UPDATE employees 
    SET department_count = (
        SELECT COUNT(*) FROM employees WHERE department_id = :NEW.department_id
    )
    WHERE department_id = :NEW.department_id;
END;

-- Solution 1: Use statement-level trigger
CREATE OR REPLACE TRIGGER trg_mutating_solution1
AFTER INSERT ON employees
DECLARE
    CURSOR dept_cursor IS
        SELECT DISTINCT department_id
        FROM employees;
BEGIN
    FOR dept_rec IN dept_cursor LOOP
        UPDATE departments
        SET employee_count = (
            SELECT COUNT(*) 
            FROM employees 
            WHERE department_id = dept_rec.department_id
        )
        WHERE department_id = dept_rec.department_id;
    END LOOP;
END;

-- Solution 2: Use compound trigger
CREATE OR REPLACE TRIGGER trg_mutating_solution2
FOR INSERT ON employees
COMPOUND TRIGGER
    
    TYPE dept_list_t IS TABLE OF NUMBER;
    g_affected_depts dept_list_t := dept_list_t();
    
    AFTER EACH ROW IS
    BEGIN
        g_affected_depts.EXTEND;
        g_affected_depts(g_affected_depts.COUNT) := :NEW.department_id;
    END AFTER EACH ROW;
    
    AFTER STATEMENT IS
    BEGIN
        FOR i IN 1 .. g_affected_depts.COUNT LOOP
            UPDATE departments
            SET employee_count = (
                SELECT COUNT(*) 
                FROM employees 
                WHERE department_id = g_affected_depts(i)
            )
            WHERE department_id = g_affected_depts(i);
        END LOOP;
    END AFTER STATEMENT;
    
END trg_mutating_solution2;
```

## 10. Debugging and Troubleshooting Triggers

### 10.1 Debugging Techniques:
```sql
-- Create debug table
CREATE TABLE trigger_debug_log (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY,
    trigger_name VARCHAR2(100),
    debug_message VARCHAR2(4000),
    debug_date DATE DEFAULT SYSDATE
);

-- Debug trigger
CREATE OR REPLACE TRIGGER trg_employee_debug
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
    PROCEDURE debug_log(p_message VARCHAR2) IS
        PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN
        INSERT INTO trigger_debug_log (trigger_name, debug_message)
        VALUES ('trg_employee_debug', p_message);
        COMMIT;
    END;
BEGIN
    debug_log('Trigger fired for employee: ' || :NEW.employee_id);
    
    IF INSERTING THEN
        debug_log('INSERT operation detected');
    ELSIF UPDATING THEN
        debug_log('UPDATE operation detected');
    END IF;
    
    -- Your trigger logic here
    :NEW.last_modified := SYSDATE;
    
    debug_log('Trigger completed successfully');
    
EXCEPTION
    WHEN OTHERS THEN
        debug_log('Error in trigger: ' || SQLERRM);
        RAISE;
END;
```

### 10.2 Trigger Management:
```sql
-- View trigger information
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers
WHERE table_name = 'EMPLOYEES';

-- Enable/disable triggers
ALTER TRIGGER trg_employee_audit DISABLE;
ALTER TRIGGER trg_employee_audit ENABLE;

-- Drop trigger
DROP TRIGGER trg_employee_audit;

-- View trigger dependencies
SELECT name, type, referenced_name, referenced_type
FROM user_dependencies
WHERE name = 'TRG_EMPLOYEE_AUDIT';
```

## 11. Common Trigger Patterns

### 11.1 Audit Trail Pattern:
```sql
-- Generic audit trigger generator
CREATE OR REPLACE PROCEDURE create_audit_trigger(
    p_table_name VARCHAR2,
    p_audit_table_name VARCHAR2 DEFAULT NULL
) IS
    v_audit_table VARCHAR2(128);
    v_trigger_name VARCHAR2(128);
    v_sql CLOB;
BEGIN
    v_audit_table := NVL(p_audit_table_name, p_table_name || '_AUDIT');
    v_trigger_name := 'TRG_' || p_table_name || '_AUDIT';
    
    v_sql := 'CREATE OR REPLACE TRIGGER ' || v_trigger_name || '
        AFTER INSERT OR UPDATE OR DELETE ON ' || p_table_name || '
        FOR EACH ROW
        BEGIN
            INSERT INTO ' || v_audit_table || ' (
                operation, operation_date, operation_user,
                old_values, new_values
            ) VALUES (
                CASE 
                    WHEN INSERTING THEN ''INSERT''
                    WHEN UPDATING THEN ''UPDATE''
                    WHEN DELETING THEN ''DELETE''
                END,
                SYSDATE,
                USER,
                CASE WHEN DELETING THEN ''OLD_DATA'' END,
                CASE WHEN NOT DELETING THEN ''NEW_DATA'' END
            );
        END;';
    
    EXECUTE IMMEDIATE v_sql;
END;
```

## Summary

Triggers are powerful database objects that provide:

1. **Automatic Execution**: Business logic that runs automatically
2. **Data Integrity**: Enforce complex business rules
3. **Auditing**: Track all data changes
4. **Security**: Implement access controls
5. **Integration**: Coordinate related data updates

Key best practices:
- Keep triggers simple and fast
- Use appropriate timing (BEFORE vs AFTER)
- Handle errors gracefully
- Avoid mutating table errors
- Document trigger behavior
- Test thoroughly

Remember: Triggers are powerful but can impact performance. Use them judiciously and always consider alternatives like check constraints, foreign keys, or application logic.

## Next Steps
- Practice creating different types of triggers
- Implement audit trails for critical tables
- Learn about trigger alternatives and when to use them
- Study Oracle's built-in triggers and their purposes
- Explore advanced trigger features like cross-edition triggers
