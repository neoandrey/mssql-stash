if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[osp_rpt_b04_web_pos_acquirer]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)
drop procedure [dbo].[osp_rpt_b04_web_pos_acquirer]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO



ALTER                                    PROCEDURE osp_rpt_b04_web_pos_acquirer_all
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
        @SinkNodes VARCHAR(255),
	@show_full_pan	INT
AS
BEGIN
	-- The B04 report uses this stored proc.
	
	CREATE TABLE #report_result
	(
		--Post_tran_id			INT,
		TranID					INT,
		Warning				VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30), 
		SinkNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (30), 
		client_id				INT,
		merchant_acct_nr			VARCHAR(60),
		acquiring_inst_id_code		VARCHAR(30),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code		CHAR (15),	 
		card_acceptor_name_loc		CHAR (255), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type			CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		--TranID			INT,
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
		structured_data_req		VARCHAR(512),
		tran_reversed			INT	
		--to_account_id			VARCHAR(512)
		
	)



	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)

	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	
	IF (@StartDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @StartDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the StartDate parameter to DateTime
		-- The TIME portion of the StartDate should be 00:00:00
		SET @yy = CAST(SubString(@StartDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@StartDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@StartDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	    INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)

	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_start = DateAdd(yyyy, @yy - 1900, 0) 

	SET @report_date_start = DateAdd(m, @mm - 1, @report_date_start) 

	SET @report_date_start = DateAdd(d, @dd - 1, @report_date_start) 
			
	IF (@EndDate IS NULL)		-- Then use yesterday the default value

	BEGIN

		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @EndDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the EndDate parameter to DateTime
		-- The TIME portion of the EndDate should be 23:59:59
		SET @yy = CAST(SubString(@EndDate, 1, 4) AS INT)
		SET @mm = CAST(SubString(@EndDate, 5, 2) AS INT)
		SET @dd = CAST(SubString(@EndDate, 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid year specified.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Invalid month specified.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	 	INSERT INTO #report_result (Warning) VALUES ('Invalid day specified.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	
	SET @report_date_end = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_end = DateAdd(m, @mm - 1, @report_date_end) 
	SET @report_date_end = DateAdd(d, @dd - 1, @report_date_end) 
	SET @report_date_end = DateAdd(ss,-1,DateAdd(d,1,@report_date_end)) 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

	INSERT
				INTO #report_result
	SELECT
				--distinct c.Post_tran_cust_id,
				distinct t.post_tran_cust_id as TranID,
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				pthc.participant_client_id,
				ISNULL(account_nr,'not available'),
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VIOD'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,0),
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
				t.tran_reversed
				--t.to_account_id
				--distinct Post_tran_id
	FROM
				post_tran t (NOLOCK), post_tran_cust c (NOLOCK), 
				post_terminal_has_client pthc (NOLOCK), post_bank_account pba(NOLOCK),
				tbl_merchant_category m (NOLOCK)
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.merchant_type *= m.category_code
				AND
				c.card_acceptor_id_code *= pba.inst_code
				AND
				c.terminal_id *= pthc.terminal_id
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND 
				t.tran_postilion_originated = 1 
                                AND
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				t.message_type IN ('0200', '0220', '0400', '0420') 
				AND
					(
					(LEFT(c.terminal_id,4)= '3IWP') OR
					(LEFT(c.terminal_id,4)= '3ICP') OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) =  '5') 
										)
				AND
				source_node_name NOT IN ('CCLOADsrc','GPRsrc','VTUsrc')	
				AND
				t.tran_type NOT IN ('31')
				AND
				t.to_account_id IS NULL
				AND
				((t.structured_data_req IS NOT NULL and t.structured_data_req NOT LIKE '218PrepaidMerchandise%')
				--OR
				--(t.structured_data_req IS NULL and t.to_account_id IS NULL)
				OR
				(t.structured_data_req IS NULL))
				       AND t.extended_tran_type IS NOT NULL
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
			* 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END




























GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


