truncate table post_tran_summary_20170624



INSERT INTO post_tran_summary_20170624
(post_tran_id ,
				t.post_tran_cust_id ,
				prev_post_tran_id,
				sink_node_name,
				tran_postilion_originated,
				tran_completed,
				message_type,
				tran_type,
				tran_nr ,
				system_trace_audit_nr,
				rsp_code_req,
				rsp_code_rsp,
				abort_rsp_code,
				auth_id_rsp,
				retention_data,
				acquiring_inst_id_code,
				message_reason_code,
				retrieval_reference_nr,
				datetime_tran_gmt,
				datetime_tran_local ,
				datetime_req ,
				datetime_rsp,
				realtime_business_date ,
				recon_business_date ,
				from_account_type,
				to_account_type,
				from_account_id,
				to_account_id,
				tran_amount_req,
				tran_amount_rsp,
				settle_amount_impact,
				tran_cash_req,
				tran_cash_rsp,
				tran_currency_code,
				tran_tran_fee_req,
				tran_tran_fee_rsp,
				tran_tran_fee_currency_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_req,
				settle_tran_fee_rsp,
				settle_currency_code,
				tran_reversed,
				prev_tran_approved,
				extended_tran_type,
				payee,
				online_system_id,
				receiving_inst_id_code,
				routing_type,
				source_node_name ,
				pan,
				card_seq_nr,
				expiry_date,
				terminal_id,
				terminal_owner,
				card_acceptor_id_code,
				merchant_type,
				card_acceptor_name_loc,
				address_verification_data,
				totals_group,
				pan_encrypted)
SELECT  

post_tran_id ,
				t.post_tran_cust_id ,
				prev_post_tran_id,
				sink_node_name,
				tran_postilion_originated,
				tran_completed,
				message_type,
				tran_type,
				tran_nr ,
				system_trace_audit_nr,
				rsp_code_req,
				rsp_code_rsp,
				abort_rsp_code,
				auth_id_rsp,
				retention_data,
				acquiring_inst_id_code,
				message_reason_code,
				retrieval_reference_nr,
				datetime_tran_gmt,
				datetime_tran_local ,
				datetime_req ,
				datetime_rsp,
				realtime_business_date ,
				recon_business_date ,
				from_account_type,
				to_account_type,
				from_account_id,
				to_account_id,
				tran_amount_req,
				tran_amount_rsp,
				settle_amount_impact,
				tran_cash_req,
				tran_cash_rsp,
				tran_currency_code,
				tran_tran_fee_req,
				tran_tran_fee_rsp,
				tran_tran_fee_currency_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_req,
				settle_tran_fee_rsp,
				settle_currency_code,
				tran_reversed,
				prev_tran_approved,
				extended_tran_type,
				payee,
				online_system_id,
				receiving_inst_id_code,
				routing_type,
				source_node_name ,
				pan,
				card_seq_nr,
				expiry_date,
				terminal_id,
				terminal_owner,
				card_acceptor_id_code,
				merchant_type,
				card_acceptor_name_loc,
				address_verification_data,
				totals_group,
				pan_encrypted

FROM  (select 
post_tran_id ,
				post_tran.post_tran_cust_id ,
				prev_post_tran_id,
				sink_node_name,
				tran_postilion_originated,
				tran_completed,
				message_type,
				tran_type,
				tran_nr ,
				system_trace_audit_nr,
				rsp_code_req,
				rsp_code_rsp,
				abort_rsp_code,
				auth_id_rsp,
				retention_data,
				acquiring_inst_id_code,
				message_reason_code,
				retrieval_reference_nr,
				datetime_tran_gmt,
				datetime_tran_local ,
				datetime_req ,
				datetime_rsp,
				realtime_business_date ,
				recon_business_date ,
				from_account_type,
				to_account_type,
				from_account_id,
				to_account_id,
				tran_amount_req,
				tran_amount_rsp,
				settle_amount_impact,
				tran_cash_req,
				tran_cash_rsp,
				tran_currency_code,
				tran_tran_fee_req,
				tran_tran_fee_rsp,
				tran_tran_fee_currency_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_req,
				settle_tran_fee_rsp,
				settle_currency_code,
				tran_reversed,
				prev_tran_approved,
				extended_tran_type,
				payee,
				online_system_id,
				receiving_inst_id_code,
				routing_type 
				 FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) where RECON_business_date = '2017-06-24') 
				 t JOIN
				
				(select 
				post_tran_cust_id,
				 source_node_name ,
				pan,
				card_seq_nr,
				expiry_date,
				terminal_id,
				terminal_owner,
				card_acceptor_id_code,
				merchant_type,
				card_acceptor_name_loc,
				address_verification_data,
				totals_group,
				pan_encrypted 
				 FROM 
				 post_tran_cust (NOLOCK, index=pk_post_tran_cust )
				 
				 )
                 c
                 ON
                 t.post_tran_cust_id = c.post_tran_cust_id
OPTION (OPTIMIZE FOR UNKNOWN,MAXDOP 8)


exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks WebAcquired_csv' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';

exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks POSAcquired_csv' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';

exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks POSRemote_csv' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';


exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks Remote_POS_disk' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';


exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks WebPay_Acquired_disk' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';



exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks Remote_WEB_disk' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';


exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks Remote_Web_csv' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';




exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Banks Remote_On_Us_disk' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';


exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Beneficiary_Confirmation_Reports' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';

exec msdb.dbo.sp_start_job @job_name = 'Postilion Office - Reports - Bpayment_Verve_Billing' 
WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY '00:05:00'; WAITFOR DELAY '00:05:00';