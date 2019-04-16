











ALTER
                                                           PROCEDURE osp_rpt_b06_CUP_all
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	


If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			c.pan AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id not like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   *

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	--GROUP BY
			--StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type
	ORDER BY 
			source_node_name
END




























































GO
