
DECLARE @source_node VARCHAR (30)
DECLARE @message_type VARCHAR (30)
DECLARE @response_code VARCHAR (30)
DECLARE @start_date VARCHAR(10)
DECLARE @end_date VARCHAR(10)
DECLARE @dayInterval INT
DECLARE @dateCursor INT

SET @start_date ='0220'
SET @end_date=RIGHT(CONVERT(VARCHAR(30),GETDATE(),112),4)
SET @dayInterval = 1
SET @dateCursor = @start_date

SET @source_node=''
SET @message_type=''
SET @response_code=''


CREATE TABLE #realtime_transactions(
	[tran_nr] [bigint] NOT NULL,
	[totals_processing] [int] NOT NULL,
	[state] [int] NOT NULL,
	[msg_class] [int] NOT NULL,
	[msg_type] [int] NOT NULL,
	[draft_capture] [int] NOT NULL,
	[stand_in] [int] NOT NULL,
	[source_node] [varchar](12) NULL,
	[source_node_key] [varchar](32) NULL,
	[source_node_sys_trace] [char](6) NULL,
	[source_node_settlement_entity] [int] NOT NULL,
	[source_node_batch] [int] NOT NULL,
	[source_node_batch_exception] [int] NOT NULL,
	[source_node_date_settlement] [char](4) NULL,
	[source_node_amount_requested] [float] NOT NULL,
	[source_node_amount_approved] [float] NOT NULL,
	[source_node_amount_final] [float] NOT NULL,
	[source_node_cash_requested] [float] NOT NULL,
	[source_node_cash_approved] [float] NOT NULL,
	[source_node_cash_final] [float] NOT NULL,
	[source_node_fee] [float] NOT NULL,
	[source_node_fee_proc] [float] NOT NULL,
	[source_node_currency_code] [char](3) NULL,
	[source_node_conversion_rate] [char](8) NULL,
	[source_node_date_conversion] [char](4) NULL,
	[source_node_original_data] [char](42) NULL,
	[source_node_echo_data] [varchar](255) NULL,
	[source_node_additional_data] [varchar](255) NULL,
	[sink_node] [varchar](12) NULL,
	[sink_node_req_sys_trace] [char](6) NULL,
	[sink_node_rev_sys_trace] [char](6) NULL,
	[sink_node_adv_sys_trace] [char](6) NULL,
	[sink_node_settlement_entity] [int] NOT NULL,
	[sink_node_batch] [int] NOT NULL,
	[sink_node_batch_exception] [int] NOT NULL,
	[sink_node_date_settlement] [char](4) NULL,
	[sink_node_amount_requested] [float] NOT NULL,
	[sink_node_amount_approved] [float] NOT NULL,
	[sink_node_amount_final] [float] NOT NULL,
	[sink_node_cash_requested] [float] NOT NULL,
	[sink_node_cash_approved] [float] NOT NULL,
	[sink_node_cash_final] [float] NOT NULL,
	[sink_node_fee] [float] NOT NULL,
	[sink_node_fee_proc] [float] NOT NULL,
	[sink_node_currency_code] [char](3) NULL,
	[sink_node_conversion_rate] [char](8) NULL,
	[sink_node_date_conversion] [char](4) NULL,
	[sink_node_original_data] [char](42) NULL,
	[sink_node_echo_data] [varchar](255) NULL,
	[control_node] [varchar](12) NULL,
	[totals_group] [varchar](12) NULL,
	[pan] [varchar](19) NOT NULL,
	[tran_type] [char](2) NULL,
	[from_account] [char](2) NULL,
	[to_account] [char](2) NULL,
	[amount_tran_requested] [float] NOT NULL,
	[amount_tran_approved] [float] NOT NULL,
	[amount_tran_final] [float] NOT NULL,
	[amount_cash_requested] [float] NOT NULL,
	[amount_cash_approved] [float] NOT NULL,
	[amount_cash_final] [float] NOT NULL,
	[gmt_date_time] [char](10) NULL,
	[time_local] [char](6) NULL,
	[date_local] [char](4) NULL,
	[expiry_date] [char](4) NULL,
	[merchant_type] [char](4) NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[pos_pin_capture_code] [char](2) NULL,
	[auth_id_rsp_length] [char](1) NULL,
	[fee_tran] [float] NOT NULL,
	[fee_tran_proc] [float] NOT NULL,
	[acquiring_inst] [varchar](11) NULL,
	[forwarding_inst] [varchar](11) NULL,
	[track2_data] [varchar](37) NULL,
	[ret_ref_no] [char](12) NULL,
	[auth_id_rsp] [char](6) NULL,
	[rsp_code_req_rsp] [char](2) NULL,
	[rsp_code_cmp] [char](2) NULL,
	[rsp_code_rev] [char](2) NULL,
	[service_restriction_code] [char](3) NULL,
	[card_acceptor_term_id] [char](8) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[card_acceptor_name_loc] [char](40) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[currency_code_tran] [char](3) NULL,
	[amount_available] [float] NOT NULL,
	[ledger_balance] [float] NOT NULL,
	[auth_life_cycle] [char](3) NULL,
	[authorising_inst] [varchar](11) NULL,
	[extended_payment_code] [char](2) NULL,
	[payee] [char](25) NULL,
	[receiving_inst] [varchar](11) NULL,
	[account_id_1] [varchar](28) NULL,
	[account_id_2] [varchar](28) NULL,
	[pos_data_code] [char](15) NULL,
	[pos_data] [char](22) NULL,
	[service_station_data] [char](73) NULL,
	[authorisation_reason] [char](1) NULL,
	[authorisation_type] [char](1) NULL,
	[check_data] [varchar](70) NULL,
	[msg_reason_code_req_in] [char](4) NULL,
	[msg_reason_code_req_out] [char](4) NULL,
	[msg_reason_code_rev] [char](4) NULL,
	[msg_reason_code_adv] [char](4) NULL,
	[terminal_owner] [varchar](25) NULL,
	[pos_geographic_data] [char](17) NULL,
	[sponsor_bank] [char](8) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [char](1) NULL,
	[abort_time] [datetime] NULL,
	[abort_reason] [int] NULL,
	[abort_state] [int] NULL,
	[abort_rsp_code] [char](2) NULL,
	[in_req] [datetime] NULL,
	[in_req_rsp] [datetime] NULL,
	[in_cmp] [datetime] NULL,
	[in_cmp_rsp] [datetime] NULL,
	[in_adv] [datetime] NULL,
	[in_adv_rsp] [datetime] NULL,
	[in_rev] [datetime] NULL,
	[in_rev_rsp] [datetime] NULL,
	[in_recon_adv] [datetime] NULL,
	[in_recon_adv_rsp] [datetime] NULL,
	[in_activ_adv] [datetime] NULL,
	[in_activ_adv_rsp] [datetime] NULL,
	[in_notify_adv_rsp] [datetime] NULL,
	[out_req] [datetime] NULL,
	[out_req_rsp] [datetime] NULL,
	[out_cmp] [datetime] NULL,
	[out_cmp_rsp] [datetime] NULL,
	[out_adv] [datetime] NULL,
	[out_adv_rsp] [datetime] NULL,
	[out_rev] [datetime] NULL,
	[out_rev_rsp] [datetime] NULL,
	[out_recon_adv] [datetime] NULL,
	[out_recon_adv_rsp] [datetime] NULL,
	[out_activ_adv] [datetime] NULL,
	[out_activ_adv_rsp] [datetime] NULL,
	[out_notify_adv] [datetime] NULL,
	[user_reserved_1] [varchar](10) NULL,
	[card_seq_nr] [char](3) NULL,
	[tran_nr_prev] [bigint] NULL,
	[tran_nr_next] [bigint] NULL,
	[sink_node_acquiring_inst] [varchar](11) NULL,
	[sink_node_forwarding_inst] [varchar](11) NULL,
	[fee_tran_original] [float] NULL,
	[source_node_fee_original] [float] NULL,
	[sink_node_fee_original] [float] NULL,
	[acquirer_participant] [int] NULL,
	[issuer_participant] [int] NULL,
	[file_update_code] [char](1) NULL,
	[file_update_name] [varchar](17) NULL,
	[file_record_id] [varchar](12) NULL,
	[bank_details] [varchar](31) NULL,
	[payee_name_and_address] [varchar](253) NULL,
	[payer_account_id] [varchar](28) NULL,
	[icc_data_req] [text] NULL,
	[icc_data_rsp] [text] NULL,
	[structured_data_req] [text] NULL,
	[structured_data_rsp] [text] NULL,
	[card_product] [varchar](20) NULL,
	[source_node_original_node] [varchar](20) NULL,
	[source_node_original_key] [varchar](32) NULL,
	[card_verification_result] [char](1) NULL,
	[secure_3d_result] [char](1) NULL,
	[track1_data] [varchar](76) NULL,
	[source_node_amount_impact] [float] NULL,
	[sink_node_amount_impact] [float] NULL,
	[amount_tran_impact] [float] NULL,
	[orig_auth_date_settle_req] [char](8) NULL,
	[orig_auth_date_settle_rsp] [char](8) NULL,
	[issuer_network_id] [varchar](11) NULL,
	[ucaf_data] [varchar](33) NULL,
	[extended_tran_type] [char](4) NULL,
	[from_account_type_qualifier] [char](1) NULL,
	[to_account_type_qualifier] [char](1) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[sink_node_card_acceptor_id] [char](15) NULL,
	[source_node_batch_settlement_date] [datetime] NULL,
	[sink_node_batch_settlement_date] [datetime] NULL,
	[pan_encrypted] [char](18) NULL,
	[pan_reference] [char](42) NULL,
	[customer_id] [char](25) NULL
	)



WHILE (@dateCursor <= @end_date)
	 BEGIN
	 
	 INSERT INTO #realtime_transactions(
	 
	  [tran_nr]
      ,[totals_processing]
      ,[state]
      ,[msg_class]
      ,[msg_type]
      ,[draft_capture]
      ,[stand_in]
      ,[source_node]
      ,[source_node_key]
      ,[source_node_sys_trace]
      ,[source_node_settlement_entity]
      ,[source_node_batch]
      ,[source_node_batch_exception]
      ,[source_node_date_settlement]
      ,[source_node_amount_requested]
      ,[source_node_amount_approved]
      ,[source_node_amount_final]
      ,[source_node_cash_requested]
      ,[source_node_cash_approved]
      ,[source_node_cash_final]
      ,[source_node_fee]
      ,[source_node_fee_proc]
      ,[source_node_currency_code]
      ,[source_node_conversion_rate]
      ,[source_node_date_conversion]
      ,[source_node_original_data]
      ,[source_node_echo_data]
      ,[source_node_additional_data]
      ,[sink_node]
      ,[sink_node_req_sys_trace]
      ,[sink_node_rev_sys_trace]
      ,[sink_node_adv_sys_trace]
      ,[sink_node_settlement_entity]
      ,[sink_node_batch]
      ,[sink_node_batch_exception]
      ,[sink_node_date_settlement]
      ,[sink_node_amount_requested]
      ,[sink_node_amount_approved]
      ,[sink_node_amount_final]
      ,[sink_node_cash_requested]
      ,[sink_node_cash_approved]
      ,[sink_node_cash_final]
      ,[sink_node_fee]
      ,[sink_node_fee_proc]
      ,[sink_node_currency_code]
      ,[sink_node_conversion_rate]
      ,[sink_node_date_conversion]
      ,[sink_node_original_data]
      ,[sink_node_echo_data]
      ,[control_node]
      ,[totals_group]
      ,[pan]
      ,[tran_type]
      ,[from_account]
      ,[to_account]
      ,[amount_tran_requested]
      ,[amount_tran_approved]
      ,[amount_tran_final]
      ,[amount_cash_requested]
      ,[amount_cash_approved]
      ,[amount_cash_final]
      ,[gmt_date_time]
      ,[time_local]
      ,[date_local]
      ,[expiry_date]
      ,[merchant_type]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[pos_pin_capture_code]
      ,[auth_id_rsp_length]
      ,[fee_tran]
      ,[fee_tran_proc]
      ,[acquiring_inst]
      ,[forwarding_inst]
      ,[track2_data]
      ,[ret_ref_no]
      ,[auth_id_rsp]
      ,[rsp_code_req_rsp]
      ,[rsp_code_cmp]
      ,[rsp_code_rev]
      ,[service_restriction_code]
      ,[card_acceptor_term_id]
      ,[card_acceptor_id_code]
      ,[card_acceptor_name_loc]
      ,[additional_rsp_data]
      ,[currency_code_tran]
      ,[amount_available]
      ,[ledger_balance]
      ,[auth_life_cycle]
      ,[authorising_inst]
      ,[extended_payment_code]
      ,[payee]
      ,[receiving_inst]
      ,[account_id_1]
      ,[account_id_2]
      ,[pos_data_code]
      ,[pos_data]
      ,[service_station_data]
      ,[authorisation_reason]
      ,[authorisation_type]
      ,[check_data]
      ,[msg_reason_code_req_in]
      ,[msg_reason_code_req_out]
      ,[msg_reason_code_rev]
      ,[msg_reason_code_adv]
      ,[terminal_owner]
      ,[pos_geographic_data]
      ,[sponsor_bank]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[abort_time]
      ,[abort_reason]
      ,[abort_state]
      ,[abort_rsp_code]
      ,[in_req]
      ,[in_req_rsp]
      ,[in_cmp]
      ,[in_cmp_rsp]
      ,[in_adv]
      ,[in_adv_rsp]
      ,[in_rev]
      ,[in_rev_rsp]
      ,[in_recon_adv]
      ,[in_recon_adv_rsp]
      ,[in_activ_adv]
      ,[in_activ_adv_rsp]
      ,[in_notify_adv_rsp]
      ,[out_req]
      ,[out_req_rsp]
      ,[out_cmp]
      ,[out_cmp_rsp]
      ,[out_adv]
      ,[out_adv_rsp]
      ,[out_rev]
      ,[out_rev_rsp]
      ,[out_recon_adv]
      ,[out_recon_adv_rsp]
      ,[out_activ_adv]
      ,[out_activ_adv_rsp]
      ,[out_notify_adv]
      ,[user_reserved_1]
      ,[card_seq_nr]
      ,[tran_nr_prev]
      ,[tran_nr_next]
      ,[sink_node_acquiring_inst]
      ,[sink_node_forwarding_inst]
      ,[fee_tran_original]
      ,[source_node_fee_original]
      ,[sink_node_fee_original]
      ,[acquirer_participant]
      ,[issuer_participant]
      ,[file_update_code]
      ,[file_update_name]
      ,[file_record_id]
      ,[bank_details]
      ,[payee_name_and_address]
      ,[payer_account_id]
      ,[icc_data_req]
      ,[icc_data_rsp]
      ,[structured_data_req]
      ,[structured_data_rsp]
      ,[card_product]
      ,[source_node_original_node]
      ,[source_node_original_key]
      ,[card_verification_result]
      ,[secure_3d_result]
      ,[track1_data]
      ,[source_node_amount_impact]
      ,[sink_node_amount_impact]
      ,[amount_tran_impact]
      ,[orig_auth_date_settle_req]
      ,[orig_auth_date_settle_rsp]
      ,[issuer_network_id]
      ,[ucaf_data]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[acquirer_network_id]
      ,[sink_node_card_acceptor_id]
      ,[source_node_batch_settlement_date]
      ,[sink_node_batch_settlement_date]
      ,[pan_encrypted]
      ,[pan_reference]
      ,[customer_id]
	 )
        
SELECT [tran_nr]
      ,[totals_processing]
      ,[state]
      ,[msg_class]
      ,[msg_type]
      ,[draft_capture]
      ,[stand_in]
      ,[source_node]
      ,[source_node_key]
      ,[source_node_sys_trace]
      ,[source_node_settlement_entity]
      ,[source_node_batch]
      ,[source_node_batch_exception]
      ,[source_node_date_settlement]
      ,[source_node_amount_requested]
      ,[source_node_amount_approved]
      ,[source_node_amount_final]
      ,[source_node_cash_requested]
      ,[source_node_cash_approved]
      ,[source_node_cash_final]
      ,[source_node_fee]
      ,[source_node_fee_proc]
      ,[source_node_currency_code]
      ,[source_node_conversion_rate]
      ,[source_node_date_conversion]
      ,[source_node_original_data]
      ,[source_node_echo_data]
      ,[source_node_additional_data]
      ,[sink_node]
      ,[sink_node_req_sys_trace]
      ,[sink_node_rev_sys_trace]
      ,[sink_node_adv_sys_trace]
      ,[sink_node_settlement_entity]
      ,[sink_node_batch]
      ,[sink_node_batch_exception]
      ,[sink_node_date_settlement]
      ,[sink_node_amount_requested]
      ,[sink_node_amount_approved]
      ,[sink_node_amount_final]
      ,[sink_node_cash_requested]
      ,[sink_node_cash_approved]
      ,[sink_node_cash_final]
      ,[sink_node_fee]
      ,[sink_node_fee_proc]
      ,[sink_node_currency_code]
      ,[sink_node_conversion_rate]
      ,[sink_node_date_conversion]
      ,[sink_node_original_data]
      ,[sink_node_echo_data]
      ,[control_node]
      ,[totals_group]
      ,[pan]
      ,[tran_type]
      ,[from_account]
      ,[to_account]
      ,[amount_tran_requested]
      ,[amount_tran_approved]
      ,[amount_tran_final]
      ,[amount_cash_requested]
      ,[amount_cash_approved]
      ,[amount_cash_final]
      ,[gmt_date_time]
      ,[time_local]
      ,[date_local]
      ,[expiry_date]
      ,[merchant_type]
      ,[pos_entry_mode]
      ,[pos_condition_code]
      ,[pos_pin_capture_code]
      ,[auth_id_rsp_length]
      ,[fee_tran]
      ,[fee_tran_proc]
      ,[acquiring_inst]
      ,[forwarding_inst]
      ,[track2_data]
      ,[ret_ref_no]
      ,[auth_id_rsp]
      ,[rsp_code_req_rsp]
      ,[rsp_code_cmp]
      ,[rsp_code_rev]
      ,[service_restriction_code]
      ,[card_acceptor_term_id]
      ,[card_acceptor_id_code]
      ,[card_acceptor_name_loc]
      ,[additional_rsp_data]
      ,[currency_code_tran]
      ,[amount_available]
      ,[ledger_balance]
      ,[auth_life_cycle]
      ,[authorising_inst]
      ,[extended_payment_code]
      ,[payee]
      ,[receiving_inst]
      ,[account_id_1]
      ,[account_id_2]
      ,[pos_data_code]
      ,[pos_data]
      ,[service_station_data]
      ,[authorisation_reason]
      ,[authorisation_type]
      ,[check_data]
      ,[msg_reason_code_req_in]
      ,[msg_reason_code_req_out]
      ,[msg_reason_code_rev]
      ,[msg_reason_code_adv]
      ,[terminal_owner]
      ,[pos_geographic_data]
      ,[sponsor_bank]
      ,[address_verification_data]
      ,[address_verification_result]
      ,[abort_time]
      ,[abort_reason]
      ,[abort_state]
      ,[abort_rsp_code]
      ,[in_req]
      ,[in_req_rsp]
      ,[in_cmp]
      ,[in_cmp_rsp]
      ,[in_adv]
      ,[in_adv_rsp]
      ,[in_rev]
      ,[in_rev_rsp]
      ,[in_recon_adv]
      ,[in_recon_adv_rsp]
      ,[in_activ_adv]
      ,[in_activ_adv_rsp]
      ,[in_notify_adv_rsp]
      ,[out_req]
      ,[out_req_rsp]
      ,[out_cmp]
      ,[out_cmp_rsp]
      ,[out_adv]
      ,[out_adv_rsp]
      ,[out_rev]
      ,[out_rev_rsp]
      ,[out_recon_adv]
      ,[out_recon_adv_rsp]
      ,[out_activ_adv]
      ,[out_activ_adv_rsp]
      ,[out_notify_adv]
      ,[user_reserved_1]
      ,[card_seq_nr]
      ,[tran_nr_prev]
      ,[tran_nr_next]
      ,[sink_node_acquiring_inst]
      ,[sink_node_forwarding_inst]
      ,[fee_tran_original]
      ,[source_node_fee_original]
      ,[sink_node_fee_original]
      ,[acquirer_participant]
      ,[issuer_participant]
      ,[file_update_code]
      ,[file_update_name]
      ,[file_record_id]
      ,[bank_details]
      ,[payee_name_and_address]
      ,[payer_account_id]
      ,[icc_data_req]
      ,[icc_data_rsp]
      ,[structured_data_req]
      ,[structured_data_rsp]
      ,[card_product]
      ,[source_node_original_node]
      ,[source_node_original_key]
      ,[card_verification_result]
      ,[secure_3d_result]
      ,[track1_data]
      ,[source_node_amount_impact]
      ,[sink_node_amount_impact]
      ,[amount_tran_impact]
      ,[orig_auth_date_settle_req]
      ,[orig_auth_date_settle_rsp]
      ,[issuer_network_id]
      ,[ucaf_data]
      ,[extended_tran_type]
      ,[from_account_type_qualifier]
      ,[to_account_type_qualifier]
      ,[acquirer_network_id]
      ,[sink_node_card_acceptor_id]
      ,[source_node_batch_settlement_date]
      ,[sink_node_batch_settlement_date]
      ,[pan_encrypted]
      ,[pan_reference]
      ,[customer_id]
       FROM
       	tm_trans (NOLOCK) 
       WHERE 
			source_node =@source_node
			 AND 
			 msg_type =@message_type 
			 AND
			rsp_code_req_rsp =@response_code

       AND
	        tran_local=@dateCursor
	        
	        
	        SET @dateCursor = CONVERT(BIGINT, @dateCursor) + CONVERT(BIGINT, @dateCursor) 
	END
	
	SELECT * FROM #realtime_transactions
	
	DROP TABLE #realtime_transactions