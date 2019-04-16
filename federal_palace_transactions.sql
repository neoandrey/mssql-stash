
DECLARE @pan VARCHAR(100);
DECLARE @pan_list VARCHAR(8000)

SET @pan_list =  '539941******6436,532732******4880,559441******0590,539941******4108,519899******2090,539983******1603,539983******9626,539983******7241,539945******7280,539983******3716,519899******2437,519899******5908,539983******0604,532732******4028,506105*********3911,559424******0298,532732******6530,519908******5576,532732******7389,539941******4975,519911******6353,539983******6202,517868******3099';

DECLARE @masked_pan_table TABLE (serial_number INT IDENTITY(1,1), pan VARCHAR(100), left_pan_six CHAR(6), right_pan_four CHAR(4));
INSERT INTO @masked_pan_table (pan) SELECT part FROM usf_split_string(@pan_list, ',')

DECLARE pan_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT pan FROM  @masked_pan_table
OPEN pan_cursor
FETCH NEXT FROM pan_cursor INTO @pan

WHILE (@@FETCH_STATUS =0) BEGIN

 	INSERT INTO @masked_pan_table (left_pan_six, right_pan_four) VALUES (LEFT(@pan, 6), RIGHT(@pan,4))
	FETCH NEXT FROM pan_cursor INTO @pan
END

CLOSE pan_cursor;
DEALLOCATE pan_cursor

SELECT  trans.post_tran_cust_id ,abort_rsp_code,draft_capture  ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id FROM post_tran trans (NOLOCK) LEFT JOIN post_tran_cust cust (NOLOCK) ON trans.post_tran_cust_id = cust.post_tran_cust_id 

WHERE LEFT(pan,6) IN (SELECT left_pan_six FROM @masked_pan_table) AND RIGHT(pan,4) IN (SELECT right_pan_four FROM @masked_pan_table)
AND datetime_req BETWEEN '2014-01-20' AND '2014-03-05'
AND
card_acceptor_name_loc LIKE '%FEDERAL PALACE HOTEL%'
AND
terminal_id IN ( '2701A009', '2701A179')