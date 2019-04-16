
CREATE PROCEDURE get_switch_uptime_report (@report_days INT, @server_name VARCHAR(20)) AS
BEGIN
DECLARE @query VARCHAR (4000)
IF object_id('tempdb..##uptime_table') IS NOT NULL
BEGIN
	DROP TABLE ##uptime_table
END

SET @query ='SELECT * INTO ##uptime_table FROM OPENQUERY(['+@server_name+'], ''SELECT * FROM task_uptime'')';
EXEC (@query)

SELECT @report_days = ISNULL(@report_days, 7);
SELECT @report_days *= -1;
SELECT task, CASE  
					WHEN  SUM(downtime_in_secs)  <  60 THEN CONVERT(VARCHAR(100),SUM(downtime_in_secs)/60)+' secs'
					WHEN  SUM(downtime_in_secs)  >=  60  AND  SUM(downtime_in_secs)  < 3600 THEN  '00:'+CONVERT(VARCHAR(100),SUM(downtime_in_secs)/60)+':'+REPLICATE('0',2-LEN(SUM(downtime_in_secs)%60))+CONVERT(VARCHAR(100),SUM(downtime_in_secs)%60)
                    ELSE '00:00:00'
              END AS total_downtime,
              ROUND(AVG(percentage_uptime),3) AS average_percentage_uptime 
FROM  ##uptime_table 
WHERE date_begin > DATEADD(D, @report_days, GETDATE()) GROUP BY task;

END

get_switch_uptime_report  @report_days=7, @server_name='172.25.15.3'
get_switch_uptime_report  @report_days=7, @server_name='172.25.0.1'
get_switch_uptime_report  @report_days=7, @server_name='172.25.25.1'