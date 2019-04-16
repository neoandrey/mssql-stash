get_daily_dcc_transaction_summary_report  '20150801', '20150826';



ALTER PROCEDURE get_daily_dcc_transaction_summary_report  (@report_date_start DATETIME,@report_date_end   DATETIME ) AS
BEGIN
 
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SET @report_date_start = COALESCE(@report_date_start, REPLACE(CONVERT(VARCHAR(10), DATEADD(D, -1, GETDATE()),111),'/', '-'))
	SET @report_date_end= COALESCE(@report_date_end, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-'));

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
	
    SELECT trans.datetime_req,
     cust.pan,terminal_id, retrieval_reference_nr, settle_amount_req, dbo.formatAmount(tran_amount_req,tran_currency_code) base_transaction_amount, tran_currency_code AS base_currency_code,dbo.formatAmount(settle_amount_impact,settle_currency_code) scheme_settlement_amount, settle_currency_code scheme_settelement_currency, terminal_id,  tran_currency_code, message_type,cust.terminal_id, cust.card_acceptor_id_code,trans.tran_type,trans.pos_entry_mode, (SELECT rate FROM post_currencies WHERE currency_code=settle_currency_code)as scheme_settlement_rate  

	FROM post_tran trans (NOLOCK)
	JOIN post_tran_cust cust (NOLOCK) ON (trans.post_tran_cust_id=cust.post_tran_cust_id)
	WHERE
 	trans.message_type in('0200','0220') AND
		tran_postilion_originated = '1' AND
		(trans.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(trans.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(trans.post_tran_id >= @first_post_tran_id) 
	AND 
	(trans.post_tran_id <= @last_post_tran_id)
 AND
		trans.rsp_code_rsp = '00'
		AND
				
		cust.pos_terminal_type = '02' AND
       trans.tran_currency_code <> '566' 
       and trans.tran_currency_code <> trans.settle_currency_code 
	   AND tran_reversed = 0
	   AND
		trans.sink_node_name IN  ('MEGGTBMDSsnk', 'MEGDCCESBsnk')

	END