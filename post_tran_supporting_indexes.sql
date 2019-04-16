
USE [postilion_office];
CREATE INDEX IX_tran_postilion_originated_message_typedatetime_req
  ON [dbo]
  .[post_tran]
  ([tran_postilion_originated], [message_type], [datetime_req])
    INCLUDE ([post_tran_id], [post_tran_cust_id], [prev_post_tran_id], [sink_node_name], [tran_type], [tran_nr], [system_trace_audit_nr], [rsp_code_rsp], [retrieval_reference_nr], [recon_business_date], [tran_amount_req], [tran_amount_rsp], [settle_amount_impact], [tran_currency_code], [settle_amount_req], [settle_amount_rsp], [settle_currency_code], [online_system_id])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_recon_business_datepost_tran_id_sink_node_name_rsp_code_rsp
  ON [dbo]
  .[post_tran]
  ([recon_business_date], [post_tran_id], [sink_node_name], [rsp_code_rsp])
    INCLUDE ([post_tran_cust_id], [settle_entity_id], [batch_nr], [prev_post_tran_id], [next_post_tran_id], [tran_postilion_originated], [tran_completed], [message_type], [tran_type], [tran_nr], [system_trace_audit_nr], [rsp_code_req], [abort_rsp_code], [auth_id_rsp], [auth_type], [auth_reason], [retention_data], [acquiring_inst_id_code], [message_reason_code], [sponsor_bank], [retrieval_reference_nr], [datetime_tran_gmt], [datetime_tran_local], [datetime_req], [datetime_rsp], [realtime_business_date], [from_account_type], [to_account_type], [from_account_id], [to_account_id], [tran_amount_req], [tran_amount_rsp], [settle_amount_impact], [tran_cash_req], [tran_cash_rsp], [tran_currency_code], [tran_tran_fee_req], [tran_tran_fee_rsp], [tran_tran_fee_currency_code], [tran_proc_fee_req], [tran_proc_fee_rsp], [tran_proc_fee_currency_code], [settle_amount_req], [settle_amount_rsp], [settle_cash_req], [settle_cash_rsp], [settle_tran_fee_req], [settle_tran_fee_rsp], [settle_proc_fee_req], [settle_proc_fee_rsp], [settle_currency_code], [pos_entry_mode], [pos_condition_code], [additional_rsp_data], [tran_reversed], [prev_tran_approved], [issuer_network_id], [acquirer_network_id], [extended_tran_type], [from_account_type_qualifier], [to_account_type_qualifier], [bank_details], [payee], [card_verification_result], [online_system_id], [participant_id], [opp_participant_id], [receiving_inst_id_code], [routing_type], [pt_pos_operating_environment], [pt_pos_card_input_mode], [pt_pos_cardholder_auth_method], [pt_pos_pin_capture_ability], [pt_pos_terminal_operator], [source_node_key], [proc_online_system_id])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_recon_business_datepost_tran_id
  ON [dbo]
  .[post_tran]
  ([recon_business_date], [post_tran_id])
    INCLUDE ([post_tran_cust_id], [prev_post_tran_id], [sink_node_name], [tran_postilion_originated], [tran_completed], [message_type], [tran_type], [tran_nr], [system_trace_audit_nr], [rsp_code_req], [rsp_code_rsp], [abort_rsp_code], [auth_id_rsp], [retention_data], [acquiring_inst_id_code], [message_reason_code], [retrieval_reference_nr], [datetime_tran_gmt], [datetime_tran_local], [datetime_req], [datetime_rsp], [realtime_business_date], [from_account_type], [to_account_type], [from_account_id], [to_account_id], [tran_amount_req], [tran_amount_rsp], [settle_amount_impact], [tran_cash_req], [tran_cash_rsp], [tran_currency_code], [tran_tran_fee_req], [tran_tran_fee_rsp], [tran_tran_fee_currency_code], [settle_amount_req], [settle_amount_rsp], [settle_tran_fee_req], [settle_tran_fee_rsp], [settle_currency_code], [tran_reversed], [prev_tran_approved], [extended_tran_type], [payee], [online_system_id], [receiving_inst_id_code], [routing_type])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_sink_node_name_tran_postilion_originated_tran_type
  ON [dbo]
  .[post_tran]
  ([sink_node_name], [tran_postilion_originated], [tran_type])
    INCLUDE ([post_tran_id], [post_tran_cust_id], [message_type], [system_trace_audit_nr], [rsp_code_rsp], [acquiring_inst_id_code], [retrieval_reference_nr], [datetime_rsp], [settle_amount_rsp], [settle_tran_fee_rsp], [tran_reversed], [extended_tran_type], [payee], [receiving_inst_id_code])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_post_tran_id
  ON [dbo]
  .[post_tran]
  ([post_tran_id])
    INCLUDE ([post_tran_cust_id], [prev_post_tran_id], [sink_node_name], [tran_postilion_originated], [tran_completed], [message_type], [tran_type], [tran_nr], [system_trace_audit_nr], [rsp_code_req], [rsp_code_rsp], [abort_rsp_code], [auth_id_rsp], [retention_data], [acquiring_inst_id_code], [message_reason_code], [retrieval_reference_nr], [datetime_tran_gmt], [datetime_tran_local], [datetime_req], [datetime_rsp], [realtime_business_date], [recon_business_date], [from_account_type], [to_account_type], [from_account_id], [to_account_id], [tran_amount_req], [tran_amount_rsp], [settle_amount_impact], [tran_cash_req], [tran_cash_rsp], [tran_currency_code], [tran_tran_fee_req], [tran_tran_fee_rsp], [tran_tran_fee_currency_code], [settle_amount_req], [settle_amount_rsp], [settle_tran_fee_req], [settle_tran_fee_rsp], [settle_currency_code], [tran_reversed], [prev_tran_approved], [extended_tran_type], [payee], [online_system_id], [receiving_inst_id_code], [routing_type])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_tran_postilion_originated_message_type_1
  ON [dbo]
  .[post_tran]
  ([tran_postilion_originated], [message_type], [recon_business_date], [settle_currency_code], [tran_type])
    INCLUDE ([post_tran_cust_id], [sink_node_name], [system_trace_audit_nr], [rsp_code_rsp], [auth_id_rsp], [retrieval_reference_nr], [from_account_id], [tran_amount_req], [tran_amount_rsp], [tran_currency_code])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_post_tran_cust_id_tran_postilion_originated
  ON [dbo]
  .[post_tran]
  ([post_tran_cust_id], [tran_postilion_originated])
    INCLUDE ([tran_nr])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_tran_postilion_originated_message_type_2
  ON [dbo]
  .[post_tran]
  ([tran_postilion_originated], [tran_completed], [sink_node_name], [message_type], [tran_type], [recon_business_date])
    INCLUDE ([post_tran_cust_id], [prev_post_tran_id], [tran_nr], [system_trace_audit_nr], [rsp_code_rsp], [acquiring_inst_id_code], [message_reason_code], [retrieval_reference_nr], [datetime_tran_local], [datetime_req], [from_account_type], [to_account_type], [settle_amount_impact], [tran_cash_req], [tran_currency_code], [settle_amount_req], [settle_amount_rsp], [settle_tran_fee_rsp], [settle_currency_code], [tran_reversed], [extended_tran_type])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_tran_postilion_originated_message_type_3
  ON [dbo]
  .[post_tran]
  ([tran_postilion_originated], [tran_completed], [sink_node_name], [message_type], [tran_type], [recon_business_date])
    INCLUDE ([post_tran_cust_id], [prev_post_tran_id], [tran_nr], [system_trace_audit_nr], [rsp_code_rsp], [acquiring_inst_id_code], [message_reason_code], [retrieval_reference_nr], [datetime_tran_local], [datetime_req], [from_account_type], [to_account_type], [from_account_id], [to_account_id], [settle_amount_impact], [tran_cash_req], [tran_currency_code], [settle_amount_req], [settle_amount_rsp], [settle_tran_fee_rsp], [settle_currency_code], [tran_reversed], [extended_tran_type], [payee])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_tran_postilion_originated_message_type_tran_nr
  ON [dbo]
  .[post_tran]
  ([tran_postilion_originated], [message_type], [tran_nr])
    
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_datetime_end
  ON [dbo]
  .[post_batch]
  ([datetime_end])
    INCLUDE ([settle_entity_id], [batch_nr])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_totals_group
  ON [dbo]
  .[post_tran_cust]
  ([totals_group])
    INCLUDE ([post_tran_cust_id], [source_node_name], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference], [card_acceptor_id_code_cs])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_terminal_idpan
  ON [dbo]
  .[post_tran_cust]
  ([terminal_id], [pan])
    INCLUDE ([post_tran_cust_id], [source_node_name], [draft_capture], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [totals_group], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference], [card_acceptor_id_code_cs])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_terminal_id_totals_group
  ON [dbo]
  .[post_tran_cust]
  ([terminal_id], [totals_group])
    INCLUDE ([post_tran_cust_id], [source_node_name], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference], [card_acceptor_id_code_cs])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_terminal_id
  ON [dbo]
  .[post_tran_cust]
  ([terminal_id])
    INCLUDE ([post_tran_cust_id], [source_node_name],[pan], [card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [totals_group], [card_product])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_pan_totals_group
  ON [dbo]
  .[post_tran_cust]
  ([pan], [totals_group])
    INCLUDE ([post_tran_cust_id], [source_node_name], [draft_capture], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference], [card_acceptor_id_code_cs])
    WITH (FILLFACTOR=90, ONLINE=ON)
USE [postilion_office];
CREATE INDEX IX_source_node_name
  ON [dbo]
  .[post_tran_cust]
  ([source_node_name])
    INCLUDE ([post_tran_cust_id], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [totals_group], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference])
    WITH (FILLFACTOR=90, ONLINE=ON)