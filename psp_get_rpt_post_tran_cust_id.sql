USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_get_rpt_post_tran_cust_id]    Script Date: 05/20/2015 14:42:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER                                                                                  PROCEDURE [dbo].[psp_get_rpt_post_tran_cust_id]
	@user_start_date	datetime,
	@user_end_date		datetime,
	@rpt_tran_id INT OUTPUT 
AS

BEGIN
	 

SELECT TOP 1 @rpt_tran_id = first_post_tran_cust_id FROM post_normalization_session (NOLOCK)
			WHERE datetime_creation  >= DATEADD(dd,-1,@user_start_date) 
			AND datetime_creation <= DATEADD(dd,0,@user_end_date) ORDER BY datetime_creation ASC
RETURN @rpt_tran_id
END
