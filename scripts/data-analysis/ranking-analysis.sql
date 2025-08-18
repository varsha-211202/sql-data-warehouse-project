/*
================================================================================
Ranking Analysis
================================================================================

Script Purpose:
    This script performs ranking analysis to identify top and bottom performers.
    It performs the following checks:
    - Finds the 5 products generating the highest revenue.
    - Finds the 5 worst-performing products in terms of sales.
    - Finds the 3 customers with the fewest orders placed.
================================================================================
*/

-- Top 5 products generating the highest revenue
SELECT *
FROM (
    SELECT p.product_name,
           ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS flag
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
           ON f.product_key = p.product_key
    GROUP BY p.product_name
) t
WHERE flag <= 5;

-- 5 worst-performing products in terms of sales
SELECT *
FROM (
    SELECT p.product_name,
           ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) ASC) AS flag
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
           ON f.product_key = p.product_key
    GROUP BY p.product_name
) t
WHERE flag <= 5;

-- 3 customers with the fewest orders placed
SELECT *
FROM (
    SELECT c.customer_key,
           ROW_NUMBER() OVER (ORDER BY COUNT(f.order_number)) AS rank_new
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c
           ON f.customer_key = c.customer_key
    GROUP BY c.customer_key
) t
WHERE rank_new <= 3;
