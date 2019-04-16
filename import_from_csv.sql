
DECLARE @table_name VARCHAR(255)

DECLARE @file_path VARCHAR(8000)

DECLARE @field_terminator VARCHAR(20)

DECLARE @row_terminator VARCHAR(20)

BULK INSERT 
	test_table
  FROM 
       'C:\temp\test_table.csv' 
  WITH
  (FIELDTERMINATOR='', ROWTERMINATOR ='')