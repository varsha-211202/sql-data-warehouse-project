/*
==================================================
Create Database and Schemas
==================================================
Script Purpose:
This script creates a new database named 'DataWarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas
within the database: 'bronze', 'silver', and 'gold'.

*/


--Create the Database: DataWarehouse

use master;
Go; --Separate and execute the batch

create database DataWarehouse;
Go;

use DataWarehouse;
Go;


--Creating the Schemas 

create schema bronze;
Go; 
create schema silver;
Go;

create schema gold;
Go;
