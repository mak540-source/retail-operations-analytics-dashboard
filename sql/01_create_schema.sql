-- ============================================================
-- Retail Operations Analytics Dashboard
-- File: 01_create_schema.sql
-- Description: Creates the database and all normalized tables
-- Author: [Your Name]
-- ============================================================

-- Create and select the database
CREATE DATABASE IF NOT EXISTS retail_ops_db;
USE retail_ops_db;

-- ============================================================
-- TABLE 1: categories
-- Stores product category information
-- ============================================================
CREATE TABLE IF NOT EXISTS categories (
    category_id   VARCHAR(10)  NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (category_id)
);

-- ============================================================
-- TABLE 2: suppliers
-- Stores vendor/supplier information
-- ============================================================
CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id   VARCHAR(10)  NOT NULL,
    supplier_name VARCHAR(100) NOT NULL,
    specialty     VARCHAR(100),
    location      VARCHAR(100),
    PRIMARY KEY (supplier_id)
);

-- ============================================================
-- TABLE 3: stores
-- Stores location and region for each retail store
-- ============================================================
CREATE TABLE IF NOT EXISTS stores (
    store_id   VARCHAR(10)  NOT NULL,
    store_name VARCHAR(100) NOT NULL,
    region     VARCHAR(50)  NOT NULL,
    city_state VARCHAR(100),
    PRIMARY KEY (store_id)
);

-- ============================================================
-- TABLE 4: products
-- Stores product catalog with pricing and supplier linkage
-- ============================================================
CREATE TABLE IF NOT EXISTS products (
    product_id   VARCHAR(10)    NOT NULL,
    product_name VARCHAR(150)   NOT NULL,
    category_id  VARCHAR(10)    NOT NULL,
    supplier_id  VARCHAR(10)    NOT NULL,
    unit_cost    DECIMAL(10,2)  NOT NULL,
    unit_price   DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (product_id),
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- ============================================================
-- TABLE 5: inventory
-- Tracks stock levels per product per store
-- ============================================================
CREATE TABLE IF NOT EXISTS inventory (
    inventory_id   VARCHAR(10) NOT NULL,
    store_id       VARCHAR(10) NOT NULL,
    product_id     VARCHAR(10) NOT NULL,
    stock_quantity INT         NOT NULL DEFAULT 0,
    reorder_level  INT         NOT NULL DEFAULT 0,
    low_stock_flag TINYINT(1)  NOT NULL DEFAULT 0,  -- 1 = at or below reorder level
    last_restocked DATE,
    PRIMARY KEY (inventory_id),
    FOREIGN KEY (store_id)   REFERENCES stores(store_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ============================================================
-- TABLE 6: orders
-- Stores order header records (one row per order)
-- ============================================================
CREATE TABLE IF NOT EXISTS orders (
    order_id           VARCHAR(10)    NOT NULL,
    store_id           VARCHAR(10)    NOT NULL,
    order_date         DATE           NOT NULL,
    delivery_date      DATE,
    delivery_days      INT,
    fulfillment_status VARCHAR(50)    NOT NULL,
    order_total        DECIMAL(10,2)  NOT NULL,
    PRIMARY KEY (order_id),
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

-- ============================================================
-- TABLE 7: order_details
-- Stores individual line items for each order
-- ============================================================
CREATE TABLE IF NOT EXISTS order_details (
    detail_id        VARCHAR(10)   NOT NULL,
    order_id         VARCHAR(10)   NOT NULL,
    product_id       VARCHAR(10)   NOT NULL,
    quantity_ordered INT           NOT NULL,
    unit_price       DECIMAL(10,2) NOT NULL,
    line_total       DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (detail_id),
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
