USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Verve_Int]    Script Date: 08/06/2017 10:49:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[osp_rpt_b04_Verve_Int]
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
		StartDate					CHAR (8),
		EndDate						CHAR (8),
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
dbo.formatAmount(-1 * p.settle_tran_fee_rsp/100, p.settle_currency_code) AS settle_tran_fee_rsp,
p.post_tran_cust_id  from 

( SELECT * from post_tran t WITH (NOLOCK, INDEX(ix_post_tran_9))
			JOIN (	 SELECT  [DATE] recon_business_date2 FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)  r
					on 
					t.recon_business_date = r.recon_business_date2 AND  post_tran_id NOT IN (
					SELECT  t.post_tran_id FROM  ( SELECT * from post_tran t WITH (NOLOCK, INDEX(ix_post_tran_9))
			JOIN (	 SELECT  [DATE] recon_business_date1 FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)  r
					on 
					t.recon_business_date = r.recon_business_date1 )t2  JOIN tbl_late_reversals l1 with  (NOLOCK) on t2.tran_nr =l1.tran_nr 
					and t2.retrieval_reference_nr = l1.retrieval_reference_nr
					
					)  and tran_postilion_originated = 0  	 and				(post_tran_id >= @first_post_tran_id) 
					AND 
				(post_tran_id <= @last_post_tran_id) 
					AND
				datetime_req >= @report_date_start 

				
				AND
				message_type IN ('0100', '0120', '0200', '0220', '0400', '0420')
				AND
			tran_completed = 1 )p
                                
                                 INNER JOIN
				 post_tran_cust c WITH (NOLOCK, INDEX = PK_POST_TRAN_CUST) ON (p.post_tran_cust_id = c.post_tran_cust_id)
				
	
WHERE 			
	
 

                                 --c.post_tran_cust_id >= @rpt_tran_id
			         
                                 
                            
     
				
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

			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
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
				post_tran t WITH (NOLOCK, INDEX (ix_post_tran_9))
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
				
			
WHERE 			
	
 (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr  not in 
	     (select (convert(varchar(50),tran_nr))+'_'+retrieval_reference_nr from #tbl_late_reversals)
                                

				--c.post_tran_cust_id >= @rpt_tran_id
			         AND t.tran_completed = 1
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





