DECLARE @bodyMsg nvarchar(max)
DECLARE @subject nvarchar(max)
DECLARE @tableHTML nvarchar(max)

SET @subject = 'Query Results in HTML with CSS'


SET @tableHTML = 
N'<style type="text/css">
#box-table
{
font-family: "Arial", "Times mew Roman", "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
font-size: 12px;
text-align: left;
border-collapse: collapse;
border-top: 7px solid #9baff1;
border-bottom: 7px solid #9baff1;
}
#box-table th
{
font-size: 13px;
font-weight: normal;
background: #b9c9fe;
border-right: 2px solid #9baff1;
border-left: 2px solid #9baff1;
border-bottom: 2px solid #9baff1;
color: #039;
}
#box-table td
{
border-right: 1px solid #aabcfe;
border-left: 1px solid #aabcfe;
border-bottom: 1px solid #aabcfe;
color: #669;
}
tr:nth-child(odd)	{ background-color:#eee; }
tr:nth-child(even)	{ background-color:#fff; }	
</style>'+	
N'<H3><font color="Black">Normalization Delay on: ' + CONVERT(varchar(max) ,CONNECTIONPROPERTY('local_net_address'))+'</H3>' +
N'<table id="box-table" >' +
N'<tr><font color="Black"><th>
Time</th>
<th>Log Description</th>
<th>Result </th>
</tr>' +
CAST ( ( 

SELECT top 10 td = CAST([datetime_begin] AS VARCHAR(100)),'',
td = CAST([log_description_param_list]AS VARCHAR(MAX)),'',
td = CASE r.[result_value]	
	WHEN   0 THEN  'UNKNOWN'
WHEN   10 THEN  'SUCCESS'
WHEN   20 THEN  'WARNING'
WHEN   30 THEN  'FAILURE'
WHEN   40 THEN  'CRASH'
END ,''

FROM post_process_run r (nolock) JOIN 
post_process_run_phase_detail d (nolock) ON r.process_run_id = 
d.process_run_id WHERE r.process_name = 'Normalization' 
and CONVERT(VARCHAR(MAX),log_description_param_list) not 
 like '[0-9]%'
ORDER BY  r.process_run_id  DESC
FOR XML PATH('tr'), TYPE 
) AS NVARCHAR(MAX) ) +
N'</table>' 


EXEC msdb.dbo.sp_send_dbmail @recipients='neoandray@gmail.com',
@subject = @subject,
@body = @tableHTML,
@body_format = 'HTML',
@copy_recipients='',
@blind_copy_recipients= 'neoandrey@yahoo.com' ;

