USE [AdventureWorksDW2008R2]
GO

/****** Object:  StoredProcedure [dbo].[manage_db_connections]    Script Date: 10/02/2013 06:15:23 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[manage_db_connections]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[manage_db_connections]
GO

USE [AdventureWorksDW2008R2]
GO

/****** Object:  StoredProcedure [dbo].[manage_db_connections]    Script Date: 10/02/2013 06:15:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[manage_db_connections] (

		@databaseName VARCHAR(255),
		@loginName VARCHAR(255),
		@maxAllowedConnections INT,
        @maxDurationInMins INT,
        @closeExtraConnections INT,
        @verbose INT


) AS BEGIN 

	DECLARE @databaseID INT =NULL;
	DECLARE @totalConnectionCount INT =NULL;
	DECLARE @maxConnectionTime INT= NULL;
	DECLARE @connectionProcID INT= NULL;
	DECLARE @processTable TABLE ( PROCESS_ID INT );
	DECLARE @query NVARCHAR(500) =NULL;
    DECLARE @parameterDefinition NVARCHAR(500) =0;
    
	SELECT @databaseID =dbid FROM sys.sysprocesses WHERE DB_NAME(dbid) =  @databaseName AND LOGINAME=@loginName;

	 IF(@databaseID IS NOT NULL AND @databaseID !='')
	    BEGIN
			 IF(@verbose =1) 
			    BEGIN

				SELECT 
					  procs.spid
					, procs.blocked AS BLOCKING_PROCESS
					, DB_NAME(procs.dbid) AS DATABASE_NAME
					, right(convert(varchar, dateadd(ms, datediff(ms, procs.last_batch, getdate()), '1900-01-01'),121), 12) AS 'CONNECTION_DURATION'
					, procs.loginame AS LOGIN_NAME
					, procs.waittime AS WAIT_TIME
					, procs.memusage AS MEMORY_USAGE
					, procs.status   AS STATUS
					, CAST(text AS VARCHAR(1000)) AS SQL_QUERY

				FROM sys.sysprocesses procs 
				OUTER APPLY sys.dm_exec_sql_text (procs.sql_handle) WHERE procs.dbid=  @databaseID  AND LOGINAME=@loginName;


			END
		IF((@loginName IS NOT NULL AND @loginName !='') AND ((@maxAllowedConnections IS NOT NULL AND @maxAllowedConnections !='') AND (@maxDurationInMins IS NOT NULL AND @maxDurationInMins !='')))
			BEGIN
			
				SELECT @totalConnectionCount = COUNT(spid),@maxConnectionTime = MAX(DATEDIFF(mi, last_batch, GETDATE())) FROM sys.sysprocesses WHERE dbid=  @databaseID  AND LOGINAME=@loginName;
				
				IF(@verbose =1) 
			    		BEGIN
						SELECT @databaseName AS DATABASE_NAME, @totalConnectionCount AS TOTAl_CONNECTION_COUNT, @maxConnectionTime AS MAX_CONN_TIME_MINS;
					END
					
				INSERT INTO @processTable 
				SELECT  SPID FROM sys.sysprocesses WHERE DATEDIFF(mi, last_batch, GETDATE()) >= @maxDurationInMins AND dbid=  @databaseID  AND LOGINAME=@loginName AND SPID NOT IN (
					SELECT TOP (@maxAllowedConnections)  SPID FROM sys.sysprocesses WHERE dbid=  @databaseID  AND LOGINAME=@loginName ORDER BY login_time DESC
				 );
				 IF (@verbose =1) 
				
						 BEGIN
				  
							SELECT right(CONVERT(VARCHAR, DATEADD(ms, DATEDIFF(ms, last_batch, getdate()), '1900-01-01'),121), 12) AS 'CONNECTION_DURATION', * FROM sys.sysprocesses WHERE spid IN (SELECT PROCESS_ID FROM @processTable);
					
						 END
				 IF (@closeExtraConnections =1) 
				
						 BEGIN
				         SET @query= N'KILL @processID;';
				         SET @parameterDefinition =  N'@processID INT';
				         
						 DECLARE processCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT PROCESS_ID FROM  @processTable;
						 
						 OPEN processCursor;
						 
						 FETCH NEXT FROM processCursor INTO  @connectionProcID;
						 
						 WHILE @@FETCH_STATUS=0
						 BEGIN
						
							 EXEC sp_executesql @query, @parameterDefinition, @processID = @connectionProcID
							 
							 FETCH NEXT FROM processCursor INTO  @connectionProcID;
							
						 END
						 CLOSE processCursor;
						 DEALLOCATE processCursor;
						
					
						 END		 
			
			END

	END
		ELSE 
			BEGIN		
			
				PRINT 'There are currently NO connections';
				PRINT CHAR(10)+'TO: '+@databaseName;
				PRINT CHAR(10)+'FROM: '+@loginName;
			
			END
	
	END
	
	
	SET NOCOUNT OFF;

	SET ANSI_NULLS ON;
GO


