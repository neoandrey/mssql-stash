

	      SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	      DECLARE @report_date_start DATETIME

		DECLARE @report_date_end   DATETIME
		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT

		SELECT  @first_post_tran_id = MAX(post_tran_id) from [172.25.15.99].[postilion_office].dbo.[post_tran] (nolock) 
		SELECT  @report_date_start =datetime_req FROM [172.25.15.99].[postilion_office].dbo.[post_tran] (nolock)  WHERE post_tran_id =@first_post_tran_id 
		SELECT  @report_date_end=  DATEADD(HOUR, 12, @report_date_start)

		IF(@report_date_start<> @report_date_end) BEGIN
			SET  @last_post_tran_id       = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end  ORDER BY datetime_req DESC)
		END

	      SELECT  [post_tran_id], [post_tran_cust_id], [settle_entity_id], [batch_nr], [prev_post_tran_id], [next_post_tran_id], [sink_node_name], [tran_postilion_originated], [tran_completed], [message_type], [tran_type], [tran_nr], [system_trace_audit_nr], [rsp_code_req], [rsp_code_rsp], [abort_rsp_code], [auth_id_rsp], [auth_type], [auth_reason], [retention_data], [acquiring_inst_id_code], [message_reason_code], [sponsor_bank], [retrieval_reference_nr], [datetime_tran_gmt], [datetime_tran_local], [datetime_req], [datetime_rsp], [realtime_business_date], [recon_business_date], [from_account_type], [to_account_type], [from_account_id], [to_account_id], [tran_amount_req], [tran_amount_rsp], [settle_amount_impact], [tran_cash_req], [tran_cash_rsp], [tran_currency_code], [tran_tran_fee_req], [tran_tran_fee_rsp], [tran_tran_fee_currency_code], [tran_proc_fee_req], [tran_proc_fee_rsp], [tran_proc_fee_currency_code], [settle_amount_req], [settle_amount_rsp], [settle_cash_req], [settle_cash_rsp], [settle_tran_fee_req], [settle_tran_fee_rsp], [settle_proc_fee_req], [settle_proc_fee_rsp], [settle_currency_code], [icc_data_req], [icc_data_rsp], [pos_entry_mode], [pos_condition_code], [additional_rsp_data], [structured_data_req], [structured_data_rsp], [tran_reversed], [prev_tran_approved], [issuer_network_id], [acquirer_network_id], [extended_tran_type], [ucaf_data], [from_account_type_qualifier], [to_account_type_qualifier], [bank_details], [payee], [card_verification_result], [online_system_id], [participant_id], [receiving_inst_id_code], [routing_type], [pt_pos_operating_environment], [pt_pos_card_input_mode], [pt_pos_cardholder_auth_method], [pt_pos_pin_capture_ability], [pt_pos_terminal_operator], [source_node_key], [proc_online_system_id], [opp_participant_id] FROM [postilion_office].[dbo].[post_tran]  WITH (nolock, INDEX(ix_post_tran_1)) 

	      WHERE

		(post_tran_id >@first_post_tran_id ) 
		AND 
		(post_tran_id <= @last_post_tran_id)

ORDER by post_tran_id asc