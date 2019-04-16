exec osp_tranqry_crdhldr_open_pan '4714151100055003','00FFBF8E676AE374430694883D6A1EE578F68D1EA8','2015-07-01 00:00:00:000','2015-07-06 00:00:00:000',NULL,NULL,NULL,-1,NULL

  
  
  SELECT datetime_req, pan, tran_nr, system_trace_audit_nr, retrieval_reference_nr, settle_amount_impact, tran_amount_req, tran_amount_rsp, source_node_name,sink_node_name, terminal_id, card_acceptor_id_code,  dbo.usf_decrypt_pan (pan, pan_encrypted) clear_pan INTO #TEMP_TABLE FROM 
 post_tran t WITH (NOLOCK, INDEX = ix_post_tran_2)  
   INNER JOIN  
   post_tran_cust c WITH (NOLOCK, INDEX = ix_post_tran_cust_1)
ON 
t.post_tran_cust_id  = c.post_tran_cust_id

 WHERE datetime_req >= '20160427' AND datetime_req <='20160429' AND pan LIKE '50610%3886'


select * from #TEMP_TABLE WHERE clear_pan = '5061000205023163886'

  
CREATE PROCEDURE [dbo].[osp_tranqry_crdhldr_open_pan]  
 @pan VARCHAR(19),  
 @pan_reference VARCHAR(42),  
 @from_datetime_tran_local DATETIME,  
 @to_datetime_tran_local DATETIME,  
 @source_node_name VARCHAR(30),  
 @card_acceptor_id_code CHAR(15),  
 @terminal_id CHAR(8),  
 @online_system_id INT,  
 @system_trace_audit_nr CHAR(6)  
 WITH EXECUTE AS OWNER  
AS  
BEGIN  
 -- For compatibility with Microsoft OLEDB  
 SET NOCOUNT ON;  
 SET ANSI_WARNINGS OFF;  
  
 -- Is this user a participant?  
 DECLARE @is_participant INT  
 EXECUTE osp_part_is @is_participant OUTPUT  
  
 IF (@online_system_id < 0) SET @online_system_id = NULL  
 SET @to_datetime_tran_local = @to_datetime_tran_local + 1  
  
 DECLARE @sql NVARCHAR(4000)  
  
 SET @sql =  N'  
  SELECT  
   post_tran.tran_nr,  
   post_tran.post_tran_id,  
     post_tran.datetime_req,  
     post_tran.datetime_tran_local,  
     post_tran.message_type,  
     post_tran.message_reason_code,  
     post_tran.tran_type,  
     post_tran.extended_tran_type,  
     post_tran.tran_amount_req,  
     post_tran.tran_currency_code,  
     post_tran.rsp_code_rsp,  
     post_tran.sink_node_name,  
   post_tran_cust.pan,  
   post_tran_cust.pan_encrypted,  
   post_tran_cust.card_acceptor_id_code,  
   post_tran_cust.terminal_id,  
   post_tran.system_trace_audit_nr,  
   post_tran_cust.source_node_name,  
   post_tran_cust.post_tran_cust_id,  
   post_tran.online_system_id  
  FROM  
   post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)  
   INNER JOIN  
   post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_1)  
    ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id  
  WHERE  
   pan = @pan  
   AND  
   datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local'  
  
 IF(@source_node_name IS NOT NULL)  
 SET @sql = @sql +N'  
  AND source_node_name = @source_node_name'  
  
 IF(@card_acceptor_id_code IS NOT NULL)  
 SET @sql = @sql + N'  
  AND card_acceptor_id_code = @card_acceptor_id_code'  
  
 IF(@terminal_id IS NOT NULL)  
 SET @sql = @sql + N'  
  AND terminal_id = @terminal_id'  
  
 IF(@online_system_id IS NOT NULL)  
 SET @sql = @sql + N'  
  AND online_system_id = @online_system_id'  
  
 IF(@system_trace_audit_nr IS NOT NULL)  
 SET @sql = @sql +N'  
  AND system_trace_audit_nr = @system_trace_audit_nr'  
  
 IF(@is_participant = 1)  
  SET @sql = @sql + N'  
   AND dbo.ofn_part_view_tran_2(post_tran.online_system_id, post_tran.participant_id, post_tran.opp_participant_id) = 1'  
 ELSE  
  SET @sql = @sql + N'  
   AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN (''0522'', ''0523'', ''0322'', ''0323'')))'  
  
 SET @sql = @sql + '  
  UNION  
  SELECT  
   post_tran.tran_nr,  
   post_tran.post_tran_id,  
     post_tran.datetime_req,  
     post_tran.datetime_tran_local,  
     post_tran.message_type,  
     post_tran.message_reason_code,  
     post_tran.tran_type,  
     post_tran.extended_tran_type,  
     post_tran.tran_amount_req,  
     post_tran.tran_currency_code,  
     post_tran.rsp_code_rsp,  
     post_tran.sink_node_name,  
   post_tran_cust.pan,  
   post_tran_cust.pan_encrypted,  
   post_tran_cust.card_acceptor_id_code,  
   post_tran_cust.terminal_id,  
   post_tran.system_trace_audit_nr,  
   post_tran_cust.source_node_name,  
   post_tran_cust.post_tran_cust_id,  
   post_tran.online_system_id  
  FROM  
   post_tran WITH (NOLOCK, INDEX = ix_post_tran_2)  
   INNER JOIN  
   post_tran_cust WITH (NOLOCK, INDEX = ix_post_tran_cust_4)  
    ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id  
  WHERE  
   pan_reference = @pan_reference  
   AND  
   datetime_tran_local BETWEEN @from_datetime_tran_local AND @to_datetime_tran_local'  
  
 IF(@source_node_name IS NOT NULL)  
 SET @sql = @sql +N'  
  AND source_node_name = @source_node_name'  
  
 IF(@card_acceptor_id_code IS NOT NULL)  
 SET @sql = @sql + N'  
  AND card_acceptor_id_code = @card_acceptor_id_code'  
  
 IF(@terminal_id IS NOT NULL)  
 SET @sql = @sql + N'  
  AND terminal_id = @terminal_id'  
  
 IF(@online_system_id IS NOT NULL)  
 SET @sql = @sql + N'  
  AND online_system_id = @online_system_id'  
  
 IF(@system_trace_audit_nr IS NOT NULL)  
 SET @sql = @sql +N'  
  AND system_trace_audit_nr = @system_trace_audit_nr'  
  
 IF(@is_participant = 1)  
  SET @sql = @sql + N'  
   AND dbo.ofn_part_view_tran_2(post_tran.online_system_id, post_tran.participant_id, post_tran.opp_participant_id) = 1'  
 ELSE  
  SET @sql = @sql + N'  
   AND (tran_postilion_originated = 0 OR (tran_postilion_originated = 1 AND message_type IN (''0522'', ''0523'', ''0322'', ''0323'')))'  
  
 SET @sql = @sql +N'  
  ORDER BY datetime_tran_local ASC'  
  
 SET @sql = @sql +N' OPTION (RECOMPILE)'  
  
 EXEC sp_executesql @sql, N'  
  @pan VARCHAR(19),  
  @pan_reference VARCHAR(42),  
  @from_datetime_tran_local DATETIME,  
  @to_datetime_tran_local DATETIME,  
  @source_node_name VARCHAR(30),  
  @card_acceptor_id_code CHAR(15),  
  @terminal_id CHAR(8),  
  @online_system_id INT,  
  @system_trace_audit_nr CHAR(6)',  
  @pan = @pan,  
  @pan_reference = @pan_reference,  
  @from_datetime_tran_local = @from_datetime_tran_local,  
  @to_datetime_tran_local = @to_datetime_tran_local,  
  @source_node_name = @source_node_name,  
  @card_acceptor_id_code = @card_acceptor_id_code,  
  @terminal_id = @terminal_id,  
  @online_system_id = @online_system_id,  
  @system_trace_audit_nr = @system_trace_audit_nr  
END  
  