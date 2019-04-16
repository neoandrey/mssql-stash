  
  
  
  CREATE FUNCTION fn_check_index_column_type
   (@column_list  VARCHAR(MAX), @table_name VARCHAR(MAX))
   RETURNS INT
  as begin
  declare @return_value int
   set @return_value =1
  DECLARE @column_type_table TABLE (COLUMN_NAME VARCHAR(MAX), COLUMN_TYPE VARCHAR(MAX))
  IF(@column_list IS NOT NULL) BEGIN
  INSERT INTO @column_type_table
   SELECT PART, null FROM dbo.usf_split_string(@column_list, ',');
  
  UPDATE  @column_type_table SET COLUMN_TYPE = DATA_TYPE FROM  INFORMATION_SCHEMA.COLUMNS  info JOIN @column_type_table cols 
  ON info.COLUMN_NAME = cols.COLUMN_NAME AND info.TABLE_NAME=@table_name;
   IF((SELECT count(COLUMN_NAME) FROM @column_type_table WHERE COLUMN_TYPE ='text')>0 )begin
	return 0;
   end
  END
  
  return @return_value
   END
   
