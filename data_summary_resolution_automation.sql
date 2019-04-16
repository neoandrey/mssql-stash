DECLARE @start_date CHAR(8)
DECLARE @end_date CHAR(8)
DECLARE @date_cursor CHAR(8)
DECLARE @param_list VARCHAR(200)
DECLARE @date_modifier INT
DECLARE @modifier_char VARCHAR(10)

SET  @start_date= '2014-12-19';
SET  @end_date =GETDATE();


SET @date_cursor = @start_date

WHILE (@date_cursor<>@end_date)

BEGIN 

WHILE (@date_cursor<>@end_date)

BEGIN 


end
        UPDATE post_datasummary_entity SET param_list =@date_cursor+';00:00' WHERE NAME ='Nodes';
        PRINT 'Running summary for: '+@date_cursor+CHAR(10)
        --EXEC xp_cmdshell 'C:\postilion\office\base\bin\run_office_process.cmd /wait DataSummary Nodes -';
         WHILE EXISTS( SELECT process_name FROM post_process_queue WHERE spawned_name ='PODatNodes.exe')
             WAITFOR DELAY '00:05:00';
         END
         EXEC msdb.dbo.sp_start_job @job_name='Postilion Office - Batch Process - Data Summary Base Tables', @step_name = 'Step 1 - Nodes'

            
        SELECT @date_modifier = CONVERT(INT, RIGHT(@date_cursor, 2))
            SELECT @date_modifier = @date_modifier+1;

            IF (LEN(@date_modifier)=1)
            BEGIN
               SET @date_cursor = LEFT(@date_cursor,7)+CONVERT(VARCHAR(2),@date_modifier)
            END
            ELSE 
            BEGIN
               SET   @date_cursor= LEFT(@date_cursor,6)+CONVERT(VARCHAR(2),@date_modifier)
            END
    WAITFOR DELAY '00:05:00';
END
UPDATE post_datasummary_entity SET param_list ='' WHERE NAME ='Nodes';
