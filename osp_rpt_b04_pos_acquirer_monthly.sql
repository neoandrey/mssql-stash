USE [isw_data]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_monthly]    Script Date: 08/26/2014 15:26:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE              PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_monthly]
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
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30),   
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
--		prev_post_tran_id		INT, 
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
		tran_amount_req         FLOAT,
		tran_amount_rsp         FLOAT,
		extended_tran_type		CHAR (4),
--		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
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
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Source node name.')
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


--
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #list_of_AcquirerInstId (AcquirerInstId	VARCHAR(50)) 
	INSERT INTO  #list_of_AcquirerInstId EXEC osp_rpt_util_split_nodenames @AcquirerInstId

SELECT 
	pan,
	card_acceptor_id_code,
	card_acceptor_name_loc,
	merchant_type,
	datetime_req,
	terminal_id,
	system_trace_audit_nr,
	dbo.formatAmount(isw.settle_amount_req, isw.settle_currency_code) AS settle_amount_req, 
	dbo.formatAmount(isw.settle_amount_rsp, isw.settle_currency_code) AS settle_amount_rsp,
	dbo.formatAmount(isw.settle_tran_fee_rsp, isw.settle_currency_code) AS settle_tran_fee_rsp,
	retrieval_reference_nr,
	dbo.calculate_msc (merchant_type,settle_amount_rsp,settle_currency_code) as msc, 
	dbo.formatAmount(isw.settle_amount_rsp, isw.settle_currency_code) - dbo.calculate_msc (merchant_type,settle_amount_rsp,settle_currency_code) as merchant_receivable,
    dbo.formatTranTypeStr(isw.tran_type, isw.extended_tran_type, isw.message_type) as tran_type_desciption,
    dbo.formatRspCodeStr(isw.rsp_code_rsp) as rsp_code_description,
    dbo.currencyNrDecimals(isw.settle_currency_code) AS settle_nr_decimals,
    dbo.currencyAlphaCode(isw.settle_currency_code) AS currency_alpha_code,
    dbo.currencyName(isw.settle_currency_code) AS currency_name,
	
CASE 

WHEN LEFT(pan, 3)= '506' THEN 'Verve Card'

WHEN LEFT(pan, 2)IN ('62','63','90','60') THEN 'Magstripe Card'

WHEN LEFT(pan, 2) IN ('51','52','53','54','55') AND LEFT(pan, 6) NOT IN ('539945','528649','521090','551609','559453','519615','528668') THEN 'MasterCard'

WHEN LEFT(pan, 6) IN ('539945','528649','521090','551609','559453','519615','528668') THEN 'MasterCard Verve Card'

WHEN LEFT(pan,1) ='4' THEN 'VisaCard'

ELSE 'Unknown Card'  
END card_brand,
	 auth_id_rsp,
	terminal_owner
FROM 

	isw_data_switchoffice isw(nolock)
where
				--isw.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				--AND
				isw.tran_completed = 1
				AND
				(isw.datetime_req >= @StartDate) 
				AND 
				(isw.datetime_req < @EndDate) 
				--AND
				--isw.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND

				(
				(isw.message_type IN ('0100','0200', '0400', '0420')) 
				)
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
                                AND  NOT  (isw.source_node_name in ('SWTNCS2src','SWTNCSKIMsrc') 
                                AND (isw.sink_node_name)+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL'))
                                --and isw.totals_group not in ('VISAGroup')
                AND
             LEFT(isw.source_node_name,2)  <> 'SB'
             AND
             LEFT(isw.sink_node_name,2)  <>  'SB'
             
END