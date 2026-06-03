# Power BI Dashboard Guide
## Retail Operations Analytics Dashboard

---

## Step 1 — Connect Your Data

1. Open Power BI Desktop (free download from Microsoft)
2. Click **Get Data → Text/CSV**
3. Import each file in this order (order matters for relationships):
   - categories.csv
   - suppliers.csv
   - stores.csv
   - products.csv
   - inventory.csv
   - orders.csv
   - order_details.csv
4. For each file, click **Transform Data** to open Power Query
5. Make sure these columns are the correct data type:
   - order_date, delivery_date, last_restocked → **Date**
   - order_total, line_total, unit_price → **Decimal Number**
   - stock_quantity, reorder_level, delivery_days, quantity_ordered → **Whole Number**
   - low_stock_flag → **Whole Number** (0 or 1)
6. Click **Close & Apply**

---

## Step 2 — Create Relationships (Model View)

Click the **Model** icon on the left sidebar. Create these relationships by dragging:

| From Table | From Column | To Table | To Column | Cardinality |
|---|---|---|---|---|
| products | category_id | categories | category_id | Many-to-One |
| products | supplier_id | suppliers | supplier_id | Many-to-One |
| order_details | product_id | products | product_id | Many-to-One |
| order_details | order_id | orders | order_id | Many-to-One |
| orders | store_id | stores | store_id | Many-to-One |
| inventory | store_id | stores | store_id | Many-to-One |
| inventory | product_id | products | product_id | Many-to-One |

**Interview tip:** "I built a star-schema-style model with a central fact table (order_details) connected to dimension tables. This is standard in data warehousing and makes DAX measures simple and reliable."

---

## Step 3 — Create a Date Table (Best Practice)

In Power BI, create a dedicated date table so your time-intelligence functions work correctly.

1. Click **Modeling → New Table**
2. Paste this DAX:

```dax
DateTable = 
CALENDAR(DATE(2024,1,1), DATE(2024,12,31))
```

3. Then add columns to it:

```dax
Year = YEAR(DateTable[Date])
Month = MONTH(DateTable[Date])
MonthName = FORMAT(DateTable[Date], "MMMM")
MonthShort = FORMAT(DateTable[Date], "MMM")
Quarter = "Q" & QUARTER(DateTable[Date])
MonthYear = FORMAT(DateTable[Date], "MMM YYYY")
WeekNumber = WEEKNUM(DateTable[Date])
```

4. Mark as Date Table: right-click the table → **Mark as date table** → select **Date**
5. Connect it: drag **DateTable[Date]** → **orders[order_date]**

---

## Step 4 — DAX Measures

Create a blank table called **_Measures** to keep things organized.
Click **Modeling → New Table** → name it `_Measures`, then delete the formula and just name it.

Create each measure using **Modeling → New Measure**:

### Core Sales Measures

```dax
Total Sales = 
SUMX(
    FILTER(
        order_details,
        RELATED(orders[fulfillment_status]) <> "Cancelled"
    ),
    order_details[line_total]
)
```
*What it does: Adds up all line totals, excluding cancelled orders.*

```dax
Total Orders = 
COUNTROWS(orders)
```

```dax
Completed Orders = 
CALCULATE(
    COUNTROWS(orders),
    orders[fulfillment_status] = "Completed"
)
```

```dax
Average Order Value = 
DIVIDE(
    SUMX(orders, orders[order_total]),
    COUNTROWS(orders)
)
```
*What it does: Divides total revenue by number of orders. DIVIDE() is safer than "/" because it handles zero gracefully.*

```dax
Total Units Sold = 
CALCULATE(
    SUM(order_details[quantity_ordered]),
    FILTER(
        orders,
        orders[fulfillment_status] <> "Cancelled"
    )
)
```

### Fulfillment Measures

```dax
Fulfillment Rate % = 
DIVIDE(
    CALCULATE(COUNTROWS(orders), orders[fulfillment_status] = "Completed"),
    COUNTROWS(orders),
    0
) * 100
```
*What it does: Shows what percentage of orders were successfully completed.*

```dax
Avg Fulfillment Days = 
CALCULATE(
    AVERAGE(orders[delivery_days]),
    orders[fulfillment_status] = "Completed"
)
```

```dax
Delayed Orders = 
CALCULATE(
    COUNTROWS(orders),
    orders[fulfillment_status] = "Delayed"
)
```

```dax
Cancelled Orders = 
CALCULATE(
    COUNTROWS(orders),
    orders[fulfillment_status] = "Cancelled"
)
```

### Inventory Measures

```dax
Low Stock Count = 
CALCULATE(
    COUNTROWS(inventory),
    inventory[low_stock_flag] = 1
)
```

```dax
Total Stock Units = 
SUM(inventory[stock_quantity])
```

```dax
Low Stock % = 
DIVIDE(
    CALCULATE(COUNTROWS(inventory), inventory[low_stock_flag] = 1),
    COUNTROWS(inventory),
    0
) * 100
```

---

## Step 5 — Dashboard Layout (4 Pages)

### PAGE 1: Executive Summary

**Purpose:** High-level KPIs at a glance for managers and leadership.

**Layout:** Top row = 5 KPI cards. Middle = two charts side by side. Bottom = one wide chart.

#### KPI Cards (top row — use Card visual):
1. **Total Sales** → measure: `Total Sales`, format as currency
2. **Total Orders** → measure: `Total Orders`
3. **Avg Order Value** → measure: `Average Order Value`, format as currency
4. **Fulfillment Rate** → measure: `Fulfillment Rate %`, format as percentage with 1 decimal
5. **Low Stock Count** → measure: `Low Stock Count`, color the value red

#### Sales Trend Line Chart (middle-left):
- Visual: Line Chart
- X-axis: DateTable[MonthYear]
- Y-axis: `Total Sales`
- Title: "Monthly Sales Trend (2024)"
- Add a data label on the last point

#### Fulfillment Status Donut (middle-right):
- Visual: Donut Chart
- Legend: orders[fulfillment_status]
- Values: `Total Orders`
- Colors: Completed=green, Delayed=orange, In Progress=blue, Cancelled=red
- Title: "Order Fulfillment Breakdown"

#### Sales by Region Bar Chart (bottom):
- Visual: Clustered Bar Chart
- Y-axis: stores[region]
- X-axis: `Total Sales`
- Title: "Total Sales by Region"

---

### PAGE 2: Sales & Product Analysis

**Purpose:** Deeper dive into product performance and category mix.

#### Sales by Category Bar Chart:
- Visual: Clustered Bar Chart
- Y-axis: categories[category_name]
- X-axis: `Total Sales`
- Sort descending by Total Sales
- Title: "Sales by Product Category"

#### Top 10 Products Table:
- Visual: Table
- Columns: product_name, category_name, `Total Units Sold`, `Total Sales`
- Sort by Total Sales descending
- Add a data bar to the Total Sales column (Format → Cell elements → Data bars)
- Title: "Top 10 Products by Revenue"

#### Sales by Store Matrix:
- Visual: Matrix
- Rows: stores[region], stores[store_name]
- Values: `Total Sales`, `Total Orders`, `Average Order Value`
- Title: "Store Performance by Region"

---

### PAGE 3: Inventory & Low Stock

**Purpose:** Monitor inventory health, identify risk items before stockouts occur.

#### Low Stock Alert Table:
- Visual: Table
- Columns: stores[store_name], stores[region], products[product_name],
  categories[category_name], inventory[stock_quantity], inventory[reorder_level],
  suppliers[supplier_name]
- Filter: inventory[low_stock_flag] = 1
- Conditional formatting on stock_quantity: red if below reorder_level
- Title: "⚠ Low Stock Alert — Items Requiring Reorder"

#### Low Stock by Category Bar Chart:
- Visual: Clustered Bar Chart
- X-axis: categories[category_name]
- Y-axis: `Low Stock Count`
- Color bars red
- Title: "Low Stock Items by Category"

#### Inventory Health Gauge (or KPI card):
- Visual: KPI Card or Gauge
- Value: `Low Stock %`
- Title: "% of SKUs at Low Stock"

#### Stock vs Reorder Level Scatter:
- Visual: Scatter Chart
- X-axis: inventory[reorder_level]
- Y-axis: inventory[stock_quantity]
- Size: `Total Units Sold`
- Legend: categories[category_name]
- Title: "Stock Level vs Reorder Threshold"
- Points below the diagonal line are at risk

---

### PAGE 4: Fulfillment & Supplier Performance

**Purpose:** Operational efficiency — how fast are orders fulfilled? Which suppliers have risk?

#### Avg Fulfillment Days by Store Bar Chart:
- Visual: Clustered Column Chart
- X-axis: stores[store_name]
- Y-axis: `Avg Fulfillment Days`
- Color by region (legend = stores[region])
- Title: "Average Fulfillment Time by Store (Completed Orders)"

#### Monthly Fulfillment Rate Line Chart:
- Visual: Line Chart
- X-axis: DateTable[MonthYear]
- Y-axis: `Fulfillment Rate %`
- Add a constant line at 85% as a target reference
- Title: "Monthly Fulfillment Rate (%)"

#### Supplier Performance Table:
- Visual: Table
- Columns: suppliers[supplier_name], suppliers[specialty],
  products[product_id] (count), `Total Units Sold`, `Total Sales`, `Low Stock Count`
- Sort by Total Sales descending
- Title: "Supplier Performance Summary"

---

## Step 6 — Add Slicers (All Pages)

Add these slicers to EVERY page using the Sync Slicers feature (View → Sync Slicers):

1. **Date Range Slicer**
   - Field: DateTable[Date]
   - Style: Between (shows a date range picker)

2. **Category Slicer**
   - Field: categories[category_name]
   - Style: Dropdown or List

3. **Region Slicer**
   - Field: stores[region]
   - Style: List with checkboxes

4. **Supplier Slicer**
   - Field: suppliers[supplier_name]
   - Style: Dropdown

5. **Fulfillment Status Slicer**
   - Field: orders[fulfillment_status]
   - Style: List with checkboxes

**How to sync:** After adding slicers on Page 1, go to View → Sync Slicers → check all pages for each slicer.

---

## Step 7 — Formatting Tips

- Set a consistent color theme: go to **View → Themes → Customize**
  - Suggested: blue (#1F4E79) for headers, light gray (#F2F2F2) background
- Add a page title text box to each page
- Use bold font for KPI card titles
- Add a company-style logo placeholder in the top-left corner
- Enable tooltips on charts for better interactivity

---

## Interview Talking Points

> "I built a 4-page Power BI dashboard with a star schema data model connecting 7 tables. I wrote DAX measures for KPIs including Fulfillment Rate, Average Fulfillment Days, and Low Stock Count. I used slicers synced across all pages so users can filter by date, category, region, and supplier simultaneously. The inventory alert page uses conditional formatting to flag low-stock items in red, which directly mirrors how I monitored stock levels in my Walmart role."
