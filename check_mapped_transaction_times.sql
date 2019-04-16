DECLARE @first_post_tran_cust_id BIGINT
DECLARE @last_post_tran_cust_id BIGINT
DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
DECLARE	@report_date_start DATETIME
DECLARE	@report_date_end DATETIME

SET @report_date_start ='20150714';
SET @report_date_end ='20150714';

IF(@report_date_start<> @report_date_end) BEGIN
SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
SELECT TOP  1 @last_post_tran_id =post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
END
ELSE IF(@report_date_start= @report_date_end) BEGIN
SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
SET  @report_date_end = DATEADD(D, 1,@report_date_end)
SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC

END

SELECT @first_post_tran_id first_post_tran_id ,@last_post_tran_id last_post_tran_id,  @first_post_tran_cust_id first_post_tran_cust_id, @last_post_tran_cust_id last_post_tran_cust_id

select 'START', tran_nr , datetime_req  FROM post_tran (NOLOCK) WHERE post_tran_id =@first_post_tran_id And post_tran_cust_id =@first_post_tran_cust_id

select 'FINISH', tran_nr , datetime_req  FROM post_tran (NOLOCK) WHERE post_tran_id =@last_post_tran_id And post_tran_cust_id =@last_post_tran_cust_id

