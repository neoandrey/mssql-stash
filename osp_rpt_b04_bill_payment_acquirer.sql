SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO































ALTER                                                   PROCEDURE [dbo].[osp_rpt_b04_bill_payment_acquirer]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@AcquiringBIN		VARCHAR(25),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id VARCHAR(2000) = NULL

AS
BEGIN
	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30), 
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
		structured_data_req		VARCHAR (510),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		Network_ID			CHAR(512),
		bank_institution_name		varchar(50),
		bank_card_type		varchar(50)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	
	

	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE  @Tempreport_date_start DATETIME
	DECLARE  @Tempreport_date_end DATETIME
	
	   IF (@StartDate IS NULL OR @StartDate ='') 
      BEGIN 
		SELECT @StartDate = REPLACE(SUBSTRING(CONVERT(VARCHAR (2000),DATEADD(DD,-1, GETDATE()), 102), 0, 12), '.', ''); 
		SELECT @EndDate =REPLACE(SUBSTRING(CONVERT(VARCHAR (2000),DATEADD(DD,-1, GETDATE()), 102), 0, 12), '.', ''); 
      END
      	    SELECT @report_date_start = CONVERT(DATETIME, @StartDate, 102);
		SELECT @report_date_end =  CONVERT(DATETIME, @EndDate, 102); 
		
    SELECT  @Tempreport_date_start	=cast(( @report_date_start) as varchar(30));
    SELECT  @Tempreport_date_end	=cast(( @report_date_end) as varchar(30));
	
	
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

	SET @StartDate = CONVERT(VARCH(8), @report_date_start, 112)
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

	-- Only look at 02xx messages that were not fully reversed.

        CREATE TABLE #AcquiringBin (AcquiringBIN VARCHAR(8)) 
	INSERT INTO  #AcquiringBin EXEC osp_rpt_util_split_nodenames @AcquiringBIN
	
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
				cast((t.datetime_req) as varchar (30)), 
				--t.extended_tran_type,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				cast((t.datetime_tran_local) as varchar (30)), 
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
				1,
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,

				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				payee,
				d.bank_institution_name,
				b.bank_card_type
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				LEFT JOIN acquirer_institution_table d (NOLOCK) ON (t.acquiring_inst_id_code = d.acquirer_inst_id)
				LEFT JOIN bank_bin_table b (NOLOCK) ON (substring (c.pan ,1,6) = b.bin)
	WHERE 			
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'
				AND 
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 	
				AND
				( 
				(t.sink_node_name IN ('PAYDIRECTsnk') or ((payee like '%62805150' or payee like '62805150%' or c.source_node_name = 'BILLSsrc' ) and t.sink_node_name <> 'BILLSsnk' and c.card_acceptor_id_code like 'QuickTeller%'))
				OR 
				(c.terminal_id IN ('3FTL0001','3UDA0001','3FET0001','3FTH0001','3UMO0001','3PLI0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001','2ONT0001','3ASI0001','4QIK0001','4MBX0001','3NCH0001','4FBI0001','3UTX0001','4TSM0001','4FMM0001','3EBM0001','4FDM0001','3HIB0001','4RBX0001') and t.sink_node_name <> 'BILLSsnk')
				OR
                                (c.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk')
                                OR
				(c.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				)
				AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')
				AND
				t.acquiring_inst_id_code  IN (SELECT AcquiringBIN FROM #AcquiringBin)
				AND
				t.tran_type NOT IN ('31', '39', '32')

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
				datetime_tran_local, retrieval_reference_nr, source_node_name
END















































































































































GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

