USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_all_Mcard_Route]    Script Date: 07/08/2016 18:55:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE[dbo].[osp_rpt_b04_web_pos_acquirer_all_Mcard_Route]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	Create   TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30), 
		SourceNodeAlias 		VARCHAR (50),
		pan						VARCHAR (19), 
		terminal_id				CHAR (8), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  			VARCHAR(12),
		merchant_type				CHAR (4),
		Category_name				VARCHAR(50),
		Fee_type				CHAR(1),
		merchant_disc				DECIMAL(7,4),
		fee_cap					FLOAT,
		amount_cap				FLOAT,
		bearer					CHAR(1),
		card_acceptor_id_code	VARCHAR (255),	 
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
                Unique_key varchar (500),
                Totals_group varchar (100),
                amount  DECIMAL(20,2),
                FEE DECIMAL(20,2)
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

INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE t.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 

				t.acquiring_inst_id_code,
				t.terminal_owner,
				ISNULL(t.merchant_type,'VOID'),
				--ISNULL(account_nr,'not available')
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,99999999999.99),
				ISNULL(m.bearer,'M'),

				t.card_acceptor_id_code, 

				t.card_acceptor_name_loc, 
				t.source_node_name,
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
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,
                                t.totals_group,
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
				left JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                 
WHERE 			
	
 
	
				
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
				t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(t.terminal_id like '3IWP%') OR
					(t.terminal_id like '3ICP%') OR
					(t.terminal_id like '2%')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(t.terminal_id like '5%') OR
                                        (t.terminal_id like '31WP%') OR
					(t.terminal_id like '31CP%') OR
					(t.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')
                                and ISNULL(y.rdm_amt,0) <>0
                                AND  NOT  (t.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') AND t.sink_node_name+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(t.pan,1) = '4' and not t.tran_type = '01')
	                        and t.totals_group not in ('VISAGroup')
                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             (t.sink_node_name  NOT LIKE 'SB%')
            OPTION (RECOMPILE, MAXDOP 8)

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				SourceNodeAlias = 
				(CASE 
					WHEN t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE t.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
				t.terminal_id, 
				t.acquiring_inst_id_code,
				t.terminal_owner,
				ISNULL(t.merchant_type,'VOID'),
				--ISNULL(account_nr,'not available')
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,99999999999.99),
				ISNULL(m.bearer,'M'),

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
					        END,
                 t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,
                                 t.totals_group,
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
				left JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
               
	
WHERE 			
	
				
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
				t.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
					(
					(t.terminal_id like '3IWP%') OR
					(t.terminal_id like '3ICP%') OR
					(t.terminal_id like '2%')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(t.terminal_id like '5%') OR
                                        (t.terminal_id like '31WP%') OR
					(t.terminal_id like '31CP%') OR
					(t.terminal_id like '6%')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				
                 AND  NOT  (t.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(t.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (t.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (t.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(t.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))	
                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
              (t.sink_node_name  NOT LIKE 'SB%' )
              option (RECOMPILE, maxdop 8)


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
         source_node_name,
         sink_node_name,
		 card_acceptor_name_loc, 
		 acquiring_inst_id_code,
		category_name, 
		merchant_type,
		 tran_type,
                 totals_group,
		no_above_limit = CONVERT( INT, SUM(CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
			ELSE 0
			END))  ,
		amount_above_limit = CONVERT( decimal(20,2),SUM(CASE
			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1	
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
                        ELSE 0
            		END)) ,
		  amount = CONVERT( decimal(20,2),SUM(settle_amount_impact * -1+ rdm_amt)),
		   fee = CONVERT( decimal(20,2),SUM(settle_tran_fee_rsp *-1)),
		tran_count = CONVERT(int, SUM(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) ),
			extended_tran_type,
			message_type,
			settle_amount_rsp,
			system_trace_audit_nr,
                        late_reversal_id
	 
	FROM 
			#report_result

                        where not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                                    -- and merchant_type not in ('5371')	
                        and  not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') 
        and unique_key  IN (SELECT unique_key FROM #temp_table)
                                               )
        and (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk')
        	
	GROUP BY
			StartDate, EndDate,category_name,extended_tran_type,
			merchant_type,acquiring_inst_id_code,tran_type, 
			card_acceptor_id_code, card_acceptor_name_loc,
			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id,unique_key,source_node_name,
         sink_node_name,totals_group-- tran_type_description, 
	ORDER BY 
			acquiring_inst_id_code
			 option (RECOMPILE, maxdop 8)




END










































































































































