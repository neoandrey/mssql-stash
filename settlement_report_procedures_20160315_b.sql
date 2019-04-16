USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer_bkp]    Script Date: 03/15/2016 18:58:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[osp_rpt_b04_web_acquirer_bkp]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@Acquirer		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
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
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			VARCHAR(15),
		terminal_owner  		VARCHAR(25),
		merchant_type				CHAR (4),
                extended_tran_type_reward               VARCHAR (50),--Chioma added this 2012-07-03
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
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
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		TEXT,
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
	        rdm_amount                      FLOAT,--Chioma added this 2012-07-03
                Reward_Discount                 FLOAT,--Chioma added this 2012-07-03
                Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03
                Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
                Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03
                Late_Reversal CHAR (1),
		totals_group		Varchar(40)
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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #list_of_AcquirerInstId (AcquirerInstId	VARCHAR(50)) 
	INSERT INTO  #list_of_AcquirerInstId EXEC osp_rpt_util_split_nodenames @AcquirerInstId
	-- Only look at 02xx messages that were not fully reversed.
	
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                 extended_trans_type = Case When c.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(t.extended_tran_type,'0000')end,
                                 --extended_trans_type = ISNULL(t.extended_tran_type,'0000'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,0),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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

				
				dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				0,

                                isnull(R.Reward_Discount,0),
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
				c.totals_group
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category_web m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				
                                /*left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))*/
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id
                                left JOIN Reward_Category r (NOLOCK)
                                ON (t.extended_tran_type = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
                               
	
WHERE 			
	
 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
			
				
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				AND 
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				t.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					--(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%') OR
					(c.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
                AND
                                c.source_node_name  NOT LIKE 'SB%'
                                AND
                                sink_node_name  NOT LIKE 'SB%'
			


INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 'Reward',
				dbo.fn_rpt_PanForDisplay(y.pan, @show_full_pan) AS pan,
				y.terminal_id, 
				y.acquiring_inst_id_code,
				'Reward',
				'5310',
                                extended_trans_type = 'BURN',
				'Discount Stores',
				'P',
				0.015000,
				2000,
				133333.33,
				'M',
				
				y.merchant_id, 
				substring(y.card_acceptor_name_loc,1,40), 
				'Reward',
				'Reward', 
				'00', 
				'00', 
				'0200', 
				y.trans_date,
				
				
				0, 
				0,
				0,
				0 as TranID,
				0, 
				y.stan, 
				0, 
				y.rr_number, 
				y.trans_date, 
				0, 
				0, 
				'566',
				
				0,				
				
				'Goods and Services' as tran_type_desciption,
				'Approved' as rsp_code_description,
				 2 AS settle_nr_decimals,
				'NGN' AS currency_alpha_code,
				'Naira' AS currency_name,
				
				1 	AS isPurchaseTrx,
				0 	AS isWithdrawTrx,
				0 		AS isRefundTrx,
				0 		AS isDepositTrx,
				0 		AS isInquiryTrx,
				0	AS isTransferTrx,
				0 		AS isOtherTrx,
				
				
				1,
				0,
				ISNULL(account_nr,'not available'),
				0,--oremeyi added this 2009-04-22
				'0000',
				0,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                isnull(R.Reward_Discount,0),
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                0,
				'Reward'
	FROM
				--post_tran t (NOLOCK)
				--INNER JOIN post_tran_cust c (NOLOCK)
				--ON  t.post_tran_cust_id = c.post_tran_cust_id
				--left JOIN tbl_merchant_category_web m (NOLOCK)
				--ON c.merchant_type = m.category_code 
				--left JOIN 
				tbl_xls_settlement y (NOLOCK)left JOIN 
				tbl_merchant_account a (NOLOCK)
				ON y.merchant_id = a.card_acceptor_id_code  
				

				--ON (c.terminal_id= y.terminal_id 
    --                                AND t.retrieval_reference_nr = y.rr_number 
    --                                --AND t.system_trace_audit_nr = y.stan
    --                                --AND (-1 * t.settle_amount_impact)/100 = y.amount
    --                                AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
    --                                = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
    --                             and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code
	WHERE 			
				
				(y.trans_date >= @report_date_start) 
				AND 
				(y.trans_date <= @report_date_end+1) 
				AND 
				y.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR y.merchant_id IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				and ISNULL(y.rdm_amt,0) <>0
                 and LEFT(y.terminal_id,1) = '3'
                 and y.extended_trans_type is not null
			
								
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END


















































































































































































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_payment_gateway_bkp]    Script Date: 03/15/2016 18:58:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















ALTER PROCEDURE [dbo].[osp_rpt_b04_payment_gateway_bkp]
	@StartDate	    CHAR(8),	-- yyyymmdd
	@EndDate	    CHAR(8),	-- yyyymmdd
	@SourceNodes	    VARCHAR(40),
   	@terminal_IDs         VARCHAR(40),
   	@SinkNode           VARCHAR(40),
	@BINs		    VARCHAR(40),
	@CBNCode	    CHAR(3),
	@show_full_pan	    BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B06 report uses this stored proc.
	

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
		source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID					BIGINT, 
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
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			BIGINT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description			VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx				INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx				INT,	
		tran_reversed				INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		totals_group			varchar(12),
                extended_tran_type            char (4)          
	)			

	IF (@Terminal_IDs IS NULL or Len(@Terminal_IDs)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Terminal ID parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
    
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
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 

	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs

        CREATE TABLE #list_of_sink_nodes (SinkNode	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode

   SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
        
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT


	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			CASE WHEN @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
		ELSE
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) 
			END AS pan,
			c.terminal_id,
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			c.source_node_name,
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
			t.from_account_id,
			t.to_account_id,  
			RIGHT(CAST(t.structured_data_req AS VARCHAR(255)), 6),
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.tran_reversed,
			c.pan_encrypted,
			t.from_account_id,
			t.to_account_id,
			t.payee,
			c.totals_group,
                        isnull(t.extended_tran_type,'0000')	
	FROM
			post_tran t (NOLOCK) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id) 
                                
                       

	
WHERE 			
	
--NOT (t.tran_nr+t.online_system_id in (select tran_nr+online_system_id from tbl_late_reversals) 
--and t.message_type = '0420'  and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1)
	 		
--			--c.post_tran_cust_id >= @rpt_tran_id			
--			AND
			t.tran_completed = 1
			AND
				(t.post_tran_id >= @first_post_tran_id   )
				AND
				( t.post_tran_id <= @last_post_tran_id   ) 	
				AND 
				t.datetime_req >=@report_date_start
				AND
			t.tran_postilion_originated = 0
			AND
			((
			t.tran_type = ('50')--this won't work for Autopay CCLoad cos the intrabank trans are 00
			AND
			t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
			AND
			source_node_name NOT IN ('CCLOADsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.tran_completed = 1 
			AND
           		(
			c.terminal_id like '3IGW%'
			OR
           		c.terminal_id like '3ADPS%'
			OR
           		c.terminal_id like '3CCW%'
			OR
           		c.terminal_id like '3IBH%'
			OR
			c.terminal_id like '3CPD%'
			OR
			c.terminal_id like '3011%'
                        OR
			c.terminal_id ='3EPY0701'
                        OR
			c.terminal_id ='3UIB0001'
			OR
			c.terminal_id ='3IPD0010'
			OR
			c.terminal_id ='3IPDTROT'
			OR 
			c.terminal_id ='3VRV0001'
			OR 
			c.terminal_id ='3IGW0010'
			OR 
			c.terminal_id = '3SFX0014'
                        OR 
		        (c.terminal_id = '3BOL0001' and t.extended_tran_type = '8502')
			OR
			c.terminal_id like '3SFA%'
			)
			)OR
			c.terminal_id like '3CPD%' and t.tran_type = ('00')
			OR
			(c.terminal_id like '3IPDFDT%' OR c.terminal_id like '3QTL002%') and message_type in ('0200','0420') and source_node_name <>'VTUsrc'
			
			)
         		
			AND 
			( 
			   (@SinkNode IS NULL OR LEN(@SinkNode) = 0)
			OR (t.sink_node_name in (SELECT SinkNode FROM #list_of_sink_nodes)) 
			OR (substring(t.sink_node_name,4,3) in (select substring (SinkNode,4,3) from #list_of_sink_nodes))--and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			OR (LEFT(pan,6)IN (SELECT BIN FROM #list_of_BINs)and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			OR LEFT(pan,6) = '628051' and (substring(c.totals_group,1,3)in (select substring (SinkNode,4,3) from #list_of_sink_nodes)) and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes)
			) 
            AND
                left(c.source_node_name,2) <> 'SB'
                   AND
               left( t.sink_node_name   ,2) <> 'SB'
				
             and 
	     (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
			
				
	


IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
	--ELSE
	--BEGIN
	--	--
	--	-- Decrypt PAN information if necessary
	--	--

	--	DECLARE @pan VARCHAR (19)
	--	DECLARE @pan_encrypted CHAR (18)
	--	DECLARE @pan_clear VARCHAR (19)
	--	DECLARE @process_descr VARCHAR (100)

	--	SET @process_descr = 'Office B04 Report'

	--	-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
	--	DECLARE pan_cursor CURSOR FORWARD_ONLY
	--	FOR
	--		SELECT
	--				pan,
	--				pan_encrypted
	--		FROM
	--				#report_result
	--	FOR UPDATE OF pan

	--	OPEN pan_cursor

	--	DECLARE @error INT
	--	SET @error = 0

	--	IF (@@CURSOR_ROWS <> 0)
	--	BEGIN
	--		FETCH pan_cursor INTO @pan, @pan_encrypted
	--		WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
	--		BEGIN
	--			-- Handle the decrypting of PANs
	--			EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

	--			-- Update the row if its different
	--			IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
	--			BEGIN
	--				UPDATE
	--					#report_result
	--				SET
	--					pan = @pan_clear
	--				WHERE
	--					CURRENT OF pan_cursor
	--			END

	--			FETCH pan_cursor INTO @pan, @pan_encrypted
	--		END
	--	END

	--	CLOSE pan_cursor
	--	DEALLOCATE pan_cursor

	--END			
	SELECT *
	FROM
			#report_result
	ORDER BY 
			datetime_req
END



























































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_cashcard_load_bkp]    Script Date: 03/15/2016 18:58:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO













ALTER PROCEDURE [dbo].[osp_rpt_cashcard_load_bkp]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@CBNCodes		VARCHAR(40),
	@totalsgroups		VARCHAR(40),
	@ALLBINs		VARCHAR(255),
	@show_full_pan		BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL

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
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40), 
		acquiring_inst_id_code		VARCHAR(25),
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40),
		structured_data_req		TEXT, 
		--prepaid_merchandise		VARCHAR(512),
		to_cashcard_account_id	VARCHAR (512),
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
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
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR(18),
		extended_tran_type		CHAR (18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(512),
		totals_group			Char(25),
		Bank_institution_name		varchar(50)      

	)

	
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


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_totalsgroup (bin VARCHAR(30))
	INSERT INTO  #list_of_totalsgroup EXEC osp_rpt_util_split_nodenames @totalsgroups

	CREATE TABLE #list_of_bins (bin VARCHAR(30))
	INSERT INTO  #list_of_bins EXEC osp_rpt_util_split_nodenames @ALLBINs
	
	CREATE TABLE #list_of_CBNCodes (CBNCode VARCHAR(30))
	INSERT INTO  #list_of_CBNCodes EXEC osp_rpt_util_split_nodenames @CBNCodes

	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
	
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				c.source_node_name,
				c.pan,
				--dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				1,
				CASE
					WHEN t.tran_type = '21'THEN c.pan		
					ELSE t.payee 
				END AS to_cashcard_account_id,
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				

				dbo.formatAmount( 			
					CASE						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
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
				c.pan_encrypted,
				extended_tran_type,
				from_account_id,
				to_account_id,
				payee,
				totals_group,
				1--'bank_institution_name' =(SELECT TOP 1 BANK_INSTITUTION_NAME FROM acquirer_institution_table  WHERE INST_SINK_CODE = substring(substring(t.sink_node_name,4, LEN(t.sink_node_name)), 1,len(substring(t.sink_node_name,4, LEN(t.sink_node_name)))-3) ) 	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				--LEFT JOIN 
				--acquirer_institution_table  d (NOLOCK) ON substring (t.sink_node_name,4,3) = d.inst_sink_code
	WHERE 
				
				t.tran_completed = 1
				AND				
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND				
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0200', '0220', '0400', '0420'))
				
				)
				AND
				tran_type <> 39	
				AND 
				((c.source_node_name = 'CCLOADsrc')
				 OR
				(LEFT(pan,7)= '6280512' and tran_type =21))
				AND
				(
					LEFT(pan,6) IN (SELECT bin FROM #list_of_bins) --their debit Card doing the loading
					OR
					LEFT(pan,11) IN (SELECT bin FROM #list_of_bins)--their cashcard doing the loading
					OR

					--(LEFT(pan,7)= '6280512' and (SUBSTRING(c.totals_group,1,3)= substring(@SinkNode,4,3)) ) --their other interswitch card e.g autopay card  doing the loading
					 --(sink_node_name= 'CCLOADsnk') OR--their other interswitch card e.g autopay card  doing the loading				
					
					(--LEFT(pan,6)like '628051%' and 
                                        (SUBSTRING(c.totals_group,1,3)in (select substring(sink_node,4,3) FROM #list_of_sink_nodes))) --and sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)) --their other interswitch card e.g autopay card  doing the loading
					OR 
					(
                                         SUBSTRING(payee,9,3) IN (SELECT CBNCode FROM #list_of_CBNCodes)
                                         or (len(payee) = 25 and SUBSTRING(payee,15,3) IN (SELECT CBNCode FROM #list_of_CBNCodes))) --their CashCard being loaded
					OR
					(
						t.acquiring_inst_id_code IN (SELECT bin FROM #list_of_bins)--other cards using their terminals to load cards that aint theirs 
						and 
						t.settle_tran_fee_rsp <> 0
					
					)
				)
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
	ORDER BY 
			datetime_tran_local, source_node_name
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
		
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B04 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor

	END	
	SELECT 
			*
	FROM 
			#report_result
			
	
END




 




 








































































GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown_reward]    Script Date: 03/15/2016 18:58:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO























ALTER PROCEDURE [dbo].[psp_settlement_summary_breakdown_reward](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL
)
AS
BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))


print(cast(getdate() as varchar(255)) + ': inserting distinct date into settlement_summary_session')

INSERT 
                               INTO settlement_summary_session
       SELECT distinct (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)) + '_Reward'
       FROM   tbl_xls_settlement AS Y (NOLOCK)

        where 
             (Y.trans_date >= @from_date AND Y.trans_date < (@to_date+1))
             

	Group by Y.trans_date

IF(@@ERROR <>0)
RETURN

print(cast(getdate() as varchar(255)) + ': inserted distinct date')



SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @from_date
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 


SELECT pt.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id
INTO ##TEMP_TRANSACTIONS_REWARD FROM post_tran PT (NOLOCK) JOIN post_tran_cust PTC (NOLOCK) ON
PT.post_tran_cust_id = PTC.post_tran_cust_id
WHERE 
       (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	  AND
      PT.tran_postilion_originated = 0
      AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc','SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
      AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
      AND PT.tran_type = '00'
      AND PT.rsp_code_rsp in ('00','11','09')
      
      AND (pt.recon_business_date >= @from_date AND pt.recon_business_date < (@to_date+1))
      AND PT.tran_completed = 1
      and not  (ptc.merchant_type in ('5371') and left(ptc.terminal_id,1) in ('2','5','6'))
      and pt.sink_node_name not like 'SB%'
      and ptc.source_node_name not like 'SB%'


print(cast(getdate() as varchar(255)) + ': create temp_trxn')


CREATE TABLE #report_result
	(
		bank_code				VARCHAR (10),
		trxn_category				VARCHAR (50),  
		Debit_Account_type		        VARCHAR (50), 
		Credit_Account_type 		        VARCHAR (50),
		trxn_amount				float, 
		trxn_fee 				float, 
                trxn_date                               VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result')
INSERT INTO #report_result
   --(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date)




SELECT  
	bank_code = CASE  WHEN (substring(t.sink_node_name,4,3) = 'UBA') THEN 'UBA'
	                  WHEN (substring(t.sink_node_name,4,3) = 'FBN') THEN 'FBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ZIB') THEN 'ZIB' 
                          WHEN (substring(t.sink_node_name,4,3) = 'SPR') THEN 'ENT'
                          WHEN (substring(t.sink_node_name,4,3) = 'GTB') THEN 'GTB'
                          WHEN (substring(t.sink_node_name,4,3) = 'PRU') THEN 'SKYE'
                          WHEN (substring(t.sink_node_name,4,3) = 'OBI') THEN 'EBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'WEM') THEN 'WEMA'
                          WHEN (substring(t.sink_node_name,4,3) = 'AFR') THEN 'MSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'CHB') THEN 'IBTC'
                          WHEN (substring(t.sink_node_name,4,3) = 'PLA') THEN 'KSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBP') THEN 'UBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'DBL') THEN 'DBL'
                          WHEN (substring(t.sink_node_name,4,3) = 'FCM') THEN 'FCMB'
                          WHEN (substring(t.sink_node_name,4,3) = 'IBP') THEN 'IBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBN') THEN 'UBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ETB') THEN 'ETB'
                          WHEN (substring(t.sink_node_name,4,3) = 'FBP') THEN 'FBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'SBP') THEN 'SBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABP') THEN 'ABP'
                          WHEN (substring(t.sink_node_name,4,3) = 'EBN') THEN 'EBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'CIT') THEN 'CITI'


                          WHEN (substring(t.sink_node_name,4,3) = 'FIN') THEN 'FIN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ASO') THEN 'ASO'
                          WHEN (substring(t.sink_node_name,4,3) = 'OLI') THEN 'OLI'
                          WHEN (substring(t.sink_node_name,4,3) = 'HSL') THEN 'HSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABS') THEN 'ABS'

                          WHEN (substring(t.sink_node_name,4,3) = 'PAY') THEN 'PAY'
                          WHEN (substring(t.sink_node_name,4,3) = 'SAT') THEN 'SAT'
                          WHEN (substring(t.sink_node_name,4,3) = '3LC') THEN '3LCM'
                          WHEN (substring(t.sink_node_name,4,3) = 'SCB') THEN 'SCB'
                          WHEN (substring(t.sink_node_name,4,3) = 'JBP') THEN 'JBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'JAI') THEN 'JBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'RSL') THEN 'RSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'RES') THEN 'RSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'PSH') THEN 'PSH'
                          WHEN (substring(t.sink_node_name,4,3) = 'ACC') THEN 'ACCI'
                          WHEN (substring(t.sink_node_name,4,3) = 'EKO') THEN 'EKON'
                          WHEN (substring(t.sink_node_name,4,3) = 'ATM') THEN 'ATMC'

						  WHEN (substring(t.sink_node_name,4,3) = 'HBC') THEN 'HBC'
						  WHEN (substring(t.sink_node_name,4,3) = 'UNI') THEN 'UNI'
						  WHEN (substring(t.sink_node_name,4,3) = 'UnC') THEN 'UnC'
						  WHEN (substring(t.sink_node_name,4,3) = 'HAG') THEN 'HAG'
						  WHEN (substring(t.sink_node_name,4,3) = 'EXP') THEN 'DBL'
						  WHEN (substring(t.sink_node_name,4,3) = 'FGM') THEN 'FGMB'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'CEL') THEN 'CEL'
						  WHEN (substring(t.sink_node_name,4,3) = 'RDY') THEN 'RDY'
						  WHEN (substring(t.sink_node_name,4,3) = 'AMJ') THEN 'AMJU'
						  WHEN (substring(t.sink_node_name,4,3) = 'UML') THEN 'UML'
						  WHEN (substring(t.sink_node_name,4,3) = 'CAP') THEN 'O3CAP'
						  WHEN (substring(t.sink_node_name,4,3) = 'VER') THEN 'VER_GLOBAL'
						  WHEN (substring(t.sink_node_name,4,3) = 'SMF') THEN 'SMFB'
						  WHEN (substring(t.sink_node_name,4,3) = 'SLT') THEN 'SLTD'
						  WHEN (substring(t.sink_node_name,4,3) = 'JES') THEN 'JES'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'MUT') THEN 'MUT'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'MOU') THEN 'MOUA'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'JUB') THEN 'JUB'
												  WHEN (substring(t.sink_node_name,4,3) = 'WET') THEN 'WET'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'LAV') THEN 'LAV'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'AGH') THEN 'AGH'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'TRU') THEN 'TRU'
												  WHEN (substring(t.sink_node_name,4,3) = 'CON') THEN 'CON'
WHEN (substring(t.sink_node_name,4,3) = 'CRU') THEN 'CRU'
WHEN (substring(t.sink_node_name,4,3) = 'NPR') THEN 'NPR'

			 ELSE 'UNK'			
END,
	trxn_category= Case when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME'
                            --when (substring(y.extended_trans_type,1,1) = '7') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT'
                            when (substring(y.extended_trans_type,1,1) = '9') then 'REWARD MONEY (SPEND) POS FEE SETTLEMENT'
                           else substring(y.extended_trans_type,1,1)
                            end,

        Debit_account_type=    'ISSUER FEE PAYABLE(Debit_Nr)',
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)' ,
                          

        amt= 0,
	fee= isnull(CASE WHEN  (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact))))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100)
                  END,0),
       (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (NOLOCK)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
     -- or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (SUBSTRING(t.Terminal_id,1,1)= '1' or SUBSTRING(t.Terminal_id,1,1)= '0'))
     -- or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (SUBSTRING(t.Terminal_id,1,1)= '1' or SUBSTRING(t.Terminal_id,1,1)= '0')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    

     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'




     and t.merchant_type not in ('5371')	
   

     and substring(y.extended_trans_type,1,1) in ('9','8') 

GROUP BY 
 substring(t.sink_node_name,4,3),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
--t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
y.extended_trans_type,
t.retrieval_reference_nr,
t.settle_amount_impact,
c.amount_cap


CREATE TABLE #report_result1
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 1')
INSERT INTO #report_result1

SELECT  
	bank_code = CASE  WHEN (substring(t.sink_node_name,4,3) = 'UBA') THEN 'UBA'
	                  WHEN (substring(t.sink_node_name,4,3) = 'FBN') THEN 'FBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ZIB') THEN 'ZIB' 
                          WHEN (substring(t.sink_node_name,4,3) = 'SPR') THEN 'ENT'
                          WHEN (substring(t.sink_node_name,4,3) = 'GTB') THEN 'GTB'
                          WHEN (substring(t.sink_node_name,4,3) = 'PRU') THEN 'SKYE'
                          WHEN (substring(t.sink_node_name,4,3) = 'OBI') THEN 'OBI'
                          WHEN (substring(t.sink_node_name,4,3) = 'WEM') THEN 'WEMA'
                          WHEN (substring(t.sink_node_name,4,3) = 'AFR') THEN 'MSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'CHB') THEN 'IBTC'
                          WHEN (substring(t.sink_node_name,4,3) = 'PLA') THEN 'KSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBP') THEN 'UBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'DBL') THEN 'DBL'
                          WHEN (substring(t.sink_node_name,4,3) = 'FCM') THEN 'FCMB'
                          WHEN (substring(t.sink_node_name,4,3) = 'IBP') THEN 'IBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBN') THEN 'UBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ETB') THEN 'ETB'
                          WHEN (substring(t.sink_node_name,4,3) = 'FBP') THEN 'FBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'SBP') THEN 'SBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABP') THEN 'ABP'
                          WHEN (substring(t.sink_node_name,4,3) = 'EBN') THEN 'EBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'CIT') THEN 'CITI'

                          WHEN (substring(t.sink_node_name,4,3) = 'FIN') THEN 'FIN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ASO') THEN 'ASO'
                          WHEN (substring(t.sink_node_name,4,3) = 'OLI') THEN 'OLI'
                          WHEN (substring(t.sink_node_name,4,3) = 'HSL') THEN 'HSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABS') THEN 'ABS'

                          WHEN (substring(t.sink_node_name,4,3) = 'PAY') THEN 'PAY'
                          WHEN (substring(t.sink_node_name,4,3) = 'SAT') THEN 'SAT'
                          WHEN (substring(t.sink_node_name,4,3) = '3LC') THEN '3LCM'

                          WHEN (substring(t.sink_node_name,4,3) = 'SCB') THEN 'SCB'
                          WHEN (substring(t.sink_node_name,4,3) = 'JBP') THEN 'JBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'JAI') THEN 'JBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'RSL') THEN 'RSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'RES') THEN 'RSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'PSH') THEN 'PSH'
                          WHEN (substring(t.sink_node_name,4,3) = 'ACC') THEN 'ACCI'
                          WHEN (substring(t.sink_node_name,4,3) = 'EKO') THEN 'EKON'

                          WHEN (substring(t.sink_node_name,4,3) = 'ATM') THEN 'ATMC'
                          WHEN (substring(t.sink_node_name,4,3) = 'HBC') THEN 'HBC'
                          WHEN (substring(t.sink_node_name,4,3) = 'UNI') THEN 'UNI'
                          WHEN (substring(t.sink_node_name,4,3) = 'UnC') THEN 'UnC'
			  WHEN (substring(t.sink_node_name,4,3) = 'HAG') THEN 'HAG'
			  WHEN (substring(t.sink_node_name,4,3) = 'EXP') THEN 'DBL'
			  WHEN (substring(t.sink_node_name,4,3) = 'FGM') THEN 'FGMB'
                          WHEN (substring(t.sink_node_name,4,3) = 'CEL') THEN 'CEL'
			  WHEN (substring(t.sink_node_name,4,3) = 'RDY') THEN 'RDY'
			  WHEN (substring(t.sink_node_name,4,3) = 'AMJ') THEN 'AMJU'
			  WHEN (substring(t.sink_node_name,4,3) = 'UML') THEN 'UML'
			  WHEN (substring(t.sink_node_name,4,3) = 'CAP') THEN 'O3CAP'
			  WHEN (substring(t.sink_node_name,4,3) = 'VER') THEN 'VER_GLOBAL'
			  WHEN (substring(t.sink_node_name,4,3) = 'SMF') THEN 'SMFB'
			  WHEN (substring(t.sink_node_name,4,3) = 'WET') THEN 'WET'
			  WHEN (substring(t.sink_node_name,4,3) = 'SLT') THEN 'SLTD'
			  WHEN (substring(t.sink_node_name,4,3) = 'JES') THEN 'JESMFB'
			  WHEN (substring(t.sink_node_name,4,3) = 'MUT') THEN 'MUT'	
			  WHEN (substring(t.sink_node_name,4,3) = 'CON') THEN 'CON'


			 ELSE 'UNK'			
END,
	trxn_category= Case when (substring(o.r_code,1,1) = '8') then 'SAVERSCARD REWARD SCHEME'
                            else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT'
                            end,

        Debit_account_type=    'ISSUER FEE PAYABLE(Debit_Nr)',
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)' ,
                          

        amt= 0,
	fee= isnull(CASE WHEN  (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact))))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap)
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100)
                  END,0),



       (substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
                              
       left JOIN tbl_reward_OutOfBand O (NOLOCK)
       ON t.terminal_id = o.terminal_id
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)                           
   
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	
   

    and (substring(o.r_code,1,1) in ('9','8') and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY 
 substring(t.sink_node_name,4,3),
o.r_code,


--t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11)),
t.retrieval_reference_nr,
t.settle_amount_impact,
c.amount_cap


CREATE TABLE #report_result2
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 2')
INSERT INTO #report_result2

SELECT  
	bank_code = CASE  WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FBN'
			  ELSE 'FBN'
                          END,			

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
	                    WHEN (substring(y.extended_trans_type,1,4) = '3000') THEN 'FORTE OIL REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    'ISSUER FEE PAYABLE(Debit_Nr)',
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)',
                          



        amt= 0,


	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 160000) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.0075* y.rdm_amt*100))

	          WHEN  (abs(y.rdm_amt) >= 160000)
                  THEN sum(1200*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
  -- ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
  
   --LEFT OUTER JOIN 
   tbl_xls_settlement y (nolock)
/* ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                               
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code */

WHERE /*t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09') */

      -- (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
       (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))
      
     /*AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	*/
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '2'
     

GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

--dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap),
y.trans_date,y.extended_trans_type,
--t.retrieval_reference_nr,
y.rdm_amt
--c.amount_cap


CREATE TABLE #report_result3
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 3')
INSERT INTO #report_result3

SELECT  
	bank_code = 'FBN',			

	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',

     Debit_account_type=   'AMOUNT PAYABLE(Debit_Nr)',
                          
     Credit_account_type= 'FEE POOL(Credit_Nr)' ,
                          

      amt= sum(y.rdm_amt*100),
	  fee= 0,

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
  
    tbl_xls_settlement y (nolock)
--ON 
   --(t.terminal_id= y.terminal_id 

   --AND t.retrieval_reference_nr = y.rr_number 
   ----AND (-1 * t.settle_amount_impact)/100 = y.amount
   --AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   --= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
   --left JOIN Reward_Category r (NOLOCK)
   --ON substring(y.extended_trans_type,1,4) = r.reward_code
   --left JOIN tbl_merchant_category_web c (NOLOCK)
   --on t.merchant_type = c.category_code 

WHERE 
 (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))

and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '3'

--t.tran_postilion_originated = 0

--      AND t.tran_type = '00'
--      AND t.rsp_code_rsp in ('00','11','09')

--      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
--      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
--      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
--     -- or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
--      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
--     AND t.tran_completed = 1
    
--     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
--     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
--     --AND t.pan not like '4%'


--     --and t.merchant_type not in ('5371')	
   

--     and (y.rdm_amt < 0 or y.rdm_amt > 0)
--     and y.extended_trans_type is not null
     

GROUP BY 
y.trans_date,y.extended_trans_type,
y.rdm_amt





CREATE TABLE #report_result4
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 4')
INSERT INTO #report_result4

SELECT  
	bank_code = CASE  WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FBN'
			  ELSE 'ISW'
                          END,			

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
	                    WHEN (substring(y.extended_trans_type,1,4) = '3000') THEN 'FORTE OIL REWARD SCHEME'

                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISSUER FEE RECEIVABLE(Credit_Nr)' ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 160000) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.3*0.0075* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 160000) 
                  THEN sum(0.3*1200*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   --##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   --LEFT OUTER JOIN 
   
   tbl_xls_settlement y (nolock)
/* ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount

   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code */

WHERE --t.tran_postilion_originated = 0
      --AND t.tran_type = '00'
      --AND t.rsp_code_rsp in ('00','11','09')

      --AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      --AND 
      (trans_date >= @from_date AND trans_date < (@to_date+1))
      
     /*AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'



     and t.merchant_type not in ('5371')*/	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '2'
     


GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

y.rdm_amt,--t.retrieval_reference_nr,c.amount_cap,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result5
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 5')
INSERT INTO #report_result5

SELECT  
	bank_code =  'ISW',		

	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISSUER and SWT FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 133333.33) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.625*0.015* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 133333.33) 
                  THEN sum(0.625*2000*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   tbl_xls_settlement y (nolock)


WHERE 
 (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))

and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '3'

				
										
     
     


GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

y.rdm_amt,

y.trans_date,y.extended_trans_type

CREATE TABLE #report_result6
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 6')
INSERT INTO #report_result6

SELECT  
	bank_code = 'ISW',			
	


	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
	                    WHEN (substring(y.extended_trans_type,1,4) = '3000') THEN 'FORTE OIL REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 160000) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.05*0.0075* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 160000) 
                  THEN sum(0.05*1200*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
  -- ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)

   --LEFT OUTER JOIN 
   tbl_xls_settlement y (nolock)
/*ON 

   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code */

WHERE --t.tran_postilion_originated = 0
      --AND t.tran_type = '00'
      --AND t.rsp_code_rsp in ('00','11','09')

      --AND (y.rdm_amt<> 0  and t.message_type   in ('0200','0220')
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0  and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      (trans_date >= @from_date AND trans_date < (@to_date+1))
      
    /* AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')*/
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '2'
     


GROUP BY 
-- t.sink_node_name,
-- y.trans_date,

y.rdm_amt,


(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result7
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 7')
INSERT INTO #report_result7

SELECT  
	bank_code = 'ISW',

        

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME PTSO'
	                    WHEN (substring(y.extended_trans_type,1,4) = '3000') THEN 'FORTE OIL REWARD SCHEME PTSO'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT PTSO'
                       END,


        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 160000) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.25*0.0075* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 160000) 

                  THEN sum(0.25*1200*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   --##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   --LEFT OUTER JOIN 
   tbl_xls_settlement y (nolock)

/*ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code */

WHERE --t.tran_postilion_originated = 0
      --AND t.tran_type = '00'

      --AND t.rsp_code_rsp in ('00','11','09')

      --AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))

      
    -- AND t.tran_completed = 1
    
    -- AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     -- AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     --and t.merchant_type not in ('5371')	

   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '2'
     


GROUP BY 
-- t.sink_node_name,
-- y.trans_date,

y.rdm_amt, --,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result8
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 8')
INSERT INTO #report_result8

SELECT  
	bank_code = 'ISW',		

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME PTSP'
	                    WHEN (substring(y.extended_trans_type,1,4) = '3000') THEN 'FORTE OIL REWARD SCHEME PTSP'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT PTSP'
                       END,

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW FEE RECEIVABLE(Credit_Nr)',
                          


        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 160000) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.25*0.0075* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 160000) 
                  THEN sum(0.25*1200*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   --##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   --LEFT OUTER JOIN 
   tbl_xls_settlement y (nolock)
/*ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code */

WHERE --t.tran_postilion_originated = 0
      --AND t.tran_type = '00'
      --AND t.rsp_code_rsp in ('00','11','09')

      --AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
     -- or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
       (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))
      
     --AND t.tran_completed = 1
    
     --AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
    -- AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     --and t.merchant_type not in ('5371')	

   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '2'
     


GROUP BY 
-- t.sink_node_name,
-- y.trans_date,

y.rdm_amt,--t.retrieval_reference_nr,c.amount_cap,
 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type


CREATE TABLE #report_result10
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 10')
INSERT INTO #report_result10

SELECT  
	bank_code = 'NCS',

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
	                    WHEN (substring(y.extended_trans_type,1,4) = '3000') THEN 'FORTE OIL REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,


        Debit_account_type=   'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'NCS FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 160000) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.075*0.0075* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 160000) 
                  THEN sum(0.075*1200*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   --##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   --LEFT OUTER JOIN 
   tbl_xls_settlement y (nolock)
/*ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code */

WHERE --t.tran_postilion_originated = 0
      --AND t.tran_type = '00'
      --AND t.rsp_code_rsp in ('00','11','09')

      --AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
       (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))
      
     --AND t.tran_completed = 1
    
     --AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				

										
     --AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


    -- and t.merchant_type not in ('5371')	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '2'
     


GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

y.rdm_amt,--t.retrieval_reference_nr,c.amount_cap,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), y.extended_trans_type

CREATE TABLE #report_result11
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 11')
INSERT INTO #report_result11

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN (substring(y.extended_trans_type,1,1) = '9' 
                   and substring(y.extended_trans_type,1,4) not in ('9080')
                   and substring(y.extended_trans_type,4,1) <> '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.025 * (-1 * t.settle_amount_impact)))

                   WHEN (substring(y.extended_trans_type,1,1) = '9'
                    and substring(y.extended_trans_type,1,4) not in ('9080') 
                   and substring(y.extended_trans_type,4,1) = '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.03 * (-1 * t.settle_amount_impact)))   

                   WHEN (substring(y.extended_trans_type,1,4) in ('9080'))
 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact)))             
             		
END,0),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)

     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
     and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(y.extended_trans_type,1,1) = '9'

GROUP BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
 y.extended_trans_type



CREATE TABLE #report_result12
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 12')
INSERT INTO #report_result12

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN (substring(o.r_code,1,1) = '9' 
                   and substring(o.r_code,1,4) not in ('9080')
                   and substring(o.r_code,4,1) <> '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.025 * (-1 * t.settle_amount_impact)))

                   WHEN (substring(o.r_code,1,1) = '9'
                    and substring(o.r_code,1,4) not in ('9080') 

                   and substring(o.r_code,4,1) = '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.03 * (-1 * t.settle_amount_impact)))   

                   WHEN (substring(o.r_code,1,4) in ('9080'))
 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact)))             
             		
END,0),





	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)                          
	left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.terminal_id = o.terminal_id
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))

     -- or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and (substring(o.r_code,1,1) = '9'and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY 
-- y.trans_date,
o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))


CREATE TABLE #report_result13
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 13')
INSERT INTO #report_result13



SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  

                          

        amt= 0,

	fee= isnull(sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact))),0),

                 


	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             		

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    AND (-1 * t.settle_amount_impact/100) = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               

                                 

	left JOIN Reward_Category r (NOLOCK)
        ON (t.extended_tran_type = r.reward_code )

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(t.extended_tran_type,1,1) = '7'


GROUP BY 
-- y.trans_date,
 t.extended_tran_type,

(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             		



CREATE TABLE #report_result14
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 14')
INSERT INTO #report_result14

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact))),0),

       (substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)                          
	left JOIN tbl_reward_OutOfBand O (NOLOCK)

        ON t.terminal_id = o.terminal_id
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				

										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and (substring(o.r_code,1,1) = '7' and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))


GROUP BY 
-- y.trans_date,
o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))




CREATE TABLE #report_result15
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 15')
INSERT INTO #report_result15




SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'

                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'


                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'

                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'
               

			 ELSE 'UNK'			
END,
	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee=  isnull(Case when(substring(y.extended_trans_type,1,4) in ('9080')) then 
             SUM(0.15*(0.0075*(-1 * (t.settle_amount_impact))))
             else 
             SUM(0.15*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),
        (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
     and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(y.extended_trans_type,1,1) = '9'

GROUP BY 
 t.acquiring_inst_id_code,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result16
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 16')
INSERT INTO #report_result16

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 

                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
			  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'
			
               

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee=  isnull(Case when(substring(o.r_code,1,4) in ('9080')) then 
             SUM(0.15*(0.0075*(-1 * (t.settle_amount_impact))))
             else 
             SUM(0.15*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.terminal_id = o.terminal_id
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and (substring(o.r_code,1,1) = '9' and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY 
 t.acquiring_inst_id_code,o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
 --y.trans_date

--

CREATE TABLE #report_result17
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 17')
INSERT INTO #report_result17



SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
               		  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Merchant Additional Reward Fee Payable(Debit_Nr)',

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
          
                          

        amt= 0,
	fee= --CASE WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 1) 
                  --THEN 
                   isnull(sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))),0)

	         -- WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 2) 
                 --THEN -sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap)
                  --END
                     ,
         

	business_date = (substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    AND (-1 * t.settle_amount_impact/100) = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               
                                  
	left JOIN Reward_Category r (NOLOCK)
        ON (t.extended_tran_type = r.reward_code)
left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )

      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and left(t.extended_tran_type,1) = '7'
    

GROUP BY 
 t.acquiring_inst_id_code,t.extended_tran_type,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
--dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap )
 --y.trans_date

CREATE TABLE #report_result18
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)

         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 18')
INSERT INTO #report_result18

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
			  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'
               

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Merchant Additional Reward Fee Payable(Debit_Nr)',  

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
        
                          

        amt= 0,
	fee= --CASE WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 1) 
                  --THEN 
                   isnull(sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))),0)

	          --WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 2) 
                  --THEN -sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap) END
                  ,
         

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
                  
             
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.terminal_id = o.terminal_id 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)
left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0

      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')
	
     and (substring(o.r_code,1,1) = '7' and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))


GROUP BY 
 t.acquiring_inst_id_code,o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
--dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) 
 --y.trans_date
--

CREATE TABLE #report_result19
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 19')
INSERT INTO #report_result19

SELECT		
	bank_code = CASE  WHEN  y.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  y.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  y.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  y.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  y.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  y.acquiring_inst_id_code = '627805' THEN 'SKYE'

                          WHEN  y.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  y.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  y.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  y.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  y.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  y.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  y.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  y.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  y.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  y.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  y.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  y.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  y.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  y.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  y.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  y.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  y.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  y.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  y.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  y.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  y.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  y.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  y.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
	                    WHEN (substring(y.extended_trans_type,1,4) = '3000') THEN 'FORTE OIL REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 160000) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.075*0.0075* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 160000) 
                  THEN sum(0.075*1200*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
--##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
--LEFT OUTER JOIN 
tbl_xls_settlement y (nolock)
/* on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
    and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
 left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code */

WHERE --t.tran_postilion_originated = 0
      --AND t.tran_type = '00'
      --AND t.rsp_code_rsp in ('00','11','09')

      --AND (y.rdm_amt<> 0  and t.message_type   in ('0200','0220')
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
       (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))
      
     --AND t.tran_completed = 1
    
     --AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     --AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     --and t.merchant_type not in ('5371')
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '2'

GROUP BY 
 y.acquiring_inst_id_code,
y.rdm_amt,--,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), substring(y.extended_trans_type,1,4),y.extended_trans_type

CREATE TABLE #report_result20
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 20')
INSERT INTO #report_result20

SELECT		
	bank_code = CASE      WHEN  y.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  y.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  y.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  y.acquiring_inst_id_code = '639563' THEN 'ENT'

                          WHEN  y.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  y.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  y.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  y.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  y.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  y.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  y.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  y.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  y.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  y.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  y.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  y.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  y.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  y.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  y.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  y.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  y.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  y.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  y.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  y.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  y.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  y.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  y.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  y.acquiring_inst_id_code = '506143' THEN 'ACCION'
	                  WHEN  y.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category='REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer and ISO Fee Receivable(Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 133333.33)-- or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.375*0.015* y.rdm_amt*100))

	          WHEN (abs(y.rdm_amt) >= 133333.33) 
                  THEN sum(0.375*2000*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
tbl_xls_settlement y (nolock)
                               
                                 
 

WHERE
 (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))

and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '3'

GROUP BY 
 y.acquiring_inst_id_code,
y.rdm_amt,y.trans_date,y.extended_trans_type


CREATE TABLE #report_result21
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 21')
INSERT INTO #report_result21

SELECT		
	bank_code = CASE                                WHEN  y.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  y.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  y.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  y.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  y.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  y.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  y.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  y.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  y.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  y.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  y.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  y.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  y.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  y.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  y.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  y.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  y.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  y.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  y.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  y.acquiring_inst_id_code = '639139' THEN 'ABP'

                          WHEN  y.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  y.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  y.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  y.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  y.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  y.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  y.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  y.acquiring_inst_id_code = '506143' THEN 'ACCION'
	                      WHEN  y.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',
                       

        Debit_account_type=  'Acquirer Fee Payable(Debit_Nr)', 
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)', 
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(y.rdm_amt) < 133333.33) --or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.015* y.rdm_amt*100))


	          WHEN (abs(y.rdm_amt) >= 133333.33) 
                  THEN sum(2000*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
 tbl_xls_settlement y (nolock)


WHERE 
(y.trans_date >= @from_date AND y.trans_date < (@to_date+1))

and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '3'
    
     
     

GROUP BY 
y.acquiring_inst_id_code,y.trans_date,y.extended_trans_type,
y.rdm_amt




CREATE TABLE #report_result22
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 22')
INSERT INTO #report_result22

SELECT		
	bank_code = CASE      WHEN  y.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  y.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  y.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  y.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  y.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  y.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  y.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  y.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  y.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  y.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  y.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  y.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  y.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  y.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  y.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  y.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  y.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  y.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  y.acquiring_inst_id_code = '636092' THEN 'SBP'


                          WHEN  y.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  y.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  y.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  y.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  y.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  y.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  y.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  y.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  y.acquiring_inst_id_code = '506143' THEN 'ACCION'
			              WHEN  y.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type= 'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Amount Receivable(Credit_Nr)',  
                          

        amt= sum(y.rdm_amt*100),
	fee=  0,
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
 tbl_xls_settlement y (nolock)
 

WHERE 
    
 (y.trans_date >= @from_date AND y.trans_date < (@to_date+1))

    and (y.rdm_amt < 0 or y.rdm_amt > 0)
     and y.extended_trans_type is not null
     and LEFT(y.terminal_id,1) = '3'
	

GROUP BY 
 y.acquiring_inst_id_code,y.trans_date,y.extended_trans_type,
 y.rdm_amt

CREATE TABLE #report_result23
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 23')
INSERT INTO #report_result23



SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Touchpoint Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee=  isnull(Case when(substring(y.extended_trans_type,1,4) in ('9080')) then 

             SUM(0.10*(0.0075*(-1 * (t.settle_amount_impact))))

             else 
             SUM(0.10*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),

        (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)

on 
   (t.terminal_id= y.terminal_id 

   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
    and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(y.extended_trans_type,1,1)= '9'

GROUP BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),substring(y.extended_trans_type,1,4),y.extended_trans_type


CREATE TABLE #report_result24
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 24')
INSERT INTO #report_result24

SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Touchpoint Fee Receivable(Credit_Nr)',  
                          



        amt= 0,
	fee=  isnull(Case when(substring(o.r_code,1,4) in ('9080')) then 
             SUM(0.10*(0.0075*(-1 * (t.settle_amount_impact))))
             else 
             SUM(0.10*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.terminal_id = o.terminal_id 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code) 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))

      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and (substring(o.r_code,1,1) = '9'  and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
-- y.trans_date

--






CREATE TABLE #report_result27
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)

         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 27')
INSERT INTO #report_result27

SELECT		
	bank_code = CASE  WHEN (r.addit_party ='YPM') THEN 'GTB'
	                  WHEN (r.addit_party = 'SAVER') THEN 'ZIB'
                          WHEN (r.addit_party = 'ISW') THEN 'ISW'

        ELSE 'UNK'
        END,

	trxn_category= CASE when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= r.addit_party + '_Reward_Fee_Receivable (Credit_Nr)',  
                          
        amt= 0,

	fee=  isnull(CASE WHEN (substring(y.extended_trans_type,1,1) = '8') 
              AND (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(y.extended_trans_type,1,1) = '8') 
                  AND (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  ELSE  
               SUM(r.addit_charge*(-1 * (t.settle_amount_impact))) END,0),
             (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))


FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'

      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and substring(y.extended_trans_type,1,1) in ('9','8') 

GROUP BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
r.addit_party,
t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
substring(y.extended_trans_type,1,4),y.extended_trans_type


CREATE TABLE #report_result28
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 28')
INSERT INTO #report_result28

SELECT		
	bank_code = CASE  WHEN (r.addit_party = 'YPM') THEN 'GTB'
	                  WHEN (r.addit_party = 'SAVER') THEN 'ZIB'

                          WHEN (r.addit_party = 'ISW') THEN 'ISW'

        ELSE 'UNK'
        END,


	trxn_category= CASE when (substring(o.r_code,1,1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= r.addit_party + '_Reward_Fee_Receivable (Credit_Nr)',  
                          
        amt= 0,

	fee=  isnull(CASE WHEN (substring(o.r_code,1,1) = '8') 
              AND (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(o.r_code,1,1) = '8') 
                  AND (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  ELSE  
               SUM(r.addit_charge*(-1 * (t.settle_amount_impact))) END,0),

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand o (NOLOCK)
        ON t.terminal_id = o.terminal_id
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)  
left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'

      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')

				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(o.r_code,1,1) in ('9','8') and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506')

GROUP BY 
-- y.trans_date,
r.addit_party,
t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))

print(cast(getdate() as varchar(255)) + ': insert into report_result 29')

insert into #report_result
select * from #report_result1
union all select * from #report_result2 union all select * from #report_result3
union all select * from #report_result4 union all select * from #report_result5
union all select * from #report_result6 union all select * from #report_result7
union all select * from #report_result8 --union all select * from #report_result9
union all select * from #report_result10 union all select * from #report_result11
union all select * from #report_result12 union all select * from #report_result13
union all select * from #report_result14 union all select * from #report_result15
union all select * from #report_result16 union all select * from #report_result17
union all select * from #report_result18 union all select * from #report_result19
union all select * from #report_result20 union all select * from #report_result21
union all select * from #report_result22 union all select * from #report_result23
union all select * from #report_result24 union all select * from #report_result27
union all select * from #report_result28

print(cast(getdate() as varchar(255)) + ': insert into report_result 30')
Declare @fee_1 money

--where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'

set @fee_1=( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type = 'ISSUER FEE PAYABLE(Debit_Nr)' and 
             trxn_category not like '%WEB%' and  trxn_category not like '%BURN%')-
            ( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'and 
             trxn_category not like '%WEB%' and  trxn_category not like '%BURN%')

print(cast(getdate() as varchar(255)) + ': insert into report_result 31')

Declare @fee_2 money
set @fee_2=( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type in 
            ('Verve additional Fee Payable(Debit_Nr)', 'Merchant Additional Reward Fee Payable(Debit_Nr)') and 
             trxn_category like '%WEB%' and  trxn_category not like '%BURN%')-
            ( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type not in
             ('Verve additional Fee Payable(Debit_Nr)', 'Merchant Additional Reward Fee Payable(Debit_Nr)') and 
             trxn_category  like '%WEB%' and  trxn_category not like '%BURN%')
--where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'

print(cast(getdate() as varchar(255)) + ': insert into report_result 32')


INSERT INTO settlement_summary_breakdown



SELECT isnull(bank_code,0),isnull(trxn_category,0),isnull(Debit_Account_type,0)
       ,isnull(Credit_Account_type,0),trxn_amount, trxn_fee,trxn_date 
			,'566','0','1',
                        CASE when (trxn_category like '%POS%') then '2'
                             when (trxn_category like '%WEB%') then '3'
                               else '2' end, 'N/A','N/A'
	FROM 
			#report_result


print(cast(getdate() as varchar(255)) + ': insert into report_result 33')



INSERT INTO settlement_summary_breakdown

SELECT	distinct	
	bank_code = 'ISW',

	trxn_category= 'SAVERSCARD REWARD SCHEME' 
                       ,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW_Reward_Fee_Receivable (Credit_Nr)',  
                          
        Amt = 0,

	 Fee = isnull(CASE WHEN (substring(y.extended_trans_type,1,1) = '8') 
              AND (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(y.extended_trans_type,1,1) = '8') 
                  AND (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5 end,0),
                  
         @to_date,
         '566','0','1',
         terminal_type = case when  t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc') then '3'
                              when  t.source_node_name not IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc') then '2' end
         , 'N/A','N/A'

	 --substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)

LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
    and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
 left JOIN tbl_merchant_category c (NOLOCK)
     on t.merchant_type = c.category_code 
 --LEFT JOIN #report_result AS Z (NOLOCK)
--on #report_result.business_date = substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 11)



WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     --AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')

    AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	
     and y.extended_trans_type like '8%'



     --and debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'


GROUP BY 

 t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
substring(y.extended_trans_type,1,4),y.extended_trans_type,
t.source_node_name

--(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
 --t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap



INSERT INTO settlement_summary_breakdown

SELECT	distinct
	bank_code = 'ISW',

	trxn_category=  'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW_Reward_Fee_Receivable (Credit_Nr)',  
                          
        Amt = 0,

	 Fee = isnull(@fee_2,0),
         @to_date,
         '566','0','1',
         terminal_type = 3
         , 'N/A','N/A'


INSERT INTO settlement_summary_breakdown

SELECT	distinct
	bank_code = 'ISW',

	trxn_category=  'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW_Reward_Fee_Receivable (Credit_Nr)',  
                          
        Amt = 0,

	 Fee = isnull(@fee_1,0),
         @to_date,
         '566','0','1',
         terminal_type = 2
         , 'N/A','N/A'

print(cast(getdate() as varchar(255)) + ': insert into report_result 34')

update ##TEMP_TRANSACTIONS_REWARD set retention_data = 
(select distinct y.extended_trans_type from tbl_xls_settlement y
 where ##TEMP_TRANSACTIONS_REWARD.terminal_id= y.terminal_id 
   AND ##TEMP_TRANSACTIONS_REWARD.retrieval_reference_nr = y.rr_number 
and isnumeric(left(y.extended_trans_type,4)) = 1
  
   AND substring (CAST (##TEMP_TRANSACTIONS_REWARD.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) 


update ##TEMP_TRANSACTIONS_REWARD set settle_cash_rsp = 0
update ##TEMP_TRANSACTIONS_REWARD set settle_cash_rsp = 
(select distinct y.rdm_amt from tbl_xls_settlement y
 where ##TEMP_TRANSACTIONS_REWARD.terminal_id= y.terminal_id 
   AND ##TEMP_TRANSACTIONS_REWARD.retrieval_reference_nr = y.rr_number 
and isnumeric(y.rdm_amt) = 1
  
   AND substring (CAST (##TEMP_TRANSACTIONS_REWARD.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) 

update ##TEMP_TRANSACTIONS_REWARD set auth_id_rsp = 
(select distinct o.r_code from tbl_reward_outofband o

 where  ##TEMP_TRANSACTIONS_REWARD.terminal_id = o.terminal_id
   and (left(##TEMP_TRANSACTIONS_REWARD.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
 or left (##TEMP_TRANSACTIONS_REWARD.pan,3) = '506') 
and isnumeric(left(o.r_code,4)) = 1)

	
 
--select * from ##TEMP_TRANSACTIONS_REWARD where isnull(retention_data,0) <> 0 or isnull(settle_cash_rsp,0) <> 0
--or isnull(auth_id_rsp,0) <> 0 or isnull(extended_tran_type,0) <> 0


DECLARE @sql VARCHAR (4000);
DECLARE @report_file VARCHAR (1000);

SET @report_file ='E:\BANK REPORTS\SWT\Daily Summary\POS\Reward_Details_'+REPLACE(REPLACE(REPLACE(REPLACE(getdate(),'-','_'), ' ', '_'), ' ', '_'), ':', '_')+'.csv';

SELECT @sql ='bcp "SELECT source_node_name, sink_node_name,datetime_rsp,retrieval_reference_nr, settle_amount_impact,settle_cash_rsp,p.category_name, p.merchant_disc, p.amount_cap, p.fee_cap,w.category_name, w.merchant_disc, w.amount_cap, w.fee_cap,r.reward_discount, r.addit_charge, r.addit_party, message_type, rsp_code_rsp, tran_type,settle_cash_rsp ,system_trace_audit_nr,pan,terminal_id,acquiring_inst_id_code,merchant_type,extended_tran_type,retention_data,auth_id_rsp,card_acceptor_id_code,card_acceptor_name_loc FROM ##TEMP_TRANSACTIONS_REWARD t left join postilion_office.dbo.tbl_merchant_category p on t.merchant_type = p.category_code left join postilion_office.dbo.tbl_merchant_category_web w on t.merchant_type = w.category_code left join postilion_office.dbo.reward_category r on (t.extended_tran_type = r.reward_code or t.retention_data = r.reward_code or t.auth_id_rsp = r.reward_code) where isnull(retention_data,0) <> 0 or isnull(settle_cash_rsp,0) <> 0 or isnull(auth_id_rsp,0) <> 0 or isnull(extended_tran_type,0) <> 0;" queryout "'+@report_file+'" -c -t, -T -S';

EXEC master..xp_cmdshell @sql;

DROP TABLE ##TEMP_TRANSACTIONS_REWARD;

print(cast(getdate() as varchar(255)) + ': insert into report_result 35')
END  






















































































GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown]    Script Date: 03/15/2016 18:58:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[psp_settlement_summary_breakdown](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
    @rpt_tran_id1 INT = NULL
)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,-1,GETDATE()),111),'/',''))
SET @to_date = ISNULL(@end_date,REPLACE(CONVERT(VARCHAR(MAX), GETDATE(),111),'/',''))

DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
DECLARE @first_post_tran_cust_id BIGINT
DECLARE @last_post_tran_cust_id BIGINT


IF( DATEDIFF(D,@from_date, @to_date)=0) BEGIN
    
INSERT 
           INTO settlement_summary_session
SELECT TOP 1  (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK) 
	   JOIN post_tran PT(NOLOCK)
	   ON j.post_tran_id = PT.post_tran_id
	   JOIN post_tran_cust PTC(NOLOCK)
	   ON 
	j.post_tran_cust_id = PT.post_tran_cust_id
        where  
		(J.business_date >= @from_date AND J.business_date <= (@to_date))
		  AND
		PT.rsp_code_rsp in ('00','11','09')
              AND  PT.tran_postilion_originated = 0
     
              AND (
			     PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220')
                 or  ((PT.message_type = '0420' and PT.tran_reversed <> 2 ) and ( (PT.settle_amount_impact<> 0 )
				   or (PT.settle_amount_rsp<> 0   and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))))
              or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))
            
			   )

   
        OPTION ( MAXDOP 16)  
	SET @to_date = REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,1,@to_date),111),'/','')
	SELECT @first_post_tran_id = MIN(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@from_date
	SELECT @last_post_tran_id =  max(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@to_date
	SELECT @first_post_tran_cust_id= MIN(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date =@from_date
	SELECT @last_post_tran_cust_id=  max(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date =@to_date
END
ELSE BEGIN
SELECT @first_post_tran_id = MIN(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@from_date
SELECT @last_post_tran_id =  max(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date <@to_date
SELECT @first_post_tran_cust_id= MIN(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date =@from_date
SELECT @last_post_tran_cust_id=  max(post_tran_cust_id) FROM sstl_journal_all (NOLOCK) where business_date <@to_date

INSERT  INTO settlement_summary_session
SELECT TOP 1  (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK) 
	   JOIN post_tran PT(NOLOCK)
	   ON j.post_tran_id = PT.post_tran_id
	   JOIN post_tran_cust PTC(NOLOCK)
	   ON 
	j.post_tran_cust_id = PT.post_tran_cust_id
        where  
		(J.post_tran_id >= @first_post_tran_id) AND 
( J.post_tran_id <= (@last_post_tran_id))
		  AND
		PT.rsp_code_rsp in ('00','11','09')
              AND  PT.tran_postilion_originated = 0
     
              AND (
			     PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220')
                 or  ((PT.message_type = '0420' and PT.tran_reversed <> 2 ) and ( (PT.settle_amount_impact<> 0 )
				   or (PT.settle_amount_rsp<> 0   and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))))
              or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))
            
			   )

   
        OPTION ( MAXDOP 16)  
END

CREATE TABLE [dbo].[#post_tran_temp](
	[post_tran_id] [bigint] NOT NULL,
	[post_tran_cust_id] [bigint] NOT NULL,
	[settle_entity_id] BIGINT NULL,
	[batch_nr] [int] NULL,
	[prev_post_tran_id] [bigint] NULL,
	[next_post_tran_id] [bigint] NULL,
	[sink_node_name] varchar(500) NULL,
	[tran_postilion_originated] int NOT NULL,
	[tran_completed] int NOT NULL,
	[message_type] [char](4) NOT NULL,
	[tran_type] [char](2) NULL,
	[tran_nr] [bigint] NOT NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[rsp_code_req] [char](2) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[abort_rsp_code] [char](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[auth_type] [numeric](1, 0) NULL,
	[auth_reason] [numeric](1, 0) NULL,
	[retention_data] [varchar](999) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [char](4) NULL,
	[sponsor_bank] [char](8) NULL,
	[retrieval_reference_nr] [char](12) NULL,
	[datetime_tran_gmt] [datetime] NULL,
	[datetime_tran_local] [datetime] NOT NULL,
	[datetime_req] [datetime] NOT NULL,
	[datetime_rsp] [datetime] NULL,
	[realtime_business_date] [datetime] NOT NULL,
	[recon_business_date] [datetime] NOT NULL,
	[from_account_type] [char](2) NULL,
	[to_account_type] [char](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] MONEY NULL,
	[tran_amount_rsp] MONEY NULL,
	[settle_amount_impact] MONEY NULL,
	[tran_cash_req] MONEY NULL,
	[tran_cash_rsp] MONEY NULL,
	[tran_currency_code] VARCHAR(5)NULL,
	[tran_tran_fee_req] MONEY NULL,
	[tran_tran_fee_rsp] MONEY NULL,
	[tran_tran_fee_currency_code] VARCHAR(5)NULL,
	[tran_proc_fee_req] MONEY NULL,
	[tran_proc_fee_rsp] MONEY NULL,
	[tran_proc_fee_currency_code] VARCHAR(5)NULL,
	[settle_amount_req] MONEY NULL,
	[settle_amount_rsp] MONEY NULL,
	[settle_cash_req] MONEY NULL,
	[settle_cash_rsp] MONEY NULL,
	[settle_tran_fee_req] MONEY NULL,
	[settle_tran_fee_rsp] MONEY NULL,
	[settle_proc_fee_req] MONEY NULL,
	[settle_proc_fee_rsp] MONEY NULL,
	[settle_currency_code] VARCHAR(5)NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[tran_reversed] [char](1) NULL,
	[prev_tran_approved] int NULL,
	[issuer_network_id] [varchar](11) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[extended_tran_type] [char](4) NULL,
	[from_account_type_qualifier] [char](1) NULL,
	[to_account_type_qualifier] [char](1) NULL,
	[bank_details] [varchar](31) NULL,
	[payee] [char](25) NULL,
	[card_verification_result] [char](1) NULL,
	[online_system_id] [int] NULL,
	[participant_id] [int] NULL,
	[opp_participant_id] [int] NULL,
	[receiving_inst_id_code] [varchar](11) NULL,
	[routing_type] [int] NULL,
	[pt_pos_operating_environment] [char](1) NULL,
	[pt_pos_card_input_mode] [char](1) NULL,
	[pt_pos_cardholder_auth_method] [char](1) NULL,
	[pt_pos_pin_capture_ability] [char](1) NULL,
	[pt_pos_terminal_operator] [char](1) NULL,
	[source_node_key] [varchar](32) NULL,
	[proc_online_system_id] [int] NULL
) 

SET ANSI_PADDING OFF


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [next_post_tran_id]


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [tran_reversed]


CREATE clustered INDEX ix_post_tran_temp_1 ON  [#post_tran_temp] (
	post_tran_id
)
CREATE INDEX ix_post_tran_temp_2 ON  [#post_tran_temp] (
	post_tran_cust_id
)  INCLUDE(post_tran_id,recon_business_date,datetime_req, datetime_tran_local)
CREATE INDEX ix_post_tran_temp_3 ON  [#post_tran_temp] (
	datetime_req
)  INCLUDE(post_tran_id,recon_business_date,post_tran_cust_id, datetime_tran_local)

CREATE INDEX ix_post_tran_temp_4 ON  [#post_tran_temp] (
	recon_business_date
)  INCLUDE(post_tran_id,datetime_req,post_tran_cust_id, datetime_tran_local)

CREATE INDEX ix_post_tran_temp_5 ON  [#post_tran_temp] (
sink_node_name
)
CREATE INDEX ix_post_tran_temp_6 ON  [#post_tran_temp] (
acquiring_inst_id_code
)
CREATE INDEX ix_post_tran_temp_7 ON  [#post_tran_temp] (
[retention_data]
)
CREATE INDEX ix_post_tran_temp_8 ON  [#post_tran_temp] (
payee
)
CREATE INDEX ix_post_tran_cust_9 ON [#post_tran_temp] (
extended_tran_type
) 

CREATE TABLE [dbo].[#post_tran_cust_temp](
	[post_tran_cust_id] [bigint] NOT NULL,
	[source_node_name] varchar(500) NOT NULL,
	[draft_capture] BIGINT NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[service_restriction_code] [char](3) NULL,
	[terminal_id] varchar(10) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[mapped_card_acceptor_id_code] [char](15) NULL,
	[merchant_type] [char](4) NULL,
	[card_acceptor_name_loc] [char](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [char](1) NULL,
	[check_data] [varchar](70) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [char](1) NULL,
	[pos_cardholder_auth_ability] [char](1) NULL,
	[pos_card_capture_ability] [char](1) NULL,
	[pos_operating_environment] [char](1) NULL,
	[pos_cardholder_present] [char](1) NULL,
	[pos_card_present] [char](1) NULL,
	[pos_card_data_input_mode] [char](1) NULL,
	[pos_cardholder_auth_method] [char](1) NULL,
	[pos_cardholder_auth_entity] [char](1) NULL,
	[pos_card_data_output_ability] [char](1) NULL,
	[pos_terminal_output_ability] [char](1) NULL,
	[pos_pin_capture_ability] [char](1) NULL,
	[pos_terminal_operator] [char](1) NULL,
	[pos_terminal_type] [char](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [char](18) NULL,
	[pan_reference] [char](42) NULL,
 CONSTRAINT [pk_post_tran_cust_temp] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
))
ALTER TABLE [dbo].[#post_tran_cust_temp] ADD  DEFAULT ((0)) FOR [draft_capture]
CREATE INDEX ix_post_tran_cust_1 ON [#post_tran_cust_temp] (
terminal_id
) 
CREATE INDEX ix_post_tran_cust_2 ON [#post_tran_cust_temp] (
totals_group
) 
CREATE INDEX ix_post_tran_cust_3 ON [#post_tran_cust_temp] (
card_acceptor_id_code
) 


CREATE INDEX ix_post_tran_cust_4 ON [#post_tran_cust_temp] (
source_node_name
) 

CREATE INDEX ix_post_tran_cust_5 ON [#post_tran_cust_temp] (
pan
) 

CREATE INDEX ix_post_tran_cust_6 ON [#post_tran_cust_temp] (
merchant_type
) 


          
IF(@@ERROR <>0)
RETURN

INSERT INTO  [#post_tran_temp](
       [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id]
      ,[next_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[auth_reason]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[sponsor_bank]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[tran_proc_fee_req]
      ,[tran_proc_fee_rsp]
      ,[tran_proc_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_cash_req]
      ,[settle_cash_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_proc_fee_req]
      ,[settle_proc_fee_rsp]
      ,[settle_currency_code]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[additional_rsp_data]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[issuer_network_id]
      ,[acquirer_network_id]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[bank_details]
      ,[payee]
      ,[card_verification_result]
      ,[online_system_id]
      ,[participant_id]
      ,[opp_participant_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[pt_pos_operating_environment]
      ,[pt_pos_card_input_mode]
      ,[pt_pos_cardholder_auth_method]
      ,[pt_pos_pin_capture_ability]
      ,[pt_pos_terminal_operator]
      ,[source_node_key]
      ,[proc_online_system_id]
      
      )
SELECT   [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id]
      ,[next_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[auth_reason]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[sponsor_bank]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[tran_proc_fee_req]
      ,[tran_proc_fee_rsp]
      ,[tran_proc_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_cash_req]
      ,[settle_cash_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_proc_fee_req]
      ,[settle_proc_fee_rsp]
      ,[settle_currency_code]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[additional_rsp_data]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[issuer_network_id]
      ,[acquirer_network_id]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[bank_details]
      ,[payee]
      ,[card_verification_result]
      ,[online_system_id]
      ,[participant_id]
      ,[opp_participant_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[pt_pos_operating_environment]
      ,[pt_pos_card_input_mode]
      ,[pt_pos_cardholder_auth_method]
      ,[pt_pos_pin_capture_ability]
      ,[pt_pos_terminal_operator]
      ,[source_node_key]
      ,[proc_online_system_id]
  FROM [postilion_office].[dbo].[post_tran] (NOLOCK)
WHERE 
(post_tran_id >=@first_post_tran_id) AND
 (post_tran_id<=@last_post_tran_id)
    
OPTION (MAXDOP 16)


INSERT INTO [#post_tran_cust_temp](
[post_tran_cust_id]
      ,[source_node_name]
      ,[draft_capture]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[service_restriction_code]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[mapped_card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[check_data]
      ,[totals_group]
      ,[card_product]
      ,[pos_card_data_input_ability]
      ,[pos_cardholder_auth_ability]
      ,[pos_card_capture_ability]
      ,[pos_operating_environment]
      ,[pos_cardholder_present]
      ,[pos_card_present]
      ,[pos_card_data_input_mode]
      ,[pos_cardholder_auth_method]
      ,[pos_cardholder_auth_entity]
      ,[pos_card_data_output_ability]
      ,[pos_terminal_output_ability]
      ,[pos_pin_capture_ability]
      ,[pos_terminal_operator]
      ,[pos_terminal_type]
      ,[pan_search]
      ,[pan_encrypted]
      ,[pan_reference]
   

)

SELECT [post_tran_cust_id]
      ,[source_node_name]
      ,[draft_capture]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[service_restriction_code]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[mapped_card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[check_data]
      ,[totals_group]
      ,[card_product]
      ,[pos_card_data_input_ability]
      ,[pos_cardholder_auth_ability]
      ,[pos_card_capture_ability]
      ,[pos_operating_environment]
      ,[pos_cardholder_present]
      ,[pos_card_present]
      ,[pos_card_data_input_mode]
      ,[pos_cardholder_auth_method]
      ,[pos_cardholder_auth_entity]
      ,[pos_card_data_output_ability]
      ,[pos_terminal_output_ability]
      ,[pos_pin_capture_ability]
      ,[pos_terminal_operator]
      ,[pos_terminal_type]
      ,[pan_search]
      ,[pan_encrypted]
      ,[pan_reference]
  FROM [postilion_office].[dbo].[post_tran_cust] (NOLOCK)
  WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM [#post_tran_temp])
OPTION (MAXDOP 16)
        
	

EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 
EXEC psp_get_rpt_post_tran_cust_id_NIBSS @from_date,@to_date,@rpt_tran_id1 OUTPUT 

	

--INSERT INTO settlement_summary_breakdown
--(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type)

CREATE TABLE #report_result
	(
		index_no bigint  IDENTITY(1,1),
		bank_code				VARCHAR (32),
		trxn_category				VARCHAR (64),  
		Debit_Account_type		        VARCHAR (100), 
		Credit_Account_type 		        VARCHAR (100),
		trxn_amount				money, 
		trxn_fee 				money, 
                trxn_date                               Datetime,
                currency                                VARCHAR (50),
                late_reversal                           CHAR    (1),
                Card_Type                               VARCHAR (25),
                Terminal_type                           VARCHAR (25),
                source_node_name                        VARCHAR (100),
                Unique_key                           VARCHAR(200),
                Acquirer                                VARCHAR (50),
                Issuer                                  VARCHAR (50)
							         )

									 				CREATE  NONCLUSTERED INDEX ix_report_result_6 ON #report_result (
	index_no
	
	)	
				CREATE  NONCLUSTERED INDEX ix_report_result_1 ON #report_result (
	Unique_key
	
	)				         
								         
	CREATE  NONCLUSTERED INDEX ix_report_result_5 ON #report_result (
	bank_code
	
	)						         
	CREATE  NONCLUSTERED INDEX ix_report_result_2 ON #report_result (
	source_node_name
	)

	
CREATE NONCLUSTERED INDEX ix_report_result_3 ON #report_result (
	 Acquirer
	
	)

	CREATE NONCLUSTERED INDEX ix_report_result_4 ON #report_result (
   Issuer 
	
	)
		
SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        
        
INSERT INTO  #report_result

SELECT		         
	bank_code = CASE 
	
/*WHEN                    (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480'
                          and dbo.fn_rpt_terminal_type(ptc.terminal_id) <>'3' 
                           THEN 'UBA'*/
                           
/*WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND (PTC.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk')
                          THEN 'UBA'*/
                          
                          
                          WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                            and  (DebitAccNr.acc_nr LIKE '%FEE_PAYABLE' or CreditAccNr.acc_nr LIKE '%FEE_PAYABLE')) THEN 'ISW' 
                              
                          
                          
WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND ((PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') 
                                OR (PTC.source_node_name = 'SWTFBPsrc' AND PT.sink_node_name = 'ASPPOSVISsnk' 
                                 AND totals_group = 'VISAGroup')
                               )
                          THEN 'UBA'
                          
                          
WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code = '627787')
                          THEN 'UNK'
                          
                          --AND (PT.acquiring_inst_id_code <> '627480' or 
                          --(PT.acquiring_inst_id_code = '627480'
                          --and dbo.fn_rpt_terminal_type(ptc.terminal_id) ='3'))
                           
                           
                           
 /* WHEN                     (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480' 
                           THEN 'UBA' */
                           
 /*WHEN                      (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(ptc.pan) = '6'
                          --AND PT.acquiring_inst_id_code <> '627480' 
                           THEN 'GTB'*/


WHEN PTT.Retention_data = '1046' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'UBN'
WHEN PTT.Retention_data in ('9130','8130') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABS'
WHEN PTT.Retention_data in ('9044','8044') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABP'
WHEN PTT.Retention_data in ('9023','8023')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'CITI'
WHEN PTT.Retention_data in ('9050','8050') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'EBN'
WHEN PTT.Retention_data in ('9214','8214') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FCMB'
WHEN PTT.Retention_data in ('9070','8070','1100') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBP'
WHEN PTT.Retention_data in ('9011','8011') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBN'
WHEN PTT.Retention_data in ('9058','8058')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'GTB'
WHEN PTT.Retention_data in ('9082','8082') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'KSB'
WHEN PTT.Retention_data in ('9076','8076') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SKYE'
WHEN PTT.Retention_data in ('9084','8084') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ENT'
WHEN PTT.Retention_data in ('9039','8039') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'IBTC'
WHEN PTT.Retention_data in ('9068','8068') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SCB'
WHEN PTT.Retention_data in ('9232','8232','1105') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SBP'
WHEN PTT.Retention_data in ('9032','8032')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBN'
WHEN PTT.Retention_data in ('9033','8033')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBA'
WHEN PTT.Retention_data in ('9215','8215')  and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBP'
WHEN PTT.Retention_data in ('9035','8035') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'WEMA'
WHEN PTT.Retention_data in ('9057','8057') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ZIB'
WHEN PTT.Retention_data in ('9301','8301') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'JBP'
WHEN PTT.Retention_data in ('9030') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE')  then 'HBC'                        
                          
			
			
			WHEN PTT.Retention_data = '1131' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'WEMA'
                         WHEN PTT.Retention_data in ('1061','1006') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'

                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'GTB'
                         WHEN PTT.Retention_data = '1708' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'FBN'
                         WHEN PTT.Retention_data in ('1027','1045','1081','1015') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'SKYE'
                         WHEN PTT.Retention_data = '1037' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'IBTC'
                         WHEN PTT.Retention_data = '1034' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'EBN'
                         -- WHEN PTT.Retention_data = '1006' and 
                         --(DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                         -- OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                         -- OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'DBL'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBA%' OR CreditAccNr.acc_nr LIKE 'UBA%') THEN 'UBA'
			 WHEN (DebitAccNr.acc_nr LIKE 'FBN%' OR CreditAccNr.acc_nr LIKE 'FBN%') THEN 'FBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ZIB%' OR CreditAccNr.acc_nr LIKE 'ZIB%') THEN 'ZIB' 
                         WHEN (DebitAccNr.acc_nr LIKE 'SPR%' OR CreditAccNr.acc_nr LIKE 'SPR%') THEN 'ENT'
                         WHEN (DebitAccNr.acc_nr LIKE 'GTB%' OR CreditAccNr.acc_nr LIKE 'GTB%') THEN 'GTB'
                         WHEN (DebitAccNr.acc_nr LIKE 'PRU%' OR CreditAccNr.acc_nr LIKE 'PRU%') THEN 'SKYE'
                         WHEN (DebitAccNr.acc_nr LIKE 'OBI%' OR CreditAccNr.acc_nr LIKE 'OBI%') THEN 'EBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'WEM%' OR CreditAccNr.acc_nr LIKE 'WEM%') THEN 'WEMA'
                         WHEN (DebitAccNr.acc_nr LIKE 'AFR%' OR CreditAccNr.acc_nr LIKE 'AFR%') THEN 'MSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBTC%' OR CreditAccNr.acc_nr LIKE 'IBTC%') THEN 'IBTC'
                         WHEN (DebitAccNr.acc_nr LIKE 'PLAT%' OR CreditAccNr.acc_nr LIKE 'PLAT%') THEN 'KSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBP%' OR CreditAccNr.acc_nr LIKE 'UBP%') THEN 'UBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'DBL%' OR CreditAccNr.acc_nr LIKE 'DBL%') THEN 'DBL'

                         WHEN (DebitAccNr.acc_nr LIKE 'FCMB%' OR CreditAccNr.acc_nr LIKE 'FCMB%') THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBP%' OR CreditAccNr.acc_nr LIKE 'IBP%') THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBN%' OR CreditAccNr.acc_nr LIKE 'UBN%') THEN 'UBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ETB%' OR CreditAccNr.acc_nr LIKE 'ETB%') THEN 'ETB'
                         WHEN (DebitAccNr.acc_nr LIKE 'FBP%' OR CreditAccNr.acc_nr LIKE 'FBP%') THEN 'FBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'SBP%' OR CreditAccNr.acc_nr LIKE 'SBP%') THEN 'SBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABP%' OR CreditAccNr.acc_nr LIKE 'ABP%') THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'EBN%' OR CreditAccNr.acc_nr LIKE 'EBN%') THEN 'EBN'

                         WHEN (DebitAccNr.acc_nr LIKE 'CITI%' OR CreditAccNr.acc_nr LIKE 'CITI%') THEN 'CITI'
                         WHEN (DebitAccNr.acc_nr LIKE 'FIN%' OR CreditAccNr.acc_nr LIKE 'FIN%') THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'ASO%' OR CreditAccNr.acc_nr LIKE 'ASO%') THEN 'ASO'
                         WHEN (DebitAccNr.acc_nr LIKE 'OLI%' OR CreditAccNr.acc_nr LIKE 'OLI%') THEN 'OLI'
                         WHEN (DebitAccNr.acc_nr LIKE 'HSL%' OR CreditAccNr.acc_nr LIKE 'HSL%') THEN 'HSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABS%' OR CreditAccNr.acc_nr LIKE 'ABS%') THEN 'ABS'
                         WHEN (DebitAccNr.acc_nr LIKE 'PAY%' OR CreditAccNr.acc_nr LIKE 'PAY%') THEN 'PAY'
                         WHEN (DebitAccNr.acc_nr LIKE 'SAT%' OR CreditAccNr.acc_nr LIKE 'SAT%') THEN 'SAT'
                         WHEN (DebitAccNr.acc_nr LIKE '3LCM%' OR CreditAccNr.acc_nr LIKE '3LCM%') THEN '3LCM'
                         WHEN (DebitAccNr.acc_nr LIKE 'SCB%' OR CreditAccNr.acc_nr LIKE 'SCB%') THEN 'SCB'
                         WHEN (DebitAccNr.acc_nr LIKE 'JBP%' OR CreditAccNr.acc_nr LIKE 'JBP%') THEN 'JBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'RSL%' OR CreditAccNr.acc_nr LIKE 'RSL%') THEN 'RSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'PSH%' OR CreditAccNr.acc_nr LIKE 'PSH%') THEN 'PSH'
                         WHEN (DebitAccNr.acc_nr LIKE 'INF%' OR CreditAccNr.acc_nr LIKE 'INF%') THEN 'INF'
                         WHEN (DebitAccNr.acc_nr LIKE 'UML%' OR CreditAccNr.acc_nr LIKE 'UML%') THEN 'UML'

                         WHEN (DebitAccNr.acc_nr LIKE 'ACCI%' OR CreditAccNr.acc_nr LIKE 'ACCI%') THEN 'ACCI'
                         WHEN (DebitAccNr.acc_nr LIKE 'EKON%' OR CreditAccNr.acc_nr LIKE 'EKON%') THEN 'EKON'
                         WHEN (DebitAccNr.acc_nr LIKE 'ATMC%' OR CreditAccNr.acc_nr LIKE 'ATMC%') THEN 'ATMC'
                         WHEN (DebitAccNr.acc_nr LIKE 'HBC%' OR CreditAccNr.acc_nr LIKE 'HBC%') THEN 'HBC'
			 WHEN (DebitAccNr.acc_nr LIKE 'UNI%' OR CreditAccNr.acc_nr LIKE 'UNI%') THEN 'UNI'
                         WHEN (DebitAccNr.acc_nr LIKE 'UNC%' OR CreditAccNr.acc_nr LIKE 'UNC%') THEN 'UNC'
                         WHEN (DebitAccNr.acc_nr LIKE 'NCS%' OR CreditAccNr.acc_nr LIKE 'NCS%') THEN 'NCS' 
			 WHEN (DebitAccNr.acc_nr LIKE 'HAG%' OR CreditAccNr.acc_nr LIKE 'HAG%') THEN 'HAG'
			 WHEN (DebitAccNr.acc_nr LIKE 'EXP%' OR CreditAccNr.acc_nr LIKE 'EXP%') THEN 'DBL'
			 WHEN (DebitAccNr.acc_nr LIKE 'FGMB%' OR CreditAccNr.acc_nr LIKE 'FGMB%') THEN 'FGMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'CEL%' OR CreditAccNr.acc_nr LIKE 'CEL%') THEN 'CEL'
			 WHEN (DebitAccNr.acc_nr LIKE 'RDY%' OR CreditAccNr.acc_nr LIKE 'RDY%') THEN 'RDY'
			 WHEN (DebitAccNr.acc_nr LIKE 'AMJ%' OR CreditAccNr.acc_nr LIKE 'AMJ%') THEN 'AMJU'
			 WHEN (DebitAccNr.acc_nr LIKE 'CAP%' OR CreditAccNr.acc_nr LIKE 'CAP%') THEN 'O3CAP'
			 WHEN (DebitAccNr.acc_nr LIKE 'VER%' OR CreditAccNr.acc_nr LIKE 'VER%') THEN 'VER_GLOBAL'

			 WHEN (DebitAccNr.acc_nr LIKE 'SMF%' OR CreditAccNr.acc_nr LIKE 'SMF%') THEN 'SMFB'
			 WHEN (DebitAccNr.acc_nr LIKE 'SLT%' OR CreditAccNr.acc_nr LIKE 'SLT%') THEN 'SLTD'
			 WHEN (DebitAccNr.acc_nr LIKE 'JES%' OR CreditAccNr.acc_nr LIKE 'JES%') THEN 'JES'
                         WHEN (DebitAccNr.acc_nr LIKE 'MOU%' OR CreditAccNr.acc_nr LIKE 'MOU%') THEN 'MOUA'
                         WHEN (DebitAccNr.acc_nr LIKE 'MUT%' OR CreditAccNr.acc_nr LIKE 'MUT%') THEN 'MUT'
                         WHEN (DebitAccNr.acc_nr LIKE 'LAV%' OR CreditAccNr.acc_nr LIKE 'LAV%') THEN 'LAV'
                         WHEN (DebitAccNr.acc_nr LIKE 'JUB%' OR CreditAccNr.acc_nr LIKE 'JUB%') THEN 'JUB'
						 WHEN (DebitAccNr.acc_nr LIKE 'WET%' OR CreditAccNr.acc_nr LIKE 'WET%') THEN 'WET'
                         WHEN (DebitAccNr.acc_nr LIKE 'AGH%' OR CreditAccNr.acc_nr LIKE 'AGH%') THEN 'AGH'
                         WHEN (DebitAccNr.acc_nr LIKE 'TRU%' OR CreditAccNr.acc_nr LIKE 'TRU%') THEN 'TRU'
						 WHEN (DebitAccNr.acc_nr LIKE 'CON%' OR CreditAccNr.acc_nr LIKE 'CON%') THEN 'CON'
                         WHEN (DebitAccNr.acc_nr LIKE 'CRU%' OR CreditAccNr.acc_nr LIKE 'CRU%') THEN 'CRU'
WHEN (DebitAccNr.acc_nr LIKE 'NPR%' OR CreditAccNr.acc_nr LIKE 'NPR%') THEN 'NPR'
                         WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCEPT%' OR CreditAccNr.acc_nr LIKE 'POS_FOODCONCEPT%') THEN 'SCB'
			 WHEN ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.tran_type ='01')  
							AND dbo.fn_rpt_CardGroup(PTC.PAN) in ('1','4')
                           AND PTC.source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PTC.source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PTC.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PTC.Terminal_id,1,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PTC.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PTC.Terminal_id,1,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                            WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 1 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Verve Token)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 2 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 3 
                           THEN 'ATM WITHDRAWAL (Cardless:Non-Card Generated)'


                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           AND PTC.source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 

                           and (DebitAccNr.acc_nr LIKE '%V%BILLING%' OR CreditAccNr.acc_nr LIKE '%V%BILLING%')
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PTC.source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			   WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and 
                           (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) then 'BILLPAYMENT MASTERCARD BILLING'

                          
			   WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1') then 'BILLPAYMENT'
			   
			
                           WHEN (PT.tran_type ='40'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' 

                           or SUBSTRING(PTC.Terminal_id,1,1)= '0' or SUBSTRING(PTC.Terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           AND SUBSTRING(PTC.Terminal_id,1,1)IN ('2','5','6')AND PT.sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 1 
                           THEN 'POS PURCHASE (Cardless:Paycode Verve Token)'
                           
                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           AND SUBSTRING(PTC.Terminal_id,1,1)IN ('2','5','6')AND PT.sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(pt.extended_tran_type) = 2 
                           THEN 'POS PURCHASE (Cardless:Paycode Non-Verve Token)'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '1'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                            or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(EASYFUEL)PURCHASE'

                           WHEN  (dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PTC.merchant_type
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '19'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '20'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '21'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '22'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '23'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'Verify card – Ecash load'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '24'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '25'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '26'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(Verve_Payment_Gateway_0.9%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '27'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(Verve_Payment_Gateway_1.25%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)= '28'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1) THEN 'WEB(Verve_Add_Card)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (pt.tran_type = '50' and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2 and 

                           SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr LIKE '%fee%' OR CreditAccNr.acc_nr LIKE '%fee%')
                                 and (PT.tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name) = 1))
                                 and not (DebitAccNr.acc_nr like '%PREPAIDLOAD%' or CreditAccNr.acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr NOT LIKE '%fee%' OR CreditAccNr.acc_nr NOT LIKE '%fee%')

                                 and PT.tran_type in ('50')
                                 and not (DebitAccNr.acc_nr like '%PREPAIDLOAD%' or CreditAccNr.acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '1' and PT.tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '2' and PT.tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '4' and PT.tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '35' and PT.tran_type = '50') then 'REMITA TRANSFERS'

       
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '31' and PT.tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PTC.source_node_name) = '32' and PT.tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '33' and PT.tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '34' and PT.tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '36' and PT.tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '37' and PT.tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '38' and PT.tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '39' and PT.tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '310' and PT.tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '311' and PT.tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '312'  and PT.tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '314'  and PT.tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '315' and PT.tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '316' and PT.tran_type = '50') then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                                 AND (DebitAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2)
                                 AND (DebitAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type)= '1') then 'PREPAID CARDLOAD'

                          when pt.tran_type = '21' then 'DEPOSIT'

                           /*WHEN (SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  (SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN  (SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'*/
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE 
                     /* WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'*/
                      
                      /*WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'*/
                      
                     /* WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'*/ 
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2')
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') 

                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT ((DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (DebitAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (DebitAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (DebitAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (DebitAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (DebitAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
  
  
                     
                      /*WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTASPUBAsrc' AND PT.sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'*/
                      
                       /* WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)' */
                         
                         
                      WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                          PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                      PT.acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(ptc.pan) = '6' 
                      AND (PTC.source_node_name = 'SWTNCS2src' AND PT.sink_node_name = 'ASPPOSVINsnk' and 
                           PT.acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                                               
                          WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1') 

                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') 
                          and SUBSTRING(PTC.Terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT ((CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr.acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'
                         
                          WHEN (CreditAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          
                          WHEN (CreditAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 
			  WHEN (CreditAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)'
			  WHEN (CreditAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'

                          ELSE 'UNK'			
END,

        amt=SUM(ISNULL(J.amount,0)),
	fee=SUM(ISNULL(J.fee,0)),
	business_date=j.business_date,
        currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and 
                           (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) THEN '840'
                        WHEN ((DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%') and( PT.sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk'))) THEN '840'
          ELSE pt.settle_currency_code END,
        Late_Reversal_id = CASE
        
                        WHEN ( dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                               and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6')
                               and PTC.merchant_type in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511') THEN 0
                               
						WHEN ( dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1)
                               and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
        card_type =  dbo.fn_rpt_CardGroup(ptc.pan),
        terminal_type = dbo.fn_rpt_terminal_type(ptc.terminal_id),    
        source_node_name =   PTC.source_node_name,
        Unique_key = pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+ptc.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
        Acquirer = (case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PTC.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
        Issuer = (case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) and (substring(ptc.totals_group,1,3) = acc.bank_code1) then acc.bank_code
                      else substring(ptc.totals_group,1,3) END)
                     

                        --currency = CASE WHEN (pt.settle_currency_code = '566') then 'Naira'
                        --WHEN (pt.settle_currency_code = '840') then 'US DOLLAR'
                        --ELSE  pt.settle_currency_code
                        --END

FROM  dbo.sstl_journal_all AS J (NOLOCK)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
RIGHT OUTER JOIN #post_tran_temp AS PT (NOLOCK)
ON (J.post_tran_id = PT.post_tran_id AND J.post_tran_cust_id = PT.post_tran_cust_id)
RIGHT OUTER JOIN #post_tran_cust_temp AS PTC (NOLOCK)
ON (J.post_tran_cust_id = PTC.post_tran_cust_id AND J.post_tran_cust_id = PTC.post_tran_cust_id)
left join #post_tran_temp ptt (nolock) 
on (pt.post_tran_cust_id = ptt.post_tran_cust_id and ptt.tran_postilion_originated = 1
    and pt.tran_nr = ptt.tran_nr)
LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code)

WHERE 

      PT.tran_postilion_originated = 0
     
      AND PT.rsp_code_rsp in ('00','11','09')
      
      AND (
          (PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220'))

       or ((PT.settle_amount_impact<> 0 and PT.message_type = '0420' 

       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) <> 1 and PT.tran_reversed <> 2)
       or (PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 ))

       or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1) IN ('0','1') ))
       or (PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)IN ( '0','1' ))))
      
      AND (J.Business_date >= @from_date AND J.Business_date< (@to_date))

      AND not (merchant_type in ('4004','4722') and pt.tran_type = '00' and source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(pt.settle_amount_impact/100)< 200
       and not (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%'))

      --AND not (merchant_type = '5371' and pt.tran_type = '00' and 

      --          (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) <> 2) 
      --         and not (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%'))
      
      and 
	     (convert(varchar(50),pt.tran_nr))+'_'+pt.retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	      
      --AND PTC.post_tran_cust_id >= @rpt_tran_id
      AND PTC.totals_group not in ('CUPGroup')
      and NOT (PTC.totals_group in ('VISAGroup') and PT.acquiring_inst_id_code = '627787')
	  and NOT (PTC.totals_group in ('VISAGroup') and PT.sink_node_name not in ('ASPPOSVINsnk')
	            and not (ptc.source_node_name = 'SWTFBPsrc' and pt.sink_node_name = 'ASPPOSVISsnk') 
	           )
      AND
            LEFT( ptc.source_node_name,2 ) <> 'SB'
             AND
            LEFT( pt.sink_node_name,2)<> 'SB'

      and (ptc.source_node_name not LIKE '%TPP%')
       and (pt.sink_node_name  not LIKE '%TPP%')
       and not (ptc.source_node_name  = 'MEGATPPsrc' and pt.tran_type = '00')
      --and source_node_name not in ('SWTWMASBsrc','SWTWEMSBsrc')
      and source_node_name <> 'SWTMEGADSsrc'
      and ptc.card_acceptor_id_code not in ('IPG000000000001')
      and pt.sink_node_name not in ('WUESBPBsnk')
      --and not (PT.tran_type in ('01','09') or (PT.tran_type = '00' and 
      --dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
      --and (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)in ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'
                                                                             -- ,'16','17','18','19','20','21','22','23') 
      --or dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)is null))
      --and(pt.datetime_req > '2015-08-05 09:20:00.000' and pt.datetime_req < '2015-08-05 10:40:00.000'))

GROUP BY 

 j.business_date,
 DebitAccNr.acc_nr,
 CreditAccNr.acc_nr,
 PT.tran_type,

 dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type),
 dbo.fn_rpt_MCC_Visa (PTC.merchant_type,PTC.terminal_id,PT.tran_type,PTC.PAN),pt.acquiring_inst_id_code,

 ptc.totals_group, SUBSTRING(PTC.Terminal_id,1,1),
 dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan),
dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan),
dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name),
dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan),
dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type),
dbo.fn_rpt_CardType (PTC.pan ,PT.sink_node_name ,PT.tran_type,PTC.TERMINAL_ID),
dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name),
PTT.Retention_data,
pt.settle_currency_code,
PTC.source_node_name,
PT.sink_node_name,
dbo.fn_rpt_late_reversal(pt.tran_nr,pt.message_type,pt.retrieval_reference_nr),
dbo.fn_rpt_CardGroup(ptc.pan), dbo.fn_rpt_terminal_type(ptc.terminal_id),
pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+ptc.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
dbo.fn_rpt_MCC_cashback (PTC.terminal_id, PT.tran_type),
(case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PTC.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PTC.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
(case when (not ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr.acc_nr LIKE 'ISW%' and DebitAccNr.acc_nr not LIKE '%POOL%' ) OR (CreditAccNr.acc_nr LIKE 'ISW%' and CreditAccNr.acc_nr not LIKE '%POOL%' ) ) and (substring(ptc.totals_group,1,3) = acc.bank_code1) then acc.bank_code1
                      else substring(ptc.totals_group,1,3) END),
acc.bank_code1, acc.bank_code, PT.acquiring_inst_id_code,pt.extended_tran_type,PTC.merchant_type
OPTION(MAXDOP 16)

create table #temp_table
(unique_key VARCHAR(200))

create nonclustered index ix_temp_table ON #temp_table(
unique_key
)
insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
OPTION(MAXDOP 16)

insert into settlement_summary_breakdown	
(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer)	
	SELECT 
			bank_code,trxn_category,Debit_Account_type,Credit_Account_type,sum(trxn_amount),sum(trxn_fee),trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer 
	FROM 
			#report_result 
where     index_no not IN (SELECT index_no FROM  #report_result where source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') and unique_key  IN (SELECT unique_key FROM #temp_table))
          

GROUP BY bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_date,Currency,late_reversal,card_type,terminal_type,Acquirer, Issuer
OPTION(MAXDOP 16)

END  







































































































































GO
/****** Object:  StoredProcedure [dbo].[psp_rpt_settlement_reconciliation]    Script Date: 03/15/2016 18:58:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO








ALTER PROCEDURE [dbo].[psp_rpt_settlement_reconciliation]
      @Start_Date DATETIME=NULL,    -- yyyymmdd
      @End_Date DATETIME=NULL,      -- yyyymmdd
      @report_date_start DATETIME = NULL,
      @report_date_end DATETIME = NULL,
      @rpt_tran_id INT = NULL

AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

      
      SET NOCOUNT ON

      CREATE TABLE #report_result
      ( 
                  --post_tran_cust_id  VARCHAR (19),
                  --tran_type   CHAR (2),
                  
                        business_date VARCHAR (40),
                        --datetime_rsp datetime,
                        Terminal_id CHAR (8),
                        PAN  VARCHAR (19),
                        --message_type CHAR (4),
                        rsp_code_rsp CHAR (2),
                        --PTC.source_node_name VARCHAR (40),
                        card_acceptor_id_code VARCHAR (25),
                       -- merchant_type CHAR (4),
                        terminal_owner VARCHAR(20),
                        totals_group VARCHAR (19),
                        --PT.sink_node_name VARCHAR (20),
                        system_trace_audit_nr CHAR (6),
                        acquiring_inst_id_code VARCHAR(12),
                        retrieval_reference_nr CHAR (12),
                        --settle_amount_rsp FLOAT,
                        --settle_tran_fee_rsp FLOAT,
                        --tran_reversed INT,
                        extended_tran_type CHAR (4),
                        --payee VARCHAR(50),
                        --receiving_inst_id_code VARCHAR(50),
                        Amount_payable  FLOAT,
                        Amount_receivable FLOAT,
                        Issuer_fee_payable  FLOAT,
                        Acquirer_fee_payable  FLOAT,
                        Acquirer_fee_receivable  FLOAT,
                        Issuer_fee_receivable  FLOAT,
                        ISW_fee_receivable  FLOAT,
                        Processor_fee_receivable  FLOAT,
                        NCS_fee_receivable  FLOAT,
                        Terminal_owner_fee_receivable  FLOAT, 
                        Easyfuel_account  FLOAT,
                        ISO_fee_receivable  FLOAT,
                        PTSP_fee_receivable  FLOAT,
                        Recharge_fee_payable  FLOAT,
                        PAYIN_Institution_fee_receivable  FLOAT,
                        Fleettech_fee_receivable  FLOAT,
                        LYSA_fee_receivable  FLOAT,
                        SVA_fee_receivable  FLOAT,
                        udirect_fee_receivable  FLOAT,
                        Merchant_fee_receivable FLOAT,
                        ATMC_Fee_Payable FLOAT,
                        ATMC_Fee_Receivable FLOAT,
                        Currency_code char (3)
                  
                       
                                       
      )
      
            
                        CREATE  NONCLUSTERED INDEX ix_report_result_1 ON #report_result (
                  business_date
      
      )                                
                                                         
                                       
      CREATE  NONCLUSTERED INDEX ix_report_result_2 ON #report_result (
      Terminal_id
      )

      
CREATE NONCLUSTERED INDEX ix_report_result_3 ON #report_result (
      PAN
      
      )

      CREATE NONCLUSTERED INDEX ix_report_result_4 ON #report_result (
   card_acceptor_id_code 
      
      )
            CREATE  NONCLUSTERED INDEX ix_report_result_5 ON #report_result (
      terminal_owner
      
      )
            CREATE  NONCLUSTERED INDEX ix_report_result_6 ON #report_result (
      totals_group
      
      )
            CREATE  NONCLUSTERED INDEX ix_report_result_7 ON #report_result (
      system_trace_audit_nr
      
      )
            CREATE  NONCLUSTERED INDEX ix_report_result_8 ON #report_result (
      acquiring_inst_id_code
      
      )
            CREATE  NONCLUSTERED INDEX ix_report_result_9 ON #report_result (
      retrieval_reference_nr
      
      )           



DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,-1,GETDATE()),111),'/',''))
SET @to_date = ISNULL(@end_date,REPLACE(CONVERT(VARCHAR(MAX), GETDATE(),111),'/',''))
DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT


IF( DATEDIFF(D,@from_date, @to_date)=0) BEGIN   
      SELECT @first_post_tran_id = MIN(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@from_date
      SELECT @last_post_tran_id =  max(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@to_date
END
ELSE BEGIN
      SELECT @first_post_tran_id = MIN(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date =@from_date
      SELECT @last_post_tran_id =  max(post_tran_id ) FROM sstl_journal_all(NOLOCK) where business_date <@to_date
END

CREATE TABLE [dbo].[#post_tran_temp](
      [post_tran_id] [bigint] NOT NULL,
      [post_tran_cust_id] [bigint] NOT NULL,
      [settle_entity_id] BIGINT NULL,
      [batch_nr] [int] NULL,
      [prev_post_tran_id] [bigint] NULL,
      [next_post_tran_id] [bigint] NULL,
      [sink_node_name] varchar(500) NULL,
      [tran_postilion_originated] int NOT NULL,
      [tran_completed] int NOT NULL,
      [message_type] [char](4) NOT NULL,
      [tran_type] [char](2) NULL,
      [tran_nr] [bigint] NOT NULL,
      [system_trace_audit_nr] [char](6) NULL,
      [rsp_code_req] [char](2) NULL,
      [rsp_code_rsp] [char](2) NULL,
      [abort_rsp_code] [char](2) NULL,
      [auth_id_rsp] [varchar](10) NULL,
      [auth_type] [numeric](1, 0) NULL,
      [auth_reason] [numeric](1, 0) NULL,
      [retention_data] [varchar](999) NULL,
      [acquiring_inst_id_code] [varchar](11) NULL,
      [message_reason_code] [char](4) NULL,
      [sponsor_bank] [char](8) NULL,
      [retrieval_reference_nr] [char](12) NULL,
      [datetime_tran_gmt] [datetime] NULL,
      [datetime_tran_local] [datetime] NOT NULL,
      [datetime_req] [datetime] NOT NULL,
      [datetime_rsp] [datetime] NULL,
      [realtime_business_date] [datetime] NOT NULL,
      [recon_business_date] [datetime] NOT NULL,
      [from_account_type] [char](2) NULL,
      [to_account_type] [char](2) NULL,
      [from_account_id] [varchar](28) NULL,
      [to_account_id] [varchar](28) NULL,
      [tran_amount_req] MONEY NULL,
      [tran_amount_rsp] MONEY NULL,
      [settle_amount_impact] MONEY NULL,
      [tran_cash_req] MONEY NULL,
      [tran_cash_rsp] MONEY NULL,
      [tran_currency_code] VARCHAR(5)NULL,
      [tran_tran_fee_req] MONEY NULL,
      [tran_tran_fee_rsp] MONEY NULL,
      [tran_tran_fee_currency_code] VARCHAR(5)NULL,
      [tran_proc_fee_req] MONEY NULL,
      [tran_proc_fee_rsp] MONEY NULL,
      [tran_proc_fee_currency_code] VARCHAR(5)NULL,
      [settle_amount_req] MONEY NULL,
      [settle_amount_rsp] MONEY NULL,
      [settle_cash_req] MONEY NULL,
      [settle_cash_rsp] MONEY NULL,
      [settle_tran_fee_req] MONEY NULL,
      [settle_tran_fee_rsp] MONEY NULL,
      [settle_proc_fee_req] MONEY NULL,
      [settle_proc_fee_rsp] MONEY NULL,
      [settle_currency_code] VARCHAR(5)NULL,
      [pos_entry_mode] [char](3) NULL,
      [pos_condition_code] [char](2) NULL,
      [additional_rsp_data] [varchar](25) NULL,
      [tran_reversed] [char](1) NULL,
      [prev_tran_approved] int NULL,
      [issuer_network_id] [varchar](11) NULL,
      [acquirer_network_id] [varchar](11) NULL,
      [extended_tran_type] [char](4) NULL,
      [from_account_type_qualifier] [char](1) NULL,
      [to_account_type_qualifier] [char](1) NULL,
      [bank_details] [varchar](31) NULL,
      [payee] [char](25) NULL,
      [card_verification_result] [char](1) NULL,
      [online_system_id] [int] NULL,
      [participant_id] [int] NULL,
      [opp_participant_id] [int] NULL,
      [receiving_inst_id_code] [varchar](11) NULL,
      [routing_type] [int] NULL,
      [pt_pos_operating_environment] [char](1) NULL,
      [pt_pos_card_input_mode] [char](1) NULL,
      [pt_pos_cardholder_auth_method] [char](1) NULL,
      [pt_pos_pin_capture_ability] [char](1) NULL,
      [pt_pos_terminal_operator] [char](1) NULL,
      [source_node_key] [varchar](32) NULL,
      [proc_online_system_id] [int] NULL
) 

SET ANSI_PADDING OFF


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [next_post_tran_id]


ALTER TABLE [dbo].[#post_tran_temp] ADD  DEFAULT ((0)) FOR [tran_reversed]


CREATE clustered INDEX ix_post_tran_temp_1 ON  [#post_tran_temp] (
      post_tran_id
)
CREATE INDEX ix_post_tran_temp_2 ON  [#post_tran_temp] (
      post_tran_cust_id
)  INCLUDE(post_tran_id,recon_business_date,datetime_req, datetime_tran_local)
CREATE INDEX ix_post_tran_temp_3 ON  [#post_tran_temp] (
      datetime_req
)  INCLUDE(post_tran_id,recon_business_date,post_tran_cust_id, datetime_tran_local)

CREATE INDEX ix_post_tran_temp_4 ON  [#post_tran_temp] (
      recon_business_date
)  INCLUDE(post_tran_id,datetime_req,post_tran_cust_id, datetime_tran_local)

CREATE INDEX ix_post_tran_temp_5 ON  [#post_tran_temp] (
sink_node_name
)
CREATE INDEX ix_post_tran_temp_6 ON  [#post_tran_temp] (
acquiring_inst_id_code
)
CREATE INDEX ix_post_tran_temp_7 ON  [#post_tran_temp] (
[retention_data]
)
CREATE INDEX ix_post_tran_temp_8 ON  [#post_tran_temp] (
payee
)
CREATE INDEX ix_post_tran_cust_9 ON [#post_tran_temp] (
extended_tran_type
) 

CREATE TABLE [dbo].[#post_tran_cust_temp](
      [post_tran_cust_id] [bigint] NOT NULL,
      [source_node_name] varchar(500) NOT NULL,
      [draft_capture] BIGINT NULL,
      [pan] [varchar](19) NULL,
      [card_seq_nr] [varchar](3) NULL,
      [expiry_date] [char](4) NULL,
      [service_restriction_code] [char](3) NULL,
      [terminal_id] varchar(10) NULL,
      [terminal_owner] [varchar](25) NULL,
      [card_acceptor_id_code] [char](15) NULL,
      [mapped_card_acceptor_id_code] [char](15) NULL,
      [merchant_type] [char](4) NULL,
      [card_acceptor_name_loc] [char](40) NULL,
      [address_verification_data] [varchar](29) NULL,
      [address_verification_result] [char](1) NULL,
      [check_data] [varchar](70) NULL,
      [totals_group] [varchar](12) NULL,
      [card_product] [varchar](20) NULL,
      [pos_card_data_input_ability] [char](1) NULL,
      [pos_cardholder_auth_ability] [char](1) NULL,
      [pos_card_capture_ability] [char](1) NULL,
      [pos_operating_environment] [char](1) NULL,
      [pos_cardholder_present] [char](1) NULL,
      [pos_card_present] [char](1) NULL,
      [pos_card_data_input_mode] [char](1) NULL,
      [pos_cardholder_auth_method] [char](1) NULL,
      [pos_cardholder_auth_entity] [char](1) NULL,
      [pos_card_data_output_ability] [char](1) NULL,
      [pos_terminal_output_ability] [char](1) NULL,
      [pos_pin_capture_ability] [char](1) NULL,
      [pos_terminal_operator] [char](1) NULL,
      [pos_terminal_type] [char](2) NULL,
      [pan_search] [int] NULL,
      [pan_encrypted] [char](18) NULL,
      [pan_reference] [char](42) NULL,
CONSTRAINT [pk_post_tran_cust_temp_recon] PRIMARY KEY CLUSTERED 
(
      [post_tran_cust_id] ASC
))
ALTER TABLE [dbo].[#post_tran_cust_temp] ADD  DEFAULT ((0)) FOR [draft_capture]
CREATE INDEX ix_post_tran_cust_1 ON [#post_tran_cust_temp] (
terminal_id
) 
CREATE INDEX ix_post_tran_cust_2 ON [#post_tran_cust_temp] (
totals_group
) 
CREATE INDEX ix_post_tran_cust_3 ON [#post_tran_cust_temp] (
card_acceptor_id_code
) 


CREATE INDEX ix_post_tran_cust_4 ON [#post_tran_cust_temp] (
source_node_name
) 

CREATE INDEX ix_post_tran_cust_5 ON [#post_tran_cust_temp] (
pan
) 

CREATE INDEX ix_post_tran_cust_6 ON [#post_tran_cust_temp] (
merchant_type
) 


          
IF(@@ERROR <>0)
RETURN

INSERT INTO  [#post_tran_temp](
       [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id]
      ,[next_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[auth_reason]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
     ,[sponsor_bank]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[tran_proc_fee_req]
      ,[tran_proc_fee_rsp]
      ,[tran_proc_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_cash_req]
      ,[settle_cash_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_proc_fee_req]
      ,[settle_proc_fee_rsp]
      ,[settle_currency_code]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[additional_rsp_data]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[issuer_network_id]
      ,[acquirer_network_id]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[bank_details]
      ,[payee]
      ,[card_verification_result]
      ,[online_system_id]
      ,[participant_id]
      ,[opp_participant_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[pt_pos_operating_environment]
      ,[pt_pos_card_input_mode]
      ,[pt_pos_cardholder_auth_method]
      ,[pt_pos_pin_capture_ability]
      ,[pt_pos_terminal_operator]
      ,[source_node_key]
      ,[proc_online_system_id]
      )
SELECT   [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id]
      ,[next_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[auth_type]
      ,[auth_reason]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[sponsor_bank]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[tran_proc_fee_req]
      ,[tran_proc_fee_rsp]
      ,[tran_proc_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_cash_req]
      ,[settle_cash_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_proc_fee_req]
      ,[settle_proc_fee_rsp]
      ,[settle_currency_code]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[additional_rsp_data]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[issuer_network_id]
      ,[acquirer_network_id]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[bank_details]
      ,[payee]
      ,[card_verification_result]
      ,[online_system_id]
      ,[participant_id]
      ,[opp_participant_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[pt_pos_operating_environment]
      ,[pt_pos_card_input_mode]
      ,[pt_pos_cardholder_auth_method]
      ,[pt_pos_pin_capture_ability]
      ,[pt_pos_terminal_operator]
      ,[source_node_key]
      ,[proc_online_system_id]
  FROM [postilion_office].[dbo].[post_tran] WITH  (NOLOCK, INDEX(ix_post_tran_1))
WHERE 
(post_tran_id >=@first_post_tran_id) AND (post_tran_id<=@last_post_tran_id)
    
OPTION (MAXDOP 16)


INSERT INTO [#post_tran_cust_temp](
[post_tran_cust_id]
      ,[source_node_name]
      ,[draft_capture]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[service_restriction_code]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[mapped_card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[check_data]
      ,[totals_group]
      ,[card_product]
      ,[pos_card_data_input_ability]
      ,[pos_cardholder_auth_ability]
      ,[pos_card_capture_ability]
      ,[pos_operating_environment]
      ,[pos_cardholder_present]
      ,[pos_card_present]
      ,[pos_card_data_input_mode]
      ,[pos_cardholder_auth_method]
      ,[pos_cardholder_auth_entity]
      ,[pos_card_data_output_ability]
      ,[pos_terminal_output_ability]
      ,[pos_pin_capture_ability]
      ,[pos_terminal_operator]
      ,[pos_terminal_type]
      ,[pan_search]
      ,[pan_encrypted]
      ,[pan_reference]
   

)

SELECT [post_tran_cust_id]
      ,[source_node_name]
      ,[draft_capture]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[service_restriction_code]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[mapped_card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[check_data]
      ,[totals_group]
      ,[card_product]
      ,[pos_card_data_input_ability]
      ,[pos_cardholder_auth_ability]
      ,[pos_card_capture_ability]
      ,[pos_operating_environment]
      ,[pos_cardholder_present]
      ,[pos_card_present]
      ,[pos_card_data_input_mode]
      ,[pos_cardholder_auth_method]
      ,[pos_cardholder_auth_entity]
      ,[pos_card_data_output_ability]
      ,[pos_terminal_output_ability]
      ,[pos_pin_capture_ability]
      ,[pos_terminal_operator]
      ,[pos_terminal_type]
      ,[pan_search]
      ,[pan_encrypted]
      ,[pan_reference]
  FROM [postilion_office].[dbo].[post_tran_cust] WITH  (NOLOCK, INDEX(pk_post_tran_cust))
  WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM [#post_tran_temp])
OPTION (MAXDOP 16)
        
            

EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 

SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1
            

INSERT
                        INTO #report_result

      SELECT
                  --PT.post_tran_cust_id ,
                  --PT.tran_type,         
                        j.business_date ,
                        --PT.datetime_rsp ,
                        PTC.Terminal_id ,
                        PTC.PAN ,
                        --PT.message_type ,
                        PT.rsp_code_rsp ,
                        --PTC.source_node_name VARCHAR (40),
                        PTC.card_acceptor_id_code ,
                        --PTC.merchant_type ,
                        PTC.terminal_owner ,
                        PTC.totals_group ,
                        --PT.sink_node_name VARCHAR (20),
                       
                        PT.system_trace_audit_nr,

                        PT.acquiring_inst_id_code,
                        PT.retrieval_reference_nr,
                        --PT.settle_amount_rsp,
                        --PT.settle_tran_fee_rsp,

                        --PT.tran_reversed,
                        PT.extended_tran_type,
                        --PT.payee,
                        --PT.receiving_inst_id_code,
                        Amount_payable  = Sum ( CASE 
                             WHEN (PTC.source_node_name = 'CCLOADsrc' and PTC.terminal_id like '3IAP%') then 0
                             WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE')then J.amount
                             WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') then J.amount*-1
                             WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE')then J.amount
                       ELSE 0 END)/100,   

                        Amount_receivable = Sum ( CASE
                             WHEN (PTC.source_node_name = 'CCLOADsrc' and PTC.terminal_id like '3IAP%') then 0
                             WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') then J.amount*-1
                             WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE')then J.amount
                       ELSE 0 END)/100,   
                        Issuer_fee_payable = Sum ( CASE 
                             WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') then J.fee*-1
                             WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE')then J.fee
                             WHEN (DebitAccNr.acc_nr LIKE '%SPONSOR%FEE%PAYABLE') then J.fee*-1
                             WHEN (CreditAccNr.acc_nr LIKE '%SPONSOR%FEE%PAYABLE')then J.fee
                             
                       ELSE 0 END)/100,   
                        Acquirer_fee_payable = Sum ( CASE
                             WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE' and DebitAccNr.acc_nr NOT LIKE '%ISW%') then J.fee*-1
                             WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE' and CreditAccNr.acc_nr NOT LIKE '%ISW%')then J.fee
                       ELSE 0 END)/100,   

                        Acquirer_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE' and DebitAccNr.acc_nr NOT LIKE '%ISW%') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE' and CreditAccNr.acc_nr NOT LIKE '%ISW%')then J.fee
                        ELSE 0 END)/100,  
                        Issuer_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE')then J.fee
                              WHEN (DebitAccNr.acc_nr LIKE '%SPONSOR%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%SPONSOR%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  

                        ISW_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' and DebitAccNr.acc_nr NOT LIKE '%PROCESSOR%' and DebitAccNr.acc_nr NOT LIKE '%PTSP%'and DebitAccNr.acc_nr NOT LIKE '%ISO%' and DebitAccNr.acc_nr NOT LIKE '%PAYIN%' and DebitAccNr.acc_nr NOT LIKE '%NCS%') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE'and CreditAccNr.acc_nr NOT LIKE '%PROCESSOR%' and CreditAccNr.acc_nr NOT LIKE '%PTSP%' and CreditAccNr.acc_nr NOT LIKE '%ISO%' and CreditAccNr.acc_nr NOT LIKE '%PAYIN%' and CreditAccNr.acc_nr NOT LIKE '%NCS%')then J.fee
                        ELSE 0 END)/100,  
                        Processor_fee_receivable= Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  

                        NCS_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  

                        Terminal_owner_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEI%' and DebitAccNr.acc_nr NOT LIKE '%ISW%') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEI%' and CreditAccNr.acc_nr NOT LIKE '%ISW%')then J.fee
                        ELSE 0 END)/100,  
                        Easyfuel_account = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT')then J.fee
                        ELSE 0 END)/100,  
                        ISO_fee_receivable  = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  
                        PTSP_fee_receivable  = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')then J.fee

                        ELSE 0 END)/100,  
                        Recharge_fee_payable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE')then J.fee
                        ELSE 0 END)/100,
                        PAYIN_Institution_fee_receivable   = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        Fleettech_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        LYSA_fee_receivable  = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        SVA_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        udirect_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        Merchant_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100, 

                        ATMC_Fee_PAYABLE = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE')then J.fee
                        ELSE 0 END)/100, 

                        ATMC_Fee_Receivable = Sum ( CASE
                              WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,

                         Currency_code = CASE WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and 
                           dbo.fn_rpt_account_type_2 (DebitAccNr.acc_nr,CreditAccNr.acc_nr) = 'BILLPAYMENT MCARD') THEN '840'
                                              WHEN (dbo.fn_rpt_account_type_2 (DebitAccNr.acc_nr,CreditAccNr.acc_nr) = 'MCARD BILLING') THEN '840'
                        ELSE pt.settle_currency_code END


                        
 
                   
                      



      FROM
                        dbo.sstl_journal_all AS J
                  LEFT OUTER JOIN
                        dbo.sstl_se_acc_nr_w AS DebitAccNr
                        ON (
                              J.debit_acc_nr_id = DebitAccNr.acc_nr_id 
                              AND 
                              J.config_set_id = DebitAccNr.config_set_id
                              )
                  LEFT OUTER JOIN
                dbo.sstl_se_acc_nr_w AS CreditAccNr 
                        ON (
                              J.credit_acc_nr_id = CreditAccNr.acc_nr_id 
                              AND 
                              J.config_set_id = CreditAccNr.config_set_id 
                              )
                  LEFT OUTER JOIN
                dbo.sstl_se_amount_w AS Amount 
                        ON (
                              J.amount_id = Amount.amount_id 
                              AND 
                              J.config_set_id = Amount.config_set_id 
                              )
                  LEFT OUTER JOIN
                dbo.sstl_se_fee_w AS Fee 
                        ON (
                              J.fee_id = Fee.fee_id 
                              AND 
                              J.config_set_id = Fee.config_set_id 
                              )
                  LEFT OUTER JOIN
                dbo.sstl_coa_w AS Coa 
                        ON (
                              J.coa_id = Coa.coa_id 
                              AND 
                              J.config_set_id = Coa.config_set_id
                              )
                  RIGHT OUTER JOIN
                dbo.#post_tran_temp AS PT (NOLOCK)
                        ON (
                              J.post_tran_id = PT.post_tran_id
                              AND
                              J.post_tran_cust_id = PT.post_tran_cust_id
                              )
                RIGHT OUTER JOIN
                dbo.#post_tran_cust_temp AS PTC (NOLOCK)
                        ON (
                              J.post_tran_cust_id = PTC.post_tran_cust_id
                              AND
                              J.post_tran_cust_id = PTC.post_tran_cust_id
                                     )
                 

WHERE 

      PT.tran_postilion_originated = 0
     
      AND PT.rsp_code_rsp in ('00','11','09')
      
      AND (
          (PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220'))

       or ((PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) <> 1 and PT.tran_reversed <> 2)
       or (PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1 ))

       or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0'))
       or (PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')))
      
      AND (PT.recon_business_date >= @from_date AND PT.recon_business_date < (@to_date+1))

      AND not (merchant_type in ('4004','4722') and pt.tran_type = '00' and ptc.source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(pt.settle_amount_impact/100)< 200
          AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr.acc_nr,CreditAccNr.acc_nr) = 'MCARD BILLING'))

      --AND not (merchant_type in ('5371') and pt.tran_type = '00' and 
      --          (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) <> 2) 
      --         AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr.acc_nr,CreditAccNr.acc_nr) = 'MCARD BILLING'))
      --AND PTC.post_tran_cust_id >= @rpt_tran_id
       and 
	     (convert(varchar(50),pt.tran_nr))+'_'+pt.retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	     
      AND NOT (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan) = '1' and (DebitAccNr.acc_nr like '%amount%'
               or CreditAccNr.acc_nr like '%amount%')) 
      AND NOT (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 2
               AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr.acc_nr,CreditAccNr.acc_nr) = 'MCARD BILLING'))
      --AND NOT (dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type)= '1' and terminal_id not like  '3IAP%')
      --AND NOT (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  --PT.extended_tran_type ,PTC.source_node_name) = '1' and PT.tran_type = '50')
      AND NOT (PTC.Terminal_id like '3IGW%' and PT.Tran_type = '00' and PT.acquiring_inst_id_code = '111111')
      AND NOT (PTC.Terminal_id = '3VRV0001' and PT.Tran_type = '00' and PT.sink_node_name = 'CCLOADsnk')
      --AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr.acc_nr,CreditAccNr.acc_nr) = 'MCARD BILLING')
      --AND NOT (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  --PT.extended_tran_type ,PTC.source_node_name) = '314' AND PT.tran_type= '50')
      AND PTC.totals_group not in ('CUPGroup')
      
	  and NOT (PTC.totals_group in ('VISAGroup') and PT.acquiring_inst_id_code = '627787')
	  and NOT (PTC.totals_group in ('VISAGroup') and PT.sink_node_name not in ('ASPPOSVINsnk'))
      and PT.tran_type <> '21'
      and pt.settle_currency_code = '566'
      and ptc.source_node_name  NOT LIKE 'SB%'
      and pt.sink_node_name  NOT LIKE 'SB%'
      and not(ptc.source_node_name  LIKE '%TPP%')
       and not(pt.sink_node_name  LIKE '%TPP%' )
        and not (ptc.source_node_name  = 'MEGATPPsrc' and pt.tran_type = '00')
        and not (pt.tran_type = '00' and substring(ptc.terminal_id,1,1) in ('0','1') and PT.sink_node_name = 'CCLOADsnk')
        and ptc.source_node_name not in ('ASPSPNTFsrc', 'ASPSPONUSsrc') 
        and not (ptc.source_node_name in ('SWTNCS2src','SWTFBPsrc') and pt.sink_node_name in ('ASPPOSLMCsnk'))
         and ptc.card_acceptor_id_code not in ('IPG000000000001')
          and pt.sink_node_name not in ('WUESBPBsnk')
        --and datetime_req > '2015-07-29 09:00:00.000' and datetime_req < '2015-07-29 13:00:00.000'
        
         --and not (PT.tran_type in ('01','09') or (PT.tran_type = '00' and 
    --  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name, PTC.terminal_id ,ptc.totals_group ,ptc.pan) = 1
     -- and (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)in ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'
                                                                            --  ,'16','17','18','19','20','21','22','23') 
     -- or dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id,PT.tran_type)is null))
     -- and(pt.datetime_req > '2015-08-05 09:20:00.000' and pt.datetime_req < '2015-08-05 10:40:00.000'))

group by PT.retrieval_reference_nr,J.business_date,
         PTC.terminal_id,PTC.pan,
         PT.rsp_code_rsp,PTC.card_acceptor_id_code,
         PTC.terminal_owner,PTC.totals_group,PT.system_trace_audit_nr,
         PT.acquiring_inst_id_code,
         PT.extended_tran_type,
         pt.settle_currency_code,
         dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name,pt.tran_type,ptc.pan),
         dbo.fn_rpt_account_type_2 (DebitAccNr.acc_nr,CreditAccNr.acc_nr)
         --PT.tran_type,PT.message_type,PT.settle_amount_rsp,PT.settle_tran_fee_rsp,PT.tran_reversed,
        
         --PT.payee,PT.receiving_inst_id_code,
         --PT.post_tran_cust_id,PT.datetime_rsp,PTC.merchant_type,
         
        OPTION (MAXDOP 16)

select * from #report_result 

where  (ROUND((Amount_payable + Amount_receivable + Issuer_fee_payable +  Acquirer_fee_payable + 
       Acquirer_fee_receivable + Issuer_fee_receivable + ISW_fee_receivable + Processor_fee_receivable + 
       NCS_fee_receivable + Terminal_owner_fee_receivable + Easyfuel_account + ISO_fee_receivable + 
       PTSP_fee_receivable + Recharge_fee_payable + PAYIN_Institution_fee_receivable + 
       Fleettech_fee_receivable + LYSA_fee_receivable +  SVA_fee_receivable + udirect_fee_receivable + 
       Merchant_fee_receivable + ATMC_Fee_PAYABLE + ATMC_Fee_Receivable),2)
       
       > 0) or 

      (ROUND((Amount_payable + Amount_receivable + Issuer_fee_payable +  Acquirer_fee_payable + 
       Acquirer_fee_receivable + Issuer_fee_receivable + ISW_fee_receivable + Processor_fee_receivable + 
       NCS_fee_receivable + Terminal_owner_fee_receivable + Easyfuel_account + ISO_fee_receivable + 
       PTSP_fee_receivable + Recharge_fee_payable + PAYIN_Institution_fee_receivable + 
       Fleettech_fee_receivable + LYSA_fee_receivable +  SVA_fee_receivable + udirect_fee_receivable + 
       Merchant_fee_receivable + ATMC_Fee_PAYABLE + ATMC_Fee_Receivable),2)
       
       < 0)

OPTION (MAXDOP 16)

END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_CashAdvance_VAS]    Script Date: 03/15/2016 18:58:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_CashAdvance_VAS]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	---@SinkNode		VARCHAR(40),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON

	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40),
		terminal_owner		VARCHAR(25),
		acquiring_inst_id_code		VARCHAR(25),
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
		--extended_tran_type      CHAR(255),
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
		structured_data_req		TEXT,
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		Network_ID			CHAR(255),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Previous month'
			
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

	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc,
				c.terminal_owner, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				--t.extended_tran_type,
				
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
				structured_data_req,
				dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				payee,
				t.from_account_id,
				t.to_account_id,
				t.payee
				
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	  			
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'
				AND 
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(c.terminal_id like '2%' AND t.message_type = '0200')
				
				AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')
				AND
				t.tran_type  IN ('01')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
			NULL AS Warning,
                @StartDate as StartDate,  
		@EndDate as EndDate,
                card_acceptor_id_code,
                card_acceptor_name_loc,
                sink_node_name,
                datetime_req,
                tran_type,
                acquiring_inst_id_code,
                case
                                when acquiring_inst_id_code= 589019 then 'FBN'             
                                when acquiring_inst_id_code= 627480 then 'UBA'
                                when acquiring_inst_id_code= 627629 then 'ZIB'                               
                                when acquiring_inst_id_code= 627787 then 'GTB'
                                when acquiring_inst_id_code= 627805 then 'PRU'
                                when acquiring_inst_id_code= 603948 then 'OBI'
                                when acquiring_inst_id_code= 627858 then 'IBTC'
                                when acquiring_inst_id_code= 627819 then 'AFRI'
                                when acquiring_inst_id_code= 627821 then 'WEM'
                                when acquiring_inst_id_code= 627955 then 'PHB'
                                when acquiring_inst_id_code= 628009 then 'FCMB'
                                when acquiring_inst_id_code= 627168 then 'DBL'
                                when acquiring_inst_id_code= 000000 then 'DBL'
                                when acquiring_inst_id_code= 602980 then 'UBN'
                                when acquiring_inst_id_code= 639249 then 'ETB'
                                when acquiring_inst_id_code= 639138 then 'FBP'
                                when acquiring_inst_id_code= 636088 then 'IBP'
                                when acquiring_inst_id_code= 639203 then 'FIN'
                                when acquiring_inst_id_code= 639139 then 'ABP'
                                when acquiring_inst_id_code= 636092 then 'SBP'
                                when acquiring_inst_id_code= 903708 then 'EBN'
                                when acquiring_inst_id_code= 639609 then 'UBP'
                                when acquiring_inst_id_code= 639563 then 'SPR'
                                when acquiring_inst_id_code= 023023 then 'CITI'
                                else 'Not Registered'             
                end as Bank,
                
               cast(sum ((settle_amount_impact) ) * -1 as numeric(18, 2)) as tran_value,
                sum (
                                case
                                                when settle_amount_impact < 0 then 1
                                                else 1
                                end) tran_volume
	FROM 
			#report_result

	GROUP BY card_acceptor_id_code,card_acceptor_name_loc,sink_node_name,datetime_req,tran_type,acquiring_inst_id_code
	ORDER BY 
				sink_node_name, acquiring_inst_id_code, datetime_req
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_bill_payment_VAS]    Script Date: 03/15/2016 18:58:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_bill_payment_VAS]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	---@SinkNode		VARCHAR(40),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON

	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40),
		terminal_owner		VARCHAR(25),
		acquiring_inst_id_code		VARCHAR(25),
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
		--extended_tran_type      CHAR(255),
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
		structured_data_req		TEXT,
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		Network_ID			CHAR(255),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Previous month'
			
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

	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc,
				c.terminal_owner, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				--t.extended_tran_type,
				
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
				structured_data_req,
				dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				payee,
				t.from_account_id,
				t.to_account_id,
				t.payee
				
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	 			
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'
				AND 
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(c.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				
				AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')
				AND
				t.tran_type NOT IN ('31', '39', '32')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
			NULL AS Warning,
                @StartDate as StartDate,  
		@EndDate as EndDate,
                card_acceptor_id_code,
                card_acceptor_name_loc,
                sink_node_name,
                datetime_req,
                tran_type,
                acquiring_inst_id_code,
                case
                                when acquiring_inst_id_code= 589019 then 'FBN'             
                                when acquiring_inst_id_code= 627480 then 'UBA'
                                when acquiring_inst_id_code= 627629 then 'ZIB'                               
                                when acquiring_inst_id_code= 627787 then 'GTB'
                                when acquiring_inst_id_code= 627805 then 'PRU'
                                when acquiring_inst_id_code= 603948 then 'OBI'
                                when acquiring_inst_id_code= 627858 then 'IBTC'
                                when acquiring_inst_id_code= 627819 then 'AFRI'
                                when acquiring_inst_id_code= 627821 then 'WEM'
                                when acquiring_inst_id_code= 627955 then 'PHB'
                                when acquiring_inst_id_code= 628009 then 'FCMB'
                                when acquiring_inst_id_code= 627168 then 'DBL'
                                when acquiring_inst_id_code= 000000 then 'DBL'
                                when acquiring_inst_id_code= 602980 then 'UBN'
                                when acquiring_inst_id_code= 639249 then 'ETB'
                                when acquiring_inst_id_code= 639138 then 'FBP'
                                when acquiring_inst_id_code= 636088 then 'IBP'
                                when acquiring_inst_id_code= 639203 then 'FIN'
                                when acquiring_inst_id_code= 639139 then 'ABP'
                                when acquiring_inst_id_code= 636092 then 'SBP'
                                when acquiring_inst_id_code= 903708 then 'EBN'
                                when acquiring_inst_id_code= 639609 then 'UBP'
                                when acquiring_inst_id_code= 639563 then 'SPR'
                                when acquiring_inst_id_code= 023023 then 'CITI'
                                else 'Not Registered'             
                end as Bank,
                
               cast(sum ((settle_amount_impact) ) * -1 as numeric(18, 2)) as tran_value,
                sum (
                                case
                                                when settle_amount_impact < 0 then 1
                                                else 1
                                end) tran_volume
	FROM 
			#report_result

	GROUP BY card_acceptor_id_code,card_acceptor_name_loc,sink_node_name,datetime_req,tran_type,acquiring_inst_id_code
	ORDER BY 
				sink_node_name, acquiring_inst_id_code, datetime_req
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_MC_Processing_all]    Script Date: 03/15/2016 18:58:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO























ALTER PROCEDURE [dbo].[osp_rpt_b08_MC_Processing_all]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(400),
	@SourceNodes		VARCHAR(255),
	@Bins			VARCHAR(18),
	@Period			VARCHAR(18),
	@show_full_pan		INT,	-- 0/1/2: Masked/Clear/As is
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
        @rpt_tran_id INT = NULL

AS
BEGIN

SET NOCOUNT ON
	-- The B08 report uses this stored proc.

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
		source_node_name		VARCHAR (40),
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
		pan_encrypted			CHAR (18),
                tran_reversed                   CHAR (1)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)
         

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END


        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #List_of_Bins (Bin	VARCHAR(30))

	INSERT INTO  #List_Of_Bins EXEC osp_rpt_util_split_nodenames @Bins

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
	
	
SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 	

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
				c.source_node_name,
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
				c.pan_encrypted,
                                tran_reversed
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

				--c.post_tran_cust_id >= @rpt_tran_id			
			        AND			
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0 ---updated from 0 for local pro aut
				      AND (
                               (T.settle_amount_impact<> 0 and T.message_type   in ('0200','0220'))

                             or ((T.settle_amount_impact<> 0 and T.message_type = '0420' 

                            and dbo.fn_rpt_isPurchaseTrx_sett(T.tran_type, C.source_node_name, T.sink_node_name,c.terminal_id,C.totals_group,C.pan) <> 1 and T.tran_reversed <> 2)
                            or (T.settle_amount_impact<> 0 and T.message_type = '0420' 
                            and dbo.fn_rpt_isPurchaseTrx_sett(T.tran_type, C.source_node_name, T.sink_node_name,c.terminal_id,C.totals_group,C.pan) = 1 )))

                             AND C.totals_group not in ('CUPGroup','VISAGroup')

                            and not (c.source_node_name  = 'MEGATPPsrc' and t.tran_type = '00')
      
                              and c.source_node_name NOT LIKE 'SWTMEGADSsrc'
				AND
				( @Bins IS NULL OR (@Bins IS NOT NULL AND substring (c.pan, 1,6) IN (SELECT Bin FROM #list_of_Bins)))
				AND
				(c.pan like '5%' and c.pan not like '506%')
				AND
				t.tran_type in ('00', '50')
				AND
				t.rsp_code_rsp IN ('00','11','09')---updated from 0 for local pro aut
				--AND
				--t.tran_reversed = 0
				
				AND
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
                  AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'


		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET

						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	
SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 SUM(CASE			
                	WHEN message_type in ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')THEN 1
                	WHEN message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16') THEN -1
                	
            		END) as tran_count,
                  
                   sink_node_name as rem_Bank,
                   source_node_name,
                   tran_type,
                   substring(terminal_id,1,1) as terminal_type,
                 (CASE WHEN rsp_code_rsp in ('00','08', '09') then 1 
                      else 0 end) as success_status,
                  
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr	

	 
	FROM 
			#report_result
where settle_amount_impact<> 0
Group by startdate, enddate, sink_node_name,rsp_code_rsp,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,source_node_name,tran_type,terminal_id
	
END








































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_MC_Processing]    Script Date: 03/15/2016 18:58:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[osp_rpt_b08_MC_Processing]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Bins			VARCHAR(18),
	@Period			VARCHAR(18),
	@show_full_pan		INT,	-- 0/1/2: Masked/Clear/As is
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
        @rpt_tran_id INT = NULL

AS
BEGIN

SET NOCOUNT ON
	-- The B08 report uses this stored proc.

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
		source_node_name		VARCHAR (40),
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
		pan_encrypted			CHAR (18)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)
         

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END


        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #List_of_Bins (Bin	VARCHAR(30))

	INSERT INTO  #List_Of_Bins EXEC osp_rpt_util_split_nodenames @Bins

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 	

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
				c.source_node_name,
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
				c.pan_encrypted
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	
				--c.post_tran_cust_id >= @rpt_tran_id			
			        AND			
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0
				 AND (
                               (T.settle_amount_impact<> 0 and T.message_type   in ('0200','0220'))

                             or ((T.settle_amount_impact<> 0 and T.message_type = '0420' 

                            and dbo.fn_rpt_isPurchaseTrx_sett_2(T.tran_type, C.source_node_name, T.sink_node_name)



 <> 1 and T.tran_reversed <> 2)
                            or (T.settle_amount_impact<> 0 and T.message_type = '0420' 
                            and dbo.fn_rpt_isPurchaseTrx_sett_2(T.tran_type, C.source_node_name, T.sink_node_name) = 1 )))

                             AND C.totals_group not in ('CUPGroup','VISAGroup')

                            and not (c.source_node_name  = 'MEGATPPsrc' and t.tran_type = '00')
      
                              and c.source_node_name NOT LIKE 'SWTMEGADSsrc'
				AND
				( @Bins IS NULL OR (@Bins IS NOT NULL AND substring (c.pan, 1,6) IN (SELECT Bin FROM #list_of_Bins)))
				AND
				(c.pan like '5%' and c.pan not like '506%')
				AND
				t.tran_type in ('00', '50')
				AND
				t.rsp_code_rsp IN ('00','11','09')
				--AND
				--t.tran_reversed = 0
				
				AND
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Verve_Int_settlement_bank]    Script Date: 03/15/2016 18:58:36 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_Verve_Int_settlement_bank]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@AcquirerBin     	VARCHAR(40),
	@show_full_pan	 	INT,		-- 0/1/2: Masked/Clear/As is
        @rpt_tran_id INT = NULL
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
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
		DollarRate				FLOAT,
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
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
                acquiring_inst_id_code                  VARCHAR (15)
	)

	-- Validate the source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Last business day'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode

        CREATE TABLE #list_of_AcquirerBin (AcquirerBin	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquirerBin EXEC osp_rpt_util_split_nodenames @AcquirerBin
	

create table #foreign_amt
(foreign_amount float, foreign_fee float, foreign_currency VARCHAR(3),TranID BIGINT)

SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        

Insert into #foreign_amt 

select p.tran_amount_rsp/100, 
dbo.formatAmount(-1 * p.tran_tran_fee_rsp/100, p.tran_currency_code) AS foreign_fee,
p.tran_currency_code,
p.post_tran_cust_id  from       post_tran p WITH (NOLOCK, INDEX (ix_post_tran_9))
                                 
                                INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (p.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

                               -- c.post_tran_cust_id >= @rpt_tran_id
                                and p.tran_postilion_originated = 0
                                and
                                (p.recon_business_date >= @report_date_start)
				
				and (p.recon_business_date <= @report_date_end)
				
				AND
				p.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				p.tran_completed = 1
				AND 
				(p.acquiring_inst_id_code in ( select AcquirerBin from #list_of_AcquirerBin))
                                AND
				p.tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             p.sink_node_name  NOT LIKE 'SB%'

	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
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
			t.to_account_type,
			1,--dbo.dollar_rate (t.settle_currency_code) as DollarRate,
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
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
                        t.acquiring_inst_id_code
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

            --c.post_tran_cust_id >= @rpt_tran_id
                        and
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			c.source_node_name  IN ('SWTMEGAsrc')
			AND
			(t.acquiring_inst_id_code in ( select AcquirerBin from #list_of_AcquirerBin))
                         And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			distinct 
			r.*,f.*
	FROM
			#report_result r
      inner join #foreign_amt f
      on r.tranId = f.tranId 
      
	ORDER BY  r.datetime_tran_local
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Verve_Int]    Script Date: 03/15/2016 18:58:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



























ALTER PROCEDURE [dbo].[osp_rpt_b06_Verve_Int]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@AcquirerBin     	VARCHAR(40),
	@show_full_pan	 	INT,		-- 0/1/2: Masked/Clear/As is
        @rpt_tran_id INT = NULL
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
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
		DollarRate				FLOAT,
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
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
                acquiring_inst_id_code                  VARCHAR (25),
         from_account_id                  VARCHAR (25)
	)

	-- Validate the source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Last business day'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode

        CREATE TABLE #list_of_AcquirerBin (AcquirerBin	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquirerBin EXEC osp_rpt_util_split_nodenames @AcquirerBin
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

create table #foreign_amt
(foreign_amount float, foreign_fee float, TranID BIGINT )

Insert into #foreign_amt 

select 
dbo.formatAmount(tran_amount_req, tran_currency_code)As tran_amount_rsp, 
dbo.formatAmount(-1 * p.settle_tran_fee_rsp, p.settle_currency_code) AS settle_tran_fee_rsp,
p.post_tran_cust_id  from       post_tran p WITH (NOLOCK, INDEX (ix_post_tran_9))
                                 
                                INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (p.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

                                -- c.post_tran_cust_id >= @rpt_tran_id
                                and p.tran_postilion_originated = 0
                                and
                                (p.recon_business_date >= @report_date_start)
				
				and (p.recon_business_date <= @report_date_end)
				
				AND
				p.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				p.tran_completed = 1
				AND 
				(p.acquiring_inst_id_code in ( select AcquirerBin from #list_of_AcquirerBin))
                                AND
				p.tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             p.sink_node_name  NOT LIKE 'SB%'

	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
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
			t.to_account_type,
			1,--dbo.dollar_rate (t.settle_currency_code) as DollarRate,
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
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
                        t.acquiring_inst_id_code,
            t.from_account_id

	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	        --c.post_tran_cust_id >= @rpt_tran_id
                        and
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			c.source_node_name  IN ('SWTMEGAsrc')
			AND
			(t.acquiring_inst_id_code in ( select AcquirerBin from #list_of_AcquirerBin))
                         And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor
	END

	SELECT
			distinct 
			r.*,f.*
	FROM
			#report_result r
      inner join #foreign_amt f
      on r.tranId = f.tranId 
      
	ORDER BY  r.datetime_tran_local
END




































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_SwitchedIn]    Script Date: 03/15/2016 18:58:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_SwitchedIn]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
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
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			INT,
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
		isOtherTrx					INT
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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
	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
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
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0100','0120','0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND 
			c.source_node_name = @SourceNode
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			
	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END




GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_SmartpointElohoTest]    Script Date: 03/15/2016 18:58:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_SmartpointElohoTest]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
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
		totals_group				Varchar(40)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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


        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
	CREATE TABLE #list_of_terminalIds (terminalID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_terminalIds EXEC osp_rpt_util_split_nodenames @terminalID
	
	
        INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
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
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data,
			c.totals_group
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')	
			AND
		(
			((c.source_node_name in (select source_node from #list_of_source_nodes)) 
			OR
			(substring (c.terminal_id,1,5) in (select substring(terminalID,1,5) from #list_of_terminalIds) --AND c.terminal_id like '1S%'
)
                        --OR
                        --(substring (c.terminal_id,2,3)=substring (@terminalID,3,3) 
			AND c.source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')
			)
			OR


            ((c.source_node_name  in ('SWTASPATMsrc')) AND (substring (c.terminal_id,2,3) in (select substring(terminalID,1,3) from #list_of_terminalIds)
            ) 
)

)

			AND
             
			c.source_node_name  NOT LIKE 'SB%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk','SWTSPTsnk')
            and t.sink_node_name not like '%TPP%'
                         and c.source_node_name not like '%TPP%'
			AND
			(terminal_id not like '2%')
           
             AND
             t.sink_node_name  NOT LIKE 'SB%'


	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
		

	

	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END




GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Smartpoint]    Script Date: 03/15/2016 18:58:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_Smartpoint]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	--@SourceNode		VARCHAR(40),
	--@terminalID		VARCHAR(40),	
	@show_full_pan	 BIT,
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
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			INT,
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
		retention_data				Varchar(999)
	)			

	/*IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END*/
	
	

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
	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
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
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
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
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')	
			--AND
			--( 
			--c.source_node_name = @SourceNode
			--OR
			--substring (c.terminal_id,1,5)=substring (@terminalID,1,5)
			--)
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk','SWTSPTsnk')
			AND
			(c.terminal_id not like '2%')
                        AND
			(C.source_node_name = 'ASPSPNOUsrc')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
          

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END




GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_MOI]    Script Date: 03/15/2016 18:58:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_MOI]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
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
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			INT,
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
		retention_data				Varchar(999)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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


        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
	CREATE TABLE #list_of_terminalIds (terminalID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_terminalIds EXEC osp_rpt_util_split_nodenames @terminalID
	
	
        INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
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
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
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
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')	
			AND
			( 
			c.source_node_name in (select source_node from #list_of_source_nodes)
			OR
			(substring (c.terminal_id,1,5) in (select substring(terminalID,1,5) from #list_of_terminalIds) AND c.terminal_id like '1S%')
                        --OR
                        --(substring (c.terminal_id,2,3)=substring (@terminalID,3,3) AND c.terminal_id not like '1S%'  and c.source_node_name = 'SWTMEGAsrc')
			)
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk','SWTSPTsnk')
			AND
			(terminal_id not like '2%')
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
		

	

	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END




GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_atmc]    Script Date: 03/15/2016 18:58:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_atmc]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(255),
	@SponsorBank		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sponsor_bank			CHAR (3),
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
		isOtherTrx					INT
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	
	IF (@StartDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @StartDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the StartDate parameter to DateTime
		-- The TIME portion of the StartDate should be 00:00:00
		SET @yy = CAST(SubString(@StartDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@StartDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@StartDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_start = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_start = DateAdd(m, @mm - 1, @report_date_start) 
	SET @report_date_start = DateAdd(d, @dd - 1, @report_date_start) 
			
	IF (@EndDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @EndDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the EndDate parameter to DateTime
		-- The TIME portion of the EndDate should be 23:59:59
		SET @yy = CAST(SubString(@EndDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@EndDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@EndDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_end = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_end = DateAdd(m, @mm - 1, @report_date_end) 
	SET @report_date_end = DateAdd(d, @dd - 1, @report_date_end) 
	SET @report_date_end = DateAdd(ss,-1,DateAdd(d,1,@report_date_end)) 

	*/

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
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode

	
	IF @SponsorBank = 'FBN'
	BEGIN
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			@SponsorBank sponsor_bank,
			
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
			t.tran_reversed,			

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
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 
			c.post_tran_cust_id >= (select min(first_post_tran_cust_id) from post_normalization_session 
			where datetime_creation  >= DATEADD(dd,-3,@report_date_start))
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			/*
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) 
			AND
			*/
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40')	
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			 c.terminal_id LIKE '1ATM%' AND c.terminal_id NOT LIKE '1ATM2%'
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	END
	ELSE IF @SponsorBank = 'STB'
	BEGIN
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			
			/*
			CASE
			when @SponsorBank = 'STB' then '1ATM2' 
			 else 'FBN'
			END sponsor_bank,
			*/
			@SponsorBank sponsor_bank,
			
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
			t.tran_reversed,			
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
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		t.post_tran_cust_id = c.post_tran_cust_id
			AND DATEADD(dd,0,DATEDIFF(dd,0,t.recon_business_date)) >= DATEADD(dd,0,DATEDIFF(dd,0,@report_date_start))
			AND DATEADD(dd,0,DATEDIFF(dd,0,t.recon_business_date)) < DATEADD(dd,1,DATEDIFF(dd,0,@report_date_end))
			AND c.post_tran_cust_id >= @rpt_tran_id
			AND t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40')	
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND 
			c.terminal_id LIKE '1ATM2%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk')
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
		
	END			

			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
END




GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_verve_int]    Script Date: 03/15/2016 18:58:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_verve_int]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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
		retention_data				Varchar(999),
        tran_postilion_originated          CHAR (1),
        acquiring_inst_id_code                  VARCHAR (8)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	
SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)
        

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

        

create table #foreign_amt
(foreign_amount float, foreign_fee float,  TranID BIGINT)

Insert into #foreign_amt 

select -1*p.settle_amount_impact/100,
dbo.formatAmount(-1 * p.settle_tran_fee_rsp/100, p.settle_currency_code) AS settle_tran_fee_rsp,
 p.tran_nr  from post_tran p WITH (NOLOCK, INDEX (ix_post_tran_9))
                               
                                 INNER JOIN
				 post_tran_cust c WITH (NOLOCK) ON (p.post_tran_cust_id = c.post_tran_cust_id)
				 
	
WHERE 			

                   p.tran_postilion_originated = 0
                                 and
       					(p.post_tran_id >= @first_post_tran_id) 
					AND 
					(p.post_tran_id <= @last_post_tran_id) 
					AND
				datetime_req >= @report_date_start

				
				AND
				p.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				p.tran_completed = 1
				--AND 
				--(substring (c.totals_group,1,3)=substring(@SinkNode,4,3))
                                AND
				p.tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             p.sink_node_name  NOT LIKE 'SB%'



	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			t.tran_nr as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data,
                        t.tran_postilion_originated,
                       t.acquiring_inst_id_code
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			


				--c.post_tran_cust_id >= @rpt_tran_id
			          t.tran_completed = 1
				AND
									(t.post_tran_id >= @first_post_tran_id) 
					AND 
					(t.post_tran_id <= @last_post_tran_id) 
					AND
				datetime_req >= @report_date_start
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				t.tran_completed = 1

				--AND 
				--(substring (c.totals_group,1,3)=substring(@SinkNode,4,3))
                                AND
				t.tran_type = ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                             (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

			
			
			
			
	
	IF @@ROWCOUNT = 0	

			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)

CREATE TABLE #report_result_2
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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
		retention_data				Varchar(999),
                tran_postilion_originated          CHAR (1),
                acquiring_inst_id_code                  VARCHAR (8),
                foreign_amount float, 
                foreign_fee float,
                TranID_2 BIGINT
	)	
	
Insert into #report_result_2
	
SELECT
			distinct 
			r.*,f.*
	FROM
			#report_result r
      inner join #foreign_amt f
      on r.tranId = f.tranId 
      where r.tran_postilion_originated = 1
	ORDER BY  r.datetime_tran_local


	
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
                 acquiring_inst_id_code,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
                 sum(foreign_fee) as foreign_fee,
		 sum(settle_amount_impact)as amount,
                 sum(foreign_amount)as foreign_amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result_2

 where
	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tranID))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,acquiring_inst_id_code 
	ORDER BY 

			source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_verve]    Script Date: 03/15/2016 18:58:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_verve]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	
SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        
        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	 		--c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND
			c.source_node_name not in ('SWTMEGAsrc','SWTATMCsrc','CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTSMPsrc')
			AND 
			t.sink_node_name not like 'TSS%'
            and t.sink_node_name not like '%TPP%'
            AND c.source_node_name  NOT LIKE '%TPP%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','ESBCSOUTsnk')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			--AND
			--c.terminal_id like '1%'
             
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 left(pan,6) as IIN,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result

where pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '559453%' or pan like '519615%' or pan like '528668%'or pan like '528649%' or pan like '519909%'or pan like '551609%'--or pan like '63958%' and terminal_id not like '1ATM%' and terminal_id not like '1085%'
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,left(pan,6)
	ORDER BY 
			left(pan,6),source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Smartpoint]    Script Date: 03/15/2016 18:58:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Smartpoint]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
	WHERE 		c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')
			AND
			rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			c.source_node_name='ASPSPNOUsrc'
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_NOU_Smartpoint]    Script Date: 03/15/2016 18:58:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_NOU_Smartpoint]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	--DECLARE @report_date_start		DATETIME
	--DECLARE @report_date_end		DATETIME
	
	IF (@StartDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @StartDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the StartDate parameter to DateTime
		-- The TIME portion of the StartDate should be 00:00:00
		SET @yy = CAST(SubString(@StartDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@StartDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@StartDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_start = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_start = DateAdd(m, @mm - 1, @report_date_start) 
	SET @report_date_start = DateAdd(d, @dd - 1, @report_date_start) 
			
	IF (@EndDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date

		SET @yy = DATEPART(yy,@def_date)

		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @EndDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the EndDate parameter to DateTime
		-- The TIME portion of the EndDate should be 23:59:59
		SET @yy = CAST(SubString(@EndDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@EndDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@EndDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_end = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_end = DateAdd(m, @mm - 1, @report_date_end) 
	SET @report_date_end = DateAdd(d, @dd - 1, @report_date_end) 
	SET @report_date_end = DateAdd(ss,-1,DateAdd(d,1,@report_date_end)) 

	*/

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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')
			AND
			rsp_code_rsp IN ('11','00')
			AND 
			c.source_node_name IN ( 'ASPSPNOUsrc')
			AND
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','539983','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk')
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 terminal_id,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,terminal_id,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_NOU_cardless]    Script Date: 03/15/2016 18:58:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_NOU_cardless]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	--DECLARE @report_date_start		DATETIME
	--DECLARE @report_date_end		DATETIME
	
	IF (@StartDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @StartDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the StartDate parameter to DateTime
		-- The TIME portion of the StartDate should be 00:00:00
		SET @yy = CAST(SubString(@StartDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@StartDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@StartDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_start = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_start = DateAdd(m, @mm - 1, @report_date_start) 
	SET @report_date_start = DateAdd(d, @dd - 1, @report_date_start) 
			
	IF (@EndDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date

		SET @yy = DATEPART(yy,@def_date)

		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @EndDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the EndDate parameter to DateTime
		-- The TIME portion of the EndDate should be 23:59:59
		SET @yy = CAST(SubString(@EndDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@EndDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@EndDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_end = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_end = DateAdd(m, @mm - 1, @report_date_end) 
	SET @report_date_end = DateAdd(d, @dd - 1, @report_date_end) 
	SET @report_date_end = DateAdd(ss,-1,DateAdd(d,1,@report_date_end)) 

	*/

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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        
        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			
	
 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	 		--c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			rsp_code_rsp IN ('11','00')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND 
			c.source_node_name not like 'VAUMO%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
                        and t.sink_node_name not like '%TPP%'
                        and c.source_node_name not like '%TPP%'
			AND
			t.sink_node_name in ('ESBCSOUTsnk')
			AND
			(c.terminal_id not like '2%')
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_NOU]    Script Date: 03/15/2016 18:58:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_NOU]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	--DECLARE @report_date_start		DATETIME
	--DECLARE @report_date_end		DATETIME
	
	IF (@StartDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @StartDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the StartDate parameter to DateTime
		-- The TIME portion of the StartDate should be 00:00:00
		SET @yy = CAST(SubString(@StartDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@StartDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@StartDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_start = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_start = DateAdd(m, @mm - 1, @report_date_start) 
	SET @report_date_start = DateAdd(d, @dd - 1, @report_date_start) 
			
	IF (@EndDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date

		SET @yy = DATEPART(yy,@def_date)

		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @EndDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the EndDate parameter to DateTime
		-- The TIME portion of the EndDate should be 23:59:59
		SET @yy = CAST(SubString(@EndDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@EndDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@EndDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_end = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_end = DateAdd(m, @mm - 1, @report_date_end) 
	SET @report_date_end = DateAdd(d, @dd - 1, @report_date_end) 
	SET @report_date_end = DateAdd(ss,-1,DateAdd(d,1,@report_date_end)) 

	*/

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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
			
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	 		--c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			rsp_code_rsp IN ('11','00')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND 
			c.source_node_name not like 'VAUMO%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
                       and t.sink_node_name not like '%TPP%'
                        and c.source_node_name not like '%TPP%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk')
			AND
			(c.terminal_id not like '2%')
            AND
             c.source_node_name  NOT LIKE 'SB%'
            AND
           t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_GTB_On_Us]    Script Date: 03/15/2016 18:58:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_GTB_On_Us]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
	WHERE 		c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')
			AND
			rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTCSSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk','VAUMOsnk')
			AND
			(terminal_id not like '2%')

                        and left (pan,6) in ('540761','533856')
                        and
				c.source_node_name ='SWTGTBsrc'
              AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Discover]    Script Date: 03/15/2016 18:58:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Discover]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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
		retention_data				Varchar(999),
		tran_amount_rsp				FLOAT
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(tt.retention_data,0),
			dbo.formatAmount (t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            left join 
            post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                          tt.tran_postilion_originated = 1
                                          and t.tran_nr = tt.tran_nr)
	
WHERE 		 (convert(varchar(50),T.tran_nr))+'_'+T.retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	     --c.post_tran_cust_id >= @rpt_tran_id
            AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end)
			/*AND
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) */
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
             AND
             c.source_node_name  = 'SWTMEGADSsrc'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 (Case when retention_data = '0' then sink_node_name
              else retention_data end) as sink_node_name,

                 retention_data,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
		sum(tran_amount_rsp) as Foreign_Amount
	
	FROM
			#report_result 
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,retention_data
	ORDER BY 
			source_node_name
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Detailed_verve_int]    Script Date: 03/15/2016 18:58:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Detailed_verve_int]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2),
		acquiring_inst_id_code		VARCHAR (225),
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 
		Tran_amount_rsp				FLOAT,
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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


SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id,
			c.terminal_owner,
                        c.source_node_name, 
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.acquiring_inst_id_code,
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS Tran_amount_rsp,

			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,	
			--t.tran_amount_rsp,		
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(t.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
            --left join 
            --post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                         -- tt.tran_postilion_originated = 1
                                          --and t.tran_nr = tt.tran_nr)
	
 		    --c.post_tran_cust_id >= @rpt_tran_id
            AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end)
			/*AND
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) */
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
             AND
             c.source_node_name  = 'SWTMEGAsrc'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
	
END







GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Detailed_Discover]    Script Date: 03/15/2016 18:58:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Detailed_Discover]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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
	SET @date_selection_mode = 'Last Discover Day'
			
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

SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id,
			c.terminal_owner,
                        c.source_node_name, 
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(t.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            --left join 
            --post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                         -- tt.tran_postilion_originated = 1
                                          --and t.tran_nr = tt.tran_nr)
	
WHERE 		--c.post_tran_cust_id >= @rpt_tran_id
   --         AND
			--t.tran_completed = 1
			--AND
			--(t.datetime_req >= @report_date_start) 
			--AND 
			--(t.datetime_req <= @report_date_end) 
			 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	        AND 
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
             AND
             c.source_node_name  = 'SWTMEGADSsrc'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
	
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Cardless]    Script Date: 03/15/2016 18:58:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Cardless]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	
	
SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        
        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(tt.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            left join 
            post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                          tt.tran_postilion_originated = 1
                                          and t.tran_nr = tt.tran_nr)
            
	
WHERE 			
	
(convert(varchar(50),t.tran_nr))+'_'+t.retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	
 		    --c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
            AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc')
			AND 
			t.sink_node_name not like 'TSS%'
            and t.sink_node_name not like '%TPP%'
                        and c.source_node_name not like '%TPP%'
			AND
			t.sink_node_name in ('ESBCSOUTsnk')
			AND
			(c.terminal_id not like '2%')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 (Case when retention_data = '0' then sink_node_name
              else retention_data end) as sink_node_name,

                 retention_data,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result 
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,retention_data
	ORDER BY 
			source_node_name
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Acquirer_verve_int]    Script Date: 03/15/2016 18:58:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Acquirer_verve_int]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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
                tran_currency_code CHAR (3),	
                post_currency_name VARCHAR (50),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	--DECLARE @report_date_start		DATETIME
	--DECLARE @report_date_end		DATETIME
	
	IF (@StartDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @StartDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the StartDate parameter to DateTime
		-- The TIME portion of the StartDate should be 00:00:00
		SET @yy = CAST(SubString(@StartDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@StartDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@StartDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_start = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_start = DateAdd(m, @mm - 1, @report_date_start) 
	SET @report_date_start = DateAdd(d, @dd - 1, @report_date_start) 
			
	IF (@EndDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date

		SET @yy = DATEPART(yy,@def_date)

		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @EndDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the EndDate parameter to DateTime
		-- The TIME portion of the EndDate should be 23:59:59
		SET @yy = CAST(SubString(@EndDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@EndDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@EndDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_end = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_end = DateAdd(m, @mm - 1, @report_date_end) 
	SET @report_date_end = DateAdd(d, @dd - 1, @report_date_end) 
	SET @report_date_end = DateAdd(ss,-1,DateAdd(d,1,@report_date_end)) 

	*/

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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1
        
        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
                        t.tran_currency_code,
                        p.name as post_currency_name,
                        

			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
                        LEFT join post_currencies p (NOLOCK) ON (t.tran_currency_code = p.currency_code)
	WHERE 		
	
	
	 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	            AND 
	            t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				t.tran_completed = 1
				--AND 
				--(substring (c.totals_group,1,3)=substring(@SinkNode,4,3))
                                AND
				tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                               AND
                                rsp_code_rsp IN ('00','11','08','10','16')
                                And
                             (pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                  AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all]    Script Date: 03/15/2016 18:58:55 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b06_all]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
			
			
			/*	
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(tt.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            left join 
            post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                          tt.tran_postilion_originated = 1
                                          and t.tran_nr = tt.tran_nr)
            
	
WHERE 			
	
(convert(varchar(50),t.tran_nr))+'_'+t.retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	
     		--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
            AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			
            and t.sink_node_name not like '%TPP%'
                        and c.source_node_name not like '%TPP%'
            AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk','VAUMOsnk')
			AND
			(c.terminal_id not like '2%')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
            AND
			c.source_node_name not like 'SWTMEGADSsrc'
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 (Case when retention_data = '0' then sink_node_name
              else retention_data end) as sink_node_name,

                 retention_data,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result 
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,retention_data
	ORDER BY 
			source_node_name
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_2]    Script Date: 03/15/2016 18:58:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b06_2]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
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
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	BEGIN TRANSACTION;

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE @report_result TABLE 
	(
		Warning						VARCHAR (255),	
		StartDate					VARCHAR(30),  
		EndDate						VARCHAR(30),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     VARCHAR(30), -- oremeyi added this
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
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			INT,
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
		totals_group				Varchar(40)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
    
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
	
	SELECT @StartDate = REPLACE(@StartDate, '-', '');
	SELECT @EndDate = REPLACE(@EndDate, '-', '');
	
	SELECT @StartDate = REPLACE(@StartDate, '.', '');
	SELECT @EndDate = REPLACE(@EndDate, '.', '');
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

  
	
	 SELECT @rpt_tran_id = (SELECT MIN(first_post_tran_cust_id)  FROM post_normalization_session (NOLOCK) WHERE datetime_creation  >= DATEADD(dd,-1,@report_date_start))
	

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM @report_result
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM @report_result
		RETURN 1
	END

      DECLARE @list_of_source_nodes TABLE  (source_node	VARCHAR(30)) 
	
	INSERT INTO  @list_of_source_nodes SELECT part as 'source_node' FROM usf_split_string(@SourceNode,',')
	
	DECLARE @list_of_terminalIds TABLE  (terminalID	VARCHAR(30)) 
	
	INSERT INTO  @list_of_terminalIds SELECT part as 'terminalID' FROM usf_split_string(@terminalID,',')
	
	DECLARE @terminal VARCHAR(2000)
	DECLARE @terminal_new  VARCHAR(2000)

	DECLARE @list_of_terminals TABLE  (terminal	VARCHAR(30)) 
	
	DECLARE terminal_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT terminalID FROM @list_of_terminalIds
	
	OPEN  terminal_cursor;
	FETCH NEXT FROM terminal_cursor INTO @terminal;
	
	WHILE (@@FETCH_STATUS=0)
	  BEGIN
	
		SET @terminal_new  =   substring(@terminal,1,5);  
	        INSERT INTO @list_of_terminals(terminal) VALUES (@terminal_new) 
		FETCH NEXT FROM terminal_cursor INTO @terminal;
	END
		
	CLOSE  terminal_cursor;
	DEALLOCATE terminal_cursor 
	
	
	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/20098
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
				, t.settle_currency_code) AS settle_amount_impact,
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data,
			post_tran_cust_id 
			
			INTO #temp_results_table
	FROM
			post_tran t (NOLOCK)	

	WHERE 		
			
			(t.recon_business_date >= @report_date_start AND  t.recon_business_date <= @report_date_end) 
            AND 
			t.tran_completed = 1
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')	
			
           AND (t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk','SWTSPTsnk') AND CHARINDEX(t.sink_node_name, 'TPP')<1 AND LEFT(t.sink_node_name,2)<>'SB')
		
	
        INSERT
			INTO @report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
		    pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			settle_amount_req, 
            settle_amount_rsp, 
			settle_tran_fee_rsp, 
			 TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
            settle_amount_impact,
            rsp_code_description,
			settle_nr_decimals,
			currency_alpha_code,
			currency_name,
			tran_type_description,
			
			t.tran_reversed,
			isPurchaseTrx,
			isWithdrawTrx,
			isRefundTrx,
			isDepositTrx,
			isInquiryTrx,
			isTransferTrx,
			isOtherTrx,
			t.retention_data,
			c.totals_group
	FROM
			#temp_results_table t (NOLOCK)
			 JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id  AND c.post_tran_cust_id >= @rpt_tran_id)
			

	WHERE 		
			
	
			((  c.source_node_name in (select source_node from @list_of_source_nodes) OR (LEFT (c.terminal_id,5) in (select terminal from @list_of_terminals) AND LEFT(c.terminal_id,2)= '1S')
                        --OR
                        --(substring (c.terminal_id,2,3)=substring (@terminalID,3,3) AND c.terminal_id not like '1S%'  and c.source_node_name = 'SWTMEGAsrc')
			)AND LEFT(c.source_node_name,2)<>'SB') 
				AND
			(LEFT(terminal_id,1)<>'2') 
         
          
	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
	
	
	IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			@report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
COMMIT TRANSACTION;
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06]    Script Date: 03/15/2016 18:58:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

















ALTER PROCEDURE [dbo].[osp_rpt_b06]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
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
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


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
		totals_group				Varchar(40)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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


        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
	CREATE TABLE #list_of_terminalIds (terminalID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_terminalIds EXEC osp_rpt_util_split_nodenames @terminalID
	
	
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	
SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)
        

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

	
        INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
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
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
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
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data,
			c.totals_group
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			
	
		
			t.tran_completed = 1
			AND
					(t.post_tran_id >= @first_post_tran_id) 
					AND 
					(t.post_tran_id <= @last_post_tran_id) 
					AND
				datetime_req >= @report_date_start
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')	
			AND
			(c.source_node_name in (select source_node from #list_of_source_nodes)
			OR
			(substring (c.terminal_id,2,3) in (select terminalID from #list_of_terminalIds) AND c.source_node_name  = 'ASPSPNOUsrc')
                        --OR
                        --(substring (c.terminal_id,2,3)=substring (@terminalID,3,3) 
			)
			AND c.source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk','SWTSPTsnk')
            and t.sink_node_name not like '%TPP%'
                         and c.source_node_name not like '%TPP%'
			AND
			(terminal_id not like '2%')
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
		

	

	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
 where
	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tranID))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END








































































































































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_WebAcquirer]    Script Date: 03/15/2016 18:58:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b04_WebAcquirer]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	--@Acquirer		VARCHAR(255),
	---@AcquirerInstId		VARCHAR(255),
	--@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

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
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		--acquiring_inst_id_code		VARCHAR(30),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		structured_data_req		TEXT,
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50)--oremeyi added this 2009-04-22
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END*/
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Previous month'
			
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				---t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,0),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code--oremeyi added this 2010-02-28
				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK), 
				tbl_merchant_category m (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.merchant_type *= m.category_code
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				AND
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
				
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%')
					
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')	------ij added SWTMEGAsnk
				AND
				t.tran_type NOT IN ('31','50')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
								
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_WEB_VISA_COACQUIRED]    Script Date: 03/15/2016 18:58:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






















ALTER PROCEDURE [dbo].[osp_rpt_b04_WEB_VISA_COACQUIRED]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@Acquirer		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
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
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			VARCHAR(15),
		terminal_owner  		VARCHAR(25),
		merchant_type				CHAR (4),
                extended_tran_type_reward               VARCHAR (50),--Chioma added this 2012-07-03
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
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
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		TEXT,
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),
		from_account_id			VARCHAR(28),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
	        rdm_amount                      FLOAT,--Chioma added this 2012-07-03
                Reward_Discount                 FLOAT,--Chioma added this 2012-07-03
                Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03
                Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
                Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03
                Late_Reversal CHAR (1),
		totals_group		Varchar(40)
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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #list_of_AcquirerInstId (AcquirerInstId	VARCHAR(50)) 
	INSERT INTO  #list_of_AcquirerInstId EXEC osp_rpt_util_split_nodenames @AcquirerInstId
	-- Only look at 02xx messages that were not fully reversed.
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                 extended_trans_type = Case When c.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(t.extended_tran_type,'0000')end,
                                 --extended_trans_type = ISNULL(t.extended_tran_type,'0000'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,0),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				t.from_account_id,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				0,

                                isnull(R.Reward_Discount,0),
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
				c.totals_group
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category_web m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				
                                /*left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))*/
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id
                                left JOIN Reward_Category r (NOLOCK)
                                ON (t.extended_tran_type = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
                 
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				AND 
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				--AND
				--t.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					--(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
                AND
                                c.source_node_name  NOT LIKE 'SB%'
                                AND
                                sink_node_name  NOT LIKE 'SB%'
								AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'

			


INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = 'BURN',
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,0),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				0, 
				0,
				0,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
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
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				t.from_account_id,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                isnull(R.Reward_Discount,0),
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
				c.totals_group
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category_web m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code
                                
               
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				AND 
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				--AND
				--t.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
                                and ISNULL(y.rdm_amt,0) <>0
                    AND
                                c.source_node_name  NOT LIKE 'SB%'
                                AND
                                sink_node_name  NOT LIKE 'SB%'
				AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'

			
								
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
			where left(pan,1) ='4'
            and source_node_name = 'SWTASPUBAsrc' and sink_node_name ='SWTWEBUBAsnk'
          --AND acquiring_inst_id_code <> '627480'
	ORDER BY 
			source_node_name, datetime_req
END













































































































































































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_summary]    Script Date: 03/15/2016 18:59:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[osp_rpt_b04_web_summary]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	
	SET NOCOUNT ON
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40), 
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
		tran_reversed			INT,	 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_description	VARCHAR (60),
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
		extended_tran_type		CHAR(12),
                rdm_amt                      DECIMAL(7,4)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	*/	
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	

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

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.
	
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				sink_node_name = case when y.rdm_amt <> 0 then 'InterSwitch' else t.sink_node_name end, 
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
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51')  THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type,
                                ISNULL(y.rdm_amt,0)as rdm_amt
                                
	FROM
				

                                post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
				
	WHERE 			
				(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
                 		--t.post_tran_cust_id >= @rpt_tran_id 
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				tran_type NOT IN ('31','39','50')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%')
					
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')------ij added SWTMEGAsnk	
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
                               

	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 sink_node_name,
		 category_name, 
		 merchant_type,
		 CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1--ij changed this to cater for 0100 transactions which always have a zero
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
                        WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
			ELSE 0
			END AS no_above_limit,
		CASE
			--WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 
                        WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt			
			ELSE 0
            		END AS amount_above_limit,
		settle_amount_impact * -1 + rdm_amt as amount,
		settle_tran_fee_rsp *-1 as fee
			

	 
	FROM 
			#report_result

                        	
	--GROUP BY
	--		StartDate, EndDate,category_name,merchant_type,sink_node_name,tran_type, card_acceptor_id_code, card_acceptor_name_loc -- tran_type_description, 
	ORDER BY 

			source_node_name, sink_node_name
	END





GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_Remote_all_Standardised]    Script Date: 03/15/2016 18:59:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





















ALTER PROCEDURE [dbo].[osp_rpt_b04_web_Remote_all_Standardised]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL
AS
BEGIN
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	
	SET NOCOUNT ON
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  		CHAR(32),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40), 
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
		tran_reversed			INT,	 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_description	VARCHAR (60),
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
		extended_tran_type		CHAR(12),
                rdm_amt                       FLOAT,
                Late_Reversal_id             CHAR (1),
                totals_group varchar (30)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	*/	
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	

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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

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

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.
SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        

INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				sink_node_name = case when y.rdm_amt <> 0 then 'InterSwitch' else t.sink_node_name end, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				0, 
				0,
				0,
				
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type,
                                ISNULL(y.rdm_amt,0)as rdm_amt,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 
                                                      and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                c.totals_group
                                
	FROM
				

                                post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category_web m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
               
	
WHERE 			
	
 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	
	--	t.post_tran_cust_id >= @rpt_tran_id 
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50','21')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					--(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%') OR
					(c.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')
                                and ISNULL(y.rdm_amt,0) <>0
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name ,
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
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51')  THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type,
                               0 as rdm_amt,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                c.totals_group
                                
	FROM
				

                                post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category_Web m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				
	
WHERE 			
	
 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
	
				
                 --t.post_tran_cust_id >= @rpt_tran_id 
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%') OR
					(c.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')------ij added SWTMEGAsnk	
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             
                               

	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
		 StartDate,

		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 case when left(pan,1) = '4' then totals_group
                 else sink_node_name end as sink_node_name,
		 category_name, 
		 merchant_type,
		 tran_type,
                 terminal_id,
		CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220')THEN 1
			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1--ij changed this to cater for 0100 transactions which always have a zero
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0220')THEN 1
                        WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
			ELSE 0
			END AS no_above_limit,
		CASE
			--WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220') then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 
                        WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt			
			ELSE 0
            		END AS amount_above_limit,
		settle_amount_impact * -1 + rdm_amt as amount,
		settle_tran_fee_rsp *-1 as fee,
		 CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	--WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END as tran_count,
			extended_tran_type,
			message_type,
			settle_amount_rsp,
                        late_reversal_id,
                 
                  (CASE When  dbo.fn_rpt_CardGroup (pan) = 1 Then 'Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 2 Then 'Magstripe Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 3 Then 'MasterCard'
                                  When dbo.fn_rpt_CardGroup (pan) = 4 Then 'MasterCard Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 5 Then 'Unknown Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 6 Then 'Visa Card'
                                  Else 'Unknown Card'
	                          END) AS CardType

	 
	FROM 
			#report_result

                        where not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                   and merchant_type not in ('5371')	
         --GROUP BY dbo.fn_rpt_CardGroup (pan)
	--GROUP BY
	--		StartDate, EndDate,category_name,merchant_type,sink_node_name,tran_type, card_acceptor_id_code, card_acceptor_name_loc -- tran_type_description, 
	ORDER BY 

			source_node_name, sink_node_name
	END






































































































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_remote]    Script Date: 03/15/2016 18:59:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


























ALTER PROCEDURE [dbo].[osp_rpt_b04_web_remote]

	@StartDate		VARCHAR (30),	-- yyyymmdd

	@EndDate			VARCHAR (30),	-- yyyymmdd

	@SinkNodes		VARCHAR(510),

	@SourceNodes	VARCHAR(255),

	@show_full_pan	BIT,

	@report_date_start DATETIME = NULL,

	@report_date_end DATETIME = NULL,

	@rpt_tran_id INT = NULL,

        @rpt_tran_id1 INT = NULL



AS

BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	

	CREATE TABLE #report_result

	(

		Warning					VARCHAR (255),

		StartDate				CHAR (8),  

		EndDate					CHAR (8), 

		SourceNodeAlias 		VARCHAR (50),

		pan						VARCHAR (255), 

		terminal_id				CHAR (8), 

		acquiring_inst_id_code			CHAR(255),

		terminal_owner  		CHAR(255),

		merchant_type				CHAR (4),

                extended_tran_type_reward               CHAR (4),--Chioma added this 2012-07-03

		Category_name				VARCHAR(50),

		Fee_type				CHAR(1),

		merchant_disc				DECIMAL(7,4),

		fee_cap					FLOAT,

		amount_cap				FLOAT,

		bearer					CHAR(1),

		card_acceptor_id_code	CHAR (15),	 

		card_acceptor_name_loc	CHAR (255), 

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

		tran_reversed			INT,

		pan_encrypted			CHAR(18),

		from_account_id			VARCHAR(28),

		to_account_id			VARCHAR(28),

		payee				char(25),

		extended_tran_type		CHAR (4),

                rdm_amount                      DECIMAL(7,4),

                Reward_Discount                 DECIMAL(7,6),

                Addit_Charge                 DECIMAL(7,6),

                Addit_Party                 Varchar (10),

                Amount_Cap_RD               DECIMAL(9,0),

                Fee_Cap_RD               DECIMAL(9,0),

                Fee_Discount_RD          DECIMAL(9,7),

                Late_Reversal CHAR (1),

				Bank_institution_name		varchar(50),

				bank_card_type		        varchar(100),

       auth_id_rsp Varchar(200)         

	)



	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')

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

	SET @date_selection_mode = 'Last business day'

			

	-- Calculate the report dates

	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT



	IF (@warning is not null)

	BEGIN


		INSERT INTO #report_result (Warning) VALUES (@warning)

		

		SELECT * FROM #report_result

		

		RETURN 1

	END



	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)

	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)



	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 



	IF (@report_date_end < @report_date_start)

	BEGIN

	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	



	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

	

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes



	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 

	

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes



print @report_date_start

print @report_date_end

	-- Only look at 02xx messages that were not fully reversed.

	

SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1
        
        
	INSERT

				INTO #report_result

	SELECT

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				SourceNodeAlias = 

				(CASE 

					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE c.source_node_name

				END),

				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,

				c.terminal_id, 

				t.acquiring_inst_id_code,

				c.terminal_owner,

				ISNULL(c.merchant_type,'VOID'),

                                 extended_trans_type = Case When c.terminal_id in 

                                (select terminal_id from tbl_reward_OutOfband)

                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 

                                  else ISNULL(t.extended_tran_type,'0000')end,

				ISNULL(m.Category_name,'VOID'),

				ISNULL(m.Fee_type,'VOID'),

				ISNULL(m.merchant_disc,0.0),

				ISNULL(m.fee_cap,0),

				ISNULL(m.amount_cap,999999999999.99),

				ISNULL(m.bearer,'M'),

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 

				c.source_node_name,

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

				

				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,

				

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

				

				dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,

				dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,

				dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,

				dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

				dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,

				dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,

				t.tran_reversed,

				c.pan_encrypted,

				t.from_account_id,

				t.to_account_id,

				t.payee,

				t.extended_tran_type,

                                0,

                                isnull(R.Reward_Discount,0),

                                R.Addit_Charge,

                                R.Addit_Party,

                                R.Amount_Cap,

                                R.Fee_Cap,

                                R.Fee_Discount,

                                Late_Reversal_id = CASE

						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1

						ELSE 0

					        END,

				1,--d.bank_institution_name,

				1,--b.bank_card_type,		

                t.auth_id_rsp



FROM

				post_tran t (NOLOCK)

				INNER JOIN post_tran_cust c (NOLOCK)

				ON  t.post_tran_cust_id = c.post_tran_cust_id

				left JOIN tbl_merchant_category_web m (NOLOCK)

				ON c.merchant_type = m.category_code 

				left JOIN tbl_merchant_account a (NOLOCK)

				ON c.card_acceptor_id_code = a.card_acceptor_id_code   

				/*left JOIN tbl_xls_settlement y (NOLOCK)

				

                                ON (c.terminal_id= y.terminal_id 

                                    AND t.retrieval_reference_nr = y.rr_number 

                                    --AND t.system_trace_audit_nr = y.stan

                                    AND (-1 * t.settle_amount_impact)/100 = y.amount

                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)

                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))*/

                                left JOIN tbl_reward_OutOfBand O (NOLOCK)

                                ON c.terminal_id = o.terminal_id

                                left JOIN Reward_Category r (NOLOCK)

                                ON (t.extended_tran_type = r.reward_code or substring(o.r_code,1,4) = r.reward_code)

								--left JOIN bank_bin_table b (NOLOCK) ON ((SUBSTRING(c.pan,1,6) = B.bin) or (SUBSTRING(c.pan,4,3) =SUBSTRING (B.bin,1,3)))

								--LEFT JOIN acquirer_institution_table d (NOLOCK) ON (t.acquiring_inst_id_code = d.acquirer_inst_id)
                                
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	

				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	

				AND

				t.tran_completed = 1

				AND

				(t.recon_business_date >= @report_date_start) 

				AND 

				(t.recon_business_date <= @report_date_end) 

				AND

				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 

				AND

				(

				(t.message_type IN ('0220','0200', '0400', '0420')) 

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='533853')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='522145')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='539983')

				)

				AND 

				((substring(c.totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))

                                or (substring (t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)))

				AND

				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

				AND 

					(

					(c.terminal_id like '3IWP%') OR

					(c.terminal_id like '3ICP%') OR

					--(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))

					(c.terminal_id like '5%') OR

                                        (c.terminal_id like '31WP%') OR

					(c.terminal_id like '31CP%') OR

					(c.terminal_id like '6%') OR
					(c.terminal_id like '%VA')

										)

				AND

				t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk

				AND

				t.tran_type NOT IN ('31','50')

                                and c.merchant_type not in ('5371')	

                                /*and  (

                                ((ISNULL(y.rdm_amt,0) = 0) 

                                or ((ISNULL(y.rdm_amt,0) <> 0)) and (ISNULL(y.amount,0) not in ('0','0.00'))) 

                                or 

                                (y.extended_trans_type = '1000')

                                )*/

               AND

             c.source_node_name  NOT LIKE 'SB%'

             AND

             t.sink_node_name  NOT LIKE 'SB%'



			--AND

			--(B.bin = SUBSTRING(c.pan,1,6) or (SUBSTRING(c.pan,4,3) IN ('051','100')and substring (c.totals_group ,1,3) = b.inst_sink_code))

				

				

	IF @@ROWCOUNT = 0

		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			

	ELSE

	BEGIN

		--

		-- Decrypt PAN information if necessary

		--



		DECLARE @pan VARCHAR (19)

		DECLARE @pan_encrypted CHAR (18)

		DECLARE @pan_clear VARCHAR (19)

		DECLARE @process_descr VARCHAR (100)



		SET @process_descr = 'Office B04 Report'



		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor

		DECLARE pan_cursor CURSOR FORWARD_ONLY

		FOR

			SELECT

					pan,

					pan_encrypted

			FROM

					#report_result

		FOR UPDATE OF pan



		OPEN pan_cursor



		DECLARE @error INT

		SET @error = 0



		IF (@@CURSOR_ROWS <> 0)

		BEGIN

			FETCH pan_cursor INTO @pan, @pan_encrypted

			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))

			BEGIN

				-- Handle the decrypting of PANs

				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT



				-- Update the row if its different

				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))

				BEGIN

					UPDATE

						#report_result

					SET

						pan = @pan_clear

					WHERE

						CURRENT OF pan_cursor

				END



				FETCH pan_cursor INTO @pan, @pan_encrypted

			END

		END



		CLOSE pan_cursor

		DEALLOCATE pan_cursor



	END			

	SELECT 


			* 

	FROM 

			#report_result
			--where  (source_node_name <> 'SWTASPUBAsrc' AND sink_node_name <> 'SWTWEBUBAsnk')

			--where left(pan,1) <>'4'

	ORDER BY 

			datetime_tran_local,source_node_name

END












































































































































































































































































































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_rdm_ISW]    Script Date: 03/15/2016 18:59:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_rdm_ISW]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SinkNodes		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (255), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(255),
		terminal_owner  		CHAR(255),
		merchant_type				CHAR (4),
                extended_tran_type_reward               CHAR (4),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (255), 
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
		tran_reversed			INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		extended_tran_type		CHAR (4),
                rdm_amount                      DECIMAL(7,4),
                Reward_Discount                 DECIMAL(7,6),
                Addit_Charge                 DECIMAL(7,6),
                Addit_Party                 Varchar (10),
                Amount_Cap_RD               DECIMAL(9,0),
                Fee_Cap_RD               DECIMAL(9,0),
                Fee_Discount_RD          DECIMAL(9,7)       
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END*/
		
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	
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

	/*CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes*/

print @report_date_start
print @report_date_end
	-- Only look at 02xx messages that were not fully reversed.
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				t.payee,
				t.extended_tran_type,
                                ISNULL(y.rdm_amt,0),
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
                                left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code


	WHERE 			
				
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				--AND 
				---(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				AND
				c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')
                                and  ISNULL(y.rdm_amt,0) <> 0	
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

				


	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B04 Report'

		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					#report_result
		FOR UPDATE OF pan

		OPEN pan_cursor

		DECLARE @error INT
		SET @error = 0

		IF (@@CURSOR_ROWS <> 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @pan_encrypted
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

				-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
				BEGIN
					UPDATE
						#report_result
					SET
						pan = @pan_clear
					WHERE
						CURRENT OF pan_cursor
				END

				FETCH pan_cursor INTO @pan, @pan_encrypted
			END
		END

		CLOSE pan_cursor
		DEALLOCATE pan_cursor

	END			
	SELECT 

			* 
	FROM 
			#report_result
	ORDER BY 
			datetime_tran_local,source_node_name
END




GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Web_Purchase_all_DS]    Script Date: 03/15/2016 18:59:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_Web_Purchase_all_DS]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	
	SET NOCOUNT ON
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
                Bin                              CHAR (6),
                totalsGroup         VARCHAR(50),
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
                recon_business_date             DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2),
		tran_reversed			INT,	 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_description	VARCHAR (60),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		extended_tran_type		CHAR(4)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	*/	
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	

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

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames_special @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
                                left(c.pan,6) as bin,
                                c.totals_group as totalsGroup,
				c.terminal_id, 
				(case when t.acquiring_inst_id_code is NULL then substring(c.terminal_id,2,3)
                                    else
				t.acquiring_inst_id_code END),
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
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
                                t.recon_business_date,
				t.from_account_type, 
				t.to_account_type,
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				left join tbl_merchant_category_web m on (c.merchant_type = m.category_code)
				
				

			WHERE 			


			(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
		
				
				--t.post_tran_cust_id >= @rpt_tran_id 
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50','21')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 

					(

					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%') OR
					(c.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk	
				And( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')
                 --And c.merchant_type not in ('9008','8299','9104','8244','9103','8241','9102','8220','9101','8211','8999','6211')
                --and not(merchant_disc = '0.015000' and amount_cap = '133333.33' and fee_cap = '2000')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	
	  AND c.source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')


	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
		
INSERT 
                               INTO data_summary_verve_billing_session
       SELECT (cast (recon_business_date as varchar(40)))+'_WEB Merchant Purchase'  
       FROM  #report_result

        where rsp_code_rsp in ('00','11','08','10','16')

	Group by recon_business_date
          
IF(@@ERROR <>0)
RETURN


        Insert into data_summary_verve_billing
	SELECT 
		 recon_business_date,
                 acquiring_inst_id_code,
                 bin,  
                 totalsGroup,                          		
		 SUM(CASE
                         WHEN message_type <> '0100' then settle_amount_impact * -1
                         WHEN message_type = '0100' then settle_amount_rsp
                         END)as amount,
                  sum(CASE			
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
                  tran_type,
                  message_type,
                  rsp_code_rsp,
                  tran_reversed,                
                  'WEB Merchant Purchase',
                   card_type =  dbo.fn_rpt_CardGroup(bin),
                   terminal_type = SUBSTRING(Terminal_id,1,1),
                    SUM(CASE			
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as Issuer_Access_fee,

                     SUM(CASE			
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as Acquirer_Access_fee,

                      SUM(CASE			
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	WHEN tran_type IN ('00','09') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END)*3 as Acquirer_Risk_fee,
                       0,0
                  

	 
	FROM 
			#report_result

        where rsp_code_rsp in ('00','11','08','10','16')
	--GROUP BY
	--		StartDate, EndDate,category_name,merchant_type,sink_node_name,tran_type, card_acceptor_id_code, card_acceptor_name_loc -- tran_type_description, 
	
Group by recon_business_date,tran_type,message_type,rsp_code_rsp,tran_reversed,bin,totalsGroup, 
         acquiring_inst_id_code,SUBSTRING(Terminal_id,1,1)

ORDER BY 

			recon_business_date
	END




GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_Visa_Co_acquirer_new]    Script Date: 03/15/2016 18:59:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




































ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_Visa_Co_acquirer_new]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@Acquirer		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@merchants	VARCHAR(255),--this is the c.card_acceptor_id_code,
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
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
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		TEXT,
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
                aggregate_column         VARCHAR(200),
				tran_cash_req  FLOAT,--Eloho Added this for cashback
tran_cash_rsp  FLOAT,--Eloho Added this for cashback
        	tran_tran_fee_rsp  FLOAT,--Eloho Added this for cashback
			tran_currency_code      VARCHAR (50)--Eloho Added this for cashback
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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #list_of_AcquirerInstId (AcquirerInstId	VARCHAR(50)) 
	INSERT INTO  #list_of_AcquirerInstId EXEC osp_rpt_util_split_nodenames @AcquirerInstId

        
	-- Only look at 02xx messages that were not fully reversed.
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = 
                                Case When c.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				isnull(t.payee,0),--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				0,

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                tt.Terminal_code,
				c.totals_group,
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,
                 t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(12)),
dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code                 

	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON c.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id 
				left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id
                                
	WHERE 			
				
				--c.post_tran_cust_id >= @rpt_tran_id1 --'81530747'	
				--AND
				
				 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
               AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				AND 
				t.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                                --and c.merchant_type not in ('5371')	
                                 and ISNULL(y.rdm_amt,0) <>0
                      --          AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND t.sink_node_name+LEFT(totals_group,3)
                      --         not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
                      --         and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   --and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk'))		

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	--AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'


INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 'Reward',
				dbo.fn_rpt_PanForDisplay(y.pan, @show_full_pan) AS pan,
				y.terminal_id, 
				y.acquiring_inst_id_code,
				'Reward',
				'5310',
                                extended_trans_type = 'BURN',
				'Discount Stores',
				'P',
				0.007500,
				1200,
				160000,
				'M',
				y.merchant_id, 
				substring(y.card_acceptor_name_loc,1,40), 
				'Reward',
				'Reward', 
				'00', 
				'00', 
				'0200', 
				y.trans_date,
				
				
				0, 
				0,
				0,
				
				0 as TranID,
				0, 
				y.stan, 
				0, 
				y.rr_number, 
				y.trans_date, 
				0, 
				0, 
				'566', 
				
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
				'Goods and Services' as tran_type_desciption,
				'Approved' as rsp_code_description,
				 2 AS settle_nr_decimals,
				'NGN' AS currency_alpha_code,
				'Naira' AS currency_name,
				
				1 	AS isPurchaseTrx,
				0 	AS isWithdrawTrx,
				0 		AS isRefundTrx,
				0 		AS isDepositTrx,
				0 		AS isInquiryTrx,
				0	AS isTransferTrx,
				0 		AS isOtherTrx,
				1,
				0,
				ISNULL(account_nr,'not available'),
				0,--oremeyi added this 2009-04-22
				'0000',
				0,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                0,
                                tt.Terminal_code,
				'Reward',
                y.rr_number+'_'+y.terminal_id+'_'+'000000'+'_'+cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50)),
                 y.rr_number+'_'+'000000'+'_'+y.terminal_id+'_'+ cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50))+'_'+'0200',
				 
				0 AS tran_cash_req, 
				0 AS tran_cash_rsp,
				0 AS tran_tran_fee_rsp,
				0 AS tran_currency_code

	FROM
					/*post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON c.merchant_type = s.category_code 
				left JOIN */
				
				  
				tbl_xls_settlement y (NOLOCK) left JOIN 
				tbl_merchant_account a (NOLOCK)
                ON y.merchant_id = a.card_acceptor_id_code 
				/*ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand)
                                ) */
				left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON y.terminal_id = tt.terminal_id
	WHERE 			
				
				/*c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND */
				(y.trans_date >= @report_date_start) 
				AND 
				(y.trans_date <= @report_date_end+1) 
				--AND
				--t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				--AND

				--(
				--(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				--)
				--AND 
				--t.tran_completed = 1 
				AND 
				y.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR y.merchant_id IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				and ISNULL(y.rdm_amt,0) <>0
                 and LEFT(y.terminal_id,1) = '2'
                 and y.extended_trans_type is not null
				
				/* AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
                                and ISNULL(y.rdm_amt,0) <>0
                                AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND t.sink_node_name+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
                                and c.totals_group not in ('VISAGroup')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc' */


INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = 
                                Case When c.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				v.discount*y.amount AS settle_amount_req, 
				v.discount*y.amount AS settle_amount_rsp,
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				(-1*y.amount*v.discount) AS settle_amount_impact,				
				


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
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				isnull('Verve',0),--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				0,

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                tt.Terminal_code,
				c.totals_group,
                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,
                t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs((-1*y.amount*v.discount))) as varchar(12)),
dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code
                
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON c.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id
				left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id
                                 left Join Verve_Discount V (nolock)
                                ON (substring(y.extended_trans_type,5,2) = v.code or (substring(o.r_code,5,2) = v.code and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
                                
	WHERE 			
				
				 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
            --c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				AND 
				t.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                              --  and c.merchant_type not in ('5371')	
                      --          AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND t.sink_node_name+LEFT(totals_group,3)
                      --         not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
                      --         and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   --and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk'))		


                                and ((len(y.extended_trans_type) = 6 and substring(y.extended_trans_type,5,2)<> '00')
                                   or (len(o.r_code) = 6 and substring(o.r_code,5,2)<> '00'))
                                  and ((-1*y.amount)-dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ))<>0
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
          --AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'

				INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE q.source_node_name
				END),
				*/
				q.source_node_name,
				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,
				q.terminal_id, 
				q.acquiring_inst_id_code,
				q.terminal_owner,
				ISNULL(q.merchant_type,'VOID'),
                                extended_trans_type = 
                                Case When q.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				q.card_acceptor_id_code, 
				q.card_acceptor_name_loc, 
				q.source_node_name,
				q.sink_node_name, 
				q.tran_type, 
				q.rsp_code_rsp, 
				q.message_type, 
				q.datetime_req,
				dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,
				
				q.post_tran_cust_id as TranID,
				q.prev_post_tran_id, 
				q.system_trace_audit_nr, 
				q.message_reason_code, 
				q.retrieval_reference_nr, 
				q.datetime_tran_local, 
				q.from_account_type, 
				q.to_account_type, 
				q.settle_currency_code, 
				
				--dbo.formatAmount(q.settle_amount_impact, q.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact
						ELSE q.settle_amount_impact
					END
					, q.settle_currency_code ) AS settle_amount_impact,				
				


				dbo.formatTranTypeStr(q.tran_type, q.extended_tran_type, q.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(q.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(q.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(q.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(q.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				q.tran_reversed,
				ISNULL(account_nr,'not available'),
				isnull(q.payee,0),--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				0,

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (q.post_tran_cust_id < @rpt_tran_id1 and q.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                tt.Terminal_code,
				q.totals_group,
                 q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(12))+'_'+q.message_type,
                 q.retrieval_reference_nr+'_'+q.terminal_id+'_'+'000000'+'_'+cast((abs(q.settle_amount_impact)) as varchar(12)),
dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_currency_code                 

	FROM
				asp_visa_pos q (NOLOCK)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON q.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON q.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON q.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (q.terminal_id= y.terminal_id 
                                    AND q.retrieval_reference_nr = y.rr_number 
                                    --AND q.system_trace_audit_nr = y.stan
                                    --AND (-1 * q.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON q.terminal_id = o.terminal_id 
				left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')))
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON tt.terminal_id = q.terminal_id
                                
	WHERE 			
				
				--q.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				--AND
				q.tran_completed = 1
				AND
				(q.recon_business_date >= @report_date_start) 
				AND 
				(q.recon_business_date <= @report_date_end) 
				AND
				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--q.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(q.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				q.tran_completed = 1 
				AND 
				q.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR q.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				--AND
				--q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(q.terminal_id like '3IWP%') OR
					(q.terminal_id like '3ICP%') OR
					(q.terminal_id like '2%')OR--(q.terminal_id like '2%' AND q.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(q.terminal_id like '5%') OR
                                        (q.terminal_id like '31WP%') OR
					(q.terminal_id like '31CP%') OR
					(q.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				q.tran_type NOT IN ('31','50')
                              --  and q.merchant_type not in ('5371')	
                                --AND  NOT  (q.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)
                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))
                                --and q.totals_group not in ('VISAGroup')
                AND
             q.source_node_name  NOT LIKE 'SB%'
             AND
             q.sink_node_name  NOT LIKE 'SB%'
	--AND q.source_node_name  <> 'SWTMEGAsrc'AND q.source_node_name  <> 'SWTMEGADSsrc'					
	--IF @@ROWCOUNT = 0
		--INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			

create table #temp_table_1
(aggregate_column varchar(200), counts float )
insert into #temp_table_1 select aggregate_column, count(aggregate_column) from #report_result
group by aggregate_column

update #report_result
set tran_type_desciption = tran_type_desciption+ '_M'
where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)

create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name = ('SWTNCS2src')


		
	SELECT 
			* 
	FROM 
			#report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where  source_node_name ='SWTNCS2src' AND sink_node_name = 'ASPPOSVINsnk'
		AND acquiring_inst_id_code <> '627787'
        and unique_key  IN (SELECT unique_key FROM #temp_table)
                                       
	ORDER BY 
			source_node_name, datetime_req
END












































































































































































































GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_Co_acquirer]    Script Date: 03/15/2016 18:59:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




































ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_Co_acquirer]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@Acquirer		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@SinkNodes	VARCHAR(255),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL

AS
BEGIN

	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
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
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		--structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		pan_encrypted			CHAR(30),
		from_account_id			VARCHAR(56),
		to_account_id			VARCHAR(56),
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
	--	receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
	        rdm_amount                      float,--Chioma added this 2012-07-03
                Reward_Discount                 float,--Chioma added this 2012-07-03
                Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03
                Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
                Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03
                totals_group		Varchar(40),
                  aggregate_column       VARCHAR(200),
               -- Late_Reversal CHAR (1),
               -- Terminal_owner_code Varchar (4),
		
                Unique_key varchar (200),
               
				tran_cash_req  FLOAT,--Eloho Added this for cashback
tran_cash_rsp  FLOAT,--Eloho Added this for cashback
        	tran_tran_fee_rsp  FLOAT,--Eloho Added this for cashback
			tran_currency_code      VARCHAR (50)--Eloho Added this for cashback
              )

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	--IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	--BEGIN	   
	--   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	--   	SELECT * FROM #report_result
	--	RETURN 1
	--END
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			

	-- Calculate the report dates
	--EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
	
	IF (@StartDate IS NULL OR @StartDate ='') 
		BEGIN 
			SELECT @StartDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		IF (@EndDate IS NULL OR @EndDate ='') 
		BEGIN 
			SELECT @EndDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		
	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET  @report_date_start = CONVERT(CHAR(8),@StartDate , 112)
	SET @report_date_end = CONVERT(CHAR(8),@EndDate , 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	--CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	--INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #list_of_AcquirerInstId (AcquirerInstId	VARCHAR(50)) 
	INSERT INTO  #list_of_AcquirerInstId EXEC osp_rpt_util_split_nodenames @AcquirerInstId

        
	-- Only look at 02xx messages that were not fully reversed.
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	
SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)
        

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                extended_trans_type = 'BURN',
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
		
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
			--	1,
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				ISNULL(account_nr,'not available'),
				isnull(t.payee,0),--oremeyi added this 2009-04-22
				extended_tran_type,
				--receiving_inst_id_code,--oremeyi added this 2010-02-28
				0,

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
      --                          Late_Reversal_id = CASE
						--WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						--ELSE 0
					 --       END,
                        --        tt.Terminal_code,
				c.totals_group,
				  t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(12)),
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,    
dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code                 

	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				--left JOIN tbl_merchant_category_visa s (NOLOCK)
				--ON c.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                --left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                --ON c.terminal_id = o.terminal_id 
				left JOIN Reward_Category r (NOLOCK)
				ON substring(y.extended_trans_type,1,4) = r.reward_code
                                --ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
                                --left JOIN tbl_terminal_owner tt (NOLOCK)
                                --ON c.terminal_id = tt.terminal_id
                                
                 
	
WHERE 			
	

				t.tran_completed = 1
				AND
				 (t.post_tran_id >= @first_post_tran_id) 
			AND 
			(t.post_tran_id <= @last_post_tran_id) 
			AND
			datetime_req >= @report_date_start
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				
				--AND 
				--t.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				--AND
				--(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
				AND
				t.tran_type NOT IN ('31','50','21')
                -- and c.merchant_type not in ('5371')	
                      --          AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND t.sink_node_name+LEFT(totals_group,3)
                      --         not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
                      --         and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   --and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk'))	
			                   and ISNULL(y.rdm_amt,0) <>0	

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	--AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'


INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = (CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = 
                                Case When c.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code,
				
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
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
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				isnull(t.payee,0),
				--ISNULL(account_nr,'not available'),
				0,--oremeyi added this 2009-04-22
					t.extended_tran_type,
				--0,--oremeyi added this 2010-02-28
				0,

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                c.totals_group,
                              --  0,
                              --  tt.Terminal_code,
				--'Reward',
                 t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(50)),
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
				 
			
                                dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
		
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code

	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_9))
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                
                                 ON c.terminal_id = o.terminal_id
                                left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code  
                                                                                       and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
	           
	
WHERE 			

				t.recon_business_date >= @report_date_start AND t.recon_business_date<= @report_date_end
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(t.message_type IN ('0220','0200', '0400', '0420') )
				--AND

				--(
				--(t.message_type IN ('0220','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				--)
				--AND 
				--t.tran_completed = 1 
				--AND 
				--y.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				--AND
				--(@merchants IS NULL OR LEN(@merchants) = 0 OR y.merchant_id IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
			
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                                --and c.merchant_type not in ('5371')
                               -- and ISNULL(y.rdm_amt,0) <>0
                               -- AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND t.sink_node_name+LEFT(totals_group,3)
                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
                               -- and c.totals_group not in ('VISAGroup')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	--AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc' */





		
	create table #temp_table_1
(aggregate_column varchar(200), counts float )
insert into #temp_table_1 select aggregate_column, count(aggregate_column) from #report_result
group by aggregate_column

update #report_result
set tran_type_desciption = tran_type_desciption+ '_M'
where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)

		
--	create table #temp_table
--(unique_key varchar(200))

--insert into #temp_table 
--select unique_key from @report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


		
	SELECT 
			* 
	FROM 
			#report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)


where    

          source_node_name ='SWTNCS2src' AND sink_node_name = 'ASPPOSVINsnk'
         -- and unique_key  IN (SELECT unique_key FROM #temp_table))
          --and left(pan,1) ='4'
          AND acquiring_inst_id_code <> '627787'
          and      (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
          

                                       
      
         
      
      -- and (source_node_name = 'SWTNCS2src' and sink_node_name = 'ASPPOSLMCsnk')
	ORDER BY 
			source_node_name, datetime_req, message_type
END



USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_payment_gateway]    Script Date: 03/16/2016 12:51:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


















ALTER PROCEDURE [dbo].[osp_rpt_b04_payment_gateway]
	@StartDate	    CHAR(8),	-- yyyymmdd
	@EndDate	    CHAR(8),	-- yyyymmdd
	@SourceNodes	    VARCHAR(40),
   	@terminal_IDs         VARCHAR(40),
   	@SinkNode           VARCHAR(40),
	@BINs		    VARCHAR(40),
	@CBNCode	    CHAR(3),
	@show_full_pan	    BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B06 report uses this stored proc.
	

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
		source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID					BIGINT, 
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
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			BIGINT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description			VARCHAR (60),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx				INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx				INT,	
		tran_reversed				INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		totals_group			varchar(12),
                extended_tran_type            char (4)          
	)			

	IF (@Terminal_IDs IS NULL or Len(@Terminal_IDs)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Terminal ID parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
    
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
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 

	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs

        CREATE TABLE #list_of_sink_nodes (SinkNode	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode

	
SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)
        
        
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT


	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			CASE WHEN @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
		ELSE
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) 
			END AS pan,
			c.terminal_id,
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			c.source_node_name,
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.from_account_id,
			t.to_account_id,  
			RIGHT(CAST(t.structured_data_req AS VARCHAR(255)), 6),
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.tran_reversed,
			c.pan_encrypted,
			t.from_account_id,
			t.to_account_id,
			t.payee,
			c.totals_group,
                        isnull(t.extended_tran_type,'0000')	
	FROM
			post_tran t (NOLOCK) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id) 
                                
                       

	
WHERE 			
	
--NOT (t.tran_nr+t.online_system_id in (select tran_nr+online_system_id from tbl_late_reversals) 
--and t.message_type = '0420'  and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1)
	 		
--			--c.post_tran_cust_id >= @rpt_tran_id			
--			AND
			t.tran_completed = 1
			AND
				(t.post_tran_id >= @first_post_tran_id   )
				AND
				( t.post_tran_id <= @last_post_tran_id   ) 	
				AND 
				t.datetime_req >=@report_date_start
				AND
			t.tran_postilion_originated = 0
			AND
			((
			t.tran_type = '50'--this won't work for Autopay CCLoad cos the intrabank trans are 00
			AND
			t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
			AND
			source_node_name NOT IN ('CCLOADsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.tran_completed = 1 
			AND
           		(
			LEFT(c.terminal_id, 4)  IN ('3IGW', '3CCW','3IBH', '3CPD', '3011','3SFA')
			OR c.terminal_id IN ('3EPY0701','3UIB0001', '3IPD0010','3IPDTROT', '3VRV0001', '3IGW0010', '3SFX0014' )
			OR   LEFT(c.terminal_id, 5)   = '3ADPS'
                        OR 
		        (c.terminal_id = '3BOL0001' and t.extended_tran_type = '8502')

			)
			)OR
			c.terminal_id like '3CPD%' and t.tran_type = ('00')
			OR
			(c.terminal_id like '3IPDFDT%' OR c.terminal_id like '3QTL002%') and message_type in ('0200','0420') and source_node_name <>'VTUsrc'
			
			)
         		
			AND 
			( 
			   (@SinkNode IS NULL OR LEN(@SinkNode) = 0)
			OR (t.sink_node_name in (SELECT SinkNode FROM #list_of_sink_nodes)) 
			OR (substring(t.sink_node_name,4,3) in (select substring (SinkNode,4,3) from #list_of_sink_nodes))--and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			OR (
              LEFT(pan,6)IN (SELECT BIN FROM #list_of_BINs)and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			  OR LEFT(pan,6) = '628051' and (substring(c.totals_group,1,3)in (select substring (SinkNode,4,3) from #list_of_sink_nodes)) and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes)
			) 
            AND
             LEFT( c.source_node_name,2)<> 'SB'
             AND
             LEFT(t.sink_node_name,2)  <> 'SB'
OPTION(MAXDOP 8)
				
	


IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
	--ELSE
	--BEGIN
	--	--
	--	-- Decrypt PAN information if necessary
	--	--

	--	DECLARE @pan VARCHAR (19)
	--	DECLARE @pan_encrypted CHAR (18)
	--	DECLARE @pan_clear VARCHAR (19)
	--	DECLARE @process_descr VARCHAR (100)

	--	SET @process_descr = 'Office B04 Report'

	--	-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
	--	DECLARE pan_cursor CURSOR FORWARD_ONLY
	--	FOR
	--		SELECT
	--				pan,
	--				pan_encrypted
	--		FROM
	--				#report_result
	--	FOR UPDATE OF pan

	--	OPEN pan_cursor

	--	DECLARE @error INT
	--	SET @error = 0

	--	IF (@@CURSOR_ROWS <> 0)
	--	BEGIN
	--		FETCH pan_cursor INTO @pan, @pan_encrypted
	--		WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
	--		BEGIN
	--			-- Handle the decrypting of PANs
	--			EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

	--			-- Update the row if its different
	--			IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
	--			BEGIN
	--				UPDATE
	--					#report_result
	--				SET
	--					pan = @pan_clear
	--				WHERE
	--					CURRENT OF pan_cursor
	--			END

	--			FETCH pan_cursor INTO @pan, @pan_encrypted
	--		END
	--	END

	--	CLOSE pan_cursor
	--	DEALLOCATE pan_cursor

	--END			
	SELECT *
	FROM
			#report_result 
	
             where 
	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
			
	ORDER BY 
			datetime_req
END


































































































































































































































































