set ANSI_NULLS ON
set QUOTED_IDENTIFIER ON
go


ALTER PROCEDURE [dbo].[stop_n_rerun_hanging_reports](@run_date DATETIME,@minutes_delay INT)
AS

BEGIN

	DECLARE @job_name VARCHAR(300);
	DECLARE @step_name VARCHAR(300);
    SET @run_date =  ISNULL(@run_date,GETDATE() );
	SET @run_date = REPLACE(CONVERT(VARCHAR(10), @run_date,111),'/', '');
    SET @minutes_delay = ISNULL(@minutes_delay,10);
	SET @minutes_delay =  REPLICATE('0',2-LEN(@minutes_delay))+@minutes_delay;
	
IF (OBJECT_ID('tempdb.dbo.#temp_process_run') IS NOT NULL)
	BEGIN
         DROP TABLE #temp_process_run
	END 

IF (OBJECT_ID('tempdb.dbo.#temp_process_run_2') IS NOT NULL)
	BEGIN
         DROP TABLE #temp_process_run
	END 
   
	DECLARE @process_entity VARCHAR(80);
    DECLARE @spawed_process VARCHAR(80);
	DECLARE @cmd_command NVARCHAR(200);

	SET @run_date =  ISNULL(@run_date,GETDATE() );
	SET @run_date = REPLACE(CONVERT(VARCHAR(10), @run_date,111),'/', '-');

   SELECT process_entity, spawned_name INTO  #temp_process_run FROM post_process_queue WHERE process_name = 'Reports' AND queue_state=20 AND DATEDIFF(MINUTE,@run_date,GETDATE())>=2 AND LEFT(CONVERT(VARCHAR(10),datetime_started, 112),10)>=@run_date
   
	IF (OBJECT_ID('tempdb.dbo.#temp_process_run') IS NOT NULL)
		BEGIN
			INSERT INTO #temp_process_run (process_entity, spawned_name )
         	SELECT process_entity, spawned_name FROM msdb.dbo.sysjobs jobs, msdb.dbo.sysjobsteps steps,(
			SELECT process_entity, spawned_name FROM post_process_queue		
			WHERE 
            DATEDIFF(HH, datetime_queued,GETDATE()) >=2 AND process_name ='Reports' AND queue_state =30
           ) reports
          WHERE steps.job_id =jobs.job_id AND jobs.enabled =1 AND steps.step_name =reports.process_entity 
	END
	DECLARE process_entity_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT  spawned_name  FROM #temp_process_run

	OPEN process_entity_cursor;

	FETCH NEXT FROM process_entity_cursor INTO @spawed_process;

	WHILE (@@FETCH_STATUS=0)BEGIN  
		PRINT 'Stoping report: '+@spawed_process+CHAR(10);
		SET @cmd_command = 'master.dbo.xp_cmdshell ''taskkill /im '+@spawed_process+' /t /f''';
		EXEC (@cmd_command);
		FETCH NEXT FROM process_entity_cursor INTO @spawed_process;

	END

	CLOSE process_entity_cursor
    DEALLOCATE process_entity_cursor

	DECLARE report_job_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT  process_entity  FROM #temp_process_run

	OPEN report_job_cursor;

	FETCH NEXT FROM report_job_cursor INTO @step_name;

	WHILE (@@FETCH_STATUS=0)BEGIN
	    PRINT 'Starting Report: '+@step_name+CHAR(10);
		SET @cmd_command = 'master.dbo.xp_cmdshell "C:\postilion\Office\base\bin\run_office_process.cmd Reports ' +@step_name+'"';
		EXEC (@cmd_command);
      	WAITFOR DELAY @minutes_delay;
		FETCH NEXT FROM report_job_cursor INTO @step_name;

	END

	CLOSE report_job_cursor

 DEALLOCATE report_job_cursor


IF (OBJECT_ID('tempdb.dbo.#temp_process_run') IS NOT NULL)
	BEGIN
         DROP TABLE #temp_process_run
	END 

	
END


--[stop_n_rerun_hanging_reports] null,null
