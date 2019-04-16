DECLARE @run_date VARCHAR(12);

DECLARE @job_name VARCHAR(300);

--SET @run_date =  DATEADD(D, -1, DATEDIFF(D, 0, GETDATE());
SET @run_date = '20141025';
--SELECT name FROM msdb.dbo.sysjobs WHERE last_run_date  = @run_date
DECLARE @job_id_table TABLE (job_id VARCHAR(80))
INSERT INTO @job_id_table (job_id)
SELECT job_id FROM msdb.dbo.sysjobsteps WHERE step_name IN( SELECT process_entity FROM postilion_office.dbo.post_process_run WHERE process_name
 LIKE 'Reports' AND result_value =0 AND LEFT(CONVERT(VARCHAR(10),datetime_begin, 112),10)>='20141025')AND last_run_date >='20141025'
INSERT INTO @job_id_table (job_id)
SELECT jobs.job_id FROM msdb.dbo.sysjobsteps steps, msdb.dbo.sysjobs jobs WHERE jobs.job_id =steps.job_id AND last_run_date ='20141025' AND LEFT(name,26)= 'Postilion OFFICE - Reports'
and jobs.job_id NOT IN (SELECT job_id FROM @job_id_table)

DECLARE report_job_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT [name] FROM msdb.dbo.sysjobs WHERE job_id IN (SELECT job_id FROM @job_id_table)
OPEN report_job_cursor;

FETCH NEXT FROM report_job_cursor INTO @job_name;

WHILE (@@FETCH_STATUS=0)BEGIN
   PRINT 'Starting Job: '''+@job_name+''''+CHAR(10);
	EXEC (N'msdb.dbo.sp_start_job  '''+@job_name+'''');
	
	WAITFOR DELAY '00:06:00'
	FETCH NEXT FROM report_job_cursor INTO @job_name;

END

CLOSE report_job_cursor

DEALLOCATE report_job_cursor