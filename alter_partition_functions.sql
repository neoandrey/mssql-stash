IF EXISTS (SELECT * FROM sys.partition_functions  
    WHERE name = 'myRangePF1')  
DROP PARTITION FUNCTION myRangePF1;  
GO  
CREATE PARTITION FUNCTION myRangePF1 (int)  
AS RANGE LEFT FOR VALUES ( 1, 100, 1000 );  
GO  
--Split the partition between boundary_values 100 and 1000  
--to create two partitions between boundary_values 100 and 500  
--and between boundary_values 500 and 1000.  
ALTER PARTITION FUNCTION myRangePF1 ()  
SPLIT RANGE (500);  


IF EXISTS (SELECT * FROM sys.partition_functions  
    WHERE name = 'myRangePF1')  
DROP PARTITION FUNCTION myRangePF1;  
GO  
CREATE PARTITION FUNCTION myRangePF1 (int)  
AS RANGE LEFT FOR VALUES ( 1, 100, 1000 );  
GO  
--Merge the partitions between boundary_values 1 and 100  
--and between boundary_values 100 and 1000 to create one partition  
--between boundary_values 1 and 1000.  
ALTER PARTITION FUNCTION myRangePF1 ()  
MERGE RANGE (100);  



-- create partition function 
CREATE PARTITION FUNCTION partRange1 (INT) 
AS RANGE LEFT FOR VALUES (10, 20, 30) ; 
GO 

-- create partition scheme 
CREATE PARTITION SCHEME partScheme1 
AS PARTITION partRange1 
ALL TO ([PRIMARY]) ; 
GO 

-- create table that uses this partitioning scheme 
CREATE TABLE partTable (col1 INT, col2 VARCHAR(20)) 
ON partScheme1 (col1) ; 
GO



-- insert some sample data 
INSERT INTO partTable (col1, col2) VALUES (5, 'partTable') 
INSERT INTO partTable (col1, col2) VALUES (6, 'partTable') 
INSERT INTO partTable (col1, col2) VALUES (7, 'partTable') 

-- select the data 
SELECT * FROM partTable


-- switch in 
CREATE TABLE newPartTable (col1 INT CHECK (col1 > 30 AND col1 <= 40 AND col1 IS NOT NULL),  
col2 VARCHAR(20)) 
GO 

-- insert some sample data into new table 
INSERT INTO newPartTable (col1, col2) VALUES (31, 'newPartTable') 
INSERT INTO newPartTable (col1, col2) VALUES (32, 'newPartTable') 
INSERT INTO newPartTable (col1, col2) VALUES (33, 'newPartTable') 

-- select the data 
SELECT * FROM partTable 
SELECT * FROM newPartTable


-- make the switch 
ALTER TABLE newPartTable SWITCH TO partTable PARTITION 4; 
GO 

-- select the data 
SELECT * FROM partTable 
SELECT * FROM newPartTable


-- switch out 
CREATE TABLE nonPartTable (col1 INT, col2 VARCHAR(20)) 
ON [primary] ; 
GO 

-- make the switch 
ALTER TABLE partTable SWITCH PARTITION 1 TO nonPartTable ; 
GO 

-- select the data 
SELECT * FROM partTable 
SELECT * FROM nonPartTable


ALTER PARTITION FUNCTION VZDArchiveDatePartition() MERGE RANGE (N'2011-08-01T00:00:00.000');
ALTER PARTITION FUNCTION VZDArchiveDatePartition() MERGE RANGE (N'2011-09-01T00:00:00.000');