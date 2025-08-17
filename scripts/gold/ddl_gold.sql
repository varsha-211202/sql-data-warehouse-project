/*
==========================================================
DDL Script: Create Gold Views
==========================================================

Script Purpose:
This script creates views for the Gold layer in the data warehouse.
The Gold layer represents the final dimension and fact tables (Star Schema)

Each view performs transformations and combines data from the Silver layer to produce a clean, enriched, and business-ready dataset.

Usage:
- These views can be queried directly for analytics and reporting.

==========================================================
*/
===================================================================================
-- Create Dimension: Gold.dim_customers
===================================================================================
IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key, -- surrogate key for dimensions
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS firstname,
    ci.cst_lastname AS lastname,
    la.cntry AS country,
    ci.cst_marital_status AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE ISNULL(ca.gen,'n/a')
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la 
    ON ci.cst_key = la.cid;
GO


===================================================================================
-- Create Dimension: Gold.dim_products
===================================================================================
IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY prd_key) AS product_key, -- surrogate key for dimensions
    pr.prd_id AS product_id,
    pr.prd_key AS product_number,
    pr.prd_nm AS product_name,
    pr.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pr.prd_cost AS cost,
    pr.prd_line AS product_line,
    pr.prd_start_dt AS start_date
FROM silver.crm_prd_info pr 
LEFT JOIN silver.erp_px_cat_g1v2 pc
    ON pr.cat_id = pc.id
WHERE pr.prd_end_dt IS NULL;  --removing the historical information and keeping only the current one
GO


===================================================================================
-- Create Fact: Gold.fact_sales
===================================================================================
IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    pr.product_key,   -- sd.sls_prd_key is changed to surrogate key from product dimension to join with this fact
    cu.customer_key,  -- sd.sls_cust_id is changed to surrogate key from customer dimension to join with this fact
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr 
    ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu 
    ON sd.sls_cust_id = cu.customer_id;
GO


===================================================================================
-- Foreign Key Integrity (Dimensions Validation)
===================================================================================
/*
Check if fact_sales has any rows where surrogate keys 
don’t match with product/customer dimension.  
Expectation: No result

SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
    ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
   OR c.customer_key IS NULL;
*/
