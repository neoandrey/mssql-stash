SELECT * FROM msdb.dbo.sysjobs jobs, msdb.dbo.sysjobsteps steps WHERE jobs.job_id = steps.job_id AND CHARINDEX('CardProduction',jobs.name)>1;


SELECT command,* FROM msdb.dbo.sysjobsteps WHERE  CHARINDEX('CardProduction',step_name)>1;

UPDATE msdb.dbo.sysjobsteps SET command =REPLACE(command, 'percentage=50', 'percentage=10')  WHERE  CHARINDEX('CardProduction',step_name)>1;