USE [postilion_office]
GO
USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[get_dates_in_range]    Script Date: 04/12/2016 12:57:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE FUNCTION [dbo].[get_dates_in_range]
(
     @StartDate    VARCHAR(30)  
    ,@EndDate    VARCHAR(30)   
)
RETURNS
@DateList table
(
    Date datetime
)
AS
BEGIN


IF ISDATE(@StartDate)!=1 OR ISDATE(@EndDate)!=1
BEGIN
    RETURN
END

while (DATEDIFF(D,  @StartDate,@EndDate)>=0) BEGIN 

INSERT INTO @DateList
        (Date)
    SELECT
        @StartDate
SET  @StartDate = DATEADD(D, 1 ,@StartDate);
        END


RETURN
END

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
		pan_encrypted			CHAR(18),
		from_account_id			VARCHAR(28),
		to_account_id			VARCHAR(28),
		payee				char(25),
		totals_group			varchar(12),
                extended_tran_type            char (4)          
	)			

	IF (@Terminal_IDs IS NULL or Len(@Terminal_IDs)=0)
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
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 

	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs

        CREATE TABLE #list_of_sink_nodes (SinkNode	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode

	DECLARE @tbl_late_reversals TABLE (tran_nr BIGINT, retrieval_reference_nr VARCHAR(20))
       

	INSERT
			INTO #report_result

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
			post_tran t (NOLOCK, INDEX(ix_post_tran_9)) 
                                INNER JOIN 
                                post_tran_cust c (NOLOCK) 
                   ON (t.post_tran_cust_id = c.post_tran_cust_id
                   AND
                   recon_business_date in (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									) AND
                   	t.tran_postilion_originated = 0
			AND 
			tran_completed = 1 
			
			AND
			
			 LEFT( c.source_node_name,2)<> 'SB'
             AND
             LEFT(t.sink_node_name,2)  <> 'SB'
                   ) 
                                
                       

	
WHERE 			
 
            
	
			((
			tran_type = '50'--this won't work for Autopay CCLoad cos the intrabank trans are 00
			AND
			sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
			AND
			source_node_name NOT IN ('CCLOADsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			
			AND
           		(terminal_id IN ('3EPY0701','3UIB0001', '3IPD0010','3IPDTROT', '3VRV0001', '3IGW0010', '3SFX0014' )
				or
 			LEFT(terminal_id, 4)  IN ('3IGW', '3CCW','3IBH', '3CPD', '3011','3SFA') OR   LEFT(terminal_id, 5)   = '3ADPS'
                        OR 
		        (terminal_id = '3BOL0001' and extended_tran_type = '8502')

			)
			)OR
			(terminal_id like '3CPD%' and t.tran_type = '00')
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
           

OPTION(RECOMPILE)

				
	


IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
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

	--	-- Get pan and pan_encrypted from #report_result and post_tran_cust using a cursor
	--	DECLARE pan_cursor CURSOR FORWARD_ONLY
	--	FOR
	--		SELECT
	--				pan,
	--				pan_encrypted
	--		FROM
	--				#report_result
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
	--					#report_result
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
			#report_result 
	
             where 
	 

(convert(varchar(12),tranID))+'_'+retrieval_reference_nr  not in 
		 (SELECT convert(varchar(12),tran_nr)+'_'+retrieval_reference_nr FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 ) 
         		

			
	ORDER BY 
			datetime_req
END





























































