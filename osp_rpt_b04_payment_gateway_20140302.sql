USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_payment_gateway_2]    Script Date: 02/28/2014 17:08:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER                                                                 PROCEDURE [dbo].[osp_rpt_b04_payment_gateway_2]
	@StartDate	    VARCHAR(30),	-- yyyymmdd
	@EndDate	    VARCHAR(30),	-- yyyymmdd
	@SourceNodes	    VARCHAR(40),
   	@terminal_IDs         VARCHAR(40),
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
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	BEGIN TRANSACTION;

	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255) NULL,	
		StartDate					VARCHAR(30),  
		EndDate						VARCHAR(30),
		pan							VARCHAR (19), 
		terminal_id			VARCHAR(20),
		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 		
		TranID					INT, 
		prev_post_tran_id			INT, 
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
		settle_nr_decimals			INT,
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
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		totals_group			varchar(12),
                extended_tran_type            char (4)          
	)			

	IF (@Terminal_IDs IS NULL or Len(@Terminal_IDs)=0)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Terminal ID parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END
    
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
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
	EXECUTE osp_rpt_get_dates_2 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END
	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)
	
	SELECT @rpt_tran_id = (SELECT MIN(first_post_tran_cust_id)  FROM post_normalization_session (NOLOCK) WHERE datetime_creation  >= DATEADD(dd,-1,@report_date_start))
	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM @report_result
		RETURN 1
	END
		
	DECLARE @list_of_terminal_IDs TABLE  (terminal_ID	VARCHAR(30)) 
	INSERT INTO  @list_of_terminal_IDs  SELECT part as 'TerminalID' FROM usf_split_string(@terminal_IDs,',')

	DECLARE @list_of_BINs TABLE  (BIN	VARCHAR(30)) 
	INSERT INTO  @list_of_BINs SELECT part as 'BIN' FROM usf_split_string(@BINs,',') 
	
	DECLARE @list_of_source_nodes TABLE  (source_node	VARCHAR(30)) 

	INSERT INTO  @list_of_source_nodes SELECT part as 'source_node' FROM usf_split_string(@SourceNodes,',')
	
	DECLARE  @list_of_sink_nodes TABLE (sink_node	VARCHAR(30)) 
	
	INSERT INTO  @list_of_sink_nodes SELECT part AS 'sink_node' FROM usf_split_string(@SinkNode,',')
	
	DECLARE @sink_node_name VARCHAR(2000)
	DECLARE @sink_node_name_new  VARCHAR(2000)
	
	DECLARE @list_of_bank_codes TABLE  (bank_code	VARCHAR(30)) 
	
	DECLARE sink_node_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT sink_node FROM @list_of_sink_nodes
	
	OPEN  sink_node_cursor;
	FETCH NEXT FROM sink_node_cursor INTO @sink_node_name;
	
	WHILE (@@FETCH_STATUS=0)
	  BEGIN
	
		SET @sink_node_name_new  =  substring(@sink_node_name,4, 3) 	  
	    INSERT INTO @list_of_bank_codes(bank_code) VALUES (@sink_node_name_new) 
		FETCH NEXT FROM sink_node_cursor INTO @sink_node_name;
	END
		
	CLOSE  sink_node_cursor;
	DEALLOCATE sink_node_cursor 


	INSERT
			INTO @report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			CASE WHEN @show_full_pan=1 THEN dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan)
					ELSE pan
				END
				 AS pan,
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
			c.pan_encrypted,
			t.from_account_id,
			t.to_account_id,
			t.payee,
			c.totals_group,
                        isnull(t.extended_tran_type,'0000')	
	FROM
			post_tran t (NOLOCK)
			 JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			 AND 
		 (c.post_tran_cust_id >= @rpt_tran_id) AND  (t.recon_business_date >=  DATEADD(D, 0, DATEDIFF(D, 0, @report_date_start)) AND t.recon_business_date <= DATEADD(D, 0, DATEDIFF(D, 0, @report_date_end)) )
	WHERE 		
			t.tran_completed = 1
	
			AND
			t.tran_postilion_originated = 0
			AND
			(
			(
			tran_type = '50' --this won't work for Autopay CCLoad cos the intrabank trans are 00
			AND
			sink_node_name NOT IN ('CCLOADsnk','GPRsnk') AND source_node_name <>'CCLOADsrc'
			AND 
			t.tran_completed = 1 
		  	AND
           	       	(
			 CHARINDEX ( LEFT(c.terminal_id,4), '3IGW 3CCW 3IBH 3CPD 3011') >0             
			OR
           		CHARINDEX ( LEFT(c.terminal_id,5),  '3ADPS'   ) 
                        OR
                        c.terminal_id  IN ('3EPY0701', '3IPD0010','3IPDTROT', '3VRV0001','3IGW0010','3SFX0014'  )
			OR
		        (c.terminal_id = '3BOL0001' and t.extended_tran_type = '8502')
			OR
			
			 CHARINDEX ( LEFT(c.terminal_id,4), '3SFA') >0
			)
			)OR
			 CHARINDEX ( LEFT(c.terminal_id,4), '3CPD') >0 and tran_type = '00'
			OR
			(
			
			CHARINDEX ( LEFT(c.terminal_id,7), '3IPDFDT 3QTL002') >0 AND message_type in ('0200','0420') and source_node_name <>'VTUsrc'
			
			)
			        		         
         		
			AND 
			( 
		    (@SinkNode IS NULL OR LEN(@SinkNode) = 0) 
		        OR 
		    (t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)) 
			OR
			(SUBSTRING(t.sink_node_name,4,3) IN (SELECT bank_code FROM @list_of_bank_codes))--and source_node_name NOT IN (SELECT source_node FROM @list_of_source_nodes))
			OR
			(LEFT(pan,6) IN (SELECT BIN FROM @list_of_BINs)AND source_node_name NOT IN (SELECT source_node FROM @list_of_source_nodes))
			OR
			LEFT(pan,6) = '628051' and (SUBSTRING(c.totals_group,1,3) IN (SELECT bank_code FROM @list_of_bank_codes)) and source_node_name NOT IN (SELECT source_node FROM @list_of_source_nodes)
			
			) 
            AND
            LEFT( c.source_node_name,2) <> 'SB'
             AND
            LEFT(t.sink_node_name,2)<>'SB'
			
				
	


IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--
	  IF (@show_full_pan=1)
	  BEGIN

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B04 Report'

		-- Get pan and pan_encrypted from @report_result and post_tran_cust using a cursor
		DECLARE pan_cursor CURSOR FORWARD_ONLY
		FOR
			SELECT
					pan,
					pan_encrypted
			FROM
					@report_result
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
						@report_result
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
	
	END		
	SELECT *
	FROM
			@report_result
	ORDER BY 
			datetime_req
COMMIT TRANSACTION;
END





