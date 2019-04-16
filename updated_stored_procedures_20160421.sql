USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04]    Script Date: 04/21/2016 10:12:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO














ALTER PROCEDURE[dbo].[osp_rpt_b04]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
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
	--BEGIN TRANSACTION;
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
		card_acceptor_id_code	VARCHAR (300),	 
		card_acceptor_name_loc	VARCHAR (300), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (300),
		rsp_code_description	VARCHAR (300),
		settle_nr_decimals		BIGINT,
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

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)
	
	
	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

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
	
    DECLARE @list_of_retention_data TABLE  (Retention_Data VARCHAR(30)) 
	
	INSERT INTO  @list_of_retention_data SELECT part as 'Retention_Data' FROM usf_split_string(@Retention_Data,',')
	
	-- Only look at 02xx messages that were not fully reversed.
    --SELECT @report_date_start AS 'START_DATE', @report_date_end AS 'END_DATE'
        DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

SELECT @first_post_tran_cust_id=min(post_tran_cust_id) FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req>=@report_date_start AND   datetime_req <=(case when @report_date_start=@report_date_end then DATEADD(D,1,@report_date_start)  else  @report_date_end end)
SELECT @last_post_tran_cust_id = max(post_tran_cust_id) FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req>=@report_date_start AND   datetime_req <=(case when @report_date_start=@report_date_end then DATEADD(D,1,@report_date_start)  else  @report_date_end end)



;WITH  post_tran_table(
post_tran_cust_id
,sink_node_name
,recon_business_date
,tran_type
,rsp_code_rsp
,message_type 
,datetime_req 
,settle_amount_req
,settle_tran_fee_rsp
,settle_currency_code
,tran_nr
,prev_post_tran_id
,system_trace_audit_nr
,message_reason_code
,retrieval_reference_nr
,datetime_tran_local
,from_account_type 
,to_account_type 
,settle_amount_impact																			
,extended_tran_type
,tran_reversed
,from_account_id
,payee
,retention_data
,tran_postilion_originated
,online_system_id
,tran_completed
,settle_amount_rsp
) AS (
SELECT
post_tran_cust_id
,sink_node_name
,recon_business_date
,tran_type
,rsp_code_rsp
,message_type 
,datetime_req 
,settle_amount_req
,settle_tran_fee_rsp
,settle_currency_code
,tran_nr
,prev_post_tran_id
,system_trace_audit_nr
,message_reason_code
,retrieval_reference_nr
,datetime_tran_local
,from_account_type 
,to_account_type 
,settle_amount_impact																			
,extended_tran_type
,tran_reversed
,from_account_id
,payee
,retention_data
,tran_postilion_originated
,online_system_id
,tran_completed
,settle_amount_rsp
FROM post_tran  (NOLOCK, INDEX(ix_post_tran_9))
WHERE
    recon_business_date   in 
  (  
    select [Date] from  dbo.get_dates_in_range(@report_date_start,@report_date_end)
    
    )  

 AND
				tran_completed = 1 AND message_type IN  (SELECT part FROM dbo.usf_split_string('0200,0220,0400,0420', ',') ) AND tran_type  ='01'
				and
				(sink_node_name NOT IN (SELECT part FROM dbo.usf_split_string('CCLOADsnk,GPRsnk,SWTCTLsnk,VTUsnk,SWTMEGAsnk,VAUMOsnk', ','))
				AND sink_node_name NOT LIKE 'SB%'
				 )  and  master.dbo.fn_rpt_contains(sink_node_name,'TPP') =0

),

 post_tran_cust_table (
post_tran_cust_id,
source_node_name,
pan,terminal_id, 
card_acceptor_id_code, 
card_acceptor_name_loc,
pan_encrypted,
totals_group

 ) as (
	SELECT 
	post_tran_cust_id,
	source_node_name,
	pan,terminal_id, 
	card_acceptor_id_code, 
	card_acceptor_name_loc, 
	
	pan_encrypted,
totals_group
FROM post_tran_cust (NOLOCK)
 WHERE

 post_tran_cust_id >=@first_post_tran_cust_id AND post_tran_cust_id <= @last_post_tran_cust_id
 AND
                (
					LEFT(source_node_name,3) NOT IN  ('TSS','GPR')
					AND source_node_name not like 'SB%'
					AND master.dbo.fn_rpt_contains(source_node_name,'CTL') =0
					AND source_node_name not like 'CCLOAD%'					
					AND master.dbo.fn_rpt_contains(source_node_name,'FUEL') =0 
					AND master.dbo.fn_rpt_contains(source_node_name,'TELCO') =0 
					AND master.dbo.fn_rpt_contains(source_node_name,'TPP') =0
					AND source_node_name  <> 'SWTMEGAsrc'AND source_node_name  <> 'SWTMEGADSsrc' AND source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
                )
				
				
				AND master.dbo.fn_rpt_starts_with(terminal_id,'2')=0
 )
 
 
 
	
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
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
					
								
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				t.tran_reversed,
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,


				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				t.from_account_id,
				t.payee,
				isnull(t.retention_data,0),
				c.totals_group,
				t.tran_postilion_originated,
				t.tran_nr+t.online_system_id
			
	FROM
				post_tran_table t (NOLOCK)
		 JOIN 			post_tran_cust_table c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id) 
		 
		
	WHERE 		
			  
                 
	
				
				(
				 ( t.retention_data IS NOT NULL AND (LEFT(retention_data,4) in (SELECT Retention_Data FROM @list_of_retention_data))   OR 
				  LEFT (c.totals_group,3) IN (SELECT bank_code FROM @list_of_bank_codes)   AND (t.sink_node_name <>'ESBCSOUTsnk' AND t.retention_data is  NULL))
				
				)  
				

				 
				
				
                               
                                
--AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
--AND c.source_node_name  = 'ASPSPNOUsrc'
				
						
						--and c.source_node_name not in ('SWTWEMSBsrc')
						
			 IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
			/*ELSE
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
				*/								

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

 WHERE 
	      (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 

             (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 

        WHERE ll.recon_business_date >= @report_date_start

        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )


	     
	ORDER BY 
		datetime_tran_local, source_node_name
		

--COMMIT TRANSACTION;
END














GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Autopay]    Script Date: 04/21/2016 10:12:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE[dbo].[osp_rpt_b04_Autopay]
	@StartDate		    VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SourceNode		    VARCHAR(40),
   	@TerminalID         VARCHAR(30),
   	@SinkNode                VARCHAR(40),
	--@CBNCode	    CHAR(3),
	@show_full_pan	    BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B06 report uses this stored proc.
	
	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255) NULL,	
		StartDate					VARCHAR(30),  
		EndDate						VARCHAR(30),
		pan							VARCHAR (19), 
		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		source_node_name		VARCHAR (40),
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2),
		terminal_id			VARCHAR(30), 
		tran_reversed				INT,
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
		account_id_1			VARCHAR(28), -- added by Vincent 31/Oct/07
		account_id_2			VARCHAR(28),  -- added by Vincent 31/Oct/07
        receiving_inst_id           CHAR (6),	
         structured_data_rsp         TEXT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description		VARCHAR (100),
		settle_nr_decimals			BIGINT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (100),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		totals_group			varchar(12),
		bank_institution_name		varchar(50)
		)			

	IF (@TerminalID IS NULL or Len(@TerminalID)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Terminal ID parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
    
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END


	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 
	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @TerminalID


	
	INSERT
			INTO #report_result


	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  

			@EndDate as EndDate,
			 CASE WHEN  @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
			 ELSE dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) 
			 END AS pan,
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			c.source_node_name,
			t.sink_node_name, 
			t.tran_type, 
			c.terminal_id,
			t.tran_reversed,
			t.rsp_code_rsp, 

			t.message_type, 
			t.datetime_req, 

			

			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.from_account_id,  -- added by Vincent 31/Oct/07
			t.to_account_id,  -- added by Vincent 31/Oct/07
			RIGHT(CAST(t.structured_data_req AS VARCHAR(255)), 6),
                        t.structured_data_req,
			t.settle_currency_code, 
			
			
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(t.tran_type) 	AS isOtherTrx,
			c.pan_encrypted,
			t.from_account_id,
			t.to_account_id,
			t.payee,
			c.totals_group,
			1--'bank_institution_name' =(SELECT TOP 1 BANK_INSTITUTION_NAME FROM acquirer_institution_table  WHERE INST_SINK_CODE = substring(substring(t.sink_node_name,4, LEN(t.sink_node_name)), 1,len(substring(t.sink_node_name,4, LEN(t.sink_node_name)))-3) ) 
			
	FROM
			post_tran t (NOLOCK, INDEX(ix_post_tran_9)) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id
                                 AND
								recon_business_date in (
														SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
														)
								and
                                t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN  (SELECT part FROM usf_split_string('0200,0220,0400,0420', ','))
			AND
			t.tran_type NOT IN ('31','38')
			AND 
			t.tran_completed = 1 
			
			and
			terminal_id  like '3IAP%'
			 
			 
			AND
			t.sink_node_name not like 'SB%'
			
			AND
			c.source_node_name not like 'SB%'
		
			
			)

                      
	
WHERE 			

           		
			(			
				(t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes))
			OR	(substring(t.sink_node_name,4,3) in (SELECT substring(sink_node,4,3) FROM #list_of_sink_nodes))---and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			OR	(LEFT(pan,6) = '628051' and (substring(c.totals_group,1,3)in (SELECT substring(sink_node,4,3) FROM #list_of_sink_nodes))
			and source_node_name  IN (SELECT source_node FROM #list_of_source_nodes)and t.sink_node_name  IN (SELECT sink_node FROM #list_of_sink_nodes))
			)


                                
  option(RECOMPILE)
  
			IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT *
	FROM
			#report_result

 WHERE 
	  
	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
				
	ORDER BY 
			datetime_req
END










































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_bill_payment_acquirer]    Script Date: 04/21/2016 10:12:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














ALTER PROCEDURE[dbo].[osp_rpt_b04_bill_payment_acquirer]
	@StartDate	VARCHAR(30),	-- yyyymmdd
	@EndDate	VARCHAR(30),	-- yyyymmdd
	@AcquiringBIN	VARCHAR(25),	-- Seperated by commas
	@show_full_pan	bit=0,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id bigint = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30), 
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		--extended_tran_type      CHAR(255),
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (30),
		rsp_code_description	VARCHAR (60),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),	
		structured_data_req		VARCHAR (max),
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
		SELECT @StartDate = REPLACE(SUBSTRING(CONVERT(VARCHAR (2000),DATEADD(DD,-1, GETDATE()), 112), 0, 12), '.', ''); 
		SELECT @EndDate =REPLACE(SUBSTRING(CONVERT(VARCHAR (2000),DATEADD(DD,-1, GETDATE()), 112), 0, 12), '.', ''); 
      END
      	    SELECT @report_date_start = CONVERT(DATETIME, @StartDate, 112);
	    SELECT @report_date_end =  CONVERT(DATETIME, @EndDate, 112); 
		
    SELECT  @Tempreport_date_start	=cast(( @report_date_start) as varchar(30));
    SELECT  @Tempreport_date_end	=cast(( @report_date_end) as varchar(30));
	

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates

	SELECT @StartDate = REPLACE( CONVERT (VARCHAR(30) , @StartDate,112), '-','');
    SELECT @EndDate = REPLACE( CONVERT (VARCHAR(30) , @EndDate,112), '-','');

	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate   = CONVERT(VARCHAR(30), @report_date_end, 112)

	
	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

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
							CASE WHEN @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
		ELSE
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) 
			END AS pan,
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
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				cast((t.datetime_tran_local) as varchar (30)), 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				1,
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				payee,
				d.bank_institution_name,
				b.bank_card_type
				
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_9))
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (
				t.post_tran_cust_id = c.post_tran_cust_id
				 AND
				recon_business_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
										)
										and
			     t.tran_completed = 1
				 
					AND
				t.tran_postilion_originated = 0 
				
				)
				LEFT JOIN acquirer_institution_table d (NOLOCK) ON (t.acquiring_inst_id_code = d.acquirer_inst_id)
				LEFT JOIN bank_bin_table b (NOLOCK) ON (substring (c.pan ,1,6) = b.bin)
				
	WHERE 			
	
				( (c.terminal_id IN ( SELECT part FROM dbo.usf_split_string('3FTL0001,3UDA0001,3FET0001,3FTH0001,3UMO0001,3PLI0001,3PAG0001,3PMM0001,4MIM0001,3BOZ0001,4RDC0001,2ONT0001,3ASI0001,4QIK0001,4MBX0001,3NCH0001,4FBI0001,3UTX0001,4TSM0001,4FMM0001,3EBM0001,4FDM0001,3HIB0001,4RBX0001', ',') )
				   and t.sink_node_name <> 'BILLSsnk')
				OR
                                (c.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk' and t.tran_type = '50')
                       OR       
				(t.sink_node_name IN ('PAYDIRECTsnk') or ((master.dbo.fn_rpt_contains(payee, '62805150') =1 or c.source_node_name = 'BILLSsrc' ) and t.sink_node_name <> 'BILLSsnk' 
				and c.card_acceptor_id_code like 'QuickTeller%'))
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
             --and t.extended_tran_type <> '8234'
             
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
			* 
	FROM 
			#report_result
 WHERE 
	     	    
	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
				
	ORDER BY 
				datetime_tran_local, retrieval_reference_nr, source_node_name
END



























































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_bill_payment_issuer]    Script Date: 04/21/2016 10:12:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









	alter PROCEDURE[dbo].[osp_rpt_b04_bill_payment_issuer]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	--@SourceNodes	VARCHAR(255),	-- Seperated by commas
	--@AcquiringBIN		VARVARCHAR(30),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR(30), 
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		--extended_tran_type      CHAR(255),
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (30),
		rsp_code_description	VARCHAR (60),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),	
		structured_data_req		VARCHAR (max),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		Network_ID			CHAR(255),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(512),
		totals_group			Varchar(40)
)
	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
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

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	
	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

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

	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
        
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
				t.datetime_req, 
				--t.extended_tran_type,
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				1,
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				payee,
				t.from_account_id,
				t.to_account_id,
				t.payee,
				c.totals_group
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_9)) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) ON (
                                t.post_tran_cust_id = c.post_tran_cust_id
                                AND
                                recon_business_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
										) and
                                t.tran_postilion_originated = 0 
				AND
					t.tran_completed = 1
				
                                
                                ) 
                                
            


			WHERE 			

			
				
				
				( 
				(t.sink_node_name = 'PAYDIRECTsnk' or ((master.dbo.fn_rpt_contains(payee, '62805150') =1 or c.source_node_name = 'BILLSsrc')and t.sink_node_name <> 'BILLSsnk' and c.card_acceptor_id_code like 'QuickTeller%'))
				OR 
		( (c.terminal_id IN ( SELECT part FROM dbo.usf_split_string('3FTL0001,3UDA0001,3FET0001,3FTH0001,3UMO0001,3PLI0001,3PAG0001,3PMM0001,4MIM0001,3BOZ0001,4RDC0001,2ONT0001,3ASI0001,4QIK0001,4MBX0001,3NCH0001,4FBI0001,3UTX0001,4TSM0001,4FMM0001,3EBM0001,4FDM0001,3HIB0001,4RBX0001', ',') )
				   and t.sink_node_name <> 'BILLSsnk')
				OR
                                (c.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk' and t.tran_type = '50')
                                OR
				(c.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				))
				AND
				c.source_node_name !='VTUsrc'
				AND
				t.sink_node_name != 'VTUsnk'
				AND
				(substring(c.totals_group,1,3) in (SELECT substring(sink_node,4,3) FROM #list_of_sink_nodes))
				AND
				t.tran_type NOT IN ('31', '39', '32')

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             OPTION(RECOMPILE)
             --and t.extended_tran_type <> '8234'
                  
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
			* 
	FROM 
			#report_result
WHERE
	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
	ORDER BY 
				datetime_tran_local, retrieval_reference_nr, source_node_name
END






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_bill_payment_summary]    Script Date: 04/21/2016 10:12:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


































ALTER PROCEDURE[dbo].[osp_rpt_b04_bill_payment_summary]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	--@SourceNodes	VARCHAR(255),	-- Seperated by commas
	--@AcquiringBIN		VARCHAR(8),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

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
		EndDate				VARCHAR (30), 
		terminal_owner		VARCHAR(25),
		acquiring_inst_id_code		VARCHAR(25),
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2),
		rsp_code_rsp				CHAR (2), 		
		tran_reversed				INT,	
		message_type			CHAR (4), 
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		settle_amount_impact	FLOAT,
		totals_group	VARCHAR(25),
		terminal_id	VARCHAR (25),
		card_acceptor_id_code	CHAR (15)
		
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
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

SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.terminal_owner, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type,
				t.rsp_code_rsp, 
				t.tran_reversed,	 
				t.message_type,
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
				totals_group,
				c.terminal_id,
				card_acceptor_id_code
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
				
	
WHERE 			
	
--NOT (t.tran_nr+t.online_system_id in (select tran_nr+online_system_id from tbl_late_reversals) 
--and t.message_type = '0420'  and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1)
			
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'
			 
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
				(t.sink_node_name = 'PAYDIRECTsnk' or ((payee like '%62805150' or payee like '62805150%' or c.source_node_name = 'BILLSsrc')and t.sink_node_name <> 'BILLSsnk' and c.card_acceptor_id_code like 'QuickTeller%'))
				OR 
				(c.terminal_id IN ('3FTL0001','3UDA0001','3FET0001','3UMO0001','3PLI0001','3FTH0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001','2ONT0001','3ASI0001','4QIK0001','4MBX0001','3NCH0001','4FBI0001','3UTX0001','4TSM0001','4FMM0001','3EBM0001','4CLT0001','4FDM0001','3HIB0001','4RBX0001')and t.sink_node_name <> 'BILLSsnk')
				OR
                                (c.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk' and t.tran_type = '50')
                                OR
				(c.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				)
				AND
				t.tran_type NOT IN ('31', '39', '32')
                                
                                AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
            -- and t.extended_tran_type <> '8234'
             and 
	     (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
				
				
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 terminal_owner,
		 acquiring_inst_id_code,
		 sum(settle_tran_fee_rsp) as fee,
		 totals_group,
		 rsp_code_rsp,
		 message_type,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
		terminal_id,
		settle_amount_rsp,
		card_acceptor_id_code

	
	FROM
			#report_result
GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,
			terminal_owner,acquiring_inst_id_code,totals_group,rsp_code_rsp,message_type,terminal_id,settle_amount_rsp,card_acceptor_id_code
	ORDER BY 
			source_node_name
	
END
































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_bill_payment_summary_backlog]    Script Date: 04/21/2016 10:12:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE[dbo].[osp_rpt_b04_bill_payment_summary_backlog]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	--@SourceNodes	VARCHAR(255),	-- Seperated by commas
	--@AcquiringBIN		VARCHAR(8),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

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
		EndDate				VARCHAR (30), 
		terminal_owner		VARCHAR(25),
		acquiring_inst_id_code		VARCHAR(25),
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2),
		rsp_code_rsp				CHAR (2), 		
		tran_reversed				INT,	
		message_type			CHAR (4), 
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		settle_amount_impact	FLOAT,
		totals_group	VARCHAR(25),
		terminal_id	VARCHAR (25),
		card_acceptor_id_code	CHAR (15)
		
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
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

	
	
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.terminal_owner, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type,
				t.rsp_code_rsp, 
				t.tran_reversed,	 
				t.message_type,
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
				totals_group,
				terminal_id,
				card_acceptor_id_code
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
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
				(t.sink_node_name = 'PAYDIRECTsnk')
				OR 
				(c.terminal_id IN ('3HIB0001','4RBX0001','3SIB001')and t.sink_node_name <> 'BILLSsnk')
				OR
                                (c.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk')
                                OR
				(c.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				)
				AND
				t.tran_type NOT IN ('31', '39', '32')
                                
                                AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
				
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 terminal_owner,
		 acquiring_inst_id_code,
		 sum(settle_tran_fee_rsp) as fee,
		 totals_group,
		 rsp_code_rsp,
		 message_type,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
		terminal_id,
		settle_amount_rsp,
		card_acceptor_id_code

	
	FROM
			#report_result
GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,
			terminal_owner,acquiring_inst_id_code,totals_group,rsp_code_rsp,message_type,terminal_id,settle_amount_rsp,card_acceptor_id_code
	ORDER BY 
			source_node_name
	
END







GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_bill_payment_summary_mastercard]    Script Date: 04/21/2016 10:12:17 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO































ALTER PROCEDURE[dbo].[osp_rpt_b04_bill_payment_summary_mastercard]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	--@SourceNodes	VARCHAR(255),	-- Seperated by commas
	--@AcquiringBIN		VARCHAR(8),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

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
		EndDate				VARCHAR (30), 
		terminal_owner		VARCHAR(25),
		acquiring_inst_id_code		VARCHAR(25),
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2),
		rsp_code_rsp				CHAR (2), 		
		tran_reversed				INT,	
		message_type			CHAR (4), 
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		settle_amount_impact	FLOAT,
		totals_group	VARCHAR(25),
		terminal_id	VARCHAR (25),
		card_acceptor_id_code	CHAR (15)
		
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
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

SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

	
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.terminal_owner, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type,
				t.rsp_code_rsp, 
				t.tran_reversed,	 
				t.message_type,
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
				totals_group,
				terminal_id,
				card_acceptor_id_code
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
	WHERE 			
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'
				--AND 
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
				(t.sink_node_name = 'PAYDIRECTsnk' or ((payee like '%62805150' or payee like '62805150%' or c.source_node_name = 'BILLSsrc') and t.sink_node_name <> 'BILLSsnk' and c.card_acceptor_id_code like 'QuickTeller%'))
				OR 
				(c.terminal_id IN ('3FTL0001','3UDA0001','3FET0001','3UMO0001','3PLI0001','3FTH0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001','2ONT0001','3ASI0001','4QIK0001','4MBX0001','3NCH0001','4FBI0001','3UTX0001','4TSM0001','4FMM0001','3EBM0001','4FDM0001','3HIB0001','4RBX0001')and t.sink_node_name <> 'BILLSsnk')
				OR
                                (c.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk' and t.tran_type = '50')
                                OR
				(c.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				)
				AND
				t.tran_type NOT IN ('31', '39', '32')
                                AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')

                                and totals_group in ('ZIBMCDebit')

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             --and t.extended_tran_type <> '8234'
             
        and 
	     (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
				
				
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 terminal_owner,
		 acquiring_inst_id_code,
		 sum(settle_tran_fee_rsp) as fee,
		 totals_group,
		 rsp_code_rsp,
		 message_type,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
		terminal_id,
		settle_amount_rsp,
		card_acceptor_id_code

	
	FROM
			#report_result
GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,
			terminal_owner,acquiring_inst_id_code,totals_group,rsp_code_rsp,message_type,terminal_id,settle_amount_rsp,card_acceptor_id_code
	ORDER BY 
			source_node_name
	
END






























































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Billpayment_all_DS]    Script Date: 04/21/2016 10:12:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

















ALTER PROCEDURE[dbo].[osp_rpt_b04_Billpayment_all_DS]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	--@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL


AS
BEGIN
	SET NOCOUNT ON

	Create   TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		pan						VARCHAR (25), 
                Bin                              CHAR (6),
                totalsGroup         VARCHAR(50),
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			VARCHAR(50),
		terminal_owner  			VARCHAR(255),
		--merchant_type				CHAR (4),
		--Category_name				VARCHAR(50),
		--Fee_type				CHAR(1),
		--merchant_disc				DECIMAL(7,4),
		--fee_cap					FLOAT,
		--amount_cap				FLOAT,
		--bearer					CHAR(1),
		card_acceptor_id_code	VARCHAR (255),	 
		card_acceptor_name_loc	VARCHAR (255), 
		source_node_name		VARCHAR (255), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 
                recon_business_date             DATETIME,				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		tran_reversed			INT,	 
		settle_amount_impact	FLOAT,
		extended_tran_type		CHAR (4),
		system_trace_audit_nr		VARCHAR (10)
		)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	/*IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END */

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

	--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(255)) 
	
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames_special @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.
	
SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				
				
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
                                left(c.pan,6) as bin,
                                c.totals_group as totalsGroup,
				c.terminal_id, 
				 (case when t.acquiring_inst_id_code is NULL then substring(c.terminal_id,2,3)
                                    else
				t.acquiring_inst_id_code END),
				c.terminal_owner,
				--ISNULL(c.merchant_type,'VOID'),
				----ISNULL(account_nr,'not available')

				----ISNULL(m.Category_name,'VOID'),
				----ISNULL(m.Fee_type,'VOID'),
				----ISNULL(m.merchant_disc,0.0),




				----ISNULL(m.fee_cap,0),

				----ISNULL(m.amount_cap,99999999999.99),
				----ISNULL(m.bearer,'M'),

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
                                T.recon_business_date ,
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				t.tran_reversed,	 
					
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
					extended_tran_type,
					t.system_trace_audit_nr										-----------added by ij 2010/04/01

	from post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
				

			WHERE 			


			--NOT (t.tran_nr+t.online_system_id in (select tran_nr+online_system_id from tbl_late_reversals) 
           --and t.message_type = '0420'  and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1)
			
				--and t.post_tran_cust_id = c.post_tran_cust_id

                               -- AND
                               
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'
				--AND 
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
				(t.sink_node_name = 'PAYDIRECTsnk' or ((payee like '%62805150' or payee like '62805150%' or c.source_node_name = 'BILLSsrc')and t.sink_node_name <> 'BILLSsnk' and c.card_acceptor_id_code like 'QuickTeller%'))
				OR 
				(c.terminal_id IN ('3FTL0001','3UDA0001','3FET0001','3UMO0001','3PLI0001','3FTH0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001','2ONT0001','3ASI0001','4QIK0001','4MBX0001','3NCH0001','4FBI0001','3UTX0001','4TSM0001','4FMM0001','3EBM0001','4CLT0001')and t.sink_node_name <> 'BILLSsnk')
				OR
                                (c.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk' and t.tran_type = '50')
                                OR
				(c.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				)
				AND
				t.tran_type NOT IN ('31', '39', '32')
                                
                                AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')
                And(( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')	or address_verification_data = '5050' )
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	   
	    AND c.source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')	
	    --and t.extended_tran_type <> '8234'
	     and 
	     (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)		

	
IF @@ROWCOUNT = 0
INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			




INSERT 
                               INTO data_summary_verve_billing_session
       SELECT (cast (recon_business_date as varchar(40)))+'_Billpayment'  
       FROM  #report_result

        where rsp_code_rsp in ('00','11','08','10','16')

	Group by recon_business_date
          
IF(@@ERROR <>0)
RETURN



INSERT
				INTO data_summary_verve_billing
	
	SELECT 
		 recon_business_date,
                 acquiring_inst_id_code,
                 bin,  
                 totalsGroup,		
	         SUM(CASE
                         WHEN message_type <> '0100' then settle_amount_impact * -1
                         WHEN message_type = '0100' then settle_amount_rsp
                         END)as amount,

                 SUM(CASE WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
		        tran_type,
                        message_type,
                        rsp_code_rsp,
                        tran_reversed,                
                       'BillPayment',
                        card_type =  dbo.fn_rpt_CardGroup(bin),
                        terminal_type = SUBSTRING(Terminal_id,1,1),
                    SUM(CASE WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END) as Issuer_Access_fee,

                     SUM(CASE WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END) as Acquirer_Access_fee,

                      SUM(CASE WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END)*3 as Acquirer_Risk_fee,
                       0,0

                  


		 
	 
	FROM 
			#report_result

        where rsp_code_rsp in ('00','11','08','10','16')

	Group by recon_business_date,acquiring_inst_id_code,tran_type,message_type,rsp_code_rsp,tran_reversed,bin,totalsgroup,
                 acquiring_inst_id_code,SUBSTRING(Terminal_id,1,1)

ORDER BY 

			recon_business_date




END












































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Discover]    Script Date: 04/21/2016 10:12:18 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE[dbo].[osp_rpt_b04_Discover]
	@StartDate		CHAR(8),
	@EndDate			CHAR(8),	
	--@SinkNodes		VARCHAR(40),
	@BankCode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	
SET NOCOUNT ON



	CREATE TABLE #report_result
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
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


        CREATE TABLE #list_of_bank_codes (bank_code	VARCHAR(30)) 
	
	INSERT INTO  #list_of_bank_codes EXEC osp_rpt_util_split_nodenames @BankCode
	

SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
           
	
        INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				t.recon_business_date,--oremeyi added this 24/02/2009
				c.source_node_name,
				
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
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.tran_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
					
								
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				t.tran_reversed,
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,


				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				t.from_account_id,
				t.payee,
				isnull(t.retention_data,0),
				c.totals_group,
				t.tran_postilion_originated,
				t.tran_nr+t.online_system_id
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	WHERE 		
			--c.post_tran_cust_id >= @rpt_tran_id
			
			
			--AND
			t.tran_completed = 1

			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			/*AND
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) */
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01')	
			AND
			
			substring(t.sink_node_name,4,3) in (select bank_code from #list_of_bank_codes)
			
                       
                       AND
                       c.source_node_name  NOT LIKE 'SB%'
                       AND
                       t.sink_node_name  NOT LIKE 'SB%'
                       AND
                       c.source_node_name  = 'SWTMEGADSsrc'
                        and 
	     (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
		       --AND
			--settle_currency_code ='840'

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
		

	

	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END







GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_easyfuel]    Script Date: 04/21/2016 10:12:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












ALTER PROCEDURE[dbo].[osp_rpt_b04_easyfuel]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@acquiring_inst_id_code		CHAR(16),
	---@terminal_id  			VARCHAR(255),   
	----@SinkNodes		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		---SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (255), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(255),
		terminal_owner  		CHAR(255),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (255), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		tran_reversed			INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		extended_tran_type		CHAR (4),
                aggregate_column         VARCHAR(200)        
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	---IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	--BEGIN	   
	   	--INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	--SELECT * FROM #report_result
		--RETURN 1
	--END

	--IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	--BEGIN	   
	   	--INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	--SELECT * FROM #report_result
		--RETURN 1
	--END
		
	
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

	

	--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	--CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	--INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

print @report_date_start
print @report_date_end
	-- Only look at 02xx messages that were not fully reversed.
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				--SourceNodeAlias = 
				--(CASE 
					--WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					--ELSE c.source_node_name
				--END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				t.payee,
				t.extended_tran_type,
                                t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(12))
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK), 
				tbl_merchant_category m
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				(c.merchant_type = m.category_code)
				AND
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				--AND 
				--(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
				AND
				c.source_node_name = 'SWTEASYFLsrc'
				--IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
							
					(c.terminal_id like '2%') 
					--OR
					--(c.terminal_id like '5%') OR-- c.source_node_name like '%POS%')
					--(c.terminal_id like '6%') -- c.source_node_name like '%POS%')
					)
				and
				acquiring_inst_id_code = @acquiring_inst_id_code
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				AND
				t.tran_type NOT IN ('31','50')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
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


create table #temp_table_1
(aggregate_column varchar(200), counts float )
insert into #temp_table_1 select aggregate_column, count(aggregate_column) from #report_result
group by aggregate_column

update #report_result
set tran_type_desciption = tran_type_desciption+ '_M'
where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)
		
	SELECT 

			* 
	FROM 
			#report_result
	ORDER BY 
			datetime_tran_local,sink_node_name
END





































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_easyfuel_all]    Script Date: 04/21/2016 10:12:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












ALTER PROCEDURE[dbo].[osp_rpt_b04_easyfuel_all]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@acquiring_inst_id_code		CHAR(16),
	----@terminal_id  			VARCHAR(255),   
	----@SinkNodes		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		---SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (255), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(255),
		terminal_owner  		CHAR(255),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (255), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		tran_reversed			INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		extended_tran_type		CHAR (4),
                aggregate_column         VARCHAR(200)       
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	---IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	--BEGIN	   
	   	--INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	--SELECT * FROM #report_result
		--RETURN 1
	--END

	--IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	--BEGIN	   
	   	--INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	--SELECT * FROM #report_result
		--RETURN 1
	--END
		
	
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

	

	--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	--CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	--INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

print @report_date_start
print @report_date_end
	-- Only look at 02xx messages that were not fully reversed.
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				--SourceNodeAlias = 
				--(CASE 
					--WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					--ELSE c.source_node_name
				--END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				t.payee,
				t.extended_tran_type,
                                t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(12)) 	
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK), 
				tbl_merchant_category m
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				(c.merchant_type = m.category_code)
				AND
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				--AND 
				--(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
				AND
				c.source_node_name = 'SWTEASYFLsrc'
				--IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
							
					(c.terminal_id like '2%') 
					
				AND
				 --terminal_id = @terminal_id
				--and
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				AND
				t.tran_type NOT IN ('31','50')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
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

create table #temp_table_1
(aggregate_column varchar(200), counts float )
insert into #temp_table_1 select aggregate_column, count(aggregate_column) from #report_result
group by aggregate_column

update #report_result
set tran_type_desciption = tran_type_desciption+ '_M'
where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)
		
	SELECT 

			* 
	FROM 
			#report_result
	ORDER BY 
			datetime_tran_local,sink_node_name
END








































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_gpr]    Script Date: 04/21/2016 10:12:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO














---FAILED TRANSACTIONS AND REVERSALS ONLY




ALTER PROCEDURE[dbo].[osp_rpt_b04_gpr]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(40),
	@SourceNodes	VARCHAR(255),	-- Seperated by commas
	@AcquiringBIN		VARCHAR(30),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		card_acceptor_id_code	CHAR (225),	 
		card_acceptor_name_loc	CHAR (512),
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_description  VARCHAR (30),
		rsp_code_description	VARCHAR (60),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),	
		structured_data_req		VARCHAR (255),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		Network_ID			CHAR(9),
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(50) 
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
		
	

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

	
	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

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

	CREATE TABLE #list_of_AcquiringBIN (AcquiringBIN VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringBIN EXEC osp_rpt_util_split_nodenames @AcquiringBIN

        CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(40)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes


	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
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
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				1,
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				left(payee,9),
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				t.payee	
				
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_9))
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (
				
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				recon_business_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
										)
				and 
				t.tran_completed = 1
				AND
				t.tran_postilion_originated = 0 
				AND
				(t.message_type IN (SELECT part FROM dbo.usf_split_string('0400,0420', ','))
                                or (t.message_type IN (SELECT part FROM dbo.usf_split_string('0100,0200,0220', ',') ))
                                and  T.rsp_code_rsp not in(SELECT part FROM dbo.usf_split_string ('00,11,09', ',')) ) 
				 AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
             AND
           			t.sink_node_name not like 'SB%'
			
			AND
			c.source_node_name not like 'SB%'
				)
				
	
WHERE 			


					--to pick only reversals and failures. refer to the SP with prefix GPR_ALL for all details
				
				(substring(c.totals_group,1,3) in (SELECT substring(sink_node,4,3) FROM #list_of_sink_nodes)
				OR 
				c.terminal_owner IN (SELECT sink_node FROM #list_of_sink_nodes)
				OR 
				t.acquiring_inst_id_code IN (SELECT AcquiringBIN FROM #list_of_AcquiringBIN))
				AND
				--(
				(c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes))
				--OR
				--(c.terminal_id LIKE '4%'AND t.tran_type = '00')
				--)
				AND
				t.tran_type NOT IN ('31', '39')
				--AND
				--c.post_tran_cust_id >= 75591745

            
           
				
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

where
(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
	ORDER BY 
				datetime_tran_local, retrieval_reference_nr, source_node_name
END



















































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_gpr_ALL]    Script Date: 04/21/2016 10:12:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO














ALTER PROCEDURE[dbo].[osp_rpt_b04_gpr_ALL]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(40),
	@SourceNodes	VARCHAR(255),	-- Seperated by commas
	@AcquiringBIN		VARCHAR(30),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
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
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
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
		Network_ID			CHAR(9),
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(512) 
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
		
	

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

	CREATE TABLE #list_of_AcquiringBIN (AcquiringBIN VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringBIN EXEC osp_rpt_util_split_nodenames @AcquiringBIN

        CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(40)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
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
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				1,
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				left(payee,9),
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				t.payee	
				
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_9))
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (
				
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				recon_business_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
										)
										AND
				t.tran_completed = 1
				and
				t.tran_postilion_originated = 0 
				AND
				t.message_type IN ( SELECT part FROM dbo.usf_split_string('0100,0200,0220,0400,0420', ',') )
				
				)
				
	WHERE 			
				
				(substring(c.totals_group,1,3) in (SELECT substring(sink_node,4,3) FROM #list_of_sink_nodes)
				OR 
				c.terminal_owner IN (SELECT sink_node FROM #list_of_sink_nodes)
				OR 
				t.acquiring_inst_id_code IN (SELECT AcquiringBIN FROM #list_of_AcquiringBIN))
				AND
				--(
				(c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes))
				--OR
				--(c.terminal_id LIKE '4%'AND t.tran_type = '00')
				--)
				AND
				t.tran_type NOT IN ('31', '39')
                AND
             c.source_node_name  NOT LIKE 'SB%'
               AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           OPTION(RECOMPILE)

				
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
			WHERE (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
	ORDER BY 
				datetime_tran_local, retrieval_reference_nr, source_node_name
END














































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_gpr_mastercard]    Script Date: 04/21/2016 10:12:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER PROCEDURE[dbo].[osp_rpt_b04_gpr_mastercard]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(40),
	@SourceNodes	VARCHAR(255),	-- Seperated by commas
	@AcquiringBIN		VARCHAR(8),	-- Seperated by commas
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

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
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (25), 
		terminal_id				VARCHAR (12), 
		card_acceptor_id_code	CHAR (512),	 
		card_acceptor_name_loc	CHAR (999),
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
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (60),
		rsp_code_description	VARCHAR (60),
		settle_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),	
		structured_data_req		VARCHAR (max),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		Network_ID			CHAR(9),
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
                tran_reversed                   varchar(2)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
		
	

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

	-- Only look at 02xx messages that were not fully reversed.
	
	
	
SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
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
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				1,
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				left(payee,9),
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				1,	
                                t.tran_reversed
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
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
				AND
				t.message_type IN ('0100','0200', '0220', '0400', '0420') 	
				AND
				(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3)
				OR 
				c.terminal_owner IN (SELECT sink_node FROM #list_of_sink_nodes)
				OR 
				t.acquiring_inst_id_code = @AcquiringBIN)
				AND
				--(
				(c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes))
				--OR
				--(c.terminal_id LIKE '4%'AND t.tran_type = '00')
				--)
				AND
				t.tran_type NOT IN ('31', '39')
                                
                                and left (pan,6) in ('539941','533301','531525','547160','530519')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				--AND
				--c.post_tran_cust_id >= 75591745
		      and 
	     (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

				
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
				datetime_tran_local, retrieval_reference_nr, source_node_name
END








































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_mobility]    Script Date: 04/21/2016 10:12:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




















ALTER PROCEDURE[dbo].[osp_rpt_b04_mobility]
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
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B06 report uses this stored proc.


	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'		

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255) NULL,	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
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
		rsp_code_description VARCHAR (60),
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

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

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



	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs
	
	INSERT
			INTO #report_result

	SELECT	


			NULL AS Warning,

			@StartDate as StartDate,  
			@EndDate as EndDate,
			 CASE WHEN  @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
			 ELSE dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) 
			 END AS pan,
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
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
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
			
			
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,

			master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.tran_reversed,
			c.pan_encrypted,
			payee,
			extended_tran_type,
			from_account_id,
			to_account_id,
			totals_group,
			prev_tran_approved
	FROM
			post_tran t (NOLOCK, INDEX(ix_post_tran_9))
			 JOIN 
			post_tran_cust c (NOLOCK) ON 
			
			(
			  t.post_tran_cust_id = c.post_tran_cust_id
			  and
			  recon_business_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
										)
		     AND
		     t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0 
			AND
			t.tran_type IN ('50','00','40')
			AND
				source_node_name NOT IN  ( select part  FROM dbo.usf_split_string('CCLOADsrc,GPRsrc,VTUsrc,SWTMEGAsrc', ','))	
            AND
			t.sink_node_name not like 'SB%'
			
			AND
			c.source_node_name not like 'SB%'
             AND
             t.sink_node_name  <>'WUESBPBsnk'
             and ( 
              t.extended_tran_type is null OR t.extended_tran_type <> '8234'  )
			)
			
			
	
WHERE 			

			
				
           		(
			(c.terminal_id like '4%' and 
			master.dbo.fn_rpt_contains(card_acceptor_name_loc, 'MCN') =0
			
			and (master.dbo.fn_rpt_contains(payee, '62805150') = 0 OR payee is null) and c.source_node_name <> 'BILLSsrc')
			OR
			((c.terminal_id like '2%') and t.tran_type <> '00' and (master.dbo.fn_rpt_contains(payee, '62805150') =0 OR payee is null) and c.source_node_name <> 'BILLSsrc')
			OR           		
			(
			(c.terminal_id like '1%')
			AND
			(master.dbo.fn_rpt_contains(payee, '62805150') = 0 OR payee is null)
			)
			)
			AND 
			c.terminal_id not like '4GLO%' 	
                         	 
				
			AND 
			( 
			(substring(t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))
			AND 
			(
				((substring(c.source_node_name,4,3) <> substring(c.totals_group,1,3))
				and master.dbo.fn_rpt_contains(sink_node_name, 'CC') = 0
				
				)
				OR
				((substring(c.source_node_name,4,3) = substring(c.totals_group,1,3)
				and c.source_node_name not like 'TSS%'))
				
			)-- intrabank transactions
			--OR
				--t.acquiring_inst_id_code IN (SELECT acquiring_inst_id_code FROM #list_of_BINs)
			)
			
             OPTION(recompile)

			IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
--	ELSE
--	BEGIN
--		--
--		-- Decrypt PAN information if necessary
--		--
--
--		DECLARE @pan VARCHAR (19)
--		DECLARE @pan_encrypted CHAR (18)
--		DECLARE @pan_clear VARCHAR (19)
--		DECLARE @process_descr VARCHAR (100)
--
--		SET @process_descr = 'Office B04 Report'
--
--		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
--		DECLARE pan_cursor CURSOR FORWARD_ONLY
--		FOR
--			SELECT
--					pan,
--					pan_encrypted
--			FROM
--					#report_result
--		FOR UPDATE OF pan
--
--		OPEN pan_cursor
--
--		DECLARE @error INT
--		SET @error = 0
--
--		IF (@@CURSOR_ROWS <> 0)
--
--		BEGIN
--			FETCH pan_cursor INTO @pan, @pan_encrypted
--			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
--			BEGIN
--				-- Handle the decrypting of PANs
--				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT
--
--				-- Update the row if its different
--				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
--				BEGIN
--					UPDATE
--						#report_result
--					SET
--						pan = @pan_clear
--					WHERE
--						CURRENT OF pan_cursor
--				END
--
--				FETCH pan_cursor INTO @pan, @pan_encrypted
--			END
--		END
--
--		CLOSE pan_cursor
--		DEALLOCATE pan_cursor
--
--	END			
	SELECT *
	FROM
			#report_result 
where
(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
	ORDER BY 
			datetime_req
END




/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer]    Script Date: 03/16/2016 18:14:22 ******/
SET ANSI_NULLS ON




GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_mobility_acquired]    Script Date: 04/21/2016 10:12:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

















ALTER PROCEDURE[dbo].[osp_rpt_b04_mobility_acquired]
	@StartDate	    CHAR(8),	-- yyyymmdd
	@EndDate	    CHAR(8),	-- yyyymmdd
	@SourceNodes	    VARCHAR(40),
   	@SinkNode           VARCHAR(40),
	@BIN		    VARCHAR(40),
	--@CBNCode	    CHAR(3),
	@show_full_pan	    BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B06 report uses this stored proc.


	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'		

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255) NULL,	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
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
		rsp_code_description VARCHAR (MAX),
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
		extended_tran_type			CHAR(18),
		payee					CHAR(25),
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
			
	--CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 
	--INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BIN

	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,

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
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
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
						
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,

			master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.tran_reversed,
			extended_tran_type,
			payee,
			prev_tran_approved
	FROM
			post_tran t (NOLOCK, INDEX(ix_post_tran_9))
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (
			t.post_tran_cust_id = c.post_tran_cust_id
			 and
			  recon_business_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)
									AND
					t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0 
			AND
			t.tran_type IN ('50','00','40')
			
			)
			
			
	
WHERE 			
	(
			(		
           		(c.terminal_id like '4%' and 
master.dbo.fn_rpt_contains(card_acceptor_name_loc, 'MCN') = 0
				and c.source_node_name <> 'BILLSsrc')
			OR
			(c.terminal_id like '2%' and t.tran_type <> '00' and (
master.dbo.fn_rpt_contains(payee, '62805150') = 0
			OR payee is null) and c.source_node_name <> 'BILLSsrc')
			OR           		
			(
			(c.terminal_id like '1%')
			AND
			(master.dbo.fn_rpt_contains(payee, '62805150') = 0 OR payee is null)
			)
			)
			AND
			c.terminal_id not like '4GLO%' 					
			AND 
			c.source_node_name in (select source_node from #list_of_source_nodes) 
			and
			t.acquiring_inst_id_code in (select BIN from #list_of_BINs) 
			
			AND
				sink_node_name NOT IN ( SELECT part FROM dbo.usf_split_string('CCLOADsnk,GPRsnk,VTUsnk,VTUSTOCKsnk,PAYDIRECTsnk,SWTMEGAsnk,WUESBPBsnk',','))
 	
			)

            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             and (t.extended_tran_type <> '8234' or t.extended_tran_type is null)
             
             OPTION (RECOMPILE)

			IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT *
	FROM
			#report_result
WHERE
(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
	ORDER BY 
			datetime_req
END
































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_payment_gateway]    Script Date: 04/21/2016 10:12:28 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE [dbo].[osp_rpt_b04_payment_gateway]
	@StartDate	    CHAR(8),	-- yyyymmdd
	@EndDate	    CHAR(8),	-- yyyymmdd
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255) NULL,	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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
		TranID					BIGINT, 
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
	
	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM @report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 

	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs

        CREATE TABLE #list_of_sink_nodes (SinkNode	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode

	DECLARE @tbl_late_reversals TABLE (tran_nr BIGINT, retrieval_reference_nr VARCHAR(20))
        
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;
	select  @first_post_tran_cust_id = MIN (post_tran_cust_id),@last_post_tran_cust_id = max (post_tran_cust_id) FROM post_tran (nolock)
	where datetime_req BETWEEN @report_date_start AND ( 
	 CASE WHEN @report_date_start = @report_date_end THEN  DATEADD(D,1, @report_date_end)
	ELSE @report_date_end END) 
	
    ;WITH post_tran_table (
        	post_tran_cust_id,
			sink_node_name, 
			tran_type, 
			rsp_code_rsp, 
			message_type, 
			datetime_req,
			settle_amount_req,			
			settle_amount_rsp,
			settle_tran_fee_rsp,
			settle_currency_code,		
			tran_nr, 
			prev_post_tran_id, 
			system_trace_audit_nr, 
			message_reason_code, 
			retrieval_reference_nr, 
			datetime_tran_local, 
			from_account_type, 
			to_account_type, 
			from_account_id,
			to_account_id,  
			structured_data_req,
			settle_amount_impact,
			extended_tran_type,
			tran_reversed,
			payee
			) as  (
				SELECT
					post_tran_cust_id,
					sink_node_name, 
					tran_type, 
					rsp_code_rsp, 
					message_type, 
					datetime_req,
					settle_amount_req,			
					settle_amount_rsp,
					settle_tran_fee_rsp,
					settle_currency_code,		
					tran_nr, 
					prev_post_tran_id, 
					system_trace_audit_nr, 
					message_reason_code, 
					retrieval_reference_nr, 
					datetime_tran_local, 
					from_account_type, 
					to_account_type, 
					from_account_id,
					to_account_id,  
					structured_data_req,
					settle_amount_impact,
					extended_tran_type,
					tran_reversed,
					payee
			FROM 
			    post_tran (NOLOCK)	WHERE
			    
			recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)
				ANd
			tran_postilion_originated = 0
			and
			 sink_node_name NOT LIKE 'SB%'
AND 
			tran_completed = 1 
			),
			post_tran_cust_table (
			    post_tran_cust_id, 
				pan,
				terminal_id,
				card_acceptor_id_code, 
				card_acceptor_name_loc, 
				source_node_name,
				pan_encrypted,
				totals_group
		)  AS 
		(SELECT 
				 post_tran_cust_id, 
				pan,
				terminal_id,
				card_acceptor_id_code, 
				card_acceptor_name_loc, 
				source_node_name,
				pan_encrypted,
				totals_group
		 FROM 
		        post_tran_cust (NOLOCK)
		WHERE
					(post_tran_cust_id >= @first_post_tran_cust_id   )
			AND
			( post_tran_cust_id <= @last_post_tran_cust_id   ) 
			
			         AND
             source_node_name NOT LIKE 'SB%'
		)
			
                      
	INSERT
			INTO @report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			CASE WHEN @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
		ELSE
			pan
			END AS pan,
			c.terminal_id,
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			c.source_node_name,
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
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
			
			
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

			master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.tran_reversed,
			c.pan_encrypted,
			t.from_account_id,
			t.to_account_id,
			t.payee,
			c.totals_group,
                        isnull(t.extended_tran_type,'0000')	
	FROM
			post_tran_table t (NOLOCK) 
                                INNER JOIN 
                                post_tran_cust_table c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id) 
                          
WHERE 			
				((
			tran_type = '50'--this won't work for Autopay CCLoad cos the intrabank trans are 00
			AND
			sink_node_name NOT IN (SELECT part FROM dbo.usf_split_string('CCLOADsnk,PRsnk', ','))
			AND
			source_node_name NOT IN  (SELECT part FROM dbo.usf_split_string('CCLOADsrc,ASPSPNTFsrc,ASPSPONUSsrc', ','))
			
			AND
           		(terminal_id IN (SELECT part FROM dbo.usf_split_string('3EPY0701,3UIB0001,3IPD0010,3IPDTROT,3VRV0001,3IGW0010,3SFX0014', ',' ))
				or
 			LEFT(terminal_id, 4)  IN (SELECT part FROM dbo.usf_split_string('3IGW,3CCW,3IBH,3CPD,3011,3SFA', ','))
  			OR   LEFT(terminal_id, 5)   = '3ADPS'
                        OR 
		        (terminal_id = '3BOL0001' and extended_tran_type = '8502')

			)
			)OR
			terminal_id like '3CPD%' and t.tran_type = '00'
			OR
			(terminal_id like '3IPDFDT%' OR c.terminal_id like '3QTL002%') and message_type in ('0200','0420') and source_node_name <>'VTUsrc'
			
			)
			AND 
			( 
			   (@SinkNode IS NULL OR LEN(@SinkNode) = 0)
			OR (t.sink_node_name in (SELECT SinkNode FROM #list_of_sink_nodes)) 
			OR (substring(t.sink_node_name,4,3) in (select substring (SinkNode,4,3) from #list_of_sink_nodes))--and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			OR (
              LEFT(pan,6)IN (SELECT BIN FROM #list_of_BINs)and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			  OR LEFT(pan,6) = '628051' and (substring(c.totals_group,1,3)in (select substring (SinkNode,4,3) from #list_of_sink_nodes)) and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes)
			) 
option(recompile)

				
	


IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
	--ELSE
	--BEGIN
	--	--
	--	-- Decrypt PAN information if necessary
	--	--

	--	DECLARE @pan VARCHAR (19)
	--	DECLARE @pan_encrypted CHAR (18)
	--	DECLARE @pan_clear VARCHAR (19)
	--	DECLARE @process_descr VARCHAR (100)

	--	SET @process_descr = 'Office B04 Report'

	--	-- Get pan and pan_encrypted from @report_result and post_tran_cust using a cursor
	--	DECLARE pan_cursor CURSOR FORWARD_ONLY
	--	FOR
	--		SELECT
	--				pan,
	--				pan_encrypted
	--		FROM
	--				@report_result
	--	FOR UPDATE OF pan

	--	OPEN pan_cursor

	--	DECLARE @error INT
	--	SET @error = 0

	--	IF (@@CURSOR_ROWS <> 0)
	--	BEGIN
	--		FETCH pan_cursor INTO @pan, @pan_encrypted
	--		WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
	--		BEGIN
	--			-- Handle the decrypting of PANs
	--			EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

	--			-- Update the row if its different
	--			IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
	--			BEGIN
	--				UPDATE
	--					@report_result
	--				SET
	--					pan = @pan_clear
	--				WHERE
	--					CURRENT OF pan_cursor
	--			END

	--			FETCH pan_cursor INTO @pan, @pan_encrypted
	--		END
	--	END

	--	CLOSE pan_cursor
	--	DEALLOCATE pan_cursor

	--END			
	SELECT *
	FROM
			@report_result 
	
             where 
	 

(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 ) 
         		

			
	ORDER BY 
			datetime_req
			OPTION(recompile,maxdop 8)

END





























































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_payment_gateway_QTWEB]    Script Date: 04/21/2016 10:12:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE[dbo].[osp_rpt_b04_payment_gateway_QTWEB]
	@StartDate	    CHAR(8),	-- yyyymmdd
	@EndDate	    CHAR(8),	-- yyyymmdd
	--@SourceNodes	    VARCHAR(40),
   	--@terminal_IDs         VARCHAR(40),
   	--@SinkNode           VARCHAR(40),
	--@BINs		    VARCHAR(40),
	--@CBNCode	    CHAR(3),
	@show_full_pan	    BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
		SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255) NULL,	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
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
		rsp_code_description VARCHAR (MAX),
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
		totals_group			varchar(12)                      
	)			

	/*IF (@Terminal_IDs IS NULL or Len(@Terminal_IDs)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Terminal ID parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
    
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END*/
	
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

	/*CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 
	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs*/
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;


	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
					CASE WHEN @show_full_pan=1 THEN dbo.usf_decrypt_pan(c.pan, pan_encrypted)
					ELSE dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan)
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
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
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
			
			
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

			master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.tran_reversed,
			c.pan_encrypted,
			t.from_account_id,
			t.to_account_id,
			t.payee,
			c.totals_group	
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id
			and recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)
			
			)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id			
			AND
			t.tran_completed = 1
			AND
			t.tran_postilion_originated = 1
			AND
			
			tran_type = ('50')--this won't work for Autopay CCLoad cos the intrabank trans are 00
			AND
			sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
			AND
			source_node_name NOT IN ('CCLOADsrc')
			AND 
			t.tran_completed = 1 
			AND
           		(c.terminal_id = '3BOL0001' and t.extended_tran_type = '8502')
			AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
		        
			
			
				
	


IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
--	ELSE
--	BEGIN
--		--
--		-- Decrypt PAN information if necessary
--		--
--
--		DECLARE @pan VARCHAR (19)
--		DECLARE @pan_encrypted CHAR (18)
--		DECLARE @pan_clear VARCHAR (19)
--		DECLARE @process_descr VARCHAR (100)
--
--		SET @process_descr = 'Office B04 Report'
--
--		-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
--		DECLARE pan_cursor CURSOR FORWARD_ONLY
--		FOR
--			SELECT
--					pan,
--					pan_encrypted
--			FROM
--					#report_result
--		FOR UPDATE OF pan
--
--		OPEN pan_cursor
--
--		DECLARE @error INT
--		SET @error = 0
--
--		IF (@@CURSOR_ROWS <> 0)
--		BEGIN
--			FETCH pan_cursor INTO @pan, @pan_encrypted
--			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
--			BEGIN
--				-- Handle the decrypting of PANs
--				EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT
--
--				-- Update the row if its different
--				IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
--				BEGIN
--					UPDATE
--						#report_result
--					SET
--						pan = @pan_clear
--					WHERE
--						CURRENT OF pan_cursor
--				END
--
--				FETCH pan_cursor INTO @pan, @pan_encrypted
--			END
--		END
--
--		CLOSE pan_cursor
--		DEALLOCATE pan_cursor
--
--	END			
	SELECT *
	FROM
			#report_result

WHERE 
(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )

	ORDER BY 
			datetime_req
END








GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_POS_non_banks_T_OWNER]    Script Date: 04/21/2016 10:12:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


























ALTER PROCEDURE[dbo].[osp_rpt_b04_POS_non_banks_T_OWNER]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@Terminal_owner_Code		VARCHAR(255),
	--@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL

AS
BEGIN
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			VARCHAR(20),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req  TEXT,
		tran_reversed			BIGINT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
	        rdm_amount                      float,--Chioma added this 2012-07-03
                Reward_Discount                 float,--Chioma added this 2012-07-03
                Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03
                Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
                Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03
                Late_Reversal CHAR (1),
                Terminal_owner_code Varchar (4),
                Unique_key varchar (200)
              )

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*(IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END */
		
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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #terminal_owner_code (terminal_owner_code	VARCHAR(20)) 
	INSERT INTO  #terminal_owner_code EXEC osp_rpt_util_split_nodenames @terminal_owner_code
	-- Only look at 02xx messages that were not fully reversed.
	
	
DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,


				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1) THEN 1
						ELSE 0
					        END,
                                tt.Terminal_code,
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  (t.post_tran_cust_id = c.post_tran_cust_id and recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			))
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON c.merchant_type = s.category_code  
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id
                                
                
	
WHERE 			

				t.tran_completed = 1
				AND
(t.post_tran_id >= @first_post_tran_id   )
AND
( t.post_tran_id <= @last_post_tran_id   ) 	
AND 
t.datetime_req >=@report_date_start
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				(@terminal_owner_code IS NULL OR LEN(@terminal_owner_code) = 0 OR tt.terminal_code IN(SELECT terminal_owner_code FROM #terminal_owner_code))
                                AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31')
                                --and c.merchant_type not in ('5371')	
                               AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
			      and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			      and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			               and not(c.source_node_name = 'SWTFBPsrc' and t.sink_node_name = 'ASPPOSVISsnk'))
			      AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))	
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE q.source_node_name
				END),
				*/
				q.source_node_name,
				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,
				q.terminal_id, 
				q.acquiring_inst_id_code,
				q.terminal_owner,
				ISNULL(q.merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				q.card_acceptor_id_code, 
				q.card_acceptor_name_loc, 
				q.source_node_name,
				q.sink_node_name, 
				q.tran_type, 
				q.rsp_code_rsp, 
				q.message_type, 
				q.datetime_req,
				master.dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,
				
				q.tran_nr as TranID,
				q.prev_post_tran_id, 
				q.system_trace_audit_nr, 
				q.message_reason_code, 
				q.retrieval_reference_nr, 
				q.datetime_tran_local, 
				q.from_account_type, 
				q.to_account_type, 
				q.settle_currency_code, 
				
				--master.dbo.formatAmount(q.settle_amount_impact, q.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact
						ELSE q.settle_amount_impact
					END
					, q.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(q.tran_type, q.extended_tran_type, q.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(q.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(q.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(q.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(q.settle_currency_code) AS currency_name,


				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				q.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (q.post_tran_cust_id < @rpt_tran_id1) THEN 1
						ELSE 0
					        END,
                                tt.Terminal_code,
                 q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(12))+'_'+q.message_type	
	FROM
				asp_visa_pos q (NOLOCK)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON q.merchant_type = m.category_code and
				recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON q.merchant_type = s.category_code  
				left JOIN tbl_merchant_account a (NOLOCK)
				ON q.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (q.terminal_id= y.terminal_id 
                                    AND q.retrieval_reference_nr = y.rr_number 
                                    --AND q.system_trace_audit_nr = y.stan
                                    AND (-1 * q.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON q.terminal_id = tt.terminal_id
	WHERE 			
				
				--q.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				--AND
				q.tran_completed = 1
				AND
				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--q.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(q.message_type IN ('0100','0200', '0400', '0420')) 

				)
				AND 
				q.tran_completed = 1 
				--AND 
				--(q.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR q.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				(@terminal_owner_code IS NULL OR LEN(@terminal_owner_code) = 0 OR tt.terminal_code IN(SELECT terminal_owner_code FROM #terminal_owner_code))
                                --AND
				--q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(q.terminal_id like '3IWP%') OR
					(q.terminal_id like '3ICP%') OR
					(q.terminal_id like '2%')OR--(q.terminal_id like '2%' AND q.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(q.terminal_id like '5%') OR
                                        (q.terminal_id like '31WP%') OR
					(q.terminal_id like '31CP%') OR
					(q.terminal_id like '6%')
										)
				--AND
				--sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				q.tran_type NOT IN ('31')
                                --and q.merchant_type not in ('5371')	
                               --AND  NOT  (q.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)
                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))
			       and q.totals_group not in ('VISAGroup')
                 AND
             q.source_node_name  NOT LIKE 'SB%'
             AND
             q.sink_node_name  NOT LIKE 'SB%'
	--AND q.source_node_name  <> 'SWTMEGAsrc'AND q.source_node_name  <> 'SWTMEGADSsrc'
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


		
	SELECT 
			* 
	FROM 
			#report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where    

(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 ) 

          and
          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') 
          and unique_key  IN (SELECT unique_key FROM #temp_table))
          
	ORDER BY 
			source_node_name, datetime_req
END

















































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_POS_non_banks_T_OWNER_all]    Script Date: 04/21/2016 10:12:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




























ALTER PROCEDURE[dbo].[osp_rpt_b04_POS_non_banks_T_OWNER_all]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@Terminal_owner_Code		VARCHAR(255),
	--@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL

AS
BEGIN

		SET NOCOUNT ON
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			VARCHAR(20),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
                recon_business_date		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(max),
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
		rdm_amount                      float,--Chioma added this 2012-07-03
		Reward_Discount                 float,--Chioma added this 2012-07-03
		Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03
		Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
		Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
		Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
		Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03
		Late_Reversal CHAR (1),
		Terminal_owner_code Varchar (4),
		Unique_key varchar (200)
              )

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*(IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END */
		
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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        --CREATE TABLE #terminal_owner_code (terminal_owner_code	VARCHAR(20)) 
	--INSERT INTO  #terminal_owner_code EXEC osp_rpt_util_split_nodenames @terminal_owner_code
	-- Only look at 02xx messages that were not fully reversed.
	

	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	


	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local,
                                t.recon_business_date,
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,


				

				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1) THEN 1
						ELSE 0
					        END,
                                tt.Terminal_code,
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON c.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id
                                
             
	
WHERE 			

				t.tran_completed = 1
				AND
							(t.post_tran_id >= @first_post_tran_id) 
			AND 
			(t.post_tran_id <= @last_post_tran_id) 
			AND
			datetime_req >= @report_date_start
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				--AND
				--(@terminal_owner_code IS NULL OR LEN(@terminal_owner_code) = 0 OR tt.terminal_code IN(SELECT terminal_owner_code FROM #terminal_owner_code))
                                AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)

				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31')
                               -- and c.merchant_type not in ('5371')	
                AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
			     and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			      and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			               and not(c.source_node_name = 'SWTFBPsrc' and t.sink_node_name = 'ASPPOSVISsnk'))
			     AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))			
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE q.source_node_name
				END),
				*/
				q.source_node_name,
				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,
				q.terminal_id, 
				q.acquiring_inst_id_code,
				q.terminal_owner,
				ISNULL(q.merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				q.card_acceptor_id_code, 
				q.card_acceptor_name_loc, 
				q.source_node_name,
				q.sink_node_name, 
				q.tran_type, 
				q.rsp_code_rsp, 
				q.message_type, 
				q.datetime_req,
				master.dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,
				
				q.tran_nr as TranID,
				q.prev_post_tran_id, 
				q.system_trace_audit_nr, 
				q.message_reason_code, 
				q.retrieval_reference_nr, 
				q.datetime_tran_local,
                                q.recon_business_date,
				q.from_account_type, 
				q.to_account_type, 
				q.settle_currency_code, 
				
				--master.dbo.formatAmount(q.settle_amount_impact, q.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact
						ELSE q.settle_amount_impact
					END
					, q.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(q.tran_type, q.extended_tran_type, q.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(q.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(q.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(q.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(q.settle_currency_code) AS currency_name,


				

				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				q.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (q.post_tran_cust_id < @rpt_tran_id1) THEN 1
						ELSE 0
					        END,
                                tt.Terminal_code,
                 q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(12))+'_'+q.message_type	
	FROM
				asp_visa_pos q (NOLOCK)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON q.merchant_type = m.category_code 
				and
				recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON q.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON q.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (q.terminal_id= y.terminal_id 
                                    AND q.retrieval_reference_nr = y.rr_number 
                                    --AND q.system_trace_audit_nr = y.stan
                                    AND (-1 * q.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON q.terminal_id = tt.terminal_id
	WHERE 			
				
				--q.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				--AND
				q.tran_completed = 1
			
				AND
				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--q.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(q.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				q.tran_completed = 1 
				--AND 
				--(q.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR q.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				--AND
				--(@terminal_owner_code IS NULL OR LEN(@terminal_owner_code) = 0 OR tt.terminal_code IN(SELECT terminal_owner_code FROM #terminal_owner_code))
                               -- AND
				--q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(q.terminal_id like '3IWP%') OR
					(q.terminal_id like '3ICP%') OR
					(q.terminal_id like '2%')OR--(q.terminal_id like '2%' AND q.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(q.terminal_id like '5%') OR
                                        (q.terminal_id like '31WP%') OR
					(q.terminal_id like '31CP%') OR
					(q.terminal_id like '6%')
										)

				--AND
				--sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				q.tran_type NOT IN ('31')
                              --  and q.merchant_type not in ('5371')	
                --AND  NOT  (q.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)
                              -- not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))
			        and q.totals_group not in ('VISAGroup')		
                 AND
             q.source_node_name  NOT LIKE 'SB%'
             AND
             q.sink_node_name  NOT LIKE 'SB%'
	--AND q.source_node_name  <> 'SWTMEGAsrc'AND q.source_node_name  <> 'SWTMEGADSsrc'
	
	
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
and      (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )


--INSERT INTO Towner_PTSP_Session
--       SELECT (cast (recon_business_date as varchar(40)))+'_Terminal'  
--       FROM  #report_result

--        where rsp_code_rsp in ('00','11','08','10','16')
--and     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
--		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
--        WHERE ll.recon_business_date >= @report_date_start
--        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )


--	Group by recon_business_date
          
--IF(@@ERROR <>0)
--RETURN



--	Insert into Terminal_owners_T1_Status
--	SELECT 
		
		
--		terminal_id,
--		system_trace_audit_nr, 
--		retrieval_reference_nr,	
--		settle_amount_impact,			
--		terminal_owner_code,
--                Recon_business_date
                

--	FROM 
--			#report_result --rresult 
--                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
--where    
--          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') 
--          and unique_key  IN (SELECT unique_key FROM #temp_table))
--and      (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
--		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
--        WHERE ll.recon_business_date >= @report_date_start
--        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )

          
        
--	ORDER BY 
--			source_node_name, datetime_req 



		
	SELECT 
			* 
	FROM 
			#report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where    

          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') 
          and unique_key  IN (SELECT unique_key FROM #temp_table))
and     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )

          
	ORDER BY 
			source_node_name, datetime_req
END























































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_POS_PTSP]    Script Date: 04/21/2016 10:12:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


























ALTER PROCEDURE[dbo].[osp_rpt_b04_POS_PTSP]

	@StartDate		CHAR(8),	-- yyyymmdd

	@EndDate			CHAR(8),	-- yyyymmdd

	@PTSP_Code		VARCHAR(255),

	--@AcquirerInstId		VARCHAR(255),

	@SourceNodes	VARCHAR(512),

	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,

	@show_full_pan	BIT,

	@report_date_start DATETIME = NULL,

	@report_date_end DATETIME = NULL,

	@rpt_tran_id INT = NULL,

        @rpt_tran_id1 INT = NULL



AS

BEGIN



	SET NOCOUNT ON



	-- The B04 report uses this stored proc.

	



	--SET @StartDate = '20071122'

	--SET @EndDate = '20071125'	



	CREATE TABLE #report_result

	(

		Warning					VARCHAR (255),

		StartDate				VARCHAR (30),  

		EndDate				VARCHAR (30), 

		SourceNodeAlias 		VARCHAR (50),

		pan						VARCHAR (19), 

		terminal_id				CHAR (8), 

		acquiring_inst_id_code			VARCHAR(20),

		terminal_owner  		CHAR(12),

		merchant_type				CHAR (4),

                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03

		Category_name				VARCHAR(50),

		Fee_type				CHAR(1),

		merchant_disc				DECIMAL(7,4),

		fee_cap					FLOAT,

		amount_cap				FLOAT,

		bearer					CHAR(1),

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

		TranID					BIGINT,

		prev_post_tran_id		BIGINT, 

		system_trace_audit_nr	CHAR (6), 

		message_reason_code		CHAR (4), 

		retrieval_reference_nr	CHAR (12), 

		datetime_tran_local		DATETIME, 

		from_account_type		CHAR (2), 

		to_account_type			CHAR (2), 

		settle_currency_code	CHAR (3),				

		settle_amount_impact	FLOAT,			

		tran_type_desciption  VARCHAR (MAX),

		rsp_code_description	VARCHAR (30),

		settle_nr_decimals		BIGINT,

		currency_alpha_code		CHAR (3),

		currency_name			VARCHAR (20),		

		isPurchaseTrx			INT,

		isWithdrawTrx			INT,

		isRefundTrx				INT,

		isDepositTrx			INT,

		isInquiryTrx			INT,

		isTransferTrx			INT,

		isOtherTrx				INT,

		structured_data_req  TEXT,

		tran_reversed			INT,

		merchant_acct_nr		VARCHAR(50),	

		payee				VARCHAR(50),

		extended_tran_type		CHAR (4),

		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22

	        rdm_amount                     float,--Chioma added this 2012-07-03

                Reward_Discount                float,--Chioma added this 2012-07-03

                Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03

                Addit_Party                 Varchar (10),--Chioma added this 2012-07-03

                Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03

                Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03

                Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03

                Late_Reversal CHAR (1),

                PTSP_code Varchar (4),

                Unique_key varchar (200)

              )



	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	/*(IF (@Acquirer IS NULL or Len(@Acquirer)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')

	   	SELECT * FROM #report_result

		RETURN 1

	END */

		

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

        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 



	IF (@report_date_end < @report_date_start)

	BEGIN

	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)

	BEGIN

	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')


	   	SELECT * FROM #report_result

		RETURN 1

	END


*/


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	

	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 

	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants



        CREATE TABLE #PTSP_code (PTSP_code	VARCHAR(20)) 

	INSERT INTO  #PTSP_code EXEC osp_rpt_util_split_nodenames @PTSP_code

	-- Only look at 02xx messages that were not fully reversed.

	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

	INSERT

				INTO #report_result

	SELECT

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				/*SourceNodeAlias = 

				(CASE 

					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE c.source_node_name

				END),

				*/

				c.source_node_name,

				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,

				c.terminal_id, 

				t.acquiring_inst_id_code,

				c.terminal_owner,

				ISNULL(c.merchant_type,'VOID'),

                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),

				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 

				else ISNULL(m.Category_name,'VOID') end,

				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 

				else ISNULL(m.Fee_type,'VOID') end,

				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 

				else ISNULL(m.merchant_disc,0.0) end,

				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 

				else ISNULL(m.fee_cap,0) end,

				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 

				else ISNULL(m.amount_cap,999999999999.99) end,

				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 

				else ISNULL(m.bearer,'M') end,

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 

				c.source_node_name,

				t.sink_node_name, 

				t.tran_type, 

				t.rsp_code_rsp, 

				t.message_type, 

				t.datetime_req,

				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				

				t.post_tran_cust_id as TranID,

				t.prev_post_tran_id, 

				t.system_trace_audit_nr, 

				t.message_reason_code, 

				t.retrieval_reference_nr, 

				t.datetime_tran_local, 

				t.from_account_type, 

				t.to_account_type, 

				t.settle_currency_code, 

				

				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,

				

				master.dbo.formatAmount( 			

					CASE

						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact

						ELSE t.settle_amount_impact

					END

					, t.settle_currency_code ) AS settle_amount_impact,				

				

				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,

				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,




				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,

				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				master.dbo.currencyName(t.settle_currency_code) AS currency_name,



				

				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,

				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,

				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,

				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,

				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,

				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,

				1,

				t.tran_reversed,

				ISNULL(account_nr,'not available'),

				payee,--oremeyi added this 2009-04-22

				extended_tran_type,

				receiving_inst_id_code,--oremeyi added this 2010-02-28

				ISNULL(y.rdm_amt,0),


                                R.Reward_Discount,

                                R.Addit_Charge,

                                R.Addit_Party,

                                R.Amount_Cap,

                                R.Fee_Cap,

                                R.Fee_Discount,

                                Late_Reversal_id = CASE

						WHEN (t.post_tran_cust_id < @rpt_tran_id1) THEN 1

						ELSE 0

					        END,

                                tp.PTSP_code,

                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type		

	FROM

				post_tran t (NOLOCK)

				INNER JOIN post_tran_cust c (NOLOCK)

				ON  t.post_tran_cust_id = c.post_tran_cust_id

				left JOIN tbl_merchant_category m (NOLOCK)

				ON c.merchant_type = m.category_code 

				left JOIN tbl_merchant_category_visa s (NOLOCK)

				ON c.merchant_type = s.category_code 

				left JOIN tbl_merchant_account a (NOLOCK)

				ON c.card_acceptor_id_code = a.card_acceptor_id_code   

				left JOIN tbl_xls_settlement y (NOLOCK)



				ON (c.terminal_id= y.terminal_id 

                                    AND t.retrieval_reference_nr = y.rr_number 

                                    --AND t.system_trace_audit_nr = y.stan

                                    AND (-1 * t.settle_amount_impact)/100 = y.amount

                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)

                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)

                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

				left JOIN Reward_Category r (NOLOCK)

                                ON y.extended_trans_type = r.reward_code

                                left JOIN tbl_PTSP tp (NOLOCK)

                                ON c.terminal_id = tp.terminal_id
                                
                   
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

		
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	

				AND

				t.tran_completed = 1

				AND

				(t.recon_business_date >= @report_date_start) 

				AND 

				(t.recon_business_date <= @report_date_end) 

				AND

				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 

				--AND

				--t.message_type IN ('0200', '0220', '0400', '0420') 

				AND


				(

				(t.message_type IN ('0100','0200', '0400', '0420')) 

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='533853')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='522145')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='539983')

				)

				AND 

				t.tran_completed = 1 

				--AND 

				--(t.acquiring_inst_id_code = @AcquirerInstId)

				AND

				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))

				AND

				(@PTSP_code IS NULL OR LEN(@PTSP_code) = 0 OR tp.PTSP_code IN(SELECT PTSP_code FROM #PTSP_code))

                                AND

				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

				AND 

					(

					(c.terminal_id like '3IWP%') OR

					(c.terminal_id like '3ICP%') OR

					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))

					(c.terminal_id like '5%') OR

                                        (c.terminal_id like '31WP%') OR

					(c.terminal_id like '31CP%') OR

					(c.terminal_id like '6%')

										)

				AND

				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk

				AND

				t.tran_type NOT IN ('31')

                               -- and c.merchant_type not in ('5371')

                AND  NOT  (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))

			      and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			      and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			               and not(c.source_node_name = 'SWTFBPsrc' and t.sink_node_name = 'ASPPOSVISsnk'))	
			      AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))	



                AND

             c.source_node_name  NOT LIKE 'SB%'

             AND

             t.sink_node_name  NOT LIKE 'SB%'

	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'
	
		INSERT

				INTO #report_result

	SELECT

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				/*SourceNodeAlias = 

				(CASE 

					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE q.source_node_name

				END),

				*/

				q.source_node_name,

				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,

				q.terminal_id, 

				q.acquiring_inst_id_code,

				q.terminal_owner,

				ISNULL(q.merchant_type,'VOID'),

                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),

				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 

				else ISNULL(m.Category_name,'VOID') end,

				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 

				else ISNULL(m.Fee_type,'VOID') end,

				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 

				else ISNULL(m.merchant_disc,0.0) end,

				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 

				else ISNULL(m.fee_cap,0) end,

				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 

				else ISNULL(m.amount_cap,999999999999.99) end,

				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 

				else ISNULL(m.bearer,'M') end,

				q.card_acceptor_id_code, 

				q.card_acceptor_name_loc, 

				q.source_node_name,

				q.sink_node_name, 

				q.tran_type, 

				q.rsp_code_rsp, 

				q.message_type, 

				q.datetime_req,

				master.dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 

				master.dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,

				

				q.post_tran_cust_id as TranID,

				q.prev_post_tran_id, 

				q.system_trace_audit_nr, 

				q.message_reason_code, 

				q.retrieval_reference_nr, 

				q.datetime_tran_local, 

				q.from_account_type, 

				q.to_account_type, 

				q.settle_currency_code, 

				

				--master.dbo.formatAmount(q.settle_amount_impact, q.settle_currency_code) as settle_amount_impact,

				

				master.dbo.formatAmount( 			

					CASE

						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact

						ELSE q.settle_amount_impact

					END

					, q.settle_currency_code ) AS settle_amount_impact,				

				

				master.dbo.formatTranTypeStr(q.tran_type, q.extended_tran_type, q.message_type) as tran_type_desciption,

				master.dbo.formatRspCodeStr(q.rsp_code_rsp) as rsp_code_description,




				master.dbo.currencyNrDecimals(q.settle_currency_code) AS settle_nr_decimals,

				master.dbo.currencyAlphaCode(q.settle_currency_code) AS currency_alpha_code,

				master.dbo.currencyName(q.settle_currency_code) AS currency_name,



				

				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,

				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,

				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,

				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,

				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,

				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,

				1,

				q.tran_reversed,

				ISNULL(account_nr,'not available'),

				payee,--oremeyi added this 2009-04-22

				extended_tran_type,

				receiving_inst_id_code,--oremeyi added this 2010-02-28

				ISNULL(y.rdm_amt,0),


                                R.Reward_Discount,

                                R.Addit_Charge,

                                R.Addit_Party,

                                R.Amount_Cap,

                                R.Fee_Cap,

                                R.Fee_Discount,

                                Late_Reversal_id = CASE

						WHEN (q.post_tran_cust_id < @rpt_tran_id1) THEN 1

						ELSE 0

					        END,

                                tp.PTSP_code,

                 q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(12))+'_'+q.message_type		

	FROM

				asp_visa_pos q (NOLOCK)

				left JOIN tbl_merchant_category m (NOLOCK)

				ON q.merchant_type = m.category_code 

				left JOIN tbl_merchant_category_visa s (NOLOCK)

				ON q.merchant_type = s.category_code 

				left JOIN tbl_merchant_account a (NOLOCK)

				ON q.card_acceptor_id_code = a.card_acceptor_id_code   

				left JOIN tbl_xls_settlement y (NOLOCK)



				ON (q.terminal_id= y.terminal_id 

                                    AND q.retrieval_reference_nr = y.rr_number 

                                    --AND q.system_trace_audit_nr = y.stan

                                    AND (-1 * q.settle_amount_impact)/100 = y.amount

                                    AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)

                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)

                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

				left JOIN Reward_Category r (NOLOCK)

                                ON y.extended_trans_type = r.reward_code

                                left JOIN tbl_PTSP tp (NOLOCK)

                                ON q.terminal_id = tp.terminal_id

	WHERE 			

				

				--q.post_tran_cust_id >= @rpt_tran_id--'81530747'	

				--AND

				q.tran_completed = 1

				AND

				(q.recon_business_date >= @report_date_start) 

				AND 

				(q.recon_business_date <= @report_date_end) 

				AND

				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 

				--AND

				--q.message_type IN ('0200', '0220', '0400', '0420') 

				AND


				(

				q.message_type IN ( SELECT part FROM dbo.usf_split_string('0100,0200,0400,0420', ',')) 

				---OR

				---(q.message_type IN ('0100')and left(pan,6)='533853')

				---OR

				---(q.message_type IN ('0100')and left(pan,6)='522145')

				---OR

				---(q.message_type IN ('0100')and left(pan,6)='539983')

				)

				AND 

				q.tran_completed = 1 

				--AND 

				--(q.acquiring_inst_id_code = @AcquirerInstId)

				AND

				(@merchants IS NULL OR LEN(@merchants) = 0 OR q.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))

				AND

				(@PTSP_code IS NULL OR LEN(@PTSP_code) = 0 OR tp.PTSP_code IN(SELECT PTSP_code FROM #PTSP_code))

                                --AND

				--q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

				AND 

					(

			
			(
					(CHARINDEX (  '3IWP', q.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', q.terminal_id) > 0 ) OR
					(LEFT(q.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(q.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', q.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', q.terminal_id) > 0) OR
					( LEFT(q.terminal_id,1) = '6')
					)

										)

				--AND

				--sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk

				AND

				q.tran_type NOT IN ('31')

                -- and q.merchant_type not in ('5371')

                --AND  NOT  (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)

                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))

			        and q.totals_group not in ('VISAGroup')		



                AND

             q.source_node_name  NOT LIKE 'SB%'

             AND

             q.sink_node_name  NOT LIKE 'SB%'

	--AND q.source_node_name  <> 'SWTMEGAsrc'AND q.source_node_name  <> 'SWTMEGADSsrc'

	

	IF @@ROWCOUNT = 0

		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			

	create table #temp_table

(unique_key varchar(200))



insert into #temp_table 

select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')





		

	SELECT 

			* 

	FROM 

			#report_result --rresult 

                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)

where    



          not(source_node_name in (dbo.usf_split_string('SWTNCS2src,SWTSHOPRTsrc,SWTNCSKIMsrc,SWTNCSKI2src,SWTFBPsrc', ','))

          and unique_key  IN (SELECT unique_key FROM #temp_table))
          

	ORDER BY 

			source_node_name, datetime_req

END














































































































































































































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_POS_PTSP_all]    Script Date: 04/21/2016 10:12:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














ALTER PROCEDURE[dbo].[osp_rpt_b04_POS_PTSP_all]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@Terminal_owner_Code		VARCHAR(255),
	--@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL

AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (255),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			VARCHAR(100),
		terminal_owner  		VARCHAR(100),
		merchant_type				CHAR (4),
                extended_tran_type_reward               VARCHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(255),
		Fee_type				VARCHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					VARCHAR(1),
		card_acceptor_id_code	 VARCHAR (255),	 
		card_acceptor_name_loc	VARCHAR (255), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			VARCHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	VARCHAR (12), 
		datetime_tran_local		DATETIME, 
                recon_business_date		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	VARCHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		VARCHAR (3),
		currency_name			VARCHAR (50),		
		isPurchaseTrx			BIGINT,
		isWithdrawTrx			BIGINT,
		isRefundTrx				BIGINT,
		isDepositTrx			BIGINT,
		isInquiryTrx			BIGINT,
		isTransferTrx			BIGINT,
		isOtherTrx				BIGINT,
		structured_data_req		VARCHAR(max),
		tran_reversed			BIGINT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (50),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
		rdm_amount                      float,--Chioma added this 2012-07-03
		Reward_Discount                 float,--Chioma added this 2012-07-03
		Addit_Charge                 DECIMAL(15,4),--Chioma added this 2012-07-03
		Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
		Amount_Cap_RD               DECIMAL(15,4),--Chioma added this 2012-07-03
		Fee_Cap_RD               DECIMAL(15,2),--Chioma added this 2012-07-03
		Fee_Discount_RD          DECIMAL(15,2),--Chioma added this 2012-07-03
                Late_Reversal CHAR (1),
                PTSP_code Varchar (4),
                Unique_key varchar (200)
              )

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*(IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END */
		
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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(255)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        --CREATE TABLE #terminal_owner_code (terminal_owner_code	VARCHAR(20)) 
	--INSERT INTO  #terminal_owner_code EXEC osp_rpt_util_split_nodenames @terminal_owner_code
	-- Only look at 02xx messages that were not fully reversed.


	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT

        

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;


	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (c.merchant_type,c.terminal_id,t.tran_type,c.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
                                t.recon_business_date,
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,


				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1) THEN 1
						ELSE 0
					        END,
                                tp.PTSP_code,
                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(15))+'_'+t.message_type	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON c.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_PTSP tp (NOLOCK)
                                ON c.terminal_id = tp.terminal_id
                                
                  
	
WHERE 			
	

				t.tran_completed = 1
				AND
				
   			    (t.post_tran_id >= @first_post_tran_id) 
			AND 
			(t.post_tran_id <= @last_post_tran_id) 
			AND
			datetime_req >= @report_date_start
				--   datetime_req>=@report_date_start
				--AND
				--post_tran_id >=@first_post_tran_id
				--AND 
				--post_tran_id <= @last_post_tran_id
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				--AND
				--(@terminal_owner_code IS NULL OR LEN(@terminal_owner_code) = 0 OR tt.terminal_code IN(SELECT terminal_owner_code FROM #terminal_owner_code))
                                AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31')
                               -- and c.merchant_type not in ('5371')	
                AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))
				 and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			     and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			              and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk')
                           )
                  AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))		


                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE q.source_node_name
				END),
				*/
				q.source_node_name,
				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,
				q.terminal_id, 
				q.acquiring_inst_id_code,
				q.terminal_owner,
				ISNULL(q.merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(s.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				q.card_acceptor_id_code, 
				q.card_acceptor_name_loc, 
				q.source_node_name,
				q.sink_node_name, 
				q.tran_type, 
				q.rsp_code_rsp, 
				q.message_type, 
				q.datetime_req,
				master.dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,
				
				q.tran_nr as TranID,
				q.prev_post_tran_id, 
				q.system_trace_audit_nr, 
				q.message_reason_code, 
				q.retrieval_reference_nr, 
				q.datetime_tran_local, 
                                q.recon_business_date,
				q.from_account_type, 
				q.to_account_type, 
				q.settle_currency_code, 
				
				--master.dbo.formatAmount(q.settle_amount_impact, q.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact
						ELSE q.settle_amount_impact
					END
					, q.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(q.tran_type, q.extended_tran_type, q.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(q.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(q.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(q.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(q.settle_currency_code) AS currency_name,


				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				1,
				q.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (q.post_tran_cust_id < @rpt_tran_id1) THEN 1
						ELSE 0
					        END,
                                tp.PTSP_code,
                 q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(15))+'_'+q.message_type	
	FROM
				asp_visa_pos q (NOLOCK)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON q.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON q.merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON q.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (q.terminal_id= y.terminal_id 
                                    AND q.retrieval_reference_nr = y.rr_number 
                                    --AND q.system_trace_audit_nr = y.stan
                                    AND (-1 * q.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_PTSP tp (NOLOCK)
                                ON q.terminal_id = tp.terminal_id
              

	WHERE 			
				
				--q.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				--AND
				q.tran_completed = 1
				AND
				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--q.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(q.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(q.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				q.tran_completed = 1 
				--AND 
				--(q.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR q.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				--AND
				--(@terminal_owner_code IS NULL OR LEN(@terminal_owner_code) = 0 OR tt.terminal_code IN(SELECT terminal_owner_code FROM #terminal_owner_code))
                                --AND
				--q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(q.terminal_id like '3IWP%') OR
					(q.terminal_id like '3ICP%') OR
					(q.terminal_id like '2%')OR--(q.terminal_id like '2%' AND q.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(q.terminal_id like '5%') OR
                                        (q.terminal_id like '31WP%') OR
					(q.terminal_id like '31CP%') OR
					(q.terminal_id like '6%')
										)
				--AND
				--sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','CUPsnk')	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				q.tran_type NOT IN ('31')
                               -- and q.merchant_type not in ('5371')	
                --AND  NOT  (q.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)
                            --   not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))
				and q.totals_group not in ('VISAGroup')	

                AND
             q.source_node_name  NOT LIKE 'SB%'
             AND
             q.sink_node_name  NOT LIKE 'SB%'
	--AND q.source_node_name  <> 'SWTMEGAsrc'AND q.source_node_name  <> 'SWTMEGADSsrc'
			
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
and     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )


--INSERT INTO Towner_PTSP_Session
--       SELECT (cast (recon_business_date as varchar(40)))+'_PTSP'  
--       FROM  #report_result

--        where rsp_code_rsp in ('00','11','08','10','16')
--and      (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
--		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
--        WHERE ll.recon_business_date >= @report_date_start
--        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )

--	Group by recon_business_date
          
--IF(@@ERROR <>0)
--RETURN



--	Insert into PTSP_T1_Status
--	SELECT 
--			                terminal_id,
--		system_trace_audit_nr, 
--		retrieval_reference_nr,	
--		settle_amount_impact,			
--		PTSP_code,
--                Recon_business_date

--	FROM 
--			#report_result --rresult 
--                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
--where    
--         not (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') 
--          and unique_key  IN (SELECT unique_key FROM #temp_table))
--AND
--          (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
--		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
--        WHERE ll.recon_business_date >= @report_date_start
--        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )

        
--	ORDER BY 
--			source_node_name, datetime_req 


		
	SELECT 
			* 
	FROM 
			#report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where    

          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') 
          and unique_key  IN (SELECT unique_key FROM #temp_table))
         and      (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )

	ORDER BY 
			source_node_name, datetime_req
END


























































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_POS_VISA_COACQUIRED]    Script Date: 04/21/2016 10:12:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO














ALTER PROCEDURE[dbo].[osp_rpt_b04_POS_VISA_COACQUIRED]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id1 INT = NULL,
    @rpt_tran_id INT = NULL
        

AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (255), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(255),
		terminal_owner  		CHAR(255),
		merchant_type				CHAR (4),
                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (255), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		VARCHAR (8), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),		
		settle_amount_impact	float,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		tran_reversed			INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		extended_tran_type		CHAR (4),
                rdm_amount                      float,
                Reward_Discount                float,
                Addit_Charge                 DECIMAL(7,6),
                Addit_Party                 Varchar (28),
                Amount_Cap_RD               DECIMAL(9,0),
                Fee_Cap_RD               DECIMAL(9,0),
                Fee_Discount_RD          DECIMAL(9,7) ,
                Totalsgroup varchar (40),
                aggregate_column         VARCHAR(200),
                Unique_key varchar (200),
				tran_cash_req  float,
tran_cash_rsp  float,
        	tran_tran_fee_rsp  float,
			tran_currency_code      VARCHAR (50)
        
                     
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END*/
		
	
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
	--EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
IF (@StartDate IS NULL OR @StartDate ='') 
		BEGIN 
			SELECT @StartDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		IF (@EndDate IS NULL OR @EndDate ='') 
		BEGIN 
			SELECT @EndDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		
	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		


		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET  @report_date_start = CONVERT(CHAR(8),@StartDate , 112)
	SET @report_date_end = CONVERT(CHAR(8),@EndDate , 112)

	EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 
    EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	

	DECLARE  @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes,',')

 --   DECLARE @first_post_tran_cust_id BIGINT
	--DECLARE @last_post_tran_cust_id BIGINT
	--DECLARE @first_post_tran_id BIGINT
	--DECLARE @last_post_tran_id BIGINT


	--IF(@report_date_start<> @report_date_end) BEGIN
	--	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	--	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	--END
	--ELSE IF(@report_date_start= @report_date_end) BEGIN
	--	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	--	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	--SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	--	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	--	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	--END


	/*CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes*/
	-- Only look at 02xx messages that were not fully reversed.
	

	
INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = 'BURN',
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				
				
				0, 
				0,
				0,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				isnull(t.payee,0),
				t.extended_tran_type,
                                ISNULL(y.rdm_amt,0),
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                c.totals_group,
                  t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50)),
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
				 
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code

                	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id and
				recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code
                                
                                
	
WHERE 			
	

				t.tran_completed = 1
				
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				t.message_type IN ( SELECT PART FROM usf_split_string('0220,0200,0400,0420', ',') )
 				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
										(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)
					
				AND
				t.sink_node_name NOT IN ( SELECT part FROM  usf_split_string('CCLOADsnk,GPRsnk,PAYDIRECTsnk,SWTMEGAsnk,VTUsnk,VTUSTOCKsnk', ','))------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                -- and c.merchant_type not in ('5371')
                 and ISNULL(y.rdm_amt,0) <>0
                 --AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND t.sink_node_name+LEFT(totals_group,3)
                 --              not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4')
                 --and c.totals_group not in ('VISAGroup')
                AND
           c.source_node_name NOT LIKE 'SB%'
              AND 
			  t.sink_node_name NOT LIKE 'SB%'
			  
			  ---AND not( t.sink_node_name   LIKE 'SB%')


	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = 
                                Case When c.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband (NOLOCK))
                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				isnull(t.payee,0),
				t.extended_tran_type,
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                c.totals_group,
                 t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(50)),
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
				
                                master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
		
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code
                 	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id and
recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)

				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                
                                 ON c.terminal_id = o.terminal_id
                                left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code  
                                                                                            and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
                                
	
WHERE 			
	
				 t.tran_completed = 1
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(t.message_type IN ('0220','0200', '0400', '0420') )
				---(
				---(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				
				--AND 
				---(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
					(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)
				AND
				t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                             --   and c.merchant_type not in ('5371')
                               -- AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc') AND t.sink_node_name+LEFT(totals_group,3)
                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4')
                               -- and c.totals_group not in ('VISAGroup')
                AND
              LEFT( c.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB' --AND not( t.sink_node_name   LIKE 'SB%')

				
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
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


create table #temp_table_1
(aggregate_column varchar(200), counts float )
insert into #temp_table_1 select aggregate_column, count(aggregate_column) from @report_result
group by aggregate_column

update @report_result
set tran_type_desciption = tran_type_desciption+ '_M'
where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)

		
--	create table #temp_table
--(unique_key varchar(200))

--insert into #temp_table 
--select unique_key from @report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


		
	SELECT 
			* 
	FROM 
			@report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where    

          ((source_node_name ='SWTNCS2src' AND sink_node_name = 'ASPPOSVINsnk')
           or  (totalsgroup in ('VISAGroup') and source_node_name = 'SWTFBPsrc' and sink_node_name = 'ASPPOSVISsnk'))
		   and 
		   (convert(varchar(50),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
                                
		
         -- and unique_key  IN (SELECT unique_key FROM #temp_table))
          --and left(pan,1) ='4'
          AND acquiring_inst_id_code <> '627787'
          

                                       
      
         
      
      -- and (source_node_name = 'SWTNCS2src' and sink_node_name = 'ASPPOSLMCsnk')
	ORDER BY 
			source_node_name, datetime_req, message_type
END













GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Verve_Int]    Script Date: 04/21/2016 10:12:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE[dbo].[osp_rpt_b04_Verve_Int]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),	-- Seperated by commas
	@show_full_pan		INT,		-- 0/1/2: Masked/Clear/As is
        @rpt_tran_id INT = NULL
AS
BEGIN
	-- The B04 report uses this stored proc.
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate				VARCHAR (30),
		EndDate				VARCHAR (30),
		SourceNodeAlias 		VARCHAR (50),
		pan							VARCHAR (19),
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
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
		tran_reversed				INT,
		acquiring_inst_id_code    VARCHAR (25),
                tran_postilion_originated          CHAR (1)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals

	IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = 'Last business day'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	
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

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

        CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode

	-- Only look at 02xx messages that were not fully reversed.


SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

create table #foreign_amt
(foreign_amount float, foreign_fee float, TranID BIGINT)

	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

Insert into #foreign_amt 

select -1 * p.settle_amount_impact/100, 
master.dbo.formatAmount(-1 * p.settle_tran_fee_rsp/100, p.settle_currency_code) AS settle_tran_fee_rsp,
p.post_tran_cust_id  from post_tran p WITH (NOLOCK)
                                
                                 INNER JOIN
				 post_tran_cust c WITH (NOLOCK) ON (p.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
 (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

                                 --c.post_tran_cust_id >= @rpt_tran_id
			         AND p.tran_postilion_originated = 0
                                 and
                            
      					(P.post_tran_id >= @first_post_tran_id) 
					AND 
					(P.post_tran_id <= @last_post_tran_id) 
					AND
				datetime_req >= @report_date_start 

				
				AND
				p.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				p.tran_completed = 1
				AND 
				(substring (c.totals_group,1,3)in (select substring(Sink_node,4,3) from  #list_of_sink_nodes ))
                                AND
				p.tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             p.sink_node_name  NOT LIKE 'SB%'


	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				SourceNodeAlias =
				(CASE
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
			c.pan,
			c.terminal_id,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,
		
						
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,

			t.settle_currency_code,


			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (t.message_type IN ('0220','0420') AND NOT t.rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			t.Auth_id_rsp,
			t.tran_reversed,
			t.acquiring_inst_id_code,
                        t.tran_postilion_originated
	FROM
				post_tran t WITH (NOLOCk)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id
				and
recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)

				
				)
				
			
WHERE 			
	
			          t.tran_completed = 1
				AND
				
      					
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ( SELECT PART  FROM usf_split_string('0100,0120,0200,0220,0400,0420',','))
				AND
				t.tran_completed = 1
				AND 
				(substring (c.totals_group,1,3)in (select substring(Sink_node,4,3) from  #list_of_sink_nodes ))
                                AND
				t.tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                             (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'


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
			distinct 
			r.*,f.*
	FROM
			#report_result r
      inner join #foreign_amt f
      on r.tranId = f.tranId 
      where r.tran_postilion_originated = 1
	ORDER BY  r.datetime_tran_local
END









GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web]    Script Date: 04/21/2016 10:12:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












ALTER PROCEDURE [dbo].[osp_rpt_b04_web]

	@StartDate		CHAR(8),	-- yyyymmdd

	@EndDate			CHAR(8),	-- yyyymmdd

	@SinkNodes		VARCHAR(510),

	@SourceNodes	VARCHAR(512),

	@show_full_pan	BIT,

	@report_date_start DATETIME = NULL,

	@report_date_end DATETIME = NULL,

	@rpt_tran_id INT = NULL,

    @rpt_tran_id1 INT = NULL,
    
    @Extended_tran_type varchar (20)



AS

BEGIN

	SET NOCOUNT ON
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	

	CREATE TABLE #report_result

	(

		Warning					VARCHAR (255),

		StartDate				CHAR (8),  

		EndDate					CHAR (8), 

		SourceNodeAlias 		VARCHAR (50),

		pan						VARCHAR (255), 

		terminal_id				CHAR (8), 

		acquiring_inst_id_code			CHAR(255),

		terminal_owner  		CHAR(255),

		merchant_type				CHAR (4),

                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03

		Category_name				VARCHAR(50),

		Fee_type				CHAR(1),

		merchant_disc				DECIMAL(7,4),

		fee_cap					FLOAT,

		amount_cap				FLOAT,

		bearer					CHAR(1),

		card_acceptor_id_code	CHAR (15),	 

		card_acceptor_name_loc	CHAR (255), 

		source_node_name		VARCHAR (40), 

		sink_node_name			VARCHAR (40), 

		tran_type				CHAR (2), 

		rsp_code_rsp			CHAR (2), 

		message_type			CHAR (4), 

		datetime_req			DATETIME, 				

		settle_amount_req		FLOAT, 

		settle_amount_rsp		FLOAT,

		settle_tran_fee_rsp		FLOAT,				

		TranID					BIGINT,

		prev_post_tran_id		BIGINT, 

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

		settle_nr_decimals		BIGINT,

		currency_alpha_code		CHAR (3),

		currency_name			VARCHAR (20),		

		isPurchaseTrx			INT,

		isWithdrawTrx			INT,

		isRefundTrx				INT,

		isDepositTrx			INT,

		isInquiryTrx			INT,

		isTransferTrx			INT,

		isOtherTrx				INT,

		tran_reversed			INT,

		pan_encrypted			CHAR(18),

		from_account_id			VARCHAR(28),

		to_account_id			VARCHAR(28),

		payee				char(25),

		extended_tran_type		CHAR (4),

                rdm_amount                      Float,

                Reward_Discount                 Float,

                Addit_Charge                 DECIMAL(7,6),

                Addit_Party                 Varchar (10),

                Amount_Cap_RD               DECIMAL(9,0),

                Fee_Cap_RD               DECIMAL(9,0),

                Fee_Discount_RD          DECIMAL(9,7),

                Late_Reversal CHAR (1),

		totals_group		Varchar(40),

                aggregate_column         VARCHAR(200),

                Unique_key varchar (200),

        auth_id_rsp Varchar(200),

tran_cash_req  FLOAT,

tran_cash_rsp  FLOAT,

        	tran_tran_fee_rsp  FLOAT,

			tran_currency_code      VARCHAR (50)      

	)



	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')

	   	SELECT * FROM #report_result

		RETURN 1

	END

		

	

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

    EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 



	IF (@report_date_end < @report_date_start)

	BEGIN

	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	



	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

	

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

--INSERT INTO  #list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',')

	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 

	

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
		CREATE TABLE #list_of_ETT (ETT	VARCHAR(20)) 

	

	INSERT INTO  #list_of_ETT EXEC osp_rpt_util_split_nodenames @extended_tran_type


	-- Only look at 02xx messages that were not fully reversed.

	INSERT

				INTO #report_result

	SELECT

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				SourceNodeAlias = 

				(CASE 

					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE c.source_node_name

				END),

				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,

				c.terminal_id, 

				t.acquiring_inst_id_code,

				c.terminal_owner,

				ISNULL(c.merchant_type,'VOID'),

                                extended_trans_type = Case When c.terminal_id in 

                                (select terminal_id from tbl_reward_OutOfband)

                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 

                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,

				ISNULL(m.Category_name,'VOID'),

				ISNULL(m.Fee_type,'VOID'),

				ISNULL(m.merchant_disc,0.0),

				ISNULL(m.fee_cap,0),

				ISNULL(m.amount_cap,999999999999.99),

				ISNULL(m.bearer,'M'),

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 

				c.source_node_name,

				t.sink_node_name, 

				t.tran_type, 

				t.rsp_code_rsp, 

				t.message_type, 

				t.datetime_req, 

				

				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				

				t.post_tran_cust_id as TranID,

				t.prev_post_tran_id, 

				t.system_trace_audit_nr, 

				t.message_reason_code, 

				t.retrieval_reference_nr, 

				t.datetime_tran_local, 

				t.from_account_type, 

				t.to_account_type, 

				t.settle_currency_code, 

				

				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,

				

				master.dbo.formatAmount( 			

					CASE

						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact

						ELSE t.settle_amount_impact

					END

					, t.settle_currency_code ) AS settle_amount_impact,				

				

				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,

				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,

				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,

				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				master.dbo.currencyName(t.settle_currency_code) AS currency_name,

				

				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,

				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,

				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,

				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,


				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,

				t.tran_reversed,

				c.pan_encrypted,

				t.from_account_id,

				t.to_account_id,

				t.payee,


				t.extended_tran_type,

                                ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,

                                R.Addit_Charge,

                                R.Addit_Party,

                                R.Amount_Cap,

                                R.Fee_Cap,

                                R.Fee_Discount,

                                Late_Reversal_id = CASE

						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1

						ELSE 0

					        END,	

				c.totals_group,

                                t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(12))+'_'+c.pan,

                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,

                t.auth_id_rsp,



master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 

				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,

				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,

				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code

	 	

	FROM

				post_tran t (NOLOCK)

				INNER JOIN post_tran_cust c (NOLOCK)

				ON ( t.post_tran_cust_id = c.post_tran_cust_id AND
				
recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)
)

				left JOIN tbl_merchant_category m (NOLOCK)

				ON c.merchant_type = m.category_code 

				left JOIN tbl_merchant_account a (NOLOCK)

				ON c.card_acceptor_id_code = a.card_acceptor_id_code   

				left JOIN tbl_xls_settlement y (NOLOCK)

				

                                ON (c.terminal_id= y.terminal_id 

                                    AND t.retrieval_reference_nr = y.rr_number 

                                    --AND t.system_trace_audit_nr = y.stan

                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount

                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)

                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)

                                    and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

                                left JOIN tbl_reward_OutOfBand O (NOLOCK)

                                ON c.terminal_id = o.terminal_id

                                left JOIN Reward_Category r (NOLOCK)

                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code

                                                                                             and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
                                  

				

	WHERE 			

				t.tran_completed = 1

				AND

				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 

				AND

				

				(t.message_type IN ( select part from usf_split_string('0220,0200,0400,0420', ',')) 

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='533853')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='522145')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='539983')

				)



				AND 

				((substring(c.totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))

               or ((substring (t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)) and t.sink_node_name <> 'SWTASPPOSsnk')
               or (t.extended_tran_type in (select ETT from #list_of_ETT ) and t.sink_node_name = 'ESBCSOUTsnk'))

                            



				AND

				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

				AND 

				

							(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)

										

				AND

				t.sink_node_name NOT IN (SELECT part FROM  usf_split_string('CCLOADsnk,GPRsnk,VTUsnk,VTUSTOCKsnk,PAYDIRECTsnk,SWTMEGAsnk', ','))------ij added SWTMEGAsnk

				AND

				t.tran_type NOT IN ('31','50')


                               -- and c.merchant_type not in ('5371')	

                                and  (

                                ((ISNULL(y.rdm_amt,0) = 0) 

                                or ((ISNULL(y.rdm_amt,0) <> 0)) and (ISNULL(y.amount,0) not in ('0','0.00'))) 

                                or 

                                (substring(y.extended_trans_type,1,4) = '1000')

                                )

                                AND  NOT  (c.source_node_name in (SELECT part FROM  usf_split_string('SWTNCS2src,SWTSHOPRTsrc,SWTNCSKIMsrc,SWTNCSKI2src,SWTFBPsrc', ','))
                                 AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01' and not t.sink_node_name in ('ASPPOSMICsnk'))

                                and c.totals_group not in ('VISAGroup')

                AND

             c.source_node_name  NOT LIKE 'SB%'

             AND

             t.sink_node_name  NOT LIKE 'SB%'

	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'


INSERT

				INTO #report_result

	SELECT

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				SourceNodeAlias = 

				(CASE 

					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE q.source_node_name

				END),

				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,

				q.terminal_id, 

				q.acquiring_inst_id_code,

				q.terminal_owner,

				ISNULL(q.merchant_type,'VOID'),

                                extended_trans_type = Case When q.terminal_id in 

                                (select terminal_id from tbl_reward_OutOfband)

                                 and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 

                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,

				ISNULL(m.Category_name,'VOID'),

				ISNULL(m.Fee_type,'VOID'),

				ISNULL(m.merchant_disc,0.0),

				ISNULL(m.fee_cap,0),

				ISNULL(m.amount_cap,999999999999.99),

				ISNULL(m.bearer,'M'),

				q.card_acceptor_id_code, 

				q.card_acceptor_name_loc, 

				q.source_node_name,

				q.sink_node_name, 

				q.tran_type, 

				q.rsp_code_rsp, 

				q.message_type, 

				q.datetime_req, 

				

				master.dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 

				master.dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,

				

				q.post_tran_cust_id as TranID,

				q.prev_post_tran_id, 

				q.system_trace_audit_nr, 

				q.message_reason_code, 

				q.retrieval_reference_nr, 

				q.datetime_tran_local, 

				q.from_account_type, 

				q.to_account_type, 

				q.settle_currency_code, 

				

				--master.dbo.formatAmount(q.settle_amount_impact, q.settle_currency_code) as settle_amount_impact,

				

				master.dbo.formatAmount( 			

					CASE

						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact

						ELSE q.settle_amount_impact

					END

					, q.settle_currency_code ) AS settle_amount_impact,				

				

				master.dbo.formatTranTypeStr(q.tran_type, q.extended_tran_type, q.message_type) as tran_type_desciption,

				master.dbo.formatRspCodeStr(q.rsp_code_rsp) as rsp_code_description,

				master.dbo.currencyNrDecimals(q.settle_currency_code) AS settle_nr_decimals,

				master.dbo.currencyAlphaCode(q.settle_currency_code) AS currency_alpha_code,

				master.dbo.currencyName(q.settle_currency_code) AS currency_name,

				

				master.dbo.fn_rpt_isPurchaseTrx(q.tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(q.tran_type) 	AS isWithdrawTrx,

				master.dbo.fn_rpt_isRefundTrx(q.tran_type) 		AS isRefundTrx,

				master.dbo.fn_rpt_isDepositTrx(q.tran_type) 		AS isDepositTrx,

				master.dbo.fn_rpt_isInquiryTrx(q.tran_type) 		AS isInquiryTrx,

				master.dbo.fn_rpt_isTransferTrx(q.tran_type) 	AS isTransferTrx,


				master.dbo.fn_rpt_isOtherTrx(q.tran_type) 		AS isOtherTrx,

				q.tran_reversed,

				q.pan_encrypted,

				q.from_account_id,

				q.to_account_id,

				q.payee,


				q.extended_tran_type,

                                ISNULL(y.rdm_amt,0),

                                R.Reward_Discount,

                                R.Addit_Charge,

                                R.Addit_Party,

                                R.Amount_Cap,

                                R.Fee_Cap,

                                R.Fee_Discount,

                                Late_Reversal_id = CASE

						WHEN (q.post_tran_cust_id < @rpt_tran_id1 and q.message_type = '0420') THEN 1

						ELSE 0

					        END,	

				q.totals_group,

                                q.retrieval_reference_nr+'_'+q.terminal_id+'_'+'000000'+'_'+cast((abs(q.settle_amount_impact)) as varchar(12))+'_'+q.pan as aggregate_column,

                                q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(12))+'_'+q.message_type,

                q.auth_id_rsp,



                master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_req, 

				master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_rsp,

				master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_tran_fee_rsp,

				master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_currency_code

	 	

	FROM

				asp_visa_pos q (NOLOCK)

				left JOIN tbl_merchant_category m (NOLOCK)

				ON q.merchant_type = m.category_code  and recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)


				left JOIN tbl_merchant_account a (NOLOCK)

				ON q.card_acceptor_id_code = a.card_acceptor_id_code   

				left JOIN tbl_xls_settlement y (NOLOCK)

				

                                ON (q.terminal_id= y.terminal_id 

                                    AND q.retrieval_reference_nr = y.rr_number 

                                    --AND q.system_trace_audit_nr = y.stan

                                    --AND (-1 * q.settle_amount_impact)/100 = y.amount

                                    AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)

                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)

                                    and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

                                left JOIN tbl_reward_OutOfBand O (NOLOCK)

                                ON q.terminal_id = o.terminal_id

                                left JOIN Reward_Category r (NOLOCK)

                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code

                                                                                             and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')))

				

	WHERE 			

				


				q.tran_completed = 1

				AND

				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 

				AND

				(

				(q.message_type IN ('0220','0200', '0400', '0420')) 

				---OR

				---(q.message_type IN ('0100')and left(pan,6)='533853')

				---OR

				---(q.message_type IN ('0100')and left(pan,6)='522145')

				---OR

				---(q.message_type IN ('0100')and left(pan,6)='539983')

				)



				AND 

				((substring(q.totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)))

                               -- or ((substring (q.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)) and q.sink_node_name <> 'SWTASPPOSsnk'))

                                



				--AND

				--q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

				AND 

					(

					(
					(CHARINDEX (  '3IWP', q.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', q.terminal_id) > 0 ) OR
					(LEFT(q.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(q.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', q.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', q.terminal_id) > 0) OR
					( LEFT(q.terminal_id,1) = '6')
					)

										)

				AND

				q.sink_node_name NOT IN ( SELECT part FROM usf_split_string('CCLOADsnk,GPRsnk,VTUsnk,VTUSTOCKsnk,PAYDIRECTsnk,SWTMEGAsnk',','))------ij added SWTMEGAsnk

				AND

				q.tran_type NOT IN ('31','50')


                           --     and q.merchant_type not in ('5371')	

                                and  (

                                ((ISNULL(y.rdm_amt,0) = 0) 

                                or ((ISNULL(y.rdm_amt,0) <> 0)) and (ISNULL(y.amount,0) not in ('0','0.00'))) 

                                or 

                                (substring(y.extended_trans_type,1,4) = '1000')

                                )

                                --AND  NOT  (q.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND q.sink_node_name+LEFT(totals_group,3)

                               --not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(q.pan,1) = '4' and not q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))

                                and q.totals_group not in ('VISAGroup')

                AND

             q.source_node_name  NOT LIKE 'SB%'

             AND

             q.sink_node_name  NOT LIKE 'SB%'

	AND q.source_node_name  <> 'SWTMEGAsrc'AND q.source_node_name  <> 'SWTMEGADSsrc'
				

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



create table #temp_table_1

(aggregate_column varchar(200), counts float )

insert into #temp_table_1 select aggregate_column, count(aggregate_column) from #report_result

group by aggregate_column



update #report_result

set tran_type_desciption = tran_type_desciption+ '_M'

where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)

		

	

create table #temp_table

(unique_key varchar(200))



insert into #temp_table 

select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')





		

	SELECT 

			* 

	FROM 

			#report_result --rresult 

                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)

where    



          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc')

          and unique_key  IN (SELECT unique_key FROM #temp_table))
          AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))

          --and left(pan,1) <>'4'

	ORDER BY 

			datetime_tran_local,source_node_name

END



























































































































































































































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer]    Script Date: 04/21/2016 10:12:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO













ALTER PROCEDURE[dbo].[osp_rpt_b04_web_acquirer]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@Acquirer		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			VARCHAR(15),
		terminal_owner  		VARCHAR(25),
		merchant_type				CHAR (4),
        extended_tran_type_reward               VARCHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (150),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req  varchar(max),
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
	        rdm_amount                      FLOAT,--Chioma added this 2012-07-03
                Reward_Discount                 FLOAT,--Chioma added this 2012-07-03
                Addit_Charge                 DECIMAL(7,6),--Chioma added this 2012-07-03
                Addit_Party                 Varchar (10),--Chioma added this 2012-07-03
                Amount_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Cap_RD               DECIMAL(9,0),--Chioma added this 2012-07-03
                Fee_Discount_RD          DECIMAL(9,7),--Chioma added this 2012-07-03
                Late_Reversal CHAR (1),
		totals_group		Varchar(40)
              )

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
		
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

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
 --   EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants

        CREATE TABLE #list_of_AcquirerInstId (AcquirerInstId	VARCHAR(50)) 
	INSERT INTO  #list_of_AcquirerInstId EXEC osp_rpt_util_split_nodenames @AcquirerInstId
	-- Only look at 02xx messages that were not fully reversed.
	

	INSERT
				INTO #report_result
	SELECT   
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				 CASE WHEN  @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
			 ELSE dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) 
			 END AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
				extended_trans_type = Case When c.terminal_id in 
				(select terminal_id from tbl_reward_OutOfband)
				and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')
				then substring(o.r_code,1,4) 
				else ISNULL(t.extended_tran_type,'0000')end,
				--extended_trans_type = ISNULL(t.extended_tran_type,'0000'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
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
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				1,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
				0,

                                isnull(R.Reward_Discount,0),
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
				c.totals_group
	FROM
			post_tran t (NOLOCK , INDEX(ix_post_tran_9))
				INNER JOIN post_tran_cust c (NOLOCK)
				ON(  t.post_tran_cust_id = c.post_tran_cust_id 
				  AND
			recon_business_date in (SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end))
				and
              t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0)
				left JOIN tbl_merchant_category_web m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				
  
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id
                                left JOIN Reward_Category r (NOLOCK)
                                ON (t.extended_tran_type = r.reward_code or substring(o.r_code,1,4) = r.reward_code)
                               
	
WHERE 			
	

				

				
				(t.message_type IN (SELECT part FROM usf_split_string('0220,0200,0400,0420',',')) )

				
				AND 
				t.tran_completed = 1 
				AND 
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				t.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND 
					(
						(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6') OR
					(c.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ( SELECT part FROM usf_split_string('CCLOADsnk,GPRsnk,PAYDIRECTsnk,SWTMEGAsnk,CUPsnk',','))	------ij added SWTMEGAsnk, Chioma added CUPsnk
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
                
            AND
                c.source_node_name NOT LIKE  'SB%'
                   AND
               t.sink_node_name  NOT LIKE  'SB%'
			
 OPTION (RECOMPILE)

INSERT
				INTO #report_result
	SELECT   
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 'Reward',
				dbo.fn_rpt_PanForDisplay(y.pan, @show_full_pan) AS pan,
				y.terminal_id, 
				y.acquiring_inst_id_code,
				'Reward',
				'5310',
                                extended_trans_type = 'BURN',
				'Discount Stores',
				'P',
				0.015000,
				2000,
				133333.33,
				'M',
				
				y.merchant_id, 
				substring(y.card_acceptor_name_loc,1,40), 
				'Reward',
				'Reward', 
				'00', 
				'00', 
				'0200', 
				y.trans_date,
				
				
				0, 
				0,
				0,
				0 as TranID,
				0, 
				y.stan, 
				0, 
				y.rr_number, 
				y.trans_date, 
				0, 
				0, 
				'566',
				
				0,				
				
				'Goods and Services' as tran_type_desciption,
				'Approved' as rsp_code_description,
				 2 AS settle_nr_decimals,
				'NGN' AS currency_alpha_code,
				'Naira' AS currency_name,
				
				1 	AS isPurchaseTrx,
				0 	AS isWithdrawTrx,
				0 		AS isRefundTrx,
				0 		AS isDepositTrx,
				0 		AS isInquiryTrx,
				0	AS isTransferTrx,
				0 		AS isOtherTrx,
				
				
				1,
				0,
				ISNULL(account_nr,'not available'),
				0,--oremeyi added this 2009-04-22
				'0000',
				0,--oremeyi added this 2010-02-28
				ISNULL(y.rdm_amt,0),

                                isnull(R.Reward_Discount,0),
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                0,
				'Reward'
	FROM
				--post_tran t (NOLOCK)
				--INNER JOIN post_tran_cust c (NOLOCK)
				--ON  t.post_tran_cust_id = c.post_tran_cust_id
				--left JOIN tbl_merchant_category_web m (NOLOCK)
				--ON c.merchant_type = m.category_code 
				--left JOIN 
				tbl_xls_settlement y (NOLOCK)left JOIN 
				tbl_merchant_account a (NOLOCK)
				ON y.merchant_id = a.card_acceptor_id_code  
				 AND
                   y.trans_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									) 
									

				--ON (c.terminal_id= y.terminal_id 
    --                                AND t.retrieval_reference_nr = y.rr_number 
    --                                --AND t.system_trace_audit_nr = y.stan
    --                                --AND (-1 * t.settle_amount_impact)/100 = y.amount
    --                                AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
    --                                = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
    --                             and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
				left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code
	WHERE 			
				
				y.acquiring_inst_id_code IN (SELECT AcquirerInstId FROM #list_of_AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR y.merchant_id IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				and ISNULL(y.rdm_amt,0) <>0
                 and LEFT(y.terminal_id,1) = '3'
                 and y.extended_trans_type is not null
			OPTION (RECOMPILE)
								
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result
WHERE

	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
			
	ORDER BY 
			source_node_name, datetime_req
END





















































































































































































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer_detail]    Script Date: 04/21/2016 10:12:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE[dbo].[osp_rpt_b04_web_acquirer_detail]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@Acquirer		VARCHAR(255),
	---@AcquirerInstId		VARCHAR(255),
	--@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
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
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		--acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		tran_type_desciption  VARCHAR (MAX),
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
		structured_data_req  TEXT,
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50)--oremeyi added this 2009-04-22
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END*/
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Previous month'
			
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reverse
	DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT


	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				---t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
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
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code--oremeyi added this 2010-02-28
				
	FROM
				post_tran t (NOLOCK) JOIN
				post_tran_cust c (NOLOCK)
				ON
				t.post_tran_cust_id = c.post_tran_cust_id 
				LEFT JOIN 
				tbl_merchant_category m (NOLOCK)
				ON
				c.merchant_type = m.category_code
			LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				c.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			
				
				
				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')	------ij added SWTMEGAsnk
				AND
				c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50')

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
								
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			#report_result where
			(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 ) 
	ORDER BY 
			source_node_name, datetime_req
END









GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_nibss]    Script Date: 04/21/2016 10:12:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














ALTER PROCEDURE [dbo].[osp_rpt_b04_web_nibss]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id1 INT = NULL,
    @rpt_tran_id INT = NULL
        

AS
BEGIN
	--SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (255), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(255),
		terminal_owner  		CHAR(255),
		merchant_type				CHAR (4),
                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (255), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		VARCHAR (8), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),		
		settle_amount_impact	float,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		tran_reversed			INT,
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		extended_tran_type		CHAR (4),
                rdm_amount                      float,
                Reward_Discount                float,
                Addit_Charge                 DECIMAL(7,6),
                Addit_Party                 Varchar (28),
                Amount_Cap_RD               DECIMAL(9,0),
                Fee_Cap_RD               DECIMAL(9,0),
                Fee_Discount_RD          DECIMAL(9,7) ,
                Totalsgroup varchar (40),
                aggregate_column         VARCHAR(200),
                Unique_key varchar (200),
				tran_cash_req  float,
tran_cash_rsp  float,
        	tran_tran_fee_rsp  float,
			tran_currency_code      VARCHAR (50)
        
                     
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END*/
		
	
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
	--EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
IF (@StartDate IS NULL OR @StartDate ='') 
		BEGIN 
			SELECT @StartDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		IF (@EndDate IS NULL OR @EndDate ='') 
		BEGIN 
			SELECT @EndDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		
	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		


		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET  @report_date_start = CONVERT(CHAR(8),@StartDate , 112)
	SET @report_date_end = CONVERT(CHAR(8),@EndDate , 112)

	EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 
    EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END	

	DECLARE  @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes,',')
	
   	--DECLARE @first_post_tran_id BIGINT
	--DECLARE @last_post_tran_id BIGINT
	--EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT
--
--SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
--        WHERE ll.recon_business_date >= @report_date_start
--        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>0 
        
INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 'Reward',
				dbo.fn_rpt_PanForDisplay(y.pan, @show_full_pan) AS pan,
				y.terminal_id, 
				y.acquiring_inst_id_code,
				'Reward',
				'5310',
                                extended_trans_type = 'BURN',
				'Discount Stores',
				'P',
				0.007500,
				1200,
				160000,
				'M',
				y.merchant_id, 
				substring(y.card_acceptor_name_loc,1,40), 
				'Reward',
				'Reward', 
				'00', 
				'00', 
				'0200', 
				y.trans_date,
				
				
				0, 
				0,
				0,
				
				0 as TranID,
				0, 
				y.stan, 
				0, 
				y.rr_number, 
				y.trans_date, 
				0, 
				0, 
				'566', 
				
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
				'Goods and Services' as tran_type_desciption,
				'Approved' as rsp_code_description,
				 2 AS settle_nr_decimals,
				'NGN' AS currency_alpha_code,
				'Naira' AS currency_name,
				
				1 	AS isPurchaseTrx,
				0 	AS isWithdrawTrx,
				0 		AS isRefundTrx,
				0 		AS isDepositTrx,
				0 		AS isInquiryTrx,
				0	AS isTransferTrx,
				0 		AS isOtherTrx,
				0,
				0,
				0,
				0,
				0,
				'0000',
                                ISNULL(y.rdm_amt,0),
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                'Reward',
                  y.rr_number+'_'+y.terminal_id+'_'+'000000'+'_'+cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50))+'_'+y.pan,
                 y.rr_number+'_'+'000000'+'_'+y.terminal_id+'_'+ cast((abs(ISNULL(y.rdm_amt,0))) as varchar(50))+'_'+'0200',
				 
				0 AS tran_cash_req, 
				0 AS tran_cash_rsp,
				0 AS tran_tran_fee_rsp,
				0 AS tran_currency_code

                	
	FROM
				/*post_tran t (NOLOCK , INDEX(ix_post_tran_9))
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON c.merchant_type = v.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code */  
				--left JOIN 
				tbl_xls_settlement y (NOLOCK)
				
                               /* ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand)
                                )*/
                                left JOIN Reward_Category r (NOLOCK)
                                ON substring(y.extended_trans_type,1,4) = r.reward_code
                                                                


	WHERE 			
				
				/*c.post_tran_cust_id >= @rpt_tran_id1 AND
    --                             or (c.post_tran_cust_id < @rpt_tran_id1 and c.post_tran_cust_id >= @rpt_tran_id and t.message_type <> '0420')
    --                           )--'81530747'	
				--AND
				t.tran_completed = 1*/
				
							y.trans_date >= @report_date_start AND y.trans_date<=  REPLACE(CONVERT(VARCHAR(10), DATEADD(D, 1,@report_date_end),111),'/', '')

				--AND
				--t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--(t.message_type IN ('0220','0200', '0400', '0420') )
				--and 
				--datediff(d, datetime_tran_local, datetime_rsp) = 0
 				 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
			
				--AND 
				---(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
				/*AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
										(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                 and c.merchant_type not in ('5371')*/
                 and ISNULL(y.rdm_amt,0) <>0
                 and LEFT(y.terminal_id,1) = '2'
                 and y.extended_trans_type is not null
                /* AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND t.sink_node_name+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                 and c.totals_group not in ('VISAGroup')
                AND
            LEFT( c.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB'*/ ---AND not( t.sink_node_name   LIKE 'SB%')
--and c.post_tran_cust_id > '931993163'
OPTION (MAXDOP 8)


	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
                                extended_trans_type = 
                                Case When c.terminal_id in 
                                (select terminal_id from tbl_reward_OutOfband)
                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				t.tran_reversed,
				c.pan_encrypted,
				t.from_account_id,
				t.to_account_id,
				isnull(t.payee,0),
				isnull(t.extended_tran_type,0),
                                0,
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                c.totals_group,
                 t.retrieval_reference_nr+'_'+c.terminal_id+'_'+'000000'+'_'+cast((abs(t.settle_amount_impact)) as varchar(50))+'_'+c.pan,
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(50))+'_'+t.message_type,
				
                                master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_req, 
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_cash_rsp,
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_tran_fee_rsp,
		
				master.dbo.formatAmount(t.tran_cash_req,t.tran_currency_code) AS tran_currency_code
                 	
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON c.merchant_type = v.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                
                                 ON c.terminal_id = o.terminal_id
                                left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code  
                                and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')))
                                
                                

				

	WHERE 			

				
--        (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
--	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
--           --c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
--
--			
--				--c.post_tran_cust_id >= @rpt_tran_id1 AND
--				and 
t.tran_completed = 1
				and t.recon_business_date >= @report_date_start AND t.recon_business_date<= @report_date_end
				--AND
								--recon_business_date >= @report_date_start AND  t.post_tran_id>=@first_post_tran_id
				--AND  t.post_tran_id>=@last_post_tran_id
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(t.message_type IN ('0220','0200', '0400', '0420') )
				--and
				--datediff(d, datetime_tran_local, datetime_rsp) = 0
				---(
				---(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				
				--AND 
				---(substring(c.totals_group,1,3) = substring(@SinkNodes,4,3))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
					(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)
				AND
				t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				--AND
				--c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50','21')
                and c.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511')
                                AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))	

                AND
              LEFT( c.source_node_name,2)  <> 'SB'
              AND LEFT( t.sink_node_name,2)  <> 'SB'
              OPTION (MAXDOP 8)

               --AND not( t.sink_node_name   LIKE 'SB%')
              --and c.post_tran_cust_id > '946318193'
              
			insert into       @report_result
 
		     SELECT
		     				NULL AS Warning,
		     				@StartDate as StartDate,  
		     				@EndDate as EndDate, 
		     				SourceNodeAlias = 
		     				(CASE 
		     					WHEN q.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
		     					ELSE q.source_node_name
		     				END),
		     				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,
		     				q.terminal_id, 
		     				q.acquiring_inst_id_code,
		     				q.terminal_owner,
		     				--q.merchant_type,
		     				ISNULL(q.merchant_type,'VOID')as merchant_type,
		                                     extended_trans_type = 
		                                     Case When q.terminal_id in 
		                                     (select terminal_id from tbl_reward_OutOfband)
		                                      and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')
		     
		                                      then substring(o.r_code,1,4) 
		                                       else ISNULL(substring(y.extended_trans_type,1,4),'0000')end,
		case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				     				else ISNULL(m.Category_name,'VOID') end as Category_name,
				     				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				     				else ISNULL(m.Fee_type,'VOID') end as Fee_type,
				     				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				     				else ISNULL(m.merchant_disc,0.0) end as merchant_disc,
				     				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				     				else ISNULL(m.fee_cap,0) end as fee_cap,
				     				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				     				else ISNULL(m.amount_cap,999999999999.99) end as amount_cap,
				     				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
		     				else ISNULL(m.bearer,'M') end as bearer,
		     				
		     				
		     				
		     				q.card_acceptor_id_code, 
		     				q.card_acceptor_name_loc, 
		     				q.source_node_name,
		     				q.sink_node_name, 
		     				q.tran_type, 
		     				q.rsp_code_rsp, 
		     				q.message_type, 
		     				q.datetime_req, 
		     				
		     				
		     				master.dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 
		     				master.dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,
		     				master.dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,
		     				
		     				q.post_tran_cust_id as TranID,
		     				q.prev_post_tran_id, 
		     				q.system_trace_audit_nr, 
		     				q.message_reason_code, 
		     				q.retrieval_reference_nr, 
		     				q.datetime_tran_local, 
		     				q.from_account_type, 
		     				q.to_account_type, 
		     				q.settle_currency_code, 
		     				
		     				
		     				--master.dbo.formatAmount(q.settle_amount_impact, q.settle_currency_code) as settle_amount_impact,
		     				
		     				master.dbo.formatAmount( 			
		     					CASE
		     						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact
		     						ELSE q.settle_amount_impact
		     					END
		     					, q.settle_currency_code ) AS settle_amount_impact,				
		     				
		     				master.dbo.formatTranTypeStr(q.tran_type, q.extended_tran_type, q.message_type) as tran_type_desciption,
		     				master.dbo.formatRspCodeStr(q.rsp_code_rsp) as rsp_code_description,
		     				master.dbo.currencyNrDecimals(q.settle_currency_code) AS settle_nr_decimals,
		     				master.dbo.currencyAlphaCode(q.settle_currency_code) AS currency_alpha_code,
		     				master.dbo.currencyName(q.settle_currency_code) AS currency_name,
		     				
		     				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
		     				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
		     				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
		     				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
		     				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
		     				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
		     				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
		     				q.tran_reversed,
		     				q.pan_encrypted,
		     				q.from_account_id,
		     				q.to_account_id,
		     				isnull(q.payee,0)as payee,
		     				isnull(q.extended_tran_type,0),
		                                     0,
		                                     R.Reward_Discount,
		                                     R.Addit_Charge,
		                                     R.Addit_Party,
		                                     R.Amount_Cap,
		                                     R.Fee_Cap,
		                                     R.Fee_Discount,
		                                     q.totals_group,
		                      q.retrieval_reference_nr+'_'+q.terminal_id+'_'+'000000'+'_'+cast((abs(q.settle_amount_impact)) as varchar(50))+'_'+q.pan as aggregate_column,
		                      q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar(50))+'_'+q.message_type as unique_key,
		     				
		                                     master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_req, 
		     				master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_cash_rsp,
		     				master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_tran_fee_rsp,
		     		
		     				master.dbo.formatAmount(q.tran_cash_req,q.tran_currency_code) AS tran_currency_code
		                      	
		     	FROM
		     				asp_visa_pos q (NOLOCK)
		     				left JOIN tbl_merchant_category m (NOLOCK)
		     				ON q.merchant_type = m.category_code 
		     				left JOIN tbl_merchant_category_visa v (NOLOCK)
		     				ON q.merchant_type = v.category_code 
		     				left JOIN tbl_merchant_account a (NOLOCK)
		     				ON q.card_acceptor_id_code = a.card_acceptor_id_code   
		     				left JOIN tbl_xls_settlement y (NOLOCK)
		     				
		                                     ON (q.terminal_id= y.terminal_id 
		                                         AND q.retrieval_reference_nr = y.rr_number 
		                                         --AND q.system_trace_audit_nr = y.stan
		                                         --AND (-1 * q.settle_amount_impact)/100 = y.amount
		                                         AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)
		                                         = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
		                                      and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
		                                     left JOIN tbl_reward_OutOfBand O (NOLOCK)
		                                     
		                                      ON q.terminal_id = o.terminal_id
		                                     left JOIN Reward_Category r (NOLOCK)
		                                     ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code  
		                                                                                                 and dbo.fn_rpt_CardGroup (q.PAN) in ('1','4')))
		     
		    WHERE 			
		    				
		    				q.tran_completed = 1
		    				AND
		    				recon_business_date >= @report_date_start AND recon_business_date<= @report_date_end
		    				AND
		    				q.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
		    				AND
		    				(q.message_type IN ('0220','0200', '0400', '0420') )
		    				--and
		    				--datediff(d, datetime_tran_local, datetime_rsp) = 0
		    				---(
		    				---(q.message_type IN ('0100','0200', '0400', '0420')) 
		    				---OR
		    				---(q.message_type IN ('0100')and left(pan,6)='533853')
		    				---OR
		    				---(q.message_type IN ('0100')and left(pan,6)='522145')
		    				---OR
		    				---(q.message_type IN ('0100')and left(pan,6)='539983')
		    				
		    				--AND 
		    				---(substring(q.totals_group,1,3) = substring(@SinkNodes,4,3))
		    				AND     				
		    		 						
		    					    				                    
		    			        	    				
		    						    				
		    			sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
		    				--AND
		    				--q.pan not like '4%'
		    				AND
		    				q.tran_type NOT IN ('31','50','21')
		                    and q.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511')
		                                                         
		                                
		                    AND
		                  LEFT( q.source_node_name,2)  <> 'SB'
              AND LEFT( q.sink_node_name,2)  <> 'SB' --AND not( q.sink_node_name   LIKE 'SB%')
              
              
              OPTION (MAXDOP 8)

				
	IF @@ROWCOUNT = 0 BEGIN
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)	
		END		
	--ELSE
	--BEGIN
	--	--
	--	-- Decrypt PAN information if necessary
	--	--

	--	DECLARE @pan VARCHAR (19)
	--	DECLARE @pan_encrypted CHAR (18)
	--	DECLARE @pan_clear VARCHAR (19)
	--	DECLARE @process_descr VARCHAR (100)

	--	SET @process_descr = 'Office B04 Report'

	--	-- Get pan and pan_encrypted from @report_result and post_tran_cust using a cursor
	--	DECLARE pan_cursor CURSOR FORWARD_ONLY
	--	FOR
	--		SELECT
	--				pan,
	--				pan_encrypted
	--		FROM
	--				@report_result
	--	FOR UPDATE OF pan

	--	OPEN pan_cursor

	--	DECLARE @error INT
	--	SET @error = 0

	--	IF (@@CURSOR_ROWS <> 0)
	--	BEGIN
	--		FETCH pan_cursor INTO @pan, @pan_encrypted
	--		WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
	--		BEGIN
	--			-- Handle the decrypting of PANs
	--			EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_clear OUTPUT, @error OUTPUT

	--			-- Update the row if its different
	--			IF ((@pan IS  NOT NULL) AND (@pan_clear <> @pan))
	--			BEGIN
	--				UPDATE
	--					@report_result
	--				SET
	--					pan = @pan_clear
	--				WHERE
	--					CURRENT OF pan_cursor
	--			END

	--			FETCH pan_cursor INTO @pan, @pan_encrypted
	--		END
	--	END

	--	CLOSE pan_cursor
	--	DEALLOCATE pan_cursor

	--END	


create table #temp_table_1
(aggregate_column varchar(200), counts float )
insert into #temp_table_1 select aggregate_column, count(aggregate_column) from @report_result
group by aggregate_column

update @report_result
set tran_type_desciption = tran_type_desciption+ '_M'
where aggregate_column in (select aggregate_column from  #temp_table_1 where counts >2)

		
	create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from @report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


		
	SELECT 
			* 
	FROM 
			@report_result --rresult 
                        --left join #temp_table ttable on (rresult.unique_key = ttable.unique_key)
where    
(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 ) 

and
          not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc')
          and unique_key  IN (SELECT unique_key FROM #temp_table))
          --and left(pan,1) ='4'
         

                                       
      
         
      
      -- and (source_node_name = 'SWTNCS2src' and sink_node_name = 'ASPPOSLMCsnk')
	ORDER BY 
			source_node_name, datetime_req, message_type
			 OPTION (MAXDOP 8)

END



























































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_all]    Script Date: 04/21/2016 10:12:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


























ALTER PROCEDURE[dbo].[osp_rpt_b04_web_pos_acquirer_all]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL
         

AS
BEGIN
	SET NOCOUNT ON

	Create   TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			VARCHAR(18),
		terminal_owner  			VARCHAR(32),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	VARCHAR (255), 
		source_node_name		VARCHAR (255), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		tran_reversed			INT,	 
		settle_amount_impact	FLOAT,
		extended_tran_type		CHAR (4),
		system_trace_audit_nr		CHAR (10),
                Rdm_Amt FLOAT,
                late_reversal_id CHAR (1),
                Unique_key varchar (200) 
		)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 


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

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(255)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	-- Only look at 02xx messages that were not fully reversed.


SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 
        
INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,

				ISNULL(c.merchant_type,'VOID'),
				--ISNULL(account_nr,'not available')
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				0, 
				0,
				0,
				t.tran_reversed,	 
					
				
				0,
					extended_tran_type,
					system_trace_audit_nr,-----------added by ij 2010/04/01
                                 ISNULL(y.rdm_amt,0)as rdm_amt,
                                 Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type	
	FROM
			
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON c.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand)
                                 )
                                 
                   
	
WHERE 			
	

	     (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
		
				
				--c.post_tran_cust_id >= @rpt_tran_id
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				
				AND
				t.tran_postilion_originated = 0  
				AND
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50','21')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')
                                and ISNULL(y.rdm_amt,0) <>0
                 AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))			

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
           t.sink_node_name  NOT LIKE 'SB%'
	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(c.merchant_type,'VOID'),
				--ISNULL(account_nr,'not available')
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				t.tran_reversed,	 
					
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
					extended_tran_type,
					system_trace_audit_nr,-----------added by ij 2010/04/01
                                 0 as rdm_amt,
                                 Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type
	FROM
			
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON c.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                   
                
	
WHERE 			
	
	     (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	
				--c.post_tran_cust_id >= @rpt_tran_id
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				
				AND
				t.tran_postilion_originated = 0  
				AND
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50','21')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				 AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))			

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
           t.sink_node_name  NOT LIKE 'SB%'
	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'


	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	



create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


	


SELECT 
		 StartDate,
		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 acquiring_inst_id_code,
		category_name, 
		merchant_type,
		 tran_type,
		SUM(CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
			ELSE 0
			END) AS no_above_limit,
		SUM(CASE
			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1	
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
                        ELSE 0
            		END) AS amount_above_limit,
		 SUM(settle_amount_impact * -1+ rdm_amt)as amount,
		 SUM(settle_tran_fee_rsp *-1) as fee,
		 SUM(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
			extended_tran_type,
			message_type,
			settle_amount_rsp,
			system_trace_audit_nr,
                        late_reversal_id
	 
	FROM 
			#report_result

                        where not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                                    --- and merchant_type not in ('5371')	

                              and not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc')
                                 and unique_key  IN (SELECT unique_key FROM #temp_table))
	
	GROUP BY
			StartDate, EndDate,category_name,extended_tran_type,
			merchant_type,acquiring_inst_id_code,tran_type, 
			card_acceptor_id_code, card_acceptor_name_loc,
			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id,source_node_name	-- tran_type_description, 
	ORDER BY 
			acquiring_inst_id_code




END















































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_T_OWNER]    Script Date: 04/21/2016 10:12:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE[dbo].[osp_rpt_b04_web_pos_acquirer_T_OWNER]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@Acquirer		VARCHAR(255),
	---@AcquirerInstId		VARCHAR(255),
	--@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id1 INT = NULL

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			VARCHAR(20),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
                extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req  TEXT,
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
                rdm_amount                      float,
                Reward_Discount                 float,
                Addit_Charge                 DECIMAL(7,6),
                Addit_Party                 Varchar (10),
                Amount_Cap_RD               DECIMAL(9,0),
                Fee_Cap_RD               DECIMAL(9,0),
                Fee_Discount_RD          DECIMAL(9,7),
                Terminal_owner_code Varchar (4)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END*/
		
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

	EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
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
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),

				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                                ISNULL(y.rdm_amt,0),
                                R.Reward_Discount,
                                R.Addit_Charge,
                                R.Addit_Party,
                                R.Amount_Cap,
                                R.Fee_Cap,
                                R.Fee_Discount,
                                tt.Terminal_code	
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id

	WHERE 			
				
				c.post_tran_cust_id >= @rpt_tran_id1--'81530747'	
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk','CUPsnk')	------ij added SWTMEGAsnk
				AND
				c.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50')
                                and c.merchant_type not in ('5371')	
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
			source_node_name, datetime_req, message_type
END








GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_all]    Script Date: 04/21/2016 10:12:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






















ALTER PROCEDURE[dbo].[osp_rpt_b04_web_pos_all]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL
AS
BEGIN
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	
	SET NOCOUNT ON
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  		CHAR(32),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2),
		tran_reversed			INT,	 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_description	VARCHAR (60),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		extended_tran_type		CHAR(12),
                rdm_amt                      FLOAT,
                totals_group varchar(40),
                Late_Reversal_id             CHAR (1),
                Unique_key varchar (200)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@SinkNode IS NULL or Len(@SinkNode)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END
	*/	
	
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
        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 

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

	-- Only look at 02xx messages that were not fully reversed.
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				sink_node_name = case when y.rdm_amt <> 0 and y.extended_trans_type = '9000' then 'InterSwitch(FBN)' 
				                      when y.rdm_amt <> 0 and y.extended_trans_type = '3000' then 'Forte Oil(FBN)'
				                      when y.extended_trans_type = '1000' then 'First Point (FBN)'
				                    
				                      else t.sink_node_name end, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				0, 
				0,
				0,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type,
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				extended_tran_type,
                                ISNULL(y.rdm_amt,0)as rdm_amt,
                                c.totals_group,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 
                                                      and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type
                                
	FROM
				

                                post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON c.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand)
                                )
                                
                  
	
WHERE 			
	
         (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
--t.post_tran_cust_id >= @rpt_tran_id 
				AND
				t.tran_completed = 1
				AND

				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50','21')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')
                                and ISNULL(y.rdm_amt,0) <>0
               AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))	

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (C.merchant_type,C.terminal_id,T.tran_type,C.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name , 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type,
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51')  THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,

				extended_tran_type,
                                0 as rdm_amt,
                                c.totals_group,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 
                                                      and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+c.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type
                                
	FROM
				

                                post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON c.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                
                  
	
WHERE 			
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
--t.post_tran_cust_id >= @rpt_tran_id 
				AND
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50','21')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')------ij added SWTMEGAsnk	
                 AND  NOT  (c.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(c.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (c.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (c.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(c.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))		

                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	AND c.source_node_name  <> 'SWTMEGAsrc'AND c.source_node_name  <> 'SWTMEGADSsrc'

	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	


create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
			
	SELECT 
		 StartDate,

		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 CASE when rdm_amt <> 0 then sink_node_name 
		 else substring(totals_group,1,3) end as sink_node_name,
		 category_name, 
		 merchant_type,
		 tran_type,
                 terminal_id,
		CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1--ij changed this to cater for 0100 transactions which always have a zero
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
                        WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
			ELSE 0
			END AS no_above_limit,
		CASE
			--WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 
                        WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt			
			ELSE 0
            		END AS amount_above_limit,
		settle_amount_impact * -1 + rdm_amt as amount,
		settle_tran_fee_rsp *-1 as fee,
		 CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END as tran_count,
			extended_tran_type,
			message_type,
			settle_amount_rsp,
                        late_reversal_id

	 
	FROM 
			#report_result

                        where not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                  -- and merchant_type not in ('5371')	

                             and not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc')
                                 and unique_key  IN (SELECT unique_key FROM #temp_table))
	--GROUP BY
	--		StartDate, EndDate,category_name,merchant_type,sink_node_name,tran_type, card_acceptor_id_code, card_acceptor_name_loc -- tran_type_description, 
	ORDER BY 

			source_node_name, sink_node_name
	END
























































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_remote]    Script Date: 04/21/2016 10:12:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





























ALTER PROCEDURE[dbo].[osp_rpt_b04_web_remote]

	@StartDate		VARCHAR (30),	-- yyyymmdd

	@EndDate			VARCHAR (30),	-- yyyymmdd

	@SinkNodes		VARCHAR(510),

	@SourceNodes	VARCHAR(255),

	@show_full_pan	BIT,

	@report_date_start DATETIME = NULL,

	@report_date_end DATETIME = NULL,

	@rpt_tran_id INT = NULL,

        @rpt_tran_id1 INT = NULL



AS

BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	

	CREATE TABLE #report_result

	(

		Warning					VARCHAR (255),

		StartDate				VARCHAR (30),  

		EndDate				VARCHAR (30), 

		SourceNodeAlias 		VARCHAR (50),

		pan						VARCHAR (255), 

		terminal_id				CHAR (8), 

		acquiring_inst_id_code			CHAR(255),

		terminal_owner  		CHAR(255),

		merchant_type				CHAR (4),

                extended_tran_type_reward               CHAR (4),--Chioma added this 2012-07-03

		Category_name				VARCHAR(50),

		Fee_type				CHAR(1),

		merchant_disc				DECIMAL(7,4),

		fee_cap					FLOAT,

		amount_cap				FLOAT,

		bearer					CHAR(1),

		card_acceptor_id_code	CHAR (15),	 

		card_acceptor_name_loc	CHAR (255), 

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

		tran_type_desciption  VARCHAR (30),

		rsp_code_description	VARCHAR (60),

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

		tran_reversed			INT,

		pan_encrypted			CHAR(18),

		from_account_id			VARCHAR(28),

		to_account_id			VARCHAR(28),

		payee				char(25),

		extended_tran_type		CHAR (4),

                rdm_amount                      DECIMAL(7,4),

                Reward_Discount                 DECIMAL(7,6),

                Addit_Charge                 DECIMAL(7,6),

                Addit_Party                 Varchar (10),

                Amount_Cap_RD               DECIMAL(9,0),

                Fee_Cap_RD               DECIMAL(9,0),

                Fee_Discount_RD          DECIMAL(9,7),

                Late_Reversal CHAR (1),

				Bank_institution_name		varchar(50),

				bank_card_type		        varchar(100),

       auth_id_rsp Varchar(200)         

	)



	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)

	BEGIN	   

	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')

	   	SELECT * FROM #report_result

		RETURN 1

	END

		

	

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



	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)

	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)



	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

        EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 



	IF (@report_date_end < @report_date_start)

	BEGIN

	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')

	   	SELECT * FROM #report_result

		RETURN 1

	END



	



	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

	

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes



	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 

	

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

	
--DECLARE @tbl_late_reversals TABLE (tran_nr BIGINT, retrieval_reference_nr VARCHAR(20))
--
--INSERT INTO @tbl_late_reversals
--(tran_nr, retrieval_reference_nr)
--SELECT tran_nr, retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
--WHERE ll.recon_business_date >= @report_date_start
--and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 


DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT 
        
	INSERT

				INTO #report_result

	SELECT 

				NULL AS Warning,

				@StartDate as StartDate,  

				@EndDate as EndDate, 

				SourceNodeAlias = 

				(CASE 

					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'

					ELSE c.source_node_name

				END),

				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,

				c.terminal_id, 

				t.acquiring_inst_id_code,

				c.terminal_owner,

				ISNULL(c.merchant_type,'VOID'),

                                 extended_trans_type = Case When c.terminal_id in 

                                (select terminal_id from tbl_reward_OutOfband)

                                 and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')

                                 then substring(o.r_code,1,4) 

                                  else ISNULL(t.extended_tran_type,'0000')end,

				ISNULL(m.Category_name,'VOID'),

				ISNULL(m.Fee_type,'VOID'),

				ISNULL(m.merchant_disc,0.0),

				ISNULL(m.fee_cap,0),

				ISNULL(m.amount_cap,999999999999.99),

				ISNULL(m.bearer,'M'),

				c.card_acceptor_id_code, 

				c.card_acceptor_name_loc, 

				c.source_node_name,

				t.sink_node_name, 

				t.tran_type, 

				t.rsp_code_rsp, 

				t.message_type, 

				t.datetime_req, 

				

				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

				

				t.post_tran_cust_id as TranID,

				t.prev_post_tran_id, 

				t.system_trace_audit_nr, 

				t.message_reason_code, 

				t.retrieval_reference_nr, 

				t.datetime_tran_local, 

				t.from_account_type, 

				t.to_account_type, 

				t.settle_currency_code, 

				

				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,

				

				master.dbo.formatAmount( 			

					CASE

						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact

						ELSE t.settle_amount_impact

					END

					, t.settle_currency_code ) AS settle_amount_impact,				

				

				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,

				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,

				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,

				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				master.dbo.currencyName(t.settle_currency_code) AS currency_name,

				

				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,

				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,

				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,

				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,

				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,

				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,

				t.tran_reversed,

				c.pan_encrypted,

				t.from_account_id,

				t.to_account_id,

				t.payee,

				t.extended_tran_type,

                                0,

                                isnull(R.Reward_Discount,0),

                                R.Addit_Charge,

                                R.Addit_Party,

                                R.Amount_Cap,

                                R.Fee_Cap,

                                R.Fee_Discount,

                                Late_Reversal_id = CASE

						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1

						ELSE 0

					        END,

				1,--d.bank_institution_name,

				1,--b.bank_card_type,		

                t.auth_id_rsp



FROM

				post_tran t (NOLOCK , INDEX(ix_post_tran_9))

				INNER JOIN post_tran_cust c (NOLOCK)

				ON  t.post_tran_cust_id = c.post_tran_cust_id 
				and
				recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)


				left JOIN tbl_merchant_category_web m (NOLOCK)

				ON c.merchant_type = m.category_code 

				left JOIN tbl_merchant_account a (NOLOCK)

				ON c.card_acceptor_id_code = a.card_acceptor_id_code   

				/*left JOIN tbl_xls_settlement y (NOLOCK)

				

                                ON (c.terminal_id= y.terminal_id 

                                    AND t.retrieval_reference_nr = y.rr_number 

                                    --AND t.system_trace_audit_nr = y.stan

                                    AND (-1 * t.settle_amount_impact)/100 = y.amount

                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)

                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))*/

                                left JOIN tbl_reward_OutOfBand O (NOLOCK)

                                ON c.terminal_id = o.terminal_id

                                left JOIN Reward_Category r (NOLOCK)

                                ON (t.extended_tran_type = r.reward_code or substring(o.r_code,1,4) = r.reward_code)

								--left JOIN bank_bin_table b (NOLOCK) ON ((SUBSTRING(c.pan,1,6) = B.bin) or (SUBSTRING(c.pan,4,3) =SUBSTRING (B.bin,1,3)))

								--LEFT JOIN acquirer_institution_table d (NOLOCK) ON (t.acquiring_inst_id_code = d.acquirer_inst_id)
                                
	
WHERE 			
	

				t.tran_completed = 1

				AND


				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 

				AND

				(

				(t.message_type IN ('0220','0200', '0400', '0420')) 

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='533853')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='522145')

				---OR

				---(t.message_type IN ('0100')and left(pan,6)='539983')

				)

				AND 

				((substring(c.totals_group,1,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes))

                                or (substring (t.sink_node_name,4,3) in (select substring(sink_node,4,3) from #list_of_sink_nodes)))

				AND

				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

				AND 

					(

							(
					(CHARINDEX (  '3IWP', c.terminal_id) > 0 )OR
					(CHARINDEX (  '3ICP', c.terminal_id) > 0 ) OR
					(LEFT(c.terminal_id,1) = '2')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1) = '5')  OR
                    (CHARINDEX ( '31WP', c.terminal_id) > 0 ) OR
					(CHARINDEX ( '31CP', c.terminal_id) > 0) OR
					( LEFT(c.terminal_id,1) = '6')
					)

					OR
					(c.terminal_id like '%VA')

										)

				AND

				t.sink_node_name NOT IN ( SELECT part FROM usf_split_string('CCLOADsnk,GPRsnk,VTUsnk,VTUSTOCKsnk,PAYDIRECTsnk,SWTMEGAsnk', ','))------ij added SWTMEGAsnk

				AND

				t.tran_type NOT IN ('31','50')

                                and c.merchant_type not in ('5371')	

                                /*and  (

                                ((ISNULL(y.rdm_amt,0) = 0) 

                                or ((ISNULL(y.rdm_amt,0) <> 0)) and (ISNULL(y.amount,0) not in ('0','0.00'))) 

                                or 

                                (y.extended_trans_type = '1000')

                                )*/

               AND

             c.source_node_name  NOT LIKE 'SB%'

             AND

             t.sink_node_name  NOT LIKE 'SB%'



			--AND

			--(B.bin = SUBSTRING(c.pan,1,6) or (SUBSTRING(c.pan,4,3) IN ('051','100')and substring (c.totals_group ,1,3) = b.inst_sink_code))

				

				

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
			--where  (source_node_name <> 'SWTASPUBAsrc' AND sink_node_name <> 'SWTWEBUBAsnk')

--			--where left(pan,1) <>'4'
--WHERE
--(
--
--tranID NOT IN (SELECT tran_nr FROM @tbl_late_reversals)   
--AND
--retrieval_reference_nr NOT IN (SELECT retrieval_reference_nr FROM @tbl_late_reversals)   
--)

	ORDER BY 

			datetime_tran_local,source_node_name

END















































































































































































































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_WebAcquirer]    Script Date: 04/21/2016 10:12:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE[dbo].[osp_rpt_b04_WebAcquirer]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@Acquirer		VARCHAR(255),
	---@AcquirerInstId		VARCHAR(255),
	--@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		--acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
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
		tran_type_desciption  VARCHAR (MAX),
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
		structured_data_req  TEXT,
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50)--oremeyi added this 2009-04-22
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@Acquirer IS NULL or Len(@Acquirer)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Merchant Acquirer name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END*/
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Previous month'
			
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  #list_of_card_acceptor_id_codes EXEC osp_rpt_util_split_nodenames @merchants
	-- Only look at 02xx messages that were not fully reversed.
	
	DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT


	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				---t.acquiring_inst_id_code,
				c.terminal_owner,
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
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
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,
				receiving_inst_id_code--oremeyi added this 2010-02-28
				
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_9)) JOIN 
				post_tran_cust c (NOLOCK)
				ON
				t.post_tran_cust_id = c.post_tran_cust_id
				and

recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)

				
			LEFT JOIN 
				tbl_merchant_category m (NOLOCK)
				ON
				c.merchant_type = m.category_code
				LEFT JOIN 
				tbl_merchant_account a (NOLOCK)
				ON
					c.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			

				c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
	

AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 
				AND

				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='533853')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='522145')
				---OR
				---(t.message_type IN ('0100')and left(pan,6)='539983')
				)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(c.terminal_id like '3IWP%') OR
					(c.terminal_id like '3ICP%') OR
				
                                        (c.terminal_id like '31WP%') OR
					(c.terminal_id like '31CP%')
					
										)
				AND
				sink_node_name NOT IN ( SELECT part FROM usf_split_string('CCLOADsnk,GPRsnk,PAYDIRECTsnk,SWTMEGAsnk,VTUsnk,VTUSTOCKsnk',','))	------ij added SWTMEGAsnk
				AND
				t.tran_type NOT IN ('31','50')
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
			source_node_name, datetime_req
END








GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06]    Script Date: 04/21/2016 10:12:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



















ALTER PROCEDURE[dbo].[osp_rpt_b06]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
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


	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
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
		settle_nr_decimals			BIGINT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption		VARCHAR (60),	
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

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END


        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
	CREATE TABLE #list_of_terminalIds (terminalID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_terminalIds EXEC osp_rpt_util_split_nodenames @terminalID
	
        INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
			
			
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data,
			c.totals_group
	FROM
			post_tran t (NOLOCK, INDEX(ix_post_tran_9))
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (
						t.post_tran_cust_id = c.post_tran_cust_id
						AND
						recon_business_date in (
								SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end) 
						  )
									AND
						t.tran_completed = 1
						AND
						t.tran_postilion_originated = 0
						AND
						
						t.sink_node_name not in  (SELECT part FROM dbo.usf_split_string('GPRsnk,CCLOADsnk,SWTCTLsnk,SWTSPTsnk', ','))
						and  
						CHARINDEX('TPP',t.sink_node_name)<1  
						
						 AND
									t.message_type IN (SELECT part FROM  dbo.usf_split_string('0200,0220,0400,0420', ',')) --- oremeyi removed 0100, 0120
						AND 
						t.tran_type = '01'
						AND
						  LEFT( t.sink_node_name ,2)!= 'SB'
			)
			
WHERE 			


			(c.source_node_name in (select source_node from #list_of_source_nodes)
			OR (substring (c.terminal_id,2,3) in (select terminalID from #list_of_terminalIds)
			AND c.source_node_name  = 'ASPSPNOUsrc')
                       )
			AND c.source_node_name not in (SELECT part FROM dbo.usf_split_string('SWTMEGAsrc,SWTMEGADSsrc,ASPSPNTFsrc,ASPSPONUSsrc', ','))
			AND
			(terminal_id not like '2%')
            AND
             LEFT( c.source_node_name  ,2)!= 'SB'
			and  CHARINDEX('TPP', c.source_node_name)<1 
			OPTION (RECOMPILE)

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
		

	

	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
			WHERE
			  (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 )
			
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END









































































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Acquirer_verve_int]    Script Date: 04/21/2016 10:12:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE[dbo].[osp_rpt_b06_all_Acquirer_verve_int]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
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
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 	
                tran_currency_code CHAR (3),	
                post_currency_name VARCHAR (50),
		settle_amount_impact		FLOAT,	
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	--DECLARE @report_date_start		DATETIME
	--DECLARE @report_date_end		DATETIME
	
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

	*/

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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)

        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
                        t.tran_currency_code,
                        p.name as post_currency_name,
                        

			
			
			/*	
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran t (NOLOCK , index(ix_post_tran_9))
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id
			and 
			

recon_business_date IN 
			(
			SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
			
			)

			
			)
                        LEFT join post_currencies p (NOLOCK) ON (t.tran_currency_code = p.currency_code)
	WHERE 		
	
	
	
	            t.tran_completed = 1
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ( SELECT part FROM  usf_split_string('0100,0120,0200,0220,0400,0420',','))
				AND
				t.tran_completed = 1
				--AND 
				--(substring (c.totals_group,1,3)=substring(@SinkNode,4,3))
                                AND
				tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                               AND
                                rsp_code_rsp IN ('00','11','08','10','16')
                                And
                             (pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                  AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
			WHERE (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END








GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Cardless]    Script Date: 04/21/2016 10:12:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE[dbo].[osp_rpt_b06_all_Cardless]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
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
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	
SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)

        
        
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
            c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			
			/*	
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			*/
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(tt.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            left join 
            post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                          tt.tran_postilion_originated = 1
                                          and t.tran_nr = tt.tran_nr)
            
	
WHERE 			
	
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc')
			AND 
			t.sink_node_name not like 'TSS%'
            and t.sink_node_name not like '%TPP%'
                        and c.source_node_name not like '%TPP%'
			AND
			t.sink_node_name in ('ESBCSOUTsnk')
			AND
			(c.terminal_id not like '2%')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 (Case when retention_data = '0' then sink_node_name
              else retention_data end) as sink_node_name,

                 retention_data,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result 
			
			WHERE (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,retention_data
	ORDER BY 
			source_node_name
END








GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_NOU]    Script Date: 04/21/2016 10:12:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO








ALTER PROCEDURE[dbo].[osp_rpt_b06_all_NOU]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
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
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	/*
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	--DECLARE @report_date_start		DATETIME
	--DECLARE @report_date_end		DATETIME
	
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

	*/

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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	
	SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)

	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			
			/*	
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
			
	
WHERE 			
	

			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			rsp_code_rsp IN ('11','00')
			AND 
			c.source_node_name not like 'SWTASP%'
			AND 
			c.source_node_name not like 'TSS%'
			AND 
			c.source_node_name not like '%WEB%'
			AND 
			c.source_node_name not like 'VAUMO%'
			AND
			c.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
                       and t.sink_node_name not like '%TPP%'
                        and c.source_node_name not like '%TPP%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk')
			AND
			(c.terminal_id not like '2%')
            AND
             c.source_node_name  NOT LIKE 'SB%'
            AND
           t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)as amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
			WHERE 
(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

			
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
END










GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_verve_int]    Script Date: 04/21/2016 10:12:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER PROCEDURE[dbo].[osp_rpt_b06_all_verve_int]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored proc.
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
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
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999),
        tran_postilion_originated          CHAR (1),
        acquiring_inst_id_code                  VARCHAR (8)
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	*/
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	
SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)
        

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;

        

create table #foreign_amt
(foreign_amount float, foreign_fee float,  TranID BIGINT)

Insert into #foreign_amt 

select -1*p.settle_amount_impact/100,
master.dbo.formatAmount(-1 * p.settle_tran_fee_rsp/100, p.settle_currency_code) AS settle_tran_fee_rsp,
 p.tran_nr  from post_tran p WITH (NOLOCK, INDEX (ix_post_tran_9))
                               
                                 INNER JOIN
				 post_tran_cust c WITH (NOLOCK) ON (p.post_tran_cust_id = c.post_tran_cust_id)
				 
	
WHERE 			

                   p.tran_postilion_originated = 0
                                 and
       					(p.post_tran_id >= @first_post_tran_id) 
					AND 
					(p.post_tran_id <= @last_post_tran_id) 
					AND
				datetime_req >= @report_date_start

				
				AND
				p.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				p.tran_completed = 1
				--AND 
				--(substring (c.totals_group,1,3)=substring(@SinkNode,4,3))
                                AND
				p.tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             p.sink_node_name  NOT LIKE 'SB%'



	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
			c.terminal_owner,
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.tran_nr as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,			
			t.settle_currency_code, 
			
			
			/*	
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data,
                        t.tran_postilion_originated,
                       t.acquiring_inst_id_code
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			


				--c.post_tran_cust_id >= @rpt_tran_id
			          t.tran_completed = 1
				AND
									(t.post_tran_id >= @first_post_tran_id) 
					AND 
					(t.post_tran_id <= @last_post_tran_id) 
					AND
				datetime_req >= @report_date_start
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				t.tran_completed = 1

				--AND 
				--(substring (c.totals_group,1,3)=substring(@SinkNode,4,3))
                                AND
				t.tran_type = ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                             (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

			
			
			
			
	
	IF @@ROWCOUNT = 0	

			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)

CREATE TABLE #report_result_2
	(
		Warning						VARCHAR (255),	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
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
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999),
                tran_postilion_originated          CHAR (1),
                acquiring_inst_id_code                  VARCHAR (8),
                foreign_amount float, 
                foreign_fee float,
                TranID_2 BIGINT
	)	
	
Insert into #report_result_2
	
SELECT
			distinct 
			r.*,f.*
	FROM
			#report_result r
      inner join #foreign_amt f
      on r.tranId = f.tranId 
      where r.tran_postilion_originated = 1
	ORDER BY  r.datetime_tran_local


	
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
                 acquiring_inst_id_code,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 sink_node_name,
		 sum(settle_tran_fee_rsp) as fee,
                 sum(foreign_fee) as foreign_fee,
		 sum(settle_amount_impact)as amount,
                 sum(foreign_amount)as foreign_amount,
		SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result_2

 where
	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tranID))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,acquiring_inst_id_code 
	ORDER BY 

			source_node_name
END










GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_SwitchedIn]    Script Date: 04/21/2016 10:13:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE[dbo].[osp_rpt_b06_SwitchedIn]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
SET NOCOUNT ON


	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		recon_business_date				DATETIME, 
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
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
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),	
		tran_reversed				INT,	
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM #report_result
		RETURN 1
	END
	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id, -- oremeyi added this
           		c.source_node_name, --oremeyi added this
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.settle_currency_code, 
			
			
			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
						
					END
					, t.settle_currency_code) AS settle_amount_impact,

					

			
			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			t.tran_reversed,
			master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx
	FROM
			post_tran t (NOLOCK) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id
                                 AND
								recon_business_date in (SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end))
								and
                                t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0 )
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			
			AND
			t.message_type IN ('0100','0120','0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			
			AND 
			c.source_node_name = @SourceNode
            AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			
	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END







GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Verve_Int]    Script Date: 04/21/2016 10:13:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






























ALTER PROCEDURE[dbo].[osp_rpt_b06_Verve_Int]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@AcquirerBin     	VARCHAR(40),
	@show_full_pan	 	INT,		-- 0/1/2: Masked/Clear/As is
        @rpt_tran_id INT = NULL
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate				VARCHAR (30),
		EndDate				VARCHAR (30),
		pan							VARCHAR (19),
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
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr		CHAR (6),
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		DollarRate				FLOAT,
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description VARCHAR (MAX),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (MAX),
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		isDeclinedForcePost			INT,
		pan_encrypted				CHAR (18),
		auth_is_rsp				VARCHAR(10),
                acquiring_inst_id_code                  VARCHAR (25),
         from_account_id                  VARCHAR (25)
	)

	-- Validate the source node
	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
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
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = 'Last business day'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

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
	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode

        CREATE TABLE #list_of_AcquirerBin (AcquirerBin	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquirerBin EXEC osp_rpt_util_split_nodenames @AcquirerBin
	
	SELECT * INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req )>1 

create table #foreign_amt
(foreign_amount float, foreign_fee float, TranID BIGINT )

Insert into #foreign_amt 

select 
master.dbo.formatAmount(tran_amount_req, tran_currency_code)As tran_amount_rsp, 
master.dbo.formatAmount(-1 * p.settle_tran_fee_rsp, p.settle_currency_code) AS settle_tran_fee_rsp,
p.post_tran_cust_id  from       post_tran p WITH (NOLOCK, INDEX (ix_post_tran_9))
                                 
                                INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (p.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

                                -- c.post_tran_cust_id >= @rpt_tran_id
                                and p.tran_postilion_originated = 0
                                and
                                (p.recon_business_date >= @report_date_start)
				
				and (p.recon_business_date <= @report_date_end)
				
				AND
				p.message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
				p.tran_completed = 1
				AND 
				(p.acquiring_inst_id_code in ( select AcquirerBin from #list_of_AcquirerBin))
                                AND
				p.tran_type IN ('01')
                                  AND
                                c.source_node_name  IN ('SWTMEGAsrc')
                                And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
                 AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             p.sink_node_name  NOT LIKE 'SB%'

	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			t.rsp_code_rsp,
			t.message_type,
			t.datetime_req,

			master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req,
			master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
			master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,

			t.post_tran_cust_id as TranID,
			t.prev_post_tran_id,
			t.system_trace_audit_nr,
			t.message_reason_code,
			t.retrieval_reference_nr,
			t.datetime_tran_local,
			t.from_account_type,
			t.to_account_type,
			1,--dbo.dollar_rate (t.settle_currency_code) as DollarRate,
			t.settle_currency_code,


			master.dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,

			master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			master.dbo.currencyName(t.settle_currency_code) AS currency_name,
			master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,

			master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
                        t.acquiring_inst_id_code,
            t.from_account_id

	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
			
	
WHERE 			
	
(convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	        --c.post_tran_cust_id >= @rpt_tran_id
                        and
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
			c.source_node_name  IN ('SWTMEGAsrc')
			AND
			(t.acquiring_inst_id_code in ( select AcquirerBin from #list_of_AcquirerBin))
                         And
                               (c.pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'
                                or pan like '559453%'or pan like '551609%' or pan like '519909%' 
                                or pan like '519615%' or pan like '528668%')
             AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

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

	SELECT
			distinct 
			r.*,f.*
	FROM
			#report_result r
      inner join #foreign_amt f
      on r.tranId = f.tranId 
      
	ORDER BY  r.datetime_tran_local
END







































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_CashAdvance_VAS]    Script Date: 04/21/2016 10:13:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE[dbo].[osp_rpt_CashAdvance_VAS]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	---@SinkNode		VARCHAR(40),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON

	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
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
		tran_type_desciption  VARCHAR (MAX),
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
		Network_ID			CHAR(255),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25)
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Previous month'
			
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

	SELECT tran_nr, retrieval_reference_nr INTO #tbl_late_reversals FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 

    CREATE NONCLUSTERED INDEX ix_tran_nr  ON  #tbl_late_reversals (
		tran_nr
		)
    CREATE NONCLUSTERED INDEX ix_retrieval_reference_nr  ON  #tbl_late_reversals (
		retrieval_reference_nr
		)
	
	-- Only look at 02xx messages that were not fully reversed.
	
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
				t.datetime_req, 
				--t.extended_tran_type,
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				master.dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				structured_data_req,
				master.dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,

				master.dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
				payee,
				t.from_account_id,
				t.to_account_id,
				t.payee
				
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
	  			
				--c.post_tran_cust_id >= @rpt_tran_id--'8153074 
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0 
				AND
				(c.terminal_id like '2%' AND t.message_type = '0200')
				
				AND
				c.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')
				AND
				t.tran_type  IN ('01')
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
				
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
			NULL AS Warning,
                @StartDate as StartDate,  
		@EndDate as EndDate,
                card_acceptor_id_code,
                card_acceptor_name_loc,
                sink_node_name,
                datetime_req,
                tran_type,
                acquiring_inst_id_code,
                case
                                when acquiring_inst_id_code= 589019 then 'FBN'             
                                when acquiring_inst_id_code= 627480 then 'UBA'
                                when acquiring_inst_id_code= 627629 then 'ZIB'                               
                                when acquiring_inst_id_code= 627787 then 'GTB'
                                when acquiring_inst_id_code= 627805 then 'PRU'
                                when acquiring_inst_id_code= 603948 then 'OBI'
                                when acquiring_inst_id_code= 627858 then 'IBTC'
                                when acquiring_inst_id_code= 627819 then 'AFRI'
                                when acquiring_inst_id_code= 627821 then 'WEM'
                                when acquiring_inst_id_code= 627955 then 'PHB'
                                when acquiring_inst_id_code= 628009 then 'FCMB'
                                when acquiring_inst_id_code= 627168 then 'DBL'
                                when acquiring_inst_id_code= 000000 then 'DBL'
                                when acquiring_inst_id_code= 602980 then 'UBN'
                                when acquiring_inst_id_code= 639249 then 'ETB'
                                when acquiring_inst_id_code= 639138 then 'FBP'
                                when acquiring_inst_id_code= 636088 then 'IBP'
                                when acquiring_inst_id_code= 639203 then 'FIN'
                                when acquiring_inst_id_code= 639139 then 'ABP'
                                when acquiring_inst_id_code= 636092 then 'SBP'
                                when acquiring_inst_id_code= 903708 then 'EBN'
                                when acquiring_inst_id_code= 639609 then 'UBP'
                                when acquiring_inst_id_code= 639563 then 'SPR'
                                when acquiring_inst_id_code= 023023 then 'CITI'
                                else 'Not Registered'             
                end as Bank,
                
               cast(sum ((settle_amount_impact) ) * -1 as numeric(18, 2)) as tran_value,
                sum (
                                case
                                                when settle_amount_impact < 0 then 1
                                                else 1
                                end) tran_volume
	FROM 
			#report_result
			
			  where   (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)

	GROUP BY card_acceptor_id_code,card_acceptor_name_loc,sink_node_name,datetime_req,tran_type,acquiring_inst_id_code
	ORDER BY 
				sink_node_name, acquiring_inst_id_code, datetime_req
END








GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_cashcard_load]    Script Date: 04/21/2016 10:13:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
















ALTER PROCEDURE[dbo].[osp_rpt_cashcard_load]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@CBNCodes		VARCHAR(40),
	@totalsgroups		VARCHAR(40),
	@ALLBINs		VARCHAR(255),
	@show_full_pan		BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	
	
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40), 
		acquiring_inst_id_code		VARCHAR(25),
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40),
		structured_data_req		VARCHAR (512), 
		--prepaid_merchandise		VARCHAR(512),
		to_cashcard_account_id	VARCHAR (512),
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (30),
		rsp_code_description	VARCHAR (60),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR(18),
		extended_tran_type		CHAR (18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(512),
		totals_group			Char(25),
		Bank_institution_name		varchar(50)      

	)

	
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


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_totalsgroup (bin VARCHAR(30))
	INSERT INTO  #list_of_totalsgroup EXEC osp_rpt_util_split_nodenames @totalsgroups

	CREATE TABLE #list_of_bins (bin VARCHAR(30))
	INSERT INTO  #list_of_bins EXEC osp_rpt_util_split_nodenames @ALLBINs
	
	CREATE TABLE #list_of_CBNCodes (CBNCode VARCHAR(30))
	INSERT INTO  #list_of_CBNCodes EXEC osp_rpt_util_split_nodenames @CBNCodes

	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
	
	-- Only look at 02xx messages that were not fully reversed.
	
	  
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				c.source_node_name,
				c.pan,
				--dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				1,
				CASE
					WHEN t.tran_type = '21'THEN c.pan		
					ELSE t.payee 
				END AS to_cashcard_account_id,
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				

				master.dbo.formatAmount( 			
					CASE						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				extended_tran_type,
				from_account_id,
				to_account_id,
				payee,
				totals_group,
				1--'bank_institution_name' =(SELECT TOP 1 BANK_INSTITUTION_NAME FROM acquirer_institution_table  WHERE INST_SINK_CODE = substring(substring(t.sink_node_name,4, LEN(t.sink_node_name)), 1,len(substring(t.sink_node_name,4, LEN(t.sink_node_name)))-3) ) 	
	FROM
					post_tran t (NOLOCK, INDEX(ix_post_tran_9)) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id
                                 AND
								recon_business_date in (SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end))
								and
                                t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0
		
			AND
                left(c.source_node_name,2) <> 'SB'
                   AND
               left( t.sink_node_name   ,2) <> 'SB'
				
			)
				--LEFT JOIN 
				--acquirer_institution_table  d (NOLOCK) ON substring (t.sink_node_name,4,3) = d.inst_sink_code
	WHERE 
				
								
				
				(
				(t.message_type IN ('0200', '0220', '0400', '0420'))
				
				)
				AND
				tran_type <> 39	
				AND 
				((c.source_node_name = 'CCLOADsrc')
				 OR
				(LEFT(pan,7)= '6280512' and tran_type =21))
				AND
				(
					LEFT(pan,6) IN (SELECT bin FROM #list_of_bins) --their debit Card doing the loading
					OR
					LEFT(pan,11) IN (SELECT bin FROM #list_of_bins)--their cashcard doing the loading
					OR

					--(LEFT(pan,7)= '6280512' and (SUBSTRING(c.totals_group,1,3)= substring(@SinkNode,4,3)) ) --their other interswitch card e.g autopay card  doing the loading
					 --(sink_node_name= 'CCLOADsnk') OR--their other interswitch card e.g autopay card  doing the loading				
					
					(--LEFT(pan,6)like '628051%' and 
                                        (SUBSTRING(c.totals_group,1,3)in (select substring(sink_node,4,3) FROM #list_of_sink_nodes))) --and sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)) --their other interswitch card e.g autopay card  doing the loading
					OR 
					(
                                         SUBSTRING(payee,9,3) IN (SELECT CBNCode FROM #list_of_CBNCodes)
                                         or (len(payee) = 25 and SUBSTRING(payee,15,3) IN (SELECT CBNCode FROM #list_of_CBNCodes))) --their CashCard being loaded
					OR
					(
						t.acquiring_inst_id_code IN (SELECT bin FROM #list_of_bins)--other cards using their terminals to load cards that aint theirs 
						and 
						t.settle_tran_fee_rsp <> 0
					
					)
				)
                
	ORDER BY 
			datetime_tran_local, source_node_name
			
			OPTION  (RECOMPILE)
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
		
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		

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

	
END




 




 











































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_cashcard_load_ecash]    Script Date: 04/21/2016 10:13:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO















ALTER PROCEDURE[dbo].[osp_rpt_cashcard_load_ecash]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@CBNCodes		VARCHAR(40),
	@totalsgroups		VARCHAR(40),
	@ALLBINs		VARCHAR(255),
	@show_full_pan		BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@payee varchar(15)

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION  LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	
	
	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (40), 
		acquiring_inst_id_code		VARCHAR(25),
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40),
		structured_data_req		VARCHAR (512), 
		--prepaid_merchandise		VARCHAR(512),
		to_cashcard_account_id	VARCHAR (512),
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		settle_amount_req		FLOAT, 
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,				
		TranID					BIGINT,
		prev_post_tran_id		BIGINT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_desciption  VARCHAR (MAX),
		rsp_code_description	VARCHAR (30),
		settle_nr_decimals		BIGINT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR(18),
		extended_tran_type		CHAR (18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(512),
		totals_group			Char(25),
		Bank_institution_name		varchar(50)      

	)

	
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


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_totalsgroup (bin VARCHAR(30))
	INSERT INTO  #list_of_totalsgroup EXEC osp_rpt_util_split_nodenames @totalsgroups

	CREATE TABLE #list_of_bins (bin VARCHAR(30))
	INSERT INTO  #list_of_bins EXEC osp_rpt_util_split_nodenames @ALLBINs
	
	CREATE TABLE #list_of_CBNCodes (CBNCode VARCHAR(30))
	INSERT INTO  #list_of_CBNCodes EXEC osp_rpt_util_split_nodenames @CBNCodes

	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
	
	-- Only look at 02xx messages that were not fully reversed.
	
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT

	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				c.source_node_name,
				c.pan,
				--dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				t.acquiring_inst_id_code,
				c.source_node_name,
				t.sink_node_name, 
				1,
				CASE
					WHEN t.tran_type = '21'THEN c.pan		
					ELSE t.payee 
				END AS to_cashcard_account_id,
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				master.dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				master.dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				master.dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.settle_currency_code, 
				
				--master.dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				

				master.dbo.formatAmount( 			
					CASE						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				master.dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				master.dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				master.dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				master.dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				master.dbo.currencyName(t.settle_currency_code) AS currency_name,
				master.dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				master.dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				master.dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				master.dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				master.dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				master.dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				master.dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				extended_tran_type,
				from_account_id,
				to_account_id,
				payee,
				totals_group,
				1--'bank_institution_name' =(SELECT TOP 1 BANK_INSTITUTION_NAME FROM acquirer_institution_table  WHERE INST_SINK_CODE = substring(substring(t.sink_node_name,4, LEN(t.sink_node_name)), 1,len(substring(t.sink_node_name,4, LEN(t.sink_node_name)))-3) ) 	
	FROM
				post_tran t (NOLOCK) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id
                                 AND
								recon_business_date in (SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end))
								and
                                t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0
			and
				(t.message_type IN ('0200', '0220', '0400', '0420'))
				
				)
				
				--LEFT JOIN 
				--acquirer_institution_table  d (NOLOCK) ON substring (t.sink_node_name,4,3) = d.inst_sink_code
	WHERE 
				
						
				(t.post_tran_id >= @first_post_tran_id   )
				AND
				( t.post_tran_id <= @last_post_tran_id   ) 	
				
		
				AND
				((
				tran_type <> 39
				and 
				(left(payee,11) = @payee
				
				)

				AND 
				((c.source_node_name = 'CCLOADsrc')
				 OR
				(LEFT(pan,7)= '6280512' and tran_type =21))
				AND
				(
					LEFT(pan,6) IN (SELECT bin FROM #list_of_bins) --their debit Card doing the loading
					OR
					LEFT(pan,11) IN (SELECT bin FROM #list_of_bins)--their cashcard doing the loading
					OR

					--(LEFT(pan,7)= '6280512' and (SUBSTRING(c.totals_group,1,3)= substring(@SinkNode,4,3)) ) --their other interswitch card e.g autopay card  doing the loading
					 --(sink_node_name= 'CCLOADsnk') OR--their other interswitch card e.g autopay card  doing the loading				
					
					(--LEFT(pan,6)like '628051%' and 
                                        (SUBSTRING(c.totals_group,1,3)in (select substring(sink_node,4,3) FROM #list_of_sink_nodes))) --and sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)) --their other interswitch card e.g autopay card  doing the loading
					OR 
					(
                                         SUBSTRING(payee,9,3) IN (SELECT CBNCode FROM #list_of_CBNCodes)
                                         or (len(payee) = 25 and SUBSTRING(payee,15,3) IN (SELECT CBNCode FROM #list_of_CBNCodes))) --their CashCard being loaded
					OR
					(
						t.acquiring_inst_id_code IN (SELECT bin FROM #list_of_bins)--other cards using their terminals to load cards that aint theirs 
						and 
						t.settle_tran_fee_rsp <> 0
					
					)
				)
                AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             )
             OR 
             
				structured_data_req like '%load%verve%ecash%')
				
	ORDER BY 
			datetime_tran_local, source_node_name
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
		
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		

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
	insert into ECash_Recon
SELECT 
			*
	FROM 
			#report_result
			
	
END
 



 




 










































































GO


