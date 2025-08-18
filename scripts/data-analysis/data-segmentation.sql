/*
================================================================================
Data Segmentation
================================================================================

Script Purpose:
    This script segments products and customers into defined ranges and categories.
    It performs the following checks:
    - Segments products into cost ranges and counts how many products fall into each segment.
    - Groups customers based on spending behavior and lifespan, then counts customers per segment.
================================================================================
*/

-- Segment products into cost ranges and count products per segment
WITH segment_cost AS (
SELECT product_name,
cost,
CASE 
    WHEN cost < 100 THEN 'below 100'
    WHEN cost > 100 AND cost < 500 THEN 'from 100-500'
    WHEN cost > 500 AND cost < 1000 THEN 'from 500-1000'
    ELSE 'above 1000'
END AS segments
FROM gold.dim_products
)
SELECT COUNT(product_name) AS count_seg,
segments
FROM segment_cost
GROUP BY segments
ORDER BY COUNT(product_name) DESC;

-- Segment customers based on spending behavior and lifespan
SELECT COUNT(customer_key) AS cust_count,
segments
FROM (
SELECT c.customer_key,
MIN(MONTH(order_date)) AS first_order_month,
MAX(MONTH(order_date)) AS last_order_month,
DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
CASE 
    WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 AND SUM(f.sales_amount) > 5000 THEN 'VIP'
    WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 AND SUM(f.sales_amount) <= 5000 THEN 'Regular'
    WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) < 12 THEN 'New'
    ELSE 'New'
END AS segments,
SUM(f.sales_amount) AS sales_cust
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
) t
GROUP BY segments;
