USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[get_rsp_code_verve_trans_2]    Script Date: 05/26/2016 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE [dbo].[get_rsp_code_verve_trans_2] @report_date_start DATETIME, @report_date_end DATETIME  AS

BEGIN

			--DECLARE @first_post_tran_cust_id BIGINT
			--DECLARE @last_post_tran_cust_id BIGINT
			--DECLARE @first_post_tran_id BIGINT
			--DECLARE @last_post_tran_id BIGINT
		  
	SET @report_date_start =  ISNULL(@report_date_start, DATEADD(D, -7, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-')));
	SET @report_date_end   =  ISNULL(@report_date_end,    DATEADD(D, 0, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-')));
		
IF (  OBJECT_ID('tempdb.dbo.#report_results') IS NOT NULL) BEGIN
	DROP TABLE #report_results
	DROP TABLE #report_results_2
	DROP TABLE #rsp_code_totals
END

--SET @sink_node_name =isnull(@sink_node_name,'%%')

SELECT  
@report_date_start [start_date],
@report_date_end [end_date],
CASE
	WHEN SUBSTRING(terminal_id, 2,3)='044'	THEN	'Access Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='070'	THEN	'Fidelity Bank'	
	WHEN SUBSTRING(terminal_id, 2,3) in ('221','039')	THEN	'StanbicIBTC'	
	WHEN SUBSTRING(terminal_id, 2,3)='014'	THEN	'Afribank'	
	WHEN SUBSTRING(terminal_id, 2,3)='085'	THEN	'Finbank'	
	WHEN SUBSTRING(terminal_id, 2,3)='068'	THEN	'Standard Chartered Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='023'	THEN	'Citibank'	
	WHEN SUBSTRING(terminal_id, 2,3)='058'	THEN	'Guaranty Trust Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='232'	THEN	'Sterling Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='063'	THEN	'Diamond Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='069'	THEN	'Intercontinental Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='033'	THEN	'United Bank for Africa'	
	WHEN SUBSTRING(terminal_id, 2,3)='050'	THEN	'Ecobank'	
	WHEN SUBSTRING(terminal_id, 2,3)='056'	THEN	'Oceanic Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='032'	THEN	'Union Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='040'	THEN	'Equitorial Trust Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='082'	THEN	'BankPhb'	
	WHEN SUBSTRING(terminal_id, 2,3)='035'	THEN	'Wema bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='011'	THEN	'First Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='076'	THEN	'Skye Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='057'	THEN	'Zenith Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='214'	THEN	'FCMB'	
	WHEN SUBSTRING(terminal_id, 2,3)='084'	THEN	'SpringBank'	
	WHEN SUBSTRING(terminal_id, 2,3)='215'	THEN	'Unity bank'	
ELSE 
   terminal_id
   
END   acquirer,

CASE  
  WHEN CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN  CHARINDEX ( 'ZIB', card_product) > 0  THEN	'Zenith International Bank'
  WHEN  CHARINDEX ( 'PRU', card_product) > 0  THEN	'Skye Bank'
  WHEN  CHARINDEX ( 'PLAT', card_product) > 0  THEN	'PlatinumHabib Bank'
  WHEN  CHARINDEX ( 'CHB', card_product) > 0  THEN	'Stanbic IBTC Bank'
  WHEN  CHARINDEX ( 'GTB', card_product) > 0  THEN	'Guaranty Trust Bank'
  WHEN  CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN  CHARINDEX ( 'FBN', card_product) > 0  THEN	'First Bank of Nigeria'
  WHEN  CHARINDEX ( 'OBI', card_product) > 0  THEN	'Oceanic Bank'
  WHEN  CHARINDEX ( 'WEM', card_product) > 0  THEN	'WEMA Bank Plc'
  WHEN  CHARINDEX ( 'AFRI', card_product) > 0  THEN	'Main Street Bank'
  WHEN  CHARINDEX ( 'ETB', card_product) > 0  THEN	'Equitorial Trust Bank'
  WHEN  CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN  CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN  CHARINDEX ( 'UBN', card_product) > 0  THEN	'Union Bank of Nigeria'
  WHEN  CHARINDEX ( 'FCMB', card_product) > 0  THEN	'First City Monument Bank'
  WHEN  CHARINDEX ( 'DBL', card_product) > 0  THEN	'Diamond Bank'
  WHEN  CHARINDEX ( 'FIB', card_product) > 0  THEN	'First Inland Bank'
  WHEN  CHARINDEX ( 'EBN', card_product) > 0  THEN	'EcoBank Nigeria'
  WHEN  CHARINDEX ( 'ABP', card_product) > 0  THEN	'Access Bank Plc'
  WHEN  CHARINDEX ( 'UBP', card_product) > 0  THEN	'Unity Bank Plc'
  WHEN  CHARINDEX ( 'SPR', card_product) > 0  THEN	'Enterprise Bank'
  WHEN  CHARINDEX ( 'SBP', card_product) > 0  THEN	'Sterling Bank Plc'
  WHEN  CHARINDEX ( 'CITI', card_product) > 0  THEN	'Citi Bank '
  WHEN  CHARINDEX ( 'FD', card_product) > 0  THEN	'Cardless'
  WHEN  CHARINDEX ( 'FBP', card_product) > 0  THEN	'Fidelity Bank'
  WHEN  CHARINDEX ( 'SCB', card_product) > 0  THEN	'Standard Chartered Bank'
  WHEN  CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN  CHARINDEX ( 'ZIB', card_product) > 0  THEN	'Zenith International Bank'
  WHEN  CHARINDEX ( 'PRU', card_product) > 0  THEN	'Skye Bank'
  WHEN  CHARINDEX ( 'PLAT', card_product) > 0  THEN	'Keystone Bank'
  WHEN  CHARINDEX ( 'CHB', card_product) > 0  THEN	'Stanbic IBTC Bank'
  WHEN  CHARINDEX ( 'GTB', card_product) > 0  THEN	'Guaranty Trust Bank'
  WHEN  CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN CHARINDEX ( 'FBN', card_product) > 0  THEN	'First Bank of Nigeria'
  WHEN CHARINDEX ( 'OBI', card_product) > 0  THEN	'Oceanic Bank'
  WHEN CHARINDEX ( 'WEM', card_product) > 0  THEN	'WEMA Bank Plc'
  WHEN CHARINDEX ( 'AFRI', card_product) > 0  THEN	'Main Street Bank'
  WHEN CHARINDEX ( 'ETB', card_product) > 0  THEN	'Equitorial Trust Bank'
  WHEN CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN CHARINDEX ( 'UBN', card_product) > 0  THEN	'Union Bank of Nigeria'
  WHEN  CHARINDEX ( 'FCMB', card_product) > 0  THEN	'First City Monument Bank'
  WHEN CHARINDEX ( 'DBL', card_product) > 0  THEN	'Diamond Bank'
  WHEN CHARINDEX ( 'FIB', card_product) > 0  THEN	'First Inland Bank'
  WHEN CHARINDEX ( 'EBN', card_product) > 0  THEN	'EcoBank Nigeria'
  WHEN CHARINDEX ( 'ABP', card_product) > 0  THEN	'Access Bank Plc'
  WHEN CHARINDEX ( 'UBP', card_product) > 0  THEN	'Unity Bank Plc'
  WHEN CHARINDEX ( 'SPR', card_product) > 0  THEN	'Enterprise Bank'
  WHEN CHARINDEX ( 'SBP', card_product) > 0  THEN	'Sterling Bank'
  WHEN CHARINDEX ( 'CITI', card_product) > 0  THEN	'Citi Bank'
  WHEN CHARINDEX ( 'ABS', card_product) > 0  THEN	'Abbey'
  WHEN CHARINDEX ( 'OtherCards', card_product) > 0  THEN	'International Issuer'
  ELSE   card_product
  
  END 
issuer, rsp_code_rsp  ,sink_node_name,datetime_req ,message_type, system_trace_audit_nr, retrieval_reference_nr, dbo.formatAmount(tran_amount_req, tran_currency_code) tran_amount_req , DBO.formatAmount(tran_amount_rsp, tran_currency_code)  tran_amount_rsp 
,tran_nr,
tran_type,
terminal_id,
tran_postilion_originated
INTO #report_results

FROM 
POST_TRAN trans (NOLOCK)  JOIN POST_TRAN_CUST cust (NOLOCK, INDEX(pk_post_tran_cust)) 
ON 
trans.post_tran_cust_id = cust.post_tran_cust_id
				  JOIN (	
										SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]('20160524', '20160524')
									)  r
					on 
			    trans.recon_business_date = r.recon_business_date
			
WHERE

 tran_completed = 1
and tran_reversed = 0
OPTION (MAXDOP  8)
--and sink_node_name = @sink_node_name
DELETE FROM #report_results WHERE tran_postilion_originated  = 1




DECLARE @start_date DATETIME
DECLARE @end_date DATETIME

SELECT @start_date = MAX(start_date), @end_date = MAX(end_date)  FROM #report_results

SELECT sink_node_name,rsp_code_rsp, COUNT( tran_nr) node_tran_count INTO #report_results_2 FROM #report_results
GROUP BY sink_node_name,rsp_code_rsp

SELECT  rsp_code_rsp, SUM (node_tran_count) total_response_count INTO #rsp_code_totals FROM #report_results_2 WHERE rsp_code_rsp = rsp_code_rsp
GROUP BY rsp_code_rsp
select @start_date, @end_date,rsp.rsp_code_rsp,CONVERT(VARCHAR (250), dbo.formatRspCodeStr(rsp.rsp_code_rsp)) rsp_code_description,sink_node_name,node_tran_count, tots.total_response_count FROM #report_results_2 rsp JOIN #rsp_code_totals tots ON rsp.rsp_code_rsp =tots.rsp_code_rsp
ORDER BY rsp.rsp_code_rsp

END






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_out_All_bkp_2]    Script Date: 05/26/2016 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE[dbo].[osp_rpt_b08_Switched_out_All_bkp_2]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(4000),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		text,
		tran_reversed			INT,
		islocalTrx			INT,
		isforeignfinancial0200		INT,
		islocalfinancial0200		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10)
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

  set @StartDate =REPLACE( CONVERT(VARCHAR(30), @report_date_start, 111), '/', '');
   set @EndDate = REPLACE( CONVERT(VARCHAR(30),@report_date_end,111), '/', '');
   
	DECLARE  @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				--t.terminal_owner,
				t.merchant_type,
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
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as islocalfinancial0200,

				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp

				
	FROM
				post_tran_summary t (NOLOCK)
	WHERE 			
				
				t.tran_completed = '1'
				AND
		
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes )
					)
					
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	 

SELECT 
		 StartDate,
		 EndDate,
tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   source_node_name as Acq_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		isforeignfinancial0200,
		islocalfinancial0200

	 
	FROM 
			@report_result
Group by startdate, enddate,tran_type, settle_currency_code, source_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,isforeignfinancial0200,islocalfinancial0200

         OPTION (MAXDOP 8)

	END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_bkp]    Script Date: 05/26/2016 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All_bkp]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNodes	VARCHAR(4000),
        --@SourceNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(100)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30),
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		islocalfinancial0200TrxNOTCashWdrl		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10)
			)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
        SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   


	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

  set @StartDate =REPLACE( CONVERT(VARCHAR(30), @report_date_start, 111), '/', '');
   set @EndDate = REPLACE( CONVERT(VARCHAR(30),@report_date_end,111), '/', '');
   
	


	DECLARE  @list_of_sink_nodes TABLE (sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT part from  usf_split_string( @SinkNodes,',') ORDER BY PART ASC

--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

		DECLARE @first_post_tran_id BIGINT

		DECLARE @last_post_tran_id BIGINT

		EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT
	
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				--t.terminal_owner,
				t.merchant_type,
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
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as islocalfinancial0200,
				dbo.fn_rpt_islocalfinancial0200TrxNOTCashWdrl(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.card_acceptor_name_loc,t.tran_type) as islocalfinancial0200TrxNOTCashWdrl,


				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp
				

				
	FROM
				post_tran_summary t (NOLOCK)		
	WHERE 			
				
				
				t.tran_completed = '1'
				AND

				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
			        
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				
				)
                                AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				
					OPTION (RECOMPILE)
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
         tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		TranID,
		prev_post_tran_id,
		isforeignfinancial0200,
		islocalfinancial0200,
		islocalfinancial0200TrxNOTCashWdrl
		

	 
	FROM 
			@report_result
Group by startdate, enddate, tran_type,settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id,isforeignfinancial0200,islocalfinancial0200,islocalfinancial0200TrxNOTCashWdrl

        OPTION (MAXDOP 8)
	END
	
	
	




GO

/****** Object:  StoredProcedure [dbo].[norm_post_tran_summary_backup]    Script Date: 05/26/2016 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[norm_post_tran_summary_backup]
			@date	char(8)
as
begin

	createtable:
	declare @date_specified BIT
	
	set @date_specified = 1

	if(@date is null)
	begin
		set @date_specified  = 0
		set @date = CONVERT(varchar(10),dateadd(dd,-1,getdate()),112)
	end
	if not exists (select top 1 name from sys.objects where name like 'post_tran_summary_'+@date  and type = 'U' )
	begin
		print 'creating new post_tran_summary partition'
		
		declare @sql_statement varchar(8000)
		set @sql_statement = '
		
		declare @completed_table varchar (50)
		set @completed_table = (select top 1 name from sys.objects where name like ''post_tran_summary_%'' and type = ''U'' order by name desc)
		declare @view_created BIT
		set @view_created = 0
		declare @action VARCHAR(10)
		
		if @completed_table is not null
		begin
			print ''previous completed table: ''+@completed_table
			print ''updating view.....''
			set @view_created = 1
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				set @action = ''CREATE''
			end
			else
			begin
				set @action = ''ALTER''
			end
			
				exec(@action+'' VIEW dbo.post_tran_summary
				as
					SELECT  a.[post_tran_id]
						  ,a.[post_tran_cust_id]
						  ,a.[prev_post_tran_id]
						  ,a.[sink_node_name]
						  ,a.[tran_postilion_originated]
						  ,a.[tran_completed]
						  ,a.[message_type]
						  ,a.[tran_type]
						  ,a.[tran_nr]
						  ,a.[system_trace_audit_nr]
						  ,a.[rsp_code_req]
						  ,a.[rsp_code_rsp]
						  ,a.[abort_rsp_code]
						  ,a.[auth_id_rsp]
						  ,a.[retention_data]
						  ,a.[acquiring_inst_id_code]
						  ,a.[message_reason_code]
						  ,a.[retrieval_reference_nr]
						  ,a.[datetime_tran_gmt]
						  ,a.[datetime_tran_local]
						  ,a.[datetime_req]
						  ,a.[datetime_rsp]
						  ,a.[realtime_business_date]
						  ,a.[recon_business_date]
						  ,a.[from_account_type]
						  ,a.[to_account_type]
						  ,a.[from_account_id]
						  ,a.[to_account_id]
						  ,a.[tran_amount_req]
						  ,a.[tran_amount_rsp]
						  ,a.[settle_amount_impact]
						  ,a.[tran_cash_req]
						  ,a.[tran_cash_rsp]
						  ,a.[tran_currency_code]
						  ,a.[tran_tran_fee_req]
						  ,a.[tran_tran_fee_rsp]
						  ,a.[tran_tran_fee_currency_code]
						  ,a.[settle_amount_req]
						  ,a.[settle_amount_rsp]
						  ,a.[settle_tran_fee_req]
						  ,a.[settle_tran_fee_rsp]
						  ,a.[settle_currency_code]
						  , b.structured_data_req
						  ,a.[tran_reversed]
						  ,a.[prev_tran_approved]
						  ,a.[extended_tran_type]
						  ,a.[payee]
						  ,a.[online_system_id]
						  ,a.[receiving_inst_id_code]
						  ,a.[routing_type]
						  ,a.[source_node_name]
						  ,a.[pan]
						  ,a.[card_seq_nr]
						  ,a.[expiry_date]
						  ,a.[terminal_id]
						  ,a.[terminal_owner]
						  ,a.[card_acceptor_id_code]
						  ,a.[merchant_type]
						  ,a.[card_acceptor_name_loc]
						  ,a.[address_verification_data]
						  ,a.[totals_group]
						  ,a.[pan_encrypted]
					  FROM ''+@completed_table+'' a (NOLOCK)
					  
					 inner join post_tran b (NOLOCK) on b.post_tran_id  = a.post_tran_id'')
		end
		else
		begin
			set @view_created = 0
		end
		
		print ''creating table post_tran_summary_'+@date+'''
		CREATE TABLE dbo.post_tran_summary_'+@date+'
		(
			post_tran_id bigint NOT NULL,
			post_tran_cust_id bigint NOT NULL,
			prev_post_tran_id bigint NULL,
			sink_node_name dbo.POST_NAME NULL,
			tran_postilion_originated dbo.POST_BOOL NOT NULL,
			tran_completed dbo.POST_BOOL NOT NULL,
			message_type char(4) NOT NULL,
			tran_type char(2) NULL,
			tran_nr bigint NOT NULL,
			system_trace_audit_nr char(6) NULL,
			rsp_code_req char(2) NULL,
			rsp_code_rsp char(2) NULL,
			abort_rsp_code char(2) NULL,
			auth_id_rsp char(6) NULL,
			retention_data varchar(999) NULL,
			acquiring_inst_id_code varchar(11) NULL,
			message_reason_code char(4) NULL,
			retrieval_reference_nr char(12) NULL,
			datetime_tran_gmt datetime NULL,
			datetime_tran_local datetime NOT NULL,
			datetime_req datetime NOT NULL,
			datetime_rsp datetime NULL,
			realtime_business_date datetime NOT NULL,
			recon_business_date datetime NOT NULL,
			from_account_type char(2) NULL,
			to_account_type char(2) NULL,
			from_account_id varchar(28) NULL,
			to_account_id varchar(28) NULL,
			tran_amount_req dbo.POST_MONEY NULL,
			tran_amount_rsp dbo.POST_MONEY NULL,
			settle_amount_impact dbo.POST_MONEY NULL,
			tran_cash_req dbo.POST_MONEY NULL,
			tran_cash_rsp dbo.POST_MONEY NULL,
			tran_currency_code dbo.POST_CURRENCY NULL,
			tran_tran_fee_req dbo.POST_MONEY NULL,
			tran_tran_fee_rsp dbo.POST_MONEY NULL,
			tran_tran_fee_currency_code dbo.POST_CURRENCY NULL,
			settle_amount_req dbo.POST_MONEY NULL,
			settle_amount_rsp dbo.POST_MONEY NULL,
			settle_tran_fee_req dbo.POST_MONEY NULL,
			settle_tran_fee_rsp dbo.POST_MONEY NULL,
			settle_currency_code dbo.POST_CURRENCY NULL,
			tran_reversed char(1) NULL,
			prev_tran_approved dbo.POST_BOOL NULL,
			extended_tran_type char(4) NULL,
			payee char(25) NULL,
			online_system_id int NULL,
			receiving_inst_id_code varchar(11) NULL,
			routing_type int NULL,
			source_node_name dbo.POST_NAME NOT NULL,
			pan varchar(19) NULL,
			card_seq_nr varchar(3) NULL,
			expiry_date char(4) NULL,
			terminal_id dbo.POST_TERMINAL_ID NULL,
			terminal_owner varchar(25) NULL,
			card_acceptor_id_code char(15) NULL,
			merchant_type char(4) NULL,
			card_acceptor_name_loc char(40) NULL,
			address_verification_data varchar(29) NULL,
			totals_group varchar(12) NULL,
			pan_encrypted char(18) NULL
		)
		
		if(@view_created = 0)
		begin
			print ''setting view to new post_tran_summary partition''
			declare @action_2 varchar(10)
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				set @action_2 = ''CREATE''
			end
			else
			begin
				set @action_2 = ''ALTER''
			end
				exec(@action_2+'' VIEW dbo.post_tran_summary
				AS
					SELECT  a.[post_tran_id]
						  ,a.[post_tran_cust_id]
						  ,a.[prev_post_tran_id]
						  ,a.[sink_node_name]
						  ,a.[tran_postilion_originated]
						  ,a.[tran_completed]
						  ,a.[message_type]
						  ,a.[tran_type]
						  ,a.[tran_nr]
						  ,a.[system_trace_audit_nr]
						  ,a.[rsp_code_req]
						  ,a.[rsp_code_rsp]
						  ,a.[abort_rsp_code]
						  ,a.[auth_id_rsp]
						  ,a.[retention_data]
						  ,a.[acquiring_inst_id_code]
						  ,a.[message_reason_code]
						  ,a.[retrieval_reference_nr]
						  ,a.[datetime_tran_gmt]
						  ,a.[datetime_tran_local]
						  ,a.[datetime_req]
						  ,a.[datetime_rsp]
						  ,a.[realtime_business_date]
						  ,a.[recon_business_date]
						  ,a.[from_account_type]
						  ,a.[to_account_type]
						  ,a.[from_account_id]
						  ,a.[to_account_id]
						  ,a.[tran_amount_req]
						  ,a.[tran_amount_rsp]
						  ,a.[settle_amount_impact]
						  ,a.[tran_cash_req]
						  ,a.[tran_cash_rsp]
						  ,a.[tran_currency_code]
						  ,a.[tran_tran_fee_req]
						  ,a.[tran_tran_fee_rsp]
						  ,a.[tran_tran_fee_currency_code]
						  ,a.[settle_amount_req]
						  ,a.[settle_amount_rsp]
						  ,a.[settle_tran_fee_req]
						  ,a.[settle_tran_fee_rsp]
						  ,a.[settle_currency_code]
						  , b.structured_data_req
						  ,a.[tran_reversed]
						  ,a.[prev_tran_approved]
						  ,a.[extended_tran_type]
						  ,a.[payee]
						  ,a.[online_system_id]
						  ,a.[receiving_inst_id_code]
						  ,a.[routing_type]
						  ,a.[source_node_name]
						  ,a.[pan]
						  ,a.[card_seq_nr]
						  ,a.[expiry_date]
						  ,a.[terminal_id]
						  ,a.[terminal_owner]
						  ,a.[card_acceptor_id_code]
						  ,a.[merchant_type]
						  ,a.[card_acceptor_name_loc]
						  ,a.[address_verification_data]
						  ,a.[totals_group]
						  ,a.[pan_encrypted]
					  FROM post_tran_summary_'+@date+' a (NOLOCK)
					  
					 inner join post_tran b (NOLOCK) on b.post_tran_id  = a.post_tran_id'')
		end'
		
		print @sql_statement
		exec (@sql_statement)
		
		exec('		
		if not exists (select top 1 * from sys.objects where name = ''post_tran_summary_shadow'' and type =''V'')
		begin
			exec(''CREATE VIEW dbo.post_tran_summary_shadow
			AS
				select  * from post_tran_summary_'+@date+''')
		end
		else
		begin
			exec(''ALTER VIEW dbo.post_tran_summary_shadow
			as
				select  * from post_tran_summary_'+@date+''')
		end
		')
		
		--print @sql_statement
		--exec (@sql_statement)
	end
	declare @current_table varchar(50)
	declare @table_date char(8)
	if(@date_specified = 1)
	begin
		set @current_table = 'post_tran_summary_'+@date
	end
	else
	begin
		set @current_table = (select top 1 name from sys.objects where name like 'post_tran_summary_%' and type = 'U' order by name desc)
	end
		
	set @table_date = SUBSTRING(@current_table,19,8)
	
	declare @last_post_tran_id bigint
	if exists (select top 1 post_tran_id from post_tran_summary_shadow (nolock))
	begin
		select @last_post_tran_id = (select MAX(post_tran_id) from post_tran_summary_shadow (nolock))
	end
	else
	begin
		set @last_post_tran_id =0
	end
	
	--if(@last_post_tran_id =0)
	--begin
		--select @last_post_tran_id = min(post_tran_id) from post_tran (nolock) where CONVERT(char(8),recon_business_date,112) = @table_date
	--end
	
	declare @closed_norm_session_post_tran_id bigint
	set @closed_norm_session_post_tran_id = (select top 1 first_post_tran_id from post_normalization_session (nolock) where completed =1 order by normalization_session_id desc)
	
	print 'copying data ' ---+ cast(@last_post_tran_id as varchar(16))
	INSERT INTO post_tran_summary_shadow
				SELECT post_tran_id ,
				post_tran.post_tran_cust_id ,
				prev_post_tran_id,
				sink_node_name,
				tran_postilion_originated,
				tran_completed,
				message_type,
				tran_type,
				tran_nr ,
				system_trace_audit_nr,
				rsp_code_req,
				rsp_code_rsp,
				abort_rsp_code,
				auth_id_rsp,
				retention_data,
				acquiring_inst_id_code,
				message_reason_code,
				retrieval_reference_nr,
				datetime_tran_gmt,
				datetime_tran_local ,
				datetime_req ,
				datetime_rsp,
				realtime_business_date ,
				recon_business_date ,
				from_account_type,
				to_account_type,
				from_account_id,
				to_account_id,
				tran_amount_req,
				tran_amount_rsp,
				settle_amount_impact,
				tran_cash_req,
				tran_cash_rsp,
				tran_currency_code,
				tran_tran_fee_req,
				tran_tran_fee_rsp,
				tran_tran_fee_currency_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_req,
				settle_tran_fee_rsp,
				settle_currency_code,
				--structured_data_req,
				tran_reversed,
				prev_tran_approved,
				extended_tran_type,
				payee,
				online_system_id,
				receiving_inst_id_code,
				routing_type,
				source_node_name ,
				pan,
				card_seq_nr,
				expiry_date,
				terminal_id,
				terminal_owner,
				card_acceptor_id_code,
				merchant_type,
				card_acceptor_name_loc,
				address_verification_data,
				totals_group,
				pan_encrypted
			
			FROM	post_tran (NOLOCK) 
						INNER JOIN
					post_tran_cust (NOLOCK) 
			ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id
			where
				post_tran_id >@last_post_tran_id
				and post_tran_id < @closed_norm_session_post_tran_id
				--and convert(varchar(8),recon_business_date,112) = @table_date
			 and recon_business_date = CONVERT(DATE,@table_date)
			order by post_tran_id
				--and post_tran_id not in (select post_tran_id from post_tran_summary_shadow (nolock))
	
	if @@ROWCOUNT =0 -- nothing copied
	BEGIN
		print 'Nothing copied'
		if(@table_date = CONVERT(varchar(8),getdate(),112) OR @date_specified = 1) -- today
		begin
			print 'Either a date was specified for which there is no data or no additional data has been normalized'
			RETURN
		end
		DECLARE @norm_cutover INT;
		EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		
		if(CAST((CONVERT(varchar(8),getdate(),112)) as int) > cast (@table_date as int)) -- today > last table date & cant copy any more data
		begin
			print 'Its next day...'
			if(@norm_cutover=0) begin print '...but normalization has not caught up' RETURN end  -- wait for normalization to cut-over
			else -- normalization has cut-over to a new date, create new table and start copying again...
			begin
				-- check that the last closed batch is greater than the max post_tran_id from that recon_biz_date
				declare @max_tran_id bigint
				set @max_tran_id = (select MAX(post_tran_id) from post_tran (nolock) where recon_business_date = CONVERT(DATE,@table_date))
				if(@closed_norm_session_post_tran_id < @max_tran_id)
				begin
					-- CHECK AGAIN
					RETURN
				end
				print 'Lets check to see if we missed out any other transactions before cutting over. Querying...'
					INSERT INTO post_tran_summary_shadow
					SELECT post_tran_id ,
					post_tran.post_tran_cust_id ,
					prev_post_tran_id,
					sink_node_name,
					tran_postilion_originated,
					tran_completed,
					message_type,
					tran_type,
					tran_nr ,
					system_trace_audit_nr,
					rsp_code_req,
					rsp_code_rsp,
					abort_rsp_code,
					auth_id_rsp,
					retention_data,
					acquiring_inst_id_code,
					message_reason_code,
					retrieval_reference_nr,
					datetime_tran_gmt,
					datetime_tran_local ,
					datetime_req ,
					datetime_rsp,
					realtime_business_date ,
					recon_business_date ,
					from_account_type,
					to_account_type,
					from_account_id,
					to_account_id,
					tran_amount_req,
					tran_amount_rsp,
					settle_amount_impact,
					tran_cash_req,
					tran_cash_rsp,
					tran_currency_code,
					tran_tran_fee_req,
					tran_tran_fee_rsp,
					tran_tran_fee_currency_code,
					settle_amount_req,
					settle_amount_rsp,
					settle_tran_fee_req,
					settle_tran_fee_rsp,
					settle_currency_code,
					--structured_data_req,
					tran_reversed,
					prev_tran_approved,
					extended_tran_type,
					payee,
					online_system_id,
					receiving_inst_id_code,
					routing_type,
					source_node_name ,
					pan,
					card_seq_nr,
					expiry_date,
					terminal_id,
					terminal_owner,
					card_acceptor_id_code,
					merchant_type,
					card_acceptor_name_loc,
					address_verification_data,
					totals_group,
					pan_encrypted
				
				FROM	post_tran (NOLOCK) 
							INNER JOIN
						post_tran_cust (NOLOCK) 
				ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id
				where convert(varchar(8),recon_business_date,112) = @table_date
				and post_tran_id < @closed_norm_session_post_tran_id
				and post_tran_id not in (select post_tran_id from dbo.post_tran_summary_shadow (nolock))
				
				print 'Done!'
				print 'Cutting over to next business day then...'
				--create indexes on current table with @table_date 
				
				declare @old_data datetime
				set @old_data = DATEADD(dd,-2,CONVERT(DATE,@table_date))
				declare @old_data_timestamp  char(8)
				set @old_data_timestamp = CONVERT(char(8),@old_data,112)
				
				print 'Housekeeping: deleting old table post_tran_summary_'+@old_data_timestamp
				exec ('
					if exists (select top 1 * from sys.objects where name = ''post_tran_summary_'+@old_data_timestamp+''' and type =''U'')
					begin
						drop table post_tran_summary_'+@old_data_timestamp+'
					end
				')
				print 'Creating indexes on last table...post_tran_summary_'+@table_date
				exec (
				' 
					CREATE CLUSTERED INDEX [ix_post_tran_'+@date+'_summary_2] ON [dbo].[post_tran_summary_'+@date+'] 
					(
						[post_tran_id] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
							
					CREATE NONCLUSTERED INDEX [is_post_tran_'+@table_date+'_summary_3] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[sink_node_name] ASC,
						[tran_postilion_originated] ASC,
						[tran_completed] ASC,
						[message_type] ASC,
						[tran_type] ASC,
						[rsp_code_rsp] ASC,
						[message_reason_code] ASC,
						[datetime_req] ASC,
						[recon_business_date] ASC,
						[tran_reversed] ASC,
						[extended_tran_type] ASC,
						[source_node_name] ASC,
						[terminal_id] ASC,
						[terminal_owner] ASC,
						[merchant_type] ASC,
						[totals_group] ASC
					)
					INCLUDE ( [post_tran_cust_id],
					[system_trace_audit_nr],
					[auth_id_rsp],
					[from_account_type],
					[to_account_type],
					[from_account_id],
					[to_account_id],
					[tran_amount_req],
					[tran_amount_rsp],
					[settle_amount_impact],
					[tran_cash_req],
					[tran_cash_rsp],
					[tran_currency_code],
					[tran_tran_fee_req],
					[tran_tran_fee_rsp],
					[tran_tran_fee_currency_code],
					[settle_amount_req],
					[settle_amount_rsp],
					[settle_tran_fee_req],
					[settle_tran_fee_rsp],
					[settle_currency_code],
					[online_system_id],
					[card_seq_nr],
					[expiry_date],
					[card_acceptor_id_code],
					[card_acceptor_name_loc],
					[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary_4] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[tran_nr] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary_5] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[retrieval_reference_nr] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary_6] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[pan] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary_7] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[receiving_inst_id_code] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary_8] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[message_reason_code] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary_9] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[payee] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_post_tran_'+@table_date+'_summary_10] ON [dbo].[post_tran_summary_'+@table_date+'] 
					(
						[datetime_tran_local] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

				'
				)
				set @date = CONVERT(varchar(8),getdate(),112)
				goto createtable
			end
		END
	END

end

GO

/****** Object:  StoredProcedure [dbo].[usp_index_manager]    Script Date: 05/26/2016 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER PROCEDURE [dbo].[usp_index_manager]
AS 

BEGIN

DECLARE @sql_text Nvarchar(max);
DECLARE @create_index_table TABLE (create_command VARCHAR(MAX))
DECLARE @drop_index_table TABLE (drop_command VARCHAR(MAX))


PRINT CHAR(10)+' Fetching list of all missing indexes and saving them in a table:';
INSERT INTO
         @create_index_table ( create_command)

 SELECT  
		distinct 'USE [' + DB_NAME(database_id) + '];
		CREATE INDEX indx_' + replace(replace(replace(replace
		(ISNULL(left(equality_columns,10), '')
		+ ISNULL(left(inequality_columns,10), ''), ', ', '_')+ +'_'+ (CONVERT(VARCHAR(5),ROW_NUMBER() OVER (ORDER BY c.object_id ))),
		'[', ''), ']', ''), ' ', '') + '
		ON [' + schema_name(d.schema_id) + ']
		.[' + OBJECT_NAME(c.object_id) + ']
		(' + ISNULL(equality_columns, '') +
		CASE WHEN equality_columns IS NOT NULL
		AND c.inequality_columns IS NOT NULL THEN ', '
		ELSE '' END + ISNULL(inequality_columns, '') + ')
		' + CASE WHEN included_columns IS NOT NULL THEN
		'INCLUDE (' + included_columns + ')' ELSE '' END + '
		WITH (FILLFACTOR=90)' [create_command]

FROM sys.dm_db_missing_index_details c JOIN sys.objects d ON c.object_id = d.object_id
WHERE c.database_id = db_id('postilion_office')
  AND 
 OBJECT_NAME(c.object_id) NOT IN ('post_tran', 'post_tran_cust')
  AND 
 OBJECT_NAME(c.object_id) NOT IN ('post_tran', 'post_tran_cust')
 AND 
 dbo.fn_check_index_column_type(RTRIM(LTRIM(REPLACE(REPLACE(equality_columns,'[',''),']',''))), [name] )=1
 AND 
  dbo.fn_check_index_column_type(RTRIM(LTRIM(REPLACE(REPLACE(inequality_columns,'[',''),']',''))),  [name]  ) =1
  AND 
  dbo.fn_check_index_column_type(RTRIM(LTRIM(REPLACE(REPLACE(included_columns,'[',''),']',''))) ,   [name]  ) =1
  
PRINT CHAR(10)+' Fetching list of all unused indexes and saving them in a table:';

INSERT INTO
         @drop_index_table ( drop_command) 
       SELECT 
       
				'DROP INDEX '+ I.[NAME]+ '	ON '+OBJECT_NAME(S.[OBJECT_ID]) [drop_command]
			   
		FROM   SYS.DM_DB_INDEX_USAGE_STATS AS S 
			   INNER JOIN SYS.INDEXES AS I ON I.[OBJECT_ID] = S.[OBJECT_ID] AND I.INDEX_ID = S.INDEX_ID 
		WHERE  OBJECTPROPERTY(S.[OBJECT_ID],'IsUserTable') = 1
			   AND S.database_id = DB_ID() 
		AND  USER_SEEKS =0 and  USER_SCANS=0  AND USER_LOOKUPS=0  AND USER_UPDATES in (0,1)
AND type_desc <> 'CLUSTERED';
		
		
		PRINT CHAR(10)+'Removing all unused indexes';
		
	    DECLARE drop_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT drop_command FROM @drop_index_table;
		OPEN drop_cursor
		FETCH NEXT FROM  drop_cursor INTO @sql_text 
		WHILE (@@FETCH_STATUS=0) BEGIN
			BEGIN TRY
			    SET @sql_text  = REPLACE(@sql_text ,'''','''''');
				PRINT CHAR(10)+'Running command to drop index: '+@sql_text;
				EXEC(@sql_text);			
				FETCH NEXT FROM  drop_cursor INTO @sql_text 
			END TRY
			BEGIN CATCH
			PRINT CHAR(10)+'Error running script: '+@sql_text;
			FETCH NEXT FROM  drop_cursor INTO @sql_text 
			END CATCH
		END
		CLOSE drop_cursor
		DEALLOCATE drop_cursor
		PRINT CHAR(10)+'All unused indexes successfully removed.';

		DECLARE create_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT create_command FROM @create_index_table;
		OPEN create_cursor
		FETCH NEXT FROM  create_cursor INTO @sql_text 
		WHILE (@@FETCH_STATUS=0) BEGIN
		BEGIN TRY
			SET @sql_text  = REPLACE(@sql_text ,'''','''''');
			PRINT CHAR(10)+'Running command to create index: '+@sql_text;
			EXEC(@sql_text);			
			FETCH NEXT FROM  create_cursor INTO @sql_text 
			END TRY
						BEGIN CATCH
						PRINT CHAR(10)+'Error running script: '+@sql_text;
						FETCH NEXT FROM  create_cursor INTO @sql_text 
			END CATCH
		END
		CLOSE create_cursor
		DEALLOCATE create_cursor
END



GO

/****** Object:  StoredProcedure [dbo].[norm_post_tran_summary]    Script Date: 05/26/2016 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[norm_post_tran_summary]
			@date	char(8)
as
begin

	createtable:
	declare @date_specified BIT
	
	set @date_specified = 1

	if(@date is null)
	begin
		set @date_specified  = 0
		set @date = CONVERT(varchar(10),dateadd(dd,-1,getdate()),112)
	end
	if not exists (select top 1 name from sys.objects where name like 'post_tran_summary_'+@date  and type = 'U' )
	begin
		print 'creating new post_tran_summary partition'
		
		declare @sql_statement varchar(8000)
		set @sql_statement = '
		
		declare @completed_table varchar (50)
		set @completed_table = (select top 1 name from sys.objects where   LEFT(name,18)= ''post_tran_summary_'' AND ISDATE(RIGHT(name, 8)) =1 and type = ''U'' order by name desc)
		declare @view_created BIT
		set @view_created = 0
		declare @action VARCHAR(10)
		
		if @completed_table is not null
		begin
			print ''previous completed table: ''+@completed_table
			print ''updating view.....''
			set @view_created = 1
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				set @action = ''CREATE''
			end
			else
			begin
				set @action = ''ALTER''
			end
			
				exec(@action+'' VIEW dbo.post_tran_summary
				as
					SELECT  a.[post_tran_id]
						  ,a.[post_tran_cust_id]
						  ,a.[prev_post_tran_id]
						  ,a.[sink_node_name]
						  ,a.[tran_postilion_originated]
						  ,a.[tran_completed]
						  ,a.[message_type]
						  ,a.[tran_type]
						  ,a.[tran_nr]
						  ,a.[system_trace_audit_nr]
						  ,a.[rsp_code_req]
						  ,a.[rsp_code_rsp]
						  ,a.[abort_rsp_code]
						  ,a.[auth_id_rsp]
						  ,a.[retention_data]
						  ,a.[acquiring_inst_id_code]
						  ,a.[message_reason_code]
						  ,a.[retrieval_reference_nr]
						  ,a.[datetime_tran_gmt]
						  ,a.[datetime_tran_local]
						  ,a.[datetime_req]
						  ,a.[datetime_rsp]
						  ,a.[realtime_business_date]
						  ,a.[recon_business_date]
						  ,a.[from_account_type]
						  ,a.[to_account_type]
						  ,a.[from_account_id]
						  ,a.[to_account_id]
						  ,a.[tran_amount_req]
						  ,a.[tran_amount_rsp]
						  ,a.[settle_amount_impact]
						  ,a.[tran_cash_req]
						  ,a.[tran_cash_rsp]
						  ,a.[tran_currency_code]
						  ,a.[tran_tran_fee_req]
						  ,a.[tran_tran_fee_rsp]
						  ,a.[tran_tran_fee_currency_code]
						  ,a.[settle_amount_req]
						  ,a.[settle_amount_rsp]
						  ,a.[settle_tran_fee_req]
						  ,a.[settle_tran_fee_rsp]
						  ,a.[settle_currency_code]
						  , b.structured_data_req
						  ,a.[tran_reversed]
						  ,a.[prev_tran_approved]
						  ,a.[extended_tran_type]
						  ,a.[payee]
						  ,a.[online_system_id]
						  ,a.[receiving_inst_id_code]
						  ,a.[routing_type]
						  ,a.[source_node_name]
						  ,a.[pan]
						  ,a.[card_seq_nr]
						  ,a.[expiry_date]
						  ,a.[terminal_id]
						  ,a.[terminal_owner]
						  ,a.[card_acceptor_id_code]
						  ,a.[merchant_type]
						  ,a.[card_acceptor_name_loc]
						  ,a.[address_verification_data]
						  ,a.[totals_group]
						  ,a.[pan_encrypted]
					  FROM ''+@completed_table+'' a (NOLOCK)
					  
					 inner join post_tran b (NOLOCK) on b.post_tran_id  = a.post_tran_id'')
		end
		else
		begin
			set @view_created = 0
		end
		
		print ''creating table post_tran_summary_'+@date+'''
		CREATE TABLE dbo.post_tran_summary_'+@date+'
		(
			post_tran_id bigint NOT NULL,
			post_tran_cust_id bigint NOT NULL,
			prev_post_tran_id bigint NULL,
			sink_node_name dbo.POST_NAME NULL,
			tran_postilion_originated dbo.POST_BOOL NOT NULL,
			tran_completed dbo.POST_BOOL NOT NULL,
			message_type char(4) NOT NULL,
			tran_type char(2) NULL,
			tran_nr bigint NOT NULL,
			system_trace_audit_nr char(6) NULL,
			rsp_code_req char(2) NULL,
			rsp_code_rsp char(2) NULL,
			abort_rsp_code char(2) NULL,
			auth_id_rsp char(6) NULL,
			retention_data varchar(999) NULL,
			acquiring_inst_id_code varchar(11) NULL,
			message_reason_code char(4) NULL,
			retrieval_reference_nr char(12) NULL,
			datetime_tran_gmt datetime NULL,
			datetime_tran_local datetime NOT NULL,
			datetime_req datetime NOT NULL,
			datetime_rsp datetime NULL,
			realtime_business_date datetime NOT NULL,
			recon_business_date datetime NOT NULL,
			from_account_type char(2) NULL,
			to_account_type char(2) NULL,
			from_account_id varchar(28) NULL,
			to_account_id varchar(28) NULL,
			tran_amount_req dbo.POST_MONEY NULL,
			tran_amount_rsp dbo.POST_MONEY NULL,
			settle_amount_impact dbo.POST_MONEY NULL,
			tran_cash_req dbo.POST_MONEY NULL,
			tran_cash_rsp dbo.POST_MONEY NULL,
			tran_currency_code dbo.POST_CURRENCY NULL,
			tran_tran_fee_req dbo.POST_MONEY NULL,
			tran_tran_fee_rsp dbo.POST_MONEY NULL,
			tran_tran_fee_currency_code dbo.POST_CURRENCY NULL,
			settle_amount_req dbo.POST_MONEY NULL,
			settle_amount_rsp dbo.POST_MONEY NULL,
			settle_tran_fee_req dbo.POST_MONEY NULL,
			settle_tran_fee_rsp dbo.POST_MONEY NULL,
			settle_currency_code dbo.POST_CURRENCY NULL,
			tran_reversed char(1) NULL,
			prev_tran_approved dbo.POST_BOOL NULL,
			extended_tran_type char(4) NULL,
			payee char(25) NULL,
			online_system_id int NULL,
			receiving_inst_id_code varchar(11) NULL,
			routing_type int NULL,
			source_node_name dbo.POST_NAME NOT NULL,
			pan varchar(19) NULL,
			card_seq_nr varchar(3) NULL,
			expiry_date char(4) NULL,
			terminal_id dbo.POST_TERMINAL_ID NULL,
			terminal_owner varchar(25) NULL,
			card_acceptor_id_code char(15) NULL,
			merchant_type char(4) NULL,
			card_acceptor_name_loc char(40) NULL,
			address_verification_data varchar(29) NULL,
			totals_group varchar(12) NULL,
			pan_encrypted char(18) NULL
		)
		
		if(@view_created = 0)
		begin
			print ''setting view to new post_tran_summary partition''
			declare @action_2 varchar(10)
			if not exists (select top 1 * from sys.objects where name = ''post_tran_summary'' and type =''V'')
			begin
				set @action_2 = ''CREATE''
			end
			else
			begin
				set @action_2 = ''ALTER''
			end
				exec(@action_2+'' VIEW dbo.post_tran_summary
				AS
					SELECT  a.[post_tran_id]
						  ,a.[post_tran_cust_id]
						  ,a.[prev_post_tran_id]
						  ,a.[sink_node_name]
						  ,a.[tran_postilion_originated]
						  ,a.[tran_completed]
						  ,a.[message_type]
						  ,a.[tran_type]
						  ,a.[tran_nr]
						  ,a.[system_trace_audit_nr]
						  ,a.[rsp_code_req]
						  ,a.[rsp_code_rsp]
						  ,a.[abort_rsp_code]
						  ,a.[auth_id_rsp]
						  ,a.[retention_data]
						  ,a.[acquiring_inst_id_code]
						  ,a.[message_reason_code]
						  ,a.[retrieval_reference_nr]
						  ,a.[datetime_tran_gmt]
						  ,a.[datetime_tran_local]
						  ,a.[datetime_req]
						  ,a.[datetime_rsp]
						  ,a.[realtime_business_date]
						  ,a.[recon_business_date]
						  ,a.[from_account_type]
						  ,a.[to_account_type]
						  ,a.[from_account_id]
						  ,a.[to_account_id]
						  ,a.[tran_amount_req]
						  ,a.[tran_amount_rsp]
						  ,a.[settle_amount_impact]
						  ,a.[tran_cash_req]
						  ,a.[tran_cash_rsp]
						  ,a.[tran_currency_code]
						  ,a.[tran_tran_fee_req]
						  ,a.[tran_tran_fee_rsp]
						  ,a.[tran_tran_fee_currency_code]
						  ,a.[settle_amount_req]
						  ,a.[settle_amount_rsp]
						  ,a.[settle_tran_fee_req]
						  ,a.[settle_tran_fee_rsp]
						  ,a.[settle_currency_code]
						  , b.structured_data_req
						  ,a.[tran_reversed]
						  ,a.[prev_tran_approved]
						  ,a.[extended_tran_type]
						  ,a.[payee]
						  ,a.[online_system_id]
						  ,a.[receiving_inst_id_code]
						  ,a.[routing_type]
						  ,a.[source_node_name]
						  ,a.[pan]
						  ,a.[card_seq_nr]
						  ,a.[expiry_date]
						  ,a.[terminal_id]
						  ,a.[terminal_owner]
						  ,a.[card_acceptor_id_code]
						  ,a.[merchant_type]
						  ,a.[card_acceptor_name_loc]
						  ,a.[address_verification_data]
						  ,a.[totals_group]
						  ,a.[pan_encrypted]
					  FROM post_tran_summary_'+@date+' a (NOLOCK)
					  
					 inner join post_tran b (NOLOCK) on b.post_tran_id  = a.post_tran_id'')
		end'
		
		print @sql_statement
		exec (@sql_statement)
		
		exec('		
		if not exists (select top 1 * from sys.objects where name = ''post_tran_summary_shadow'' and type =''V'')
		begin
			exec(''CREATE VIEW dbo.post_tran_summary_shadow
			AS
				select  * from post_tran_summary_'+@date+''')
		end
		else
		begin
			exec(''ALTER VIEW dbo.post_tran_summary_shadow
			as
				select  * from post_tran_summary_'+@date+''')
		end
		')
		
		--print @sql_statement
		--exec (@sql_statement)
	end
	declare @current_table varchar(50)
	declare @table_date char(8)
	if(@date_specified = 1)
	begin
		set @current_table = 'post_tran_summary_'+@date
	end
	else
	begin
			set @current_table = (select top 1 name from sys.objects where  LEFT(name,18)= 'post_tran_summary_' AND ISDATE(RIGHT(name, 8)) =1 and type = 'U' order by name desc)
	end
		
	set @table_date = SUBSTRING(@current_table,19,8)
	
	declare @last_post_tran_id bigint
	if exists (select top 1 post_tran_id from post_tran_summary_shadow (nolock))
	begin
		select @last_post_tran_id = (select MAX(post_tran_id) from post_tran_summary_shadow (nolock))
	end
	else
	begin
		set @last_post_tran_id =0
	end
	
	--if(@last_post_tran_id =0)
	--begin
		--select @last_post_tran_id = min(post_tran_id) from post_tran (nolock) where CONVERT(char(8),recon_business_date,112) = @table_date
	--end
	
	declare @closed_norm_session_post_tran_id bigint
	set @closed_norm_session_post_tran_id = (select top 1 first_post_tran_id from post_normalization_session (nolock) where completed =1 order by normalization_session_id desc)
	
	print 'copying data ' ---+ cast(@last_post_tran_id as varchar(16))
	INSERT INTO post_tran_summary_shadow
				SELECT post_tran_id ,
				post_tran.post_tran_cust_id ,
				prev_post_tran_id,
				sink_node_name,
				tran_postilion_originated,
				tran_completed,
				message_type,
				tran_type,
				tran_nr ,
				system_trace_audit_nr,
				rsp_code_req,
				rsp_code_rsp,
				abort_rsp_code,
				auth_id_rsp,
				retention_data,
				acquiring_inst_id_code,
				message_reason_code,
				retrieval_reference_nr,
				datetime_tran_gmt,
				datetime_tran_local ,
				datetime_req ,
				datetime_rsp,
				realtime_business_date ,
				recon_business_date ,
				from_account_type,
				to_account_type,
				from_account_id,
				to_account_id,
				tran_amount_req,
				tran_amount_rsp,
				settle_amount_impact,
				tran_cash_req,
				tran_cash_rsp,
				tran_currency_code,
				tran_tran_fee_req,
				tran_tran_fee_rsp,
				tran_tran_fee_currency_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_req,
				settle_tran_fee_rsp,
				settle_currency_code,
				--structured_data_req,
				tran_reversed,
				prev_tran_approved,
				extended_tran_type,
				payee,
				online_system_id,
				receiving_inst_id_code,
				routing_type,
				source_node_name ,
				pan,
				card_seq_nr,
				expiry_date,
				terminal_id,
				terminal_owner,
				card_acceptor_id_code,
				merchant_type,
				card_acceptor_name_loc,
				address_verification_data,
				totals_group,
				pan_encrypted
			
			FROM	post_tran (NOLOCK) 
						INNER JOIN
					post_tran_cust (NOLOCK, INDEX(pk_post_tran_cust)) 
			ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id
			where
				post_tran_id >@last_post_tran_id
				and post_tran_id < @closed_norm_session_post_tran_id
				--and convert(varchar(8),recon_business_date,112) = @table_date
			 and recon_business_date = CONVERT(DATE,@table_date)
			order by post_tran_id
				--and post_tran_id not in (select post_tran_id from post_tran_summary_shadow (nolock))
	
	if @@ROWCOUNT =0 -- nothing copied
	BEGIN
		print 'Nothing copied'
		if(@table_date = CONVERT(varchar(8),getdate(),112) OR @date_specified = 1) -- today
		begin
			print 'Either a date was specified for which there is no data or no additional data has been normalized'
			RETURN
		end
		DECLARE @norm_cutover INT;
		EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		
		if(CAST((CONVERT(varchar(8),getdate(),112)) as int) > cast (@table_date as int)) -- today > last table date & cant copy any more data
		begin
			print 'Its next day...'
			if(@norm_cutover=0) begin print '...but normalization has not caught up' RETURN end  -- wait for normalization to cut-over
			else -- normalization has cut-over to a new date, create new table and start copying again...
			begin
				-- check that the last closed batch is greater than the max post_tran_id from that recon_biz_date
				declare @max_tran_id bigint
				set @max_tran_id = (select MAX(post_tran_id) from post_tran (nolock) where recon_business_date = CONVERT(DATE,@table_date))
				if(@closed_norm_session_post_tran_id < @max_tran_id)
				begin
					-- CHECK AGAIN
					RETURN
				end
				print 'Lets check to see if we missed out any other transactions before cutting over. Querying...'
					INSERT INTO post_tran_summary_shadow
					SELECT post_tran_id ,
					post_tran.post_tran_cust_id ,
					prev_post_tran_id,
					sink_node_name,
					tran_postilion_originated,
					tran_completed,
					message_type,
					tran_type,
					tran_nr ,
					system_trace_audit_nr,
					rsp_code_req,
					rsp_code_rsp,
					abort_rsp_code,
					auth_id_rsp,
					retention_data,
					acquiring_inst_id_code,
					message_reason_code,
					retrieval_reference_nr,
					datetime_tran_gmt,
					datetime_tran_local ,
					datetime_req ,
					datetime_rsp,
					realtime_business_date ,
					recon_business_date ,
					from_account_type,
					to_account_type,
					from_account_id,
					to_account_id,
					tran_amount_req,
					tran_amount_rsp,
					settle_amount_impact,
					tran_cash_req,
					tran_cash_rsp,
					tran_currency_code,
					tran_tran_fee_req,
					tran_tran_fee_rsp,
					tran_tran_fee_currency_code,
					settle_amount_req,
					settle_amount_rsp,
					settle_tran_fee_req,
					settle_tran_fee_rsp,
					settle_currency_code,
					--structured_data_req,
					tran_reversed,
					prev_tran_approved,
					extended_tran_type,
					payee,
					online_system_id,
					receiving_inst_id_code,
					routing_type,
					source_node_name ,
					pan,
					card_seq_nr,
					expiry_date,
					terminal_id,
					terminal_owner,
					card_acceptor_id_code,
					merchant_type,
					card_acceptor_name_loc,
					address_verification_data,
					totals_group,
					pan_encrypted
				
				FROM	post_tran (NOLOCK) 
							INNER JOIN
						post_tran_cust (NOLOCK, INDEX(pk_post_tran_cust)) 
				ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id
				where convert(varchar(8),recon_business_date,112) = @table_date
				and post_tran_id < @closed_norm_session_post_tran_id
				and post_tran_id not in (select post_tran_id from dbo.post_tran_summary_shadow (nolock))
				
				print 'Done!'
				print 'Cutting over to next business day then...'
				--create indexes on current table with @table_date 
				
				declare @old_data datetime
				set @old_data = DATEADD(dd,-2,CONVERT(DATE,@table_date))
				declare @old_data_timestamp  char(8)
				set @old_data_timestamp = CONVERT(char(8),@old_data,112)
				
				print 'Housekeeping: deleting old table post_tran_summary_'+@old_data_timestamp
				exec ('
					if exists (select top 1 * from sys.objects where name = ''post_tran_summary_'+@old_data_timestamp+''' and type =''U'')
					begin
						drop table post_tran_summary_'+@old_data_timestamp+'
					end
				')
				print 'Creating indexes on last table...post_tran_summary_'+@table_date
							    

					declare  @table_name VARCHAR(255)
declare  @sqlquery   nVARCHAR(max)
SET @table_name= 'post_tran_summary_'+@table_date;
EXEC('IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N''[dbo].['+@table_name+']'') AND name = N''ix_'+@table_name+'_9'') BEGIN
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_10] ON [dbo].['+@table_name+'] 
(
	[recon_business_date] ASC
)
/****** Object:  Index [indx_tran_post_15]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_11] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC
)
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_12] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group]) CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_13] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee]) 
CREATE NONCLUSTERED INDEX [indx_tran_post_22] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_nr],
[system_trace_audit_nr],
[rsp_code_rsp],
[retention_data],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee],
[online_system_id]) 
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_14] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[message_type] ASC
)
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_15] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[terminal_id] ASC
)
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_16] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[sink_node_name] ASC,
	[message_type] ASC,
	[tran_type] ASC,
	[source_node_name] ASC,
	[terminal_id] ASC,
	[totals_group] ASC
)
/****** Object:  Index [ix_'+@table_name+'_17]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_17] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[sink_node_name] ASC,
	[tran_type] ASC,
	[source_node_name] ASC
)
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_18] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[source_node_name] ASC
)
/****** Object:  Index [ix_'+@table_name+'_19]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_19] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC
)
CREATE NONCLUSTERED INDEX [is_'+@table_name+'_3] ON [dbo].['+@table_name+'] 
(
	[sink_node_name] ASC,
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[message_type] ASC,
	[tran_type] ASC,
	[rsp_code_rsp] ASC,
	[message_reason_code] ASC,
	[datetime_req] ASC,
	[recon_business_date] ASC,
	[tran_reversed] ASC,
	[extended_tran_type] ASC,
	[source_node_name] ASC,
	[terminal_id] ASC,
	[terminal_owner] ASC,
	[merchant_type] ASC,
	[totals_group] ASC
)
INCLUDE ( [post_tran_cust_id],
[system_trace_audit_nr],
[auth_id_rsp],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[tran_amount_req],
[tran_amount_rsp],
[settle_amount_impact],
[tran_cash_req],
[tran_cash_rsp],
[tran_currency_code],
[tran_tran_fee_req],
[tran_tran_fee_rsp],
[tran_tran_fee_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_req],
[settle_tran_fee_rsp],
[settle_currency_code],
[online_system_id],
[card_seq_nr],
[expiry_date],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) 
/****** Object:  Index [ix_'+@table_name+'_10]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_10] ON [dbo].['+@table_name+'] 
(
	[datetime_tran_local] ASC
)
/****** Object:  Index [ix_'+@table_name+'_2]    Script Date: 05/24/2016 16:24:57 ******/
CREATE CLUSTERED INDEX [ix_'+@table_name+'_2] ON [dbo].['+@table_name+'] 
(
	[post_tran_id] ASC
)
/****** Object:  Index [ix_'+@table_name+'_4]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_4] ON [dbo].['+@table_name+'] 
(
	[tran_nr] ASC
)
/****** Object:  Index [ix_'+@table_name+'_5]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_5] ON [dbo].['+@table_name+'] 
(
	[retrieval_reference_nr] ASC
)
/****** Object:  Index [ix_'+@table_name+'_6]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_6] ON [dbo].['+@table_name+'] 
(
	[pan] ASC
)
/****** Object:  Index [ix_'+@table_name+'_7]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_7] ON [dbo].['+@table_name+'] 
(
	[receiving_inst_id_code] ASC
)
/****** Object:  Index [ix_'+@table_name+'_8]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_8] ON [dbo].['+@table_name+'] 
(
	[message_reason_code] ASC
)
/****** Object:  Index [ix_'+@table_name+'_9]    Script Date: 05/24/2016 16:24:57 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_9] ON [dbo].['+@table_name+'] 
(
	[payee] ASC
)
end')
 



				set @date = CONVERT(varchar(8),getdate(),112)
				goto createtable
			end
		END
	END

end

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_backup]    Script Date: 05/26/2016 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_backup]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' and @user_start_date IS NULL AND @user_end_date IS NULL
)
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	
	end







GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_3]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_3]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (8),
	@user_end_date		VARCHAR (8),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN

	CREATE TABLE #rpt_get_dates
	(
		node_name	VARCHAR (12)
	)

	DELETE FROM #rpt_get_dates

	DECLARE @yy INT
	DECLARE @mm INT
	DECLARE @dd INT

	SELECT @warning = NULL

	IF @default_date_method IS NULL
		SET @default_date_method = '<Not specified>'


	IF (@user_start_date IS NOT NULL OR @user_end_date IS NOT NULL)
	BEGIN

		--
		-- At least one date was specified, so use the specified dates
		--

		IF (@user_start_date IS NULL OR @user_end_date IS NULL)
		BEGIN
				SET @warning = 'Both the from- and to- dates should be specified.'
				RETURN
		END

		--
		-- Start date
		--

		EXECUTE osp_rpt_date_from_user @user_start_date, @report_date_start OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- End date
		--

		EXECUTE osp_rpt_date_from_user @user_end_date, @report_date_end OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- Some validation
		--

		IF (@report_date_end < @report_date_start)
		BEGIN
			SET @warning = 'The End Date must be AFTER the Start Date.'
			RETURN
		END
	END -- use specified dates

	ELSE

	IF (@default_date_method = 'Last business day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list VARCHAR (2048)
		SET @tmp_node_list = @node_name_list

		WHILE (@tmp_node_list IS NOT NULL)
		BEGIN
				INSERT INTO #rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list))
				SET @tmp_node_list = dbo.fn_rpt_remainelem(@tmp_node_list)
		END

		--
		-- We need to get the business date of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.settle_date)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM #rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'

			RETURN
		END

		SET @report_date_end = @report_date_start

	END -- Last business day

	ELSE

	IF (@default_date_method = 'Previous week')
	BEGIN
		--
		-- Previous week
		-- We do not know if the week should start on a Sun, or a Mon. We, for now, consider a week as the last 7 days - up to yesterday
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -7, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
		--
		-- Previous day
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		--
		-- Today
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Previous month')
	BEGIN

		-- Previous month

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -DATEPART(dd, @report_date_end), @report_date_end)

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, - DATEPART(dd, @report_date_start) + 1, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, 1, @report_date_end)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Last closed batch end calendar day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list_2 VARCHAR (2048)
		SET @tmp_node_list_2 = @node_name_list

		WHILE (@tmp_node_list_2 IS NOT NULL)
		BEGIN
				INSERT INTO #rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list_2))
				SET @tmp_node_list_2 = dbo.fn_rpt_remainelem(@tmp_node_list_2)
		END

		--
		-- We need to get the calendar date of the end of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.datetime_end)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM #rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The calendar date of the last closed batch could not be determined.'

			RETURN
		END

		-- Get only the date portion of the datetime_begin
		SET @report_date_start = CONVERT(DATETIME, CONVERT(VARCHAR(10), @report_date_start, 101), 101)
		SET @report_date_end = @report_date_start

	END -- Last closed batch end calendar day

	ELSE

	BEGIN
		SET @warning = 'Invalid default date method specified: ' + @default_date_method
	END

	SET @report_date_end_next = DATEADD(dd, 1, @report_date_end)

	DROP TABLE #rpt_get_dates
END






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_20160215]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_20160215]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' and @user_start_date IS NULL AND @user_end_date IS NULL
)
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	
	
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	
	end






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2015_old]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_2015_old]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
			EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		        IF  (@norm_cutover=0) BEGIN
				SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			RETURN
			END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' OR @default_date_method IS NULL)
		BEGIN
			
			SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET      @report_date_end =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
		
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @report_date_end  = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
	    	SELECT @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
	        SET @report_date_end  = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
	    	SELECT @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @report_date_end = GETDATE()
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN

				SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
				SET @report_date_end = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
		END
		
	else BEGIN
	
	SELECT  @report_date_start = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET @report_date_end = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
				SET @report_date_start = ISNULL(@user_start_date, @report_date_start)
				SET @report_date_end = ISNULL(@user_end_date, @report_date_end)
	
	end





GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2015_bkp]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--
-- Used the Report SP's for the selection of dates for which the report will run for.
-- Algo:
--    1. The user's start and end date will be the first option to choose.
--    2. IF the user dates are not specified, the 'default_date_method'
--        will be used to determine the date range
--
-- NB: The report_start_date and report_end_date parameter will be set to the same day if the
--      report needs to be generated for a single date only.
--

ALTER PROCEDURE [dbo].[osp_rpt_get_dates_2015_bkp]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (30),
	@user_end_date		VARCHAR (30),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN
    
    
    IF (@user_start_date IS NULL AND @user_end_date IS NULL)
		BEGIN
			DECLARE @norm_cutover INT;
		--	EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
		 --       IF  (@norm_cutover=0) BEGIN
			--	SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'
			--RETURN
			--END
			
		END


	END 
 
	
	IF (@default_date_method = 'Last business day' --OR @default_date_method IS NULL
	)
		BEGIN
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
		     -- SELECT @user_start_date, @user_start_date, @user_end_date
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	END 

	IF (@default_date_method = 'Previous week')
	BEGIN
		
	
	        SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-7,GETDATE()),111),'/', '')
		SET @report_date_start = @user_start_date
		SET @report_date_end = @user_end_date
		
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
               
			
			SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(12), DATEADD(D,-1,GETDATE()),111),'/', '')
			SET       @user_end_date =REPLACE(CONVERT(VARCHAR(12), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	END
			

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
		SET @user_end_date = GETDATE()
		SET @report_date_start = @user_start_date;
		SET @report_date_end = @user_end_date;
	END

	ELSE IF (@default_date_method = 'Previous month')
		BEGIN
	
SELECT  @user_start_date = REPLACE(CONVERT(VARCHAR(10), DATEADD(Month,-1,GETDATE()),111),'/', '')
			SET @user_end_date = REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
		END
		
	else BEGIN
	
	
			SET @report_date_start = @user_start_date;
			SET @report_date_end = @user_end_date;
	
	
	end






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_e02_get_transaction_details]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












ALTER PROCEDURE [dbo].[osp_rpt_e02_get_transaction_details]
	@StartDate		VARCHAR(8),	-- yyyymmdd
	@EndDate		VARCHAR(8),	-- yyyymmdd
	@Tran_Amount		VARCHAR(255)
	
	
AS
BEGIN

select b.pan,b.expiry_date,b.service_restriction_code,b.terminal_id,a.retrieval_reference_nr,a.system_trace_audit_nr,a.auth_id_rsp,a.retrieval_reference_nr,a.datetime_tran_local,a.tran_amount_req
from post_tran a(nolock), post_tran_cust b(nolock)
where a.post_tran_cust_id = b.post_tran_cust_id
and a.datetime_tran_local > @StartDate and a.datetime_tran_local < @EndDate
--and a.post_tran_cust_id = '4553505'
and tran_amount_req = @Tran_Amount
--and b.pan like %@Pan_Last_four
and tran_postilion_originated = 0


END











GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_e02_card_on_foreign_atm]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO










ALTER PROCEDURE [dbo].[osp_rpt_e02_card_on_foreign_atm]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNodes		VARCHAR(255),	
	@MessageType		VARCHAR(255)
	
AS
BEGIN
-- my card on foreign atm
select count (*)as 'my card on foreign atm''@MessageType'
from post_tran pt (nolock)
inner join post_tran_cust ptc (nolock)
on pt.post_tran_cust_id = ptc.post_tran_cust_id
where pt.sink_node_name in ('MEGAGTBsnk','MEGAPWCsnk')
and (pt.datetime_req >= @StartDate and pt.datetime_req < @EndDate)
and (pt.message_type = @MessageType)
and (pt.tran_type not in ('00'))
and ((ptc.terminal_id not like '1058%')
and (ptc.terminal_id not like '1082%')
and (ptc.terminal_id not like '1701%'))
and (pt.tran_postilion_originated=0)
and (pt.tran_completed=1)

END








GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_different_amounts_in_0100_0220]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE [dbo].[osp_rpt_different_amounts_in_0100_0220]

@Start_Date  Varchar(10),
@End_Date  Varchar(10),
@Sink_Node   Varchar(14)
AS 
BEGIN
set NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

IF (@Start_Date IS NULL or Len(@Start_Date)=0) 

BEGIN
SET @Start_Date =  CONVERT(CHAR(8),(DATEADD (dd, -1, GetDate())), 112)


END

SET @End_Date =  CONVERT(CHAR(8),(DATEADD (dd, 1, @Start_Date)), 112) 

CREATE TABLE #summary2
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

CREATE TABLE #summary3
(post_tran_cust_id CHAR(16), mean_amount NUMERIC)

CREATE TABLE #summary4
(auth_stan varchar (10),post_tran_cust_id CHAR(16), auth_tran_amount NUMERIC, auth_tran_currency char (5), auth_settle_amount NUMERIC, auth_settle_currency char (5), auth_datetime DATETIME)

INSERT INTO #summary2

select post_tran_cust_id as post_tran_cust_id, count (*) from post_tran_summary as tran_count (NOLOCK) 
where message_type in ('0100','0220')
and tran_reversed = 0
and rsp_code_rsp = '00'
and post_tran_cust_id in (select distinct post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = '0220'
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < @ENd_date
and sink_node_name = @Sink_Node)

and post_tran_cust_id not in (select post_tran_cust_id from post_tran_summary (NOLOCK) where message_type = '0220' and rsp_code_req != '00' and sink_node_name = 'MEGAPRUsnk')
group by post_tran_cust_id

INSERT INTO #summary3

select s2.post_tran_cust_id as post_tran_cust_id, sum (tran_amount_req)/4 as mean_amount
from post_tran_summary  ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
group by s2.post_tran_cust_id

INSERT INTO #summary4

select ptr.system_trace_audit_nr as auth_stan, s2.post_tran_cust_id as post_tran_cust_id, tran_amount_req/100 as auth_tran_amount,dbo.currencyAlphaCode(ptr.tran_currency_code) as auth_tran_currency,ptr.settle_amount_req/100 as auth_settle_amount,dbo.currencyAlphaCode(ptr.settle_currency_code) as auth_settle_currency, datetime_req as auth_datetime
from post_tran_summary ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
and ptr.message_type = '0100'
and ptr.tran_postilion_originated=0
--group by s2.post_tran_cust_id


select 
       pt.message_type as message_type,
       ptc.terminal_id as terminal_id,
	s4.auth_stan,
system_trace_audit_nr as completion_stan,
  ptc.card_acceptor_id_code as card_acceptor_id,
ptc.card_acceptor_name_loc as card_acceptor_name_loc,
       
	pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       s4.auth_tran_amount,
	s4.auth_tran_currency,
	pt.tran_amount_req/100 as completion_tran_amount,
	dbo.currencyAlphaCode(pt.tran_currency_code) as completion_tran_currency,
	s4.auth_tran_amount - pt.tran_amount_req/100 as difference_in_amounts,
         
	s4.auth_settle_amount,
	s4.auth_settle_currency,
        pt.settle_amount_req/100 as completion_settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as completion_settle_currency,
       	s4.auth_datetime,
	pt.datetime_req as completion_date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
       
       pt.post_tran_cust_id as tran_id

FROM post_tran_summary  pt (nolock)
join #summary3 s (nolock)
ON s.post_tran_cust_id = ptc.post_tran_cust_id
join #summary4 s4 (nolock)
on s.post_tran_cust_id = s4.post_tran_cust_id
where s.mean_amount != pt.tran_amount_req
and pt.tran_postilion_originated=1
and message_type = '0220'
order by pt.datetime_req


END






GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_diff_tran_amts_0100_0220_issuer]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO














-- script developed by eseosa osaikhuiwu @ interswitch ltd 02/05/2012
-- modified by eseosa osaikhuiwu @ interswitch ltd to include retrieval reference number 04/05/2012
-- 







ALTER PROCEDURE [dbo].[osp_rpt_diff_tran_amts_0100_0220_issuer]

@Start_Date  Varchar(10),
@End_Date  Varchar(10),
@Source_Node   Varchar(14)


AS 
BEGIN
set NOCOUNT ON


IF (@Start_Date IS NULL or Len(@Start_Date)=0) 

BEGIN
SET @Start_Date = CONVERT(CHAR(8),(DATEADD (dd, -1, GetDate())), 112)
SET @End_Date = @Start_Date

END

CREATE TABLE #summary2
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

CREATE TABLE #summary3
(post_tran_cust_id CHAR(16), mean_amount NUMERIC)

CREATE TABLE #summary4
(auth_stan varchar (10),post_tran_cust_id CHAR(16), auth_tran_amount NUMERIC, auth_tran_currency char (5), auth_settle_amount NUMERIC, auth_settle_currency char (5), auth_datetime DATETIME)

INSERT INTO #summary2

select pt.post_tran_cust_id as post_tran_cust_id, count (*)as tran_count from post_tran pt join post_tran_cust ptc on pt.post_tran_cust_id = ptc.post_tran_cust_id 
where message_type in ('0100','0220')
and tran_reversed = 0
and rsp_code_rsp = '00'
and pt.post_tran_cust_id in (select distinct pt.post_tran_cust_id from post_tran pt join post_tran_cust ptc on pt.post_tran_cust_id = ptc.post_tran_cust_id where message_type = '0220'
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < (SELECT CONVERT(char(8), (DATEADD (DAY, +1,@End_Date)), 112))
and source_node_name = @Source_Node)

and pt.post_tran_cust_id not in (select pt.post_tran_cust_id from post_tran pt join post_tran_cust ptc on pt.post_tran_cust_id = ptc.post_tran_cust_id  where message_type = '0220' and rsp_code_req != '00' and source_node_name = @Source_Node)
group by pt.post_tran_cust_id

INSERT INTO #summary3

select s2.post_tran_cust_id as post_tran_cust_id, sum (tran_amount_req)/4 as mean_amount
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
group by s2.post_tran_cust_id

INSERT INTO #summary4

select ptr.system_trace_audit_nr as auth_stan, s2.post_tran_cust_id as post_tran_cust_id, tran_amount_req/100 as auth_tran_amount,dbo.currencyAlphaCode(ptr.tran_currency_code) as auth_tran_currency,ptr.settle_amount_req/100 as auth_settle_amount,dbo.currencyAlphaCode(ptr.settle_currency_code) as auth_settle_currency, datetime_req as auth_datetime
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
and ptr.message_type = '0100'
and ptr.tran_postilion_originated=0
--group by s2.post_tran_cust_id


select 
       pt.message_type as message_type,
       ptc.terminal_id as terminal_id,
	s4.auth_stan,
system_trace_audit_nr as completion_stan,
  ptc.card_acceptor_id_code as card_acceptor_id,
ptc.card_acceptor_name_loc as card_acceptor_name_loc,
       
	pan as pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       s4.auth_tran_amount,
	s4.auth_tran_currency,
	pt.tran_amount_req/100 as completion_tran_amount,
	dbo.currencyAlphaCode(pt.tran_currency_code) as completion_tran_currency,
	s4.auth_settle_amount,
	s4.auth_settle_currency,
        pt.settle_amount_req/100 as completion_settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as completion_settle_currency,
       	s4.auth_datetime,
	pt.datetime_req as completion_date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
       
       pt.post_tran_cust_id as tran_id

from post_tran_cust ptc (nolock)
join #summary3 s (nolock)
on s.post_tran_cust_id = ptc.post_tran_cust_id
join post_tran pt (nolock) 
on s.post_tran_cust_id = pt.post_tran_cust_id
join #summary4 s4 (nolock)

on s.post_tran_cust_id = s4.post_tran_cust_id
where s.mean_amount != pt.tran_amount_req
and pt.tran_postilion_originated=0
and message_type = '0220'
order by pt.datetime_req


END




















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_diff_tran_amts_0100_0220]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO













-- script developed by eseosa osaikhuiwu @ interswitch ltd 02/05/2012
-- modified by eseosa osaikhuiwu @ interswitch ltd to include retrieval reference number 04/05/2012
-- 







ALTER PROCEDURE [dbo].[osp_rpt_diff_tran_amts_0100_0220]

@Start_Date  Varchar(10),
@End_Date  Varchar(10),
@Sink_Node   Varchar(14)


AS 
BEGIN
set NOCOUNT ON


IF (@Start_Date IS NULL or Len(@Start_Date)=0) 

BEGIN
SET @Start_Date = CONVERT(CHAR(8),(DATEADD (dd, -1, GetDate())), 112)
SET @End_Date = @Start_Date

END

CREATE TABLE #summary2
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

CREATE TABLE #summary3
(post_tran_cust_id CHAR(16), mean_amount NUMERIC)

CREATE TABLE #summary4
(auth_stan varchar (10),post_tran_cust_id CHAR(16), auth_tran_amount NUMERIC, auth_tran_currency char (5), auth_settle_amount NUMERIC, auth_settle_currency char (5), auth_datetime DATETIME)

INSERT INTO #summary2

select post_tran_cust_id as post_tran_cust_id, count (*) from post_tran as tran_count
where message_type in ('0100','0220')
and tran_reversed = 0
and rsp_code_rsp = '00'
and post_tran_cust_id in (select distinct post_tran_cust_id from post_tran where message_type = '0220'
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < (SELECT CONVERT(char(8), (DATEADD (DAY, +1,@End_Date)), 112))
and sink_node_name = @Sink_Node)

and post_tran_cust_id not in (select post_tran_cust_id from post_tran where message_type = '0220' and rsp_code_req != '00' and sink_node_name = 'MEGAPRUsnk')
group by post_tran_cust_id

INSERT INTO #summary3

select s2.post_tran_cust_id as post_tran_cust_id, sum (tran_amount_req)/4 as mean_amount
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
group by s2.post_tran_cust_id

INSERT INTO #summary4

select ptr.system_trace_audit_nr as auth_stan, s2.post_tran_cust_id as post_tran_cust_id, tran_amount_req/100 as auth_tran_amount,dbo.currencyAlphaCode(ptr.tran_currency_code) as auth_tran_currency,ptr.settle_amount_req/100 as auth_settle_amount,dbo.currencyAlphaCode(ptr.settle_currency_code) as auth_settle_currency, datetime_req as auth_datetime
from post_tran ptr (nolock) join #summary2 s2 (nolock)
on ptr.post_tran_cust_id = s2.post_tran_cust_id
where s2.tran_count = 4
and ptr.message_type = '0100'
and ptr.tran_postilion_originated=0
--group by s2.post_tran_cust_id


select 
       pt.message_type as message_type,
       ptc.terminal_id as terminal_id,
	s4.auth_stan,
system_trace_audit_nr as completion_stan,
  ptc.card_acceptor_id_code as card_acceptor_id,
ptc.card_acceptor_name_loc as card_acceptor_name_loc,
       
	pan as pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       s4.auth_tran_amount,
	s4.auth_tran_currency,
	pt.tran_amount_req/100 as completion_tran_amount,
	dbo.currencyAlphaCode(pt.tran_currency_code) as completion_tran_currency,
	s4.auth_settle_amount,
	s4.auth_settle_currency,
        pt.settle_amount_req/100 as completion_settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as completion_settle_currency,
       	s4.auth_datetime,
	pt.datetime_req as completion_date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
       
       pt.post_tran_cust_id as tran_id

from post_tran_cust ptc (nolock)
join #summary3 s (nolock)
on s.post_tran_cust_id = ptc.post_tran_cust_id
join post_tran pt (nolock) 
on s.post_tran_cust_id = pt.post_tran_cust_id
join #summary4 s4 (nolock)
on s.post_tran_cust_id = s4.post_tran_cust_id
where s.mean_amount != pt.tran_amount_req
and pt.tran_postilion_originated=0
and message_type = '0220'
order by pt.datetime_req


END



















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_card_on_foreign_atm]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO





















ALTER PROCEDURE [dbo].[osp_rpt_card_on_foreign_atm]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
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
				(t.message_type IN ('0220')) 
				)
				AND 
				t.tran_completed = 1 
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr 
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b36]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




















-- a new report created by Eseosa on 7/05/2013 to generate a summary of switched-out transactions
-- the report became necessry due to the bulkiness of the detail repoRT

ALTER PROCEDURE [dbo].[osp_rpt_b36]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(80),
	@SinkNode		VARCHAR(40),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.
CREATE TABLE #report_result
	(
		
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		Source_node				VARCHAR (40),
		message_type				varchar (6),
		Volume				NUMERIC,
		Response				VARCHAR (15),
		Region				VARCHAR (20))

		

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
	NULL AS Warning,
	CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
	CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
	c.source_node_name as Source_node,
	t.message_type,
	count(*) as Volume,
	case rsp_code_rsp when '00' then 'Successful' else 'Unsuccessful' end as Response,
	case dbo.fn_rpt_islocalAcqTrx (c.pan) when 1 then 'Local' else 'Foreign' end as Region
	
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0
				AND
				t.message_type IN ('0100','0200','0220')--oremeyi removed the 0120
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@SinkNode IS NULL or t.sink_node_name = @SinkNode)


	group by c.source_node_name,t.message_type,case rsp_code_rsp when '00' then 'Successful' else 'Unsuccessful' end,case dbo.fn_rpt_islocalAcqTrx (c.pan) when 1 then 'Local' else 'Foreign' end

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	

	SELECT
			*
	FROM
			#report_result
	order by Source_node
	
END































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b28]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












-- a new report created by Eseosa on 7/05/2013 to generate a summary of switched-in transactions
-- the report became necessry due to the bulkiness of the detail repoRT

ALTER PROCEDURE [dbo].[osp_rpt_b28]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.
CREATE TABLE #report_result
	(
		
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		Bin 					VARCHAR (6),
		local_fin_0100				NUMERIC,
		local_fin_0200				NUMERIC,
		local_fin_0220				NUMERIC,
		foreign_0100				NUMERIC,
		foreign_0200				NUMERIC,
		foreign_fin_0220			NUMERIC)

		
	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
	NULL AS Warning,
	CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
	CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
	left (c.pan,6) as Bin,
	sum (dbo.fn_rpt_islocalfinancial0100Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.card_acceptor_name_loc)) as local_fin_0100,
	sum (dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.card_acceptor_name_loc)) as local_fin_0200,
	sum (dbo.fn_rpt_islocalfinancial0220Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.card_acceptor_name_loc)) as local_fin_0220,

	sum (dbo.fn_rpt_isforeign0100Trx(t.message_type,c.card_acceptor_name_loc)) as foreign_0100,
	sum (dbo.fn_rpt_isforeign0200Trx(t.message_type,c.card_acceptor_name_loc)) as foreign_0200,
	sum (dbo.fn_rpt_isforeignfinancial0220Trx (t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.card_acceptor_name_loc)) as foreign_fin_0220	
	
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220')--oremeyi removed the 0120
				AND
				
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
	group by left(c.pan,6)

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	

	SELECT
			*
	FROM
			#report_result
	order by Bin
	
END























GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b26]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

















-- a new report created by Eseosa on 7/05/2013 to generate a summary of switched-out transactions
-- the report became necessry due to the bulkiness of the detail repoRT

ALTER PROCEDURE [dbo].[osp_rpt_b26]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(80),
	@SinkNode		VARCHAR(40),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.
CREATE TABLE #report_result
	(
		
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		Source_node				VARCHAR (40),
		local_Acq_fin_0100				NUMERIC,
		local_Acq_fin_0200				NUMERIC,
		local_Acq_fin_0220				NUMERIC,
		foreign_Acq_0100				NUMERIC,
		foreign_Acq_0200				NUMERIC,
		foreign_Acq_fin_0220			NUMERIC)

		

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SinkNode
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
	NULL AS Warning,
	CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
	CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
	c.source_node_name as Source_node,
	sum (dbo.fn_rpt_islocalfinancial0100AcqTrx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.pan)) as local_Acq_fin_0100,
	sum (dbo.fn_rpt_islocalfinancial0200AcqTrx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.pan)) as local_Acq_fin_0200,
	sum (dbo.fn_rpt_islocalfinancial0220AcqTrx(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.pan)) as local_Acq_fin_0220,

	sum (dbo.fn_rpt_isforeign0100AcqTrx(t.message_type,c.pan)) as foreign_Acq_0100,
	sum (dbo.fn_rpt_isforeign0200AcqTrx(t.message_type,c.pan)) as foreign_Acq_0200,
	sum (dbo.fn_rpt_isforeignfinancial0220AcqTrx (t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.rsp_code_req, c.pan)) as foreign_Acq_fin_0220	
	
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220')--oremeyi removed the 0120
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				(@SinkNode IS NULL or t.sink_node_name = @SinkNode)


	group by c.source_node_name

	IF @@ROWCOUNT = 0
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	

	SELECT
			*
	FROM
			#report_result
	order by Source_node
	
END





























GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA Local_Issuing_Billing]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














ALTER PROCEDURE [dbo].[osp_rpt_b08_VISA Local_Issuing_Billing]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC

	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				t.pan,
				t.terminal_id,
				t.card_acceptor_id_code,
				t.card_acceptor_name_loc,
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
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				t.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                t.totals_group

				
	FROM
		 post_tran_summary  t (NOLOCK)
	WHERE 			
				t.post_tran_cust_id = t.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
and t.pan like '4%'
--and settle_currency_code not in ('566')
--and rsp_code_rsp = ('00')
and RIGHT (t.card_acceptor_name_loc,2) = 'NG'
--and t.totals_group like '%FBPVisa%'
and tran_type = '01'
OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END





/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA International Acquiring Billing_All]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA International_Issuing_Billing_All]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














ALTER PROCEDURE [dbo].[osp_rpt_b08_VISA International_Issuing_Billing_All]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40),
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		islocalfinancial0200TrxNOTCashWdrl		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		tran_reversed  INT
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC

	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				t.pan,
				t.terminal_id,
				t.card_acceptor_id_code,
				t.card_acceptor_name_loc,
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
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				t.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                t.totals_group,
                                
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as islocalfinancial0200,
				dbo.fn_rpt_islocalfinancial0200TrxNOTCashWdrl(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.card_acceptor_name_loc,t.tran_type) as islocalfinancial0200TrxNOTCashWdrl,


				extended_tran_type,
				tran_reversed

				
	FROM
				post_tran_summary t (NOLOCK)
				
				
	WHERE 			

				t.tran_completed = '1'
				AND

				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
and t.pan like '468219%'
--and settle_currency_code not in ('566')
and rsp_code_rsp = ('00')
and RIGHT (t.card_acceptor_name_loc,2) <> 'NG'
and tran_type in ('01','31')
OPTION (RECOMPILE)

				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
         tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                    left(totals_group,3) as totals_group,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type
		

	 
	FROM 
			@report_result
Group by startdate, enddate, tran_type,settle_currency_code, totals_group,rsp_code_rsp,message_type,islocalTrx

       OPTION (MAXDOP 8) 
	END



/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA Local_Issuing_Billing]    Script Date: 05/17/2016 16:30:20 ******/
SET ANSI_NULLS ON

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_VISA Billing]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_VISA Billing]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC

	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				t.pan,
				t.terminal_id,
				t.card_acceptor_id_code,
				t.card_acceptor_name_loc,
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
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				t.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                t.totals_group

				
	FROM
					post_tran_summary  t (NOLOCK)
				
	WHERE 			
				t.post_tran_cust_id = t.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND

				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
and t.pan like '468219%'
--and settle_currency_code not in ('566')
and rsp_code_rsp = ('00')
and t.card_acceptor_name_loc like '%NG%'
OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local
    OPTION (MAXDOP 8)
        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_verveintl_All]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b08_verveintl_All]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

SET NOCOUNT ON

CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2),
		acquiring_inst_id_code		VARCHAR (225),
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 
		--tran_amount_rsp				FLOAT,
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
		rsp_code_description	VARCHAR (200),
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
		retention_data				Varchar(999)
	)	

DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	 --Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAUBAsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	

CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id,
			c.terminal_owner,
                        c.source_node_name, 
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.acquiring_inst_id_code,
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
			--t.tran_amount_rsp,		
			t.settle_currency_code, 
			
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
			isnull(t.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            --left join 
            --post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                         -- tt.tran_postilion_originated = 1
                                          --and t.tran_nr = tt.tran_nr)
	
WHERE 		c.post_tran_cust_id >= @rpt_tran_id
            AND
			t.tran_completed = 1
			--AND
			--(t.recon_business_date >= @report_date_start) 
			--AND 
			--(t.recon_business_date <= @report_date_end)
			/*AND
			(t.datetime_req >= @report_date_start) 
			AND 
			(t.datetime_req <= @report_date_end) */
			AND
			t.tran_postilion_originated = 1
			AND
			t.message_type IN ('0200','0220','0400','0420')
			AND 
			t.tran_completed = 1 
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
           -- AND
         -- t.sink_node_name = 'MEGASWTsnk'
            -- AND
          --.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
		AND totals_group in('VerveTGrp','VerveTSBGrp')
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
	
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Verve_Intl]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_Verve_Intl]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	
		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		tran_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10),
                totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE @list_of_sink_nodes TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT PART FROM usf_split_string(@SinkNodes, ',') ORDER BY PART ASC
	
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT


		IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
		ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
		SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,

				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req,

				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,


				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id,


				t.system_trace_audit_nr,
				t.message_reason_code,
				t.retrieval_reference_nr,
				t.datetime_tran_local,
				t.from_account_type,
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region,
                                c.totals_group

				
	FROM
							post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END

































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_out_verveintl_All]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_out_verveintl_All]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'SWTMEGAsnk'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	

CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0
				
				AND totals_group like 'VerveTGrp'
				
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
					
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   source_node_name as Acq_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr	

	 
	FROM 
			#report_result


Group by startdate, enddate, settle_currency_code, source_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr	

      
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_out_All_bkp]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE[dbo].[osp_rpt_b08_Switched_out_All_bkp]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(4000),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		islocalTrx			INT,
		isforeignfinancial0200		INT,
		islocalfinancial0200		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10)
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	DECLARE  @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
	
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT


	IF(@report_date_start<> @report_date_end) BEGIN
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END

	
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,

				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp

				
	FROM
				post_tran t (NOLOCK) join

				post_tran_cust c (NOLOCK)
on
				
				
			t.post_tran_cust_id = c.post_tran_cust_id
				
	WHERE 			
				
				t.tran_completed = '1'
				AND
				t.post_tran_cust_id >= @first_post_tran_cust_id
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
				AND
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes )
					)
					
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   source_node_name as Acq_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		isforeignfinancial0200,
		islocalfinancial0200

	 
	FROM 
			@report_result
Group by startdate, enddate, settle_currency_code, source_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,isforeignfinancial0200,islocalfinancial0200

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_out_All]    Script Date: 05/26/2016 15:50:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE[dbo].[osp_rpt_b08_Switched_out_All]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(4000),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED



	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		text,
		tran_reversed			INT,
		islocalTrx			INT,
		isforeignfinancial0200		INT,
		islocalfinancial0200		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10)
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

  set @StartDate =REPLACE( CONVERT(VARCHAR(30), @report_date_start, 111), '/', '');
   set @EndDate = REPLACE( CONVERT(VARCHAR(30),@report_date_end,111), '/', '');
   
	DECLARE  @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				--t.terminal_owner,
				t.merchant_type,
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
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as islocalfinancial0200,

				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp

				
	FROM
				post_tran_summary t (NOLOCK)
	WHERE 			
				
				t.tran_completed = '1'
				AND
		
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes )
					)
					
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	 

SELECT 
		 StartDate,
		 EndDate,
tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   source_node_name as Acq_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		isforeignfinancial0200,
		islocalfinancial0200

	 
	FROM 
			@report_result
Group by startdate, enddate,tran_type, settle_currency_code, source_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,isforeignfinancial0200,islocalfinancial0200

         OPTION (MAXDOP 8)

	END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_VISA]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




















ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All_VISA]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SinkNodes	VARCHAR(4000),
        --@SourceNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	DECLARE  @report_result TABLE
	(
		seq_num_id        BIGINT IDENTITY (1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30),
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		islocalfinancial0200TrxNOTCashWdrl		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
        CardType CHAR(19)
			)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
        SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   


	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	DECLARE  @list_of_sink_nodes TABLE (sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT part from  usf_split_string( @SinkNodes,',') ORDER BY PART ASC

--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT


		IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
		ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
		SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
		END
	
	
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,
				dbo.fn_rpt_islocalfinancial0200TrxNOTCashWdrl(t.message_type,t.tran_amount_req,t.rsp_code_rsp,c.card_acceptor_name_loc,t.tran_type) as islocalfinancial0200TrxNOTCashWdrl,


				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp,
                dbo.fn_rpt_CardType(c.pan,t.sink_node_name,t.tran_type,c.terminal_id) AS CardType
				

				
	FROM
				post_tran t (NOLOCK)
				join
				post_tran_cust c (NOLOCK)
				on 
				t.post_tran_cust_id = c.post_tran_cust_id				
	WHERE 			
				
				
				t.tran_completed = '1'
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
			        
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				
				)
                                AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
and c.pan like '4%'
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
         tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		TranID,
		prev_post_tran_id,
		isforeignfinancial0200,
		islocalfinancial0200,
		islocalfinancial0200TrxNOTCashWdrl
		

	 
	FROM 
			@report_result
Group by startdate, enddate, tran_type,settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id,isforeignfinancial0200,islocalfinancial0200,islocalfinancial0200TrxNOTCashWdrl

        
	END







































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_test]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All_test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
        --@SourceNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		isforeignFinancial0200		INT,
		islocalfinancial0200		INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
        SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes

--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as isforeignfinancial0200,
				dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, c.card_acceptor_name_loc) as islocalfinancial0200,

				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
			        
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
				
				)
                                AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		TranID,
		prev_post_tran_id,
		isforeignfinancial0200,
		islocalfinancial0200
		

	 
	FROM 
			#report_result
Group by startdate, enddate, settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id,isforeignfinancial0200,islocalfinancial0200	

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_review]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b08_Switched_in_All_review]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
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
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_Switched_in_All_FBN]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_Switched_in_All_FBN]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNodes	Text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		pan				VARCHAR (19), 
		terminal_id				VARCHAR (18), 
		acquiring_inst_id_code			VARCHAR(18),
		--terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
                islocalTrx			INT,
		
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		
		
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				--c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
					)
				
				)
				AND t.sink_node_name LIKE 'FBN'
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   sink_node_name as Rem_Bank,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                     islocalTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr	

	 
	FROM 
			#report_result
Group by startdate, enddate, settle_currency_code, sink_node_name,rsp_code_rsp,islocalTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr	

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_monthly_old]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_monthly_old]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(40),
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				isnull(t.rsp_code_rsp,'99'),
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

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

		SET @process_descr = 'Office B08 Report'

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
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_ksb]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_ksb]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				isnull(t.rsp_code_rsp,'99'),
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

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

		SET @process_descr = 'Office B08 Report'

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
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_failed]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_failed]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	DECLARE  @report_result TABLE 
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM @report_result
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)

		SELECT * FROM @report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE  @list_of_source_nodes TABLE(source_node	VARCHAR(30))

	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',');

	DECLARE  @list_of_Sink_nodes TABLE(sink_node	VARCHAR(30))

	INSERT INTO  @list_of_Sink_nodes SELECT part FROM usf_split_string(@SinkNode, ',');

		
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		

	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @report_date_start  AND recon_business_date >=  @report_date_start   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end ) ORDER BY datetime_req DESC)
	     SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start   AND recon_business_date >= @report_date_start     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @report_date_start  AND (recon_business_date >= @report_date_start )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @report_date_end  AND (recon_business_date < @report_date_end ) ORDER BY recon_business_date DESC)
		
		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @report_date_start AND (recon_business_date >= @report_date_start )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @report_date_end AND (recon_business_date < @report_date_end  ) ORDER BY datetime_req DESC)
	END
	

				
	

	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_2))
				 JOIN
					post_tran_cust c (NOLOCK, INDEX(pk_post_tran_cust))
				ON 
					t.post_tran_cust_id = c.post_tran_cust_id
	WHERE
				t.tran_completed = 1
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
                                AND
                                 t.rsp_code_rsp not in ('00')
                                AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM @list_of_Sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)

	IF @@ROWCOUNT = 0
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	ELSE
	BEGIN
		--
		-- Decrypt PAN information if necessary
		--

		DECLARE @pan VARCHAR (19)
		DECLARE @pan_encrypted CHAR (18)
		DECLARE @pan_clear VARCHAR (19)
		DECLARE @process_descr VARCHAR (100)

		SET @process_descr = 'Office B08 Report'

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

	SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_credit_adj_NEW]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

















ALTER PROCEDURE [dbo].[osp_rpt_b08_credit_adj_NEW]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		from_account_id						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		tran_amount_req			FLOAT,
		tran_currency_code		CHAR (6),
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		TranCurrencyName		VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		Trancurrency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				dbo.DecryptPan(c.pan,pan_encrypted,'CardStatement'),
				t.from_account_id,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,
				--t.tran_amount_req,
				
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req,
				t.tran_currency_code,
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,
				dbo.currencyName(t.tran_currency_code) AS  TranCurrencyName,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyAlphaCode(t.tran_currency_code) AS Trancurrency_alpha_code,
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0
				AND
				t.message_type IN ('0100','0200','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_type in  ('22', '20')
				AND
				t.tran_completed = 1
				AND
			        t.rsp_code_rsp IN ('00', '11','10','08','16')	
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

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

		SET @process_descr = 'Office B08 Report'

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
			datetime_tran_local
END



















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_credit_adj]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO
















ALTER PROCEDURE [dbo].[osp_rpt_b08_credit_adj]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		from_account_id						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		tran_amount_req			FLOAT,
		tran_currency_code		CHAR (6),
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		TranCurrencyName		VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		Trancurrency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				dbo.DecryptPan(t.pan,pan_encrypted,'CardStatement'),
				t.from_account_id,
				t.terminal_id,
				t.card_acceptor_id_code,
				t.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,
				--t.tran_amount_req,
				
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req,
				t.tran_currency_code,
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,
				dbo.currencyName(t.tran_currency_code) AS  TranCurrencyName,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyAlphaCode(t.tran_currency_code) AS Trancurrency_alpha_code,
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran_summary  t (NOLOCK)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_type in  ('22', '20')
				and t.rsp_code_rsp = '00'
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
			OPTION (RECOMPILE)

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

		SET @process_descr = 'Office B08 Report'

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
			datetime_tran_local
END




GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_channels]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_channels]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		channel				varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp,
				case when ((c.pos_terminal_type in ('01')) and merchant_type not in ('6011')) then 'Pos' when ((c.pos_terminal_type not in ('01','02')) and merchant_type not in ('6011')) then 'Web' when ((c.pos_terminal_type = '02') or (c.pos_terminal_type = '01' and (merchant_type = '6011' or merchant_type is NULL))) then 'Atm' else 'others'  end as channel
				
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

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

		SET @process_descr = 'Office B08 Report'

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
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_card_product]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b08_card_product]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		card_product			varchar(20)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				c.pan_encrypted,
				auth_id_rsp,
				card_product
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
				t.tran_completed = 1
				AND
				(t.recon_business_date >= @report_date_start)
				AND
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1
				AND
				t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				AND
				t.tran_completed = 1
				AND 
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

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

		SET @process_descr = 'Office B08 Report'

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
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_aborted_completion]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO










ALTER PROCEDURE [dbo].[osp_rpt_b08_aborted_completion]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET NOCOUNT ON

IF ((@Period is NULL or @Period = 'Daily') and (@StartDate IS NULL or @EndDate is NULL OR Len(@StartDate)=0)) 

BEGIN
SET @StartDate  = CONVERT(VARCHAR(30),(DATEADD (dd, -1, GetDate())), 112)
SET @EndDate = CONVERT(VARCHAR(30),(DATEADD (dd,-1, GetDate())), 112)
END

IF (@Period = 'Weekly' and (@StartDate IS NULL or @EndDate is NULL OR Len(@StartDate)=0)) 

BEGIN
SET @StartDate  = CONVERT(CHAR(8),(DATEADD (dd, -7, GetDate())), 112)
SET @EndDate = CONVERT(CHAR(8),(DATEADD (dd, 0, GetDate())), 112)
END


IF (@Period = 'Monthly' and (@StartDate IS NULL or @EndDate is NULL OR Len(@StartDate)=0)) 

BEGIN
SET @StartDate = (select CONVERT(char(6), (DATEADD (MONTH, -1,GETDATE())), 112)+ '01') 
SET @EndDate = (select CONVERT(char(6), GETDATE(), 112)+ '01')
END

DECLARE @report_date_start DATETIME;
DECLARE @report_date_end DATETIME;

SET @report_date_start = @StartDate
set @report_date_end = dateadd(dd,1,@EndDate)


	
create table #aborted (post_tran_cust_id	varchar(20), tran_nr		varchar (16))

insert into #aborted  select post_tran_cust_id,tran_nr from post_tran_summary a (NOLOCK)
where message_type in ('0220')
	and a.tran_amount_req != '0'
	and a.rsp_code_req = '00'
	and
					(a.recon_business_date >= @report_date_start) 
				AND 
				(a.recon_business_date <= @report_date_end) 
	and a.abort_rsp_code is not null
	and a.sink_node_name = @SinkNode
	OPTION (RECOMPILE)

	SELECT		t.pan,
			t.from_account_id,
			t.to_account_id,
			convert(char, t.datetime_req, 109) as Tran_Date,
			t.terminal_id,
			t.card_acceptor_id_code,
			t.card_acceptor_name_loc, 
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description, 
			t.retrieval_reference_nr, 			
			
			dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount,
			dbo.currencyAlphaCode(t.tran_currency_code) AS tran_currency_alpha_code,
			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee,	
			dbo.formatAmount((t.settle_amount_req + t.settle_tran_fee_rsp), t.settle_currency_code) as Total_Impact,
			dbo.currencyAlphaCode(t.settle_currency_code) AS settle_currency_alpha_code,
			dbo.formatRspCodeStr(t.rsp_code_rsp) AS Response_Code_description,
			auth_id_rsp AS Auth_Id,
			system_trace_audit_nr as stan,
			t.tran_nr,
			t.post_tran_cust_id
			
						
	FROM
			post_tran_summary t (NOLOCK)
			join #aborted a (nolock) on (t.post_tran_cust_id = t.post_tran_cust_id)

	where t.message_type = '0220' 
	and t.tran_postilion_originated = 0
	order by t.datetime_req
	OPTION (RECOMPILE)
END

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_settle_currency]    Script Date: 05/17/2016 16:30:14 ******/
SET ANSI_NULLS ON

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_aborted]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b08_aborted]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
	@SourceNodes		VARCHAR(255),
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@show_full_pan		INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B08 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning 				VARCHAR (255),
		StartDate				CHAR (8),
		EndDate					CHAR (8),
		pan						VARCHAR (19),
		from_account_id						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		tran_amount_req			FLOAT,
		tran_currency_code		CHAR (6),
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		TranCurrencyName		VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		Trancurrency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode



				
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				dbo.DecryptPan(c.pan,pan_encrypted,'CardStatement'),
				t.from_account_id,
				c.terminal_id,
				c.card_acceptor_id_code,
				c.card_acceptor_name_loc,
				t.sink_node_name,
				t.tran_type,
				t.rsp_code_rsp,
				t.message_type,
				t.datetime_req,
				--t.tran_amount_req,
				
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req,
				t.tran_currency_code,
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

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,
				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,
				dbo.currencyName(t.tran_currency_code) AS  TranCurrencyName,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyAlphaCode(t.tran_currency_code) AS Trancurrency_alpha_code,
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				c.pan_encrypted,
				auth_id_rsp
	FROM
				post_tran t WITH (NOLOCK)
				INNER JOIN
				post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)

	WHERE			abort_rsp_code is not null
				--t.tran_completed = 1
				and
				(t.recon_business_date >= @report_date_start)
				and
				(t.recon_business_date <= @report_date_end)
				--AND
				--t.tran_postilion_originated = 0
				--AND
				--t.message_type IN ('0100','0200','0220','0420', '0400')--oremeyi removed the 0120
				--AND
				--t.tran_type in  ('22', '20')
				--AND
				--t.tran_completed = 1
				--AND 
				and
				t.sink_node_name IN (SELECT sink_node FROM #list_of_sink_nodes)
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)

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

		SET @process_descr = 'Office B08 Report'

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
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_2]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b08_2]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	    VARCHAR(30),	-- yyyymmdd
	@SinkNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	DECLARE  @report_result TABLE
	(
		Warning 				VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		pan						VARCHAR (19),
		terminal_id				CHAR (8),
		card_acceptor_id_code	CHAR (15),
		card_acceptor_name_loc	CHAR (40),
		sink_node_name			VARCHAR (40),
		tran_type				CHAR (2),
		rsp_code_rsp			CHAR (2),
		message_type			CHAR (4),
		datetime_req			DATETIME,
		settle_amount_req		FLOAT,
		settle_amount_rsp		FLOAT,
		settle_tran_fee_rsp		FLOAT,
		TranID						BIGINT,
		prev_post_tran_id			BIGINT,
		system_trace_audit_nr	CHAR (6),
		message_reason_code		CHAR (4),
		retrieval_reference_nr	CHAR (12),
		datetime_tran_local		DATETIME,
		from_account_type		CHAR (2),
		from_account_id			VARCHAR(20),
		to_account_type			CHAR (2),
		settle_currency_code	CHAR (3),
		settle_amount_impact	FLOAT,
		CurrencyNrDecimals		INT,
		CurrencyName			VARCHAR (20),
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		islocalTrx			INT,
		isnairaTrx			INT,
		iscompletionTrx			INT,
		pan_encrypted			CHAR (18),
		auth_id_rsp			varchar(10),
		Region				varchar(10)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(varchar(30), @report_date_start, 112)
	SET @EndDate = CONVERT(varchar(30),  @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 

	DECLARE  @list_of_sink_nodes  TABLE(sink_node	VARCHAR(30)) 
	INSERT INTO  @list_of_sink_nodes SELECT part FROM dbo.usf_split_string( @SinkNodes, ',');
	
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=@report_date_start  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req < @report_date_end  ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=CONVERT(DATETIME,@report_date_start)  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req < CONVERT(DATETIME,@report_date_end)  ORDER BY datetime_req DESC)
	END
	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
				CONVERT(VARCHAR(30), @report_date_end, 112) as EndDate,
				c.pan,
				c.terminal_id,
				c.card_acceptor_id_code,
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
				t.from_account_id,
				t.to_account_type,
				t.settle_currency_code,

				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END
						, t.settle_currency_code) AS settle_amount_impact,

				dbo.currencyNrDecimals(t.settle_currency_code) AS CurrencyNrDecimals,

				dbo.currencyName(t.settle_currency_code) AS  CurrencyName,

				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,

				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				dbo.fn_rpt_islocalTrx(card_acceptor_name_loc)   AS islocalTrx,
				dbo.fn_rpt_isnairaTrx(tran_currency_code)	AS isnairaTrx,
				dbo.fn_rpt_isApprovedTrx(rsp_code_req)		AS iscompletionTrx,
				c.pan_encrypted,
				auth_id_rsp,
				dbo.fn_rpt_getRegion_Issuer(card_acceptor_name_loc) as Region

				
	FROM
					 post_tran t (nolock, INDEX(ix_post_tran_2 ))
		, post_tran_cust c (nolock,INDEX(pk_post_tran_cust))
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SinkNodes IS NULL
					OR
					(
						@SinkNodes IS NOT NULL
						AND
						t.sink_node_name IN (SELECT sink_node FROM @list_of_sink_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06b]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06b]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
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
		rsp_code_description	VARCHAR (200),
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
		islocalAcqTrx		INT  -- added by eseosa on 17th
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
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
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_weekly]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_weekly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
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
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
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
	SET @date_selection_mode = 'Previous week'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
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
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Voice_Auth_weekly]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b06_Voice_Auth_weekly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
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
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			--AND
			--t.message_type = '0220'---eseosa
			AND
			t.tran_completed = 1
			--and t.rsp_code_rsp = '00'  ---eseosa
			and t.pos_entry_mode in ( '010','000')--eseosa
			and t.tran_reversed = '0' --eseosa
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Voice_Auth_monthly]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b06_Voice_Auth_monthly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
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
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
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
	SET @date_selection_mode = 'Previous month'

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type = '0220'---eseosa
			AND
			t.tran_completed = 1
			and t.rsp_code_rsp = '00'  ---eseosa
			and t.pos_entry_mode in ( '010','000')--eseosa
			and t.tran_reversed = '0' --eseosa
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Voice_Auth]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b06_Voice_Auth]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@show_full_pan	 	INT,		-- 0/1/2: Masked/Clear/As is
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
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
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start)
			AND
			(t.recon_business_date <= @report_date_end)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type = '0220'---eseosa
			AND
			t.tran_completed = 1
			and t.rsp_code_rsp = '00'  ---eseosa
			and t.pos_entry_mode in ( '010','000')--eseosa
			and t.tran_reversed = '0' --eseosa
			AND
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA Local_Issuing_Detail]    Script Date: 05/26/2016 15:50:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA Local_Issuing_Detail]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@TotalsGroup VARCHAR(30)
AS
BEGIN

			SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
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
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (255),
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
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20),
		totals_group                    varchar(40),
		from_account_id				VARCHAR (30)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC

		
	CREATE TABLE #list_of_TotalsGroup(TotalsGroup	VARCHAR(30)) 
	
	INSERT INTO  #list_of_TotalsGroup EXEC osp_rpt_util_split_nodenames @TotalsGroup

	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			t.pan,
			t.terminal_id,
			t.card_acceptor_id_code,
			t.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			t.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(t.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code,
			t.totals_group,
			t.from_account_id

				
	FROM
		post_tran_summary t (nolock)
				
	WHERE 			
			
				t.tran_completed = '1'
				AND

				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				--and t.totals_group <> 'OtherVisaGroup'
				and t.pan like '4%'
				and substring(t.terminal_id,2,3) = '070'
				and t.tran_type = '01'
				and t.settle_currency_code = '566'
				and @TotalsGroup = left(totals_group,3)--FROM #list_of_totalsgroup)
			OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local
			OPTION (MAXDOP 8)

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA Local Acquiring Billing_test]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA Local Acquiring Billing_test]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@TotalsGroup VARCHAR(30)
AS
BEGIN

			SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
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
		rsp_code_description		VARCHAR (255),
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
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20),
		totals_group                    varchar(40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC

		
	CREATE TABLE #list_of_TotalsGroup(TotalsGroup	VARCHAR(30)) 
	
	INSERT INTO  #list_of_TotalsGroup EXEC osp_rpt_util_split_nodenames @TotalsGroup

	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT


	IF(@report_date_start<> @report_date_end) BEGIN
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	
	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code,
			c.totals_group

				
	FROM
				post_tran t (NOLOCK) 
				JOIN
				
				post_tran_cust c (NOLOCK)
				ON
			t.post_tran_cust_id = c.post_tran_cust_id
			
				
				
	WHERE 			
			
				t.tran_completed = '1'
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				--and c.totals_group <> 'OtherVisaGroup'
				and c.pan like '4%'
				and substring(c.terminal_id,2,3) = '070'
				and t.tran_type = '01'
				and t.settle_currency_code = '566'
				and @TotalsGroup = left(totals_group,3)--FROM #list_of_totalsgroup)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END






























































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA Local Acquiring Billing_All]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA Local Acquiring Billing_All]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
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
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (255),
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
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20),
		totals_group                    varchar(40),
		tran_reversed               INT,
		source_node_name  VARCHAR (40)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC

	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			t.pan,
			t.terminal_id,
			t.card_acceptor_id_code,
			t.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			t.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(t.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code,
			t.totals_group,
			t.tran_reversed,
			t.source_node_name

				
	FROM
	   post_tran_summary t (NOLOCK)
				
	WHERE 			
			
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				and t.totals_group <> 'OtherVisaGroup'
				and t.pan like '4%'
				and substring(t.terminal_id,2,3) = '070'
				and t.tran_type = '01'
				and t.settle_currency_code = '566'
				OPTION  (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 ABS(settle_tran_fee_rsp)as fee_group,
		 left(totals_group,3) as totals_group,
		 sum(settle_tran_fee_rsp) as fee,
		 sum(settle_amount_impact)* -1 as amount,
		SUM(CASE			
                	WHEN tran_type = '01' and message_type in ('0100','0200','0220') and rsp_code_rsp = '00' and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type = '01' and message_type = '0420' and rsp_code_rsp = '00' and tran_reversed = 1 THEN 1
                	WHEN tran_type = '01' and message_type in ('0100','0200','0220') and rsp_code_rsp = '00' and tran_reversed = 2 THEN 0 
            		WHEN tran_type = '01' and message_type = '0420' and rsp_code_rsp = '00' and tran_reversed = 2 THEN 0 
            		END) as tran_count
	
	FROM
			@report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, totals_group
	ORDER BY 
			source_node_name
	OPTION (MAXDOP 8)
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA International Acquiring Billing_All]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO







ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA International Acquiring Billing_All]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	 SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
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
		rsp_code_description		VARCHAR (255),
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
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20)
		--isforeignFinancial0200		INT,
		--islocalfinancial0200		INT,
		--islocalfinancial0200TrxNOTCashWdrl		INT
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC
	
	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			t.pan,
			t.terminal_id,
			t.card_acceptor_id_code,
			t.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			t.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(t.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code
			--dbo.fn_rpt_isforeignfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as isforeignfinancial0200,
			--	dbo.fn_rpt_islocalfinancial0200Trx(t.message_type,t.tran_amount_req,t.rsp_code_rsp, t.card_acceptor_name_loc) as islocalfinancial0200,
			--	dbo.fn_rpt_islocalfinancial0200TrxNOTCashWdrl(t.message_type,t.tran_amount_req,t.rsp_code_rsp,t.card_acceptor_name_loc,t.tran_type) as islocalfinancial0200TrxNOTCashWdrl

				
	FROM

		post_tran_summary t (NOLOCK)
			
		where 			
			
				t.tran_completed = '1'
				AND
				
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND t.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				and t.totals_group like '%OtherVisaGroup%'
				and t.pan like '4%'
				and t.tran_type in ('01','31')
				OPTION (RECOMPILE)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
         tran_type,
		 sum(isnull(settle_amount_impact * -1,0))  as amount,
		 sum(1) as tran_count,
                   settle_currency_code,
                   --source_node_name,
                 (CASE WHEN rsp_code_rsp in ('00','08', '10', '11', '16') then 1 
                      else 0 end) as success_status,
                       islocalAcqTrx,
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr,
		TranID,
		prev_post_tran_id
		--isforeignfinancial0200,
		--islocalfinancial0200,
		--islocalfinancial0200TrxNOTCashWdrl
		
		FROM 
			@report_result
Group by startdate, enddate, tran_type,settle_currency_code,rsp_code_rsp,islocalAcqTrx,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,TranID,prev_post_tran_id
 OPTION (MAXDOP 8)
        
	END

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_VISA International Acquiring Billing]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO











ALTER PROCEDURE [dbo].[osp_rpt_b06_VISA International Acquiring Billing]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

			SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
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
		rsp_code_description		VARCHAR (255),
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
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		acquiring_inst_id_code VARCHAR(20)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report date

	
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR (30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR (30), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC

		

	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT


	IF(@report_date_start<> @report_date_end) BEGIN
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
	SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	
	
	INSERT
				INTO @report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR (30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR (30), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			t.acquiring_inst_id_code

				
	FROM
				post_tran t (NOLOCK) 
				JOIN
				
				post_tran_cust c (NOLOCK)
				ON
			t.post_tran_cust_id = c.post_tran_cust_id
			
				
				
	WHERE 			
			
				t.tran_completed = '1'
				AND
(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				AND c.source_node_name not in ('ASPSPNTFsrc','ASPSPONUSsrc')
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
					)
				)
				
				--and t.acquiring_inst_id_code = '447118'
				and c.totals_group like '%OtherVisaGroup%'
				and c.pan like '4%'
				and t.tran_type = '01'
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			@report_result
	ORDER BY
			datetime_tran_local

        
	END






























































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Terminal_settle_currency]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE[dbo].[osp_rpt_b06_Terminal_settle_currency]--oremeyi modified the previous
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@terminalID		VARCHAR(40),	
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


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
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
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
	SET @node_name_list = @SourceNode
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
			dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
			t.terminal_id, -- oremeyi added this
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
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
	  post_tran_summary  t (NOLOCK)
	WHERE 		
			t.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.recon_business_date >= @report_date_start) 
			AND 
			(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 1 
			AND
			t.message_type IN ('0100','0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40')	
			AND
			( 
			t.source_node_name = @SourceNode
			OR
			substring (t.terminal_id,1,4)=substring (@terminalID,1,4)
			)
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk')
			OPTION (RECOMPILE)
	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			#report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
			OPTION (MAXDOP 8)
	
END


































































































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Terminal]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b06_Terminal]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@terminalID		VARCHAR(40),	
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

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),	
		StartDate					VARCHAR(30),
		EndDate						VARCHAR(30),
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
		rsp_code_description	VARCHAR (200),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
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
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
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

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	

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
		
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		

	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @report_date_start  AND recon_business_date >=  @report_date_start   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end ) ORDER BY datetime_req DESC)
	     SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start   AND recon_business_date >= @report_date_start     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @report_date_start  AND (recon_business_date >= @report_date_start )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @report_date_end  AND (recon_business_date < @report_date_end ) ORDER BY recon_business_date DESC)
		
		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @report_date_start AND (recon_business_date >= @report_date_start )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @report_date_end AND (recon_business_date < @report_date_end  ) ORDER BY datetime_req DESC)
	END
	
	
	INSERT
			INTO @report_result

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
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
			post_tran t (NOLOCK, INDEX(ix_post_tran_2))
			INNER JOIN 
			post_tran_cust c (NOLOCK, INDEX(pk_post_tran_cust)) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
			t.tran_completed = 1
			AND
			(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			t.message_type IN ('0100','0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40')	
			AND
			( 
			c.source_node_name = @SourceNode
			OR
			substring (c.terminal_id,1,4)=substring (@terminalID,1,4)
			)
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTCTLsnk')

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			@report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_settle_currency]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_settle_currency]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B06 report uses this stored proc.

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR (30),
		EndDate						VARCHAR (30),
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
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
	)

	

	
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT
	
	DECLARE  @list_of_source_nodes TABLE(source_node	VARCHAR(30)) 
	
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNode, ',')
	

	INSERT
			INTO @report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(VARCHAR(30), @report_date_start, 112) as StartDate,
			CONVERT(VARCHAR(30),  @report_date_end, 112) as EndDate,
			t.pan,
			t.terminal_id,
			t.card_acceptor_name_loc,
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			t.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran_summary t (NOLOCK)
	WHERE
			t.tran_completed = 1
			AND
								(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
			AND
			t.tran_postilion_originated = 1
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)
			OPTION (RECOMPILE)

	IF @@ROWCOUNT = 0
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	

	SELECT *
	FROM
			@report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_REGION]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b06_REGION]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(1050),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
		terminal_id					varchar (8),
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
		rsp_code_description	VARCHAR (200),
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
		islocalAcqTrx		INT,  -- added by eseosa on 17th
		network_stan		varchar (8),
		Region				varchar(10)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
			c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
			t.sink_node_name,
			t.tran_type,
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp,
			dbo.fn_rpt_islocalAcqTrx(c.pan) as islocalAcqTrx,
			dbo.mc_stan(t.tran_nr) as network_stan,
			dbo.fn_rpt_getRegion_Acquirer(pan) as Region

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK)
				
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0
				AND
				(
				(t.message_type IN ('0100','0200','0220','0420', '0400')) 
				)
				
				          
				
				AND
				(
					@SourceNodes IS NULL
					OR
					(
						@SourceNodes IS NOT NULL
						AND
						c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
					)
				)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT
			*
	FROM
			#report_result
	ORDER BY
			datetime_tran_local

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_monthly]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_monthly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@SinkNode		VARCHAR(40),
	@Period			VARCHAR(20),
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
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
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
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
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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
			isnull(t.rsp_code_rsp,'99'),
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
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
			c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
			AND
			(@SinkNode IS NULL or t.sink_node_name = @SinkNode)

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_TEST]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO














ALTER PROCEDURE [dbo].[osp_rpt_b06_CUP_TEST]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
        @CBN_Code CHAR(3),
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
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
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
	SET @node_name_list = @sourcenode
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



	CREATE TABLE #list_of_source_nodes (source_node_name VARCHAR(40)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNode
	
        CREATE TABLE #list_of_CBN_Codes (CBN_Codes VARCHAR(40)) 
	INSERT INTO  #list_of_CBN_Codes EXEC osp_rpt_util_split_nodenames @CBN_Code

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
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		
			c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			--t.post_tran_cust_id >= '170126684'	
			
			AND
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
			tran_type IN ('01','40','31')	
			AND
			
			(c.source_node_name IN (SELECT source_node_name FROM #list_of_source_nodes)
                        or substring (c.terminal_id,2,3) in (SELECT CBN_Codes from #list_of_CBN_Codes))
			
			AND
			(terminal_id not like '2%')
                          AND
			t.sink_node_name = 'CUPsnk'

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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_Summary_SAM]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_CUP_Summary_SAM]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

--SET FMTONLY OFF
--GO
	                                                                                             
AS
BEGIN
	


If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
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
		rsp_code_description	VARCHAR (200),
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
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			c.pan AS pan,
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
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)


	WHERE 		c.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id not like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   StartDate,
		 EndDate,
		 
                 tran_type,
		 sum(settle_amount_impact) as Total_amount,
		count(settle_amount_impact) as Total_Count,
                source_node_name,
                substring(terminal_id,2,3) as CBN_Code

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type, substring(terminal_id,2,3)
	ORDER BY 
			source_node_name
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_Summary_POS]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b06_CUP_Summary_POS]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date   DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
    SET NOCOUNT ON

If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
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
		rsp_code_description	VARCHAR (200),
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
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			t.pan AS pan,
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
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
		 post_tran_summary t (NOLOCK)
	WHERE 		
			t.tran_completed = 1
			 AND (t.recon_business_date  >= @from_date 
			 AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('00')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			OPTION (RECOMPILE)
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   StartDate,
		 EndDate,
		 
                 tran_type,
		 sum(settle_amount_impact)as total_amount,
		count(settle_amount_impact) as total_count,
                source_node_name,
                substring(terminal_id,2,3) as CBN_Code

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type,substring(terminal_id,2,3)
	ORDER BY 
			source_node_name
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_Summary]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[osp_rpt_b06_CUP_Summary]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON


If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
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
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (255),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			t.pan AS pan,
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
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
    post_tran_summary t (NOLOCK)
	WHERE 		t.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id not like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			OPTION(RECOMPILE)	
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   StartDate,
		 EndDate,
		 
                 tran_type,
		 sum(settle_amount_impact) as Total_amount,
		count(settle_amount_impact) as Total_Count,
                source_node_name,
                substring(terminal_id,2,3) as CBN_Code

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type, substring(terminal_id,2,3)
	ORDER BY 
			source_node_name
END


/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_all_POS]    Script Date: 05/17/2016 16:30:13 ******/
SET ANSI_NULLS ON

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_all_POS]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b06_CUP_all_POS]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

	
AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON
	


If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
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
		rsp_code_description	VARCHAR (255),
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
		retention_data				Varchar(999)
	)			

	




	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			t.pan AS pan,
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
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran_summary t (NOLOCK)
	WHERE 		t.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('00')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id  like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			OPTION (RECOMPILE)
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   *

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	--GROUP BY
			--StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type
	ORDER BY 
			source_node_name
END


/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing]    Script Date: 05/17/2016 16:30:05 ******/
SET ANSI_NULLS ON

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP_all]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO














CREATE
                                                           PROCEDURE [dbo].[osp_rpt_b06_CUP_all]
	@Start_Date DATETIME=NULL,	-- yyyymmdd
	@End_Date    DATETIME=NULL,	-- yyyymmdd
	@rpt_tran_id INT = NULL

	
AS
BEGIN
 SET TRANSACtiON ISOLATION LEVEL READ UNCOMMITTED;
 SET NOCOUNT ON

If @start_date is null 
set @start_date = dbo.DateOnly(getdate()-1)

If @end_date is null 
set @end_date = dbo.DateOnly(getdate()-1)
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (11),  
		EndDate						CHAR (11),
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
		rsp_code_description		VARCHAR (255),
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
		retention_data				Varchar(999)
	)			


	


	EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 


	IF (@to_date < @from_date)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM #report_result
		RETURN 1
	END

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			convert ( char(11),@start_date) as StartDate,  
			convert ( char(11),@end_date) as EndDate,
			t.pan AS pan,
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
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
			
	FROM
			post_tran_summary t (NOLOCK)
	WHERE 		t.post_tran_cust_id >= @rpt_tran_id
			AND
			t.tran_completed = 1
			

                        AND (t.recon_business_date  >= @from_date AND t.recon_business_date < (@to_date+1))
			AND			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')
			AND
			rsp_code_rsp IN ('11','00')
			
			AND
			(terminal_id not like '2%')

                         AND
			t.sink_node_name = 'CUPsnk'
			option (RECOMPILE)
			
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @from_date, @to_date)
			


SELECT   *

	
	FROM
			#report_result

where (message_type in ( '0200','0100') and tran_reversed IN(0,1)) or ( message_type = '0420' and tran_reversed = 1)
	--GROUP BY
			--StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name, tran_type
	ORDER BY 
			source_node_name
END











GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_CUP]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






ALTER PROCEDURE [dbo].[osp_rpt_b06_CUP]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),		-- yyyymmdd
	@SourceNode		VARCHAR(40),
        @CBN_Code CHAR(3),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL
	
AS
BEGIN
	-- The B06 report uses this stored proc.
			SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),	
		StartDate					VARCHAR(30),	 
		EndDate						VARCHAR(30),	
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
		rsp_code_description		VARCHAR (255),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_description		VARCHAR (60),	
		tran_reversed				INT,	
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
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	

	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = @sourcenode
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	--EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END
	 IF (@StartDate IS NULL OR @StartDate ='')
	BEGIN 
			SELECT @StartDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		IF (@EndDate IS NULL OR @EndDate ='') 
		BEGIN 
			SELECT @EndDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END

		SELECT @report_date_start = CONVERT(DATETIME, REPLACE(@StartDate, '-', ''));
		SELECT @report_date_end = CONVERT(DATETIME, REPLACE(@EndDate, '-', '')); 


	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	

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



	DECLARE  @list_of_source_nodes TABLE(source_node_name VARCHAR(40)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string( @SourceNode,',') ORDER BY PART ASC
	
    DECLARE  @list_of_CBN_Codes TABLE(CBN_Codes VARCHAR(40)) 
	INSERT INTO  @list_of_CBN_Codes SELECT part FROM usf_split_string( @CBN_Code,',')ORDER BY PART ASC

	INSERT
			INTO @report_result

	SELECT	 top 1000
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			t.recon_business_date,--oremeyi added this 24/02/2009
			dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
			t.terminal_id, -- oremeyi added this
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
			
			t.tran_reversed,
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data
	FROM
		 post_tran_summary t (NOLOCK)
	WHERE 		
			--'81530747'	
		
			t.tran_completed = 1	
			AND
			(LEFT(terminal_id,1) <> '2')
                          AND
			t.sink_node_name = 'CUPsnk'
				AND
			(t.source_node_name IN (SELECT source_node_name FROM @list_of_source_nodes)
                        OR substring (t.terminal_id,2,3) in (SELECT CBN_Codes from @list_of_CBN_Codes))
			AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
			AND 
			t.tran_postilion_originated = 0 
			AND
			(LEFT(t.message_type,2) IN ('01','02','04')) --- oremeyi removed 0100, 0120
			AND 
			t.tran_completed = 1 
			AND
			tran_type IN ('01','40','31')	
			OPTION (RECOMPILE)
			

	--ORDER BY	terminal_id, datetime_tran_local, sink_node_name
		
	IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
		
		
	SELECT *
	FROM
			@report_result
	ORDER BY 
			terminal_id,datetime_tran_local, sink_node_name
	
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Eloho_Test]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Eloho_Test]--oremeyi modified the previous
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
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
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
		rsp_code_description	VARCHAR (255),
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
		retention_data				Varchar(999),
                Late_Reversal                          CHAR (1)
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
			
			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			t.retention_data,
			Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id) THEN 1
						ELSE 0
					        END
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE 		c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
			AND
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
			tran_type IN ('01','40')
			AND
			rsp_code_rsp IN ('00','11','08','10','16')
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
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk','VAUMOsnk')
			AND
			(terminal_id not like '2%')
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
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) as tran_count

	
	FROM
			#report_result
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Detailed_verve_int-test]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b06_all_Detailed_verve_int-test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(40),
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
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		CHAR (15), 
		card_acceptor_name_loc		CHAR (40), 
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2),
		acquiring_inst_id_code		VARCHAR (225),
		rsp_code_rsp				CHAR (2), 
		message_type				CHAR (4), 
		datetime_req				DATETIME, 		
		settle_amount_req			FLOAT, 
		settle_amount_rsp			FLOAT, 
		settle_tran_fee_rsp			FLOAT, 
		Tran_amount_rsp				FLOAT,
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
		rsp_code_description		VARCHAR (255),
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
		retention_data				Varchar(999)
	)			

	IF (@SinkNode IS NULL or Len(@SinkNode)=0)
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

	
	INSERT
			INTO #report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
			c.terminal_id,
			c.terminal_owner,
                        c.source_node_name, 
			c.card_acceptor_id_code, 
			c.card_acceptor_name_loc, 
			t.sink_node_name, 
			t.tran_type, 
			t.acquiring_inst_id_code,
			t.rsp_code_rsp, 
			t.message_type, 
			t.datetime_req, 

			dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
			dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
			dbo.formatAmount(-1 * t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
			dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS Tran_amount_rsp,

			t.post_tran_cust_id as TranID, 
			t.prev_post_tran_id, 
			t.system_trace_audit_nr, 
			t.message_reason_code, 
			t.retrieval_reference_nr, 
			t.datetime_tran_local, 
			t.from_account_type, 
			t.to_account_type, 
			t.tran_reversed,	
			--t.tran_amount_rsp,		
			t.settle_currency_code, 
			
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
			isnull(t.retention_data,0)
			
	FROM

			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
            --left join 
            --post_tran tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                         -- tt.tran_postilion_originated = 1
                                          --and t.tran_nr = tt.tran_nr)
	
WHERE 		c.post_tran_cust_id >= @rpt_tran_id
            AND
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
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
		
		
             AND
             t.sink_node_name  = 'MEGASWTsnk'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--c.terminal_id like '1%'
			
	--insert into 		
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
	
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_visa]    Script Date: 05/26/2016 15:50:23 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b04_web_pos_acquirer_visa]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3) -- included by eseosa to specify currency
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MGASPVGTBsrc'
	SET @date_selection_mode = @Period
			
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
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_uba_visa_acquiring]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_uba_visa_acquiring]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3) -- included by eseosa to specify currency
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE   @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(25),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (512),	 
		card_acceptor_name_loc	CHAR (999), 
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		VARCHAR(max),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
		--tran_tran_fee_rsp		INT,     --sopeju added this
		--merchant_service_charge	INT,	 --sopeju added this
		--tran_amount_rsp			INT		 --sopeju added this
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET  @StartDate= CONVERT(CHAR(8),@report_date_start  , 112)
	SET @EndDate= CONVERT(CHAR(8), @report_date_end , 112)

--	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')	   	SELECT * FROM @report_result
		RETURN 1
	END*/
		DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM dbo.usf_split_string (@SourceNodes, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM dbo.usf_split_string (@IINs, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM dbo.usf_split_string (@merchants, ',') ORDER BY part ASC; 
	-- Only look at 02xx messages that were not fully reversed.
	

DECLARE @first_post_tran_id BIGINT

		DECLARE @last_post_tran_id BIGINT

		EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT
	-- Only look at 02xx messages that were not fully reversed.
	print @first_post_tran_id 

		print @last_post_tran_id 
		print @report_date_start 
		print @report_date_end 
	INSERT
				INTO @report_result
	SELECT 
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
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
				--t.tran_tran_fee_rsp,
				--t.tran_amount_rsp,
				--merchant_service_charge,
				
				
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

	
				
	FROM
		 post_tran t (nolock)
		 JOIN post_tran_cust c (nolock)
			ON t.post_tran_cust_id = c.post_tran_cust_id
		LEFT JOIN tbl_merchant_account a (NOLOCK)
			ON c.card_acceptor_id_code = a.card_acceptor_id_code		
				
	WHERE 			
				
				t.tran_completed = '1'
                 AND
							(t.post_tran_id >= @first_post_tran_id) 
			AND 
			datetime_req >=@report_date_start
			AND
			
			(t.post_tran_id <= @last_post_tran_id) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				LEFT(t.message_type,2) = '02' 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				--AND
				--(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name =  @SourceNodes
				-- IN (SELECT source_node FROM @list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END

















GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_settle_currency]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_settle_currency]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	

	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
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
				--AND
				--(
				--(t.message_type IN ('0100')) --- changed from 0220 to 0110 to pick settlement amt in settlement currency
				--)
				AND 
				t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_rates_msc]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_rates_msc]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

	SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABlE   #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		VARCHAR(15)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABlE   #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABlE   #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
	CREATE TABlE   #list_of_card_acceptor_id_codes (card_acceptor_id_code	VARCHAR(15)) 
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
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
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				e.merchant_service_charge

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK),
				merchant_msc_table e (NOLOCK)
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				c.card_acceptor_id_code = e.card_acceptor_id_code
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_rates_3]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_rates_3]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	     VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
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

	
	DECLARE @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT PART FROM usf_split_string(@SourceNodes, ',')
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT PART FROM usf_split_string(@IINs, ',')
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT PART FROM usf_split_string(@merchants, ',')
	-- Only look at 02xx messages that were not fully reversed.
		DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  (datetime_req >=@report_date_start)   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   (datetime_req < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE (datetime_req >=@report_date_start)  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE (datetime_req < @report_date_end) ORDER BY datetime_req DESC)
	END
	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
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
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
						 post_tran t (nolock, INDEX(ix_post_tran_2 ))
		LEFT JOIN  post_tran_cust c (nolock,INDEX(pk_post_tran_cust))
		ON t.post_tran_cust_id = c.post_tran_cust_id
		LEFT JOIN
				tbl_merchant_account a (NOLOCK, INDEX(card_acceptor_id_code_idx))
			ON	c.card_acceptor_id_code = a.card_acceptor_id_code
	WHERE 			
					
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				t.tran_completed = '1'
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
				tran_amount_rsp > 0
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_rates_2]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_rates_2]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6),
	@currency	VARCHAR(5)	

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	set @currency	= isnull(@currency, '566');
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
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
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = @currency
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_rates]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_rates]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate	     VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the t.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

		SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
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
	
	DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART asc
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM usf_split_string(@IINs, ',') ORDER BY PART asc
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants, ',') ORDER BY PART asc
	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE t.source_node_name
				END),
				*/
				t.source_node_name,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				t.terminal_owner,
				t.merchant_type,
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
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
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
		post_tran_summary t (NOLOCK)
		LEFT	JOIN
			tbl_merchant_account a (NOLOCK)
			ON	t.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			
				
				t.tran_completed = '1'
				AND
						
	
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				
			
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR t.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND 
				tran_amount_rsp >0
				option (recompile)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_NGN]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_NGN]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
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

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30), 
		EndDate					VARCHAR(30),
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		dollar_amount			FLOAT(10),
		RATE				varchar(50)
		
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	SET @StartDate =  REPLACE(CONVERT(VARCHAR(10),@report_date_start,111),'/', '-') 
	SET @EndDate = REPLACE(CONVERT(VARCHAR(10),@report_date_end,111),'/', '-') 

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

	DECLARE  @list_of_source_nodes  TABLE(source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string( @SourceNodes, ',');
	
	DECLARE  @list_of_IINs TABLE (IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM usf_split_string( @IINs, ',');
	
	DECLARE  @list_of_card_acceptor_id_codes  TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants, ',');
	-- Only look at 02xx messages that were not fully reversed.
	
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=@report_date_start  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req < @report_date_end  ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=CONVERT(DATETIME,@report_date_start)  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req < CONVERT(DATETIME,@report_date_end)  ORDER BY datetime_req DESC)
	END
	
	INSERT
				INTO @report_result
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / (select round (rate,2) from tm_currencies
					where currency_code = 566 ))/100 AS settle_currency_amount,
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
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				(t.tran_amount_rsp / (select round (rate,2) from tm_currencies
					where currency_code = 566 ))/100 AS dollar_amount,
				(t.tran_amount_rsp)/(t.tran_amount_rsp / (select round (rate,2) from tm_currencies
					where currency_code = 566 )) AS RATE

				
	FROM
		 post_tran t (nolock, INDEX(ix_post_tran_2 ))
		, post_tran_cust c (nolock,INDEX(pk_post_tran_cust))
				,		tbl_merchant_account a (NOLOCK, INDEX(card_acceptor_id_code_idx))				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_new]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_new]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				--t.post_tran_cust_id = c.post_tran_cust_id
				--AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				t.tran_reversed = '0'
				--AND 
				--t.tran_completed = 1 
				
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_naira_msc_apply]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_naira_msc_apply]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		VARCHAR(15)--adeola added 27/09/2013
	)

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
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
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
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				e.merchant_service_charge
				
				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK),
				merchant_msc_table e (NOLOCK)
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'--reoved by eseosa 020611 it caused ommission of trns	
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
				(t.message_type IN ('0220','0200')) 
				)
				AND
				settle_currency_code = '566'
				AND 
				t.tran_completed = '1' 
				AND
				t.tran_reversed = '0' -- included by eseosa -- exclude reversals

				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND
				c.card_acceptor_id_code = e.card_acceptor_id_code
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_naira_FBN]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_naira_FBN]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  		CHAR(25),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (100),
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
		structured_data_req		TEXT,
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(12),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

	
	SET @StartDate =  REPLACE(CONVERT(VARCHAR(10),@report_date_start,111),'/', '-') 
	SET @EndDate = REPLACE(CONVERT(VARCHAR(10),@report_date_end,111),'/', '-') 
	
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

	DECLARE   @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs  SELECT part FROM usf_split_string(@IINs, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants, ',') ORDER BY part ASC;
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
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
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_naira]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_naira]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the t.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@rate		FLOAT(6)	

AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate					VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  		CHAR(25),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT,
		settle_currency_amount		FLOAT,		
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (100),
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
		structured_data_req		TEXT,
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(12),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
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

	DECLARE   @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs  SELECT part FROM usf_split_string(@IINs, ',') ORDER BY part ASC;
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE (card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants, ',') ORDER BY part ASC;
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE t.source_node_name
				END),
				*/
				t.source_node_name,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				t.terminal_owner,
				t.merchant_type,
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_response,
				t.tran_currency_code,
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				(tran_amount_rsp / @rate) AS settle_currency_amount,
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
			
				--dbo.formatAmount(t.tran_amount_rsp * 150) AS tran_settle_value,
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				 post_tran_summary t (NOLOCK) LEFT join
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			
					t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				tran_currency_code = '566'
				
				AND
				t.tran_reversed = '0'
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR t.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END


/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_aborted_completion]    Script Date: 05/17/2016 16:30:17 ******/
SET ANSI_NULLS ON

GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_msc2_old]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_msc2_old]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3), -- included by eseosa to specify currency
	@local_msc		NUMERIC(18,4), 		-- Included by eseosa on 9/07/13 to specify msc based on card brands
	@foreign_msc	NUMERIC(18,4)			-- saa
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		tran_amount_req		FLOAT, 
		tran_amount_rsp		FLOAT,
		tran_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		tran_currency_code	CHAR (3),				
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		tran_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		NUMERIC(18,4)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
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
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.tran_tran_fee_rsp, t.tran_currency_code) AS tran_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code, 
				
				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.tran_currency_code) AS tran_nr_decimals,
				dbo.currencyAlphaCode(t.tran_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				case ((select top 1 country_numeric from mcipm_ip0040t1 (nolock) where substring (issuer_acct_range_low,1,6) = substring (c.pan,1,6))union (select top 1 country_numeric from visa_bin_table (nolock) where substring (issuer_acct_range_low,1,6) = substring (c.pan,1,6))) when '566' then @local_msc else @foreign_msc end as merchant_service_charge
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				t.rsp_code_req = '00'
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_amount_req != '0'
				and
				t.tran_currency_code = @currency_code

				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_msc1_old]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_msc1_old]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3), -- included by eseosa to specify currency
	@local_msc		NUMERIC(18,4), 		-- Included by eseosa on 9/07/13 to specify msc based on card brands
	@foreign_msc	NUMERIC(18,4)			-- saa
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		tran_amount_req		FLOAT, 
		tran_amount_rsp		FLOAT,
		tran_tran_fee_rsp		FLOAT,				
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2), 
		tran_currency_code	CHAR (3),				
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
		tran_nr_decimals		INT,
		currency_alpha_code		CHAR (3),
		currency_name			VARCHAR (20),		
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		NUMERIC(18,4)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
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
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.tran_tran_fee_rsp, t.tran_currency_code) AS tran_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code, 
				
				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.tran_currency_code) AS tran_nr_decimals,
				dbo.currencyAlphaCode(t.tran_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				case (select top 1 country_numeric from mcipm_ip0040t1 (nolock) where substring (issuer_acct_range_low,1,6) = substring (c.pan,1,6)) when '566' then @local_msc else @foreign_msc end as merchant_service_charge

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_msc]    Script Date: 05/26/2016 15:50:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_msc]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the t.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3), -- included by eseosa to specify currency
	@local_msc		NUMERIC(18,2), 		-- Included by eseosa on 9/07/13 to specify msc based on card brands
	@foreign_msc	NUMERIC(18,2)			-- saa
AS
BEGIN

	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(2000),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		merchant_service_charge		NUMERIC(18,2)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
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


	 DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string(@SourceNodes,',') ORDER BY part ASC

	DECLARE  @list_of_IINs  TABLE(IIN VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM usf_split_string(@IINs,',') ORDER BY part ASC 

	DECLARE  @list_of_card_acceptor_id_codes  TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string(@merchants,',') ORDER BY part ASC 
	-- Only look at 02xx messages that were not fully reversed.
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE t.source_node_name
				END),
				*/
				t.source_node_name,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				t.terminal_owner,
				t.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				case (select top 1 country_numeric from mcipm_ip0040t1 (nolock) where LEFT (issuer_acct_range_low,6) = LEFT (t.pan,6)) when '566' then @local_msc else @foreign_msc end as merchant_service_charge

				
	FROM
			    post_tran_summary t (NOLOCK)
				LEFT JOIN
				tbl_merchant_account a (NOLOCK)
				ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
	WHERE 			
				t.tran_completed = '1'
				AND
					
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 			
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR t.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				OPTION (RECOMPILE)
				
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
			OPTION (MAXDOP  8)
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_monthly]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_monthly]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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
	

	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_gtb_naira]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_gtb_naira]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(4), -- included by eseosa to specify currency
	@rate			numeric
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
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
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount((t.settle_amount_req/@rate), t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount((t.settle_amount_rsp/@rate), t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount((t.settle_tran_fee_rsp/@rate), t.settle_currency_code) AS settle_tran_fee_rsp,
				
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
						WHEN (t.tran_type = '51') THEN -1 * (t.settle_amount_impact/@rate)
						ELSE (t.settle_amount_impact/@rate)
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.settle_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_FBN]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_FBN]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME,
		tran_amount_rsp			FLOAT,
		tran_currency_code		FLOAT, 				
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				t.tran_currency_code,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				AND
				t.tran_reversed = '0'
				--AND 
				--t.tran_completed = 1 
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted_test]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted_test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255)
AS
BEGIN

	DECLARE
	 @IINs	VARCHAR(255),
	 @AcquirerInstId	VARCHAR(255)	,
	@merchants	VARCHAR(255)	 ,--this is the c.card_acceptor_id_code,
	 @show_full_pan	BIT  ,
	 @report_date_start DATETIME,
	@report_date_end DATETIME,
	@rpt_tran_id INT	

	
	
	

SET NOCOUNT ON
	
	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				--mcipm_extract_trans m (nolock)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				--and m.post_tran_id = t.post_tran_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				AND t.post_tran_id not in (select post_tran_id from mcipm_extract_trans)
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
 	and @IINs = NULL	
	and @AcquirerInstId = NULL		
	and @merchants = NULL	--this is the c.card_acceptor_id_code,
	and @show_full_pan = NULL	
	and @report_date_start = NULL 
	and @report_date_end = NULL 
	and @rpt_tran_id = NULL 	

					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_unextracted]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				--mcipm_extract_trans m (nolock)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				--and m.post_tran_id = t.post_tran_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				AND t.post_tran_id not in (select post_tran_id from mcipm_extract_trans)
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID
	FROM 
			#report_result
	ORDER BY 
			source_node_name, datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_omc]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa_omc]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
		card_acceptor_id_code	CHAR (15),	 
		card_acceptor_name_loc	CHAR (70), 
		source_node_name		VARCHAR (40), 
		sink_node_name			VARCHAR (40), 
		tran_type				CHAR (2), 
		rsp_code_rsp			CHAR (2), 
		message_type			CHAR (4), 
		datetime_req			DATETIME, 				
		tran_amount_req		FLOAT, 
		tran_amount_rsp		FLOAT,
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50),
		acquirer_ref_no			VARCHAR(50),
		service_restriction_code	VARCHAR(50),
		src				VARCHAR(50),
		pos_card_data_input_ability   VARCHAR(50),
		pos_card_data_input_mode      VARCHAR(50),
		ird				VARCHAR(50),
		fileid				VARCHAR(50),
		session_id			VARCHAR(50)
		
		
		
	)

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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
				c.card_acceptor_id_code, 
				c.card_acceptor_name_loc, 
				c.source_node_name,
				t.sink_node_name, 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req,
				dbo.formatAmount(t.tran_amount_req, t.tran_currency_code) AS tran_amount_req, 
				dbo.formatAmount(t.tran_amount_rsp, t.tran_currency_code) AS tran_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_cust_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type, 
				t.tran_currency_code,
				 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.tran_amount_req
						ELSE t.tran_amount_rsp
					END
					, t.tran_currency_code ) AS settle_amount_req,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
				dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


				dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				dbo.currencyName(t.tran_currency_code) AS currency_name,

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr,
				m.acquirer_ref_no,	
				service_restriction_code,
				SUBSTRING(service_restriction_code,1,1) as src,	
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				m.ird as ird,
				m.file_id as fileid,
				s.session_id
				
				
			
				
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK),
				mcipm_extract_trans m (nolock),
				mcipm_extract_transmission s (nolock)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				and m.post_tran_id = t.post_tran_id
				and s.transmission_nr = m.transmission_nr
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 1--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	
	SELECT 
				pan,				
				terminal_id,
				merchant_type,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				tran_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID,
				acquirer_ref_no,
				service_restriction_code,
				src,
				pos_card_data_input_ability,
				pos_card_data_input_mode,
				ird,
				session_id,
				fileid
				
				
				
			
				
				
	FROM 
			#report_result
	ORDER BY 
			datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_eseosa]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(255),	
	@IINs		VARCHAR(255)=NULL,
	@AcquirerInstId		VARCHAR (255)= NULL,
	@merchants		VARCHAR(512) = NULL,--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT = NULL ,
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(8),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning, EndDate) VALUES ('Please supply the Web channel source node name.','yes')
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
	SET @node_name_list = 'MEGAASPsrc'
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


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	CREATE TABLE #list_of_IINs (IIN	VARCHAR(30)) 
	INSERT INTO  #list_of_IINs EXEC osp_rpt_util_split_nodenames @IINs
	
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
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr
				
				

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--AND
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end)
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220')) 
				)
				--AND 
				--t.tran_completed = '1' 
				AND
				t.tran_reversed = '0'
				--AND
				--t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM #list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
				pan,				
				terminal_id,
				card_acceptor_id_code,
				card_acceptor_name_loc,
				message_type,
				datetime_req,
				system_trace_audit_nr,
				retrieval_reference_nr,
				settle_amount_req, 
				tran_type_desciption,
				rsp_code_description,
				currency_name,
				auth_id_rsp,
				account_nr ,
				TranID
	FROM 
			#report_result
	ORDER BY 
			datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_dollar]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_dollar]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the t.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods

AS
BEGIN

	SET NOCOUNT ON
	SET TRAnSACTION ISOLATION level READ UNCOMMITTED

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE   @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),  
		EndDate					VARCHAR(30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(11),
		terminal_owner  		CHAR(25),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		TEXT,
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	--EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)
		
		SELECT * FROM @report_result
		
		RETURN 1
	END

		IF (@StartDate IS NULL OR @StartDate ='') 
		BEGIN 
			SELECT @StartDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END
		IF (@EndDate IS NULL OR @EndDate ='') 
		BEGIN 
			SELECT @EndDate =REPLACE(CONVERT(VARCHAR(10), DATEADD(DD,-1, GETDATE()),111),'/', '') ; 
		END

		SELECT @report_date_start = CONVERT(DATETIME, REPLACE(@StartDate, '-', ''));
		SELECT @report_date_end = CONVERT(DATETIME, REPLACE(@EndDate, '-', '')); 

	--EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


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


	DECLARE  @list_of_source_nodes  TABLE(source_node	VARCHAR(30))
	INSERT INTO  @list_of_source_nodes SELECT part FROM usf_split_string( @SourceNodes,',')  ORDER BY PART ASC; 
	
	DECLARE  @list_of_IINs TABLE (IIN	VARCHAR(30) ) 
	INSERT INTO  @list_of_IINs SELECT part FROM usf_split_string( @IINs,',')ORDER BY PART ASC;
	
	DECLARE @list_of_card_acceptor_id_codes   TABLE  (card_acceptor_id_code	VARCHAR(15))
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM usf_split_string( @merchants,',') ORDER BY PART ASC; 
		

	
	INSERT
				INTO @report_result
	SELECT  
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE t.source_node_name
				END),
				*/
				t.source_node_name,
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				t.terminal_owner,
				t.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran_summary t (NOLOCK)
			  LEFT	JOIN
			    tbl_merchant_account a (NOLOCK, INDEX(card_acceptor_id_code_idx))
			    	ON
				t.card_acceptor_id_code = a.card_acceptor_id_code
				
				
	WHERE 			
							(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				--AND
				--t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				 (LEFT(t.message_type,2) = '02') 
				)
				AND
		tran_currency_code = '840'
	AND
				t.tran_reversed = '0'

				AND 
				t.tran_completed = 1 
				
			--	AND 
			--	(t.acquiring_inst_id_code = @AcquirerInstId)
			--	AND
			--	(@merchants IS NULL OR LEN(@merchants) = 0 OR t.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
--
			AND
			t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
			OPTION (RECOMPILE)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END


GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_CUP_towner_ptsp]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_CUP_towner_ptsp]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@Acquirer		VARCHAR(255),
	---@AcquirerInstId		VARCHAR(255),
	--@SinkNode		VARCHAR(255),
	--@SourceNodes	VARCHAR(512),
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			VARCHAR(20),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
               -- extended_tran_type_reward               CHAR (50),--Chioma added this 2012-07-03
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
	--extended_tran_type		CHAR (4),
		receiving_inst_id_code		VARCHAR(50),--oremeyi added this 2009-04-22
           --   rdm_amount                      float,
             --  Reward_Discount                 float,
              --  Addit_Charge                 DECIMAL(7,6),
              --  Addit_Party                 Varchar (10),
               -- Amount_Cap_RD               DECIMAL(9,0),
               -- Fee_Cap_RD               DECIMAL(9,0),
               -- Fee_Discount_RD          DECIMAL(9,7),
                Terminal_owner_code Varchar (4),
				ptsp_code			varchar (4)
	)

	--IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	--BEGIN	   
	   	--INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   --	SELECT * FROM #report_result
		--RETURN 1
	--END

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
	--SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = 'Last business day'
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN

		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

	--SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	--SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	--EXEC psp_get_rpt_post_tran_cust_id_NIBSS @report_date_start,@report_date_end,@rpt_tran_id1 OUTPUT 


	--IF (@report_date_end < @report_date_start)
--	BEGIN
	   --	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   --	SELECT * FROM #report_result
		--RETURN 1
	--END

	/*IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')

	   	SELECT * FROM #report_result
		RETURN 1
	END

*/

	--CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	--INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
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
                           --     extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				ISNULL(account_nr,'not available'),

				payee,--oremeyi added this 2009-04-22
				--extended_tran_type,
				receiving_inst_id_code,--oremeyi added this 2010-02-28
                              --  ISNULL(y.rdm_amt,0),
                              --  R.Reward_Discount,
                             --   R.Addit_Charge,
                             --   R.Addit_Party,
                              --  R.Amount_Cap,
                              --  R.Fee_Cap,
                              --  R.Fee_Discount,
                                tt.Terminal_code,
								tp.ptsp_code	
				
	FROM
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				left JOIN tbl_merchant_category m (NOLOCK)
				ON c.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON c.card_acceptor_id_code = a.card_acceptor_id_code   
				--left JOIN tbl_xls_settlement y (NOLOCK)

				--ON (c.terminal_id= y.terminal_id 
                                    --AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    --AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    --= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                --left JOIN Reward_Category r (NOLOCK)
                               -- ON y.extended_trans_type = r.reward_code
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id
							left JOIN tbl_ptsp tp (NOLOCK)
                                ON c.terminal_id = tp.terminal_id

	WHERE 			
				
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
			--AND
			--(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                   --      or 
                         --(substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'

						
								
				
								
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

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing_VISA]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO












ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing_VISA]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	VARCHAR(550),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @report_result TABLE
	(   
	       seq_num_id		BIGINT IDENTITY(1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	If @startdate is null 
set @report_date_start = dbo.DateOnly(getdate()-1)

If @enddate is null 
set @report_date_end = dbo.DateOnly(getdate()-1)




SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT PART FROM dbo.usf_split_string(@SourceNodes,',') ORDER BY PART ASC;
	
			DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		

	IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP  1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	
	
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp,
				account_nr

				
	FROM
				post_tran t (NOLOCK, INDEX(ix_post_tran_2) ),
					post_tran_cust c (NOLOCK, INDEX (pk_post_tran_cust)),
				tbl_merchant_account a (NOLOCK, INDEX(tbl_merchant_idx))
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				
				AND
				t.tran_completed = '1'
				AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
                 AND 		   	
            	t.post_tran_cust_id >= @first_post_tran_cust_id
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				
				AND
				t.tran_reversed = 0  -- eseosa 141010
                                
                                AND not( c.source_node_name = 'GTBMIGSsrc' and not t.settle_currency_code = '840')
				
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 isnull(settle_amount_impact * -1,0)  as amount,
		 isnull(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	
                        WHEN tran_type IN ('20') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN -1
                	WHEN tran_type IN ('20') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN -1

                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END,0) as tran_count,
                   settle_currency_code,
                  substring(terminal_id,1,1) as Terminal_type,
                   case when CHARINDEX('MIGS', source_node_name)>0 then 'MIGS'
                      when LEFT(source_node_name,6)='MGASPV'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 6),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   
                   else source_node_name end as Bank

	 
	FROM 
			@report_result

        
	END






































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing_investigate]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing_investigate]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SourceNodes	text,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON


	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(CHAR(8), @report_date_start, 112)
	SET @EndDate = CONVERT(CHAR(8), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	


	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
	
	
	
	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK),
				post_tran_cust c (NOLOCK),
				tbl_merchant_account a (NOLOCK)
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				
				AND
				t.tran_completed = '1'
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				t.tran_postilion_originated = 1
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				
				AND
				t.tran_reversed = 0  -- eseosa 141010
                                
				
				AND
				c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	

SELECT 
		 StartDate,
		 EndDate,
		 isnull(settle_amount_impact * -1,0)  as amount,
		 isnull(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	
                        WHEN tran_type IN ('20') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN -1
                	WHEN tran_type IN ('20') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN -1

                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END,0) as tran_count,
                   settle_currency_code,
                  substring(terminal_id,1,1) as Terminal_type,
                   case when source_node_name like '%MIGS%' then 'MIGS'
                   when source_node_name like 'MEGASP%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 6),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   when source_node_name like 'ADJ%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 3),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   else source_node_name end as Bank

	 
	FROM 
			#report_result

        
	END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing_details]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing_details]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SourceNodes	VARCHAR(4000),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	
AS
BEGIN

	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @report_result TABLE
	(
                seq_num_id		BIGINT IDENTITY(1,1) UNIQUE,
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30),
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (9), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
	)

	

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	

	SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
	SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	DECLARE  @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
	
	
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP (1) @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP (1) @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP (1) @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP (1) @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END



	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
				post_tran t (NOLOCK)
				JOIN 
				post_tran_cust c (NOLOCK)
				ON 
				t.post_tran_cust_id = c.post_tran_cust_id
			       LEFT JOIN
			     tbl_merchant_account a (NOLOCK)
				on c.card_acceptor_id_code = a.card_acceptor_id_code
				
	WHERE 			

				t.tran_completed = '1'
				AND

				t.tran_postilion_originated = 0
				AND
				(
				 (LEFT(t.message_type,2)  ='02') 
				)
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				AND
				t.tran_reversed = 0  -- eseosa 141010
                AND
				(t.post_tran_id >= @first_post_tran_id) 
				AND 
				(t.post_tran_id <= @last_post_tran_id)
                 AND 		   	
            	t.post_tran_cust_id >= @first_post_tran_cust_id
				AND 
				(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				
				AND              
				 t.settle_currency_code in ('566','840')
				OPTION(MAXDOP 12)
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	


		SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req

	 
	

        OPTION(MAXDOP 12)
	END










































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_billing]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_billing]
      @StartDate        VARCHAR(30),      -- yyyymmdd
      @EndDate          VARCHAR(30),-- yyyymmdd
      @SourceNodes      VARCHAR(4000),
      @show_full_pan    BIT,
      @report_date_start DATETIME = NULL,
      @report_date_end DATETIME = NULL,
      @rpt_tran_id INT = NULL,
      @Period                 VARCHAR(20)   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
      
AS
BEGIN

      SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

      DECLARE  @report_result TABLE
      (
                seq_num_id          BIGINT IDENTITY(1,1) UNIQUE,
            Warning                             VARCHAR (255),
            StartDate                     VARCHAR(30),
            EndDate                             VARCHAR(30),
            SourceNodeAlias         VARCHAR (50),
            pan                                 VARCHAR (19), 
            terminal_id                   CHAR (9), 
            acquiring_inst_id_code              CHAR(18),
            terminal_owner          CHAR(12),
            merchant_type                       CHAR (4),
            card_acceptor_id_code   CHAR (15),  
            card_acceptor_name_loc  CHAR (70), 
            source_node_name        VARCHAR (40), 
            sink_node_name                VARCHAR (40), 
            tran_type                     CHAR (2), 
            rsp_code_rsp                  CHAR (2), 
            message_type                  CHAR (4), 
            datetime_req                  DATETIME,                     
            settle_amount_req       FLOAT, 
            settle_amount_rsp       FLOAT,
            settle_tran_fee_rsp           FLOAT,                        
            TranID                              INT,
            prev_post_tran_id       INT, 
            system_trace_audit_nr   CHAR (6), 
            message_reason_code           CHAR (4), 
            retrieval_reference_nr  CHAR (12), 
            datetime_tran_local           DATETIME, 
            from_account_type       CHAR (2), 
            to_account_type               CHAR (2), 
            settle_currency_code    CHAR (3),                     
            settle_amount_impact    FLOAT,                  
            tran_type_desciption    VARCHAR (255),
            rsp_code_description    VARCHAR (255),
            settle_nr_decimals            INT,
            currency_alpha_code           CHAR (3),
            currency_name                 VARCHAR (20),           
            isPurchaseTrx                 INT,
            isWithdrawTrx                 INT,
            isRefundTrx                   INT,
            isDepositTrx                  INT,
            isInquiryTrx                  INT,
            isTransferTrx                 INT,
            isOtherTrx                    INT,
            structured_data_req           VARCHAR(MAX),
            tran_reversed                 INT,
            --merchant_acct_nr            VARCHAR(50),      
            payee                   VARCHAR(50),
            extended_tran_type            CHAR (4),--oremeyi added this 2009-04-22
            auth_id_rsp             VARCHAR(10),
            account_nr              VARCHAR(50)
      )

      

      
            
      DECLARE @idx                                    INT
      DECLARE @node_list                        VARCHAR(255)
      
      DECLARE @warning VARCHAR(255)
      DECLARE @report_date_end_next DATETIME
      DECLARE @node_name_list VARCHAR(255)
      DECLARE @date_selection_mode              VARCHAR(50)
      
      -- Get the list of nodes that will be used in determining the last closed batch
      SET @node_name_list = 'MEGAASPsrc'
      SET @date_selection_mode = @Period
                  
      -- Calculate the report dates
      --EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

        IF(@StartDate IS NULL OR @EndDate IS NULL ) BEGIN  
  EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT   

   SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)  
 SET @EndDate   = CONVERT(VARCHAR(30), @report_date_end, 112)  
   
   END  
    ELSE BEGIN  
      SET @report_date_start = @StartDate   
   SET @report_date_end = @EndDate   
    END 



      --EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


      DECLARE  @list_of_source_nodes  TABLE (source_node    VARCHAR(30)) 
      INSERT INTO  @list_of_source_nodes  SELECT part FROM usf_split_string(@SourceNodes, ',') ORDER BY PART ASC;
      
      INSERT
                        INTO @report_result
SELECT
                        NULL AS Warning,
                        @StartDate as StartDate,  
                        @EndDate as EndDate, 
                        t.source_node_name,
                        dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
                        t.terminal_id, 
                        t.acquiring_inst_id_code,
                        t.terminal_owner,
                        t.merchant_type,
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
                              , t.settle_currency_code ) AS settle_amount_impact,                     
                        
                        dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_desciption,
                        dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,


                        dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
                        dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
                        dbo.currencyName(t.settle_currency_code) AS currency_name,

                        
                        dbo.fn_rpt_isPurchaseTrx(tran_type)       AS isPurchaseTrx,
                        dbo.fn_rpt_isWithdrawTrx(tran_type)       AS isWithdrawTrx,
                        dbo.fn_rpt_isRefundTrx(tran_type)         AS isRefundTrx,
                        dbo.fn_rpt_isDepositTrx(tran_type)        AS isDepositTrx,
                        dbo.fn_rpt_isInquiryTrx(tran_type)        AS isInquiryTrx,
                        dbo.fn_rpt_isTransferTrx(tran_type)       AS isTransferTrx,
                        dbo.fn_rpt_isOtherTrx(tran_type)          AS isOtherTrx,
                        t.structured_data_req,
                        t.tran_reversed,
                        payee,--oremeyi added this 2009-04-22
                        extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
                        auth_id_rsp ,
                        account_nr

                        
      FROM
                    post_tran_summary t (NOLOCK)
                         LEFT JOIN
                       tbl_merchant_account a (NOLOCK)
                        on t.card_acceptor_id_code = a.card_acceptor_id_code
                        
      WHERE                   

               (t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
                        AND
                        t.tran_completed = '1'
                        AND

                        t.tran_postilion_originated = 0
                        AND
                        (
                        left(t.message_type,2)='02' 
                        )
                        AND
                        t.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
                        AND
                        t.tran_reversed = 0  -- eseosa 141010
                AND
                                      
                         t.settle_currency_code in ('566','840')
						 OPTION (RECOMPILE)
                        
                              
      IF @@ROWCOUNT = 0
            INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)                 
      

SELECT 
             StartDate,
            EndDate,
            isnull(settle_amount_impact * -1,0)  as amount,
            isnull(CASE                  
                  WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                  WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                  
                        WHEN tran_type IN ('20') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN -1
                  WHEN tran_type IN ('20') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN -1

                  WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                  
                        WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                        END,0) as tran_count,
                   settle_currency_code,
                  substring(terminal_id,1,1) as Terminal_type,
                   case when source_node_name like '%MIGS%' then 'MIGS'
                   when source_node_name like 'MEGASP%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 6),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   when source_node_name like 'ADJ%'
                   then left(RIGHT(source_node_name, LEN(source_node_name) - 3),len(RIGHT(source_node_name, LEN(source_node_name) - 6))-3)
                   else source_node_name end as Bank

      
      FROM 
                  @report_result
      ORDER BY 
                  source_node_name, datetime_req

      
      

        OPTION(MAXDOP 12)
      END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_2]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_pos_acquirer_2]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@IINs		VARCHAR(255),
	@AcquirerInstId		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@merchants		VARCHAR(512),--this is the c.card_acceptor_id_code,
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
	@Period			VARCHAR(20),   -- included by eseosa on 14/02/2012 to accommodate multiple time periods
	@Currency_code		VARCHAR(3) -- included by eseosa to specify currency
AS
BEGIN

	SET NOCOUNT ON

	-- The B04 report uses this stored proc.
	

	--SET @StartDate = '20071122'
	--SET @EndDate = '20071125'	

	DECLARE  @report_result TABLE
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR(30),
		EndDate					VARCHAR(30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(18),
		terminal_owner  		CHAR(12),
		merchant_type				CHAR (4),
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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (200),
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
		structured_data_req		VARCHAR(MAX),
		tran_reversed			INT,
		--merchant_acct_nr		VARCHAR(50),	
		payee				VARCHAR(50),
		extended_tran_type		CHAR (4),--oremeyi added this 2009-04-22
		auth_id_rsp			VARCHAR(10),
		account_nr			VARCHAR(50)
		--tran_tran_fee_rsp		INT,     --sopeju added this
		--merchant_service_charge	INT,	 --sopeju added this
		--tran_amount_rsp			INT		 --sopeju added this
	)

	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END

	
		
	DECLARE @idx 						INT
	DECLARE @node_list				VARCHAR(255)
	
	DECLARE @warning VARCHAR(255)
	DECLARE @report_date_end_next DATETIME
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	
	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'MEGAASPsrc'
	SET @date_selection_mode = @Period
			
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


	DECLARE  @list_of_source_nodes TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM dbo.usf_split_string (@SourceNodes, ',');
	
	DECLARE  @list_of_IINs TABLE(IIN	VARCHAR(30)) 
	INSERT INTO  @list_of_IINs SELECT part FROM dbo.usf_split_string (@IINs, ',');
	
	DECLARE  @list_of_card_acceptor_id_codes TABLE(card_acceptor_id_code	VARCHAR(15)) 
	INSERT INTO  @list_of_card_acceptor_id_codes SELECT part FROM dbo.usf_split_string (@merchants, ','); 
	-- Only look at 02xx messages that were not fully reversed.
	
		DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=@report_date_start  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req < @report_date_end  ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE recon_business_date >=CONVERT(DATETIME,@report_date_start)  ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE recon_business_date < CONVERT(DATETIME,@report_date_end)  ORDER BY datetime_req DESC)
	END
	
	INSERT
				INTO @report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				/*SourceNodeAlias = 
				(CASE 
					WHEN c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes) THEN '-Our ATMs-'
					ELSE c.source_node_name
				END),
				*/
				c.source_node_name,
				dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
				c.terminal_id, 
				t.acquiring_inst_id_code,
				c.terminal_owner,
				c.merchant_type,
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
				--t.tran_tran_fee_rsp,
				--t.tran_amount_rsp,
				--merchant_service_charge,
				
				
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

				
				dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
				dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
				dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
				dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
				dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
				dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
				dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
				t.structured_data_req,
				t.tran_reversed,
				payee,--oremeyi added this 2009-04-22
				extended_tran_type,--oremeyi added this 2010-02-28 for YPM transactions
				auth_id_rsp	,
				account_nr

				
	FROM
		 post_tran t (nolock, INDEX(ix_post_tran_2 ))
		, post_tran_cust c (nolock,INDEX(pk_post_tran_cust))
		, tbl_merchant_account a (NOLOCK, INDEX(card_acceptor_id_code_idx))
				
				
	WHERE 			
				t.post_tran_cust_id = c.post_tran_cust_id
				AND
				c.card_acceptor_id_code *= a.card_acceptor_id_code
				--c.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = '1'
				AND
				--(t.post_tran_cust_id >= @first_post_tran_cust_id) 
				--AND 
				--(t.post_tran_cust_id <= @last_post_tran_cust_id) 
				 datetime_req  >= @report_date_start
				AND datetime_req<@report_date_end
				AND
				t.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				(t.message_type IN ('0220','0200')) 
				)
				and
				t.tran_currency_code = @currency_code
				--AND 
				--t.tran_completed = 1 
				AND
				t.tran_reversed = 0  -- eseosa 141010
				--AND 
				--(t.acquiring_inst_id_code = @AcquirerInstId)
				AND
				(@merchants IS NULL OR LEN(@merchants) = 0 OR c.card_acceptor_id_code IN(SELECT card_acceptor_id_code FROM @list_of_card_acceptor_id_codes))
				AND
				c.source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
				
					
	IF @@ROWCOUNT = 0
		INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
	SELECT 
			* 
	FROM 
			@report_result
	ORDER BY 
			source_node_name, datetime_req
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer_all_UBAVISA]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_web_acquirer_all_UBAVISA]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	--@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@AcquiringBIN	VARCHAR(25),
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
                late_reversal_id CHAR (1)
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
	SET @node_name_list = 'MEGAASPsrc'
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
				--ISNULL(m.Category_name,'VOID'),
				--ISNULL(m.Fee_type,'VOID'),
				--ISNULL(m.merchant_disc,0.0),
				--ISNULL(m.fee_cap,0),
				--ISNULL(m.amount_cap,99999999999.99),
				--ISNULL(m.bearer,'M'),

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
                                0 as rdm_amt,
                                 Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END
	FROM
			
				post_tran t (NOLOCK)
				INNER JOIN post_tran_cust c (NOLOCK)
				ON  t.post_tran_cust_id = c.post_tran_cust_id
				--left JOIN tbl_merchant_category_Web m (NOLOCK)
				--ON c.merchant_type = m.category_code 
				--left JOIN tbl_xls_settlement y (NOLOCK)
				
                            --    ON (c.terminal_id= y.terminal_id 
                                 --   AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                 --   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                 --   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                -- and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

                                
	WHERE 			
				
				c.post_tran_cust_id >= @rpt_tran_id
				AND
				(t.recon_business_date >= @report_date_start) 
				AND 
				(t.recon_business_date <= @report_date_end) 
				AND
				
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				
				AND
				t.tran_postilion_originated = 0  
				AND
				t.tran_completed = 1
				AND
				tran_type NOT IN ('31','39','50')
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
				--AND
				--sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				AND
             c.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'


	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT *

--		 StartDate,
--		 EndDate,
--		 card_acceptor_id_code, 
--		 card_acceptor_name_loc, 
--		 acquiring_inst_id_code,
--		category_name, 
--		merchant_type,
--		 tran_type,
--		SUM(CASE
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220')THEN 1
--                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0220')THEN 1
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
--			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
--                        --WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
--			ELSE 0
--			END) AS no_above_limit,
--		SUM(CASE
--			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220') then settle_amount_impact * -1	
--			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
--			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
--			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
--                        ELSE 0
--            		END) AS amount_above_limit,
--		 SUM(settle_amount_impact * -1+ rdm_amt)as amount,
--		 SUM(settle_tran_fee_rsp *-1) as fee,
--		 SUM(CASE			
--                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
--                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
--                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
--            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
--            		END) as tran_count,
--			extended_tran_type,
--			message_type,
--			settle_amount_rsp,
--			system_trace_audit_nr,
--                        late_reversal_id,
--                  (CASE When  dbo.fn_rpt_CardGroup (pan) = 1 Then 'Verve Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 2 Then 'Magstripe Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 3 Then 'MasterCard'
--                                  When dbo.fn_rpt_CardGroup (pan) = 4 Then 'MasterCard Verve Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 6 Then 'Visa Card'
--                                  When dbo.fn_rpt_CardGroup (pan) = 5 Then 'Unknown Card'
--                                  Else 'Unknown Card'
--	                          END) AS CardType
	FROM 
			#report_result

                        where not (c.merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                                     and c.merchant_type not in ('5371')		
--	GROUP BY
--			StartDate, EndDate,category_name,extended_tran_type,
--			merchant_type,acquiring_inst_id_code,tran_type, 
--			card_acceptor_id_code, card_acceptor_name_loc,
--			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id,dbo.fn_rpt_CardGroup (pan) -- tran_type_description, 
                          
	ORDER BY 
			acquiring_inst_id_code




END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node_2]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node_2]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
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
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
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
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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
	
	DECLARE  @list_of_AcquiringID TABLE(AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  @list_of_AcquiringID SELECT part FROM usf_split_string( @AcquiringID, ',')

       DECLARE @list_of_CBN_Code TABLE (CBN_Code CHAR(3)) 
	
	INSERT INTO  @list_of_CBN_Code   SELECT part FROM usf_split_string( @CBN_Code, ',')


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			dbo.usf_decrypt_pan(c.pan,c.pan_encrypted) as pan,
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
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
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM @list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM @list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
			AND
			LEFT(c.terminal_id, 1)= '2'

	IF (@@ROWCOUNT = 0)BEGIN
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
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

	--	SET @process_descr = 'Office B06 Report'

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
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node]    Script Date: 05/26/2016 15:50:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO











ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP_source_node]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),
		StartDate					VARCHAR(30),
		EndDate						VARCHAR(30),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
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
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description		VARCHAR (255),
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
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('Please supply the Network Name parameter.')
		SELECT * FROM @report_result
		RETURN 1
	END

	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)

	-- Get the list of nodes that will be used in determining the last closed batch
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES (@warning)

		SELECT * FROM @report_result

		RETURN 1
	END

	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	DECLARE  @list_of_AcquiringID  TABLE(AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  @list_of_AcquiringID SELECT part FROM dbo.usf_split_string(@AcquiringID, ',');

        DECLARE  @list_of_CBN_Code TABLE(CBN_Code CHAR(3)) 
	
	INSERT INTO  @list_of_CBN_Code  SELECT part FROM dbo.usf_split_string(@CBN_Code, ','); 
	
	
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		

	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @report_date_start  AND recon_business_date >=  @report_date_start   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end ) ORDER BY datetime_req DESC)
	     SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start   AND recon_business_date >= @report_date_start     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
	    SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
	    SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	    SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @report_date_start  AND (recon_business_date >= @report_date_start )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @report_date_end  AND (recon_business_date < @report_date_end ) ORDER BY recon_business_date DESC)
		
		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @report_date_start AND (recon_business_date >= @report_date_start )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @report_date_end AND (recon_business_date < @report_date_end  ) ORDER BY datetime_req DESC)
	END
	


	INSERT
			INTO @report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			dbo.usf_decrypt_pan(c.pan,c.pan_encrypted) pan,
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK, INDEX(ix_post_tran_2))
			INNER JOIN
			post_tran_cust c WITH (NOLOCK, INDEX(pk_post_tran_cust)) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
			t.tran_completed = 1
			AND
			(t.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t.post_tran_id >= @first_post_tran_id) 
	AND 
	(t.post_tran_id <= @last_post_tran_id)
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0100','0200','0220','0400','0420')---oremeyi removed 0120
			AND
			t.tran_completed = 1
			AND
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM @list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM @list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        LEFT(c.terminal_id,1) = '2'
                        
	IF @@ROWCOUNT = 0
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', CONVERT(CHAR(8), @report_date_start, 112), CONVERT(CHAR(8), @report_date_end, 112))
	--ELSE
	--BEGIN
	--	--
	--	-- Decrypt PAN information if necessary
	--	--
	--	DECLARE @pan VARCHAR (19)
	--	DECLARE @pan_encrypted CHAR (18)
	--	DECLARE @pan_clear VARCHAR (19)
	--	DECLARE @process_descr VARCHAR (100)

	--	SET @process_descr = 'Office B06 Report'

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
	ORDER BY
			datetime_tran_local
END

































GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test_try]    Script Date: 05/26/2016 15:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE[dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test_try]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
        @SourceNodes	VARCHAR(255),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
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
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
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
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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
	
	CREATE TABLE #list_of_AcquiringID (AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringID EXEC osp_rpt_util_split_nodenames @AcquiringID

        CREATE TABLE #list_of_CBN_Code (CBN_Code CHAR(3)) 
	
	INSERT INTO  #list_of_CBN_Code EXEC osp_rpt_util_split_nodenames @CBN_Code

        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

        INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
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
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'
                        AND
                        c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local, source_node_name
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test]    Script Date: 05/26/2016 15:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP_Eloho_Test]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
        @SourceNodes	VARCHAR(255),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
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
		message_reason_code			CHAR (4),
		retrieval_reference_nr		CHAR (12),
		datetime_tran_local			DATETIME,
		from_account_type			CHAR (2),
		to_account_type				CHAR (2),
		settle_currency_code		CHAR (3),
		settle_amount_impact		FLOAT,
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
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
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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
	
	CREATE TABLE #list_of_AcquiringID (AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringID EXEC osp_rpt_util_split_nodenames @AcquiringID

        CREATE TABLE #list_of_CBN_Code (CBN_Code CHAR(3)) 
	
	INSERT INTO  #list_of_CBN_Code EXEC osp_rpt_util_split_nodenames @CBN_Code

        CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 

        INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
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
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'
                        AND
                        c.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local, source_node_name
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_pos_acquirer_CUP]    Script Date: 05/26/2016 15:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER PROCEDURE [dbo].[osp_rpt_b04_pos_acquirer_CUP]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate		CHAR(8),	-- yyyymmdd
	@AcquiringID	VARCHAR(40),
	@CBN_Code		CHAR(3),
	@Period			VARCHAR(20),    -- included by eseosa to support multiple time frames 14/02/2012
	@show_full_pan	 	INT		-- 0/1/2: Masked/Clear/As is
AS
BEGIN
	-- The B06 report uses this stored proc.

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),
		StartDate					CHAR (8),
		EndDate						CHAR (8),
		pan							VARCHAR (19),
                terminal_id                     VARCHAR (10),
		card_acceptor_id_code		CHAR (15),
		card_acceptor_name_loc		CHAR (40),
                Acquiring_Inst_id_code          VARCHAR (10),
                
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
		rsp_code_description	VARCHAR (200),
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
		auth_is_rsp				VARCHAR(10)
	)

	-- Validate the source node
	IF (@AcquiringID IS NULL or Len(@AcquiringID)=0)
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
	--SET @node_name_list = @SourceNode
	SET @date_selection_mode = @Period -- modified by eseosa 14/02/2012

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

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
	
	CREATE TABLE #list_of_AcquiringID (AcquiringID	VARCHAR(30)) 
	
	INSERT INTO  #list_of_AcquiringID EXEC osp_rpt_util_split_nodenames @AcquiringID

        CREATE TABLE #list_of_CBN_Code (CBN_Code CHAR(3)) 
	
	INSERT INTO  #list_of_CBN_Code EXEC osp_rpt_util_split_nodenames @CBN_Code


	INSERT
			INTO #report_result

	SELECT
			NULL AS Warning,
			-- change these to @report_date_... etc
			CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
			CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
			c.pan,
			c.terminal_id,
                        c.card_acceptor_id_code,
			c.card_acceptor_name_loc,
                        t.acquiring_inst_id_code,
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

			dbo.fn_rpt_isPurchaseTrx(tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(tran_type) 		AS isOtherTrx,
			isDeclinedForcePost =
				(CASE
					WHEN (message_type IN ('0220','0420') AND NOT rsp_code_rsp IN ('00','08','10','11','16')) THEN
						1
					ELSE
						0
				END),
			c.pan_encrypted,
			Auth_id_rsp
	FROM
			post_tran t WITH (NOLOCK)
			INNER JOIN
			post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE
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
			(t.acquiring_inst_id_code IN (SELECT AcquiringID FROM #list_of_AcquiringID) 
                         or 
                         (substring (c.terminal_id,2,3) IN (SELECT CBN_Code FROM #list_of_CBN_Code)))
			AND
			 t.sink_node_name = 'CUPsnk'
                        AND
                        c.terminal_id like '2%'

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

	SELECT *
	FROM
			#report_result
	ORDER BY
			datetime_tran_local
END



GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_Discover]    Script Date: 05/26/2016 15:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER PROCEDURE [dbo].[osp_rpt_b04_Discover]
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
	BEGIN TRANSACTION;
		

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
		tran_type_desciption	VARCHAR (255),
		rsp_code_description	VARCHAR (255),
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

	
	
	IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO @report_result (Warning) VALUES ('Please supply the Host name.')
	   	SELECT * FROM @report_result
		RETURN 1
	END
		
	
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
				dbo.formatAmount(t.tran_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,

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
				t.tran_nr+t.online_system_id
	FROM
				post_tran t (NOLOCK)
				 JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id) AND	
				(c.post_tran_cust_id >= @rpt_tran_id) AND  (t.recon_business_date >= @report_date_start AND t.recon_business_date <= @report_date_end)
	WHERE 		
			  
				t.tran_completed = 1 AND
				(
				 ( t.retention_data IS NOT NULL AND (LEFT(retention_data,4) in (SELECT Retention_Data FROM @list_of_retention_data))   OR 
				  LEFT (c.totals_group,3) IN (SELECT bank_code FROM @list_of_bank_codes)   AND (t.sink_node_name <>'ESBCSOUTsnk' AND t.retention_data is  NULL))
				
				)
				

				AND
				t.message_type IN ('0200', '0220', '0400', '0420')  AND t.tran_type  ='01'
				
				AND
                (
				c.source_node_name  = 'SWTMEGADSsrc'
                )
				AND
				LEFT(t.sink_node_name,2) <> 'SB' 
				

						
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
		

COMMIT TRANSACTION;
END







GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_0100_no_0220_1]    Script Date: 05/26/2016 15:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO







ALTER PROCEDURE [dbo].[osp_rpt_0100_no_0220_1]

@Start_Date  Varchar(10),
@Sink_Node   Varchar(14),
@message_type Varchar(4),
@Days		Numeric

AS 
BEGIN
set NOCOUNT ON

CREATE TABLE #summary
(post_tran_cust_id CHAR(16), tran_count NUMERIC)

IF (@Start_Date IS NULL or Len(@Start_Date)=0) 



SET @Start_Date = CONVERT(CHAR(8),(DATEADD (dd, -(@Days+1), GetDate())), 112)


INSERT INTO #summary

select post_tran_cust_id as post_tran_cust_id, count (*) from post_tran as tran_count
where message_type in ('0100','0220')
and post_tran_cust_id in (select distinct post_tran_cust_id from post_tran where message_type = @message_type 
and datetime_req >= @Start_Date--(SELECT CONVERT(char(8), (DATEADD (DAY, -32,GETDATE())), 112))
and datetime_req < (SELECT CONVERT(char(8), (DATEADD (DAY, -@Days,GETDATE())), 112))
and sink_node_name = @Sink_Node
and tran_type = '00'
and rsp_code_rsp = '00'
and tran_reversed = 0)

and post_tran_cust_id not in (select post_tran_cust_id from post_tran where message_type = '0220' and rsp_code_req != '00' and sink_node_name = 'MEGAPRUsnk')



group by post_tran_cust_id


select 
       pt.message_type as message_type,
       ptc.terminal_id as terminal_id,
system_trace_audit_nr as stan,
  ptc.card_acceptor_id_code as card_acceptor_id,
ptc.card_acceptor_name_loc as card_acceptor_name_loc,
       
	dbo.DecryptPan(pan,pan_encrypted,'cardstatement') as pan,
	pt.from_account_id as account_number,
	dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
       pt.tran_amount_req/100 as tran_amount,
       dbo.currencyAlphaCode(pt.tran_currency_code) as tran_currency,
       pt.settle_amount_req/100 as settle_amount,
	dbo.currencyAlphaCode(pt.settle_currency_code) as settle_currency,
       pt.datetime_req as date_time,
      pt.auth_id_rsp,
	pt.retrieval_reference_nr,
      
       pt.post_tran_cust_id as tran_id

from post_tran_cust ptc (nolock)
join #summary s (nolock)
on s.post_tran_cust_id = ptc.post_tran_cust_id
join post_tran pt (nolock) 
on s.post_tran_cust_id = pt.post_tran_cust_id
where s.tran_count < 3
and pt.tran_postilion_originated=0
and message_type = @message_type
order by pt.datetime_req


END















GO

/****** Object:  StoredProcedure [dbo].[usp_who2]    Script Date: 05/26/2016 15:50:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--usp_who2 1
ALTER PROCEDURE [dbo].[usp_who2]  @show_deadlocks_only BIT 

AS

BEGIN

IF (OBJECT_ID('#process_map') IS NOT NULL)
BEGIN
	DROP TABLE #process_map
END

IF (OBJECT_ID('#temp_process_table') IS NOT NULL)
BEGIN
	DROP TABLE #temp_process_table
END


IF (OBJECT_ID('#temp_process_table_2') IS NOT NULL)
BEGIN
	DROP TABLE #temp_process_table_2
END

IF (OBJECT_ID('#temp_process_data') IS NOT NULL)
BEGIN
	DROP TABLE #temp_process_data
END
CREATE TABLE #temp_process_table (
	spid  INT, 
	blocked INT,
	kpid INT, 
	dbname VARCHAR(50),
	cpu BIGINT,
	status  VARCHAR(250),
	physical_io BIGINT,
	memusage BIGINT, 
	login_time DATETIME, 
	 last_batch DATETIME,
	duration_secs BIGINT, 
	loginame VARCHAR (250),
	 hostname VARCHAR (250), 
	program_name VARCHAR (250),
	cmd VARCHAR (250),
	 sql_handle VARBINARY (4000)

)


IF (@show_deadlocks_only =1)
    BEGIN
	INSERT INTO  #temp_process_table SELECT spid, blocked,kpid, db_name(dbid) AS dbname,cpu,status,physical_io,memusage, login_time, last_batch,DATEDIFF(S, last_batch, GETDATE()) AS duration_secs, loginame, hostname, program_name,cmd, sql_handle FROM master.dbo.sysprocesses WHERE blocked !=0 AND blocked = spid
  END  
  ELSE  BEGIN
   INSERT INTO  #temp_process_table SELECT spid, blocked,kpid, db_name(dbid) AS dbname,cpu,status,physical_io,memusage, login_time, last_batch,DATEDIFF(S, last_batch, GETDATE()) AS duration_secs, loginame, hostname, program_name,cmd, sql_handle FROM master.dbo.sysprocesses WHERE blocked !=0
END

CREATE TABLE #process_map (spid int, query_details varchar (4000));

DECLARE @processID INT
DECLARE @process VARCHAR(4000)
		IF (OBJECT_ID('#temp_process_data') IS NOT NULL)
		BEGIN
		DROP TABLE #temp_process_data
		END
CREATE TABLE #temp_process_data(eventtype nvarchar(30), parameters int, eventinfo nvarchar(4000));

DECLARE spid_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT spid FROM  #temp_process_table UNION SELECT blocked FROM #temp_process_table;

OPEN spid_cursor
FETCH NEXT FROM spid_cursor INTO @processID
WHILE (@@FETCH_STATUS =0) 
 BEGIN


INSERT INTO #temp_process_data  (EventType, Parameters, EventInfo)  EXEC ('DBCC INPUTBUFFER('+@processID+')');

SELECT @process= EventInfo FROM #temp_process_data 
--IF NOT EXISTS (SELECT  spid FROM #process_map WHERE spid =@processID )
--BEGIN
	INSERT INTO #process_map select @processID,@process
--END

FETCH NEXT FROM spid_cursor INTO @processID

END
CLOSE spid_cursor
DEALLOCATE spid_cursor


SELECT  procs.spid, blocked,kpid, dbname, maps.query_details as 'running_query_details',(SELECT query_details FROM #process_map WHERE spid =blocked ) as 'blocking_query_details', cpu,status,physical_io,memusage, login_time, last_batch, duration_secs, loginame, hostname, program_name,cmd, sql_handle FROM #temp_process_table procs JOIN #process_map maps ON procs.spid = maps.spid JOIN #process_map bmaps ON procs.spid = bmaps.spid 
DROP TABLE #temp_process_data
DROP TABLE #temp_process_table
DROP TABLE #process_map
END


GO

