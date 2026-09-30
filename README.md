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

## Data Model & Grain

The cleaned views represent different levels of detail:

- `vw_customer_master_clean`: one row per customer
- `vw_ecommerce_sales_customer_clean`: one row per order
- `vw_order_items_cleaned`: one row per order-product line
- `vw_Product_cleaned`: one row per product

Relationships:

- Customer → Orders: `customer_id`
- Orders → Order Items: `order_id`
- Products → Order Items: `product_id`

Order-level quantity was compared with aggregated order-item quantities, distinct product counts, and line counts. 
Differences were observed because the order-level quantity field does not represent the same grain as the line-item measures.
