DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT

IF(@report_date_start<> @report_date_end) BEGIN
	SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC)
	SET  @last_post_tran_id =(SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC)
END
ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC)
	SET  @last_post_tran_id =(SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC)
END