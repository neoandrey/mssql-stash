
CREATE PROCEDURE get_daily_dcc_transaction_summary_report_2  (@report_date_start DATETIME,@report_date_end   DATETIME ) AS
BEGIN
    SET NOCOUNT ON
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    
	SET @report_date_start = COALESCE(@report_date_start, REPLACE(CONVERT(VARCHAR(10), DATEADD(D, -1, GETDATE()),111),'/', '-'))
	SET @report_date_end= COALESCE(@report_date_end, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-'));


	
    SELECT 
			trans.recon_business_date,
			cust.pan,terminal_id, 
			retrieval_reference_nr, 
			settle_amount_req, 
			dbo.formatAmount(tran_amount_req,tran_currency_code) base_transaction_amount, 
			tran_currency_code AS base_currency_code,
			dbo.formatAmount(settle_amount_impact,settle_currency_code) scheme_settlement_amount, 
			settle_currency_code scheme_settelement_currency,
			terminal_id, 
			tran_currency_code,
			message_type,
			cust.terminal_id,
			cust.card_acceptor_id_code,
			trans.tran_type,trans.pos_entry_mode, 
    		ext_009_conv_rate_settle scheme_settlement_rate  
	FROM post_tran trans (NOLOCK, INDEX(ix_post_tran_9))
	JOIN 
	 (SELECT [DATE] recon_business_date  FROM dbo.get_dates_in_range (@report_date_start, @report_date_end))r
	 ON 
	 trans.recon_business_date = r.recon_business_datE
	   AND tran_reversed = 0
	   AND
	   trans.message_type in('0200','0220')
 	  AND
		tran_postilion_originated = 1 
		AND
		trans.rsp_code_rsp = '00'
	JOIN post_tran_cust cust (NOLOCK) ON (trans.post_tran_cust_id=cust.post_tran_cust_id)
		AND	cust.pos_terminal_type = '02'  
	WHERE

		ext_009_conv_rate_settle IS NOT NULL

	 
	END
	
