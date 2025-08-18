/*
================================================================================
Date Exploration
================================================================================

Script Purpose:
    This script explores key date-related information in the data warehouse.
    It performs the following checks:
    - Finds the first and last order dates and calculates the number of years of sales available.
    - Finds the youngest and oldest customer along with their ages.
================================================================================
*/

-- Find the dates of the first and last order and the number of years of sales
SELECT MIN(order_date) AS first_order_date, 
       MAX(order_date) AS last_order_date,
       DATEDIFF(year, MIN(order_date), MAX(order_date)) AS number_of_years
FROM gold.fact_sales;


-- Find the youngest and oldest customer and their ages
SELECT MAX(birthdate) AS youngest_birthdate,
       MIN(birthdate) AS oldest_birthdate,
       DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
       DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers;
