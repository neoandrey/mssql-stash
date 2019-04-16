
SELECT * FROM sys.dm_db_missing_index_details 

 SELECT  'USE [' + DB_NAME(database_id) + '];
CREATE INDEX indx_' + replace(replace(replace(replace
  (ISNULL(equality_columns, '')
  + ISNULL(inequality_columns, ''), ', ', '_'),
  '[', ''), ']', ''), ' ', '') + '
  ON [' + schema_name(d.schema_id) + ']
  .[' + OBJECT_NAME(c.object_id) + ']
  (' + ISNULL(equality_columns, '') +
  CASE WHEN equality_columns IS NOT NULL
    AND c.inequality_columns IS NOT NULL THEN ', '
    ELSE '' END + ISNULL(inequality_columns, '') + ')
    ' + CASE WHEN included_columns IS NOT NULL THEN
    'INCLUDE (' + included_columns + ')' ELSE '' END + '
    WITH (FILLFACTOR=90, ONLINE=ON)',* FROM sys.dm_db_missing_index_details c JOIN sys.objects d ON c.object_id = d.object_id
WHERE c.database_id = db_id()



--SELECT * FROM  sys.dm_db_missing_index_columns()
  SELECT a.avg_user_impact
  * a.avg_total_user_cost
  * a.user_seeks,
  db_name(c.database_id),
  OBJECT_NAME(c.object_id, c.database_id),
  c.equality_columns,
  c.inequality_columns,
  c.included_columns,
  c.statement,
  'USE [' + DB_NAME(c.database_id) + '];
CREATE INDEX indx_' + replace(replace(replace(replace
  (ISNULL(equality_columns, '')
  + ISNULL(c.inequality_columns, ''), ', ', '_'),
  '[', ''), ']', ''), ' ', '') + '
  ON [' + schema_name(d.schema_id) + ']
  .[' + OBJECT_NAME(c.object_id, c.database_id) + ']
  (' + ISNULL(equality_columns, '') +
  CASE WHEN c.equality_columns IS NOT NULL
    AND c.inequality_columns IS NOT NULL THEN ', '
    ELSE '' END + ISNULL(c.inequality_columns, '') + ')
    ' + CASE WHEN included_columns IS NOT NULL THEN
    'INCLUDE (' + included_columns + ')' ELSE '' END + '
    WITH (FILLFACTOR=70, ONLINE=ON)'
FROM sys.dm_db_missing_index_group_stats a
JOIN sys.dm_db_missing_index_groups b
  ON a.group_handle = b.index_group_handle
JOIN sys.dm_db_missing_index_details c
  ON b.index_handle = c.index_handle
JOIN sys.objects d ON c.object_id = d.object_id
WHERE c.database_id = db_id()
AND  OBJECT_NAME(c.object_id, c.database_id) not in ('post_tran', 'post_tran_cust')
ORDER BY DB_NAME(c.database_id),
  ISNULL(equality_columns, '')
  + ISNULL(c.inequality_columns, ''), a.avg_user_impact
  * a.avg_total_user_cost * a.user_seeks DESC

remove unnecessary indexes:

SELECT OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
       I.[NAME] AS [INDEX NAME], 
       USER_SEEKS, 
       USER_SCANS, 
       USER_LOOKUPS, 
       USER_UPDATES 
FROM   SYS.DM_DB_INDEX_USAGE_STATS AS S 
       INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID] AND I.INDEX_ID = S.INDEX_ID 
WHERE  OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1
       AND S.database_id = DB_ID() 
ORDER BY USER_SEEKS, USER_SCANS,USER_LOOKUPS,USER_UPDATES




 SELECT  distinct 'USE [' + DB_NAME(database_id) + '];
CREATE INDEX indx_' + replace(replace(replace(replace
  (ISNULL(equality_columns, '')
  + ISNULL(inequality_columns, ''), ', ', '_')+ +'_'+ (CONVERT(VARCHAR(5),ROW_NUMBER() OVER (ORDER BY c.object_id ))),
  '[', ''), ']', ''), ' ', '') + '
  ON [' + schema_name(d.schema_id) + ']
  .[' + OBJECT_NAME(c.object_id) + ']
  (' + ISNULL(equality_columns, '') +
  CASE WHEN equality_columns IS NOT NULL
    AND c.inequality_columns IS NOT NULL THEN ', '
    ELSE '' END + ISNULL(inequality_columns, '') + ')
    ' + CASE WHEN included_columns IS NOT NULL THEN
    'INCLUDE (' + included_columns + ')' ELSE '' END + '
    WITH (FILLFACTOR=90, ONLINE=ON)'FROM sys.dm_db_missing_index_details c JOIN sys.objects d ON c.object_id = d.object_id
WHERE c.database_id = db_id('postilion_office')
  and 
  OBJECT_NAME(c.object_id) NOT IN ('post_tran', 'post_tran_cust')
  
   SELECT  'USE [' + DB_NAME(database_id) + '];
CREATE INDEX indx_' + replace(replace(replace(replace
  (ISNULL(equality_columns, '')
  + ISNULL(inequality_columns, ''), ', ', '_'),
  '[', ''), ']', ''), ' ', '') + '
  ON [' + schema_name(d.schema_id) + ']
  .[' + OBJECT_NAME(c.object_id) + ']
  (' + ISNULL(equality_columns, '') +
  CASE WHEN equality_columns IS NOT NULL
    AND c.inequality_columns IS NOT NULL THEN ', '
    ELSE '' END + ISNULL(inequality_columns, '') + ')
    ' + CASE WHEN included_columns IS NOT NULL THEN
    'INCLUDE (' + included_columns + ')' ELSE '' END + '
    WITH (FILLFACTOR=70, ONLINE=ON)',* FROM sys.dm_db_missing_index_details c JOIN sys.objects d ON c.object_id = d.object_id
WHERE c.database_id = db_id()
AND OBJECT_NAME( c.object_id) LIKE  'post_tran_summary%'
  


SELECT   OBJECT_NAME(S.[OBJECT_ID]) AS [OBJECT NAME], 
         I.[NAME] AS [INDEX NAME], 
         USER_SEEKS, 
         USER_SCANS, 
         USER_LOOKUPS, 
         USER_UPDATES 
FROM     SYS.DM_DB_INDEX_USAGE_STATS AS S 
         INNER JOIN SYS.INDEXES AS I 
           ON I.[OBJECT_ID] = S.[OBJECT_ID] 
              AND I.INDEX_ID = S.INDEX_ID 
WHERE    OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1 



SELECT dbschemas.[name] as 'Schema', 
dbtables.[name] as 'Table', 
dbindexes.[name] as 'Index',
indexstats.alloc_unit_type_desc,
indexstats.avg_fragmentation_in_percent,
indexstats.page_count
FROM sys.dm_db_index_physical_stats (DB_ID('postilion_office'), NULL, NULL, NULL, NULL) AS indexstats
INNER JOIN sys.tables dbtables on dbtables.[object_id] = indexstats.[object_id]
INNER JOIN sys.schemas dbschemas on dbtables.[schema_id] = dbschemas.[schema_id]
INNER JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID('postilion_office')
ORDER BY indexstats.avg_fragmentation_in_percent desc