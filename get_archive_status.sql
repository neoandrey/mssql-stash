
CREATE PROCEDURE get_current_archive_status AS
BEGIN
DECLARE @online_system_id INT
DECLARE @server_name VARCHAR(50)
DECLARE @status_table  TABLE  (online_sys_id INT, online_sys_name VARCHAR(255), server_type VARCHAR(10), last_tran_date datetime)

DECLARE online_system_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT name, online_system_id FROM  postilion_office.dbo.post_online_system (NOLOCK) WHERE [enabled] = 1;
OPEN online_system_cursor
FETCH NEXT FROM online_system_cursor INTO @server_name,@online_system_id
WHILE (@@FETCH_STATUS =0)BEGIN
INSERT INTO @status_table
SELECT TOP 1 @online_system_id,@server_name, CASE WHEN  @online_system_id IN (1,2) THEN 'MEGA' WHEN @online_system_id IN (3,4) THEN 'SUPER' END, datetime_req  FROM  postilion_office.dbo.post_tran WITH (NOLOCK, INDEX = IX_POST_TRAN_7) WHERE online_system_id = @online_system_id ORDER BY datetime_req DESC
FETCH NEXT FROM online_system_cursor INTO @server_name,@online_system_id
END
CLOSE online_system_cursor 
DEALLOCATE online_system_cursoR
--select * from @status_table

DECLARE @temp_sql_table TABLE (sql_command VARCHAR(MAX))
INSERT INTO  @temp_sql_table
SELECT top 2   'SELECT MAX (datetime_req) FROM '+table_name+ ' WITH (NOLOCK)' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'post_tran_super%' AND ISNUMERIC(RIGHT(TABLE_NAME,2)) =1 AND TABLE_TYPE = 'BASE TABLE'	ORDER BY TABLE_NAME DESC 

DECLARE @sql VARCHAR(MAX)
DECLARE @super_datetime_table TABLE (latest_datetime DATETIME)

DECLARE command_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT sql_command FROM @temp_sql_table 
OPEN command_cursor
FETCH NEXT FROM command_cursor INTO @sql
WHILE (@@FETCH_STATUS =0)BEGIN
	INSERT INTO @super_datetime_table EXEC(@sql);
	FETCH NEXT FROM command_cursor INTO @sql
END
CLOSE command_cursor
DEALLOCATE command_cursor

DELETE FROM @temp_sql_table

INSERT INTO  @temp_sql_table
SELECT top 2   'SELECT MAX (datetime_req) FROM '+table_name+ ' WITH (NOLOCK)' FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'post_tran_MEGA%' AND ISNUMERIC(RIGHT(TABLE_NAME,2)) =1 AND TABLE_TYPE = 'BASE TABLE'	ORDER BY TABLE_NAME DESC 

DECLARE @mega_datetime_table TABLE (latest_datetime DATETIME)

DECLARE command_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT sql_command FROM @temp_sql_table 
OPEN command_cursor
FETCH NEXT FROM command_cursor INTO @sql
WHILE (@@FETCH_STATUS =0)BEGIN
	INSERT INTO @mega_datetime_table EXEC(@sql);
	FETCH NEXT FROM command_cursor INTO @sql
END
CLOSE command_cursor
DEALLOCATE command_cursor

--SELECT  'MEGA', MAX(latest_datetime) FROM @mega_datetime_table

select  online_sys_id online_system_id, online_sys_name online_system_name, last_tran_date latest_normalized_transaction_time, lastest_tran_time latest_archived_transaction_time, DATEDIFF(MINUTE,lastest_tran_time, last_tran_date ) 'archive_delay (in mins)'  FROM @status_table  s join    (SELECT 'SUPER' server_type,MAX(latest_datetime) lastest_tran_time FROM @super_datetime_table union
SELECT 'MEGA' server_type,MAX(latest_datetime) lastest_tran_time FROM @mega_datetime_table)  arch 
on s.server_type = arch.server_type 
END
