# Advanced PL/SQL Concepts

## Learning Objectives
By the end of this lesson, you will be able to:
- Work with advanced PL/SQL data structures (collections, records, objects)
- Implement dynamic SQL for flexible database programming
- Use bulk operations for high-performance data processing
- Apply advanced cursor techniques and cursor variables
- Implement object-oriented programming concepts in PL/SQL
- Work with external procedures and Java integration

## Prerequisites
- Strong understanding of basic PL/SQL
- Experience with functions, procedures, and packages
- Knowledge of triggers and exception handling
- Familiarity with Oracle database architecture

## 1. Advanced Data Structures

### 1.1 Collections in Detail

#### Associative Arrays (Index-By Tables)
```sql
DECLARE
    -- Associative array with VARCHAR2 index
    TYPE salary_table_t IS TABLE OF NUMBER INDEX BY VARCHAR2(100);
    employee_salaries salary_table_t;
    
    -- Associative array with PLS_INTEGER index
    TYPE name_list_t IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    employee_names name_list_t;
    
    -- Complex associative array
    TYPE emp_record_t IS RECORD (
        name VARCHAR2(100),
        salary NUMBER,
        department VARCHAR2(50)
    );
    TYPE emp_table_t IS TABLE OF emp_record_t INDEX BY VARCHAR2(20);
    employees emp_table_t;
    
    v_index VARCHAR2(100);
BEGIN
    -- Populate associative arrays
    employee_salaries('JOHN_SMITH') := 75000;
    employee_salaries('JANE_DOE') := 85000;
    employee_salaries('BOB_WILSON') := 65000;
    
    employee_names(1) := 'John Smith';
    employee_names(2) := 'Jane Doe';
    employee_names(3) := 'Bob Wilson';
    
    -- Complex record assignment
    employees('EMP001').name := 'John Smith';
    employees('EMP001').salary := 75000;
    employees('EMP001').department := 'IT';
    
    -- Iterate through associative array
    v_index := employee_salaries.FIRST;
    WHILE v_index IS NOT NULL LOOP
        DBMS_OUTPUT.PUT_LINE(v_index || ': $' || employee_salaries(v_index));
        v_index := employee_salaries.NEXT(v_index);
    END LOOP;
    
    -- Check if key exists
    IF employee_salaries.EXISTS('JOHN_SMITH') THEN
        DBMS_OUTPUT.PUT_LINE('John Smith salary: $' || employee_salaries('JOHN_SMITH'));
    END IF;
    
    -- Get collection information
    DBMS_OUTPUT.PUT_LINE('Total employees: ' || employee_salaries.COUNT);
    DBMS_OUTPUT.PUT_LINE('First key: ' || employee_salaries.FIRST);
    DBMS_OUTPUT.PUT_LINE('Last key: ' || employee_salaries.LAST);
END;
```

#### Nested Tables
```sql
DECLARE
    -- Define nested table type
    TYPE number_list_t IS TABLE OF NUMBER;
    number_list number_list_t;
    
    -- Define object type and nested table
    TYPE address_obj_t IS OBJECT (
        street VARCHAR2(100),
        city VARCHAR2(50),
        state VARCHAR2(20),
        zip_code VARCHAR2(10)
    );
    
    TYPE address_list_t IS TABLE OF address_obj_t;
    addresses address_list_t;
    
BEGIN
    -- Initialize nested table
    number_list := number_list_t();
    
    -- Add elements
    number_list.EXTEND(5);
    number_list(1) := 10;
    number_list(2) := 20;
    number_list(3) := 30;
    number_list(4) := 40;
    number_list(5) := 50;
    
    -- Initialize complex nested table
    addresses := address_list_t();
    addresses.EXTEND(2);
    
    addresses(1) := address_obj_t('123 Main St', 'Anytown', 'CA', '12345');
    addresses(2) := address_obj_t('456 Oak Ave', 'Somewhere', 'NY', '67890');
    
    -- Use collection methods
    DBMS_OUTPUT.PUT_LINE('Count: ' || number_list.COUNT);
    DBMS_OUTPUT.PUT_LINE('Limit: ' || NVL(TO_CHAR(number_list.LIMIT), 'UNLIMITED'));
    
    -- Extend and add more elements
    number_list.EXTEND(3);
    number_list(6) := 60;
    number_list(7) := 70;
    number_list(8) := 80;
    
    -- Trim elements
    number_list.TRIM(2); -- Remove last 2 elements
    
    -- Delete specific element
    number_list.DELETE(3); -- Delete 3rd element
    
    -- Iterate through nested table
    FOR i IN 1 .. number_list.COUNT LOOP
        IF number_list.EXISTS(i) THEN
            DBMS_OUTPUT.PUT_LINE('Element ' || i || ': ' || number_list(i));
        END IF;
    END LOOP;
END;
```

#### VARRAYs (Variable Arrays)
```sql
DECLARE
    -- Define VARRAY type
    TYPE skills_array_t IS VARRAY(10) OF VARCHAR2(50);
    employee_skills skills_array_t;
    
    -- Define complex VARRAY
    TYPE project_info_t IS RECORD (
        project_id NUMBER,
        project_name VARCHAR2(100),
        hours_worked NUMBER
    );
    TYPE project_array_t IS VARRAY(5) OF project_info_t;
    employee_projects project_array_t;
    
BEGIN
    -- Initialize VARRAY
    employee_skills := skills_array_t();
    
    -- Add elements to VARRAY
    employee_skills.EXTEND(4);
    employee_skills(1) := 'Java';
    employee_skills(2) := 'Oracle';
    employee_skills(3) := 'Python';
    employee_skills(4) := 'JavaScript';
    
    -- Initialize complex VARRAY
    employee_projects := project_array_t();
    employee_projects.EXTEND(2);
    
    employee_projects(1).project_id := 1001;
    employee_projects(1).project_name := 'Database Migration';
    employee_projects(1).hours_worked := 120;
    
    employee_projects(2).project_id := 1002;
    employee_projects(2).project_name := 'Web Application';
    employee_projects(2).hours_worked := 80;
    
    -- Display VARRAY contents
    FOR i IN 1 .. employee_skills.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Skill ' || i || ': ' || employee_skills(i));
    END LOOP;
    
    -- VARRAY methods
    DBMS_OUTPUT.PUT_LINE('Skills count: ' || employee_skills.COUNT);
    DBMS_OUTPUT.PUT_LINE('Skills limit: ' || employee_skills.LIMIT);
    DBMS_OUTPUT.PUT_LINE('First skill: ' || employee_skills.FIRST);
    DBMS_OUTPUT.PUT_LINE('Last skill: ' || employee_skills.LAST);
END;
```

### 1.2 Advanced Record Types
```sql
DECLARE
    -- Define nested record types
    TYPE address_rec_t IS RECORD (
        street VARCHAR2(100),
        city VARCHAR2(50),
        state VARCHAR2(20),
        zip_code VARCHAR2(10)
    );
    
    TYPE contact_rec_t IS RECORD (
        phone VARCHAR2(20),
        email VARCHAR2(100),
        address address_rec_t
    );
    
    TYPE employee_rec_t IS RECORD (
        employee_id NUMBER,
        name VARCHAR2(100),
        salary NUMBER,
        contact_info contact_rec_t,
        skills skills_array_t,
        hire_date DATE := SYSDATE
    );
    
    -- Declare record variables
    employee_info employee_rec_t;
    employee_backup employee_rec_t;
    
    -- Record based on table structure
    emp_table_rec employees%ROWTYPE;
    
    -- Record based on cursor
    CURSOR emp_cursor IS
        SELECT e.employee_id, e.first_name || ' ' || e.last_name as full_name,
               e.salary, e.hire_date, d.department_name
        FROM employees e JOIN departments d ON e.department_id = d.department_id;
    
    emp_cursor_rec emp_cursor%ROWTYPE;
    
BEGIN
    -- Initialize record
    employee_info.employee_id := 1001;
    employee_info.name := 'John Smith';
    employee_info.salary := 75000;
    
    -- Initialize nested record
    employee_info.contact_info.phone := '555-1234';
    employee_info.contact_info.email := 'john.smith@company.com';
    employee_info.contact_info.address.street := '123 Main St';
    employee_info.contact_info.address.city := 'Anytown';
    employee_info.contact_info.address.state := 'CA';
    employee_info.contact_info.address.zip_code := '12345';
    
    -- Initialize VARRAY within record
    employee_info.skills := skills_array_t('Java', 'Oracle', 'Python');
    
    -- Copy entire record
    employee_backup := employee_info;
    
    -- Use table-based record
    SELECT * INTO emp_table_rec
    FROM employees
    WHERE employee_id = 100;
    
    -- Display record information
    DBMS_OUTPUT.PUT_LINE('Employee: ' || employee_info.name);
    DBMS_OUTPUT.PUT_LINE('Salary: $' || employee_info.salary);
    DBMS_OUTPUT.PUT_LINE('Email: ' || employee_info.contact_info.email);
    DBMS_OUTPUT.PUT_LINE('Address: ' || employee_info.contact_info.address.street);
    
    -- Compare records
    IF employee_info.employee_id = employee_backup.employee_id THEN
        DBMS_OUTPUT.PUT_LINE('Records have same employee ID');
    END IF;
END;
```

## 2. Dynamic SQL

### 2.1 EXECUTE IMMEDIATE
```sql
DECLARE
    v_sql VARCHAR2(4000);
    v_table_name VARCHAR2(30) := 'EMPLOYEES';
    v_column_name VARCHAR2(30) := 'SALARY';
    v_threshold NUMBER := 50000;
    v_count NUMBER;
    v_result VARCHAR2(100);
    
    -- Dynamic cursor
    TYPE ref_cursor_t IS REF CURSOR;
    v_cursor ref_cursor_t;
    
    v_emp_id NUMBER;
    v_emp_name VARCHAR2(100);
    v_emp_salary NUMBER;
    
BEGIN
    -- Simple dynamic SQL
    v_sql := 'SELECT COUNT(*) FROM ' || v_table_name || 
             ' WHERE ' || v_column_name || ' > :threshold';
    
    EXECUTE IMMEDIATE v_sql INTO v_count USING v_threshold;
    DBMS_OUTPUT.PUT_LINE('Employees with salary > ' || v_threshold || ': ' || v_count);
    
    -- Dynamic SQL with multiple parameters
    v_sql := 'SELECT first_name || '' '' || last_name 
              FROM employees 
              WHERE salary BETWEEN :min_sal AND :max_sal 
              AND department_id = :dept_id
              AND ROWNUM = 1';
    
    EXECUTE IMMEDIATE v_sql INTO v_result USING 40000, 80000, 10;
    DBMS_OUTPUT.PUT_LINE('Sample employee: ' || v_result);
    
    -- Dynamic DML
    v_sql := 'UPDATE ' || v_table_name || 
             ' SET last_modified = SYSDATE 
               WHERE employee_id = :emp_id';
    
    EXECUTE IMMEDIATE v_sql USING 100;
    DBMS_OUTPUT.PUT_LINE('Rows updated: ' || SQL%ROWCOUNT);
    
    -- Dynamic DDL
    v_sql := 'CREATE TABLE temp_employee_backup AS 
              SELECT * FROM employees WHERE 1=0';
    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('Backup table created');
    
    -- Dynamic cursor
    v_sql := 'SELECT employee_id, first_name || '' '' || last_name, salary
              FROM employees 
              WHERE department_id = :dept_id
              ORDER BY salary DESC';
    
    OPEN v_cursor FOR v_sql USING 10;
    LOOP
        FETCH v_cursor INTO v_emp_id, v_emp_name, v_emp_salary;
        EXIT WHEN v_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(v_emp_id || ': ' || v_emp_name || 
                           ' - $' || v_emp_salary);
    END LOOP;
    CLOSE v_cursor;
    
    -- Cleanup
    EXECUTE IMMEDIATE 'DROP TABLE temp_employee_backup';
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RAISE;
END;
```

### 2.2 DBMS_SQL Package
```sql
DECLARE
    v_cursor NUMBER;
    v_sql VARCHAR2(4000);
    v_rows_processed NUMBER;
    v_col_count NUMBER;
    v_desc_tab DBMS_SQL.DESC_TAB;
    
    -- Variables for fetching data
    v_emp_id NUMBER;
    v_emp_name VARCHAR2(100);
    v_emp_salary NUMBER;
    
BEGIN
    -- Open cursor
    v_cursor := DBMS_SQL.OPEN_CURSOR;
    
    -- Build dynamic query
    v_sql := 'SELECT employee_id, first_name || '' '' || last_name as name, salary
              FROM employees 
              WHERE department_id = :dept_id
              ORDER BY salary DESC';
    
    -- Parse the statement
    DBMS_SQL.PARSE(v_cursor, v_sql, DBMS_SQL.NATIVE);
    
    -- Bind variables
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':dept_id', 10);
    
    -- Describe columns (optional)
    DBMS_SQL.DESCRIBE_COLUMNS(v_cursor, v_col_count, v_desc_tab);
    
    -- Define columns
    DBMS_SQL.DEFINE_COLUMN(v_cursor, 1, v_emp_id);
    DBMS_SQL.DEFINE_COLUMN(v_cursor, 2, v_emp_name, 100);
    DBMS_SQL.DEFINE_COLUMN(v_cursor, 3, v_emp_salary);
    
    -- Execute the statement
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursor);
    
    -- Fetch and process results
    WHILE DBMS_SQL.FETCH_ROWS(v_cursor) > 0 LOOP
        DBMS_SQL.COLUMN_VALUE(v_cursor, 1, v_emp_id);
        DBMS_SQL.COLUMN_VALUE(v_cursor, 2, v_emp_name);
        DBMS_SQL.COLUMN_VALUE(v_cursor, 3, v_emp_salary);
        
        DBMS_OUTPUT.PUT_LINE(v_emp_id || ': ' || v_emp_name || 
                           ' - $' || v_emp_salary);
    END LOOP;
    
    -- Close cursor
    DBMS_SQL.CLOSE_CURSOR(v_cursor);
    
    -- Example: Dynamic DML with DBMS_SQL
    v_cursor := DBMS_SQL.OPEN_CURSOR;
    
    v_sql := 'UPDATE employees 
              SET salary = salary * :raise_percent
              WHERE department_id = :dept_id
              AND performance_rating >= :min_rating';
    
    DBMS_SQL.PARSE(v_cursor, v_sql, DBMS_SQL.NATIVE);
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':raise_percent', 1.05);
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':dept_id', 10);
    DBMS_SQL.BIND_VARIABLE(v_cursor, ':min_rating', 4);
    
    v_rows_processed := DBMS_SQL.EXECUTE(v_cursor);
    DBMS_OUTPUT.PUT_LINE('Employees updated: ' || v_rows_processed);
    
    DBMS_SQL.CLOSE_CURSOR(v_cursor);
    
EXCEPTION
    WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(v_cursor) THEN
            DBMS_SQL.CLOSE_CURSOR(v_cursor);
        END IF;
        RAISE;
END;
```

## 3. Bulk Operations

### 3.1 BULK COLLECT
```sql
DECLARE
    -- Define collection types
    TYPE emp_id_list_t IS TABLE OF NUMBER;
    TYPE emp_name_list_t IS TABLE OF VARCHAR2(100);
    TYPE emp_salary_list_t IS TABLE OF NUMBER;
    
    -- Declare collections
    l_emp_ids emp_id_list_t;
    l_emp_names emp_name_list_t;
    l_emp_salaries emp_salary_list_t;
    
    -- For record collections
    TYPE emp_rec_t IS RECORD (
        employee_id NUMBER,
        full_name VARCHAR2(100),
        salary NUMBER,
        department_id NUMBER
    );
    TYPE emp_rec_list_t IS TABLE OF emp_rec_t;
    l_employees emp_rec_list_t;
    
    -- Cursor for bulk operations
    CURSOR emp_cursor IS
        SELECT employee_id, first_name || ' ' || last_name, 
               salary, department_id
        FROM employees
        WHERE department_id IN (10, 20, 30);
    
    v_start_time NUMBER;
    v_end_time NUMBER;
    
BEGIN
    v_start_time := DBMS_UTILITY.GET_TIME;
    
    -- Bulk collect into multiple collections
    SELECT employee_id, first_name || ' ' || last_name, salary
    BULK COLLECT INTO l_emp_ids, l_emp_names, l_emp_salaries
    FROM employees
    WHERE department_id = 10;
    
    DBMS_OUTPUT.PUT_LINE('Collected ' || l_emp_ids.COUNT || ' employees');
    
    -- Process collected data
    FOR i IN 1 .. l_emp_ids.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(l_emp_ids(i) || ': ' || l_emp_names(i) || 
                           ' - $' || l_emp_salaries(i));
    END LOOP;
    
    -- Bulk collect with LIMIT (for large datasets)
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor BULK COLLECT INTO l_employees LIMIT 100;
        
        -- Process this batch
        FOR i IN 1 .. l_employees.COUNT LOOP
            -- Process each employee record
            NULL; -- Your processing logic here
        END LOOP;
        
        EXIT WHEN emp_cursor%NOTFOUND;
    END LOOP;
    CLOSE emp_cursor;
    
    -- Bulk collect with cursor FOR loop
    FOR rec IN (
        SELECT employee_id, first_name || ' ' || last_name as name,
               salary, department_id
        FROM employees
        WHERE hire_date >= ADD_MONTHS(SYSDATE, -12)
    ) LOOP
        -- Process recent hires
        DBMS_OUTPUT.PUT_LINE('Recent hire: ' || rec.name);
    END LOOP;
    
    v_end_time := DBMS_UTILITY.GET_TIME;
    DBMS_OUTPUT.PUT_LINE('Execution time: ' || (v_end_time - v_start_time) || ' centiseconds');
END;
```

### 3.2 FORALL Statement
```sql
DECLARE
    TYPE emp_id_list_t IS TABLE OF NUMBER;
    TYPE salary_list_t IS TABLE OF NUMBER;
    TYPE bonus_list_t IS TABLE OF NUMBER;
    
    l_emp_ids emp_id_list_t;
    l_salaries salary_list_t;
    l_bonuses bonus_list_t;
    
    -- For error handling
    bulk_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(bulk_errors, -24381);
    
    v_error_count NUMBER;
    
BEGIN
    -- Collect data for bulk operations
    SELECT employee_id, salary, salary * 0.1
    BULK COLLECT INTO l_emp_ids, l_salaries, l_bonuses
    FROM employees
    WHERE department_id IN (10, 20, 30);
    
    -- FORALL with simple index range
    FORALL i IN 1 .. l_emp_ids.COUNT
        UPDATE employees
        SET bonus = l_bonuses(i),
            last_modified = SYSDATE
        WHERE employee_id = l_emp_ids(i);
    
    DBMS_OUTPUT.PUT_LINE('Updated ' || SQL%ROWCOUNT || ' employees');
    
    -- FORALL with INDICES OF clause (sparse collections)
    -- First, create some gaps in the collection
    l_emp_ids.DELETE(2);
    l_bonuses.DELETE(2);
    
    FORALL i IN INDICES OF l_emp_ids
        UPDATE employees
        SET bonus = l_bonuses(i)
        WHERE employee_id = l_emp_ids(i);
    
    -- FORALL with VALUES OF clause
    DECLARE
        TYPE index_list_t IS TABLE OF PLS_INTEGER;
        l_indices index_list_t := index_list_t(1, 3, 5, 7, 9);
    BEGIN
        FORALL i IN VALUES OF l_indices
            UPDATE employees
            SET bonus = l_bonuses(i)
            WHERE employee_id = l_emp_ids(i);
    END;
    
    -- FORALL with error handling using SAVE EXCEPTIONS
    BEGIN
        FORALL i IN 1 .. l_emp_ids.COUNT SAVE EXCEPTIONS
            INSERT INTO employee_bonus_history (
                employee_id, bonus_amount, bonus_date
            ) VALUES (
                l_emp_ids(i), l_bonuses(i), SYSDATE
            );
    EXCEPTION
        WHEN bulk_errors THEN
            v_error_count := SQL%BULK_EXCEPTIONS.COUNT;
            DBMS_OUTPUT.PUT_LINE('Bulk operation completed with ' || 
                               v_error_count || ' errors');
            
            FOR i IN 1 .. v_error_count LOOP
                DBMS_OUTPUT.PUT_LINE('Error ' || i || ': Index = ' || 
                                   SQL%BULK_EXCEPTIONS(i).ERROR_INDEX ||
                                   ', Code = ' || 
                                   SQL%BULK_EXCEPTIONS(i).ERROR_CODE);
            END LOOP;
    END;
    
    -- Bulk insert example
    DECLARE
        TYPE new_emp_rec_t IS RECORD (
            employee_id NUMBER,
            first_name VARCHAR2(50),
            last_name VARCHAR2(50),
            email VARCHAR2(100),
            salary NUMBER,
            department_id NUMBER
        );
        TYPE new_emp_list_t IS TABLE OF new_emp_rec_t;
        l_new_employees new_emp_list_t;
    BEGIN
        -- Initialize new employee data
        l_new_employees := new_emp_list_t();
        l_new_employees.EXTEND(3);
        
        l_new_employees(1) := new_emp_rec_t(1001, 'John', 'Smith', 
                                          'john.smith@company.com', 75000, 10);
        l_new_employees(2) := new_emp_rec_t(1002, 'Jane', 'Doe', 
                                          'jane.doe@company.com', 80000, 20);
        l_new_employees(3) := new_emp_rec_t(1003, 'Bob', 'Wilson', 
                                          'bob.wilson@company.com', 70000, 30);
        
        -- Bulk insert
        FORALL i IN 1 .. l_new_employees.COUNT
            INSERT INTO employees (
                employee_id, first_name, last_name, email,
                salary, department_id, hire_date
            ) VALUES (
                l_new_employees(i).employee_id,
                l_new_employees(i).first_name,
                l_new_employees(i).last_name,
                l_new_employees(i).email,
                l_new_employees(i).salary,
                l_new_employees(i).department_id,
                SYSDATE
            );
        
        DBMS_OUTPUT.PUT_LINE('Inserted ' || SQL%ROWCOUNT || ' new employees');
    END;
END;
```

## 4. Advanced Cursor Techniques

### 4.1 Cursor Variables (REF CURSOR)
```sql
DECLARE
    -- Define REF CURSOR types
    TYPE emp_cursor_t IS REF CURSOR RETURN employees%ROWTYPE;
    TYPE generic_cursor_t IS REF CURSOR;
    
    -- Declare cursor variables
    v_emp_cursor emp_cursor_t;
    v_generic_cursor generic_cursor_t;
    
    -- Variables for fetching
    v_emp_rec employees%ROWTYPE;
    v_dept_id NUMBER;
    v_min_salary NUMBER;
    
    -- For dynamic cursor
    v_sql VARCHAR2(4000);
    
    -- Function returning REF CURSOR
    FUNCTION get_employees_by_dept(p_dept_id NUMBER) 
    RETURN emp_cursor_t IS
        v_cursor emp_cursor_t;
    BEGIN
        OPEN v_cursor FOR
            SELECT * FROM employees
            WHERE department_id = p_dept_id
            ORDER BY salary DESC;
        RETURN v_cursor;
    END;
    
BEGIN
    -- Static cursor variable
    v_dept_id := 10;
    OPEN v_emp_cursor FOR
        SELECT * FROM employees
        WHERE department_id = v_dept_id;
    
    LOOP
        FETCH v_emp_cursor INTO v_emp_rec;
        EXIT WHEN v_emp_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE(v_emp_rec.first_name || ' ' || 
                           v_emp_rec.last_name || ' - $' || v_emp_rec.salary);
    END LOOP;
    CLOSE v_emp_cursor;
    
    -- Dynamic cursor variable
    v_min_salary := 50000;
    v_sql := 'SELECT * FROM employees WHERE salary >= :min_sal ORDER BY salary';
    
    OPEN v_generic_cursor FOR v_sql USING v_min_salary;
    LOOP
        FETCH v_generic_cursor INTO v_emp_rec;
        EXIT WHEN v_generic_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('High earner: ' || v_emp_rec.first_name || 
                           ' ' || v_emp_rec.last_name);
    END LOOP;
    CLOSE v_generic_cursor;
    
    -- Using function that returns cursor
    v_emp_cursor := get_employees_by_dept(20);
    LOOP
        FETCH v_emp_cursor INTO v_emp_rec;
        EXIT WHEN v_emp_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Dept 20: ' || v_emp_rec.first_name);
    END LOOP;
    CLOSE v_emp_cursor;
    
    -- Cursor variable with different result sets
    FOR choice IN 1..2 LOOP
        IF choice = 1 THEN
            OPEN v_generic_cursor FOR
                SELECT employee_id, first_name, last_name, NULL as department_name
                FROM employees WHERE department_id = 10;
        ELSE
            OPEN v_generic_cursor FOR
                SELECT d.department_id, d.department_name, 
                       d.location, d.manager_id
                FROM departments d;
        END IF;
        
        -- Process the cursor (would need different variables for each type)
        CLOSE v_generic_cursor;
    END LOOP;
END;
```

### 4.2 Cursor Expressions
```sql
DECLARE
    -- Cursor with cursor expression
    CURSOR dept_with_employees IS
        SELECT d.department_id, d.department_name,
               CURSOR(SELECT e.employee_id, e.first_name, e.last_name, e.salary
                      FROM employees e
                      WHERE e.department_id = d.department_id
                      ORDER BY e.salary DESC) as employees
        FROM departments d
        WHERE d.department_id IN (10, 20, 30);
    
    TYPE emp_cursor_t IS REF CURSOR;
    v_emp_cursor emp_cursor_t;
    
    v_emp_id NUMBER;
    v_first_name VARCHAR2(50);
    v_last_name VARCHAR2(50);
    v_salary NUMBER;
    
BEGIN
    FOR dept_rec IN dept_with_employees LOOP
        DBMS_OUTPUT.PUT_LINE('Department: ' || dept_rec.department_name);
        DBMS_OUTPUT.PUT_LINE('Employees:');
        
        v_emp_cursor := dept_rec.employees;
        LOOP
            FETCH v_emp_cursor INTO v_emp_id, v_first_name, v_last_name, v_salary;
            EXIT WHEN v_emp_cursor%NOTFOUND;
            
            DBMS_OUTPUT.PUT_LINE('  ' || v_first_name || ' ' || v_last_name || 
                               ' - $' || v_salary);
        END LOOP;
        CLOSE v_emp_cursor;
        
        DBMS_OUTPUT.PUT_LINE('---');
    END LOOP;
END;
```

## 5. Object-Oriented PL/SQL

### 5.1 Object Types
```sql
-- Create object type
CREATE OR REPLACE TYPE person_obj_t AS OBJECT (
    person_id NUMBER,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    birth_date DATE,
    
    -- Constructor method
    CONSTRUCTOR FUNCTION person_obj_t(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2
    ) RETURN SELF AS RESULT,
    
    -- Member methods
    MEMBER FUNCTION get_full_name RETURN VARCHAR2,
    MEMBER FUNCTION get_age RETURN NUMBER,
    MEMBER PROCEDURE set_name(p_first VARCHAR2, p_last VARCHAR2),
    
    -- Static methods
    STATIC FUNCTION create_person(p_first VARCHAR2, p_last VARCHAR2) 
        RETURN person_obj_t,
    
    -- Comparison methods
    ORDER MEMBER FUNCTION compare_by_age(p_other person_obj_t) RETURN NUMBER
) NOT FINAL;

-- Create object type body
CREATE OR REPLACE TYPE BODY person_obj_t AS
    
    -- Constructor implementation
    CONSTRUCTOR FUNCTION person_obj_t(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2
    ) RETURN SELF AS RESULT IS
    BEGIN
        self.person_id := person_seq.NEXTVAL;
        self.first_name := p_first_name;
        self.last_name := p_last_name;
        self.birth_date := SYSDATE;
        RETURN;
    END;
    
    -- Member method implementations
    MEMBER FUNCTION get_full_name RETURN VARCHAR2 IS
    BEGIN
        RETURN self.first_name || ' ' || self.last_name;
    END;
    
    MEMBER FUNCTION get_age RETURN NUMBER IS
    BEGIN
        RETURN FLOOR(MONTHS_BETWEEN(SYSDATE, self.birth_date) / 12);
    END;
    
    MEMBER PROCEDURE set_name(p_first VARCHAR2, p_last VARCHAR2) IS
    BEGIN
        self.first_name := p_first;
        self.last_name := p_last;
    END;
    
    -- Static method implementation
    STATIC FUNCTION create_person(p_first VARCHAR2, p_last VARCHAR2) 
    RETURN person_obj_t IS
        v_person person_obj_t;
    BEGIN
        v_person := person_obj_t(p_first, p_last);
        RETURN v_person;
    END;
    
    -- Comparison method
    ORDER MEMBER FUNCTION compare_by_age(p_other person_obj_t) RETURN NUMBER IS
    BEGIN
        IF self.get_age() < p_other.get_age() THEN
            RETURN -1;
        ELSIF self.get_age() > p_other.get_age() THEN
            RETURN 1;
        ELSE
            RETURN 0;
        END IF;
    END;
    
END;

-- Create inherited type
CREATE OR REPLACE TYPE employee_obj_t UNDER person_obj_t (
    employee_id NUMBER,
    salary NUMBER,
    department_id NUMBER,
    hire_date DATE,
    
    -- Override constructor
    CONSTRUCTOR FUNCTION employee_obj_t(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_department_id NUMBER
    ) RETURN SELF AS RESULT,
    
    -- Additional methods
    MEMBER FUNCTION get_annual_salary RETURN NUMBER,
    MEMBER PROCEDURE give_raise(p_percentage NUMBER),
    
    -- Override inherited method
    OVERRIDING MEMBER FUNCTION get_full_name RETURN VARCHAR2
);

CREATE OR REPLACE TYPE BODY employee_obj_t AS
    
    CONSTRUCTOR FUNCTION employee_obj_t(
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_department_id NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        -- Call parent constructor
        self.person_obj_t := person_obj_t(p_first_name, p_last_name);
        
        self.employee_id := employee_seq.NEXTVAL;
        self.salary := p_salary;
        self.department_id := p_department_id;
        self.hire_date := SYSDATE;
        
        RETURN;
    END;
    
    MEMBER FUNCTION get_annual_salary RETURN NUMBER IS
    BEGIN
        RETURN self.salary * 12;
    END;
    
    MEMBER PROCEDURE give_raise(p_percentage NUMBER) IS
    BEGIN
        self.salary := self.salary * (1 + p_percentage / 100);
    END;
    
    OVERRIDING MEMBER FUNCTION get_full_name RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Employee: ' || self.first_name || ' ' || self.last_name;
    END;
    
END;
```

### 5.2 Using Object Types
```sql
DECLARE
    -- Declare object variables
    v_person person_obj_t;
    v_employee employee_obj_t;
    v_another_person person_obj_t;
    
    -- Collection of objects
    TYPE person_list_t IS TABLE OF person_obj_t;
    v_people person_list_t;
    
BEGIN
    -- Create objects using constructors
    v_person := person_obj_t('John', 'Smith');
    v_employee := employee_obj_t('Jane', 'Doe', 75000, 10);
    
    -- Call object methods
    DBMS_OUTPUT.PUT_LINE('Person: ' || v_person.get_full_name());
    DBMS_OUTPUT.PUT_LINE('Age: ' || v_person.get_age());
    
    DBMS_OUTPUT.PUT_LINE('Employee: ' || v_employee.get_full_name());
    DBMS_OUTPUT.PUT_LINE('Annual salary: $' || v_employee.get_annual_salary());
    
    -- Modify object
    v_employee.give_raise(10);
    DBMS_OUTPUT.PUT_LINE('New annual salary: $' || v_employee.get_annual_salary());
    
    -- Use static method
    v_another_person := person_obj_t.create_person('Bob', 'Wilson');
    
    -- Work with collections of objects
    v_people := person_list_t();
    v_people.EXTEND(3);
    v_people(1) := v_person;
    v_people(2) := v_employee; -- Employee is a subtype of person
    v_people(3) := v_another_person;
    
    -- Iterate through object collection
    FOR i IN 1 .. v_people.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Person ' || i || ': ' || v_people(i).get_full_name());
    END LOOP;
    
    -- Object comparison
    IF v_person.compare_by_age(v_another_person) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Same age');
    END IF;
END;
```

## 6. External Procedures and Java Integration

### 6.1 External Procedures (C/C++)
```sql
-- First create the external library (OS-dependent)
-- CREATE OR REPLACE LIBRARY my_external_lib AS 
-- '/path/to/my_library.so';  -- Linux/Unix
-- 'C:\path\to\my_library.dll';  -- Windows

-- Create wrapper for external procedure
CREATE OR REPLACE PACKAGE external_utils AS
    
    -- External function to calculate complex math
    FUNCTION complex_calculation(p_input NUMBER) RETURN NUMBER
    AS LANGUAGE C
    LIBRARY my_external_lib
    NAME "complex_calc"
    PARAMETERS (p_input BY VALUE);
    
    -- External procedure for file operations
    PROCEDURE write_to_file(
        p_filename VARCHAR2,
        p_content VARCHAR2,
        p_result OUT NUMBER
    )
    AS LANGUAGE C
    LIBRARY my_external_lib
    NAME "write_file"
    PARAMETERS (
        p_filename STRING,
        p_content STRING,
        p_result BY REFERENCE
    );
    
END external_utils;
```

### 6.2 Java Integration
```sql
-- Create Java source in database
CREATE OR REPLACE AND COMPILE JAVA SOURCE NAMED "MathUtils" AS
public class MathUtils {
    public static double calculateCompoundInterest(
        double principal, 
        double rate, 
        int periods
    ) {
        return principal * Math.pow(1 + rate, periods);
    }
    
    public static String formatCurrency(double amount) {
        return String.format("$%.2f", amount);
    }
    
    public static boolean isValidEmail(String email) {
        return email != null && 
               email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");
    }
}

-- Create PL/SQL wrappers for Java methods
CREATE OR REPLACE PACKAGE java_utils AS
    
    FUNCTION compound_interest(
        p_principal NUMBER,
        p_rate NUMBER,
        p_periods NUMBER
    ) RETURN NUMBER
    AS LANGUAGE JAVA
    NAME 'MathUtils.calculateCompoundInterest(double, double, int) return double';
    
    FUNCTION format_currency(p_amount NUMBER) RETURN VARCHAR2
    AS LANGUAGE JAVA
    NAME 'MathUtils.formatCurrency(double) return java.lang.String';
    
    FUNCTION is_valid_email(p_email VARCHAR2) RETURN NUMBER
    AS LANGUAGE JAVA
    NAME 'MathUtils.isValidEmail(java.lang.String) return boolean';
    
END java_utils;

-- Using Java functions
DECLARE
    v_investment NUMBER := 10000;
    v_rate NUMBER := 0.05;
    v_years NUMBER := 10;
    v_result NUMBER;
    v_formatted VARCHAR2(20);
BEGIN
    v_result := java_utils.compound_interest(v_investment, v_rate, v_years);
    v_formatted := java_utils.format_currency(v_result);
    
    DBMS_OUTPUT.PUT_LINE('Investment result: ' || v_formatted);
    
    IF java_utils.is_valid_email('user@example.com') = 1 THEN
        DBMS_OUTPUT.PUT_LINE('Valid email format');
    END IF;
END;
```

## 7. Performance Optimization Techniques

### 7.1 PL/SQL Optimization
```sql
-- Efficient cursor processing
DECLARE
    -- Use BULK COLLECT with LIMIT for large datasets
    CURSOR large_dataset_cursor IS
        SELECT employee_id, salary FROM employees;
    
    TYPE emp_data_t IS RECORD (
        employee_id NUMBER,
        salary NUMBER
    );
    TYPE emp_list_t IS TABLE OF emp_data_t;
    
    l_employees emp_list_t;
    l_batch_size CONSTANT PLS_INTEGER := 1000;
    
BEGIN
    OPEN large_dataset_cursor;
    LOOP
        FETCH large_dataset_cursor 
        BULK COLLECT INTO l_employees 
        LIMIT l_batch_size;
        
        -- Process batch
        FOR i IN 1 .. l_employees.COUNT LOOP
            -- Your processing logic here
            NULL;
        END LOOP;
        
        EXIT WHEN large_dataset_cursor%NOTFOUND;
    END LOOP;
    CLOSE large_dataset_cursor;
END;

-- Cache frequently used data
CREATE OR REPLACE PACKAGE performance_cache AS
    
    -- Package-level variables for caching
    TYPE lookup_cache_t IS TABLE OF VARCHAR2(100) INDEX BY PLS_INTEGER;
    g_dept_cache lookup_cache_t;
    g_cache_loaded BOOLEAN := FALSE;
    
    FUNCTION get_department_name(p_dept_id NUMBER) RETURN VARCHAR2;
    PROCEDURE refresh_cache;
    
END performance_cache;

CREATE OR REPLACE PACKAGE BODY performance_cache AS
    
    PROCEDURE refresh_cache IS
    BEGIN
        g_dept_cache.DELETE;
        
        FOR rec IN (SELECT department_id, department_name FROM departments) LOOP
            g_dept_cache(rec.department_id) := rec.department_name;
        END LOOP;
        
        g_cache_loaded := TRUE;
    END refresh_cache;
    
    FUNCTION get_department_name(p_dept_id NUMBER) RETURN VARCHAR2 IS
    BEGIN
        IF NOT g_cache_loaded THEN
            refresh_cache;
        END IF;
        
        IF g_dept_cache.EXISTS(p_dept_id) THEN
            RETURN g_dept_cache(p_dept_id);
        ELSE
            RETURN 'Unknown';
        END IF;
    END get_department_name;
    
END performance_cache;
```

## Summary

Advanced PL/SQL provides powerful features for:

1. **Complex Data Structures**: Collections, records, and objects
2. **Dynamic Programming**: Runtime SQL generation and execution
3. **High Performance**: Bulk operations and optimized processing
4. **Flexibility**: Cursor variables and dynamic cursors
5. **Object-Oriented Design**: Inheritance and encapsulation
6. **External Integration**: C/C++ and Java connectivity

Key principles:
- Use appropriate data structures for your needs
- Leverage bulk operations for performance
- Implement proper error handling
- Cache frequently accessed data
- Use dynamic SQL judiciously
- Follow object-oriented design principles

## Next Steps
- Practice with complex data structures
- Implement dynamic SQL solutions
- Optimize existing PL/SQL code using bulk operations
- Explore object-oriented design patterns
- Learn about PL/SQL profiling and debugging tools
