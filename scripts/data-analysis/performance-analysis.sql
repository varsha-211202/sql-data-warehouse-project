/*
================================================================================
Year-over-Year (YOY) Performance Analysis
================================================================================

Script Purpose:
    This script analyzes the yearly performance of products by comparing their sales
    to both the average sales performance of the product and the previous year's sales.
    It performs the following checks:
    - Computes total sales per product per year.
    - Compares each year's sales to the product's average sales.
    - Flags performance as above average, average, or below average.
    - Compares each year's sales to the previous year's sales.
    - Flags changes as increase, no change, or decrease.
================================================================================
*/

-- YOY: Year-Over-Year Analysis using CTE
WITH cte_perf AS (
    SELECT YEAR(f.order_date) AS order_year,
           SUM(f.sales_amount) AS sales_year,
           p.product_name
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p 
           ON f.product_key = p.product_key
    GROUP BY YEAR(f.order_date), p.product_name
)
SELECT order_year,
       sales_year,
       product_name,
       AVG(sales_year) OVER (PARTITION BY product_name) AS avg_sales,
       sales_year - AVG(sales_year) OVER (PARTITION BY product_name) AS diff_avg,
       CASE 
           WHEN sales_year - AVG(sales_year) OVER (PARTITION BY product_name) > 0 THEN 'above avg'
           WHEN sales_year - AVG(sales_year) OVER (PARTITION BY product_name) = 0 THEN 'avg'
           ELSE 'below avg'
       END AS flag_avg,
       LAG(sales_year) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_sales,
       sales_year - LAG(sales_year) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_prev,
       CASE 
           WHEN sales_year - LAG(sales_year) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'increase'
           WHEN sales_year - LAG(sales_year) OVER (PARTITION BY product_name ORDER BY order_year) = 0 THEN 'no change'
           ELSE 'decrease'
       END AS flag_change
FROM cte_perf;
