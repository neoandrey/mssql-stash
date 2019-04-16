USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[rerun_data_summary_for_dates]    Script Date: 01/26/2015 17:37:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER     PROCEDURE [dbo].[rerun_data_summary_for_dates]  (@startDate VARCHAR(30), @endDate VARCHAR(30)) AS

BEGIN

DECLARE @start_date CHAR(8)
DECLARE @end_date CHAR(8)
DECLARE @date_cursor VARCHAR(10)
DECLARE @param_list VARCHAR(200)
DECLARE @date_modifier INT
DECLARE @modifier_char VARCHAR(10)
DECLARE @session_id INT

SET  @startDate= ISNULL (@startDate, DATEADD(D, -1, GETDATE()));
SET  @endDate =ISNULL (@endDate,  GETDATE());

IF (@startDate=@endDate) BEGIN
   SET @endDate= CONVERT(VARCHAR(50), DATEADD(D, 1, @endDate),112);
END

SELECT @session_id=session_id from post_ds_nodes_session WHERE datetime_from = @startDate;

UPDATE post_ds_nodes_session SET datetime_from ='1900-01-01', datetime_end = '1900-01-02' WHERE session_id = @session_id

SET @startDate = REPLACE(REPLACE(@startDate, '/',''), '-','');
SET @endDate = REPLACE(REPLACE(@endDate, '/',''), '-','');

SET @startDate = LEFT(@startDate, 8);
SET @endDate = LEFT(@endDate, 8);


SET @date_cursor = @startDate

WHILE (DATEDIFF(D,@date_cursor,@endDate)>=0)

BEGIN 
        UPDATE post_datasummary_entity SET param_list =@date_cursor+';00:00' WHERE NAME ='Nodes';
        PRINT 'Running summary for: '+@date_cursor+CHAR(10)

         WHILE EXISTS( SELECT process_name FROM post_process_queue WHERE spawned_name ='PODatNodes.exe')
	BEGIN
             WAITFOR DELAY '00:05:00';
         END
         --EXEC msdb.dbo.sp_start_job @job_name='Postilion Office - Batch Process - Data Summary Base Tables', @step_name = 'Step 1 - Nodes'
	EXEC master.dbo.xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /wait DataSummary Nodes -';
            
            SELECT @date_modifier = CONVERT(INT, RIGHT(@date_cursor, 2))+1;
	    SET @date_cursor = REPLACE(REPLACE( CONVERT(VARCHAR(50),DATEADD(D,1,@date_cursor),112), '/',''), '-','');
            SET @date_cursor = LEFT(@date_cursor,8);
PRINT @date_cursor
    --WAITFOR DELAY '00:05:00';
END

UPDATE post_datasummary_entity SET param_list ='' WHERE NAME ='Nodes';


END





