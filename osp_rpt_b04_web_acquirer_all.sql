if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[osp_rpt_b04_web_acquirer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[osp_rpt_b04_web_acquirer]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




CREATE          PROCEDURE [dbo].[osp_rpt_b04_web_acquirer_all]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@rpt_tran_id        VARCHAR(30),
	@rpt_tran_id1        VARCHAR(30),
    @report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@show_full_pan bit

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
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			VARCHAR(15),
		terminal_owner  		VARCHAR(25),
		merchant_type				CHAR (4),
        extended_tran_type_reward               VARCHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc		DECIMAL(7,4),
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
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
                                 extended_trans_type = Case When c.card_acceptor_id_code in 
                                (select card_acceptor_id_code from tbl_reward_OutOfband)
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
				payee,--oremeyi added this 2009-04-22
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
                                ON c.card_acceptor_id_code = o.card_acceptor_id_code 
                                left JOIN Reward_Category r (NOLOCK)
                                ON (t.extended_tran_type = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
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

				AND 
					(
					(LEFT(c.terminal_id,4)='3IWP') OR
					(LEFT(c.terminal_id,4)='3ICP') OR
					(LEFT(c.terminal_id,1)='2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1)='5') OR
                    (LEFT(c.terminal_id,4)='31WP') OR
					(LEFT(c.terminal_id,4)= '31CP') OR
					(LEFT(c.terminal_id,1)= '6')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
                AND
                                LEFT(c.source_node_name,2) ='SB'
                                AND
                                LEFT(sink_node_name,2) ='SB'
                AND t.extended_tran_type IS NOT NULL
                                  
			


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
				ISNULL(merchant_type,'VOID'),
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
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

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
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
				left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code
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
				AND 
					(
					(LEFT(c.terminal_id,4)='3IWP') OR
					(LEFT(c.terminal_id,4)='3ICP') OR
					(LEFT(c.terminal_id,1)='2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1)='5') OR
                    (LEFT(c.terminal_id,4)='31WP') OR
					(LEFT(c.terminal_id,4)= '31CP') OR
					(LEFT(c.terminal_id,1)= '6')
										)
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
                AND
                                LEFT(c.source_node_name,2) ='SB'
                                AND
                                LEFT(sink_node_name,2) ='SB'
                                  
			 AND t.extended_tran_type IS NOT NULL
								
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
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

