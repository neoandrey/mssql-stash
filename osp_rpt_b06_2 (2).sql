USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_2]    Script Date: 07/23/2014 16:58:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER       PROCEDURE [dbo].[osp_rpt_b06_2]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@terminalID		VARCHAR(40),	
	@show_full_pan	 BIT,
	@TotalsGroup    VARCHAR (512),
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	BEGIN TRANSACTION;

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE @report_result TABLE 
	(
		Warning						VARCHAR (255),	
		StartDate					VARCHAR(30),  
		EndDate						VARCHAR(30),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     VARCHAR(30), -- oremeyi added this
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID						INT, 
		prev_post_tran_id			INT, 
		system_trace_audit_nr		CHAR (6), 
		message_reason_code			CHAR (4), 
		retrieval_reference_nr		CHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 			
		settle_currency_code		CHAR (3), 	
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (60),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999),
		totals_group				Varchar(40)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
    
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
	
	SELECT @StartDate = REPLACE(@StartDate, '-', '');
	SELECT @EndDate = REPLACE(@EndDate, '-', '');
	
	SELECT @StartDate = REPLACE(@StartDate, '.', '');
	SELECT @EndDate = REPLACE(@EndDate, '.', '');
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

  
	
	 SELECT @rpt_tran_id = (SELECT MIN(first_post_tran_cust_id)  FROM post_normalization_session (NOLOCK) WHERE datetime_creation  >= DATEADD(dd,-1,@report_date_start))
	

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM @report_result
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM @report_result
		RETURN 1
	END

      DECLARE @list_of_source_nodes TABLE  (source_node	VARCHAR(30)) 
	
	INSERT INTO  @list_of_source_nodes SELECT part as 'source_node' FROM usf_split_string(@SourceNode,',')
	
	DECLARE @list_of_terminalIds TABLE  (terminalID	VARCHAR(30)) 
	
	INSERT INTO  @list_of_terminalIds SELECT part as 'terminalID' FROM usf_split_string(@terminalID,',')
	
	DECLARE @terminal VARCHAR(2000)
	DECLARE @terminal_new  VARCHAR(2000)

	DECLARE @list_of_terminals TABLE  (terminal	VARCHAR(30)) 
	
	DECLARE terminal_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT terminalID FROM @list_of_terminalIds
	
	OPEN  terminal_cursor;
	FETCH NEXT FROM terminal_cursor INTO @terminal;
	
	WHILE (@@FETCH_STATUS=0)
	  BEGIN
	
		SET @terminal_new  =   substring(@terminal,1,5);  
	        INSERT INTO @list_of_terminals(terminal) VALUES (@terminal_new) 
		FETCH NEXT FROM terminal_cursor INTO @terminal;
	END
		
	CLOSE  terminal_cursor;
	DEALLOCATE terminal_cursor 
	
	
	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/20098
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
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data,
			post_tran_cust_id 
			
			INTO #temp_results_table
	FROM
			post_tran t (NOLOCK)	

	WHERE 		
			
			(t.recon_business_date >= @report_date_start AND  t.recon_business_date <= @report_date_end) 
            AND 
			t.tran_completed = 1
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')	
			
           AND (t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk','SWTSPTsnk') AND CHARINDEX(t.sink_node_name, 'TPP')<1 AND LEFT(t.sink_node_name,2)<>'SB')
		
	
        INSERT
			INTO @report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
		    pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			settle_amount_req, 
            settle_amount_rsp, 
			settle_tran_fee_rsp, 
			 TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
            settle_amount_impact,
            rsp_code_description,
			settle_nr_decimals,
			currency_alpha_code,
			currency_name,
			tran_type_description,
			
			t.tran_reversed,
			isPurchaseTrx,
			isWithdrawTrx,
			isRefundTrx,
			isDepositTrx,
			isInquiryTrx,
			isTransferTrx,
			isOtherTrx,
			t.retention_data,
			c.totals_group
	FROM
			#temp_results_table t (NOLOCK)
			 JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id  AND c.post_tran_cust_id >= @rpt_tran_id)
			

	WHERE 		
			
	
			((  c.source_node_name in (select source_node from @list_of_source_nodes) OR (LEFT (c.terminal_id,5) in (select terminal from @list_of_terminals) AND LEFT(c.terminal_id,2)= '1S')
                        --OR
                        --(substring (c.terminal_id,2,3)=substring (@terminalID,3,3) AND c.terminal_id not like '1S%'  and c.source_node_name = 'SWTMEGAsrc')
			)AND LEFT(c.source_node_name,2)<>'SB') 
				AND
			(LEFT(terminal_id,1)<>'2') 
         
          
	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
	
	
	IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			@report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
COMMIT TRANSACTION;
END





























































































































