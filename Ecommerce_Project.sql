CREATE OR ALTER VIEW dbo.vw_customer_master_clean AS
SELECT
    TRIM(customer_id) AS customer_id,
    TRIM(customer_name) AS customer_name,
    customer_age,
    CASE
        WHEN TRIM(gender) = 'Non-Binary' THEN 'Other'
        ELSE TRIM(gender)
    END AS gender,
    TRIM(customer_segment) AS customer_segment,
    TRIM(customer_city) AS customer_city,
    TRIM(customer_state) AS customer_state,
    TRIM(customer_country) AS customer_country,
    TRIM(region) AS region,
    ROUND(customer_acquisition_cost, 0) AS customer_acquisition_cost
FROM dbo.customer_master;
go


CREATE OR ALTER VIEW dbo.vw_ecommerce_sales_customer_clean AS
SELECT
    TRIM(order_id) AS order_id,
    order_date,
    order_time,
    TRIM(order_status) AS order_status,
    TRIM(sales_channel) AS sales_channel,
    TRIM(customer_id) AS customer_id,
    TRIM(payment_method) AS payment_method,
    TRIM(payment_status) AS payment_status,
    TRIM(currency) AS currency,
    TRIM(shipping_method) AS shipping_method,
    TRIM(warehouse) AS warehouse,
    delivery_days,
    estimated_delivery_days,

    CASE
        WHEN delivery_days IS NULL
          OR estimated_delivery_days IS NULL
            THEN TRIM(delivery_status)
        WHEN delivery_days < estimated_delivery_days
            THEN 'Early'
        WHEN delivery_days = estimated_delivery_days
            THEN 'On Time'
        WHEN delivery_days > estimated_delivery_days
            THEN 'Delayed'
        ELSE TRIM(delivery_status)
    END AS delivery_status,

    TRIM(return_status) AS return_status,
    TRIM(return_reason) AS return_reason,
    customer_rating,
    TRIM(review_sentiment) AS review_sentiment,
    TRIM(customer_review) AS customer_review,
    TRIM(marketing_channel) AS marketing_channel,
    TRIM(campaign_name) AS campaign_name,
    TRIM(coupon_code) AS coupon_code,
    loyalty_points_earned,
    loyalty_points_redeemed,
    quantity,
    gross_sales,
    discount_amount,
    tax_amount,
    shipping_cost,
    net_sales,
    product_cost,
    profit,
    TRIM(customer_type) AS customer_type
FROM dbo.ecommerce_sales_customer_analytics_150k;
go

CREATE OR ALTER VIEW dbo.vw_order_items_cleaned AS
SELECT
    TRIM(order_id) AS order_id,
    TRIM(product_id) AS product_id,
    quantity,
    unit_price,
    discount_percentage,
    discount_amount,
    gross_sales,
    tax_amount,
    shipping_cost,
    net_sales,
    product_cost,
    profit
FROM dbo.order_items;
go

CREATE OR ALTER VIEW dbo.vw_Product_cleaned AS
SELECT
    TRIM(product_id) AS product_id,
    TRIM(product_name) AS product_name,
    TRIM(product_category) AS product_category,
    TRIM(product_subcategory) AS product_subcategory,
    TRIM(brand) AS brand,
    TRIM(supplier) AS supplier,
    unit_price,
    product_cost,
    product_rating
FROM dbo.product_catalog;
go

select * from [dbo].[vw_customer_master_clean];
select COUNT(*) as total_rows 
from [dbo].[vw_customer_master_clean];

--check if there is space --
select count(*)  from [dbo].[vw_customer_master_clean]
where customer_id <> TRIM(customer_id) or
customer_name <> TRIM(customer_name) or
gender <> TRIM(gender) or
customer_segment <> TRIM(customer_segment) or
customer_city <> TRIM(customer_city) or 
customer_state <> Trim(customer_state) or
customer_country <> Trim(customer_country) or
region <> Trim(region) ;

select COUNT(*) as total_rows,
	sum(case when customer_id is null then 1 else 0 end) as missing_customer_id,
	sum(case when customer_name is null then 1 else 0 end) as missing_customer_name,
	sum(case when gender is null then 1 else 0 end) as gender,
	sum(case when customer_segment is null then 1 else 0 end) as customer_segment,
	sum(case when customer_city is null then 1 else 0 end) as customer_city,
	sum(case when customer_state is null then 1 else 0 end) as missing_customer_state,
	sum(case when customer_country is null then 1 else 0 end) as missing_customer_country,
	sum(case when region is null then 1 else 0 end) as missing_region,
	sum(case when customer_acquisition_cost is null then 1 else 0 end) as missing_customer_acquisition_cost
	
from [dbo].[vw_customer_master_clean];


--check duplicated--
select customer_id,count(*) as duplicated_rows
from  [dbo].[vw_customer_master_clean]
group by customer_id 
having count(*) > 1 ;

--check age--
select 
	MAX(customer_age) as max_age,
	Min(customer_age) as min_age
from [dbo].[vw_customer_master_clean];

--check gender--
select gender, count(*) as gender_types_num
from [dbo].[vw_customer_master_clean]
group by gender ;

--customer segment--
select customer_segment , count(*) as customer_segment_group
from [dbo].[vw_customer_master_clean]
group by customer_segment ;

--Region--
select region , count(*) as Rigion_group
from [dbo].[vw_customer_master_clean]
group by region ;

--customer_country--
select customer_country , count(*) as customer_country_group
from [dbo].[vw_customer_master_clean]
group by customer_country ;

--customer_state--
select customer_state , count(*) as customer_state_group
from [dbo].[vw_customer_master_clean]
group by customer_state ;

--customer_city--
select customer_city , count(*) as customer_city_group
from [dbo].[vw_customer_master_clean]
group by customer_city ;

select count(*) as invalid_customer_acquisition_cost
from dbo.vw_customer_master_clean
where customer_acquisition_cost < 0;
--Drop unuseful column (customer_postal_code)--
--Alter View [dbo].[vw_customer_master_clean] Drop column customer_postal_code;

select * from [dbo].[vw_customer_master_clean];

--Second View --

-- check total rows and unique orders
select count(*) as total_rows, count(distinct order_id) as distinct_orders
from dbo.vw_ecommerce_sales_customer_clean;


select * from dbo.vw_ecommerce_sales_customer_clean;

-- check null values
select
    sum(case when order_id is null then 1 else 0 end) as null_order_id,
    sum(case when order_date is null then 1 else 0 end) as null_order_date,
    sum(case when order_time is null then 1 else 0 end) as null_order_time,
    sum(case when order_status is null then 1 else 0 end) as null_order_status,
    sum(case when sales_channel is null then 1 else 0 end) as null_sales_channel,
    sum(case when customer_id is null then 1 else 0 end) as null_customer_id,
    sum(case when payment_method is null then 1 else 0 end) as null_payment_method,
    sum(case when payment_status is null then 1 else 0 end) as null_payment_status,
    sum(case when currency is null then 1 else 0 end) as null_currency,
    sum(case when shipping_method is null then 1 else 0 end) as null_shipping_method,
    sum(case when warehouse is null then 1 else 0 end) as null_warehouse,
    sum(case when delivery_days is null then 1 else 0 end) as null_delivery_days,
    sum(case when estimated_delivery_days is null then 1 else 0 end) as null_estimated_delivery_days,
    sum(case when delivery_status is null then 1 else 0 end) as null_delivery_status,
    sum(case when return_status is null then 1 else 0 end) as null_return_status,
    sum(case when return_reason is null then 1 else 0 end) as null_return_reason,
    sum(case when customer_rating is null then 1 else 0 end) as null_customer_rating,
    sum(case when review_sentiment is null then 1 else 0 end) as null_review_sentiment,
    sum(case when customer_review is null then 1 else 0 end) as null_customer_review,
    sum(case when marketing_channel is null then 1 else 0 end) as null_marketing_channel,
    sum(case when campaign_name is null then 1 else 0 end) as null_campaign_name,
    sum(case when coupon_code is null then 1 else 0 end) as null_coupon_code,
    sum(case when loyalty_points_earned is null then 1 else 0 end) as null_loyalty_points_earned,
    sum(case when loyalty_points_redeemed is null then 1 else 0 end) as null_loyalty_points_redeemed,
    sum(case when quantity is null then 1 else 0 end) as null_quantity,
    sum(case when gross_sales is null then 1 else 0 end) as null_gross_sales,
    sum(case when discount_amount is null then 1 else 0 end) as null_discount_amount,
    sum(case when tax_amount is null then 1 else 0 end) as null_tax_amount,
    sum(case when shipping_cost is null then 1 else 0 end) as null_shipping_cost,
    sum(case when net_sales is null then 1 else 0 end) as null_net_sales,
    sum(case when product_cost is null then 1 else 0 end) as null_product_cost,
    sum(case when customer_type is null then 1 else 0 end) as null_customer_type,
    sum(case when profit is null then 1 else 0 end) as null_profit
from dbo.vw_ecommerce_sales_customer_clean;

-- check leading and trailing spaces
select count(*) as rows_with_spaces
from dbo.vw_ecommerce_sales_customer_clean
where order_id <> trim(order_id)
   or order_status <> trim(order_status)
   or sales_channel <> trim(sales_channel)
   or customer_id <> trim(customer_id)
   or payment_method <> trim(payment_method)
   or payment_status <> trim(payment_status)
   or currency <> trim(currency)
   or shipping_method <> trim(shipping_method)
   or warehouse <> trim(warehouse)
   or delivery_status <> trim(delivery_status)
   or return_status <> trim(return_status)
   or return_reason <> trim(return_reason)
   or review_sentiment <> trim(review_sentiment)
   or customer_review <> trim(customer_review)
   or marketing_channel <> trim(marketing_channel)
   or campaign_name <> trim(campaign_name)
   or customer_type <> trim(customer_type)
   or coupon_code <> trim(coupon_code);

-- check order status values
select order_status, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by order_status
order by order_count desc;

-- check sales channel values
select sales_channel, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by sales_channel
order by order_count desc;

-- check payment method values
select payment_method, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by payment_method
order by order_count desc;

select payment_status, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by payment_status
order by order_count desc;

select currency, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by currency
order by order_count desc;

select shipping_method, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by shipping_method
order by order_count desc;

select warehouse, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by warehouse
order by order_count desc;

select delivery_status, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by delivery_status
order by order_count desc;

select return_status, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by return_status
order by order_count desc;

select return_reason, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by return_reason
order by order_count desc;

select review_sentiment, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by review_sentiment
order by order_count desc;

select marketing_channel, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by marketing_channel
order by order_count desc;

select campaign_name, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by campaign_name
order by order_count desc;

select customer_type, count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by customer_type
order by order_count desc;

select count(*) as unmatched_customer_ids
from dbo.vw_ecommerce_sales_customer_clean o
left join dbo.vw_customer_master_clean c
    on o.customer_id = c.customer_id
where c.customer_id is null;


select delivery_days,estimated_delivery_days,delivery_status,count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by delivery_days,estimated_delivery_days,delivery_status
order by delivery_days,estimated_delivery_days;

select count(*) as incorrect_delivery_status
from dbo.vw_ecommerce_sales_customer_clean
where delivery_days = estimated_delivery_days
  and delivery_status <> 'On Time';

select order_status,return_status,count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by order_status,return_status
order by order_status,return_status;

select order_status,return_status,return_reason,count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by order_status,return_status,return_reason
order by order_status,return_status,return_reason;

select customer_rating,review_sentiment,customer_review,count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by customer_rating,review_sentiment,customer_review
order by customer_rating,review_sentiment;

select count(*) as invalid_loyalty_points
from dbo.vw_ecommerce_sales_customer_clean
where loyalty_points_redeemed > loyalty_points_earned;

--check negative values--
select count(*) as invalid_loyalty_points
from dbo.vw_ecommerce_sales_customer_clean
where loyalty_points_earned < 0
   or loyalty_points_redeemed < 0;

select count(*) as orders_without_items
from [dbo].[vw_ecommerce_sales_customer_clean] o
left join [dbo].[vw_order_items_cleaned] oi
    on o.order_id = oi.order_id
where oi.order_id is null;

select count(*) as items_without_orders
from [dbo].[vw_order_items_cleaned] oi
left join [dbo].[vw_ecommerce_sales_customer_clean] o
    on oi.order_id = o.order_id
where o.order_id is null;

select count(*) as different_quantity
from dbo.vw_ecommerce_sales_customer_clean o
join (
    select
        order_id,
        sum(quantity) as items_quantity
    from dbo.vw_order_items_cleaned
    group by order_id
) oi
    on o.order_id = oi.order_id
where o.quantity <> oi.items_quantity;

select top 10
    o.order_id,
    o.quantity as order_quantity,
    oi.items_quantity
from dbo.vw_ecommerce_sales_customer_clean o
join (
    select
        order_id,
        sum(quantity) as items_quantity
    from [dbo].[vw_order_items_cleaned]
    group by order_id
) oi
    on o.order_id = oi.order_id
where o.quantity <> oi.items_quantity
order by o.order_id;

select count(*) as invalid_quantity
from dbo.vw_ecommerce_sales_customer_clean
where quantity <= 0;

select count(*) as invalid_gross_sales
from dbo.vw_ecommerce_sales_customer_clean
where gross_sales < 0;

select count(*) as invalid_discount_amount
from dbo.vw_ecommerce_sales_customer_clean
where discount_amount < 0;

select count(*) as invalid_tax_amount
from dbo.vw_ecommerce_sales_customer_clean
where tax_amount < 0;

select count(*) as invalid_shipping_cost
from dbo.vw_ecommerce_sales_customer_clean
where shipping_cost < 0;

select
    order_id,
    product_id,
    quantity
from [dbo].[vw_order_items_cleaned]
where order_id = 'ORD-100046';
select
    order_id,
    quantity
from dbo.vw_ecommerce_sales_customer_clean
where order_id = 'ORD-100046';

select count(*) as different_quantity
from dbo.vw_ecommerce_sales_customer_clean o
join (
    select
        order_id,
        count(distinct product_id) as product_count
    from [dbo].[vw_order_items_cleaned]
    group by order_id
) oi
    on o.order_id = oi.order_id
where o.quantity <> oi.product_count;

select count(*) as different_quantity
from dbo.vw_ecommerce_sales_customer_clean o
join (
    select
        order_id,
        count(*) as line_count
    from [dbo].[vw_order_items_cleaned]
    group by order_id
) oi
    on o.order_id = oi.order_id
where o.quantity <> oi.line_count;

select
    order_status,
    quantity,
    count(*) as order_count
from dbo.vw_ecommerce_sales_customer_clean
group by order_status, quantity
order by order_status, quantity;

select
    oi.order_id,
    sum(oi.quantity) as items_quantity,
    sum(oi.gross_sales) as items_gross_sales,
    sum(oi.discount_amount) as items_discount,
    sum(oi.tax_amount) as items_tax,
    sum(oi.shipping_cost) as items_shipping,
    sum(oi.net_sales) as items_net_sales,
    sum(oi.product_cost) as items_product_cost,
    sum(oi.profit) as items_profit,

    o.quantity as order_quantity,
    o.gross_sales as order_gross_sales,
    o.discount_amount as order_discount,
    o.tax_amount as order_tax,
    o.shipping_cost as order_shipping,
    o.net_sales as order_net_sales,
    o.product_cost as order_product_cost,
    o.profit as order_profit

from [dbo].[vw_order_items_cleaned] oi
join dbo.vw_ecommerce_sales_customer_clean o
    on oi.order_id = o.order_id

group by
    oi.order_id,
    o.quantity,
    o.gross_sales,
    o.discount_amount,
    o.tax_amount,
    o.shipping_cost,
    o.net_sales,
    o.product_cost,
    o.profit;

select count(*) as incorrect_net_sales
from dbo.vw_ecommerce_sales_customer_clean
where abs(
    net_sales - (gross_sales - discount_amount + tax_amount+ shipping_cost)) > 0.01;

select count(*) as different_profit
from dbo.vw_ecommerce_sales_customer_clean
where abs(net_sales - product_cost - shipping_cost - profit) > 0.01;

select count(*) as invalid_discount
from dbo.vw_ecommerce_sales_customer_clean
where discount_amount > gross_sales;
/*

--Drop Duplicated Cloumns--

select * from dbo.vw_ecommerce_sales_customer_clean;
*/


--Therid View --
select * from dbo.vw_order_items_cleaned;

SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_orders, COUNT(DISTINCT product_id) AS distinct_products
FROM dbo.vw_order_items_cleaned;

--check null valuse--
select count(*) as total_rows ,
    sum(case when order_id is null then 1 else 0 end ) missing_order_id,
    sum(case when product_id is null then 1 else 0 end ) missing_product_id,
    sum(case when quantity is null then 1 else 0 end ) missing_quantity,
    sum(case when unit_price is null then 1 else 0 end ) missing_unit_price,
    sum(case when discount_percentage is null then 1 else 0 end ) missing_discount_percentage,
    sum(case when discount_amount is null then 1 else 0 end ) missing_discount_amount,
    sum(case when gross_sales is null then 1 else 0 end ) missing_gross_sales,
    sum(case when tax_amount is null then 1 else 0 end ) missing_tax_amount,
    sum(case when shipping_cost is null then 1 else 0 end ) missing_shipping_cost,
    sum(case when net_sales is null then 1 else 0 end ) missing_net_sales,
    sum(case when product_cost is null then 1 else 0 end ) missing_product_cost,
    sum(case when profit is null then 1 else 0 end ) missing_profit
    from dbo.vw_order_items_cleaned;

--check trim--
select count(*) as rows_with_space
from dbo.vw_order_items_cleaned
where order_id <> trim(order_id) or 
product_id <> TRIM(product_id);

--check duplicated--
select order_id ,product_id ,count(*) as duplicated_rows
from dbo.vw_order_items_cleaned
group by order_id ,product_id 
having count(*)>1 ;

SELECT *
FROM dbo.vw_order_items_cleaned
WHERE order_id = 'ORD-124215'
  AND product_id = 'PROD-000044';

select order_id, product_id, quantity, unit_price, discount_percentage, discount_amount, gross_sales, tax_amount, shipping_cost, net_sales, product_cost, profit, count(*) as duplicated_rows
from dbo.vw_order_items_cleaned
group by order_id, product_id, quantity, unit_price, discount_percentage, discount_amount, gross_sales, tax_amount, shipping_cost, net_sales, product_cost, profit
having count(*) > 1; --there is no duplicate--

--check invalid values--
select count(*) as invalid_quantity
from dbo.vw_order_items_cleaned
where quantity < 0;

select count(*) as invalid_unit_price
from dbo.vw_order_items_cleaned
where unit_price < 0;

select count(*) as invalid_discount_percentage
from dbo.vw_order_items_cleaned
where try_convert(decimal(18,10), discount_percentage) < 0
   or try_convert(decimal(18,10), discount_percentage) > 1;

select count(*) as invalid_discount_amount
from dbo.vw_order_items_cleaned
where try_convert(decimal(18,2), discount_amount) < 0;

select count(*) as invalid_gross_sales
from dbo.vw_order_items_cleaned
where gross_sales < 0;

select count(*) as invalid_tax_amount
from dbo.vw_order_items_cleaned
where tax_amount < 0;

select count(*) as invalid_shipping_cost
from dbo.vw_order_items_cleaned
where shipping_cost < 0;

select count(*) as invalid_net_sales
from dbo.vw_order_items_cleaned
where net_sales < 0;

select count(*) as invalid_product_cost
from dbo.vw_order_items_cleaned
where product_cost < 0;

select count(*) as invalid_profit
from dbo.vw_order_items_cleaned
where profit < 0; -- 5426 rows have negative profit (valid loss)

select top 20 order_id,product_id,gross_sales,discount_amount,tax_amount,shipping_cost,net_sales,product_cost,profit
from dbo.vw_order_items_cleaned
where profit < 0;

select count(*) as different_net_sales
from dbo.vw_order_items_cleaned
where abs(gross_sales -  discount_amount + tax_amount + shipping_cost- net_sales) > 0.01;

select count(*) as different_profit
from dbo.vw_order_items_cleaned
where abs(net_sales - product_cost - shipping_cost - profit) > 0.01; --5,426 — valid--
-- profit(-) mean lose --

select count(*) as invalid_discount
from dbo.vw_order_items_cleaned
where discount_amount > gross_sales;

select count(*) as different_discount_amount
from dbo.vw_order_items_cleaned
where abs(gross_sales * try_convert(decimal(18,10), discount_percentage)- discount_amount) > 0.01;

select count(*) as different_gross_sales
from dbo.vw_order_items_cleaned
where abs(quantity * unit_price - gross_sales) > 0.01;

--Fourth View --
select count(*) as total_rows , count(DISTINCT product_id) as distinct_products
from dbo.vw_Product_cleaned;

--check null values--
select
    count(*) as total_rows,
    sum(case when product_id is null then 1 else 0 end) as missing_product_id,
    sum(case when product_name is null then 1 else 0 end) as missing_product_name,
    sum(case when product_category is null then 1 else 0 end) as missing_category,
    sum(case when product_subcategory is null then 1 else 0 end) as missing_subcategory,
    sum(case when brand is null then 1 else 0 end) as missing_brand,
    sum(case when supplier is null then 1 else 0 end) as missing_supplier,
    sum(case when unit_price is null then 1 else 0 end) as missing_unit_price,
    sum(case when product_cost is null then 1 else 0 end) as missing_product_cost,
    sum(case when product_rating is null then 1 else 0 end) as missing_rating
from dbo.vw_Product_cleaned;

--check spaces-- 
select count(*) as rows_with_spaces
from dbo.vw_Product_cleaned
where product_id <> trim(product_id)
   or product_name <> trim(product_name)
   or product_category <> trim(product_category)
   or product_subcategory <> trim(product_subcategory)
   or brand <> trim(brand)
   or supplier <> trim(supplier);

--check (-)values
select
    sum(case when unit_price < 0 then 1 else 0 end) as invalid_unit_price,
    sum(case when product_cost < 0 then 1 else 0 end) as invalid_product_cost
from dbo.vw_Product_cleaned;


select count(*) as invalid_product_rating
from dbo.vw_Product_cleaned
where product_rating < 0
   or product_rating > 5;

-- check if product cost is higher than unit price--
select count(*) as cost_greater_than_price
from dbo.vw_Product_cleaned
where product_cost > unit_price;

-- check product category values
select product_category, count(*) as product_count
from dbo.vw_Product_cleaned
group by product_category
order by product_count desc;

select * from dbo.vw_Product_cleaned;

select count(*) as unmatched_product_ids
from dbo.vw_order_items_cleaned oi
left join dbo.vw_product_cleaned p
    on oi.product_id = p.product_id
where p.product_id is null;



