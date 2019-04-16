-- select  'exec master.dbo.xp_cmdshell ''TASKKILL /IM '+spawned_name+' /F /T''' as kill_command, 'exec master.dbo.xp_cmdshell ''C:\postilion\Office\base\bin\run_office_process.cmd Reports '+process_entity+'''; waitfor delay ''00:02:00'';' as start_command,   * from post_process_queue where process_name ='Reports'

 
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - ABP'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - CHB'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - CITI'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - CUP_2'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - DBL'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - EBN'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - FBN'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - FBP'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - FCMB';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - GTB'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 
 
 
 
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - GTBSL'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - HBC'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - PHB';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';;
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - SBP';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - SCB';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - SKYE'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - SPR';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - SWT'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
  EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - UBN'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
  EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - UBP'; WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 )WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
  EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - WEMA';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
  EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - UBA1';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 EXEC msdb.dbo.sp_start_job @job_name ='Postilion Office - Reports - ZIB';WHILE ((SELECT COUNT(*) FROM post_process_queue)>10 ) WAITFOR DELAY '00:01:00'; WAITFOR DELAY '00:01:00';
 
 
 