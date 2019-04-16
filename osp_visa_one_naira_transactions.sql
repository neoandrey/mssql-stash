ALTER PROCEDURE  osp_visa_one_naira_transactions  @acquiring_inst_id_code VARCHAR(250), @startDate VARCHAR(30), @endDate VARCHAR(30)

AS
BEGIN

SET @startDate = ISNULL(@startDate,REPLACE(CONVERT(VARCHAR(10),DATEADD(D,-1, DATEDIFF(D,0, GETDATE())) ,111),'/', ''))
SET @endDate = ISNULL(@endDate, REPLACE(CONVERT(VARCHAR(10), DATEADD(D,0, DATEDIFF(D,0, GETDATE())),111),'/', '-'))
set @acquiring_inst_id_code = ISNULL(@acquiring_inst_id_code, '');


SELECT @startDate start_date,  @endDate end_date, acquiring_inst_id_code,datetime_req, card_acceptor_id_code, terminal_id, card_acceptor_name_loc, merchant_type, system_trace_audit_nr, retrieval_reference_nr, tran_amount_rsp, auth_id_rsp FROM post_tran trans (NOLOCK, INDEX(ix_post_tran_8)) JOIN post_tran_cust cst  (NOLOCK, INDEX(ix_post_tran_cust_1)) ON  trans.post_tran_cust_id = cst.post_tran_cust_id
 WHERE tran_amount_rsp =100 AND message_type IN  ('0200','0220') AND LEFT(cst.pan, 1)='4' AND tran_currency_code='566'
AND tran_postilion_Originated =0 
and datetime_req>=  @startDate AND datetime_req <  @endDate
AND sink_node_name = 'MEGGTBVB2snk' and acquiring_inst_id_code LIKE  '%'+@acquiring_inst_id_code+'%';

END
