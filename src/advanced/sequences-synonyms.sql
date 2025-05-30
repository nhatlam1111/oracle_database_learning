/*
================================================================================
ORACLE DATABASE LEARNING PROJECT
Lesson 5: Advanced SQL Techniques
File: sequences-synonyms.sql
Topic: Sequences and Synonyms Practice Exercises

Description: Comprehensive practice file covering Oracle sequences and synonyms
             with real-world examples and business scenarios.

Author: Oracle Learning Project
Date: May 2025
================================================================================
*/

-- ============================================================================
-- SECTION 1: BASIC SEQUENCES
-- Understanding auto-incrementing sequences in Oracle
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 1: BASIC SEQUENCES
PROMPT ========================================

-- Example 1: Creating a simple sequence for primary keys
-- Business scenario: Employee ID generation
CREATE SEQUENCE emp_id_seq
    START WITH 1000
    INCREMENT BY 1
    NOCACHE
    NOORDER;

-- Demonstrate sequence usage
SELECT emp_id_seq.NEXTVAL FROM dual;
SELECT emp_id_seq.CURRVAL FROM dual;

-- Show sequence details
SELECT 
    sequence_name,
    min_value,
    max_value,
    increment_by,
    cycle_flag,
    cache_size,
    last_number
FROM user_sequences 
WHERE sequence_name = 'EMP_ID_SEQ';

-- Example 2: Creating sequence with caching for performance
-- Business scenario: Order number generation for high-volume system
CREATE SEQUENCE order_number_seq
    START WITH 100000
    INCREMENT BY 1
    CACHE 20
    NOORDER
    NOMAXVALUE;

-- Test the cached sequence
SELECT order_number_seq.NEXTVAL FROM dual;

-- Example 3: Creating a sequence with cycling
-- Business scenario: Daily batch job ID (resets monthly)
CREATE SEQUENCE daily_batch_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 31
    CYCLE
    CACHE 5;

-- Demonstrate cycling behavior
SELECT daily_batch_seq.NEXTVAL FROM dual;

-- ============================================================================
-- SECTION 2: ADVANCED SEQUENCE CONFIGURATIONS
-- Complex sequence scenarios and business applications
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 2: ADVANCED SEQUENCE CONFIGURATIONS
PROMPT ========================================

-- Example 4: Sequence with step increment
-- Business scenario: Version numbers that increment by 10
CREATE SEQUENCE version_seq
    START WITH 10
    INCREMENT BY 10
    NOCACHE
    NOORDER;

-- Generate version numbers
SELECT 'v' || version_seq.NEXTVAL || '.0' AS version_number FROM dual;
SELECT 'v' || version_seq.NEXTVAL || '.0' AS version_number FROM dual;

-- Example 5: Descending sequence
-- Business scenario: Countdown timer or priority levels
CREATE SEQUENCE priority_seq
    START WITH 100
    INCREMENT BY -1
    MINVALUE 1
    NOCYCLE
    CACHE 10;

-- Generate priority levels
SELECT priority_seq.NEXTVAL AS priority_level FROM dual;

-- Example 6: Large number sequence for global IDs
-- Business scenario: Distributed system unique identifiers
CREATE SEQUENCE global_id_seq
    START WITH 1000000000000
    INCREMENT BY 1
    NOMAXVALUE
    CACHE 100
    ORDER;

-- Generate global IDs
SELECT global_id_seq.NEXTVAL AS global_id FROM dual;

-- ============================================================================
-- SECTION 3: SEQUENCES WITH TABLES
-- Practical implementation in table design
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 3: SEQUENCES WITH TABLES
PROMPT ========================================

-- Example 7: Using sequences in table creation
-- Business scenario: Customer management system

-- Create sequence for customer IDs
CREATE SEQUENCE customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOORDER;

-- Create customers table using the sequence
CREATE TABLE customers_seq_demo (
    customer_id NUMBER DEFAULT customer_id_seq.NEXTVAL PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    email VARCHAR2(100),
    registration_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'ACTIVE'
);

-- Insert data using sequence (implicit)
INSERT INTO customers_seq_demo (customer_name, email)
VALUES ('John Smith', 'john.smith@email.com');

INSERT INTO customers_seq_demo (customer_name, email)
VALUES ('Jane Doe', 'jane.doe@email.com');

-- Insert data using sequence (explicit)
INSERT INTO customers_seq_demo (customer_id, customer_name, email)
VALUES (customer_id_seq.NEXTVAL, 'Bob Johnson', 'bob.johnson@email.com');

-- View the results
SELECT * FROM customers_seq_demo ORDER BY customer_id;

-- Example 8: Multiple sequences for different ID types
-- Business scenario: Order management with different ID patterns

-- Sequence for standard orders
CREATE SEQUENCE std_order_seq
    START WITH 10000
    INCREMENT BY 1
    CACHE 20;

-- Sequence for express orders
CREATE SEQUENCE express_order_seq
    START WITH 90000
    INCREMENT BY 1
    CACHE 10;

-- Orders table with conditional sequence usage
CREATE TABLE orders_demo (
    order_id NUMBER PRIMARY KEY,
    order_type VARCHAR2(20) NOT NULL,
    customer_id NUMBER,
    order_date DATE DEFAULT SYSDATE,
    total_amount NUMBER(10,2)
);

-- Insert orders with appropriate sequences
-- Standard orders
INSERT INTO orders_demo (order_id, order_type, customer_id, total_amount)
VALUES (std_order_seq.NEXTVAL, 'STANDARD', 1, 299.99);

-- Express orders
INSERT INTO orders_demo (order_id, order_type, customer_id, total_amount)
VALUES (express_order_seq.NEXTVAL, 'EXPRESS', 2, 149.99);

SELECT * FROM orders_demo ORDER BY order_id;

-- ============================================================================
-- SECTION 4: BASIC SYNONYMS
-- Creating aliases for database objects
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 4: BASIC SYNONYMS
PROMPT ========================================

-- Example 9: Creating synonyms for tables
-- Business scenario: Simplifying long table names

-- Create a synonym for the customers table
CREATE SYNONYM cust FOR customers_seq_demo;

-- Use the synonym in queries
SELECT * FROM cust WHERE customer_id <= 3;

-- Example 10: Creating synonyms for sequences
-- Business scenario: Standardizing sequence names across applications
CREATE SYNONYM next_customer_id FOR customer_id_seq;

-- Use synonym for sequence
SELECT next_customer_id.NEXTVAL FROM dual;

-- Example 11: Creating synonyms for complex schema objects
-- Business scenario: Cross-schema access simplification

-- Assuming we have objects in different schemas
-- Create synonym for a view (simulated)
CREATE TABLE employee_details AS 
SELECT 1 AS emp_id, 'John Doe' AS emp_name, 'Manager' AS position FROM dual
UNION ALL
SELECT 2, 'Jane Smith', 'Developer' FROM dual;

CREATE SYNONYM emp_info FOR employee_details;

-- Use synonym
SELECT * FROM emp_info;

-- ============================================================================
-- SECTION 5: PUBLIC SYNONYMS
-- Creating database-wide accessible aliases
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 5: PUBLIC SYNONYMS
PROMPT ========================================

-- Example 12: Public synonyms for common lookup tables
-- Business scenario: Company-wide reference data

-- Create a lookup table
CREATE TABLE country_codes (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR2(50),
    region VARCHAR2(30)
);

INSERT INTO country_codes VALUES ('US', 'United States', 'North America');
INSERT INTO country_codes VALUES ('CA', 'Canada', 'North America');
INSERT INTO country_codes VALUES ('UK', 'United Kingdom', 'Europe');
INSERT INTO country_codes VALUES ('DE', 'Germany', 'Europe');

-- Create public synonym (requires DBA privileges in real environment)
-- CREATE PUBLIC SYNONYM countries FOR country_codes;

-- For demonstration, create private synonym
CREATE SYNONYM countries FOR country_codes;

-- Use the synonym
SELECT * FROM countries WHERE region = 'Europe';

-- ============================================================================
-- SECTION 6: SYNONYM MANAGEMENT
-- Managing and maintaining synonyms
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 6: SYNONYM MANAGEMENT
PROMPT ========================================

-- Example 13: Viewing synonym information
-- Business scenario: Database documentation and maintenance

-- Query user synonyms
SELECT 
    synonym_name,
    table_owner,
    table_name,
    db_link
FROM user_synonyms
ORDER BY synonym_name;

-- Example 14: Dropping and recreating synonyms
-- Business scenario: Schema reorganization

-- Drop a synonym
DROP SYNONYM emp_info;

-- Recreate with different target
CREATE SYNONYM emp_info FOR employee_details;

-- ============================================================================
-- SECTION 7: SEQUENCES AND SYNONYMS TOGETHER
-- Combining both concepts in real applications
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 7: SEQUENCES AND SYNONYMS TOGETHER
PROMPT ========================================

-- Example 15: Complete application scenario
-- Business scenario: Product catalog system

-- Create sequence for product IDs
CREATE SEQUENCE product_id_seq
    START WITH 1000
    INCREMENT BY 1
    CACHE 50;

-- Create product table
CREATE TABLE product_catalog (
    product_id NUMBER DEFAULT product_id_seq.NEXTVAL PRIMARY KEY,
    product_code VARCHAR2(20) NOT NULL,
    product_name VARCHAR2(100) NOT NULL,
    category VARCHAR2(50),
    price NUMBER(10,2),
    created_date DATE DEFAULT SYSDATE,
    status VARCHAR2(20) DEFAULT 'ACTIVE'
);

-- Create synonyms for easier access
CREATE SYNONYM products FOR product_catalog;
CREATE SYNONYM next_product_id FOR product_id_seq;

-- Insert products using synonyms
INSERT INTO products (product_code, product_name, category, price)
VALUES ('LAPTOP001', 'Gaming Laptop Pro', 'Electronics', 1299.99);

INSERT INTO products (product_code, product_name, category, price)
VALUES ('MOUSE001', 'Wireless Gaming Mouse', 'Electronics', 79.99);

-- Query using synonym
SELECT 
    product_id,
    product_code,
    product_name,
    price,
    created_date
FROM products
ORDER BY product_id;

-- ============================================================================
-- SECTION 8: PERFORMANCE CONSIDERATIONS
-- Optimizing sequences and synonyms for production
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 8: PERFORMANCE CONSIDERATIONS
PROMPT ========================================

-- Example 16: High-performance sequence configuration
-- Business scenario: High-transaction OLTP system

CREATE SEQUENCE transaction_id_seq
    START WITH 1
    INCREMENT BY 1
    CACHE 1000          -- Large cache for high-volume
    ORDER               -- Ensure order in RAC environment
    NOMAXVALUE;

-- Example 17: Sequence gap analysis
-- Business scenario: Auditing sequence usage

-- Check current sequence values
SELECT 
    sequence_name,
    last_number,
    cache_size,
    increment_by
FROM user_sequences
WHERE sequence_name LIKE '%_SEQ';

-- Calculate potential gaps
SELECT 
    sequence_name,
    last_number,
    cache_size,
    (last_number + cache_size - 1) AS potential_next_cached_value
FROM user_sequences
WHERE cache_size > 0;

-- ============================================================================
-- SECTION 9: TROUBLESHOOTING AND BEST PRACTICES
-- Common issues and solutions
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 9: TROUBLESHOOTING AND BEST PRACTICES
PROMPT ========================================

-- Example 18: Handling sequence exhaustion
-- Business scenario: Monitoring sequence limits

-- Create sequence with low maximum for demonstration
CREATE SEQUENCE demo_limited_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 5
    NOCYCLE
    NOCACHE;

-- Use the sequence
SELECT demo_limited_seq.NEXTVAL FROM dual; -- 1
SELECT demo_limited_seq.NEXTVAL FROM dual; -- 2
SELECT demo_limited_seq.NEXTVAL FROM dual; -- 3

-- Check sequence status
SELECT 
    sequence_name,
    last_number,
    max_value,
    CASE 
        WHEN last_number >= max_value THEN 'EXHAUSTED'
        WHEN last_number > (max_value * 0.9) THEN 'WARNING'
        ELSE 'OK'
    END AS status
FROM user_sequences
WHERE sequence_name = 'DEMO_LIMITED_SEQ';

-- Example 19: Sequence reset and maintenance
-- Business scenario: Annual sequence reset

-- Method 1: Drop and recreate
DROP SEQUENCE daily_batch_seq;
CREATE SEQUENCE daily_batch_seq
    START WITH 1
    INCREMENT BY 1
    MAXVALUE 31
    CYCLE
    CACHE 5;

-- Method 2: Alter sequence (when possible)
ALTER SEQUENCE version_seq RESTART START WITH 100;

-- ============================================================================
-- SECTION 10: REAL-WORLD BUSINESS SCENARIOS
-- Complete examples with business logic
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 10: REAL-WORLD BUSINESS SCENARIOS
PROMPT ========================================

-- Example 20: E-commerce order processing system
-- Business scenario: Complete order management with multiple sequences

-- Customer sequence
CREATE SEQUENCE ecom_customer_seq START WITH 100000 INCREMENT BY 1 CACHE 20;

-- Order sequence  
CREATE SEQUENCE ecom_order_seq START WITH 200000 INCREMENT BY 1 CACHE 50;

-- Invoice sequence
CREATE SEQUENCE ecom_invoice_seq START WITH 300000 INCREMENT BY 1 CACHE 30;

-- Create tables
CREATE TABLE ecom_customers (
    customer_id NUMBER DEFAULT ecom_customer_seq.NEXTVAL PRIMARY KEY,
    email VARCHAR2(100) UNIQUE NOT NULL,
    first_name VARCHAR2(50),
    last_name VARCHAR2(50),
    registration_date DATE DEFAULT SYSDATE
);

CREATE TABLE ecom_orders (
    order_id NUMBER DEFAULT ecom_order_seq.NEXTVAL PRIMARY KEY,
    customer_id NUMBER REFERENCES ecom_customers(customer_id),
    order_date DATE DEFAULT SYSDATE,
    total_amount NUMBER(10,2),
    status VARCHAR2(20) DEFAULT 'PENDING'
);

CREATE TABLE ecom_invoices (
    invoice_id NUMBER DEFAULT ecom_invoice_seq.NEXTVAL PRIMARY KEY,
    order_id NUMBER REFERENCES ecom_orders(order_id),
    invoice_date DATE DEFAULT SYSDATE,
    amount NUMBER(10,2),
    payment_status VARCHAR2(20) DEFAULT 'UNPAID'
);

-- Create synonyms for application layer
CREATE SYNONYM customers FOR ecom_customers;
CREATE SYNONYM orders FOR ecom_orders;
CREATE SYNONYM invoices FOR ecom_invoices;

-- Insert sample data
INSERT INTO customers (email, first_name, last_name)
VALUES ('alice@email.com', 'Alice', 'Johnson');

INSERT INTO customers (email, first_name, last_name)
VALUES ('bob@email.com', 'Bob', 'Williams');

-- Create orders
INSERT INTO orders (customer_id, total_amount)
VALUES (100000, 299.99);

INSERT INTO orders (customer_id, total_amount)
VALUES (100001, 149.50);

-- Create invoices
INSERT INTO invoices (order_id, amount)
VALUES (200000, 299.99);

INSERT INTO invoices (order_id, amount)
VALUES (200001, 149.50);

-- Query the complete system using synonyms
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    o.order_id,
    o.total_amount,
    i.invoice_id,
    i.payment_status
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN invoices i ON o.order_id = i.order_id
ORDER BY c.customer_id;

-- ============================================================================
-- CLEANUP SECTION
-- Clean up objects created during practice
-- ============================================================================

PROMPT ========================================
PROMPT CLEANUP SECTION
PROMPT ========================================

-- Drop tables (this will also drop dependent objects)
DROP TABLE ecom_invoices;
DROP TABLE ecom_orders;
DROP TABLE ecom_customers;
DROP TABLE orders_demo;
DROP TABLE customers_seq_demo;
DROP TABLE product_catalog;
DROP TABLE employee_details;
DROP TABLE country_codes;

-- Drop sequences
DROP SEQUENCE emp_id_seq;
DROP SEQUENCE order_number_seq;
DROP SEQUENCE daily_batch_seq;
DROP SEQUENCE version_seq;
DROP SEQUENCE priority_seq;
DROP SEQUENCE global_id_seq;
DROP SEQUENCE customer_id_seq;
DROP SEQUENCE std_order_seq;
DROP SEQUENCE express_order_seq;
DROP SEQUENCE product_id_seq;
DROP SEQUENCE transaction_id_seq;
DROP SEQUENCE demo_limited_seq;
DROP SEQUENCE ecom_customer_seq;
DROP SEQUENCE ecom_order_seq;
DROP SEQUENCE ecom_invoice_seq;

-- Drop synonyms
DROP SYNONYM cust;
DROP SYNONYM next_customer_id;
DROP SYNONYM emp_info;
DROP SYNONYM countries;
DROP SYNONYM products;
DROP SYNONYM next_product_id;
DROP SYNONYM customers;
DROP SYNONYM orders;
DROP SYNONYM invoices;

PROMPT ========================================
PROMPT SEQUENCES AND SYNONYMS PRACTICE COMPLETE
PROMPT ========================================

/*
================================================================================
LEARNING OBJECTIVES COMPLETED:

1. ✓ Created and managed basic sequences with various configurations
2. ✓ Implemented advanced sequence patterns for business scenarios
3. ✓ Integrated sequences with table design and data insertion
4. ✓ Created and used synonyms for simplifying database access
5. ✓ Implemented public and private synonym strategies
6. ✓ Combined sequences and synonyms in real-world applications
7. ✓ Applied performance optimization techniques
8. ✓ Demonstrated troubleshooting and best practices
9. ✓ Built complete business scenarios with proper sequence/synonym usage
10. ✓ Implemented proper cleanup and maintenance procedures

NEXT STEPS:
- Practice with stored-procedures.sql
- Study functions-packages.sql
- Explore triggers.sql
- Master advanced-plsql.sql
- Learn error-handling.sql

BUSINESS SCENARIOS COVERED:
- Employee ID generation
- Order processing systems
- Version control numbering
- Priority level management
- Global identifier systems
- Customer management
- Product catalog systems
- E-commerce platforms
- High-performance OLTP systems
- Cross-schema access patterns

================================================================================
*/
