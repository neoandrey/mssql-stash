delete from adjustment_countries;
	INSERT INTO	adjustment_countries	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_countries
	delete from adjustment_countries1;
	INSERT INTO	adjustment_countries1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_countries1
	--INSERT INTO	adjustment_cs_get_prev_trans_issuer_view	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_cs_get_prev_trans_issuer_view
	--INSERT INTO	adjustment_cs_get_prev_trans_view	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_cs_get_prev_trans_view
	--INSERT INTO	adjustment_cs_get_trans_view	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_cs_get_trans_view
	INSERT INTO	adjustment_hub_case_items	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_hub_case_items
	INSERT INTO	adjustment_hub_case_items1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_hub_case_items1
	INSERT INTO	adjustment_interface	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_interface
	INSERT INTO	adjustment_interface1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_interface1
	INSERT INTO	 adjustment_iso_msg_data	
	(msg_id,message_type,pan,tran_type,from_account_type,to_account_type,tran_amount_req,settle_amount_req,system_trace_audit_nr,datetime_tran_local,expiry_date,merchant_type,card_seq_nr,pos_entry_mode,pos_condition_code,message_reason_code,tran_tran_fee_req,settle_tran_fee_req,acquiring_inst_id_code,retrieval_reference_nr,auth_id_rsp,service_restriction_code,terminal_id,card_acceptor_id_code,card_acceptor_name_loc,tran_currency_code,settle_currency_code,amount_cash_final,pos_card_data_input_capability,pos_cardholder_auth_capability,pos_card_capture_capability,pos_operating_environment,pos_cardholder_present,pos_card_present,pos_card_data_input_mode,pos_cardholder_auth_method,pos_cardholder_auth_entity,pos_card_data_output_capability,pos_terminal_output_capability,pos_pin_capture_capability,pos_terminal_operator,pos_terminal_type,pos_geographic_data,network_id,prev_post_tran_id,comment,extended_tran_type,date_settlement,payee,from_account_id,to_account_id,from_account_type_qualifier,to_account_type_qualifier,pan_encrypted,pan_reference)
	SELECT msg_id,message_type,pan,tran_type,from_account_type,to_account_type,tran_amount_req,settle_amount_req,system_trace_audit_nr,datetime_tran_local,expiry_date,merchant_type,card_seq_nr,pos_entry_mode,pos_condition_code,message_reason_code,tran_tran_fee_req,settle_tran_fee_req,acquiring_inst_id_code,retrieval_reference_nr,auth_id_rsp,service_restriction_code,terminal_id,card_acceptor_id_code,card_acceptor_name_loc,tran_currency_code,settle_currency_code,amount_cash_final,pos_card_data_input_capability,pos_cardholder_auth_capability,pos_card_capture_capability,pos_operating_environment,pos_cardholder_present,pos_card_present,pos_card_data_input_mode,pos_cardholder_auth_method,pos_cardholder_auth_entity,pos_card_data_output_capability,pos_terminal_output_capability,pos_pin_capture_capability,pos_terminal_operator,pos_terminal_type,pos_geographic_data,network_id,prev_post_tran_id,comment,extended_tran_type,date_settlement,payee,from_account_id,to_account_id,from_account_type_qualifier,to_account_type_qualifier,pan_encrypted,pan_reference  FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_iso_msg_data
	INSERT INTO	adjustment_iso_msg_data_new	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_iso_msg_data_new
	INSERT INTO	adjustment_iso_msg_data1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_iso_msg_data1
	INSERT INTO	adjustment_iso_msg_data5	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_iso_msg_data5
	INSERT INTO	adjustment_iso_msg_data6	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_iso_msg_data6
	INSERT INTO	adjustment_lookup	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_lookup
	INSERT INTO	adjustment_lookup1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_lookup1
	INSERT INTO	adjustment_matching	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_matching
	INSERT INTO	adjustment_matching1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_matching1
	INSERT INTO	adjustment_msg_data
	(msg_id,msg_type_id,tran_amount_original,settle_amount_original,tran_currency_code_original,settle_currency_code_original,partial_amount,partial_currency_code,retrieval_document_code,acquirer_ref_no,issuer_ref_no,fee_collection_control_no,documentation_indicator,message_text,date_action,fulfillment_document_code,original_retrieval_reason,mastercard_function_code,destination_inst,originator_inst,mastercard_additional_data,acquiring_inst_country_code,forwarding_inst_country_code,forwarding_inst_id_code,receiving_inst_country_code,receiving_inst_id_code,network_structured_data,message_matching,reject_fields,reject_codes,tran_nr,source_node_name)
		SELECT msg_id,msg_type_id,tran_amount_original,settle_amount_original,tran_currency_code_original,settle_currency_code_original,partial_amount,partial_currency_code,retrieval_document_code,acquirer_ref_no,issuer_ref_no,fee_collection_control_no,documentation_indicator,message_text,date_action,fulfillment_document_code,original_retrieval_reason,mastercard_function_code,destination_inst,originator_inst,mastercard_additional_data,acquiring_inst_country_code,forwarding_inst_country_code,forwarding_inst_id_code,receiving_inst_country_code,receiving_inst_id_code,network_structured_data,message_matching,reject_fields,reject_codes,tran_nr,source_node_name
 FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_data
	--INSERT INTO	adjustment_msg_data_new	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_data_new
	INSERT INTO	adjustment_msg_data1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_data1
	INSERT INTO	adjustment_msg_data2	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_data2
	--INSERT INTO	 adjustment_msg_state
	--(msg_id,outgoing,correction,role,online_system_id,network_name,state,date_active,date_processed,date_inactive,date_accepted,date_represented,date_arbitrated,date_reversed,date_delivered,post_tran_cust_id,prev_msg_id)
	--	SELECT msg_id,outgoing,correction,role,online_system_id,network_name,state,date_active,date_processed,date_inactive,date_accepted,date_represented,date_arbitrated,date_reversed,date_delivered,post_tran_cust_id,prev_msg_id FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_state
	INSERT INTO	adjustment_msg_state1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_state1
	--INSERT INTO	adjustment_msg_type	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_type
	INSERT INTO	adjustment_msg_type1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_type1
	INSERT INTO	adjustment_properties	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_properties
	INSERT INTO	adjustment_properties1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_properties1
	INSERT INTO	adjustment_routing_info	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_routing_info
	INSERT INTO	adjustment_routing_info1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_routing_info1
	INSERT INTO	adjustment_tran_types	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_tran_types
	INSERT INTO	adjustment_tran_types1	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_tran_types1
	
	
SET IDENTITY_INSERT adjustment_msg_state ON
INSERT INTO	 adjustment_msg_state
	(msg_id,outgoing,correction,role,online_system_id,network_name,state,date_active,date_processed,date_inactive,date_accepted,date_represented,date_arbitrated,date_reversed,date_delivered,post_tran_cust_id,prev_msg_id)
		SELECT msg_id,outgoing,correction,role,online_system_id,network_name,state,date_active,date_processed,date_inactive,date_accepted,date_represented,date_arbitrated,date_reversed,date_delivered,post_tran_cust_id,prev_msg_id FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_state
	SET IDENTITY_INSERT adjustment_msg_state OFF
	
		INSERT INTO	adjustment_msg_data_new	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_data_new
	
	INSERT INTO	adjustment_msg_type	SELECT * FROM 	[172.25.20.4].[postilion_office].dbo.adjustment_msg_type where msg_type_id NOT IN 
	
	(
	
	SELECT msg_type_id FROM 	[postilion_office].dbo.adjustment_msg_type
	
	)
	
