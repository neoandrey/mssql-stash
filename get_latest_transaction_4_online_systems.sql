DECLARE @online_system_id INT
DECLARE @server_name VARCHAR(50)
DECLARE @status_table  TABLE  (online_sys_id INT, online_sys_name VARCHAR(255), last_tran_date datetime)

DECLARE online_system_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT name, online_system_id FROM  postilion_office.dbo.post_online_system (NOLOCK) WHERE [enabled] = 1;
OPEN online_system_cursor
FETCH NEXT FROM online_system_cursor INTO @server_name,@online_system_id
WHILE (@@FETCH_STATUS =0)BEGIN
INSERT INTO @status_table
SELECT TOP 1 @online_system_id,@server_name,datetime_req  FROM  postilion_office.dbo.post_tran WITH (NOLOCK, INDEX = IX_POST_TRAN_7) WHERE online_system_id = @online_system_id ORDER BY datetime_req DESC
FETCH NEXT FROM online_system_cursor INTO @server_name,@online_system_id
END
CLOSE online_system_cursor 
DEALLOCATE online_system_cursoR
select * from @status_table