


ALTER                       	PROCEDURE osp_rpt_card_activity_speed_dated_2
	@MaskedPAN		VARCHAR(19),
	@fullpan		VARCHAR(19),
	@StartDate		varchar(10),
	@EndDate		varchar (10),
     --   @day_interval           INT
 
--- the script was modified by eseosa on 26-10-2011
-- script was modified to include requested date and time and also response code description
AS
BEGIN

DECLARE @date_diff DATETIME;
DECLARE @day_interval   INT;


IF EXISTS (SELECT * FROM temp.dbo.sysobjects WHERE ID = OBJECT_ID(N'#TEMP_RESULTS_TABLE'))
BEGIN
	DROP TABLE #TEMP_RESULTS_TABLE
END


SELECT  ISNULL(@day_interval, 5);

SELECT @date_diff = DATEADD(DAY, @day_interval, @StartDate );


SELECT	
			t.datetime_tran_local,
			t.datetime_req,
			c.terminal_id,
			c.card_acceptor_name_loc, 
			dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description, 
			t.retrieval_reference_nr, 	
			t.system_trace_audit_nr,		
			dbo.formatAmount(
					CASE
						WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
						ELSE t.settle_amount_impact
					END, t.settle_currency_code) AS settle_amount_impact,
			dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee,					
			dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
			t.from_account_id,
			dbo.rpt_fxn_account_type(t.from_account_type) AS from_account_type,
			t.to_account_id,
			dbo.rpt_fxn_account_type(t.to_account_type) AS to_account_type,
			c.post_tran_cust_id,
			t.sink_node_name,
			rsp_code_rsp,
			dbo.formatRspCodeStr(t.rsp_code_rsp) AS Response_Code_description,
			acquiring_inst_id_code,
			terminal_owner,
			payee
			
		INTO	#TEMP_RESULTS_TABLE
						
	FROM
			post_tran t (NOLOCK)
			INNER JOIN 
			post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)

	WHERE 		c.pan in (@MaskedPAN,@fullpan)
			AND (t.from_account_id = @fullpan or t.to_account_id = @fullpan)
			--and t.sink_node_name = 'UBACCsnk'
                        and t.tran_completed = 1
			--AND	(t.datetime_req >= @pdtStartDate) 
			--AND 	(t.datetime_req < @pdtEndDate) 
			AND 	t.tran_postilion_originated = 0 
			AND	(t.message_type IN ('0200','0220','0420') )--AND t.tran_reversed IN ('0', '1')
 			 	--or t.message_type IN ('0400', '0420') AND tran_amount_rsp <> 0 ) 
			AND	t.tran_type IN ('00', '01', '09', '20', '21', '40', '50' )
			--AND	t.rsp_code_rsp IN ('00', '11')
			AND	(c.source_node_name like '%SWTsrc' OR c.source_node_name = 'CCLOADsrc')
			AND t.datetime_req BETWEEN @StartDate AND  @date_diff
			
 WHILE (@date_diff <= @EndDate)
	BEGIN
	SELECT @StartDate = @date_diff;
	SELECT  @date_diff = DATEADD(DAY, @day_interval, @StartDate )
	
	INSERT  INTO	#TEMP_RESULTS_TABLE 
	SELECT	
				t.datetime_tran_local,
				t.datetime_req,
				c.terminal_id,
				c.card_acceptor_name_loc, 
				dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description, 
				t.retrieval_reference_nr, 	
				t.system_trace_audit_nr,		
				dbo.formatAmount(
						CASE
							WHEN (t.tran_type = '51') THEN -1 * t.settle_amount_impact
							ELSE t.settle_amount_impact
						END, t.settle_currency_code) AS settle_amount_impact,
				dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee,					
				dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
				t.from_account_id,
				dbo.rpt_fxn_account_type(t.from_account_type) AS from_account_type,
				t.to_account_id,
				dbo.rpt_fxn_account_type(t.to_account_type) AS to_account_type,
				c.post_tran_cust_id,
				t.sink_node_name,
				rsp_code_rsp,
				dbo.formatRspCodeStr(t.rsp_code_rsp) AS Response_Code_description,
				acquiring_inst_id_code,
				terminal_owner,
				payee
				
									
		FROM
				post_tran t (NOLOCK)
				INNER JOIN 
				post_tran_cust c (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	
		WHERE 		c.pan in (@MaskedPAN,@fullpan)
				AND (t.from_account_id = @fullpan or t.to_account_id = @fullpan)
				--and t.sink_node_name = 'UBACCsnk'
	                        and t.tran_completed = 1
				--AND	(t.datetime_req >= @pdtStartDate) 
				--AND 	(t.datetime_req < @pdtEndDate) 
				AND 	t.tran_postilion_originated = 0 
				AND	(t.message_type IN ('0200','0220','0420') )--AND t.tran_reversed IN ('0', '1')
	 			 	--or t.message_type IN ('0400', '0420') AND tran_amount_rsp <> 0 ) 
				AND	t.tran_type IN ('00', '01', '09', '20', '21', '40', '50' )
				--AND	t.rsp_code_rsp IN ('00', '11')
				AND	(c.source_node_name like '%SWTsrc' OR c.source_node_name = 'CCLOADsrc')
			AND t.datetime_req BETWEEN @StartDate AND  @date_diff
	
	
	
	
	END
	
	SELECT * FROM #TEMP_RESULTS_TABLE ORDER BY datetime_req desc
	
	IF EXISTS (SELECT * FROM temp.dbo.sysobjects WHERE ID = OBJECT_ID(N'#TEMP_RESULTS_TABLE'))
		BEGIN
			DROP TABLE #TEMP_RESULTS_TABLE
		END


END



















GO
