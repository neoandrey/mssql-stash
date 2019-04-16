USE postilion_office;
go
	create procedure usp_terminate_long_running_extracts @allowed_mins int
as begin

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

SET @allowed_mins = ISNULL (@allowed_mins, 180)
  
  IF( (SELECT COUNT(*) FROM post_process_queue WITH (NOLOCK) WHERE process_name = 'Extracts' AND DATEDIFF(MI,datetime_started, datetime_ended)>@allowed_mins) >0) BEGIN
		DECLARE @start_time DATETIME
		DECLARE @end_time DATETIME
		DECLARE @sql VARCHAR(MAX)
		DECLARE @process VARCHAR(1000)
		
		DECLARE process_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT spawned_name from post_process_queue WITH (NOLOCK) WHERE process_name = 'Extracts' AND DATEDIFF(MI,datetime_started, datetime_ended)>@allowed_mins;
		OPEN process_cursor
		FETCH NEXT FROM  process_cursor INTO @process
		
		WHILE (@@FETCH_STATUS =0)BEGIN
		 SET  @sql = 'exec master.dbo.xp_cmdshell ''TASKKILL /IM '+@process+' /F /T''' ;
		 EXEC(@sql)
		
		FETCH NEXT FROM  process_cursor INTO @process
		END
      CLOSE process_cursor
      DEALLOCATE process_cursor
      TRUNCATE TABLE extract_tran
  END
  
  END

  go


USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'terminate_long_running_extracts', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'officeadmin', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'terminate_long_running_extracts', @server_name = N'MEGAPORTAL64'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'terminate_long_running_extracts', @step_name=N'terminate', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  usp_terminate_long_running_extracts @allowed_mins= 90', 
		@database_name=N'postilion_office', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'terminate_long_running_extracts', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'officeadmin', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'terminate_long_running_extracts', @name=N'30mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20170713, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO
