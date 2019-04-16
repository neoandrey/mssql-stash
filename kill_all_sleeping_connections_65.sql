DECLARE @spidCount  INT;
DECLARE @counter  INT;
DECLARE @currentID INT;
DECLARE @loginame  VARCHAR(1000);

SET @counter  =1;
IF  (OBJECT_ID('tempdb.dbo.#TEMP_SPIDS') IS NOT NULL)
BEGIN
     DROP TABLE #TEMP_SPIDS;
END

SET @loginame = 'NT AUTHORITY\SYSTEM';
--SET @loginame = 'SET @loginame = 'SET @loginame = 'OFFICE5D32\Administrator';

SELECT SPID INTO #TEMP_SPIDS FROM master.dbo.sysprocesses WHERE STATUS = 'SLEEPING' AND  LOGINAME !=@loginame AND LOGINAME !='sa' AND LOGINAME !='OFFICE5D32\Administrator' AND LOGINAME !='OFFICE2011\Administrator'

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
END