USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_nibss]    Script Date: 04/16/2014 13:28:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE                     PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_nibss_2]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id1 INT = NULL,
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
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30), 
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
                rdm_amount                     float,
                Reward_Discount                float,
                Addit_Charge                 DECIMAL(7,6),
                Addit_Party                 Varchar (10),
                Amount_Cap_RD               DECIMAL(9,0),
                Fee_Cap_RD               DECIMAL(9,0),
                Fee_Discount_RD          DECIMAL(9,7),
                aggregate_column         VARCHAR(200),
                Unique_key varchar (200)           
                
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
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 
        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants;
	-- Only look at 02xx messages that were not fully reversed.
	
	SELECT  post_tran_id,post_tran_cust_id,settle_entity_id,batch_nr,prev_post_tran_id,next_post_tran_id,sink_node_name,tran_postilion_originated,tran_completed,message_type,tran_type,tran_nr,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,abort_rsp_code,auth_id_rsp,auth_type,auth_reason,retention_data,acquiring_inst_id_code,message_reason_code,sponsor_bank,retrieval_reference_nr,datetime_tran_gmt,datetime_tran_local,datetime_req,datetime_rsp,realtime_business_date,recon_business_date,from_account_type,to_account_type,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,settle_amount_impact,tran_cash_req,tran_cash_rsp,tran_currency_code,tran_tran_fee_req,tran_tran_fee_rsp,tran_tran_fee_currency_code,tran_proc_fee_req,tran_proc_fee_rsp,tran_proc_fee_currency_code,settle_amount_req,settle_amount_rsp,settle_cash_req,settle_cash_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_proc_fee_req,settle_proc_fee_rsp,settle_currency_code,icc_data_req,icc_data_rsp,pos_entry_mode,pos_condition_code,additional_rsp_data,structured_data_req,structured_data_rsp,tran_reversed,prev_tran_approved,issuer_network_id,acquirer_network_id,extended_tran_type,ucaf_data,from_account_type_qualifier,to_account_type_qualifier,bank_details,payee,card_verification_result,online_system_id,participant_id,receiving_inst_id_code,routing_type,pt_pos_operating_environment,pt_pos_card_input_mode,pt_pos_cardholder_auth_method,pt_pos_pin_capture_ability,pt_pos_terminal_operator INTO #TEMP_POST_TRAN FROM post_tran (NOLOCK) WHERE

                (recon_business_date >= @report_date_start) AND  (recon_business_date <= @report_date_end)
                AND
				tran_completed = 1				
				AND
				tran_postilion_originated = 0
				AND

				(
				message_type IN ('0100','0200', '0400', '0420')
				
				)
				AND 
			        tran_completed = 1 
				AND
				LEFT(sink_node_name,2) <>'SB'
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk','CUPsnk')
				AND
				tran_type NOT IN ('31','50','21')
		
				
SELECT post_tran_cust_id,source_node_name,draft_capture,pan,card_seq_nr,expiry_date,service_restriction_code,terminal_id,terminal_owner,card_acceptor_id_code,mapped_card_acceptor_id_code,merchant_type,card_acceptor_name_loc,address_verification_data,address_verification_result,check_data,totals_group,card_product,pos_card_data_input_ability,pos_cardholder_auth_ability,pos_card_capture_ability,pos_operating_environment,pos_cardholder_present,pos_card_present,pos_card_data_input_mode,pos_cardholder_auth_method,pos_cardholder_auth_entity,pos_card_data_output_ability,pos_terminal_output_ability,pos_pin_capture_ability,pos_terminal_operator,pos_terminal_type,pan_search,pan_encrypted,pan_reference INTO #TEMP_POST_TRAN_CUST FROM post_tran_cust (NOLOCK)
 WHERE 
 post_tran_cust_id >= (SELECT MIN(post_tran_cust_id) FROM #TEMP_POST_TRAN) AND post_tran_cust_id <= (SELECT MAX(post_tran_cust_id) FROM #TEMP_POST_TRAN )
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
								AND
								source_node_name IN (SELECT source_node FROM #list_of_source_nodes) AND  NOT  (source_node_name = 'SWTNCS2src'  AND not LEFT(c.pan,1) = '4')
								AND 
									(
									( LEFT(terminal_id,4) = '3IWP') OR
									(LEFT(terminal_id,4) =  '3ICP') OR
									(LEFT(terminal_id,1) =  '2')OR
									(LEFT(terminal_id,1) = '5') OR
				                                        (LEFT(c.terminal_id,4) =  '31WP') OR
									(LEFT(terminal_id,4) = '31CP') OR
									(LEFT(terminal_id,1) =  '6')
														)
									AND merchant_type not in ('5371')	
						
									AND totals_group not in ('VISAGroup')
									AND
									LEFT( source_node_name,2) <>'SB'
      
INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
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
				1,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                                ISNULL(y.rdm_amt,0),
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                  t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(ISNULL(y.rdm_amt,0))) as varchar(12)),
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type
                  
 
				
	FROM
				#TEMP_POST_TRAN t (NOLOCK)
				INNER JOIN #TEMP_POST_TRAN_CUST c (NOLOCK)
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
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
                                left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code

	WHERE 			
				
						((c.post_tran_cust_id >= @rpt_tran_id1)  OR (c.post_tran_cust_id < @rpt_tran_id1 and c.post_tran_cust_id >= @rpt_tran_id and t.message_type <> '0420')
						)
						 and ISNULL(y.rdm_amt,0) <>0	
                           

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
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
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
				1,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                 t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(12)),
                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type
                 	
				
	FROM
				#TEMP_POST_TRAN t (NOLOCK)
				INNER JOIN #TEMP_POST_TRAN_CUST c (NOLOCK)
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
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
                                 left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.card_acceptor_id_code = o.card_acceptor_id_code 
                                left JOIN Reward_Category r (NOLOCK)
                                 ON (substring(y.extended_trans_type,1,4) = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
	WHERE 			
				
				((c.post_tran_cust_id >= @rpt_tran_id1) 
                                 or (c.post_tran_cust_id < @rpt_tran_id1 and c.post_tran_cust_id >= @rpt_tran_id and t.message_type <> '0420')
                                )--'81530747'	
				
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
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
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
				1,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,

                t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs((-1*y.amount*v.discount))) as varchar(12)),
                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type
				
	FROM
				#TEMP_POST_TRAN t (NOLOCK)
				INNER JOIN #TEMP_POST_TRAN_CUST c (NOLOCK)
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
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
                                 left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.card_acceptor_id_code = o.card_acceptor_id_code 
                                left JOIN Reward_Category r (NOLOCK)
                                 ON (substring(y.extended_trans_type,1,4) = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
                                 left Join Verve_Discount V (nolock)
                                 ON (substring(y.extended_trans_type,5,2) = v.code or substring(o.r_code,5,2) = v.code)

	WHERE 			
				
				((c.post_tran_cust_id >= @rpt_tran_id1) 
                                 or (c.post_tran_cust_id < @rpt_tran_id1 and c.post_tran_cust_id >= @rpt_tran_id and t.message_type <> '0420')
                                )--'81530747'	
				AND
			
           ((len(y.extended_trans_type) = 6 and substring(y.extended_trans_type,5,2)<> '00')
                                   or (len(o.r_code) = 6 and substring(o.r_code,5,2)<> '00'))
                                  and ((-1*y.amount)-dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ))<>0
  
						
								
				
								
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name= 'SWTASPPOSsrc'


		
	SELECT 
			* 
	FROM 
			#report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where     not(source_node_name = 'SWTNCS2src' 
          and unique_key  IN (SELECT unique_key FROM #temp_table))
         
	ORDER BY 
			source_node_name, datetime_req, message_type
END



















































































































































































































