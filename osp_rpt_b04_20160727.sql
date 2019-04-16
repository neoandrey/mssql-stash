USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04]    Script Date: 07/27/2016 11:07:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO















create PROCEDURE[dbo].[osp_rpt_b04]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNodes		VARCHAR(40),
	@SourceNodes	VARCHAR(255),	-- Seperated by commas
    @Retention_Data VARCHAR (30),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
	--BEGIN TRANSACTION;
	-- The B04 report uses this stored prot.

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

   -- SELECT @rpt_tran_id = (SELECT MIN(first_post_tran_cust_id)  FROM post_normalization_session (NOLOCK) WHERE datetime_creation  >= DATEADD(dd,-1,@report_date_start))

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
	

	
	INSERT
				INTO @report_result
	SELECT   
	     
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				t.recon_business_date,--oremeyi added this 24/02/2009
				SourceNodeAlias = 
				(CASE 
					WHEN t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE t.source_node_name
				END),
				CASE WHEN @show_full_pan=1 THEN dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan)
					ELSE pan
				END
				 AS pan,
				t.terminal_id, 
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.tran_nr as TranID,
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
				t.pan_encrypted,
				t.from_account_id,
				t.payee,
				isnull(t.retention_data,0),
				t.totals_group,
				t.tran_postilion_originated,
				t.tran_nr+t.online_system_id
			
	FROM
			     post_tran_summary t
			    JOIN (	
										SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@report_date_start, @report_date_end)
									)  r
					on 
			    t.recon_business_date = r.recon_business_date
			    and
					post_tran_id NOT IN (
					SELECT  post_tran_id  FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
					)
		 
		
	WHERE 		
			  
				t.tran_completed = 1 AND
				(
				 ( t.retention_data IS NOT NULL AND (LEFT(retention_data,4) in (SELECT Retention_Data FROM @list_of_retention_data))   OR 
				  LEFT (t.totals_group,3) IN (SELECT bank_code FROM @list_of_bank_codes)   AND (t.sink_node_name <>'ESBCSOUTsnk' AND t.retention_data is  NULL))
				
				)
				

				  AND
				t.message_type IN ( SELECT part message_type FROM usf_split_string('0200,0220,0400,0420', ',')) AND t.tran_type  ='01'
				
				AND
                (
					LEFT(t.source_node_name,3) NOT IN  ('TSS','GPR') AND LEFT(t.source_node_name,2) <> 'SB' AND t.source_node_name  NOT LIKE '%CTL%'
					AND LEFT(t.source_node_name,6) <> 'CCLOAD' AND t.source_node_name  NOT LIKE '%FUEL%' AND t.source_node_name  NOT LIKE '%TELCO%'  AND t.source_node_name  NOT LIKE '%TPP%'
					AND t.source_node_name  <> 'SWTMEGAsrc'AND t.source_node_name  <> 'SWTMEGADSsrc' AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
                )
				AND
				(t.sink_node_name NOT IN ( SELECT part  sink_node_name FROM	 usf_split_string('CCLOADsnk,GPRsnk,SWTCTLsnk,VTUsnk,SWTMEGAsnk,VAUMOsnk', ',')) AND LEFT(t.sink_node_name,2) <> 'SB') AND LEFT(t.terminal_id,1)<> '2' 
                                 and t.sink_node_name not  LIKE '%TPP%'
						
						option(recompile)
						
			 IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
			ELSE
			BEGIn	
												

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
		








END




END