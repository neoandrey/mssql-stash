USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_2]    Script Date: 04/15/2015 11:17:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER                                                        PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNodes	Text,
        --@SourceNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	DECLARE @report_result TABLE  (
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30), 
		EndDate					VARCHAR(30),
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (60),
		rsp_code_description	VARCHAR (60),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(1000),
		tran_reversed			INT,
                islocalTrx			INT,
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10)
		
		
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

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30),  @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	DECLARE  @list_of_sink_nodes TABLE (sink_node	VARCHAR(30)) 
	--INSERT INTO  @list_of_sink_nodes SELECT part FROM  usf_split_string(@SinkNodes,',')

--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
		

	IF(@StartDate<> @EndDate) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @StartDate  AND recon_business_date >=  @StartDate   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @EndDate AND (recon_business_date < @EndDate ) ORDER BY datetime_req DESC)
	     SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @StartDate   AND recon_business_date >= @StartDate     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @EndDate AND (recon_business_date < @EndDate) ORDER BY datetime_req DESC)
	END
	ELSE IF(@StartDate= @EndDate) BEGIN
	    SET  @StartDate = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @StartDate),111),'/', '-') 
	    SET  @EndDate = DATEADD(D, 1,@EndDate)
	    SET  @EndDate = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @EndDate),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @StartDate  AND (recon_business_date >= @StartDate )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @EndDate  AND (recon_business_date < @EndDate ) ORDER BY recon_business_date DESC)
		
		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @StartDate AND (recon_business_date >= @StartDate )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @EndDate AND (recon_business_date < @EndDate  ) ORDER BY datetime_req DESC)
	END

	SELECT                  post_tran_cust_id,
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				t.acquiring_inst_id_code,
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
				t.to_account_type, 
				t.settle_currency_code, 
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				extended_tran_type
				auth_id_rsp
		INTO #temp_post_tran

	FROM
		 post_tran t (nolock , INDEX(ix_post_tran_2))
	WHERE 
			(t.post_tran_cust_id >= @first_post_tran_cust_id) 
			AND 
			(t.post_tran_cust_id <= @last_post_tran_cust_id) 
			AND
			(t.post_tran_id >= @first_post_tran_id) 
			AND 
			(t.post_tran_id <= @last_post_tran_id) 
			AND
			t.tran_completed = '1'

			AND
			t.tran_postilion_originated = 1
			AND
			(t.message_type IN ('0100','0200','0220','0420', '0400')) 

			AND
			(
			@SinkNodes IS NULL
			OR

			@SinkNodes IS NOT NULL AND t.sink_node_name IN (SELECT part FROM  usf_split_string(@SinkNodes,','))
			)  
	
	INSERT
				INTO @report_result			
	
	SELECT
		Warning,
		StartDate,  
		EndDate,
		dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
		c.terminal_id, 
		t.acquiring_inst_id_code,
		c.merchant_type,
		c.card_acceptor_id_code, 
		c.card_acceptor_name_loc, 
		c.source_node_name,
		t.sink_node_name, 
		t.tran_type, 
		t.rsp_code_rsp, 
		t.message_type, 
		t.datetime_req,
		t.settle_amount_req, 
		t.settle_amount_rsp,
		t.settle_tran_fee_rsp,
		t.pTranID,
		t.prev_post_tran_id, 
		t.system_trace_audit_nr, 
		t.message_reason_code, 
		t.retrieval_reference_nr, 
		t.datetime_tran_local, 
		t.from_account_type, 
		t.to_account_type, 
		t.settle_currency_code, 
		t.settle_amount_impact,				
		t.tran_type_desciption,
		t.rsp_code_description,
		t.settle_nr_decimals,
		t.currency_alpha_code,
		t.currency_name,
		t.isPurchaseTrx,
		t.isWithdrawTrx,
		t.isRefundTrx,
		t.isDepositTrx,
		t.isInquiryTrx,
		t.isTransferTrx,
		t.isOtherTrx,
		t.structured_data_req,
		t.tran_reversed,
		dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
		dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
		dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,
		extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
		auth_id_rsp
	FROM
	#temp_post_tran t JOIN
	post_tran_cust c (NOLOCK)
	ON t.post_tran_cust_id = c.post_tran_cust_id
					WHERE
					 c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)	
		
		
SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		TranID,
		prev_post_tran_id,
		isforeignfinancial0200,
		islocalfinancial0200
		

	 
	FROM 
			@report_result
Group by startdate, enddate, settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id,isforeignfinancial0200,islocalfinancial0200	
        
	END



