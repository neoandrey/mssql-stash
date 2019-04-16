TRUNCATE TABLE pc_cards_test;

DECLARE @table_name  VARCHAR(50);
DECLARE @sql_query  VARCHAR(max);
DECLARE @counter  INT
SET @counter = 0;
DECLARE pc_cards_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR 

SELECT TABLE_NAME  FROM [172.25.15.213].postcard.INFORMATION_SCHEMA.TABLES where  table_type = 'BASE TABLE' AND TABLE_NAME LIKE 'pc_cards_[0-9]%' 
ORDER BY  SUBSTRING(TABLE_NAME, (CHARINDEX('ds_', TABLE_NAME)+3), LEN(TABLE_NAME))  ASC
OPEN pc_cards_cursor
FETCH NEXT FROM pc_cards_cursor   INTO @table_name
WHILE (@@FETCH_STATUS=0) BEGIN
  SELECT @counter =@counter +1;
  PRINT CONVERT(VARCHAR(10),@counter)+'. Populating table: '+@table_name
  EXEC('INSERT INTO pc_cards_test SELECT * FROM  OPENQUERY([172.25.15.213], ''SELECT * FROM  postcard.dbo.['+@table_name+'] (NOLOCK);'');')
FETCH NEXT FROM pc_cards_cursor   INTO @table_name
END
CLOSE pc_cards_cursor
DEALLOCATE pc_cards_cursor