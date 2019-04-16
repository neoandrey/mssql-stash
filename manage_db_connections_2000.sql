USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[manage_db_connections]    Script Date: 10/02/2013 06:15:23 ******/
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'[dbo].[manage_db_connections]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[manage_db_connections]
GO

USE [postilion_office]
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

	DECLARE @databaseID INT;
	DECLARE @totalConnectionCount INT;
	DECLARE @maxConnectionTime INT;
	DECLARE @connectionProcID INT;
	DECLARE @processTable TABLE ( PROCESS_ID INT );
	DECLARE @query NVARCHAR(500);
        DECLARE @processCount INT;


    DECLARE @parameterDefinition NVARCHAR(500);
    
	SELECT @databaseID =dbid FROM sysprocesses WHERE DB_NAME(dbid) =  @databaseName AND LOGINAME=@loginName;

	 IF(@databaseID IS NOT NULL AND @databaseID !='')
	    BEGIN

			 IF(@verbose =1) 
			    BEGIN


                        SET @query= N'SELECT TOP @maxAllowedConnections  SPID FROM sysprocesses WHERE dbid=  @databaseID  AND LOGINAME=@loginName ORDER BY login_time DESC;';
		        SET @parameterDefinition =  N'@databaseID INT,@maxAllowedConnections INT, @loginName VARCHAR(1000)';
			 EXEC sp_executesql @query, @parameterDefinition, @databaseID = @connectionProcID
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
					--, (SELECT CAST(text AS VARCHAR(1000)) FROM fn_get_sql(sql_handle))  AS SQL_QUERY_2

				FROM sysprocesses procs 
				WHERE procs.dbid=  @databaseID  AND LOGINAME=@loginName;


			END
		IF((@loginName IS NOT NULL AND @loginName !='') AND ((@maxAllowedConnections IS NOT NULL AND @maxAllowedConnections !='') AND (@maxDurationInMins IS NOT NULL AND @maxDurationInMins !='')))
			BEGIN
			
				SELECT @totalConnectionCount = COUNT(spid),@maxConnectionTime = MAX(DATEDIFF(mi, last_batch, GETDATE())) FROM sysprocesses WHERE dbid=  @databaseID  AND LOGINAME=@loginName;
				
				IF(@verbose =1) 
			    		BEGIN
						SELECT @databaseName AS DATABASE_NAME, @totalConnectionCount AS TOTAl_CONNECTION_COUNT, @maxConnectionTime AS MAX_CONN_TIME_MINS;
					END
					
				INSERT INTO @processTable 
				SELECT  SPID FROM sysprocesses WHERE DATEDIFF(mi, last_batch, GETDATE()) >= @maxDurationInMins AND dbid=  @databaseID  AND LOGINAME=@loginName  ORDER BY SPID DESC
				 IF (@verbose =1) 
				
						 BEGIN
				  
							SELECT right(CONVERT(VARCHAR, DATEADD(ms, DATEDIFF(ms, last_batch, getdate()), '1900-01-01'),121), 12) AS 'CONNECTION_DURATION', * FROM sysprocesses WHERE spid IN (SELECT PROCESS_ID FROM @processTable);
					
						 END
				 IF (@closeExtraConnections =1) 
				
						 BEGIN
				         SET @query= N'KILL @processID;';
				         SET @parameterDefinition =  N'@processID INT';
					 SET @processCount =0;
				         
						 DECLARE processCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT PROCESS_ID FROM  @processTable ORDER BY PROCESS_ID DESC;
						 
						 OPEN processCursor;
						 
						 FETCH NEXT FROM processCursor INTO  @connectionProcID;
						 
						 WHILE @@FETCH_STATUS=0
						 BEGIN

 						SET @processCount = @processCount+1;

					        IF (@processCount >@maxAllowedConnections)
							 BEGIN
							
								 EXEC sp_executesql @query, @parameterDefinition, @processID = @connectionProcID
								 
								 FETCH NEXT FROM processCursor INTO  @connectionProcID;
							END
							
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


