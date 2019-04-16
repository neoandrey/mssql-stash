IF(object_id('tempdb.dbo.#temp_table_count') IS NOT NULL ) BEGIN
drop table #temp_table_count
END

IF(object_id('tempdb.dbo.#temp_table') IS NOT NULL ) BEGIN
drop table #temp_table
END


DECLARE @report_date_start datetime
DECLARE	@report_date_end datetime

SET @report_date_start = '2016-07-12 13:00:00'
SET @report_date_end = '2016-07-12 17:00:00'

SELECT  online_system_id, rsp_code_rsp, COUNT(rsp_code_rsp) rsp_count, 0 [percentage] into #temp_table  FROM post_tran (NOLOCK, INDEX(ix_post_tran_7))
WHERE datetime_req >= report_date_start AND  datetime_req <= @report_date_end 
GROUP BY  online_system_id,rsp_code_rsp

SELECT online_system_id, COUNT (recon_business_date) total_count into #temp_table_count  FROM post_tran (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= report_date_start AND  datetime_req <= @report_date_end 
group by online_system_id

UPDATE #temp_table SET  [percentage] = (CONVERT(FLOAT,rsp_count)/CONVERT(FLOAT, total_count)) *100.0 FROM #temp_table temp JOIN #temp_table_count ct ON temp.online_system_id = ct.online_system_id


SELECT name,rsp_code_rsp, dbo.formatRspCodeStr(rsp_code_rsp)[description],rsp_count,percentage  from  #temp_table  t join post_online_system syt (NOLOCK)
ON t.online_system_id = syt.online_system_id
ORDER BY NAME,rsp_count desc
