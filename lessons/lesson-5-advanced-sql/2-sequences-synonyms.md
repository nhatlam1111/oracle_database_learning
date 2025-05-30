# Sequences and Synonyms

Sequences and synonyms are essential Oracle database objects that provide automation and abstraction capabilities. Sequences generate unique numbers automatically, while synonyms create aliases for database objects, improving code maintainability and security.

## 🎯 Learning Objectives

By the end of this section, you will understand:

1. **Sequence Fundamentals**: Auto-incrementing number generation
2. **Sequence Creation and Management**: Configuring and maintaining sequences
3. **Sequence Usage Patterns**: Best practices for primary keys and numbering
4. **Synonym Types**: Public vs private synonyms
5. **Synonym Benefits**: Code portability and security
6. **Object Management**: Organizing database objects effectively

## 📖 Table of Contents

1. [Understanding Sequences](#understanding-sequences)
2. [Creating and Managing Sequences](#creating-and-managing-sequences)
3. [Sequence Usage Patterns](#sequence-usage-patterns)
4. [Understanding Synonyms](#understanding-synonyms)
5. [Creating and Managing Synonyms](#creating-and-managing-synonyms)
6. [Advanced Object Management](#advanced-object-management)
7. [Best Practices](#best-practices)

---

## Understanding Sequences

### What is a Sequence?

A **sequence** is a database object that generates unique numbers automatically. Sequences are commonly used for:

- **Primary Key Values**: Auto-incrementing IDs
- **Transaction Numbers**: Unique transaction identifiers
- **Version Numbers**: Document or record versioning
- **Batch Numbers**: Processing batch identification

### Key Features of Sequences

#### **Guaranteed Uniqueness**
```sql
-- Each call to NEXTVAL returns a unique number
SELECT employee_seq.NEXTVAL FROM dual;  -- Returns 1
SELECT employee_seq.NEXTVAL FROM dual;  -- Returns 2
SELECT employee_seq.NEXTVAL FROM dual;  -- Returns 3
```

#### **Performance Optimization**
- Numbers are pre-allocated in memory
- No locking required for number generation
- High concurrency support

#### **Flexibility**
- Configurable increment values
- Start values and maximum values
- Cycling and caching options

### Sequence vs Alternative Methods

| Method | Pros | Cons |
|--------|------|------|
| **Sequences** | Fast, concurrent, guaranteed unique | Oracle-specific, gaps possible |
| **MAX(ID)+1** | Simple, no gaps | Slow, locking issues, not concurrent |
| **Application Logic** | Portable | Complex, prone to errors |
| **UUID/GUID** | Globally unique | Large storage, not sequential |

---

## Creating and Managing Sequences

### Basic Sequence Creation

#### Simple Sequence
```sql
-- Create a basic sequence starting at 1
CREATE SEQUENCE employee_seq
START WITH 1
INCREMENT BY 1;

-- Use the sequence
SELECT employee_seq.NEXTVAL FROM dual;  -- Gets next value
SELECT employee_seq.CURRVAL FROM dual;  -- Gets current value (after NEXTVAL)
```

#### Sequence with All Options
```sql
CREATE SEQUENCE order_seq
    START WITH 1000          -- Start at 1000
    INCREMENT BY 1           -- Increment by 1
    MAXVALUE 999999         -- Maximum value
    MINVALUE 1              -- Minimum value (for cycling)
    NOCYCLE                 -- Don't cycle when max reached
    CACHE 20                -- Cache 20 values in memory
    NOORDER;                -- Don't guarantee order in RAC
```

### Sequence Parameters Explained

#### **START WITH**
```sql
-- Start sequence at specific value
CREATE SEQUENCE invoice_seq START WITH 10000;
-- First value will be 10000
```

#### **INCREMENT BY**
```sql
-- Increment by different amounts
CREATE SEQUENCE even_seq INCREMENT BY 2;        -- 2, 4, 6, 8...
CREATE SEQUENCE negative_seq INCREMENT BY -1;   -- Countdown sequence
```

#### **MAXVALUE and MINVALUE**
```sql
-- Set bounds
CREATE SEQUENCE bounded_seq
    START WITH 1
    MAXVALUE 1000
    MINVALUE 1;
```

#### **CYCLE vs NOCYCLE**
```sql
-- Cycling sequence (returns to start after max)
CREATE SEQUENCE cycling_seq
    START WITH 1
    MAXVALUE 100
    CYCLE;

-- After reaching 100, next value will be 1 again
```

#### **CACHE**
```sql
-- Cache for performance
CREATE SEQUENCE high_volume_seq
    CACHE 100;              -- Pre-allocate 100 numbers

CREATE SEQUENCE low_volume_seq
    NOCACHE;                -- Generate one at a time
```

#### **ORDER vs NOORDER**
```sql
-- Important for Oracle RAC (Real Application Clusters)
CREATE SEQUENCE rac_seq ORDER;      -- Guarantee order across nodes (slower)
CREATE SEQUENCE rac_seq NOORDER;    -- No order guarantee (faster)
```

### Modifying Sequences

```sql
-- Alter sequence parameters
ALTER SEQUENCE employee_seq
    INCREMENT BY 5
    MAXVALUE 100000
    CACHE 50;

-- Cannot modify START WITH value
-- Must drop and recreate to change START WITH
```

### Sequence Information

```sql
-- View sequence details
SELECT sequence_name, min_value, max_value, increment_by, 
       last_number, cache_size, cycle_flag
FROM user_sequences
WHERE sequence_name = 'EMPLOYEE_SEQ';

-- Check all sequences
SELECT sequence_name, last_number, cache_size
FROM user_sequences
ORDER BY sequence_name;
```

---

## Sequence Usage Patterns

### Primary Key Generation

#### **Method 1: Direct in INSERT**
```sql
-- Create table with sequence-generated primary key
CREATE TABLE customers (
    customer_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE
);

-- Create sequence for primary key
CREATE SEQUENCE customer_seq START WITH 1;

-- Insert using sequence
INSERT INTO customers (customer_id, customer_name, email)
VALUES (customer_seq.NEXTVAL, 'John Doe', 'john@email.com');

INSERT INTO customers (customer_id, customer_name, email)
VALUES (customer_seq.NEXTVAL, 'Jane Smith', 'jane@email.com');
```

#### **Method 2: Using Triggers (Oracle 11g and earlier)**
```sql
-- Create trigger for automatic ID assignment
CREATE OR REPLACE TRIGGER customers_pk_trigger
    BEFORE INSERT ON customers
    FOR EACH ROW
BEGIN
    IF :NEW.customer_id IS NULL THEN
        :NEW.customer_id := customer_seq.NEXTVAL;
    END IF;
END;

-- Now you can insert without specifying ID
INSERT INTO customers (customer_name, email)
VALUES ('Bob Johnson', 'bob@email.com');
```

#### **Method 3: Identity Columns (Oracle 12c+)**
```sql
-- Modern approach with identity columns
CREATE TABLE modern_customers (
    customer_id NUMBER GENERATED ALWAYS AS IDENTITY,
    customer_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE
);

-- Insert without specifying ID
INSERT INTO modern_customers (customer_name, email)
VALUES ('Alice Brown', 'alice@email.com');
```

### Multi-Table Sequences

```sql
-- Shared sequence across related tables
CREATE SEQUENCE transaction_seq START WITH 1;

-- Orders table
INSERT INTO sales.orders (order_id, customer_id, order_date)
VALUES (transaction_seq.NEXTVAL, 1, SYSDATE);

-- Payments table (using same sequence for consistency)
INSERT INTO payments (payment_id, order_id, amount)
VALUES (transaction_seq.NEXTVAL, 1, 150.00);
```

### Sequence Reset and Maintenance

```sql
-- Function to reset sequence to specific value
CREATE OR REPLACE FUNCTION reset_sequence(
    seq_name VARCHAR2,
    new_value NUMBER
) RETURN NUMBER IS
    current_val NUMBER;
    increment_val NUMBER;
BEGIN
    -- Get current value
    EXECUTE IMMEDIATE 'SELECT ' || seq_name || '.NEXTVAL FROM dual' INTO current_val;
    
    -- Calculate increment needed
    increment_val := new_value - current_val - 1;
    
    -- Alter sequence
    EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || seq_name || ' INCREMENT BY ' || increment_val;
    
    -- Get next value (which will be the desired value)
    EXECUTE IMMEDIATE 'SELECT ' || seq_name || '.NEXTVAL FROM dual' INTO current_val;
    
    -- Reset increment to 1
    EXECUTE IMMEDIATE 'ALTER SEQUENCE ' || seq_name || ' INCREMENT BY 1';
    
    RETURN current_val;
END;

-- Usage
SELECT reset_sequence('customer_seq', 5000) FROM dual;
```

### Handling Sequence Gaps

```sql
-- Sequences may have gaps due to:
-- 1. Rollbacks
-- 2. System crashes  
-- 3. Cached values not used

-- Example of gap creation
BEGIN
    INSERT INTO customers (customer_id, customer_name)
    VALUES (customer_seq.NEXTVAL, 'Test Customer');
    
    -- This rollback creates a gap
    ROLLBACK;
END;

-- Next insert will skip the rolled-back number
INSERT INTO customers (customer_id, customer_name)
VALUES (customer_seq.NEXTVAL, 'Real Customer');

-- Check for gaps
SELECT customer_id, 
       LAG(customer_id) OVER (ORDER BY customer_id) as prev_id,
       customer_id - LAG(customer_id) OVER (ORDER BY customer_id) as gap
FROM customers
WHERE customer_id - LAG(customer_id) OVER (ORDER BY customer_id) > 1
ORDER BY customer_id;
```

---

## Understanding Synonyms

### What is a Synonym?

A **synonym** is an alias for a database object (table, view, sequence, procedure, etc.). Synonyms provide:

- **Location Transparency**: Hide object location from users
- **Security**: Control access through synonym permissions
- **Portability**: Change underlying objects without changing code
- **Simplification**: Shorter names for complex object paths

### Types of Synonyms

#### **Private Synonyms**
- Owned by a specific user
- Only accessible to that user (unless granted)
- Created in user's schema

#### **Public Synonyms**
- Available to all database users
- Created by privileged users (DBA)
- No schema qualification needed

### Benefits of Synonyms

#### **Code Portability**
```sql
-- Without synonyms - environment-specific code
SELECT * FROM prod_schema.employees;      -- Production
SELECT * FROM test_schema.employees;      -- Test
SELECT * FROM dev_schema.employees;       -- Development

-- With synonyms - environment-independent code
CREATE SYNONYM employees FOR prod_schema.employees;  -- Production
CREATE SYNONYM employees FOR test_schema.employees;  -- Test  
CREATE SYNONYM employees FOR dev_schema.employees;   -- Development

-- Same code works in all environments
SELECT * FROM employees;
```

#### **Simplified Access**
```sql
-- Complex object name
SELECT * FROM hr_application.employee_management.current_employees_view;

-- Create synonym for simplification
CREATE SYNONYM emp FOR hr_application.employee_management.current_employees_view;

-- Simplified access
SELECT * FROM emp;
```

---

## Creating and Managing Synonyms

### Creating Private Synonyms

```sql
-- Basic private synonym
CREATE SYNONYM emp FOR employees;

-- Synonym for object in different schema
CREATE SYNONYM sales_data FOR sales_schema.orders;

-- Synonym for complex object
CREATE SYNONYM monthly_sales FOR reporting.monthly_sales_materialized_view;
```

### Creating Public Synonyms

```sql
-- Create public synonym (requires DBA privileges)
CREATE PUBLIC SYNONYM global_employees FOR hr.employees;

-- Now all users can access without schema qualification
SELECT * FROM global_employees;
```

### Synonym for Different Object Types

#### **Table Synonyms**
```sql
CREATE SYNONYM cust FOR customers;
CREATE SYNONYM prod FOR sales.products;
```

#### **View Synonyms**
```sql
CREATE SYNONYM emp_summary FOR employee_department_summary;
CREATE SYNONYM sales_rpt FOR monthly_sales_report_view;
```

#### **Sequence Synonyms**
```sql
CREATE SYNONYM next_id FOR customer_seq;

-- Usage
INSERT INTO customers (customer_id, customer_name)
VALUES (next_id.NEXTVAL, 'New Customer');
```

#### **Procedure/Function Synonyms**
```sql
CREATE SYNONYM calc_bonus FOR hr.calculate_employee_bonus;

-- Usage
EXEC calc_bonus(employee_id => 100);
```

### Managing Synonyms

#### **View Synonym Information**
```sql
-- Check user's private synonyms
SELECT synonym_name, table_owner, table_name
FROM user_synonyms
ORDER BY synonym_name;

-- Check all synonyms accessible to user
SELECT owner, synonym_name, table_owner, table_name
FROM all_synonyms
WHERE synonym_name LIKE 'EMP%'
ORDER BY owner, synonym_name;

-- Check public synonyms
SELECT synonym_name, table_owner, table_name
FROM dba_synonyms
WHERE owner = 'PUBLIC'
ORDER BY synonym_name;
```

#### **Dropping Synonyms**
```sql
-- Drop private synonym
DROP SYNONYM emp;

-- Drop public synonym (requires DBA privileges)
DROP PUBLIC SYNONYM global_employees;
```

#### **Replace Synonyms**
```sql
-- Replace synonym with OR REPLACE
CREATE OR REPLACE SYNONYM emp FOR new_employees_table;

-- Synonyms don't support OR REPLACE, so drop first
DROP SYNONYM emp;
CREATE SYNONYM emp FOR new_employees_table;
```

---

## Advanced Object Management

### Database Links with Synonyms

```sql
-- Create database link to remote database
CREATE DATABASE LINK remote_db
CONNECT TO hr_user IDENTIFIED BY password
USING 'remote_server';

-- Create synonym for remote table
CREATE SYNONYM remote_employees FOR employees@remote_db;

-- Access remote data transparently
SELECT * FROM remote_employees WHERE department_id = 20;
```

### Schema Migration with Synonyms

```sql
-- Original application points to old schema
-- CREATE SYNONYM app_employees FOR old_schema.employees;

-- Phase 1: Create synonyms pointing to old schema
CREATE SYNONYM app_employees FOR old_schema.employees;
CREATE SYNONYM app_departments FOR old_schema.departments;

-- Phase 2: Migrate data to new schema
-- (Data migration process)

-- Phase 3: Switch synonyms to new schema
DROP SYNONYM app_employees;
CREATE SYNONYM app_employees FOR new_schema.employees;

DROP SYNONYM app_departments;
CREATE SYNONYM app_departments FOR new_schema.departments;

-- Application code remains unchanged!
```

### Multi-Environment Setup

```sql
-- Development environment setup
CREATE SYNONYM config_table FOR dev_config.application_config;
CREATE SYNONYM log_table FOR dev_logs.application_logs;

-- Production environment setup
-- CREATE SYNONYM config_table FOR prod_config.application_config;
-- CREATE SYNONYM log_table FOR prod_logs.application_logs;

-- Same application code works in both environments
SELECT config_value FROM config_table WHERE config_name = 'MAX_USERS';
INSERT INTO log_table (log_message, log_date) VALUES ('User login', SYSDATE);
```

### Sequence and Synonym Integration

```sql
-- Create sequence in specific schema
CREATE SEQUENCE hr.employee_id_seq START WITH 1000;

-- Create public synonym for the sequence
CREATE PUBLIC SYNONYM emp_id_seq FOR hr.employee_id_seq;

-- Application uses synonym
INSERT INTO employees (employee_id, first_name, last_name)
VALUES (emp_id_seq.NEXTVAL, 'John', 'Doe');

-- Easy to change sequence location later
DROP PUBLIC SYNONYM emp_id_seq;
CREATE PUBLIC SYNONYM emp_id_seq FOR new_hr.employee_id_seq;
```

---

## Best Practices

### Sequence Best Practices

#### **1. Naming Conventions**
```sql
-- Good naming conventions
CREATE SEQUENCE customer_seq;          -- Clear purpose
CREATE SEQUENCE order_id_seq;          -- Specific to use case
CREATE SEQUENCE transaction_number_seq; -- Descriptive

-- Poor naming
CREATE SEQUENCE seq1;                  -- Unclear
CREATE SEQUENCE s_cust;               -- Too abbreviated
```

#### **2. Appropriate Cache Sizes**
```sql
-- High-volume sequences
CREATE SEQUENCE order_seq CACHE 100;   -- Frequent inserts

-- Low-volume sequences  
CREATE SEQUENCE config_seq CACHE 5;    -- Infrequent inserts

-- Single-user sequences
CREATE SEQUENCE user_pref_seq NOCACHE; -- One user, no caching needed
```

#### **3. Monitoring and Maintenance**
```sql
-- Monitor sequence usage
SELECT 
    sequence_name,
    last_number,
    cache_size,
    CASE WHEN max_value - last_number < cache_size * 10 
         THEN 'WARNING: Approaching max value'
         ELSE 'OK'
    END as status
FROM user_sequences;

-- Regular sequence health check
CREATE OR REPLACE PROCEDURE check_sequence_health IS
    v_warning_threshold NUMBER := 1000;
BEGIN
    FOR seq_rec IN (
        SELECT sequence_name, max_value, last_number
        FROM user_sequences
        WHERE max_value - last_number < v_warning_threshold
    ) LOOP
        DBMS_OUTPUT.PUT_LINE('WARNING: Sequence ' || seq_rec.sequence_name || 
                           ' is approaching maximum value');
    END LOOP;
END;
```

### Synonym Best Practices

#### **1. Clear Naming Strategy**
```sql
-- Good synonym names
CREATE SYNONYM emp FOR employees;              -- Clear abbreviation
CREATE SYNONYM monthly_rpt FOR monthly_report_view; -- Descriptive

-- Avoid confusing names
-- CREATE SYNONYM data FOR employees;          -- Too generic
-- CREATE SYNONYM e FOR employees;             -- Too short
```

#### **2. Documentation**
```sql
-- Document synonym purposes
-- Synonym: emp_data
-- Purpose: Points to current employee table, may change during migrations
-- Created: 2025-01-15
-- Owner: HR Application Team
CREATE SYNONYM emp_data FOR current_schema.employees;
```

#### **3. Consistent Usage Patterns**
```sql
-- Establish patterns for your organization
-- Pattern 1: Synonyms for cross-schema access
CREATE SYNONYM hr_employees FOR hr_schema.employees;
CREATE SYNONYM sales_orders FOR sales_schema.orders;

-- Pattern 2: Synonyms for environment independence
CREATE SYNONYM app_config FOR current_env.application_config;
CREATE SYNONYM app_logs FOR current_env.application_logs;
```

#### **4. Permission Management**
```sql
-- Grant permissions on underlying objects, not synonyms
GRANT SELECT ON employees TO app_user;
CREATE SYNONYM emp FOR employees;

-- App_user can now use the synonym
-- GRANT SELECT ON emp TO another_user;  -- This won't work
-- GRANT SELECT ON employees TO another_user;  -- This works
```

### Integration Best Practices

#### **1. Sequence + Trigger + Synonym Pattern**
```sql
-- Complete pattern for auto-incrementing IDs
-- 1. Create sequence
CREATE SEQUENCE customer_id_seq START WITH 1;

-- 2. Create synonym for sequence
CREATE SYNONYM next_cust_id FOR customer_id_seq;

-- 3. Create trigger for automatic assignment
CREATE OR REPLACE TRIGGER customers_auto_id
    BEFORE INSERT ON customers
    FOR EACH ROW
BEGIN
    IF :NEW.customer_id IS NULL THEN
        :NEW.customer_id := next_cust_id.NEXTVAL;
    END IF;
END;

-- 4. Application code is clean
INSERT INTO customers (customer_name) VALUES ('New Customer');
```

#### **2. Error Handling**
```sql
-- Handle synonym resolution errors
CREATE OR REPLACE FUNCTION safe_synonym_access(
    synonym_name VARCHAR2
) RETURN NUMBER IS
    result NUMBER;
BEGIN
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || synonym_name INTO result;
    RETURN result;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error accessing synonym: ' || synonym_name);
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        RETURN -1;
END;
```

#### **3. Migration Planning**
```sql
-- Plan for synonym changes during migrations
-- Step 1: Create new synonyms pointing to old objects
CREATE SYNONYM old_employees FOR legacy_schema.employees;

-- Step 2: Update application to use synonyms
-- (Application deployment)

-- Step 3: Create new schema and migrate data
-- (Data migration process)

-- Step 4: Switch synonyms to new objects
DROP SYNONYM old_employees;
CREATE SYNONYM old_employees FOR new_schema.employees;

-- Step 5: Rename synonyms to remove "old" prefix
DROP SYNONYM old_employees;
CREATE SYNONYM employees FOR new_schema.employees;
```

---

## Summary

Sequences and synonyms are fundamental Oracle objects that provide:

### **Sequences:**
- **Automatic Number Generation**: Reliable, unique, high-performance
- **Concurrency Support**: Multiple users can generate numbers simultaneously
- **Flexibility**: Configurable increment, start, max values, and caching
- **Gap Tolerance**: Understand that gaps are normal and acceptable

### **Synonyms:**
- **Location Transparency**: Hide physical object locations
- **Code Portability**: Same code works across environments
- **Security**: Control access through synonym permissions  
- **Simplification**: Easier names for complex object paths

### Key Takeaways:

1. **Use sequences for primary keys** - Much more efficient than MAX(ID)+1
2. **Cache sequences appropriately** - Balance performance vs gap tolerance
3. **Synonyms enable flexible architecture** - Easy to change underlying objects
4. **Plan for migrations** - Synonyms make schema changes transparent
5. **Follow naming conventions** - Clear, consistent names improve maintainability

### Next Steps:

- Implement sequences for all auto-incrementing columns
- Create synonyms for cross-schema object access
- Design migration strategies using synonyms
- Monitor sequence performance and usage

**Practice File**: Work through `src/advanced/sequences-synonyms.sql` for hands-on examples and exercises.
