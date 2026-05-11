/*
==================================================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
==================================================================================================
Script Purpose:
      This stored Procedufre loads data into the 'bronze' schema from external files.
      It performs the following actions:
      -Truncate the bronze tables before loading data.
      -Uses the 'BULK INSERT' Command to load data from CSV Files to bronze tables.

Parameters:
      None.
 This stored procedure does not accept any parameters or return any values.

Using Example:
Exec bronze.load_bronze;
===================================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
     DECLARE @start_time DATETIME,@end_time DATETIME;
     BEGIN TRY
print'===========================================================================';
PRINT'LOADING BRONZE LAYER';
PRINT'===========================================================================';

PRINT'---------------------------------------------------------------------------';
PRINT'LOADING CRM TABLES';
PRINT'---------------------------------------------------------------------------';
SET @start_time=GETDATE();
PRINT'TRUNCATING TABLE:bronze.crm_cust_info'
TRUNCATE TABLE bronze.crm_cust_info;

PRINT'INSERTING DATA INTO:bronze.crm_cust_info';
BULK INSERT bronze.crm_cust_info
FROM 'C:\Users\HP\Downloads\dWH\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
WITH(
     FIRSTROW=2,
     FIELDTERMINATOR=',',
     TABLOCK
     );
SET @end_time=GETDATE();
PRINT'>>LOAD DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds';
print'----------------------------------------';
SET @start_time=GETDATE();
PRINT'TRUNCATING TABLE:bronze.crm_prd_info'
TRUNCATE TABLE bronze.crm_prd_info;
PRINT'INSERTING DATA INTO:bronze.crm_prd_info';
BULK INSERT bronze.crm_prd_info
FROM 'C:\Users\HP\Downloads\dWH\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
WITH(
     FIRSTROW=2,
     FIELDTERMINATOR=',',
     TABLOCK);
SET @end_time=GETDATE();
PRINT('>>LOAD DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) +' seconds');
PRINT'TRUNCATING TABLE:bronze.crm_sales_details'
TRUNCATE TABLE bronze.crm_sales_details;
PRINT'INSERTING DATA INTO:bronze.crm_sales_details';
BULK INSERT bronze.crm_sales_details
FROM 'C:\Users\HP\Downloads\dWH\sql-data-warehouse-project\datasets\source_crm/sales_details.csv'
WITH(
     FIRSTROW=2,
     FIELDTERMINATOR=',',
     TABLOCK);
PRINT'TRUNCATING TABLE:bronze.erp_cust_az12'
TRUNCATE TABLE bronze.erp_cust_az12;
PRINT'INSERTING DATA INTO:bronze.erp_cust_az12';
BULK INSERT bronze.erp_cust_az12
FROM 'C:\Users\HP\Downloads\dWH\sql-data-warehouse-project\datasets\source_erp/cust_az12.csv'
WITH(
     FIRSTROW=2,
     FIELDTERMINATOR=',',
     TABLOCK);

PRINT'TRUNCATING TABLE:bronze.erp_loc_a101'
TRUNCATE TABLE bronze.erp_loc_a101;
PRINT'INSERTING DATA INTO:bronze.erp_loc_a101';
BULK INSERT bronze.erp_loc_a101
FROM 'C:\Users\HP\Downloads\dWH\sql-data-warehouse-project\datasets\source_erp/loc_a101.csv'
WITH(
     FIRSTROW=2,
     FIELDTERMINATOR=',',
     TABLOCK);

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
PRINT'INSERTING DATA INTO:bronze.erp_px_cat_g1v2';
BULK INSERT bronze.erp_px_cat_g1v2
FROM 'C:\Users\HP\Downloads\dWH\sql-data-warehouse-project\datasets\source_erp/px_cat_g1v2.csv'
WITH(
     FIRSTROW=2,
     FIELDTERMINATOR=',',
     TABLOCK);
     END TRY
     BEGIN CATCH
         PRINT'=============================================================================';
         PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER';
         PRINT'==============================================================================';
         PRINT'ERROR MESSAGE'+ERROR_MESSAGE();
         PRINT'ERROR NUMBER'+CAST(ERROR_NUMBER() AS NVARCHAR);
     END CATCH
END;
