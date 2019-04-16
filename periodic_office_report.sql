DECLARE @startDate DATETIME
DECLARE @endDate DATETIME

SET @startDate = REPLACE(CONVERT(VARCHAR(10), DATEADD(y,-1, GETDATE()),111),'/', '-') ;
SET @endDate = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,0, GETDATE()),111),'/', '-') ;

SELECT count_table.process_name, result_value, result_total, process_total, CONVERT(FLOAT,result_total )/CONVERT(FLOAT,process_total )*100.0 'percentage(%)' FROM 
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
 WHERE process_name IN('Settlement','Normalization','Extract','Reports', 'Cleaner')  GROUP BY process_name,result_value
) count_table
,(SELECT process_name,COUNT(process_name)as process_total FROM dbo.post_process_run (nolock) WHERE process_name IN('Settlement','Normalization','Extract','Reports', 'Cleaner') AND datetime_begin BETWEEN @startDate AND @endDate GROUP BY process_name) total_table
WHERE count_table.process_name = total_table.process_name `