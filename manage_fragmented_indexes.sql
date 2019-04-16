DECLARE @name_filter VARCHAR(250)
DECLARE @fillfactor INT;
DECLARE @name VARCHAR(100),@table_name VARCHAR(255), @fragmentation float, @sql NVARCHAR(4000);

IF ( OBJECT_ID('tempdb.dbo.#index_fragmentation_table') IS NOT NULL)
 BEGIN
          DROP TABLE #index_fragmentation_table
 END

CREATE TABLE #index_fragmentation_table (name VARCHAR(100),table_name VARCHAR(250), fragmentation float);

SELECT @name_filter='sstl'

DECLARE @db_id int 

SELECT @db_id = DB_ID('postilion_office');

INSERT INTO #index_fragmentation_table (name,table_name, fragmentation)

SELECT
		i.[name]
		,o.[name]
		, dm.[avg_fragmentation_in_percent]
FROM 
 sys.objects o INNER JOIN sys.indexes i
ON 
o.[object_id] = i.[object_id] AND (i.name IS NOT NULL OR i.name <> 'NULL' )
INNER JOIN sys.dm_db_index_physical_stats (@db_id, NULL, NULL, NULL, 'LIMITED') dm
ON i.[object_id] = dm.[object_id]
AND i.[index_id] = dm.[index_id]
AND dm.[avg_fragmentation_in_percent] >= 5
WHERE i.name  LIKE '%'+@name_filter+'%'

SELECT * FROM #index_fragmentation_table;

DECLARE index_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT name,table_name, fragmentation FROM #index_fragmentation_table ORDER BY fragmentation DESC;

OPEN index_cursor;

FETCH NEXT FROM index_cursor INTO @name,@table_name ,@fragmentation;

WHILE (@@FETCH_STATUS=0) BEGIN

IF (@@MICROSOFTVERSION / POWER(2, 24) >= 9)
	BEGIN
	  SET @sql = 'ALTER INDEX '+@name+' ON '+@table_name+'  REBUILD PARTITION = ALL WITH ( FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ', PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, ONLINE = ON, SORT_IN_TEMPDB = OFF, MAXDOP = 16 )';
      EXEC sp_executesql @statement = @sql
     PRINT 'Finished rebuiding index: '+@name +' of table: '+@table_name+CHAR(10);
END
ELSE BEGIN
IF (@fragmentation<30.0)
 BEGIN
	 SET @sql = 'DBCC INDEXDEFRAG(' + DB_NAME(DB_ID()) + ',' + @table_name + ', ' + @name + ') WITH NO_INFOMSGS'
	 EXEC sp_executesql @statement = @sql
	 PRINT 'Finished defragmenting index: '+@name +' of table: '+@table_name+CHAR(10);
 END
ELSE 
     BEGIN
		SET @sql = 'DBCC DBREINDEX ('''+@table_name+''', '''+@name+''', 90)'
		EXEC sp_executesql @statement = @sql
		PRINT 'Finished rebuiding index: '+@name +' of table: '+@table_name+CHAR(10);
	END
END


FETCH NEXT FROM index_cursor INTO @name,@table_name ,@fragmentation;
END
CLOSE index_cursor;
DEALLOCATE index_cursor;

=======================================================================

USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[manage_fragmented_indexes]    Script Date: 08/28/2014 10:17:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[manage_fragmented_indexes] (@name_filter VARCHAR(250), @fillfactor INT)
 AS
 
 BEGIN 

DECLARE @name VARCHAR(100),@table_name VARCHAR(255), @fragmentation float, @sql NVARCHAR(4000);

IF ( OBJECT_ID('tempdb.dbo.#index_fragmentation_table') IS NOT NULL)
 BEGIN
          DROP TABLE #index_fragmentation_table
 END

CREATE TABLE #index_fragmentation_table (name VARCHAR(100),table_name VARCHAR(250), fragmentation float);

SELECT @name_filter=ISNULL(@name_filter,'');

SELECT @fillfactor=ISNULL(@fillfactor,85);


DECLARE @db_id INT;

SELECT @db_id = DB_ID('postilion_office');

INSERT INTO #index_fragmentation_table (name,table_name, fragmentation)

SELECT
		i.[name]
		,o.[name]
		, dm.[avg_fragmentation_in_percent]
FROM 
 sys.objects o INNER JOIN sys.indexes i
ON 
o.[object_id] = i.[object_id] AND (i.name IS NOT NULL OR i.name <> 'NULL' )
INNER JOIN sys.dm_db_index_physical_stats (@db_id, NULL, NULL, NULL, 'LIMITED') dm
ON i.[object_id] = dm.[object_id]
AND i.[index_id] = dm.[index_id]
AND dm.[avg_fragmentation_in_percent] >= 5
WHERE i.name  LIKE '%'+@name_filter+'%'

SELECT * FROM #index_fragmentation_table;

DECLARE index_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT name,table_name, fragmentation FROM #index_fragmentation_table ORDER BY fragmentation DESC;

OPEN index_cursor;

FETCH NEXT FROM index_cursor INTO @name,@table_name ,@fragmentation;


WHILE (@@FETCH_STATUS=0) BEGIN

IF (@@MICROSOFTVERSION / POWER(2, 24) >= 9)
	BEGIN
	  SET @sql = 'ALTER INDEX '+@name+' ON '+@table_name+'  REBUILD PARTITION = ALL WITH ( FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ', PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON,  SORT_IN_TEMPDB = OFF, MAXDOP = 3)';
      EXEC sp_executesql @statement = @sql
     PRINT 'Finished rebuiding index: '+@name +' of table: '+@table_name+CHAR(10);
END
ELSE BEGIN
IF (@fragmentation<30.0)
 BEGIN
	 SET @sql = 'DBCC INDEXDEFRAG(' + DB_NAME(DB_ID()) + ',' + @table_name + ', ' + @name + ') WITH NO_INFOMSGS'
	 EXEC sp_executesql @statement = @sql
	 PRINT 'Finished defragmenting index: '+@name +' of table: '+@table_name+CHAR(10);
 END
ELSE 
     BEGIN
		SET @sql = 'DBCC DBREINDEX ('''+@table_name+''', '''+@name+''', 90)'
		EXEC sp_executesql @statement = @sql
		PRINT 'Finished rebuiding index: '+@name +' of table: '+@table_name+CHAR(10);
	END
END


FETCH NEXT FROM index_cursor INTO @name,@table_name ,@fragmentation;
END

CLOSE index_cursor;
DEALLOCATE index_cursor;

END

==============================================


DECLARE @db_id int 

SELECT @db_id = DB_ID('postilion_office');

SELECT dm.[object_id]
, DB_NAME(DB_ID()) + '.' + s.[name] +'.' + o.[name]
, dm.[index_id]
, i.[name]
, dm.[partition_number]
, dm.[index_type_desc]
, [pad_index] = CASE i.[is_padded]
WHEN 0 THEN 'OFF'
WHEN 1 THEN 'ON'
END
, i.[fill_factor]
, [statistics_norecompute] = CASE st.[no_recompute]
WHEN 0 THEN 'OFF'
WHEN 1 THEN 'ON'
END
, [ignore_dup_key] = CASE i.[ignore_dup_key]
WHEN 0 THEN 'OFF'
WHEN 1 THEN 'ON'
END
, [allow_row_locks] = CASE i.[allow_row_locks]
WHEN 0 THEN 'OFF'
WHEN 1 THEN 'ON'
END
, [allow_page_locks] = CASE i.[allow_page_locks]
WHEN 0 THEN 'OFF'
WHEN 1 THEN 'ON'
END
, dm.[avg_fragmentation_in_percent]
FROM sys.objects o
INNER JOIN sys.indexes i
ON o.[object_id] = i.[object_id] AND (i.name IS NOT NULL OR i.name <> 'NULL')
INNER JOIN sys.dm_db_index_physical_stats (@db_id, NULL, NULL, NULL, 'LIMITED') dm
ON i.[object_id] = dm.[object_id]
AND i.[index_id] = dm.[index_id]
AND dm.[avg_fragmentation_in_percent] >= 5
INNER JOIN sys.schemas s
ON o.[schema_id] = s.[schema_id]
INNER JOIN sys.stats st
ON i.[name] = st.[name] AND o.[object_id] = st.[object_id]
AND o.[type] = 'U'