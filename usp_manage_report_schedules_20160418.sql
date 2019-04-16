USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[usp_manage_report_schedules]    Script Date: 04/18/2016 17:14:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_manage_report_schedules] (@allowed_report_count INT, @min_delay_until_next_check INT) 
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
        while(@running_report_count>@allowed_report_count) BEGIN  
if(len(@min_delay_until_next_check)=1)begin
set @min_delay_until_next_check ='0'+@min_delay_until_next_check;
end
			 SET @wait_duration  = '00:'+CONVERT(CHAR(2),@min_delay_until_next_check) +':00';
             WAITFOR DELAY @wait_duration;
			 select  @running_report_count = COUNT(spawned_name) from post_process_queue(nolock) where process_name ='Reports'
		END
    
           RETURN
		 
	 END

END
GO


