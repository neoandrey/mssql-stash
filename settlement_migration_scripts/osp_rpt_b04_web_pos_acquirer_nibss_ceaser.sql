USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_nibss]    Script Date: 10/25/2016 13:54:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



    CREATE                   PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_nibss_ceaser]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	--@Acquirer		VARCHAR(255),
	---@AcquirerInstId		VARCHAR(255),
	--@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id1 INT = NULL,
        @rpt_tran_id INT = NULL

AS
BEGIN
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @report_result TABLE
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
			card_acceptor_name_loc	CHAR (544), 
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
			structured_data_req		VARCHAR(255),
			tran_reversed			INT,
			merchant_acct_nr		VARCHAR(50),
			bank_code	VARCHAR(3),	
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
			Unique_key varchar (200),
			tran_cash_req  FLOAT,
			tran_cash_rsp  FLOAT,
			tran_tran_fee_rsp  FLOAT,
			tran_currency_code      VARCHAR (50)

                
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
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

		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET  @report_date_start = CONVERT(CHAR(8), @StartDate , 112)
	SET  @report_date_end  = CONVERT(CHAR(8), @EndDate, 112)

	EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 
    EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes,',') ORDER BY part ASC
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants,',') ORDER BY part ASC
 DECLARE @report_date_end2 DATETIME =@report_date_end+1;
	

INSERT
				INTO @report_result
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
				case when y.merchant_id is null or y.merchant_id = '' then 'NOCARDACCEPTORI'
				else y.merchant_id end, 
				case when a.Account_name is null or a.Account_name = ' ' then substring(y.card_acceptor_name_loc,1,40) else a.Account_name end,
				--substring(y.card_acceptor_name_loc,1,40), 
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
				a.bank_code,
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
                 y.rr_number+'_'+y.terminal_id+'_'+'000000'+'_'+cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50))+'_'+y.pan,
                 y.rr_number+'_'+'000000'+'_'+y.terminal_id+'_'+ cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50))+'_'+'0200',
                0 AS tran_cash_req, 
				0 AS tran_cash_rsp,
				0 AS tran_tran_fee_rsp,
				0 AS tran_currency_code
			
				--'SSS'
                  
 
				
	FROM
				
				 
				 ( SELECT * FROM  tbl_xls_settlement txs(NOLOCK)  JOIN
					(SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end2))rec
					ON
					txs.trans_date = rec.rec_bus_date
   				 )y left JOIN
				 tbl_merchant_account a (NOLOCK)
				 ON y.merchant_id = a.card_acceptor_id_code  
                                left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code

	WHERE 			
				
				
				 (@merchants IS NULL OR LEN(@merchants) = 0 OR y.merchant_id IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				and ISNULL(y.rdm_amt,0) <>0
                 and LEFT(y.terminal_id,1) = '2'
                 and y.extended_trans_type is not null 
				 OPTION(RECOMPILE)


	 INSERT
				INTO @report_result
			SELECT
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate, 
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
			else ISNULL(substring(y.extended_trans_type,1,4),'0000')end ,
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
			case when c.card_acceptor_id_code is null or c.card_acceptor_id_code = '' then 'NOCARDACCEPTORI'
			else c.card_acceptor_id_code end, 
			case when a.Account_name is null or a.Account_name = ' ' then c.card_acceptor_name_loc else a.Account_name end,
			--c.card_acceptor_name_loc, 
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
			a.bank_code,
			c.totals_group,--oremeyi added this 2009-04-22

			extended_tran_type,
			0,
			0,
			R.Reward_Discount,
			R.Addit_Charge,
			R.Addit_Party,
			R.Amount_Cap,
			R.Fee_Cap,
			R.Fee_Discount,
			t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(50))+'_'+c.pan,
			t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
			dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
			dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
			dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
			dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code

			--c.totals_group
                 	
				
	FROM
				(
				 SELECT * FROM post_tran pt (NOLOCK, INDEX(ix_post_tran_9)) JOIN
				 
				 	(SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))rec
					ON
					pt.recon_business_date = rec.rec_bus_date 
					and
					 pt.tran_completed = 1
				AND
				pt.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
			
				AND

				(
				(pt.message_type IN ('0220','0200', '0400', '0420')) 
				
				)
				
					AND post_tran_id NOT IN (
					
	
SELECT LL.post_tran_id FROM tbl_late_reversals ll (NOLOCK)  JOIN  ( SELECT * FROM post_tran pt (NOLOCK, INDEX(ix_post_tran_9)) JOIN
				 
				 	(SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))rec
					ON
					pt.recon_business_date = rec.rec_bus_date)tt ON ll.post_tran_id = tt.post_tran_id and
         ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>0 
				)) t   
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
                                   
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                 left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id 
                                left JOIN Reward_Category r (NOLOCK)
                                 ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
	            

				

	WHERE 			

				
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
					(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)
				AND
				t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk','CUPsnk')	------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                and c.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511')
                 AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))			

                 AND
    LEFT( c.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB' --AND not( t.sink_node_name   LIKE 'SB%') 
            
OPTION (RECOMPILE,MAXDOP 8)
                
INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
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
				case when c.card_acceptor_id_code is null or c.card_acceptor_id_code = '' then 'NOCARDACCEPTORI'
				else c.card_acceptor_id_code end,
				 case when a.Account_name is null or a.Account_name = ' 'then c.card_acceptor_name_loc else a.Account_name end,
				--c.card_acceptor_name_loc, 
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
				a.bank_code,
				c.totals_group,--oremeyi added this 2009-04-22

				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,

                t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs((-1*y.amount*v.discount))) as varchar(50))+'_'+c.pan,
                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code
			
				--c.totals_group
	FROM
				(
				 SELECT * FROM post_tran pt (NOLOCK, INDEX(ix_post_tran_9)) JOIN
				 
				 	(SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))rec
					ON
					pt.recon_business_date = rec.rec_bus_date 
					and
					 pt.tran_completed = 1
				AND
				pt.tran_postilion_originated = 0
			
				AND

				(
				(pt.message_type IN ('0220','0200', '0400', '0420')) 
				
				)
				
					AND post_tran_id NOT IN (
					
	
SELECT LL.post_tran_id FROM tbl_late_reversals ll (NOLOCK)  JOIN  ( SELECT * FROM post_tran pt (NOLOCK, INDEX(ix_post_tran_9)) JOIN
				 
				 	(SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))rec
					ON
					pt.recon_business_date = rec.rec_bus_date)tt ON ll.post_tran_id = tt.post_tran_id and
         ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>0 
				)) t
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
                                 left Join Verve_Discount V (nolock)
                                 ON (substring(y.extended_trans_type,5,2) = v.code or (substring(o.r_code,5,2) = v.code  and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
                   

				

	WHERE 			

		
				
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
			(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)
				AND
				t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk','CUPsnk')
				AND
				t.tran_type NOT IN ('31','50','21')
                and c.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511')
                 AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))			

                                 and ((len(y.extended_trans_type) = 6 and substring(y.extended_trans_type,5,2)<> '00')
                                   or (len(o.r_code) = 6 and substring(o.r_code,5,2)<> '00'))
                                  and ((-1*y.amount)-dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ))<>0
                 AND
    LEFT( c.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB' 
      
     OPTION (RECOMPILE, MAXDOP 8)
	 
      INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 

				q.source_node_name,
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
				case when q.card_acceptor_id_code is null or q.card_acceptor_id_code = '' then 'NOCARDACCEPTORI'
				else q.card_acceptor_id_code end, 
				case when a.Account_name is null or a.Account_name = ' ' then q.card_acceptor_name_loc else a.Account_name end,
				--q.card_acceptor_name_loc, 
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
				a.bank_code,
				q.totals_group,--oremeyi added this 2009-04-22

				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                 q.retrieval_reference_nr+'_'+q.terminal_id+'_'+'000000'+'_'+cast((abs(q.settle_amount_impact)) as varchar(50))+'_'+q.pan,
                q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(50))+'_'+q.message_type,
dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_currency_code
				
				--q.totals_group
                 	
				
	FROM
				 (
				 SELECT * FROM asp_visa_pos asq (NOLOCK)
				 JOIN
				 (SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))rec
					ON
					asq.recon_business_date = rec.rec_bus_date
					AND
		asq.tran_completed = 1
				
				AND
				asq.tran_postilion_originated = 0
				
				AND

				(
				(asq.message_type IN ('0220','0200', '0400', '0420')) 
				
				)					
				 ) q
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
	WHERE 			
				
		
				
				
				(@merchants IS NULL OR LEN(@merchants) = 0 OR q.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				--AND
				--q.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
					(
					(CHARINDEX (  '3IWP', q.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', q.terminal_id) > 0 ) OR
					(LEFT(q.terminal_id,1) = '2')OR--(q.terminal_id like '2%' AND q.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(q.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', q.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', q.terminal_id) > 0) OR
					( LEFT(q.terminal_id,1) = '6')
					)
				--AND
				--sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk','CUPsnk')	------ij added SWTMEGAsnk
				--AND
				--q.pan not like '4%'
				AND
				q.tran_type NOT IN ('31','50','21')
                and q.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511')	
                               --AND  NOT  (q.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)
                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01')  
               	                and q.totals_group not in ('VISAGroup')
                 AND
    LEFT( q.source_node_name,2)  <> 'SB'
              AND LEFT( q.sink_node_name,2)  <> 'SB' --AND not( q.sink_node_name   LIKE 'SB%') 
			 --and c.post_tran_cust_id > '931993163'   					
				OPTION (recompile, MAXDOP 8)
								
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from @report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


		
DECLARE  @report_result2 TABLE
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
		structured_data_req		VARCHAR(70),
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),
		bank_code           VARCHAR(3),	
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
                Unique_key varchar (200),
tran_cash_req  FLOAT,
tran_cash_rsp  FLOAT,
        	tran_tran_fee_rsp  FLOAT,
			tran_currency_code      VARCHAR (50)
		
			--Totalsgroup varchar (40)
			 )  
			
       
                
	

	insert into
	@report_result2	
	SELECT 
			* 
	FROM 
			@report_result  
			
where     not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') 
          and unique_key  IN (SELECT unique_key FROM #temp_table))
       
	ORDER BY 
			source_node_name, datetime_req, message_type
			
create table #temp_table2
(merchant_id varchar(20), sett_amt float, recoup_amt float)

create table #temp_report_results (card_acceptor_id_code varchar(20), settle_amount_impact float)


INSERT INTO #temp_report_results  SELECT card_acceptor_id_code, sum(settle_amount_impact)
FROM  @report_result2
GROUP BY card_acceptor_id_code

create table #temp_report_recoup
(SERIAL_NO varchar(25),ACCOUNT_NO varchar(20),SORT_CODE varchar(20),AMOUNT float,
PAYEE varchar(255),MERCHANT_ID varchar(50),DATE_RECOUPED datetime)


INSERT INTO #temp_report_recoup 
SELECT SERIAL_NO,ACCOUNT_NO,SORT_CODE,sum(amount),PAYEE,merchant_id,DATE_RECOUPED 
from recoupment_data
group by merchant_id,SERIAL_NO,ACCOUNT_NO,SORT_CODE,PAYEE,DATE_RECOUPED 
OPTION (MAXDOP 8)


insert into #temp_table2
select tt.merchant_id,sum(r.settle_amount_impact*-1),sum(tt.amount)
from #temp_report_results r join #temp_report_recoup  tt
on r.card_acceptor_id_code = tt.merchant_id

group by tt.merchant_id
OPTION (MAXDOP 8)

create table #temp_table3
(merchant_id varchar(20), recoup_amt float)

insert into #temp_table3
select tt.merchant_id,sum(tt.amount)
from recoupment_data tt
group by tt.merchant_id
OPTION (MAXDOP 8)

insert into recoupment_data (SERIAL_NO,ACCOUNT_NO,SORT_CODE,AMOUNT,PAYEE,MERCHANT_ID,DATE_RECOUPED)
select SERIAL_NO,ACCOUNT_NO,SORT_CODE
,isnull(case when (sett_amt*0.95)-recoup_amt <0 then sett_amt*0.95*-1
             when (sett_amt*0.95)-recoup_amt =0 then sett_amt*0.95*-1
      when (sett_amt*0.95)-recoup_amt >0 then recoup_amt*-1 end,0),
PAYEE ,tt.MERCHANT_ID , getdate() from #temp_table2 te  join  #temp_report_recoup  tt
on te.merchant_id = tt.merchant_id
where recoup_amt<>0 --and tt.merchant_id in (select r.card_acceptor_id_code from @report_result2)
OPTION (MAXDOP 8)
insert into @report_result2	
select NULL,'20150717','20150717','RECOUPDATA','xxxx','2'+substring(sort_code,1,3)+'0001','100001','101','1111','0000','RECOUPDATA',
'P','0.0001','0','0','M',TT.MERCHANT_ID,TT.PAYEE,'RECOUPDATA','RECOUPDATA','00','00','0200','20150717',
 TT.AMOUNT,TT.AMOUNT,0,'1000000001','0','100001','1510','100000000001','20150717','10','00','566',
 isnull(case when (sett_amt*0.95)-recoup_amt <0 then sett_amt*0.95
             when (sett_amt*0.95)-recoup_amt =0 then sett_amt*0.95
      when (sett_amt*0.95)-recoup_amt >0 then recoup_amt end,0),
 'RECOUPDATA','Approved','2','NGN','Naira','1','0','0','0','0','0','0','1','0',ACCOUNT_NO,'1','bank_code',
 NULL,NULL,'0',NULL,NULL,NULL,NULL,NULL,NULL,'100000000001_2'+substring(sort_code,1,3)+'0001_100001_'+substring(account_no,5,6)+'0',
 '100000000001_000000_10000001_0_0200','0','0','0','0'
from #temp_table2 te join  #temp_report_recoup  tt
on te.merchant_id = tt.merchant_id
where recoup_amt<>0 
OPTION (recompile, MAXDOP 8)


		 
select *  from @report_result2



END

 












































































































































































