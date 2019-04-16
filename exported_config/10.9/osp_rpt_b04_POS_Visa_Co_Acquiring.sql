










CREATE                                           PROCEDURE osp_rpt_b04_POS_Visa_Co_Acquiring
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@cbn_code		CHAR(3),
	@SourceNodes	VARCHAR(255),
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  			VARCHAR(12),
		merchant_disc				DECIMAL(7,4),
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
                settle_currency_code char(3),
                retrieval_reference_nr char (12),
                TranID					INT,
		prev_post_tran_id		INT, 
                message_reason_code		CHAR (4),
                datetime_tran_local		DATETIME, 
                merchant_account_nr  VARCHAR(50),
                totals_group		Varchar(40),
                tran_type_desciption	VARCHAR (60),
		rsp_code_description	VARCHAR (30)
                
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

	

	If @startdate is null 
set @report_date_start = dbo.DateOnly(getdate()-1)

If @enddate is null 
set @report_date_end = dbo.DateOnly(getdate()-1)




SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

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


        CREATE TABLE #list_of_cbn_code(cbn_code	CHAR(3)) 
	
	INSERT INTO  #list_of_cbn_code EXEC osp_rpt_util_split_nodenames @cbn_code

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
				
				ISNULL(m.merchant_disc,0.0),
				

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
				t.tran_reversed,	 
					
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
					extended_tran_type,
					system_trace_audit_nr,-----------added by ij 2010/04/01
                                        t.settle_currency_code,
                                t.retrieval_reference_nr, 
                                t.post_tran_cust_id as TranID,
                                t.prev_post_tran_id,
                                t.message_reason_code,
                                t.datetime_tran_local, 
                                ISNULL(a.account_nr,'not available'),
                                c.totals_group ,
                                dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description
                                
                                
                                
                                 
	FROM
			
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN merchant_category_msc m (NOLOCK)
				ON m.MID = c.card_acceptor_id_code 
                                left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code 
				--left JOIN tbl_xls_settlement y (NOLOCK)
				
                                

                                
	WHERE 			
				
				c.post_tran_cust_id >= @rpt_tran_id
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
				tran_type NOT IN ('31','39','50','21')
				--AND 
				--t.sink_node_name = @SinkNode
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
                                AND
				substring(c.terminal_id,2,3) IN (SELECT cbn_code FROM #list_of_cbn_code)
				AND 
					(
					--(c.terminal_id like '3IWP%') OR
					--(c.terminal_id like '3ICP%') OR
					(c.terminal_id like '2%')OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(c.terminal_id like '5%') OR
                                        --(c.terminal_id like '31WP%') OR
					--(c.terminal_id like '31CP%') OR
					(c.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				

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
