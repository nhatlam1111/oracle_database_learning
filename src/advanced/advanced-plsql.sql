/*
================================================================================
ORACLE DATABASE LEARNING PROJECT
Lesson 5: Advanced SQL Techniques
File: advanced-plsql.sql
Topic: Advanced PL/SQL Features Practice Exercises

Description: Comprehensive practice file covering advanced PL/SQL concepts including
             collections, cursors, dynamic SQL, bulk operations, object-oriented
             programming, and external procedures.

Author: Oracle Learning Project
Date: May 2025
================================================================================
*/

-- ============================================================================
-- SECTION 1: COLLECTIONS AND ASSOCIATIVE ARRAYS
-- Advanced data structures for complex processing
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 1: COLLECTIONS AND ASSOCIATIVE ARRAYS
PROMPT ========================================

-- Example 1: Associative Arrays (INDEX BY tables)
-- Business scenario: Sales territory performance analysis
DECLARE
    -- Define associative array types
    TYPE t_territory_sales IS TABLE OF NUMBER INDEX BY VARCHAR2(50);
    TYPE t_territory_reps IS TABLE OF VARCHAR2(100) INDEX BY VARCHAR2(50);
    
    v_sales t_territory_sales;
    v_reps t_territory_reps;
    v_territory VARCHAR2(50);
    v_total_sales NUMBER := 0;
    v_avg_sales NUMBER;
    v_top_territory VARCHAR2(50);
    v_top_sales NUMBER := 0;
BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE('=== TERRITORY SALES ANALYSIS ===');
    
    -- Populate sales data
    v_sales('North America') := 2500000;
    v_sales('Europe') := 1800000;
    v_sales('Asia Pacific') := 2200000;
    v_sales('Latin America') := 950000;
    v_sales('Middle East') := 750000;
    
    -- Populate representative data
    v_reps('North America') := 'John Smith, Jane Doe';
    v_reps('Europe') := 'Pierre Dubois, Anna Mueller';
    v_reps('Asia Pacific') := 'Hiroshi Tanaka, Li Wei';
    v_reps('Latin America') := 'Carlos Rivera';
    v_reps('Middle East') := 'Ahmed Hassan';
    
    -- Analyze data
    v_territory := v_sales.FIRST;
    WHILE v_territory IS NOT NULL LOOP
        v_total_sales := v_total_sales + v_sales(v_territory);
        
        -- Find top performing territory
        IF v_sales(v_territory) > v_top_sales THEN
            v_top_sales := v_sales(v_territory);
            v_top_territory := v_territory;
        END IF;
        
        -- Display territory information
        DBMS_OUTPUT.PUT_LINE('Territory: ' || v_territory);
        DBMS_OUTPUT.PUT_LINE('  Sales: $' || TO_CHAR(v_sales(v_territory), '9,999,999'));
        DBMS_OUTPUT.PUT_LINE('  Representatives: ' || v_reps(v_territory));
        DBMS_OUTPUT.PUT_LINE('');
        
        v_territory := v_sales.NEXT(v_territory);
    END LOOP;
    
    v_avg_sales := v_total_sales / v_sales.COUNT;
    
    DBMS_OUTPUT.PUT_LINE('=== SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('Total Territories: ' || v_sales.COUNT);
    DBMS_OUTPUT.PUT_LINE('Total Sales: $' || TO_CHAR(v_total_sales, '99,999,999'));
    DBMS_OUTPUT.PUT_LINE('Average Sales: $' || TO_CHAR(v_avg_sales, '9,999,999'));
    DBMS_OUTPUT.PUT_LINE('Top Territory: ' || v_top_territory || ' ($' || 
                        TO_CHAR(v_top_sales, '9,999,999') || ')');
END;
/

-- Example 2: Nested Tables and VARRAYs
-- Business scenario: Product catalog with multiple categories
DECLARE
    -- Define collection types
    TYPE t_string_array IS TABLE OF VARCHAR2(100);
    TYPE t_price_array IS VARRAY(10) OF NUMBER;
    
    v_categories t_string_array;
    v_prices t_price_array;
    v_premium_products t_string_array := t_string_array();
    
    PROCEDURE analyze_products(
        p_categories IN t_string_array,
        p_prices IN t_price_array
    ) IS
        v_total_value NUMBER := 0;
        v_premium_threshold NUMBER := 1000;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== PRODUCT ANALYSIS ===');
        
        FOR i IN 1..p_categories.COUNT LOOP
            v_total_value := v_total_value + p_prices(i);
            
            DBMS_OUTPUT.PUT_LINE('Product ' || i || ': ' || p_categories(i) || 
                               ' - $' || TO_CHAR(p_prices(i), '9,999.99'));
            
            -- Identify premium products
            IF p_prices(i) > v_premium_threshold THEN
                v_premium_products.EXTEND;
                v_premium_products(v_premium_products.LAST) := p_categories(i);
            END IF;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Total Catalog Value: $' || TO_CHAR(v_total_value, '99,999.99'));
        DBMS_OUTPUT.PUT_LINE('Average Price: $' || 
                           TO_CHAR(v_total_value / p_categories.COUNT, '9,999.99'));
    END analyze_products;
    
BEGIN
    -- Initialize collections
    v_categories := t_string_array('Gaming Laptop', 'Business Laptop', 'Ultrabook', 
                                  'Desktop Pro', 'Workstation');
    v_prices := t_price_array(1299.99, 899.99, 1199.99, 799.99, 2499.99);
    
    -- Analyze products
    analyze_products(v_categories, v_prices);
    
    -- Display premium products
    IF v_premium_products.COUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Premium Products (>$1000):');
        FOR i IN 1..v_premium_products.COUNT LOOP
            DBMS_OUTPUT.PUT_LINE('  ' || v_premium_products(i));
        END LOOP;
    END IF;
END;
/

-- ============================================================================
-- SECTION 2: ADVANCED CURSOR OPERATIONS
-- Complex cursor patterns and cursor variables
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 2: ADVANCED CURSOR OPERATIONS
PROMPT ========================================

-- Example 3: Cursor variables (REF CURSOR)
-- Business scenario: Dynamic reporting with flexible queries
DECLARE
    TYPE t_emp_cursor IS REF CURSOR;
    v_emp_cursor t_emp_cursor;
    
    TYPE t_emp_record IS RECORD (
        emp_id NUMBER,
        emp_name VARCHAR2(100),
        dept_name VARCHAR2(50),
        salary NUMBER,
        performance_rating NUMBER
    );
    
    v_emp_rec t_emp_record;
    v_report_type VARCHAR2(20) := 'HIGH_PERFORMERS';
    v_sql_query VARCHAR2(1000);
    v_count NUMBER := 0;
    v_total_salary NUMBER := 0;
    
BEGIN
    -- Create sample data in a temporary structure
    EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE temp_employees (
        emp_id NUMBER,
        emp_name VARCHAR2(100),
        dept_name VARCHAR2(50),
        salary NUMBER,
        performance_rating NUMBER
    ) ON COMMIT DELETE ROWS';
    
    -- Insert sample data
    INSERT INTO temp_employees VALUES (1, 'John Smith', 'IT', 85000, 4.5);
    INSERT INTO temp_employees VALUES (2, 'Jane Doe', 'Finance', 75000, 4.8);
    INSERT INTO temp_employees VALUES (3, 'Bob Johnson', 'IT', 92000, 4.2);
    INSERT INTO temp_employees VALUES (4, 'Alice Wilson', 'Marketing', 68000, 4.7);
    INSERT INTO temp_employees VALUES (5, 'Charlie Brown', 'Finance', 58000, 3.8);
    INSERT INTO temp_employees VALUES (6, 'Diana Prince', 'IT', 98000, 4.9);
    
    -- Dynamic query based on report type
    CASE v_report_type
        WHEN 'HIGH_PERFORMERS' THEN
            v_sql_query := 'SELECT emp_id, emp_name, dept_name, salary, performance_rating 
                           FROM temp_employees WHERE performance_rating >= 4.5 
                           ORDER BY performance_rating DESC';
        WHEN 'HIGH_SALARY' THEN
            v_sql_query := 'SELECT emp_id, emp_name, dept_name, salary, performance_rating 
                           FROM temp_employees WHERE salary >= 80000 
                           ORDER BY salary DESC';
        WHEN 'IT_DEPARTMENT' THEN
            v_sql_query := 'SELECT emp_id, emp_name, dept_name, salary, performance_rating 
                           FROM temp_employees WHERE dept_name = ''IT'' 
                           ORDER BY emp_name';
        ELSE
            v_sql_query := 'SELECT emp_id, emp_name, dept_name, salary, performance_rating 
                           FROM temp_employees ORDER BY emp_id';
    END CASE;
    
    DBMS_OUTPUT.PUT_LINE('=== ' || REPLACE(v_report_type, '_', ' ') || ' REPORT ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Open cursor with dynamic query
    OPEN v_emp_cursor FOR v_sql_query;
    
    LOOP
        FETCH v_emp_cursor INTO v_emp_rec;
        EXIT WHEN v_emp_cursor%NOTFOUND;
        
        v_count := v_count + 1;
        v_total_salary := v_total_salary + v_emp_rec.salary;
        
        DBMS_OUTPUT.PUT_LINE(v_emp_rec.emp_id || ': ' || v_emp_rec.emp_name || 
                           ' (' || v_emp_rec.dept_name || ')');
        DBMS_OUTPUT.PUT_LINE('    Salary: $' || TO_CHAR(v_emp_rec.salary, '99,999') || 
                           ', Rating: ' || v_emp_rec.performance_rating);
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    CLOSE v_emp_cursor;
    
    -- Display summary
    DBMS_OUTPUT.PUT_LINE('=== SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('Employees Found: ' || v_count);
    IF v_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('Total Salary: $' || TO_CHAR(v_total_salary, '999,999'));
        DBMS_OUTPUT.PUT_LINE('Average Salary: $' || TO_CHAR(v_total_salary / v_count, '99,999'));
    END IF;
    
    -- Cleanup
    EXECUTE IMMEDIATE 'DROP TABLE temp_employees';
END;
/

-- Example 4: Advanced cursor FOR loops with complex processing
-- Business scenario: Multi-level data aggregation
DECLARE
    -- Create temporary tables for complex analysis
    PROCEDURE setup_sample_data IS
    BEGIN
        EXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE temp_sales (
            region VARCHAR2(50),
            country VARCHAR2(50),
            salesperson VARCHAR2(100),
            product_category VARCHAR2(50),
            sale_amount NUMBER,
            sale_date DATE
        ) ON COMMIT DELETE ROWS';
        
        -- Insert comprehensive sample data
        INSERT INTO temp_sales VALUES ('North America', 'USA', 'John Smith', 'Laptops', 125000, DATE '2025-01-15');
        INSERT INTO temp_sales VALUES ('North America', 'USA', 'Jane Doe', 'Desktops', 85000, DATE '2025-01-20');
        INSERT INTO temp_sales VALUES ('North America', 'Canada', 'Bob Wilson', 'Laptops', 95000, DATE '2025-02-10');
        INSERT INTO temp_sales VALUES ('Europe', 'Germany', 'Anna Mueller', 'Laptops', 110000, DATE '2025-01-25');
        INSERT INTO temp_sales VALUES ('Europe', 'France', 'Pierre Dubois', 'Tablets', 75000, DATE '2025-02-05');
        INSERT INTO temp_sales VALUES ('Asia Pacific', 'Japan', 'Hiroshi Tanaka', 'Laptops', 130000, DATE '2025-01-30');
        INSERT INTO temp_sales VALUES ('Asia Pacific', 'China', 'Li Wei', 'Desktops', 105000, DATE '2025-02-15');
    END setup_sample_data;
    
    TYPE t_region_summary IS RECORD (
        region VARCHAR2(50),
        total_sales NUMBER,
        avg_sales NUMBER,
        top_salesperson VARCHAR2(100),
        top_sales NUMBER
    );
    
    TYPE t_region_summaries IS TABLE OF t_region_summary INDEX BY VARCHAR2(50);
    v_summaries t_region_summaries;
    
    v_grand_total NUMBER := 0;
    v_region VARCHAR2(50);
    
BEGIN
    setup_sample_data;
    
    DBMS_OUTPUT.PUT_LINE('=== MULTI-LEVEL SALES ANALYSIS ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- First level: Regional analysis
    FOR region_rec IN (
        SELECT region, 
               SUM(sale_amount) as total_sales,
               AVG(sale_amount) as avg_sales,
               COUNT(*) as sale_count
        FROM temp_sales 
        GROUP BY region 
        ORDER BY total_sales DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('REGION: ' || region_rec.region);
        DBMS_OUTPUT.PUT_LINE('  Total Sales: $' || TO_CHAR(region_rec.total_sales, '999,999'));
        DBMS_OUTPUT.PUT_LINE('  Average Sale: $' || TO_CHAR(region_rec.avg_sales, '99,999'));
        DBMS_OUTPUT.PUT_LINE('  Number of Sales: ' || region_rec.sale_count);
        
        v_grand_total := v_grand_total + region_rec.total_sales;
        
        -- Second level: Country analysis within region
        DBMS_OUTPUT.PUT_LINE('  Countries:');
        FOR country_rec IN (
            SELECT country, 
                   SUM(sale_amount) as country_sales,
                   COUNT(*) as country_count
            FROM temp_sales 
            WHERE region = region_rec.region
            GROUP BY country 
            ORDER BY country_sales DESC
        ) LOOP
            DBMS_OUTPUT.PUT_LINE('    ' || country_rec.country || ': $' || 
                               TO_CHAR(country_rec.country_sales, '999,999') ||
                               ' (' || country_rec.country_count || ' sales)');
            
            -- Third level: Salesperson analysis within country
            FOR person_rec IN (
                SELECT salesperson, 
                       SUM(sale_amount) as person_sales,
                       product_category
                FROM temp_sales 
                WHERE region = region_rec.region 
                  AND country = country_rec.country
                GROUP BY salesperson, product_category
                ORDER BY person_sales DESC
            ) LOOP
                DBMS_OUTPUT.PUT_LINE('      ' || person_rec.salesperson || 
                                   ' (' || person_rec.product_category || '): $' ||
                                   TO_CHAR(person_rec.person_sales, '99,999'));
            END LOOP;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    -- Product category analysis across all regions
    DBMS_OUTPUT.PUT_LINE('=== PRODUCT CATEGORY ANALYSIS ===');
    FOR product_rec IN (
        SELECT product_category,
               SUM(sale_amount) as category_sales,
               COUNT(*) as category_count,
               AVG(sale_amount) as category_avg,
               MIN(sale_amount) as category_min,
               MAX(sale_amount) as category_max
        FROM temp_sales
        GROUP BY product_category
        ORDER BY category_sales DESC
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Category: ' || product_rec.product_category);
        DBMS_OUTPUT.PUT_LINE('  Total Sales: $' || TO_CHAR(product_rec.category_sales, '999,999'));
        DBMS_OUTPUT.PUT_LINE('  Count: ' || product_rec.category_count);
        DBMS_OUTPUT.PUT_LINE('  Average: $' || TO_CHAR(product_rec.category_avg, '99,999'));
        DBMS_OUTPUT.PUT_LINE('  Range: $' || TO_CHAR(product_rec.category_min, '99,999') ||
                           ' - $' || TO_CHAR(product_rec.category_max, '99,999'));
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('=== OVERALL SUMMARY ===');
    DBMS_OUTPUT.PUT_LINE('Grand Total Sales: $' || TO_CHAR(v_grand_total, '999,999'));
    
    -- Cleanup
    EXECUTE IMMEDIATE 'DROP TABLE temp_sales';
END;
/

-- ============================================================================
-- SECTION 3: DYNAMIC SQL AND NATIVE DYNAMIC SQL
-- Building and executing SQL statements at runtime
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 3: DYNAMIC SQL AND NATIVE DYNAMIC SQL
PROMPT ========================================

-- Example 5: Dynamic SQL for flexible table operations
-- Business scenario: Generic data analysis tool
DECLARE
    TYPE t_column_info IS RECORD (
        column_name VARCHAR2(128),
        data_type VARCHAR2(106),
        nullable VARCHAR2(1),
        column_id NUMBER
    );
    
    TYPE t_column_list IS TABLE OF t_column_info;
    v_columns t_column_list;
    
    v_table_name VARCHAR2(128) := 'USER_TABLES';  -- Analyzing data dictionary
    v_sql VARCHAR2(4000);
    v_count NUMBER;
    v_max_length NUMBER := 0;
    v_column_name VARCHAR2(128);
    
    -- Dynamic cursor variable
    TYPE t_generic_cursor IS REF CURSOR;
    v_cursor t_generic_cursor;
    v_value VARCHAR2(4000);
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== DYNAMIC TABLE ANALYSIS ===');
    DBMS_OUTPUT.PUT_LINE('Analyzing table: ' || v_table_name);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Get table structure dynamically
    v_sql := 'SELECT column_name, data_type, nullable, column_id 
              FROM user_tab_columns 
              WHERE table_name = :table_name 
              ORDER BY column_id';
    
    EXECUTE IMMEDIATE v_sql BULK COLLECT INTO v_columns USING v_table_name;
    
    DBMS_OUTPUT.PUT_LINE('=== TABLE STRUCTURE ===');
    FOR i IN 1..v_columns.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(v_columns(i).column_id || '. ' || 
                           v_columns(i).column_name || ' (' || 
                           v_columns(i).data_type || 
                           CASE WHEN v_columns(i).nullable = 'N' THEN ' NOT NULL' ELSE '' END || ')');
        
        -- Track longest column name for formatting
        IF LENGTH(v_columns(i).column_name) > v_max_length THEN
            v_max_length := LENGTH(v_columns(i).column_name);
        END IF;
    END LOOP;
    
    -- Get row count dynamically
    v_sql := 'SELECT COUNT(*) FROM ' || v_table_name;
    EXECUTE IMMEDIATE v_sql INTO v_count;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Total rows: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Sample data analysis for VARCHAR2 columns
    DBMS_OUTPUT.PUT_LINE('=== VARCHAR2 COLUMN ANALYSIS ===');
    FOR i IN 1..v_columns.COUNT LOOP
        IF v_columns(i).data_type LIKE 'VARCHAR2%' THEN
            -- Get distinct count
            v_sql := 'SELECT COUNT(DISTINCT ' || v_columns(i).column_name || ') FROM ' || v_table_name;
            EXECUTE IMMEDIATE v_sql INTO v_count;
            
            DBMS_OUTPUT.PUT_LINE(RPAD(v_columns(i).column_name, v_max_length + 2) || 
                               'Distinct values: ' || v_count);
        END IF;
    END LOOP;
    
    -- Dynamic query with cursor
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== SAMPLE DATA (First 5 table names) ===');
    v_sql := 'SELECT table_name FROM ' || v_table_name || ' WHERE ROWNUM <= 5 ORDER BY table_name';
    
    OPEN v_cursor FOR v_sql;
    LOOP
        FETCH v_cursor INTO v_value;
        EXIT WHEN v_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('  ' || v_value);
    END LOOP;
    CLOSE v_cursor;
    
EXCEPTION
    WHEN OTHERS THEN
        IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error in dynamic analysis: ' || SQLERRM);
END;
/

-- Example 6: Dynamic SQL for DDL operations
-- Business scenario: Dynamic table creation and management
DECLARE
    TYPE t_table_spec IS RECORD (
        table_name VARCHAR2(30),
        columns VARCHAR2(1000),
        constraints VARCHAR2(500)
    );
    
    TYPE t_table_specs IS TABLE OF t_table_spec;
    v_tables t_table_specs;
    
    v_sql VARCHAR2(4000);
    v_exists NUMBER;
    
    PROCEDURE create_table_if_not_exists(
        p_table_name IN VARCHAR2,
        p_columns IN VARCHAR2,
        p_constraints IN VARCHAR2 DEFAULT NULL
    ) IS
    BEGIN
        -- Check if table exists
        SELECT COUNT(*)
        INTO v_exists
        FROM user_tables
        WHERE table_name = UPPER(p_table_name);
        
        IF v_exists = 0 THEN
            v_sql := 'CREATE TABLE ' || p_table_name || ' (' || p_columns;
            IF p_constraints IS NOT NULL THEN
                v_sql := v_sql || ', ' || p_constraints;
            END IF;
            v_sql := v_sql || ')';
            
            EXECUTE IMMEDIATE v_sql;
            DBMS_OUTPUT.PUT_LINE('Created table: ' || p_table_name);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Table already exists: ' || p_table_name);
        END IF;
    END create_table_if_not_exists;
    
    PROCEDURE populate_sample_data(p_table_name IN VARCHAR2) IS
    BEGIN
        CASE UPPER(p_table_name)
            WHEN 'DYNAMIC_CUSTOMERS' THEN
                v_sql := 'INSERT INTO ' || p_table_name || ' VALUES (1, ''John Smith'', ''john@email.com'', SYSDATE)';
                EXECUTE IMMEDIATE v_sql;
                v_sql := 'INSERT INTO ' || p_table_name || ' VALUES (2, ''Jane Doe'', ''jane@email.com'', SYSDATE-30)';
                EXECUTE IMMEDIATE v_sql;
                
            WHEN 'DYNAMIC_ORDERS' THEN
                v_sql := 'INSERT INTO ' || p_table_name || ' VALUES (1, 1, 150.00, SYSDATE, ''COMPLETED'')';
                EXECUTE IMMEDIATE v_sql;
                v_sql := 'INSERT INTO ' || p_table_name || ' VALUES (2, 2, 275.50, SYSDATE-15, ''SHIPPED'')';
                EXECUTE IMMEDIATE v_sql;
        END CASE;
        
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Sample data inserted into: ' || p_table_name);
    END populate_sample_data;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== DYNAMIC TABLE MANAGEMENT ===');
    
    -- Define table specifications
    v_tables := t_table_specs();
    
    v_tables.EXTEND;
    v_tables(v_tables.LAST).table_name := 'dynamic_customers';
    v_tables(v_tables.LAST).columns := 'customer_id NUMBER, customer_name VARCHAR2(100), email VARCHAR2(100), registration_date DATE';
    v_tables(v_tables.LAST).constraints := 'CONSTRAINT pk_dyn_cust PRIMARY KEY (customer_id)';
    
    v_tables.EXTEND;
    v_tables(v_tables.LAST).table_name := 'dynamic_orders';
    v_tables(v_tables.LAST).columns := 'order_id NUMBER, customer_id NUMBER, amount NUMBER(10,2), order_date DATE, status VARCHAR2(20)';
    v_tables(v_tables.LAST).constraints := 'CONSTRAINT pk_dyn_ord PRIMARY KEY (order_id)';
    
    -- Create tables dynamically
    FOR i IN 1..v_tables.COUNT LOOP
        create_table_if_not_exists(
            v_tables(i).table_name,
            v_tables(i).columns,
            v_tables(i).constraints
        );
        
        populate_sample_data(v_tables(i).table_name);
    END LOOP;
    
    -- Dynamic reporting
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== DYNAMIC REPORTING ===');
    
    -- Customer report
    v_sql := 'SELECT customer_name, email FROM dynamic_customers ORDER BY registration_date DESC';
    FOR rec IN (EXECUTE IMMEDIATE v_sql) LOOP
        DBMS_OUTPUT.PUT_LINE('Customer: ' || rec.customer_name || ' (' || rec.email || ')');
    END LOOP;
    
    -- Order summary
    v_sql := 'SELECT COUNT(*) as order_count, SUM(amount) as total_amount FROM dynamic_orders';
    EXECUTE IMMEDIATE v_sql INTO v_exists, v_sql; -- Reusing variables
    DBMS_OUTPUT.PUT_LINE('Total Orders: ' || v_exists || ', Total Amount: $' || v_sql);
    
    -- Cleanup demonstration
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== CLEANUP ===');
    FOR i IN 1..v_tables.COUNT LOOP
        v_sql := 'DROP TABLE ' || v_tables(i).table_name;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Dropped table: ' || v_tables(i).table_name);
    END LOOP;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in dynamic table management: ' || SQLERRM);
        -- Attempt cleanup on error
        FOR i IN 1..v_tables.COUNT LOOP
            BEGIN
                EXECUTE IMMEDIATE 'DROP TABLE ' || v_tables(i).table_name;
            EXCEPTION
                WHEN OTHERS THEN NULL; -- Ignore errors during cleanup
            END;
        END LOOP;
END;
/

-- ============================================================================
-- SECTION 4: BULK OPERATIONS
-- High-performance data processing techniques
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 4: BULK OPERATIONS
PROMPT ========================================

-- Example 7: BULK COLLECT and FORALL for high-performance processing
-- Business scenario: Large-scale data transformation
DECLARE
    -- Setup for bulk operations demonstration
    PROCEDURE setup_bulk_demo IS
    BEGIN
        EXECUTE IMMEDIATE 'CREATE TABLE source_data (
            id NUMBER,
            first_name VARCHAR2(50),
            last_name VARCHAR2(50),
            salary NUMBER,
            department VARCHAR2(50),
            hire_date DATE
        )';
        
        EXECUTE IMMEDIATE 'CREATE TABLE processed_data (
            id NUMBER,
            full_name VARCHAR2(101),
            annual_salary NUMBER,
            department_code VARCHAR2(10),
            tenure_years NUMBER,
            salary_grade VARCHAR2(10),
            processed_date DATE
        )';
        
        -- Insert large amount of sample data
        FOR i IN 1..1000 LOOP
            INSERT INTO source_data VALUES (
                i,
                'FirstName' || i,
                'LastName' || i,
                40000 + MOD(i * 37, 60000), -- Random salary between 40k-100k
                CASE MOD(i, 5) 
                    WHEN 0 THEN 'Engineering'
                    WHEN 1 THEN 'Sales'
                    WHEN 2 THEN 'Marketing'
                    WHEN 3 THEN 'Finance'
                    ELSE 'Operations'
                END,
                SYSDATE - MOD(i * 13, 3650) -- Random hire date within last 10 years
            );
        END LOOP;
        COMMIT;
    END setup_bulk_demo;
    
    -- Types for bulk operations
    TYPE t_id_array IS TABLE OF NUMBER;
    TYPE t_name_array IS TABLE OF VARCHAR2(101);
    TYPE t_salary_array IS TABLE OF NUMBER;
    TYPE t_dept_array IS TABLE OF VARCHAR2(10);
    TYPE t_tenure_array IS TABLE OF NUMBER;
    TYPE t_grade_array IS TABLE OF VARCHAR2(10);
    
    -- Arrays for bulk collect
    v_ids t_id_array;
    v_full_names t_name_array;
    v_annual_salaries t_salary_array;
    v_dept_codes t_dept_array;
    v_tenures t_tenure_array;
    v_salary_grades t_grade_array;
    
    -- Cursor for bulk processing
    CURSOR c_source_data IS
        SELECT id, 
               first_name || ' ' || last_name as full_name,
               salary * 12 as annual_salary,
               CASE department
                   WHEN 'Engineering' THEN 'ENG'
                   WHEN 'Sales' THEN 'SAL'
                   WHEN 'Marketing' THEN 'MKT'
                   WHEN 'Finance' THEN 'FIN'
                   ELSE 'OPS'
               END as dept_code,
               ROUND(MONTHS_BETWEEN(SYSDATE, hire_date) / 12, 1) as tenure_years,
               CASE 
                   WHEN salary >= 80000 THEN 'A'
                   WHEN salary >= 60000 THEN 'B'
                   WHEN salary >= 45000 THEN 'C'
                   ELSE 'D'
               END as salary_grade
        FROM source_data;
    
    v_start_time NUMBER;
    v_end_time NUMBER;
    v_batch_size CONSTANT NUMBER := 100;
    v_total_processed NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== BULK OPERATIONS DEMONSTRATION ===');
    
    setup_bulk_demo;
    
    v_start_time := DBMS_UTILITY.GET_TIME;
    
    -- Bulk processing with LIMIT for memory management
    OPEN c_source_data;
    LOOP
        -- Clear arrays
        v_ids.DELETE;
        v_full_names.DELETE;
        v_annual_salaries.DELETE;
        v_dept_codes.DELETE;
        v_tenures.DELETE;
        v_salary_grades.DELETE;
        
        -- Bulk collect with LIMIT
        FETCH c_source_data BULK COLLECT INTO 
            v_ids, v_full_names, v_annual_salaries, 
            v_dept_codes, v_tenures, v_salary_grades
        LIMIT v_batch_size;
        
        EXIT WHEN v_ids.COUNT = 0;
        
        -- Process the batch
        FORALL i IN 1..v_ids.COUNT
            INSERT INTO processed_data (
                id, full_name, annual_salary, department_code,
                tenure_years, salary_grade, processed_date
            ) VALUES (
                v_ids(i), v_full_names(i), v_annual_salaries(i),
                v_dept_codes(i), v_tenures(i), v_salary_grades(i), SYSDATE
            );
        
        v_total_processed := v_total_processed + v_ids.COUNT;
        
        -- Progress reporting
        IF MOD(v_total_processed, 500) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Processed ' || v_total_processed || ' records...');
        END IF;
        
        COMMIT; -- Commit each batch
    END LOOP;
    CLOSE c_source_data;
    
    v_end_time := DBMS_UTILITY.GET_TIME;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== BULK PROCESSING RESULTS ===');
    DBMS_OUTPUT.PUT_LINE('Total records processed: ' || v_total_processed);
    DBMS_OUTPUT.PUT_LINE('Processing time: ' || (v_end_time - v_start_time) / 100 || ' seconds');
    DBMS_OUTPUT.PUT_LINE('Records per second: ' || ROUND(v_total_processed / ((v_end_time - v_start_time) / 100), 2));
    
    -- Analysis of processed data
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== PROCESSED DATA ANALYSIS ===');
    
    FOR dept_rec IN (
        SELECT department_code, 
               COUNT(*) as emp_count,
               AVG(annual_salary) as avg_salary,
               AVG(tenure_years) as avg_tenure
        FROM processed_data
        GROUP BY department_code
        ORDER BY department_code
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Department ' || dept_rec.department_code || ':');
        DBMS_OUTPUT.PUT_LINE('  Employees: ' || dept_rec.emp_count);
        DBMS_OUTPUT.PUT_LINE('  Avg Salary: $' || TO_CHAR(dept_rec.avg_salary, '999,999'));
        DBMS_OUTPUT.PUT_LINE('  Avg Tenure: ' || ROUND(dept_rec.avg_tenure, 1) || ' years');
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    -- Salary grade distribution
    DBMS_OUTPUT.PUT_LINE('=== SALARY GRADE DISTRIBUTION ===');
    FOR grade_rec IN (
        SELECT salary_grade, COUNT(*) as grade_count
        FROM processed_data
        GROUP BY salary_grade
        ORDER BY salary_grade
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('Grade ' || grade_rec.salary_grade || ': ' || 
                           grade_rec.grade_count || ' employees');
    END LOOP;
    
    -- Cleanup
    EXECUTE IMMEDIATE 'DROP TABLE processed_data';
    EXECUTE IMMEDIATE 'DROP TABLE source_data';
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_source_data%ISOPEN THEN
            CLOSE c_source_data;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error in bulk processing: ' || SQLERRM);
        -- Cleanup on error
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE processed_data';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
        BEGIN
            EXECUTE IMMEDIATE 'DROP TABLE source_data';
        EXCEPTION WHEN OTHERS THEN NULL;
        END;
END;
/

-- ============================================================================
-- SECTION 5: OBJECT-ORIENTED PL/SQL
-- Object types, methods, and inheritance concepts
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 5: OBJECT-ORIENTED PL/SQL
PROMPT ========================================

-- Example 8: Object types and methods
-- Business scenario: Employee hierarchy with polymorphism

-- Base employee type
CREATE OR REPLACE TYPE t_employee AS OBJECT (
    employee_id NUMBER,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    hire_date DATE,
    base_salary NUMBER,
    
    -- Constructor
    CONSTRUCTOR FUNCTION t_employee(
        p_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER
    ) RETURN SELF AS RESULT,
    
    -- Member functions
    MEMBER FUNCTION get_full_name RETURN VARCHAR2,
    MEMBER FUNCTION get_annual_salary RETURN NUMBER,
    MEMBER FUNCTION get_tenure_years RETURN NUMBER,
    
    -- Virtual function (to be overridden)
    MEMBER FUNCTION calculate_bonus RETURN NUMBER,
    
    -- Member procedures
    MEMBER PROCEDURE display_info,
    MEMBER PROCEDURE give_raise(p_percentage NUMBER)
) NOT FINAL;
/

-- Type body implementation
CREATE OR REPLACE TYPE BODY t_employee AS
    CONSTRUCTOR FUNCTION t_employee(
        p_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        employee_id := p_id;
        first_name := p_first_name;
        last_name := p_last_name;
        hire_date := SYSDATE;
        base_salary := p_salary;
        RETURN;
    END;
    
    MEMBER FUNCTION get_full_name RETURN VARCHAR2 IS
    BEGIN
        RETURN first_name || ' ' || last_name;
    END;
    
    MEMBER FUNCTION get_annual_salary RETURN NUMBER IS
    BEGIN
        RETURN base_salary * 12;
    END;
    
    MEMBER FUNCTION get_tenure_years RETURN NUMBER IS
    BEGIN
        RETURN ROUND(MONTHS_BETWEEN(SYSDATE, hire_date) / 12, 1);
    END;
    
    MEMBER FUNCTION calculate_bonus RETURN NUMBER IS
    BEGIN
        -- Base bonus is 5% of annual salary
        RETURN get_annual_salary() * 0.05;
    END;
    
    MEMBER PROCEDURE display_info IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('Employee: ' || get_full_name());
        DBMS_OUTPUT.PUT_LINE('  ID: ' || employee_id);
        DBMS_OUTPUT.PUT_LINE('  Annual Salary: $' || TO_CHAR(get_annual_salary(), '999,999'));
        DBMS_OUTPUT.PUT_LINE('  Tenure: ' || get_tenure_years() || ' years');
        DBMS_OUTPUT.PUT_LINE('  Bonus: $' || TO_CHAR(calculate_bonus(), '99,999'));
    END;
    
    MEMBER PROCEDURE give_raise(p_percentage NUMBER) IS
    BEGIN
        base_salary := base_salary * (1 + p_percentage / 100);
        DBMS_OUTPUT.PUT_LINE('Raise of ' || p_percentage || '% given to ' || get_full_name());
    END;
END;
/

-- Manager subtype
CREATE OR REPLACE TYPE t_manager UNDER t_employee (
    department VARCHAR2(50),
    team_size NUMBER,
    
    -- Override constructor
    CONSTRUCTOR FUNCTION t_manager(
        p_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_department VARCHAR2,
        p_team_size NUMBER
    ) RETURN SELF AS RESULT,
    
    -- Override bonus calculation
    OVERRIDING MEMBER FUNCTION calculate_bonus RETURN NUMBER,
    
    -- Additional methods
    MEMBER FUNCTION get_management_bonus RETURN NUMBER,
    OVERRIDING MEMBER PROCEDURE display_info
);
/

CREATE OR REPLACE TYPE BODY t_manager AS
    CONSTRUCTOR FUNCTION t_manager(
        p_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_department VARCHAR2,
        p_team_size NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        employee_id := p_id;
        first_name := p_first_name;
        last_name := p_last_name;
        hire_date := SYSDATE;
        base_salary := p_salary;
        department := p_department;
        team_size := p_team_size;
        RETURN;
    END;
    
    OVERRIDING MEMBER FUNCTION calculate_bonus RETURN NUMBER IS
    BEGIN
        -- Managers get base bonus plus management bonus
        RETURN (SELF AS t_employee).calculate_bonus() + get_management_bonus();
    END;
    
    MEMBER FUNCTION get_management_bonus RETURN NUMBER IS
    BEGIN
        -- Management bonus based on team size
        RETURN team_size * 1000;
    END;
    
    OVERRIDING MEMBER PROCEDURE display_info IS
    BEGIN
        -- Call parent method
        (SELF AS t_employee).display_info();
        DBMS_OUTPUT.PUT_LINE('  Department: ' || department);
        DBMS_OUTPUT.PUT_LINE('  Team Size: ' || team_size);
        DBMS_OUTPUT.PUT_LINE('  Management Bonus: $' || TO_CHAR(get_management_bonus(), '99,999'));
    END;
END;
/

-- Executive subtype
CREATE OR REPLACE TYPE t_executive UNDER t_manager (
    stock_options NUMBER,
    
    CONSTRUCTOR FUNCTION t_executive(
        p_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_department VARCHAR2,
        p_team_size NUMBER,
        p_stock_options NUMBER
    ) RETURN SELF AS RESULT,
    
    OVERRIDING MEMBER FUNCTION calculate_bonus RETURN NUMBER,
    MEMBER FUNCTION get_stock_value RETURN NUMBER,
    OVERRIDING MEMBER PROCEDURE display_info
);
/

CREATE OR REPLACE TYPE BODY t_executive AS
    CONSTRUCTOR FUNCTION t_executive(
        p_id NUMBER,
        p_first_name VARCHAR2,
        p_last_name VARCHAR2,
        p_salary NUMBER,
        p_department VARCHAR2,
        p_team_size NUMBER,
        p_stock_options NUMBER
    ) RETURN SELF AS RESULT IS
    BEGIN
        employee_id := p_id;
        first_name := p_first_name;
        last_name := p_last_name;
        hire_date := SYSDATE;
        base_salary := p_salary;
        department := p_department;
        team_size := p_team_size;
        stock_options := p_stock_options;
        RETURN;
    END;
    
    OVERRIDING MEMBER FUNCTION calculate_bonus RETURN NUMBER IS
    BEGIN
        -- Executives get manager bonus plus stock value
        RETURN (SELF AS t_manager).calculate_bonus() + get_stock_value();
    END;
    
    MEMBER FUNCTION get_stock_value RETURN NUMBER IS
    BEGIN
        -- Simplified stock value calculation
        RETURN stock_options * 50; -- $50 per option
    END;
    
    OVERRIDING MEMBER PROCEDURE display_info IS
    BEGIN
        (SELF AS t_manager).display_info();
        DBMS_OUTPUT.PUT_LINE('  Stock Options: ' || stock_options);
        DBMS_OUTPUT.PUT_LINE('  Stock Value: $' || TO_CHAR(get_stock_value(), '999,999'));
    END;
END;
/

-- Demonstrate object-oriented programming
DECLARE
    v_employee t_employee;
    v_manager t_manager;
    v_executive t_executive;
    
    -- Collection of employees (polymorphism)
    TYPE t_employee_list IS TABLE OF t_employee;
    v_employees t_employee_list;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== OBJECT-ORIENTED PL/SQL DEMONSTRATION ===');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Create different types of employees
    v_employee := t_employee(1, 'John', 'Smith', 5000);
    v_manager := t_manager(2, 'Jane', 'Doe', 8000, 'Engineering', 15);
    v_executive := t_executive(3, 'Bob', 'Johnson', 12000, 'Technology', 50, 10000);
    
    -- Display individual employee information
    DBMS_OUTPUT.PUT_LINE('=== INDIVIDUAL EMPLOYEE DETAILS ===');
    v_employee.display_info();
    DBMS_OUTPUT.PUT_LINE('');
    
    v_manager.display_info();
    DBMS_OUTPUT.PUT_LINE('');
    
    v_executive.display_info();
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Demonstrate polymorphism with collection
    v_employees := t_employee_list(v_employee, v_manager, v_executive);
    
    DBMS_OUTPUT.PUT_LINE('=== POLYMORPHIC PROCESSING ===');
    FOR i IN 1..v_employees.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Processing employee ' || i || ':');
        DBMS_OUTPUT.PUT_LINE('  Name: ' || v_employees(i).get_full_name());
        DBMS_OUTPUT.PUT_LINE('  Total Bonus: $' || TO_CHAR(v_employees(i).calculate_bonus(), '999,999'));
        DBMS_OUTPUT.PUT_LINE('');
    END LOOP;
    
    -- Demonstrate method calls
    DBMS_OUTPUT.PUT_LINE('=== METHOD DEMONSTRATIONS ===');
    v_manager.give_raise(10);
    DBMS_OUTPUT.PUT_LINE('New annual salary: $' || TO_CHAR(v_manager.get_annual_salary(), '999,999'));
    
END;
/

-- ============================================================================
-- CLEANUP SECTION
-- Clean up all objects created during practice
-- ============================================================================

PROMPT ========================================
PROMPT CLEANUP SECTION
PROMPT ========================================

-- Drop object types (in reverse order of dependencies)
DROP TYPE t_executive;
DROP TYPE t_manager;
DROP TYPE t_employee;

PROMPT ========================================
PROMPT ADVANCED PL/SQL PRACTICE COMPLETE
PROMPT ========================================

/*
================================================================================
LEARNING OBJECTIVES COMPLETED:

1. ✓ Mastered associative arrays and nested tables for complex data structures
2. ✓ Implemented advanced cursor operations including cursor variables (REF CURSOR)
3. ✓ Applied dynamic SQL for flexible query construction and execution
4. ✓ Utilized bulk operations (BULK COLLECT, FORALL) for high-performance processing
5. ✓ Created object-oriented PL/SQL with types, inheritance, and polymorphism
6. ✓ Implemented advanced collection methods and manipulation techniques
7. ✓ Developed multi-level data processing with nested cursor loops
8. ✓ Applied dynamic DDL operations for runtime table management
9. ✓ Integrated complex business logic with advanced PL/SQL features
10. ✓ Demonstrated performance optimization techniques and best practices

BUSINESS SCENARIOS COVERED:
- Territory sales performance analysis with associative arrays
- Product catalog management with nested tables and VARRAYs
- Dynamic reporting systems with flexible query generation
- Multi-level sales analysis with complex cursor processing
- Generic data analysis tools using dynamic SQL
- Dynamic table creation and management systems
- Large-scale data transformation with bulk operations
- Employee hierarchy modeling with object-oriented design
- Performance monitoring and optimization techniques
- Polymorphic data processing with inheritance

ADVANCED CONCEPTS DEMONSTRATED:
- Associative arrays (INDEX BY tables) for key-value data structures
- Nested tables and VARRAYs for ordered collections
- REF CURSOR for dynamic result set processing
- Native Dynamic SQL (NDS) for runtime SQL construction
- BULK COLLECT with LIMIT for memory-efficient processing
- FORALL for high-performance DML operations
- Object types with constructors and member methods
- Inheritance and method overriding in PL/SQL
- Polymorphism with object collections
- Exception handling in complex operations

KEY FEATURES COVERED:
- Collection methods (FIRST, LAST, NEXT, COUNT, EXISTS, etc.)
- Dynamic cursor processing with runtime queries
- DDL execution through dynamic SQL
- Batch processing techniques for large datasets
- Object construction and method invocation
- Type hierarchy and inheritance patterns
- Performance optimization strategies
- Memory management in bulk operations
- Error handling in complex scenarios
- Code reusability through object-oriented design

PERFORMANCE TECHNIQUES:
- Bulk operations for reduced context switching
- Cursor processing with LIMIT for memory control
- Dynamic SQL for flexible and efficient queries
- Object-oriented design for code maintainability
- Exception handling for robust error management
- Collection optimization for large datasets
- Memory-efficient processing patterns
- Scalable data transformation techniques

NEXT STEPS:
- Study error-handling.sql for production-grade error management
- Explore lesson5-combined-practice.sql for integrated scenarios
- Practice combining advanced PL/SQL with triggers and packages
- Apply these concepts in real-world database applications

================================================================================
*/
