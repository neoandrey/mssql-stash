USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web]    Script Date: 08/19/2016 08:45:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












ALTER      PROCEDURE [dbo].[osp_rpt_b04_web]

	@StartDate		CHAR(8),	-- yyyymmdd

	@EndDate			CHAR(8),	-- yyyymmdd

	@SinkNodes		VARCHAR(510),

	@SourceNodes	VARCHAR(512),

	@show_full_pan	BIT,

	@report_date_start DATETIME = NULL,

	@report_date_end DATETIME = NULL,

	@rpt_tran_id INT = NULL,

    @rpt_tran_id1 INT = NULL,
    
    @Extended_tran_type varchar (20)



AS

BEGIN

	SET NOCOUNT ON
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	

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

                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03

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

		tran_type_desciption	VARCHAR (500),

		rsp_code_description	VARCHAR (500),

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

		tran_reversed			INT,

		pan_encrypted			CHAR(18),

		from_account_id			VARCHAR(28),

		to_account_id			VARCHAR(28),

		payee				char(25),

		extended_tran_type		CHAR (4),

                rdm_amount                      Float,

                Reward_Discount                 Float,

                Addit_Charge                 DECIMAL(7,6),

                Addit_Party                 Varchar (10),

                Amount_Cap_RD               DECIMAL(9,0),

                Fee_Cap_RD               DECIMAL(9,0),

                Fee_Discount_RD          DECIMAL(9,7),

                Late_Reversal CHAR (1),

		totals_group		Varchar(40),

                aggregate_column         VARCHAR(200),

                Unique_key varchar (200),

        auth_id_rsp Varchar(200),

tran_cash_req  FLOAT,

tran_cash_rsp  FLOAT,

        	tran_tran_fee_rsp  FLOAT,

			tran_currency_code      VARCHAR (50)      

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

	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT



	IF (@warning is not null)

	BEGIN

		INSERT INTO #report_result (Warning) VALUES (@warning)

		

		SELECT * FROM #report_result

		

		RETURN 1


	END





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

--INSERT INTO  #list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',')

	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 

	

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
		CREATE TABLE #list_of_ETT (ETT	VARCHAR(20)) 

	

	INSERT INTO  #list_of_ETT EXEC osp_rpt_util_split_nodenames @extended_tran_type





	INSERT

				INTO #report_result

	SELECT

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				SourceNodeAlias = 

				(CASE 

					WHEN t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE t.source_node_name

				END),

				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,

				t.terminal_id, 

				t.acquiring_inst_id_code,

				t.terminal_owner,

				ISNULL(t.merchant_type,'VOID'),

                                extended_trans_type = Case When t.terminal_id in 

                                (select terminal_id from tbl_reward_OutOfband)

                                 and dbo.fn_rpt_CardGroup (t.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 

                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,

				ISNULL(m.Category_name,'VOID'),

				ISNULL(m.Fee_type,'VOID'),

				ISNULL(m.merchant_disc,0.0),

				ISNULL(m.fee_cap,0),

				ISNULL(m.amount_cap,999999999999.99),

				ISNULL(m.bearer,'M'),

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

				

				dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,

				dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,

				dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,

				dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

				dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,


				dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,

				t.tran_reversed,

				t.pan_encrypted,

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

                                R.Fee_Discount,

                                Late_Reversal_id = CASE

						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1

						ELSE 0

					        END,	

				t.totals_group,

                                t.retrieval_reference_nr+'_'+t.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(max))+'_'+t.pan,

                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(max))+'_'+t.message_type,

                t.auth_id_rsp,



dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 

				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,

				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,

				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code

	 	

	FROM

				post_tran_summary t (NOLOCK)
	join (SELECT [DATE] recon_business_date   FROM dbo.get_dates_in_range(@report_date_start, @report_date_end))rec
	ON t.recon_business_date = rec.recon_business_date

				left JOIN tbl_merchant_category m (NOLOCK)

				ON t.merchant_type = m.category_code 

				left JOIN tbl_merchant_account a (NOLOCK)

				ON t.card_acceptor_id_code = a.card_acceptor_id_code   

				left JOIN tbl_xls_settlement y (NOLOCK)

				

                                ON (t.terminal_id= y.terminal_id 

                                    AND t.retrieval_reference_nr = y.rr_number 

                                    --AND t.system_trace_audit_nr = y.stan

                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount

                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)

                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)

                                    and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

                                left JOIN tbl_reward_OutOfBand O (NOLOCK)

                                ON t.terminal_id = o.terminal_id

                                left JOIN Reward_Category r (NOLOCK)

                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code

                                                                                             and dbo.fn_rpt_CardGroup (t.PAN) in ('1','4')))
                                  

				

	WHERE 			

	

				t.tran_completed = 1 

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

				((substring(t.totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))

               or ((substring (t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)) and t.sink_node_name <> 'SWTASPPOSsnk')
               or (t.extended_tran_type in (select ETT from #list_of_ETT ) and t.sink_node_name = 'ESBCSOUTsnk'))

                            



				AND

				t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

				AND 

					(

					(t.terminal_id like '3IWP%') OR

					(t.terminal_id like '3ICP%') OR

					(t.terminal_id like '2%')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))

					(t.terminal_id like '5%') OR

                                        (t.terminal_id like '31WP%') OR

					(t.terminal_id like '31CP%') OR

					(t.terminal_id like '6%')

										)

				AND

				t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk

				AND

				t.tran_type NOT IN ('31','50')


                               -- and t.merchant_type not in ('5371')	

                                and  (

                                ((ISNULL(y.rdm_amt,0) = 0) 

                                or ((ISNULL(y.rdm_amt,0) <> 0)) and (ISNULL(y.amount,0) not in ('0','0.00'))) 

                                or 

                                (substring(y.extended_trans_type,1,4) = '1000')

                                )

                                AND  NOT  (t.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(t.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))

                                and t.totals_group  != 'VISAGroup'

                AND

              LEFT(t.source_node_name,2) != 'SB'

             AND

              LEFT(t.sink_node_name ,2) !='SB'

	AND t.source_node_name   NOT IN ( 'SWTMEGAsrc', 'SWTMEGADSsrc')
OPTION (RECOMPILE)

INSERT

				INTO #report_result

	SELECT

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				SourceNodeAlias = 

				(CASE 

					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE q.source_node_name

				END),

				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,

				q.terminal_id, 

				q.acquiring_inst_id_code,

				q.terminal_owner,

				ISNULL(q.merchant_type,'VOID'),

                                extended_trans_type = Case When q.terminal_id in 

                                (select terminal_id from tbl_reward_OutOfband)

                                 and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 

                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,

				ISNULL(m.Category_name,'VOID'),

				ISNULL(m.Fee_type,'VOID'),

				ISNULL(m.merchant_disc,0.0),

				ISNULL(m.fee_cap,0),

				ISNULL(m.amount_cap,999999999999.99),

				ISNULL(m.bearer,'M'),

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

				

				q.tran_nr as TranID,

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

				

				dbo.fn_rpt_isPurchaseTrx(q.tran_type) 	AS isPurchaseTrx,

				dbo.fn_rpt_isWithdrawTrx(q.tran_type) 	AS isWithdrawTrx,

				dbo.fn_rpt_isRefundTrx(q.tran_type) 		AS isRefundTrx,

				dbo.fn_rpt_isDepositTrx(q.tran_type) 		AS isDepositTrx,

				dbo.fn_rpt_isInquiryTrx(q.tran_type) 		AS isInquiryTrx,

				dbo.fn_rpt_isTransferTrx(q.tran_type) 	AS isTransferTrx,


				dbo.fn_rpt_isOtherTrx(q.tran_type) 		AS isOtherTrx,

				q.tran_reversed,

				q.pan_encrypted,

				q.from_account_id,

				q.to_account_id,

				q.payee,


				q.extended_tran_type,

                                ISNULL(y.rdm_amt,0),

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

				q.totals_group,

                                q.retrieval_reference_nr+'_'+q.terminal_id+'_'+'000000'+'_'+cast((abs(q.settle_amount_impact)) as varchar(12))+'_'+q.pan as aggregate_column,

                                q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(12))+'_'+q.message_type,

                q.auth_id_rsp,



                dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_req, 

				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_rsp,

				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_tran_fee_rsp,

				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_currency_code

	 	

	FROM

				asp_visa_pos q (NOLOCK)
					join (SELECT [DATE] recon_business_date   FROM dbo.get_dates_in_range(@report_date_start, @report_date_end))rec
	ON q.recon_business_date = rec.recon_business_date


				left JOIN tbl_merchant_category m (NOLOCK)

				ON q.merchant_type = m.category_code 

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

                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code

                                                                                             and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')))

				

	WHERE 			

			

				q.tran_completed = 1


				AND

				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 

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

				((substring(q.totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)))

                               -- or ((substring (q.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)) and q.sink_node_name <> 'SWTASPPOSsnk'))

                                



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

				q.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk

				AND

				q.tran_type NOT IN ('31','50')


                           --     and q.merchant_type not in ('5371')	

                                and  (

                                ((ISNULL(y.rdm_amt,0) = 0) 

                                or ((ISNULL(y.rdm_amt,0) <> 0)) and (ISNULL(y.amount,0) not in ('0','0.00'))) 

                                or 

                                (substring(y.extended_trans_type,1,4) = '1000')

                                )

                                --AND  NOT  (q.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)

                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))

                                and q.totals_group not in ('VISAGroup')

                AND

              LEFT(q.source_node_name,2) !=  'SB'

             AND

              LEFT(q.sink_node_name,2)!=  'SB'

	AND q.source_node_name NOT IN ('SWTMEGAsrc' ,  'SWTMEGADSsrc') 
	 OPTION (RECOMPILE)
				

	IF @@ROWCOUNT = 0

		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			

	--ELSE

	--BEGIN

		--

		-- Decrypt PAN information if necessary

		--



		--DECLARE @pan VARCHAR (19)

		--DECLARE @pan_encrypted CHAR (18)

		--DECLARE @pan_clear VARCHAR (19)

		--DECLARE @process_descr VARCHAR (100)



		--SET @process_descr = 'Office B04 Report'



		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor

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

select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')




		

	SELECT 

			* 

	FROM 

			#report_result --rresult 

                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)

where    

  retrieval_reference_nr NOT IN 
	(SELECT  retrieval_reference_nr 

	FROM 

			#report_result res  (NOLOCK)
			
			JOIN
			
			tbl_late_reversals ll (NOLOCK)
	   ON res.tranID = ll.tran_nr AND res.retrieval_reference_nr = ll.retrieval_reference_nr
	   
	   WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
	     and
          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc')

          and unique_key  IN (SELECT unique_key FROM #temp_table))
          AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))

          --and left(pan,1) <>'4'

	ORDER BY 

			datetime_tran_local,source_node_name

END



