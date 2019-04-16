SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

















ALTER                      PROCEDURE osp_rpt_b04_pos_acquirer_CUP_source_node
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
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
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	CREATE TABLE #list_of_AcquiringID (AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringID SELECT part FROM dbo.usf_split_string(@AcquiringID, ',');

        CREATE TABLE #list_of_CBN_Code (CBN_Code CHAR(3)) 
	
	INSERT INTO  #list_of_CBN_Code  SELECT part FROM dbo.usf_split_string(@CBN_Code, ','); 


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
                        c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
                        t.acquiring_inst_id_code,
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
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        LEFT(c.terminal_id,1) = '2'
                        
	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B06 Report'

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END




























GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

