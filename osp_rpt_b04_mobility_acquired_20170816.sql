USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_mobility_acquired]    Script Date: 8/16/2017 4:21:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER procedure[dbo].[osp_rpt_b04_mobility_acquired]
	@StartDate	    CHAR(8),	-- yyyymmdd
	@EndDate	    CHAR(8),	-- yyyymmdd
	@SourceNodes	    VARCHAR(40),
   	@SinkNode           VARCHAR(40),
	@BIN		    VARCHAR(40),
	--@CBNCode	    CHAR(3),
	@show_full_pan	    BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B06 report uses this stored prot.


	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'		

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255) NULL,	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id			VARCHAR(20),
		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40),
		acquiring_inst_id_code 		VARCHAR(15),
		source_node_name		VARCHAR (40),
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
		message_reason_code			CHAR (4) NULL, 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 
		account_id_1			VARCHAR(28), 
		account_id_2			VARCHAR(28), 
        receiving_inst_id           CHAR (6),		
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			BIGINT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description			VARCHAR (255),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx				    INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx				INT,	
		tran_reversed				INT,
		extended_tran_type			CHAR(18),
		payee					CHAR(25),
		prev_tran_approved		INT , 
	    channel					VARCHAR(255)                       
	)			

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
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

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
			
	--CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 
	--INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BIN

 ;WITH post_tran_table (	
            post_tran_id,		
			post_tran_cust_id,
			sink_node_name, 
			tran_type, 
			rsp_code_rsp, 
			message_type, 
			datetime_req, 
			acquiring_inst_id_code,
			settle_amount_req,
			settle_amount_rsp,
			settle_tran_fee_rsp,
			settle_currency_code,
			tran_nr, 
			prev_post_tran_id, 
			system_trace_audit_nr, 
			message_reason_code, 
			retrieval_reference_nr, 
			datetime_tran_local, 
			from_account_type, 
			to_account_type, 
			from_account_id,  
			to_account_id,  
			structured_data_req ,
            settle_amount_impact,
			extended_tran_type,
			tran_reversed,
			payee,
			prev_tran_approved,
			channel
			) AS (
			SELECT
			    post_tran_id,
				post_tran_cust_id,
				sink_node_name, 
				t.tran_type, 
				rsp_code_rsp, 
				message_type, 
				datetime_req, 
				acquiring_inst_id_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_rsp,
				settle_currency_code,
				tran_nr, 
				prev_post_tran_id, 
				system_trace_audit_nr, 
				message_reason_code, 
				retrieval_reference_nr, 
				datetime_tran_local, 
				from_account_type, 
				to_account_type, 
				from_account_id,  
				to_account_id,  
				null ,
				settle_amount_impact,
				extended_tran_type,
				tran_reversed,
				payee,
				prev_tran_approved,
			channel  = CASE   WHEN  source_node_name  IN  ('GPRsrc','VTUsrc','VTUSTOCKsrc')  THEN  'Recharge Transactions'  
				WHEN  t.tran_type  =  '40'  THEN  'Cardholder Account Transfer Transactions'  
				WHEN  source_node_name  IN  ('GPRsrc','VTUsrc','VTUSTOCKsrc')  AND  t.tran_type  =  '00'  THEN  'Purchases'  
				WHEN  LEFT(terminal_id,1)    ='1'  AND  (  extended_tran_type  !='6110'  OR  extended_tran_type  IS  NULL)  THEN    'ATM Transfer Transactions'
				WHEN  LEFT(terminal_id,1)  ='2'  THEN  'POS Transfer Transactions'  
				WHEN  terminal_id=  '3BOL0001'  THEN  'Web ( Quickteller Website) Transfer Transactions'  
				WHEN  LEFT(terminal_id,4)  IN  ('4QTL',  '4IQT','4AQT','4WQT','4BQT','4JQT')  THEN  'QuicktellerMobile Transfer Transactions'
				WHEN  extended_tran_type='6110'  THEN  'ATM Cardless-Transfer Transactions'  
				ELSE  'Mobile Transfer Transactions'  
				END 
			FROM
			 		post_tran_summary t (NOLOCK)
			    
			    JOIN (	
										SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)  r
					on 
			    t.recon_business_date = r.recon_business_date
				join 
				( SELECT part as tran_type FROM usf_split_string('50,00,40', ',')) e
				ON
				t.tran_type = e.tran_type
				WHERE
			
			t.tran_completed = 1
			and
			t.tran_postilion_originated = 0 
			
			and
			t.acquiring_inst_id_code in (select BIN from #list_of_BINs) 
			AND
					sink_node_name NOT IN ( select part FROM usf_split_string('CCLOADsnk,GPRsnk,VTUsnk,VTUSTOCKsnk,PAYDIRECTsnk,SWTMEGAsnk,WUESBPBsnk',','))
				 AND
             t.sink_node_name  NOT LIKE 'SB%'
             and (t.extended_tran_type <> '8234' or t.extended_tran_type is null)
			
			
			), post_tran_cust_table (
				post_tran_cust_id,
				terminal_id,
				pan,
				card_acceptor_id_code, 
				card_acceptor_name_loc, 
				source_node_name
			
			) AS (
				SELECT
				
				post_tran_cust_id,
				terminal_id,
				pan,
				card_acceptor_id_code, 
				card_acceptor_name_loc, 
				source_node_name
			 FROM 
			   post_tran_summary t (NOLOCK)
			   JOIN  (	
										SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)  r
					on 
			    t.recon_business_date = r.recon_business_date
				  
			   
			   WHERE
             t.source_node_name  NOT LIKE 'SB%'
			 AND
			t.terminal_id not like '4GLO%' 					
			AND 
			t.source_node_name in (select source_node from #list_of_source_nodes) 
			

			)
			insert into #report_result
	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,

			c.terminal_id,
			C.card_acceptor_id_code, 

			c.card_acceptor_name_loc, 
			t.acquiring_inst_id_code,
			c.source_node_name,
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
			t.from_account_id,  
			t.to_account_id,  
		  NULL receiving_inst_id,  --	RIGHT(CAST(t.structured_data_req AS VARCHAR(255)), 6),
			t.settle_currency_code, 
						
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
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
			t.tran_reversed,
			extended_tran_type,
			payee,
			prev_tran_approved,
	        channel
 
	FROM
			post_tran_table t(NOLOCK) JOIN post_tran_cust_table c (NOLOCK)
		on t.post_tran_cust_id =c.post_tran_cust_id
			
	
WHERE 			
	
 				
		
			(	
           		(c.terminal_id like '4%' and card_acceptor_name_loc not like '%MCN%' and c.source_node_name <> 'BILLSsrc')
			OR
			(c.terminal_id like '2%' and t.tran_type <> '00' and (payee not like '%62805150%' OR payee is null) and c.source_node_name <> 'BILLSsrc')
			OR           		
			(
			(c.terminal_id like '1%')
			AND
			(payee not like '%62805150%' OR payee is null)
			)
			)
			AND post_tran_id  not in 
		 (SELECT post_tran_id FROM tbl_late_reversals ll (NOLOCK) ) 
		
 	
		
 OPTION (RECOMPILE, OPTIMIZE FOR UNKNOWN)


			IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			    else begin
			 UPDATE #report_result  SET  receiving_inst_id =RIGHT(CAST(t.structured_data_req AS VARCHAR(255)), 6)   FROM #report_result r JOIN post_tran t(NOLOCK) ON (r.datetime_req = t.datetime_req AND r.tranID = t.tran_nr )
			
			
			end
			
	SELECT *
	FROM
			#report_result
   
         	
	ORDER BY 
			datetime_req
			 OPTION (RECOMPILE,maxdop 8)
END






























































































































