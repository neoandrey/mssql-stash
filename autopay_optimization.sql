USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Autopay]    Script Date: 04/10/2016 12:08:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[osp_rpt_b04_Autopay]
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

	DECLARE   @report_result TABLE
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
		tran_type_description		VARCHAR (250),		
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
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Terminal ID parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END
    
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

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM @report_result
		RETURN 1
	END


	
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 
	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @TerminalID

	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;
	SELECT @first_post_tran_cust_id =post_tran_cust_id FROM post_tran (NOLOCK) WHERE post_tran_id = @first_post_tran_id
	SELECT @last_post_tran_cust_id =post_tran_cust_id FROM post_tran (NOLOCK) WHERE post_tran_id = @last_post_tran_id
	
;WITH post_tran_table(
		sink_node_name, 
		post_tran_cust_id,
		tran_type, 
		tran_reversed,
		rsp_code_rsp, 
		message_type, 
		datetime_req,
		settle_amount_req, 
		settle_currency_code,
		settle_amount_rsp,
		settle_tran_fee_rsp,
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
		payee
)   AS ( SELECT 
            sink_node_name,
            post_tran_cust_id, 
		tran_type, 
		tran_reversed,
		rsp_code_rsp, 
		message_type, 
		datetime_req,
		settle_amount_req, 
		settle_currency_code,
		settle_amount_rsp,
		settle_tran_fee_rsp,
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
		payee 
	FROM

post_tran
 (NOLOCK, INDEX(ix_post_tran_9))
WHERE
    recon_business_date   in 
  (  
    select [Date] from  dbo.get_dates_in_range(@report_date_start,@report_date_end)
    
    )   
AND
tran_completed = 1
AND
tran_postilion_originated = 0
AND
message_type IN ('0200','0220','0400','0420')
AND
tran_type NOT IN ('31','38')
AND
 left(sink_node_name,2 ) != 'SB'
), 
post_tran_cust_table (post_tran_cust_id, card_acceptor_id_code, card_acceptor_name_loc, source_node_name,terminal_id,pan_encrypted,totals_group,pan) AS

(
SELECT 
	post_tran_cust_id, card_acceptor_id_code, card_acceptor_name_loc, source_node_name,terminal_id,pan_encrypted,totals_group ,pan

FROM  
post_tran_cust 
 (NOLOCK)
WHERE
post_tran_cust_id>= @first_post_tran_cust_id
AND
post_tran_cust_id<= @last_post_tran_cust_id
	and
			terminal_id   like '3IAP%'
			 AND
			  left(source_node_name,2 ) != 'SB'
)
		insert	INTO @report_result
 

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  

			@EndDate as EndDate,
			 CASE WHEN  @show_full_pan =1 THEN dbo.usf_decrypt_pan(pan, pan_encrypted)
			 ELSE pan
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
			post_tran_table t (NOLOCK) 
                                 JOIN 
                                post_tran_cust_table c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id 
                                --AND
                                --	datetime_req >= @report_date_start
			

					) 
                      
	
WHERE 			
				

			
			(			
				(t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes))
			OR	(substring(t.sink_node_name,4,3) in (SELECT substring(sink_node,4,3) FROM #list_of_sink_nodes))---and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			OR	(LEFT(pan,6) = '628051' and (substring(c.totals_group,1,3)in (SELECT substring(sink_node,4,3) FROM #list_of_sink_nodes))
			and source_node_name  IN (SELECT source_node FROM #list_of_source_nodes)and t.sink_node_name  IN (SELECT sink_node FROM #list_of_sink_nodes))
			)
		

        	OPTION(recompile)	
		

			IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT *
	FROM
			@report_result

 WHERE 
	     	     (convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(12),tran_nr))+'_'+retrieval_reference_nr from tbl_late_reversals(nolock))
				
	ORDER BY 
			datetime_req
			OPTION(recompile,maxdop 8)	
		
ENd
























































