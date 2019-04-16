USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_mobility]    Script Date: 11/16/2016 13:32:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



















CREATE procedure[dbo].[osp_rpt_b04_mobility]
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

	-- The B06 report uses this stored prot.


	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'		

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255) NULL,	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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
		rsp_code_description		VARCHAR (60),
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
		prev_tran_approved		INT                
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
			
	--CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 
	--INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs



	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs
	
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

	INSERT
			INTO #report_result

	SELECT	


			NULL AS Warning,

			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
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
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 

			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.from_account_id,  
			t.to_account_id,  
			RIGHT(CAST(t.structured_data_req AS VARCHAR(255)), 6),
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
			t.tran_reversed,
			t.pan_encrypted,
			payee,
			extended_tran_type,
			from_account_id,
			to_account_id,
			totals_group,
			prev_tran_approved
	FROM
			 (
			 SELECT * FROM post_tran_summary pt JOIN
			 (SELECT [DATE]rec_bus_date FROM dbo.get_dates_in_range(@report_date_start,@report_date_end))r
			ON   pt.recon_business_date = r.rec_bus_date
			 )	t		
			
	
WHERE 			
	
-
			t.tran_completed = 1
			  AND
			  post_tran_id NOT IN (
				SELECT tbl.post_tran_id FROM tbl_late_reversals tbl (NOLOCK) JOIN
				post_tran_summary pts ON tbl.recon_business_date >= @report_date_start 
				AND
				tbl.tran_nr  = pts.tran_nr 
				 AND
				 datepart(D,tbl.rev_datetime_req) - datepart(D, tbl.trans_datetime_req )>1

				 AND 
				 tbl.retrieval_reference_nr =   pts.retrieval_reference_nr

			  ) 
	     
			AND
			t.tran_postilion_originated = 0 
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('50','00','40')
			AND	
           		(
			(t.terminal_id like '4%' and card_acceptor_name_loc not like '%MCN%'  and (payee not like '%62805150%'OR payee is null) and t.source_node_name <> 'BILLSsrc')
			OR
			((t.terminal_id like '2%') and t.tran_type <> '00' and (payee not like '%62805150%' OR payee is null) and t.source_node_name <> 'BILLSsrc')
			OR           		
			(
			(t.terminal_id like '1%')
			AND
			(payee not like '%62805150%' OR payee is null)
			)
			)
			AND 
			t.terminal_id not like '4GLO%' 	
                         	 
				
			AND 
			( 
			(substring(t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))
			AND 
			(
				((substring(t.source_node_name,4,3) <> substring(t.totals_group,1,3))
				and t.sink_node_name <> '%CC%'
				
				)
				OR
				((substring(t.source_node_name,4,3) = substring(t.totals_group,1,3)
				and t.source_node_name not like 'TSS%'))
				
			)-- intrabank transactions
			--OR
				--t.acquiring_inst_id_code IN (SELECT acquiring_inst_id_code FROM #list_of_BINs)
			)
			AND
				source_node_name NOT IN ('CCLOADsrc','GPRsrc','VTUsrc','SWTMEGAsrc')	
            AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  not in ('WUESBPBsnk')
             and (t.extended_tran_type <> '8234' or t.extended_tran_type is null)
             option (recompile)

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
	SELECT *
	FROM
			#report_result
	ORDER BY 
			datetime_req
END








































































































































