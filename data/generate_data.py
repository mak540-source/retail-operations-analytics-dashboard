import csv
import random
from datetime import datetime, timedelta

random.seed(42)

categories = [
    ("CAT01", "Fresh Produce"),
    ("CAT02", "Dairy & Eggs"),
    ("CAT03", "Meat & Seafood"),
    ("CAT04", "Bakery"),
    ("CAT05", "Frozen Foods"),
    ("CAT06", "Beverages"),
    ("CAT07", "Snacks & Candy"),
    ("CAT08", "Household & Cleaning"),
    ("CAT09", "Personal Care"),
    ("CAT10", "Baby & Toddler"),
]

suppliers = [
    ("SUP01", "FreshFarm Co.", "Fresh Produce", "Chicago, IL"),
    ("SUP02", "DairyBest Inc.", "Dairy & Eggs", "Madison, WI"),
    ("SUP03", "Pacific Seafood", "Meat & Seafood", "Seattle, WA"),
    ("SUP04", "Sunrise Bakery", "Bakery", "Atlanta, GA"),
    ("SUP05", "Arctic Foods", "Frozen Foods", "Minneapolis, MN"),
    ("SUP06", "BlueSky Beverages", "Beverages", "Dallas, TX"),
    ("SUP07", "Snack World", "Snacks & Candy", "Columbus, OH"),
    ("SUP08", "CleanHome Corp.", "Household & Cleaning", "Detroit, MI"),
    ("SUP09", "GlowUp Supply", "Personal Care", "Miami, FL"),
    ("SUP10", "TinySteps LLC", "Baby & Toddler", "Phoenix, AZ"),
]

stores = [
    ("STR01", "Store 4721", "Northeast", "Boston, MA"),
    ("STR02", "Store 1803", "Southeast", "Atlanta, GA"),
    ("STR03", "Store 2294", "Midwest", "Chicago, IL"),
    ("STR04", "Store 3317", "Southwest", "Dallas, TX"),
    ("STR05", "Store 5501", "West", "Los Angeles, CA"),
    ("STR06", "Store 6042", "Northeast", "New York, NY"),
    ("STR07", "Store 7188", "Midwest", "Columbus, OH"),
    ("STR08", "Store 8830", "Southeast", "Orlando, FL"),
]

products = [
    ("PRD001","Organic Bananas","CAT01","SUP01",0.59,2.99),
    ("PRD002","Baby Spinach 5oz","CAT01","SUP01",1.20,3.49),
    ("PRD003","Roma Tomatoes","CAT01","SUP01",0.75,2.49),
    ("PRD004","Whole Milk 1gal","CAT02","SUP02",2.10,4.29),
    ("PRD005","Large Eggs 12ct","CAT02","SUP02",1.80,4.99),
    ("PRD006","Shredded Cheddar 2lb","CAT02","SUP02",3.50,7.49),
    ("PRD007","Chicken Breast 2lb","CAT03","SUP03",4.20,8.99),
    ("PRD008","Atlantic Salmon 1lb","CAT03","SUP03",5.50,10.99),
    ("PRD009","Ground Beef 1lb","CAT03","SUP03",3.80,7.49),
    ("PRD010","White Sandwich Bread","CAT04","SUP04",0.90,2.79),
    ("PRD011","Blueberry Muffins 4ct","CAT04","SUP04",1.50,3.99),
    ("PRD012","Bagels 6ct","CAT04","SUP04",1.20,3.49),
    ("PRD013","Frozen Pizza 12in","CAT05","SUP05",3.20,6.98),
    ("PRD014","Frozen Broccoli 12oz","CAT05","SUP05",1.10,2.68),
    ("PRD015","Ice Cream 1.5qt","CAT05","SUP05",2.80,5.98),
    ("PRD016","Orange Juice 52oz","CAT06","SUP06",1.80,4.49),
    ("PRD017","Sparkling Water 12pk","CAT06","SUP06",2.50,5.99),
    ("PRD018","2% Reduced Fat Milk","CAT02","SUP02",2.00,4.19),
    ("PRD019","Potato Chips 8oz","CAT07","SUP07",0.90,3.49),
    ("PRD020","Mixed Nuts 10oz","CAT07","SUP07",4.20,8.99),
    ("PRD021","Granola Bars 6ct","CAT07","SUP07",1.80,4.29),
    ("PRD022","Laundry Detergent 64oz","CAT08","SUP08",5.20,10.99),
    ("PRD023","Paper Towels 6pk","CAT08","SUP08",3.80,8.49),
    ("PRD024","Dish Soap 24oz","CAT08","SUP08",1.50,3.29),
    ("PRD025","Shampoo 12oz","CAT09","SUP09",2.20,5.49),
    ("PRD026","Body Wash 18oz","CAT09","SUP09",2.50,5.99),
    ("PRD027","Toothpaste 4oz","CAT09","SUP09",1.20,3.49),
    ("PRD028","Baby Wipes 72ct","CAT10","SUP10",2.80,5.99),
    ("PRD029","Diapers Size 3 27ct","CAT10","SUP10",8.50,16.99),
    ("PRD030","Baby Formula 12oz","CAT10","SUP10",10.20,22.99),
]

reorder_levels = {
    "CAT01": (30, 80), "CAT02": (25, 70), "CAT03": (20, 60),
    "CAT04": (20, 65), "CAT05": (25, 75), "CAT06": (30, 80),
    "CAT07": (25, 70), "CAT08": (20, 60), "CAT09": (20, 60), "CAT10": (15, 50),
}

# Write categories.csv
with open("/home/claude/retail-ops-dashboard/data/categories.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["category_id","category_name"])
    w.writerows(categories)

# Write suppliers.csv
with open("/home/claude/retail-ops-dashboard/data/suppliers.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["supplier_id","supplier_name","specialty","location"])
    w.writerows(suppliers)

# Write stores.csv
with open("/home/claude/retail-ops-dashboard/data/stores.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["store_id","store_name","region","city_state"])
    w.writerows(stores)

# Write products.csv
with open("/home/claude/retail-ops-dashboard/data/products.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["product_id","product_name","category_id","supplier_id","unit_cost","unit_price"])
    w.writerows(products)

# Write inventory.csv
inventory_rows = []
inv_id = 1
for store_id, _, _, _ in stores:
    for prod_id, _, cat_id, _, _, _ in products:
        reorder_min, reorder_max = reorder_levels[cat_id]
        reorder_level = random.randint(reorder_min, reorder_max)
        stock_quantity = random.randint(0, reorder_level * 3)
        low_stock_flag = 1 if stock_quantity <= reorder_level else 0
        last_restocked = datetime(2024, 1, 1) + timedelta(days=random.randint(0, 364))
        inventory_rows.append([
            f"INV{inv_id:04d}", store_id, prod_id,
            stock_quantity, reorder_level,
            low_stock_flag, last_restocked.strftime("%Y-%m-%d")
        ])
        inv_id += 1

with open("/home/claude/retail-ops-dashboard/data/inventory.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["inventory_id","store_id","product_id","stock_quantity","reorder_level","low_stock_flag","last_restocked"])
    w.writerows(inventory_rows)

# Write orders.csv and order_details.csv
start_date = datetime(2024, 1, 1)
order_rows = []
detail_rows = []
order_id = 1
detail_id = 1

for _ in range(700):
    store = random.choice(stores)
    store_id = store[0]
    order_date = start_date + timedelta(days=random.randint(0, 364))

    status = random.choices(
        ["Completed","In Progress","Delayed","Cancelled"],
        weights=[0.65, 0.15, 0.12, 0.08]
    )[0]

    if status == "Completed":
        delivery_days = random.randint(1, 5)
        delivery_date = order_date + timedelta(days=delivery_days)
    elif status == "Delayed":
        delivery_days = random.randint(6, 14)
        delivery_date = order_date + timedelta(days=delivery_days)
    else:
        delivery_days = None
        delivery_date = None

    num_items = random.randint(1, 5)
    selected_products = random.sample(products, num_items)
    order_total = 0.0

    for prod in selected_products:
        prod_id = prod[0]
        unit_price = prod[5]
        qty = random.randint(1, 10)
        total = round(qty * unit_price, 2)
        order_total += total
        detail_rows.append([
            f"DTL{detail_id:05d}",
            f"ORD{order_id:05d}",
            prod_id, qty, unit_price, total
        ])
        detail_id += 1

    order_rows.append([
        f"ORD{order_id:05d}",
        store_id,
        order_date.strftime("%Y-%m-%d"),
        delivery_date.strftime("%Y-%m-%d") if delivery_date else "",
        delivery_days if delivery_days is not None else "",
        status,
        round(order_total, 2)
    ])
    order_id += 1

with open("/home/claude/retail-ops-dashboard/data/orders.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["order_id","store_id","order_date","delivery_date","delivery_days","fulfillment_status","order_total"])
    w.writerows(order_rows)

with open("/home/claude/retail-ops-dashboard/data/order_details.csv", "w", newline="") as f:
    w = csv.writer(f)
    w.writerow(["detail_id","order_id","product_id","quantity_ordered","unit_price","line_total"])
    w.writerows(detail_rows)

print("Dataset generation complete!")
print(f"  categories.csv:    {len(categories)} rows")
print(f"  suppliers.csv:     {len(suppliers)} rows")
print(f"  stores.csv:        {len(stores)} rows")
print(f"  products.csv:      {len(products)} rows")
print(f"  inventory.csv:     {len(inventory_rows)} rows")
print(f"  orders.csv:        {len(order_rows)} rows")
print(f"  order_details.csv: {len(detail_rows)} rows")
total = len(categories)+len(suppliers)+len(stores)+len(products)+len(inventory_rows)+len(order_rows)+len(detail_rows)
print(f"  TOTAL RECORDS:     {total}")
