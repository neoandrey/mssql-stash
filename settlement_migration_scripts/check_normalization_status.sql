

USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[check_norm_cutover_status]    Script Date: 08/24/2015 09:26:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[check_norm_cutover_status] @is_cutover_successful BIT OUTPUT

  AS BEGIN
		DECLARE @most_recent_tran_date  DATETIME;
		DECLARE @today DATETIME;
		DECLARE @time_diff INT;
				
		SELECT @most_recent_tran_date = (SELECT TOP 1 datetime_req FROM post_tran (NOLOCK) ORDER BY datetime_req DESC)
		SELECT @today= GETDATE();
		SELECT @time_diff = DATEDIFF(D,  @most_recent_tran_date, @today);
		IF(@time_diff=0) BEGIN
			SET @is_cutover_successful=1;
		END
		ELSE 
		BEGIN
			SET @is_cutover_successful=0;
		END
		
        RETURN 

END



DECLARE @norm_cutover BIT;

EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;

IF(@norm_cutover<> 1 ) BEGIN
RAISERROR ('Normalization has not cutover. Reports will not be complete. Please report to your administrator'
            , 16, 1)

END