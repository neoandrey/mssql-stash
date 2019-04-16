ALTER PROCEDURE rerun_all_unsuccessful_reports_for_date(@run_date DATETIME, @minutes_delay INT)

AS

BEGIN

	DECLARE @job_name VARCHAR(300);
    SET @run_date =  ISNULL(@run_date,GETDATE() );
	DECLARE @report_name VARCHAR(300);
	DECLARE @cmd_command NVARCHAR(200);
	SET @run_date = REPLACE(CONVERT(VARCHAR(10), @run_date,112),'/', '');
	SET @minutes_delay = ISNULL(@minutes_delay,10);
	SET @minutes_delay =  REPLICATE('0',2-LEN(@minutes_delay))+@minutes_delay;
	
   SELECT @run_date;
	IF  (OBJECT_ID('tempdb.dbo.#temp_reports_procs') IS NOT NULL) BEGIN
	
	DROP TABLE #temp_reports_procs
	
	END
	IF (OBJECT_ID('tempdb.dbo.#temp_reports_procs_2') IS NOT NULL) BEGIN
	
	DROP TABLE #temp_reports_procs_2
	
	END
	
	SELECT DISTINCT process_entity INTO #temp_reports_procs  FROM postilion_office.dbo.post_process_run WHERE process_run_id  IN ( 
	
	   SELECT process_run_id  FROM postilion_office.dbo.post_process_run_phase  WHERE  (result_value<> 10  AND  result_value<> 20)
	        AND name = 'Schedule Reports' AND LEFT(CONVERT(VARCHAR(10),datetime_begin, 112),10)>=@run_date
	   )
	

   DECLARE process_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT  process_entity  FROM #temp_reports_procs

	OPEN process_cursor;

	FETCH NEXT FROM process_cursor INTO @report_name;

	WHILE (@@FETCH_STATUS=0)BEGIN
	    PRINT 'Starting Report: '+@report_name+CHAR(10);
		SET @cmd_command = 'master.dbo.xp_cmdshell "C:\postilion\Office\base\bin\run_office_process.cmd Reports ' +@report_name+'"';
print @cmd_command+CHAR(10);
		EXEC (@cmd_command);
      	WAITFOR DELAY @minutes_delay;
		FETCH NEXT FROM process_cursor INTO @report_name;

	END

	CLOSE process_cursor

 DEALLOCATE process_cursor

	
	
	IF  (OBJECT_ID('tempdb.dbo.#temp_reports_procs') IS NOT NULL) BEGIN
	
	DROP TABLE #temp_reports_procs
	
	END
	IF (OBJECT_ID('tempdb.dbo.#temp_reports_procs_2') IS NOT NULL) BEGIN
	
	DROP TABLE #temp_reports_procs_2
	
	END

END

--rerun_all_unsuccessful_reports_for_date null, 2