/*
===============================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================

Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver_load_silver;
===============================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    BEGIN TRY
        DECLARE @start_time datetime, @end_time datetime, @overall_start_time datetime;
        SET @overall_start_time = GETDATE();

        PRINT '==============================================================================================';
        PRINT 'Loading the Silver Layer';
        PRINT '==============================================================================================';

        PRINT '------------------------------------------------------------------------------------------------';
        PRINT 'Loading the CRM Tables';
        PRINT '------------------------------------------------------------------------------------------------';

        -- CRM_CUST_INFO
        SET @start_time = GETDATE();
        PRINT 'Truncating table SILVER.CRM_CUST_INFO';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT 'Inserting into the table SILVER.CRM_CUST_INFO';
        INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
        SELECT cst_id,
               cst_key,
               TRIM(cst_firstname),
               TRIM(cst_lastname),
               CASE WHEN UPPER(TRIM(cst_marital_status))='M' THEN 'Married'
                    WHEN UPPER(TRIM(cst_marital_status))='S' THEN 'Single'
                    ELSE 'n/a'
               END,
               CASE WHEN UPPER(TRIM(cst_gndr))='M' THEN 'Male'
                    WHEN UPPER(TRIM(cst_gndr))='F' THEN 'Female'
                    ELSE 'n/a'
               END,
               cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
            FROM bronze.crm_cust_info
        ) t
        WHERE flag = 1;

        SET @end_time = GETDATE();
        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load CRM_CUST_INFO is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        -- CRM_PRD_INFO
        SET @start_time = GETDATE();
        PRINT 'Truncating table SILVER.CRM_PRD_INFO';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT 'Inserting into the table SILVER.CRM_PRD_INFO';
        INSERT INTO silver.crm_prd_info(prd_id, cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
        SELECT prd_id,
               REPLACE(SUBSTRING(prd_key,1,5),'-','_'),
               SUBSTRING(prd_key,7,LEN(prd_key)),
               prd_nm,
               ISNULL(prd_cost,0),
               CASE UPPER(TRIM(prd_line))
                    WHEN 'M' THEN 'Mountain'
                    WHEN 'R' THEN 'Road'
                    WHEN 'T' THEN 'Touring'
                    WHEN 'S' THEN 'other Sales'
                    ELSE 'n/a'
               END,
               CAST(prd_start_dt AS date),
               CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS date)
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load CRM_PRD_INFO is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        -- CRM_SALES_DETAILS
        SET @start_time = GETDATE();
        PRINT 'Truncating table SILVER.CRM_SALES_DETAILS';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT 'Inserting into the table SILVER.CRM_SALES_DETAILS';
        INSERT INTO silver.crm_sales_details(sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
        SELECT sls_ord_num,
               sls_prd_key,
               sls_cust_id,
               CASE WHEN LEN(sls_order_dt) != 8 OR sls_order_dt <= 0 THEN NULL
                    ELSE CAST(CAST(sls_order_dt AS nvarchar) AS date)
               END,
               CASE WHEN LEN(sls_ship_dt) != 8 OR sls_ship_dt <= 0 THEN NULL
                    ELSE CAST(CAST(sls_ship_dt AS nvarchar) AS date)
               END,
               CASE WHEN LEN(sls_due_dt) != 8 OR sls_due_dt <= 0 THEN NULL
                    ELSE CAST(CAST(sls_due_dt AS nvarchar) AS date)
               END,
               CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                    ELSE sls_sales
               END,
               sls_quantity,
               CASE WHEN sls_price IS NULL OR sls_price <=0 OR sls_price != sls_sales/NULLIF(sls_quantity,0)
                    THEN sls_sales/NULLIF(sls_quantity,0)
                    ELSE sls_price
               END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load CRM_SALES_DETAILS is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        PRINT '------------------------------------------------------------------------------------------------';
        PRINT 'Loading the ERP Tables';
        PRINT '------------------------------------------------------------------------------------------------';

        -- ERP_CUST_AZ12
        SET @start_time = GETDATE();
        PRINT 'Truncating table SILVER.ERP_CUST_AZ12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT 'Inserting into the table SILVER.ERP_CUST_AZ12';
        INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
        SELECT CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID)) ELSE CID END,
               CASE WHEN BDATE > GETDATE() THEN NULL ELSE BDATE END,
               CASE WHEN TRIM(UPPER(GEN)) = 'F' THEN 'FEMALE'
                    WHEN TRIM(UPPER(GEN)) = '' OR GEN IS NULL THEN 'N/A'
                    WHEN TRIM(UPPER(GEN)) = 'M' THEN 'MALE'
                    ELSE GEN
               END
        FROM bronze.erp_CUST_AZ12;

        SET @end_time = GETDATE();
        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load ERP_CUST_AZ12 is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        -- ERP_LOC_A101
        SET @start_time = GETDATE();
        PRINT 'Truncating table SILVER.ERP_LOC_A101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT 'Inserting into the table SILVER.ERP_LOC_A101';
        INSERT INTO silver.erp_loc_a101(cid, cntry)
        SELECT REPLACE(CID,'-',''),
               CASE WHEN TRIM(CNTRY)='DE' THEN 'Germany'
                    WHEN TRIM(CNTRY) IN ('USA','US') THEN 'United States'
                    WHEN TRIM(CNTRY)=' ' OR CNTRY IS NULL THEN 'N/A'
                    ELSE TRIM(CNTRY)
               END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load ERP_LOC_A101 is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        -- ERP_PX_CAT_G1V2
        SET @start_time = GETDATE();
        PRINT 'Truncating table SILVER.ERP_PX_CAT_G1V2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT 'Inserting into the table SILVER.ERP_PX_CAT_G1V2';
        INSERT INTO silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
        SELECT id, cat, subcat, maintenance
        FROM bronze.erp_PX_CAT_G1V2;

        SET @end_time = GETDATE();
        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load ERP_PX_CAT_G1V2 is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        SET @end_time = GETDATE();
        PRINT '====================================================================================================';
        PRINT 'The overall duration to load the SILVER layer is ' + CAST(DATEDIFF(SECOND, @overall_start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '====================================================================================================';
    END TRY

    BEGIN CATCH
        PRINT '========================================================================';
        PRINT 'ERROR OCCURRED DURING LOAD PROCESS';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
    END CATCH
END


