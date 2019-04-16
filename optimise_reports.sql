   IF(@StartDate IS NULL OR @EndDate IS NULL ) BEGIN
		EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
   SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate   = CONVERT(VARCHAR(30), @report_date_end, 112)
	
	
	
	
	
	
	
   END
   	ELSE BEGIN
		    SET @report_date_start = @StartDate 
			SET @report_date_end = @EndDate 
   	END
   	
   			DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		DECLARE @online_system_id INT
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id ,@online_system_id =online_system_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end AND online_system_id =@online_system_id  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id,@online_system_id =online_system_id  FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end AND online_system_id =@online_system_id  order by recon_business_date DESC
	END
	