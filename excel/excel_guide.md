# Excel Dashboard Guide
## Retail Operations Analytics Dashboard

---

## Overview

The Excel dashboard is a secondary reporting file that mirrors the Power BI dashboard in a format that operations managers can open without any special software. It uses PivotTables, PivotCharts, Slicers, and conditional formatting.

---

## Step 1 — Import Your Data

1. Open Excel and create a new workbook named `RetailOps_Dashboard.xlsx`
2. For each CSV file, click **Data → Get Data → From Text/CSV**, import, and load to a sheet
3. Name each sheet to match the file:
   - `orders`
   - `order_details`
   - `products`
   - `categories`
   - `suppliers`
   - `stores`
   - `inventory`
4. Format each data range as a Table: click inside the data → **Insert → Table** → check "My table has headers"
5. Name each table to match the sheet (Table Design → Table Name in the top-left)

**Why tables?** Excel Tables automatically expand when new data is added, and PivotTables built on them refresh correctly.

---

## Step 2 — Create a Master Data Sheet

Create a new sheet called `MasterData`. This sheet will hold a combined flat table using XLOOKUP or Power Query for easy PivotTable building.

**Option A (Recommended — Power Query):**
1. Go to **Data → Get Data → Combine Queries → Merge**
2. Merge `order_details` with `orders` on `order_id`
3. Then merge with `products` on `product_id`
4. Then merge with `categories` on `category_id`
5. Then merge with `stores` on `store_id`
6. Then merge with `suppliers` on `supplier_id`
7. Load to a new sheet called `MasterData`

**Option B (Manual XLOOKUP approach for smaller datasets):**
In your `order_details` sheet, add these helper columns using XLOOKUP:

```excel
=XLOOKUP([@order_id], orders[order_id], orders[order_date])        → order_date
=XLOOKUP([@order_id], orders[order_id], orders[store_id])          → store_id
=XLOOKUP([@order_id], orders[order_id], orders[fulfillment_status]) → fulfillment_status
=XLOOKUP([@order_id], orders[order_id], orders[delivery_days])     → delivery_days
=XLOOKUP([@product_id], products[product_id], products[product_name]) → product_name
=XLOOKUP([@product_id], products[product_id], products[category_id])  → category_id
=XLOOKUP([@category_id], categories[category_id], categories[category_name]) → category_name
=XLOOKUP([@store_id], stores[store_id], stores[region])            → region
=XLOOKUP([@store_id], stores[store_id], stores[store_name])        → store_name
=YEAR([@order_date])                                               → Year
=MONTH([@order_date])                                              → Month
=TEXT([@order_date], "mmm yyyy")                                   → MonthYear
```

---

## Step 3 — Create PivotTables

Create a new sheet called `PivotTables`. Build each PivotTable by clicking **Insert → PivotTable → From Table/Range → select MasterData**.

### PivotTable 1: Sales by Month
- Rows: MonthYear
- Values: line_total (Sum) → rename to "Total Sales"
- Values: order_id (Count Distinct) → rename to "Total Orders"
- Sort by date order (not alphabetical — right-click → Sort → custom)

### PivotTable 2: Sales by Category
- Rows: category_name
- Values: line_total (Sum), quantity_ordered (Sum)
- Sort by Total Sales descending

### PivotTable 3: Sales by Region and Store
- Rows: region, store_name
- Values: line_total (Sum), order_id (Count)

### PivotTable 4: Top Products
- Rows: product_name, category_name
- Values: quantity_ordered (Sum), line_total (Sum)
- Apply Top 10 filter: Row Labels → Value Filters → Top 10 → by line_total

### PivotTable 5: Fulfillment Status Breakdown
- From the `orders` table
- Rows: fulfillment_status
- Values: order_id (Count)

### PivotTable 6: Avg Fulfillment Days by Store
- From the `orders` table (Completed only)
- Rows: store_name
- Values: delivery_days (Average)
- Filter: fulfillment_status = Completed

### PivotTable 7: Low Stock Items
- From the `inventory` table joined with products/stores
- Rows: store_name, product_name
- Values: stock_quantity (Sum), reorder_level (Sum)
- Filter: low_stock_flag = 1

---

## Step 4 — Create PivotCharts

For each PivotTable above, click inside it → **Insert → PivotChart**:

| Chart | Type | Notes |
|---|---|---|
| Sales by Month | Line Chart | Shows trend over time |
| Sales by Category | Horizontal Bar | Sort bars descending |
| Sales by Region | Clustered Column | Group by region |
| Fulfillment Status | Donut Chart | Color by status |
| Avg Fulfillment Days | Bar Chart | Sort fastest to slowest |
| Top 10 Products | Bar Chart | Sort by sales |

**Formatting tips:**
- Right-click chart → Format Chart Area → add shadow and rounded corners
- Use consistent color: blue (#1F4E79) for positive metrics, red (#C00000) for risk items
- Add data labels to all charts

---

## Step 5 — Add Slicers

Slicers are filter buttons that control PivotTables visually.

1. Click any PivotTable
2. Go to **PivotTable Analyze → Insert Slicer**
3. Add slicers for: `category_name`, `region`, `fulfillment_status`, `MonthYear`

**Connect slicers to multiple PivotTables:**
1. Right-click each slicer → **Report Connections**
2. Check ALL PivotTables you want it to control
3. This makes one click filter every chart at once

**Format slicers:**
- Slicer Tools → Options → choose a blue slicer style
- Resize to be uniform (e.g., 1.5 inches wide, 2 inches tall for list slicers)

---

## Step 6 — Build the Dashboard Sheet

Create a sheet called `Dashboard` — this is the sheet you'll show to others.

**Layout:**

```
Row 1:  [Logo/Title]   "Retail Operations Analytics Dashboard — 2024"
Row 2:  [Slicers: Category | Region | Fulfillment Status | Month]
Row 3:  [KPI Box 1] [KPI Box 2] [KPI Box 3] [KPI Box 4] [KPI Box 5]
Row 4-12: [Sales Trend Line Chart]    [Fulfillment Donut Chart]
Row 13-21: [Sales by Category Bar]    [Sales by Region Bar]
Row 22-30: [Low Stock Table]          [Top 10 Products Chart]
```

**Create KPI boxes manually:**
- Merge cells for each KPI (e.g., merge B3:C4)
- Type the KPI label in smaller font above
- Use a formula to pull from a PivotTable:
  ```excel
  =GETPIVOTDATA("line_total", PivotTables!$A$3)   → Total Sales
  =GETPIVOTDATA("order_id", PivotTables!$A$22)     → Total Orders
  ```
- Format Total Sales as Currency: `$#,##0`
- Make KPI numbers bold, 24pt font

**KPI box styling:**
- Fill color: dark blue (#1F4E79) for header, white for value
- Add a thin border around each box
- Use an icon (Insert → Icons) for each KPI

---

## Step 7 — Conditional Formatting for Low Stock

In the Low Stock table or the inventory sheet:

1. Select the `stock_quantity` column
2. **Home → Conditional Formatting → New Rule**
3. Rule: "Use a formula to determine which cells to format"
4. Formula: `=C2<=D2` (where C = stock_quantity, D = reorder_level)
5. Format: Red fill (#FFCCCC), Bold red text
6. Apply a second rule for very low (< 10 units):
   - Formula: `=C2<10`
   - Format: Dark red fill (#C00000), White bold text

This makes critically low items stand out immediately.

---

## Step 8 — Final Polish

- Hide the raw data sheets: right-click tab → Hide (keep Dashboard, PivotTables visible)
- Protect the Dashboard sheet: **Review → Protect Sheet** (password optional)
- Freeze the top rows: **View → Freeze Panes → Freeze Top Row**
- Save as `.xlsx`, not `.csv`
- Add a tab for `Documentation` with a brief description of each sheet

---

## Interview Talking Points

> "I built an Excel version of the dashboard using PivotTables, PivotCharts, and connected Slicers so that one filter updates every chart on the page simultaneously. I used conditional formatting to flag low-stock items in red — a direct parallel to how inventory alerts work in retail operations. The dashboard is designed so any manager can use it without training."
