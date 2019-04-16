tran_type_descriptionUSE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_mobility_2016work]    Script Date: 11/22/2016 08:57:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE[dbo].[osp_rpt_b04_mobility_2016work]
	@StartDate	    CHAR(8),	-- yyyymmdd
	@EndDate	    CHAR(8),	-- yyyymmdd
	@SourceNodes	    VARCHAR(40),
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

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255) NULL,	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
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
		rsp_code_description VARCHAR (60),
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
		pan_encrypted				CHAR(18),
		payee					CHAR(25),
		extended_tran_type			CHAR(4),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		totals_group			varchar(12),
		prev_tran_approved		INT,
		channel					VARCHAR (255)                 
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

        CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
			

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs

	INSERT
			INTO #report_result

	SELECT	


			NULL AS Warning,

			@StartDate as StartDate,  
			@EndDate as EndDate,
			 CASE WHEN  @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
			 ELSE dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) 
			 END AS pan,
			t.terminal_id,
			t.card_acceptor_id_code, 

			t.card_acceptor_name_loc, 
			t.acquiring_inst_id_code,
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
			t.from_account_id,  
			t.to_account_id,  
			1,
			--RIGHT(CAST(t.structured_data_req AS VARCHAR(255)), 6),
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
			tran_type_description = CASE WHEN  
			((substring(t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))
			or ((substring(t.totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_node)))) and t.sink_node_name = 'SWTWEBUBAsnk'
			AND substring(t.sink_node_name,4,3) <> substring(t.source_node_name,4,3) 
			then 'Initiated'
	 
			WHEN (substring(t.source_node_name,4,3) in (select substring(source_node,4,3) from #list_of_source_nodes)
			AND substring(t.sink_node_name,4,3) <> substring(t.source_node_name,4,3))
			THEN 'Received'
			
			WHEN substring(t.totals_group,1,3) = substring(t.source_node_name,4,3) 
			THEN 'Intrabank'
			
			ELSE dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type)
			END,
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,

			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.tran_reversed,
			t.pan_encrypted,
			payee,
			extended_tran_type,
			from_account_id,
			to_account_id,
			totals_group,
			prev_tran_approved,
			channel  = CASE   WHEN  source_node_name  IN  ('GPRsrc','VTUsrc','VTUSTOCKsrc')  THEN  'Recharge Transactions'  
WHEN  tran_type  =  '40'  THEN  'Cardholder Account Transfer Transactions'  
WHEN  source_node_name  IN  ('GPRsrc','VTUsrc','VTUSTOCKsrc')  AND  tran_type  =  '00'  THEN  'Purchases'  
WHEN  LEFT(terminal_id,1)    ='1'  AND  (  extended_tran_type  !='6110'  OR  extended_tran_type  IS  NULL)  THEN    'ATM Transfer Transactions'
WHEN  LEFT(terminal_id,1)  ='2'  THEN  'POS Transfer Transactions'  
WHEN  terminal_id=  '3BOL0001'  THEN  'Web ( Quickteller Website) Transfer Transactions'  
WHEN  LEFT(terminal_id,4)  IN  ('4QTL',  '4IQT','4AQT','4WQT','4BQT','4JQT')  THEN  'QuicktellerMobile Transfer Transactions'
WHEN  extended_tran_type='6110'  THEN  'ATM Cardless-Transfer Transactions'  
ELSE  'Mobile Transfer Transactions'  
END
	FROM
			 post_tran_summary t (NOLOCK)	
	
WHERE 			
	t.tran_completed = 1 
	
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 0 
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN (SELECT part FROM usf_split_string('50,00,40', ','))		
			
			AND
			(
			(t.terminal_id like '1%')
			AND
			(payee not like '%62805150%' OR payee is null)
			AND substring(t.sink_node_name,4,3) not like 'TSS%'
			)
			AND 
			t.terminal_id not like '4GLO%' 	
			AND
			(
			 (
			t.source_node_name  like 'TSS%'
		
			AND
			(
		(substring(t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))
	
or ((substring(t..totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)) and t.sink_node_name = 'SWTWEBUBAsnk'
)
	))
				or ( t.source_node_name  like 'TSS%' and
					(substring(t.source_node_name,4,3) in (select substring(source_node,4,3) from #list_of_source_nodes))
					
			)
				 )
				--(
				
	
				--	OR 
				--	((t.source_node_name like 'TSS%' or t.source_node_name like 'SWT%') and t.sink_node_name not like 'TSS%'
				--	AND 
				--	substring(t.source_node_name,4,3) = substring(t.sink_node_name,4,3)
				--	)
				--	)
			
			 

			
				AND
				source_node_name NOT IN ( SELECT part FROM usf_split_string('CCLOADsrc,GPRsrc,VTUsrc,SWTMEGAsrc', ','))	
            AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  not in ('WUESBPBsnk')
             and (t.extended_tran_type <> '8234' or t.extended_tran_type is null)
				
option(recompile)	
			IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
	SELECT *
	FROM
			#report_result 
where
(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
	ORDER BY 
			datetime_req
END




/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer]    Script Date: 03/16/2016 18:14:22 ******/
SET ANSI_NULLS ON




