/*
===================================================================================
Customer Report
===================================================================================

Purpose:
 - This report consolidates key customer metrics and behaviors

Highlights:
1. Gathers essential fields such as names, ages, and transaction details.
2. Segments customers into categories (VIP, Regular, New) and age groups.
3. Aggregates customer-level metrics:
   - total orders
   - total sales
   - total quantity purchased
   - total products
   - lifespan (in months)
4. Calculates valuable KPIs:
   - recency (months since last order)
   - average order value --total sales/total orders
   - average monthly spend --total sales/# of months(lifespan)
===================================================================================
*/

create view gold.customer_report as -- store the full report in a view for user-access

/*---------------------------------------------------------------------------------
  STEP 1: Base Query 
  Pulls all raw details needed for calculations
           (customer info, age, order info, sales, quantity)
---------------------------------------------------------------------------------*/
WITH base_query AS (
    SELECT 
        f.customer_key,
        c.customer_id,
        c.customer_number,
        f.order_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age, -- current age in years
        f.product_key,
        f.order_date,
        f.sales_amount,
        f.quantity
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c 
        ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL -- filter out missing order dates
),

/*---------------------------------------------------------------------------------
  STEP 2: Customer Aggregation 
   Add order-level data into customer-level summary
           Metrics: orders, sales, quantity, products, lifespan
---------------------------------------------------------------------------------*/
customer_aggregation AS (
    SELECT 
        COUNT(DISTINCT order_number) AS total_orders,        -- number of unique orders
        SUM(sales_amount) AS total_sales,                   -- how much customer spent
        SUM(quantity) AS total_quantity,                    -- total items purchased
        COUNT(DISTINCT product_key) AS total_products,      -- product variety
        MAX(order_date) AS last_order_date,                 -- last order for recency
        customer_key,
        customer_number,
        customer_name,
        age,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan -- months active
    FROM base_query
    GROUP BY customer_key, customer_number, customer_name, age
)

/*---------------------------------------------------------------------------------
  STEP 3: Final Report
   Present customer report with categories, recency, and averages
           - Average Order Value = total_sales   total_orders
           - Average Monthly Spend = total_sales   lifespan
---------------------------------------------------------------------------------*/
SELECT 
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age group
    CASE 
        WHEN age > 20 AND age <= 29 THEN 'under 30'
        WHEN age > 30 AND age <= 39 THEN 'under 40'
        WHEN age > 40 AND age <= 49 THEN 'under 50'
        WHEN age < 20 THEN 'below 20'
        ELSE 'above 50'
    END AS age_segment,

    -- Category by spend + activity
    CASE 
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        WHEN lifespan < 12 THEN 'New'
        ELSE 'New'
    END AS lifespan_segment,

    -- Recency: months since last order
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    -- Key averages
    total_sales / NULLIF(total_orders, 0) AS average_order_value,  -- total_sales   total_orders
    total_sales / NULLIF(lifespan, 0) AS average_monthly_spend,    -- total_sales   lifespan

    -- Supporting metrics
    total_orders,
    total_products,
    total_quantity,
    total_sales
FROM customer_aggregation;
