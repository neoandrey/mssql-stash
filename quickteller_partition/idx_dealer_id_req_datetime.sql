CREATE INDEX 
 ON [dbo].[tbl_transactions] ([dealer_id] ) 
include
(   req_datetime,   transaction_id, tran_seq_id, telco_domain_id, issuer_domain_id, pan, terminal_id, stan,
acquirer_id, merchant_id, location, network_id, message_type, txn_value, postilion_ref_id, dealer_msisdn,
subscriber_msisdn, res_datetime, account_balance, transaction_type, host_sequence_nr, prev_postilion_response_code,
prev_postilion_response_message, postilion_response_code, postilion_response_message, vtu_response_code,
vtu_response_message, local_tran_datetime) 

WITH (FILLFACTOR=90, ONLINE=ON)
ON 
partition_vtucare_transactions_by_month_partition_scheme(req_datetime)