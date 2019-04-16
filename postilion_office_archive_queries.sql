XML ARCHIVE QUERY
==================================================
  SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
  
  SELECT 
       [post_tran_id]
      ,[post_tran_cust_id]  
      ,[tran_nr]
      ,[system_trace_audit_nr] 
      ,[retrieval_reference_nr]
      ,[recon_business_date]
      ,[icc_data_req]
      ,[icc_data_rsp]
      ,[structured_data_req]
      ,[structured_data_rsp]

FROM 
POST_TRAN t (NOLOCK, index (ix_post_tran_9)) 
 JOIN (SELECT [date] recon_business_date FROM [get_dates_in_range]('20151201','20151231')) r ON
r.recon_business_date = t.recon_business_date
OPTION (maxdop 16)


===================================================
post_tran_cust archive query
===================================
DECLARE @currentDate DATETIME;
DECLARE @lastDate DATETIME;
DECLARE @first_post_tran_cust_id BIGINT
DECLARE @last_post_tran_cust_id BIGINT

SET @currentDate = '20151201'
SET @lastDate = '210831978'


select  MIN(post_tran_cust_id) FROM post_tran (NOLOCK) where recon_business_date = '20151201'
select MAX(post_tran_cust_id) FROM post_tran (NOLOCK) where recon_business_date = '20151231'

SELECT   [post_tran_cust_id]
      ,[source_node_name]
      ,[draft_capture]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[service_restriction_code]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[mapped_card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[check_data]
      ,[totals_group]
      ,[card_product]
      ,[pos_card_data_input_ability]
      ,[pos_cardholder_auth_ability]
      ,[pos_card_capture_ability]
      ,[pos_operating_environment]
      ,[pos_cardholder_present]
      ,[pos_card_present]
      ,[pos_card_data_input_mode]
      ,[pos_cardholder_auth_method]
      ,[pos_cardholder_auth_entity]
      ,[pos_card_data_output_ability]
      ,[pos_terminal_output_ability]
      ,[pos_pin_capture_ability]
      ,[pos_terminal_operator]
      ,[pos_terminal_type]
      ,[pan_search]
      ,[pan_encrypted]
      ,[pan_reference]
      ,[card_acceptor_id_code_cs]
  FROM [postilion_office].[dbo].[post_tran_cust] (Nolock , INDEX(pk_post_tran_cust)) WHERE
  post_tran_cust_id>=114711824 AND post_tran_cust_id<=210831978
  OPTION (MAXDOP 16)
  
  ========================================
  post_tran Archive query
  =======================================
  
  

DECLARE @currentDate DATETIME;
DECLARE @lastDate DATETIME;

SET @currentDate = '20151201'
SET @lastDate = '20151231'



SELECT 
       [post_tran_id]
      ,[post_tran_cust_id]
      ,[settle_entity_id]
      ,[batch_nr]
      ,[prev_post_tran_id]
      ,[next_post_tran_id]
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
      ,[auth_type]
      ,[auth_reason]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[sponsor_bank]
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
      ,[tran_proc_fee_req]
      ,[tran_proc_fee_rsp]
      ,[tran_proc_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_cash_req]
      ,[settle_cash_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_proc_fee_req]
      ,[settle_proc_fee_rsp]
      ,[settle_currency_code]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[additional_rsp_data]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[issuer_network_id]
      ,[acquirer_network_id]
      ,[extended_tran_type]
      ,[ucaf_data]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[bank_details]
      ,[payee]
      ,[card_verification_result]
      ,[online_system_id]
      ,[participant_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[pt_pos_operating_environment]
      ,[pt_pos_card_input_mode]
      ,[pt_pos_cardholder_auth_method]
      ,[pt_pos_pin_capture_ability]
      ,[pt_pos_terminal_operator]
      ,[source_node_key]
      ,[proc_online_system_id]
      ,[opp_participant_id]

FROM 
POST_TRAN t (NOLOCK, index (ix_post_tran_9)) 
 JOIN (SELECT [date] recon_business_date FROM [get_dates_in_range]('20151201','20151231')) r ON
r.recon_business_date = t.recon_business_date
OPTION (maxdop 16)