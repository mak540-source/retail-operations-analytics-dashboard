-- ============================================================
-- Retail Operations Analytics Dashboard
-- File: 03_analysis_queries.sql
-- Description: Business analysis queries for reporting and dashboard
-- ============================================================

USE retail_ops_db;

-- ============================================================
-- QUERY 1: Total Sales by Month
-- Business Use: Track revenue trends over time; identify
-- peak and slow seasons. Ties directly to sales planning.
-- ============================================================
SELECT
    DATE_FORMAT(o.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT o.order_id)         AS total_orders,
    SUM(od.line_total)                 AS total_sales,
    ROUND(AVG(od.line_total), 2)       AS avg_line_value
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
WHERE o.fulfillment_status != 'Cancelled'
GROUP BY DATE_FORMAT(o.order_date, '%Y-%m')
ORDER BY sales_month;


-- ============================================================
-- QUERY 2: Sales by Category
-- Business Use: See which product categories drive the most
-- revenue. Helps buying and merchandising decisions.
-- ============================================================
SELECT
    c.category_name,
    COUNT(DISTINCT o.order_id)         AS total_orders,
    SUM(od.quantity_ordered)           AS units_sold,
    SUM(od.line_total)                 AS total_sales,
    ROUND(SUM(od.line_total) /
          (SELECT SUM(line_total) FROM order_details) * 100, 2) AS pct_of_total_sales
FROM order_details od
JOIN products p   ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o     ON od.order_id   = o.order_id
WHERE o.fulfillment_status != 'Cancelled'
GROUP BY c.category_name
ORDER BY total_sales DESC;


-- ============================================================
-- QUERY 3: Sales by Region and Store
-- Business Use: Compare performance across store locations
-- and geographic regions for regional planning.
-- ============================================================
SELECT
    s.region,
    s.store_name,
    s.city_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(od.line_total)         AS total_sales,
    ROUND(AVG(o.order_total), 2) AS avg_order_value
FROM orders o
JOIN stores s        ON o.store_id   = s.store_id
JOIN order_details od ON o.order_id  = od.order_id
WHERE o.fulfillment_status != 'Cancelled'
GROUP BY s.region, s.store_name, s.city_state
ORDER BY total_sales DESC;


-- ============================================================
-- QUERY 4: Top 10 Products by Total Sales
-- Business Use: Identify best-selling products for
-- prioritized stocking, promotions, and reorder planning.
-- ============================================================
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    SUM(od.quantity_ordered) AS units_sold,
    SUM(od.line_total)       AS total_sales,
    ROUND(AVG(od.unit_price), 2) AS avg_unit_price
FROM order_details od
JOIN products p   ON od.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN orders o     ON od.order_id   = o.order_id
WHERE o.fulfillment_status != 'Cancelled'
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY total_sales DESC
LIMIT 10;


-- ============================================================
-- QUERY 5: Low-Stock Products (All Stores)
-- Business Use: Alert operations team to items at or below
-- reorder threshold — prevents out-of-stock and lost sales.
-- ============================================================
SELECT
    i.store_id,
    s.store_name,
    s.region,
    p.product_name,
    c.category_name,
    sup.supplier_name,
    i.stock_quantity,
    i.reorder_level,
    (i.reorder_level - i.stock_quantity) AS units_needed,
    i.last_restocked
FROM inventory i
JOIN stores s     ON i.store_id   = s.store_id
JOIN products p   ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers sup ON p.supplier_id = sup.supplier_id
WHERE i.low_stock_flag = 1
ORDER BY units_needed DESC, s.region;


-- ============================================================
-- QUERY 6: Inventory Summary — Stock vs. Reorder Level
-- Business Use: High-level view of inventory health by
-- category. Supports purchasing and supply chain decisions.
-- ============================================================
SELECT
    c.category_name,
    COUNT(i.inventory_id)                   AS total_sku_store_combinations,
    SUM(i.stock_quantity)                   AS total_units_on_hand,
    SUM(i.reorder_level)                    AS total_reorder_threshold,
    SUM(CASE WHEN i.low_stock_flag = 1 THEN 1 ELSE 0 END) AS low_stock_count,
    ROUND(
        SUM(CASE WHEN i.low_stock_flag = 1 THEN 1 ELSE 0 END) * 100.0
        / COUNT(i.inventory_id), 1
    )                                       AS low_stock_pct
FROM inventory i
JOIN products p   ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY low_stock_pct DESC;


-- ============================================================
-- QUERY 7: Order Fulfillment Status Breakdown
-- Business Use: Monitor how many orders are completed,
-- delayed, or cancelled. Critical for service-level reporting.
-- ============================================================
SELECT
    fulfillment_status,
    COUNT(order_id)                          AS order_count,
    ROUND(COUNT(order_id) * 100.0 /
          (SELECT COUNT(*) FROM orders), 2)  AS pct_of_orders,
    ROUND(AVG(order_total), 2)               AS avg_order_value,
    SUM(order_total)                         AS total_value
FROM orders
GROUP BY fulfillment_status
ORDER BY order_count DESC;


-- ============================================================
-- QUERY 8: Average Fulfillment Time (Completed Orders)
-- Business Use: Measure operational efficiency; benchmark
-- against service targets. Mirrors online grocery pickup KPIs.
-- ============================================================
SELECT
    s.region,
    s.store_name,
    COUNT(o.order_id)             AS completed_orders,
    ROUND(AVG(o.delivery_days), 2) AS avg_fulfillment_days,
    MIN(o.delivery_days)           AS fastest_fulfillment,
    MAX(o.delivery_days)           AS slowest_fulfillment
FROM orders o
JOIN stores s ON o.store_id = s.store_id
WHERE o.fulfillment_status = 'Completed'
GROUP BY s.region, s.store_name
ORDER BY avg_fulfillment_days;


-- ============================================================
-- QUERY 9: Delayed Orders Detail
-- Business Use: Identify which stores and products are
-- consistently delayed. Used for supplier or routing review.
-- ============================================================
SELECT
    o.order_id,
    s.store_name,
    s.region,
    o.order_date,
    o.delivery_date,
    o.delivery_days,
    o.fulfillment_status,
    o.order_total
FROM orders o
JOIN stores s ON o.store_id = s.store_id
WHERE o.fulfillment_status = 'Delayed'
ORDER BY o.delivery_days DESC;


-- ============================================================
-- QUERY 10: Supplier Performance Summary
-- Business Use: Evaluate suppliers by total units supplied,
-- sales generated, and low-stock exposure.
-- ============================================================
SELECT
    sup.supplier_name,
    sup.specialty,
    COUNT(DISTINCT p.product_id)   AS products_supplied,
    SUM(od.quantity_ordered)       AS total_units_ordered,
    SUM(od.line_total)             AS total_revenue_generated,
    SUM(CASE WHEN i.low_stock_flag = 1 THEN 1 ELSE 0 END) AS low_stock_instances
FROM suppliers sup
JOIN products p     ON sup.supplier_id = p.supplier_id
LEFT JOIN order_details od ON p.product_id = od.product_id
LEFT JOIN orders o  ON od.order_id = o.order_id AND o.fulfillment_status != 'Cancelled'
LEFT JOIN inventory i ON p.product_id = i.product_id
GROUP BY sup.supplier_name, sup.specialty
ORDER BY total_revenue_generated DESC;


-- ============================================================
-- QUERY 11: Inventory Turnover Risk
-- Business Use: Find products with high sales velocity but
-- low stock — the highest risk for stockouts.
-- ============================================================
SELECT
    p.product_name,
    c.category_name,
    SUM(od.quantity_ordered)       AS units_ordered_ytd,
    AVG(i.stock_quantity)          AS avg_stock_on_hand,
    AVG(i.reorder_level)           AS avg_reorder_level,
    ROUND(
        SUM(od.quantity_ordered) /
        NULLIF(AVG(i.stock_quantity), 0)
    , 2)                           AS turnover_ratio,
    SUM(CASE WHEN i.low_stock_flag = 1 THEN 1 ELSE 0 END) AS stores_at_low_stock
FROM products p
JOIN categories c   ON p.category_id = c.category_id
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o       ON od.order_id   = o.order_id
JOIN inventory i    ON p.product_id  = i.product_id
WHERE o.fulfillment_status != 'Cancelled'
GROUP BY p.product_name, c.category_name
HAVING turnover_ratio > 1
ORDER BY turnover_ratio DESC
LIMIT 15;


-- ============================================================
-- QUERY 12: Monthly Fulfillment Rate
-- Business Use: Track % of orders successfully completed
-- each month — a core operational KPI.
-- ============================================================
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(order_id)                  AS total_orders,
    SUM(CASE WHEN fulfillment_status = 'Completed' THEN 1 ELSE 0 END) AS completed,
    SUM(CASE WHEN fulfillment_status = 'Delayed'   THEN 1 ELSE 0 END) AS delayed,
    SUM(CASE WHEN fulfillment_status = 'Cancelled' THEN 1 ELSE 0 END) AS cancelled,
    ROUND(
        SUM(CASE WHEN fulfillment_status = 'Completed' THEN 1 ELSE 0 END) * 100.0
        / COUNT(order_id), 1
    ) AS fulfillment_rate_pct
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;
