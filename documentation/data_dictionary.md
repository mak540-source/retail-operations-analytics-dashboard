# Data Dictionary
## Retail Operations Analytics Dashboard

This document defines every column in every table. Use this when someone asks "what does this column mean?" in an interview or code review.

---

## Table: categories

Stores the product category taxonomy. Every product belongs to exactly one category.

| Column | Data Type | Description | Example |
|---|---|---|---|
| category_id | VARCHAR(10) | Primary key. Unique identifier for the category. | CAT01 |
| category_name | VARCHAR(100) | Full name of the product category. | Fresh Produce |

**Relationships:** One category → many products (one-to-many)

---

## Table: suppliers

Stores vendor information. Each supplier provides products in a specific specialty area.

| Column | Data Type | Description | Example |
|---|---|---|---|
| supplier_id | VARCHAR(10) | Primary key. Unique identifier for the supplier. | SUP03 |
| supplier_name | VARCHAR(100) | Company name of the supplier. | Pacific Seafood |
| specialty | VARCHAR(100) | Product area the supplier focuses on. | Meat & Seafood |
| location | VARCHAR(100) | City and state where supplier is based. | Seattle, WA |

**Relationships:** One supplier → many products (one-to-many)

---

## Table: stores

Stores location and regional grouping for each retail location.

| Column | Data Type | Description | Example |
|---|---|---|---|
| store_id | VARCHAR(10) | Primary key. Unique identifier for the store. | STR05 |
| store_name | VARCHAR(100) | Display name including store number. | Store 5501 |
| region | VARCHAR(50) | Geographic region grouping. | West |
| city_state | VARCHAR(100) | Physical city and state of store location. | Los Angeles, CA |

**Regions used:** Northeast, Southeast, Midwest, Southwest, West

**Relationships:** One store → many orders, many inventory records (one-to-many)

---

## Table: products

The product catalog. Contains pricing, category assignment, and supplier linkage for each SKU.

| Column | Data Type | Description | Example |
|---|---|---|---|
| product_id | VARCHAR(10) | Primary key. Unique product SKU. | PRD007 |
| product_name | VARCHAR(150) | Full display name of the product. | Chicken Breast 2lb |
| category_id | VARCHAR(10) | Foreign key → categories.category_id | CAT03 |
| supplier_id | VARCHAR(10) | Foreign key → suppliers.supplier_id | SUP03 |
| unit_cost | DECIMAL(10,2) | Wholesale cost paid to supplier per unit. | 4.20 |
| unit_price | DECIMAL(10,2) | Retail selling price charged to customer. | 8.99 |

**Margin note:** unit_price − unit_cost = gross profit per unit. Margin = (unit_price − unit_cost) / unit_price × 100.

**Relationships:** Many products → one category; many products → one supplier; one product → many order_details; one product → many inventory records

---

## Table: inventory

Tracks the current stock level for each product at each store. This is the core table for inventory health monitoring.

| Column | Data Type | Description | Example |
|---|---|---|---|
| inventory_id | VARCHAR(10) | Primary key. Unique record per store-product pair. | INV0042 |
| store_id | VARCHAR(10) | Foreign key → stores.store_id | STR03 |
| product_id | VARCHAR(10) | Foreign key → products.product_id | PRD005 |
| stock_quantity | INT | Current number of units on hand at this store. | 18 |
| reorder_level | INT | Minimum threshold — if stock_quantity ≤ this value, reorder is needed. | 25 |
| low_stock_flag | TINYINT(1) | 1 if stock_quantity ≤ reorder_level; 0 if stock is adequate. | 1 |
| last_restocked | DATE | Date the product was last restocked at this store. | 2024-08-14 |

**Key business logic:** low_stock_flag = 1 triggers a reorder alert. The gap between reorder_level and stock_quantity tells you how many units need to be ordered.

**Relationships:** Many inventory records → one store; many inventory records → one product

---

## Table: orders

The order header table. Each row represents one customer or fulfillment order placed at a store.

| Column | Data Type | Description | Example |
|---|---|---|---|
| order_id | VARCHAR(10) | Primary key. Unique order identifier. | ORD00142 |
| store_id | VARCHAR(10) | Foreign key → stores.store_id. The store that processed the order. | STR01 |
| order_date | DATE | Date the order was placed. | 2024-03-15 |
| delivery_date | DATE | Date the order was fulfilled/delivered. NULL if not yet complete. | 2024-03-17 |
| delivery_days | INT | Number of days from order_date to delivery_date. NULL if not complete. | 2 |
| fulfillment_status | VARCHAR(50) | Current status of the order. | Completed |
| order_total | DECIMAL(10,2) | Total dollar value of all items in the order. | 47.82 |

**fulfillment_status values:**
- `Completed` — Order was fulfilled on time
- `In Progress` — Order is active, not yet delivered
- `Delayed` — Order took longer than standard lead time (6–14 days)
- `Cancelled` — Order was cancelled; excluded from sales metrics

**Relationships:** One order → many order_details (one-to-many); many orders → one store

---

## Table: order_details

The order line-item table. Each row is one product on one order. An order with 3 products has 3 rows in this table.

| Column | Data Type | Description | Example |
|---|---|---|---|
| detail_id | VARCHAR(10) | Primary key. Unique line item identifier. | DTL00381 |
| order_id | VARCHAR(10) | Foreign key → orders.order_id | ORD00142 |
| product_id | VARCHAR(10) | Foreign key → products.product_id | PRD022 |
| quantity_ordered | INT | Number of units of this product ordered. | 3 |
| unit_price | DECIMAL(10,2) | Selling price per unit at time of order. | 10.99 |
| line_total | DECIMAL(10,2) | quantity_ordered × unit_price | 32.97 |

**Note:** unit_price is stored here (not just in products) because prices can change over time. Capturing it at order time is standard practice in retail data modeling.

**Relationships:** Many order_details → one order; many order_details → one product

---

## Entity Relationship Summary

```
categories ──< products >── suppliers
                  │
                  ├──< order_details >── orders >── stores
                  │
                  └──< inventory >── stores
```

**Reading the diagram:**
- `──<` means "one-to-many" (one category has many products)
- `>──` means "many-to-one" (many products belong to one category)
- The `products` table is the central product dimension
- `order_details` is the main fact table — it connects products and orders
- `inventory` is a second fact-like table connecting products and stores
