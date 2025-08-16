/*
===========================================================
Quality Checks
===========================================================

Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schemas. It includes checks for:
        - Null or duplicate primary keys.
        - Unwanted spaces in string fields.
        - Data standardization and consistency.
        - Invalid date ranges and orders.
        - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
*/

--Quality Checks

--1. Nulls or Duplicates in Primary Key
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


--2. Leading/Trailing Spaces in Customer Names
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);


--3. Leading/Trailing Spaces in Product Name
SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);


--4. Null Values in Product Cost
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost IS NULL;


--5. Invalid Date Order (End Date < Start Date)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;
