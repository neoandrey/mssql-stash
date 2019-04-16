CREATE TABLE temp_transactions (
 tran_number VARCHAR(1000) NOT NULL

 )
 
 SELECT * FROM temp_transactions


BULK INSERT dbo.temp_transactions 
   FROM 'c:\temp\file.txt'
   WITH 
      (
         ROWTERMINATOR ='\n'
      )