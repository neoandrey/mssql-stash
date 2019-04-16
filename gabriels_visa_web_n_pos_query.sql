SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160301','20160331') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) = '2'
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160401','20160430') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) = '2'
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)



SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160501','20160531') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) = '2'
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160601','20160630') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) = '2'
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160701','20160731') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) = '2'
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)
==============================================================================================================================

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160301','20160331') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) IN ('3', '4')
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160401','20160430') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) IN ('3', '4')
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)



SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160501','20160531') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) IN ('3', '4')
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160601','20160630') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) IN ('3', '4')
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)

SELECT 

datetime_req ,card_acceptor_name_loc,terminal_id ,tran_amount_req,tran_amount_rsp, LEFT(pan,6) ,Pan ,acquiring_inst_id_code ,sink_node_name as issuing_bank ,retrieval_reference_nr, rsp_code_rsp ,system_trace_audit_nr, source_node_name , merchant_type

FROM post_tran t (NOLOCK, index(ix_post_tran_9))
JOIN
(SELECT [date] recon_business_date FROM dbo.get_dates_in_range('20160701','20160731') )r
ON
r.recon_business_date = t.recon_business_date 

 JOIN post_tran_cust c (NOLOCK)
ON
t.post_tran_cust_id = c.post_tran_cust_id AND LEFT(terminal_id ,1 ) IN ('3', '4')
AND LEFT(pan ,1 ) = '4'
OPTION (RECOMPILE)
