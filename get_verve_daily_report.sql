  alter PROCEDURE get_verve_daily_report  @report_date_start DATETIME, @report_date_end DATETIME
	as
	BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 SET @report_date_start = ISNULL(@report_date_start,REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,-1,GETDATE()),111),'/',''))
SET @report_date_end = ISNULL(@report_date_end,REPLACE(CONVERT(VARCHAR(MAX), GETDATE(),111),'/',''))
	
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT
	SELECT @first_post_tran_cust_id =  post_tran_cust_id FROM post_tran (NOLOCK) WHERE post_tran_id= @first_post_tran_id
	SELECT @last_post_tran_cust_id =  post_tran_cust_id FROM post_tran (NOLOCK) WHERE post_tran_id= @last_post_tran_id
	
SELECT  pan,
			sink_node_name,
			source_node_name,
			message_type,
			tran_type,
			extended_tran_type,
			rsp_code_rsp,
			datetime_req,
			terminal_id,
			acquiring_inst_id_code,
			system_trace_audit_nr,
			retrieval_reference_nr, 
			dbo.formatAmount(tran_amount_req, tran_currency_code) tran_amount_req , 
			dbo.formatAmount(tran_amount_rsp, tran_currency_code)  tran_amount_rsp,
			dbo.formatAmount(settle_amount_impact, tran_currency_code)  amount_settled,  
			tran_currency_code,
							dbo.formatTranTypeStr(trans.tran_type, trans.extended_tran_type, trans.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(rsp_code_rsp) as rsp_code_description,
				dbo.currencyNrDecimals(trans.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyName(trans.settle_currency_code) AS currency_name,
			settle_currency_code,
			settle_tran_fee_rsp 'settle_tran_fee_rsp(Surchage)'
   	FROM
		post_tran trans WITH(NOLOCK) 
			JOIN post_tran_cust cust WITH (NOLOCK) ON
			trans.post_tran_cust_id = cust.post_tran_cust_id

			WHERE
				datetime_req>=@report_date_start
				AND
				(post_tran_id >=@first_post_tran_id AND trans.post_tran_cust_id >= @first_post_tran_cust_id)
				AND 
				 (post_tran_id <= @last_post_tran_id AND trans.post_tran_cust_id <= @last_post_tran_cust_id)
				and
				left(pan,3)='506'
				AND
				(
				sink_node_name  IN ('VERVEINTsnk','MEGASWTsnk')
				
				)
		        AND
		        tran_postilion_originated = 0
		OPTION (MAXDOP 16)
		
		
		end
	