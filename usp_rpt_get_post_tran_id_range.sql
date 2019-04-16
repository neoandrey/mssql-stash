USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_rpt_get_post_tran_id_range]    Script Date: 10/29/2015 5:47:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[usp_rpt_get_post_tran_id_range] (@report_date_start DATETIME, @report_date_end DATETIME, @first_post_tran_id BIGINT OUTPUT, @last_post_tran_id BIGINT OUTPUT)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '') 
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '') 
	DECLARE @report_date_start_plus DATETIME
	SET @report_date_start_plus = DATEADD(HOUR, 1,@report_date_start)

	DECLARE @report_date_end_minus DATETIME
	SET @report_date_end_minus = DATEADD(HOUR, -1,@report_date_end)

	DECLARE @temp_date_start DATETIME
	DECLARE @temp_date_end DATETIME


			IF(@report_date_start<> @report_date_end) BEGIN


				SELECT @temp_date_start= MIN(datetime_req) FROM post_tran_Leg_internal (NOLOCK) WHERE  datetime_req >=@report_date_start AND datetime_req <@report_date_start_plus
				SELECT  @temp_date_end= max(datetime_req) FROM post_tran_Leg_internal (NOLOCK) WHERE   datetime_req >@report_date_end_minus AND datetime_req <@report_date_end


		END
		ELSE IF(@report_date_start= @report_date_end) BEGIN

						SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '') 
						SET  @report_date_end = DATEADD(D, 1,@report_date_end)
						SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '') 
						
				SELECT  @temp_date_start = MIN(datetime_req) FROM post_tran_Leg_internal (NOLOCK) WHERE  datetime_req >=@report_date_start AND datetime_req <@report_date_start_plus
				SELECT  @temp_date_end= max(datetime_req) FROM post_tran_Leg_internal (NOLOCK) WHERE   datetime_req >@report_date_end_minus AND datetime_req <@report_date_end

		END
		if(@temp_date_end IS NULL) BEGIN
			SELECT @temp_date_end = ISNULL(@temp_date_end, MAX(datetime_req)) FROM post_tran_Leg_internal (NOLOCK)   
		END
		SELECT @first_post_tran_id = post_tran_id FROM post_tran_Leg_internal (NOLOCK) WHERE  datetime_req =@temp_date_start
		SELECT @last_post_tran_id = post_tran_id FROM post_tran_Leg_internal (NOLOCK) WHERE  datetime_req =@temp_date_end
		
RETURN
END

	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT
	
	(post_tran_id >= @first_post_tran_id)
	AND
	(post_tran_id <= @last_post_tran_id)

	
	