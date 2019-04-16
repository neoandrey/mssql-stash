/****** Object:  StoredProcedure [dbo].[manage_connections]    Script Date: 10/02/2013 06:15:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER PROCEDURE [dbo].[manage_connections] (

		@databaseName VARCHAR(255),
		@loginName VARCHAR(255),
		@programName VARCHAR(255),
		@command VARCHAR(255),
	        @status VARCHAR(255),
	        @maxDurationInMins INT,
	        @cpuTime BIGINT,
	        @closeConnections INT,
	        @verbose INT


) AS BEGIN 

	DECLARE @databaseID INT
	DECLARE @maxConnectionTime INT
	DECLARE @connectionProcID INT
	--DECLARE @ProcessTable TABLE ( SPID INT )
	DECLARE @query NVARCHAR(500) 
	DECLARE @parameterDefinition NVARCHAR(500)
	DECLARE @processCount INT
	DECLARE @totalConnectionCount INT
	DECLARE @handle BINARY (500)
        DECLARE @tempQuery VARCHAR (8000)
        
	SELECT @databaseName = ISNULL(@databaseName, 'postilion_office')
	SELECT @loginName = ISNULL('%'+@loginName+'%', '%%')
	SELECT @programName = ISNULL('%'+@programName+'%', '%Microsoft SQL Server Management Studio%')
	SELECT @command = ISNULL('%'+@command+'%', '%AWAIT%')
	SELECT @status = ISNULL('%'+@status+'%', '%sleeping%')
	SELECT @maxDurationInMins = ISNULL(@maxDurationInMins, 0)
	SELECT @closeConnections = ISNULL(@closeConnections, 0)
	SELECT @cpuTime = ISNULL(@cpuTime,0)
	
    IF OBJECT_ID('tempdb.dbo.#ProcessTable') IS NOT NULL
	BEGIN
		DROP TABLE #ProcessTable;
	END	
	
	CREATE TABLE #ProcessTable (
			[spid] [smallint] NOT NULL ,
			[kpid] [smallint] NOT NULL ,
			[blocked] [smallint] NOT NULL ,
			[waittype] [binary] (2) NOT NULL ,
			[waittime] [int] NOT NULL ,
			[lastwaittype] [nchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[waitresource] [nchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[dbid] [smallint] NOT NULL ,
			[uid] [smallint] NOT NULL ,
			[cpu] [int] NOT NULL ,
			[physical_io] [bigint] NOT NULL ,
			[memusage] [int] NOT NULL ,
			[login_time] [datetime] NOT NULL ,
			[last_batch] [datetime] NOT NULL ,
			[ecid] [smallint] NOT NULL ,
			[open_tran] [smallint] NOT NULL ,
			[status] [nchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[sid] [binary] (86) NOT NULL ,
			[hostname] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[program_name] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[hostprocess] [nchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[cmd] [nchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[nt_domain] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[nt_username] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[net_address] [nchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[net_library] [nchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[loginame] [nchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
			[context_info] [binary] (128) NOT NULL ,
			[sql_handle] [binary] (20) NOT NULL ,
			[stmt_start] [int] NOT NULL ,
			[stmt_end] [int] NOT NULL,
			 sql_statement [text] null
)



	
INSERT INTO #ProcessTable(	
        [spid] ,
	[kpid] ,
	[blocked]  ,
	[waittype]  ,
	[waittime] ,
	[lastwaittype] ,
	[waitresource] ,
	[dbid] ,
	[uid] ,
	[cpu] ,
	[physical_io],
	[memusage] ,
	[login_time] ,
	[last_batch] ,
	[ecid] ,
	[open_tran] ,
	[status] ,
	[sid],
	[hostname] ,
	[program_name] ,
	[hostprocess] ,
	[cmd] ,
	[nt_domain] ,
	[nt_username] ,
	[net_address] ,
	[net_library] ,
	[loginame] ,
	[context_info] ,
	[sql_handle] ,
	[stmt_start]  ,
	[stmt_end] ,
    [sql_statement]
        )
    SELECT 	
        [spid] ,
	[kpid] ,
	[blocked]  ,
	[waittype]  ,
	[waittime] ,
	[lastwaittype] ,
	[waitresource] ,
	[dbid] ,
	[uid] ,
	[cpu] ,
	[physical_io],
	[memusage] ,
	[login_time] ,
	[last_batch] ,
	[ecid] ,
	[open_tran] ,
	[status] ,
	[sid],
	[hostname] ,
	[program_name] ,
	[hostprocess] ,
	[cmd] ,
	[nt_domain] ,
	[nt_username] ,
	[net_address] ,
	[net_library] ,
	[loginame] ,
	[context_info] ,
	[sql_handle] ,
	[stmt_start]  ,
	[stmt_end] ,
     null 
     FROM  
		master.dbo.sysprocesses
     WHERE loginame LIKE @loginName  AND cmd LIKE @command AND program_name LIKE  @programName AND status LIKE @status AND DATEDIFF(mi, last_batch, GETDATE()) >= @maxDurationInMins AND CPU >=@cpuTime;
	
	SELECT @processCount = COUNT(SPID) FROM #ProcessTable;

	SELECT @databaseID =dbid FROM #ProcessTable WHERE DB_NAME(dbid) LIKE  @databaseName;
	
	DECLARE spidCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT SPID FROM  #ProcessTable;
	DECLARE @processID INT;
	
	OPEN spidCursor
	FETCH NEXT FROM spidCursor INTO @processID
	
	WHILE (@@FETCH_STATUS =0)
		BEGIN
		SELECT @handle =  sql_handle FROM #ProcessTable WHERE spid = @processID
		SELECT @tempQuery =null;
		SELECT @tempQuery=text FROM ::fn_get_sql(@handle) 
		UPDATE #ProcessTable SET sql_statement =  @tempQuery  WHERE spid = @processID
		
		FETCH NEXT FROM spidCursor INTO @processID
	       END
	CLOSE spidCursor
	DEALLOCATE spidCursor
	
	

	IF(@databaseID IS NOT NULL AND @databaseID !='' AND  @processCount>0 )
	    BEGIN
			 IF(@verbose =1) 
			    BEGIN
                              SELECT * FROM #ProcessTable;
				--SELECT 
				--	  procs.spid
				--	, procs.blocked AS BLOCKING_PROCESS
				--	, DB_NAME(procs.dbid) AS DATABASE_NAME
				--	, right(convert(varchar, dateadd(ms, datediff(ms, procs.last_batch, getdate()), '1900-01-01'),121), 12) AS 'CMD'
				--	, procs.loginame AS LOGIN_NAME
				--	, procs.waittime AS WAIT_TIME
				--	, procs.memusage AS MEMORY_USAGE
				----	, procs.status   AS STATUS
				--	, CAST(text AS VARCHAR(1000)) AS SQL_QUERY
				--FROM #ProcessTable procs 
				--OUTER APPLY sys.dm_exec_sql_text (procs.sql_handle) 

			END
			
				SELECT @totalConnectionCount = COUNT(spid),@maxConnectionTime = MAX(DATEDIFF(ss, last_batch, GETDATE())) FROM #ProcessTable ;

					
				 IF (@verbose =1) 
				
						 BEGIN
				  
							SELECT  (CASE 
	 	WHEN  (DATEDIFF(ss, last_batch, getdate())/60.0)<=1 THEN CONVERT(VARCHAR(25),((DATEDIFF(ss, last_batch, getdate())/1000.0)))+' secs'
	 	WHEN (DATEDIFF(ss, last_batch, getdate()) /60.0)>1 AND (DATEDIFF(ss, last_batch, getdate()) /60.0)<=59 THEN CONVERT(VARCHAR(25),(DATEDIFF(ss, last_batch, getdate())/60))+' mins: '+CONVERT(VARCHAR(25),(DATEDIFF(ss, last_batch, getdate())% 60))+' secs '
	 	WHEN (DATEDIFF(ss, last_batch, getdate()) /3600.0)>1 AND (DATEDIFF(ss, last_batch, getdate()) /3600.0)<=24 THEN CONVERT(VARCHAR(25),(DATEDIFF(ss, last_batch, getdate())/3600))+' hr(s): '+(CONVERT(VARCHAR(25),(DATEDIFF(ss, last_batch, getdate()) % 3600)/60))+' mins: '+(CONVERT(VARCHAR(25),(DATEDIFF(ss, last_batch, getdate())% 3600)/60 % 60))+' secs '
	 	END ) AS 
	'connection_duration', *  FROM #ProcessTable;
					
						 END
						 
				 IF (@closeConnections =1) 
				
						 BEGIN
				                 SET @query= N'KILL @processID;';
				                 SET @parameterDefinition =  N'@processID INT';   
				         
						 DECLARE processCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT SPID FROM  #ProcessTable;
						 
						 OPEN processCursor;
						 
						 DECLARE @duration BIGINT;
						 
						 FETCH NEXT FROM processCursor INTO  @connectionProcID;
						 
						 WHILE @@FETCH_STATUS=0
						 BEGIN
						         SELECT @databaseName =DB_ID(dbid), @loginName =loginame, @status =status, @programName =[PROGRAM_NAME], @command=cmd,@duration= RIGHT(CONVERT(VARCHAR, DATEADD(ms, DATEDIFF(ms, last_batch, getdate()), '1900-01-01'),121), 12)  FROM  #ProcessTable WHERE SPID=@connectionProcID;
  								 PRINT 'CHAR(10)Stopping process with ID: '+ @connectionProcID+',  Database Name: '+@databaseName+', Status: '+@status+', Program Name: '+@programName+', CMD: '+@command+', Duration: '+@duration;
							     PRINT '--------------------------------------------------------------------------------------------------------------------'
						
						        EXEC sp_executesql @query, @parameterDefinition, @processID = @connectionProcID
							 
							FETCH NEXT FROM processCursor INTO  @connectionProcID;
							
						 END
						 CLOSE processCursor;
						 DEALLOCATE processCursor;
										
						 END		 

	END
		ELSE 
			BEGIN		
		
				PRINT 'There are currently NO connections';
			
			END
	
	END
	
IF OBJECT_ID('tempdb.dbo.#ProcessTable') IS NOT NULL
	BEGIN
		DROP TABLE #ProcessTable;
	END	

	
	SET NOCOUNT OFF;

	SET ANSI_NULLS ON;
GO


