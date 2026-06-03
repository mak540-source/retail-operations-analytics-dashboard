# Project Overview
## Retail Operations Analytics Dashboard

---

## Business Problem

Retail operations generate enormous amounts of data every day — sales transactions, inventory counts, order fulfillment records, supplier deliveries. The challenge isn't collecting the data. The challenge is connecting it, organizing it, and turning it into decisions.

In large retail environments like Walmart, data often lives in separate systems:
- POS (point-of-sale) systems track sales
- WMS (warehouse management systems) track inventory
- OMS (order management systems) track fulfillment
- Supplier portals track purchase orders and delivery

Without a unified analytics layer, managers answer critical questions by manually pulling reports, copying data into spreadsheets, and making decisions based on incomplete information.

**This project builds that unified analytics layer** — a connected database backed by a visual dashboard that gives operations teams a single source of truth.

---

## Who the Dashboard Serves

**Primary Users:**
- Store Operations Managers — daily monitoring of orders, fulfillment status, and stock alerts
- Inventory/Supply Chain Analysts — reorder decisions, supplier evaluation, risk identification
- Regional Directors — cross-store performance comparison and regional benchmarking

**Secondary Users:**
- IT/MIS Analysts — maintaining the data pipeline, ensuring data quality
- Merchandising Teams — product performance analysis, category mix decisions

---

## What Decisions the Dashboard Supports

| Decision | Data Used | Dashboard Page |
|---|---|---|
| Should we reorder Product X at Store Y today? | inventory: stock_quantity vs reorder_level | Inventory & Low Stock |
| Which store is underperforming on fulfillment this month? | orders: delivery_days by store | Fulfillment & Suppliers |
| What were our top-selling categories last quarter? | order_details + categories | Sales & Product Analysis |
| Which supplier has the most low-stock incidents? | inventory + suppliers | Fulfillment & Suppliers |
| What is our on-time fulfillment rate this month? | orders: fulfillment_status | Executive Summary |
| Which regions are growing fastest? | orders + stores by month | Executive Summary |

---

## Why This Project Is Valuable for Target Roles

### MIS / IT Roles
- Demonstrates relational database design with normalized tables, primary keys, and foreign keys
- Shows understanding of data pipelines (CSV → MySQL → BI tool)
- Reflects systems thinking: how do different data sources connect?

### Data Analyst Roles
- 12 SQL queries answering real business questions
- DAX measures in Power BI showing analytical depth
- Data modeling with a fact table (order_details) and dimension tables

### Business Analyst Roles
- Translates business requirements into a data solution
- Builds KPIs tied to actual operational decisions
- Documents the system for non-technical stakeholders

### Supply Chain / Operations Analyst Roles
- Inventory reorder logic mirrors real retail replenishment systems
- Fulfillment tracking reflects online grocery pickup operations
- Supplier performance analysis supports vendor management decisions

---

## Technical Architecture

```
[Raw Data Layer]
Python script generates realistic CSV files
  ↓
[Database Layer]
MySQL database with 7 normalized tables
  ↓
[Analysis Layer]
12 SQL queries for business reporting
  ↓
[Visualization Layer]
Power BI (primary) + Excel (secondary)
  ↓
[Insight Layer]
KPI cards, charts, slicers, alerts
```

---

## Design Decisions

**Why normalize the database?**
Rather than putting everything in one flat table, the database is split into 7 related tables. This mirrors how real retail systems work (separate tables for products, orders, inventory) and avoids data duplication. It also makes the data easier to maintain — if a product name changes, you update one row in `products`, not thousands of rows in `order_details`.

**Why include a low_stock_flag column?**
The flag is pre-calculated at the database level (1 if stock ≤ reorder_level). This makes querying and filtering much faster — instead of calculating `stock_quantity <= reorder_level` every time, you filter on a simple binary column. This is a common pattern in operational data warehouses.

**Why store unit_price in order_details instead of only in products?**
Prices change over time. If you only store price in `products`, historical orders would show wrong prices after a price update. Capturing price at the time of the order (in `order_details`) is standard retail data modeling practice.

**Why use delivery_days instead of calculating it each time?**
Pre-calculating delivery_days = delivery_date − order_date saves computation in every query that uses it. It's a form of denormalization that improves query performance, which is acceptable for a reporting-focused system.

---

## Limitations and Future Improvements

| Limitation | Future Improvement |
|---|---|
| Static dataset (no live refresh) | Connect to a live MySQL or cloud database (Azure SQL, BigQuery) |
| No customer-level data | Add a customers table for customer lifetime value analysis |
| No return/refund tracking | Add an order_returns table |
| No seasonal demand modeling | Add a forecasting module using Python (Prophet or statsmodels) |
| No cost margin analysis | Add a margin calculation using unit_cost from products |
| Excel requires manual refresh | Automate with Power Automate or a Python refresh script |

---

## Connections to Real Walmart Operations

This project was designed to reflect actual retail operations experience:

| Real Experience | Project Feature |
|---|---|
| Online grocery pickup orders | orders + fulfillment_status tracking |
| Inventory scanning and counting | inventory table with reorder levels |
| Stockout prevention and alerts | low_stock_flag and Low Stock Alert page |
| Order routing and fulfillment | delivery_days and Avg Fulfillment Time KPI |
| Supplier check-in and receiving | suppliers table and Supplier Performance query |
| Operational reporting | SQL queries + Power BI dashboard |
