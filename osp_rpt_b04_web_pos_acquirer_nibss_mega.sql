USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_nibss]    Script Date: 11/02/2016 15:55:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[osp_rpt_b04_web_pos_acquirer_nibss] NULL,NULL,NULL,NULL

    alter                   PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_nibss]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),
		@report_date_start		VARCHAR(30),	-- yyyymmdd
	@report_date_end 		VARCHAR(30)	

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
			--Totalsgroup varchar (40)          
                
	)

	

	/*IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM @report_result
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

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

--INSERT
--				INTO @report_result
--	SELECT
--				NULL AS Warning,
--				@StartDate as StartDate,  
--				@EndDate as EndDate, 
--				SourceNodeAlias = 'Reward',
--				dbo.fn_rpt_PanForDisplay(y.pan, '0') AS pan,
--				y.terminal_id, 
--				y.acquiring_inst_id_code,
--				'Reward',
--				'5310',
--                                extended_trans_type = 'BURN',
--				'Discount Stores',
--				'P',
--				0.007500,
--				1200,
--				160000,
--				'M',
--				case when y.merchant_id is null or y.merchant_id = '' then 'NOCARDACCEPTORI'
--				else y.merchant_id end, 
--				case when a.Account_name is null or a.Account_name = ' ' then substring(y.card_acceptor_name_loc,1,40) else a.Account_name end,
--				--substring(y.card_acceptor_name_loc,1,40), 
--				'Reward',
--				'Reward', 
--				'00', 
--				'00', 
--				'0200', 
--				y.trans_date,
				
				
--				0, 
--				0,
--				0,
				
--				0 as TranID,
--				0, 
--				y.stan, 
--				0, 
--				y.rr_number, 
--				y.trans_date, 
--				0, 
--				0, 
--				'566', 
				
				
--				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
--				0,				
				
--				'Goods and Services' as tran_type_desciption,
--				'Approved' as rsp_code_description,
--				 2 AS settle_nr_decimals,
--				'NGN' AS currency_alpha_code,
--				'Naira' AS currency_name,
				
--				1 	AS isPurchaseTrx,
--				0 	AS isWithdrawTrx,
--				0 		AS isRefundTrx,
--				0 		AS isDepositTrx,
--				0 		AS isInquiryTrx,
--				0	AS isTransferTrx,
--				0 		AS isOtherTrx,
--				1,
--				0,
--				ISNULL(account_nr,'not available'),
--				a.bank_code,
--				0,--oremeyi added this 2009-04-22
--				'0000',
--				0,--oremeyi added this 2010-02-28
--				ISNULL(y.rdm_amt,0),

--                                R.Reward_Discount,
--                                R.Addit_Charge,
--                                R.Addit_Party,
--                                R.Amount_Cap,
--                                R.Fee_Cap,
--                                R.Fee_Discount,
--                 y.rr_number+'_'+y.terminal_id+'_'+'000000'+'_'+cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50))+'_'+y.pan,
--                 y.rr_number+'_'+'000000'+'_'+y.terminal_id+'_'+ cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50))+'_'+'0200',
--                0 AS tran_cash_req, 
--				0 AS tran_cash_rsp,
--				0 AS tran_tran_fee_rsp,
--				0 AS tran_currency_code
			
--				--'SSS'
                  
 
				
--	FROM
				 
--				 tbl_xls_settlement y (NOLOCK) left JOIN
--				 tbl_merchant_account a (NOLOCK)
--				 ON y.merchant_id = a.card_acceptor_id_code  
--                                left JOIN Reward_Category r (NOLOCK)
--                                ON substring(y.extended_trans_type,1,4) = r.reward_code

--	WHERE 			
				
--				y.trans_date >= @report_date_start AND y.trans_date<= @report_date_end+1
--				AND ISNULL(y.rdm_amt,0) <>0
--                AND LEFT(y.terminal_id,1) = '2'
--                AND y.extended_trans_type is not null 
               

	 INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				t.source_node_name,
				dbo.fn_rpt_PanForDisplay(t.pan, '0') AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				t.terminal_owner,
				ISNULL(t.merchant_type,'VOID'),
                               extended_trans_type = Case When t.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (t.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end ,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				case when t.card_acceptor_id_code is null or t.card_acceptor_id_code = '' then 'NOCARDACCEPTORI'
				else t.card_acceptor_id_code end, 
				case when a.Account_name is null or a.Account_name = ' ' then t.card_acceptor_name_loc else a.Account_name end,
				--t.card_acceptor_name_loc, 
				t.source_node_name,
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
				acc.bank_code,
				t.totals_group,--oremeyi added this 2009-04-22

				extended_tran_type,
				0,
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                t.retrieval_reference_nr+'_'+t.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(50))+'_'+t.pan,
                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code
				
				--t.totals_group
                 	
				
	FROM
				post_tran_summary t (NOLOCK)
				
				left JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
                left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON t.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON t.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                   
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                 left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON t.terminal_id = o.terminal_id 
                                left JOIN Reward_Category r (NOLOCK)
                                 ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code and dbo.fn_rpt_CardGroup (t.PAN) in ('1','4')))
	            

				LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = t.acquiring_inst_id_code or acc.acquirer_inst_id2 = t.acquiring_inst_id_code or 
acc.acquirer_inst_id3 = t.acquiring_inst_id_code or acc.acquirer_inst_id4 = t.acquiring_inst_id_code or acc.acquirer_inst_id5 
= t.acquiring_inst_id_code)

	WHERE 			

					
			 post_tran_id NOT IN (
					
	
SELECT LL.post_tran_id FROM tbl_late_reversals ll (NOLOCK)  JOIN  ( SELECT * FROM post_tran_summary pt (NOLOCK, INDEX(ix_post_tran_9)) JOIN
				 
				 	(SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))rec
					ON
					pt.recon_business_date = rec.rec_bus_date)tt ON ll.post_tran_id = tt.post_tran_id and
         ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>0 
				)
				and t.tran_completed = 1
				AND
				t.recon_business_date >= @report_date_start AND t.recon_business_date<= @report_date_end
				AND
				t.tran_postilion_originated = 0
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
		
				)
				
				AND 
				t.tran_completed = 1 
			
				AND

				 
					(
					(CHARINDEX (  '3IWP', t.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', t.terminal_id) > 0 ) OR
					(LEFT(t.terminal_id,1) = '2')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(t.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', t.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', t.terminal_id) > 0) OR
					( LEFT(t.terminal_id,1) = '6')
					)

				AND
				t.tran_type NOT IN ('31','50','21')
                and t.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511')
             		AND
    LEFT( t.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB' 
    AND
    ((source_node_name = 'MGASPVLGTsrc' AND sink_node_name ='MEGGTBVB2snk')
 OR
(source_node_name = 'MGASPUBVLsrc' AND sink_node_name ='MEGUBAVB2snk')
 or
(source_node_name ='MGASPUBVIsrc'   AND sink_node_name ='MEGUBAVB2snk')
  
  OR
(sink_node_name = 'MEGBANKMDSsnk'
AND 
source_node_name IN (
'MEGASPABPsrc',
'MEGASPCHBsrc',
'MEGASPEBNsrc',
'MEGASPFBNsrc',
'MEGASPFBPsrc',
'MEGASPFCMsrc',
'MEGASPGTBsrc',
'MEGASPHBCsrc',
'MEGASPKSBsrc',
'MEGASPPRUsrc',
'MEGASPSBPsrc',
'MEGASPUBAsrc',
'MEGASPUBNsrc',
'MEGASPUBPsrc',
'MEGASPWEMsrc')
)
)
and totals_group NOT IN ('MCSGroup', 'MPPGroup','MCCredGroup' )
OPTION (MAXDOP 8)
                
INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
			
				t.source_node_name,
				dbo.fn_rpt_PanForDisplay(t.pan,'0') AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				t.terminal_owner,
				ISNULL(t.merchant_type,'VOID'),
                                extended_trans_type = Case When t.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (t.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,t.tran_type,t.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				case when t.card_acceptor_id_code is null or t.card_acceptor_id_code = '' then 'NOCARDACCEPTORI'
				else t.card_acceptor_id_code end,
				 case when a.Account_name is null or a.Account_name = ' 'then t.card_acceptor_name_loc else a.Account_name end,
				--t.card_acceptor_name_loc, 
				t.source_node_name,
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
				acc.bank_code,
				t.totals_group,--oremeyi added this 2009-04-22

				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,

                t.retrieval_reference_nr+'_'+t.terminal_id+'_'+'000000'+'_'+cast((abs((-1*y.amount*v.discount))) as varchar(50))+'_'+t.pan,
                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
				dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code
		
	FROM
				post_tran_summary  t (NOLOCK)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON t.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON t.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                   
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                  and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                 left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON t.terminal_id = o.terminal_id 
                                left JOIN Reward_Category r (NOLOCK)
                                 ON (substring(y.extended_trans_type,1,4) = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
                                 left Join Verve_Discount V (nolock)
                                 ON (substring(y.extended_trans_type,5,2) = v.code or (substring(o.r_code,5,2) = v.code  and dbo.fn_rpt_CardGroup (t.PAN) in ('1','4')))
                   

				LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = t.acquiring_inst_id_code or acc.acquirer_inst_id2 = t.acquiring_inst_id_code or 
acc.acquirer_inst_id3 = t.acquiring_inst_id_code or acc.acquirer_inst_id4 = t.acquiring_inst_id_code or acc.acquirer_inst_id5 
= t.acquiring_inst_id_code)
				

	WHERE 			

		post_tran_id NOT IN (
					
	
SELECT LL.post_tran_id FROM tbl_late_reversals ll (NOLOCK)  JOIN  ( SELECT * FROM post_tran_summary pt (NOLOCK, INDEX(ix_post_tran_9)) JOIN
				 
				 	(SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))rec
					ON
					pt.recon_business_date = rec.rec_bus_date)tt ON ll.post_tran_id = tt.post_tran_id and
         ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>0 
				)	and t.tran_completed = 1
				AND
				t.recon_business_date >= @report_date_start AND t.recon_business_date<= @report_date_end

				AND
				t.tran_postilion_originated = 0
				
				AND

				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
			
				)
			
				and
				t.tran_completed = 1 
				
			
				AND 
			(
					(CHARINDEX (  '3IWP', t.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', t.terminal_id) > 0 ) OR
					(LEFT(t.terminal_id,1) = '2')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(t.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', t.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', t.terminal_id) > 0) OR
					( LEFT(t.terminal_id,1) = '6')
					)
				AND
				
				t.tran_type NOT IN ('31','50','21')
                and t.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511') 		
                                 and ((len(y.extended_trans_type) = 6 and substring(y.extended_trans_type,5,2)<> '00')
                                   or (len(o.r_code) = 6 and substring(o.r_code,5,2)<> '00'))
                                  and ((-1*y.amount)-dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ))<>0
                 AND
    LEFT( t.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB' 
              AND
    ((source_node_name = 'MGASPVLGTsrc' AND sink_node_name ='MEGGTBVB2snk')
 OR
(source_node_name = 'MGASPUBVLsrc' AND sink_node_name ='MEGUBAVB2snk')
 or
(source_node_name ='MGASPUBVIsrc'   AND sink_node_name ='MEGUBAVB2snk')
  
  OR
(sink_node_name = 'MEGBANKMDSsnk'
AND 
source_node_name IN (
'MEGASPABPsrc',
'MEGASPCHBsrc',
'MEGASPEBNsrc',
'MEGASPFBNsrc',
'MEGASPFBPsrc',
'MEGASPFCMsrc',
'MEGASPGTBsrc',
'MEGASPHBCsrc',
'MEGASPKSBsrc',
'MEGASPPRUsrc',
'MEGASPSBPsrc',
'MEGASPUBAsrc',
'MEGASPUBNsrc',
'MEGASPUBPsrc',
'MEGASPWEMsrc')
)
)and totals_group NOT IN ('MCSGroup', 'MPPGroup','MCCredGroup' )
               
     OPTION (MAXDOP 8)
     
     
								
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
			
       
                
	

	insert into @report_result2	
	SELECT 
			* 
	FROM 
			@report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where       unique_key  IN (SELECT unique_key FROM #temp_table)
          --and t.post_tran_cust_id > '931993163'   
	ORDER BY 
			source_node_name, datetime_req, message_type
			

create table #temp_table2
(merchant_id varchar(20), sett_amt float, recoup_amt float)

create table #temp_report_results
(card_acceptor_id_code varchar(20), settle_amount_impact float)


INSERT INTO #temp_report_results  SELECT card_acceptor_id_code, sum(settle_amount_impact)
from @report_result2
group by card_acceptor_id_code

create table #temp_report_recoup
(SERIAL_NO varchar(25),ACCOUNT_NO varchar(20),SORT_CODE varchar(20),AMOUNT float,
PAYEE varchar(255),MERCHANT_ID varchar(50),DATE_RECOUPED datetime)



--INSERT INTO #temp_report_recoup 
--SELECT SERIAL_NO,ACCOUNT_NO,SORT_CODE,sum(amount),PAYEE,merchant_id,DATE_RECOUPED 
--from recoupment_data
--group by merchant_id,SERIAL_NO,ACCOUNT_NO,SORT_CODE,PAYEE,DATE_RECOUPED 
--OPTION (MAXDOP 8)


insert into #temp_table2
select tt.merchant_id,sum(r.settle_amount_impact*-1),sum(tt.amount)
from #temp_report_results r join #temp_report_recoup  tt
on r.card_acceptor_id_code = tt.merchant_id

group by tt.merchant_id
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
OPTION (MAXDOP 8)


IF ( OBJECT_ID('tbl_web_pos_acquirer_nibss') IS NOT NULL)
		 BEGIN
				  DROP TABLE tbl_web_pos_acquirer_nibss
		 END
		 
		 
		 
select * into tbl_web_pos_acquirer_nibss from @report_result2

select * from tbl_web_pos_acquirer_nibss
--where left(pan,1) ='4'

--SELECT * FROM tbl_web_pos_acquirer_nibss (NOLOCK)

END

 

--select * from @report_result

--END













































































































































































