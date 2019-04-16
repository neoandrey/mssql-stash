USE [isw_data]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer]    Script Date: 07/31/2014 16:52:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE              PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_monthly]
	@StartDate		VARCHAR(20),	-- yyyymmdd
	@EndDate	    VARCHAR(20),	-- yyyymmdd
	@Acquirer		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@merchants	VARCHAR(255),--this is the isw.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
    @rpt_tran_id1 INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (80),
		pan						VARCHAR (30), 
		terminal_id				VARCHAR (15), 
		acquiring_inst_id_code			VARCHAR(28),
		terminal_owner  		VARCHAR(32),
		merchant_type				CHAR (4),
                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		rsp_code_description	VARCHAR (30),
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
		structured_data_req		VARCHAR(70),
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
	        rdm_amount                      float,--Chioma added this 2012-07-03
                Reward_Discount                 float,--Chioma added this 2012-07-03
                Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03
                Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
                Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03
                Late_Reversal CHAR (1),
                Terminal_owner_code Varchar (4),
		totals_group		Varchar(40),
                Unique_key varchar (200),
                aggregate_column         VARCHAR(200)
              )

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'

	SET @date_selection_mode = 'Last Month'
	
	  IF (@StartDate IS NULL OR @StartDate ='' AND  (@EndDate IS NULL OR @EndDate ='')) 
      BEGIN 
		
		SELECT @StartDate =SUBSTRING( REPLACE(CONVERT(VARCHAR(10), DATEADD(MM,-1, GETDATE()),111),'/', '-'), 1, 8)+'01' ; 

        SELECT @EndDate   =REPLACE(CONVERT(VARCHAR(10),DATEADD(MM, 1, SUBSTRING( REPLACE(CONVERT(VARCHAR(10), DATEADD(MM,-1, GETDATE()),111),'/', '-'), 1, 8)+'01') ,111),'/', '-'); 
      END
			
	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	--SET @StartDate = CONVERT(VARCHAR(20), @report_date_start, 112)
	--SET @EndDate = CONVERT(VARCHAR(20), @report_date_end, 112)

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END



	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #list_of_AcquirerInstId (AcquirerInstId	VARCHAR(50)) 
	INSERT INTO  #list_of_AcquirerInstId EXEC osp_rpt_util_split_nodenames @AcquirerInstId
	
INSERT INTO 
#report_result

SELECT

				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				isw.source_node_name,
				dbo.fn_rpt_PanForDisplay(isw.pan, @show_full_pan) AS pan,
				isw.terminal_id, 
				isw.acquiring_inst_id_code,
				isw.terminal_owner,
				ISNULL(isw.merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,0),
				ISNULL(m.bearer,'M'),
				isw.card_acceptor_id_code, 
				isw.card_acceptor_name_loc, 
				isw.source_node_name,
				isw.sink_node_name, 
				isw.tran_type, 
				isw.rsp_code_rsp, 
				isw.message_type, 
				isw.datetime_req,
				dbo.formatAmount(isw.settle_amount_req, isw.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(isw.settle_amount_rsp, isw.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(isw.settle_tran_fee_rsp, isw.settle_currency_code) AS settle_tran_fee_rsp,
				
				isw.post_tran_cust_id as TranID,
				isw.prev_post_tran_id, 
				isw.system_trace_audit_nr, 
				isw.message_reason_code, 
				isw.retrieval_reference_nr, 
				isw.datetime_tran_local, 
				isw.from_account_type, 
				isw.to_account_type, 
				isw.settle_currency_code, 
				
				--dbo.formatAmount(isw.settle_amount_impact, isw.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (isw.tran_type = '51') THEN -1 * isw.settle_amount_impact
						ELSE isw.settle_amount_impact
					END
					, isw.settle_currency_code ) AS settle_amount_impact,				
				


				dbo.formatTranTypeStr(isw.tran_type, isw.extended_tran_type, isw.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(isw.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(isw.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(isw.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(isw.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				isw.tran_reversed,
				ISNULL(account_nr,'not available'),
				isnull(isw.payee,0),--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				Late_Reversal_id = CASE
						WHEN (isw.post_tran_cust_id < @rpt_tran_id1 and isw.message_type = '0420') THEN 1
						ELSE 0
					        END,
                tt.Terminal_code,
				isw.totals_group,
                 isw.retrieval_reference_nr+'_'+isw.system_trace_audit_nr+'_'+isw.terminal_id+'_'+ cast((isw.settle_amount_impact) as varchar(12))+'_'+isw.message_type,
                 isw.retrieval_reference_nr+'_'+isw.terminal_id+'_'+'000000'+'_'+cast((abs(isw.settle_amount_impact)) as varchar(12))                 
FROM 

		isw_data_switchoffice isw
		JOIN tbl_merchant_category m (NOLOCK)
		ON isw.merchant_type = m.category_code 
		JOIN tbl_merchant_account a (NOLOCK)
		ON isw.card_acceptor_id_code = a.card_acceptor_id_code  
		JOIN tbl_terminal_owner tt (NOLOCK)
		ON  isw.terminal_id = tt.terminal_id
		
WHERE 

				
				isw.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				isw.tran_completed = 1
				AND
				(isw.datetime_req >= @report_date_start) 
				AND 
				(isw.datetime_req < @report_date_end) 
				--AND
				--isw.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND

				(
				(isw.message_type IN ('0100','0200', '0400', '0420')) 
				)
				AND 
				isw.tran_completed = 1 
				AND 
				isw.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR isw.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				isw.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					( LEFT(isw.terminal_id,4)= '3IWP') OR
					(LEFT(isw.terminal_id,4) = '3ICP') OR
					(LEFT(isw.terminal_id,1) ='2' )OR--(isw.terminal_id like '2%' AND isw.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(isw.terminal_id,1) ='5') OR
                     (LEFT(isw.terminal_id,4)= '31WP') OR
					(LEFT(isw.terminal_id,4)= '31CP') OR
					(LEFT(isw.terminal_id,1)= '6')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				isw.tran_type NOT IN ('31','50')
                                and isw.merchant_type not in ('5371')	
                                AND  NOT  (isw.source_node_name in ('SWTNCS2src','SWTNCSKIMsrc') AND (isw.sink_node_name)+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(isw.pan,1) = '4')
                                and isw.totals_group not in ('VISAGroup')
                AND
             LEFT(isw.source_node_name,2)  <> 'SB'
             AND
             LEFT(isw.sink_node_name,2)  <>  'SB'
             
END