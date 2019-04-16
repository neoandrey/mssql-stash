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