CREATE TABLE #fragmention_check(
	ObjectName  VARCHAR(255),
	ObjectId      BIGINT,
	IndexName  VARCHAR(255),
	IndexId  BIGINT,
	[Level]  BIGINT,
	Pages  BIGINT,
	[Rows]  BIGINT,
	MinimumRecordSize  BIGINT,
	MaximumRecordSize  BIGINT,
	AverageRecordSize  BIGINT,
	ForwardedRecords  BIGINT,
	Extents  BIGINT,
	ExtentSwitches  BIGINT,
	AverageFreeBytes  BIGINT,
	AveragePageDensity  BIGINT,
	ScanDensity  BIGINT,
	BestCount  BIGINT,
	ActualCount  BIGINT,
	LogicalFragmentation  FLOAT,
	ExtentFragmentation   FLOAT

)


INSERT INTO #fragmention_check (ObjectName,ObjectId,IndexName,IndexId,Level,Pages,Rows,MinimumRecordSize,MaximumRecordSize,AverageRecordSize,ForwardedRecords,Extents,ExtentSwitches,AverageFreeBytes,AveragePageDensity,ScanDensity,BestCount,ActualCount,LogicalFragmentation,ExtentFragmentation
) EXEC sp_MsforEachtable @command1 ='DBCC SHOWCONTIG (''?'') WITH FAST, TABLERESULTS, ALL_INDEXES, NO_INFOMSGS;'

DECLARE @objectName VARCHAR(30), @indexName VARCHAR(30), @logicalfragmentation VARCHAR(30);
DECLARE @query VARCHAR(4000);
DECLARE @database varchar(20);

SET @database ='postilion_office'

DECLARE defrag_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT objectName, indexName, logicalfragmentation from #fragmention_check where logicalfragmentation > 0
OPEN defrag_cursor;
FETCH NEXT FROM  defrag_cursor INTO @objectName, @indexName, @logicalfragmentation;
WHILE (@@FETCH_STATUS=0)BEGIN
SET @query='DBCC INDEXDEFRAG ('''+@database+''', '''+@objectName+''','''+@indexName+''')';
EXEC (@query);

FETCH NEXT FROM  defrag_cursor INTO @objectName, @indexName, @logicalfragmentation;
END
CLOSE defrag_cursor;
DEALLOCATE defrag_cursor;


