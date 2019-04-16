
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_all_visa_CoAcquiring]    Script Date: 07/08/2016 23:51:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






ALTER PROCEDURE[dbo].[osp_rpt_b04_web_pos_acquirer_all_visa_CoAcquiring]
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
		pan						VARCHAR (25), 
		terminal_id				VARCHAR (12), 
		acquiring_inst_id_code			CHAR(12),
		terminal_owner  			VARCHAR(20),
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
                Unique_key varchar (200), 
                	amount  DECIMAL(20,2),
		fee DECIMAL(20,2),
		no_above_limit  INT,
		amount_above_limit DECIMAL(20,2),
		tran_count INT 
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
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, 

@report_date_end_next OUTPUT, @warning OUTPUT

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
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar

(12))+'_'+t.message_type	
	
	,0,0,0,0,0
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
                                and not (t.source_node_name in ('SWTNCS2src','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') 
                                AND not(substring(t.pan,1,1) = '4') and not t.tran_type = '01')
	                         and NOT (t.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                 and NOT (t.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                         and not(t.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))		

                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
           t.sink_node_name  NOT LIKE 'SB%'
           OPTION  (RECOMPILE, MAXDOP 8)

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
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar

(12))+'_'+t.message_type	
	,0,0,0,0,0
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
					)left JOIN tbl_merchant_category m (NOLOCK)
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
				and not (t.source_node_name in ('SWTNCS2src','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND not(substring(t.pan,1,1) = '4') and not 

t.tran_type = '01')
                and NOT (t.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			    and NOT (t.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			        and not(t.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))		

                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
           t.sink_node_name  NOT LIKE 'SB%'
           option  (RECOMPILE, MAXDOP 8)


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
		no_above_limit = convert(int, SUM(CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
			ELSE 0
			END) ),
		amount_above_limit = convert(DECIMAL(20,2),SUM(CASE
			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1	
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
                        ELSE 0
            		END) ),
		 amount = convert( DECIMAL(20,2),SUM(settle_amount_impact * -1+ rdm_amt)),
		  fee = convert( DECIMAL(20,2),SUM(settle_tran_fee_rsp *-1) ),
		tran_count = CONVERT(INT, SUM(CASE			
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

                    where    not(source_node_name in ('SWTNCS2src','SWTNCSKIMsrc','SWTNCSKI2src')
                                 and unique_key  IN (SELECT unique_key FROM #temp_table))
                      and (pan like '4%' and acquiring_inst_id_code not in  ('462526','627787'))
					and	not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                   -- and merchant_type not in ('5371')
                   
						
          
	GROUP BY
			StartDate, EndDate,category_name,extended_tran_type,
			merchant_type,acquiring_inst_id_code,tran_type, 
			card_acceptor_id_code, card_acceptor_name_loc,
			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id-- tran_type_description, 
	ORDER BY 
			acquiring_inst_id_code
option (recompile, maxdop 8)



END







/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_all_Kimono]    Script Date: 07/08/2016 23:02:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






alter PROCEDURE[dbo].[osp_rpt_b04_web_pos_acquirer_all_Kimono]
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
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

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
		card_acceptor_id_code	VARCHAR (30),	 
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
                Unique_key varchar (200) ,
                no_above_limit  INT,
                amount_above_limit DECIMAL(20,2),
                amount  DECIMAL(20,2),
                fee DECIMAL(20,2),
                tran_count INT
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
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, 

@report_date_end_next OUTPUT, @warning OUTPUT

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
					WHEN q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes) THEN '-Our ATMs-'
					ELSE q.source_node_name
				END),
				dbo.fn_rpt_PanForDisplay(q.pan, @show_full_pan) AS pan,
				q.terminal_id, 
				q.acquiring_inst_id_code,
				q.terminal_owner,
				ISNULL(q.merchant_type,'VOID'),
				--ISNULL(account_nr,'not available')
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL

(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (q.merchant_type,q.terminal_id,q.tran_type,q.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,

				q.card_acceptor_id_code, 

				q.card_acceptor_name_loc, 
				q.source_node_name,
				q.sink_node_name, 
				q.tran_type, 
				q.rsp_code_rsp, 
				q.message_type, 
				q.datetime_req, 
				dbo.formatAmount(q.settle_amount_req, q.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(q.settle_amount_rsp, q.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(q.settle_tran_fee_rsp, q.settle_currency_code) AS settle_tran_fee_rsp,
				q.tran_reversed,	 
					
				
				dbo.formatAmount( 			
					CASE
						WHEN (q.tran_type = '51') THEN -1 * q.settle_amount_impact
						ELSE q.settle_amount_impact
					END
					, q.settle_currency_code ) AS settle_amount_impact,
					extended_tran_type,
					system_trace_audit_nr,-----------added by ij 2010/04/01
                                 0 as rdm_amt,
                                 Late_Reversal_id = CASE
						WHEN (q.post_tran_cust_id < @rpt_tran_id1 and q.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                q.retrieval_reference_nr+'_'+q.system_trace_audit_nr+'_'+q.terminal_id+'_'+ cast((q.settle_amount_impact) as varchar

(12))+'_'+q.message_type
	FROM
			
				asp_visa_pos q (NOLOCK)
				 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@report_date_start,@report_date_end)
					)r
				ON
					r.recon_business_date = q.recon_business_date
				left JOIN tbl_merchant_category m (NOLOCK)
				ON q.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON q.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (q.terminal_id= y.terminal_id 
                                    AND q.retrieval_reference_nr = y.rr_number 
                                    --AND q.system_trace_audit_nr = y.stan
                                    --AND (-1 * q.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (q.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                   and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))

                                
	WHERE 			
			
				
				(q.message_type IN ('0100','0200', '0400', '0420')) 
				
				AND
				q.tran_postilion_originated = 0  
				AND
				q.tran_completed = 1
				AND
				tran_type NOT IN ('31','39','50','21')
				--AND 
				--q.sink_node_name = @SinkNode
				--AND
				--q.source_node_name IN (SELECT source_node FROM #list_of_source_nodes)
				AND 
				(
					(q.terminal_id like '3IWP%') OR
					(q.terminal_id like '3ICP%') OR
					(q.terminal_id like '2%') OR
					(q.terminal_id like '5%') OR
                    (q.terminal_id like '31WP%') OR
					(q.terminal_id like '31CP%') OR
					(q.terminal_id like '6%')
					
										
AND
q.tran_type = '01' and not q.sink_node_name in ('ASPPOSMICsnk'))
                                and q.totals_group not in ('VISAGroup')
                AND
             q.source_node_name  NOT LIKE 'SB%'
             AND
           q.sink_node_name  NOT LIKE 'SB%'
	AND q.source_node_name  <> 'SWTMEGAsrc'AND q.source_node_name  <> 'SWTMEGADSsrc'
	OPTION (RECOMPILE)


	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	



/* create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc') */


	


SELECT 
		 StartDate,
		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 acquiring_inst_id_code,
		category_name, 
		merchant_type,
		 tran_type,
	no_above_limit = CONVERT(INT, 	SUM(CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
			ELSE 0
			END) ),
	amount_above_limit = CONVERT( decimal(20,2),	SUM(CASE
			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1	
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
                        ELSE 0
            		END) ),
		amount = CONVERT( decimal(20,2), SUM(settle_amount_impact * -1+ rdm_amt))  ,
		fee = CONVERT( decimal(20,2),  SUM(settle_tran_fee_rsp *-1) ),
		tran_count = CONVERT(INT,  SUM(CASE			
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

                              --and not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src')
                                 --and unique_key  IN (SELECT unique_key FROM #temp_table))
	
	GROUP BY
			StartDate, EndDate,category_name,extended_tran_type,
			merchant_type,acquiring_inst_id_code,tran_type, 
			card_acceptor_id_code, card_acceptor_name_loc,
			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id,source_node_name	-- tran_type_description, 
	ORDER BY 
			acquiring_inst_id_code
			option (recompile, maxdop 8)




END



GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_all]    Script Date: 07/08/2016 22:39:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO








ALTER procedure[dbo].[osp_rpt_b04_web_pos_acquirer_all]
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
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
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
                Unique_key varchar (200),
                no_above_limit  INT,
                amount_above_limit DECIMAL(20,2),
                amount  DECIMAL(20,2),
                fee DECIMAL(20,2),
                tran_count INT
                
                
                
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
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, 

@report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)
		
		SELECT * FROM #report_result
		
		RETURN 1
	END

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
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL

(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,

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
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar

(12))+'_'+t.message_type	
                                ,0,0,0,0,0
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
					) JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON t.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                 --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand)
                                 )
                                 
                   
	
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
                 AND  NOT  (t.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(t.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (t.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (t.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(t.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 

'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))			

                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
           t.sink_node_name  NOT LIKE 'SB%'
	AND t.source_node_name  <> 'SWTMEGAsrc'AND t.source_node_name  <> 'SWTMEGADSsrc'
 
	OPTION (RECOMPILE, maxdop 8)
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
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL

(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,

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
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar

(12))+'_'+t.message_type
                                ,0,0,0,0,0
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
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON t.merchant_type = v.category_code 
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
				 AND  NOT  (t.source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND t.sink_node_name--+LEFT

(totals_group,3)
                               not in ('ASPPOSLMCsnk') AND not LEFT(t.pan,1) = '4' and not t.tran_type = '01')
                                and NOT (t.totals_group in ('VISAGroup') and t.acquiring_inst_id_code = '627787')
			                   and NOT (t.totals_group in ('VISAGroup') and t.sink_node_name not in ('ASPPOSVINsnk')
			                           and not(t.source_node_name = 'SWTFBPsrc'and t.sink_node_name = 'ASPPOSVISsnk'))	
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 

'ASPPOSLMCsnk'
                                         and totals_group in ('MCCGroup','CITIDEMCC'))			

                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
           t.sink_node_name  NOT LIKE 'SB%'
	AND t.source_node_name  <> 'SWTMEGAsrc'AND t.source_node_name  <> 'SWTMEGADSsrc'
 
	OPTION (RECOMPILE, MAXDOP 8)

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
	no_above_limit = CONVERT(int,	SUM(CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
			ELSE 0
			END)),
		amount_above_limit= CONVERT(DECIMAL(20,2), SUM(CASE
			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1	
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
                        ELSE 0
            		END)),
		amount = CONVERT(DECIMAL(20,2),  SUM(settle_amount_impact * -1+ rdm_amt)),
		fee = CONVERT(DECIMAL(20,2),   SUM(settle_tran_fee_rsp *-1) ),
		tran_count =  CONVERT(int,  SUM(CASE			
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

OPTION (RECOMPILE, MAXDOP 8)


END



























GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_bill_payment_summary]    Script Date: 07/08/2016 22:05:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE[dbo].[osp_rpt_b04_bill_payment_summary]
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
    set transaction isolation level read uncommitted
	-- The B04 report uses this stored prot.
	

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
		card_acceptor_id_code	CHAR (15),
		fee	DECIMAL(20, 2),
	    amount DECIMAL(20,2),
        fee_group DECIMAL(20,2),
	    tran_count int
		
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
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, 

@report_date_end_next OUTPUT, @warning OUTPUT

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
				t.terminal_owner, 
				t.acquiring_inst_id_code,
				t.source_node_name,
				t.sink_node_name, 
				t.tran_type,
				t.rsp_code_rsp, 
				t.tran_reversed,	 
				t.message_type,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
				totals_group,
				t.terminal_id,
				card_acceptor_id_code,
				0,0,0,0	
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
			 
				t.tran_completed = 1
	
				AND
				t.tran_postilion_originated = 0 
		
				AND
				( 
				(t.sink_node_name = 'PAYDIRECTsnk' or ((payee like '%62805150' or payee like '62805150%' or t.source_node_name = 'BILLSsrc')and 

t.sink_node_name <> 'BILLSsnk' and t.card_acceptor_id_code like 'QuickTeller%'))
				OR 
				(t.terminal_id IN 

('3FTL0001','3UDA0001','3FET0001','3UMO0001','3PLI0001','3FTH0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001','2ONT0001','3ASI0001','4QIK0001','4MBX0001',

'3NCH0001','4FBI0001','3UTX0001','4TSM0001','4FMM0001','3EBM0001','4CLT0001','4FDM0001','3HIB0001','4RBX0001')and t.sink_node_name <> 'BILLSsnk')
				OR
                                (t.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk' and 

t.tran_type = '50')
                                OR
				(t.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				)
				AND
				t.tran_type NOT IN ('31', '39', '32')
                                
                                AND
				t.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')

                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
            -- and t.extended_tran_type <> '8234'
            Option(recompile, maxdop 8)
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT  
	                StartDate,
					EndDate,
					source_node_name,
					fee_group  =  CONVERT(DECIMAL(20,2),ABS(settle_tran_fee_rsp)),
					sink_node_name,
					terminal_owner,
					acquiring_inst_id_code,
					fee =  CONVERT(DECIMAL(20,2),sum(settle_tran_fee_rsp)  ),
					totals_group,
					rsp_code_rsp,
					message_type,
					amount =  CONVERT(DECIMAL(20,2),sum(settle_amount_impact)) ,
					tran_count = CONVERT(int,SUM(CASE			
					WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN

(0,1)THEN 1
					WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN

(0,1)THEN 1
					WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 

THEN 0 
					WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 

THEN 0 
					END) ),
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
			Option(recompile, maxdop 8)
	
END


GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_NOU]    Script Date: 07/08/2016 21:33:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE[dbo].[osp_rpt_b06_all_NOU]--oremeyi modified the previous
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
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	
	
	SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

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
		rsp_code_description VARCHAR (300),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (300),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(500),
		fee		DECIMAL(20,2),
		fee_group  DECIMAL(20,2),
		amount DECIMAL(20,2),
		tran_count INT
		
	)			

	IF (@SourceNode IS NULL or Len(@SourceNode)=0)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
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
			0,0,0,0
			
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
	

			t.tran_completed = 1
		AND
			
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			
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
			t.source_node_name not in 

('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
                       and t.sink_node_name not like '%TPP%'
                        and t.source_node_name not like '%TPP%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk')
			AND
			(t.terminal_id not like '2%')
            AND
             t.source_node_name  NOT LIKE 'SB%'
            AND
           t.sink_node_name  NOT LIKE 'SB%'
           OPTION (RECOMPILE,MAXDOP 8)
			
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		fee_group = CONVERT(DECIMAL(20,2), ABS(settle_tran_fee_rsp) ),
		 sink_node_name,
		fee  = CONVERT(DECIMAL(20,2), sum(settle_tran_fee_rsp) ),
		amount= CONVERT(DECIMAL(20,2), sum(settle_amount_impact)),
		tran_count = CONVERT(INT,SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 2 THEN 0 
            		END))

	
	FROM
			#report_result
			
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name
	ORDER BY 
			source_node_name
			OPTION (RECOMPILE,MAXDOP 8)
END



GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_acquirer_all_Mcard_Route]    Script Date: 07/08/2016 21:28:49 ******/
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
		FEE DECIMAL(20,2),
		no_above_limit  INT,
		amount_above_limit DECIMAL(20,2),
		tran_count INT
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
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, 

@report_date_end_next OUTPUT, @warning OUTPUT

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
                               not in ('ASPPOSLMCsnkAFR','ASPPOSLMCsnkCIT','ASPPOSLMCsnkABP','ASPPOSLMCsnkDBL') AND not LEFT(t.pan,1) = '4' and not t.tran_type = 

'01')
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
			                   AND NOT (source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc') AND sink_node_name = 

'ASPPOSLMCsnk'
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
		amount decimal(15,2),
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
	EXECUTE osp_rpt_get_dates_2015 @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, 

@report_date_end_next OUTPUT, @warning OUTPUT

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
			t.source_node_name not in 

('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
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
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer_all_Standardised]    Script Date: 07/09/2016 07:07:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO







create PROCEDURE[dbo].[osp_rpt_b04_web_acquirer_all_Standardised]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
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
		no_above_limit int,
		amount_above_limit INT,
		CardType VARCHAR(30),
		fee			decimal(15,2),
		amount decimal(15,2),
		tran_count decimal(15,2)
		
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
					        END
					        ,0,0,'',0,0,0
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
				left JOIN tbl_merchant_category_web m (NOLOCK)
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

				
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				
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
					--(t.terminal_id like '2%')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(t.terminal_id like '5%') OR
                                        (t.terminal_id like '31WP%') OR
					(t.terminal_id like '31CP%') OR
					(t.terminal_id like '6%') OR
					(t.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')
                                and ISNULL(y.rdm_amt,0) <>0
                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
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
					        END
					        ,0,0,'',0,0,0
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
				left JOIN tbl_merchant_category_Web m (NOLOCK)
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

				(t.message_type IN ('0220','0200', '0400', '0420')) 
				
				AND
				t.tran_postilion_originated = 0  
				AND
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50')
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
					(t.terminal_id like '6%') OR
					(t.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
OPTION (RECOMPILE, MAXDOP 8)

	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
		 StartDate,
		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 acquiring_inst_id_code,
		category_name, 
		merchant_type,
		 tran_type,
		no_above_limit = convert( int, SUM(CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220')THEN 1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0220')THEN 1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        --WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
			ELSE 0
			END) ),
		amount_above_limit   =  CONVERT( DECIMAL(20,2), SUM(CASE
			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220') then settle_amount_impact * -1	
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
                        ELSE 0
            		END) ),
		 amount = CONVERT(DECIMAL(20,2), SUM(settle_amount_impact * -1+ rdm_amt)),
		fee = CONVERT(DECIMAL(20,2), SUM(settle_tran_fee_rsp *-1) ),
		tran_count = CONVERT(INT, SUM(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END)),
			extended_tran_type,
			message_type,
			settle_amount_rsp,
			system_trace_audit_nr,
                        late_reversal_id,
                CardType =CONVERT(VARCHAR(30),  (CASE When  dbo.fn_rpt_CardGroup (pan) = 1 Then 'Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 2 Then 'Magstripe Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 3 Then 'MasterCard'
                                  When dbo.fn_rpt_CardGroup (pan) = 4 Then 'MasterCard Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 6 Then 'Visa Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 5 Then 'Unknown Card'
                                  Else 'Unknown Card'
	                          END) )
	FROM 
			#report_result

                        where not (t.merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                                     and t.merchant_type not in ('5371')		
	GROUP BY
			StartDate, EndDate,category_name,extended_tran_type,
			merchant_type,acquiring_inst_id_code,tran_type, 
			card_acceptor_id_code, card_acceptor_name_loc,
			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id,dbo.fn_rpt_CardGroup (pan) -- tran_type_description, 
                          
	ORDER BY 
			acquiring_inst_id_code

OPTION (RECOMPILE, MAXDOP 8)


END



GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_acquirer_all_Standardised]    Script Date: 07/09/2016 07:07:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO







alter PROCEDURE[dbo].[osp_rpt_b04_web_acquirer_all_Standardised]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
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
		no_above_limit int,
		amount_above_limit INT,
		CardType VARCHAR(30),
		fee			decimal(15,2),
		amount decimal(15,2),
		tran_count decimal(15,2)
		
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
					        END
					        ,0,0,'',0,0,0
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
				left JOIN tbl_merchant_category_web m (NOLOCK)
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

				
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				
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
					--(t.terminal_id like '2%')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(t.terminal_id like '5%') OR
                                        (t.terminal_id like '31WP%') OR
					(t.terminal_id like '31CP%') OR
					(t.terminal_id like '6%') OR
					(t.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')
                                and ISNULL(y.rdm_amt,0) <>0
                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
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
					        END
					        ,0,0,'',0,0,0
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
				left JOIN tbl_merchant_category_Web m (NOLOCK)
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

				(t.message_type IN ('0220','0200', '0400', '0420')) 
				
				AND
				t.tran_postilion_originated = 0  
				AND
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50')
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
					(t.terminal_id like '6%') OR
					(t.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk','VTUSTOCKsnk','PAYDIRECTsnk','SWTMEGAsnk')------ij added SWTMEGAsnk
				AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
OPTION (RECOMPILE, MAXDOP 8)

	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
		 StartDate,
		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 acquiring_inst_id_code,
		category_name, 
		merchant_type,
		 tran_type,
		no_above_limit = convert( int, SUM(CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220')THEN 1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0220')THEN 1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        --WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1
			ELSE 0
			END) ),
		amount_above_limit   =  CONVERT( DECIMAL(20,2), SUM(CASE
			---WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220') then settle_amount_impact * -1	
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt
                        ELSE 0
            		END) ),
		 amount = CONVERT(DECIMAL(20,2), SUM(settle_amount_impact * -1+ rdm_amt)),
		fee = CONVERT(DECIMAL(20,2), SUM(settle_tran_fee_rsp *-1) ),
		tran_count = CONVERT(INT, SUM(CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END)),
			extended_tran_type,
			message_type,
			settle_amount_rsp,
			system_trace_audit_nr,
                        late_reversal_id,
                CardType =CONVERT(VARCHAR(30),  (CASE When  dbo.fn_rpt_CardGroup (pan) = 1 Then 'Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 2 Then 'Magstripe Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 3 Then 'MasterCard'
                                  When dbo.fn_rpt_CardGroup (pan) = 4 Then 'MasterCard Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 6 Then 'Visa Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 5 Then 'Unknown Card'
                                  Else 'Unknown Card'
	                          END) )
	FROM 
			#report_result

                        where not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                                     and merchant_type not in ('5371')		
	GROUP BY
			StartDate, EndDate,category_name,extended_tran_type,
			merchant_type,acquiring_inst_id_code,tran_type, 
			card_acceptor_id_code, card_acceptor_name_loc,
			 message_type,settle_amount_rsp,system_trace_audit_nr,late_reversal_id,dbo.fn_rpt_CardGroup (pan) -- tran_type_description, 
                          
	ORDER BY 
			acquiring_inst_id_code

OPTION (RECOMPILE, MAXDOP 8)


END



GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_bank_computation]    Script Date: 07/09/2016 13:27:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





	ALTER PROCEDURE [dbo].[psp_settlement_bank_computation](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @bank_code varchar (30)
)
AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

If (@start_date is null) begin  
set @start_date =   REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()) ,112),'/', '');
end

If (@end_date is null ) begin
set @end_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');
END


DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');
SET @to_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');

SELECT
         StartDate= CONVERT(VARCHAR(10), @start_date,112), 
 
         EndDate=CONVERT(VARCHAR(10), @end_date, 112),

	trxn_category,
        
        Account_type = CASE 
        
        
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'VISA CO-ACQUIRER AMOUNT PAYABLE' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE'
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'VISA CO-ACQUIRER FEE PAYABLE' THEN 'VISA CO-ACQUIRER FEE PAYABLE'
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE' THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE'
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISSUER FEE PAYABLE' and trxn_category = 'REWARD MONEY (BURN) POS FEE SETTLEMENT'THEN 'ISSUER FEE PAYABLE_ISW SUNDRY (Acc 2017896339)'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'AMOUNT PAYABLE' and trxn_category = 'REWARD MONEY (BURN) WEB FEE SETTLEMENT'THEN 'AMOUNT PAYABLE_ISW SUNDRY (Acc 2017896339)'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'AMOUNT PAYABLE' THEN 'AMOUNT PAYABLE'
			    WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'AMOUNT RECEIVABLE'THEN 'AMOUNT RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'RECHARGE FEE PAYABLE' THEN  'RECHARGE FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ACQUIRER FEE PAYABLE' THEN 'ACQUIRER FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'CO-ACQUIRER FEE RECEIVABLE' THEN 'CO-ACQUIRER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ACQUIRER FEE RECEIVABLE' THEN 'ACQUIRER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISSUER FEE PAYABLE' THEN 'ISSUER FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'CARDHOLDER_ISSUER FEE RECEIVABLE' THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SCHEME OWNER ISSUER FEE RECEIVABLE' THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISSUER FEE RECEIVABLE' THEN 'ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW ACQUIRER FEE RECEIVABLE' THEN 'ISW ACQUIRER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW ISSUER FEE RECEIVABLE' THEN 'ISW ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE GENERIC FEE RECEIVABLE' THEN 'ISW VERVE GENERIC FEE RECEIVABLE' 
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE ECOBANK FEE RECEIVABLE' THEN 'ISW VERVE ECOBANK FEE RECEIVABLE' 
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE SKYEBANK FEE RECEIVABLE' THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE FIRSTBANK FEE RECEIVABLE' THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE GENERIC FEE RECEIVABLE' THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE'

                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW 3LCM FEE RECEIVABLE' THEN 'ISW 3LCM FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE' THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE GTBANK FEE RECEIVABLE' THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE UBA FEE RECEIVABLE' THEN 'ISW NON-VERVE UBA FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW FEE RECEIVABLE' THEN 'ISW FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISO FEE RECEIVABLE' THEN 'ISO FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'TERMINAL_OWNER FEE RECEIVABLE' THEN 'TERMINAL_OWNER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'PROCESSOR FEE RECEIVABLE' THEN 'PROCESSOR FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ATMC FEE PAYABLE' THEN 'ATMC FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ATMC FEE RECEIVABLE' THEN 'ATMC FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'EASYFUEL FEE RECEIVABLE' THEN 'EASYFUEL FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'MERCHANT FEE RECEIVABLE' THEN 'MERCHANT FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'YPM FEE RECEIVABLE' THEN 'YPM FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'FLEETTECH FEE RECEIVABLE' THEN 'FLEETTECH FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'LYSA FEE RECEIVABLE' THEN 'LYSA FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'PAYIN INSTITUTION FEE RECEIVABLE' THEN 'PAYIN INSTITUTION FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA FEE RECEIVABLE' THEN 'SVA FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'UDIRECT FEE RECEIVABLE' THEN 'UDIRECT FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'PTSP FEE RECEIVABLE' THEN 'PTSP FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'CARDHOLDER_NCS FEE RECEIVABLE' THEN 'CARDHOLDER_NCS FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'NCS FEE RECEIVABLE' THEN 'NCS FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'REWARD_SUNDRY_AMOUNT_RECEIVABLE' THEN  'REWARD_SUNDRY_AMOUNT_RECEIVABLE(Acc 2017896339)'                                                                        
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'TOUCHPOINT FEE RECEIVABLE' THEN  'TOUCHPOINT FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'YPM FEE RECEIVABLE' THEN  'YPM FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SAVER FEE RECEIVABLE' THEN  'SAVER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW FEE RECEIVABLE' THEN  'ISW FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW_REWARD_FEE_RECEIVABLE' THEN  'ISW_REWARD_FEE_RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'MERCHANT ADDITIONAL REWARD FEE PAYABLE' THEN  'MERCHANT ADDITIONAL REWARD FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE' THEN  'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW CARD SCHEME FEE RECEIVABLE' THEN  'ISW CARD SCHEME FEE RECEIVABLE' 
			    WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA SPONSOR FEE RECEIVABLE' THEN  'SVA SPONSOR FEE RECEIVABLE' 
			    WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA SPONSOR FEE PAYABLE' THEN  'SVA SPONSOR FEE PAYABLE'




         ELSE 'UNK' END,

        total_Amount = (SUM(CASE WHEN (CHARINDEX ('pool' ,Debit_account_type) = 0 ) THEN -trxn_amount
 			 ElSE trxn_amount END)/100),
	total_fee = (SUM(CASE WHEN (CHARINDEX ('pool' ,Debit_account_type) = 0 ) THEN -trxn_fee
 			 ELSE trxn_fee END)/100),
    currency,
    Rate = case  when sett.currency = '566' then 1
          else (SELECT cbn.Rate
          FROM cbn_currency AS cbn
          WHERE  sett.currency = cbn.currency_code 
          and cbn.date = (select max(date) from cbn_currency)) end, 
     late_reversal--,
    -- card_type
	 

FROM  settlement_summary_breakdown as sett (nolock)
 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@from_date,@from_date)
					)r
				ON
					sett.trxn_date = r.recon_business_date

WHERE bank_code = @bank_code

     AND trxn_category NOT LIKE  'UNK%'
      and not (trxn_category like 'POS%' and trxn_category not like '%transfer%' and ((debit_account_type like '%amount%'
               or credit_account_type like '%amount%') and late_reversal =0))
     -- and not (trxn_category LIKE 'PREPAID CARDLOAD%')
       and not (trxn_category LIKE 'BILLPAYMENT%' and (debit_account_type like '%amount%'
               or credit_account_type like '%amount%'))
       and not (trxn_category LIKE 'PREPAID MERCHANDISE%')
       --and not (trxn_category like '%MASTERCARD LOCAL PROCESSING BILLING%')
       and  (sett.currency = '566' or (sett.currency = '840' and (trxn_category in ('QUICKTELLER TRANSFERS(SVA)','WESTERN UNION MONEY TRANSFERS','BILLPAYMENT MASTERCARD BILLING','ATM WITHDRAWAL (MASTERCARD ISO)') or trxn_category like '%MASTERCARD LOCAL PROCESSING BILLING%')))
       and trxn_category <> 'DEPOSIT'
       
group by trxn_category,dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type),currency,late_reversal--,card_type
OPTION(RECOMPILE, MAXDOP 8)

END

go 
ALTER  PROCEDURE [dbo].[psp_settlement_bank_computation_all](
	@start_date DATETIME=NULL,
      @end_date DATETIME=NULL
)
AS
BEGIN


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

If (@start_date is null) begin  
set @start_date =   REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()) ,112),'/', '');
end

If (@end_date is null ) begin
set @end_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');
END


DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');
SET @to_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');


SELECT
        StartDate= CONVERT(VARCHAR(10), @start_date,112), 
 
         EndDate=CONVERT(VARCHAR(10), @end_date, 112),
        
        Bank_code,

	trxn_category,
        
        Amount_payable  = (SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%AMOUNT%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_amount-trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%AMOUNT%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_amount+trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1),	

                        Amount_receivable = (SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%AMOUNT%RECEIVABLE' and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%REWARD%AMOUNT%RECEIVABLE%'and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_amount-trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%AMOUNT%RECEIVABLE' and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%REWARD%AMOUNT%RECEIVABLE%'and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_amount+trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1),	

                        Issuer_fee_payable = (SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISSUER%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISSUER%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
                             WHEN (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA SPONSOR FEE PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
			                 WHEN (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA SPONSOR FEE PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1),	
	
                        Acquirer_fee_payable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ACQUIRER%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ACQUIRER%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),	

                        Acquirer_fee_receivable =convert( DECIMAL(20,2), (SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ACQUIRER%FEE%RECEIVABLE' 
                              and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%ISW%FEE%RECEIVABLE'
                               and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ACQUIRER%FEE%RECEIVABLE' 
                             and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%ISW%FEE%RECEIVABLE'
                              and (CHARINDEX ('pool' ,Debit_account_type) <> 0 ))THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        Issuer_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISSUER%FEE%RECEIVABLE' 
                             and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%ISW%FEE%RECEIVABLE'
                             and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%ACQUIRER%FEE%RECEIVABLE'
                              and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISSUER%FEE%RECEIVABLE' 
                              and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%ISW%FEE%RECEIVABLE'
                              and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%ACQUIRER%FEE%RECEIVABLE'
                               and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),



                        Terminal_owner_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%TERMINAL%FEE%REC%' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%TERMINAL%FEE%REC%' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        ISW_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When ((dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISW%FEE%RECEIVABLE' 
                              or dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%MCARD GTB/FBN%'
                              or dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%MAGSTRIPE/MCARD%')
                              and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%TERMINAL%FEE%REC%'
                              and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee

                             When ((dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISW%FEE%RECEIVABLE'
                              or dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%MCARD GTB/FBN%'
                              or dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%MAGSTRIPE/MCARD%')
                              and dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) not like '%TERMINAL%FEE%REC%' 
                              and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        Processor_fee_receivable= convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%PROCESSOR%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%PROCESSOR%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        NCS_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%NCS%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%NCS%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        
	
                        Easyfuel_account =convert( DECIMAL(20,2), (SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%EASYFUEL%ACCOUNT' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%EASYFUEL%ACCOUNT' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        ISO_fee_receivable  = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISO%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ISO%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),	
                        PTSP_fee_receivable  = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%PTSP%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%PTSP%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),
	
                        Recharge_fee_payable =convert( DECIMAL(20,2), (SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%RECHARGE%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%RECHARG%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)), 

                        PAYIN_Institution_fee_receivable   = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%PAYIN_INSTITUTION_FEE_RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%PAYIN_INSTITUTION_FEE_RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        Fleettech_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%FLEETTECH%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%FLEETTECH%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        LYSA_fee_receivable  = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%LYSA%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%LYSA%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        SVA_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%SVA%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%SVA%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        udirect_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%UDIRECT%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%UDIRECT%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),


                        Merchant_fee_receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%MERCHANT%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%MERCHANT%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        ATMC_Fee_PAYABLE = convert( DECIMAL(20,2),(SUM(CASE 


                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ATMC%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ATMC%FEE%PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			     When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like 'MERCHANT ADDITIONAL REWARD FEE PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like 'MERCHANT ADDITIONAL REWARD FEE PAYABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                        ATMC_Fee_Receivable = convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ATMC%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%ATMC%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),
                             
                         Touchpoint_fee_receivable= convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%TOUCHPOINT%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%TOUCHPOINT%FEE%RECEIVABLE' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),
       
                         Reward_Amount_receivable= convert( DECIMAL(20,2),(SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%REWARD%AMOUNT%RECEIVABLE%' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%REWARD%AMOUNT%RECEIVABLE%' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),

                          Reward_Fee_receivable= (convert( DECIMAL(20,2),SUM(CASE 

                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%REWARD%FEE%RECEIVABLE%' and (CHARINDEX ('pool' ,Debit_account_type) = 0 )) THEN -trxn_fee
                             When (dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) like '%REWARD%FEE%RECEIVABLE%' and (CHARINDEX ('pool' ,Debit_account_type) <> 0 )) THEN trxn_fee
 			
                             
			     ELSE 0 END)/100)* isnull(cbn.rate,1)),
                 currency,
      Rate = convert( DECIMAL(20,2),case  when sett.currency = '566' then 1
          else (SELECT cbn.Rate
          FROM cbn_currency AS cbn (nolock)
          WHERE  sett.currency = cbn.currency_code 
          and cbn.date = (select max(date) from cbn_currency (nolock))) end
	 
	 )
into #report_result
FROM  
settlement_summary_breakdown as sett (nolock)
 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@from_date,@from_date)
					)r
				ON
					sett.trxn_date = r.recon_business_date
 LEFT  join  cbn_currency cbn (NOLOCK)
  on
  ((sett.currency = cbn.currency_code) and cbn.date = (select max(date) from cbn_currency (NOLOCK)))

WHERE  
       trxn_category NOT LIKE  'UNK%'
      and not (trxn_category like 'POS%' and trxn_category not like '%transfer%' and ((debit_account_type like '%amount%'
               or credit_account_type like '%amount%') and late_reversal = 0))
     -- and not (trxn_category LIKE 'PREPAID CARDLOAD%')
      and not (trxn_category LIKE 'BILLPAYMENT%' and (debit_account_type like '%amount%'
               or credit_account_type like '%amount%'))
      and not (trxn_category LIKE 'PREPAID MERCHANDISE%')
       
       --and not (trxn_category LIKE 'ATM TRANSFERS%')
       
       --and cbn.date = (select max(date) from cbn_currency))
      --and not (trxn_category like '%MASTERCARD LOCAL PROCESSING BILLING%')
    and  (sett.currency = '566' or (sett.currency = '840' and (trxn_category in ('QUICKTELLER TRANSFERS(SVA)','WESTERN UNION MONEY TRANSFERS','BILLPAYMENT MASTERCARD BILLING','ATM WITHDRAWAL (MASTERCARD ISO)','MASTERCARD LOCAL PROCESSING BILLING(ATM WITHDRAWAL)') or trxn_category like '%MASTERCARD LOCAL PROCESSING BILLING%')))
     and trxn_category <> 'DEPOSIT' 
     
       

group by trxn_category,Bank_Code, currency, cbn.rate
  OPTION(RECOMPILE, MAXDOP 8) 
  
  SELECT * FROM #report_result   

END


GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_bill_payment_summary_mastercard]    Script Date: 07/09/2016 14:54:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






CREATE                                                            PROCEDURE [dbo].[osp_rpt_b04_bill_payment_summary_mastercard]
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
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #report_result
	(
		Warning					VARCHAR (255),
		StartDate				CHAR (8),  
		EndDate					CHAR (8), 
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
		card_acceptor_id_code	CHAR (15),
		fee			decimal(15,2),
		fee_group  decimal(15,2),
		amount decimal(15,2),
		tran_count decimal(15,2)
		
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

	
	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				@StartDate as StartDate,  
				@EndDate as EndDate, 
				t.terminal_owner, 
				t.acquiring_inst_id_code,
				t.source_node_name,
				t.sink_node_name, 
				t.tran_type,
				t.rsp_code_rsp, 
				t.tran_reversed,	 
				t.message_type,
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,
				totals_group,
				terminal_id,
				card_acceptor_id_code,
				0,0,0,0
				
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
			
				t.tran_completed = 1
				AND
	
				t.tran_postilion_originated = 0 
				--AND
				--t.message_type IN ('0200', '0220', '0400', '0420') 	
				AND
				( 
				(t.sink_node_name = 'PAYDIRECTsnk' or ((payee like '%62805150' or payee like '62805150%' or t.source_node_name = 'BILLSsrc') and t.sink_node_name <> 'BILLSsnk' and t.card_acceptor_id_code like 'QuickTeller%'))
				OR 
				(t.terminal_id IN ('3FTL0001','3UDA0001','3FET0001','3UMO0001','3PLI0001','3FTH0001','3PAG0001','3PMM0001','4MIM0001','3BOZ0001','4RDC0001','2ONT0001','3ASI0001','4QIK0001','4MBX0001','3NCH0001','4FBI0001','3UTX0001','4TSM0001','4FMM0001','3EBM0001','4FDM0001','3HIB0001','4RBX0001')and t.sink_node_name <> 'BILLSsnk')
				OR
                                (t.terminal_id = '3BOL0001' and (t.extended_tran_type <> '8502'or t.extended_tran_type is NULL) and t.sink_node_name <> 'BILLSsnk' and t.tran_type = '50')
                                OR
				(t.terminal_id like '2%' AND t.extended_tran_type = '8500' AND t.message_type = '0200')
				)
				AND
				t.tran_type NOT IN ('31', '39', '32')
                                AND
				t.source_node_name NOT IN ( 'VTUsrc')
				AND
				t.sink_node_name NOT IN ( 'VTUsnk')

                                and totals_group in ('ZIBMCDebit')

                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             --and t.extended_tran_type <> '8234'
             
       option (recompile, maxdop 8)
				
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 fee_group =  CONVERT(DECIMAL(20,2), ABS(settle_tran_fee_rsp)),
		 sink_node_name,
		 terminal_owner,
		 acquiring_inst_id_code,
		 fee = CONVERT(DECIMAL(20,2),sum(settle_tran_fee_rsp)) ,
		 totals_group,
		 rsp_code_rsp,
		 message_type,
		amount =  CONVERT(DECIMAL(20,2), sum(settle_amount_impact)),
		tran_count =  CONVERT(DECIMAL(20,2),SUM(CASE			
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed IN(0,1)THEN 1
                	WHEN tran_type IN ('00','50') and message_type = '0200' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','50') and message_type = '0220' and rsp_code_rsp IN('00','08','10','11','16')and tran_reversed = 2 THEN 0 
            		END)),
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
	
	option (recompile, maxdop 8)
END









GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b08_MC_Processing_all]    Script Date: 07/09/2016 15:31:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO






ALTER                              PROCEDURE [dbo].[osp_rpt_b08_MC_Processing_all]
	@StartDate	varchar(30),	-- yyyymmdd
	@EndDate		varchar(30),	-- yyyymmdd
	@SinkNode		VARCHAR(1000),
	@SourceNodes		VARCHAR(1000),
	@Bins			VARCHAR(30),
	@Period			VARCHAR(30),
	@show_full_pan	  int,	-- 0/1/2: Masked/Clear/As is
	@report_date_start DATETIME,
	@report_date_end DATETIME,
        @rpt_tran_id INT

AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	-- The B08 report uses this stored prot.

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
		source_node_name		VARCHAR (40),
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
		tran_type_desciption	VARCHAR (60),
		rsp_code_description	VARCHAR (60),
		currency_alpha_code		CHAR (3),
		isPurchaseTrx			INT,
		isWithdrawTrx			INT,
		isRefundTrx				INT,
		isDepositTrx			INT,
		isInquiryTrx			INT,
		isTransferTrx			INT,
		isOtherTrx				INT,
		pan_encrypted			CHAR (18),
                tran_reversed                   CHAR (1),
                amount DECIMAL(20,2),
                tran_count INT,
                terminal_type VARCHAR(50),
                success_status  int,
                rem_Bank  varchar(50)
	)

	IF (@SinkNode IS NULL OR Len(@SinkNode)=0)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply all the parameters.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	
	DECLARE @report_date_end_next		DATETIME
	DECLARE @warning 			VARCHAR (255)
	DECLARE @node_name_list VARCHAR(255)
	DECLARE @date_selection_mode			VARCHAR(50)
	DECLARE @node_list				VARCHAR(255)
         

	-- Get the list of nodes that will be used in determining the last closed batch
	SET @node_name_list = 'CCLOADsrc'
	SET @date_selection_mode = @Period

	-- Calculate the report dates
	EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

	IF (@warning is not null)
	BEGIN
		INSERT INTO #report_result (Warning) VALUES (@warning)

		SELECT * FROM #report_result

		RETURN 1
	END


        EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
	-- Do additional validation
	IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30))

	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	CREATE TABLE #List_of_Bins (Bin	VARCHAR(30))

	INSERT INTO  #List_Of_Bins EXEC osp_rpt_util_split_nodenames @Bins

	CREATE TABLE #list_of_Sink_nodes (sink_node	VARCHAR(30))

	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
	

	INSERT
				INTO #report_result
	SELECT
				NULL AS Warning,
				CONVERT(CHAR(8), @report_date_start, 112) as StartDate,
				CONVERT(CHAR(8), @report_date_end, 112) as EndDate,
				t.pan,
				t.terminal_id,
				t.card_acceptor_id_code,
				t.card_acceptor_name_loc,
				t.sink_node_name,
				t.source_node_name,
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
				t.pan_encrypted,
                                tran_reversed,
                                0,0,0,0,''
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
		
				t.tran_completed = 1
				
				AND
				t.tran_postilion_originated = 0 ---updated from 0 for local pro aut
				      AND (
                               (T.settle_amount_impact<> 0 and T.message_type   in ('0200','0220'))

                             or ((T.settle_amount_impact<> 0 and T.message_type = '0420' 

                            and dbo.fn_rpt_isPurchaseTrx_sett(T.tran_type, t.source_node_name, T.sink_node_name,t.terminal_id,t.totals_group,t.pan) <> 1 and T.tran_reversed <> 2)
                            or (T.settle_amount_impact<> 0 and T.message_type = '0420' 
                            and dbo.fn_rpt_isPurchaseTrx_sett(T.tran_type, t.source_node_name, T.sink_node_name,t.terminal_id,t.totals_group,t.pan) = 1 )))

                             AND t.totals_group not in ('CUPGroup','VISAGroup')

                            and not (t.source_node_name  = 'MEGATPPsrc' and t.tran_type = '00')
      
                              and t.source_node_name NOT LIKE 'SWTMEGADSsrc'
				AND
				( @Bins IS NULL OR (@Bins IS NOT NULL AND substring (t.pan, 1,6) IN (SELECT Bin FROM #list_of_Bins)))
				AND
				(t.pan like '5%' and t.pan not like '506%')
				AND
				t.tran_type in ('00', '50')
				AND
				t.rsp_code_rsp IN ('00','11','09')---updated from 0 for local pro aut
				--AND
				--t.tran_reversed = 0
				
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
                  AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
             Option(recompile, maxdop 8)
				

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
		 StartDate,
		 EndDate,
		amount = CONVERT(DECIMAL(20,2), sum(isnull(settle_amount_impact * -1,0)))  ,
		tran_count = CONVERT( DECIMAL(20,2), SUM(CASE			
                	WHEN message_type in ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')THEN 1
                	WHEN message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16') THEN -1
                	
            		END) ),
                  
                  rem_Bank =  sink_node_name ,
                   source_node_name,
                   tran_type,
                 terminal_type =   substring(terminal_id,1,1) ,
                 success_status = (CASE WHEN rsp_code_rsp in ('00','08', '09') then 1 
                      else 0 end) ,
                  
                  message_type,
                  system_trace_audit_nr, 
		retrieval_reference_nr	

	 
	FROM 
			#report_result
where settle_amount_impact<> 0
Group by startdate, enddate, sink_node_name,rsp_code_rsp,message_type,system_trace_audit_nr, 
		retrieval_reference_nr,source_node_name,tran_type,terminal_id
	 Option(recompile, maxdop 8)
END






GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_Detailed_Discover]    Script Date: 07/09/2016 17:34:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





alter PROCEDURE[dbo].[osp_rpt_b06_all_Detailed_Discover]
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
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	


SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
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
		rsp_code_description VARCHAR (500),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (500),		
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
	SET @date_selection_mode = 'Last Business Day'
			
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
			dbo.fn_rpt_PanForDisplay(t.pan, @show_full_pan) AS pan,
			t.terminal_id,
			t.terminal_owner,
                        t.source_node_name, 
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
			
			dbo.fn_rpt_isPurchaseTrx(t.tran_type) 	AS isPurchaseTrx,
			dbo.fn_rpt_isWithdrawTrx(t.tran_type) 	AS isWithdrawTrx,
			dbo.fn_rpt_isRefundTrx(t.tran_type) 		AS isRefundTrx,
			dbo.fn_rpt_isDepositTrx(t.tran_type) 		AS isDepositTrx,
			dbo.fn_rpt_isInquiryTrx(t.tran_type) 		AS isInquiryTrx,
			dbo.fn_rpt_isTransferTrx(t.tran_type) 	AS isTransferTrx,
			dbo.fn_rpt_isOtherTrx(t.tran_type) 		AS isOtherTrx,
			isnull(t.retention_data,0)
			
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
             t.source_node_name  = 'SWTMEGADSsrc'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
           
			--AND
			--t.terminal_id like '1%'
			
			
			Option(recompile, maxdop 8)
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   *

	
	FROM
			#report_result 
Option(recompile, maxdop 8)

END


GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all]    Script Date: 07/09/2016 21:02:19 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER PROCEDURE[dbo].[osp_rpt_b06_all]--oremeyi modified the previous
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
	

	--SET @StartDate = '20071126'
	--SET @EndDate = '20071126'	
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON
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
		rsp_code_description VARCHAR (500),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (500),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999),
		fee	DECIMAL(20, 2),
	    amount DECIMAL(20,2),
        fee_group DECIMAL(20,2),
	    tran_count int
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
			isnull(tt.retention_data,0),0,0,0,0
			
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
            left join 
            post_tran_summary tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and 
                                          tt.tran_postilion_originated = 1
                                          and t.tran_nr = tt.tran_nr)
            
	
WHERE 			
	

			t.tran_completed = 1
		
			AND
			t.tran_postilion_originated = 0
			AND
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
		
			AND
			t.tran_type IN ('01')
			AND
			t.rsp_code_rsp IN ('00','11','08','10','16')
			AND 
			t.source_node_name not like 'SWTASP%'
			AND 
			t.source_node_name not like 'TSS%'
			AND 
			t.source_node_name not like '%WEB%'
			
            and t.sink_node_name not like '%TPP%'
                        and t.source_node_name not like '%TPP%'
            AND
			t.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc','ASPSPNTFsrc','ASPSPONUSsrc')
			AND 
			t.sink_node_name not like 'TSS%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','SWTMEGAsnk','VAUMOsnk')
			AND
			(t.terminal_id not like '2%')
             AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
            AND
			t.source_node_name not like 'SWTMEGADSsrc'
			--AND
			--t.terminal_id like '1%'
			 OPTION  (RECOMPILE, MAXDOP 8)
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 fee_group = CONVERT(DECIMAL(20,2),ABS(settle_tran_fee_rsp)),
		sink_node_name =   CONVERT(DECIMAL(20,2),(Case when retention_data = '0' then sink_node_name
              else retention_data end) ),

                 retention_data,
		fee = CONVERT( DECIMAL(20,2),sum(settle_tran_fee_rsp) ),
		amount =  CONVERT( DECIMAL(20,2), sum(settle_amount_impact)),
		tran_count = CONVERT( DECIMAL(20,2),SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp = 0 THEN 1
                	--WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11')and tran_reversed = 1 and settle_tran_fee_rsp <> 0 THEN 0
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END))

	
	FROM
			#report_result 
		 


	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,retention_data
	ORDER BY 
			source_node_name
				 OPTION  (RECOMPILE, MAXDOP 8)
				 
				 
END









GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_all]    Script Date: 07/09/2016 22:15:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


alter PROCEDURE[dbo].[osp_rpt_b04_web_pos_all]
	@StartDate		varchar(30),	-- yyyymmdd
	@EndDate		varchar(30),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL
AS
BEGIN
	-- The B04 report uses this stored prot.
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
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
		tran_type_description	VARCHAR (500),
		rsp_code_description	VARCHAR (500),
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
                Unique_key varchar (200),
                amount  DECIMAL(20,2),
		fee DECIMAL(20,2),
		no_above_limit  INT,
		amount_above_limit DECIMAL(20,2),
		tran_count INT 
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
	
INSERT
				INTO #report_result
select
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
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
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
				
				t.post_tran_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type,
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type,
                                ISNULL(y.rdm_amt,0)as rdm_amt,
                                t.totals_group,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 
                                                      and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,
                                0,0,0,0,0
                                
	FROM
				

                                post_tran_summary t (NOLOCK)
			 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@report_date_start,@report_date_end)
					)r
				ON
					r.recon_business_date = t.recon_business_date
				left JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON t.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                --and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand)
                                )
                                
                  
	
WHERE 			
	

				t.tran_completed = 1
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
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')
                                and ISNULL(y.rdm_amt,0) <>0
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
             t.sink_node_name  NOT LIKE 'SB%'
AND t.source_node_name  <> 'SWTMEGAsrc'AND t.source_node_name  <> 'SWTMEGADSsrc'
	 OPTION  (RECOMPILE, MAXDOP 8)


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
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.Category_name,'VOID') 
				else ISNULL(m.Category_name,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_type,'VOID') 
				else ISNULL(m.Fee_type,'VOID') end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.merchant_disc,0.0) 
				else ISNULL(m.merchant_disc,0.0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.fee_cap,0) 
				else ISNULL(m.fee_cap,0) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.amount_cap,999999999999.99) 
				else ISNULL(m.amount_cap,999999999999.99) end,
				case when dbo.fn_rpt_MCC_Visa (t.merchant_type,t.terminal_id,T.tran_type,t.PAN) in ('1','2','3') then ISNULL(v.bearer,'M') 
				else ISNULL(m.bearer,'M') end,
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
				t.sink_node_name , 
				t.tran_type, 
				t.rsp_code_rsp, 
				t.message_type, 
				t.datetime_req, 
				
				dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 
				dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp,
				
				t.post_tran_id as TranID,
				t.prev_post_tran_id, 
				t.system_trace_audit_nr, 
				t.message_reason_code, 
				t.retrieval_reference_nr, 
				t.datetime_tran_local, 
				t.from_account_type, 
				t.to_account_type,
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51')  THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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

				extended_tran_type,
                                0 as rdm_amt,
                                t.totals_group,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 
                                                      and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.retrieval_reference_nr+'_'+t.system_trace_audit_nr+'_'+t.terminal_id+'_'+ cast((t.settle_amount_impact) as varchar(12))+'_'+t.message_type,
                                 0,0,0,0,0
                                
	FROM
				

                               post_tran_summary t (NOLOCK)
			 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@report_date_start,@report_date_end)
					)r
				ON
					r.recon_business_date = t.recon_business_date
				left JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa v (NOLOCK)
				ON t.merchant_type = v.category_code 
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    --AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand))
                                
                  
	
WHERE 			

				t.tran_completed = 1
				
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
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')------ij added SWTMEGAsnk	
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
             t.sink_node_name  NOT LIKE 'SB%'
	AND t.source_node_name  <> 'SWTMEGAsrc'AND t.source_node_name  <> 'SWTMEGADSsrc'
	
			 OPTION  (RECOMPILE, MAXDOP 8)

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
		no_above_limit = CONVERT(INT, CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1--ij changed this to cater for 0100 transactions which always have a zero
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0100')THEN 1
                        WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
			ELSE 0
			END ),
	amount_above_limit =  CONVERT(DECIMAL(20,2),	CASE
			--WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 
                        WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt			
			ELSE 0
            		END),
	amount = CONVERT(DECIMAL(20,2),	settle_amount_impact * -1 + rdm_amt),
	fee = 	CONVERT(DECIMAL(20,2),	settle_tran_fee_rsp *-1),
	tran_count = CONVERT(INT,	 CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END ),
			extended_tran_type,
			message_type,
			settle_amount_rsp,
                        late_reversal_id

	  INTO #report_result_2
	FROM 
			#report_result

                        where 
                            tranID  not in 
		 (SELECT post_tran_id FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 ) 
         	
                        
                        and not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                  -- and merchant_type not in ('5371')	

                             and not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc')
                                 and unique_key  IN (SELECT unique_key FROM #temp_table))
	--GROUP BY
	--		StartDate, EndDate,category_name,merchant_type,sink_node_name,tran_type, card_acceptor_id_code, card_acceptor_name_loc -- tran_type_description, 
	ORDER BY 

			source_node_name, sink_node_name
			
			select * from #report_result_2
	END


GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_Remote_all_Standardised]    Script Date: 07/09/2016 22:33:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE[dbo].[osp_rpt_b04_web_Remote_all_Standardised]
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate		VARCHAR(30),-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
        @rpt_tran_id1 INT = NULL
AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
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
		TranID					INT,
		prev_post_tran_id		INT, 
		system_trace_audit_nr	CHAR (6), 
		message_reason_code		CHAR (4), 
		retrieval_reference_nr	CHAR (12), 
		datetime_tran_local		DATETIME, 
		from_account_type		CHAR (2), 
		to_account_type			CHAR (2),
		tran_reversed			INT,	 
		settle_currency_code	CHAR (3),				
		settle_amount_impact	FLOAT,			
		tran_type_description	VARCHAR (500),
		rsp_code_description	VARCHAR (500),
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
		extended_tran_type		CHAR(12),
		rdm_amt                       FLOAT,
		Late_Reversal_id             CHAR (1),
		totals_group varchar (30),
				no_above_limit int,
		amount_above_limit INT,
		CardType VARCHAR(30),
		fee			decimal(15,2),
		amount decimal(15,2),
		tran_count decimal(15,2)
		
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

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
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
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
				sink_node_name = case when y.rdm_amt <> 0 then 'InterSwitch' else t.sink_node_name end, 
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				0,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type,
                                ISNULL(y.rdm_amt,0)as rdm_amt,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 
                                                      and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.totals_group,
                                0,0,'',0,0,0
                                
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
			
				left JOIN tbl_merchant_category_web m (NOLOCK)
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
	

	--	t.post_tran_cust_id >= @rpt_tran_id 
				
				t.tran_completed = 1
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				)
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
					--(t.terminal_id like '2%')OR--(t.terminal_id like '2%' AND t.source_node_name IN ('SWTASPPOSsrc', 'SWTASPTAMsrc'))
					(t.terminal_id like '5%') OR
                                        (t.terminal_id like '31WP%') OR
					(t.terminal_id like '31CP%') OR
					(t.terminal_id like '6%') OR
					(t.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')
                                and ISNULL(y.rdm_amt,0) <>0
                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
              OPTION  (RECOMPILE, MAXDOP 8)
	
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
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
				ISNULL(m.bearer,'M'),
				t.card_acceptor_id_code, 
				t.card_acceptor_name_loc, 
				t.source_node_name,
				t.sink_node_name ,
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
				t.tran_reversed,	 
				t.settle_currency_code, 
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51')  THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type,
                               0 as rdm_amt,
                                Late_Reversal_id = CASE
						WHEN (t.post_tran_cust_id < @rpt_tran_id1 and t.message_type = '0420') THEN 1
						ELSE 0
					        END,
                                t.totals_group,
                                0,0,'',0,0,0
                                
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
			
				left JOIN tbl_merchant_category_Web m (NOLOCK)
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
	
                 --t.post_tran_cust_id >= @rpt_tran_id 
				
				t.tran_completed = 1
				AND
			
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0220','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50')
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
					(t.terminal_id like '6%') OR
					(t.terminal_id like '%VA')
										)
				AND
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')------ij added SWTMEGAsnk	
                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
              OPTION  (RECOMPILE, MAXDOP 8)
             
                               

	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
		 StartDate,

		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		sink_node_name = ( case when left(pan,1) = '4' then totals_group
                 else sink_node_name end ),
		 category_name, 
		 merchant_type,
		 tran_type,
                 terminal_id,
	no_above_limit = CONVERT(INT,	CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220')THEN 1
			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1--ij changed this to cater for 0100 transactions which always have a zero
			WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0200','0220')THEN 1
                        WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
                        WHEN ABS(Rdm_amt) >= amount_cap AND message_type IN('0420','0400')THEN -1
			ELSE 0
			END  ),
		amount_above_limit = convert(decimal(20,2), CASE
			--WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200','0220') then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			--WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 
                        WHEN ABS(Rdm_amt) >= amount_cap  then rdm_amt			
			ELSE 0
            		END),
		amount = CONVERT( decimal(20,2), settle_amount_impact * -1 + rdm_amt),
		fee = CONVERT(DECIMAL(20,2), settle_tran_fee_rsp *-1),
		tran_count = CONVERT( int,  CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	--WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200','0220') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	--WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END ),
			extended_tran_type,
			message_type,
			settle_amount_rsp,
                        late_reversal_id,
                 
               CardType =    (CASE When  dbo.fn_rpt_CardGroup (pan) = 1 Then 'Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 2 Then 'Magstripe Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 3 Then 'MasterCard'
                                  When dbo.fn_rpt_CardGroup (pan) = 4 Then 'MasterCard Verve Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 5 Then 'Unknown Card'
                                  When dbo.fn_rpt_CardGroup (pan) = 6 Then 'Visa Card'
                                  Else 'Unknown Card'
	                          END)

	 
	FROM 
			#report_result

                        where not (merchant_type in ('4004','4722') and  abs(settle_amount_impact * -1)< 200)
                                   and merchant_type not in ('5371')
                                 
	
         --GROUP BY dbo.fn_rpt_CardGroup (pan)
	--GROUP BY
	--		StartDate, EndDate,category_name,merchant_type,sink_node_name,tran_type, card_acceptor_id_code, card_acceptor_name_loc -- tran_type_description, 
	ORDER BY 

			source_node_name, sink_node_name
			 OPTION  (RECOMPILE, MAXDOP 8)
	END



GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_rdm_ISW]    Script Date: 07/09/2016 23:04:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE[dbo].[osp_rpt_b04_web_rdm_ISW]
	@StartDate		varchar(30),	-- yyyymmdd
	@EndDate			varchar(30),	-- yyyymmdd
	@SinkNodes		VARCHAR(255),
	@SourceNodes	VARCHAR(255),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

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
                Fee_Discount_RD          DECIMAL(9,7)       
	)

	-- Note: The @SourceNodes can be NULL, because the customer might not drive their own terminals
	IF (@SourceNodes IS NULL or Len(@SourceNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Web channel source node name.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	/*IF (@SinkNodes IS NULL or Len(@SinkNodes)=0)
	BEGIN	   
	   	INSERT INTO #report_result (Warning) VALUES ('Please supply the Host name.')
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

	EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 


	IF (@report_date_end < @report_date_start)
	BEGIN
	   	INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
	   	SELECT * FROM #report_result
		RETURN 1
	END

	

	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes

	/*CREATE TABLE #list_of_sink_nodes (sink_node	VARCHAR(30)) 
	
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNodes*/


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
                                extended_trans_type = ISNULL(y.extended_trans_type,'0000'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
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
				t.tran_reversed,
				t.pan_encrypted,
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
                                R.Fee_Discount	
	FROM
					 post_tran_summary t (NOLOCK)
			 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@report_date_start,@report_date_end)
					)rec
				ON
					rec.recon_business_date = t.recon_business_date
					and
					post_tran_id NOT IN (
					SELECT  post_tran_id  FROM tbl_late_reversals ll (NOLOCK) 
        WHERE ll.recon_business_date >= @report_date_start
        and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
					)
				left JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON t.card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)
				
                                ON (t.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * t.settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
                                left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code


	WHERE 			
				
				t.post_tran_cust_id >= @rpt_tran_id--'81530747'	
				AND
				t.tran_completed = 1
		
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
				---(substring(t.totals_group,1,3) = substring(@SinkNodes,4,3))
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
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')------ij added SWTMEGAsnk
				AND
				t.pan not like '4%'
				AND
				t.tran_type NOT IN ('31','50')
                                and t.merchant_type not in ('5371')
                                and  ISNULL(y.rdm_amt,0) <> 0	
                AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
 OPTION  (RECOMPILE, MAXDOP 8)
				


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
			datetime_tran_local,source_node_name
			 OPTION  (RECOMPILE, MAXDOP 8)
END


GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b04_web_pos_all_Mastercard]    Script Date: 07/09/2016 23:16:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



alter PROCEDURE[dbo].[osp_rpt_b04_web_pos_all_Mastercard]
	@StartDate		CHAR(8),	-- yyyymmdd
	@EndDate			CHAR(8),	-- yyyymmdd
	@SinkNode		VARCHAR(255),
	@SourceNodes	VARCHAR(512),
	@show_full_pan	BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
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
		terminal_owner  		CHAR(12),
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
		tran_type_description	VARCHAR (500),
		rsp_code_description	VARCHAR (500),
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
			amount  DECIMAL(20,2),
		fee DECIMAL(20,2),
		no_above_limit  INT,
		amount_above_limit DECIMAL(20,2),
		tran_count INT 
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
				ISNULL(merchant_type,'VOID'),
				ISNULL(m.Category_name,'VOID'),
				ISNULL(m.Fee_type,'VOID'),
				ISNULL(m.merchant_disc,0.0),
				ISNULL(m.fee_cap,0),
				ISNULL(m.amount_cap,999999999999.99),
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
				
				--dbo.formatAmount(t.settle_amount_impact, t.settle_currency_code) as settle_amount_impact,
				
				dbo.formatAmount( 			
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END
					, t.settle_currency_code ) AS settle_amount_impact,				
				
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) as tran_type_description,
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
				extended_tran_type,
				0,0,0,0,0
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
				left JOIN tbl_merchant_category_web m (NOLOCK)
				ON t.merchant_type = m.category_code 
				
	
WHERE 			
	
				t.tran_completed = 1
				AND
				t.tran_postilion_originated = 0 
				AND
				(
				(t.message_type IN ('0100','0200', '0400', '0420')) 
				)
				AND 				
				t.tran_completed = 1
				AND
				t.tran_type NOT IN ('31','39','50')
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
				sink_node_name NOT IN ('CCLOADsnk','GPRsnk','VTUsnk')------ij added SWTMEGAsnk	
				AND left (pan,6) in ('512336','515803','530519','531525','533301','539941','547160','549970',
						'539923','533853','541569','539983','533856','552279','540761','532732')
                 AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'

			 OPTION  (RECOMPILE, MAXDOP 8)
				
	IF @@ROWCOUNT = 0
		INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)			
				
	SELECT 
		 StartDate,

		 EndDate,
		 card_acceptor_id_code, 
		 card_acceptor_name_loc, 
		 sink_node_name,
		 category_name, 
		 merchant_type,
		 tran_type,
		no_above_limit = convert(int, CASE
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200')THEN 1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100')THEN 1--ij changed this to cater for 0100 transactions which always have a zero
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400')THEN -1
			ELSE 0
			END ),
		amount_above_limit = convert(decimal(20,2), CASE
			--WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1WHEN ABS(settle_amount_impact) >= amount_cap then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0200') then settle_amount_impact * -1
			WHEN ABS(settle_amount_impact) >= amount_cap AND message_type IN('0420','0400') then settle_amount_impact * -1
			WHEN ABS(settle_amount_rsp) >= amount_cap AND message_type IN('0100') then settle_amount_rsp 		
			ELSE 0
            		END ),
		amount =  CONVERT(DECIMAL(20,2), settle_amount_impact * -1 ),
		fee =  CONVERT(DECIMAL(20,2),settle_tran_fee_rsp *-1 ),
		tran_count = CONVERT( INT, CASE			
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0200') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
                	WHEN tran_type IN ('00','09','01') and message_type IN ('0100') and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('00','09','01') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END),
			extended_tran_type,
			message_type,
			settle_amount_rsp

	 
	FROM 
			#report_result
	--GROUP BY
	--		StartDate, EndDate,category_name,merchant_type,sink_node_name,tran_type, card_acceptor_id_code, card_acceptor_name_loc -- tran_type_description, 
	ORDER BY 

			source_node_name, sink_node_name
			 OPTION  (RECOMPILE, MAXDOP 8)
	END


GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_all_verve]    Script Date: 07/09/2016 23:28:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







create PROCEDURE[dbo].[osp_rpt_b06_all_verve]--oremeyi modified the previous
	@StartDate		VARCHAR(30),	-- yyyymmdd
	@EndDate			VARCHAR(30),	-- yyyymmdd
	@SourceNode		VARCHAR(40),
	@show_full_pan	 BIT,
	@report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL

	
AS
BEGIN
	-- The B06 report uses this stored prot.
	

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON	

	CREATE TABLE #report_result
	(
		Warning						VARCHAR (255),	
		StartDate				VARCHAR (30),  
		EndDate				VARCHAR (30),
		pan							VARCHAR (19), 
		terminal_id                     CHAR (8), -- oremeyi added this
		terminal_owner			VARCHAR (40),
		source_node_name		VARCHAR (40), --- oremeyi added this
  		card_acceptor_id_code		VARCHAR (255), 
		card_acceptor_name_loc		VARCHAR (255), 
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
		system_trace_audit_nr		VARCHAR (6), 
		message_reason_code			VARCHAR (4), 
		retrieval_reference_nr		VARCHAR (12), 
		datetime_tran_local			DATETIME, 
		from_account_type			CHAR (2), 
		to_account_type				CHAR (2), 	
		tran_reversed				INT,	
		settle_currency_code		CHAR (3), 		
		settle_amount_impact		FLOAT,	
		rsp_code_description VARCHAR (500),
		settle_nr_decimals			INT,
		currency_alpha_code			CHAR (3),
		currency_name				VARCHAR (20),
		tran_type_desciption  VARCHAR (500),		
		isPurchaseTrx				INT,
		isWithdrawTrx				INT,
		isRefundTrx					INT,
		isDepositTrx				INT,
		isInquiryTrx				INT,
		isTransferTrx				INT,
		isOtherTrx					INT,
		retention_data				Varchar(999),
		fee	DECIMAL(20, 2),
	    amount DECIMAL(20,2),
        fee_group DECIMAL(20,2),
	    tran_count int,
	    INN varchar(255),
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
			0,0,0,0,''
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
								and
                                t.tran_completed = 1
			AND
			t.tran_postilion_originated = 0
				AND			
		
			t.message_type IN ('0200','0220','0400','0420') --- oremeyi removed 0100, 0120
			AND 
			
			t.tran_type IN ('01')
			AND
			rsp_code_rsp IN ('00','11','08','10','16')
			
	
WHERE 			

	 
			t.source_node_name not like 'SWTASP%'
			AND 
			t.source_node_name not like 'TSS%'
			AND 
			t.source_node_name not like '%WEB%'
			AND
			t.source_node_name not in ('SWTMEGAsrc','SWTATMCsrc','CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTSMPsrc')
			AND 
			t.sink_node_name not like 'TSS%'
            and t.sink_node_name not like '%TPP%'
            AND t.source_node_name  NOT LIKE '%TPP%'
			AND
			t.sink_node_name not in ('GPRsnk','CCLOADsnk','ESBCSOUTsnk')
             AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
			--AND
			--t.terminal_id like '1%'
             
				 OPTION  (RECOMPILE, MAXDOP 8)
			
			
			
	
	IF @@ROWCOUNT = 0	
			INSERT INTO #report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT   StartDate,
		 EndDate,
		 source_node_name,
		 IIN = left(pan,6),
		fee_group =  CONVERT(DECIMAL(20,2), ABS(settle_tran_fee_rsp)),
		 sink_node_name,
	fee =   CONVERT(DECIMAL(20,2),	 sum(settle_tran_fee_rsp)),
	amount =  CONVERT(DECIMAL(20,2),		 sum(settle_amount_impact)),
	tran_count = CONVERT(int,	SUM(CASE			
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed IN(0,1) THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 1 THEN 1
                	WHEN tran_type IN ('01','40') and message_type = '0200' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		WHEN tran_type IN ('01','40') and message_type = '0420' and rsp_code_rsp IN('00','11','08','10','16')and tran_reversed = 2 THEN 0 
            		END) )

	
	FROM
			#report_result

where pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '559453%' or pan like '519615%' or pan like '528668%'or pan like '528649%' or pan like '519909%'or pan like '551609%'--or pan like '63958%' and terminal_id not like '1ATM%' and terminal_id not like '1085%'
	
	
	GROUP BY
			StartDate, EndDate,ABS(settle_tran_fee_rsp),source_node_name, sink_node_name,left(pan,6)
	ORDER BY 
			left(pan,6),source_node_name
				 OPTION  (RECOMPILE, MAXDOP 8)
END


UPDATE reports_crystal SET output_params =  REPLACE(CONVERT(VARCHAR(MAX),output_params),'xls~NULL~','xls~0~') 
  WHERE template  LIKE  '%Settlement_Computation.rpt%'
  
  UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~2016/06/23 00:00:00~','~NULL~') 
  WHERE template  LIKE  '%Settlement_Computation.rpt%'
    
UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~~','~') 
  WHERE template  LIKE  '%Settlement_Computation.rpt%'
 
   
UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~~NULL~','~NULL~') 
  WHERE template  LIKE  '%Settlement_Computation.rpt%'
 
    
UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~~2015/12/11 00:00:00~2015/11/13 00:00:00~','~NULL~') 
  WHERE template  LIKE  '%Settlement_Computation.rpt%'
 
 
 UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~NULL 00:00:00~','~NULL~') 
   WHERE template  LIKE  '%Settlement Bank Net.rpt%'
 
 
     SELECT * FROM reports_entity ent  (NOLOCK) 
 JOIN
  reports_crystal cry (NOLOCK)
  ON
  ent.entity_id = cry.entity
  WHERE template  LIKE  '%Settlement Bank Net.rpt%'
 UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~NULL 00:00:00~','~NULL~') 
   WHERE template  LIKE  '%Settlement Bank Net.rpt%'
   UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~2016/06/23 00:00:00~','~NULL~') 
   WHERE template  LIKE  '%Settlement Bank Net.rpt%'
   UPDATE reports_crystal SET report_params =  REPLACE(CONVERT(VARCHAR(MAX),report_params),'~~','~') 
   WHERE template  LIKE  '%Settlement Bank Net.rpt%'
   
    
       
     UPDATE reports_crystal SET output_params =  REPLACE(CONVERT(VARCHAR(MAX),output_params),'xls~NULL~','xls~0~') 
     WHERE template  LIKE  '%Settlement Bank Net.rpt%'
     
      
      UPDATE reports_crystal SET 
      output_params='~E:\BANK REPORTS\SWT\Mastercard_Summary\MasterCard Locally Processed Summary.pdf~1~1~',
      report_params = '~NULL~NULL~NULL~NULL~NULL~NULL~Last Business Day~SWTASPPWCsnk,SWTPLATsnk,SWTFBNsnk,SWTCHBsnk,SWTUBNsnk,SWTUBPMPPsnk,SWTHaggaiSnk,SWTUBAsnk~NULL~NULL~'
      WHERE template  LIKE  '%MasterCard Locally Processed Summary.rpt%'
 
   
 INSERT INTO reports_template VALUES(740468939,	'Crystal',	'B11 - Remote On Us Summary_ATM_Detailed_Verve Int','Balancing')
 INSERT  INTO reports_crystal_template values (740468939,'Office\base\reports\Balancing\B11 - Remote On Us Summary_ATM_Detailed_Verve Int.rpt', 'EDITBOX=StartDate in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
+CHAR(13)+CHAR(10)+'EDITBOX=EndDate in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=SourceNodes:; 1000;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=merchants:; 512;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=show_full_pan:; 1000;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=report_date_start in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=report_date_end in ''yyyymmdd'' format:; 30;1;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=rpt_tran_id:; 1000;0;DEFAULT:NULL'
 +CHAR(13)+CHAR(10)+'EDITBOX=rpt_tran_id1:; 1000;0;DEFAULT:NULL'
 )
 update reports_entity set template_id = 740468939 WHERE name ='SWT_Remote_ATM_Detd_Verve_Int'
 
 






























































































































































































































































































































































































































































































































































































































































































































































































































































































































































































	