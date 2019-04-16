SELECT  post_tran_id, trans.post_tran_cust_id, retrieval_reference_nr, system_trace_audit_nr, auth_id_rsp, tran_nr, sink_node_name, source_node_name  INTO #gen_nibbs_table
FROM 
post_tran trans (NOLOCK) JOIN post_tran_cust cst (NOLOCK) ON trans.post_tran_cust_id = cst.post_tran_cust_id

WHERE source_node_name IN ('SWTNCSsrc', 'SWTNCS2src') AND datetime_req >='2014-11-10 00:00:00' AND datetime_req <='20141117 12:00:00'


SELECT  post_tran_id, trans.post_tran_cust_id, retrieval_reference_nr, system_trace_audit_nr, auth_id_rsp, tran_nr, sink_node_name, source_node_name  INTO #asp_nibbs_table
FROM 
post_tran trans (NOLOCK) JOIN post_tran_cust cst (NOLOCK) ON trans.post_tran_cust_id = cst.post_tran_cust_id

WHERE source_node_name = 'SWTASPPOSsrc' AND datetime_req >='2014-11-10 00:00:00' AND datetime_req <='20141117 12:00:00'


SELECT * FROM #gen_nibbs_table WHERE retrieval_reference_nr NOT IN (SELECT retrieval_reference_nr FROM #asp_nibbs_table) AND system_trace_audit_nr NOT IN (SELECT system_trace_audit_nr FROM #asp_nibbs_table)


SELECT * FROM #asp_nibbs_table WHERE retrieval_reference_nr  IN (SELECT retrieval_reference_nr FROM #gen_nibbs_table) AND system_trace_audit_nr  IN (SELECT system_trace_audit_nr FROM #gen_nibbs_table) 
 AND CHARINDEX('FCMB', sink_node_name) >0 AND LEFT(sink_node_name,2) <> 'SB'
 
 
 SELECT * FROM #asp_nibbs_table WHERE retrieval_reference_nr  IN (SELECT retrieval_reference_nr FROM #gen_nibbs_table) AND system_trace_audit_nr  IN (SELECT system_trace_audit_nr FROM #gen_nibbs_table) 
 AND CHARINDEX('FCMB', sink_node_name) >0 AND LEFT(sink_node_name,2) = 'SB'