SELECT distinct s.step_name,  'exec master.dbo.xp_cmdshell '''+command+'''  WHILE ((SELECT COUNT(*) FROM post_process_queue WITH (nolock) WHERE process_name= ''Reports'')>10)  WAITFOR DELAY ''00:00:45'';'  FROM  MSDB.DBO.sysjobs j
 join MSDB.DBO.sysjobhistory h
  on
 j.job_id =h.job_id  
 join MSDB.DBO.sysjobsteps s
 on j.job_id = s.job_id
and s.command LIKE '%REPORTS%'
AND S.step_name not in ('check_norm_staus','(Job outcome)','get_file_size_details') 
and last_run_date !=0