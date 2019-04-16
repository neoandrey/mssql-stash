IF(OBJECT_ID('#temp_results_table') IS NOT NULL)
BEGIN
DROP TABLE #temp_results_table
END
DECLARE @pan VARCHAR(100);
DECLARE @pan_list VARCHAR(8000)

SET @pan_list =  '5170581046039352,5170581473034520';

DECLARE @masked_pan_table TABLE (serial_number INT IDENTITY(1,1), pan VARCHAR(100), left_pan_six CHAR(6), right_pan_four CHAR(4));
INSERT INTO @masked_pan_table (pan) SELECT part FROM usf_split_string(@pan_list, ',')

DECLARE pan_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT pan FROM  @masked_pan_table
OPEN pan_cursor
FETCH NEXT FROM pan_cursor INTO @pan

WHILE (@@FETCH_STATUS =0) BEGIN

 	INSERT INTO @masked_pan_table (left_pan_six, right_pan_four) VALUES (LEFT(@pan, 6), RIGHT(@pan,4))
	FETCH NEXT FROM pan_cursor INTO @pan
END

CLOSE pan_cursor;
DEALLOCATE pan_cursor


DECLARE @report_date_start datetime;
DECLARE @report_date_end datetime;

SET @report_date_start ='20150501'
SET @report_date_end ='20150601'

	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP 1 @first_post_tran_id=post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start order by datetime_req DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
	SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
		SELECT TOP 1 @first_post_tran_id=post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP 1 @last_post_tran_id=post_tran_id  FROM post_tran (NOLOCK,INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by datetime_req DESC
	END
	
	
	SELECT 
		datetime_req, post_tran_id, trans.post_tran_cust_id, pan,pan_encrypted, pan_search, tran_nr, retrieval_reference_nr, system_trace_audit_nr
	INTO 
		#temp_results_table
	FROM post_tran trans (NOLOCK, INDEX(ix_post_tran_1)) LEFT JOIN post_tran_cust cust (NOLOCK) 
	ON trans.post_tran_cust_id = cust.post_tran_cust_id 
	WHERE 
	LEFT(pan,6) IN (SELECT left_pan_six FROM @masked_pan_table) AND RIGHT(pan,4) IN (SELECT right_pan_four FROM @masked_pan_table) 
	AND 
	post_tran_id >=@first_post_tran_id AND post_tran_id <=@last_post_tran_id;
	
	
	SELECT datetime_req, dbo.usf_decrypt_pan(pan,pan_encrypted) clear_pan, post_tran_id, post_tran_cust_id, pan,pan_encrypted, pan_search, tran_nr, retrieval_reference_nr, system_trace_audit_trace_nr
	FROM 
	#temp_results_table
	WHERE 
	dbo.usf_decrypt_pan(pan,pan_encrypted) IN ('5170581046039352','5170581473034520')
	