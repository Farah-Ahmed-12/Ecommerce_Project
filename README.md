# Ecommerce SQL Data Cleaning & Validation

## Project Overview

This project focuses on cleaning, validating, and preparing an e-commerce dataset using **SQL Server**.

The main goal was to improve data quality, validate relationships and business rules, and prepare a clean analytical layer while keeping the original source tables unchanged.

The cleaned data is created using **SQL Views**.

---

## Data Sources

The project uses four main source tables:

* `customer_master`
* `ecommerce_sales_customer_analytics_150k`
* `product_catalog`
* `order_items`

---

## Data Cleaning Approach

The cleaning process included:

* Checking missing values
* Removing leading and trailing spaces
* Checking duplicate records
* Validating data ranges
* Validating categorical values
* Checking foreign key relationships
* Validating business rules
* Checking calculated financial fields
* Creating clean SQL views

---

# 1. Customer Master Cleaning

### Basic Validation

The `customer_master` table was checked for:

* Missing values
* Duplicate `customer_id`
* Invalid customer ages
* Text formatting and extra spaces
* Gender values
* Customer segments
* Location fields

### Data Cleaning

* Applied `TRIM()` to text fields.
* Replaced `Non-Binary` with `Other` in the `gender` field.
* Removed `customer_postal_code` from the clean analytical view because it was not required for the analysis.
* Reviewed numeric fields such as customer acquisition cost.

### Customer ID Validation

Customer IDs were checked against the e-commerce orders data.

**Result:** No unmatched customer IDs were found.

This confirms that every order is linked to a valid customer in the customer master.

---

# 2. Product Catalog Validation

The `product_master` table contains **1,175 products**, with **1,175 distinct product IDs**.

The following checks were performed:

* Missing values
* Extra spaces in text fields
* Negative unit prices
* Negative product costs
* Product rating range
* Product cost compared with unit price

### Results

* No missing values were found.
* No unwanted spaces were found.
* No negative prices or costs were found.
* All product ratings were within the expected `0–5` range.
* No products had a product cost greater than the unit price.

The product data passed the main validation checks.

---

# 3. Order Items Validation

The `order_items` table contains:

* **397,569 rows**
* **138,116 distinct orders**
* **1,175 distinct products**

### Data Quality Checks

The following checks were performed:

* Missing values
* Extra spaces
* Exact duplicate rows
* Invalid quantities
* Negative prices
* Invalid discount percentages
* Negative discounts
* Negative sales values
* Negative tax
* Negative shipping costs

### Results

* No missing values were found.
* No unwanted spaces were found.
* No exact duplicate rows were found.
* Quantities were valid.
* Prices were valid.
* Discount percentages were within the expected range.
* Sales, tax, and shipping values were valid.

### Business Rule Validation

The following financial calculations were verified:

* `gross_sales = quantity × unit_price`
* `discount_amount = gross_sales × discount_percentage`
* `net_sales = gross_sales - discount_amount + tax_amount + shipping_cost`
* `profit = net_sales - product_cost - shipping_cost`

All formula checks returned **0 differences**, confirming that the calculated financial fields were internally consistent.

Negative profit values were also checked. They were retained because they represent valid loss-making transactions rather than data errors.

---

# 4. E-commerce Orders Validation

The `ecommerce_sales_customer_analytics_150k` table contains:

* **138,116 rows**
* **138,116 distinct orders**

A clean analytical view was created:

`vw_ecommerce_sales_customer_clean`

Unnecessary duplicated customer information was removed from the analytical view, while order, delivery, payment, marketing, customer type, and financial fields were retained.

---

## Missing Values

Missing values were checked across the order data.

Some fields contained NULL values that were considered valid business cases rather than data errors.

Examples include:

* `delivery_days`
* `estimated_delivery_days`
* `customer_rating`
* `review_sentiment`
* `customer_review`
* `return_status`
* `return_reason`
* `campaign_name`
* `coupon_code`

For example, return-related fields can be NULL when an order was not returned.

---

## Text Cleaning

Text fields were checked using `TRIM()`.

**Result:** No unwanted leading or trailing spaces were found.

---

# 5. Categorical Data Validation

The main categorical fields were checked to identify unexpected values.

The following fields were validated:

* `order_status`
* `sales_channel`
* `payment_method`
* `payment_status`
* `currency`
* `shipping_method`
* `warehouse`
* `delivery_status`
* `return_status`
* `return_reason`
* `review_sentiment`
* `marketing_channel`
* `campaign_name`
* `customer_type`

The observed values were reviewed and no unexpected categorical values requiring cleaning were identified.

---

# 6. Customer Relationship Validation

The order data was checked against the cleaned customer master using `customer_id`.

**Result:**

* Unmatched customer IDs = **0**

This confirms that the customer relationship is valid and that every order references an existing customer.

---

# 7. Delivery Logic Validation

The relationship between:

* `delivery_days`
* `estimated_delivery_days`
* `delivery_status`

was validated.

The expected business logic is:

| Condition          | Delivery Status |
| ------------------ | --------------- |
| Actual < Estimated | Early           |
| Actual = Estimated | On Time         |
| Actual > Estimated | Delayed         |

Cancelled orders had NULL delivery values, which was considered valid because no delivery occurs for cancelled orders.

A total of 511 completed orders were initially classified as `Early` even though actual and estimated delivery days were both 0.
The delivery status logic was corrected in the clean analytical view, and the final validation returned 0 incorrect records.

### Issue Identified

A total of **511 completed orders** had:

* `delivery_days = 0`
* `estimated_delivery_days = 0`
* `delivery_status = Early`

Since the actual and estimated delivery days are equal, these records should logically be classified as **On Time**.

The records were identified for correction in the clean analytical layer.

---

# Clean Views

The project uses SQL Views to create the cleaned analytical layer while keeping the original source tables unchanged.

Main clean views include:

* `vw_customer_master_clean`
* `vw_ecommerce_sales_customer_clean`
* `vw_order_items_cleaned`
* `vw_Product_cleaned`

This approach preserves the original raw data and separates the cleaning logic from the source tables.

---

# Validation Summary

The main validation process covered:

| Area                   | Validation                                             |
| ---------------------- | ------------------------------------------------------ |
| Customer Data          | Missing values, duplicates, age, gender, text cleaning |
| Customer Relationships | Customer ID matching                                   |
| Product Data           | Missing values, prices, costs, ratings                 |
| Order Items            | Duplicates, quantities, prices, discounts              |
| Financial Data         | Sales, discounts, tax, shipping, profit formulas       |
| Categorical Data       | Status, payment, currency, shipping, marketing fields  |
| Delivery Data          | Actual vs estimated delivery logic                     |
| Data Structure         | Clean analytical views                                 |

All cleaning transformations were implemented through SQL Views. The original source tables were kept unchanged to preserve data lineage and allow comparison with the raw data.

# Power BI Dashboard & Analysis

After completing the SQL data cleaning and validation process, the cleaned analytical views were imported into **Power BI** for data modeling, DAX calculations, business analysis, and interactive dashboard development.

The dashboard was designed to transform the cleaned e-commerce data into actionable insights across **sales, customers, products, orders, payments, and shipping performance**.

---

## Data Modeling

A relational analytical model was created in Power BI using the cleaned SQL views.

The model follows a **star-schema-oriented structure**, with customer and product dimensions connected to transactional order and order-item data.

### Relationships

- `vw_customer_master_clean` → `vw_ecommerce_sales_customer_clean` using `customer_id`
- `vw_ecommerce_sales_customer_clean` → `vw_order_items_cleaned` using `order_id`
- `vw_Product_cleaned` → `vw_order_items_cleaned` using `product_id`

Single-direction filtering was used to maintain a clear filter flow and avoid ambiguous relationships.

### Data Grain

| Table | Grain |
|---|---|
| `vw_customer_master_clean` | One row per customer |
| `vw_ecommerce_sales_customer_clean` | One row per order |
| `vw_order_items_cleaned` | One row per order-product line |
| `vw_Product_cleaned` | One row per product |

### Power BI Data Model

<p align="center">
 <img width="1771" height="729" alt="Screenshot (2212)" src="https://github.com/user-attachments/assets/7b6ffb72-8ed7-44dd-907b-5726effed1d5" />

</p>
---

## DAX Measures

DAX measures were created to support the dashboard analysis and ensure that calculations were performed at the appropriate data grain.

### Key Measures

- Total Orders
- Total Customers
- Total Products
- Total Net Sales
- Total Profit
- Average Order Value
- Profit Margin
- Total Quantity
- Average Customer Revenue
- Average Orders per Customer
- Total Loyalty Points Earned
- Customer Lifetime Value
- Product Net Sales
- Product Profit
- Product Profit Margin
- Average Discount Percentage

Order-level metrics were calculated from the vw_ecommerce_sales_customer_clean view, while product-level sales, quantity, discount, and profitability metrics were calculated from the vw_order_items_cleaned view to avoid double-counting.

---

# Dashboard Pages

## 1. Executive Overview

The **Executive Overview** provides a high-level summary of overall business performance.

### Key Analysis

- Total Orders
- Total Net Sales
- Total Profit
- Total Customers
- Sales Trends
- Order Status
- Top 5 Products By Sales
- Overall Business KPIs

### Dashboard Preview
<p align="center">
  <img width="1337" height="737" alt="Screenshot (2213)" src="https://github.com/user-attachments/assets/ebab8dc2-f5c2-47ee-96c6-5e1e40088601" />

</p>

---

## 2. Sales & Customer Analysis

This page focuses on **sales performance and customer behavior**.

### Key Analysis

- Average Customer Revenue
- Customer Lifetime Value
- Customer Segments
- Customer Age Groups
- Sales by Country / State
- loyalty Points vs Net Sales by customer

### Dashboard Preview

<p align="center">
  <img width="1351" height="749" alt="Screenshot (2215)" src="https://github.com/user-attachments/assets/20fa7c86-4cc0-4a67-a67a-a10ac8a08a31" />

</p>

---

## 3. Product & Sales Performance

This page analyzes **product-level sales, quantity, discounts, costs, and profitability**.

### Key Analysis

- Top Products by Net Sales
- Top Products by Profit
- Product Quantity
- Product Cost vs. Profit
- Discount Rate vs. Profit Margin
- Product Category Performance
- Product-Level Profitability

Product-level measures are calculated using the order-item grain so that sales, quantity, discounts, and profit are correctly attributed to individual products.

### Dashboard Preview

<p align="center">
  <img width="1328" height="743" alt="Screenshot (2216)" src="https://github.com/user-attachments/assets/2e20872d-626c-410c-9085-e6b65dcb3cb9" />

</p>

---

## 4. Order & Sales Performance

This page focuses on **order activity, sales trends, payment methods, and shipping methods**.

### Key Analysis

- Orders Over Time
- Net Sales Over Time
- Orders by Payment Method
- Returned Quantity by Return Reason
- Orders by Payment Method and Order Status
- Net Sales by Shipping Method
- Yearly Sales Performance

### Dashboard Preview

<p align="center">
  <img width="1316" height="731" alt="Screenshot (2224)" src="https://github.com/user-attachments/assets/f3d79f51-97bf-417c-87ed-3495ff776649" />

</p>

---

## Interactive Features

The dashboard includes interactive Power BI features that allow users to explore the data dynamically.

- Slicers
- Cross-filtering
- Drill-through
- Dynamic DAX Measures
- KPI Cards
- Interactive Charts
