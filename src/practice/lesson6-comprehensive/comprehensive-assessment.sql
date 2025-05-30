-- =============================================================================
-- LESSON 6: COMPREHENSIVE PRACTICE AND APPLICATION
-- Skills Assessment and Integration Exercises
-- =============================================================================
-- This file contains comprehensive exercises that integrate all concepts
-- from Lessons 1-5, designed to assess and reinforce your Oracle Database skills.
-- 
-- Instructions:
-- 1. Complete all exercises in order
-- 2. Test each solution thoroughly
-- 3. Document any challenges you encounter
-- 4. Time yourself to gauge proficiency
-- 
-- Estimated completion time: 4-6 hours
-- =============================================================================

-- =============================================================================
-- SECTION 1: DATABASE SETUP AND SAMPLE DATA
-- =============================================================================

-- First, let's create a comprehensive business scenario database
-- This represents a complete e-commerce and inventory management system

-- Drop existing tables if they exist (cleanup)
DROP TABLE order_items CASCADE CONSTRAINTS;
DROP TABLE orders CASCADE CONSTRAINTS;
DROP TABLE products CASCADE CONSTRAINTS;
DROP TABLE categories CASCADE CONSTRAINTS;
DROP TABLE customers CASCADE CONSTRAINTS;
DROP TABLE suppliers CASCADE CONSTRAINTS;
DROP TABLE employees CASCADE CONSTRAINTS;
DROP TABLE departments CASCADE CONSTRAINTS;
DROP TABLE audit_log CASCADE CONSTRAINTS;
DROP SEQUENCE customer_seq;
DROP SEQUENCE order_seq;
DROP SEQUENCE product_seq;
DROP SEQUENCE audit_seq;

-- Create sequences for primary keys
CREATE SEQUENCE customer_seq START WITH 1001 INCREMENT BY 1;
CREATE SEQUENCE order_seq START WITH 5001 INCREMENT BY 1;
CREATE SEQUENCE product_seq START WITH 2001 INCREMENT BY 1;
CREATE SEQUENCE audit_seq START WITH 1 INCREMENT BY 1;

-- =============================================================================
-- DEPARTMENTS TABLE
-- =============================================================================
CREATE TABLE departments (
    department_id NUMBER(4) PRIMARY KEY,
    department_name VARCHAR2(50) NOT NULL UNIQUE,
    manager_id NUMBER(6),
    location_id NUMBER(4),
    created_date DATE DEFAULT SYSDATE,
    status VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- =============================================================================
-- EMPLOYEES TABLE
-- =============================================================================
CREATE TABLE employees (
    employee_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(30) NOT NULL,
    last_name VARCHAR2(30) NOT NULL,
    email VARCHAR2(50) NOT NULL UNIQUE,
    phone_number VARCHAR2(20),
    hire_date DATE NOT NULL,
    job_id VARCHAR2(20) NOT NULL,
    salary NUMBER(8,2) CHECK (salary > 0),
    commission_pct NUMBER(3,2) CHECK (commission_pct BETWEEN 0 AND 1),
    manager_id NUMBER(6),
    department_id NUMBER(4),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT emp_dept_fk FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT emp_mgr_fk FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- Add the manager foreign key to departments after employees table is created
ALTER TABLE departments ADD CONSTRAINT dept_mgr_fk 
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- =============================================================================
-- SUPPLIERS TABLE
-- =============================================================================
CREATE TABLE suppliers (
    supplier_id NUMBER(6) PRIMARY KEY,
    supplier_name VARCHAR2(100) NOT NULL,
    contact_name VARCHAR2(50),
    email VARCHAR2(50),
    phone VARCHAR2(20),
    address VARCHAR2(200),
    city VARCHAR2(50),
    country VARCHAR2(50),
    rating NUMBER(2,1) CHECK (rating BETWEEN 1 AND 5),
    created_date DATE DEFAULT SYSDATE,
    status VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

-- =============================================================================
-- CATEGORIES TABLE
-- =============================================================================
CREATE TABLE categories (
    category_id NUMBER(4) PRIMARY KEY,
    category_name VARCHAR2(50) NOT NULL UNIQUE,
    description VARCHAR2(200),
    parent_category_id NUMBER(4),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT cat_parent_fk FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

-- =============================================================================
-- PRODUCTS TABLE
-- =============================================================================
CREATE TABLE products (
    product_id NUMBER(6) PRIMARY KEY,
    product_name VARCHAR2(100) NOT NULL,
    description CLOB,
    category_id NUMBER(4) NOT NULL,
    supplier_id NUMBER(6) NOT NULL,
    unit_price NUMBER(8,2) NOT NULL CHECK (unit_price > 0),
    units_in_stock NUMBER(6) DEFAULT 0 CHECK (units_in_stock >= 0),
    units_on_order NUMBER(6) DEFAULT 0 CHECK (units_on_order >= 0),
    reorder_level NUMBER(6) DEFAULT 0,
    discontinued VARCHAR2(1) DEFAULT 'N' CHECK (discontinued IN ('Y', 'N')),
    weight NUMBER(5,2),
    dimensions VARCHAR2(50),
    created_date DATE DEFAULT SYSDATE,
    last_updated DATE DEFAULT SYSDATE,
    CONSTRAINT prod_cat_fk FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT prod_supp_fk FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- =============================================================================
-- CUSTOMERS TABLE
-- =============================================================================
CREATE TABLE customers (
    customer_id NUMBER(6) PRIMARY KEY,
    first_name VARCHAR2(30) NOT NULL,
    last_name VARCHAR2(30) NOT NULL,
    email VARCHAR2(50) NOT NULL UNIQUE,
    phone VARCHAR2(20),
    birth_date DATE,
    gender VARCHAR2(1) CHECK (gender IN ('M', 'F')),
    address VARCHAR2(200),
    city VARCHAR2(50),
    state VARCHAR2(50),
    country VARCHAR2(50) DEFAULT 'USA',
    postal_code VARCHAR2(20),
    registration_date DATE DEFAULT SYSDATE,
    last_login_date DATE,
    customer_status VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (customer_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    credit_limit NUMBER(10,2) DEFAULT 1000 CHECK (credit_limit >= 0),
    total_orders NUMBER(6) DEFAULT 0,
    total_spent NUMBER(12,2) DEFAULT 0
);

-- =============================================================================
-- ORDERS TABLE
-- =============================================================================
CREATE TABLE orders (
    order_id NUMBER(8) PRIMARY KEY,
    customer_id NUMBER(6) NOT NULL,
    employee_id NUMBER(6),
    order_date DATE DEFAULT SYSDATE,
    required_date DATE,
    shipped_date DATE,
    ship_via VARCHAR2(50),
    freight NUMBER(8,2) DEFAULT 0,
    ship_name VARCHAR2(50),
    ship_address VARCHAR2(200),
    ship_city VARCHAR2(50),
    ship_state VARCHAR2(50),
    ship_country VARCHAR2(50),
    ship_postal_code VARCHAR2(20),
    order_status VARCHAR2(20) DEFAULT 'PENDING' 
        CHECK (order_status IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    payment_method VARCHAR2(20) DEFAULT 'CREDIT_CARD'
        CHECK (payment_method IN ('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'CASH')),
    subtotal NUMBER(10,2) DEFAULT 0,
    tax_amount NUMBER(8,2) DEFAULT 0,
    total_amount NUMBER(10,2) DEFAULT 0,
    CONSTRAINT ord_cust_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT ord_emp_fk FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    CONSTRAINT ord_dates_chk CHECK (required_date >= order_date),
    CONSTRAINT ord_ship_chk CHECK (shipped_date >= order_date OR shipped_date IS NULL)
);

-- =============================================================================
-- ORDER_ITEMS TABLE
-- =============================================================================
CREATE TABLE order_items (
    order_id NUMBER(8),
    product_id NUMBER(6),
    unit_price NUMBER(8,2) NOT NULL,
    quantity NUMBER(4) NOT NULL CHECK (quantity > 0),
    discount NUMBER(3,2) DEFAULT 0 CHECK (discount BETWEEN 0 AND 1),
    line_total NUMBER(10,2),
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT oi_ord_fk FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT oi_prod_fk FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- =============================================================================
-- AUDIT_LOG TABLE
-- =============================================================================
CREATE TABLE audit_log (
    audit_id NUMBER(10) PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation VARCHAR2(10) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE')),
    record_id VARCHAR2(50) NOT NULL,
    old_values CLOB,
    new_values CLOB,
    changed_by VARCHAR2(50) DEFAULT USER,
    change_date DATE DEFAULT SYSDATE,
    session_id NUMBER DEFAULT SYS_CONTEXT('USERENV', 'SESSIONID')
);

-- =============================================================================
-- SECTION 2: SAMPLE DATA INSERTION
-- =============================================================================

-- Insert Departments
INSERT INTO departments (department_id, department_name, location_id) VALUES 
(10, 'Administration', 1700);
INSERT INTO departments (department_id, department_name, location_id) VALUES 
(20, 'Marketing', 1800);
INSERT INTO departments (department_id, department_name, location_id) VALUES 
(30, 'Purchasing', 1700);
INSERT INTO departments (department_id, department_name, location_id) VALUES 
(40, 'Human Resources', 2400);
INSERT INTO departments (department_id, department_name, location_id) VALUES 
(50, 'Shipping', 1500);
INSERT INTO departments (department_id, department_name, location_id) VALUES 
(60, 'IT', 1400);

-- Insert Employees (Managers first, then other employees)
INSERT INTO employees VALUES 
(100, 'Steven', 'King', 'sking@company.com', '515.123.4567', 
DATE '1987-06-17', 'AD_PRES', 24000, NULL, NULL, 10, SYSDATE);

INSERT INTO employees VALUES 
(101, 'Neena', 'Kochhar', 'nkochhar@company.com', '515.123.4568', 
DATE '1989-09-21', 'AD_VP', 17000, NULL, 100, 10, SYSDATE);

INSERT INTO employees VALUES 
(102, 'Lex', 'De Haan', 'ldehaan@company.com', '515.123.4569', 
DATE '1993-01-13', 'AD_VP', 17000, NULL, 100, 10, SYSDATE);

INSERT INTO employees VALUES 
(103, 'Alexander', 'Hunold', 'ahunold@company.com', '590.423.4567', 
DATE '1990-01-03', 'IT_PROG', 9000, NULL, 102, 60, SYSDATE);

INSERT INTO employees VALUES 
(104, 'Bruce', 'Ernst', 'bernst@company.com', '590.423.4568', 
DATE '1991-05-21', 'IT_PROG', 6000, NULL, 103, 60, SYSDATE);

-- Update departments with manager IDs
UPDATE departments SET manager_id = 100 WHERE department_id = 10;
UPDATE departments SET manager_id = 101 WHERE department_id = 20;
UPDATE departments SET manager_id = 102 WHERE department_id = 60;

-- Insert Suppliers
INSERT INTO suppliers VALUES 
(1, 'Tech Solutions Inc', 'John Smith', 'john@techsolutions.com', 
'555-0101', '123 Tech Street', 'Seattle', 'USA', 4.5, SYSDATE, 'ACTIVE');

INSERT INTO suppliers VALUES 
(2, 'Global Electronics', 'Sarah Johnson', 'sarah@globalelec.com', 
'555-0102', '456 Electronic Ave', 'San Francisco', 'USA', 4.2, SYSDATE, 'ACTIVE');

INSERT INTO suppliers VALUES 
(3, 'Quality Parts Ltd', 'Mike Wilson', 'mike@qualityparts.com', 
'555-0103', '789 Parts Road', 'Chicago', 'USA', 3.8, SYSDATE, 'ACTIVE');

-- Insert Categories
INSERT INTO categories VALUES (1, 'Electronics', 'Electronic devices and accessories', NULL, SYSDATE);
INSERT INTO categories VALUES (2, 'Computers', 'Desktop and laptop computers', 1, SYSDATE);
INSERT INTO categories VALUES (3, 'Mobile Devices', 'Smartphones and tablets', 1, SYSDATE);
INSERT INTO categories VALUES (4, 'Accessories', 'Computer and mobile accessories', 1, SYSDATE);
INSERT INTO categories VALUES (5, 'Software', 'Computer software and applications', NULL, SYSDATE);

-- Insert Products using sequence
INSERT INTO products VALUES 
(product_seq.NEXTVAL, 'Laptop Pro 15"', 'High-performance laptop with 16GB RAM and 512GB SSD', 
2, 1, 1299.99, 50, 0, 10, 'N', 2.5, '15x10x1 inches', SYSDATE, SYSDATE);

INSERT INTO products VALUES 
(product_seq.NEXTVAL, 'Smartphone X', 'Latest smartphone with advanced camera and 5G', 
3, 2, 899.99, 100, 20, 15, 'N', 0.2, '6x3x0.3 inches', SYSDATE, SYSDATE);

INSERT INTO products VALUES 
(product_seq.NEXTVAL, 'Wireless Mouse', 'Ergonomic wireless mouse with precision tracking', 
4, 3, 49.99, 200, 0, 25, 'N', 0.1, '4x2x1 inches', SYSDATE, SYSDATE);

INSERT INTO products VALUES 
(product_seq.NEXTVAL, 'USB-C Cable', 'High-speed USB-C charging and data cable', 
4, 3, 19.99, 500, 0, 50, 'N', 0.05, '3 feet', SYSDATE, SYSDATE);

INSERT INTO products VALUES 
(product_seq.NEXTVAL, 'Tablet Ultra', '10-inch tablet with stylus support', 
3, 2, 599.99, 75, 10, 12, 'N', 0.5, '10x7x0.3 inches', SYSDATE, SYSDATE);

-- Insert Customers using sequence
INSERT INTO customers VALUES 
(customer_seq.NEXTVAL, 'Alice', 'Johnson', 'alice.johnson@email.com', '555-1001', 
DATE '1985-03-15', 'F', '123 Main St', 'Portland', 'OR', 'USA', '97201', 
SYSDATE, SYSDATE, 'ACTIVE', 5000, 0, 0);

INSERT INTO customers VALUES 
(customer_seq.NEXTVAL, 'Bob', 'Smith', 'bob.smith@email.com', '555-1002', 
DATE '1990-07-22', 'M', '456 Oak Ave', 'Seattle', 'WA', 'USA', '98101', 
SYSDATE, SYSDATE, 'ACTIVE', 3000, 0, 0);

INSERT INTO customers VALUES 
(customer_seq.NEXTVAL, 'Carol', 'Williams', 'carol.williams@email.com', '555-1003', 
DATE '1988-11-08', 'F', '789 Pine St', 'San Francisco', 'CA', 'USA', '94101', 
SYSDATE, SYSDATE, 'ACTIVE', 7500, 0, 0);

INSERT INTO customers VALUES 
(customer_seq.NEXTVAL, 'David', 'Brown', 'david.brown@email.com', '555-1004', 
DATE '1975-05-30', 'M', '321 Elm Dr', 'Los Angeles', 'CA', 'USA', '90001', 
SYSDATE, SYSDATE, 'ACTIVE', 4000, 0, 0);

-- Insert Orders using sequence
INSERT INTO orders VALUES 
(order_seq.NEXTVAL, 1001, 103, SYSDATE, SYSDATE + 7, NULL, 'UPS', 25.00,
'Alice Johnson', '123 Main St', 'Portland', 'OR', 'USA', '97201',
'PROCESSING', 'CREDIT_CARD', 0, 0, 0);

INSERT INTO orders VALUES 
(order_seq.NEXTVAL, 1002, 104, SYSDATE - 1, SYSDATE + 6, SYSDATE,
'FedEx', 15.00, 'Bob Smith', '456 Oak Ave', 'Seattle', 'WA', 'USA', '98101',
'SHIPPED', 'PAYPAL', 0, 0, 0);

INSERT INTO orders VALUES 
(order_seq.NEXTVAL, 1003, 103, SYSDATE - 2, SYSDATE + 5, NULL,
'DHL', 30.00, 'Carol Williams', '789 Pine St', 'San Francisco', 'CA', 'USA', '94101',
'PENDING', 'CREDIT_CARD', 0, 0, 0);

-- Insert Order Items
INSERT INTO order_items VALUES (5001, 2001, 1299.99, 1, 0.05, NULL);
INSERT INTO order_items VALUES (5001, 2003, 49.99, 2, 0, NULL);

INSERT INTO order_items VALUES (5002, 2002, 899.99, 1, 0.1, NULL);
INSERT INTO order_items VALUES (5002, 2004, 19.99, 3, 0, NULL);

INSERT INTO order_items VALUES (5003, 2005, 599.99, 1, 0, NULL);
INSERT INTO order_items VALUES (5003, 2003, 49.99, 1, 0, NULL);

COMMIT;

-- =============================================================================
-- SECTION 3: COMPREHENSIVE ASSESSMENT EXERCISES
-- =============================================================================

-- =============================================================================
-- EXERCISE 1: BASIC SQL OPERATIONS (20 points)
-- =============================================================================

PROMPT ============================================================================
PROMPT EXERCISE 1: BASIC SQL OPERATIONS
PROMPT ============================================================================

-- 1.1 Find all customers who registered in the last 30 days with credit limit > 3000
-- Expected: Customer details sorted by registration date
PROMPT 1.1 Recent high-credit customers:

-- YOUR SOLUTION HERE:
-- SELECT customer_id, first_name, last_name, email, registration_date, credit_limit
-- FROM customers
-- WHERE registration_date >= SYSDATE - 30 
--   AND credit_limit > 3000
-- ORDER BY registration_date DESC;

-- 1.2 Update all products in the 'Accessories' category to increase price by 10%
-- Expected: Price increase with proper rounding
PROMPT 1.2 Price update for accessories:

-- YOUR SOLUTION HERE:
-- UPDATE products 
-- SET unit_price = ROUND(unit_price * 1.1, 2),
--     last_updated = SYSDATE
-- WHERE category_id = (SELECT category_id FROM categories WHERE category_name = 'Accessories');

-- 1.3 Insert a new customer with data validation
-- Expected: New customer record with proper constraints
PROMPT 1.3 New customer insertion:

-- YOUR SOLUTION HERE:
-- INSERT INTO customers (
--     customer_id, first_name, last_name, email, phone, birth_date, gender,
--     address, city, state, country, postal_code, credit_limit
-- ) VALUES (
--     customer_seq.NEXTVAL, 'Jane', 'Doe', 'jane.doe@email.com', '555-9999',
--     DATE '1992-08-15', 'F', '999 Test Ave', 'Denver', 'CO', 'USA', '80201', 2500
-- );

-- 1.4 Delete all orders that are cancelled and older than 6 months
-- Expected: Cleanup of old cancelled orders
PROMPT 1.4 Cleanup old cancelled orders:

-- YOUR SOLUTION HERE:
-- DELETE FROM orders 
-- WHERE order_status = 'CANCELLED' 
--   AND order_date < SYSDATE - 180;

-- =============================================================================
-- EXERCISE 2: ADVANCED QUERIES (25 points)
-- =============================================================================

PROMPT ============================================================================
PROMPT EXERCISE 2: ADVANCED QUERIES
PROMPT ============================================================================

-- 2.1 Monthly sales analysis with year-over-year comparison
-- Expected: Monthly totals with previous year comparison
PROMPT 2.1 Monthly sales trends:

-- YOUR SOLUTION HERE:
-- SELECT 
--     TO_CHAR(o.order_date, 'YYYY-MM') as sales_month,
--     SUM(o.total_amount) as current_sales,
--     LAG(SUM(o.total_amount), 12) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM')) as prev_year_sales,
--     ROUND(
--         (SUM(o.total_amount) - LAG(SUM(o.total_amount), 12) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM'))) 
--         / NULLIF(LAG(SUM(o.total_amount), 12) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM')), 0) * 100, 2
--     ) as growth_percentage
-- FROM orders o
-- WHERE o.order_status NOT IN ('CANCELLED')
-- GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
-- ORDER BY sales_month;

-- 2.2 Find customers who have ordered products from every category
-- Expected: Customers with diverse purchasing patterns
PROMPT 2.2 Customers with orders from all categories:

-- YOUR SOLUTION HERE:
-- SELECT c.customer_id, c.first_name, c.last_name, c.email
-- FROM customers c
-- WHERE NOT EXISTS (
--     SELECT cat.category_id
--     FROM categories cat
--     WHERE cat.parent_category_id IS NULL  -- Only top-level categories
--     AND NOT EXISTS (
--         SELECT 1
--         FROM orders o
--         JOIN order_items oi ON o.order_id = oi.order_id
--         JOIN products p ON oi.product_id = p.product_id
--         WHERE o.customer_id = c.customer_id
--         AND p.category_id = cat.category_id
--     )
-- );

-- 2.3 Product performance ranking by category
-- Expected: Best-selling products ranked within each category
PROMPT 2.3 Top products by category:

-- YOUR SOLUTION HERE:
-- SELECT 
--     cat.category_name,
--     p.product_name,
--     SUM(oi.quantity) as total_sold,
--     SUM(oi.line_total) as total_revenue,
--     RANK() OVER (PARTITION BY cat.category_id ORDER BY SUM(oi.quantity) DESC) as sales_rank
-- FROM categories cat
-- JOIN products p ON cat.category_id = p.category_id
-- JOIN order_items oi ON p.product_id = oi.product_id
-- JOIN orders o ON oi.order_id = o.order_id
-- WHERE o.order_status NOT IN ('CANCELLED')
-- GROUP BY cat.category_id, cat.category_name, p.product_id, p.product_name
-- ORDER BY cat.category_name, sales_rank;

-- 2.4 Customer lifetime value calculation
-- Expected: CLV with purchase history analysis
PROMPT 2.4 Customer lifetime value analysis:

-- YOUR SOLUTION HERE:
-- SELECT 
--     c.customer_id,
--     c.first_name || ' ' || c.last_name as customer_name,
--     COUNT(DISTINCT o.order_id) as total_orders,
--     SUM(o.total_amount) as total_spent,
--     AVG(o.total_amount) as avg_order_value,
--     MAX(o.order_date) as last_order_date,
--     TRUNC(SYSDATE - MIN(o.order_date)) as customer_age_days,
--     ROUND(SUM(o.total_amount) / NULLIF(TRUNC(SYSDATE - MIN(o.order_date)), 0), 2) as daily_value
-- FROM customers c
-- LEFT JOIN orders o ON c.customer_id = o.customer_id AND o.order_status NOT IN ('CANCELLED')
-- GROUP BY c.customer_id, c.first_name, c.last_name
-- HAVING COUNT(DISTINCT o.order_id) > 0
-- ORDER BY total_spent DESC;

-- =============================================================================
-- EXERCISE 3: STORED PROCEDURES AND FUNCTIONS (25 points)
-- =============================================================================

PROMPT ============================================================================
PROMPT EXERCISE 3: STORED PROCEDURES AND FUNCTIONS
PROMPT ============================================================================

-- 3.1 Create a procedure to process a complete order
-- Expected: Order creation with inventory management
PROMPT 3.1 Order processing procedure:

CREATE OR REPLACE PROCEDURE process_order (
    p_customer_id IN NUMBER,
    p_employee_id IN NUMBER DEFAULT NULL,
    p_ship_address IN VARCHAR2 DEFAULT NULL,
    p_payment_method IN VARCHAR2 DEFAULT 'CREDIT_CARD',
    p_order_id OUT NUMBER
) AS
    v_credit_available NUMBER;
    v_customer_status VARCHAR2(10);
    insufficient_credit EXCEPTION;
    inactive_customer EXCEPTION;
BEGIN
    -- Validate customer
    SELECT customer_status, credit_limit - total_spent
    INTO v_customer_status, v_credit_available
    FROM customers
    WHERE customer_id = p_customer_id;
    
    IF v_customer_status != 'ACTIVE' THEN
        RAISE inactive_customer;
    END IF;
    
    -- Create order
    SELECT order_seq.NEXTVAL INTO p_order_id FROM DUAL;
    
    INSERT INTO orders (
        order_id, customer_id, employee_id, order_date, required_date,
        ship_address, payment_method, order_status
    ) VALUES (
        p_order_id, p_customer_id, p_employee_id, SYSDATE, SYSDATE + 7,
        NVL(p_ship_address, (SELECT address FROM customers WHERE customer_id = p_customer_id)),
        p_payment_method, 'PENDING'
    );
    
    COMMIT;
    
    DBMS_OUTPUT.PUT_LINE('Order ' || p_order_id || ' created successfully');
    
EXCEPTION
    WHEN inactive_customer THEN
        RAISE_APPLICATION_ERROR(-20001, 'Customer account is not active');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Customer not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'Error processing order: ' || SQLERRM);
END;
/

-- 3.2 Create a function to calculate order total with tax
-- Expected: Accurate total calculation with tax rules
PROMPT 3.2 Order total calculation function:

CREATE OR REPLACE FUNCTION calculate_order_total (
    p_order_id IN NUMBER,
    p_tax_rate IN NUMBER DEFAULT 0.08
) RETURN NUMBER AS
    v_subtotal NUMBER := 0;
    v_tax_amount NUMBER := 0;
    v_total NUMBER := 0;
BEGIN
    -- Calculate subtotal from order items
    SELECT NVL(SUM(oi.unit_price * oi.quantity * (1 - oi.discount)), 0)
    INTO v_subtotal
    FROM order_items oi
    WHERE oi.order_id = p_order_id;
    
    -- Calculate tax
    v_tax_amount := v_subtotal * p_tax_rate;
    v_total := v_subtotal + v_tax_amount;
    
    -- Update order totals
    UPDATE orders
    SET subtotal = v_subtotal,
        tax_amount = v_tax_amount,
        total_amount = v_total
    WHERE order_id = p_order_id;
    
    RETURN v_total;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20003, 'Error calculating order total: ' || SQLERRM);
END;
/

-- 3.3 Create a procedure for inventory management
-- Expected: Stock level management with reorder alerts
PROMPT 3.3 Inventory management procedure:

CREATE OR REPLACE PROCEDURE manage_inventory (
    p_product_id IN NUMBER,
    p_quantity_change IN NUMBER,
    p_operation IN VARCHAR2 -- 'SALE', 'RESTOCK', 'ADJUSTMENT'
) AS
    v_current_stock NUMBER;
    v_reorder_level NUMBER;
    v_product_name VARCHAR2(100);
    insufficient_stock EXCEPTION;
BEGIN
    -- Get current stock information
    SELECT units_in_stock, reorder_level, product_name
    INTO v_current_stock, v_reorder_level, v_product_name
    FROM products
    WHERE product_id = p_product_id;
    
    -- Validate stock for sales
    IF p_operation = 'SALE' AND v_current_stock + p_quantity_change < 0 THEN
        RAISE insufficient_stock;
    END IF;
    
    -- Update stock
    UPDATE products
    SET units_in_stock = units_in_stock + p_quantity_change,
        last_updated = SYSDATE
    WHERE product_id = p_product_id;
    
    -- Check for reorder alert
    IF v_current_stock + p_quantity_change <= v_reorder_level THEN
        DBMS_OUTPUT.PUT_LINE('REORDER ALERT: Product ' || v_product_name || 
                           ' (ID: ' || p_product_id || ') is at or below reorder level');
    END IF;
    
    COMMIT;
    
EXCEPTION
    WHEN insufficient_stock THEN
        RAISE_APPLICATION_ERROR(-20004, 'Insufficient stock for product ID: ' || p_product_id);
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005, 'Product not found: ' || p_product_id);
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20006, 'Error managing inventory: ' || SQLERRM);
END;
/

-- =============================================================================
-- EXERCISE 4: TRIGGERS AND AUTOMATION (15 points)
-- =============================================================================

PROMPT ============================================================================
PROMPT EXERCISE 4: TRIGGERS AND AUTOMATION
PROMPT ============================================================================

-- 4.1 Create trigger for order item line total calculation
-- Expected: Automatic line total calculation on insert/update
PROMPT 4.1 Order item calculation trigger:

CREATE OR REPLACE TRIGGER trg_order_item_total
    BEFORE INSERT OR UPDATE ON order_items
    FOR EACH ROW
BEGIN
    -- Calculate line total
    :NEW.line_total := :NEW.unit_price * :NEW.quantity * (1 - :NEW.discount);
END;
/

-- 4.2 Create trigger for customer statistics maintenance
-- Expected: Automatic customer totals update
PROMPT 4.2 Customer statistics trigger:

CREATE OR REPLACE TRIGGER trg_customer_stats
    AFTER INSERT OR UPDATE OR DELETE ON orders
    FOR EACH ROW
DECLARE
    v_customer_id NUMBER;
BEGIN
    -- Determine which customer to update
    IF INSERTING OR UPDATING THEN
        v_customer_id := :NEW.customer_id;
    ELSE
        v_customer_id := :OLD.customer_id;
    END IF;
    
    -- Update customer statistics
    UPDATE customers
    SET total_orders = (
            SELECT COUNT(*)
            FROM orders
            WHERE customer_id = v_customer_id
            AND order_status NOT IN ('CANCELLED')
        ),
        total_spent = (
            SELECT NVL(SUM(total_amount), 0)
            FROM orders
            WHERE customer_id = v_customer_id
            AND order_status NOT IN ('CANCELLED')
        )
    WHERE customer_id = v_customer_id;
END;
/

-- 4.3 Create audit trigger for sensitive data changes
-- Expected: Complete audit trail for important tables
PROMPT 4.3 Audit trail trigger:

CREATE OR REPLACE TRIGGER trg_audit_customers
    AFTER INSERT OR UPDATE OR DELETE ON customers
    FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
BEGIN
    -- Determine operation
    IF INSERTING THEN
        v_operation := 'INSERT';
        v_new_values := 'ID:' || :NEW.customer_id || '|Name:' || :NEW.first_name || ' ' || :NEW.last_name || 
                       '|Email:' || :NEW.email || '|Credit:' || :NEW.credit_limit;
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
        v_old_values := 'ID:' || :OLD.customer_id || '|Name:' || :OLD.first_name || ' ' || :OLD.last_name || 
                       '|Email:' || :OLD.email || '|Credit:' || :OLD.credit_limit;
        v_new_values := 'ID:' || :NEW.customer_id || '|Name:' || :NEW.first_name || ' ' || :NEW.last_name || 
                       '|Email:' || :NEW.email || '|Credit:' || :NEW.credit_limit;
    ELSE
        v_operation := 'DELETE';
        v_old_values := 'ID:' || :OLD.customer_id || '|Name:' || :OLD.first_name || ' ' || :OLD.last_name || 
                       '|Email:' || :OLD.email || '|Credit:' || :OLD.credit_limit;
    END IF;
    
    -- Insert audit record
    INSERT INTO audit_log (
        audit_id, table_name, operation, record_id, old_values, new_values
    ) VALUES (
        audit_seq.NEXTVAL, 'CUSTOMERS', v_operation, 
        COALESCE(:NEW.customer_id, :OLD.customer_id), v_old_values, v_new_values
    );
END;
/

-- =============================================================================
-- EXERCISE 5: VIEWS AND SECURITY (10 points)
-- =============================================================================

PROMPT ============================================================================
PROMPT EXERCISE 5: VIEWS AND SECURITY
PROMPT ============================================================================

-- 5.1 Create view for customer order summary
-- Expected: Comprehensive customer order information
PROMPT 5.1 Customer order summary view:

CREATE OR REPLACE VIEW vw_customer_order_summary AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.email,
    c.customer_status,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status NOT IN ('CANCELLED') THEN o.total_amount ELSE 0 END) AS total_spent,
    AVG(CASE WHEN o.order_status NOT IN ('CANCELLED') THEN o.total_amount END) AS avg_order_value,
    MAX(o.order_date) AS last_order_date,
    MIN(o.order_date) AS first_order_date,
    c.credit_limit,
    c.credit_limit - c.total_spent AS available_credit
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email, c.customer_status, 
         c.credit_limit, c.total_spent;

-- 5.2 Create view for product sales analytics
-- Expected: Product performance metrics
PROMPT 5.2 Product sales analytics view:

CREATE OR REPLACE VIEW vw_product_analytics AS
SELECT 
    p.product_id,
    p.product_name,
    cat.category_name,
    s.supplier_name,
    p.unit_price,
    p.units_in_stock,
    COALESCE(sales.total_quantity_sold, 0) AS total_sold,
    COALESCE(sales.total_revenue, 0) AS total_revenue,
    COALESCE(sales.avg_selling_price, p.unit_price) AS avg_selling_price,
    p.units_in_stock + COALESCE(sales.total_quantity_sold, 0) AS total_inventory_moved,
    CASE 
        WHEN p.units_in_stock <= p.reorder_level THEN 'REORDER_NEEDED'
        WHEN p.units_in_stock <= p.reorder_level * 2 THEN 'LOW_STOCK'
        ELSE 'ADEQUATE'
    END AS stock_status
FROM products p
JOIN categories cat ON p.category_id = cat.category_id
JOIN suppliers s ON p.supplier_id = s.supplier_id
LEFT JOIN (
    SELECT 
        oi.product_id,
        SUM(oi.quantity) AS total_quantity_sold,
        SUM(oi.line_total) AS total_revenue,
        AVG(oi.unit_price) AS avg_selling_price
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status NOT IN ('CANCELLED')
    GROUP BY oi.product_id
) sales ON p.product_id = sales.product_id;

-- =============================================================================
-- EXERCISE 6: PERFORMANCE OPTIMIZATION (5 points)
-- =============================================================================

PROMPT ============================================================================
PROMPT EXERCISE 6: PERFORMANCE OPTIMIZATION
PROMPT ============================================================================

-- 6.1 Create strategic indexes for performance
-- Expected: Indexes based on query patterns
PROMPT 6.1 Creating performance indexes:

-- Index for customer lookup by email (unique searches)
CREATE INDEX idx_customers_email ON customers(email);

-- Index for order date range queries
CREATE INDEX idx_orders_date_status ON orders(order_date, order_status);

-- Index for product category and price range queries
CREATE INDEX idx_products_cat_price ON products(category_id, unit_price);

-- Index for order items product lookup
CREATE INDEX idx_order_items_product ON order_items(product_id);

-- Composite index for customer order analysis
CREATE INDEX idx_orders_cust_date ON orders(customer_id, order_date);

-- 6.2 Analyze table statistics for optimizer
-- Expected: Current table statistics for CBO
PROMPT 6.2 Gathering table statistics:

EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'CUSTOMERS');
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'ORDERS');
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'ORDER_ITEMS');
EXEC DBMS_STATS.GATHER_TABLE_STATS(USER, 'PRODUCTS');

-- =============================================================================
-- SECTION 4: INTEGRATION TESTING AND VALIDATION
-- =============================================================================

PROMPT ============================================================================
PROMPT SECTION 4: INTEGRATION TESTING
PROMPT ============================================================================

-- Test the complete system with realistic scenarios
PROMPT Testing complete order processing workflow:

DECLARE
    v_order_id NUMBER;
    v_total NUMBER;
BEGIN
    -- Test order processing
    process_order(
        p_customer_id => 1001,
        p_employee_id => 103,
        p_payment_method => 'CREDIT_CARD',
        p_order_id => v_order_id
    );
    
    -- Add items to order
    INSERT INTO order_items (order_id, product_id, unit_price, quantity, discount)
    VALUES (v_order_id, 2001, 1299.99, 1, 0.05);
    
    INSERT INTO order_items (order_id, product_id, unit_price, quantity, discount)
    VALUES (v_order_id, 2003, 49.99, 2, 0);
    
    -- Calculate and update totals
    v_total := calculate_order_total(v_order_id, 0.08);
    
    -- Update inventory
    manage_inventory(2001, -1, 'SALE');
    manage_inventory(2003, -2, 'SALE');
    
    DBMS_OUTPUT.PUT_LINE('Order processing completed successfully');
    DBMS_OUTPUT.PUT_LINE('Order ID: ' || v_order_id || ', Total: $' || v_total);
    
    COMMIT;
END;
/

-- Test data validation and views
PROMPT Testing views and data integrity:

SELECT 'Customer Order Summary' AS test_type FROM DUAL;
SELECT * FROM vw_customer_order_summary WHERE total_orders > 0;

SELECT 'Product Analytics' AS test_type FROM DUAL;
SELECT * FROM vw_product_analytics WHERE total_sold > 0;

SELECT 'Audit Trail' AS test_type FROM DUAL;
SELECT table_name, operation, COUNT(*) as operation_count
FROM audit_log
GROUP BY table_name, operation
ORDER BY table_name, operation;

-- =============================================================================
-- SECTION 5: FINAL ASSESSMENT SUMMARY
-- =============================================================================

PROMPT ============================================================================
PROMPT FINAL ASSESSMENT SUMMARY
PROMPT ============================================================================

PROMPT Assessment completed! Please review your solutions and compare with expected results.
PROMPT 
PROMPT Key areas covered:
PROMPT - Database design and normalization
PROMPT - Complex SQL queries and joins
PROMPT - Stored procedures and functions
PROMPT - Triggers and automation
PROMPT - Views and security
PROMPT - Performance optimization
PROMPT - Error handling and validation
PROMPT - Integration testing
PROMPT 
PROMPT Next steps:
PROMPT 1. Review any areas where you struggled
PROMPT 2. Practice additional exercises in weak areas
PROMPT 3. Proceed to real-world projects
PROMPT 4. Consider Oracle certification preparation
PROMPT 
PROMPT Congratulations on completing the comprehensive assessment!

-- =============================================================================
-- END OF COMPREHENSIVE PRACTICE FILE
-- =============================================================================
