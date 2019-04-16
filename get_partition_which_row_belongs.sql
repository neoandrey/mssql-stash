[ database_name. ] $PARTITION.partition_function_name(expression)  
SELECT * FROM Production.TransactionHistory  
WHERE $PARTITION.TransactionRangePF1(TransactionDate) = 5 ;    
SELECT $PARTITION.[partition_quickteller_db_by_id](60728105)