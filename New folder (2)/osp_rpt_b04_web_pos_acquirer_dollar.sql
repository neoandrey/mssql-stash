


alter                                         PROCEDURE osp_rpt_b04_web_pos_acquirer_dollar
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
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
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
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

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM @report_result
		RETURN 1
	END

*/
         DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes,',') ORDER BY part ASC

	DECLARE  @list_of_IINs  TABLE(IIN VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM usf_split_string(@IINs,',') ORDER BY part ASC 

	DECLARE  @list_of_card_acceptor_id_codes  TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants,',') ORDER BY part ASC
	-- Only look at 02xx messages that were not fully reversed.
	
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		

	IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	
	
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
				c.merchant_type,
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
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK) JOIN
				post_tran_cust c (NOLOCK)
				ON
				t.post_tran_cust_id = c.post_tran_cust_id
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
					c.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			
				
				t.tran_completed = '1'
				AND
				tran_currency_code = '840'

				AND
				t.tran_reversed = '0'
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))

				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
                		 AND 		   	
            			t.post_tran_cust_id >= @first_post_tran_cust_id
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END
































































































































GO