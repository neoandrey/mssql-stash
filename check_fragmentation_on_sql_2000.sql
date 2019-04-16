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

SELECT * FROM #fragmention_check;