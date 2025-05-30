-- =====================================================
-- E-COMMERCE REPORTING VIEWS
-- =====================================================
-- Project: Oracle Database Learning - Lesson 6 Practice
-- Description: Comprehensive reporting views for e-commerce platform
-- Author: Oracle Learning Project
-- Created: 2024
-- =====================================================

-- Enable server output for feedback
SET SERVEROUTPUT ON;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Creating E-commerce Reporting Views...');
    DBMS_OUTPUT.PUT_LINE('====================================');
END;
/

-- =====================================================
-- 1. CUSTOMER VIEWS
-- =====================================================

-- Customer overview with order statistics
CREATE OR REPLACE VIEW vw_customer_overview AS
SELECT 
    c.customer_id,
    c.email,
    c.first_name,
    c.last_name,
    c.phone,
    c.customer_type,
    c.account_status,
    c.registration_date,
    c.last_login,
    COUNT(o.order_id) as total_orders,
    NVL(SUM(o.total_amount), 0) as total_spent,
    NVL(AVG(o.total_amount), 0) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    CASE 
        WHEN COUNT(o.order_id) = 0 THEN 'New Customer'
        WHEN COUNT(o.order_id) = 1 THEN 'First Time Buyer'
        WHEN COUNT(o.order_id) BETWEEN 2 AND 5 THEN 'Regular Customer'
        WHEN COUNT(o.order_id) BETWEEN 6 AND 15 THEN 'Loyal Customer'
        ELSE 'VIP Customer'
    END as customer_segment,
    CASE 
        WHEN MAX(o.order_date) >= SYSDATE - 30 THEN 'Active'
        WHEN MAX(o.order_date) >= SYSDATE - 90 THEN 'At Risk'
        WHEN MAX(o.order_date) >= SYSDATE - 180 THEN 'Inactive'
        ELSE 'Lost'
    END as activity_status
FROM ecom_customers c
LEFT JOIN ecom_orders o ON c.customer_id = o.customer_id 
    AND o.order_status NOT IN ('CANCELLED', 'REFUNDED')
GROUP BY c.customer_id, c.email, c.first_name, c.last_name, c.phone,
         c.customer_type, c.account_status, c.registration_date, c.last_login;

-- Customer addresses summary
CREATE OR REPLACE VIEW vw_customer_addresses AS
SELECT 
    ca.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    ca.address_id,
    ca.address_type,
    ca.address_line1 || 
    CASE WHEN ca.address_line2 IS NOT NULL THEN ', ' || ca.address_line2 ELSE '' END ||
    ', ' || ca.city || ', ' || ca.state_province || ' ' || ca.postal_code ||
    ', ' || ca.country as full_address,
    ca.is_default,
    ca.created_date
FROM ecom_customer_addresses ca
JOIN ecom_customers c ON ca.customer_id = c.customer_id
ORDER BY ca.customer_id, ca.is_default DESC, ca.created_date;

-- =====================================================
-- 2. PRODUCT CATALOG VIEWS
-- =====================================================

-- Product catalog with pricing and inventory
CREATE OR REPLACE VIEW vw_product_catalog AS
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    c.category_name,
    c.category_path,
    b.brand_name,
    p.short_description,
    p.base_price,
    p.product_status,
    p.is_featured,
    SUM(i.quantity_available) as total_inventory,
    COUNT(DISTINCT pv.variant_id) as variant_count,
    fn_get_product_rating(p.product_id) as avg_rating,
    COUNT(DISTINCT pr.review_id) as review_count,
    CASE 
        WHEN SUM(i.quantity_available) = 0 THEN 'Out of Stock'
        WHEN SUM(i.quantity_available) <= 10 THEN 'Low Stock'
        WHEN SUM(i.quantity_available) <= 50 THEN 'Medium Stock'
        ELSE 'In Stock'
    END as stock_status,
    p.created_date,
    p.modified_date
FROM ecom_products p
JOIN ecom_categories c ON p.category_id = c.category_id
LEFT JOIN ecom_brands b ON p.brand_id = b.brand_id
LEFT JOIN ecom_inventory i ON p.product_id = i.product_id
LEFT JOIN ecom_product_variants pv ON p.product_id = pv.product_id
LEFT JOIN ecom_product_reviews pr ON p.product_id = pr.product_id 
    AND pr.review_status = 'APPROVED'
GROUP BY p.product_id, p.product_code, p.product_name, c.category_name,
         c.category_path, b.brand_name, p.short_description, p.base_price,
         p.product_status, p.is_featured, p.created_date, p.modified_date;

-- Product variants with pricing
CREATE OR REPLACE VIEW vw_product_variants AS
SELECT 
    p.product_id,
    p.product_name,
    pv.variant_id,
    pv.sku_code,
    pv.variant_name,
    pv.size_value,
    pv.color_value,
    pv.style_value,
    pv.material_value,
    p.base_price,
    pv.price_adjustment,
    p.base_price + NVL(pv.price_adjustment, 0) as final_price,
    pv.is_default,
    pv.is_active,
    SUM(i.quantity_available) as available_inventory
FROM ecom_products p
JOIN ecom_product_variants pv ON p.product_id = pv.product_id
LEFT JOIN ecom_inventory i ON pv.variant_id = i.variant_id
GROUP BY p.product_id, p.product_name, pv.variant_id, pv.sku_code,
         pv.variant_name, pv.size_value, pv.color_value, pv.style_value,
         pv.material_value, p.base_price, pv.price_adjustment,
         pv.is_default, pv.is_active;

-- Best selling products
CREATE OR REPLACE VIEW vw_best_selling_products AS
SELECT 
    p.product_id,
    p.product_name,
    c.category_name,
    b.brand_name,
    COUNT(oi.order_item_id) as order_count,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(oi.unit_price) as avg_selling_price,
    fn_get_product_rating(p.product_id) as avg_rating,
    RANK() OVER (ORDER BY SUM(oi.quantity) DESC) as sales_rank
FROM ecom_products p
JOIN ecom_categories c ON p.category_id = c.category_id
LEFT JOIN ecom_brands b ON p.brand_id = b.brand_id
JOIN ecom_order_items oi ON p.product_id = oi.product_id
JOIN ecom_orders o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
  AND o.order_date >= SYSDATE - 365 -- Last 12 months
GROUP BY p.product_id, p.product_name, c.category_name, b.brand_name
ORDER BY total_quantity_sold DESC;

-- =====================================================
-- 3. INVENTORY VIEWS
-- =====================================================

-- Inventory summary by warehouse
CREATE OR REPLACE VIEW vw_inventory_summary AS
SELECT 
    w.warehouse_id,
    w.warehouse_name,
    w.warehouse_code,
    COUNT(DISTINCT i.product_id) as unique_products,
    SUM(i.quantity_available) as total_inventory,
    SUM(i.quantity_reserved) as total_reserved,
    SUM(CASE WHEN i.quantity_available <= i.reorder_level THEN 1 ELSE 0 END) as items_needing_reorder,
    SUM(i.quantity_available * p.cost_price) as inventory_value,
    AVG(i.quantity_available) as avg_stock_level
FROM ecom_warehouses w
LEFT JOIN ecom_inventory i ON w.warehouse_id = i.warehouse_id
LEFT JOIN ecom_products p ON i.product_id = p.product_id
GROUP BY w.warehouse_id, w.warehouse_name, w.warehouse_code;

-- Low stock alert
CREATE OR REPLACE VIEW vw_low_stock_alert AS
SELECT 
    p.product_id,
    p.product_code,
    p.product_name,
    c.category_name,
    w.warehouse_name,
    i.quantity_available,
    i.quantity_reserved,
    i.reorder_level,
    i.max_stock_level,
    i.quantity_available - i.quantity_reserved as available_for_sale,
    CASE 
        WHEN i.quantity_available = 0 THEN 'OUT_OF_STOCK'
        WHEN i.quantity_available <= i.reorder_level THEN 'REORDER_NEEDED'
        WHEN i.quantity_available <= i.reorder_level * 1.5 THEN 'LOW_STOCK'
        ELSE 'NORMAL'
    END as stock_status,
    i.last_updated
FROM ecom_inventory i
JOIN ecom_products p ON i.product_id = p.product_id
JOIN ecom_categories c ON p.category_id = c.category_id
JOIN ecom_warehouses w ON i.warehouse_id = w.warehouse_id
WHERE i.quantity_available <= i.reorder_level * 1.5
ORDER BY i.quantity_available ASC;

-- =====================================================
-- 4. ORDER VIEWS
-- =====================================================

-- Order details view
CREATE OR REPLACE VIEW vw_order_details AS
SELECT 
    o.order_id,
    o.order_number,
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.email as customer_email,
    o.order_status,
    o.payment_status,
    o.order_date,
    o.subtotal_amount,
    o.tax_amount,
    o.shipping_amount,
    o.discount_amount,
    o.total_amount,
    o.currency_code,
    ship_addr.address_line1 || ', ' || ship_addr.city || ', ' || 
    ship_addr.state_province || ' ' || ship_addr.postal_code as shipping_address,
    bill_addr.address_line1 || ', ' || bill_addr.city || ', ' || 
    bill_addr.state_province || ' ' || bill_addr.postal_code as billing_address,
    o.shipping_method,
    o.tracking_number,
    o.estimated_delivery,
    COUNT(oi.order_item_id) as item_count,
    SUM(oi.quantity) as total_quantity
FROM ecom_orders o
JOIN ecom_customers c ON o.customer_id = c.customer_id
LEFT JOIN ecom_customer_addresses ship_addr ON o.shipping_address_id = ship_addr.address_id
LEFT JOIN ecom_customer_addresses bill_addr ON o.billing_address_id = bill_addr.address_id
LEFT JOIN ecom_order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, c.customer_id, c.first_name, c.last_name,
         c.email, o.order_status, o.payment_status, o.order_date,
         o.subtotal_amount, o.tax_amount, o.shipping_amount, o.discount_amount,
         o.total_amount, o.currency_code, ship_addr.address_line1, ship_addr.city,
         ship_addr.state_province, ship_addr.postal_code, bill_addr.address_line1,
         bill_addr.city, bill_addr.state_province, bill_addr.postal_code,
         o.shipping_method, o.tracking_number, o.estimated_delivery;

-- Order items detailed view
CREATE OR REPLACE VIEW vw_order_items_detail AS
SELECT 
    oi.order_id,
    o.order_number,
    oi.order_item_id,
    oi.product_id,
    oi.product_name,
    oi.product_sku,
    p.category_id,
    c.category_name,
    oi.quantity,
    oi.unit_price,
    oi.total_price,
    oi.item_status,
    p.cost_price,
    oi.total_price - (p.cost_price * oi.quantity) as item_profit,
    o.order_date,
    o.customer_id
FROM ecom_order_items oi
JOIN ecom_orders o ON oi.order_id = o.order_id
JOIN ecom_products p ON oi.product_id = p.product_id
JOIN ecom_categories c ON p.category_id = c.category_id;

-- =====================================================
-- 5. SALES ANALYTICS VIEWS
-- =====================================================

-- Daily sales summary
CREATE OR REPLACE VIEW vw_daily_sales AS
SELECT 
    TRUNC(o.order_date) as sale_date,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    SUM(oi.quantity) as total_items_sold,
    SUM(o.total_amount - o.tax_amount - o.shipping_amount) as net_product_revenue
FROM ecom_orders o
JOIN ecom_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
GROUP BY TRUNC(o.order_date)
ORDER BY sale_date DESC;

-- Monthly sales summary
CREATE OR REPLACE VIEW vw_monthly_sales AS
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') as sale_month,
    COUNT(DISTINCT o.order_id) as order_count,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    SUM(o.total_amount) as total_revenue,
    AVG(o.total_amount) as avg_order_value,
    SUM(oi.quantity) as total_items_sold,
    SUM(o.total_amount - (NVL(oi_cost.total_cost, 0) + o.tax_amount + o.shipping_amount)) as gross_profit
FROM ecom_orders o
JOIN ecom_order_items oi ON o.order_id = oi.order_id
LEFT JOIN (
    SELECT oi2.order_id, SUM(oi2.quantity * p2.cost_price) as total_cost
    FROM ecom_order_items oi2
    JOIN ecom_products p2 ON oi2.product_id = p2.product_id
    GROUP BY oi2.order_id
) oi_cost ON o.order_id = oi_cost.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY sale_month DESC;

-- Category performance
CREATE OR REPLACE VIEW vw_category_performance AS
SELECT 
    c.category_id,
    c.category_name,
    c.parent_category_id,
    COUNT(DISTINCT oi.product_id) as products_sold,
    COUNT(oi.order_item_id) as total_orders,
    SUM(oi.quantity) as total_quantity_sold,
    SUM(oi.total_price) as total_revenue,
    AVG(oi.unit_price) as avg_selling_price,
    SUM(oi.total_price - (p.cost_price * oi.quantity)) as category_profit,
    RANK() OVER (ORDER BY SUM(oi.total_price) DESC) as revenue_rank
FROM ecom_categories c
JOIN ecom_products p ON c.category_id = p.category_id
JOIN ecom_order_items oi ON p.product_id = oi.product_id
JOIN ecom_orders o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
  AND o.order_date >= SYSDATE - 365
GROUP BY c.category_id, c.category_name, c.parent_category_id
ORDER BY total_revenue DESC;

-- =====================================================
-- 6. CUSTOMER ANALYTICS VIEWS
-- =====================================================

-- Customer lifetime value
CREATE OR REPLACE VIEW vw_customer_lifetime_value AS
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name as customer_name,
    c.email,
    c.customer_type,
    c.registration_date,
    COUNT(o.order_id) as total_orders,
    SUM(o.total_amount) as lifetime_value,
    AVG(o.total_amount) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    MIN(o.order_date) as first_order_date,
    MAX(o.order_date) - MIN(o.order_date) as customer_lifespan_days,
    CASE 
        WHEN COUNT(o.order_id) > 0 THEN 
            SUM(o.total_amount) / (GREATEST(MAX(o.order_date) - MIN(o.order_date), 1))
        ELSE 0 
    END as revenue_per_day,
    CASE 
        WHEN MAX(o.order_date) >= SYSDATE - 30 THEN 'Active'
        WHEN MAX(o.order_date) >= SYSDATE - 90 THEN 'At Risk'
        ELSE 'Churned'
    END as customer_status
FROM ecom_customers c
LEFT JOIN ecom_orders o ON c.customer_id = o.customer_id 
    AND o.order_status NOT IN ('CANCELLED', 'REFUNDED')
GROUP BY c.customer_id, c.first_name, c.last_name, c.email,
         c.customer_type, c.registration_date
ORDER BY lifetime_value DESC;

-- =====================================================
-- 7. FINANCIAL VIEWS
-- =====================================================

-- Revenue breakdown
CREATE OR REPLACE VIEW vw_revenue_breakdown AS
SELECT 
    TO_CHAR(o.order_date, 'YYYY-MM') as revenue_month,
    SUM(o.subtotal_amount) as gross_revenue,
    SUM(o.discount_amount) as total_discounts,
    SUM(o.subtotal_amount - o.discount_amount) as net_product_revenue,
    SUM(o.tax_amount) as tax_collected,
    SUM(o.shipping_amount) as shipping_revenue,
    SUM(o.total_amount) as total_revenue,
    SUM(cost_summary.total_cost) as total_cost,
    SUM(o.total_amount) - SUM(cost_summary.total_cost) as gross_profit,
    CASE 
        WHEN SUM(o.total_amount) > 0 THEN 
            ROUND((SUM(o.total_amount) - SUM(cost_summary.total_cost)) / SUM(o.total_amount) * 100, 2)
        ELSE 0 
    END as profit_margin_pct
FROM ecom_orders o
LEFT JOIN (
    SELECT oi.order_id, SUM(oi.quantity * p.cost_price) as total_cost
    FROM ecom_order_items oi
    JOIN ecom_products p ON oi.product_id = p.product_id
    GROUP BY oi.order_id
) cost_summary ON o.order_id = cost_summary.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
ORDER BY revenue_month DESC;

-- =====================================================
-- 8. EXECUTIVE DASHBOARD VIEWS
-- =====================================================

-- Executive summary metrics
CREATE OR REPLACE VIEW vw_executive_summary AS
SELECT 
    'Today' as period_name,
    COUNT(DISTINCT CASE WHEN TRUNC(o.order_date) = TRUNC(SYSDATE) THEN o.order_id END) as orders_today,
    NVL(SUM(CASE WHEN TRUNC(o.order_date) = TRUNC(SYSDATE) THEN o.total_amount END), 0) as revenue_today,
    COUNT(DISTINCT CASE WHEN TRUNC(c.registration_date) = TRUNC(SYSDATE) THEN c.customer_id END) as new_customers_today,
    COUNT(DISTINCT CASE WHEN o.order_date >= TRUNC(SYSDATE) - 7 THEN o.order_id END) as orders_this_week,
    NVL(SUM(CASE WHEN o.order_date >= TRUNC(SYSDATE) - 7 THEN o.total_amount END), 0) as revenue_this_week,
    COUNT(DISTINCT CASE WHEN o.order_date >= TRUNC(SYSDATE) - 30 THEN o.order_id END) as orders_this_month,
    NVL(SUM(CASE WHEN o.order_date >= TRUNC(SYSDATE) - 30 THEN o.total_amount END), 0) as revenue_this_month,
    COUNT(DISTINCT c.customer_id) as total_customers,
    COUNT(DISTINCT p.product_id) as total_products,
    SUM(i.quantity_available) as total_inventory
FROM ecom_orders o
FULL OUTER JOIN ecom_customers c ON 1=1
FULL OUTER JOIN ecom_products p ON 1=1
FULL OUTER JOIN ecom_inventory i ON 1=1
WHERE (o.order_status IS NULL OR o.order_status NOT IN ('CANCELLED', 'REFUNDED'));

-- Top performers summary
CREATE OR REPLACE VIEW vw_top_performers AS
SELECT 
    'PRODUCTS' as category,
    'Top Product' as metric_name,
    p.product_name as metric_value,
    SUM(oi.total_price) as metric_amount
FROM ecom_products p
JOIN ecom_order_items oi ON p.product_id = oi.product_id
JOIN ecom_orders o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
  AND o.order_date >= SYSDATE - 30
GROUP BY p.product_id, p.product_name
HAVING RANK() OVER (ORDER BY SUM(oi.total_price) DESC) = 1

UNION ALL

SELECT 
    'CUSTOMERS' as category,
    'Top Customer' as metric_name,
    c.first_name || ' ' || c.last_name as metric_value,
    SUM(o.total_amount) as metric_amount
FROM ecom_customers c
JOIN ecom_orders o ON c.customer_id = o.customer_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
  AND o.order_date >= SYSDATE - 30
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING RANK() OVER (ORDER BY SUM(o.total_amount) DESC) = 1

UNION ALL

SELECT 
    'CATEGORIES' as category,
    'Top Category' as metric_name,
    cat.category_name as metric_value,
    SUM(oi.total_price) as metric_amount
FROM ecom_categories cat
JOIN ecom_products p ON cat.category_id = p.category_id
JOIN ecom_order_items oi ON p.product_id = oi.product_id
JOIN ecom_orders o ON oi.order_id = o.order_id
WHERE o.order_status NOT IN ('CANCELLED', 'REFUNDED')
  AND o.order_date >= SYSDATE - 30
GROUP BY cat.category_id, cat.category_name
HAVING RANK() OVER (ORDER BY SUM(oi.total_price) DESC) = 1;

-- =====================================================
-- 9. OPERATIONAL VIEWS
-- =====================================================

-- Orders pending fulfillment
CREATE OR REPLACE VIEW vw_pending_orders AS
SELECT 
    o.order_id,
    o.order_number,
    c.first_name || ' ' || c.last_name as customer_name,
    o.order_status,
    o.payment_status,
    o.order_date,
    o.total_amount,
    COUNT(oi.order_item_id) as item_count,
    CASE 
        WHEN o.order_date < SYSDATE - 2 THEN 'URGENT'
        WHEN o.order_date < SYSDATE - 1 THEN 'HIGH'
        ELSE 'NORMAL'
    END as priority,
    ship_addr.city || ', ' || ship_addr.state_province as shipping_location
FROM ecom_orders o
JOIN ecom_customers c ON o.customer_id = c.customer_id
JOIN ecom_order_items oi ON o.order_id = oi.order_id
LEFT JOIN ecom_customer_addresses ship_addr ON o.shipping_address_id = ship_addr.address_id
WHERE o.order_status IN ('CONFIRMED', 'PROCESSING')
  AND o.payment_status = 'PAID'
GROUP BY o.order_id, o.order_number, c.first_name, c.last_name,
         o.order_status, o.payment_status, o.order_date, o.total_amount,
         ship_addr.city, ship_addr.state_province
ORDER BY o.order_date ASC;

-- =====================================================
-- 10. REVIEW AND RATING VIEWS
-- =====================================================

-- Product reviews summary
CREATE OR REPLACE VIEW vw_product_reviews_summary AS
SELECT 
    p.product_id,
    p.product_name,
    COUNT(pr.review_id) as total_reviews,
    AVG(pr.rating) as avg_rating,
    COUNT(CASE WHEN pr.rating = 5 THEN 1 END) as five_star_count,
    COUNT(CASE WHEN pr.rating = 4 THEN 1 END) as four_star_count,
    COUNT(CASE WHEN pr.rating = 3 THEN 1 END) as three_star_count,
    COUNT(CASE WHEN pr.rating = 2 THEN 1 END) as two_star_count,
    COUNT(CASE WHEN pr.rating = 1 THEN 1 END) as one_star_count,
    COUNT(CASE WHEN pr.is_verified = 'Y' THEN 1 END) as verified_reviews,
    MAX(pr.created_date) as latest_review_date
FROM ecom_products p
LEFT JOIN ecom_product_reviews pr ON p.product_id = pr.product_id 
    AND pr.review_status = 'APPROVED'
GROUP BY p.product_id, p.product_name
ORDER BY avg_rating DESC, total_reviews DESC;

BEGIN
    DBMS_OUTPUT.PUT_LINE('E-commerce Reporting Views Complete!');
    DBMS_OUTPUT.PUT_LINE('===================================');
    DBMS_OUTPUT.PUT_LINE('✓ Customer overview and analytics views');
    DBMS_OUTPUT.PUT_LINE('✓ Product catalog and performance views');
    DBMS_OUTPUT.PUT_LINE('✓ Inventory management views');
    DBMS_OUTPUT.PUT_LINE('✓ Order processing views');
    DBMS_OUTPUT.PUT_LINE('✓ Sales analytics views');
    DBMS_OUTPUT.PUT_LINE('✓ Financial reporting views');
    DBMS_OUTPUT.PUT_LINE('✓ Executive dashboard views');
    DBMS_OUTPUT.PUT_LINE('✓ Operational views');
    DBMS_OUTPUT.PUT_LINE('✓ Review and rating views');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Available views:');
    DBMS_OUTPUT.PUT_LINE('- vw_customer_overview');
    DBMS_OUTPUT.PUT_LINE('- vw_product_catalog');
    DBMS_OUTPUT.PUT_LINE('- vw_best_selling_products');
    DBMS_OUTPUT.PUT_LINE('- vw_inventory_summary');
    DBMS_OUTPUT.PUT_LINE('- vw_order_details');
    DBMS_OUTPUT.PUT_LINE('- vw_daily_sales');
    DBMS_OUTPUT.PUT_LINE('- vw_monthly_sales');
    DBMS_OUTPUT.PUT_LINE('- vw_customer_lifetime_value');
    DBMS_OUTPUT.PUT_LINE('- vw_revenue_breakdown');
    DBMS_OUTPUT.PUT_LINE('- vw_executive_summary');
    DBMS_OUTPUT.PUT_LINE('- vw_pending_orders');
    DBMS_OUTPUT.PUT_LINE('...and many more!');
END;
/
