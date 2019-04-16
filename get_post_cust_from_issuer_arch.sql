
INSERT INTO post_tran_cust
( [post_tran_cust_id]
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
           ,[pan_reference])
SELECT

  [post_tran_cust_id]
           ,[source_node_name]
           ,null
           ,[pan]
           ,[card_seq_nr]
           ,[expiry_date]
           ,[service_restriction_code]
           ,[terminal_id]
           ,[terminal_owner]
           ,[card_acceptor_id_code]
           ,null
           ,[merchant_type]
           ,[card_acceptor_name_loc]
           ,[address_verification_data]
           ,[address_verification_result]
           ,null
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
             FROM [172.25.15.92].[isw_data].dbo.isw_data_switchoffice_201503 