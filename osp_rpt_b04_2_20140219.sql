USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_2]    Script Date: 02/19/2014 08:20:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER   PROCEDURE [dbo].[osp_rpt_b04_2]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	BEGIN TRANSACTION;
	-- The B04 report uses this stored proc.

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30), 
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
		totals_group			varchar(40),
		tran_postilion_originated  varchar(5),
		tran_nr                    varchar(40)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM @report_result
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
	DECLARE @Tempreport_date_start DATETIME
    DECLARE @Tempreport_date_end DATETIME
    DECLARE @isDateNull INT
    SET @isDateNull = 0
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
	
	SELECT @StartDate = REPLACE(@StartDate, '-', '');
	SELECT @EndDate = REPLACE(@EndDate, '-', '');
	
	SELECT @StartDate = REPLACE(@StartDate, '.', '');
	SELECT @EndDate = REPLACE(@EndDate, '.', '');
	
	-- Calculate the report dates
	

	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
    
	--SELECT @StartDate AS 'START_DATE'
	--SELECT @EndDate AS 'END_DATE'
    --SELECT @report_date_start AS 'REPORT_START_DATE'
    --SELECT @report_date_end AS 'REPORT_END_DATE'

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


	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE @list_of_source_nodes TABLE  (source_node	VARCHAR(30)) 

	
	INSERT INTO  @list_of_source_nodes SELECT part as 'source_node' FROM usf_split_string(@SourceNodes,',')
	
	DECLARE @list_of_sink_nodes TABLE  (sink_node	VARCHAR(30)) 
	
	INSERT INTO  @list_of_sink_nodes SELECT part AS 'Sink_Node' FROM usf_split_string(@SinkNodes,',')
	
	
	
	DECLARE @sink_node_name VARCHAR(2000)
	DECLARE @sink_node_name_new  VARCHAR(2000)
	
	DECLARE @list_of_bank_codes TABLE  (bank_code	VARCHAR(30)) 
	
	DECLARE sink_node_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT Sink_Node FROM @list_of_sink_nodes
	
	OPEN  sink_node_cursor;
	FETCH NEXT FROM sink_node_cursor INTO @sink_node_name;
	
	WHILE (@@FETCH_STATUS=0)
	  BEGIN
	
		--SET @sink_node_name_new  =  substring(substring(@sink_node_name,4, LEN(@sink_node_name)), 1,len(substring(@sink_node_name,4, LEN(@sink_node_name)))-3) 	  
		  SET @sink_node_name_new  =  substring(@sink_node_name,4, 3)  
	        INSERT INTO @list_of_bank_codes(bank_code) VALUES (@sink_node_name_new) 
		FETCH NEXT FROM sink_node_cursor INTO @sink_node_name;
	END
		
	CLOSE  sink_node_cursor;
	DEALLOCATE sink_node_cursor 
	
	SELECT * FROM @list_of_source_nodes
	
	SELECT * FROM @list_of_sink_nodes
	
	SELECT * FROM @list_of_bank_codes
	
    DECLARE @list_of_retention_data TABLE  (Retention_Data VARCHAR(30)) 
	
	INSERT INTO  @list_of_retention_data SELECT part as 'Retention_Data' FROM usf_split_string(@Retention_Data,',')
	
	-- Only look at 02xx messages that were not fully reversed.
    --SELECT @report_date_start AS 'START_DATE', @report_date_end AS 'END_DATE'

	DECLARE @post_tran_cust_id_table TABLE (post_tran_cust_id VARCHAR (2000))

	INSERT INTO @post_tran_cust_id_table (post_tran_cust_id) SELECT post_tran_cust_id FROM post_tran (NOLOCK) WHERE (post_tran_cust_id >= @rpt_tran_id) AND  (recon_business_date >= @report_date_start  AND recon_business_date<= @report_date_end) 


	--SELECT  post_tran_id,post_tran_cust_id,settle_entity_id,batch_nr,prev_post_tran_id,next_post_tran_id,sink_node_name,tran_postilion_originated,tran_completed,message_type,tran_type,tran_nr,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,abort_rsp_code,auth_id_rsp,auth_type,auth_reason,retention_data,acquiring_inst_id_code,message_reason_code,sponsor_bank,retrieval_reference_nr,datetime_tran_gmt,datetime_tran_local,datetime_req,datetime_rsp,realtime_business_date,recon_business_date,from_account_type,to_account_type,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,settle_amount_impact,tran_cash_req,tran_cash_rsp,tran_currency_code,tran_tran_fee_req,tran_tran_fee_rsp,tran_tran_fee_currency_code,tran_proc_fee_req,tran_proc_fee_rsp,tran_proc_fee_currency_code,settle_amount_req,settle_amount_rsp,settle_cash_req,settle_cash_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_proc_fee_req,settle_proc_fee_rsp,settle_currency_code,pos_entry_mode,pos_condition_code,additional_rsp_data,tran_reversed,prev_tran_approved,issuer_network_id,acquirer_network_id,extended_tran_type,ucaf_data,from_account_type_qualifier,to_account_type_qualifier,bank_details,payee,card_verification_result,online_system_id,participant_id,receiving_inst_id_code,routing_type,pt_pos_operating_environment,pt_pos_card_input_mode,pt_pos_cardholder_auth_method,pt_pos_pin_capture_ability,pt_pos_terminal_operator INTO #TEMP_POST_TRAN FROM post_tran (NOLOCK) WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM @post_tran_cust_id_table)

	--SELECT  post_tran_cust_id,source_node_name,draft_capture,pan,card_seq_nr,expiry_date,service_restriction_code,terminal_id,terminal_owner,card_acceptor_id_code,mapped_card_acceptor_id_code,merchant_type,card_acceptor_name_loc,address_verification_data,address_verification_result,check_data,totals_group,card_product,pos_card_data_input_ability,pos_cardholder_auth_ability,pos_card_capture_ability,pos_operating_environment,pos_cardholder_present,pos_card_present,pos_card_data_input_mode,pos_cardholder_auth_method,pos_cardholder_auth_entity,pos_card_data_output_ability,pos_terminal_output_ability,pos_pin_capture_ability,pos_terminal_operator,pos_terminal_type,pan_search,pan_encrypted,pan_reference INTO #TEMP_POST_TRAN_CUST FROM post_tran_cust (NOLOCK) WHERE post_tran_cust_id  IN (SELECT post_tran_cust_id FROM @post_tran_cust_id_table);

    
	INSERT
				INTO @report_result
	SELECT
	     
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				t.recon_business_date,--oremeyi added this 24/02/2009
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
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
				isnull(t.retention_data,0),
				c.totals_group,
				t.tran_postilion_originated,
				t.tran_nr
	FROM

       post_tran t (NOLOCK)  JOIN post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id =c.post_tran_cust_id) AND t.post_tran_cust_id  IN (SELECT post_tran_cust_id FROM @post_tran_cust_id_table)
				
	WHERE 		
			  tran_completed = 1 AND 
				(
				 ( t.retention_data IS NOT NULL AND (LEFT(retention_data,4) in (SELECT Retention_Data FROM @list_of_retention_data))   OR 
				  LEFT (c.totals_group,3) IN (SELECT bank_code FROM @list_of_bank_codes)   AND (t.sink_node_name <>'ESBCSOUTsnk' AND t.retention_data is  NULL))
				
				)
				

				  AND
				t.message_type IN ('0200', '0220', '0400', '0420')  AND t.tran_type  ='01'
				
				AND
                (
					c.source_node_name  NOT LIKE '%ASP%' AND  LEFT(c.source_node_name,3) NOT IN  ('TSS','GPR') AND LEFT(c.source_node_name,2) <> 'SB' AND c.source_node_name  NOT LIKE '%CTL%'
					AND LEFT(c.source_node_name,6) <> 'CCLOAD' AND c.source_node_name  NOT LIKE '%FUEL%' AND c.source_node_name  NOT LIKE '%TELCO%'  AND c.source_node_name  NOT LIKE '%TPP%'
					AND c.source_node_name  <> 'SWTMEGAsrc'
                )
				AND
				(t.sink_node_name NOT IN ('CCLOADsnk', 'GPRsnk', 'SWTCTLsnk','VTUsnk''SWTMEGAsnk','VAUMOsnk') AND LEFT(t.sink_node_name,2) <> 'SB') AND LEFT(terminal_id,1)<> '2' 
				
						
						--and c.source_node_name not in ('SWTWEMSBsrc')
			
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
			--  SELECT @pan_clear = postilion_office.dbo.DecryptPan(@pan, @pan_encrypted, @process_descr);
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
												

				DECLARE @current_tran_nr VARCHAR (255)
				DECLARE @current_retention_data VARCHAR (255)

				DECLARE tran_nr_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR (SELECT tran_nr,retention_data FROM @report_result WHERE tran_postilion_originated =1 AND retention_data IS NOT NULL AND (LEFT(retention_data,4) in (SELECT Retention_Data FROM @list_of_retention_data)))

				OPEN  tran_nr_cursor;
			
				FETCH NEXT FROM tran_nr_cursor INTO @current_tran_nr, @current_retention_data;

				WHILE (@@FETCH_STATUS=0)
					BEGIN

						UPDATE @report_result SET retention_data = @current_retention_data WHERE tran_nr = @current_tran_nr AND tran_postilion_originated=0
						
						
						FETCH NEXT FROM tran_nr_cursor INTO @current_tran_nr, @current_retention_data;

					END

				CLOSE  tran_nr_cursor;			
				DEALLOCATE tran_nr_cursor;
				
				DELETE FROM @report_result WHERE tran_postilion_originated=1 AND sink_node_name <>'ESBCSOUTsnk'
	

				
	
	SELECT  Warning,StartDate,EndDate,recon_business_date,SourceNodeAlias,pan,terminal_id,card_acceptor_id_code,card_acceptor_name_loc,source_node_name,sink_node_name,tran_type,rsp_code_rsp,message_type,datetime_req,settle_amount_req,settle_amount_rsp,settle_tran_fee_rsp,TranID,prev_post_tran_id,system_trace_audit_nr,message_reason_code,retrieval_reference_nr,datetime_tran_local,from_account_type,to_account_type,settle_currency_code,settle_amount_impact,tran_type_desciption,rsp_code_description,settle_nr_decimals,currency_alpha_code,currency_name,tran_reversed,isPurchaseTrx,isWithdrawTrx,isRefundTrx,isDepositTrx,isInquiryTrx,isTransferTrx,isOtherTrx,pan_encrypted,from_account_id,payee,retention_data,totals_group  FROM 
	
	     @report_result
	ORDER BY 
		datetime_tran_local, source_node_name

--DROP TABLE #TEMP_POST_TRAN;

--DROP TABLE #TEMP_POST_TRAN_CUST;
		

COMMIT TRANSACTION;
END