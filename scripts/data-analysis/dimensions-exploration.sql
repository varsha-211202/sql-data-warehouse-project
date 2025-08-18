/*
================================================================================
Dimensions Exploration
================================================================================

Script Purpose:
    This script explores key dimensions available in the data warehouse.
    It performs the following checks:
    - Retrieves all distinct customer countries.
    - Retrieves all distinct product categories, subcategories, and product names.
================================================================================
*/

-- Explore all the countries the customers come from
SELECT DISTINCT country 
FROM gold.dim_customers;


-- Explore all categories, subcategories, and products
SELECT DISTINCT category,
                subcategory,
                product_name
FROM gold.dim_products
ORDER BY category,
         subcategory,
         product_name;
