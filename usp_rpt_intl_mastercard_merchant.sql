
ALTER PROCEDURE usp_rpt_intl_mastercard_merchant (@StartDate DATETIME, @EndDate DATETIME, @card_acceptor_id_code VARCHAR(35))
AS
BEGIN
	DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SET @StartDate = ISNULL(@StartDate, DATEADD(D,-1,GETDATE()));
	SET @EndDate = ISNULL(@EndDate, GETDATE());
	
	SET @report_date_start = @StartDate
	SET @report_date_end= @EndDate
	SET @card_acceptor_id_code = ISNULL(@card_acceptor_id_code, GETDATE());

	

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
				CASE 
				WHEN  @card_acceptor_id_code  = '20100001MC00344' THEN dbo.formatAmount((settle_amount_req - settle_amount_rsp *0.03), trans.settle_currency_code)
				WHEN  @card_acceptor_id_code  = '20100001MC00487' THEN dbo.formatAmount((settle_amount_req - settle_amount_rsp *0.03), trans.settle_currency_code)
				WHEN  @card_acceptor_id_code  = '20100012MC00406' THEN dbo.formatAmount((settle_amount_req - settle_amount_rsp *0.0325), trans.settle_currency_code)
				WHEN  @card_acceptor_id_code  = '20100025MC00606' THEN dbo.formatAmount((settle_amount_req - settle_amount_rsp *0.035), trans.settle_currency_code)
				WHEN  @card_acceptor_id_code  = '20100006MC00412' THEN dbo.formatAmount((settle_amount_req - settle_amount_rsp *0.035), trans.settle_currency_code)
				ELSE  dbo.formatAmount((settle_amount_req - settle_amount_rsp *0.03), trans.settle_currency_code)
					
				END 
				merchant_receivable

FROM 
POST_TRAN trans (NOLOCK)  JOIN POST_TRAN_CUST cust (NOLOCK) 
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
AND rsp_code_rsp='00'
AND tran_postilion_originated = 0
AND tran_completed = 1
AND RIGHT(card_acceptor_id_code,2)<>'NG'
AND card_acceptor_id_code LIKE '%'+@card_acceptor_id_code+'%';


END
