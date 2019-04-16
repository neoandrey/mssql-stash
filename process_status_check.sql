<?query --
SELECT count_table.process_name, result_value, result_total, process_total, CONVERT(FLOAT,result_total )/CONVERT(FLOAT,process_total )*100.0 'percentage' FROM 
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
--?>


SELECT  
process_entity,
datetime_begin,
datetime_end,
DATEDIFF(MINUTE,datetime_begin, datetime_end ) 'duration (mins)',
CASE result_value
WHEN 0 THEN 'UNKNOWN'
WHEN 10 THEN 'SUCCESS'
WHEN 20 THEN 'WARNING'
WHEN 30 THEN 'FAILURE'
WHEN 40 THEN 'CRASH'
END AS result_value

FROM dbo.post_process_run (nolock) 
 WHERE process_name  = 'Reports'  AND datetime_begin BETWEEN dateadd(d, -1, getdate()) AND getdate()