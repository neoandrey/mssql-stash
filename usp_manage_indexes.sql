 
  
  CREATE FUNCTION [dbo].[fn_check_index_column_type]
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
   


GO


USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[usp_index_manager]    Script Date: 05/20/2016 08:26:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[usp_index_manager]
AS 

BEGIN

DECLARE @sql_text Nvarchar(max);
DECLARE @create_index_table TABLE (create_command VARCHAR(MAX))
DECLARE @drop_index_table TABLE (drop_command VARCHAR(MAX))


PRINT CHAR(10)+' Fetching list of all missing indexes and saving them in a table:';
INSERT INTO
         @create_index_table ( create_command)

 SELECT  
		distinct 'USE [' + DB_NAME(database_id) + '];
		CREATE INDEX indx_' + replace(replace(replace(replace
		(ISNULL(left(equality_columns,10), '')
		+ ISNULL(left(inequality_columns,10), ''), ', ', '_')+ +'_'+ (CONVERT(VARCHAR(5),ROW_NUMBER() OVER (ORDER BY c.object_id ))),
		'[', ''), ']', ''), ' ', '') + '
		ON [' + schema_name(d.schema_id) + ']
		.[' + OBJECT_NAME(c.object_id) + ']
		(' + ISNULL(equality_columns, '') +
		CASE WHEN equality_columns IS NOT NULL
		AND c.inequality_columns IS NOT NULL THEN ', '
		ELSE '' END + ISNULL(inequality_columns, '') + ')
		' + CASE WHEN included_columns IS NOT NULL THEN
		'INCLUDE (' + included_columns + ')' ELSE '' END + '
		WITH (FILLFACTOR=90)' [create_command]

FROM sys.dm_db_missing_index_details c JOIN sys.objects d ON c.object_id = d.object_id
WHERE c.database_id = db_id('postilion_office')
  AND 
 OBJECT_NAME(c.object_id) NOT IN ('post_tran', 'post_tran_cust')
  AND 
 OBJECT_NAME(c.object_id) NOT IN ('post_tran', 'post_tran_cust')
 AND 
 dbo.fn_check_index_column_type(RTRIM(LTRIM(REPLACE(REPLACE(equality_columns,'[',''),']',''))), [name] )=1
 AND 
  dbo.fn_check_index_column_type(RTRIM(LTRIM(REPLACE(REPLACE(inequality_columns,'[',''),']',''))),  [name]  ) =1
  AND 
  dbo.fn_check_index_column_type(RTRIM(LTRIM(REPLACE(REPLACE(included_columns,'[',''),']',''))) ,   [name]  ) =1
  
PRINT CHAR(10)+' Fetching list of all unused indexes and saving them in a table:';

INSERT INTO
         @drop_index_table ( drop_command) 
       SELECT 
       
				'DROP INDEX '+ I.[NAME]+ '	ON '+OBJECT_NAME(S.[OBJECT_ID]) [drop_command]
			   
		FROM   SYS.DM_DB_INDEX_USAGE_STATS AS S 
			   INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID] AND I.INDEX_ID = S.INDEX_ID 
		WHERE  OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1
			   AND S.database_id = DB_ID() 
		AND  USER_SEEKS =0 and  USER_SCANS=0  AND USER_LOOKUPS=0  AND USER_UPDATES in (0,1)
AND type_desc <> 'CLUSTERED';
		
		
		PRINT CHAR(10)+'Removing all unused indexes';
		
	    DECLARE drop_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT drop_command FROM @drop_index_table;
		OPEN drop_cursor
		FETCH NEXT FROM  drop_cursor INTO @sql_text 
		WHILE (@@FETCH_STATUS=0) BEGIN
			BEGIN TRY
			    SET @sql_text  = REPLACE(@sql_text ,'''','''''');
				PRINT CHAR(10)+'Running command to drop index: '+@sql_text;
				EXEC(@sql_text);			
				FETCH NEXT FROM  drop_cursor INTO @sql_text 
			END TRY
			BEGIN CATCH
			PRINT CHAR(10)+'Error running script: '+@sql_text;
			FETCH NEXT FROM  drop_cursor INTO @sql_text 
			END CATCH
		END
		CLOSE drop_cursor
		DEALLOCATE drop_cursor
		PRINT CHAR(10)+'All unused indexes successfully removed.';

		DECLARE create_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT create_command FROM @create_index_table;
		OPEN create_cursor
		FETCH NEXT FROM  create_cursor INTO @sql_text 
		WHILE (@@FETCH_STATUS=0) BEGIN
		BEGIN TRY
			SET @sql_text  = REPLACE(@sql_text ,'''','''''');
			PRINT CHAR(10)+'Running command to create index: '+@sql_text;
			EXEC(@sql_text);			
			FETCH NEXT FROM  create_cursor INTO @sql_text 
			END TRY
						BEGIN CATCH
						PRINT CHAR(10)+'Error running script: '+@sql_text;
						FETCH NEXT FROM  create_cursor INTO @sql_text 
			END CATCH
		END
		CLOSE create_cursor
		DEALLOCATE create_cursor
END


GO


