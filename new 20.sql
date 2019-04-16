              string mainQry = "SET NOCOUNT ON; " +
"IF(OBJECT_ID('tempdb.dbo.#TEMP_RECON_OFFICE_" + tableNamesuffix + "') IS NOT NULL) DROP TABLE  #TEMP_RECON_OFFICE_" + tableNamesuffix + ";" +
" SELECT post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode , " +
" realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ," +
" t.retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ," +
" settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank,t.system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ," +
" tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ," +
" tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,t.card_acceptor_id_code ,t.card_acceptor_name_loc ," +
" card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,t.merchant_type ,t.pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ," +
" pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ," +
" pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,t.terminal_id ," +
" terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,t.auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,t.datetime_req ,datetime_rsp ,datetime_tran_gmt ," +
" datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,issuer_network_id ,message_reason_code ,t.message_type ,next_post_tran_id ," +
" online_system_id ,participant_id  INTO #TEMP_RECON_OFFICE_" + tableNamesuffix + " FROM ( SELECT  " +
"tt.post_tran_cust_id, abort_rsp_code, acquirer_network_id, payee, pos_condition_code, pos_entry_mode, post_tran_id, prev_post_tran_id, prev_tran_approved, pt_pos_card_input_mode, " +
" realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ," +
" tt.retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ," +
" settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank,tt.system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ," +
" tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ," +
" tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,c.card_acceptor_id_code ,c.card_acceptor_name_loc ," +
" card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,c.merchant_type ,c.pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ," +
" pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ," +
" pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,c.terminal_id ," +
" terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,tt.auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,tt.datetime_req ,datetime_rsp ,datetime_tran_gmt ," +
" datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,issuer_network_id ,message_reason_code ,tt.message_type ,next_post_tran_id ," +
" online_system_id ,participant_id " +
" FROM " +
" (SELECT  * FROM    post_tran  tt(NOLOCK, INDEX(ix_post_tran_9))  JOIN (SELECT date [rec_bus_date] FROM dbo.get_dates_in_range('" + startDatetimePicker.Value.Date.ToString("yyyy-MM-dd HH:mm:ss") + "','" + endDatetimePicker.Value.Date.ToString("yyyy-MM-dd HH:mm:ss") + "') ) r ON tt.recon_business_date  =r.rec_bus_date)tt  JOIN post_tran_cust c (NOLOCK) ON tt.post_tran_cust_id = c.post_tran_cust_id AND  tt.tran_completed = 1	AND	tt.tran_postilion_originated = 0	AND	(tran_type NOT IN ('31','50','21')   AND LEFT( source_node_name,2)  != 'SB'  AND LEFT( sink_node_name,2)  != 'SB' and c.merchant_type not in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511')) )t " +
"  JOIN recon_client_data_settle_unmatched_" + tableNamesuffix + " rec (NOLOCK)    ";
