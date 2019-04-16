USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_terminate_long_running_extracts]    Script Date: 07/14/2017 09:27:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	ALTER procedure [dbo].[usp_terminate_long_running_extracts] @allowed_mins int
as begin

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

SET @allowed_mins = ISNULL (@allowed_mins, 180)
  
  IF( (SELECT COUNT(*) FROM post_process_queue WITH (NOLOCK) WHERE process_name = 'Extract' AND DATEDIFF(MI,datetime_started, GETDATE())>@allowed_mins) >0) BEGIN
		DECLARE @start_time DATETIME
		DECLARE @end_time DATETIME
		DECLARE @sql VARCHAR(MAX)
		DECLARE @process VARCHAR(1000)
		
		DECLARE process_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT spawned_name from post_process_queue WITH (NOLOCK) WHERE process_name = 'Extract' AND DATEDIFF(MI,datetime_started,  GETDATE())>@allowed_mins;
		OPEN process_cursor
		FETCH NEXT FROM  process_cursor INTO @process
		
		WHILE (@@FETCH_STATUS =0)BEGIN
		 SET  @sql = 'exec master.dbo.xp_cmdshell ''TASKKILL /IM '+@process+' /F /T''' ;
		 EXEC(@sql)
		
		FETCH NEXT FROM  process_cursor INTO @process
		END
      CLOSE process_cursor
      DEALLOCATE process_cursor
      TRUNCATE TABLE extract_tran
  END
  
  END

