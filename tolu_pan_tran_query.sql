SELECT datetime_req, pan, tran_nr, system_trace_audit_nr, retrieval_reference_nr, settle_amount_impact, tran_amount_req, tran_amount_rsp, source_node_name,sink_node_name, terminal_id, card_acceptor_id_code,  dbo.usf_decrypt_pan (pan, pan_encrypted) clear_pan INTO #TEMP_TABLE FROM 
 post_tran t WITH (NOLOCK, INDEX = ix_post_tran_2)  
   INNER JOIN  
   post_tran_cust c WITH (NOLOCK, INDEX = ix_post_tran_cust_1)
ON 
t.post_tran_cust_id  = c.post_tran_cust_id

 WHERE datetime_req >= '20160427' AND datetime_req <='20160429' AND pan LIKE '50610%3886'


select * from #TEMP_TABLE WHERE clear_pan = '5061000205023163886'