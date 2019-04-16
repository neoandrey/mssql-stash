DECLARE @session_id INT
DECLARE @sql_command  NVARCHAR(500)

DECLARE session_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT  des.session_id  FROM sys.dm_exec_requests der
INNER JOIN sys.dm_exec_connections dec
ON der.session_id = dec.session_id INNER JOIN sys.dm_exec_sessions des
ON des.session_id = der.session_id 
WHERE des.is_user_process = 1
AND [host_name] ='REPORTS' OR 
client_net_address IN ('172.25.10.92', '172.25.15.92')
OPEN session_cursor
FETCH NEXT FROM session_cursor into @session_id;
WHILE (@@FETCH_STATUS =0) BEGIN 
SET @sql_command = ' KILL '+convert(varchar(10),@session_id)
print  'Running query: '+@sql_command
EXEC sp_executesql  @statement =@sql_command
FETCH NEXT FROM session_cursor into @session_id;
END
CLOSE session_cursor
DEALLOCATE session_cursor