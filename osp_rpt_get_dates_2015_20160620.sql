USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2015]    Script Date: 06/20/2016 13:51:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_get_dates_2015]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    



	IF (@default_date_method = 'Last business day' and (@user_start_date IS NULL AND @user_end_date IS NULL))
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	IF (@user_start_date IS NULL AND @user_end_date IS NULL )  BEGIN
	
	SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
			
	END
	ELSE BEGIN
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
	
	
	end


END



