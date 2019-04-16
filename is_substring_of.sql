CREATE  FUNCTION isValidInColumn(@column_value VARCHAR(255), @search_string  VARCHAR(8000), @delimiter VARCHAR(5)) 
RETURNS BIT
AS  
BEGIN
 DECLARE  @is_contained_in_column BIT = 0

 DECLARE @field_container_table TABLE (field_value VARCHAR(8000))
 INSERT INTO @field_container_table select part FROM usf_split_string(@search_string, @delimiter);

   IF ((SELECT COUNT(*) FROM  @field_container_table  WHERE  CHARINDEX(field_value, @column_value)>0) > 0) BEGIN
   
		SET @is_contained_in_column  =1
	END

	RETURN @is_contained_in_column

END


CREATE  FUNCTION is_substring_of(@column_value VARCHAR(255), @search_string  VARCHAR(8000), @delimiter VARCHAR(5)) 
RETURNS BIT
AS  
BEGIN
 DECLARE  @is_contained_in_column BIT = 0

 DECLARE @field_container_table TABLE (field_value VARCHAR(8000))
 INSERT INTO @field_container_table select part FROM usf_split_string(@search_string, @delimiter);

   IF ((SELECT COUNT(*) FROM  @field_container_table  WHERE  CHARINDEX(field_value, @column_value)>0) > 0) BEGIN
   
		SET @is_contained_in_column  =1
	END

	RETURN @is_contained_in_column

END