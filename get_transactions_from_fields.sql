drop table #temp_tran_data

CREATE TABLE #temp_tran_data (tran_info varchar(255))

BULK INSERT #temp_tran_data FROM  'C:\temp\arbiter_data.csv' WITH (
         FIELDTERMINATOR =','
 	, ROWTERMINATOR='\n'
)

	DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SET @report_date_start = '2015-06-10'
	SET @report_date_end= '2015-06-12'
	
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

SELECT  DISTINCT dbo.usf_decrypt_pan(pan, pan_encrypted) clear, pan, terminal_id, retrieval_reference_nr, system_trace_audit_nr ,tran_nr, sink_node_name
FROM 
POST_TRAN trans (NOLOCK) LEFT JOIN POST_TRAN_CUST cust (NOLOCK) 
ON 
trans.post_tran_cust_id = cust.post_tran_cust_id
WHERE
	(trans.post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(trans.post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(trans.post_tran_id >= @first_post_tran_id) 
	AND 
	(trans.post_tran_id <= @last_post_tran_id)
	and

LOWER(terminal_id+'_'+system_trace_audit_nr+'_'+retrieval_reference_nr) IN ( SELECT LOWER(tran_info) FROM #temp_tran_data)
