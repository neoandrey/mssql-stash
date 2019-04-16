USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_NOU_cardless]    Script Date: 07/08/2016 12:44:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE[dbo].[osp_rpt_b06_all_NOU_cardless]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN

	-- The B06 report uses this stored prot.
	
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	

	DECLARE   @report_result TABLE
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
		rsp_code_description VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (255),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(500),
		fee			decimal(15,2),
		fee_group  decimal(15,2),
		amounnt decimal(15,2),
		tran_count decimal(15,2)
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
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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
	

        
	INSERT
			INTO @report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
			t.terminal_id, -- oremeyi added this
			t.terminal_owner,
           		t.source_node_name, --oremeyi added this
			t.card_acceptor_id_code, 
			t.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 
			
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			
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
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END

					, t.settle_currency_code) AS settle_amount_impact,
			*/
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN t.settle_amount_impact
						ELSE -1 * t.settle_amount_impact
					END
					, t.settle_currency_code) AS settle_amount_impact,
			
			dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
			dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			dbo.currencyName(t.settle_currency_code) AS currency_name,
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			t.retention_data,
			0,
			0,
			0,
			0
			
	FROM
			post_tran_summary t (NOLOCK)
			
			 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@report_date_start,@report_date_end)
					)r
				ON
					r.recon_business_date = t.recon_business_date
					and
					post_tran_id NOT IN (
					SELECT  post_tran_id  FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
					)
	
WHERE 			
	
 
	 		--t.post_tran_cust_id >= @rpt_tran_id
			
			t.tran_completed = 1
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
			t.source_node_name not like 'SWTASP%'
			AND 
			t.source_node_name not like 'TSS%'
			AND 
			t.source_node_name not like '%WEB%'
			AND 
			t.source_node_name not like 'VAUMO%'
			AND
			t.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
                        and t.sink_node_name not like '%TPP%'
                        and t.source_node_name not like '%TPP%'
			AND
			t.sink_node_name in ('ESBCSOUTsnk')
			AND
			(t.terminal_id not like '2%')
            AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			--AND
			--t.terminal_id like '1%'
			
			OPTION (RECOMPILE, MAXDOP 8)
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 fee_group =  CONVERT(decimal(20,2) , ABS(settle_tran_fee_rsp)) ,
		 sink_node_name,
		 fee = CONVERT(decimal(20,2)  , sum(settle_tran_fee_rsp)) ,
		amount =   CONVERT(decimal(20,2)  ,sum(settle_amount_impact) ),
		tran_count =  CONVERT(INT,SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END) 
)
	
	FROM
			@report_result
			 
		
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
					OPTION (RECOMPILE, MAXDOP 8)
END










GO


