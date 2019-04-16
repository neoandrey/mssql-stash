CREATE PROCEDURE dbo.usp_linked_account_query ( @report_date_start DATETIME,  @report_date_end   DATETIME) AS
	BEGIN
	
    SET @report_date_start = CONVERT(VARCHAR(10),GETDATE()-7,120)
    SET @report_date_end= CONVERT(VARCHAR(10),GETDATE(),120)

;WITH  response_table (rsp_code_rsp, rsp_count) 
	AS 
	(
		SELECT  rsp_code_rsp
		,count(*)
		FROM 
		( SELECT * FROM POST_TRAN trans (NOLOCK, INDEX(ix_post_tran_9))  
			JOIN
			(SELECT [date] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start, @report_date_end)) r
			ON 
			trans.recon_business_date =  r.rec_bus_date
			AND tran_type = 39
			AND message_type IN ('0200', '0100')
		 ) 
		 t 
		 LEFT JOIN POST_TRAN_CUST cust (NOLOCK, INDEX(pk_post_tran_cust)) 
		ON 
		t.post_tran_cust_id = cust.post_tran_cust_id
		    GROUP BY
		rsp_code_rsp
	)
	SELECT * FROM response_table	
	ORDER BY rsp_count desc
    OPTION (RECOMPILE)
		 
END

CREATE PROCEDURE dbo.usp_analysis_deposit_transfers(@report_date_start DATETIME,  @report_date_end   DATETIME) AS
BEGIN
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	SET NOCOUNT ON
    SET @report_date_start = CONVERT(VARCHAR(10),GETDATE()-7,120)
    SET @report_date_end= CONVERT(VARCHAR(10),GETDATE(),112)

;WITH  response_table (rsp_code_rsp, rsp_count) 
	AS 
	(
		SELECT  rsp_code_rsp
		,count(*)
		FROM 
		( SELECT * FROM POST_TRAN trans (NOLOCK, INDEX(ix_post_tran_9))  
			JOIN
			(SELECT [date] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start, @report_date_end)) r
			ON 
			trans.recon_business_date =  r.rec_bus_date	
	AND  tran_type = 21
	AND message_type IN ('0200','0100')
	AND sink_node_name <> 'POSSWTsnk'		 ) 
		 t 
		 LEFT JOIN POST_TRAN_CUST cust (NOLOCK, INDEX(pk_post_tran_cust)) 
		ON 
		t.post_tran_cust_id = cust.post_tran_cust_id
		    GROUP BY
		rsp_code_rsp
	)
	SELECT * FROM response_table	
	ORDER BY rsp_count desc
    OPTION (RECOMPILE)
		 
		 
END