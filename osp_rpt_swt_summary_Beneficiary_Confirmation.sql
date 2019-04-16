USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_swt_summary_Beneficiary_Confirmation]    Script Date: 07/15/2016 18:41:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER                                                PROCEDURE  [dbo].[osp_rpt_swt_summary_Beneficiary_Confirmation]--oremeyi modified the previous. this is v7
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@report_date_start	DATETIME,
	@report_date_end	DATETIME,
	@show_full_pan	 BIT

AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	SET NOCOUNT ON

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (510),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		Scheme_type                     INT,
		pan							VARCHAR (38), 
		terminal_id                     CHAR (16), -- oremeyi added this
		acquiring_inst_id_code		CHAR(24),
		terminal_owner			VARCHAR(40), -- added this in v3
		source_node_name		VARCHAR (80), --- oremeyi added this
  		card_acceptor_id_code		CHAR (30), 
		card_acceptor_name_loc		CHAR (80), 
		sink_node_name				VARCHAR (80), 
		tran_type					CHAR (4), 
		rsp_code_rsp				CHAR (4), 
		message_type				CHAR (8), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT,
		post_tran_cust_id			INT, 
		system_trace_audit_nr		CHAR (12), 
		message_reason_code			CHAR (8), 
		retrieval_reference_nr		CHAR (24), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (4), 
		to_account_type				CHAR (4), 
		receiving_inst_code		CHAR (12),		
		settle_currency_code		CHAR (6), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (120),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (6),
		currency_name				VARCHAR (40),
		tran_type_description		VARCHAR (500),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		totals_group				VARCHAR (24),
        extended_tran_type VARCHAR (4),
        to_account_id				VARCHAR (24), 
        payee						VARCHAR (120)
	)			

	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(100)
	
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

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	;WITH tss_sink_table (post_tran_id,retrieval_reference_nr)
AS
(SELECT post_tran_id,retrieval_reference_nr FROM post_tran t  with (NOLOCK, INDEX(ix_post_tran_9)) 
  JOIN (	 SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]( @report_date_start, @report_date_end)
									)  r
					on 
					t.recon_business_date = r.recon_business_date 
					AND 
					t.tran_completed = 1
					AND 
					T.tran_type = '50'
					AND 
					t.sink_node_name LIKE 'TSS%'
					AND 
					t.tran_postilion_originated = 0
					AND
						t.rsp_code_rsp 	IN ('91', '68', '60')
						AND
			(
			  (t.message_type IN ('0200','0220','0600') AND t.tran_reversed IN (0, 1))
 			   OR
 			  ( t.message_type IN ('0400', '0420') AND tran_amount_rsp <> 0 )
 			  ) 
 			 	
JOIN
post_tran_cust c with (NOLOCK,INDEX(pk_post_tran_cust))
on t.post_tran_cust_id = c.post_tran_cust_id 
and c.terminal_id like '1%'
		 	AND
			c.terminal_id not LIKE '3IQT%'
			AND 
			c.terminal_id not LIKE '3AIM%'
			AND
			c.terminal_id not LIKE '3IBH%'
			--AND 
			---c.terminal_id not LIKE '3IDP%'
			AND
			c.terminal_id not LIKE '3IPT%'),
			
	tss_source_table (post_tran_id,retrieval_reference_nr )
AS		
(SELECT  post_tran_id,retrieval_reference_nr 
  FROM post_tran t  with (NOLOCK, INDEX(ix_post_tran_9)) 
  JOIN (	 SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)  r
					on 
					t.recon_business_date = r.recon_business_date 
					AND 
					t.tran_completed = 1
					AND 
					T.tran_type = '50'
					AND 
					t.tran_postilion_originated = 0
					AND
						
			(
			  (t.message_type IN ('0200','0220','0600') AND t.tran_reversed IN (0, 1))
 			   OR
 			  ( t.message_type IN ('0400', '0420') AND tran_amount_rsp <> 0 )
 			  ) AND
 			 	t.Sink_node_name <> 'CCLOADsnk' 
			AND
			t.Sink_node_name <> 'GPRsnk' 
			AND
			t.Sink_node_name <> 'VTUsnk' 
JOIN
post_tran_cust c with (NOLOCK,INDEX(pk_post_tran_cust))
on t.post_tran_cust_id = c.post_tran_cust_id 
AND Source_node_name like 'TSS%' 
and c.terminal_id like '1%'
		 	AND
			c.terminal_id not LIKE '3IQT%'
			AND 
			c.terminal_id not LIKE '3AIM%'
			AND
			c.terminal_id not LIKE '3IBH%'
			--AND 
			---c.terminal_id not LIKE '3IDP%'
			AND
			c.terminal_id not LIKE '3IPT%')
			
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			
		CASE 
           		 ---WHEN Source_node_name IN ('SWTUBAsrc','SWTFBNsrc', 'SWTZIBsrc', 'SWTUTBsrc', 'SWTSTBsrc', 'SWTGTBsrc', 'SWTPRUsrc', 'SWTOBIsrc', 'SWTCHBsrc', 'SWTWEMsrc', 'SWTAFRIsrc', 'SWTBONDsrc', 'SWTPLATsrc', 'SWTNATsrc', 'SWTGULFsrc', 'SWTFCMBsrc', 'SWTUBNsrc', 'SWTEIBsrc','SWTDBLsrc', 'SWTIBPsrc', 'SWTEIBsrc', 'SWTSBPsrc', 'SWTFBPsrc')and c.terminal_id like '1%' THEN '1'
			 WHEN Source_node_name like 'SWT%'and c.terminal_id like '1%'and Sink_node_name like 'TSS%' and c.terminal_owner  IS NOT NULL THEN 20
           		 ---WHEN Source_node_name like 'SWT%'and c.terminal_id like '1%'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') and c.terminal_owner  IS NOT NULL THEN 1
           		 --WHEN Source_node_name = 'SWTDBLsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 1
			 ---WHEN Source_node_name = 'SWTATMCsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 2
			 WHEN Source_node_name = 'SWTASPPOSsrc'and c.terminal_id like '2%'and Sink_node_name like 'TSS%' THEN 19
			 WHEN Source_node_name = 'SWTASPPOSsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 3
			 WHEN Source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc')and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3IWP%' THEN 4
			 WHEN Source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc')and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3ICP%' THEN 4
			 WHEN Source_node_name = 'SWTASPWEBsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '4GLO%'THEN 5
        		 --WHEN Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3IAP%'THEN 6
			 ---WHEN Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND (c.terminal_id like '3IAP%' or c.terminal_id like '3CPD%')THEN 6
			 WHEN Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND (c.terminal_id like '3IAP%')THEN 6
        		 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3IGW0001%'THEN 7
			 WHEN Source_node_name = 'SWTWEBFEEsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 8
			 WHEN Source_node_name like 'SWT%'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND (c.terminal_id like '3ADPS%' or c.terminal_id = '3UIB0001')THEN 9
			 WHEN Source_node_name like 'SWT%'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3011%'THEN 9
			 WHEN Source_node_name like 'SWT%'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3CPD%'THEN 9
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3IGW0006%'THEN 9
        		 WHEN Source_node_name = 'GPRsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 10
			 WHEN Source_node_name = 'CCLOADsrc' and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id not like '3IAP%' THEN 11
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3CCW%'THEN 12
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3IBH%'THEN 12
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3SFA%'THEN 23
			 WHEN Source_node_name = 'SWTASPPABsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 13
			 WHEN Source_node_name = 'SWTTELCOsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 14
			 WHEN Source_node_name = 'SWTFUELsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 15
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') AND c.terminal_id like '3ICP%'THEN 16
			 WHEN Source_node_name like 'SWT%'and c.terminal_id like '4%'and c.terminal_id not like '4GLO%' and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 17
           		 WHEN Source_node_name = 'VTUsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 18
			 WHEN Source_node_name = 'SWTASPWEBsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3BOL%'THEN 21
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name ='CCLOADsnk' AND c.terminal_id='3IPD0010' THEN 22
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3FTL0001%'THEN 21
			 WHEN Source_node_name = 'SWTASPPCPsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 3
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3UDA0001%'THEN 21
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3IPDFDT2%'THEN 24
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3FET0001%'THEN 24
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3FTH0001%'THEN 24
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3UMO0001%'THEN 24
			 WHEN Source_node_name = 'SWTASPIPDsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk')AND c.terminal_id like '3PLI0001%'THEN 24
			 WHEN Source_node_name = 'SWTEASYFLsrc'and Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'VTUsnk') THEN 25
			  
			 END Scheme_type,
 
			c.pan,
			c.terminal_id, -- oremeyi added this
			t.acquiring_inst_id_code, -- oremeyi added this
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
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.post_tran_cust_id,
			t.system_trace_audit_nr, 			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.receiving_inst_id_code,			
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
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			c.totals_group,
                        t.extended_tran_type,
                        t.to_account_id,
                        t.payee
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			AND 
			post_tran_id IN
		(SELECT  tsr.post_tran_id FROM 
tss_source_table tsr  JOIN tss_sink_table tsk
ON tsr.retrieval_reference_nr = tsk.retrieval_reference_nr) 	
OPTION (RECOMPILE, MAXDOP 8)
			

			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT *
	FROM
			#report_result
	
	ORDER BY 
			Scheme_type,source_node_name,terminal_id,datetime_req,system_trace_audit_nr
					OPTION (RECOMPILE, MAXDOP 8)
	

 
END






































































