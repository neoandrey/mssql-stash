
;WITH tss_sink_table (post_tran_id, post_tran_cust_id, tran_nr, system_trace_audit_nr, retrieval_reference_nr, source_node_name, sink_node_name,rsp_code_rsp,message_type)
AS
(SELECT post_tran_id, t.post_tran_cust_id, tran_nr, system_trace_audit_nr, retrieval_reference_nr, source_node_name, sink_node_name ,rsp_code_rsp,message_type
 FROM post_tran t  with (NOLOCK, INDEX(ix_post_tran_9)) 
  JOIN (	 SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]('20160714', '20160714')
									)  r
					on 
					t.recon_business_date = r.recon_business_date 
					AND 
					t.tran_completed = 1
					AND 
					T.tran_type = '50'
					AND 
					t.sink_node_name LIKE 'TSS%'
					AND 
					t.tran_postilion_originated = 0
					AND
						t.rsp_code_rsp 	IN ('91', '68')
						AND
			(
			  (t.message_type IN ('0200','0220','0600') AND t.tran_reversed IN (0, 1))
 			   OR
 			  ( t.message_type IN ('0400', '0420') AND tran_amount_rsp <> 0 )
 			  ) 
 			 	
JOIN
post_tran_cust c with (NOLOCK,INDEX(pk_post_tran_cust))
on t.post_tran_cust_id = c.post_tran_cust_id 
and c.terminal_id like '1%'
		 	AND
			c.terminal_id not LIKE '3IQT%'
			AND 
			c.terminal_id not LIKE '3AIM%'
			AND
			c.terminal_id not LIKE '3IBH%'
			--AND 
			---c.terminal_id not LIKE '3IDP%'
			AND
			c.terminal_id not LIKE '3IPT%'),
			
	tss_source_table (post_tran_id, post_tran_cust_id, tran_nr, system_trace_audit_nr, retrieval_reference_nr, source_node_name, sink_node_name,rsp_code_rsp,message_type)
AS		
(SELECT  post_tran_id, t.post_tran_cust_id, tran_nr, system_trace_audit_nr, retrieval_reference_nr, source_node_name, sink_node_name,rsp_code_rsp,message_type
  FROM post_tran t  with (NOLOCK, INDEX(ix_post_tran_9)) 
  JOIN (	 SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]('20160714', '20160714')
									)  r
					on 
					t.recon_business_date = r.recon_business_date 
					AND 
					t.tran_completed = 1
					AND 
					T.tran_type = '50'
					AND 
					t.tran_postilion_originated = 0
					AND
						
			(
			  (t.message_type IN ('0200','0220','0600') AND t.tran_reversed IN (0, 1))
 			   OR
 			  ( t.message_type IN ('0400', '0420') AND tran_amount_rsp <> 0 )
 			  ) AND
 			 	t.Sink_node_name <> 'CCLOADsnk' 
			AND
			t.Sink_node_name <> 'GPRsnk' 
			AND
			t.Sink_node_name <> 'VTUsnk' 
JOIN
post_tran_cust c with (NOLOCK,INDEX(pk_post_tran_cust))
on t.post_tran_cust_id = c.post_tran_cust_id 
AND Source_node_name like 'TSS%' 
and c.terminal_id like '1%'
		 	AND
			c.terminal_id not LIKE '3IQT%'
			AND 
			c.terminal_id not LIKE '3AIM%'
			AND
			c.terminal_id not LIKE '3IBH%'
			--AND 
			---c.terminal_id not LIKE '3IDP%'
			AND
			c.terminal_id not LIKE '3IPT%')
			
			
SELECT  s.post_tran_id , s.post_tran_cust_id, s.tran_nr, s.system_trace_audit_nr, s.retrieval_reference_nr, s.source_node_name, s.sink_node_name, t.rsp_code_rsp, s.rsp_code_rsp, t.message_type, s.message_type FROM 
tss_source_table s  JOIN tss_sink_table t
ON S.retrieval_reference_nr = t.retrieval_reference_nr
			