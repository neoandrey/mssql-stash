
ALTER     PROCEDURE [dbo].[osp_rpt_find_pending_reversals]
	@pan		VARCHAR(19),
	@StartDate		varchar(10),
	@EndDate		varchar (10)

AS BEGIN
	IF (OBJECT_ID('#temp_retrieval_ref_nr') IS NOT NULL)
	BEGIN
		DROP TABLE #temp_retrieval_ref_nr
	END

	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
		

	IF(@StartDate<> @EndDate) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @StartDate  AND recon_business_date >=  @StartDate   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @EndDate AND (recon_business_date < @EndDate ) ORDER BY datetime_req DESC)
	     SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @StartDate   AND recon_business_date >= @StartDate     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @EndDate AND (recon_business_date < @EndDate) ORDER BY datetime_req DESC)
	END
	ELSE IF(@StartDate= @EndDate) BEGIN
	    SET  @StartDate = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @StartDate),111),'/', '-') 
	    SET  @EndDate = DATEADD(D, 1,@EndDate)
	    SET  @EndDate = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @EndDate),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @StartDate  AND (recon_business_date >= @StartDate )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @EndDate  AND (recon_business_date < @EndDate ) ORDER BY recon_business_date DESC)
		
		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @StartDate AND (recon_business_date >= @StartDate )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @EndDate AND (recon_business_date < @EndDate  ) ORDER BY datetime_req DESC)
	END


	SELECT  
	retrieval_reference_nr INTO
		#temp_retrieval_ref_nr
	FROM 
	 	 post_tran pt(NOLOCK, INDEX(ix_post_tran_2)) 
	JOIN post_tran_cust ptc (NOLOCK, INDEX(pk_post_tran_cust))
		ON pt.post_tran_cust_id = ptc.post_tran_cust_id
	WHERE   (LEFT(ptc.pan,6) = LEFT(@pan,6) AND RIGHT(ptc.pan,4)= RIGHT(@pan,4))
		AND
		(pt.post_tran_cust_id >= @first_post_tran_cust_id) 
		AND 
		(pt.post_tran_cust_id <= @last_post_tran_cust_id) 
		AND
		(pt.post_tran_id >= @first_post_tran_id) 
		AND 
		(pt.post_tran_id <= @last_post_tran_id) 
		
		and ( CHARINDEX('CCsnk' ,sink_node_name) >0 or CHARINDEX('MPPsnk' ,sink_node_name) >0 )
		and tran_reversed = '0'
		and rsp_code_rsp = '00'
		and message_type = '0200'
		and tran_postilion_originated = '0';
	
	SELECT 
	        ptc.pan,
		from_account_id,
		ptc.terminal_id,
		ptc.card_acceptor_id_code,
		ptc.card_acceptor_name_loc,
	  	pt.message_type,
		pt.datetime_req,
		pt.system_trace_audit_nr,
		pt.retrieval_reference_nr,
		pt.tran_amount_req/100 as tran_amount,
		dbo.currencyAlphaCode(pt.tran_currency_code) as tran_currency,
		dbo.formatTranTypeStr(pt.tran_type, pt.extended_tran_type, pt.message_type) AS tran_type_description,
		dbo.formatRspCodeStr(pt.rsp_code_rsp) AS Response_Code_description,
		pt.settle_amount_rsp/100 as settle_amount,
		pt.settle_amount_impact/100 as settle_amount_Impact,
		dbo.currencyAlphaCode(pt.settle_currency_code) as settle_currency,
		pt.auth_id_rsp,
		ptc.post_tran_cust_id,
		pt.sink_node_name,
		ptc.source_node_name,
		pt.acquiring_inst_id_code,
		'Reversal Pending' as Reversal_Status
	    
	FROM 
	 	 post_tran pt(NOLOCK, INDEX(ix_post_tran_2)) 
	JOIN post_tran_cust ptc (NOLOCK, INDEX(pk_post_tran_cust))
		ON pt.post_tran_cust_id = ptc.post_tran_cust_id
	WHERE 
	         (LEFT(ptc.pan,6) = LEFT(@pan,6) AND RIGHT(ptc.pan,4)= RIGHT(@pan,4))
	
	and (pt.post_tran_cust_id >= @first_post_tran_cust_id) 
		AND 
		(pt.post_tran_cust_id <= @last_post_tran_cust_id) 
		AND
		(pt.post_tran_id >= @first_post_tran_id) 
		AND 
		(pt.post_tran_id <= @last_post_tran_id) 
         and pt.tran_postilion_originated = 0
	and rsp_code_rsp != '00'
	and (CHARINDEX('CCsnk' ,sink_node_name) <=0 AND CHARINDEX('MPPsnk' ,sink_node_name) <= 0 )
	and LEFT(source_node_name,3)  = 'WEB' 
	and tran_type in ('00','50')
	AND retrieval_reference_nr  IN ( SELECT  retrieval_reference_nr FROM #temp_retrieval_ref_nr)
	

	
END
	
	