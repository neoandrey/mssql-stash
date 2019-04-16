ALTER PROCEDURE migrate_transaction_data  @trans_server VARCHAR(50), @trans_date VARCHAR(30) 

AS 

BEGIN
set quoted_identifier off


DECLARE @sub_query VARCHAR(8000);
DECLARE @query VARCHAR(8000)
DECLARE @num_of_rows BIGINT
DECLARE @local_server VARCHAR (120);
DECLARE @tran_count VARCHAR (120);

    SET  @local_server = @@SERVERNAME;
	SET  @trans_server = ISNULL(@trans_server, @local_server); 
	SET  @trans_date   = ISNULL(@trans_date, DATEADD(D, -1, DATEDIFF(D, 0, GETDATE())));
	SELECT @tran_count=COUNT(*) FROM joined_transaction_table WHERE recon_business_date = @trans_date
	IF  (@tran_count=0)
	BEGIN
		SET @query= 'DECLARE @min_post_tran_cust_id VARCHAR (120);'+CHAR(10)+'DECLARE @max_post_tran_cust_id  VARCHAR (120);'+CHAR(10)+'SELECT @max_post_tran_cust_id = MAX(post_tran_cust_id), @min_post_tran_cust_id =MIN(post_tran_cust_id) FROM joined_transaction_table;'+CHAR(10)+'PRINT ''min_post_tran_cust_id: ''+@min_post_tran_cust_id;'+CHAR(10)+'PRINT ''max_post_tran_cust_id: ''+@max_post_tran_cust_id; '+CHAR(10)+'INSERT INTO ['+@local_server+'].[postilion_office].[dbo].[joined_transaction_table] ([post_tran_id],[post_tran_cust_id],[settle_entity_id],[batch_nr],[prev_post_tran_id],[next_post_tran_id],[sink_node_name],[tran_postilion_originated],[tran_completed],[message_type],[tran_type],[tran_nr],[system_trace_audit_nr],[rsp_code_req],[rsp_code_rsp],[abort_rsp_code],[auth_id_rsp],[auth_type],[auth_reason],[retention_data],[acquiring_inst_id_code],[message_reason_code],[sponsor_bank],[retrieval_reference_nr],[datetime_tran_gmt],[datetime_tran_local],[datetime_req],[datetime_rsp],[realtime_business_date],[recon_business_date],[from_account_type],[to_account_type],[from_account_id],[to_account_id],[tran_amount_req],[tran_amount_rsp],[settle_amount_impact],[tran_cash_req],[tran_cash_rsp],[tran_currency_code],[tran_tran_fee_req],[tran_tran_fee_rsp],[tran_tran_fee_currency_code],[tran_proc_fee_req],[tran_proc_fee_rsp],[tran_proc_fee_currency_code],[settle_amount_req],[settle_amount_rsp],[settle_cash_req],[settle_cash_rsp],[settle_tran_fee_req],[settle_tran_fee_rsp],[settle_proc_fee_req],[settle_proc_fee_rsp],[settle_currency_code],[icc_data_req],[icc_data_rsp],[pos_entry_mode],[pos_condition_code],[additional_rsp_data],[structured_data_req],[structured_data_rsp],[tran_reversed],[prev_tran_approved],[issuer_network_id],[acquirer_network_id],[extended_tran_type],[ucaf_data],[from_account_type_qualifier],[to_account_type_qualifier],[bank_details],[payee],[card_verification_result],[online_system_id],[participant_id],[receiving_inst_id_code],[routing_type],[pt_pos_operating_environment],[pt_pos_card_input_mode],[pt_pos_cardholder_auth_method],[pt_pos_pin_capture_ability],[pt_pos_terminal_operator],[source_node_name],[draft_capture],[pan],[card_seq_nr],[expiry_date],[service_restriction_code],[terminal_id],[terminal_owner],[card_acceptor_id_code],[mapped_card_acceptor_id_code],[merchant_type],[card_acceptor_name_loc],[address_verification_data],[address_verification_result],[check_data],[totals_group],[card_product],[pos_card_data_input_ability],[pos_cardholder_auth_ability],[pos_card_capture_ability],[pos_operating_environment],[pos_cardholder_present],[pos_card_present],[pos_card_data_input_mode],[pos_cardholder_auth_method],[pos_cardholder_auth_entity],[pos_card_data_output_ability],[pos_terminal_output_ability],[pos_pin_capture_ability],[pos_terminal_operator],[pos_terminal_type],[pan_search],[pan_encrypted],[pan_reference]) SELECT [post_tran_id], trans.[post_tran_cust_id],[settle_entity_id],[batch_nr],[prev_post_tran_id],[next_post_tran_id],[sink_node_name],[tran_postilion_originated],[tran_completed],[message_type],[tran_type],[tran_nr],[system_trace_audit_nr],[rsp_code_req],[rsp_code_rsp],[abort_rsp_code],[auth_id_rsp],[auth_type],[auth_reason],[retention_data],[acquiring_inst_id_code],[message_reason_code],[sponsor_bank],[retrieval_reference_nr],[datetime_tran_gmt],[datetime_tran_local],[datetime_req],[datetime_rsp],[realtime_business_date],[recon_business_date],[from_account_type],[to_account_type],[from_account_id],[to_account_id],[tran_amount_req],[tran_amount_rsp],[settle_amount_impact],[tran_cash_req],[tran_cash_rsp],[tran_currency_code],[tran_tran_fee_req],[tran_tran_fee_rsp],[tran_tran_fee_currency_code],[tran_proc_fee_req],[tran_proc_fee_rsp],[tran_proc_fee_currency_code],[settle_amount_req],[settle_amount_rsp],[settle_cash_req],[settle_cash_rsp],[settle_tran_fee_req],[settle_tran_fee_rsp],[settle_proc_fee_req],[settle_proc_fee_rsp],[settle_currency_code],[icc_data_req],[icc_data_rsp],[pos_entry_mode],[pos_condition_code],[additional_rsp_data],[structured_data_req],[structured_data_rsp],[tran_reversed],[prev_tran_approved],[issuer_network_id],[acquirer_network_id],[extended_tran_type],[ucaf_data],[from_account_type_qualifier],[to_account_type_qualifier],[bank_details],[payee],[card_verification_result],[online_system_id],[participant_id],[receiving_inst_id_code],[routing_type],[pt_pos_operating_environment],[pt_pos_card_input_mode],[pt_pos_cardholder_auth_method],[pt_pos_pin_capture_ability],[pt_pos_terminal_operator],[source_node_name],[draft_capture],[pan],[card_seq_nr],[expiry_date],[service_restriction_code],[terminal_id],[terminal_owner],[card_acceptor_id_code],[mapped_card_acceptor_id_code],[merchant_type],[card_acceptor_name_loc],[address_verification_data],[address_verification_result],[check_data],[totals_group],[card_product],[pos_card_data_input_ability],[pos_cardholder_auth_ability],[pos_card_capture_ability],[pos_operating_environment],[pos_cardholder_present],[pos_card_present],[pos_card_data_input_mode],[pos_cardholder_auth_method],[pos_cardholder_auth_entity],[pos_card_data_output_ability],[pos_terminal_output_ability],[pos_pin_capture_ability],[pos_terminal_operator],[pos_terminal_type],[pan_search],[pan_encrypted],[pan_reference] FROM ['+@trans_server+'].[postilion_office].dbo.post_tran trans  JOIN ['+@trans_server+'].[postilion_office].dbo.[post_tran_cust] cust ON trans.post_tran_cust_id = cust.post_tran_cust_id WHERE trans.recon_business_date ='''+@trans_date+''';' 
	
	PRINT 'Transaction Server: '+@trans_server+CHAR(10);
	PRINT 'Local Server: '+@local_server+CHAR(10);
	PRINT 'Date to Migrate: '+@trans_date+CHAR(10);
	PRINT 'Migration Query: '+@query+CHAR(10);
    EXEC( @query);
    END
    ELSE
    BEGIN
     PRINT 'Transaction for: '+@trans_date+' already exist in joined_transaction_table.'
    END

    PRINT 'Data migration complete...'+CHAR(10);
    PRINT CONVERT(VARCHAR(500),@num_of_rows)+' rows copied to join_transaction_table.';
        
END

exec migrate_transaction_data  @trans_server='172.25.10.68', @trans_date ='2014-05-20'