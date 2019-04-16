SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO











ALTER                                                     PROCEDURE [dbo].[osp_rpt_b08]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (60),
		rsp_code_description	VARCHAR (60),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes SELECT part FROM dbo.usf_split_string( @SinkNodes, ',');
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local

        
	END


























































GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

