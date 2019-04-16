
SELECT process_entity INTO #temp_reports_procs  FROM postilion_office.dbo.post_process_run WHERE process_run_id  IN ( 

   SELECT process_run_id  FROM postilion_office.dbo.post_process_run_phase  WHERE  (result_value<> 10  AND  result_value<> 20)
        AND name = 'Schedule Reports' AND LEFT(CONVERT(VARCHAR(10),datetime_begin, 112),10)>='20141103'
   )

SELECT DISTINCT  [name], step_name INTO #temp_reports_procs_2 FROM msdb.dbo.sysjobs jobs, msdb.dbo.sysjobsteps steps WHERE  jobs.job_id =steps.job_id 
AND step_name IN (SELECT process_entity FROM #temp_reports_procs)
AND jobs.enabled  =1

SELECT * FROM #temp_reports_procs_2

DROP TABLE #temp_reports_procs
DROP TABLE #temp_reports_procs_2
