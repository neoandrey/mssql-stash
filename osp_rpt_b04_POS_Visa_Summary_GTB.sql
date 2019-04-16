USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_POS_Visa_Summary_GTB]    Script Date: 03/03/2015 17:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






ALTER                                         PROCEDURE [dbo].[osp_rpt_b04_POS_Visa_Summary_GTB]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL
         

AS
BEGIN
	SET NOCOUNT ON

	DECLARE   @report_result TABLE
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
                settle_currency_code char(3)
		)
		
		 DECLARE  @report_result_2 TABLE (
              Warning  VARCHAR(1000),
                 StartDate  DATETIME,
		 EndDate   DATETIME,
		 card_acceptor_id_code  VARCHAR(30), 
		 card_acceptor_name_loc VARCHAR(30), 
		 acquiring_inst_id_code VARCHAR(30),
		
		merchant_disc VARCHAR(30),
		 tran_type VARCHAR(30),
                 cbn_code VARCHAR(10),
		
		  amount FLOAT,
		 fee  FLOAT,
		  tran_count BIGINT,
                        settle_currency_code VARCHAR(10)
                        )

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result_2 (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result_2
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
	   	INSERT INTO @report_result_2 (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result_2
		RETURN 1
	END

	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result_2 (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM @report_result_2
		RETURN 1
	END

	DECLARE  @list_of_source_nodes  TABLE(source_node	VARCHAR(255)) 
	
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',');

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
                                        t.settle_currency_code
                                 
	FROM
			
			 	post_tran t (NOLOCK , INDEX(ix_post_tran_7))
				INNER JOIN   post_tran_cust c (NOLOCK, INDEX(pk_post_tran_cust))
				ON  t.post_tran_cust_id = c.post_tran_cust_id
			   left JOIN  merchant_category_msc m (NOLOCK)
				ON m.MID = c.card_acceptor_id_code 
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
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
					(
					--(c.terminal_id like '3IWP%') OR
					--(c.terminal_id like '3ICP%') OR
					 LEFT(c.terminal_id,1)='2' OR--(c.terminal_id like '2%' AND c.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(LEFT(c.terminal_id,1)= '5') OR
                                        --(c.terminal_id like '31WP%') OR
					--(c.terminal_id like '31CP%') OR
					(LEFT(c.terminal_id,1) ='6')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				

	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
INSERT INTO 
@report_result_2		
	SELECT 
	  NULL,
		 StartDate,
		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 acquiring_inst_id_code,
		
		merchant_disc,
		 tran_type,
                substring(terminal_id,2,3) as cbn_code,
		
		 SUM(settle_amount_impact * -1)as amount,
		 SUM(settle_tran_fee_rsp *-1) as fee,
		 SUM(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count,
                        settle_currency_code
                        --late_reversal_id
                   
	 
	FROM 
			@report_result

                       
	GROUP BY
			StartDate, enddate,
			merchant_disc,acquiring_inst_id_code,tran_type, 
			card_acceptor_id_code, card_acceptor_name_loc
			 ,substring(terminal_id,2,3),settle_currency_code-- tran_type_description, 
	ORDER BY 
			acquiring_inst_id_code



SELECT * FROM @report_result_2
END





