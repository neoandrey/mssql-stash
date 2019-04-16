SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT   
[post_tran_id]
      ,t.[post_tran_cust_id]
      ,[prev_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,t.[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_currency_code]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[extended_tran_type]
      ,[payee]
      ,[online_system_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_name]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[totals_group]
      ,[pan_encrypted]


FROM 
POST_TRAN t  WITH (NOLOCK, index (ix_post_tran_9))
 JOIN (SELECT [date] recon_business_date FROM [get_dates_in_range]('20170712','20170712'))r
on
r.recon_business_date = t.recon_business_date
 LEFT JOIN POST_TRAN_CUST c WITH  (NOLOCK,INDEX(pk_post_tran_cust)) 
ON 
t.post_tran_cust_id = c.post_tran_cust_id

OPTION(recompile, maxdop 6)














=======================================

SELECT   
[post_tran_id]
      ,t.[post_tran_cust_id]
      ,[prev_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,t.[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_currency_code]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[extended_tran_type]
      ,[payee]
      ,[online_system_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_name]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[totals_group]
      ,[pan_encrypted]


FROM 
POST_TRAN t (NOLOCK, index (ix_post_tran_9)) LEFT JOIN POST_TRAN_CUST c (NOLOCK, INDEX(ix_post_tran_cust_1)) 
ON 
t.post_tran_cust_id = cust.post_tran_cust_id
AND
( JOIN (SELECT [date] recon_business_date FROM [get_dates_in_range]('20170712','20170712'))r)
r.recon_business_date = t.recon_business_date

UNION ALL



SELECT   
[post_tran_id]
      ,t.[post_tran_cust_id]
      ,[prev_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,t.[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_currency_code]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[extended_tran_type]
      ,[payee]
      ,[online_system_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_name]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[totals_group]
      ,[pan_encrypted]


FROM 
POST_TRAN t (NOLOCK, index (ix_post_tran_9)) 

 JOIN (SELECT [date] recon_business_date FROM [get_dates_in_range]('20161009','20161009'))r ON r.recon_business_date = t.recon_business_date  JOIN POST_TRAN_CUST c (NOLOCK, INDEX(pk_post_tran_cust)) 
 ON  t.post_tran_cust_id = c.post_tran_cust_id

OPTION (recompile, maxdop 16)

SELECT   
[post_tran_id]
      ,t.[post_tran_cust_id]
      ,[prev_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,t.[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_currency_code]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[extended_tran_type]
      ,[payee]
      ,[online_system_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_name]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[totals_group]
      ,[pan_encrypted]
	  ,pos_entry_mode


FROM 
(  SELECT * FROM post_tran pt (NOLOCK, index (ix_post_tran_9))   JOIN 
 (SELECT [date] rec_business_date FROM [get_dates_in_range]('20170711','20170711'))r ON r.rec_business_date = pt.recon_business_date 
 ) t 

  JOIN POST_TRAN_CUST c (NOLOCK, INDEX(pk_post_tran_cust)) 
 ON  t.post_tran_cust_id = c.post_tran_cust_id

OPTION (recompile)