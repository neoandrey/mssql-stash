DECLARE @startDate DATETIME;
DECLARE @endDate DATETIME;

SET @startDate ='2014-01-22';

SET @endDate = '2014-01-23'

SELECT  post_tran_id,post_tran_cust_id,settle_entity_id,batch_nr,prev_post_tran_id,next_post_tran_id,sink_node_name,tran_postilion_originated,tran_completed,message_type,tran_type,tran_nr,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,abort_rsp_code,auth_id_rsp,auth_type,auth_reason,retention_data,acquiring_inst_id_code,message_reason_code,sponsor_bank,retrieval_reference_nr,datetime_tran_gmt,datetime_tran_local,datetime_req,datetime_rsp,realtime_business_date,recon_business_date,from_account_type,to_account_type,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,settle_amount_impact,tran_cash_req,tran_cash_rsp,tran_currency_code,tran_tran_fee_req,tran_tran_fee_rsp,tran_tran_fee_currency_code,tran_proc_fee_req,tran_proc_fee_rsp,tran_proc_fee_currency_code,settle_amount_req,settle_amount_rsp,settle_cash_req,settle_cash_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_proc_fee_req,settle_proc_fee_rsp,settle_currency_code,icc_data_req,icc_data_rsp,pos_entry_mode,pos_condition_code,additional_rsp_data,structured_data_req,structured_data_rsp,tran_reversed,prev_tran_approved,issuer_network_id,acquirer_network_id,extended_tran_type,ucaf_data,from_account_type_qualifier,to_account_type_qualifier,bank_details,payee,card_verification_result,online_system_id,participant_id,receiving_inst_id_code,routing_type,pt_pos_operating_environment,pt_pos_card_input_mode,pt_pos_cardholder_auth_method,pt_pos_pin_capture_ability,pt_pos_terminal_operator,source_node_key,proc_online_system_id,opp_participant_id,ion_orig_post_tran_id,ion_orig_post_tran_cust_id,from_account_id_cs,to_account_id_cs INTO #TEMP_POST_TRAN FROM post_tran (NOLOCK) WHERE datetime_req BETWEEN @startDate AND @endDate;

SELECT post_tran_cust_id,source_node_name,draft_capture,pan,card_seq_nr,expiry_date,service_restriction_code,terminal_id,terminal_owner,card_acceptor_id_code,mapped_card_acceptor_id_code,merchant_type,card_acceptor_name_loc,address_verification_data,address_verification_result,check_data,totals_group,card_product,pos_card_data_input_ability,pos_cardholder_auth_ability,pos_card_capture_ability,pos_operating_environment,pos_cardholder_present,pos_card_present,pos_card_data_input_mode,pos_cardholder_auth_method,pos_cardholder_auth_entity,pos_card_data_output_ability,pos_terminal_output_ability,pos_pin_capture_ability,pos_terminal_operator,pos_terminal_type,pan_search,pan_encrypted,pan_reference,card_acceptor_id_code_cs INTO #TEMP_POST_TRAN_CUST FROM post_tran_cust (NOLOCK) WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM #TEMP_POST_TRAN );

SELECT  'post_tran_cust_id' ,'abort_rsp_code' ,'acquirer_network_id' ,'payee' ,'pos_condition_code' ,'pos_entry_mode' ,'post_tran_id' ,'prev_post_tran_id' ,'prev_tran_approved' ,'pt_pos_card_input_mode' ,'pt_pos_cardholder_auth_method' ,'pt_pos_operating_environment' ,'pt_pos_pin_capture_ability' ,'pt_pos_terminal_operator' ,'realtime_business_date' ,'receiving_inst_id_code' ,'recon_business_date' ,'retention_data' ,'retrieval_reference_nr' ,'routing_type' ,'rsp_code_req' ,'rsp_code_rsp' ,'settle_amount_impact' ,'settle_amount_req' ,'settle_amount_rsp' ,'settle_cash_req' ,'settle_cash_rsp' ,'settle_currency_code' ,'settle_entity_id' ,'settle_proc_fee_req' ,'settle_proc_fee_rsp' ,'settle_tran_fee_req' ,'settle_tran_fee_rsp' ,'sink_node_name' ,'sponsor_bank' ,'structured_data_req' ,'structured_data_rsp' ,'system_trace_audit_nr' ,'to_account_id' ,'to_account_type' ,'to_account_type_qualifier' ,'tran_amount_req' ,'tran_amount_rsp' ,'tran_cash_req' ,'tran_cash_rsp' ,'tran_completed' ,'tran_currency_code' ,'tran_nr' ,'tran_postilion_originated' ,'tran_proc_fee_currency_code' ,'tran_proc_fee_req' ,'tran_proc_fee_rsp' ,'tran_reversed' ,'tran_tran_fee_currency_code' ,'tran_tran_fee_req' ,'tran_tran_fee_rsp' ,'tran_type' ,'ucaf_data' ,'address_verification_data' ,'address_verification_result' ,'card_acceptor_id_code' ,'card_acceptor_name_loc' ,'card_product' ,'card_seq_nr' ,'check_data' ,'draft_capture' ,'expiry_date' ,'mapped_card_acceptor_id_code' ,'merchant_type' ,'pan' ,'pan_encrypted' ,'pan_reference' ,'pan_search' ,'pos_card_capture_ability' ,'pos_card_data_input_ability' ,'pos_card_data_input_mode' ,'pos_card_data_output_ability' ,'pos_card_present' ,'pos_cardholder_auth_ability' ,'pos_cardholder_auth_entity' ,'pos_cardholder_auth_method' ,'pos_cardholder_present' ,'pos_operating_environment' ,'pos_pin_capture_ability' ,'pos_terminal_operator' ,'pos_terminal_output_ability' ,'pos_terminal_type' ,'service_restriction_code' ,'source_node_name' ,'terminal_id' ,'terminal_owner' ,'totals_group' ,'acquiring_inst_id_code' ,'additional_rsp_data' ,'auth_id_rsp' ,'auth_reason' ,'auth_type' ,'bank_details' ,'batch_nr' ,'card_verification_result' ,'datetime_req' ,'datetime_rsp' ,'datetime_tran_gmt' ,'datetime_tran_local' ,'extended_tran_type' ,'from_account_id' ,'from_account_type' ,'from_account_type_qualifier' ,'icc_data_req' ,'icc_data_rsp' ,'issuer_network_id' ,'message_reason_code' ,'message_type' ,'next_post_tran_id' ,'online_system_id' ,'participant_id'

SELECT  trans.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id FROM #TEMP_POST_TRAN trans (NOLOCK) LEFT JOIN #TEMP_POST_TRAN_CUST cust (NOLOCK) ON trans.post_tran_cust_id = cust.post_tran_cust_id

--WHERE

DROP TABLE #TEMP_POST_TRAN;

DROP TABLE #TEMP_POST_TRAN_CUST;