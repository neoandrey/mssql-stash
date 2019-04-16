IF (  object_id('tempdb.dbo.#temp_table_spaces') is not null)BEGIN
         DROP TABLE #temp_table_spaces
END

SELECT 
 t.NAME AS TableName,
 i.name AS indexName,
 SUM(p.rows) AS RowCounts,
 SUM(a.total_pages) AS TotalPages, 
 SUM(a.used_pages) AS UsedPages, 
 SUM(a.data_pages) AS DataPages,
 (SUM(a.total_pages) * 8) / 1024 AS TotalSpaceMB, 
 (SUM(a.used_pages) * 8) / 1024 AS UsedSpaceMB, 
 (SUM(a.data_pages) * 8) / 1024 AS DataSpaceMB
 INTO #temp_table_spaces
FROM 
 sys.tables t
INNER JOIN  
 sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN 
 sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN 
 sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
 t.NAME NOT LIKE 'dt%' AND
 i.OBJECT_ID > 255 AND  
 i.index_id <= 1
GROUP BY 
 t.NAME, i.object_id, i.index_id, i.name 
ORDER BY 
 OBJECT_NAME(i.object_id) 
 

 SELECT * FROM #temp_table_spaces order by UsedSpaceMB DESC
 
 
 
 http://172.25.20.56:9080/api/v1/loyalty/redemption