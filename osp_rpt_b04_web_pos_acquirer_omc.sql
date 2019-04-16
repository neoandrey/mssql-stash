set fmtonly on 
   EXEC    [dbo].[osp_rpt_b04_web_pos_acquirer_omc] 
                @StartDate = NULL, 
                @EndDate = NULL, 
                @SourceNodes = N'MEGASPFBNsrc', 
                @IINs = NULL, 
                @AcquirerInstId = NULL, 
                @merchants = NULL, 
                @show_full_pan = NULL, 
                @report_date_start = NULL, 
                @report_date_end = NULL, 
                @rpt_tran_id = NULL 
 

set fmtonly off



USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2]    Script Date: 04/03/2014 18:08:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER   PROCEDURE [dbo].[osp_rpt_get_dates_2]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (8),
	@user_end_date		VARCHAR (8),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN

	DECLARE  @rpt_get_dates TABLE
	(
		node_name	VARCHAR (12)
	)

	DELETE FROM @rpt_get_dates

	DECLARE @yy INT
	DECLARE @mm INT
	DECLARE @dd INT

	SELECT @warning = NULL

	IF @default_date_method IS NULL
		SET @default_date_method = '<Not specified>'


	IF (@user_start_date IS NOT NULL OR @user_end_date IS NOT NULL)
	BEGIN

		--
		-- At least one date was specified, so use the specified dates
		--

		IF (@user_start_date IS NULL OR @user_end_date IS NULL)
		BEGIN
				SET @warning = 'Both the from- and to- dates should be specified.'
				RETURN
		END

		--
		-- Start date
		--

		EXECUTE osp_rpt_date_from_user @user_start_date, @report_date_start OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- End date
		--

		EXECUTE osp_rpt_date_from_user @user_end_date, @report_date_end OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- Some validation
		--

		IF (@report_date_end < @report_date_start)
		BEGIN
			SET @warning = 'The End Date must be AFTER the Start Date.'
			RETURN
		END
	END -- use specified dates

	ELSE

	IF (@default_date_method = 'Last business day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list VARCHAR (2048)
		SET @tmp_node_list = @node_name_list

		WHILE (@tmp_node_list IS NOT NULL)
		BEGIN
				INSERT INTO @rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list))
				SET @tmp_node_list = dbo.fn_rpt_remainelem(@tmp_node_list)
		END

		--
		-- We need to get the business date of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.settle_date)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM @rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'

			RETURN
		END

		--IF (@report_date_start
		SET @report_date_end = @report_date_start

        DECLARE @yesterday VARCHAR(30)
        SET @yesterday = DATEADD(D, -1, DATEDIFF(D, 0, GETDATE()))

        IF( @report_date_start >= @yesterday)
           BEGIN
             SET @report_date_start = @yesterday
             SET @report_date_end = @yesterday
           END

      --  SELECT @report_date_end AS 'report_date_end';
       -- SELECT @report_date_start AS 'report_date_start';

	END -- Last business day


        ELSE

	IF (@default_date_method = 'Two Days Ago')
	BEGIN
		

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -2, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -2, @report_date_end)
	END


	ELSE

	IF (@default_date_method = 'Previous week')
	BEGIN
		--
		-- Previous week
		-- We do not know if the week should start on a Sun, or a Mon. We, for now, consider a week as the last 7 days - up to yesterday
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -7, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
		--
		-- Previous day
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		--
		-- Today
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Previous month')
	BEGIN

		-- Previous month

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -DATEPART(dd, @report_date_end), @report_date_end)

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, - DATEPART(dd, @report_date_start) + 1, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, 1, @report_date_end)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Last closed batch end calendar day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list_2 VARCHAR (2048)
		SET @tmp_node_list_2 = @node_name_list

		WHILE (@tmp_node_list_2 IS NOT NULL)
		BEGIN
				INSERT INTO @rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list_2))
				SET @tmp_node_list_2 = dbo.fn_rpt_remainelem(@tmp_node_list_2)
		END

		--
		-- We need to get the calendar date of the end of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.datetime_end)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM @rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The calendar date of the last closed batch could not be determined.'

			RETURN
		END

		-- Get only the date portion of the datetime_begin
		SET @report_date_start = CONVERT(DATETIME, CONVERT(VARCHAR(10), @report_date_start, 101), 101)
		SET @report_date_end = @report_date_start

	END -- Last closed batch end calendar day

	ELSE

	BEGIN
		SET @warning = 'Invalid default date method specified: ' + @default_date_method
	END

	SET @report_date_end_next = DATEADD(dd, 1, @report_date_end)


END



USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_omc]    Script Date: 04/02/2014 10:16:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER                   PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_omc]
	@StartDate		VARCHAR (30),	-- yyyymmdd
	@EndDate		VARCHAR (30),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

		DECLARE @report_result  TABLE (

			Warning	VARCHAR(255), 
			StartDate	DATETIME,
			EndDate	DATETIME,
			source_node_name	varchar(30),
			pan	varchar(20),
			terminal_id	VARCHAR(10),
			acquiring_inst_id_code	varchar(20),
			terminal_owner	varchar(25),
			merchant_type	VARCHAR(10),
			card_acceptor_id_code	VARCHAR(20),
			card_acceptor_name_loc	VARCHAR(40),
			sink_node_name	varchar(30),
			tran_type	VARCHAR(5),
			rsp_code_rsp	VARCHAR(5),
			message_type	VARCHAR(10),
			datetime_req	DATETIME,
			tran_amount_req	FLOAT,
			tran_amount_rsp	FLOAT,
			settle_tran_fee_rsp	FLOAT	,
			TranID	BIGINT,
			prev_post_tran_id	BIGINT,
			system_trace_audit_nr	VARCHAR(10),
			message_reason_code	VARCHAR(10),
			retrieval_reference_nr	VARCHAR(15),
			datetime_tran_local	DATETIME,
			from_account_type	VARCHAR(10),
			to_account_type		VARCHAR(10),
			tran_currency_code	VARCHAR(10),
			settle_amount_req	float,
			tran_type_desciption	VARCHAR(100),
			rsp_code_description   VARCHAR(100),
			settle_nr_decimals	int,
			currency_alpha_code	VARCHAR(10),
			currency_name	VARCHAR(50),
			isPurchaseTrx	int	,
			isWithdrawTrx	int	,
			isRefundTrx	int	,
			isDepositTrx	int	,
			isInquiryTrx	int	,
			isTransferTrx	int	,
			isOtherTrx	int	,
			structured_data_req	text,
			tran_reversed	VARCHAR(10),
			payee		VARCHAR(30),
			extended_tran_type	VARCHAR(10),
			auth_id_rsp	VARCHAR(10),
			account_nr	VARCHAR(70),
			acquirer_ref_no	VARCHAR(50),
			service_restriction_code	VARCHAR(10),
			src	VARCHAR(10),
			pos_card_data_input_ability	VARCHAR(10),
			pos_card_data_input_mode	VARCHAR(10),
			ird		VARCHAR(10),
			fileid		VARCHAR(50),
			session_id	int	

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
	SET @date_selection_mode = 'Last business day'
	
    SELECT @StartDate = REPLACE(@StartDate, '-', '');
	SELECT @EndDate = REPLACE(@EndDate, '-', '');
	
	SELECT @StartDate = REPLACE(@StartDate, '.', '');
	SELECT @EndDate = REPLACE(@EndDate, '.', '');
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates_2 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	 SET @StartDate =  DATEADD(D, 0, DATEDIFF(D, 0, @report_date_start))
	 SET @EndDate =   DATEADD(D, 0, DATEDIFF(D, 0, @report_date_end))

	SELECT @rpt_tran_id = (SELECT MIN(first_post_tran_cust_id)  FROM post_normalization_session (NOLOCK) WHERE datetime_creation  >= DATEADD(dd,-1,@report_date_start))


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


	DECLARE @list_of_source_nodes  TABLE  (source_node	VARCHAR(MAX)) 
   
	INSERT INTO  @list_of_source_nodes  SELECT part AS 'source_node' FROM usf_split_string(@SourceNodes,',')
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(100)) 
	INSERT INTO  @list_of_IINs SELECT part AS 'iin' FROM usf_split_string( @IINs,',')
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE (card_acceptor_id_code	VARCHAR(100)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part AS 'card_acceptor_id_code' FROM usf_split_string( @merchants,',');

	--INSERT INTO  @list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
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
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code,
				 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.tran_amount_req
						ELSE t.tran_amount_rsp
					END
					, t.tran_currency_code ) AS settle_amount_req,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,

				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code)  AS currency_name,			
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
				account_nr,
				m.acquirer_ref_no,	
				service_restriction_code,
				SUBSTRING(service_restriction_code,1,1) as src,	
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				m.ird as ird,
				m.file_id as fileid,
				s.session_id
				
				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK),
				mcipm_extract_trans m (nolock),
				mcipm_extract_transmission s (nolock)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				and m.post_tran_id = t.post_tran_id
				and s.transmission_nr = m.transmission_nr
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				merchant_type,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				tran_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID,
				acquirer_ref_no,
				service_restriction_code,
				src,
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				ird,
				session_id,
				fileid
				
				
				
			
				
				
	FROM 
			@report_result
	ORDER BY 
			datetime_req
			
			

END

























