USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Beneficiary_Confirmation]    Script Date: 07/28/2016 08:44:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

















alter         PROCEDURE [dbo].[osp_rpt_b06_Beneficiary_Confirmation]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@terminalID		VARCHAR(40),	
	@show_full_pan	 BIT,
	@TotalsGroup    VARCHAR (512),
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
SET NOCOUNT ON


	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
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
		TranID						BIGINT, 
		prev_post_tran_id			BIGINT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			BIGINT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999),
		totals_group				Varchar(40),
		payee						VARCHAR(50),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28)
		--Beneficiary_Account		VARCHAR (60)
	)	
	CREATE TABLE #report_result_2
	(
		retrieval_reference_nr		CHAR (12), 
		settle_amount_impact		FLOAT,
		system_trace_audit_nr		CHAR (6)	
		
		)	

	IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END


        CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
	
	CREATE TABLE #list_of_terminalIds (terminalID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_terminalIds EXEC osp_rpt_util_split_nodenames @terminalID
	
	
	--SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
 --       WHERE ll.recon_business_date >= @report_date_start
 --       and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
        INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			pan , --  dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           	c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
		 	 t2.settle_amount_req, --dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

			t2.settle_amount_rsp,  -- dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			t2.settle_tran_fee_rsp,  --, t.settle_currency_code  dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
			t2.settle_amount_impact,
			
			--dbo.formatAmount(
			--		CASE
			--			WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
			--			ELSE t.settle_amount_impact
						
			--		END
			--		, t.settle_currency_code) AS settle_amount_impact,

					

			
			 t.rsp_code_rsp rsp_code_description,   --dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			t.settle_currency_code settle_nr_decimals,  --dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			 t.settle_currency_code  currency_alpha_code, --dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			t.settle_currency_code currency_name , --dbo.currencyName(t.settle_currency_code) AS currency_name,
			t.extended_tran_type tran_type_description, -- dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			t.tran_type isPurchaseTrx,--dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			t.tran_type isWithdrawTrx,--dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			t.tran_type isRefundTrx,--dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			t.tran_type isDepositTrx,--dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			t.tran_type isInquiryTrx,--dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			t.tran_type isTransferTrx,--dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			t.tran_type isOtherTrx,--dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data,
			c.totals_group,
			t.payee,
			t.from_account_id,
			t.to_account_id
--			Beneficiary_Account = CASE WHEN substring(t.sink_node_name,4,3) = substring(C.totals_group,1,3) THEN 
--T.to_account_id

--Else T.payee
--END
	FROM
			post_tran t (NOLOCK, INDEX(ix_post_tran_9))
			JOIN (	 SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)  r
					on 
					t.recon_business_date = r.recon_business_date 
			
			   AND
			
			(t.tran_postilion_originated = 1 
			AND
			t.message_type IN ('0400','0420') --- oremeyi removed 0100, 0120
			--AND 
			--t.tran_completed = 1 
			AND
			t.tran_type IN ('50')	
			
			AND t.rsp_code_rsp = '05'
		)
			 JOIN 
			post_tran_cust c (NOLOCK, index(pk_post_tran_cust)) ON (t.post_tran_cust_id = c.post_tran_cust_id) 
			AND
			(substring (c.terminal_id,1,1) = '1')
	  JOIN post_tran t2 (NOLOCK) ON t.retrieval_reference_nr = t2.retrieval_reference_nr and t.tran_nr != t2.tran_nr 
		and t2.settle_amount_impact <> 0
			
			where
				 (

LEFT(t.sink_node_name, 3) ='TSS' AND SUBSTRING(t.sink_node_name,4, 3)  in ( 

												SELECT SUBSTRING(sink_NODE,4,3) FROM #list_of_sink_nodes
)
and LEFT(source_node_name, 3) = 'SWT' and t.sink_node_name not like '%CC%')
	
	option (recompile)
		IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			

--	INSERT INTO #report_result_2
-- select  t.retrieval_reference_nr,t.settle_amount_impact,t.system_trace_audit_nr
--	from post_Tran t  join post_tran c  on t.retrieval_reference_nr = c.retrieval_reference_nr 
	
--	where  ( 
--	( t.rsp_code_rsp = '00' and t.sink_node_name like 'SWT%')
-- or c.rsp_code_rsp  IN ('00', '91') and c.sink_node_name like 'tss%' )
-- and  t.tran_type= '50'
--and (c.recon_business_date >= @report_date_start) 
--			AND 
--			(c.recon_business_date <= @report_date_end) 
	
	

	
	
		
		
	SELECT 
	
	NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			recon_business_date,--oremeyi added this 24/02/2009
			 dbo.fn_rpt_PanForDisplay(pan, @show_full_pan) AS pan,
			terminal_id, -- oremeyi added this
           	source_node_name, --oremeyi added this
			card_acceptor_id_code, 
			card_acceptor_name_loc, 
			sink_node_name, 
			tran_type, 
			rsp_code_rsp, 
			message_type, 
			datetime_req, 
			
			dbo.formatAmount(settle_amount_req, settle_currency_code) AS settle_amount_req, 

			dbo.formatAmount(settle_amount_rsp, settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(settle_tran_fee_rsp, settle_currency_code) AS settle_tran_fee_rsp, 
			
			 TranID, 
			prev_post_tran_id, 
			system_trace_audit_nr, 
			message_reason_code, 
			retrieval_reference_nr, 
			datetime_tran_local, 
			from_account_type, 
			to_account_type, 
			settle_currency_code, 
			
			
			dbo.formatAmount(
					CASE
						WHEN (tran_type = '51') THEN -1 * settle_amount_impact
						ELSE settle_amount_impact
						
					END
					, settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(rsp_code_description) as rsp_code_description,
			dbo.currencyNrDecimals(settle_nr_decimals) AS settle_nr_decimals,
			dbo.currencyAlphaCode(currency_alpha_code) AS currency_alpha_code,
			dbo.currencyName(currency_name) AS currency_name,
			dbo.formatTranTypeStr(tran_type, tran_type_description, message_type) AS tran_type_description,
			tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(isPurchaseTrx) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(isWithdrawTrx) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(isRefundTrx) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(isDepositTrx) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(isInquiryTrx) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(isTransferTrx) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(isOtherTrx) 		AS isOtherTrx,
			retention_data,
			totals_group,
			payee,
			from_account_id,
		    to_account_id
	
	
	FROM
			#report_result 
			--t join #report_result_2 tt on t.retrieval_reference_nr  = tt.retrieval_reference_nr
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
	option (recompile)
END







































































































































