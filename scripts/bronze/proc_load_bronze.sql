/*
================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
================================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from CSV files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
================================================================================
*/

---1.CRM TABLES

CREATE OR ALTER PROCEDURE bronze.LOAD_BRONZE AS --we will need to insert the data everyday in datawarehouse. so write it in a stored procedure.
BEGIN
    BEGIN TRY -- error handling

        DECLARE @start_time datetime, @end_time datetime, @overall_start_time datetime; --calculate how long it takes for one table data to be inserted.
        SET @overall_start_time = GETDATE(); -- To calculate the overall time taken to load the bronze layer.

        PRINT '==============================================================================================';
        PRINT 'Loading the Bronze Layer';
        PRINT '==============================================================================================';

        PRINT '------------------------------------------------------------------------------------------------';
        PRINT 'Loading the CRM Tables';
        PRINT '------------------------------------------------------------------------------------------------';

        SET @start_time = GETDATE(); --CURRENT TIME WHEN LOADING STARTS

        PRINT 'Truncating the table BRONZE.CRM_CUST_INFO';
        TRUNCATE TABLE BRONZE.CRM_CUST_INFO; --emptying the table data while retaining the structure so that data gets loaded only once.

        PRINT 'Inserting into the table BRONZE.CRM_CUST_INFO';
        BULK INSERT BRONZE.CRM_CUST_INFO
        FROM 'C:\Users\varsha.raguraman\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FirstRow = 2,
            FieldTerminator = ',',
            Tablock
        );

        SET @end_time = GETDATE(); --current time when loading is complete

        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load the data is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        --1st row contains all the column names. so data starts from 2nd row.
        --in csv file, all datas are separated with commas which is given as fieldterminator
        --Tablock: Locks the table(during) when the bulk insert happens.
        --Check the data quality and correctness

        SELECT * FROM bronze.crm_cust_info;
        SELECT COUNT(*) FROM bronze.crm_cust_info; -- check in csv files how many rows we've got.

        --when this query is executed again, it loads the same set of data again which is wrong.
        --The Load method we will be using is full load: Truncate and insert.

        SET @start_time = GETDATE();

        PRINT 'Truncating the table BRONZE.CRM_PRD_INFO';
        TRUNCATE TABLE BRONZE.CRM_PRD_INFO;

        PRINT 'Inserting into the table BRONZE.CRM_PRD_INFO';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\varsha.raguraman\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FirstRow = 2,
            FieldTerminator = ',',
            Tablock
        );

        SET @end_time = GETDATE();

        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load the data is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT 'Truncating the table BRONZE.CRM_SALES_DETAILS';
        TRUNCATE TABLE BRONZE.CRM_SALES_DETAILS;

        PRINT 'Inserting into the table bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\varsha.raguraman\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FirstRow = 2,
            FieldTerminator = ',',
            Tablock
        );

        SET @end_time = GETDATE();

        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load the data is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';


        PRINT '------------------------------------------------------------------------------------------------';
        PRINT 'Loading the ERP Tables';
        PRINT '------------------------------------------------------------------------------------------------';

        --2.ERP TABLES

        SET @start_time = GETDATE();

        PRINT 'Truncating the table BRONZE.ERP_CUST_AZ12';
        TRUNCATE TABLE bronze.erp_CUST_AZ12;

        PRINT 'Inserting into the table BRONZE.ERP_CUST_AZ12';
        BULK INSERT bronze.erp_CUST_AZ12
        FROM 'C:\Users\varsha.raguraman\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\cust_AZ12.csv'
        WITH (
            FirstRow = 2,
            FieldTerminator = ',',
            Tablock
        );

        SET @end_time = GETDATE();

        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load the data is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT 'Truncating the table BRONZE.ERP_LOC_A101';
        TRUNCATE TABLE bronze.erp_LOC_A101;

        PRINT 'Inserting into the table BRONZE.ERP_LOC_A101';
        BULK INSERT bronze.erp_LOC_A101
        FROM 'C:\Users\varsha.raguraman\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FirstRow = 2,
            FieldTerminator = ',',
            Tablock
        );

        SET @end_time = GETDATE();

        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load the data is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        SET @start_time = GETDATE();

        PRINT 'Truncating the table BRONZE.PX_CAT_G1V2';
        TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

        PRINT 'Inserting into the table BRONZE.PX_CAT_G1V2';
        BULK INSERT bronze.erp_PX_CAT_G1V2
        FROM 'C:\Users\varsha.raguraman\Downloads\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FirstRow = 2,
            FieldTerminator = ',',
            Tablock
        );

        SET @end_time = GETDATE();

        PRINT '-----------------------------------------------------------------------';
        PRINT 'The duration to load the data is ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '-----------------------------------------------------------------------';

        SET @end_time = GETDATE();
        PRINT '=====================================================================================================';
        PRINT 'The overall duration to load the bronze layer is ' + CAST(DATEDIFF(SECOND, @overall_start_time, @end_time) AS NVARCHAR) + ' secs';
        PRINT '=====================================================================================================';

    END TRY

    BEGIN CATCH
        PRINT '========================================================================';
        PRINT 'ERROR OCCURED DURING LOAD PROCESS';
        PRINT 'ERROR MESSAGE: ' + ERROR_MESSAGE();
        PRINT 'ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR);
    END CATCH
END
