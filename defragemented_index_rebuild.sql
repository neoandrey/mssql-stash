USE postilion_office

GO

 

DECLARE @tsql NVARCHAR(MAX)  

DECLARE @fillfactor INT

 

SET @fillfactor = 70 

 

DECLARE @FragmentedIndexs TABLE (IndexID INT,

                                 IndexName VARCHAR(100),

                                 ObjectName VARCHAR(100),

                                 AvgFragmentationInPercent DECIMAL(6,2),

                                 FragmentCount INT,

                                 AvgFragmentSizeInPage DECIMAL(6,2),

                                 IndexDepth INT)

 

--Insert the Details for Fragmented Indexes.

INSERT INTO @FragmentedIndexs

SELECT 

  PS.index_id,

  QUOTENAME(I.name) Name,

  QUOTENAME(DB_NAME()) +'.'+ QUOTENAME(OBJECT_SCHEMA_NAME(I.[object_id])) + '.' + QUOTENAME(OBJECT_NAME(I.[object_id])) ObjectName,

  PS.avg_fragmentation_in_percent,

  PS.fragment_count,

  PS.avg_fragment_size_in_pages,

  PS.index_depth

FROM 

  sys.dm_db_index_physical_stats (NULL, NULL ,NULL, NULL, NULL) AS PS

INNER JOIN sys.indexes AS I 

  ON PS.[object_id]= I.[object_id]

  AND PS.index_id = I.index_id

WHERE

  PS.avg_fragmentation_in_percent > 5  

ORDER BY 

  PS.avg_fragmentation_in_percent DESC

 

--Select the details.

SELECT * FROM @FragmentedIndexs

 

--Prepare the Query to REORGANIZE the Indexes

SET @tsql = ''

 

SELECT @tsql = 

  STUFF(( SELECT DISTINCT 

           ';' + 'ALTER INDEX ' + FI.IndexName + ' ON ' + FI.ObjectName + ' REORGANIZE '

          FROM 

           @FragmentedIndexs FI

          WHERE

            FI.AvgFragmentationInPercent <= 30

          FOR XML PATH('')), 1,1,'')

  

SELECT @tsql

PRINT 'REORGANIZING START'

EXEC sp_executesql @tsql 

PRINT 'REORGANIZING END'

 

--Prepare the Query to REBUILD the Indexes

SET @tsql = ''

 

SELECT @tsql = 

  STUFF(( SELECT DISTINCT 

           ';' + 'ALTER INDEX ' + FI.IndexName + ' ON ' + FI.ObjectName + ' REBUILD WITH (FILLFACTOR = ' + CONVERT(VARCHAR(3),@fillfactor) + ') '

          FROM 

           @FragmentedIndexs FI

          WHERE

            FI.AvgFragmentationInPercent > 30

          FOR XML PATH('')), 1,1,'')

  

SELECT @tsql

PRINT 'REBUILD START'

EXEC sp_executesql @tsql

PRINT 'REBUILD END'