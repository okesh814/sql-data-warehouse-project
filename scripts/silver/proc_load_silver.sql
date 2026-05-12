/*
============================================================================================================
STORED PROCEDURE:LOAD SILVER LAYER (BRONZE-> SILVER)
============================================================================================================
SCRIPT PURPOSE:
    This stored procedure performs the ETL(EXTRACT,TRANSFORM,LOAD) Process to populate the 'silver' schema
    tables from the 'bronze' schema'

Actions Performed:
  -Truncates Silver tables.
  -Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
   None.
   This stored procedure does not accept any parameters or return any values.

Usage Example:
   Exec silver.load_silver;
==========================================================================================================
*/

CREATE or ALTER PROCEDURE silver.load_silver AS
BEGIN 
DECLARE @start_time DATETIME,@end_time DATETIME,@batch_start_time DATETIME,@batch_end_time DATETIME;
BEGIN TRY
 SET @batch_start_time=GETDATE();
 PRINT'===============================================================';
 PRINT'LOADING SILVER LAYER';
 PRINT'===============================================================';


 PRINT'----------------------------------------------------------------';
 PRINT'LOADING CRM TABLE';
 PRINT'----------------------------------------------------------------';

--LOADING silver.crm_cust_info
SET @start_time=GETDATE();
PRINT'>>TRUNCATING TABLE:silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
PRINT'>>INSERTING DATA INTO :silver.crm_cust_info';
INSERT INTO silver.crm_cust_info(
       cst_id,
       cst_key,
       cst_firstname,
       cst_lastname,
       cst_material_status,
       cst_gndr,
       cst_create_date)
SELECT cst_id,
       cst_key,
       TRIM(cst_firstname) AS cst_firstname,
       TRIM(cst_lastname) AS cst_lastname,
       CASE
           WHEN UPPER(TRIM(cst_material_status))='M' THEN 'MARRIED'
           WHEN UPPER(TRIM(cst_material_status))='S' THEN 'SINGLE'
           ELSE 'n/a'
        END AS cst_material_status,
        CASE
            WHEN UPPER(TRIM(cst_gndr))='M' THEN 'MALE'
            WHEN UPPER(TRIM(cst_gndr))='F' THEN 'FEMALE'
            ELSE 'n/a'
         END AS cst_gndr,
         cst_create_date
         FROM (
       SELECT *,
       ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date desc) AS flag_last
       FROM bronze.crm_cust_info
       WHERE cst_id IS NOT NULL
       )t WHERE flag_last=1 ;
    SET @end_time=GETDATE();
    PRINT'>>LOAD DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' SECONDS';
    PRINT'>>--------';
   
   ------------------------------------------------------------------------;
   /*
   --CHECK FOR NULLS OR DUPLICATES IN PRIMARY KEY
   --EXPECTATIONS: NO RESULT
   SELECT cst_id,
          count(*)
          from silver.crm_cust_info
          group by cst_id
          having count(*) >1 and cst_id is null;
     */
   --------------------------------------------------------------------------;
   
   --checking for unwanted spaces
   --Expectation :NO RESULT
   /*
   SELECT cst_firstname from silver.crm_cust_info
   where TRIM(cst_firstname)!=cst_firstname;
   */

   --=============================================================================;
   --LOADING silver.crm_prd_info TABLE
   --INSERT CLEAN AND PROCESSED DATA INTO SILVER TABLE
   SET @start_time=GETDATE();
   PRINT'>>TRUNCATING TABLE:silver.crm_prd_info';
   TRUNCATE TABLE silver.crm_prd_info;
   PRINT'>>INSERTING DATA INTO :silver.crm_prd_info';
   INSERT INTO silver.crm_prd_info(
          prd_id,
          cat_id,
          prd_key,
          prd_nm,
          prd_cost,
          prd_line,
          prd_start_dt,
          prd_end_dt)

    SELECT 
          prd_id,
          REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,  --EXTRACT CATEGORY ID
          SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,       --EXTRACT PRODUCT KEY
          prd_nm,
          ISNULL(prd_cost,0) AS prd_cost,
          CASE
              WHEN UPPER(TRIM(prd_line))='M' THEN 'Mountain'
              WHEN UPPER(TRIM(prd_line))='R' THEN 'Road'
              WHEN UPPER(TRIM(prd_line))='S' THEN 'Other Sales'
              WHEN UPPER(TRIM(prd_line))='T' THEN 'Touring'
              ELSE 'n/a'
           END AS prd_line,   --MAP PRODUCT LINE CODES TO DESCRIPTIVE VALUES
           CAST(prd_start_dt AS DATE) AS prd_start_dt,
           DATEADD(DAY,-1,LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
           FROM bronze.crm_prd_info;
           SET @end_time=GETDATE();
           PRINT'>>LOAD DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' SECONDS';
           PRINT'>>--------';

---------------------------------------------------------------------------------------------------------------------;
--INSERT DATA INTO SILVER TABLE 
/*
SELECT DISTINCT sls_cust_id from bronze.crm_sales_details;
SELECT sls_cust_id,count(*)
from bronze.crm_sales_details
group by sls_cust_id
having count(*)>1;
*/
-----------------------------------------------------------------------------------------------------------;
--LOADING silver.crm_sales_details TABLE
SET @start_time=GETDATE();
PRINT'>>TRUNCATING TABLE:silver.crm_sales_details';
TRUNCATE TABLE silver.crm_sales_details;
PRINT'>>INSERTING DATA INTO :silver.crm_sales_details';
INSERT INTO silver.crm_sales_details(
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      sls_order_dt,
      sls_ship_date,
      sls_due_dt,
      sls_sales,
      sls_quantity,
      sls_price
      )
SELECT 
      sls_ord_num,
      sls_prd_key,
      sls_cust_id,
      CASE 
          WHEN sls_order_dt=0 or LEN(sls_order_dt)!=8 THEN NULL
          ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
      END AS sls_order_dt,
      CASE 
          WHEN sls_ship_date=0 OR LEN(sls_ship_date)!=8 THEN NULL
          ELSE CAST(CAST(sls_ship_date AS VARCHAR) AS DATE)
      END AS sls_ship_date,
      CASE 
          WHEN sls_due_dt =0 OR LEN(sls_due_dt)!=8 THEN NULL
          ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
      END AS sls_due_dt,
      CASE WHEN sls_sales IS NULL OR sls_sales <=0 or sls_sales!=sls_quantity*ABS(sls_price)
               THEN sls_quantity*ABS(sls_price)
            ELSE sls_sales
      END AS sls_sales,
      sls_quantity,
      CASE WHEN sls_price IS NULL OR sls_price<0
                THEN sls_sales/NULLIF(sls_quantity,0)
            ELSE sls_price
      END sls_price
      FROM bronze.crm_sales_details;
      SET @end_time=GETDATE();
      PRINT'>>LOAD DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' SECONDS';
      PRINT'>>--------';
      
 ----------------------------------------------------------------;
 --LOADING silver.erp_cust_az12 TABLE
 SET @start_time=GETDATE();
PRINT'>>TRUNCATING TABLE:silver.erp_cust_az12';
TRUNCATE TABLE silver.erp_cust_az12;
PRINT'>>INSERTING DATA INTO :silver.erp_cust_az12';
 INSERT INTO silver.erp_cust_az12(
      cid,
      bday,
      gen)
SELECT 
      CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
           ELSE cid
      END AS cid,
      CASE WHEN bday>GETDATE() THEN NULL
           ELSE bday
      END AS bday,
      CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
           WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
          else 'n/a'
       END AS gen
       FROM bronze.erp_cust_az12;
       SET @end_time=GETDATE();
       PRINT'LOADING DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' SECONDS';
       PRINT'>>------';
       --=======================================================================================;
       --DATA CHECK ----IDENTIFY OUT OF RANGE DATES
       /*
       SELECT DISTINCT bday
       FROM silver.erp_cust_az12
       WHERE bday>GETDATE();
       
       select * from silver.erp_cust_az12;
       */
       --------------------------------------------------------------------------------------------;
      --LOADING silver.erp_loc_a101 TABLE
      SET @start_time=GETDATE();
       PRINT'>>TRUNCATING TABLE:silver.erp_loc_a101';
       TRUNCATE TABLE silver.erp_loc_a101;
       PRINT'>>INSERTING DATA INTO :silver.erp_loc_a101';
       INSERT INTO silver.erp_loc_a101(
                 cid,
                 cntry)
       SELECT 
             CASE WHEN cid LIKE 'AW-%' THEN REPLACE(cid,'-','')
                 ELSE cid
             END cid,
             CASE WHEN TRIM(cntry)='DE' THEN 'Germany'
                  WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
                  WHEN TRIM(cntry)='' or cntry IS NULL THEN 'n/a'
                  ELSE cntry
             END cntry
             from bronze.erp_loc_a101;
             SET @end_time=GETDATE();
             PRINT'LOADING DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' SECONDS';
             PRINT'>>-----------';
----------------------------------------------------------;
--DATA STANDARDIZATION & CONSISTENCY
/*
SELECT DISTINCT cntry
from bronze.erp_loc_a101
order by cntry;
*/
--======================================================================================;
--LOADING silver.erp_px_cat_g1v2 table
SET @start_time=GETDATE();
PRINT'>>TRUNCATING TABLE:silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
PRINT'>>INSERTING DATA INTO :silver.erp_px_cat_g1v2';
INSERT INTO silver.erp_px_cat_g1v2(
     id,
     cat,
     subcat,
     maintenance)
SELECT id,
       cat,
       subcat,
       maintenance
       FROM bronze.erp_px_cat_g1v2;
       SET @end_time=GETDATE();
       PRINT'LOADING DURATION:'+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' SECONDS';
       PRINT'>>---------------------';
       
       SET @batch_end_time=GETDATE();
       PRINT'==================================================';
       PRINT'LOADING SILVER TABLE IS COMPLETED';
       PRINT'TOTAL LOAD DURATION:'+CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) as nvarchar)+' seconds';
       PRINT'===================================================';
    END TRY
    BEGIN CATCH
      PRINT'====================================================';
      PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER';
      PRINT'ERROR MESSAGE'+ERROR_MESSAGE();
      PRINT'ERROR NUMBER'+CAST(ERROR_NUMBER() AS NVARCHAR);
      PRINT'====================================================';
    END CATCH
END
