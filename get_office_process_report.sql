DECLARE @startDate DATETIME
DECLARE @endDate DATETIME

SET @startDate = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-')  ;
SET @endDate = GETDATE() ;

SELECT count_table.process_name, result_value,   result_total,  process_total,   CONVERT(FLOAT,result_total )/CONVERT(FLOAT,process_total )*100.0  'percentage' FROM 
(SELECT  
process_name, 
CASE result_value
WHEN 0 THEN 'UNKNOWN'
WHEN 10 THEN 'SUCCESS'
WHEN 20 THEN 'WARNING'
WHEN 30 THEN 'FAILURE'
WHEN 40 THEN 'CRASH'
END AS result_value,
COUNT(result_value) result_total
FROM dbo.post_process_run (nolock) 
 WHERE process_name IN('Settlement','Normalization','Extract','Reports')  AND datetime_begin BETWEEN @startDate AND @endDate GROUP BY process_name,result_value
) count_table
,(SELECT process_name,COUNT(process_name)as process_total FROM dbo.post_process_run (nolock) WHERE process_name IN('Settlement','Normalization','Extract','Reports') AND datetime_begin BETWEEN @startDate AND @endDate GROUP BY process_name) total_table
WHERE count_table.process_name = total_table.process_name 
UNION 
SELECT 'Normalization', 'Last Transaction Time:  '+(SELECT convert(VARCHAR(250),(SELECT TOP 1 datetime_req FROM post_tran (NOLOCK) ORDER BY datetime_req DESC), 105)+' '+convert(VARCHAR(250),(SELECT TOP 1 datetime_req FROM post_tran (NOLOCK) ORDER BY datetime_req DESC), 108) ),1, 1,100 
UNION all
Select
 j.name  as process_name
    ,'Job Outcome: '+Case jh.run_status
 When  0 THEN 'Failed'
 When 1 then 'Success'
 when 2 then 'Retry'
 when 3 then 'Cancelled'
 when 4 then 'InProgress'  End +CHAR(10)+'Job Message: '+jh.message 
 +CHAR(10)+'Job Runtime: '+Left(cast(run_date as varchar ),4) + '/' + 
 substring(cast(run_date as varchar ), 5,2) + '/' + 
 Right(cast(run_date as varchar ), 2) + ' ' + 
 cast( ((run_time/10000) %100) as varchar ) + ':' + 
 cast( ((run_time/100) %100) as varchar ) + ':' +
 cast( (run_time %100) as varchar ) +CHAR(10)+'Job Duration: '+
 cast( ((run_duration/10000) %100) as varchar ) + ':' + 
 cast( ((run_duration/100) %100) as varchar ) + ':' +
 cast( (run_duration %100) as varchar )+jh.step_name 
 as result_value,
  jh.run_status result_total,
  2 process_total,
0 percentage
From
 msdb..sysjobs j
join
 msdb..sysjobhistory jh
on 
 j.job_id = jh.job_id
WHERE 

CHARINDEX ('settlement_summary',j.name) > 0 
AND jh.step_name IN('settlement_summary_breakdown','(Job outcome)')
AND run_date >= REPLACE(CONVERT(VARCHAR(50), @startDate,102), '.', '') AND run_date >= REPLACE(CONVERT(VARCHAR(50), @endDate,102), '.', '')