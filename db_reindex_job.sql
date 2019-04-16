 -- Script generated on 7/24/2014 1:01 PM
 -- By: OFFICE3D\mobolaji.aina
 -- Server: (local)
 
 BEGIN TRANSACTION            
   DECLARE @JobID BINARY(16)  
   DECLARE @ReturnCode INT    
   SELECT @ReturnCode = 0     
 IF (SELECT COUNT(*) FROM msdb.dbo.syscategories WHERE name = N'[Uncategorized (Local)]') < 1 
   EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'
 
   -- Delete the job with the same name (if it exists)
   SELECT @JobID = job_id     
   FROM   msdb.dbo.sysjobs    
   WHERE (name = N'reindex_databases')       
   IF (@JobID IS NOT NULL)    
   BEGIN  
   -- Check if the job is a multi-server job  
   IF (EXISTS (SELECT  * 
               FROM    msdb.dbo.sysjobservers 
               WHERE   (job_id = @JobID) AND (server_id <> 0))) 
   BEGIN 
     -- There is, so abort the script 
     RAISERROR (N'Unable to import job ''reindex_databases'' since there is already a multi-server job with this name.', 16, 1) 
     GOTO QuitWithRollback  
   END 
   ELSE 
     -- Delete the [local] job 
     EXECUTE msdb.dbo.sp_delete_job @job_name = N'reindex_databases' 
     SELECT @JobID = NULL
   END 
 
 BEGIN 
 
   -- Add the job
   EXECUTE @ReturnCode = msdb.dbo.sp_add_job @job_id = @JobID OUTPUT , @job_name = N'reindex_databases', @owner_login_name = N'OFFICE3D\mobolaji.aina', @description = N'No description available.', @category_name = N'[Uncategorized (Local)]', @enabled = 1, @notify_level_email = 0, @notify_level_page = 0, @notify_level_netsend = 0, @notify_level_eventlog = 2, @delete_level= 0
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
 
   -- Add the job steps
   EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep @job_id = @JobID, @step_id = 1, @step_name = N'reindex_step', @command = N'USE postilion_office;
 
 exec reindex_databases @exception_list=null;
 ', @database_name = N'postilion_office', @server = N'', @database_user_name = N'', @subsystem = N'TSQL', @cmdexec_success_code = 0, @flags = 0, @retry_attempts = 0, @retry_interval = 1, @output_file_name = N'', @on_success_step_id = 0, @on_success_action = 1, @on_fail_step_id = 0, @on_fail_action = 2
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
   EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 
 
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
 
   -- Add the job schedules
   EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id = @JobID, @name = N'early_sundays', @enabled = 1, @freq_type = 8, @active_start_date = 20140724, @active_start_time = 90000, @freq_interval = 1, @freq_subday_type = 1, @freq_subday_interval = 0, @freq_relative_interval = 0, @freq_recurrence_factor = 1, @active_end_date = 99991231, @active_end_time = 235959
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
 
   -- Add the Target Servers
   EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
   IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
 
 END
 COMMIT TRANSACTION          
 GOTO   EndSave              
 QuitWithRollback:
   IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
 EndSave: 
 
 
