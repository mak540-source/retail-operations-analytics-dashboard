-- ============================================================
-- Retail Operations Analytics Dashboard
-- File: 02_load_data.sql
-- Description: Load data from CSV files into each table.
--   Option A: Use LOAD DATA INFILE (fastest, MySQL server method)
--   Option B: Use MySQL Workbench Table Data Import Wizard (easiest for beginners)
--   This file covers Option A. See README.md for Option B instructions.
-- ============================================================

USE retail_ops_db;

-- NOTE: Update the file paths below to match your local folder.
-- Example Windows path: 'C:/Users/YourName/retail-ops-dashboard/data/categories.csv'
-- Example Mac/Linux path: '/home/yourname/retail-ops-dashboard/data/categories.csv'

-- If you get an "access denied" error, run this first:
-- SET GLOBAL local_infile = 1;
-- And connect with: mysql --local-infile=1 -u root -p

-- ============================================================
-- Load categories
-- ============================================================
LOAD DATA LOCAL INFILE './data/categories.csv'
INTO TABLE categories
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(category_id, category_name);

-- ============================================================
-- Load suppliers
-- ============================================================
LOAD DATA LOCAL INFILE './data/suppliers.csv'
INTO TABLE suppliers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(supplier_id, supplier_name, specialty, location);

-- ============================================================
-- Load stores
-- ============================================================
LOAD DATA LOCAL INFILE './data/stores.csv'
INTO TABLE stores
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(store_id, store_name, region, city_state);

-- ============================================================
-- Load products (must come after categories + suppliers)
-- ============================================================
LOAD DATA LOCAL INFILE './data/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_name, category_id, supplier_id, unit_cost, unit_price);

-- ============================================================
-- Load inventory (must come after stores + products)
-- ============================================================
LOAD DATA LOCAL INFILE './data/inventory.csv'
INTO TABLE inventory
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(inventory_id, store_id, product_id, stock_quantity, reorder_level, low_stock_flag, last_restocked);

-- ============================================================
-- Load orders (must come after stores)
-- ============================================================
LOAD DATA LOCAL INFILE './data/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, store_id, order_date, @delivery_date, @delivery_days, fulfillment_status, order_total)
SET
  delivery_date = NULLIF(@delivery_date, ''),
  delivery_days = NULLIF(@delivery_days, '');

-- ============================================================
-- Load order_details (must come after orders + products)
-- ============================================================
LOAD DATA LOCAL INFILE './data/order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(detail_id, order_id, product_id, quantity_ordered, unit_price, line_total);

-- ============================================================
-- Verify row counts after loading
-- ============================================================
SELECT 'categories'   AS table_name, COUNT(*) AS row_count FROM categories
UNION ALL
SELECT 'suppliers',   COUNT(*) FROM suppliers
UNION ALL
SELECT 'stores',      COUNT(*) FROM stores
UNION ALL
SELECT 'products',    COUNT(*) FROM products
UNION ALL
SELECT 'inventory',   COUNT(*) FROM inventory
UNION ALL
SELECT 'orders',      COUNT(*) FROM orders
UNION ALL
SELECT 'order_details', COUNT(*) FROM order_details;
