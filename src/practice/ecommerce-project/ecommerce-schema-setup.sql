-- =====================================================
-- E-COMMERCE DATABASE SCHEMA SETUP
-- =====================================================
-- Project: Oracle Database Learning - Lesson 6 Practice
-- Description: Complete e-commerce platform database schema
-- Author: Oracle Learning Project
-- Created: 2024
-- =====================================================

-- Enable server output for feedback
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Starting E-commerce Database Schema Setup...');
    DBMS_OUTPUT.PUT_LINE('============================================');
END;
/

-- =====================================================
-- 1. CUSTOMER MANAGEMENT
-- =====================================================

-- Customer accounts table
CREATE TABLE ecom_customers (
    customer_id         NUMBER(10) PRIMARY KEY,
    email              VARCHAR2(100) NOT NULL UNIQUE,
    password_hash      VARCHAR2(255) NOT NULL,
    first_name         VARCHAR2(50) NOT NULL,
    last_name          VARCHAR2(50) NOT NULL,
    phone              VARCHAR2(20),
    birth_date         DATE,
    gender             CHAR(1) CHECK (gender IN ('M', 'F', 'O')),
    customer_type      VARCHAR2(20) DEFAULT 'REGULAR' CHECK (customer_type IN ('REGULAR', 'PREMIUM', 'VIP')),
    account_status     VARCHAR2(20) DEFAULT 'ACTIVE' CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    registration_date  DATE DEFAULT SYSDATE,
    last_login         TIMESTAMP,
    created_by         VARCHAR2(50) DEFAULT USER,
    created_date       DATE DEFAULT SYSDATE,
    modified_by        VARCHAR2(50) DEFAULT USER,
    modified_date      DATE DEFAULT SYSDATE
);

-- Customer addresses
CREATE TABLE ecom_customer_addresses (
    address_id         NUMBER(10) PRIMARY KEY,
    customer_id        NUMBER(10) NOT NULL,
    address_type       VARCHAR2(20) NOT NULL CHECK (address_type IN ('BILLING', 'SHIPPING', 'BOTH')),
    address_line1      VARCHAR2(100) NOT NULL,
    address_line2      VARCHAR2(100),
    city               VARCHAR2(50) NOT NULL,
    state_province     VARCHAR2(50) NOT NULL,
    postal_code        VARCHAR2(20) NOT NULL,
    country            VARCHAR2(50) NOT NULL,
    is_default         CHAR(1) DEFAULT 'N' CHECK (is_default IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_addr_customer FOREIGN KEY (customer_id) REFERENCES ecom_customers(customer_id)
);

-- =====================================================
-- 2. PRODUCT CATALOG
-- =====================================================

-- Product categories
CREATE TABLE ecom_categories (
    category_id        NUMBER(10) PRIMARY KEY,
    category_name      VARCHAR2(100) NOT NULL,
    parent_category_id NUMBER(10),
    category_path      VARCHAR2(500),
    description        CLOB,
    display_order      NUMBER(3) DEFAULT 0,
    is_active          CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_cat_parent FOREIGN KEY (parent_category_id) REFERENCES ecom_categories(category_id)
);

-- Brands
CREATE TABLE ecom_brands (
    brand_id           NUMBER(10) PRIMARY KEY,
    brand_name         VARCHAR2(100) NOT NULL UNIQUE,
    brand_logo_url     VARCHAR2(255),
    description        CLOB,
    website_url        VARCHAR2(255),
    is_active          CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE
);

-- Products
CREATE TABLE ecom_products (
    product_id         NUMBER(10) PRIMARY KEY,
    product_code       VARCHAR2(50) NOT NULL UNIQUE,
    product_name       VARCHAR2(200) NOT NULL,
    category_id        NUMBER(10) NOT NULL,
    brand_id           NUMBER(10),
    short_description  VARCHAR2(500),
    long_description   CLOB,
    base_price         NUMBER(10,2) NOT NULL CHECK (base_price >= 0),
    cost_price         NUMBER(10,2) CHECK (cost_price >= 0),
    weight             NUMBER(8,2),
    dimensions         VARCHAR2(100),
    product_status     VARCHAR2(20) DEFAULT 'ACTIVE' CHECK (product_status IN ('ACTIVE', 'INACTIVE', 'DISCONTINUED')),
    is_featured        CHAR(1) DEFAULT 'N' CHECK (is_featured IN ('Y', 'N')),
    meta_title         VARCHAR2(200),
    meta_description   VARCHAR2(500),
    tags               VARCHAR2(500),
    created_date       DATE DEFAULT SYSDATE,
    modified_date      DATE DEFAULT SYSDATE,
    CONSTRAINT fk_prod_category FOREIGN KEY (category_id) REFERENCES ecom_categories(category_id),
    CONSTRAINT fk_prod_brand FOREIGN KEY (brand_id) REFERENCES ecom_brands(brand_id)
);

-- Product variants (SKUs)
CREATE TABLE ecom_product_variants (
    variant_id         NUMBER(10) PRIMARY KEY,
    product_id         NUMBER(10) NOT NULL,
    sku_code           VARCHAR2(50) NOT NULL UNIQUE,
    variant_name       VARCHAR2(100),
    size_value         VARCHAR2(20),
    color_value        VARCHAR2(50),
    style_value        VARCHAR2(50),
    material_value     VARCHAR2(50),
    price_adjustment   NUMBER(10,2) DEFAULT 0,
    weight_adjustment  NUMBER(8,2) DEFAULT 0,
    is_default         CHAR(1) DEFAULT 'N' CHECK (is_default IN ('Y', 'N')),
    is_active          CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_variant_product FOREIGN KEY (product_id) REFERENCES ecom_products(product_id)
);

-- Product images
CREATE TABLE ecom_product_images (
    image_id           NUMBER(10) PRIMARY KEY,
    product_id         NUMBER(10) NOT NULL,
    variant_id         NUMBER(10),
    image_url          VARCHAR2(500) NOT NULL,
    image_alt_text     VARCHAR2(200),
    image_type         VARCHAR2(20) DEFAULT 'PRODUCT' CHECK (image_type IN ('PRODUCT', 'THUMBNAIL', 'GALLERY')),
    display_order      NUMBER(3) DEFAULT 0,
    is_primary         CHAR(1) DEFAULT 'N' CHECK (is_primary IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_img_product FOREIGN KEY (product_id) REFERENCES ecom_products(product_id),
    CONSTRAINT fk_img_variant FOREIGN KEY (variant_id) REFERENCES ecom_product_variants(variant_id)
);

-- =====================================================
-- 3. INVENTORY MANAGEMENT
-- =====================================================

-- Warehouses
CREATE TABLE ecom_warehouses (
    warehouse_id       NUMBER(10) PRIMARY KEY,
    warehouse_code     VARCHAR2(20) NOT NULL UNIQUE,
    warehouse_name     VARCHAR2(100) NOT NULL,
    address_line1      VARCHAR2(100) NOT NULL,
    address_line2      VARCHAR2(100),
    city               VARCHAR2(50) NOT NULL,
    state_province     VARCHAR2(50) NOT NULL,
    postal_code        VARCHAR2(20) NOT NULL,
    country            VARCHAR2(50) NOT NULL,
    phone              VARCHAR2(20),
    email              VARCHAR2(100),
    manager_name       VARCHAR2(100),
    is_active          CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE
);

-- Inventory
CREATE TABLE ecom_inventory (
    inventory_id       NUMBER(10) PRIMARY KEY,
    product_id         NUMBER(10) NOT NULL,
    variant_id         NUMBER(10),
    warehouse_id       NUMBER(10) NOT NULL,
    quantity_available NUMBER(10) DEFAULT 0 CHECK (quantity_available >= 0),
    quantity_reserved  NUMBER(10) DEFAULT 0 CHECK (quantity_reserved >= 0),
    quantity_ordered   NUMBER(10) DEFAULT 0 CHECK (quantity_ordered >= 0),
    reorder_level      NUMBER(10) DEFAULT 10,
    max_stock_level    NUMBER(10),
    last_updated       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_inv_product FOREIGN KEY (product_id) REFERENCES ecom_products(product_id),
    CONSTRAINT fk_inv_variant FOREIGN KEY (variant_id) REFERENCES ecom_product_variants(variant_id),
    CONSTRAINT fk_inv_warehouse FOREIGN KEY (warehouse_id) REFERENCES ecom_warehouses(warehouse_id),
    CONSTRAINT uk_inv_prod_var_wh UNIQUE (product_id, variant_id, warehouse_id)
);

-- Inventory transactions
CREATE TABLE ecom_inventory_transactions (
    transaction_id     NUMBER(10) PRIMARY KEY,
    inventory_id       NUMBER(10) NOT NULL,
    transaction_type   VARCHAR2(20) NOT NULL CHECK (transaction_type IN ('IN', 'OUT', 'TRANSFER', 'ADJUSTMENT')),
    quantity_change    NUMBER(10) NOT NULL,
    reference_type     VARCHAR2(20),
    reference_id       NUMBER(10),
    transaction_date   DATE DEFAULT SYSDATE,
    notes              VARCHAR2(500),
    created_by         VARCHAR2(50) DEFAULT USER,
    CONSTRAINT fk_invt_inventory FOREIGN KEY (inventory_id) REFERENCES ecom_inventory(inventory_id)
);

-- =====================================================
-- 4. SHOPPING CART & WISHLIST
-- =====================================================

-- Shopping carts
CREATE TABLE ecom_shopping_carts (
    cart_id            NUMBER(10) PRIMARY KEY,
    customer_id        NUMBER(10),
    session_id         VARCHAR2(100),
    created_date       DATE DEFAULT SYSDATE,
    modified_date      DATE DEFAULT SYSDATE,
    expires_date       DATE DEFAULT SYSDATE + 30,
    CONSTRAINT fk_cart_customer FOREIGN KEY (customer_id) REFERENCES ecom_customers(customer_id)
);

-- Cart items
CREATE TABLE ecom_cart_items (
    cart_item_id       NUMBER(10) PRIMARY KEY,
    cart_id            NUMBER(10) NOT NULL,
    product_id         NUMBER(10) NOT NULL,
    variant_id         NUMBER(10),
    quantity           NUMBER(5) NOT NULL CHECK (quantity > 0),
    unit_price         NUMBER(10,2) NOT NULL,
    added_date         DATE DEFAULT SYSDATE,
    CONSTRAINT fk_cartitem_cart FOREIGN KEY (cart_id) REFERENCES ecom_shopping_carts(cart_id),
    CONSTRAINT fk_cartitem_product FOREIGN KEY (product_id) REFERENCES ecom_products(product_id),
    CONSTRAINT fk_cartitem_variant FOREIGN KEY (variant_id) REFERENCES ecom_product_variants(variant_id)
);

-- Wishlists
CREATE TABLE ecom_wishlists (
    wishlist_id        NUMBER(10) PRIMARY KEY,
    customer_id        NUMBER(10) NOT NULL,
    wishlist_name      VARCHAR2(100) DEFAULT 'My Wishlist',
    is_public          CHAR(1) DEFAULT 'N' CHECK (is_public IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_wish_customer FOREIGN KEY (customer_id) REFERENCES ecom_customers(customer_id)
);

-- Wishlist items
CREATE TABLE ecom_wishlist_items (
    wishlist_item_id   NUMBER(10) PRIMARY KEY,
    wishlist_id        NUMBER(10) NOT NULL,
    product_id         NUMBER(10) NOT NULL,
    variant_id         NUMBER(10),
    added_date         DATE DEFAULT SYSDATE,
    notes              VARCHAR2(500),
    CONSTRAINT fk_wishitem_wishlist FOREIGN KEY (wishlist_id) REFERENCES ecom_wishlists(wishlist_id),
    CONSTRAINT fk_wishitem_product FOREIGN KEY (product_id) REFERENCES ecom_products(product_id),
    CONSTRAINT fk_wishitem_variant FOREIGN KEY (variant_id) REFERENCES ecom_product_variants(variant_id)
);

-- =====================================================
-- 5. ORDER MANAGEMENT
-- =====================================================

-- Orders
CREATE TABLE ecom_orders (
    order_id           NUMBER(10) PRIMARY KEY,
    order_number       VARCHAR2(50) NOT NULL UNIQUE,
    customer_id        NUMBER(10),
    order_status       VARCHAR2(20) DEFAULT 'PENDING' CHECK (order_status IN ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED')),
    order_date         DATE DEFAULT SYSDATE,
    subtotal_amount    NUMBER(12,2) NOT NULL CHECK (subtotal_amount >= 0),
    tax_amount         NUMBER(12,2) DEFAULT 0 CHECK (tax_amount >= 0),
    shipping_amount    NUMBER(10,2) DEFAULT 0 CHECK (shipping_amount >= 0),
    discount_amount    NUMBER(10,2) DEFAULT 0 CHECK (discount_amount >= 0),
    total_amount       NUMBER(12,2) NOT NULL CHECK (total_amount >= 0),
    currency_code      VARCHAR2(3) DEFAULT 'USD',
    shipping_address_id NUMBER(10),
    billing_address_id  NUMBER(10),
    payment_status     VARCHAR2(20) DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'PARTIAL', 'FAILED', 'REFUNDED')),
    shipping_method    VARCHAR2(50),
    tracking_number    VARCHAR2(100),
    estimated_delivery DATE,
    notes              CLOB,
    created_date       DATE DEFAULT SYSDATE,
    modified_date      DATE DEFAULT SYSDATE,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) REFERENCES ecom_customers(customer_id),
    CONSTRAINT fk_order_ship_addr FOREIGN KEY (shipping_address_id) REFERENCES ecom_customer_addresses(address_id),
    CONSTRAINT fk_order_bill_addr FOREIGN KEY (billing_address_id) REFERENCES ecom_customer_addresses(address_id)
);

-- Order items
CREATE TABLE ecom_order_items (
    order_item_id      NUMBER(10) PRIMARY KEY,
    order_id           NUMBER(10) NOT NULL,
    product_id         NUMBER(10) NOT NULL,
    variant_id         NUMBER(10),
    product_name       VARCHAR2(200) NOT NULL,
    product_sku        VARCHAR2(50),
    quantity           NUMBER(5) NOT NULL CHECK (quantity > 0),
    unit_price         NUMBER(10,2) NOT NULL CHECK (unit_price >= 0),
    total_price        NUMBER(12,2) NOT NULL CHECK (total_price >= 0),
    item_status        VARCHAR2(20) DEFAULT 'ORDERED' CHECK (item_status IN ('ORDERED', 'BACKORDERED', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED')),
    CONSTRAINT fk_orderitem_order FOREIGN KEY (order_id) REFERENCES ecom_orders(order_id),
    CONSTRAINT fk_orderitem_product FOREIGN KEY (product_id) REFERENCES ecom_products(product_id),
    CONSTRAINT fk_orderitem_variant FOREIGN KEY (variant_id) REFERENCES ecom_product_variants(variant_id)
);

-- =====================================================
-- 6. PAYMENT PROCESSING
-- =====================================================

-- Payment methods
CREATE TABLE ecom_payment_methods (
    payment_method_id  NUMBER(10) PRIMARY KEY,
    customer_id        NUMBER(10) NOT NULL,
    method_type        VARCHAR2(20) NOT NULL CHECK (method_type IN ('CREDIT_CARD', 'DEBIT_CARD', 'PAYPAL', 'BANK_TRANSFER', 'DIGITAL_WALLET')),
    card_last_four     VARCHAR2(4),
    card_type          VARCHAR2(20),
    expiry_month       NUMBER(2),
    expiry_year        NUMBER(4),
    cardholder_name    VARCHAR2(100),
    billing_address_id NUMBER(10),
    is_default         CHAR(1) DEFAULT 'N' CHECK (is_default IN ('Y', 'N')),
    is_active          CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES ecom_customers(customer_id),
    CONSTRAINT fk_payment_address FOREIGN KEY (billing_address_id) REFERENCES ecom_customer_addresses(address_id)
);

-- Payment transactions
CREATE TABLE ecom_payment_transactions (
    transaction_id     NUMBER(10) PRIMARY KEY,
    order_id           NUMBER(10) NOT NULL,
    payment_method_id  NUMBER(10),
    transaction_type   VARCHAR2(20) NOT NULL CHECK (transaction_type IN ('AUTHORIZE', 'CAPTURE', 'SALE', 'REFUND', 'VOID')),
    amount             NUMBER(12,2) NOT NULL CHECK (amount >= 0),
    currency_code      VARCHAR2(3) DEFAULT 'USD',
    transaction_status VARCHAR2(20) DEFAULT 'PENDING' CHECK (transaction_status IN ('PENDING', 'SUCCESS', 'FAILED', 'CANCELLED')),
    gateway_reference  VARCHAR2(100),
    gateway_response   CLOB,
    processed_date     DATE,
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT fk_paytr_order FOREIGN KEY (order_id) REFERENCES ecom_orders(order_id),
    CONSTRAINT fk_paytr_method FOREIGN KEY (payment_method_id) REFERENCES ecom_payment_methods(payment_method_id)
);

-- =====================================================
-- 7. PROMOTIONS & DISCOUNTS
-- =====================================================

-- Coupons
CREATE TABLE ecom_coupons (
    coupon_id          NUMBER(10) PRIMARY KEY,
    coupon_code        VARCHAR2(50) NOT NULL UNIQUE,
    coupon_name        VARCHAR2(100) NOT NULL,
    discount_type      VARCHAR2(20) NOT NULL CHECK (discount_type IN ('PERCENTAGE', 'FIXED_AMOUNT', 'FREE_SHIPPING')),
    discount_value     NUMBER(10,2) NOT NULL CHECK (discount_value >= 0),
    minimum_order      NUMBER(10,2) DEFAULT 0,
    maximum_discount   NUMBER(10,2),
    usage_limit        NUMBER(5),
    usage_per_customer NUMBER(3) DEFAULT 1,
    valid_from         DATE NOT NULL,
    valid_until        DATE NOT NULL,
    is_active          CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date       DATE DEFAULT SYSDATE,
    CONSTRAINT chk_coupon_dates CHECK (valid_until >= valid_from)
);

-- Coupon usage tracking
CREATE TABLE ecom_coupon_usage (
    usage_id           NUMBER(10) PRIMARY KEY,
    coupon_id          NUMBER(10) NOT NULL,
    order_id           NUMBER(10) NOT NULL,
    customer_id        NUMBER(10),
    discount_amount    NUMBER(10,2) NOT NULL,
    used_date          DATE DEFAULT SYSDATE,
    CONSTRAINT fk_usage_coupon FOREIGN KEY (coupon_id) REFERENCES ecom_coupons(coupon_id),
    CONSTRAINT fk_usage_order FOREIGN KEY (order_id) REFERENCES ecom_orders(order_id),
    CONSTRAINT fk_usage_customer FOREIGN KEY (customer_id) REFERENCES ecom_customers(customer_id)
);

-- =====================================================
-- 8. REVIEWS & RATINGS
-- =====================================================

-- Product reviews
CREATE TABLE ecom_product_reviews (
    review_id          NUMBER(10) PRIMARY KEY,
    product_id         NUMBER(10) NOT NULL,
    customer_id        NUMBER(10) NOT NULL,
    order_id           NUMBER(10),
    rating             NUMBER(2,1) NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_title       VARCHAR2(200),
    review_text        CLOB,
    is_verified        CHAR(1) DEFAULT 'N' CHECK (is_verified IN ('Y', 'N')),
    is_featured        CHAR(1) DEFAULT 'N' CHECK (is_featured IN ('Y', 'N')),
    helpful_votes      NUMBER(5) DEFAULT 0,
    total_votes        NUMBER(5) DEFAULT 0,
    review_status      VARCHAR2(20) DEFAULT 'PENDING' CHECK (review_status IN ('PENDING', 'APPROVED', 'REJECTED', 'HIDDEN')),
    created_date       DATE DEFAULT SYSDATE,
    approved_date      DATE,
    CONSTRAINT fk_review_product FOREIGN KEY (product_id) REFERENCES ecom_products(product_id),
    CONSTRAINT fk_review_customer FOREIGN KEY (customer_id) REFERENCES ecom_customers(customer_id),
    CONSTRAINT fk_review_order FOREIGN KEY (order_id) REFERENCES ecom_orders(order_id)
);

-- =====================================================
-- 9. SEQUENCES FOR PRIMARY KEYS
-- =====================================================

-- Customer sequences
CREATE SEQUENCE seq_ecom_customers START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_addresses START WITH 1 INCREMENT BY 1;

-- Product sequences
CREATE SEQUENCE seq_ecom_categories START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_brands START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_products START WITH 1000 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_variants START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_images START WITH 1 INCREMENT BY 1;

-- Inventory sequences
CREATE SEQUENCE seq_ecom_warehouses START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_inventory START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_inv_trans START WITH 1 INCREMENT BY 1;

-- Cart sequences
CREATE SEQUENCE seq_ecom_carts START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_cart_items START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_wishlists START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_wish_items START WITH 1 INCREMENT BY 1;

-- Order sequences
CREATE SEQUENCE seq_ecom_orders START WITH 10000 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_order_items START WITH 1 INCREMENT BY 1;

-- Payment sequences
CREATE SEQUENCE seq_ecom_pay_methods START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_pay_trans START WITH 1 INCREMENT BY 1;

-- Promotion sequences
CREATE SEQUENCE seq_ecom_coupons START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ecom_usage START WITH 1 INCREMENT BY 1;

-- Review sequences
CREATE SEQUENCE seq_ecom_reviews START WITH 1 INCREMENT BY 1;

-- =====================================================
-- 10. INDEXES FOR PERFORMANCE
-- =====================================================

-- Customer indexes
CREATE INDEX idx_customers_email ON ecom_customers(email);
CREATE INDEX idx_customers_status ON ecom_customers(account_status);
CREATE INDEX idx_customers_type ON ecom_customers(customer_type);
CREATE INDEX idx_addresses_customer ON ecom_customer_addresses(customer_id);

-- Product indexes
CREATE INDEX idx_products_category ON ecom_products(category_id);
CREATE INDEX idx_products_brand ON ecom_products(brand_id);
CREATE INDEX idx_products_status ON ecom_products(product_status);
CREATE INDEX idx_products_featured ON ecom_products(is_featured);
CREATE INDEX idx_products_name ON ecom_products(UPPER(product_name));
CREATE INDEX idx_variants_product ON ecom_product_variants(product_id);
CREATE INDEX idx_images_product ON ecom_product_images(product_id);

-- Inventory indexes
CREATE INDEX idx_inventory_product ON ecom_inventory(product_id);
CREATE INDEX idx_inventory_warehouse ON ecom_inventory(warehouse_id);
CREATE INDEX idx_inv_trans_inventory ON ecom_inventory_transactions(inventory_id);
CREATE INDEX idx_inv_trans_date ON ecom_inventory_transactions(transaction_date);

-- Cart indexes
CREATE INDEX idx_carts_customer ON ecom_shopping_carts(customer_id);
CREATE INDEX idx_carts_session ON ecom_shopping_carts(session_id);
CREATE INDEX idx_cart_items_cart ON ecom_cart_items(cart_id);

-- Order indexes
CREATE INDEX idx_orders_customer ON ecom_orders(customer_id);
CREATE INDEX idx_orders_status ON ecom_orders(order_status);
CREATE INDEX idx_orders_date ON ecom_orders(order_date);
CREATE INDEX idx_order_items_order ON ecom_order_items(order_id);
CREATE INDEX idx_order_items_product ON ecom_order_items(product_id);

-- Payment indexes
CREATE INDEX idx_pay_methods_customer ON ecom_payment_methods(customer_id);
CREATE INDEX idx_pay_trans_order ON ecom_payment_transactions(order_id);
CREATE INDEX idx_pay_trans_status ON ecom_payment_transactions(transaction_status);

-- Promotion indexes
CREATE INDEX idx_coupons_code ON ecom_coupons(coupon_code);
CREATE INDEX idx_coupons_active ON ecom_coupons(is_active, valid_from, valid_until);
CREATE INDEX idx_usage_coupon ON ecom_coupon_usage(coupon_id);

-- Review indexes
CREATE INDEX idx_reviews_product ON ecom_product_reviews(product_id);
CREATE INDEX idx_reviews_customer ON ecom_product_reviews(customer_id);
CREATE INDEX idx_reviews_status ON ecom_product_reviews(review_status);

-- =====================================================
-- 11. TRIGGERS FOR BUSINESS LOGIC
-- =====================================================

-- Auto-generate order numbers
CREATE OR REPLACE TRIGGER trg_orders_order_number
    BEFORE INSERT ON ecom_orders
    FOR EACH ROW
BEGIN
    IF :NEW.order_number IS NULL THEN
        :NEW.order_number := 'ORD-' || TO_CHAR(SYSDATE, 'YYYY') || '-' || LPAD(seq_ecom_orders.NEXTVAL, 6, '0');
    END IF;
END;
/

-- Update modified date on customer changes
CREATE OR REPLACE TRIGGER trg_customers_modified
    BEFORE UPDATE ON ecom_customers
    FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
    :NEW.modified_by := USER;
END;
/

-- Update cart modified date
CREATE OR REPLACE TRIGGER trg_carts_modified
    BEFORE UPDATE ON ecom_shopping_carts
    FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- Update order total when items change
CREATE OR REPLACE TRIGGER trg_order_items_total
    BEFORE INSERT OR UPDATE ON ecom_order_items
    FOR EACH ROW
BEGIN
    :NEW.total_price := :NEW.quantity * :NEW.unit_price;
END;
/

-- Update inventory on order item changes
CREATE OR REPLACE TRIGGER trg_order_items_inventory
    AFTER INSERT OR UPDATE OR DELETE ON ecom_order_items
    FOR EACH ROW
DECLARE
    v_inventory_id NUMBER;
    v_quantity_change NUMBER := 0;
BEGIN
    -- Calculate quantity change
    IF INSERTING THEN
        v_quantity_change := -:NEW.quantity; -- Reserve inventory
    ELSIF UPDATING THEN
        v_quantity_change := :OLD.quantity - :NEW.quantity; -- Adjust reservation
    ELSIF DELETING THEN
        v_quantity_change := :OLD.quantity; -- Release inventory
    END IF;
    
    -- Find inventory record
    IF INSERTING OR UPDATING THEN
        SELECT inventory_id INTO v_inventory_id
        FROM ecom_inventory
        WHERE product_id = :NEW.product_id
          AND (variant_id = :NEW.variant_id OR (variant_id IS NULL AND :NEW.variant_id IS NULL))
          AND ROWNUM = 1;
    ELSIF DELETING THEN
        SELECT inventory_id INTO v_inventory_id
        FROM ecom_inventory
        WHERE product_id = :OLD.product_id
          AND (variant_id = :OLD.variant_id OR (variant_id IS NULL AND :OLD.variant_id IS NULL))
          AND ROWNUM = 1;
    END IF;
    
    -- Update inventory reservation
    UPDATE ecom_inventory
    SET quantity_reserved = quantity_reserved + v_quantity_change,
        last_updated = SYSDATE
    WHERE inventory_id = v_inventory_id;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL; -- Inventory record not found, skip update
END;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('E-commerce Database Schema Setup Complete!');
    DBMS_OUTPUT.PUT_LINE('============================================');
    DBMS_OUTPUT.PUT_LINE('✓ 20+ tables created for complete e-commerce platform');
    DBMS_OUTPUT.PUT_LINE('✓ Sequences created for auto-incrementing IDs');
    DBMS_OUTPUT.PUT_LINE('✓ Indexes created for optimal performance');
    DBMS_OUTPUT.PUT_LINE('✓ Triggers created for business logic automation');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Next steps:');
    DBMS_OUTPUT.PUT_LINE('1. Run ecommerce-sample-data.sql to populate with test data');
    DBMS_OUTPUT.PUT_LINE('2. Run ecommerce-procedures.sql for business logic procedures');
    DBMS_OUTPUT.PUT_LINE('3. Run ecommerce-views.sql for reporting views');
END;
/
