
	DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SET @report_date_start = '2015-07-22'
	SET @report_date_end= GETDATE()
	

IF(@report_date_start<> @report_date_end) BEGIN
		SELECT @first_post_tran_cust_id= MIN (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE Recon_business_date >= @report_date_start; 
		SELECT @last_post_tran_cust_id= MAX (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9))  WHERE Recon_business_date<=  @report_date_end;
		SELECT TOP 1 @first_post_tran_id=post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) WHERE datetime_req <=  @report_date_end  order by datetime_req DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	    		SELECT @first_post_tran_cust_id= MIN (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE Recon_business_date >= @report_date_start; 
		SELECT @last_post_tran_cust_id= MAX (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9))  WHERE Recon_business_date<=  @report_date_end;
		SELECT TOP 1 @first_post_tran_id=post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) WHERE datetime_req <=  @report_date_end  order by datetime_req DESC
	    END

SELECT rsp_code_rsp, datetime_req, tran_nr, message_type,card_acceptor_name_loc, tran_currency_code, tran_amount_impact, settle_amount_impact

FROM 
POST_TRAN trans (NOLOCK) LEFT JOIN POST_TRAN_CUST cust (NOLOCK) 
ON 
trans.post_tran_cust_id = cust.post_tran_cust_id
WHERE

	(trans.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(trans.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(trans.post_tran_id >= @first_post_tran_id) 
	AND 
	(trans.post_tran_id <= @last_post_tran_id)
	AND
	(CHARINDEX('ENT',sink_node_name )>0 OR CHARINDEX('SPR',sink_node_name )>0)
	AND
	RIGHT(card_acceptor_name_loc,2)<>'NG'
	AND
	tran_currency_code='566'