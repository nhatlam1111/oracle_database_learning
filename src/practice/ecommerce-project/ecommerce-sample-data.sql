-- =====================================================
-- E-COMMERCE SAMPLE DATA
-- =====================================================
-- Project: Oracle Database Learning - Lesson 6 Practice
-- Description: Sample data for e-commerce platform
-- Author: Oracle Learning Project
-- Created: 2024
-- =====================================================

-- Enable server output for feedback
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Loading E-commerce Sample Data...');
    DBMS_OUTPUT.PUT_LINE('=================================');
END;
/

-- =====================================================
-- 1. CATEGORIES DATA
-- =====================================================

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Electronics', NULL, 'Electronics', 'Electronic devices and accessories', 1);

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Computers', 1, 'Electronics > Computers', 'Desktop and laptop computers', 10);

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Smartphones', 1, 'Electronics > Smartphones', 'Mobile phones and accessories', 20);

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Clothing', NULL, 'Clothing', 'Fashion and apparel', 2);

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Men''s Clothing', 4, 'Clothing > Men''s Clothing', 'Men''s fashion and apparel', 10);

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Women''s Clothing', 4, 'Clothing > Women''s Clothing', 'Women''s fashion and apparel', 20);

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Home & Garden', NULL, 'Home & Garden', 'Home improvement and garden supplies', 3);

INSERT INTO ecom_categories (category_id, category_name, parent_category_id, category_path, description, display_order) VALUES
(seq_ecom_categories.NEXTVAL, 'Books', NULL, 'Books', 'Books and educational materials', 4);

-- =====================================================
-- 2. BRANDS DATA
-- =====================================================

INSERT INTO ecom_brands (brand_id, brand_name, description, website_url) VALUES
(seq_ecom_brands.NEXTVAL, 'TechCorp', 'Leading technology manufacturer', 'https://www.techcorp.com');

INSERT INTO ecom_brands (brand_id, brand_name, description, website_url) VALUES
(seq_ecom_brands.NEXTVAL, 'MobilePro', 'Premium smartphone manufacturer', 'https://www.mobilepro.com');

INSERT INTO ecom_brands (brand_id, brand_name, description, website_url) VALUES
(seq_ecom_brands.NEXTVAL, 'FashionBrand', 'Contemporary fashion label', 'https://www.fashionbrand.com');

INSERT INTO ecom_brands (brand_id, brand_name, description, website_url) VALUES
(seq_ecom_brands.NEXTVAL, 'HomeStyle', 'Modern home furnishings', 'https://www.homestyle.com');

INSERT INTO ecom_brands (brand_id, brand_name, description, website_url) VALUES
(seq_ecom_brands.NEXTVAL, 'BookPublisher', 'Educational and fiction books', 'https://www.bookpublisher.com');

-- =====================================================
-- 3. WAREHOUSES DATA
-- =====================================================

INSERT INTO ecom_warehouses (warehouse_id, warehouse_code, warehouse_name, address_line1, city, state_province, postal_code, country, phone, email, manager_name) VALUES
(seq_ecom_warehouses.NEXTVAL, 'WH-EAST', 'East Coast Distribution Center', '123 Industrial Blvd', 'Newark', 'NJ', '07102', 'USA', '(555) 123-4567', 'east@warehouse.com', 'John Smith');

INSERT INTO ecom_warehouses (warehouse_id, warehouse_code, warehouse_name, address_line1, city, state_province, postal_code, country, phone, email, manager_name) VALUES
(seq_ecom_warehouses.NEXTVAL, 'WH-WEST', 'West Coast Distribution Center', '456 Commerce Way', 'Los Angeles', 'CA', '90210', 'USA', '(555) 987-6543', 'west@warehouse.com', 'Sarah Johnson');

INSERT INTO ecom_warehouses (warehouse_id, warehouse_code, warehouse_name, address_line1, city, state_province, postal_code, country, phone, email, manager_name) VALUES
(seq_ecom_warehouses.NEXTVAL, 'WH-CENTRAL', 'Central Distribution Hub', '789 Logistics Dr', 'Chicago', 'IL', '60601', 'USA', '(555) 456-7890', 'central@warehouse.com', 'Mike Davis');

-- =====================================================
-- 4. PRODUCTS DATA
-- =====================================================

-- Electronics - Computers
INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'LAPTOP-TC-001', 'TechCorp UltraBook Pro 15', 2, 1, 'High-performance laptop for professionals', 'Premium laptop with 15.6" 4K display, Intel i7 processor, 16GB RAM, 512GB SSD. Perfect for business and creative work.', 1299.99, 899.99, 2.1, 'Y', 'laptop,computer,business,professional');

INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'DESKTOP-TC-002', 'TechCorp Gaming Tower X1', 2, 1, 'Ultimate gaming desktop computer', 'High-end gaming PC with latest graphics card, 32GB RAM, 1TB NVMe SSD. Ready for 4K gaming and VR.', 2199.99, 1599.99, 15.5, 'Y', 'desktop,gaming,computer,high-performance');

-- Electronics - Smartphones
INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'PHONE-MP-001', 'MobilePro X12 Pro', 3, 2, 'Latest flagship smartphone', 'Premium smartphone with 6.7" OLED display, triple camera system, 5G connectivity, and all-day battery life.', 999.99, 699.99, 0.21, 'Y', 'smartphone,mobile,5G,camera');

INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'PHONE-MP-002', 'MobilePro Lite 8', 3, 2, 'Affordable smartphone with great features', 'Budget-friendly smartphone with excellent camera, long battery life, and smooth performance for everyday use.', 399.99, 279.99, 0.18, 'N', 'smartphone,budget,mobile,everyday');

-- Clothing - Men's
INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'SHIRT-FB-001', 'FashionBrand Premium Dress Shirt', 5, 3, 'Professional dress shirt for business', 'High-quality cotton dress shirt with modern fit. Perfect for office wear and formal occasions.', 79.99, 39.99, 0.3, 'N', 'shirt,mens,business,formal,cotton');

INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'JEANS-FB-002', 'FashionBrand Classic Jeans', 5, 3, 'Comfortable classic fit jeans', 'Premium denim jeans with classic fit and vintage wash. Made from sustainable materials.', 89.99, 44.99, 0.6, 'N', 'jeans,mens,denim,casual,sustainable');

-- Clothing - Women's
INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'DRESS-FB-003', 'FashionBrand Summer Dress', 6, 3, 'Elegant summer dress for any occasion', 'Flowing summer dress made from lightweight fabric. Perfect for casual outings or special events.', 119.99, 59.99, 0.4, 'Y', 'dress,womens,summer,elegant,casual');

-- Home & Garden
INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'CHAIR-HS-001', 'HomeStyle Ergonomic Office Chair', 7, 4, 'Comfortable office chair with lumbar support', 'Professional office chair with adjustable height, lumbar support, and breathable mesh back.', 299.99, 179.99, 12.5, 'N', 'chair,office,ergonomic,furniture,comfort');

-- Books
INSERT INTO ecom_products (product_id, product_code, product_name, category_id, brand_id, short_description, long_description, base_price, cost_price, weight, is_featured, tags) VALUES
(seq_ecom_products.NEXTVAL, 'BOOK-BP-001', 'Oracle Database Administration Guide', 8, 5, 'Comprehensive guide to Oracle DBA', 'Complete reference for Oracle Database administration covering installation, configuration, and maintenance.', 59.99, 29.99, 1.2, 'N', 'book,oracle,database,technical,education');

-- =====================================================
-- 5. PRODUCT VARIANTS DATA
-- =====================================================

-- Laptop variants (colors)
INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, color_value, is_default) VALUES
(seq_ecom_variants.NEXTVAL, 1000, 'LAPTOP-TC-001-SLV', 'Silver', 'Silver', 'Y');

INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, color_value) VALUES
(seq_ecom_variants.NEXTVAL, 1000, 'LAPTOP-TC-001-BLK', 'Space Black', 'Black');

-- Smartphone variants (storage and color)
INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, color_value, style_value, price_adjustment, is_default) VALUES
(seq_ecom_variants.NEXTVAL, 1002, 'PHONE-MP-001-128-BLK', '128GB Black', 'Black', '128GB', 0, 'Y');

INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, color_value, style_value, price_adjustment) VALUES
(seq_ecom_variants.NEXTVAL, 1002, 'PHONE-MP-001-256-BLK', '256GB Black', 'Black', '256GB', 100);

INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, color_value, style_value, price_adjustment) VALUES
(seq_ecom_variants.NEXTVAL, 1002, 'PHONE-MP-001-128-WHT', '128GB White', 'White', '128GB', 0);

-- Clothing variants (sizes)
INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, size_value, is_default) VALUES
(seq_ecom_variants.NEXTVAL, 1004, 'SHIRT-FB-001-M', 'Medium', 'M', 'Y');

INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, size_value) VALUES
(seq_ecom_variants.NEXTVAL, 1004, 'SHIRT-FB-001-L', 'Large', 'L');

INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, size_value) VALUES
(seq_ecom_variants.NEXTVAL, 1004, 'SHIRT-FB-001-XL', 'Extra Large', 'XL');

-- Dress variants (sizes and colors)
INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, size_value, color_value, is_default) VALUES
(seq_ecom_variants.NEXTVAL, 1006, 'DRESS-FB-003-S-BLU', 'Small Blue', 'S', 'Blue', 'Y');

INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, size_value, color_value) VALUES
(seq_ecom_variants.NEXTVAL, 1006, 'DRESS-FB-003-M-BLU', 'Medium Blue', 'M', 'Blue');

INSERT INTO ecom_product_variants (variant_id, product_id, sku_code, variant_name, size_value, color_value) VALUES
(seq_ecom_variants.NEXTVAL, 1006, 'DRESS-FB-003-S-RED', 'Small Red', 'S', 'Red');

-- =====================================================
-- 6. INVENTORY DATA
-- =====================================================

-- Populate inventory for all products across warehouses
DECLARE
    v_product_id NUMBER;
    v_warehouse_id NUMBER;
    v_variant_id NUMBER;
    v_base_qty NUMBER;
BEGIN
    -- Electronics inventory (higher quantities in tech warehouses)
    FOR prod IN (SELECT product_id FROM ecom_products WHERE category_id IN (1,2,3)) LOOP
        FOR wh IN (SELECT warehouse_id FROM ecom_warehouses) LOOP
            v_base_qty := CASE 
                WHEN wh.warehouse_id = 1 THEN 150  -- East coast higher tech inventory
                WHEN wh.warehouse_id = 2 THEN 200  -- West coast highest tech inventory
                ELSE 100 -- Central
            END;
            
            INSERT INTO ecom_inventory (inventory_id, product_id, warehouse_id, quantity_available, reorder_level, max_stock_level)
            VALUES (seq_ecom_inventory.NEXTVAL, prod.product_id, wh.warehouse_id, 
                   v_base_qty + DBMS_RANDOM.VALUE(0,50), 20, v_base_qty + 100);
        END LOOP;
    END LOOP;
    
    -- Clothing inventory (more distributed)
    FOR prod IN (SELECT product_id FROM ecom_products WHERE category_id IN (4,5,6)) LOOP
        FOR wh IN (SELECT warehouse_id FROM ecom_warehouses) LOOP
            v_base_qty := 300; -- Higher quantities for clothing
            
            INSERT INTO ecom_inventory (inventory_id, product_id, warehouse_id, quantity_available, reorder_level, max_stock_level)
            VALUES (seq_ecom_inventory.NEXTVAL, prod.product_id, wh.warehouse_id, 
                   v_base_qty + DBMS_RANDOM.VALUE(0,100), 50, v_base_qty + 200);
        END LOOP;
    END LOOP;
    
    -- Other categories inventory
    FOR prod IN (SELECT product_id FROM ecom_products WHERE category_id NOT IN (1,2,3,4,5,6)) LOOP
        FOR wh IN (SELECT warehouse_id FROM ecom_warehouses) LOOP
            v_base_qty := 75;
            
            INSERT INTO ecom_inventory (inventory_id, product_id, warehouse_id, quantity_available, reorder_level, max_stock_level)
            VALUES (seq_ecom_inventory.NEXTVAL, prod.product_id, wh.warehouse_id, 
                   v_base_qty + DBMS_RANDOM.VALUE(0,25), 15, v_base_qty + 50);
        END LOOP;
    END LOOP;
END;
/

-- =====================================================
-- 7. CUSTOMERS DATA
-- =====================================================

INSERT INTO ecom_customers (customer_id, email, password_hash, first_name, last_name, phone, birth_date, gender, customer_type, registration_date) VALUES
(seq_ecom_customers.NEXTVAL, 'john.smith@email.com', 'hashed_password_123', 'John', 'Smith', '(555) 123-4567', DATE '1985-03-15', 'M', 'PREMIUM', DATE '2023-01-15');

INSERT INTO ecom_customers (customer_id, email, password_hash, first_name, last_name, phone, birth_date, gender, customer_type, registration_date) VALUES
(seq_ecom_customers.NEXTVAL, 'sarah.johnson@email.com', 'hashed_password_456', 'Sarah', 'Johnson', '(555) 987-6543', DATE '1990-07-22', 'F', 'VIP', DATE '2022-11-08');

INSERT INTO ecom_customers (customer_id, email, password_hash, first_name, last_name, phone, birth_date, gender, customer_type, registration_date) VALUES
(seq_ecom_customers.NEXTVAL, 'mike.davis@email.com', 'hashed_password_789', 'Mike', 'Davis', '(555) 456-7890', DATE '1988-12-03', 'M', 'REGULAR', DATE '2023-05-20');

INSERT INTO ecom_customers (customer_id, email, password_hash, first_name, last_name, phone, birth_date, gender, customer_type, registration_date) VALUES
(seq_ecom_customers.NEXTVAL, 'emily.brown@email.com', 'hashed_password_abc', 'Emily', 'Brown', '(555) 321-6547', DATE '1992-09-18', 'F', 'REGULAR', DATE '2023-08-12');

INSERT INTO ecom_customers (customer_id, email, password_hash, first_name, last_name, phone, birth_date, gender, customer_type, registration_date) VALUES
(seq_ecom_customers.NEXTVAL, 'david.wilson@email.com', 'hashed_password_def', 'David', 'Wilson', '(555) 789-1234', DATE '1987-04-25', 'M', 'PREMIUM', DATE '2023-02-28');

-- =====================================================
-- 8. CUSTOMER ADDRESSES DATA
-- =====================================================

-- John Smith addresses
INSERT INTO ecom_customer_addresses (address_id, customer_id, address_type, address_line1, city, state_province, postal_code, country, is_default) VALUES
(seq_ecom_addresses.NEXTVAL, 1000, 'BOTH', '123 Main Street', 'New York', 'NY', '10001', 'USA', 'Y');

INSERT INTO ecom_customer_addresses (address_id, customer_id, address_type, address_line1, city, state_province, postal_code, country) VALUES
(seq_ecom_addresses.NEXTVAL, 1000, 'SHIPPING', '456 Work Plaza', 'New York', 'NY', '10002', 'USA');

-- Sarah Johnson addresses
INSERT INTO ecom_customer_addresses (address_id, customer_id, address_type, address_line1, city, state_province, postal_code, country, is_default) VALUES
(seq_ecom_addresses.NEXTVAL, 1001, 'BOTH', '789 Oak Avenue', 'Los Angeles', 'CA', '90210', 'USA', 'Y');

-- Mike Davis addresses
INSERT INTO ecom_customer_addresses (address_id, customer_id, address_type, address_line1, city, state_province, postal_code, country, is_default) VALUES
(seq_ecom_addresses.NEXTVAL, 1002, 'BOTH', '321 Pine Street', 'Chicago', 'IL', '60601', 'USA', 'Y');

-- Emily Brown addresses
INSERT INTO ecom_customer_addresses (address_id, customer_id, address_type, address_line1, city, state_province, postal_code, country, is_default) VALUES
(seq_ecom_addresses.NEXTVAL, 1003, 'BOTH', '654 Elm Drive', 'Miami', 'FL', '33101', 'USA', 'Y');

-- David Wilson addresses
INSERT INTO ecom_customer_addresses (address_id, customer_id, address_type, address_line1, city, state_province, postal_code, country, is_default) VALUES
(seq_ecom_addresses.NEXTVAL, 1004, 'BOTH', '987 Cedar Lane', 'Seattle', 'WA', '98101', 'USA', 'Y');

-- =====================================================
-- 9. PAYMENT METHODS DATA
-- =====================================================

-- Payment methods for customers
INSERT INTO ecom_payment_methods (payment_method_id, customer_id, method_type, card_last_four, card_type, expiry_month, expiry_year, cardholder_name, billing_address_id, is_default) VALUES
(seq_ecom_pay_methods.NEXTVAL, 1000, 'CREDIT_CARD', '1234', 'VISA', 12, 2026, 'John Smith', 1, 'Y');

INSERT INTO ecom_payment_methods (payment_method_id, customer_id, method_type, card_last_four, card_type, expiry_month, expiry_year, cardholder_name, billing_address_id, is_default) VALUES
(seq_ecom_pay_methods.NEXTVAL, 1001, 'CREDIT_CARD', '5678', 'MASTERCARD', 8, 2027, 'Sarah Johnson', 3, 'Y');

INSERT INTO ecom_payment_methods (payment_method_id, customer_id, method_type, card_last_four, card_type, expiry_month, expiry_year, cardholder_name, billing_address_id, is_default) VALUES
(seq_ecom_pay_methods.NEXTVAL, 1002, 'DEBIT_CARD', '9012', 'VISA', 5, 2025, 'Mike Davis', 4, 'Y');

INSERT INTO ecom_payment_methods (payment_method_id, customer_id, method_type, card_last_four, card_type, expiry_month, expiry_year, cardholder_name, billing_address_id, is_default) VALUES
(seq_ecom_pay_methods.NEXTVAL, 1003, 'CREDIT_CARD', '3456', 'AMEX', 10, 2026, 'Emily Brown', 5, 'Y');

INSERT INTO ecom_payment_methods (payment_method_id, customer_id, method_type, card_last_four, card_type, expiry_month, expiry_year, cardholder_name, billing_address_id, is_default) VALUES
(seq_ecom_pay_methods.NEXTVAL, 1004, 'CREDIT_CARD', '7890', 'VISA', 3, 2028, 'David Wilson', 6, 'Y');

-- =====================================================
-- 10. ORDERS DATA
-- =====================================================

-- Order 1 - John Smith (Premium customer)
INSERT INTO ecom_orders (order_id, customer_id, order_status, order_date, subtotal_amount, tax_amount, shipping_amount, total_amount, shipping_address_id, billing_address_id, payment_status) VALUES
(seq_ecom_orders.NEXTVAL, 1000, 'DELIVERED', DATE '2024-01-15', 1299.99, 103.99, 0.00, 1403.98, 1, 1, 'PAID');

-- Order items for order 1
INSERT INTO ecom_order_items (order_item_id, order_id, product_id, variant_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(seq_ecom_order_items.NEXTVAL, 10000, 1000, 1, 'TechCorp UltraBook Pro 15', 'LAPTOP-TC-001-SLV', 1, 1299.99, 1299.99);

-- Order 2 - Sarah Johnson (VIP customer)
INSERT INTO ecom_orders (order_id, customer_id, order_status, order_date, subtotal_amount, tax_amount, shipping_amount, total_amount, shipping_address_id, billing_address_id, payment_status) VALUES
(seq_ecom_orders.NEXTVAL, 1001, 'SHIPPED', DATE '2024-01-20', 1319.98, 105.60, 0.00, 1425.58, 3, 3, 'PAID');

-- Order items for order 2
INSERT INTO ecom_order_items (order_item_id, order_id, product_id, variant_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(seq_ecom_order_items.NEXTVAL, 10001, 1002, 4, 'MobilePro X12 Pro', 'PHONE-MP-001-256-BLK', 1, 1099.99, 1099.99);

INSERT INTO ecom_order_items (order_item_id, order_id, product_id, variant_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(seq_ecom_order_items.NEXTVAL, 10001, 1006, 8, 'FashionBrand Summer Dress', 'DRESS-FB-003-S-BLU', 1, 119.99, 119.99);

INSERT INTO ecom_order_items (order_item_id, order_id, product_id, variant_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(seq_ecom_order_items.NEXTVAL, 10001, 1008, NULL, 'Oracle Database Administration Guide', 'BOOK-BP-001', 1, 59.99, 59.99);

-- Order 3 - Mike Davis (Recent order)
INSERT INTO ecom_orders (order_id, customer_id, order_status, order_date, subtotal_amount, tax_amount, shipping_amount, total_amount, shipping_address_id, billing_address_id, payment_status) VALUES
(seq_ecom_orders.NEXTVAL, 1002, 'PROCESSING', DATE '2024-01-25', 389.97, 31.20, 15.99, 437.16, 4, 4, 'PAID');

-- Order items for order 3
INSERT INTO ecom_order_items (order_item_id, order_id, product_id, variant_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(seq_ecom_order_items.NEXTVAL, 10002, 1004, 6, 'FashionBrand Premium Dress Shirt', 'SHIRT-FB-001-L', 2, 79.99, 159.98);

INSERT INTO ecom_order_items (order_item_id, order_id, product_id, variant_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(seq_ecom_order_items.NEXTVAL, 10002, 1005, NULL, 'FashionBrand Classic Jeans', 'JEANS-FB-002', 1, 89.99, 89.99);

INSERT INTO ecom_order_items (order_item_id, order_id, product_id, variant_id, product_name, product_sku, quantity, unit_price, total_price) VALUES
(seq_ecom_order_items.NEXTVAL, 10002, 1007, NULL, 'HomeStyle Ergonomic Office Chair', 'CHAIR-HS-001', 1, 299.99, 299.99);

-- =====================================================
-- 11. PAYMENT TRANSACTIONS DATA
-- =====================================================

-- Payment transactions for completed orders
INSERT INTO ecom_payment_transactions (transaction_id, order_id, payment_method_id, transaction_type, amount, transaction_status, gateway_reference, processed_date) VALUES
(seq_ecom_pay_trans.NEXTVAL, 10000, 1, 'SALE', 1403.98, 'SUCCESS', 'TXN-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-001', DATE '2024-01-15');

INSERT INTO ecom_payment_transactions (transaction_id, order_id, payment_method_id, transaction_type, amount, transaction_status, gateway_reference, processed_date) VALUES
(seq_ecom_pay_trans.NEXTVAL, 10001, 2, 'SALE', 1425.58, 'SUCCESS', 'TXN-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-002', DATE '2024-01-20');

INSERT INTO ecom_payment_transactions (transaction_id, order_id, payment_method_id, transaction_type, amount, transaction_status, gateway_reference, processed_date) VALUES
(seq_ecom_pay_trans.NEXTVAL, 10002, 3, 'SALE', 437.16, 'SUCCESS', 'TXN-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-003', DATE '2024-01-25');

-- =====================================================
-- 12. COUPONS DATA
-- =====================================================

INSERT INTO ecom_coupons (coupon_id, coupon_code, coupon_name, discount_type, discount_value, minimum_order, usage_limit, valid_from, valid_until) VALUES
(seq_ecom_coupons.NEXTVAL, 'WELCOME10', 'Welcome 10% Off', 'PERCENTAGE', 10, 50, 1000, DATE '2024-01-01', DATE '2024-12-31');

INSERT INTO ecom_coupons (coupon_id, coupon_code, coupon_name, discount_type, discount_value, minimum_order, usage_limit, valid_from, valid_until) VALUES
(seq_ecom_coupons.NEXTVAL, 'SAVE50', 'Save $50 on Orders Over $500', 'FIXED_AMOUNT', 50, 500, 500, DATE '2024-01-01', DATE '2024-06-30');

INSERT INTO ecom_coupons (coupon_id, coupon_code, coupon_name, discount_type, discount_value, minimum_order, usage_limit, valid_from, valid_until) VALUES
(seq_ecom_coupons.NEXTVAL, 'FREESHIP', 'Free Shipping', 'FREE_SHIPPING', 0, 100, NULL, DATE '2024-01-01', DATE '2024-12-31');

INSERT INTO ecom_coupons (coupon_id, coupon_code, coupon_name, discount_type, discount_value, minimum_order, usage_limit, valid_from, valid_until) VALUES
(seq_ecom_coupons.NEXTVAL, 'VIP20', 'VIP 20% Discount', 'PERCENTAGE', 20, 200, 100, DATE '2024-01-01', DATE '2024-12-31');

-- =====================================================
-- 13. PRODUCT REVIEWS DATA
-- =====================================================

INSERT INTO ecom_product_reviews (review_id, product_id, customer_id, order_id, rating, review_title, review_text, is_verified, review_status, helpful_votes, total_votes, approved_date) VALUES
(seq_ecom_reviews.NEXTVAL, 1000, 1000, 10000, 5.0, 'Excellent laptop for work', 'This laptop exceeded my expectations. Fast performance, great display, and excellent build quality. Highly recommended for professionals.', 'Y', 'APPROVED', 15, 18, DATE '2024-01-20');

INSERT INTO ecom_product_reviews (review_id, product_id, customer_id, order_id, rating, review_title, review_text, is_verified, review_status, helpful_votes, total_votes, approved_date) VALUES
(seq_ecom_reviews.NEXTVAL, 1002, 1001, 10001, 4.5, 'Great phone with amazing camera', 'Love the camera quality and the phone is very responsive. Battery life is excellent. Only minor issue is it can get warm during heavy use.', 'Y', 'APPROVED', 12, 14, DATE '2024-01-25');

INSERT INTO ecom_product_reviews (review_id, product_id, customer_id, order_id, rating, review_title, review_text, is_verified, review_status, helpful_votes, total_votes, approved_date) VALUES
(seq_ecom_reviews.NEXTVAL, 1006, 1001, 10001, 5.0, 'Beautiful dress, perfect fit', 'Gorgeous dress that fits perfectly. The fabric is high quality and the color is exactly as shown. Will definitely buy more from this brand.', 'Y', 'APPROVED', 8, 9, DATE '2024-01-26');

INSERT INTO ecom_product_reviews (review_id, product_id, customer_id, rating, review_title, review_text, review_status) VALUES
(seq_ecom_reviews.NEXTVAL, 1001, 1003, 4.0, 'Powerful gaming machine', 'Great gaming desktop with excellent performance. Setup was straightforward and it handles all modern games at high settings.', 'APPROVED');

INSERT INTO ecom_product_reviews (review_id, product_id, customer_id, rating, review_title, review_text, review_status) VALUES
(seq_ecom_reviews.NEXTVAL, 1008, 1001, 5.0, 'Essential Oracle reference', 'Comprehensive guide that covers everything you need to know about Oracle DB administration. Well-written and easy to follow.', 'APPROVED');

-- =====================================================
-- 14. SHOPPING CARTS DATA (Active carts)
-- =====================================================

-- Emily's current cart
INSERT INTO ecom_shopping_carts (cart_id, customer_id, created_date, modified_date) VALUES
(seq_ecom_carts.NEXTVAL, 1003, SYSDATE - 2, SYSDATE - 1);

INSERT INTO ecom_cart_items (cart_item_id, cart_id, product_id, variant_id, quantity, unit_price) VALUES
(seq_ecom_cart_items.NEXTVAL, 1, 1003, 5, 1, 999.99);

INSERT INTO ecom_cart_items (cart_item_id, cart_id, product_id, quantity, unit_price) VALUES
(seq_ecom_cart_items.NEXTVAL, 1, 1007, 1, 299.99);

-- David's current cart
INSERT INTO ecom_shopping_carts (cart_id, customer_id, created_date, modified_date) VALUES
(seq_ecom_carts.NEXTVAL, 1004, SYSDATE - 1, SYSDATE);

INSERT INTO ecom_cart_items (cart_item_id, cart_id, product_id, variant_id, quantity, unit_price) VALUES
(seq_ecom_cart_items.NEXTVAL, 2, 1004, 7, 2, 79.99);

INSERT INTO ecom_cart_items (cart_item_id, cart_id, product_id, quantity, unit_price) VALUES
(seq_ecom_cart_items.NEXTVAL, 2, 1005, 1, 89.99);

-- =====================================================
-- 15. WISHLISTS DATA
-- =====================================================

-- Customer wishlists
INSERT INTO ecom_wishlists (wishlist_id, customer_id, wishlist_name) VALUES
(seq_ecom_wishlists.NEXTVAL, 1000, 'Tech Upgrades');

INSERT INTO ecom_wishlists (wishlist_id, customer_id, wishlist_name) VALUES
(seq_ecom_wishlists.NEXTVAL, 1001, 'Fashion Favorites');

INSERT INTO ecom_wishlists (wishlist_id, customer_id, wishlist_name) VALUES
(seq_ecom_wishlists.NEXTVAL, 1003, 'Home Office Setup');

-- Wishlist items
INSERT INTO ecom_wishlist_items (wishlist_item_id, wishlist_id, product_id, variant_id, notes) VALUES
(seq_ecom_wish_items.NEXTVAL, 1, 1001, NULL, 'For gaming setup upgrade');

INSERT INTO ecom_wishlist_items (wishlist_item_id, wishlist_id, product_id, variant_id, notes) VALUES
(seq_ecom_wish_items.NEXTVAL, 2, 1006, 9, 'For summer vacation');

INSERT INTO ecom_wishlist_items (wishlist_item_id, wishlist_id, product_id, variant_id, notes) VALUES
(seq_ecom_wish_items.NEXTVAL, 2, 1006, 10, 'Alternative color option');

INSERT INTO ecom_wishlist_items (wishlist_item_id, wishlist_id, product_id, notes) VALUES
(seq_ecom_wish_items.NEXTVAL, 3, 1007, 'Need for new home office');

INSERT INTO ecom_wishlist_items (wishlist_item_id, wishlist_id, product_id, notes) VALUES
(seq_ecom_wish_items.NEXTVAL, 3, 1000, 'Laptop for remote work');

-- =====================================================
-- 16. SAMPLE INVENTORY TRANSACTIONS
-- =====================================================

-- Sample inventory movements
INSERT INTO ecom_inventory_transactions (transaction_id, inventory_id, transaction_type, quantity_change, reference_type, reference_id, transaction_date, notes) VALUES
(seq_ecom_inv_trans.NEXTVAL, 1, 'IN', 200, 'PURCHASE', 1, DATE '2024-01-01', 'Initial stock receipt');

INSERT INTO ecom_inventory_transactions (transaction_id, inventory_id, transaction_type, quantity_change, reference_type, reference_id, transaction_date, notes) VALUES
(seq_ecom_inv_trans.NEXTVAL, 1, 'OUT', -1, 'ORDER', 10000, DATE '2024-01-15', 'Order fulfillment');

INSERT INTO ecom_inventory_transactions (transaction_id, inventory_id, transaction_type, quantity_change, reference_type, reference_id, transaction_date, notes) VALUES
(seq_ecom_inv_trans.NEXTVAL, 7, 'OUT', -1, 'ORDER', 10001, DATE '2024-01-20', 'Order fulfillment');

COMMIT;

BEGIN
    DBMS_OUTPUT.PUT_LINE('E-commerce Sample Data Loading Complete!');
    DBMS_OUTPUT.PUT_LINE('=======================================');
    DBMS_OUTPUT.PUT_LINE('✓ 8 product categories with hierarchy');
    DBMS_OUTPUT.PUT_LINE('✓ 5 brands across different industries');
    DBMS_OUTPUT.PUT_LINE('✓ 3 warehouses for distribution');
    DBMS_OUTPUT.PUT_LINE('✓ 9 products with variants and pricing');
    DBMS_OUTPUT.PUT_LINE('✓ Comprehensive inventory across warehouses');
    DBMS_OUTPUT.PUT_LINE('✓ 5 customers with complete profiles');
    DBMS_OUTPUT.PUT_LINE('✓ Customer addresses and payment methods');
    DBMS_OUTPUT.PUT_LINE('✓ 3 sample orders with items and payments');
    DBMS_OUTPUT.PUT_LINE('✓ Active shopping carts and wishlists');
    DBMS_OUTPUT.PUT_LINE('✓ Product reviews and ratings');
    DBMS_OUTPUT.PUT_LINE('✓ Promotional coupons and discounts');
    DBMS_OUTPUT.PUT_LINE('✓ Inventory transaction history');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Database ready for e-commerce application development!');
END;
/
