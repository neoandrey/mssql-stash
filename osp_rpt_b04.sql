SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO




ALTER    PROCEDURE [dbo].[osp_rpt_b04]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(40),
	@SourceNodes	VARCHAR(255),	-- Seperated by commas
    @Retention_Data VARCHAR (10),
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
		recon_business_date			DATETIME, 	
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19),
		terminal_id				CHAR (8), 
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
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (60),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),
		tran_reversed			INT,		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		payee				char(25),
		retention_data			varchar(999),  
		totals_group			varchar(40)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
		
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	*/

	--DECLARE @report_date_start		DATETIME
	--DECLARE @report_date_end		DATETIME
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
	
	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

        CREATE TABLE #list_of_retention_data (Retention_Data VARCHAR(30)) 
	
	INSERT INTO  #list_of_retention_data EXEC osp_rpt_util_split_nodenames @Retention_Data

	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				t.recon_business_date,--oremeyi added this 24/02/2009
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
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
				
				t.tran_reversed,
				dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,


				dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				t.from_account_id,
				t.payee,
				isnull(tt.retention_data,0),
				c.totals_group
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
                left join 
                post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                          tt.tran_postilion_originated = 1
                                          and t.tran_nr = tt.tran_nr)
	WHERE 			
				c.post_tran_cust_id >= @rpt_tran_id	
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
				t.message_type IN ('0200', '0220', '0400', '0420') 
				AND
				t.tran_type IN ('01')
				AND 
				(substring (c.totals_group,1,3)in (select substring (Sink_Node,4,3) from #list_of_sink_nodes) and not (t.Sink_node_name in ('ESBCSOUTsnk') and tt.retention_data is not null)-- IN (SELECT sink_node FROM #list_of_sink_nodes)
                OR (substring(tt.retention_data,1,4) in (SELECT Retention_Data FROM #list_of_Retention_Data)  and @Retention_data is not null))
				AND
				c.source_node_name  NOT LIKE '%ASP%'
				AND 
				c.source_node_name  NOT LIKE 'TSS%'
				AND
				c.source_node_name  NOT LIKE 'GPR%'
				AND
				c.source_node_name  NOT LIKE '%CTL%'
				AND

				c.source_node_name  NOT LIKE 'CCLOAD%'
				AND
				c.source_node_name  NOT LIKE '%FUEL%'

				AND
				c.source_node_name  NOT LIKE '%TELCO%'
                AND c.source_node_name  NOT LIKE '%TPP%'
                                AND
                                c.source_node_name  NOT IN ('SWTMEGAsrc')
				AND
				t.Sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'SWTCTLsnk','VTUsnk''SWTMEGAsnk','VAUMOsnk')
				AND
				(terminal_id not like '2%')

                                AND
                                c.source_node_name  NOT LIKE 'SB%'
                                AND
                                t.sink_node_name  NOT LIKE 'SB%'
                                --and c.source_node_name not in ('SWTWEMSBsrc')
			

				
				
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
				datetime_tran_local, source_node_name
END






















































































GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

