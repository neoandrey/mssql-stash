
	DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	DECLARE @card_acceptor_id_code VARCHAR(30)
	
	SET @report_date_start = '2015-08-27'
	SET @report_date_end= GETDATE()
	SET @card_acceptor_id_code ='07613600000B001';

	

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

SELECT   datetime_req, pan, terminal_id, 

				cust.card_acceptor_id_code, 
				cust.card_acceptor_name_loc, 
				cust.source_node_name,
				trans.sink_node_name, 
				trans.tran_type, 
				trans.rsp_code_rsp, 
				trans.message_type, 
				trans.datetime_req,
				dbo.formatAmount(trans.settle_amount_req, trans.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(trans.settle_amount_rsp,trans.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(trans.settle_tran_fee_rsp, trans.settle_currency_code) AS settle_tran_fee_rsp,
				
				trans.post_tran_cust_id as TranID,
				trans.prev_post_tran_id, 
				trans.system_trace_audit_nr, 
				trans.message_reason_code, 
				trans.retrieval_reference_nr, 
				trans.datetime_tran_local, 
				trans.from_account_type, 
				trans.to_account_type, 
				trans.settle_currency_code, 
			
				
				dbo.formatAmount( 			
					CASE
						WHEN (trans.tran_type = '51') THEN -1 * trans.settle_amount_impact
						ELSE trans.settle_amount_impact
					END
					, trans.settle_currency_code ) AS settle_amount_impact,				
				


				dbo.formatTranTypeStr(trans.tran_type, trans.extended_tran_type, trans.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(trans.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(trans.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(trans.settle_currency_code) AS currency_name,
				dbo.formatAmount((trans.settle_amount_req*0.03)/100.0, trans.settle_currency_code) merchant_receivable

FROM 
POST_TRAN trans (NOLOCK, INDEX(ix_post_tran_2)) LEFT JOIN POST_TRAN_CUST cust (NOLOCK) 
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

AND card_acceptor_id_code =@card_acceptor_id_code;