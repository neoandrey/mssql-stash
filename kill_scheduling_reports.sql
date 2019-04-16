

CREATE PROCEDURE terminate_reports_on_monitor 

AS

BEGIN					

	DECLARE @process_entity VARCHAR(80);
	DECLARE @cmd_command NVARCHAR(200);
	DECLARE @run_date VARCHAR(30);

		SET @run_date =  ISNULL(@run_date,GETDATE() );
		SET @run_date = REPLACE(CONVERT(VARCHAR(10), @run_date,111),'/', '-');

	DECLARE process_entity_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT process_entity  FROM postilion_office.dbo.post_process_run WHERE process_name
	 LIKE 'Reports' AND result_value =0 AND LEFT(CONVERT(VARCHAR(10),datetime_begin, 112),10)>=@run_date AND process_entity NOT IN (SELECT process_entity FROM post_process_run WHERE process_name
	 LIKE 'Reports' AND result_value =10 AND LEFT(CONVERT(VARCHAR(10),datetime_begin, 112),10)>=@run_date)

	OPEN process_entity_cursor;

	FETCH NEXT FROM process_entity_cursor INTO @process_entity;

	WHILE (@@FETCH_STATUS=0)BEGIN  
		PRINT 'Stoping report: '+@process_entity+CHAR(10);
		SET @cmd_command = 'master.dbo.xp_cmdshell ''taskkill /im PORep'+@process_entity+'.exe /t /f''';
		EXEC (@cmd_command);
		FETCH NEXT FROM process_entity_cursor INTO @process_entity;

	END

	CLOSE process_entity_cursor

END