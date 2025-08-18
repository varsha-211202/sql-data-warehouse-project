/*==========================================================
 Product Report
==========================================================

Purpose:
    This report consolidates key product metrics and behaviors.

Highlights:
1. Retrieves core product fields such as name, category, subcategory, and sale dates.
2. Groups products based on total revenue:
      - High-Performer
      - Mid-Range
      - Low-Performer
3. Aggregates product-level metrics:
      - total orders
      - total sales
      - total quantity sold
      - total customers (unique)
      - lifespan (months active in sales history)
4. Calculates key KPIs:
      - recency (months since last sale)
      - average order revenue (AOR = total_sales ÷ total_orders)
      - average monthly revenue (total_sales ÷ lifespan)
==========================================================*/

create view gold.products_report as

/*---------------------------------------------------------------------------------
  STEP 1: Base Query
  Purpose: Pulls raw details from sales & product tables
---------------------------------------------------------------------------------*/
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL -- only valid sales dates
),

/*---------------------------------------------------------------------------------
  STEP 2: Product Aggregation
  Purpose: Roll up sales data into product-level summary
           Metrics: orders, sales, quantity, customers, lifespan
---------------------------------------------------------------------------------*/
product_aggregation AS (
    SELECT
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,

        COUNT(DISTINCT f.order_number) AS total_orders,      -- how many unique orders contained this product
        SUM(f.sales_amount) AS total_sales,                  -- total revenue generated
        SUM(f.quantity) AS total_quantity,                   -- total units sold
        COUNT(DISTINCT f.customer_key) AS total_customers,   -- how many unique customers purchased
        MAX(f.order_date) AS last_sale_date,                 -- most recent sale
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan -- active months
    FROM base_query f
    JOIN gold.dim_products p 
        ON f.product_key = p.product_key
    GROUP BY p.product_key, p.product_name, p.category, p.subcategory
)

/*---------------------------------------------------------------------------------
  STEP 3: Final Report
  Purpose: Present product performance profile with categories & KPIs
           - AOR = total_sales ÷ total_orders
           - Avg Monthly Revenue = total_sales ÷ lifespan
---------------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,

    -- Segment by total revenue
    CASE 
        WHEN total_sales > 10000 THEN 'High-Performer'
        WHEN total_sales BETWEEN 5000 AND 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS revenue_segment,

    -- Recency: months since last sale
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency,

    -- KPIs
    total_sales / NULLIF(total_orders, 0) AS average_order_revenue, -- AOR
    total_sales / NULLIF(lifespan, 0) AS average_monthly_revenue,   -- monthly revenue

    -- Supporting metrics
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan
FROM product_aggregation;
