/*
================================================================================
Change-over-Time Analysis
================================================================================

Script Purpose:
    This script analyzes sales performance over time.
    It performs the following checks:
    - Aggregates sales, customer count, and quantity over years.
    - Aggregates sales, customer count, and quantity over months.
    - Aggregates sales, customer count, and quantity over years and months.
================================================================================
*/

-- Sales performance over years
SELECT YEAR(order_date) AS order_year,
       SUM(sales_amount) AS total_sales,
       COUNT(DISTINCT customer_key) AS total_customers,
       SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);

-- Sales performance over months
SELECT MONTH(order_date) AS order_month,
       SUM(sales_amount) AS total_sales,
       COUNT(DISTINCT customer_key) AS total_customers,
       SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date)
ORDER BY MONTH(order_date);

-- Sales performance over years and months
SELECT YEAR(order_date) AS order_year,
       MONTH(order_date) AS order_month,
       SUM(sales_amount) AS total_sales,
       COUNT(DISTINCT customer_key) AS total_customers,
       SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);
