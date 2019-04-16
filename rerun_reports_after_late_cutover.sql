SELECT COUNT(*) FROM  post_tran_summary WITH  (nolock) WHERE recon_business_date = '20170713'

SELECT COUNT(*) FROM post_tran WITH (nolock, index= ix_post_tran_9) WHERE recon_business_date = '20170713'

SELECT   'WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY ''00:00:45''; exec master.dbo.xp_cmdshell ''C:\postilion\Office\base\bin\run_office_process.cmd Reports '+process_entity+''';  WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY ''00:00:45'';' FROM post_process_run (NOLOCK) Where process_name = 'Reports' AND datetime_begin >='20170714' AND datetime_end <='2017-07-14 02:45:00'




ALTER PROCEDURE usp_rerun_reports_after_late_cutover as

BEGIN

SET transaction isolation level read uncommitted

DECLARE @is_late_cutover BIT

DECLARE @summary_count BIGINT;
DECLARE @post_tran_count BIGINT;
DECLARE @yesterdays_date VARCHAR(10);
DECLARE @todays_date VARCHAR(10);

SET    @yesterdays_date = CONVERT(VARCHAR(10),DATEADD(D, -1, GETDATE()), 112);

SET    @todays_date = CONVERT(VARCHAR(10), GETDATE(), 112);


SELECT @summary_count = COUNT(*) FROM  post_tran_summary WITH  (nolock) WHERE recon_business_date = @yesterdays_date;

SELECT @post_tran_count =COUNT(*) FROM post_tran WITH (nolock, index= ix_post_tran_9) WHERE recon_business_date = @yesterdays_date;


WHILE(@summary_count!= @post_tran_count) BEGIN 

	WAITFOR delay '00:02:00'
 
	SELECT @summary_count = COUNT(*) FROM  post_tran_summary WITH  (nolock) WHERE recon_business_date = @yesterdays_date;

	SELECT @post_tran_count =COUNT(*) FROM post_tran WITH (nolock, index= ix_post_tran_9) WHERE recon_business_date = @yesterdays_date;
   
    SET @is_late_cutover = 1

END

IF(@is_late_cutover = 1) BEGIN

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


END
ELSE  BEGIN 

	PRINT 'The server cutover fine as at: '+convert(varchar(30), getdate(),112)+' '+convert(varchar(30), getdate(),108)

END 

END


