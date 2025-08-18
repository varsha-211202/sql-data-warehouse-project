/*
================================================================================
Cumulative Analysis
================================================================================

Script Purpose:
    This script calculates cumulative measures over time.
    It performs the following checks:
    - Total sales per month.
    - Running total of sales over months.
    - Running total of sales per year with partitioning.
    - Moving average of price per year with cumulative calculations.
================================================================================
*/

-- Total sales over month
SELECT MONTH(order_date) AS order_month,
       SUM(sales_amount) AS total_sales
FROM gold.fact_sales
GROUP BY MONTH(order_date);

-- Running total of sales over time (monthly)
SELECT order_month,
       total_sales,
       SUM(total_sales) OVER (ORDER BY order_month) AS running_total
FROM (
    SELECT DATE_TRUNC(month, order_date) AS order_month,
           SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC(month, order_date)
) t;

-- Running total of sales per year (partitioned by year)
SELECT order_year,
       total_sales,
       SUM(total_sales) OVER (PARTITION BY order_year ORDER BY order_year) AS running_total
FROM (
    SELECT DATE_TRUNC(year, order_date) AS order_year,
           SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC(year, order_date)
) t;

-- Moving average of price per year with cumulative calculations
SELECT order_year,
       total_sales,
       SUM(total_sales) OVER (PARTITION BY order_year ORDER BY order_year) AS running_total, -- refresh after each year
       AVG(avg_price) OVER (ORDER BY order_year) AS moving_avg
FROM (
    SELECT DATE_TRUNC(year, order_date) AS order_year,
           SUM(sales_amount) AS total_sales,
           AVG(price) AS avg_price -- aggregate any column for moving average
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_TRUNC(year, order_date)
) t;
