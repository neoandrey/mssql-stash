DECLARE @sql VARCHAR(MAX) =''

		DECLARE @sql_script VARCHAR(MAX)=''
		DECLARE @yesterdays_date VARCHAR(10);
DECLARE @todays_date VARCHAR(10);

SET    @yesterdays_date = CONVERT(VARCHAR(10),DATEADD(D, -1, GETDATE()), 112);

SET    @todays_date = CONVERT(VARCHAR(10), GETDATE(), 112);

	  DECLARE report_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR 
		SELECT   'WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY ''00:00:45''; exec master.dbo.xp_cmdshell ''C:\postilion\Office\base\bin\run_office_process.cmd Reports '+process_entity+''';  WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY ''00:00:45'';'

		 FROM post_process_run (NOLOCK) Where process_name = 'Reports' AND datetime_begin >= @todays_date AND datetime_end <=GETDATE()

		 OPEN report_cursor;
		 
		 FETCH NEXT FROM  report_cursor INTO  @sql 
		 WHILE (@@FETCH_STATUS=0)BEGIN
		 
		 set @sql_script = @sql_script+' '+@sql; 
		 FETCH NEXT FROM  report_cursor INTO  @sql
		 END
		 CLOSE report_cursor
		 DEALLOCATE report_cursor 
		 
		 EXEC (@sql_script);

