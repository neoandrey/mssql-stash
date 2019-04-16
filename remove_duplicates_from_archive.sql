DECLARE @dup_post_tran_id BIGINT;

CREATE TABLE #temp_post_tran(
	[post_tran_id] [bigint] NOT NULL,
	[post_tran_cust_id] [bigint] NOT NULL,
	[settle_entity_id] [BIGINT] NULL,
	[batch_nr] [int] NULL,
	[prev_post_tran_id] [bigint] NULL,
	[next_post_tran_id] [bigint] NULL,
	[sink_node_name] VARCHAR(30) NULL,
	[tran_postilion_originated] BIT NOT NULL,
	[tran_completed] BIT NOT NULL,
	[message_type] [char](4) NOT NULL,
	[tran_type] [char](2) NULL,
	[tran_nr] [bigint] NOT NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[rsp_code_req] [char](2) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[abort_rsp_code] [char](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[auth_type] [numeric](1, 0) NULL,
	[auth_reason] [numeric](1, 0) NULL,
	[retention_data] [varchar](999) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [char](4) NULL,
	[sponsor_bank] [char](8) NULL,
	[retrieval_reference_nr] [char](12) NULL,
	[datetime_tran_gmt] [datetime] NULL,
	[datetime_tran_local] [datetime] NOT NULL,
	[datetime_req] [datetime] NOT NULL,
	[datetime_rsp] [datetime] NULL,
	[realtime_business_date] [datetime] NOT NULL,
	[recon_business_date] [datetime] NOT NULL,
	[from_account_type] [char](2) NULL,
	[to_account_type] [char](2) NULL,
	[from_account_id] [varchar](28) NULL,
	[to_account_id] [varchar](28) NULL,
	[tran_amount_req] [numeric](20,4) NULL,
	[tran_amount_rsp] [numeric](20,4) NULL,
	[settle_amount_impact] [numeric](20,4) NULL,
	[tran_cash_req] [numeric](20,4) NULL,
	[tran_cash_rsp] [numeric](20,4) NULL,
	[tran_currency_code] VARCHAR (3) NULL,
	[tran_tran_fee_req] [numeric](20,4) NULL,
	[tran_tran_fee_rsp] [numeric](20,4) NULL,
	[tran_tran_fee_currency_code] VARCHAR (3) NULL,
	[tran_proc_fee_req] [numeric](20,4) NULL,
	[tran_proc_fee_rsp] [numeric](20,4) NULL,
	[tran_proc_fee_currency_code] VARCHAR (3) NULL,
	[settle_amount_req] [numeric](20,4) NULL,
	[settle_amount_rsp] [numeric](20,4) NULL,
	[settle_cash_req] [numeric](20,4) NULL,
	[settle_cash_rsp] [numeric](20,4) NULL,
	[settle_tran_fee_req] [numeric](20,4) NULL,
	[settle_tran_fee_rsp] [numeric](20,4) NULL,
	[settle_proc_fee_req] [numeric](20,4) NULL,
	[settle_proc_fee_rsp] [numeric](20,4) NULL,
	[settle_currency_code] VARCHAR (3) NULL,
	[icc_data_req] [text] NULL,
	[icc_data_rsp] [text] NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[structured_data_req] [text] NULL,
	[structured_data_rsp] [text] NULL,
	[tran_reversed] [char](1) NULL,
	[prev_tran_approved] BIT NULL,
	[issuer_network_id] [varchar](11) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[extended_tran_type] [char](4) NULL,
	[ucaf_data] [varchar](33) NULL,
	[from_account_type_qualifier] [char](1) NULL,
	[to_account_type_qualifier] [char](1) NULL,
	[bank_details] [varchar](31) NULL,
	[payee] [char](25) NULL,
	[card_verification_result] [char](1) NULL,
	[online_system_id] [int] NULL,
	[participant_id] [int] NULL,
	[receiving_inst_id_code] [varchar](11) NULL,
	[routing_type] [int] NULL,
	[pt_pos_operating_environment] [char](1) NULL,
	[pt_pos_card_input_mode] [char](1) NULL,
	[pt_pos_cardholder_auth_method] [char](1) NULL,
	[pt_pos_pin_capture_ability] [char](1) NULL,
	[pt_pos_terminal_operator] [char](1) NULL,
	[opp_participant_id] [int] NULL,
	[source_node_key] [varchar](32) NULL,
	[proc_online_system_id] [int] NULL
) 

 SET @dup_post_tran_id  =(SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK)  GROUP BY post_tran_id having COUNT(post_tran_id)>1)
 
 WHILE (@dup_post_tran_id IS NOT NULL )BEGIN
 
 INSERT INTO  #temp_post_tran ([post_tran_id] ,[post_tran_cust_id] ,[settle_entity_id] ,[batch_nr] ,[prev_post_tran_id] ,[next_post_tran_id] ,[sink_node_name] ,[tran_postilion_originated] ,[tran_completed] ,[message_type] ,[tran_type] ,[tran_nr] ,[system_trace_audit_nr] ,[rsp_code_req] ,[rsp_code_rsp] ,[abort_rsp_code] ,[auth_id_rsp] ,[auth_type] ,[auth_reason] ,[retention_data] ,[acquiring_inst_id_code] ,[message_reason_code] ,[sponsor_bank] ,[retrieval_reference_nr] ,[datetime_tran_gmt] ,[datetime_tran_local] ,[datetime_req] ,[datetime_rsp] ,[realtime_business_date] ,[recon_business_date] ,[from_account_type] ,[to_account_type] ,[from_account_id] ,[to_account_id] ,[tran_amount_req] ,[tran_amount_rsp] ,[settle_amount_impact] ,[tran_cash_req] ,[tran_cash_rsp] ,[tran_currency_code] ,[tran_tran_fee_req] ,[tran_tran_fee_rsp] ,[tran_tran_fee_currency_code] ,[tran_proc_fee_req] ,[tran_proc_fee_rsp] ,[tran_proc_fee_currency_code] ,[settle_amount_req] ,[settle_amount_rsp] ,[settle_cash_req] ,[settle_cash_rsp] ,[settle_tran_fee_req] ,[settle_tran_fee_rsp] ,[settle_proc_fee_req] ,[settle_proc_fee_rsp] ,[settle_currency_code] ,[icc_data_req] ,[icc_data_rsp] ,[pos_entry_mode] ,[pos_condition_code] ,[additional_rsp_data] ,[structured_data_req] ,[structured_data_rsp] ,[tran_reversed] ,[prev_tran_approved] ,[issuer_network_id] ,[acquirer_network_id] ,[extended_tran_type] ,[ucaf_data] ,[from_account_type_qualifier] ,[to_account_type_qualifier] ,[bank_details] ,[payee] ,[card_verification_result] ,[online_system_id] ,[participant_id] ,[receiving_inst_id_code] ,[routing_type] ,[pt_pos_operating_environment] ,[pt_pos_card_input_mode] ,[pt_pos_cardholder_auth_method] ,[pt_pos_pin_capture_ability] ,[pt_pos_terminal_operator] ,[opp_participant_id] ,[source_node_key] ,[proc_online_system_id])  SELECT  [post_tran_id] ,[post_tran_cust_id] ,[settle_entity_id] ,[batch_nr] ,[prev_post_tran_id] ,[next_post_tran_id] ,[sink_node_name] ,[tran_postilion_originated] ,[tran_completed] ,[message_type] ,[tran_type] ,[tran_nr] ,[system_trace_audit_nr] ,[rsp_code_req] ,[rsp_code_rsp] ,[abort_rsp_code] ,[auth_id_rsp] ,[auth_type] ,[auth_reason] ,[retention_data] ,[acquiring_inst_id_code] ,[message_reason_code] ,[sponsor_bank] ,[retrieval_reference_nr] ,[datetime_tran_gmt] ,[datetime_tran_local] ,[datetime_req] ,[datetime_rsp] ,[realtime_business_date] ,[recon_business_date] ,[from_account_type] ,[to_account_type] ,[from_account_id] ,[to_account_id] ,[tran_amount_req] ,[tran_amount_rsp] ,[settle_amount_impact] ,[tran_cash_req] ,[tran_cash_rsp] ,[tran_currency_code] ,[tran_tran_fee_req] ,[tran_tran_fee_rsp] ,[tran_tran_fee_currency_code] ,[tran_proc_fee_req] ,[tran_proc_fee_rsp] ,[tran_proc_fee_currency_code] ,[settle_amount_req] ,[settle_amount_rsp] ,[settle_cash_req] ,[settle_cash_rsp] ,[settle_tran_fee_req] ,[settle_tran_fee_rsp] ,[settle_proc_fee_req] ,[settle_proc_fee_rsp] ,[settle_currency_code] ,[icc_data_req] ,[icc_data_rsp] ,[pos_entry_mode] ,[pos_condition_code] ,[additional_rsp_data] ,[structured_data_req] ,[structured_data_rsp] ,[tran_reversed] ,[prev_tran_approved] ,[issuer_network_id] ,[acquirer_network_id] ,[extended_tran_type] ,[ucaf_data] ,[from_account_type_qualifier] ,[to_account_type_qualifier] ,[bank_details] ,[payee] ,[card_verification_result] ,[online_system_id] ,[participant_id] ,[receiving_inst_id_code] ,[routing_type] ,[pt_pos_operating_environment] ,[pt_pos_card_input_mode] ,[pt_pos_cardholder_auth_method] ,[pt_pos_pin_capture_ability] ,[pt_pos_terminal_operator] ,[opp_participant_id] ,[source_node_key] ,[proc_online_system_id] FROM post_tran
 (NOLOCK) WHERE post_tran_id = @dup_post_tran_id
 INSERT INTO  post_tran_backup ([post_tran_id] ,[post_tran_cust_id] ,[settle_entity_id] ,[batch_nr] ,[prev_post_tran_id] ,[next_post_tran_id] ,[sink_node_name] ,[tran_postilion_originated] ,[tran_completed] ,[message_type] ,[tran_type] ,[tran_nr] ,[system_trace_audit_nr] ,[rsp_code_req] ,[rsp_code_rsp] ,[abort_rsp_code] ,[auth_id_rsp] ,[auth_type] ,[auth_reason] ,[retention_data] ,[acquiring_inst_id_code] ,[message_reason_code] ,[sponsor_bank] ,[retrieval_reference_nr] ,[datetime_tran_gmt] ,[datetime_tran_local] ,[datetime_req] ,[datetime_rsp] ,[realtime_business_date] ,[recon_business_date] ,[from_account_type] ,[to_account_type] ,[from_account_id] ,[to_account_id] ,[tran_amount_req] ,[tran_amount_rsp] ,[settle_amount_impact] ,[tran_cash_req] ,[tran_cash_rsp] ,[tran_currency_code] ,[tran_tran_fee_req] ,[tran_tran_fee_rsp] ,[tran_tran_fee_currency_code] ,[tran_proc_fee_req] ,[tran_proc_fee_rsp] ,[tran_proc_fee_currency_code] ,[settle_amount_req] ,[settle_amount_rsp] ,[settle_cash_req] ,[settle_cash_rsp] ,[settle_tran_fee_req] ,[settle_tran_fee_rsp] ,[settle_proc_fee_req] ,[settle_proc_fee_rsp] ,[settle_currency_code] ,[icc_data_req] ,[icc_data_rsp] ,[pos_entry_mode] ,[pos_condition_code] ,[additional_rsp_data] ,[structured_data_req] ,[structured_data_rsp] ,[tran_reversed] ,[prev_tran_approved] ,[issuer_network_id] ,[acquirer_network_id] ,[extended_tran_type] ,[ucaf_data] ,[from_account_type_qualifier] ,[to_account_type_qualifier] ,[bank_details] ,[payee] ,[card_verification_result] ,[online_system_id] ,[participant_id] ,[receiving_inst_id_code] ,[routing_type] ,[pt_pos_operating_environment] ,[pt_pos_card_input_mode] ,[pt_pos_cardholder_auth_method] ,[pt_pos_pin_capture_ability] ,[pt_pos_terminal_operator] ,[opp_participant_id] ,[source_node_key] ,[proc_online_system_id])  SELECT  TOP 1 [post_tran_id] ,[post_tran_cust_id] ,[settle_entity_id] ,[batch_nr] ,[prev_post_tran_id] ,[next_post_tran_id] ,[sink_node_name] ,[tran_postilion_originated] ,[tran_completed] ,[message_type] ,[tran_type] ,[tran_nr] ,[system_trace_audit_nr] ,[rsp_code_req] ,[rsp_code_rsp] ,[abort_rsp_code] ,[auth_id_rsp] ,[auth_type] ,[auth_reason] ,[retention_data] ,[acquiring_inst_id_code] ,[message_reason_code] ,[sponsor_bank] ,[retrieval_reference_nr] ,[datetime_tran_gmt] ,[datetime_tran_local] ,[datetime_req] ,[datetime_rsp] ,[realtime_business_date] ,[recon_business_date] ,[from_account_type] ,[to_account_type] ,[from_account_id] ,[to_account_id] ,[tran_amount_req] ,[tran_amount_rsp] ,[settle_amount_impact] ,[tran_cash_req] ,[tran_cash_rsp] ,[tran_currency_code] ,[tran_tran_fee_req] ,[tran_tran_fee_rsp] ,[tran_tran_fee_currency_code] ,[tran_proc_fee_req] ,[tran_proc_fee_rsp] ,[tran_proc_fee_currency_code] ,[settle_amount_req] ,[settle_amount_rsp] ,[settle_cash_req] ,[settle_cash_rsp] ,[settle_tran_fee_req] ,[settle_tran_fee_rsp] ,[settle_proc_fee_req] ,[settle_proc_fee_rsp] ,[settle_currency_code] ,[icc_data_req] ,[icc_data_rsp] ,[pos_entry_mode] ,[pos_condition_code] ,[additional_rsp_data] ,[structured_data_req] ,[structured_data_rsp] ,[tran_reversed] ,[prev_tran_approved] ,[issuer_network_id] ,[acquirer_network_id] ,[extended_tran_type] ,[ucaf_data] ,[from_account_type_qualifier] ,[to_account_type_qualifier] ,[bank_details] ,[payee] ,[card_verification_result] ,[online_system_id] ,[participant_id] ,[receiving_inst_id_code] ,[routing_type] ,[pt_pos_operating_environment] ,[pt_pos_card_input_mode] ,[pt_pos_cardholder_auth_method] ,[pt_pos_pin_capture_ability] ,[pt_pos_terminal_operator] ,[opp_participant_id] ,[source_node_key] ,[proc_online_system_id] FROM #temp_post_tran
 (NOLOCK) WHERE post_tran_id = @dup_post_tran_id   
 
 IF (@dup_post_tran_id =(SELECT TOP 1 post_tran_id FROM #temp_post_tran) AND (SELECT COUNT(post_tran_id) FROM #temp_post_tran)>1) BEGIN
  DELETE FROM post_tran WHERE post_tran_id  = @dup_post_tran_id;
  INSERT INTO post_tran ([post_tran_id] ,[post_tran_cust_id] ,[settle_entity_id] ,[batch_nr] ,[prev_post_tran_id] ,[next_post_tran_id] ,[sink_node_name] ,[tran_postilion_originated] ,[tran_completed] ,[message_type] ,[tran_type] ,[tran_nr] ,[system_trace_audit_nr] ,[rsp_code_req] ,[rsp_code_rsp] ,[abort_rsp_code] ,[auth_id_rsp] ,[auth_type] ,[auth_reason] ,[retention_data] ,[acquiring_inst_id_code] ,[message_reason_code] ,[sponsor_bank] ,[retrieval_reference_nr] ,[datetime_tran_gmt] ,[datetime_tran_local] ,[datetime_req] ,[datetime_rsp] ,[realtime_business_date] ,[recon_business_date] ,[from_account_type] ,[to_account_type] ,[from_account_id] ,[to_account_id] ,[tran_amount_req] ,[tran_amount_rsp] ,[settle_amount_impact] ,[tran_cash_req] ,[tran_cash_rsp] ,[tran_currency_code] ,[tran_tran_fee_req] ,[tran_tran_fee_rsp] ,[tran_tran_fee_currency_code] ,[tran_proc_fee_req] ,[tran_proc_fee_rsp] ,[tran_proc_fee_currency_code] ,[settle_amount_req] ,[settle_amount_rsp] ,[settle_cash_req] ,[settle_cash_rsp] ,[settle_tran_fee_req] ,[settle_tran_fee_rsp] ,[settle_proc_fee_req] ,[settle_proc_fee_rsp] ,[settle_currency_code] ,[icc_data_req] ,[icc_data_rsp] ,[pos_entry_mode] ,[pos_condition_code] ,[additional_rsp_data] ,[structured_data_req] ,[structured_data_rsp] ,[tran_reversed] ,[prev_tran_approved] ,[issuer_network_id] ,[acquirer_network_id] ,[extended_tran_type] ,[ucaf_data] ,[from_account_type_qualifier] ,[to_account_type_qualifier] ,[bank_details] ,[payee] ,[card_verification_result] ,[online_system_id] ,[participant_id] ,[receiving_inst_id_code] ,[routing_type] ,[pt_pos_operating_environment] ,[pt_pos_card_input_mode] ,[pt_pos_cardholder_auth_method] ,[pt_pos_pin_capture_ability] ,[pt_pos_terminal_operator] ,[opp_participant_id] ,[source_node_key] ,[proc_online_system_id])  SELECT  TOP 1 [post_tran_id] ,[post_tran_cust_id] ,[settle_entity_id] ,[batch_nr] ,[prev_post_tran_id] ,[next_post_tran_id] ,[sink_node_name] ,[tran_postilion_originated] ,[tran_completed] ,[message_type] ,[tran_type] ,[tran_nr] ,[system_trace_audit_nr] ,[rsp_code_req] ,[rsp_code_rsp] ,[abort_rsp_code] ,[auth_id_rsp] ,[auth_type] ,[auth_reason] ,[retention_data] ,[acquiring_inst_id_code] ,[message_reason_code] ,[sponsor_bank] ,[retrieval_reference_nr] ,[datetime_tran_gmt] ,[datetime_tran_local] ,[datetime_req] ,[datetime_rsp] ,[realtime_business_date] ,[recon_business_date] ,[from_account_type] ,[to_account_type] ,[from_account_id] ,[to_account_id] ,[tran_amount_req] ,[tran_amount_rsp] ,[settle_amount_impact] ,[tran_cash_req] ,[tran_cash_rsp] ,[tran_currency_code] ,[tran_tran_fee_req] ,[tran_tran_fee_rsp] ,[tran_tran_fee_currency_code] ,[tran_proc_fee_req] ,[tran_proc_fee_rsp] ,[tran_proc_fee_currency_code] ,[settle_amount_req] ,[settle_amount_rsp] ,[settle_cash_req] ,[settle_cash_rsp] ,[settle_tran_fee_req] ,[settle_tran_fee_rsp] ,[settle_proc_fee_req] ,[settle_proc_fee_rsp] ,[settle_currency_code] ,[icc_data_req] ,[icc_data_rsp] ,[pos_entry_mode] ,[pos_condition_code] ,[additional_rsp_data] ,[structured_data_req] ,[structured_data_rsp] ,[tran_reversed] ,[prev_tran_approved] ,[issuer_network_id] ,[acquirer_network_id] ,[extended_tran_type] ,[ucaf_data] ,[from_account_type_qualifier] ,[to_account_type_qualifier] ,[bank_details] ,[payee] ,[card_verification_result] ,[online_system_id] ,[participant_id] ,[receiving_inst_id_code] ,[routing_type] ,[pt_pos_operating_environment] ,[pt_pos_card_input_mode] ,[pt_pos_cardholder_auth_method] ,[pt_pos_pin_capture_ability] ,[pt_pos_terminal_operator] ,[opp_participant_id] ,[source_node_key] ,[proc_online_system_id] FROM #temp_post_tran
  DELETE FROM #temp_post_tran WHERE post_tran_id  = @dup_post_tran_id; 
 END
 SET @dup_post_tran_id  =(SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK)  GROUP BY post_tran_id having COUNT(post_tran_id)>1)
 
 END
