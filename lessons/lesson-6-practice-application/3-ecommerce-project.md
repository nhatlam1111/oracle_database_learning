# E-Commerce Database System Project

This comprehensive project guides you through building a complete e-commerce database system from scratch. You'll apply all Oracle Database concepts learned in previous lessons to create a real-world, scalable solution.

## 🎯 Project Overview

**Duration**: 1-2 weeks
**Complexity**: High
**Skills Applied**: All lessons 1-5 concepts
**Deliverable**: Complete e-commerce database with management system

## 📋 Business Requirements

### **Core Functionality**
1. **Customer Management**: Registration, profiles, addresses, preferences
2. **Product Catalog**: Categories, products, inventory, pricing
3. **Order Processing**: Shopping cart, checkout, payment, fulfillment
4. **Inventory Management**: Stock tracking, reordering, supplier management
5. **Reporting and Analytics**: Sales reports, customer analytics, inventory reports

### **Advanced Features**
1. **Multi-tier Pricing**: Customer groups, bulk discounts, promotional pricing
2. **Shipping Integration**: Multiple carriers, shipping calculations, tracking
3. **Review System**: Product reviews, ratings, moderation
4. **Recommendation Engine**: Purchase history analysis, related products
5. **Audit and Compliance**: Complete transaction audit trails

## 🏗️ Database Architecture

### **Core Tables**

#### **Customer Management**
- `customers` - Customer profiles and contact information
- `customer_addresses` - Multiple addresses per customer
- `customer_groups` - Customer segmentation for pricing
- `customer_preferences` - Shopping preferences and settings

#### **Product Catalog**
- `categories` - Hierarchical product categories
- `products` - Product master data
- `product_variants` - Size, color, model variations
- `product_images` - Multiple images per product
- `product_reviews` - Customer reviews and ratings

#### **Inventory Management**
- `inventory` - Real-time stock levels
- `suppliers` - Supplier information
- `purchase_orders` - Inventory replenishment
- `purchase_order_items` - PO line items

#### **Order Processing**
- `shopping_carts` - Temporary customer carts
- `cart_items` - Items in shopping carts
- `orders` - Order headers
- `order_items` - Order line items
- `order_status_history` - Order lifecycle tracking

#### **Payment and Shipping**
- `payment_methods` - Customer payment options
- `payments` - Payment transactions
- `shipping_methods` - Available shipping options
- `shipments` - Package tracking information

#### **Promotions and Discounts**
- `promotions` - Marketing campaigns
- `discount_rules` - Pricing rules engine
- `coupon_codes` - Promotional codes

## 📝 Detailed Implementation Guide

### **Phase 1: Database Structure (Week 1, Days 1-3)**

#### **Day 1: Core Tables Creation**

```sql
-- Customer Management Tables
CREATE TABLE customer_groups (
    group_id NUMBER(4) PRIMARY KEY,
    group_name VARCHAR2(50) NOT NULL UNIQUE,
    discount_percentage NUMBER(5,2) DEFAULT 0,
    min_order_amount NUMBER(10,2) DEFAULT 0,
    description VARCHAR2(200),
    created_date DATE DEFAULT SYSDATE,
    status VARCHAR2(10) DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE'))
);

CREATE TABLE customers (
    customer_id NUMBER(10) PRIMARY KEY,
    customer_group_id NUMBER(4) DEFAULT 1,
    email VARCHAR2(100) NOT NULL UNIQUE,
    password_hash VARCHAR2(64) NOT NULL,
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    phone VARCHAR2(20),
    birth_date DATE,
    gender VARCHAR2(1) CHECK (gender IN ('M', 'F', 'O')),
    registration_date DATE DEFAULT SYSDATE,
    last_login_date DATE,
    email_verified VARCHAR2(1) DEFAULT 'N' CHECK (email_verified IN ('Y', 'N')),
    account_status VARCHAR2(15) DEFAULT 'ACTIVE' 
        CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED', 'CLOSED')),
    total_orders NUMBER(6) DEFAULT 0,
    total_spent NUMBER(12,2) DEFAULT 0,
    loyalty_points NUMBER(8) DEFAULT 0,
    CONSTRAINT cust_group_fk FOREIGN KEY (customer_group_id) REFERENCES customer_groups(group_id)
);

CREATE TABLE customer_addresses (
    address_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10) NOT NULL,
    address_type VARCHAR2(10) DEFAULT 'SHIPPING' CHECK (address_type IN ('BILLING', 'SHIPPING')),
    is_default VARCHAR2(1) DEFAULT 'N' CHECK (is_default IN ('Y', 'N')),
    first_name VARCHAR2(50) NOT NULL,
    last_name VARCHAR2(50) NOT NULL,
    company VARCHAR2(100),
    address_line1 VARCHAR2(100) NOT NULL,
    address_line2 VARCHAR2(100),
    city VARCHAR2(50) NOT NULL,
    state_province VARCHAR2(50) NOT NULL,
    postal_code VARCHAR2(20) NOT NULL,
    country VARCHAR2(50) NOT NULL DEFAULT 'USA',
    phone VARCHAR2(20),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT addr_cust_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);
```

#### **Day 2: Product Catalog Tables**

```sql
-- Product Catalog Tables
CREATE TABLE categories (
    category_id NUMBER(6) PRIMARY KEY,
    parent_category_id NUMBER(6),
    category_name VARCHAR2(100) NOT NULL,
    category_description CLOB,
    category_image VARCHAR2(200),
    sort_order NUMBER(4) DEFAULT 0,
    meta_title VARCHAR2(100),
    meta_description VARCHAR2(200),
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT cat_parent_fk FOREIGN KEY (parent_category_id) REFERENCES categories(category_id)
);

CREATE TABLE suppliers (
    supplier_id NUMBER(6) PRIMARY KEY,
    supplier_name VARCHAR2(100) NOT NULL,
    contact_person VARCHAR2(100),
    email VARCHAR2(100),
    phone VARCHAR2(20),
    address VARCHAR2(200),
    city VARCHAR2(50),
    state_province VARCHAR2(50),
    country VARCHAR2(50),
    postal_code VARCHAR2(20),
    tax_id VARCHAR2(50),
    payment_terms VARCHAR2(50),
    rating NUMBER(3,1) CHECK (rating BETWEEN 1 AND 5),
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE
);

CREATE TABLE products (
    product_id NUMBER(10) PRIMARY KEY,
    category_id NUMBER(6) NOT NULL,
    supplier_id NUMBER(6),
    sku VARCHAR2(50) NOT NULL UNIQUE,
    product_name VARCHAR2(200) NOT NULL,
    short_description VARCHAR2(500),
    long_description CLOB,
    base_price NUMBER(10,2) NOT NULL CHECK (base_price > 0),
    cost_price NUMBER(10,2) CHECK (cost_price >= 0),
    weight NUMBER(8,3),
    dimensions VARCHAR2(50),
    brand VARCHAR2(100),
    model VARCHAR2(100),
    color VARCHAR2(50),
    size VARCHAR2(20),
    material VARCHAR2(100),
    care_instructions CLOB,
    warranty_period NUMBER(3),
    is_digital VARCHAR2(1) DEFAULT 'N' CHECK (is_digital IN ('Y', 'N')),
    requires_shipping VARCHAR2(1) DEFAULT 'Y' CHECK (requires_shipping IN ('Y', 'N')),
    tax_class VARCHAR2(20) DEFAULT 'STANDARD',
    meta_title VARCHAR2(100),
    meta_description VARCHAR2(200),
    meta_keywords VARCHAR2(200),
    is_active VARCHAR2(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    is_featured VARCHAR2(1) DEFAULT 'N' CHECK (is_featured IN ('Y', 'N')),
    sort_order NUMBER(6) DEFAULT 0,
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT prod_cat_fk FOREIGN KEY (category_id) REFERENCES categories(category_id),
    CONSTRAINT prod_supp_fk FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

CREATE TABLE product_images (
    image_id NUMBER(10) PRIMARY KEY,
    product_id NUMBER(10) NOT NULL,
    image_url VARCHAR2(300) NOT NULL,
    alt_text VARCHAR2(200),
    sort_order NUMBER(3) DEFAULT 0,
    is_primary VARCHAR2(1) DEFAULT 'N' CHECK (is_primary IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    CONSTRAINT img_prod_fk FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);
```

#### **Day 3: Inventory and Order Tables**

```sql
-- Inventory Management
CREATE TABLE inventory (
    product_id NUMBER(10) PRIMARY KEY,
    quantity_on_hand NUMBER(8) DEFAULT 0 CHECK (quantity_on_hand >= 0),
    quantity_allocated NUMBER(8) DEFAULT 0 CHECK (quantity_allocated >= 0),
    quantity_available AS (quantity_on_hand - quantity_allocated),
    reorder_level NUMBER(6) DEFAULT 0,
    reorder_quantity NUMBER(6) DEFAULT 0,
    last_stock_check DATE DEFAULT SYSDATE,
    location VARCHAR2(50),
    bin_location VARCHAR2(20),
    CONSTRAINT inv_prod_fk FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Shopping Cart
CREATE TABLE shopping_carts (
    cart_id NUMBER(10) PRIMARY KEY,
    customer_id NUMBER(10),
    session_id VARCHAR2(100),
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    expires_date DATE DEFAULT SYSDATE + 7,
    CONSTRAINT cart_cust_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE cart_items (
    cart_id NUMBER(10),
    product_id NUMBER(10),
    quantity NUMBER(4) NOT NULL CHECK (quantity > 0),
    unit_price NUMBER(10,2) NOT NULL,
    added_date DATE DEFAULT SYSDATE,
    PRIMARY KEY (cart_id, product_id),
    CONSTRAINT ci_cart_fk FOREIGN KEY (cart_id) REFERENCES shopping_carts(cart_id) ON DELETE CASCADE,
    CONSTRAINT ci_prod_fk FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Orders
CREATE TABLE orders (
    order_id NUMBER(12) PRIMARY KEY,
    customer_id NUMBER(10) NOT NULL,
    order_number VARCHAR2(20) NOT NULL UNIQUE,
    order_date DATE DEFAULT SYSDATE,
    order_status VARCHAR2(20) DEFAULT 'PENDING' 
        CHECK (order_status IN ('PENDING', 'CONFIRMED', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED')),
    currency_code VARCHAR2(3) DEFAULT 'USD',
    subtotal NUMBER(12,2) DEFAULT 0,
    tax_amount NUMBER(10,2) DEFAULT 0,
    shipping_amount NUMBER(8,2) DEFAULT 0,
    discount_amount NUMBER(10,2) DEFAULT 0,
    total_amount NUMBER(12,2) DEFAULT 0,
    billing_address_id NUMBER(10),
    shipping_address_id NUMBER(10),
    payment_method VARCHAR2(20),
    payment_status VARCHAR2(20) DEFAULT 'PENDING' 
        CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED', 'REFUNDED', 'PARTIAL')),
    shipping_method VARCHAR2(50),
    tracking_number VARCHAR2(100),
    notes CLOB,
    created_date DATE DEFAULT SYSDATE,
    updated_date DATE DEFAULT SYSDATE,
    CONSTRAINT ord_cust_fk FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT ord_bill_addr_fk FOREIGN KEY (billing_address_id) REFERENCES customer_addresses(address_id),
    CONSTRAINT ord_ship_addr_fk FOREIGN KEY (shipping_address_id) REFERENCES customer_addresses(address_id)
);
```

### **Phase 2: Business Logic Implementation (Week 1, Days 4-7)**

#### **Day 4: Core Procedures and Functions**

```sql
-- Order Processing Procedure
CREATE OR REPLACE PROCEDURE process_checkout (
    p_customer_id IN NUMBER,
    p_billing_address_id IN NUMBER,
    p_shipping_address_id IN NUMBER,
    p_payment_method IN VARCHAR2,
    p_shipping_method IN VARCHAR2,
    p_order_id OUT NUMBER
) AS
    v_cart_id NUMBER;
    v_subtotal NUMBER := 0;
    v_tax_rate NUMBER := 0.0875; -- 8.75% tax rate
    v_tax_amount NUMBER := 0;
    v_shipping_cost NUMBER := 0;
    v_total NUMBER := 0;
    v_order_number VARCHAR2(20);
    cart_empty EXCEPTION;
    insufficient_stock EXCEPTION;
BEGIN
    -- Find customer's active cart
    SELECT cart_id INTO v_cart_id
    FROM shopping_carts
    WHERE customer_id = p_customer_id
    AND expires_date > SYSDATE
    AND ROWNUM = 1;
    
    -- Check if cart has items
    SELECT COUNT(*) INTO v_subtotal FROM cart_items WHERE cart_id = v_cart_id;
    IF v_subtotal = 0 THEN
        RAISE cart_empty;
    END IF;
    
    -- Calculate subtotal
    SELECT SUM(unit_price * quantity) INTO v_subtotal
    FROM cart_items
    WHERE cart_id = v_cart_id;
    
    -- Calculate tax and shipping
    v_tax_amount := v_subtotal * v_tax_rate;
    v_shipping_cost := CASE 
        WHEN v_subtotal > 100 THEN 0 
        ELSE 9.99 
    END;
    v_total := v_subtotal + v_tax_amount + v_shipping_cost;
    
    -- Generate order number
    SELECT 'ORD' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || order_seq.NEXTVAL 
    INTO v_order_number FROM DUAL;
    
    -- Create order
    SELECT order_seq.NEXTVAL INTO p_order_id FROM DUAL;
    
    INSERT INTO orders (
        order_id, customer_id, order_number, subtotal, tax_amount,
        shipping_amount, total_amount, billing_address_id, shipping_address_id,
        payment_method, shipping_method
    ) VALUES (
        p_order_id, p_customer_id, v_order_number, v_subtotal, v_tax_amount,
        v_shipping_cost, v_total, p_billing_address_id, p_shipping_address_id,
        p_payment_method, p_shipping_method
    );
    
    -- Copy cart items to order items
    INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total)
    SELECT p_order_id, product_id, quantity, unit_price, unit_price * quantity
    FROM cart_items
    WHERE cart_id = v_cart_id;
    
    -- Update inventory
    UPDATE inventory i
    SET quantity_allocated = quantity_allocated + (
        SELECT quantity FROM cart_items ci 
        WHERE ci.cart_id = v_cart_id AND ci.product_id = i.product_id
    )
    WHERE product_id IN (SELECT product_id FROM cart_items WHERE cart_id = v_cart_id);
    
    -- Clear cart
    DELETE FROM cart_items WHERE cart_id = v_cart_id;
    
    COMMIT;
    
EXCEPTION
    WHEN cart_empty THEN
        RAISE_APPLICATION_ERROR(-20001, 'Shopping cart is empty');
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No active shopping cart found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20999, 'Checkout failed: ' || SQLERRM);
END;
/
```

### **Phase 3: Advanced Features (Week 2)**

#### **Performance Optimization**
- Strategic indexing for fast product searches
- Query optimization for reporting
- Materialized views for analytics

#### **Security Implementation**
- Role-based access control
- Data encryption for sensitive information
- Audit trails for all transactions

#### **Reporting System**
- Daily sales reports
- Inventory status reports
- Customer analytics
- Supplier performance metrics

## 🧪 Testing Scenarios

### **Functional Testing**
1. **Customer Registration and Login**
2. **Product Browsing and Search**
3. **Shopping Cart Management**
4. **Checkout Process**
5. **Order Fulfillment**
6. **Inventory Management**

### **Performance Testing**
1. **High-Volume Product Searches**
2. **Concurrent Checkout Processing**
3. **Large-Scale Reporting Queries**
4. **Inventory Update Performance**

### **Security Testing**
1. **SQL Injection Prevention**
2. **Access Control Validation**
3. **Data Encryption Verification**
4. **Audit Trail Completeness**

## 📊 Success Metrics

### **Functional Completeness**
- [ ] All core e-commerce features implemented
- [ ] Complete order lifecycle management
- [ ] Comprehensive inventory tracking
- [ ] Full customer management system

### **Performance Standards**
- [ ] Product searches < 500ms
- [ ] Checkout process < 2 seconds
- [ ] Reports generate < 5 seconds
- [ ] 100+ concurrent users supported

### **Professional Quality**
- [ ] Complete documentation
- [ ] Comprehensive error handling
- [ ] Professional code standards
- [ ] Full test coverage

## 🎉 Project Completion

Upon completion, you will have:
- **Production-Ready E-commerce System**: Complete database solution
- **Professional Portfolio Project**: Demonstrable to employers
- **Comprehensive Oracle Skills**: All concepts applied in practice
- **Real-World Experience**: Practical database development skills

This project represents a significant achievement in your Oracle Database learning journey and demonstrates your readiness for professional database development roles!

---

**Ready to build a complete e-commerce system?** This project will challenge you to apply everything you've learned and create something truly impressive!
