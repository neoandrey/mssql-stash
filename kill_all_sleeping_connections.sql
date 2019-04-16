DECLARE @spidCount  INT;
DECLARE @counter  INT;
DECLARE @currentID INT;

SET @counter  =1;
IF  (OBJECT_ID('tempdb.dbo.#TEMP_SPIDS') IS NOT NULL)
BEGIN
     DROP TABLE #TEMP_SPIDS;
END

SELECT SPID INTO #TEMP_SPIDS FROM master.dbo.sysprocesses WHERE STATUS = 'SLEEPING' AND  LOGINAME !='NT AUTHORITY\SYSTEM' AND    LOGINAME !='sa'
SELECT @spidCount  = COUNT(SPID) FROM #TEMP_SPIDS 

WHILE (@counter <=@spidCount   )
			BEGIN 

				SET @currentID = (SELECT TOP 1 SPID FROM #TEMP_SPIDS);
				EXEC ('KILL '+@currentID);
				PRINT 'Terminating process with ID: '+CONVERT(VARCHAR(4000),@currentID)+CHAR(10);
				DELETE FROM #TEMP_SPIDS WHERE SPID =@currentID;
			SET @counter =@counter+1;

END

IF  ( OBJECT_ID('tempdb.dbo.#TEMP_SPIDS') IS NOT NULL) 
BEGIN
     DROP TABLE #TEMP_SPIDS;
ENDKK