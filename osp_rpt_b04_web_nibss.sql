USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_nibss]    Script Date: 07/21/2015 10:40:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




















ALTER                             PROCEDURE [dbo].[osp_rpt_b04_web_nibss]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id1 INT = NULL,
    @rpt_tran_id INT = NULL
        

AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE  @report_result TABLE
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
		message_reason_code		VARCHAR (8), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),		
		settle_amount_impact	float,			
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
		tran_reversed			INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		extended_tran_type		CHAR (4),
                rdm_amount                      float,
                Reward_Discount                float,
                Addit_Charge                 DECIMAL(7,6),
                Addit_Party                 Varchar (28),
                Amount_Cap_RD               DECIMAL(9,0),
                Fee_Cap_RD               DECIMAL(9,0),
                Fee_Discount_RD          DECIMAL(9,7) ,
                Totalsgroup varchar (40),
                aggregate_column         VARCHAR(200),
                Unique_key varchar (200),
				tran_cash_req  float,
tran_cash_rsp  float,
        	tran_tran_fee_rsp  float,
			tran_currency_code      VARCHAR (50)
        
                     
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Host name.')
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
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		


		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 
    --EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	

	DECLARE  @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes,',')

    DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT


	IF(@report_date_start<> @report_date_end) BEGIN
	SELECT @first_post_tran_cust_id= MIN (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE Recon_business_date >= @report_date_start; 
	SELECT @last_post_tran_cust_id= MAX (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9))  WHERE Recon_business_date<=  @report_date_end;
	SELECT TOP 1 @first_post_tran_id=post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) WHERE datetime_req <=  @report_date_end  order by datetime_req DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
			SELECT @first_post_tran_cust_id= MIN (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE Recon_business_date >= @report_date_start; 
	SELECT @last_post_tran_cust_id= MAX (post_tran_cust_id) FROM  post_tran (NOLOCK, INDEX(ix_post_tran_9))  WHERE Recon_business_date<=  @report_date_end;
	SELECT TOP 1 @first_post_tran_id=post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) WHERE datetime_req <=  @report_date_end  order by datetime_req DESC
	END


	/*CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes*/
	-- Only look at 02xx messages that were not fully reversed.
	
INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
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
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				isnull(t.payee,0),
				t.extended_tran_type,
                                ISNULL(y.rdm_amt,0),
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                c.totals_group,
                  t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(ISNULL(y.rdm_amt,0))) as varchar(12)),
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
				
				((c.post_tran_cust_id >= @rpt_tran_id1) 
                                 or (c.post_tran_cust_id < @rpt_tran_id1 and c.post_tran_cust_id >= @rpt_tran_id and t.message_type <> '0420')
                                )--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(t.message_type IN ('0100','0200', '0400', '0420') )
 				 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
			
				--AND 
				---(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
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
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                 and c.merchant_type not in ('5371')
                 and ISNULL(y.rdm_amt,0) <>0
                 AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND t.sink_node_name+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4')
                 and c.totals_group not in ('VISAGroup')
                AND
            LEFT( c.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB' ---AND not( t.sink_node_name   LIKE 'SB%')


	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
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
				isnull(t.payee,0),
				t.extended_tran_type,
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
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
				
				t.tran_completed = 1
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(t.message_type IN ('0100','0200', '0400', '0420') )
				---(
				---(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				
				--AND 
				---(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
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
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                                and c.merchant_type not in ('5371')
                                AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND t.sink_node_name+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4')
                                and c.totals_group not in ('VISAGroup')
                AND
              LEFT( c.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB' --AND not( t.sink_node_name   LIKE 'SB%')

				
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
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

		-- Get pan and pan_encrypted from @report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					@report_result
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
						@report_result
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


create table #temp_table_1
(aggregate_column varchar(200), counts float )
insert into #temp_table_1 select aggregate_column, count(aggregate_column) from @report_result
group by aggregate_column

update @report_result
set tran_type_desciption = tran_type_desciption+ '_M'
where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)

		
	create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from @report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


		
	SELECT 
			* 
	FROM 
			@report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where    

          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc')
          and unique_key  IN (SELECT unique_key FROM #temp_table))
          

                                       
      
         
      
      -- and (source_node_name = 'SWTNCS2src' and sink_node_name = 'ASPPOSLMCsnk')
	ORDER BY 
			source_node_name, datetime_req, message_type
END











































































































