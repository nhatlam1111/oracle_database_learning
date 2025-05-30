/*
================================================================================
ORACLE DATABASE LEARNING PROJECT
Lesson 5: Advanced SQL Techniques
File: functions-packages.sql
Topic: Functions and Packages Practice Exercises

Description: Comprehensive practice file covering Oracle functions (scalar, table,
             aggregate), package specifications and bodies, built-in functions,
             and advanced package features.

Author: Oracle Learning Project
Date: May 2025
================================================================================
*/

-- ============================================================================
-- SECTION 1: SCALAR FUNCTIONS
-- Functions that return single values
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 1: SCALAR FUNCTIONS
PROMPT ========================================

-- Example 1: Simple scalar function
-- Business scenario: Calculate tax amount
CREATE OR REPLACE FUNCTION calculate_tax(
    p_amount IN NUMBER,
    p_tax_rate IN NUMBER DEFAULT 0.08
) RETURN NUMBER
IS
    v_tax_amount NUMBER;
BEGIN
    -- Input validation
    IF p_amount < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Amount cannot be negative');
    END IF;
    
    IF p_tax_rate < 0 OR p_tax_rate > 1 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Tax rate must be between 0 and 1');
    END IF;
    
    v_tax_amount := p_amount * p_tax_rate;
    RETURN ROUND(v_tax_amount, 2);
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 'Error calculating tax: ' || SQLERRM);
END calculate_tax;
/

-- Test the tax function
SELECT 
    100 AS amount,
    calculate_tax(100) AS tax_8_percent,
    calculate_tax(100, 0.10) AS tax_10_percent,
    100 + calculate_tax(100) AS total_with_tax
FROM dual;

-- Example 2: String manipulation function
-- Business scenario: Format customer names
CREATE OR REPLACE FUNCTION format_customer_name(
    p_first_name IN VARCHAR2,
    p_last_name IN VARCHAR2,
    p_format_type IN VARCHAR2 DEFAULT 'FULL'
) RETURN VARCHAR2
IS
    v_formatted_name VARCHAR2(200);
BEGIN
    -- Handle NULL inputs
    IF p_first_name IS NULL AND p_last_name IS NULL THEN
        RETURN 'Unknown Customer';
    END IF;
    
    CASE UPPER(p_format_type)
        WHEN 'FULL' THEN
            v_formatted_name := TRIM(NVL(p_first_name, '') || ' ' || NVL(p_last_name, ''));
        WHEN 'LAST_FIRST' THEN
            v_formatted_name := NVL(p_last_name, '') || ', ' || NVL(p_first_name, '');
        WHEN 'INITIALS' THEN
            v_formatted_name := NVL(SUBSTR(p_first_name, 1, 1), '') || 
                               NVL(SUBSTR(p_last_name, 1, 1), '');
        WHEN 'FORMAL' THEN
            v_formatted_name := 'Mr./Ms. ' || TRIM(NVL(p_first_name, '') || ' ' || NVL(p_last_name, ''));
        ELSE
            v_formatted_name := TRIM(NVL(p_first_name, '') || ' ' || NVL(p_last_name, ''));
    END CASE;
    
    RETURN v_formatted_name;
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error formatting name';
END format_customer_name;
/

-- Test the name formatting function
SELECT 
    format_customer_name('John', 'Smith') AS full_name,
    format_customer_name('John', 'Smith', 'LAST_FIRST') AS last_first,
    format_customer_name('John', 'Smith', 'INITIALS') AS initials,
    format_customer_name('John', 'Smith', 'FORMAL') AS formal,
    format_customer_name(NULL, 'Smith') AS partial_name
FROM dual;

-- Example 3: Date manipulation function
-- Business scenario: Calculate business days between dates
CREATE OR REPLACE FUNCTION calculate_business_days(
    p_start_date IN DATE,
    p_end_date IN DATE,
    p_exclude_holidays IN BOOLEAN DEFAULT FALSE
) RETURN NUMBER
IS
    v_business_days NUMBER := 0;
    v_current_date DATE;
    v_day_of_week NUMBER;
    
    TYPE t_holiday_array IS TABLE OF DATE;
    v_holidays t_holiday_array;
    v_is_holiday BOOLEAN;
BEGIN
    -- Input validation
    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        RAISE_APPLICATION_ERROR(-20003, 'Start and end dates cannot be NULL');
    END IF;
    
    IF p_start_date > p_end_date THEN
        RAISE_APPLICATION_ERROR(-20004, 'Start date cannot be after end date');
    END IF;
    
    -- Initialize common holidays for current year
    IF p_exclude_holidays THEN
        v_holidays := t_holiday_array(
            DATE '2025-01-01',  -- New Year's Day
            DATE '2025-07-04',  -- Independence Day
            DATE '2025-12-25'   -- Christmas Day
        );
    END IF;
    
    v_current_date := p_start_date;
    
    WHILE v_current_date <= p_end_date LOOP
        -- Get day of week (1=Sunday, 2=Monday, ..., 7=Saturday)
        v_day_of_week := TO_NUMBER(TO_CHAR(v_current_date, 'D'));
        
        -- Check if it's a weekend (Sunday=1 or Saturday=7)
        IF v_day_of_week NOT IN (1, 7) THEN
            v_is_holiday := FALSE;
            
            -- Check if it's a holiday
            IF p_exclude_holidays AND v_holidays IS NOT NULL THEN
                FOR i IN 1..v_holidays.COUNT LOOP
                    IF v_current_date = v_holidays(i) THEN
                        v_is_holiday := TRUE;
                        EXIT;
                    END IF;
                END LOOP;
            END IF;
            
            -- Count as business day if not a holiday
            IF NOT v_is_holiday THEN
                v_business_days := v_business_days + 1;
            END IF;
        END IF;
        
        v_current_date := v_current_date + 1;
    END LOOP;
    
    RETURN v_business_days;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20999, 'Error calculating business days: ' || SQLERRM);
END calculate_business_days;
/

-- Test the business days function
SELECT 
    DATE '2025-05-01' AS start_date,
    DATE '2025-05-15' AS end_date,
    calculate_business_days(DATE '2025-05-01', DATE '2025-05-15') AS business_days,
    calculate_business_days(DATE '2025-05-01', DATE '2025-05-15', TRUE) AS business_days_no_holidays
FROM dual;

-- ============================================================================
-- SECTION 2: TABLE FUNCTIONS
-- Functions that return collections/result sets
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 2: TABLE FUNCTIONS
PROMPT ========================================

-- Example 4: Table function returning a collection
-- Business scenario: Generate date range for reporting

-- First, create object types for the table function
CREATE OR REPLACE TYPE t_date_range_row AS OBJECT (
    date_value DATE,
    day_name VARCHAR2(20),
    is_weekend VARCHAR2(1),
    is_business_day VARCHAR2(1)
);
/

CREATE OR REPLACE TYPE t_date_range_table AS TABLE OF t_date_range_row;
/

-- Create the table function
CREATE OR REPLACE FUNCTION generate_date_range(
    p_start_date IN DATE,
    p_end_date IN DATE
) RETURN t_date_range_table PIPELINED
IS
    v_current_date DATE;
    v_day_of_week NUMBER;
    v_is_weekend VARCHAR2(1);
    v_is_business_day VARCHAR2(1);
BEGIN
    v_current_date := p_start_date;
    
    WHILE v_current_date <= p_end_date LOOP
        v_day_of_week := TO_NUMBER(TO_CHAR(v_current_date, 'D'));
        
        IF v_day_of_week IN (1, 7) THEN  -- Sunday or Saturday
            v_is_weekend := 'Y';
            v_is_business_day := 'N';
        ELSE
            v_is_weekend := 'N';
            v_is_business_day := 'Y';
        END IF;
        
        PIPE ROW(t_date_range_row(
            v_current_date,
            TO_CHAR(v_current_date, 'Day'),
            v_is_weekend,
            v_is_business_day
        ));
        
        v_current_date := v_current_date + 1;
    END LOOP;
    
    RETURN;
END generate_date_range;
/

-- Test the table function
SELECT * FROM TABLE(generate_date_range(DATE '2025-05-01', DATE '2025-05-10'))
ORDER BY date_value;

-- Example 5: More complex table function
-- Business scenario: Sales performance analysis
CREATE OR REPLACE TYPE t_sales_summary_row AS OBJECT (
    period_name VARCHAR2(20),
    total_sales NUMBER,
    avg_sales NUMBER,
    performance_rating VARCHAR2(20)
);
/

CREATE OR REPLACE TYPE t_sales_summary_table AS TABLE OF t_sales_summary_row;
/

CREATE OR REPLACE FUNCTION analyze_sales_performance(
    p_sales_data IN VARCHAR2  -- Comma-separated sales figures
) RETURN t_sales_summary_table PIPELINED
IS
    v_sales_array DBMS_SQL.VARCHAR2_TABLE;
    v_total_sales NUMBER := 0;
    v_avg_sales NUMBER;
    v_count NUMBER := 0;
    v_rating VARCHAR2(20);
BEGIN
    -- Parse the comma-separated sales data
    SELECT REGEXP_COUNT(p_sales_data, ',') + 1 INTO v_count FROM dual;
    
    FOR i IN 1..v_count LOOP
        v_sales_array(i) := TO_NUMBER(TRIM(REGEXP_SUBSTR(p_sales_data, '[^,]+', 1, i)));
        v_total_sales := v_total_sales + v_sales_array(i);
    END LOOP;
    
    v_avg_sales := v_total_sales / v_count;
    
    -- Determine overall performance rating
    IF v_avg_sales >= 10000 THEN
        v_rating := 'EXCELLENT';
    ELSIF v_avg_sales >= 7500 THEN
        v_rating := 'GOOD';
    ELSIF v_avg_sales >= 5000 THEN
        v_rating := 'AVERAGE';
    ELSE
        v_rating := 'POOR';
    END IF;
    
    -- Return overall summary
    PIPE ROW(t_sales_summary_row(
        'OVERALL',
        v_total_sales,
        v_avg_sales,
        v_rating
    ));
    
    -- Return individual period analysis
    FOR i IN 1..v_count LOOP
        IF v_sales_array(i) >= v_avg_sales * 1.2 THEN
            v_rating := 'ABOVE_AVERAGE';
        ELSIF v_sales_array(i) >= v_avg_sales * 0.8 THEN
            v_rating := 'AVERAGE';
        ELSE
            v_rating := 'BELOW_AVERAGE';
        END IF;
        
        PIPE ROW(t_sales_summary_row(
            'PERIOD_' || i,
            v_sales_array(i),
            v_avg_sales,
            v_rating
        ));
    END LOOP;
    
    RETURN;
END analyze_sales_performance;
/

-- Test the sales analysis function
SELECT * FROM TABLE(analyze_sales_performance('8500,12000,6700,9800,11200,7300'))
ORDER BY period_name;

-- ============================================================================
-- SECTION 3: BASIC PACKAGES
-- Package specifications and bodies
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 3: BASIC PACKAGES
PROMPT ========================================

-- Example 6: Basic utility package
-- Business scenario: Math and string utilities

-- Package specification
CREATE OR REPLACE PACKAGE math_utils AS
    -- Constants
    c_pi CONSTANT NUMBER := 3.14159265359;
    c_e CONSTANT NUMBER := 2.71828182846;
    
    -- Public functions
    FUNCTION factorial(p_number IN NUMBER) RETURN NUMBER;
    FUNCTION power_of(p_base IN NUMBER, p_exponent IN NUMBER) RETURN NUMBER;
    FUNCTION is_prime(p_number IN NUMBER) RETURN BOOLEAN;
    FUNCTION greatest_common_divisor(p_a IN NUMBER, p_b IN NUMBER) RETURN NUMBER;
    
    -- Public procedures
    PROCEDURE display_number_info(p_number IN NUMBER);
    
END math_utils;
/

-- Package body
CREATE OR REPLACE PACKAGE BODY math_utils AS

    -- Private function (not in specification)
    FUNCTION is_perfect_square(p_number IN NUMBER) RETURN BOOLEAN IS
        v_sqrt NUMBER;
    BEGIN
        v_sqrt := SQRT(p_number);
        RETURN (v_sqrt = TRUNC(v_sqrt));
    END is_perfect_square;

    -- Implementation of factorial function
    FUNCTION factorial(p_number IN NUMBER) RETURN NUMBER IS
        v_result NUMBER := 1;
    BEGIN
        IF p_number < 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Factorial not defined for negative numbers');
        END IF;
        
        IF p_number = 0 OR p_number = 1 THEN
            RETURN 1;
        END IF;
        
        FOR i IN 2..p_number LOOP
            v_result := v_result * i;
        END LOOP;
        
        RETURN v_result;
    END factorial;
    
    -- Implementation of power function
    FUNCTION power_of(p_base IN NUMBER, p_exponent IN NUMBER) RETURN NUMBER IS
        v_result NUMBER := 1;
    BEGIN
        IF p_exponent = 0 THEN
            RETURN 1;
        END IF;
        
        IF p_exponent > 0 THEN
            FOR i IN 1..p_exponent LOOP
                v_result := v_result * p_base;
            END LOOP;
        ELSE
            v_result := 1 / power_of(p_base, ABS(p_exponent));
        END IF;
        
        RETURN v_result;
    END power_of;
    
    -- Implementation of prime check
    FUNCTION is_prime(p_number IN NUMBER) RETURN BOOLEAN IS
        v_sqrt NUMBER;
    BEGIN
        IF p_number <= 1 THEN
            RETURN FALSE;
        END IF;
        
        IF p_number <= 3 THEN
            RETURN TRUE;
        END IF;
        
        IF MOD(p_number, 2) = 0 OR MOD(p_number, 3) = 0 THEN
            RETURN FALSE;
        END IF;
        
        v_sqrt := SQRT(p_number);
        FOR i IN 5..v_sqrt LOOP
            IF MOD(p_number, i) = 0 THEN
                RETURN FALSE;
            END IF;
        END LOOP;
        
        RETURN TRUE;
    END is_prime;
    
    -- Implementation of GCD
    FUNCTION greatest_common_divisor(p_a IN NUMBER, p_b IN NUMBER) RETURN NUMBER IS
        v_a NUMBER := ABS(p_a);
        v_b NUMBER := ABS(p_b);
        v_temp NUMBER;
    BEGIN
        WHILE v_b != 0 LOOP
            v_temp := v_b;
            v_b := MOD(v_a, v_b);
            v_a := v_temp;
        END LOOP;
        
        RETURN v_a;
    END greatest_common_divisor;
    
    -- Implementation of display procedure
    PROCEDURE display_number_info(p_number IN NUMBER) IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== NUMBER ANALYSIS: ' || p_number || ' ===');
        DBMS_OUTPUT.PUT_LINE('Factorial: ' || factorial(p_number));
        DBMS_OUTPUT.PUT_LINE('Is Prime: ' || CASE WHEN is_prime(p_number) THEN 'YES' ELSE 'NO' END);
        DBMS_OUTPUT.PUT_LINE('Is Perfect Square: ' || CASE WHEN is_perfect_square(p_number) THEN 'YES' ELSE 'NO' END);
        DBMS_OUTPUT.PUT_LINE('Square: ' || power_of(p_number, 2));
        DBMS_OUTPUT.PUT_LINE('Square Root: ' || ROUND(SQRT(p_number), 4));
        DBMS_OUTPUT.PUT_LINE('');
    END display_number_info;
    
END math_utils;
/

-- Test the math utilities package
BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    
    -- Test individual functions
    DBMS_OUTPUT.PUT_LINE('Pi constant: ' || math_utils.c_pi);
    DBMS_OUTPUT.PUT_LINE('5! = ' || math_utils.factorial(5));
    DBMS_OUTPUT.PUT_LINE('2^10 = ' || math_utils.power_of(2, 10));
    DBMS_OUTPUT.PUT_LINE('GCD(48, 18) = ' || math_utils.greatest_common_divisor(48, 18));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test display procedure
    math_utils.display_number_info(7);
    math_utils.display_number_info(16);
END;
/

-- ============================================================================
-- SECTION 4: ADVANCED PACKAGES
-- Complex packages with state management
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 4: ADVANCED PACKAGES
PROMPT ========================================

-- Example 7: Advanced package with state management
-- Business scenario: Shopping cart management system

-- Package specification
CREATE OR REPLACE PACKAGE shopping_cart AS
    -- Types
    TYPE t_cart_item IS RECORD (
        product_id VARCHAR2(20),
        product_name VARCHAR2(100),
        unit_price NUMBER,
        quantity NUMBER,
        total_price NUMBER
    );
    
    TYPE t_cart_items IS TABLE OF t_cart_item INDEX BY VARCHAR2(20);
    
    -- Constants
    c_max_items CONSTANT NUMBER := 50;
    c_tax_rate CONSTANT NUMBER := 0.08;
    
    -- Exception
    cart_full EXCEPTION;
    item_not_found EXCEPTION;
    
    -- Public procedures and functions
    PROCEDURE add_item(
        p_product_id IN VARCHAR2,
        p_product_name IN VARCHAR2,
        p_unit_price IN NUMBER,
        p_quantity IN NUMBER DEFAULT 1
    );
    
    PROCEDURE remove_item(p_product_id IN VARCHAR2);
    PROCEDURE update_quantity(p_product_id IN VARCHAR2, p_new_quantity IN NUMBER);
    PROCEDURE clear_cart;
    
    FUNCTION get_item_count RETURN NUMBER;
    FUNCTION get_subtotal RETURN NUMBER;
    FUNCTION get_tax_amount RETURN NUMBER;
    FUNCTION get_total RETURN NUMBER;
    FUNCTION item_exists(p_product_id IN VARCHAR2) RETURN BOOLEAN;
    
    PROCEDURE display_cart;
    PROCEDURE checkout(
        p_customer_id IN NUMBER,
        p_order_id OUT NUMBER,
        p_total_amount OUT NUMBER
    );
    
END shopping_cart;
/

-- Package body
CREATE OR REPLACE PACKAGE BODY shopping_cart AS
    -- Private package variables (state)
    g_cart_items t_cart_items;
    g_item_count NUMBER := 0;
    
    -- Private procedures/functions
    FUNCTION calculate_item_total(p_unit_price IN NUMBER, p_quantity IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_unit_price * p_quantity;
    END calculate_item_total;
    
    -- Public procedure implementations
    PROCEDURE add_item(
        p_product_id IN VARCHAR2,
        p_product_name IN VARCHAR2,
        p_unit_price IN NUMBER,
        p_quantity IN NUMBER DEFAULT 1
    ) IS
        v_item t_cart_item;
    BEGIN
        -- Check if cart is full
        IF g_item_count >= c_max_items THEN
            RAISE cart_full;
        END IF;
        
        -- Input validation
        IF p_product_id IS NULL OR p_unit_price <= 0 OR p_quantity <= 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid item parameters');
        END IF;
        
        -- Check if item already exists
        IF g_cart_items.EXISTS(p_product_id) THEN
            -- Update existing item quantity
            g_cart_items(p_product_id).quantity := g_cart_items(p_product_id).quantity + p_quantity;
            g_cart_items(p_product_id).total_price := calculate_item_total(
                g_cart_items(p_product_id).unit_price,
                g_cart_items(p_product_id).quantity
            );
        ELSE
            -- Add new item
            v_item.product_id := p_product_id;
            v_item.product_name := p_product_name;
            v_item.unit_price := p_unit_price;
            v_item.quantity := p_quantity;
            v_item.total_price := calculate_item_total(p_unit_price, p_quantity);
            
            g_cart_items(p_product_id) := v_item;
            g_item_count := g_item_count + 1;
        END IF;
        
    EXCEPTION
        WHEN cart_full THEN
            RAISE_APPLICATION_ERROR(-20002, 'Shopping cart is full. Maximum ' || c_max_items || ' items allowed.');
    END add_item;
    
    PROCEDURE remove_item(p_product_id IN VARCHAR2) IS
    BEGIN
        IF NOT g_cart_items.EXISTS(p_product_id) THEN
            RAISE item_not_found;
        END IF;
        
        g_cart_items.DELETE(p_product_id);
        g_item_count := g_item_count - 1;
        
    EXCEPTION
        WHEN item_not_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Item not found in cart: ' || p_product_id);
    END remove_item;
    
    PROCEDURE update_quantity(p_product_id IN VARCHAR2, p_new_quantity IN NUMBER) IS
    BEGIN
        IF NOT g_cart_items.EXISTS(p_product_id) THEN
            RAISE item_not_found;
        END IF;
        
        IF p_new_quantity <= 0 THEN
            remove_item(p_product_id);
        ELSE
            g_cart_items(p_product_id).quantity := p_new_quantity;
            g_cart_items(p_product_id).total_price := calculate_item_total(
                g_cart_items(p_product_id).unit_price,
                p_new_quantity
            );
        END IF;
        
    EXCEPTION
        WHEN item_not_found THEN
            RAISE_APPLICATION_ERROR(-20003, 'Item not found in cart: ' || p_product_id);
    END update_quantity;
    
    PROCEDURE clear_cart IS
    BEGIN
        g_cart_items.DELETE;
        g_item_count := 0;
    END clear_cart;
    
    FUNCTION get_item_count RETURN NUMBER IS
    BEGIN
        RETURN g_item_count;
    END get_item_count;
    
    FUNCTION get_subtotal RETURN NUMBER IS
        v_subtotal NUMBER := 0;
        v_product_id VARCHAR2(20);
    BEGIN
        v_product_id := g_cart_items.FIRST;
        WHILE v_product_id IS NOT NULL LOOP
            v_subtotal := v_subtotal + g_cart_items(v_product_id).total_price;
            v_product_id := g_cart_items.NEXT(v_product_id);
        END LOOP;
        
        RETURN v_subtotal;
    END get_subtotal;
    
    FUNCTION get_tax_amount RETURN NUMBER IS
    BEGIN
        RETURN get_subtotal * c_tax_rate;
    END get_tax_amount;
    
    FUNCTION get_total RETURN NUMBER IS
    BEGIN
        RETURN get_subtotal + get_tax_amount;
    END get_total;
    
    FUNCTION item_exists(p_product_id IN VARCHAR2) RETURN BOOLEAN IS
    BEGIN
        RETURN g_cart_items.EXISTS(p_product_id);
    END item_exists;
    
    PROCEDURE display_cart IS
        v_product_id VARCHAR2(20);
        v_item t_cart_item;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('=== SHOPPING CART ===');
        
        IF g_item_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Cart is empty');
            RETURN;
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('Items: ' || g_item_count);
        DBMS_OUTPUT.PUT_LINE('');
        
        v_product_id := g_cart_items.FIRST;
        WHILE v_product_id IS NOT NULL LOOP
            v_item := g_cart_items(v_product_id);
            DBMS_OUTPUT.PUT_LINE(v_item.product_name || ' (' || v_item.product_id || ')');
            DBMS_OUTPUT.PUT_LINE('  Qty: ' || v_item.quantity || 
                               ' x $' || TO_CHAR(v_item.unit_price, '999.99') ||
                               ' = $' || TO_CHAR(v_item.total_price, '9,999.99'));
            v_product_id := g_cart_items.NEXT(v_product_id);
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Subtotal: $' || TO_CHAR(get_subtotal, '9,999.99'));
        DBMS_OUTPUT.PUT_LINE('Tax (' || (c_tax_rate * 100) || '%): $' || TO_CHAR(get_tax_amount, '9,999.99'));
        DBMS_OUTPUT.PUT_LINE('TOTAL: $' || TO_CHAR(get_total, '9,999.99'));
        DBMS_OUTPUT.PUT_LINE('');
    END display_cart;
    
    PROCEDURE checkout(
        p_customer_id IN NUMBER,
        p_order_id OUT NUMBER,
        p_total_amount OUT NUMBER
    ) IS
    BEGIN
        IF g_item_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'Cannot checkout empty cart');
        END IF;
        
        -- Generate order ID
        SELECT TO_NUMBER(TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS')) INTO p_order_id FROM dual;
        p_total_amount := get_total;
        
        DBMS_OUTPUT.PUT_LINE('=== CHECKOUT COMPLETED ===');
        DBMS_OUTPUT.PUT_LINE('Customer ID: ' || p_customer_id);
        DBMS_OUTPUT.PUT_LINE('Order ID: ' || p_order_id);
        DBMS_OUTPUT.PUT_LINE('Total Amount: $' || TO_CHAR(p_total_amount, '9,999.99'));
        
        -- Clear cart after checkout
        clear_cart;
    END checkout;
    
END shopping_cart;
/

-- Test the shopping cart package
DECLARE
    v_order_id NUMBER;
    v_total NUMBER;
BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    
    -- Test adding items
    shopping_cart.add_item('LAPTOP001', 'Gaming Laptop Pro', 1299.99, 1);
    shopping_cart.add_item('MOUSE001', 'Wireless Gaming Mouse', 79.99, 2);
    shopping_cart.add_item('KEYBOARD001', 'Mechanical Keyboard', 149.99, 1);
    
    -- Display cart
    shopping_cart.display_cart;
    
    -- Update quantity
    shopping_cart.update_quantity('MOUSE001', 3);
    DBMS_OUTPUT.PUT_LINE('After updating mouse quantity to 3:');
    shopping_cart.display_cart;
    
    -- Remove item
    shopping_cart.remove_item('KEYBOARD001');
    DBMS_OUTPUT.PUT_LINE('After removing keyboard:');
    shopping_cart.display_cart;
    
    -- Checkout
    shopping_cart.checkout(1001, v_order_id, v_total);
    
    -- Display empty cart
    shopping_cart.display_cart;
END;
/

-- ============================================================================
-- SECTION 5: BUILT-IN FUNCTIONS USAGE
-- Demonstrating Oracle's built-in functions
-- ============================================================================

PROMPT ========================================
PROMPT SECTION 5: BUILT-IN FUNCTIONS USAGE
PROMPT ========================================

-- Example 8: Comprehensive built-in functions demonstration
-- Business scenario: Data analysis and reporting functions
CREATE OR REPLACE FUNCTION demonstrate_builtin_functions RETURN VARCHAR2
IS
    v_result CLOB := '';
    v_sample_date DATE := SYSDATE;
    v_sample_string VARCHAR2(100) := '  Oracle Database 21c  ';
    v_sample_number NUMBER := 12345.6789;
BEGIN
    v_result := v_result || '=== ORACLE BUILT-IN FUNCTIONS DEMO ===' || CHR(10);
    v_result := v_result || CHR(10);
    
    -- String Functions
    v_result := v_result || '--- STRING FUNCTIONS ---' || CHR(10);
    v_result := v_result || 'Original: "' || v_sample_string || '"' || CHR(10);
    v_result := v_result || 'TRIM: "' || TRIM(v_sample_string) || '"' || CHR(10);
    v_result := v_result || 'UPPER: "' || UPPER(v_sample_string) || '"' || CHR(10);
    v_result := v_result || 'LOWER: "' || LOWER(v_sample_string) || '"' || CHR(10);
    v_result := v_result || 'INITCAP: "' || INITCAP(v_sample_string) || '"' || CHR(10);
    v_result := v_result || 'LENGTH: ' || LENGTH(TRIM(v_sample_string)) || CHR(10);
    v_result := v_result || 'SUBSTR(1,6): "' || SUBSTR(TRIM(v_sample_string), 1, 6) || '"' || CHR(10);
    v_result := v_result || 'INSTR(Oracle): ' || INSTR(v_sample_string, 'Oracle') || CHR(10);
    v_result := v_result || 'REPLACE(Oracle, MySQL): "' || REPLACE(v_sample_string, 'Oracle', 'MySQL') || '"' || CHR(10);
    v_result := v_result || CHR(10);
    
    -- Number Functions
    v_result := v_result || '--- NUMBER FUNCTIONS ---' || CHR(10);
    v_result := v_result || 'Original: ' || v_sample_number || CHR(10);
    v_result := v_result || 'ROUND(2): ' || ROUND(v_sample_number, 2) || CHR(10);
    v_result := v_result || 'TRUNC(1): ' || TRUNC(v_sample_number, 1) || CHR(10);
    v_result := v_result || 'CEIL: ' || CEIL(v_sample_number) || CHR(10);
    v_result := v_result || 'FLOOR: ' || FLOOR(v_sample_number) || CHR(10);
    v_result := v_result || 'ABS(-123.45): ' || ABS(-123.45) || CHR(10);
    v_result := v_result || 'MOD(17,5): ' || MOD(17, 5) || CHR(10);
    v_result := v_result || 'POWER(2,8): ' || POWER(2, 8) || CHR(10);
    v_result := v_result || 'SQRT(64): ' || SQRT(64) || CHR(10);
    v_result := v_result || CHR(10);
    
    -- Date Functions
    v_result := v_result || '--- DATE FUNCTIONS ---' || CHR(10);
    v_result := v_result || 'SYSDATE: ' || TO_CHAR(v_sample_date, 'DD-MON-YYYY HH24:MI:SS') || CHR(10);
    v_result := v_result || 'ADD_MONTHS(+6): ' || TO_CHAR(ADD_MONTHS(v_sample_date, 6), 'DD-MON-YYYY') || CHR(10);
    v_result := v_result || 'NEXT_DAY(Friday): ' || TO_CHAR(NEXT_DAY(v_sample_date, 'FRIDAY'), 'DD-MON-YYYY') || CHR(10);
    v_result := v_result || 'LAST_DAY: ' || TO_CHAR(LAST_DAY(v_sample_date), 'DD-MON-YYYY') || CHR(10);
    v_result := v_result || 'EXTRACT(YEAR): ' || EXTRACT(YEAR FROM v_sample_date) || CHR(10);
    v_result := v_result || 'EXTRACT(MONTH): ' || EXTRACT(MONTH FROM v_sample_date) || CHR(10);
    v_result := v_result || 'MONTHS_BETWEEN(now, jan-1): ' || ROUND(MONTHS_BETWEEN(v_sample_date, DATE '2025-01-01'), 2) || CHR(10);
    v_result := v_result || CHR(10);
    
    -- Conversion Functions
    v_result := v_result || '--- CONVERSION FUNCTIONS ---' || CHR(10);
    v_result := v_result || 'TO_CHAR(12345, 999,999): ' || TO_CHAR(12345, '999,999') || CHR(10);
    v_result := v_result || 'TO_CHAR(0.85, 999.99%): ' || TO_CHAR(0.85, '999.99%') || CHR(10);
    v_result := v_result || 'TO_NUMBER("12345"): ' || TO_NUMBER('12345') || CHR(10);
    v_result := v_result || 'TO_DATE("01-JAN-2025"): ' || TO_CHAR(TO_DATE('01-JAN-2025', 'DD-MON-YYYY'), 'DD-MON-YYYY') || CHR(10);
    v_result := v_result || CHR(10);
    
    -- Conditional Functions
    v_result := v_result || '--- CONDITIONAL FUNCTIONS ---' || CHR(10);
    v_result := v_result || 'NVL(NULL, "Default"): ' || NVL(NULL, 'Default') || CHR(10);
    v_result := v_result || 'NVL2("Value", "Not Null", "Is Null"): ' || NVL2('Value', 'Not Null', 'Is Null') || CHR(10);
    v_result := v_result || 'NULLIF(5, 5): ' || NVL(TO_CHAR(NULLIF(5, 5)), 'NULL') || CHR(10);
    v_result := v_result || 'COALESCE(NULL, NULL, "Third"): ' || COALESCE(NULL, NULL, 'Third') || CHR(10);
    v_result := v_result || 'DECODE(1, 1, "One", 2, "Two", "Other"): ' || DECODE(1, 1, 'One', 2, 'Two', 'Other') || CHR(10);
    v_result := v_result || CHR(10);
    
    -- Aggregate Functions (simulated)
    v_result := v_result || '--- AGGREGATE FUNCTIONS (Examples) ---' || CHR(10);
    v_result := v_result || 'COUNT(*) - counts all rows' || CHR(10);
    v_result := v_result || 'SUM(column) - sums numeric values' || CHR(10);
    v_result := v_result || 'AVG(column) - calculates average' || CHR(10);
    v_result := v_result || 'MIN/MAX(column) - finds minimum/maximum' || CHR(10);
    v_result := v_result || 'STDDEV(column) - standard deviation' || CHR(10);
    v_result := v_result || 'VARIANCE(column) - variance calculation' || CHR(10);
    
    RETURN v_result;
END demonstrate_builtin_functions;
/

-- Execute the built-in functions demonstration
BEGIN
    DBMS_OUTPUT.ENABLE(1000000);
    DBMS_OUTPUT.PUT_LINE(demonstrate_builtin_functions);
END;
/

-- ============================================================================
-- CLEANUP SECTION
-- Clean up objects created during practice
-- ============================================================================

PROMPT ========================================
PROMPT CLEANUP SECTION
PROMPT ========================================

-- Drop packages
DROP PACKAGE shopping_cart;
DROP PACKAGE math_utils;

-- Drop functions
DROP FUNCTION calculate_tax;
DROP FUNCTION format_customer_name;
DROP FUNCTION calculate_business_days;
DROP FUNCTION generate_date_range;
DROP FUNCTION analyze_sales_performance;
DROP FUNCTION demonstrate_builtin_functions;

-- Drop types
DROP TYPE t_sales_summary_table;
DROP TYPE t_sales_summary_row;
DROP TYPE t_date_range_table;
DROP TYPE t_date_range_row;

PROMPT ========================================
PROMPT FUNCTIONS AND PACKAGES PRACTICE COMPLETE
PROMPT ========================================

/*
================================================================================
LEARNING OBJECTIVES COMPLETED:

1. ✓ Created and tested scalar functions with various return types
2. ✓ Implemented table functions returning collections
3. ✓ Built pipelined table functions for data generation
4. ✓ Developed basic packages with specifications and bodies
5. ✓ Created advanced packages with state management
6. ✓ Implemented private and public package elements
7. ✓ Demonstrated comprehensive built-in function usage
8. ✓ Applied advanced parameter handling and validation
9. ✓ Integrated functions and packages in business scenarios
10. ✓ Implemented proper error handling and exception management

BUSINESS SCENARIOS COVERED:
- Tax calculation systems
- Customer name formatting and standardization
- Business day calculations for scheduling
- Date range generation for reporting
- Sales performance analysis and reporting
- Mathematical utilities and calculations
- Shopping cart management with state
- E-commerce checkout processing
- Data transformation and analysis
- Comprehensive reporting functions

ADVANCED CONCEPTS DEMONSTRATED:
- Scalar function development with validation
- Table function implementation with PIPELINED keyword
- Object type creation for structured data
- Package specification and body separation
- Package state management and persistence
- Private vs public package elements
- Complex business logic implementation
- Built-in function integration and usage
- Exception handling in functions and packages
- Parameter validation and error reporting

KEY FEATURES COVERED:
- Function overloading concepts
- Default parameter values
- Complex return types and collections
- Package initialization and state
- Function deterministic optimization
- Pipelined function performance
- Built-in function comprehensive usage
- Error handling best practices

NEXT STEPS:
- Study triggers.sql for event-driven programming
- Practice advanced-plsql.sql for complex PL/SQL features
- Learn error-handling.sql for production-grade error management
- Explore lesson5-combined-practice.sql for integrated scenarios

================================================================================
*/
