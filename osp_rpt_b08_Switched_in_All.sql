USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All]    Script Date: 06/16/2016 08:20:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















ALTER                                                         PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNodes	VARCHAR(4000),
        --@SourceNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(100)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
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
		structured_data_req		VARCHAR(max),
		tran_reversed			INT,
                islocalTrx			INT,
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		islocalfinancial0200TrxNOTCashWdrl		INT,
		
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
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   


	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

  set @StartDate =REPLACE( CONVERT(VARCHAR(30), @report_date_start, 111), '/', '');
   set @EndDate = REPLACE( CONVERT(VARCHAR(30),@report_date_end,111), '/', '');
  


	DECLARE  @list_of_sink_nodes TABLE (sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT part from  usf_split_string( @SinkNodes,',') ORDER BY PART ASC

--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				--t.terminal_owner,
				t.merchant_type,
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_id as TranID,
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
				 (SELECT  structured_data_req  FROM post_tran (NOLOCK, INDEX(ix_post_tran_1)) WHERE post_tran_id = t.post_tran_id) structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as islocalfinancial0200,
				dbo.fn_rpt_islocalfinancial0200TrxNOTCashWdrl(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.card_acceptor_name_loc,t.tran_type) as islocalfinancial0200TrxNOTCashWdrl,


				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp
				

				
	FROM
				post_tran_summary t (NOLOCK)
				JOIN
				  (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@report_date_start,@report_date_end))r
				ON
			    t.recon_business_date = r.recon_business_date
			    AND 
			    t.tran_completed = '1'
				AND
				t.tran_postilion_originated = 1
				
			    		
	WHERE 			
				
				
				
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
			        
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				
				)
                                AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				
					OPTION (recompile)
	IF (@@ROWCOUNT = 0) BEGIN
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	END
	--ELSE BEGIN
	--  UPDATE @report_result SET res.structured_data_req = t.structured_data_req FROM  @report_result res JOIN post_tran_summary t   ON res.TranID = t.post_tran_id
	--END
	 

SELECT 
		 StartDate,
		 EndDate,
         tran_type,
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
		islocalfinancial0200,
		islocalfinancial0200TrxNOTCashWdrl
		

	 
	FROM 
			@report_result
Group by startdate, enddate, tran_type,settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id,isforeignfinancial0200,islocalfinancial0200,islocalfinancial0200TrxNOTCashWdrl

        OPTION (MAXDOP 8)
	END





































































