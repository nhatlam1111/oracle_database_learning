-- =====================================================
-- E-COMMERCE STORED PROCEDURES AND FUNCTIONS
-- =====================================================
-- Project: Oracle Database Learning - Lesson 6 Practice
-- Description: Business logic procedures for e-commerce platform
-- Author: Oracle Learning Project
-- Created: 2024
-- =====================================================

-- Enable server output for feedback
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Creating E-commerce Business Logic Procedures...');
    DBMS_OUTPUT.PUT_LINE('===============================================');
END;
/

-- =====================================================
-- 1. CUSTOMER MANAGEMENT PROCEDURES
-- =====================================================

-- Procedure to register a new customer
CREATE OR REPLACE PROCEDURE sp_register_customer(
    p_email            IN VARCHAR2,
    p_password_hash    IN VARCHAR2,
    p_first_name       IN VARCHAR2,
    p_last_name        IN VARCHAR2,
    p_phone            IN VARCHAR2 DEFAULT NULL,
    p_birth_date       IN DATE DEFAULT NULL,
    p_gender           IN CHAR DEFAULT NULL,
    p_customer_id      OUT NUMBER,
    p_status           OUT VARCHAR2,
    p_message          OUT VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Check if email already exists
    SELECT COUNT(*) INTO v_count
    FROM ecom_customers
    WHERE email = p_email;
    
    IF v_count > 0 THEN
        p_status := 'ERROR';
        p_message := 'Email address already registered';
        RETURN;
    END IF;
    
    -- Insert new customer
    INSERT INTO ecom_customers (
        customer_id, email, password_hash, first_name, last_name,
        phone, birth_date, gender, registration_date
    ) VALUES (
        seq_ecom_customers.NEXTVAL, p_email, p_password_hash, p_first_name, p_last_name,
        p_phone, p_birth_date, p_gender, SYSDATE
    ) RETURNING customer_id INTO p_customer_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Customer registered successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Registration failed: ' || SQLERRM;
END sp_register_customer;
/

-- Procedure to update customer profile
CREATE OR REPLACE PROCEDURE sp_update_customer_profile(
    p_customer_id      IN NUMBER,
    p_first_name       IN VARCHAR2 DEFAULT NULL,
    p_last_name        IN VARCHAR2 DEFAULT NULL,
    p_phone            IN VARCHAR2 DEFAULT NULL,
    p_birth_date       IN DATE DEFAULT NULL,
    p_status           OUT VARCHAR2,
    p_message          OUT VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Check if customer exists
    SELECT COUNT(*) INTO v_count
    FROM ecom_customers
    WHERE customer_id = p_customer_id;
    
    IF v_count = 0 THEN
        p_status := 'ERROR';
        p_message := 'Customer not found';
        RETURN;
    END IF;
    
    -- Update customer profile
    UPDATE ecom_customers
    SET first_name = NVL(p_first_name, first_name),
        last_name = NVL(p_last_name, last_name),
        phone = NVL(p_phone, phone),
        birth_date = NVL(p_birth_date, birth_date),
        modified_date = SYSDATE,
        modified_by = USER
    WHERE customer_id = p_customer_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Customer profile updated successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Profile update failed: ' || SQLERRM;
END sp_update_customer_profile;
/

-- Procedure to add customer address
CREATE OR REPLACE PROCEDURE sp_add_customer_address(
    p_customer_id      IN NUMBER,
    p_address_type     IN VARCHAR2,
    p_address_line1    IN VARCHAR2,
    p_address_line2    IN VARCHAR2 DEFAULT NULL,
    p_city             IN VARCHAR2,
    p_state_province   IN VARCHAR2,
    p_postal_code      IN VARCHAR2,
    p_country          IN VARCHAR2,
    p_is_default       IN CHAR DEFAULT 'N',
    p_address_id       OUT NUMBER,
    p_status           OUT VARCHAR2,
    p_message          OUT VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Validate customer exists
    SELECT COUNT(*) INTO v_count
    FROM ecom_customers
    WHERE customer_id = p_customer_id;
    
    IF v_count = 0 THEN
        p_status := 'ERROR';
        p_message := 'Customer not found';
        RETURN;
    END IF;
    
    -- If this is set as default, update existing default addresses
    IF p_is_default = 'Y' THEN
        UPDATE ecom_customer_addresses
        SET is_default = 'N'
        WHERE customer_id = p_customer_id
          AND address_type = p_address_type;
    END IF;
    
    -- Insert new address
    INSERT INTO ecom_customer_addresses (
        address_id, customer_id, address_type, address_line1, address_line2,
        city, state_province, postal_code, country, is_default
    ) VALUES (
        seq_ecom_addresses.NEXTVAL, p_customer_id, p_address_type, p_address_line1, p_address_line2,
        p_city, p_state_province, p_postal_code, p_country, p_is_default
    ) RETURNING address_id INTO p_address_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Address added successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Address creation failed: ' || SQLERRM;
END sp_add_customer_address;
/

-- =====================================================
-- 2. SHOPPING CART PROCEDURES
-- =====================================================

-- Procedure to add item to cart
CREATE OR REPLACE PROCEDURE sp_add_to_cart(
    p_customer_id      IN NUMBER,
    p_product_id       IN NUMBER,
    p_variant_id       IN NUMBER DEFAULT NULL,
    p_quantity         IN NUMBER,
    p_status           OUT VARCHAR2,
    p_message          OUT VARCHAR2
) AS
    v_cart_id NUMBER;
    v_current_qty NUMBER := 0;
    v_product_price NUMBER;
    v_variant_price_adj NUMBER := 0;
    v_final_price NUMBER;
    v_available_qty NUMBER;
BEGIN
    -- Get or create cart for customer
    BEGIN
        SELECT cart_id INTO v_cart_id
        FROM ecom_shopping_carts
        WHERE customer_id = p_customer_id
          AND expires_date > SYSDATE
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            INSERT INTO ecom_shopping_carts (cart_id, customer_id)
            VALUES (seq_ecom_carts.NEXTVAL, p_customer_id)
            RETURNING cart_id INTO v_cart_id;
    END;
    
    -- Get product price
    SELECT base_price INTO v_product_price
    FROM ecom_products
    WHERE product_id = p_product_id;
    
    -- Get variant price adjustment if applicable
    IF p_variant_id IS NOT NULL THEN
        SELECT NVL(price_adjustment, 0) INTO v_variant_price_adj
        FROM ecom_product_variants
        WHERE variant_id = p_variant_id;
    END IF;
    
    v_final_price := v_product_price + v_variant_price_adj;
    
    -- Check inventory availability
    SELECT SUM(quantity_available) INTO v_available_qty
    FROM ecom_inventory
    WHERE product_id = p_product_id
      AND (p_variant_id IS NULL OR variant_id = p_variant_id);
    
    IF v_available_qty < p_quantity THEN
        p_status := 'ERROR';
        p_message := 'Insufficient inventory. Available: ' || v_available_qty;
        RETURN;
    END IF;
    
    -- Check if item already exists in cart
    BEGIN
        SELECT quantity INTO v_current_qty
        FROM ecom_cart_items
        WHERE cart_id = v_cart_id
          AND product_id = p_product_id
          AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL));
        
        -- Update existing item
        UPDATE ecom_cart_items
        SET quantity = v_current_qty + p_quantity,
            unit_price = v_final_price
        WHERE cart_id = v_cart_id
          AND product_id = p_product_id
          AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL));
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Insert new item
            INSERT INTO ecom_cart_items (
                cart_item_id, cart_id, product_id, variant_id, quantity, unit_price
            ) VALUES (
                seq_ecom_cart_items.NEXTVAL, v_cart_id, p_product_id, p_variant_id, p_quantity, v_final_price
            );
    END;
    
    -- Update cart modified date
    UPDATE ecom_shopping_carts
    SET modified_date = SYSDATE
    WHERE cart_id = v_cart_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Item added to cart successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Failed to add item to cart: ' || SQLERRM;
END sp_add_to_cart;
/

-- Procedure to remove item from cart
CREATE OR REPLACE PROCEDURE sp_remove_from_cart(
    p_customer_id      IN NUMBER,
    p_cart_item_id     IN NUMBER,
    p_status           OUT VARCHAR2,
    p_message          OUT VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Verify the cart item belongs to the customer
    SELECT COUNT(*) INTO v_count
    FROM ecom_cart_items ci
    JOIN ecom_shopping_carts sc ON ci.cart_id = sc.cart_id
    WHERE ci.cart_item_id = p_cart_item_id
      AND sc.customer_id = p_customer_id;
    
    IF v_count = 0 THEN
        p_status := 'ERROR';
        p_message := 'Cart item not found or access denied';
        RETURN;
    END IF;
    
    -- Remove the item
    DELETE FROM ecom_cart_items
    WHERE cart_item_id = p_cart_item_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Item removed from cart successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Failed to remove item from cart: ' || SQLERRM;
END sp_remove_from_cart;
/

-- =====================================================
-- 3. ORDER PROCESSING PROCEDURES
-- =====================================================

-- Procedure to create order from cart
CREATE OR REPLACE PROCEDURE sp_create_order_from_cart(
    p_customer_id         IN NUMBER,
    p_shipping_address_id IN NUMBER,
    p_billing_address_id  IN NUMBER,
    p_payment_method_id   IN NUMBER,
    p_coupon_code         IN VARCHAR2 DEFAULT NULL,
    p_order_id            OUT NUMBER,
    p_status              OUT VARCHAR2,
    p_message             OUT VARCHAR2
) AS
    v_cart_id NUMBER;
    v_subtotal NUMBER := 0;
    v_tax_rate NUMBER := 0.08; -- 8% tax rate
    v_tax_amount NUMBER := 0;
    v_shipping_amount NUMBER := 15.99; -- Standard shipping
    v_discount_amount NUMBER := 0;
    v_total_amount NUMBER;
    v_coupon_id NUMBER;
    v_cart_item_count NUMBER;
    
    -- Cursor for cart items
    CURSOR cart_items_cur IS
        SELECT ci.product_id, ci.variant_id, ci.quantity, ci.unit_price,
               p.product_name, pv.sku_code
        FROM ecom_cart_items ci
        JOIN ecom_products p ON ci.product_id = p.product_id
        LEFT JOIN ecom_product_variants pv ON ci.variant_id = pv.variant_id
        WHERE ci.cart_id = v_cart_id;
        
BEGIN
    -- Get customer's active cart
    BEGIN
        SELECT cart_id INTO v_cart_id
        FROM ecom_shopping_carts
        WHERE customer_id = p_customer_id
          AND expires_date > SYSDATE
          AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'ERROR';
            p_message := 'No active cart found';
            RETURN;
    END;
    
    -- Check if cart has items
    SELECT COUNT(*) INTO v_cart_item_count
    FROM ecom_cart_items
    WHERE cart_id = v_cart_id;
    
    IF v_cart_item_count = 0 THEN
        p_status := 'ERROR';
        p_message := 'Cart is empty';
        RETURN;
    END IF;
    
    -- Calculate subtotal
    SELECT SUM(quantity * unit_price) INTO v_subtotal
    FROM ecom_cart_items
    WHERE cart_id = v_cart_id;
    
    -- Apply coupon if provided
    IF p_coupon_code IS NOT NULL THEN
        BEGIN
            SELECT coupon_id INTO v_coupon_id
            FROM ecom_coupons
            WHERE coupon_code = p_coupon_code
              AND is_active = 'Y'
              AND valid_from <= SYSDATE
              AND valid_until >= SYSDATE
              AND minimum_order <= v_subtotal;
            
            -- Calculate discount (simplified logic)
            SELECT CASE discount_type
                       WHEN 'PERCENTAGE' THEN LEAST(v_subtotal * discount_value / 100, NVL(maximum_discount, v_subtotal))
                       WHEN 'FIXED_AMOUNT' THEN LEAST(discount_value, v_subtotal)
                       WHEN 'FREE_SHIPPING' THEN v_shipping_amount
                       ELSE 0
                   END
            INTO v_discount_amount
            FROM ecom_coupons
            WHERE coupon_id = v_coupon_id;
            
            -- Free shipping coupon
            IF EXISTS (SELECT 1 FROM ecom_coupons WHERE coupon_id = v_coupon_id AND discount_type = 'FREE_SHIPPING') THEN
                v_shipping_amount := 0;
                v_discount_amount := 15.99; -- Show original shipping cost as discount
            END IF;
            
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                p_status := 'ERROR';
                p_message := 'Invalid or expired coupon code';
                RETURN;
        END;
    END IF;
    
    -- Calculate final amounts
    v_tax_amount := (v_subtotal - v_discount_amount) * v_tax_rate;
    v_total_amount := v_subtotal - v_discount_amount + v_tax_amount + v_shipping_amount;
    
    -- Create order
    INSERT INTO ecom_orders (
        order_id, customer_id, order_status, order_date,
        subtotal_amount, tax_amount, shipping_amount, discount_amount, total_amount,
        shipping_address_id, billing_address_id, payment_status
    ) VALUES (
        seq_ecom_orders.NEXTVAL, p_customer_id, 'PENDING', SYSDATE,
        v_subtotal, v_tax_amount, v_shipping_amount, v_discount_amount, v_total_amount,
        p_shipping_address_id, p_billing_address_id, 'PENDING'
    ) RETURNING order_id INTO p_order_id;
    
    -- Copy cart items to order items
    FOR item IN cart_items_cur LOOP
        INSERT INTO ecom_order_items (
            order_item_id, order_id, product_id, variant_id,
            product_name, product_sku, quantity, unit_price, total_price
        ) VALUES (
            seq_ecom_order_items.NEXTVAL, p_order_id, item.product_id, item.variant_id,
            item.product_name, item.sku_code, item.quantity, item.unit_price,
            item.quantity * item.unit_price
        );
    END LOOP;
    
    -- Record coupon usage if applicable
    IF v_coupon_id IS NOT NULL THEN
        INSERT INTO ecom_coupon_usage (
            usage_id, coupon_id, order_id, customer_id, discount_amount, used_date
        ) VALUES (
            seq_ecom_usage.NEXTVAL, v_coupon_id, p_order_id, p_customer_id, v_discount_amount, SYSDATE
        );
    END IF;
    
    -- Clear the cart
    DELETE FROM ecom_cart_items WHERE cart_id = v_cart_id;
    DELETE FROM ecom_shopping_carts WHERE cart_id = v_cart_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Order created successfully. Order ID: ' || p_order_id;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Order creation failed: ' || SQLERRM;
END sp_create_order_from_cart;
/

-- Procedure to process payment
CREATE OR REPLACE PROCEDURE sp_process_payment(
    p_order_id          IN NUMBER,
    p_payment_method_id IN NUMBER,
    p_transaction_type  IN VARCHAR2 DEFAULT 'SALE',
    p_gateway_reference IN VARCHAR2,
    p_gateway_response  IN CLOB DEFAULT NULL,
    p_status            OUT VARCHAR2,
    p_message           OUT VARCHAR2
) AS
    v_order_total NUMBER;
    v_transaction_id NUMBER;
BEGIN
    -- Get order total
    SELECT total_amount INTO v_order_total
    FROM ecom_orders
    WHERE order_id = p_order_id;
    
    -- Create payment transaction
    INSERT INTO ecom_payment_transactions (
        transaction_id, order_id, payment_method_id, transaction_type,
        amount, transaction_status, gateway_reference, gateway_response, processed_date
    ) VALUES (
        seq_ecom_pay_trans.NEXTVAL, p_order_id, p_payment_method_id, p_transaction_type,
        v_order_total, 'SUCCESS', p_gateway_reference, p_gateway_response, SYSDATE
    ) RETURNING transaction_id INTO v_transaction_id;
    
    -- Update order payment status
    UPDATE ecom_orders
    SET payment_status = 'PAID',
        order_status = 'CONFIRMED',
        modified_date = SYSDATE
    WHERE order_id = p_order_id;
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Payment processed successfully. Transaction ID: ' || v_transaction_id;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Payment processing failed: ' || SQLERRM;
END sp_process_payment;
/

-- =====================================================
-- 4. INVENTORY MANAGEMENT PROCEDURES
-- =====================================================

-- Procedure to update inventory
CREATE OR REPLACE PROCEDURE sp_update_inventory(
    p_product_id       IN NUMBER,
    p_variant_id       IN NUMBER DEFAULT NULL,
    p_warehouse_id     IN NUMBER,
    p_quantity_change  IN NUMBER,
    p_transaction_type IN VARCHAR2,
    p_reference_type   IN VARCHAR2 DEFAULT NULL,
    p_reference_id     IN NUMBER DEFAULT NULL,
    p_notes           IN VARCHAR2 DEFAULT NULL,
    p_status          OUT VARCHAR2,
    p_message         OUT VARCHAR2
) AS
    v_inventory_id NUMBER;
    v_current_qty NUMBER;
BEGIN
    -- Get inventory record
    BEGIN
        SELECT inventory_id, quantity_available
        INTO v_inventory_id, v_current_qty
        FROM ecom_inventory
        WHERE product_id = p_product_id
          AND (variant_id = p_variant_id OR (variant_id IS NULL AND p_variant_id IS NULL))
          AND warehouse_id = p_warehouse_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create new inventory record
            INSERT INTO ecom_inventory (
                inventory_id, product_id, variant_id, warehouse_id,
                quantity_available, reorder_level, max_stock_level
            ) VALUES (
                seq_ecom_inventory.NEXTVAL, p_product_id, p_variant_id, p_warehouse_id,
                0, 10, 1000
            ) RETURNING inventory_id, quantity_available INTO v_inventory_id, v_current_qty;
    END;
    
    -- Validate inventory won't go negative
    IF v_current_qty + p_quantity_change < 0 THEN
        p_status := 'ERROR';
        p_message := 'Insufficient inventory. Available: ' || v_current_qty;
        RETURN;
    END IF;
    
    -- Update inventory
    UPDATE ecom_inventory
    SET quantity_available = quantity_available + p_quantity_change,
        last_updated = SYSDATE
    WHERE inventory_id = v_inventory_id;
    
    -- Record transaction
    INSERT INTO ecom_inventory_transactions (
        transaction_id, inventory_id, transaction_type, quantity_change,
        reference_type, reference_id, transaction_date, notes
    ) VALUES (
        seq_ecom_inv_trans.NEXTVAL, v_inventory_id, p_transaction_type, p_quantity_change,
        p_reference_type, p_reference_id, SYSDATE, p_notes
    );
    
    COMMIT;
    
    p_status := 'SUCCESS';
    p_message := 'Inventory updated successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR';
        p_message := 'Inventory update failed: ' || SQLERRM;
END sp_update_inventory;
/

-- =====================================================
-- 5. UTILITY FUNCTIONS
-- =====================================================

-- Function to get customer cart total
CREATE OR REPLACE FUNCTION fn_get_cart_total(
    p_customer_id IN NUMBER
) RETURN NUMBER AS
    v_total NUMBER := 0;
BEGIN
    SELECT NVL(SUM(quantity * unit_price), 0)
    INTO v_total
    FROM ecom_cart_items ci
    JOIN ecom_shopping_carts sc ON ci.cart_id = sc.cart_id
    WHERE sc.customer_id = p_customer_id
      AND sc.expires_date > SYSDATE;
    
    RETURN v_total;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_get_cart_total;
/

-- Function to get product average rating
CREATE OR REPLACE FUNCTION fn_get_product_rating(
    p_product_id IN NUMBER
) RETURN NUMBER AS
    v_rating NUMBER := 0;
BEGIN
    SELECT NVL(AVG(rating), 0)
    INTO v_rating
    FROM ecom_product_reviews
    WHERE product_id = p_product_id
      AND review_status = 'APPROVED';
    
    RETURN ROUND(v_rating, 1);
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END fn_get_product_rating;
/

-- Function to check inventory availability
CREATE OR REPLACE FUNCTION fn_check_inventory_availability(
    p_product_id IN NUMBER,
    p_variant_id IN NUMBER DEFAULT NULL,
    p_quantity   IN NUMBER
) RETURN VARCHAR2 AS
    v_total_available NUMBER := 0;
BEGIN
    SELECT NVL(SUM(quantity_available), 0)
    INTO v_total_available
    FROM ecom_inventory
    WHERE product_id = p_product_id
      AND (p_variant_id IS NULL OR variant_id = p_variant_id);
    
    IF v_total_available >= p_quantity THEN
        RETURN 'AVAILABLE';
    ELSE
        RETURN 'INSUFFICIENT';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR';
END fn_check_inventory_availability;
/

-- Function to calculate order total with discounts
CREATE OR REPLACE FUNCTION fn_calculate_order_total(
    p_subtotal        IN NUMBER,
    p_coupon_code     IN VARCHAR2 DEFAULT NULL,
    p_customer_type   IN VARCHAR2 DEFAULT 'REGULAR'
) RETURN NUMBER AS
    v_discount_amount NUMBER := 0;
    v_tax_rate NUMBER := 0.08;
    v_shipping_amount NUMBER := 15.99;
    v_total NUMBER;
BEGIN
    -- Apply coupon discount
    IF p_coupon_code IS NOT NULL THEN
        SELECT CASE discount_type
                   WHEN 'PERCENTAGE' THEN LEAST(p_subtotal * discount_value / 100, NVL(maximum_discount, p_subtotal))
                   WHEN 'FIXED_AMOUNT' THEN LEAST(discount_value, p_subtotal)
                   WHEN 'FREE_SHIPPING' THEN v_shipping_amount
                   ELSE 0
               END
        INTO v_discount_amount
        FROM ecom_coupons
        WHERE coupon_code = p_coupon_code
          AND is_active = 'Y'
          AND valid_from <= SYSDATE
          AND valid_until >= SYSDATE
          AND minimum_order <= p_subtotal;
        
        -- Free shipping for coupon
        IF EXISTS (SELECT 1 FROM ecom_coupons WHERE coupon_code = p_coupon_code AND discount_type = 'FREE_SHIPPING') THEN
            v_shipping_amount := 0;
        END IF;
    END IF;
    
    -- Apply customer type benefits
    IF p_customer_type = 'VIP' THEN
        v_shipping_amount := 0; -- Free shipping for VIP
    ELSIF p_customer_type = 'PREMIUM' AND p_subtotal >= 100 THEN
        v_shipping_amount := 0; -- Free shipping for Premium customers over $100
    END IF;
    
    -- Calculate total
    v_total := p_subtotal - v_discount_amount + (p_subtotal - v_discount_amount) * v_tax_rate + v_shipping_amount;
    
    RETURN ROUND(v_total, 2);
EXCEPTION
    WHEN OTHERS THEN
        RETURN p_subtotal * 1.08 + 15.99; -- Default calculation
END fn_calculate_order_total;
/

-- =====================================================
-- 6. REPORTING PROCEDURES
-- =====================================================

-- Procedure to generate sales report
CREATE OR REPLACE PROCEDURE sp_generate_sales_report(
    p_start_date       IN DATE,
    p_end_date         IN DATE,
    p_category_id      IN NUMBER DEFAULT NULL,
    p_total_orders     OUT NUMBER,
    p_total_revenue    OUT NUMBER,
    p_avg_order_value  OUT NUMBER,
    p_status           OUT VARCHAR2,
    p_message          OUT VARCHAR2
) AS
BEGIN
    SELECT COUNT(*),
           NVL(SUM(total_amount), 0),
           NVL(AVG(total_amount), 0)
    INTO p_total_orders, p_total_revenue, p_avg_order_value
    FROM ecom_orders o
    WHERE o.order_date BETWEEN p_start_date AND p_end_date
      AND o.order_status NOT IN ('CANCELLED', 'REFUNDED')
      AND (p_category_id IS NULL OR EXISTS (
          SELECT 1 FROM ecom_order_items oi
          JOIN ecom_products p ON oi.product_id = p.product_id
          WHERE oi.order_id = o.order_id
            AND p.category_id = p_category_id
      ));
    
    p_status := 'SUCCESS';
    p_message := 'Sales report generated successfully';
    
EXCEPTION
    WHEN OTHERS THEN
        p_status := 'ERROR';
        p_message := 'Report generation failed: ' || SQLERRM;
END sp_generate_sales_report;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('E-commerce Business Logic Procedures Complete!');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('✓ Customer management procedures created');
    DBMS_OUTPUT.PUT_LINE('✓ Shopping cart procedures created');
    DBMS_OUTPUT.PUT_LINE('✓ Order processing procedures created');
    DBMS_OUTPUT.PUT_LINE('✓ Inventory management procedures created');
    DBMS_OUTPUT.PUT_LINE('✓ Utility functions created');
    DBMS_OUTPUT.PUT_LINE('✓ Reporting procedures created');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Available procedures:');
    DBMS_OUTPUT.PUT_LINE('- sp_register_customer');
    DBMS_OUTPUT.PUT_LINE('- sp_update_customer_profile');
    DBMS_OUTPUT.PUT_LINE('- sp_add_customer_address');
    DBMS_OUTPUT.PUT_LINE('- sp_add_to_cart');
    DBMS_OUTPUT.PUT_LINE('- sp_remove_from_cart');
    DBMS_OUTPUT.PUT_LINE('- sp_create_order_from_cart');
    DBMS_OUTPUT.PUT_LINE('- sp_process_payment');
    DBMS_OUTPUT.PUT_LINE('- sp_update_inventory');
    DBMS_OUTPUT.PUT_LINE('- sp_generate_sales_report');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Available functions:');
    DBMS_OUTPUT.PUT_LINE('- fn_get_cart_total');
    DBMS_OUTPUT.PUT_LINE('- fn_get_product_rating');
    DBMS_OUTPUT.PUT_LINE('- fn_check_inventory_availability');
    DBMS_OUTPUT.PUT_LINE('- fn_calculate_order_total');
END;
/
