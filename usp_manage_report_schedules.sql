CREATE PROCEDURE usp_manage_report_schedules (@allowed_report_count INT, @min_delay_until_next_check INT) 
AS

BEGIN
     IF( CONVERT(int,@min_delay_until_next_check) >60 ) BEGIN
           DECLARE @err_msg VARCHAR(255)
			SET @err_msg = 'Delay period must be equal to or less than 1 hour';
			RAISERROR(@err_msg, 16, 1)
       return
     END ELSE
     BEGIN
		DECLARE @running_report_count INT
       DECLARE @wait_duration  VARCHAR(15)
      
		select  @running_report_count = COUNT(spawned_name) from post_process_queue(nolock) where process_name ='Reports'
        if(@running_report_count>@allowed_report_count) BEGIN
			 SET @wait_duration  = '00:'+CONVERT(CHAR(2),@min_delay_until_next_check) +':00';
             WAITFOR DELAY @wait_duration;
			 select  @running_report_count = COUNT(spawned_name) from post_process_queue(nolock) where process_name ='Reports'
		END
         ELSE BEGIN
           RETURN
		 END
	 END

END