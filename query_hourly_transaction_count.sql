USE postilion_office;

DECLARE @startTime DATETIME
DECLARE @endTime DATETIME
DECLARE @newTimeStart DATETIME
DECLARE @newTimeEnd DATETIME

SELECT @startTime = DATEDIFF(DAY,5,SYSUTCDATETIME())
SELECT @endTime = SYSUTCDATETIME()

SELECT @startTime, @endTime;
 IF OBJECT_ID('tempdb.dbo.#TEMP_DATA_TABLE') IS NOT NULL
	BEGIN
		DROP TABLE #TEMP_DATA_TABLE

	END
                        
SELECT @newTimeStart =  @startTime                     
SELECT @newTimeEnd =  DATEADD(HOUR,1,@startTime)

WHILE (@newTimeStart < @endTime)

	BEGIN
         	SELECT @newTimeStart AS START_TIME, @newTimeEnd AS END_TIME,COUNT(a.post_tran_cust_id) AS TRANSACTION_COUNT INTO #TEMP_DATA_TABLE FROM dbo.post_tran a (NOLOCK),dbo.post_tran_cust b (NOLOCK)
         	                   WHERE a.post_tran_cust_id = b.post_tran_cust_id
						AND datetime_tran_gmt BETWEEN @newTimeStart and @newTimeEnd
						
	SELECT @newTimeStart =  @newTimeEnd                     
        SELECT @newTimeEnd =  DATEADD(HOUR,1,@newTimeStart)
					
	END
	
IF OBJECT_ID('tempdb.dbo.#TEMP_DATA_TABLE') IS NOT NULL
				     BEGIN
 DROP TABLE #TEMP_DATA_TABLE;
END	
