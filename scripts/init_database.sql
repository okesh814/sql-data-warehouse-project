/*
=====================================================================
CREATE Database and Schemas
=====================================================================
Script Pupose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists.If the database exists,it is dropped and recreated.Additionally,
    the script sets up three schemas within databese:'bronze','silver', and 'gold'.

*/



-- CREATE DATABASE 'DataWareHouse'
 USE MASTER; --It is a system databse

 --Drop and recreate the 'DataWarehouse' database
 IF EXISTS(SELECT 1 FROM SYS.DATABASES WHERE NAME='DataWarehouse')
 BEGIN
      ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
      DROP DATABASE DataWarehouse;
 END;
 GO

 CREATE DATABASE DataWarehouse; --CREATE the 'DataWarehouse' database
 USE DataWarehouse;
 CREATE SCHEMA bronze;
 GO
 CREATE SCHEMA silver;
 GO
 CREATE SCHEMA gold;
 GO
