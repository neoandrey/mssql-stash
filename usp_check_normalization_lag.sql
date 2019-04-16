CREATE  PROCEDURE usp_check_normalization_lag @allowed_lag_mins INT 

AS

begin

DECLARE @norm_lag_mins INT

SELECT @norm_lag_mins = DATEDIFF(MINUTE, MAX(datetime_req), GETDATE()) from post_Tran (nolock, INDEX(ix_post_tran_7));

DECLARE @message VARCHAR(MAX)

IF(@norm_lag_mins >=(@allowed_lag_mins)) BEGIN

    SET  @message= 'Normalization is currently lagging by: '+CONVERT(VARCHAR(MAX),@norm_lag_mins)+' minutes. The information below might be helpful in determining the reason for the delay in Normalization:'
    EXEC usp_send_normalization_status_mail @message
	END
ELSE 
   BEGIN
   
   PRINT 'The lag  in Normalization has not exceeded the threshold: '+CONVERT(VARCHAR(MAX),@allowed_lag_mins)+' minute(s).'+CHAR(10)+'Normalization lag: '+CONVERT(VARCHAR(MAX),@norm_lag_mins)+' minutes.'
   
   END

END