	DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SET @report_date_start = '20150412'
	SET @report_date_end= '20150413'

	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @report_date_start  AND recon_business_date >=  @report_date_start   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id  = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end ) ORDER BY datetime_req DESC)
		SET  @first_post_tran_id      = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start   AND recon_business_date >= @report_date_start     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id       = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
		SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @report_date_start  AND (recon_business_date >= @report_date_start )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @report_date_end  AND (recon_business_date < @report_date_end ) ORDER BY recon_business_date DESC)

		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @report_date_start AND (recon_business_date >= @report_date_start )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @report_date_end AND (recon_business_date < @report_date_end  ) ORDER BY datetime_req DESC)
	END
	
	



SELECT		c.pan,
			datetime_req,
			c.terminal_id,
			c.card_acceptor_name_loc, 
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description, 
			t.retrieval_reference_nr, 			
			dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount,
			dbo.currencyAlphaCode(t.tran_currency_code) AS tran_currency_alpha_code,
			dbo.formatAmount(-1 * t.settle_amount_impact, t.settle_currency_code) AS settle_amount,
			
			dbo.formatAmount(-1*t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee,	
			dbo.formatAmount((t.settle_amount_impact + t.settle_tran_fee_rsp)*-1, t.settle_currency_code) as Total_Impact,
								
			dbo.currencyAlphaCode(t.settle_currency_code) AS settle_currency_alpha_code,
			t.from_account_id,
			dbo.rpt_fxn_account_type(t.from_account_type) AS from_account_type,
			t.to_account_id,
			dbo.rpt_fxn_account_type(t.to_account_type) AS to_account_type,
			c.post_tran_cust_id AS tran_number,
			payee,
			rsp_code_rsp
						
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)

	WHERE 		c.pan in ((LEFT(N'6280512305702001120',6))+ '******' + (RIGHT (N'6280512305702001120',4)),(LEFT(N'6280512305702001120',6))+ '*********' + (RIGHT (N'6280512305702001120',4)),N'6280512305702001120')
			AND (t.from_account_id = N'6280512305702001120' or t.to_account_id = N'6280512305702001120')
			--and t.sink_node_name = 'UBACCsnk'
                       and t.tran_completed = 1
			AND 	t.tran_postilion_originated = 0 
			AND	(t.message_type IN ('0200','0220','0420') )--AND t.tran_reversed IN ('0', '1')
 			 	--or t.message_type IN ('0400', '0420') AND tran_amount_rsp <> 0 ) 
			AND	t.tran_type IN ('00', '01', '09', '20', '21', '40', '50','22','02' )
			--AND	t.rsp_code_rsp IN ('00', '11')
			AND (t.sink_node_name like '%CCsnk'or t.sink_node_name like '%MPPsnk')
		AND (t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				--AND	(t.recon_business_date >= @StartDate) 
			--AND 	(t.recon_business_date < @EndDate) 
	ORDER BY 
			t.datetime_req
