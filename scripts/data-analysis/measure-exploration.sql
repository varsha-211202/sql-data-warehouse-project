/*
================================================================================
Measure Exploration
================================================================================

Script Purpose:
    This script explores key measures in the data warehouse.
    It performs the following checks:
    - Finds total sales, number of items sold, average selling price.
    - Finds total number of orders, products, and customers.
    - Finds the total number of customers who have placed an order.
    - Generates a consolidated report showing all measure metrics.
================================================================================
*/

-- Find the total sales
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;
-- Find how many items are sold
SELECT SUM(quantity) AS no_of_items_sold
FROM gold.fact_sales;
-- Find the average selling price
SELECT AVG(price) AS avg_selling_price
FROM gold.fact_sales;
-- Find the total number of orders
SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;
-- Find the total number of products
SELECT COUNT(DISTINCT product_id) AS total_products
FROM gold.dim_products;
-- Find the total number of customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM gold.dim_customers;
-- Find the total number of customers that have placed an order
SELECT COUNT(DISTINCT customer_key) AS count_customers_with_order
FROM gold.fact_sales;

-- Generate a consolidated report showing all measure metrics
SELECT 'Total sales' AS measure_name, SUM(sales_amount) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total items' AS measure_name, SUM(quantity) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Average Selling Price' AS measure_name, AVG(price) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total orders' AS measure_name, COUNT(DISTINCT order_number) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total products' AS measure_name, COUNT(DISTINCT product_id) AS measure_value
FROM gold.dim_products
UNION ALL
SELECT 'Total customers' AS measure_name, COUNT(DISTINCT customer_id) AS measure_value
FROM gold.dim_customers
UNION ALL
SELECT 'Total Customers that placed orders' AS measure_name, COUNT(DISTINCT customer_key) AS measure_value
FROM gold.fact_sales;
