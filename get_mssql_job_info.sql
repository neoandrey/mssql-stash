SELECT * FROM [msdb].dbo.sysjobhistory his,[msdb].dbo.sysjobs jobs, [msdb].dbo.sysjobschedules sch,[msdb].dbo.sysjobsteps steps,[msdb].dbo.sysjobservers serv  WHERE 
								his.job_id = jobs.job_id AND sch.job_id  = jobs.job_id AND steps.job_id  = jobs.job_id 
								AND serv.job_id  = jobs.job_id AND jobs.[name] LIKE '%nor%';