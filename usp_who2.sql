USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_who2]    Script Date: 11/03/2014 16:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



--usp_who2 1
ALTER   PROCEDURE [dbo].[usp_who2]  @show_deadlocks_only BIT 

AS

BEGIN

IF (OBJECT_ID('#process_map') IS NOT NULL)
BEGIN
	DROP TABLE #process_map
END

IF (OBJECT_ID('#temp_process_table') IS NOT NULL)
BEGIN
	DROP TABLE #temp_process_table
END


IF (OBJECT_ID('#temp_process_table_2') IS NOT NULL)
BEGIN
	DROP TABLE #temp_process_table_2
END

IF (OBJECT_ID('#temp_process_data') IS NOT NULL)
BEGIN
	DROP TABLE #temp_process_data
END
CREATE TABLE #temp_process_table (
	spid  INT, 
	blocked INT,
	kpid INT, 
	dbname VARCHAR(50),
	cpu BIGINT,
	status  VARCHAR(250),
	physical_io BIGINT,
	memusage BIGINT, 
	login_time DATETIME, 
	 last_batch DATETIME,
	duration_secs BIGINT, 
	loginame VARCHAR (250),
	 hostname VARCHAR (250), 
	program_name VARCHAR (250),
	cmd VARCHAR (250),
	 sql_handle VARBINARY (4000)

)


IF (@show_deadlocks_only =1)
    BEGIN
	INSERT INTO  #temp_process_table SELECT spid, blocked,kpid, db_name(dbid) AS dbname,cpu,status,physical_io,memusage, login_time, last_batch,DATEDIFF(S, last_batch, GETDATE()) AS duration_secs, loginame, hostname, program_name,cmd, sql_handle FROM master.dbo.sysprocesses WHERE blocked !=0 AND blocked = spid
  END  
  ELSE  BEGIN
   INSERT INTO  #temp_process_table SELECT spid, blocked,kpid, db_name(dbid) AS dbname,cpu,status,physical_io,memusage, login_time, last_batch,DATEDIFF(S, last_batch, GETDATE()) AS duration_secs, loginame, hostname, program_name,cmd, sql_handle FROM master.dbo.sysprocesses WHERE blocked !=0
END

CREATE TABLE #process_map (spid int, query_details varchar (4000));

DECLARE @processID INT
DECLARE @process VARCHAR(4000)
		IF (OBJECT_ID('#temp_process_data') IS NOT NULL)
		BEGIN
		DROP TABLE #temp_process_data
		END
CREATE TABLE #temp_process_data(eventtype nvarchar(30), parameters int, eventinfo nvarchar(4000));

DECLARE spid_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT spid FROM  #temp_process_table UNION SELECT blocked FROM #temp_process_table;

OPEN spid_cursor
FETCH NEXT FROM spid_cursor INTO @processID
WHILE (@@FETCH_STATUS =0) 
 BEGIN


INSERT INTO #temp_process_data  (EventType, Parameters, EventInfo)  EXEC ('DBCC INPUTBUFFER('+@processID+')');

SELECT @process= EventInfo FROM #temp_process_data 
INSERT INTO #process_map select @processID,@process

FETCH NEXT FROM spid_cursor INTO @processID

END
CLOSE spid_cursor
DEALLOCATE spid_cursor


SELECT  procs.spid, blocked,kpid, dbname, maps.query_details as 'running_query_details',bmaps.query_details as 'blocked_query_details', cpu,status,physical_io,memusage, login_time, last_batch, duration_secs, loginame, hostname, program_name,cmd, sql_handle FROM #temp_process_table procs JOIN #process_map maps ON procs.spid = maps.spid JOIN #process_map bmaps ON procs.spid = bmaps.spid 
DROP TABLE #temp_process_data
DROP TABLE #temp_process_table
DROP TABLE #process_map
END





