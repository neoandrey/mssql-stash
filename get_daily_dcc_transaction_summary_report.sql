
CREATE PROCEDURE get_daily_dcc_transaction_summary_report  (@report_date_start DATETIME,@report_date_end   DATETIME ) AS
BEGIN
 
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SET @report_date_start = COALESCE(@report_date_start, REPLACE(CONVERT(VARCHAR(10), DATEADD(D, -1, GETDATE()),111),'/', '-'))
	SET @report_date_end= COALESCE(@report_date_end, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-'));


	
    SELECT trans.datetime_req,
     cust.pan,terminal_id, retrieval_reference_nr, settle_amount_req, dbo.formatAmount(tran_amount_req,tran_currency_code) base_transaction_amount, tran_currency_code AS base_currency_code,
	 dbo.formatAmount(settle_amount_impact,settle_currency_code) scheme_settlement_amount,
	 settle_currency_code scheme_settelement_currency
	 , terminal_id,  tran_currency_code, message_type,cust.terminal_id, 
	 cust.card_acceptor_id_code,
	 trans.tran_type,trans.pos_entry_mode, (SELECT rate FROM post_currencies WHERE currency_code=settle_currency_code)as scheme_settlement_rate  

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
		trans.sink_node_name = 'MEGGTBMDSsnk' 
		AND
		cust.pos_terminal_type = '02' AND
       trans.tran_currency_code <> '566' 
	   AND tran_reversed = 0
	END
	
