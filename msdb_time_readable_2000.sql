CREATE FUNCTION msdb_time_readable ( 
    @int_time INT 
) 
RETURNS VARCHAR(10) 
AS 
BEGIN 
    IF NOT (@int_time BETWEEN 0 AND 235959) 
        RETURN NULL  

    DECLARE @str VARCHAR(32)
    SELECT @str  = CAST(@int_time AS VARCHAR(32)) 
    SELECT @str = REPLICATE('0', 6 - LEN(@str)) + @str 
    SELECT @str = STUFF(@str, 3, 0, ':') 
    SELECT @str = STUFF(@str, 6, 0, ':') 

    RETURN REPLACE(CONVERT(VARCHAR(10), @str,111),'/', '-')
END 
GO



select js.name,CONVERT(DATETIME, CAST(next_run_date AS VARCHAR(32)), 112) as date, 
dbo.msdb_time_readable(next_run_time) as time, js.job_id 
from msdb..sysjobschedules js inner join msdb..sysjobs j 
on j.job_id = js.job_id 
where js.enabled = 1 
and dbo.msdb_time_readable(next_run_time)  between '05:30:00' and '06:30:00'



SELECT   distinct name  FROM  sysjobs jobs (nolock) JOIN 
sysjobhistory his (NOLOCK) ON
JOBS.job_id =his.job_id

where 

CONVERT(datetime,CONVERT(varchar(30), run_date)+' '+dbo.msdb_time_readable(run_time)) > CONVERT(datetime,'20161217')
AND 
name LIKE 'Postilion Office - Reports%'

