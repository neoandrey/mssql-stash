USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_copy_settlement_transaction_details]    Script Date: 03/23/2017 21:54:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 ALTER PROCEDURE [dbo].[usp_copy_settlement_transaction_details] (@settlement_date NVARCHAR(10), @retention_period INT)  AS
							BEGIN
							
							SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
							
							DECLARE @start_post_tran_id NVARCHAR(30)
							DECLARE @end_post_tran_id NVARCHAR(30)
							DECLARE @last_session_id NVARCHAR(20) 
							DECLARE @previous_settlement_date NVARCHAR(10)
							DECLARE @create_table_sql NVARCHAR(MAX)
							DECLARE @table_name NVARCHAR(MAX);
							DECLARE @previous_table_name NVARCHAR(MAX);
							DECLARE @delete_date NVARCHAR(MAX);
						    DECLARE @delete_table_name VARCHAR(MAX);
						    
							EXEC postilion_office.[dbo].[usp_get_sstl_journal_daily];
							
							SELECT @retention_period = ISNULL(@retention_period,5)
							SET @retention_period = -1*@retention_period;
						    SELECT @delete_date = CONVERT(VARCHAR(10),DATEADD(DAY, @retention_period, GETDATE()),112);
							 
							SET @settlement_date = ISNULL(@settlement_date,CONVERT(VARCHAR(10), GETDATE(),112));
							
							SET @previous_settlement_date = CONVERT(VARCHAR(10), DATEADD(D,-1,@settlement_date),112);

							SET @table_name  = 'settlement_summary_breakdown_details_'+ @settlement_date;
							SET @previous_table_name  = 'settlement_summary_breakdown_details_'+ @previous_settlement_date;
							SET @delete_table_name  = 'settlement_summary_breakdown_details_'+ @delete_date;
							
							EXEC ('IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'''+@table_name+''') AND type in (N''U'')) BEGIN CREATE TABLE [dbo].['+@table_name+'](	[bank_code] [varchar](10) NOT NULL,[trxn_category] [varchar](49) NULL,[Debit_account_type] [varchar](55) NOT NULL,[Credit_account_type] [varchar](56) NOT NULL,[trxn_amount] [float] NOT NULL,[trxn_fee] [float] NOT NULL,[trxn_date] [datetime] NOT NULL,[currency] [char](3) NULL,[late_reversal] [int] NOT NULL,[card_type] [int] NULL,[terminal_type] [int] NULL,[source_node_name] [varchar](30) NULL,[Unique_key] [varchar](54) NULL,[Acquirer] [varchar](50) NULL,[Issuer] [varchar](50) NULL,[Volume] [int] NOT NULL,[Value_RequestedAmount] [numeric](16, 0) NULL,[Value_SettleAmount] [numeric](16, 0) NULL,[ptid] [bigint] NOT NULL,[ptcid] [bigint] NOT NULL,[index_no] [int] NOT NULL,[post_tran_id_1] [bigint] NOT NULL,[post_tran_cust_id_1] [bigint] NOT NULL,[PT_settle_entity_id] [int] NULL,[PT_batch_nr] [int] NULL,[PT_prev_post_tran_id] [bigint] NULL,[PT_next_post_tran_id] [bigint] NULL,[PT_sink_node_name] [varchar](30) NULL,[PT_tran_postilion_originated] [numeric](1, 0) NOT NULL,[PT_tran_completed] [numeric](1, 0) NOT NULL,[PT_message_type] [char](4) NOT NULL,[PT_tran_type] [char](2) NULL,[PT_tran_nr] [bigint] NOT NULL,[PT_system_trace_audit_nr] [char](6) NULL,[PT_rsp_code_req] [char](2) NULL,[PT_rsp_code_rsp] [char](2) NULL,[PT_abort_rsp_code] [char](2) NULL,[PT_auth_id_rsp] [varchar](10) NULL,[PT_auth_type] [numeric](1, 0) NULL,[PT_auth_reason] [numeric](1, 0) NULL,[PT_retention_data] [varchar](999) NULL,[PT_acquiring_inst_id_code] [varchar](11) NULL,[PT_message_reason_code] [char](4) NULL,[PT_sponsor_bank] [char](8) NULL,[PT_retrieval_reference_nr] [char](12) NULL,[PT_datetime_tran_gmt] [datetime] NULL,[PT_datetime_tran_local] [datetime] NOT NULL,[PT_datetime_req] [datetime] NOT NULL,[PT_datetime_rsp] [datetime] NULL,[PT_realtime_business_date] [datetime] NOT NULL,[PT_recon_business_date] [datetime] NOT NULL,[PT_from_account_type] [char](2) NULL,[PT_to_account_type] [char](2) NULL,[PT_from_account_id] [varchar](28) NULL,[PT_to_account_id] [varchar](28) NULL,[PT_tran_amount_req] [numeric](16, 0) NULL,[PT_tran_amount_rsp] [numeric](16, 0) NULL,[PT_settle_amount_impact] [numeric](16, 0) NULL,[PT_tran_cash_req] [numeric](16, 0) NULL,[PT_tran_cash_rsp] [numeric](16, 0) NULL,[PT_tran_currency_code] [char](3) NULL,[PT_tran_tran_fee_req] [numeric](16, 0) NULL,[PT_tran_tran_fee_rsp] [numeric](16, 0) NULL,[PT_tran_tran_fee_currency_code] [char](3) NULL,[PT_tran_proc_fee_req] [numeric](16, 0) NULL,[PT_tran_proc_fee_rsp] [numeric](16, 0) NULL,[PT_tran_proc_fee_currency_code] [char](3) NULL,[PT_settle_amount_req] [numeric](16, 0) NULL,[PT_settle_amount_rsp] [numeric](16, 0) NULL,[PT_settle_cash_req] [numeric](16, 0) NULL,[PT_settle_cash_rsp] [numeric](16, 0) NULL,[PT_settle_tran_fee_req] [numeric](16, 0) NULL,[PT_settle_tran_fee_rsp] [numeric](16, 0) NULL,[PT_settle_proc_fee_req] [numeric](16, 0) NULL,[PT_settle_proc_fee_rsp] [numeric](16, 0) NULL,[PT_settle_currency_code] [char](3) NULL,[PT_pos_entry_mode] [char](3) NULL,[PT_pos_condition_code] [char](2) NULL,[PT_additional_rsp_data] [varchar](25) NULL,[PT_tran_reversed] [char](1) NULL,[PT_prev_tran_approved] [numeric](1, 0) NULL,[PT_issuer_network_id] [varchar](11) NULL,[PT_acquirer_network_id] [varchar](11) NULL,[PT_extended_tran_type] [char](4) NULL,[PT_from_account_type_qualifier] [char](1) NULL,[PT_to_account_type_qualifier] [char](1) NULL,[PT_bank_details] [varchar](31) NULL,[PT_payee] [char](25) NULL,[PT_card_verification_result] [char](1) NULL,[PT_online_system_id] [int] NULL,[PT_participant_id] [int] NULL,[PT_opp_participant_id] [int] NULL,[PT_receiving_inst_id_code] [varchar](11) NULL,[PT_routing_type] [int] NULL,[PT_pt_pos_operating_environment] [char](1) NULL,[PT_pt_pos_card_input_mode] [char](1) NULL,[PT_pt_pos_cardholder_auth_method] [char](1) NULL,[PT_pt_pos_pin_capture_ability] [char](1) NULL,[PT_pt_pos_terminal_operator] [char](1) NULL,[PT_source_node_key] [varchar](32) NULL,[PT_proc_online_system_id] [int] NULL,[PTC_post_tran_cust_id] [bigint] NULL,[PTC_source_node_name] [varchar](30) NULL,[PTC_draft_capture] [int] NULL,[PTC_pan] [varchar](19) NULL,[PTC_card_seq_nr] [varchar](3) NULL,[PTC_expiry_date] [char](4) NULL,[PTC_service_restriction_code] [char](3) NULL,[PTC_terminal_id] [char](8) NULL,[PTC_terminal_owner] [varchar](25) NULL,[PTC_card_acceptor_id_code] [char](15) NULL,[PTC_mapped_card_acceptor_id_code] [char](15) NULL,[PTC_merchant_type] [char](4) NULL,[PTC_card_acceptor_name_loc] [char](40) NULL,[PTC_address_verification_data] [varchar](29) NULL,[PTC_address_verification_result] [char](1) NULL,[PTC_check_data] [varchar](70) NULL,[PTC_totals_group] [varchar](12) NULL,[PTC_card_product] [varchar](20) NULL,[PTC_pos_card_data_input_ability] [char](1) NULL,[PTC_pos_cardholder_auth_ability] [char](1) NULL,[PTC_pos_card_capture_ability] [char](1) NULL,[PTC_pos_operating_environment] [char](1) NULL,[PTC_pos_cardholder_present] [char](1) NULL,[PTC_pos_card_present] [char](1) NULL,[PTC_pos_card_data_input_mode] [char](1) NULL,[PTC_pos_cardholder_auth_method] [char](1) NULL,[PTC_pos_cardholder_auth_entity] [char](1) NULL,[PTC_pos_card_data_output_ability] [char](1) NULL,[PTC_pos_terminal_output_ability] [char](1) NULL,[PTC_pos_pin_capture_ability] [char](1) NULL,[PTC_pos_terminal_operator] [char](1) NULL,[PTC_pos_terminal_type] [char](2) NULL,[PTC_pan_search] [int] NULL,[PTC_pan_encrypted] [char](18) NULL,[PTC_pan_reference] [char](42) NULL,[PTSP_Account_Nr] [varchar](50) NULL,[ptsp_code] [varchar](4) NULL,[account_PTSP_Code] [varchar](3) NULL,[PTSP_Name] [varchar](50) NULL,[rdm_amt] [decimal](18, 2) NULL,[Reward_Code] [char](4) NULL,[Reward_discount] [decimal](7, 6) NULL,[rr_number] [varchar](20) NULL,[sdi_tran_id] [bigint] NULL,[se_id] [int] NULL,[session_id] [int] NULL,[Sort_Code] [varchar](50) NULL,[spay_session_id] [int] NULL,[spst_session_id] [int] NULL,[stan] [varchar](20) NULL,[tag] [varchar](4000) NULL,[ptsp_terminal_id] [varchar](15) NULL,[reward_terminal_id] [varchar](10) NULL,[terminal_mode] [varchar](20) NULL,[trans_date] [datetime] NULL,[txn_id] [int] NULL,[web_category_code] [char](4) NULL,[web_category_name] [varchar](50) NULL,[web_fee_type] [char](1) NULL,[web_merchant_disc] [decimal](7, 6) NULL,[web_amount_cap] [float] NULL,[web_fee_cap] [float] NULL,[web_bearer] [char](1) NULL,[owner_terminal_id] [varchar](15) NULL,[owner_terminal_code] [varchar](4) NULL,[acc_post_id] [int] NULL,[Account_Name] [varchar](50) NULL,[account_nr] [varchar](50) NULL,[acquirer_inst_id1] [varchar](20) NULL,[acquirer_inst_id2] [varchar](20) NULL,[acquirer_inst_id3] [varchar](20) NULL,[acquirer_inst_id4] [varchar](20) NULL,[acquirer_inst_id5] [varchar](20) NULL,[Acquiring_bank] [varchar](50) NULL,[acquiring_inst_id_code] [varchar](50) NULL,[Addit_charge] [decimal](7, 6) NULL,[Addit_party] [varchar](10) NULL,[adj_id] [bigint] NULL,[journal_amount] [float] NULL,[xls_amount] [float] NULL,[Amount_amount_id] [int] NULL,[merch_cat_amount_cap] [float] NULL,[merch_cat_visa_amount_cap] [float] NULL,[reward_amount_cap] [decimal](18, 0) NULL,[Amount_config_set_id] [int] NULL,[Amount_config_state] [int] NULL,[Amount_description] [varchar](255) NULL,[amount_id] [int] NULL,[Amount_name] [varchar](100) NULL,[Amount_se_id] [int] NULL,[amount_value_id] [int] NULL,[Authorized_Person] [varchar](50) NULL,[ACC_BANK_CODE] [varchar](50) NULL,[BANK_CODE1] [varchar](10) NULL,[BANK_INSTITUTION_NAME] [varchar](50) NULL,[merch_cat_bearer] [char](1) NULL,[merch_cat_visa_bearer] [char](1) NULL,[business_date] [datetime] NULL,[card_acceptor_id_code] [varchar](50) NULL,[card_acceptor_name_loc] [varchar](1000) NULL,[cashier_acct] [varchar](50) NULL,[cashier_code] [varchar](12) NULL,[cashier_ext_trans_code] [varchar](8) NULL,[cashier_name] [varchar](20) NULL,[merch_cat_visa_category_code] [char](4) NULL,[merch_cat_category_code] [char](4) NULL,[merch_cat_visa_category_name] [varchar](50) NULL,[merch_cat_category_name] [varchar](50) NULL,[CBN_Code1] [varchar](20) NULL,[CBN_Code2] [varchar](20) NULL,[CBN_Code3] [varchar](20) NULL,[CBN_Code4] [varchar](20) NULL,[coa_coa_id] [int] NULL,[coa_config_set_id] [int] NULL,[coa_config_state] [int] NULL,[coa_description] [varchar](255) NULL,[coa_id] [int] NULL,[coa_name] [varchar](100) NULL,[coa_se_id] [int] NULL,[coa_type] [int] NULL,[config_set_id] [int] NULL,[credit_acc_id] [int] NULL,[credit_acc_nr_id] [int] NULL,[credit_cardholder_acc_id] [varchar](28) NULL,[credit_cardholder_acc_type] [char](2) NULL,[CreditAccNr_acc_id] [int] NULL,[CreditAccNr_acc_nr] [varchar](40) NULL,[CreditAccNr_acc_nr_id] [int] NULL,[CreditAccNr_aggregation_id] [int] NULL,[CreditAccNr_config_set_id] [int] NULL,[CreditAccNr_config_state] [int] NULL,[CreditAccNr_se_id] [int] NULL,[CreditAccNr_state] [int] NULL,[Date_Modified] [datetime] NULL,[debit_acc_id] [int] NULL,[debit_acc_nr_id] [int] NULL,[debit_cardholder_acc_id] [varchar](28) NULL,[debit_cardholder_acc_type] [char](2) NULL,[DebitAccNr_acc_id] [int] NULL,[DebitAccNr_acc_nr] [varchar](40) NULL,[DebitAccNr_acc_nr_id] [int] NULL,[DebitAccNr_aggregation_id] [int] NULL,[DebitAccNr_config_set_id] [int] NULL,[DebitAccNr_config_state] [int] NULL,[DebitAccNr_se_id] [int] NULL,[DebitAccNr_state] [int] NULL,[entry_id] [bigint] NULL,[extended_trans_type] [varchar](100) NULL,[fee] [float] NULL,[Fee_amount_id] [int] NULL,[merch_cat_fee_cap] [float] NULL,[merch_cat_visa_fee_cap] [float] NULL,[reward_fee_cap] [decimal](18, 0) NULL,[Fee_config_set_id] [int] NULL,[Fee_config_state] [int] NULL,[Fee_description] [varchar](255) NULL,[Fee_Discount] [decimal](18, 7) NULL,[Fee_fee_id] [int] NULL,[fee_id] [int] NULL,[Fee_name] [varchar](100) NULL,[Fee_se_id] [int] NULL,[merch_cat_category_fee_type] [char](1) NULL,[merch_cat_category_visa_fee_type] [char](1) NULL,[journal_fee_type] [int] NULL,[fee_value_id] [int] NULL,[granularity_element] [varchar](100) NULL,[merch_cat_category_merch_discount] [decimal](7, 6) NULL,[merch_cat_category_visa_merch_discount] [decimal](7, 6) NULL,[merchant_id] [varchar](20) NULL,[merchant_type] [varchar](30) NULL,[nt_fee] [float] NULL,[nt_fee_acc_post_id] [int] NULL,[nt_fee_id] [int] NULL,[nt_fee_value_id] [int] NULL,[pan] [varchar](20) NULL,[post_tran_cust_id] [bigint] NULL,[post_tran_id] [bigint] NULL) ON [PRIMARY] END');
							EXEC ('IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'''+@previous_table_name+''') AND type in (N''U'')) BEGIN CREATE TABLE [dbo].['+@previous_table_name+'](	[bank_code] [varchar](10) NOT NULL,[trxn_category] [varchar](49) NULL,[Debit_account_type] [varchar](55) NOT NULL,[Credit_account_type] [varchar](56) NOT NULL,[trxn_amount] [float] NOT NULL,[trxn_fee] [float] NOT NULL,[trxn_date] [datetime] NOT NULL,[currency] [char](3) NULL,[late_reversal] [int] NOT NULL,[card_type] [int] NULL,[terminal_type] [int] NULL,[source_node_name] [varchar](30) NULL,[Unique_key] [varchar](54) NULL,[Acquirer] [varchar](50) NULL,[Issuer] [varchar](50) NULL,[Volume] [int] NOT NULL,[Value_RequestedAmount] [numeric](16, 0) NULL,[Value_SettleAmount] [numeric](16, 0) NULL,[ptid] [bigint] NOT NULL,[ptcid] [bigint] NOT NULL,[index_no] [int] NOT NULL,[post_tran_id_1] [bigint] NOT NULL,[post_tran_cust_id_1] [bigint] NOT NULL,[PT_settle_entity_id] [int] NULL,[PT_batch_nr] [int] NULL,[PT_prev_post_tran_id] [bigint] NULL,[PT_next_post_tran_id] [bigint] NULL,[PT_sink_node_name] [varchar](30) NULL,[PT_tran_postilion_originated] [numeric](1, 0) NOT NULL,[PT_tran_completed] [numeric](1, 0) NOT NULL,[PT_message_type] [char](4) NOT NULL,[PT_tran_type] [char](2) NULL,[PT_tran_nr] [bigint] NOT NULL,[PT_system_trace_audit_nr] [char](6) NULL,[PT_rsp_code_req] [char](2) NULL,[PT_rsp_code_rsp] [char](2) NULL,[PT_abort_rsp_code] [char](2) NULL,[PT_auth_id_rsp] [varchar](10) NULL,[PT_auth_type] [numeric](1, 0) NULL,[PT_auth_reason] [numeric](1, 0) NULL,[PT_retention_data] [varchar](999) NULL,[PT_acquiring_inst_id_code] [varchar](11) NULL,[PT_message_reason_code] [char](4) NULL,[PT_sponsor_bank] [char](8) NULL,[PT_retrieval_reference_nr] [char](12) NULL,[PT_datetime_tran_gmt] [datetime] NULL,[PT_datetime_tran_local] [datetime] NOT NULL,[PT_datetime_req] [datetime] NOT NULL,[PT_datetime_rsp] [datetime] NULL,[PT_realtime_business_date] [datetime] NOT NULL,[PT_recon_business_date] [datetime] NOT NULL,[PT_from_account_type] [char](2) NULL,[PT_to_account_type] [char](2) NULL,[PT_from_account_id] [varchar](28) NULL,[PT_to_account_id] [varchar](28) NULL,[PT_tran_amount_req] [numeric](16, 0) NULL,[PT_tran_amount_rsp] [numeric](16, 0) NULL,[PT_settle_amount_impact] [numeric](16, 0) NULL,[PT_tran_cash_req] [numeric](16, 0) NULL,[PT_tran_cash_rsp] [numeric](16, 0) NULL,[PT_tran_currency_code] [char](3) NULL,[PT_tran_tran_fee_req] [numeric](16, 0) NULL,[PT_tran_tran_fee_rsp] [numeric](16, 0) NULL,[PT_tran_tran_fee_currency_code] [char](3) NULL,[PT_tran_proc_fee_req] [numeric](16, 0) NULL,[PT_tran_proc_fee_rsp] [numeric](16, 0) NULL,[PT_tran_proc_fee_currency_code] [char](3) NULL,[PT_settle_amount_req] [numeric](16, 0) NULL,[PT_settle_amount_rsp] [numeric](16, 0) NULL,[PT_settle_cash_req] [numeric](16, 0) NULL,[PT_settle_cash_rsp] [numeric](16, 0) NULL,[PT_settle_tran_fee_req] [numeric](16, 0) NULL,[PT_settle_tran_fee_rsp] [numeric](16, 0) NULL,[PT_settle_proc_fee_req] [numeric](16, 0) NULL,[PT_settle_proc_fee_rsp] [numeric](16, 0) NULL,[PT_settle_currency_code] [char](3) NULL,[PT_pos_entry_mode] [char](3) NULL,[PT_pos_condition_code] [char](2) NULL,[PT_additional_rsp_data] [varchar](25) NULL,[PT_tran_reversed] [char](1) NULL,[PT_prev_tran_approved] [numeric](1, 0) NULL,[PT_issuer_network_id] [varchar](11) NULL,[PT_acquirer_network_id] [varchar](11) NULL,[PT_extended_tran_type] [char](4) NULL,[PT_from_account_type_qualifier] [char](1) NULL,[PT_to_account_type_qualifier] [char](1) NULL,[PT_bank_details] [varchar](31) NULL,[PT_payee] [char](25) NULL,[PT_card_verification_result] [char](1) NULL,[PT_online_system_id] [int] NULL,[PT_participant_id] [int] NULL,[PT_opp_participant_id] [int] NULL,[PT_receiving_inst_id_code] [varchar](11) NULL,[PT_routing_type] [int] NULL,[PT_pt_pos_operating_environment] [char](1) NULL,[PT_pt_pos_card_input_mode] [char](1) NULL,[PT_pt_pos_cardholder_auth_method] [char](1) NULL,[PT_pt_pos_pin_capture_ability] [char](1) NULL,[PT_pt_pos_terminal_operator] [char](1) NULL,[PT_source_node_key] [varchar](32) NULL,[PT_proc_online_system_id] [int] NULL,[PTC_post_tran_cust_id] [bigint] NULL,[PTC_source_node_name] [varchar](30) NULL,[PTC_draft_capture] [int] NULL,[PTC_pan] [varchar](19) NULL,[PTC_card_seq_nr] [varchar](3) NULL,[PTC_expiry_date] [char](4) NULL,[PTC_service_restriction_code] [char](3) NULL,[PTC_terminal_id] [char](8) NULL,[PTC_terminal_owner] [varchar](25) NULL,[PTC_card_acceptor_id_code] [char](15) NULL,[PTC_mapped_card_acceptor_id_code] [char](15) NULL,[PTC_merchant_type] [char](4) NULL,[PTC_card_acceptor_name_loc] [char](40) NULL,[PTC_address_verification_data] [varchar](29) NULL,[PTC_address_verification_result] [char](1) NULL,[PTC_check_data] [varchar](70) NULL,[PTC_totals_group] [varchar](12) NULL,[PTC_card_product] [varchar](20) NULL,[PTC_pos_card_data_input_ability] [char](1) NULL,[PTC_pos_cardholder_auth_ability] [char](1) NULL,[PTC_pos_card_capture_ability] [char](1) NULL,[PTC_pos_operating_environment] [char](1) NULL,[PTC_pos_cardholder_present] [char](1) NULL,[PTC_pos_card_present] [char](1) NULL,[PTC_pos_card_data_input_mode] [char](1) NULL,[PTC_pos_cardholder_auth_method] [char](1) NULL,[PTC_pos_cardholder_auth_entity] [char](1) NULL,[PTC_pos_card_data_output_ability] [char](1) NULL,[PTC_pos_terminal_output_ability] [char](1) NULL,[PTC_pos_pin_capture_ability] [char](1) NULL,[PTC_pos_terminal_operator] [char](1) NULL,[PTC_pos_terminal_type] [char](2) NULL,[PTC_pan_search] [int] NULL,[PTC_pan_encrypted] [char](18) NULL,[PTC_pan_reference] [char](42) NULL,[PTSP_Account_Nr] [varchar](50) NULL,[ptsp_code] [varchar](4) NULL,[account_PTSP_Code] [varchar](3) NULL,[PTSP_Name] [varchar](50) NULL,[rdm_amt] [decimal](18, 2) NULL,[Reward_Code] [char](4) NULL,[Reward_discount] [decimal](7, 6) NULL,[rr_number] [varchar](20) NULL,[sdi_tran_id] [bigint] NULL,[se_id] [int] NULL,[session_id] [int] NULL,[Sort_Code] [varchar](50) NULL,[spay_session_id] [int] NULL,[spst_session_id] [int] NULL,[stan] [varchar](20) NULL,[tag] [varchar](4000) NULL,[ptsp_terminal_id] [varchar](15) NULL,[reward_terminal_id] [varchar](10) NULL,[terminal_mode] [varchar](20) NULL,[trans_date] [datetime] NULL,[txn_id] [int] NULL,[web_category_code] [char](4) NULL,[web_category_name] [varchar](50) NULL,[web_fee_type] [char](1) NULL,[web_merchant_disc] [decimal](7, 6) NULL,[web_amount_cap] [float] NULL,[web_fee_cap] [float] NULL,[web_bearer] [char](1) NULL,[owner_terminal_id] [varchar](15) NULL,[owner_terminal_code] [varchar](4) NULL,[acc_post_id] [int] NULL,[Account_Name] [varchar](50) NULL,[account_nr] [varchar](50) NULL,[acquirer_inst_id1] [varchar](20) NULL,[acquirer_inst_id2] [varchar](20) NULL,[acquirer_inst_id3] [varchar](20) NULL,[acquirer_inst_id4] [varchar](20) NULL,[acquirer_inst_id5] [varchar](20) NULL,[Acquiring_bank] [varchar](50) NULL,[acquiring_inst_id_code] [varchar](50) NULL,[Addit_charge] [decimal](7, 6) NULL,[Addit_party] [varchar](10) NULL,[adj_id] [bigint] NULL,[journal_amount] [float] NULL,[xls_amount] [float] NULL,[Amount_amount_id] [int] NULL,[merch_cat_amount_cap] [float] NULL,[merch_cat_visa_amount_cap] [float] NULL,[reward_amount_cap] [decimal](18, 0) NULL,[Amount_config_set_id] [int] NULL,[Amount_config_state] [int] NULL,[Amount_description] [varchar](255) NULL,[amount_id] [int] NULL,[Amount_name] [varchar](100) NULL,[Amount_se_id] [int] NULL,[amount_value_id] [int] NULL,[Authorized_Person] [varchar](50) NULL,[ACC_BANK_CODE] [varchar](50) NULL,[BANK_CODE1] [varchar](10) NULL,[BANK_INSTITUTION_NAME] [varchar](50) NULL,[merch_cat_bearer] [char](1) NULL,[merch_cat_visa_bearer] [char](1) NULL,[business_date] [datetime] NULL,[card_acceptor_id_code] [varchar](50) NULL,[card_acceptor_name_loc] [varchar](1000) NULL,[cashier_acct] [varchar](50) NULL,[cashier_code] [varchar](12) NULL,[cashier_ext_trans_code] [varchar](8) NULL,[cashier_name] [varchar](20) NULL,[merch_cat_visa_category_code] [char](4) NULL,[merch_cat_category_code] [char](4) NULL,[merch_cat_visa_category_name] [varchar](50) NULL,[merch_cat_category_name] [varchar](50) NULL,[CBN_Code1] [varchar](20) NULL,[CBN_Code2] [varchar](20) NULL,[CBN_Code3] [varchar](20) NULL,[CBN_Code4] [varchar](20) NULL,[coa_coa_id] [int] NULL,[coa_config_set_id] [int] NULL,[coa_config_state] [int] NULL,[coa_description] [varchar](255) NULL,[coa_id] [int] NULL,[coa_name] [varchar](100) NULL,[coa_se_id] [int] NULL,[coa_type] [int] NULL,[config_set_id] [int] NULL,[credit_acc_id] [int] NULL,[credit_acc_nr_id] [int] NULL,[credit_cardholder_acc_id] [varchar](28) NULL,[credit_cardholder_acc_type] [char](2) NULL,[CreditAccNr_acc_id] [int] NULL,[CreditAccNr_acc_nr] [varchar](40) NULL,[CreditAccNr_acc_nr_id] [int] NULL,[CreditAccNr_aggregation_id] [int] NULL,[CreditAccNr_config_set_id] [int] NULL,[CreditAccNr_config_state] [int] NULL,[CreditAccNr_se_id] [int] NULL,[CreditAccNr_state] [int] NULL,[Date_Modified] [datetime] NULL,[debit_acc_id] [int] NULL,[debit_acc_nr_id] [int] NULL,[debit_cardholder_acc_id] [varchar](28) NULL,[debit_cardholder_acc_type] [char](2) NULL,[DebitAccNr_acc_id] [int] NULL,[DebitAccNr_acc_nr] [varchar](40) NULL,[DebitAccNr_acc_nr_id] [int] NULL,[DebitAccNr_aggregation_id] [int] NULL,[DebitAccNr_config_set_id] [int] NULL,[DebitAccNr_config_state] [int] NULL,[DebitAccNr_se_id] [int] NULL,[DebitAccNr_state] [int] NULL,[entry_id] [bigint] NULL,[extended_trans_type] [varchar](100) NULL,[fee] [float] NULL,[Fee_amount_id] [int] NULL,[merch_cat_fee_cap] [float] NULL,[merch_cat_visa_fee_cap] [float] NULL,[reward_fee_cap] [decimal](18, 0) NULL,[Fee_config_set_id] [int] NULL,[Fee_config_state] [int] NULL,[Fee_description] [varchar](255) NULL,[Fee_Discount] [decimal](18, 7) NULL,[Fee_fee_id] [int] NULL,[fee_id] [int] NULL,[Fee_name] [varchar](100) NULL,[Fee_se_id] [int] NULL,[merch_cat_category_fee_type] [char](1) NULL,[merch_cat_category_visa_fee_type] [char](1) NULL,[journal_fee_type] [int] NULL,[fee_value_id] [int] NULL,[granularity_element] [varchar](100) NULL,[merch_cat_category_merch_discount] [decimal](7, 6) NULL,[merch_cat_category_visa_merch_discount] [decimal](7, 6) NULL,[merchant_id] [varchar](20) NULL,[merchant_type] [varchar](30) NULL,[nt_fee] [float] NULL,[nt_fee_acc_post_id] [int] NULL,[nt_fee_id] [int] NULL,[nt_fee_value_id] [int] NULL,[pan] [varchar](20) NULL,[post_tran_cust_id] [bigint] NULL,[post_tran_id] [bigint] NULL) ON [PRIMARY] CREATE INDEX [ix_'+@previous_table_name+'_1] ON ['+@previous_table_name+'](	[post_tran_id])  END');							
							EXEC ('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'''+@delete_table_name+''') AND type in (N''U'')) BEGIN DROP TABLE [dbo].['+@delete_table_name+'] END');

							
							IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
							DROP TABLE ##temp_query_table;
							END
							EXEC (' SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED SELECT  MAX(post_tran_id) post_tran_id INTO  ##temp_query_table  FROM  [postilion_office].[dbo].['+@table_name+'] (NOLOCK)')
							IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
								SELECT @start_post_tran_id = ISNULL(post_tran_id,0)  FROM  ##temp_query_table;
								DROP TABLE ##temp_query_table;
							END
						

							IF (@start_post_tran_id = 0 OR @start_post_tran_id IS NULL) 
							 BEGIN
							 IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
							DROP TABLE ##temp_query_table;
							END
							 
							 
									EXEC ('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED SELECT  MAX(post_tran_id) post_tran_id INTO  ##temp_query_table  FROM  [postilion_office].[dbo].['+@previous_table_name+'] (NOLOCK)')
									IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
										SELECT @start_post_tran_id = ISNULL(post_tran_id,0)  FROM  ##temp_query_table;
										DROP TABLE ##temp_query_table;
									END
								
									IF (@start_post_tran_id <> 0 AND @start_post_tran_id IS not NULL)
									BEGIN      			
								IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
							DROP TABLE ##temp_query_table;
							END
							EXEC ('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED SELECT MIN (last_post_tran_id) post_tran_id INTO  ##temp_query_table  FROM postilion_office.dbo.sstl_session (NOLOCK) WHERE CONVERT(VARCHAR(10),datetime_started ,112)='''+@settlement_date+''' and completed =1 ')
							IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
								SELECT @end_post_tran_id = ISNULL(post_tran_id,0)  FROM  ##temp_query_table;
								DROP TABLE ##temp_query_table;
							END
									
									
														EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED IF (OBJECT_ID(''tempdb.dbo.##settle_tran_details'') IS NOT NULL) BEGIN
														DROP TABLE ##settle_tran_details
														END
														
														IF (OBJECT_ID(''tempdb.dbo.##temp_journal_data_local'') IS NOT NULL) BEGIN
														DROP TABLE ##temp_journal_data_local
														END
														
														IF (OBJECT_ID(''tempdb.dbo.##temp_post_tran_data_local'') IS NOT NULL) BEGIN
														DROP TABLE ##temp_post_tran_data_local
														END
														
														 SELECT  
														J.adj_id
														,J.entry_id
														,J.config_set_id
														,J.session_id
														,J.post_tran_id
														,J.post_tran_cust_id
														,J.sdi_tran_id
														,J.acc_post_id
														,J.nt_fee_acc_post_id
														,J.coa_id
														,J.coa_se_id
														,J.se_id
														,J.amount
														,J.amount_id
														,J.amount_value_id
														,J.fee
														,J.fee_id
														,J.fee_value_id
														,J.nt_fee
														,J.nt_fee_id
														,J.nt_fee_value_id
														,J.debit_acc_nr_id
														,J.debit_acc_id
														,J.debit_cardholder_acc_id
														,J.debit_cardholder_acc_type
														,J.credit_acc_nr_id
														,J.credit_acc_id
															,J.credit_cardholder_acc_id
															,J.credit_cardholder_acc_type
															,J.business_date
															,J.granularity_element
															,J.tag
															,J.spay_session_id
															,J.spst_session_id
															,DebitAccNr.config_set_id DebitAccNr_config_set_id
															,DebitAccNr.acc_nr_id  DebitAccNr_acc_nr_id
															,DebitAccNr.se_id	DebitAccNr_se_id
															,DebitAccNr.acc_id	DebitAccNr_acc_id
															,DebitAccNr.acc_nr	DebitAccNr_acc_nr
															,DebitAccNr.aggregation_id DebitAccNr_aggregation_id
															,DebitAccNr.state	DebitAccNr_state
															,DebitAccNr.config_state DebitAccNr_config_state
															,CreditAccNr.config_set_id CreditAccNr_config_set_id
															,CreditAccNr.acc_nr_id  CreditAccNr_acc_nr_id
															,CreditAccNr.se_id	CreditAccNr_se_id
															,CreditAccNr.acc_id	CreditAccNr_acc_id
															,CreditAccNr.acc_nr	CreditAccNr_acc_nr
															,CreditAccNr.aggregation_id CreditAccNr_aggregation_id
															,CreditAccNr.state	CreditAccNr_state
															,CreditAccNr.config_state CreditAccNr_config_state
															,Amount.config_set_id	Amount_config_set_id
															,Amount.amount_id	Amount_amount_id
															,Amount.se_id	Amount_se_id
															,Amount.name	Amount_name
															,Amount.description	Amount_description
															,Amount.config_state	Amount_config_state
															,Fee.config_set_id Fee_config_set_id
															,Fee.fee_id	Fee_fee_id
															,Fee.se_id	Fee_se_id
															,Fee.name	Fee_name
															,Fee.description Fee_description
															,Fee.type	Fee_type
															,Fee.amount_id Fee_amount_id
															,Fee.config_state Fee_config_state
															,coa.config_set_id coa_config_set_id
															,coa.coa_id	coa_coa_id
															,coa.name	coa_name
															,coa.description	coa_description
															,coa.type	coa_type
															,coa.config_state	coa_config_state
															 INTO  ##temp_journal_data_local
															FROM	(SELECT  Jr.adj_id,Jr.entry_id,Jr.config_set_id,Jr.session_id,Jr.post_tran_id,Jr.post_tran_cust_id,Jr.sdi_tran_id,Jr.acc_post_id,Jr.nt_fee_acc_post_id,Jr.coa_id,Jr.coa_se_id,Jr.se_id,Jr.amount,Jr.amount_id,Jr.amount_value_id,Jr.fee,Jr.fee_id,Jr.fee_value_id,Jr.nt_fee,Jr.nt_fee_id,Jr.nt_fee_value_id,Jr.debit_acc_nr_id,Jr.debit_acc_id,Jr.debit_cardholder_acc_id,Jr.debit_cardholder_acc_type,Jr.credit_acc_nr_id,Jr.credit_acc_id,Jr.credit_cardholder_acc_id,Jr.credit_cardholder_acc_type,Jr.business_date,Jr.granularity_element,Jr.tag,Jr.spay_session_id,Jr.spst_session_id FROM dbo.[sstl_journal_temp] jr WHERE post_tran_id  > '+@start_post_tran_id+'  AND post_tran_id <='+@end_post_tran_id+'	AND business_date = '''+@previous_settlement_date+''') J 
															LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
															ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
															LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
															ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
															LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
															ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
															LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
															ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
															LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
															ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
															OPTION(RECOMPILE,optimize for unknown)
															');
															
															exec(' SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
																SELECT
															PT.[post_tran_id]	PT_post_tran_id
															,PT.[post_tran_cust_id]	PT_post_tran_cust_id
															,PT.[settle_entity_id]	PT_settle_entity_id
															,PT.[batch_nr]	PT_batch_nr
															,PT.[prev_post_tran_id]	PT_prev_post_tran_id
															,PT.[next_post_tran_id]	PT_next_post_tran_id
															,PT.[sink_node_name]	PT_sink_node_name
															,PT.[tran_postilion_originated]	PT_tran_postilion_originated
															,PT.[tran_completed]	PT_tran_completed
															,PT.[message_type]	PT_message_type
															,PT.[tran_type]	PT_tran_type
															,PT.[tran_nr]	PT_tran_nr
															,PT.[system_trace_audit_nr]	PT_system_trace_audit_nr
															,PT.[rsp_code_req]	PT_rsp_code_req
															,PT.[rsp_code_rsp]	PT_rsp_code_rsp
															,PT.[abort_rsp_code]	PT_abort_rsp_code
															,PT.[auth_id_rsp]	PT_auth_id_rsp
															,PT.[auth_type]	PT_auth_type
															,PT.[auth_reason]	PT_auth_reason
															,PT.[retention_data]	PT_retention_data
															,PT.[acquiring_inst_id_code]	PT_acquiring_inst_id_code
															,PT.[message_reason_code]	PT_message_reason_code
															,PT.[sponsor_bank]	PT_sponsor_bank
															,PT.[retrieval_reference_nr]	PT_retrieval_reference_nr
															,PT.[datetime_tran_gmt]	PT_datetime_tran_gmt
															,PT.[datetime_tran_local]	PT_datetime_tran_local
															,PT.[datetime_req]	PT_datetime_req
															,PT.[datetime_rsp]	PT_datetime_rsp
															,PT.[realtime_business_date]	PT_realtime_business_date
															,PT.[recon_business_date]	PT_recon_business_date
															,PT.[from_account_type]	PT_from_account_type
															,PT.[to_account_type]	PT_to_account_type
															,PT.[from_account_id]	PT_from_account_id
															,PT.[to_account_id]	PT_to_account_id
															,PT.[tran_amount_req]	PT_tran_amount_req
															,PT.[tran_amount_rsp]	PT_tran_amount_rsp
															,PT.[settle_amount_impact]	PT_settle_amount_impact
															,PT.[tran_cash_req]	PT_tran_cash_req
															,PT.[tran_cash_rsp]	PT_tran_cash_rsp
															,PT.[tran_currency_code]	PT_tran_currency_code
															,PT.[tran_tran_fee_req]	PT_tran_tran_fee_req
															,PT.[tran_tran_fee_rsp]	PT_tran_tran_fee_rsp
															,PT.[tran_tran_fee_currency_code]	PT_tran_tran_fee_currency_code
															,PT.[tran_proc_fee_req]	PT_tran_proc_fee_req
															,PT.[tran_proc_fee_rsp]	PT_tran_proc_fee_rsp
															,PT.[tran_proc_fee_currency_code]	PT_tran_proc_fee_currency_code
															,PT.[settle_amount_req]	PT_settle_amount_req
															,PT.[settle_amount_rsp]	PT_settle_amount_rsp
															,PT.[settle_cash_req]	PT_settle_cash_req
															,PT.[settle_cash_rsp]	PT_settle_cash_rsp
															,PT.[settle_tran_fee_req]	PT_settle_tran_fee_req
															,PT.[settle_tran_fee_rsp]	PT_settle_tran_fee_rsp
															,PT.[settle_proc_fee_req]	PT_settle_proc_fee_req
															,PT.[settle_proc_fee_rsp]	PT_settle_proc_fee_rsp
															,PT.[settle_currency_code]	PT_settle_currency_code
															,PT.[pos_entry_mode]	PT_pos_entry_mode
															,PT.[pos_condition_code]	PT_pos_condition_code
															,PT.[additional_rsp_data]	PT_additional_rsp_data
															,PT.[tran_reversed]	PT_tran_reversed
															,PT.[prev_tran_approved]	PT_prev_tran_approved
															,PT.[issuer_network_id]	PT_issuer_network_id
															,PT.[acquirer_network_id]	PT_acquirer_network_id
															,PT.[extended_tran_type]	PT_extended_tran_type
															,PT.[from_account_type_qualifier]	PT_from_account_type_qualifier
															,PT.[to_account_type_qualifier]	PT_to_account_type_qualifier
															,PT.[bank_details]	PT_bank_details
															,PT.[payee]	PT_payee
															,PT.[card_verification_result]	PT_card_verification_result
															,PT.[online_system_id]	PT_online_system_id
															,PT.[participant_id]	PT_participant_id
															,PT.[opp_participant_id]	PT_opp_participant_id
															,PT.[receiving_inst_id_code]	PT_receiving_inst_id_code
															,PT.[routing_type]	PT_routing_type
															,PT.[pt_pos_operating_environment]	PT_pt_pos_operating_environment
															,PT.[pt_pos_card_input_mode]	PT_pt_pos_card_input_mode
															,PT.[pt_pos_cardholder_auth_method]	PT_pt_pos_cardholder_auth_method
															,PT.[pt_pos_pin_capture_ability]	PT_pt_pos_pin_capture_ability
															,PT.[pt_pos_terminal_operator]	PT_pt_pos_terminal_operator
															,PT.[source_node_key]	PT_source_node_key
															,PT.[proc_online_system_id]	PT_proc_online_system_id
															,PTC.[post_tran_cust_id]	PTC_post_tran_cust_id
															,PTC.[source_node_name]	PTC_source_node_name
															,PTC.[draft_capture]	PTC_draft_capture
															,PTC.[pan]	PTC_pan
															,PTC.[card_seq_nr]	PTC_card_seq_nr
															,PTC.[expiry_date]	PTC_expiry_date
															,PTC.[service_restriction_code]	PTC_service_restriction_code
															,PTC.[terminal_id]	PTC_terminal_id
															,PTC.[terminal_owner]	PTC_terminal_owner
															,PTC.[card_acceptor_id_code]	PTC_card_acceptor_id_code
															,PTC.[mapped_card_acceptor_id_code]	PTC_mapped_card_acceptor_id_code
															,PTC.[merchant_type]	PTC_merchant_type
															,PTC.[card_acceptor_name_loc]	PTC_card_acceptor_name_loc
															,PTC.[address_verification_data]	PTC_address_verification_data
															,PTC.[address_verification_result]	PTC_address_verification_result
															,PTC.[check_data]	PTC_check_data
															,PTC.[totals_group]	PTC_totals_group
															,PTC.[card_product]	PTC_card_product
															,PTC.[pos_card_data_input_ability]	PTC_pos_card_data_input_ability
															,PTC.[pos_cardholder_auth_ability]	PTC_pos_cardholder_auth_ability
															,PTC.[pos_card_capture_ability]	PTC_pos_card_capture_ability
															,PTC.[pos_operating_environment]	PTC_pos_operating_environment
															,PTC.[pos_cardholder_present]	PTC_pos_cardholder_present
															,PTC.[pos_card_present]	PTC_pos_card_present
															,PTC.[pos_card_data_input_mode]	PTC_pos_card_data_input_mode
															,PTC.[pos_cardholder_auth_method]	PTC_pos_cardholder_auth_method
															,PTC.[pos_cardholder_auth_entity]	PTC_pos_cardholder_auth_entity
															,PTC.[pos_card_data_output_ability]	PTC_pos_card_data_output_ability
															,PTC.[pos_terminal_output_ability]	PTC_pos_terminal_output_ability
															,PTC.[pos_pin_capture_ability]	PTC_pos_pin_capture_ability
															,PTC.[pos_terminal_operator]	PTC_pos_terminal_operator
															,PTC.[pos_terminal_type]	PTC_pos_terminal_type
															,PTC.[pan_search]	PTC_pan_search
															,PTC.[pan_encrypted]	PTC_pan_encrypted
															,PTC.[pan_reference]	PTC_pan_reference
															
															INTO ##temp_post_tran_data_local
															FROM   (SELECT [post_tran_id]
														,[post_tran_cust_id]	
														,[settle_entity_id]	
														,[batch_nr]
														,[prev_post_tran_id]	
														,[next_post_tran_id]	
														,[sink_node_name]	
														,[tran_postilion_originated]
														,[tran_completed]	
														,[message_type]
														,[tran_type]
														,[tran_nr]
														,[system_trace_audit_nr]
														,[rsp_code_req]
														,[rsp_code_rsp]
														,[abort_rsp_code]	
														,[auth_id_rsp]
														,[auth_type]
														,[auth_reason]
														,[retention_data]	
														,[acquiring_inst_id_code]
														,[message_reason_code]	
														,[sponsor_bank]
														,[retrieval_reference_nr]
														,[datetime_tran_gmt]	
														,[datetime_tran_local]	
														,[datetime_req]
														,[datetime_rsp]
														,[realtime_business_date]
														,[recon_business_date]	
														,[from_account_type]	
														,[to_account_type]	
														,[from_account_id]	
														,[to_account_id]	
														,[tran_amount_req]	
														,[tran_amount_rsp]	
														,[settle_amount_impact]	
														,[tran_cash_req]	
														,[tran_cash_rsp]	
														,[tran_currency_code]	
														,[tran_tran_fee_req]	
														,[tran_tran_fee_rsp]	
														,[tran_tran_fee_currency_code]
														,[tran_proc_fee_req]	
														,[tran_proc_fee_rsp]	
														,[tran_proc_fee_currency_code]
														,[settle_amount_req]	
														,[settle_amount_rsp]	
														,[settle_cash_req]	
														,[settle_cash_rsp]	
														,[settle_tran_fee_req]	
														,[settle_tran_fee_rsp]	
														,[settle_proc_fee_req]	
														,[settle_proc_fee_rsp]	
														,[settle_currency_code]	
														,[pos_entry_mode]	
														,[pos_condition_code]	
														,[additional_rsp_data]	
														,[tran_reversed]	
														,[prev_tran_approved]	
														,[issuer_network_id]	
														,[acquirer_network_id]	
														,[extended_tran_type]	
														,[from_account_type_qualifier]
														,[to_account_type_qualifier]
														,[bank_details]
														,[payee]
														,[card_verification_result]
														,[online_system_id]	
														,[participant_id]	
														,[opp_participant_id]	
														,[receiving_inst_id_code]
														,[routing_type]
														,pt_pos_operating_environment
														,pt_pos_card_input_mode
														,pt_pos_cardholder_auth_method
														,pt_pos_pin_capture_ability
														,pt_pos_terminal_operator
														,source_node_key
														,[proc_online_system_id] FROM   post_tran AS PT1 WITH (NOLOCK, INDEX(ix_post_tran_9))
														   WHERE   recon_business_date = '''+@previous_settlement_date+''' AND  post_tran_id  > '+@start_post_tran_id+'  AND post_tran_id <='+@end_post_tran_id+' 
															AND PT1.post_tran_id NOT IN (
															 SELECT  post_tran_id  FROM tbl_late_reversals ll (NOLOCK) 
																	WHERE ll.recon_business_date >= '''+@previous_settlement_date+'''
																	and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
																				) AND
																				rsp_code_rsp IN (''00'',''11'',''09'')	
														AND LEFT(sink_node_name,2)<> ''SB''
																			 AND  sink_node_name <> ''WUESBPBsnk''
																   AND  CHARINDEX(''TPP'', sink_node_name) < 1  )  PT
																    JOIN  Post_tran_cust AS PTC WITH  (NOLOCK, INDEX(pk_post_tran_cust))
															ON (PT.post_tran_cust_id = PTC.post_tran_cust_id 
															 AND  LEFT( source_node_name,2 ) <> ''SB''
															AND  CHARINDEX(''TPP'',source_node_name )<1
															AND source_node_name <> ''SWTMEGADSsrc'') 
															AND LEFT(card_acceptor_id_code,3) <>''IPG''
														OPTION(RECOMPILE,optimize for unknown)
														');
														
														EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_1] ON [##temp_post_tran_data_local] 
(
	[PT_message_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_10] ON [##temp_post_tran_data_local] 
(
	[PT_settle_amount_impact] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]



CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_11] ON [##temp_post_tran_data_local] 
(
	[PT_message_type] ASC,
	[PT_tran_type] ASC,
	[PTC_source_node_name] ASC,
	[PT_sink_node_name] ASC,
	[PTC_terminal_id] ASC,
	[PTC_totals_group] ASC,
	[PTC_pan] ASC,
	[PT_settle_amount_impact] ASC,
	[PT_acquiring_inst_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]



CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_12] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC
)
INCLUDE ( [PT_post_tran_cust_id],
[PT_tran_nr],
[PT_retention_data]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_13] ON [##temp_post_tran_data_local] 
(
	[PT_post_tran_cust_id] ASC,
	[PT_tran_postilion_originated] ASC,
	[PT_tran_nr] ASC
)
INCLUDE ( [PT_retention_data]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_14] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PTC_totals_group] ASC
)
INCLUDE ( [PT_post_tran_id],
[PT_post_tran_cust_id],
[PT_sink_node_name],
[PT_message_type],
[PT_tran_type],
[PT_tran_nr],
[PT_system_trace_audit_nr],
[PT_acquiring_inst_id_code],
[PT_retrieval_reference_nr],
[PT_settle_amount_impact],
[PT_settle_amount_rsp],
[PT_settle_currency_code],
[PT_tran_reversed],
[PT_extended_tran_type],
[PT_payee],
[PTC_source_node_name],
[PTC_pan],
[PTC_terminal_id],
[PTC_card_acceptor_id_code],
[PTC_merchant_type],
[PTC_card_acceptor_name_loc]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_15] ON [##temp_post_tran_data_local] 
(
	[PT_recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_16] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_message_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PT_settle_amount_impact] ASC
)
INCLUDE ( [PT_sink_node_name],
[PT_system_trace_audit_nr],
[PT_retrieval_reference_nr],
[PT_to_account_id],
[PT_payee],
[PTC_source_node_name],
[PTC_pan],
[PTC_terminal_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_17] ON [##temp_post_tran_data_local] 
(
	[PT_extended_tran_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_18]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_18] ON [##temp_post_tran_data_local] 
(
	[PT_retention_data] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_2]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_2] ON [##temp_post_tran_data_local] 
(
	[PT_tran_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_3]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_3] ON [##temp_post_tran_data_local] 
(
	[PTC_source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_4]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_4] ON [##temp_post_tran_data_local] 
(
	[PT_sink_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_5]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_5] ON [##temp_post_tran_data_local] 
(
	[PTC_terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_6]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_6] ON [##temp_post_tran_data_local] 
(
	[PTC_totals_group] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_7]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_7] ON [##temp_post_tran_data_local] 
(
	[PTC_pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_9]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_9] ON [##temp_post_tran_data_local] 
(
	[PT_acquiring_inst_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_recon]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_recon] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_settle_currency_code] ASC,
	[PT_sink_node_name] ASC,
	[PT_tran_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PTC_source_node_name] ASC,
	[PTC_card_acceptor_id_code] ASC,
	[PTC_totals_group] ASC
)
INCLUDE ( [PT_post_tran_id],
[PT_post_tran_cust_id],
[PT_message_type],
[PT_system_trace_audit_nr],
[PT_acquiring_inst_id_code],
[PT_retrieval_reference_nr],
[PT_settle_amount_impact],
[PT_settle_amount_rsp],
[PT_tran_reversed],
[PT_extended_tran_type],
[PT_payee],
[PTC_pan],
[PTC_terminal_id],
[PTC_terminal_owner],
[PTC_merchant_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_recon_2]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_recon_2] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_settle_currency_code] ASC,
	[PT_sink_node_name] ASC,
	[PT_tran_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PTC_source_node_name] ASC,
	[PTC_card_acceptor_id_code] ASC,
	[PTC_totals_group] ASC
)
INCLUDE ( [PT_post_tran_id],
[PT_post_tran_cust_id],
[PT_message_type],
[PT_system_trace_audit_nr],
[PT_acquiring_inst_id_code],
[PT_retrieval_reference_nr],
[PT_settle_amount_impact],
[PT_settle_amount_rsp],
[PT_tran_reversed],
[PT_extended_tran_type],
[PT_payee],
[PTC_pan],
[PTC_terminal_id],
[PTC_terminal_owner],
[PTC_merchant_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_local_1] ON [##temp_journal_data_local] 
(
	[DebitAccNr_acc_nr] ASC
)
INCLUDE ( [CreditAccNr_acc_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_local_2] ON [##temp_journal_data_local] 
(
	[CreditAccNr_acc_nr] ASC
)
INCLUDE ( [DebitAccNr_acc_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_local_3] ON [##temp_journal_data_local] 
(
	[business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

create index ix_post_tran_id on ##TEMP_journal_DATA_LOCAL(
post_tran_id
)

create index ix_post_tran_cust_id on ##TEMP_journal_DATA_LOCAL(
post_tran_cust_id
)
')


	EXEC('
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @all_fees VARCHAR(255)
SET @all_fees = ''ISSUER_FEE_PAYABLE,ISSUER_FEE_RECEIVABLE,AMOUNT_PAYABLE''

SELECT	     
															bank_code = CASE 
															                      
	WHEN					(dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
							   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
							   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
								and  (DebitAccNr_acc_nr LIKE ''%FEE_PAYABLE'' or CreditAccNr_acc_nr LIKE ''%FEE_PAYABLE'')) THEN ''ISW'' 
	WHEN                      
						   (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
							AND  
						   (DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'')
							 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							 THEN ''UBA''     
								 
	WHEN
					(DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE''
							
							  OR DebitAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'')
						AND (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
									  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''312''  and PT.PT_tran_type = ''50'')
									  
									  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							 THEN ''UBA''                            
							  
	WHEN                      (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							  AND ((PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
							  PT.PT_acquiring_inst_id_code <> ''627787'') 
									OR (PT.PTC_source_node_name = ''SWTFBPsrc'' AND PT.PT_sink_node_name = ''ASPPOSVISsnk'' 
									 AND PT.PTC_totals_group = ''VISAGroup'')
								   )
							  THEN ''UBA''
							  
							  
	WHEN                     (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
							  PT.PT_acquiring_inst_id_code = ''627787'')
							  THEN ''UNK'' 
	WHEN                      
				(PT.PT_sink_node_name = ''SWTWEBUBAsnk'')  
							AND  
				(DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE''
							 OR DebitAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'')
				 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
							 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
							 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							 THEN ''UBA''                             
							  
							  
							  
	  WHEN                     (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							AND  PT.PT_acquiring_inst_id_code <> ''627787'' 
								  AND PT.PT_sink_node_name = ''ASPPOSVISsnk''    
							  THEN ''UBA''     
							  
														
	 WHEN                     (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							AND  PT.PT_acquiring_inst_id_code = ''627787''  
							AND PT.PT_sink_node_name = ''ASPPOSVISsnk''   
							  THEN ''GTB''       
																   
	 WHEN                      
							(PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  
							   AND  
							(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							  THEN ''ABP''   
							 
		WHEN                     
						 (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
						 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
									   
							  THEN ''GTB''                                                                        
							   
	   WHEN                     
							 (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'')  AND
							(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
									  
							  THEN ''EBN''  
							  
	   WHEN                   
							(PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
							(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
									   
							  THEN ''UBA''                                             

WHEN PTT.PT_retention_data   = ''1046'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''UBN''
WHEN PTT.PT_retention_data  IN (''9130'',''8130'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ABS''
WHEN PTT.PT_retention_data  IN (''9044'',''8044'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ABP''
WHEN PTT.PT_retention_data  IN (''9023'',''8023'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''CITI''
WHEN PTT.PT_retention_data  IN (''9050'',''8050'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''EBN''
WHEN PTT.PT_retention_data  IN (''9214'',''8214'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''FCMB''
WHEN PTT.PT_retention_data  IN (''9070'',''8070'',''1100'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''FBP''
WHEN PTT.PT_retention_data  IN (''9011'',''8011'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''FBN''
WHEN PTT.PT_retention_data  IN (''9058'',''8058'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''GTB''
WHEN PTT.PT_retention_data  IN (''9082'',''8082'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''KSB''
WHEN PTT.PT_retention_data  IN (''9076'',''8076'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''SKYE''
WHEN PTT.PT_retention_data  IN (''9084'',''8084'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ENT''
WHEN PTT.PT_retention_data  IN (''9039'',''8039'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''IBTC''
WHEN PTT.PT_retention_data  IN (''9068'',''8068'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''SCB''
WHEN PTT.PT_retention_data  IN (''9232'',''8232'',''1105'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''SBP''
WHEN PTT.PT_retention_data  IN (''9032'',''8032'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''UBN''
WHEN PTT.PT_retention_data  IN (''9033'',''8033'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''UBA''
WHEN PTT.PT_retention_data  IN (''9215'',''8215'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''UBP''
WHEN PTT.PT_retention_data  IN (''9035'',''8035'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''WEMA''
WHEN PTT.PT_retention_data  IN (''9057'',''8057'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ZIB''
WHEN PTT.PT_retention_data  IN (''9301'',''8301'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''JBP''
WHEN PTT.PT_retention_data  IN (''9030'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''HBC''	  
WHEN PTT.PT_retention_data   = ''1411'' and 
		(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''HBC''																						  
WHEN PTT.PT_retention_data   = ''1131'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''WEMA''
WHEN PTT.PT_retention_data  IN (''1061'',''1006'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''GTB''
WHEN PTT.PT_retention_data   = ''1708'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)THEN ''FBN''
WHEN PTT.PT_retention_data  IN (''1027'',''1045'',''1081'',''1015'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''SKYE''
WHEN PTT.PT_retention_data   = ''1037'' and 
		(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''IBTC''
WHEN PTT.PT_retention_data   = ''1034'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''EBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UBA%'' OR CreditAccNr_acc_nr LIKE ''UBA%'') THEN ''UBA''
																	 WHEN (DebitAccNr_acc_nr LIKE ''FBN%'' OR CreditAccNr_acc_nr LIKE ''FBN%'') THEN ''FBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ZIB%'' OR CreditAccNr_acc_nr LIKE ''ZIB%'') THEN ''ZIB'' 
																				 WHEN (DebitAccNr_acc_nr LIKE ''SPR%'' OR CreditAccNr_acc_nr LIKE ''SPR%'') THEN ''ENT''
																				 WHEN (DebitAccNr_acc_nr LIKE ''GTB%'' OR CreditAccNr_acc_nr LIKE ''GTB%'') THEN ''GTB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PRU%'' OR CreditAccNr_acc_nr LIKE ''PRU%'') THEN ''SKYE''
																				 WHEN (DebitAccNr_acc_nr LIKE ''OBI%'' OR CreditAccNr_acc_nr LIKE ''OBI%'') THEN ''EBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''WEM%'' OR CreditAccNr_acc_nr LIKE ''WEM%'') THEN ''WEMA''
																				 WHEN (DebitAccNr_acc_nr LIKE ''AFR%'' OR CreditAccNr_acc_nr LIKE ''AFR%'') THEN ''MSB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''IBTC%'' OR CreditAccNr_acc_nr LIKE ''IBTC%'') THEN ''IBTC''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PLAT%'' OR CreditAccNr_acc_nr LIKE ''PLAT%'') THEN ''KSB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UBP%'' OR CreditAccNr_acc_nr LIKE ''UBP%'') THEN ''UBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''DBL%'' OR CreditAccNr_acc_nr LIKE ''DBL%'') THEN ''DBL''
																				 WHEN (DebitAccNr_acc_nr LIKE ''FCMB%'' OR CreditAccNr_acc_nr LIKE ''FCMB%'') THEN ''FCMB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''IBP%'' OR CreditAccNr_acc_nr LIKE ''IBP%'') THEN ''ABP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UBN%'' OR CreditAccNr_acc_nr LIKE ''UBN%'') THEN ''UBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ETB%'' OR CreditAccNr_acc_nr LIKE ''ETB%'') THEN ''ETB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''FBP%'' OR CreditAccNr_acc_nr LIKE ''FBP%'') THEN ''FBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''SBP%'' OR CreditAccNr_acc_nr LIKE ''SBP%'') THEN ''SBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ABP%'' OR CreditAccNr_acc_nr LIKE ''ABP%'') THEN ''ABP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''EBN%'' OR CreditAccNr_acc_nr LIKE ''EBN%'') THEN ''EBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CITI%'' OR CreditAccNr_acc_nr LIKE ''CITI%'') THEN ''CITI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''FIN%'' OR CreditAccNr_acc_nr LIKE ''FIN%'') THEN ''FCMB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ASO%'' OR CreditAccNr_acc_nr LIKE ''ASO%'') THEN ''ASO''
																				 WHEN (DebitAccNr_acc_nr LIKE ''OLI%'' OR CreditAccNr_acc_nr LIKE ''OLI%'') THEN ''OLI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''HSL%'' OR CreditAccNr_acc_nr LIKE ''HSL%'') THEN ''HSL''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ABS%'' OR CreditAccNr_acc_nr LIKE ''ABS%'') THEN ''ABS''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PAY%'' OR CreditAccNr_acc_nr LIKE ''PAY%'') THEN ''PAY''
																				 WHEN (DebitAccNr_acc_nr LIKE ''SAT%'' OR CreditAccNr_acc_nr LIKE ''SAT%'') THEN ''SAT''
																				 WHEN (DebitAccNr_acc_nr LIKE ''3LCM%'' OR CreditAccNr_acc_nr LIKE ''3LCM%'') THEN ''3LCM''
																				 WHEN (DebitAccNr_acc_nr LIKE ''SCB%'' OR CreditAccNr_acc_nr LIKE ''SCB%'') THEN ''SCB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''JBP%'' OR CreditAccNr_acc_nr LIKE ''JBP%'') THEN ''JBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''RSL%'' OR CreditAccNr_acc_nr LIKE ''RSL%'') THEN ''RSL''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PSH%'' OR CreditAccNr_acc_nr LIKE ''PSH%'') THEN ''PSH''
																				 WHEN (DebitAccNr_acc_nr LIKE ''INF%'' OR CreditAccNr_acc_nr LIKE ''INF%'') THEN ''INF''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UML%'' OR CreditAccNr_acc_nr LIKE ''UML%'') THEN ''UML''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ACCI%'' OR CreditAccNr_acc_nr LIKE ''ACCI%'') THEN ''ACCI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''EKON%'' OR CreditAccNr_acc_nr LIKE ''EKON%'') THEN ''EKON''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ATMC%'' OR CreditAccNr_acc_nr LIKE ''ATMC%'') THEN ''ATMC''
																				 WHEN (DebitAccNr_acc_nr LIKE ''HBC%'' OR CreditAccNr_acc_nr LIKE ''HBC%'') THEN ''HBC''
																	 WHEN (DebitAccNr_acc_nr LIKE ''UNI%'' OR CreditAccNr_acc_nr LIKE ''UNI%'') THEN ''UNI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UNC%'' OR CreditAccNr_acc_nr LIKE ''UNC%'') THEN ''UNC''
																				 WHEN (DebitAccNr_acc_nr LIKE ''NCS%'' OR CreditAccNr_acc_nr LIKE ''NCS%'') THEN ''NCS'' 
																	 WHEN (DebitAccNr_acc_nr LIKE ''HAG%'' OR CreditAccNr_acc_nr LIKE ''HAG%'') THEN ''HAG''
																	 WHEN (DebitAccNr_acc_nr LIKE ''EXP%'' OR CreditAccNr_acc_nr LIKE ''EXP%'') THEN ''DBL''
																	 WHEN (DebitAccNr_acc_nr LIKE ''FGMB%'' OR CreditAccNr_acc_nr LIKE ''FGMB%'') THEN ''FGMB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CEL%'' OR CreditAccNr_acc_nr LIKE ''CEL%'') THEN ''CEL''
																	 WHEN (DebitAccNr_acc_nr LIKE ''RDY%'' OR CreditAccNr_acc_nr LIKE ''RDY%'') THEN ''RDY''
																	 WHEN (DebitAccNr_acc_nr LIKE ''AMJ%'' OR CreditAccNr_acc_nr LIKE ''AMJ%'') THEN ''AMJU''
																	 WHEN (DebitAccNr_acc_nr LIKE ''CAP%'' OR CreditAccNr_acc_nr LIKE ''CAP%'') THEN ''O3CAP''
																	 WHEN (DebitAccNr_acc_nr LIKE ''VER%'' OR CreditAccNr_acc_nr LIKE ''VER%'') THEN ''VER_GLOBAL''
																	 WHEN (DebitAccNr_acc_nr LIKE ''SMF%'' OR CreditAccNr_acc_nr LIKE ''SMF%'') THEN ''SMFB''
																	 WHEN (DebitAccNr_acc_nr LIKE ''SLT%'' OR CreditAccNr_acc_nr LIKE ''SLT%'') THEN ''SLTD''
																	 WHEN (DebitAccNr_acc_nr LIKE ''JES%'' OR CreditAccNr_acc_nr LIKE ''JES%'') THEN ''JES''
																				 WHEN (DebitAccNr_acc_nr LIKE ''MOU%'' OR CreditAccNr_acc_nr LIKE ''MOU%'') THEN ''MOUA''
																				 WHEN (DebitAccNr_acc_nr LIKE ''MUT%'' OR CreditAccNr_acc_nr LIKE ''MUT%'') THEN ''MUT''
																				 WHEN (DebitAccNr_acc_nr LIKE ''LAV%'' OR CreditAccNr_acc_nr LIKE ''LAV%'') THEN ''LAV''
																				 WHEN (DebitAccNr_acc_nr LIKE ''JUB%'' OR CreditAccNr_acc_nr LIKE ''JUB%'') THEN ''JUB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''WET%'' OR CreditAccNr_acc_nr LIKE ''WET%'') THEN ''WET''
																				 WHEN (DebitAccNr_acc_nr LIKE ''AGH%'' OR CreditAccNr_acc_nr LIKE ''AGH%'') THEN ''AGH''
																				 WHEN (DebitAccNr_acc_nr LIKE ''TRU%'' OR CreditAccNr_acc_nr LIKE ''TRU%'') THEN ''TRU''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CON%'' OR CreditAccNr_acc_nr LIKE ''CON%'') THEN ''CON''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CRU%'' OR CreditAccNr_acc_nr LIKE ''CRU%'') THEN ''CRU''
																				WHEN (DebitAccNr_acc_nr LIKE ''NPR%'' OR CreditAccNr_acc_nr LIKE ''NPR%'') THEN ''NPR''
																				WHEN (DebitAccNr_acc_nr LIKE ''OMO%'' OR CreditAccNr_acc_nr LIKE ''OMO%'') THEN ''OMO''
																				WHEN (DebitAccNr_acc_nr LIKE ''SUN%'' OR CreditAccNr_acc_nr LIKE ''SUN%'') THEN ''SUN''
																				WHEN (DebitAccNr_acc_nr LIKE ''NGB%'' OR CreditAccNr_acc_nr LIKE ''NGB%'') THEN ''NGB''
																				WHEN (DebitAccNr_acc_nr LIKE ''OSC%'' OR CreditAccNr_acc_nr LIKE ''OSC%'') THEN ''OSC''
																				WHEN (DebitAccNr_acc_nr LIKE ''OSP%'' OR CreditAccNr_acc_nr LIKE ''OSP%'') THEN ''OSP''
																				WHEN (DebitAccNr_acc_nr LIKE ''IFIS%'' OR CreditAccNr_acc_nr LIKE ''IFIS%'') THEN ''IFIS''
																				WHEN (DebitAccNr_acc_nr LIKE ''NPM%'' OR CreditAccNr_acc_nr LIKE ''NPM%'') THEN ''NPM''
																				WHEN (DebitAccNr_acc_nr LIKE ''POL%'' OR CreditAccNr_acc_nr LIKE ''POL%'') THEN ''POL''
																				WHEN (DebitAccNr_acc_nr LIKE ''ALV%'' OR CreditAccNr_acc_nr LIKE ''ALV%'') THEN ''ALV''
																				WHEN (DebitAccNr_acc_nr LIKE ''MAY%'' OR CreditAccNr_acc_nr LIKE ''MAY%'') THEN ''MAY''
																				WHEN (DebitAccNr_acc_nr LIKE ''PRO%'' OR CreditAccNr_acc_nr LIKE ''PRO%'') THEN ''PRO''
																				WHEN (DebitAccNr_acc_nr LIKE ''UNIL%'' OR CreditAccNr_acc_nr LIKE ''UNIL%'') THEN ''UNIL''
																				WHEN (DebitAccNr_acc_nr LIKE ''PAR%'' OR CreditAccNr_acc_nr LIKE ''PAR%'') THEN ''PAR''
																				WHEN (DebitAccNr_acc_nr LIKE ''FOR%'' OR CreditAccNr_acc_nr LIKE ''FOR%'') THEN ''FOR''
																					WHEN (DebitAccNr_acc_nr LIKE ''MON%'' OR CreditAccNr_acc_nr LIKE ''MON%'') THEN ''MON''
																					WHEN (DebitAccNr_acc_nr LIKE ''NDI%'' OR CreditAccNr_acc_nr LIKE ''NDI%'') THEN ''NDI''					
																				 WHEN (DebitAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'' OR CreditAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'') THEN ''SCB''
																	 WHEN ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) THEN ''ISW''
																	
																	 ELSE ''UNK''	
																
														END,
															trxn_category=CASE WHEN (PT.PT_tran_type =''01'')  
																					AND dbo.fn_rpt_CardGroup(PT.PTC_PAN) in (''1'',''4'')
																				   AND PT.PTC_source_node_name = ''SWTMEGAsrc''
																				   THEN ''ATM WITHDRAWAL (VERVE INTERNATIONAL)''
														                           
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''50''  then ''MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)''
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''00'' and PT.PTC_source_node_name = ''VTUsrc''  then ''MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)''
														                
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''00'' and PT.PTC_source_node_name <> ''VTUsrc''  and PT.PT_sink_node_name <> ''VTUsnk''
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in (''2'',''5'',''6'')
																				   then ''MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)''
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''00'' and PT.PTC_source_node_name <> ''VTUsrc''  and PT.PT_sink_node_name <> ''VTUsnk''
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in (''3'')
																				   then ''MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)''
																					WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
																				   and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
																				   THEN ''ATM WITHDRAWAL (Cardless:Paycode Verve Token)''
														                           
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
																				   and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
																				   THEN ''ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)''
														                           
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
																				   and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 3 
																				   THEN ''ATM WITHDRAWAL (Cardless:Non-Card Generated)''
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr  LIKE ''%ATM%ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%'')
																				   AND PT.PTC_source_node_name <> ''SWTMEGAsrc''
																				   AND PT.PTC_source_node_name <> ''ASPSPNOUsrc''                           
																				   THEN ''ATM WITHDRAWAL (MASTERCARD ISO)''
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PTC_source_node_name <> ''SWTMEGAsrc''
																				   AND PT.PTC_source_node_name <> ''ASPSPNOUsrc''
																				   THEN ''ATM WITHDRAWAL (REGULAR)''
														                           
														                                                                           
														                           
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr LIKE ''%V%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%V%BILLING%'')
																				   AND PT.PTC_source_node_name <> ''SWTMEGAsrc''
																				   THEN ''ATM WITHDRAWAL (VERVE BILLING)''
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PTC_source_node_name = ''ASPSPNOUsrc''
																				   THEN ''ATM WITHDRAWAL (SMARTPOINT)''
														 
																				   WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' and 
																				   (DebitAccNr_acc_nr like ''%BILLPAYMENT MCARD%'' or CreditAccNr_acc_nr like ''%BILLPAYMENT MCARD%'') ) then ''BILLPAYMENT MASTERCARD BILLING''
																				   WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' 
																				   and (DebitAccNr_acc_nr like ''%SVA_FEE_RECEIVABLE'' or CreditAccNr_acc_nr like ''%SVA_FEE_RECEIVABLE'') ) 
																				   AND dbo.fn_rpt_isBillpayment_IFIS(PT.PTC_terminal_id) = 1  then ''BILLPAYMENT IFIS REMITTANCE''
														                          
																				   WHEN ( dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'')  then ''BILLPAYMENT''
																	   
																	
																				   WHEN (PT.PT_tran_type =''40''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' 
																				   or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''4'')) THEN ''CARD HOLDER ACCOUNT TRANSFER''
																				   WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   AND SUBSTRING(PT.PTC_terminal_id,1,1)IN (''2'',''5'',''6'')AND PT.PT_sink_node_name = ''ESBCSOUTsnk'' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
																				   THEN ''POS PURCHASE (Cardless:Paycode Verve Token)''
														                           
																				   WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   AND SUBSTRING(PT.PTC_terminal_id,1,1)IN (''2'',''5'',''6'')AND PT.PT_sink_node_name = ''ESBCSOUTsnk'' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
																				   THEN ''POS PURCHASE (Cardless:Paycode Non-Verve Token)''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''1''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					  or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(GENERAL MERCHANT)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''2''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(CHURCHES, FASTFOODS & NGOS)''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''3''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(CONCESSION)PURCHASE''
																				   WHEN ( dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''4''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(TRAVEL AGENCIES)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''5''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(HOTELS)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''6''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(WHOLESALE)PURCHASE''
														                    
																					WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''14''
																					and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''7''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(FUEL STATION)PURCHASE''
														 
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''8''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(EASYFUEL)PURCHASE''
														                           
																				   WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(TRAVEL AGENCIES-VISA)PURCHASE''
														                     
																				   WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(WHOLESALE CLUBS-VISA)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''3''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(GENERAL MERCHANT-VISA)PURCHASE''
														                         
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					  or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(VAS CLOSED SCHEME)PURCHASE''+''_''+PT.PTC_merchant_type
														                              
																					WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1 OR PT.PT_tran_type = ''50'')
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					  or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(VAS CLOSED SCHEME)PURCHASE''+''_''+PT.PTC_merchant_type
														                              
														                              
																					  WHEN (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name IN (''SWTWEBEBNsnk'',''SWTWEBUBAsnk'',''SWTWEBGTBsnk'',''SWTWEBABPsnk''))
																					  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																					  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																					  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
																					  THEN ''WEB(GENERIC)PURCHASE''
														                              
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''9''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) 
																				   THEN ''WEB(GENERIC)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''10''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N200)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''11''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N300)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''12''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N150)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''13''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1.5% CAPPED AT N300)PURCHASE''
														                       
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''15''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB COLLEGES ( 1.5% capped specially at 250)''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''16''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (PROFESSIONAL SERVICES)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''17''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (SECURITY BROKERS/DEALERS)PURCHASE''
														 
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''18''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (COMMUNICATION)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''19''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N400)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''20''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N250)PURCHASE''
														                  
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''21''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N265)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''22''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N550)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''23''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''Verify card – Ecash load''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''24''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''25''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''26''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Payment_Gateway_0.9%)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''27''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Payment_Gateway_1.25%)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''28''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Add_Card)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''30''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(0.75% CAPPED AT 1,000 CATEGORY)PURCHASE''
														                            
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''31''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1% CAPPED AT N50 CATEGORY)PURCHASE''                     
														                                                      
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')THEN ''POS(GENERAL MERCHANT)PURCHASE'' 
																					 WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')THEN ''POS PURCHASE WITH CASHBACK''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''POS CASHWITHDRAWAL''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''14'')
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (PT.PT_tran_type = ''50'' and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
														                           
																				   WHEN (PT.PT_tran_type = ''50'' and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''Fees collected for all PTSPs''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''14'')
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1)= ''3'' THEN ''WEB(GENERIC)PURCHASE''
																				  
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''313'' 
																						 and (DebitAccNr_acc_nr LIKE ''%fee%'' OR CreditAccNr_acc_nr LIKE ''%fee%'')
																						 AND PT.PT_tran_type in (''50'') or(dbo.fn_rpt_autopay_intra_sett (PT.PTC_source_node_name,PT.PT_tran_type,PT.PT_payee) = 1))
																						 and not (DebitAccNr_acc_nr like ''%PREPAIDLOAD%'' or CreditAccNr_acc_nr like ''%PREPAIDLOAD%'') THEN ''AUTOPAY TRANSFER FEES''
														                          
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''313'' 
																						 and (DebitAccNr_acc_nr NOT LIKE ''%fee%'' OR CreditAccNr_acc_nr NOT LIKE ''%fee%'')
																						 and PT.PT_tran_type in (''50'')
																						 and not (DebitAccNr_acc_nr like ''%PREPAIDLOAD%'' or CreditAccNr_acc_nr like ''%PREPAIDLOAD%'')) THEN ''AUTOPAY TRANSFERS''
														                                 
																				  WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																				   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'' and PT.PT_extended_tran_type = ''6011'') THEN ''ATM CARDLESS-TRANSFERS''     
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'') THEN ''ATM TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''2'' and PT.PT_tran_type = ''50'') THEN ''POS TRANSFERS''
														                           
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''4'' and PT.PT_tran_type = ''50'') THEN ''MOBILE TRANSFERS''
																				  WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''35'' and PT.PT_tran_type = ''50'') then ''REMITA TRANSFERS''
														       
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''31'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''32'' and PT.PT_tran_type = ''50'') then ''RELATIONAL TRANSFERS''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''33'' and PT.PT_tran_type = ''50'') then ''SEAMFIX TRANSFERS''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''34'' and PT.PT_tran_type = ''50'') then ''VERVE INTL TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''36'' and PT.PT_tran_type = ''50'') then ''PREPAID CARD UNLOAD''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''37'' and PT.PT_tran_type = ''50'' ) then ''QUICKTELLER TRANSFERS(BANK BRANCH)''
														 
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''38'' and PT.PT_tran_type = ''50'') then ''QUICKTELLER TRANSFERS(SVA)''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''39'' and PT.PT_tran_type = ''50'') then ''SOFTPAY TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''310'' and PT.PT_tran_type = ''50'') then ''OANDO S&T TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''311'' and PT.PT_tran_type = ''50'') then ''UPPERLINK TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''312''  and PT.PT_tran_type = ''50'') then ''QUICKTELLER WEB TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''314''  and PT.PT_tran_type = ''50'') then ''QUICKTELLER MOBILE TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''315'' and PT.PT_tran_type = ''50'') then ''WESTERN UNION MONEY TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''316'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS(NON GENERIC PLATFORM)''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''317'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS(ACCESSBANK PORTAL)''
														                                  
																				   WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
																						 AND (DebitAccNr_acc_nr NOT LIKE ''%AMOUNT%RECEIVABLE'' AND CreditAccNr_acc_nr NOT LIKE ''%AMOUNT%RECEIVABLE'') then ''PREPAID MERCHANDISE''
														                           
																				   WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
																						 AND (DebitAccNr_acc_nr  LIKE ''%AMOUNT%RECEIVABLE'' or CreditAccNr_acc_nr  LIKE ''%AMOUNT%RECEIVABLE'') then ''PREPAID MERCHANDISE DUE ISW''--the unk% is excempted from the bank''s net
														                           
														                                                      
																				  WHEN (dbo.fn_rpt_isCardload (PT.PTC_source_node_name ,PT.PTC_pan, PT.PT_tran_type)= ''1'') then ''PREPAID CARDLOAD''
																				  when PT.PT_tran_type = ''21'' then ''DEPOSIT''
																				  ELSE ''UNK''		
														END,
														  Debit_account_type=CASE 
														                    
																			  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
														                      
																			  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                          
																			   WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''
														                          
																			 WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk''  AND
																			 (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																				THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			   PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                        
																				THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                          
																			   WHEN 
																			   PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																				  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''    
														                        
																			WHEN                      
																			(dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
																				AND  
																			(DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
																				 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
																				 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''     
														                        
																			  WHEN 
																			 PT.PT_sink_node_name = ''SWTWEBUBAsnk''  AND
																			(DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'')
																			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																			 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																			 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
																			 THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
																			WHEN 
																			 PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
																			 (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
																			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																			 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																			 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
																			 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''    
														                           
														                          
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			 (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''     
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''   
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''   
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''  
														                      
														                       
														                      
																			  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Debit_Nr)''
																			  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%RECHARGE%FEE%PAYABLE'') THEN ''RECHARGE FEE PAYABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%CO%ACQUIRER%FEE%RECEIVABLE'') THEN ''CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)''   
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%CARDHOLDER%ISSUER%FEE%RECEIVABLE%'') THEN ''CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%SCH%ISSUER%FEE%RECEIVABLE'') THEN ''SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%PAYIN_INSTITUTION_FEE_RECEIVABLE'') THEN ''PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%PAYABLE'') THEN ''ISW FEE PAYABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_CARD_SCHEME%'') THEN ''ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ACQ_%'') THEN ''ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ISS_%'') THEN ''ISW ISSUER FEE RECEIVABLE (Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''1'')
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'')THEN ''ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''2'')
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''3'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''4'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)''
														                           
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''5'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW 3LCM FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''6'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''7'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''8'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)''
														               
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''10'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''9''
																				  AND NOT ((DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')OR (DebitAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN ''ISW FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'')THEN ''FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ATMC%FEE%PAYABLE'') THEN ''ATMC FEE PAYABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ATMC%FEE%RECEIVABLE'') THEN ''ATMC FEE RECEIVABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%EASYFUEL_ACCOUNT'') THEN ''EASYFUEL ACCOUNT(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%YPM%FEE%RECEIVABLE'') THEN ''YPM FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%FLEETTECH%FEE%RECEIVABLE'') THEN ''FLEETTECH FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%LYSA%FEE%RECEIVABLE'') THEN ''LYSA FEE RECEIVABLE(Debit_Nr)''
														                         
																				  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_FEE_RECEIVABLE'') THEN ''SVA FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%UDIRECT_FEE_RECEIVABLE'') THEN ''UDIRECT FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Debit_Nr)''
														                            
																				  WHEN (DebitAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Debit_Nr)''  
																	  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_PAYABLE'') THEN ''SVA SPONSOR FEE PAYABLE(Debit_Nr)''
																	  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_RECEIVABLE'') THEN ''SVA SPONSOR FEE RECEIVABLE(Debit_Nr)''                      
																				  ELSE ''UNK''			
														END,
														  Credit_account_type=CASE  
														  
																			  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																			  PT.PT_acquiring_inst_id_code <> ''627787'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				   PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''
														                           
																			 WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk''  AND
																			 (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
														                      
																			  WHEN                      
																		   (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
																				AND  
																			(CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
																				 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
																				 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
														                      
																			  WHEN 
																			  PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'')
																			  and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																			 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																			 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
																			THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														        
														 
																		WHEN 
																		   PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
																		  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
 																		   and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																		   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																		   AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
																		   THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			 WHEN 
																			 (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  AND
																			 (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																				  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                          
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																				WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''    
														                      
																			  WHEN 
																			 (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'')  AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'')  AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
														                                               
																				  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Credit_Nr)''
																			  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%RECHARGE%FEE%PAYABLE'') THEN ''RECHARGE FEE PAYABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%CO%ACQUIRER%FEE%RECEIVABLE'') THEN ''CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)''   
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%PAYABLE'') THEN ''ISW FEE PAYABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%CARDHOLDER%ISSUER%FEE%RECEIVABLE%'') THEN ''CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%SCH%ISSUER%FEE%RECEIVABLE'') THEN ''SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%PAYIN_INSTITUTION_FEE_RECEIVABLE'') THEN ''PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_CARD_SCHEME%'') THEN ''ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ACQ_%'') THEN ''ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ISS_%'') THEN ''ISW ISSUER FEE RECEIVABLE (Credit_Nr)''
																				   WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''1'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''2'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''3'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''4'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)''
														                           
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''5'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW 3LCM FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''6'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''7'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''8'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''10'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''9''
																				  AND NOT ((CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN ''ISW FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'')THEN ''FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ATMC%FEE%PAYABLE'') THEN ''ATMC FEE PAYABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ATMC%FEE%RECEIVABLE'') THEN ''ATMC FEE RECEIVABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%EASYFUEL_ACCOUNT'') THEN ''EASYFUEL ACCOUNT(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%YPM%FEE%RECEIVABLE'') THEN ''YPM FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%FLEETTECH%FEE%RECEIVABLE'') THEN ''FLEETTECH FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%LYSA%FEE%RECEIVABLE'') THEN ''LYSA FEE RECEIVABLE(Credit_Nr)''
														                         
																				  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_FEE_RECEIVABLE'') THEN ''SVA FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%UDIRECT_FEE_RECEIVABLE'') THEN ''UDIRECT FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Credit_Nr)''
														                          
																				  WHEN (CreditAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Credit_Nr)'' 
																	  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_RECEIVABLE'') THEN ''SVA SPONSOR FEE RECEIVABLE(Credit_Nr)''
																	  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_PAYABLE'') THEN ''SVA SPONSOR FEE PAYABLE(Credit_Nr)''
																				  ELSE ''UNK''			
														END,
															   trxn_amount=ISNULL(J.amount,0),
															trxn_fee=ISNULL(J.fee,0),
															trxn_date=J.business_date,
																currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' and 
																				   (DebitAccNr_acc_nr like ''%BILLPAYMENT MCARD%'' or CreditAccNr_acc_nr like ''%BILLPAYMENT MCARD%'') ) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTUBAsnk''))) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM%ISO%ACQUIRER%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%ACQUIRER%'') ) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM_FEE_ACQ_ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM_FEE_ACQ_ISO%'') ) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM%ISO%ISSUER%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%ISSUER%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTPLATsnk''))) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM_FEE_ISS_ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM_FEE_ISS_ISO%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTPLATsnk''))) THEN ''840''
																				ELSE PT.PT_settle_currency_code END,
																late_reversal = CASE
														        
																				WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
																					   and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																					   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																					   and PT.PTC_merchant_type in (''5371'',''2501'',''2504'',''2505'',''2506'',''2507'',''2508'',''2509'',''2510'',''2511'') THEN 0
														                               
																				WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
																					   and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																					   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') THEN 1
																				ELSE 0
																					END,
																card_type =  dbo.fn_rpt_CardGroup(PT.PTC_pan),
																terminal_type = dbo.fn_rpt_terminal_type(PT.PTC_terminal_id),    
																source_node_name =   PT.PTC_source_node_name,
																Unique_key = PT.PT_retrieval_reference_nr+''_''+PT.PT_system_trace_audit_nr+''_''+PT.PTC_terminal_id+''_''+ cast((CONVERT(NUMERIC (15,2),isnull(PT.PT_settle_amount_impact,0))) as VARCHAR(20))+''_''+PT.PT_message_type,
																Acquirer = (case when (not ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) )) then ''''
																			  when ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) AND (pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5)) then acc.bank_code 
																			  else PT.PT_acquiring_inst_id_code END),
																Issuer = (case when (not ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) )) then ''''
																			  when ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) and (substring(PT.PTC_totals_group,1,3) = acc.bank_code1) then acc.bank_code
																			  else substring(PT.PTC_totals_group,1,3) END),
															   Volume = (case when PT.PT_message_type in (''0200'',''0220'') then 1
																			   else 0 end),  
																   Value_RequestedAmount = PT.PT_settle_amount_req,
																   Value_SettleAmount = PT.PT_settle_amount_impact,pt.pt_post_tran_id as ptid ,pt.pt_post_tran_cust_id as ptcid                  
															 ,       index_no = IDENTITY(INT,1,1)
															INTO  ##settle_tran_details 
														 
														 FROM 
														 (select  [adj_id]
															  ,[entry_id]
															  ,[config_set_id]
															  ,[session_id]
															  ,[post_tran_id]
															  ,[post_tran_cust_id]
															  ,[sdi_tran_id]
															  ,[acc_post_id]
															  ,[nt_fee_acc_post_id]
															  ,[coa_id]
															  ,[coa_se_id]
															  ,[se_id]
															  ,[amount]
															  ,[amount_id]
															  ,[amount_value_id]
															  ,[fee]
															  ,[fee_id]
															  ,[fee_value_id]
															  ,[nt_fee]
															  ,[nt_fee_id]
															  ,[nt_fee_value_id]
															  ,[debit_acc_nr_id]
															  ,[debit_acc_id]
															  ,[debit_cardholder_acc_id]
															  ,[debit_cardholder_acc_type]
															  ,[credit_acc_nr_id]
															  ,[credit_acc_id]
															  ,[credit_cardholder_acc_id]
															  ,[credit_cardholder_acc_type]
															  ,[business_date]
															  ,[granularity_element]
															  ,[tag]
															  ,[spay_session_id]
															  ,[spst_session_id]
															  ,[DebitAccNr_config_set_id]
															  ,[DebitAccNr_acc_nr_id]
															  ,[DebitAccNr_se_id]
															  ,[DebitAccNr_acc_id]
															  ,[DebitAccNr_acc_nr]
															  ,[DebitAccNr_aggregation_id]
															  ,[DebitAccNr_state]
															  ,[DebitAccNr_config_state]
															  ,[CreditAccNr_config_set_id]
															  ,[CreditAccNr_acc_nr_id]
															  ,[CreditAccNr_se_id]
															  ,[CreditAccNr_acc_id]
															  ,[CreditAccNr_acc_nr]
															  ,[CreditAccNr_aggregation_id]
															  ,[CreditAccNr_state]
															  ,[CreditAccNr_config_state]
															  ,[Amount_config_set_id]
															  ,[Amount_amount_id]
															  ,[Amount_se_id]
															  ,[Amount_name]
															  ,[Amount_description]
															  ,[Amount_config_state]
															  ,[Fee_config_set_id]
															  ,[Fee_fee_id]
															  ,[Fee_se_id]
															  ,[Fee_name]
															  ,[Fee_description]
															  ,[Fee_type]
															  ,[Fee_amount_id]
															  ,[Fee_config_state]
															  ,[coa_config_set_id]
															  ,[coa_coa_id]
															  ,[coa_name]
															  ,[coa_description]
															  ,[coa_type]
															  ,[coa_config_state] from  ##temp_journal_data_local (NOLOCK)   )J
																			 JOIN 
												 (SELECT * FROM ##temp_post_tran_data_local (NOLOCK) WHERE PT_tran_postilion_originated =0)   PT 
													ON (J.post_tran_id = PT.PT_post_tran_id   and substring(pt.ptc_terminal_id,1,1)!=''G'')
												
																 
																		 	and 
																			
															(
																  (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in (''0200'',''0220''))
															   or ((PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = ''0420'' 
															   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,  PT.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,PT.PTC_totals_group ,PT.ptc_pan) <> 1
																and PT.PT_tran_reversed <> 2)
															   or (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = ''0420'' 
															   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type, pt.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,pt.PTC_totals_group ,pt.PTC_pan) = 1 ))
															   or (PT.PT_settle_amount_rsp<> 0 and PT.PT_message_type   in (''0200'',''0220'') and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1) IN (''0'',''1'') ))
															   or (PT.PT_message_type = ''0420'' and PT.PT_tran_reversed <> 2 and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1)IN ( ''0'',''1'' ))))
														     
															  AND not (pt.PTC_merchant_type in (''4004'',''4722'') and PT.PT_tran_type = ''00'' and pt.PTC_source_node_name not in (''VTUsrc'',''CCLOADsrc'') and  abs(PT.PT_settle_amount_impact/100)< 200
															   and not (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%''))
															  AND pt.PTC_totals_group <>''CUPGroup''
															  and NOT (PT.PTC_totals_group in (''VISAGroup'') and PT.PT_acquiring_inst_id_code = ''627787'')
															  and NOT (PT.PTC_totals_group in (''VISAGroup'') and PT.PT_sink_node_name not in (''ASPPOSVINsnk'')
																		and not (pt.ptc_source_node_name in (''SWTFBPsrc'',''SWTUBAsrc'',''SWTZIBsrc'',''SWTPLATsrc'') and PT.PT_sink_node_name = ''ASPPOSVISsnk'') 
																	   )
															 and not (PT.ptc_source_node_name  = ''MEGATPPsrc'' and PT.PT_tran_type = ''00'' ) 														 
															  JOIN 
								  (SELECT  PT_post_tran_id,PT_post_tran_cust_id,ptc_terminal_id,PT_tran_nr, PT_retention_data FROM ##temp_post_tran_data_local (NOLOCK) WHERE PT_tran_postilion_originated =1)PTT 
																ON
																(PT.PT_post_tran_cust_id = PTT.PT_post_tran_cust_id and substring(ptT.ptc_terminal_id,1,1)!=''G'' and PT.PT_tran_nr = PTT.PT_tran_nr)  
														   LEFT OUTER JOIN aid_cbn_code acc ON
														  pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5)
														    OPTION (optimize for unknown,maxdop 8)
														 ')

															EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED IF (OBJECT_ID(''tempdb.dbo.#temp_table'') is not null )begin
														  DROP TABLE #temp_table
														end
														create table #temp_table
														(unique_key VARCHAR(200))
														create nonclustered index ix_temp_table ON #temp_table(
														unique_key
														)
														insert into #temp_table 
														select unique_key from ##settle_tran_details (NOLOCK) where source_node_name in (''SWTASPPOSsrc'',''SWTASGTVLsrc'')
														OPTION(RECOMPILE,optimize for unknown)

														DELETE FROM  ##settle_tran_details WHERE index_no IN (SELECT index_no FROM ##settle_tran_details (NOLOCK) where source_node_name 
														 IN (''SWTNCS2src'',''SWTSHOPRTsrc'',''SWTNCSKIMsrc'',''SWTNCSKI2src'',''SWTFBPsrc'',''SWTUBAsrc'',''SWTZIBsrc'',''SWTPLATsrc'') and unique_key IN (SELECT unique_key FROM #temp_table))

					');
					ExeC('set transaction isolation level read uncommitted 	CREATE INDEX ix_settle_tran_details  ON  ##settle_tran_details (
									PTID 
							)
							IF (OBJECT_ID(''tempdb.dbo.##final_results_tables'') IS NOT NULL) BEGIN
					DROP TABLE ##final_results_tables
					END
create index ix_post_tran_id on ##temp_post_tran_data_local(
PT_post_tran_id
)
SELECT  report_results.bank_code,
			 report_results.trxn_category,
			 report_results.Debit_account_type,
			 report_results.Credit_account_type,
			 report_results.trxn_amount,
			 report_results.trxn_fee,
			 report_results.trxn_date,
			 report_results.currency,
			 report_results.late_reversal,
			 report_results.card_type,
			 terminal_type,
			 report_results.source_node_name,
			 report_results.Unique_key,
			 report_results.Acquirer,
			 report_results.Issuer,
			 report_results.Volume,
			 report_results.Value_RequestedAmount,
			 report_results.Value_SettleAmount,
			 report_results.ptid,
			 report_results.ptcid,
			 report_results.index_no
			 ,(SELECT  TOP  1   pt.[PT_post_tran_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID ) 		post_tran_id_1
			 ,(SELECT  TOP  1   pt.[PT_post_tran_cust_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )  		post_tran_cust_id_1
			 ,(SELECT  TOP  1   [PT_settle_entity_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_entity_id
			 ,(SELECT  TOP  1   [PT_batch_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_batch_nrS
			 ,(SELECT  TOP  1   [PT_prev_post_tran_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_prev_post_tran_id
			 ,(SELECT  TOP  1   [PT_next_post_tran_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_next_post_tran_id
			 ,(SELECT  TOP  1   [PT_sink_node_name]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_sink_node_name
			 ,(SELECT  TOP  1   [PT_tran_postilion_originated]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_tran_postilion_originated
			 ,(SELECT  TOP  1   [PT_tran_completed]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_completed
			 ,(SELECT  TOP  1   [PT_message_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_message_type
			 ,(SELECT  TOP  1   [PT_tran_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_type
			 ,(SELECT  TOP  1   [PT_tran_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )				PT_tran_nr
			 ,(SELECT  TOP  1   [PT_system_trace_audit_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_system_trace_audit_nr
			 ,(SELECT  TOP  1   [PT_rsp_code_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_rsp_code_req
			 ,(SELECT  TOP  1   [PT_rsp_code_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_rsp_code_rsp
			 ,(SELECT  TOP  1   [PT_abort_rsp_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_abort_rsp_code
			 ,(SELECT  TOP  1   [PT_auth_id_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_auth_id_rsp
			 ,(SELECT  TOP  1   [PT_auth_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_auth_type
			 ,(SELECT  TOP  1   [PT_auth_reason]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_auth_reason
			 ,(SELECT  TOP  1   [PT_retention_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_retention_data
			 ,(SELECT  TOP  1   [PT_acquiring_inst_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_acquiring_inst_id_code
			 ,(SELECT  TOP  1   [PT_message_reason_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_message_reason_code
			 ,(SELECT  TOP  1   [PT_sponsor_bank]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_sponsor_bank
			 ,(SELECT  TOP  1   [PT_retrieval_reference_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_retrieval_reference_nr
			 ,(SELECT  TOP  1   [PT_datetime_tran_gmt]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_datetime_tran_gmt
			 ,(SELECT  TOP  1   [PT_datetime_tran_local]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_datetime_tran_local
			 ,(SELECT  TOP  1   [PT_datetime_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_datetime_req
			 ,(SELECT  TOP  1   [PT_datetime_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_datetime_rsp
			 ,(SELECT  TOP  1   [PT_realtime_business_date]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_realtime_business_date
			 ,(SELECT  TOP  1   [PT_recon_business_date]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_recon_business_date
			 ,(SELECT  TOP  1   [PT_from_account_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_from_account_type
			 ,(SELECT  TOP  1   [PT_to_account_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_to_account_type
			 ,(SELECT  TOP  1   [PT_from_account_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_from_account_id
			 ,(SELECT  TOP  1   [PT_to_account_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_to_account_id
			 ,(SELECT  TOP  1   [PT_tran_amount_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_amount_req
			 ,(SELECT  TOP  1   [PT_tran_amount_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_amount_rsp
			 ,(SELECT  TOP  1   [PT_settle_amount_impact]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_amount_impact
			 ,(SELECT  TOP  1   [PT_tran_cash_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_cash_req
			 ,(SELECT  TOP  1   [PT_tran_cash_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_cash_rsp
			 ,(SELECT  TOP  1   [PT_tran_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_currency_code
			 ,(SELECT  TOP  1   [PT_tran_tran_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_tran_fee_req
			 ,(SELECT  TOP  1   [PT_tran_tran_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_tran_fee_rsp
			 ,(SELECT  TOP  1   [PT_tran_tran_fee_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_tran_tran_fee_currency_code
			 ,(SELECT  TOP  1   [PT_tran_proc_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_proc_fee_req
			 ,(SELECT  TOP  1   [PT_tran_proc_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_proc_fee_rsp
			 ,(SELECT  TOP  1   [PT_tran_proc_fee_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_tran_proc_fee_currency_code
			 ,(SELECT  TOP  1   [PT_settle_amount_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_amount_req
			 ,(SELECT  TOP  1   [PT_settle_amount_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_amount_rsp
			 ,(SELECT  TOP  1   [PT_settle_cash_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_settle_cash_req
			 ,(SELECT  TOP  1   [PT_settle_cash_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_settle_cash_rsp
			 ,(SELECT  TOP  1   [PT_settle_tran_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_tran_fee_req
			 ,(SELECT  TOP  1   [PT_settle_tran_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_tran_fee_rsp
			 ,(SELECT  TOP  1   [PT_settle_proc_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_proc_fee_req
			 ,(SELECT  TOP  1   [PT_settle_proc_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_proc_fee_rsp
			 ,(SELECT  TOP  1   [PT_settle_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_currency_code
			 ,(SELECT  TOP  1   [PT_pos_entry_mode]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_pos_entry_mode
			 ,(SELECT  TOP  1   [PT_pos_condition_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_pos_condition_code
			 ,(SELECT  TOP  1   [PT_additional_rsp_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_additional_rsp_data
			 ,(SELECT  TOP  1   [PT_tran_reversed]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_reversed
			 ,(SELECT  TOP  1   [PT_prev_tran_approved]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_prev_tran_approved
			 ,(SELECT  TOP  1   [PT_issuer_network_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_issuer_network_id
			 ,(SELECT  TOP  1   [PT_acquirer_network_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_acquirer_network_id
			 ,(SELECT  TOP  1   [PT_extended_tran_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_extended_tran_type
			 ,(SELECT  TOP  1   [PT_from_account_type_qualifier]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_from_account_type_qualifier
			 ,(SELECT  TOP  1   [PT_to_account_type_qualifier]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_to_account_type_qualifier
			 ,(SELECT  TOP  1   [PT_bank_details]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_bank_details
			 ,(SELECT  TOP  1   [PT_payee]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )				PT_payee
			 ,(SELECT  TOP  1   [PT_card_verification_result]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_card_verification_result
			 ,(SELECT  TOP  1   [PT_online_system_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_online_system_id
			 ,(SELECT  TOP  1   [PT_participant_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_participant_id
			 ,(SELECT  TOP  1   [PT_opp_participant_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_opp_participant_id
			 ,(SELECT  TOP  1   [PT_receiving_inst_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_receiving_inst_id_code
			 ,(SELECT  TOP  1   [PT_routing_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_routing_type
			 ,(SELECT  TOP  1   [PT_pt_pos_operating_environment]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_operating_environment
			 ,(SELECT  TOP  1   [PT_pt_pos_card_input_mode]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_pt_pos_card_input_mode
			 ,(SELECT  TOP  1   [PT_pt_pos_cardholder_auth_method]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_cardholder_auth_method
			 ,(SELECT  TOP  1   [PT_pt_pos_pin_capture_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_pin_capture_ability
			 ,(SELECT  TOP  1   [PT_pt_pos_terminal_operator]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_terminal_operator
			 ,(SELECT  TOP  1   [PT_source_node_key]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_source_node_key
			 ,(SELECT  TOP  1   [PT_proc_online_system_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_proc_online_system_id
			 ,(SELECT  TOP  1   [PTC_post_tran_cust_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_post_tran_cust_id
			 ,(SELECT  TOP  1   [PTC_source_node_name]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_source_node_name
			 ,(SELECT  TOP  1   [PTC_draft_capture]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_draft_capture
			 ,(SELECT  TOP  1   [PTC_pan]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )				PTC_pan
			 ,(SELECT  TOP  1   [PTC_card_seq_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_card_seq_nr
			 ,(SELECT  TOP  1   [PTC_expiry_date]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_expiry_date
			 ,(SELECT  TOP  1   [PTC_service_restriction_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_service_restriction_code
			 ,(SELECT  TOP  1   [PTC_terminal_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_terminal_id
			 ,(SELECT  TOP  1   [PTC_terminal_owner]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_terminal_owner
			 ,(SELECT  TOP  1   [PTC_card_acceptor_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_card_acceptor_id_code
			 ,(SELECT  TOP  1   [PTC_mapped_card_acceptor_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_mapped_card_acceptor_id_code
			 ,(SELECT  TOP  1   [PTC_merchant_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_merchant_type
			 ,(SELECT  TOP  1   [PTC_card_acceptor_name_loc]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_card_acceptor_name_loc
			 ,(SELECT  TOP  1   [PTC_address_verification_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_address_verification_data
			 ,(SELECT  TOP  1   [PTC_address_verification_result]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_address_verification_result
			 ,(SELECT  TOP  1   [PTC_check_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_check_data
			 ,(SELECT  TOP  1   [PTC_totals_group]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_totals_group
			 ,(SELECT  TOP  1   [PTC_card_product]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_card_product
			 ,(SELECT  TOP  1   [PTC_pos_card_data_input_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_data_input_ability
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_auth_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_cardholder_auth_ability
			 ,(SELECT  TOP  1   [PTC_pos_card_capture_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_capture_ability
			 ,(SELECT  TOP  1   [PTC_pos_operating_environment]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_operating_environment
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_present]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_cardholder_present
			 ,(SELECT  TOP  1   [PTC_pos_card_present]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_card_present
			 ,(SELECT  TOP  1   [PTC_pos_card_data_input_mode]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_data_input_mode
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_auth_method]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_cardholder_auth_method
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_auth_entity]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_cardholder_auth_entity
			 ,(SELECT  TOP  1   [PTC_pos_card_data_output_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_data_output_ability
			 ,(SELECT  TOP  1   [PTC_pos_terminal_output_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_terminal_output_ability
			 ,(SELECT  TOP  1   [PTC_pos_pin_capture_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_pin_capture_ability
			 ,(SELECT  TOP  1   [PTC_pos_terminal_operator]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_terminal_operator
			 ,(SELECT  TOP  1   [PTC_pos_terminal_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_terminal_type
			 ,(SELECT  TOP  1   [PTC_pan_search]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_pan_search
			 ,(SELECT  TOP  1   [PTC_pan_encrypted]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_pan_encrypted
			 ,(SELECT  TOP  1   [PTC_pan_reference]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_pan_reference
			   ,(SELECT TOP 1   PTSP_Account_Nr FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id)   PTSP_Account_Nr
			 ,(SELECT TOP 1   ptsp_code FROM  tbl_PTSP PTSP (nolock) where  PTT.PTC_terminal_id = PTSP.terminal_id)  ptsp_code
			 , (SELECT TOP 1   pa.PTSP_Code FROM  tbl_PTSP_Account PA(nolock) join  tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id )   account_PTSP_Code
			 ,(SELECT TOP 1   PTSP_Name FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id)    PTSP_Name
			 ,(SELECT TOP 1   rdm_amt FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)    rdm_amt
			 ,(SELECT TOP 1   Reward_Code FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)       Reward_Code
			 ,(SELECT TOP 1   Reward_discount FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     Reward_discount
			 ,(SELECT TOP 1   rr_number FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)  rr_number
			 ,(SELECT TOP  1 sdi_tran_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)     sdi_tran_id
			 ,(SELECT TOP  1 se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)        se_id
			 ,(SELECT TOP  1 session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id) session_id
			 ,(SELECT TOP 1   SORT_CODE FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id)    Sort_Code
			 ,(SELECT TOP  1 spay_session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)  spay_session_id
			 ,(SELECT TOP  1 spst_session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			 
			  spst_session_id
			 ,(SELECT TOP 1   stan FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													) stan
			 ,(SELECT TOP  1 tag FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         tag
			 , (SELECT TOP 1   terminal_id FROM  tbl_PTSP PTSP (nolock) where  PTT.PTC_terminal_id = PTSP.terminal_id)      ptsp_terminal_id
			 ,(SELECT TOP 1   Y.terminal_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)	reward_terminal_id
			 	,(SELECT TOP 1   terminal_mode FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  ) terminal_mode
			 ,(SELECT TOP 1   Y.trans_date FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code) trans_date
			 ,(SELECT TOP 1   Y.txn_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     txn_id
			 ,(SELECT TOP 1   mer.category_code FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code)web_category_code
			 ,(SELECT TOP 1   mer.category_name FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code ) web_category_name
			 , (SELECT TOP 1   mer.fee_type FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )  web_fee_type
			 , (SELECT TOP 1   mer.merchant_disc FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )   web_merchant_disc
			 ,(SELECT TOP 1   mer.amount_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )    web_amount_cap
			 ,(SELECT TOP 1   mer.fee_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )     web_fee_cap
			 , (SELECT TOP 1   mer.bearer FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )     web_bearer
			 , (SELECT TOP 1   ow.terminal_id FROM  tbl_terminal_owner ow (nolock) WHERE PTT.PTC_terminal_id = ow.terminal_id  )   owner_terminal_id
			 ,(SELECT TOP 1   ow.Terminal_code FROM  tbl_terminal_owner ow (nolock) WHERE PTT.PTC_terminal_id = ow.terminal_id  )  owner_terminal_code
			 ,(SELECT TOP  1 acc_post_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			  acc_post_id
			 ,(SELECT TOP 1   Account_Name FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			       Account_Name
			 ,(SELECT TOP 1   account_nr FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			   account_nr
			 ,(SELECT TOP 1 acquirer_inst_id1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id1
			 ,(SELECT TOP 1 acquirer_inst_id2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id2
			 ,(SELECT TOP 1 acquirer_inst_id3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id3
			 ,(SELECT TOP 1 acquirer_inst_id4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id4
			 ,(SELECT TOP 1 acquirer_inst_id5 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id5
			 ,(SELECT TOP 1   Acquiring_bank FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			      Acquiring_bank
			 ,(SELECT TOP 1   acquiring_inst_id_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													) acquiring_inst_id_code
			 ,(SELECT TOP 1   Addit_charge FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     Addit_charge
			 ,(SELECT TOP 1   Addit_party FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)        Addit_party
			 ,(SELECT TOP  1 adj_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       adj_id
			 ,(SELECT TOP  1 amount FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      journal_amount
			 ,(SELECT TOP 1    amount FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)  xls_amount
			 ,(SELECT TOP  1 Amount_amount_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			     Amount_amount_id
			 ,(SELECT TOP 1   m.Amount_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)     merch_cat_amount_cap
			 ,(SELECT TOP 1   s.amount_cap FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )    merch_cat_visa_amount_cap
			 ,(SELECT TOP 1   r.amount_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)    reward_amount_cap
			 ,(SELECT TOP  1 Amount_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      Amount_config_set_id
			 ,(SELECT TOP  1 Amount_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         Amount_config_state
			 ,(SELECT TOP  1 Amount_description FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			             Amount_description
			 ,(SELECT TOP  1 amount_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			              amount_id
			 ,(SELECT TOP  1 Amount_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  Amount_name
			 ,(SELECT TOP  1 Amount_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                      Amount_se_id
			 ,(SELECT TOP  1 amount_value_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                      amount_value_id
			 ,(SELECT TOP 1   Authorized_Person FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			        Authorized_Person
			 ,(SELECT TOP 1 BANK_CODE FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						
			 	  ACC_BANK_CODE
			 ,(SELECT TOP 1 bank_code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       BANK_CODE1
			 ,(SELECT TOP 1 BANK_INSTITUTION_NAME FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)				  BANK_INSTITUTION_NAME
			 ,(SELECT TOP 1   m.bearer FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)  merch_cat_bearer
			 ,(SELECT TOP 1   s.bearer FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )  merch_cat_visa_bearer
			 ,(SELECT TOP  1 business_date FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       business_date
			 ,(SELECT TOP 1   card_acceptor_id_code FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			    card_acceptor_id_code
			 ,PTc_card_acceptor_name_loc card_acceptor_name_loc
			 ,(SELECT TOP 1   cashier_acct FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)     cashier_acct
			 ,(SELECT TOP 1   cashier_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)       cashier_code
			 ,(SELECT TOP 1   cashier_ext_trans_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)   cashier_ext_trans_code
			 ,(SELECT TOP 1   cashier_name FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)      cashier_name
			 ,(SELECT TOP 1   s.category_code FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )   merch_cat_visa_category_code
			 , (SELECT TOP 1   m.Category_Code FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)  merch_cat_category_code
			 ,(SELECT TOP 1   s.category_name FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )  merch_cat_visa_category_name
			 ,(SELECT TOP 1   m.Category_name FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)   merch_cat_category_name
			 ,(SELECT TOP 1 CBN_Code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       CBN_Code1
			 ,(SELECT TOP 1 CBN_Code2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)			  CBN_Code2
			 ,(SELECT TOP 1 CBN_Code3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)  CBN_Code3
			 ,(SELECT TOP 1 CBN_Code4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)	  CBN_Code4
			 ,(SELECT TOP  1 coa_coa_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			   coa_coa_id
			 ,(SELECT TOP  1 coa_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      coa_config_set_id
			 ,(SELECT TOP  1 coa_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			     coa_config_state
			 ,(SELECT TOP  1 coa_description FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      coa_description
			 ,(SELECT TOP  1 coa_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         coa_id
			 ,(SELECT TOP  1 coa_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         coa_name
			 ,(SELECT TOP  1 coa_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       coa_se_id
			 ,(SELECT TOP  1 coa_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       coa_type
			 ,(SELECT TOP  1 config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			        config_set_id
			 ,(SELECT TOP  1 credit_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       credit_acc_id
			 ,(SELECT TOP  1 credit_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      credit_acc_nr_id
			 ,(SELECT TOP  1 credit_cardholder_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       credit_cardholder_acc_id
			 ,(SELECT TOP  1 credit_cardholder_acc_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       credit_cardholder_acc_type
			 ,(SELECT TOP  1 CreditAccNr_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			          CreditAccNr_acc_id
			 ,(SELECT TOP  1 CreditAccNr_acc_nr FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         CreditAccNr_acc_nr
			 ,(SELECT TOP  1 CreditAccNr_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      CreditAccNr_acc_nr_id
			 ,(SELECT TOP  1 CreditAccNr_aggregation_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       CreditAccNr_aggregation_id
			 ,(SELECT TOP  1 CreditAccNr_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       CreditAccNr_config_set_id
			 ,(SELECT TOP  1 CreditAccNr_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			            CreditAccNr_config_state
			 ,(SELECT TOP  1 CreditAccNr_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			            CreditAccNr_se_id
			 ,(SELECT TOP  1 CreditAccNr_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			             CreditAccNr_state
			 ,(SELECT TOP 1   Date_Modified FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			      Date_Modified
			 ,(SELECT TOP  1 debit_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			               debit_acc_id
			 ,(SELECT TOP  1 debit_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			           debit_acc_nr_id
			 ,(SELECT TOP  1 debit_cardholder_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			             debit_cardholder_acc_id
			 ,(SELECT TOP  1 debit_cardholder_acc_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                debit_cardholder_acc_type
			 ,(SELECT TOP  1 DebitAccNr_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         DebitAccNr_acc_id
			 ,(SELECT TOP  1 DebitAccNr_acc_nr FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         DebitAccNr_acc_nr
			 ,(SELECT TOP  1 DebitAccNr_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			           DebitAccNr_acc_nr_id
			 ,(SELECT TOP  1 DebitAccNr_aggregation_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			              DebitAccNr_aggregation_id
			 ,(SELECT TOP  1 DebitAccNr_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_config_set_id
			 ,(SELECT TOP  1 DebitAccNr_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_config_state
			 ,(SELECT TOP  1 DebitAccNr_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_se_id
			 ,(SELECT TOP  1 DebitAccNr_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_state
			 ,(SELECT TOP  1 entry_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                   entry_id
			 ,(SELECT TOP 1   extended_trans_type FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)    extended_trans_type
			 ,(SELECT TOP  1 fee FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			               fee
			 ,(SELECT TOP  1 Fee_amount_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  Fee_amount_id
			 , (SELECT TOP 1   m.Fee_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)   merch_cat_fee_cap
			 ,(SELECT TOP 1   s.Fee_Cap  FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code ) merch_cat_visa_fee_cap
			 ,(SELECT TOP 1   r.fee_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code) reward_fee_cap
			    ,        (SELECT TOP  1 Fee_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			 Fee_config_set_id
			 ,(SELECT TOP  1 Fee_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			  Fee_config_state
			 ,(SELECT TOP  1 Fee_description FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			    Fee_description
			 ,(SELECT TOP 1   Fee_Discount FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     Fee_Discount
			 ,(SELECT TOP  1 Fee_fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			   Fee_fee_id
			 ,(SELECT TOP  1 fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       fee_id
			 ,(SELECT TOP  1 Fee_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         Fee_name
			 ,(SELECT TOP  1 Fee_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			          Fee_se_id
			 ,(SELECT TOP 1   m.fee_type FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code) merch_cat_category_fee_type
			 ,(SELECT TOP 1   s.fee_type FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code ) merch_cat_category_visa_fee_type
			 , (SELECT TOP  1 Fee_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			          journal_fee_type
			 ,(SELECT TOP  1 fee_value_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			              fee_value_id
			 ,(SELECT TOP  1 granularity_element FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			     granularity_element
			 ,(SELECT TOP 1   m.Merchant_Disc FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code) merch_cat_category_merch_discount
			 ,(SELECT TOP 1   s.Merchant_Disc FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )  merch_cat_category_visa_merch_discount
			 ,(SELECT TOP 1   merchant_id FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)       merchant_id
			 ,(SELECT TOP 1   merchant_type FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)    merchant_type
			 ,(SELECT TOP  1 nt_fee FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			            nt_fee
			 ,(SELECT TOP  1 nt_fee_acc_post_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                nt_fee_acc_post_id
			 ,(SELECT TOP  1 nt_fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                 nt_fee_id
			 ,(SELECT TOP  1 nt_fee_value_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  nt_fee_value_id
			 ,(SELECT TOP 1   pan FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)  pan
			 INTO ##final_results_tables  
			   FROM 
			 						     ##settle_tran_details report_results  (nolock) join ##temp_post_tran_data_local PTT (nolock) 
										 ON   PTT.PT_post_tran_id = report_results.PTID
			 						OPTION(recompile,optimize for unknown, MAXDOP 8)
			 								
							INSERT INTO postilion_office.dbo.['+@previous_table_name+']	SELECT DISTINCT * ,post_tran_id_1,post_tran_cust_id_1 FROM ##final_results_tables;								 
															 ');
								
	EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED IF (OBJECT_ID(''tempdb.dbo.##settle_tran_details'') IS NOT NULL) BEGIN
		DROP TABLE ##settle_tran_details
		END
		
				IF (OBJECT_ID(''tempdb.dbo.##final_results_tables'') IS NOT NULL) BEGIN
					DROP TABLE ##final_results_tables
					END
		IF (OBJECT_ID(''tempdb.dbo.##temp_journal_data_local'') IS NOT NULL) BEGIN
		DROP TABLE ##temp_journal_data_local
		END
		
		IF (OBJECT_ID(''tempdb.dbo.##temp_post_tran_data_local'') IS NOT NULL) BEGIN
		DROP TABLE ##temp_post_tran_data_local
		END
				');
				IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[settlement_summary_breakdown_details]')) BEGIN
						
						 
						EXEC('ALTER VIEW dbo.settlement_summary_breakdown_details AS SELECT * FROM  ['+@previous_table_name+'] (NOLOCK)')
					END
					ELSE  BEGIN
						
						EXEC('CREATE VIEW dbo.settlement_summary_breakdown_details AS SELECT * FROM  ['+@previous_table_name+'](NOLOCK)')
					END
							
					END
								

										
					END
					IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
							DROP TABLE ##temp_query_table;
							END
						EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED	DECLARE @temp_post_tran_id BIGINT							
								SELECT   TOP	1 @temp_post_tran_id = (post_tran_id) FROM SSTL_JOURNAL_TEMP (NOLOCK) WHERE replace(CONVERT(VARCHAR(10), business_date,112),''-'','''')  ='''+@settlement_date+''' ORDER BY  entry_id ASC;
								SELECT   TOP  1 post_tran_id  INTO  ##temp_query_table from sstl_journal_temp  (NOLOCK) WHERE post_tran_id <@temp_post_tran_id and REPLACE(CONVERT(VARCHAR(10), business_date,112),''-'','''') <='''+@settlement_date+''' ORDER BY  post_tran_id ASC')
								IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
								SELECT @start_post_tran_id = ISNULL(post_tran_id-1,0)  FROM  ##temp_query_table;
								DROP TABLE ##temp_query_table;
								END	
									
									IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
							DROP TABLE ##temp_query_table;
							END
				EXEC ('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED SELECT MAX (last_post_tran_id) post_tran_id INTO  ##temp_query_table  FROM postilion_office.dbo.sstl_session (NOLOCK) WHERE CONVERT(VARCHAR(10),datetime_started ,112)='''+@settlement_date+''' and completed =1 ')
							IF(OBJECT_ID('tempdb.dbo.##temp_query_table') IS NOT NULL) BEGIN
								SELECT @end_post_tran_id = ISNULL(post_tran_id,0)  FROM  ##temp_query_table;
								DROP TABLE ##temp_query_table;
							END			    
	EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED IF (OBJECT_ID(''tempdb.dbo.##settle_tran_details'') IS NOT NULL) BEGIN
		DROP TABLE ##settle_tran_details
		END
		
		IF (OBJECT_ID(''tempdb.dbo.##temp_journal_data_local'') IS NOT NULL) BEGIN
		DROP TABLE ##temp_journal_data_local
		END
		
		IF (OBJECT_ID(''tempdb.dbo.##temp_post_tran_data_local'') IS NOT NULL) BEGIN
		DROP TABLE ##temp_post_tran_data_local
		END
				');
	
EXEC('	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED			
						 SELECT  
						J.adj_id
						,J.entry_id
						,J.config_set_id
						,J.session_id
						,J.post_tran_id
						,J.post_tran_cust_id
						,J.sdi_tran_id
						,J.acc_post_id
						,J.nt_fee_acc_post_id
						,J.coa_id
						,J.coa_se_id
						,J.se_id
						,J.amount
						,J.amount_id
						,J.amount_value_id
						,J.fee
						,J.fee_id
						,J.fee_value_id
						,J.nt_fee
						,J.nt_fee_id
						,J.nt_fee_value_id
						,J.debit_acc_nr_id
						,J.debit_acc_id
						,J.debit_cardholder_acc_id
						,J.debit_cardholder_acc_type
						,J.credit_acc_nr_id
						,J.credit_acc_id
							,J.credit_cardholder_acc_id
							,J.credit_cardholder_acc_type
							,J.business_date
							,J.granularity_element
							,J.tag
							,J.spay_session_id
							,J.spst_session_id
							,DebitAccNr.config_set_id DebitAccNr_config_set_id
							,DebitAccNr.acc_nr_id  DebitAccNr_acc_nr_id
							,DebitAccNr.se_id	DebitAccNr_se_id
							,DebitAccNr.acc_id	DebitAccNr_acc_id
							,DebitAccNr.acc_nr	DebitAccNr_acc_nr
							,DebitAccNr.aggregation_id DebitAccNr_aggregation_id
							,DebitAccNr.state	DebitAccNr_state
							,DebitAccNr.config_state DebitAccNr_config_state
							,CreditAccNr.config_set_id CreditAccNr_config_set_id
							,CreditAccNr.acc_nr_id  CreditAccNr_acc_nr_id
							,CreditAccNr.se_id	CreditAccNr_se_id
							,CreditAccNr.acc_id	CreditAccNr_acc_id
							,CreditAccNr.acc_nr	CreditAccNr_acc_nr
							,CreditAccNr.aggregation_id CreditAccNr_aggregation_id
							,CreditAccNr.state	CreditAccNr_state
							,CreditAccNr.config_state CreditAccNr_config_state
							,Amount.config_set_id	Amount_config_set_id
							,Amount.amount_id	Amount_amount_id
							,Amount.se_id	Amount_se_id
							,Amount.name	Amount_name
							,Amount.description	Amount_description
							,Amount.config_state	Amount_config_state
							,Fee.config_set_id Fee_config_set_id
							,Fee.fee_id	Fee_fee_id
							,Fee.se_id	Fee_se_id
							,Fee.name	Fee_name
							,Fee.description Fee_description
							,Fee.type	Fee_type
							,Fee.amount_id Fee_amount_id
							,Fee.config_state Fee_config_state
							,coa.config_set_id coa_config_set_id
							,coa.coa_id	coa_coa_id
							,coa.name	coa_name
							,coa.description	coa_description
							,coa.type	coa_type
							,coa.config_state	coa_config_state
							 INTO ##temp_journal_data_local
							FROM	(SELECT  Jr.adj_id,Jr.entry_id,Jr.config_set_id,Jr.session_id,Jr.post_tran_id,Jr.post_tran_cust_id,Jr.sdi_tran_id,Jr.acc_post_id,Jr.nt_fee_acc_post_id,Jr.coa_id,Jr.coa_se_id,Jr.se_id,Jr.amount,Jr.amount_id,Jr.amount_value_id,Jr.fee,Jr.fee_id,Jr.fee_value_id,Jr.nt_fee,Jr.nt_fee_id,Jr.nt_fee_value_id,Jr.debit_acc_nr_id,Jr.debit_acc_id,Jr.debit_cardholder_acc_id,Jr.debit_cardholder_acc_type,Jr.credit_acc_nr_id,Jr.credit_acc_id,Jr.credit_cardholder_acc_id,Jr.credit_cardholder_acc_type,Jr.business_date,Jr.granularity_element,Jr.tag,Jr.spay_session_id,Jr.spst_session_id FROM dbo.[sstl_journal_temp] jr WHERE post_tran_id  > '+@start_post_tran_id+' and post_tran_id  <='+@end_post_tran_id+' 	AND business_date = '''+@settlement_date+''') J 
							LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
							ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
							LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
							ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
							LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
							ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
							LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
							ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
							LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
							ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
							
							OPTION(RECOMPILE,optimize for unknown)
							');
														
EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
										SELECT
									PT.[post_tran_id]	PT_post_tran_id
									,PT.[post_tran_cust_id]	PT_post_tran_cust_id
									,PT.[settle_entity_id]	PT_settle_entity_id
									,PT.[batch_nr]	PT_batch_nr
									,PT.[prev_post_tran_id]	PT_prev_post_tran_id
									,PT.[next_post_tran_id]	PT_next_post_tran_id
									,PT.[sink_node_name]	PT_sink_node_name
									,PT.[tran_postilion_originated]	PT_tran_postilion_originated
									,PT.[tran_completed]	PT_tran_completed
									,PT.[message_type]	PT_message_type
									,PT.[tran_type]	PT_tran_type
									,PT.[tran_nr]	PT_tran_nr
									,PT.[system_trace_audit_nr]	PT_system_trace_audit_nr
									,PT.[rsp_code_req]	PT_rsp_code_req
									,PT.[rsp_code_rsp]	PT_rsp_code_rsp
									,PT.[abort_rsp_code]	PT_abort_rsp_code
									,PT.[auth_id_rsp]	PT_auth_id_rsp
									,PT.[auth_type]	PT_auth_type
									,PT.[auth_reason]	PT_auth_reason
									,PT.[retention_data]	PT_retention_data
									,PT.[acquiring_inst_id_code]	PT_acquiring_inst_id_code
									,PT.[message_reason_code]	PT_message_reason_code
									,PT.[sponsor_bank]	PT_sponsor_bank
									,PT.[retrieval_reference_nr]	PT_retrieval_reference_nr
									,PT.[datetime_tran_gmt]	PT_datetime_tran_gmt
									,PT.[datetime_tran_local]	PT_datetime_tran_local
									,PT.[datetime_req]	PT_datetime_req
									,PT.[datetime_rsp]	PT_datetime_rsp
									,PT.[realtime_business_date]	PT_realtime_business_date
									,PT.[recon_business_date]	PT_recon_business_date
									,PT.[from_account_type]	PT_from_account_type
									,PT.[to_account_type]	PT_to_account_type
									,PT.[from_account_id]	PT_from_account_id
									,PT.[to_account_id]	PT_to_account_id
									,PT.[tran_amount_req]	PT_tran_amount_req
									,PT.[tran_amount_rsp]	PT_tran_amount_rsp
									,PT.[settle_amount_impact]	PT_settle_amount_impact
									,PT.[tran_cash_req]	PT_tran_cash_req
									,PT.[tran_cash_rsp]	PT_tran_cash_rsp
									,PT.[tran_currency_code]	PT_tran_currency_code
									,PT.[tran_tran_fee_req]	PT_tran_tran_fee_req
									,PT.[tran_tran_fee_rsp]	PT_tran_tran_fee_rsp
									,PT.[tran_tran_fee_currency_code]	PT_tran_tran_fee_currency_code
									,PT.[tran_proc_fee_req]	PT_tran_proc_fee_req
									,PT.[tran_proc_fee_rsp]	PT_tran_proc_fee_rsp
									,PT.[tran_proc_fee_currency_code]	PT_tran_proc_fee_currency_code
									,PT.[settle_amount_req]	PT_settle_amount_req
									,PT.[settle_amount_rsp]	PT_settle_amount_rsp
									,PT.[settle_cash_req]	PT_settle_cash_req
									,PT.[settle_cash_rsp]	PT_settle_cash_rsp
									,PT.[settle_tran_fee_req]	PT_settle_tran_fee_req
									,PT.[settle_tran_fee_rsp]	PT_settle_tran_fee_rsp
									,PT.[settle_proc_fee_req]	PT_settle_proc_fee_req
									,PT.[settle_proc_fee_rsp]	PT_settle_proc_fee_rsp
									,PT.[settle_currency_code]	PT_settle_currency_code
									,PT.[pos_entry_mode]	PT_pos_entry_mode
									,PT.[pos_condition_code]	PT_pos_condition_code
									,PT.[additional_rsp_data]	PT_additional_rsp_data
									,PT.[tran_reversed]	PT_tran_reversed
									,PT.[prev_tran_approved]	PT_prev_tran_approved
									,PT.[issuer_network_id]	PT_issuer_network_id
									,PT.[acquirer_network_id]	PT_acquirer_network_id
									,PT.[extended_tran_type]	PT_extended_tran_type
									,PT.[from_account_type_qualifier]	PT_from_account_type_qualifier
									,PT.[to_account_type_qualifier]	PT_to_account_type_qualifier
									,PT.[bank_details]	PT_bank_details
									,PT.[payee]	PT_payee
									,PT.[card_verification_result]	PT_card_verification_result
									,PT.[online_system_id]	PT_online_system_id
									,PT.[participant_id]	PT_participant_id
									,PT.[opp_participant_id]	PT_opp_participant_id
									,PT.[receiving_inst_id_code]	PT_receiving_inst_id_code
									,PT.[routing_type]	PT_routing_type
									,PT.[pt_pos_operating_environment]	PT_pt_pos_operating_environment
									,PT.[pt_pos_card_input_mode]	PT_pt_pos_card_input_mode
									,PT.[pt_pos_cardholder_auth_method]	PT_pt_pos_cardholder_auth_method
									,PT.[pt_pos_pin_capture_ability]	PT_pt_pos_pin_capture_ability
									,PT.[pt_pos_terminal_operator]	PT_pt_pos_terminal_operator
									,PT.[source_node_key]	PT_source_node_key
									,PT.[proc_online_system_id]	PT_proc_online_system_id
									,PTC.[post_tran_cust_id]	PTC_post_tran_cust_id
									,PTC.[source_node_name]	PTC_source_node_name
									,PTC.[draft_capture]	PTC_draft_capture
									,PTC.[pan]	PTC_pan
									,PTC.[card_seq_nr]	PTC_card_seq_nr
									,PTC.[expiry_date]	PTC_expiry_date
									,PTC.[service_restriction_code]	PTC_service_restriction_code
									,PTC.[terminal_id]	PTC_terminal_id
									,PTC.[terminal_owner]	PTC_terminal_owner
									,PTC.[card_acceptor_id_code]	PTC_card_acceptor_id_code
									,PTC.[mapped_card_acceptor_id_code]	PTC_mapped_card_acceptor_id_code
									,PTC.[merchant_type]	PTC_merchant_type
									,PTC.[card_acceptor_name_loc]	PTC_card_acceptor_name_loc
									,PTC.[address_verification_data]	PTC_address_verification_data
									,PTC.[address_verification_result]	PTC_address_verification_result
									,PTC.[check_data]	PTC_check_data
									,PTC.[totals_group]	PTC_totals_group
									,PTC.[card_product]	PTC_card_product
									,PTC.[pos_card_data_input_ability]	PTC_pos_card_data_input_ability
									,PTC.[pos_cardholder_auth_ability]	PTC_pos_cardholder_auth_ability
									,PTC.[pos_card_capture_ability]	PTC_pos_card_capture_ability
									,PTC.[pos_operating_environment]	PTC_pos_operating_environment
									,PTC.[pos_cardholder_present]	PTC_pos_cardholder_present
									,PTC.[pos_card_present]	PTC_pos_card_present
									,PTC.[pos_card_data_input_mode]	PTC_pos_card_data_input_mode
									,PTC.[pos_cardholder_auth_method]	PTC_pos_cardholder_auth_method
									,PTC.[pos_cardholder_auth_entity]	PTC_pos_cardholder_auth_entity
									,PTC.[pos_card_data_output_ability]	PTC_pos_card_data_output_ability
									,PTC.[pos_terminal_output_ability]	PTC_pos_terminal_output_ability
									,PTC.[pos_pin_capture_ability]	PTC_pos_pin_capture_ability
									,PTC.[pos_terminal_operator]	PTC_pos_terminal_operator
									,PTC.[pos_terminal_type]	PTC_pos_terminal_type
									,PTC.[pan_search]	PTC_pan_search
									,PTC.[pan_encrypted]	PTC_pan_encrypted
									,PTC.[pan_reference]	PTC_pan_reference
									
									INTO ##temp_post_tran_data_local
									FROM   (SELECT [post_tran_id]
								,[post_tran_cust_id]	
								,[settle_entity_id]	
								,[batch_nr]
								,[prev_post_tran_id]	
								,[next_post_tran_id]	
								,[sink_node_name]	
								,[tran_postilion_originated]
								,[tran_completed]	
								,[message_type]
								,[tran_type]
								,[tran_nr]
								,[system_trace_audit_nr]
								,[rsp_code_req]
								,[rsp_code_rsp]
								,[abort_rsp_code]	
								,[auth_id_rsp]
								,[auth_type]
								,[auth_reason]
								,[retention_data]	
								,[acquiring_inst_id_code]
								,[message_reason_code]	
								,[sponsor_bank]
								,[retrieval_reference_nr]
								,[datetime_tran_gmt]	
								,[datetime_tran_local]	
								,[datetime_req]
								,[datetime_rsp]
								,[realtime_business_date]
								,[recon_business_date]	
								,[from_account_type]	
								,[to_account_type]	
								,[from_account_id]	
								,[to_account_id]	
								,[tran_amount_req]	
								,[tran_amount_rsp]	
								,[settle_amount_impact]	
								,[tran_cash_req]	
								,[tran_cash_rsp]	
								,[tran_currency_code]	
								,[tran_tran_fee_req]	
								,[tran_tran_fee_rsp]	
								,[tran_tran_fee_currency_code]
								,[tran_proc_fee_req]	
								,[tran_proc_fee_rsp]	
								,[tran_proc_fee_currency_code]
								,[settle_amount_req]	
								,[settle_amount_rsp]	
								,[settle_cash_req]	
								,[settle_cash_rsp]	
								,[settle_tran_fee_req]	
								,[settle_tran_fee_rsp]	
								,[settle_proc_fee_req]	
								,[settle_proc_fee_rsp]	
								,[settle_currency_code]	
								,[pos_entry_mode]	
								,[pos_condition_code]	
								,[additional_rsp_data]	
								,[tran_reversed]	
								,[prev_tran_approved]	
								,[issuer_network_id]	
								,[acquirer_network_id]	
								,[extended_tran_type]	
								,[from_account_type_qualifier]
								,[to_account_type_qualifier]
								,[bank_details]
								,[payee]
								,[card_verification_result]
								,[online_system_id]	
								,[participant_id]	
								,[opp_participant_id]	
								,[receiving_inst_id_code]
								,[routing_type]
								,pt_pos_operating_environment
								,pt_pos_card_input_mode
								,pt_pos_cardholder_auth_method
								,pt_pos_pin_capture_ability
								,pt_pos_terminal_operator
								,source_node_key
								,[proc_online_system_id] FROM   post_tran AS PT1 WITH (NOLOCK, INDEX(ix_post_tran_9))
								     WHERE   recon_business_date = '''+@settlement_date+''' AND  post_tran_id  > '+@start_post_tran_id+'  AND post_tran_id <='+@end_post_tran_id+' 
															AND PT1.post_tran_id NOT IN (
															 SELECT  post_tran_id  FROM tbl_late_reversals ll (NOLOCK) 
																	WHERE ll.recon_business_date >= '''+@settlement_date+'''
																	and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
																				) AND
																				rsp_code_rsp IN (''00'',''11'',''09'')	
															AND LEFT(sink_node_name,2)<> ''SB''
																			 AND  sink_node_name <> ''WUESBPBsnk''
																   AND  CHARINDEX(''TPP'', sink_node_name) < 1 
																 )  PT    JOIN  Post_tran_cust AS PTC WITH  (NOLOCK, INDEX(pk_post_tran_cust))
									ON (PT.post_tran_cust_id = PTC.post_tran_cust_id 
									 AND  LEFT( source_node_name,2 ) <> ''SB''
									AND  CHARINDEX(''TPP'',source_node_name )<1
									AND source_node_name <> ''SWTMEGADSsrc'') 
									AND LEFT(card_acceptor_id_code,3) <>''IPG''			
								option(RECOMPILE,optimize for unknown, MAXDOP 8)
								');
														
	EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_1] ON [##temp_post_tran_data_local] 
(
	[PT_message_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_10] ON [##temp_post_tran_data_local] 
(
	[PT_settle_amount_impact] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]



CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_11] ON [##temp_post_tran_data_local] 
(
	[PT_message_type] ASC,
	[PT_tran_type] ASC,
	[PTC_source_node_name] ASC,
	[PT_sink_node_name] ASC,
	[PTC_terminal_id] ASC,
	[PTC_totals_group] ASC,
	[PTC_pan] ASC,
	[PT_settle_amount_impact] ASC,
	[PT_acquiring_inst_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]



CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_12] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC
)
INCLUDE ( [PT_post_tran_cust_id],
[PT_tran_nr],
[PT_retention_data]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_13] ON [##temp_post_tran_data_local] 
(
	[PT_post_tran_cust_id] ASC,
	[PT_tran_postilion_originated] ASC,
	[PT_tran_nr] ASC
)
INCLUDE ( [PT_retention_data]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_14] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PTC_totals_group] ASC
)
INCLUDE ( [PT_post_tran_id],
[PT_post_tran_cust_id],
[PT_sink_node_name],
[PT_message_type],
[PT_tran_type],
[PT_tran_nr],
[PT_system_trace_audit_nr],
[PT_acquiring_inst_id_code],
[PT_retrieval_reference_nr],
[PT_settle_amount_impact],
[PT_settle_amount_rsp],
[PT_settle_currency_code],
[PT_tran_reversed],
[PT_extended_tran_type],
[PT_payee],
[PTC_source_node_name],
[PTC_pan],
[PTC_terminal_id],
[PTC_card_acceptor_id_code],
[PTC_merchant_type],
[PTC_card_acceptor_name_loc]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_15] ON [##temp_post_tran_data_local] 
(
	[PT_recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_16] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_message_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PT_settle_amount_impact] ASC
)
INCLUDE ( [PT_sink_node_name],
[PT_system_trace_audit_nr],
[PT_retrieval_reference_nr],
[PT_to_account_id],
[PT_payee],
[PTC_source_node_name],
[PTC_pan],
[PTC_terminal_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_17] ON [##temp_post_tran_data_local] 
(
	[PT_extended_tran_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_18]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_18] ON [##temp_post_tran_data_local] 
(
	[PT_retention_data] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_2]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_2] ON [##temp_post_tran_data_local] 
(
	[PT_tran_type] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_3]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_3] ON [##temp_post_tran_data_local] 
(
	[PTC_source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_4]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_4] ON [##temp_post_tran_data_local] 
(
	[PT_sink_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_5]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_5] ON [##temp_post_tran_data_local] 
(
	[PTC_terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_6]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_6] ON [##temp_post_tran_data_local] 
(
	[PTC_totals_group] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_7]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_7] ON [##temp_post_tran_data_local] 
(
	[PTC_pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_9]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_9] ON [##temp_post_tran_data_local] 
(
	[PT_acquiring_inst_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_recon]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_recon] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_settle_currency_code] ASC,
	[PT_sink_node_name] ASC,
	[PT_tran_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PTC_source_node_name] ASC,
	[PTC_card_acceptor_id_code] ASC,
	[PTC_totals_group] ASC
)
INCLUDE ( [PT_post_tran_id],
[PT_post_tran_cust_id],
[PT_message_type],
[PT_system_trace_audit_nr],
[PT_acquiring_inst_id_code],
[PT_retrieval_reference_nr],
[PT_settle_amount_impact],
[PT_settle_amount_rsp],
[PT_tran_reversed],
[PT_extended_tran_type],
[PT_payee],
[PTC_pan],
[PTC_terminal_id],
[PTC_terminal_owner],
[PTC_merchant_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]


/****** Object:  INDEX [ix_temp_post_tran_data_local_recon_2]    Script Date: 03/16/2017 22:16:06 ******/
CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_local_recon_2] ON [##temp_post_tran_data_local] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_settle_currency_code] ASC,
	[PT_sink_node_name] ASC,
	[PT_tran_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PTC_source_node_name] ASC,
	[PTC_card_acceptor_id_code] ASC,
	[PTC_totals_group] ASC
)
INCLUDE ( [PT_post_tran_id],
[PT_post_tran_cust_id],
[PT_message_type],
[PT_system_trace_audit_nr],
[PT_acquiring_inst_id_code],
[PT_retrieval_reference_nr],
[PT_settle_amount_impact],
[PT_settle_amount_rsp],
[PT_tran_reversed],
[PT_extended_tran_type],
[PT_payee],
[PTC_pan],
[PTC_terminal_id],
[PTC_terminal_owner],
[PTC_merchant_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_local_1] ON [##temp_journal_data_local] 
(
	[DebitAccNr_acc_nr] ASC
)
INCLUDE ( [CreditAccNr_acc_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_local_2] ON [##temp_journal_data_local] 
(
	[CreditAccNr_acc_nr] ASC
)
INCLUDE ( [DebitAccNr_acc_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_local_3] ON [##temp_journal_data_local] 
(
	[business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
create index ix_post_tran_id on ##TEMP_journal_DATA_LOCAL(
post_tran_id
)

create index ix_post_tran_cust_id on ##TEMP_journal_DATA_LOCAL(
post_tran_cust_id
)
')
	
	EXEC('
	 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @all_fees VARCHAR(255)
SET @all_fees = ''ISSUER_FEE_PAYABLE,ISSUER_FEE_RECEIVABLE,AMOUNT_PAYABLE''

SELECT	     
															bank_code = CASE 
															                      
	WHEN					(dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
							   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
							   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
								and  (DebitAccNr_acc_nr LIKE ''%FEE_PAYABLE'' or CreditAccNr_acc_nr LIKE ''%FEE_PAYABLE'')) THEN ''ISW'' 
	WHEN                      
						   (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
							AND  
						   (DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'')
							 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							 THEN ''UBA''     
								 
	WHEN
					(DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE''
							
							  OR DebitAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'')
						AND (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
									  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''312''  and PT.PT_tran_type = ''50'')
									  
									  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							 THEN ''UBA''                            
							  
	WHEN                      (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							  AND ((PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
							  PT.PT_acquiring_inst_id_code <> ''627787'') 
									OR (PT.PTC_source_node_name = ''SWTFBPsrc'' AND PT.PT_sink_node_name = ''ASPPOSVISsnk'' 
									 AND PT.PTC_totals_group = ''VISAGroup'')
								   )
							  THEN ''UBA''
							  
							  
	WHEN                     (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
							  PT.PT_acquiring_inst_id_code = ''627787'')
							  THEN ''UNK'' 
	WHEN                      
				(PT.PT_sink_node_name = ''SWTWEBUBAsnk'')  
							AND  
				(DebitAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%ISSUER_FEE_PAYABLE''
							 OR DebitAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'' OR CreditAccNr_acc_nr LIKE ''%AMOUNT_PAYABLE'')
				 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
							 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
							 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							 THEN ''UBA''                             
							  
							  
							  
	  WHEN                     (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							AND  PT.PT_acquiring_inst_id_code <> ''627787'' 
								  AND PT.PT_sink_node_name = ''ASPPOSVISsnk''    
							  THEN ''UBA''     
							  
														
	 WHEN                     (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
							AND  PT.PT_acquiring_inst_id_code = ''627787''  
							AND PT.PT_sink_node_name = ''ASPPOSVISsnk''   
							  THEN ''GTB''       
																   
	 WHEN                      
							(PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  
							   AND  
							(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
							  THEN ''ABP''   
							 
		WHEN                     
						 (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
						 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
									   
							  THEN ''GTB''                                                                        
							   
	   WHEN                     
							 (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'')  AND
							(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
									  
							  THEN ''EBN''  
							  
	   WHEN                   
							(PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
							(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) 
							  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
							  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
							  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
									   
							  THEN ''UBA''                                             

WHEN PTT.PT_retention_data   = ''1046'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''UBN''
WHEN PTT.PT_retention_data  IN (''9130'',''8130'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ABS''
WHEN PTT.PT_retention_data  IN (''9044'',''8044'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ABP''
WHEN PTT.PT_retention_data  IN (''9023'',''8023'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''CITI''
WHEN PTT.PT_retention_data  IN (''9050'',''8050'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''EBN''
WHEN PTT.PT_retention_data  IN (''9214'',''8214'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''FCMB''
WHEN PTT.PT_retention_data  IN (''9070'',''8070'',''1100'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''FBP''
WHEN PTT.PT_retention_data  IN (''9011'',''8011'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''FBN''
WHEN PTT.PT_retention_data  IN (''9058'',''8058'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''GTB''
WHEN PTT.PT_retention_data  IN (''9082'',''8082'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''KSB''
WHEN PTT.PT_retention_data  IN (''9076'',''8076'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''SKYE''
WHEN PTT.PT_retention_data  IN (''9084'',''8084'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ENT''
WHEN PTT.PT_retention_data  IN (''9039'',''8039'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''IBTC''
WHEN PTT.PT_retention_data  IN (''9068'',''8068'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''SCB''
WHEN PTT.PT_retention_data  IN (''9232'',''8232'',''1105'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''SBP''
WHEN PTT.PT_retention_data  IN (''9032'',''8032'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''UBN''
WHEN PTT.PT_retention_data  IN (''9033'',''8033'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''UBA''
WHEN PTT.PT_retention_data  IN (''9215'',''8215'')  and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) then ''UBP''
WHEN PTT.PT_retention_data  IN (''9035'',''8035'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''WEMA''
WHEN PTT.PT_retention_data  IN (''9057'',''8057'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''ZIB''
WHEN PTT.PT_retention_data  IN (''9301'',''8301'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''JBP''
WHEN PTT.PT_retention_data  IN (''9030'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)  then ''HBC''	  
WHEN PTT.PT_retention_data   = ''1411'' and 
		(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''HBC''																						  
WHEN PTT.PT_retention_data   = ''1131'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''WEMA''
WHEN PTT.PT_retention_data  IN (''1061'',''1006'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''GTB''
WHEN PTT.PT_retention_data   = ''1708'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0)THEN ''FBN''
WHEN PTT.PT_retention_data  IN (''1027'',''1045'',''1081'',''1015'') and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''SKYE''
WHEN PTT.PT_retention_data   = ''1037'' and 
		(CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''IBTC''
WHEN PTT.PT_retention_data   = ''1034'' and 
		 (CHARINDEX(DebitAccNr_acc_nr, @all_fees)> 0 OR CHARINDEX(CreditAccNr_acc_nr, @all_fees)> 0) THEN ''EBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UBA%'' OR CreditAccNr_acc_nr LIKE ''UBA%'') THEN ''UBA''
																	 WHEN (DebitAccNr_acc_nr LIKE ''FBN%'' OR CreditAccNr_acc_nr LIKE ''FBN%'') THEN ''FBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ZIB%'' OR CreditAccNr_acc_nr LIKE ''ZIB%'') THEN ''ZIB'' 
																				 WHEN (DebitAccNr_acc_nr LIKE ''SPR%'' OR CreditAccNr_acc_nr LIKE ''SPR%'') THEN ''ENT''
																				 WHEN (DebitAccNr_acc_nr LIKE ''GTB%'' OR CreditAccNr_acc_nr LIKE ''GTB%'') THEN ''GTB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PRU%'' OR CreditAccNr_acc_nr LIKE ''PRU%'') THEN ''SKYE''
																				 WHEN (DebitAccNr_acc_nr LIKE ''OBI%'' OR CreditAccNr_acc_nr LIKE ''OBI%'') THEN ''EBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''WEM%'' OR CreditAccNr_acc_nr LIKE ''WEM%'') THEN ''WEMA''
																				 WHEN (DebitAccNr_acc_nr LIKE ''AFR%'' OR CreditAccNr_acc_nr LIKE ''AFR%'') THEN ''MSB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''IBTC%'' OR CreditAccNr_acc_nr LIKE ''IBTC%'') THEN ''IBTC''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PLAT%'' OR CreditAccNr_acc_nr LIKE ''PLAT%'') THEN ''KSB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UBP%'' OR CreditAccNr_acc_nr LIKE ''UBP%'') THEN ''UBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''DBL%'' OR CreditAccNr_acc_nr LIKE ''DBL%'') THEN ''DBL''
																				 WHEN (DebitAccNr_acc_nr LIKE ''FCMB%'' OR CreditAccNr_acc_nr LIKE ''FCMB%'') THEN ''FCMB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''IBP%'' OR CreditAccNr_acc_nr LIKE ''IBP%'') THEN ''ABP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UBN%'' OR CreditAccNr_acc_nr LIKE ''UBN%'') THEN ''UBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ETB%'' OR CreditAccNr_acc_nr LIKE ''ETB%'') THEN ''ETB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''FBP%'' OR CreditAccNr_acc_nr LIKE ''FBP%'') THEN ''FBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''SBP%'' OR CreditAccNr_acc_nr LIKE ''SBP%'') THEN ''SBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ABP%'' OR CreditAccNr_acc_nr LIKE ''ABP%'') THEN ''ABP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''EBN%'' OR CreditAccNr_acc_nr LIKE ''EBN%'') THEN ''EBN''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CITI%'' OR CreditAccNr_acc_nr LIKE ''CITI%'') THEN ''CITI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''FIN%'' OR CreditAccNr_acc_nr LIKE ''FIN%'') THEN ''FCMB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ASO%'' OR CreditAccNr_acc_nr LIKE ''ASO%'') THEN ''ASO''
																				 WHEN (DebitAccNr_acc_nr LIKE ''OLI%'' OR CreditAccNr_acc_nr LIKE ''OLI%'') THEN ''OLI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''HSL%'' OR CreditAccNr_acc_nr LIKE ''HSL%'') THEN ''HSL''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ABS%'' OR CreditAccNr_acc_nr LIKE ''ABS%'') THEN ''ABS''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PAY%'' OR CreditAccNr_acc_nr LIKE ''PAY%'') THEN ''PAY''
																				 WHEN (DebitAccNr_acc_nr LIKE ''SAT%'' OR CreditAccNr_acc_nr LIKE ''SAT%'') THEN ''SAT''
																				 WHEN (DebitAccNr_acc_nr LIKE ''3LCM%'' OR CreditAccNr_acc_nr LIKE ''3LCM%'') THEN ''3LCM''
																				 WHEN (DebitAccNr_acc_nr LIKE ''SCB%'' OR CreditAccNr_acc_nr LIKE ''SCB%'') THEN ''SCB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''JBP%'' OR CreditAccNr_acc_nr LIKE ''JBP%'') THEN ''JBP''
																				 WHEN (DebitAccNr_acc_nr LIKE ''RSL%'' OR CreditAccNr_acc_nr LIKE ''RSL%'') THEN ''RSL''
																				 WHEN (DebitAccNr_acc_nr LIKE ''PSH%'' OR CreditAccNr_acc_nr LIKE ''PSH%'') THEN ''PSH''
																				 WHEN (DebitAccNr_acc_nr LIKE ''INF%'' OR CreditAccNr_acc_nr LIKE ''INF%'') THEN ''INF''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UML%'' OR CreditAccNr_acc_nr LIKE ''UML%'') THEN ''UML''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ACCI%'' OR CreditAccNr_acc_nr LIKE ''ACCI%'') THEN ''ACCI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''EKON%'' OR CreditAccNr_acc_nr LIKE ''EKON%'') THEN ''EKON''
																				 WHEN (DebitAccNr_acc_nr LIKE ''ATMC%'' OR CreditAccNr_acc_nr LIKE ''ATMC%'') THEN ''ATMC''
																				 WHEN (DebitAccNr_acc_nr LIKE ''HBC%'' OR CreditAccNr_acc_nr LIKE ''HBC%'') THEN ''HBC''
																	 WHEN (DebitAccNr_acc_nr LIKE ''UNI%'' OR CreditAccNr_acc_nr LIKE ''UNI%'') THEN ''UNI''
																				 WHEN (DebitAccNr_acc_nr LIKE ''UNC%'' OR CreditAccNr_acc_nr LIKE ''UNC%'') THEN ''UNC''
																				 WHEN (DebitAccNr_acc_nr LIKE ''NCS%'' OR CreditAccNr_acc_nr LIKE ''NCS%'') THEN ''NCS'' 
																	 WHEN (DebitAccNr_acc_nr LIKE ''HAG%'' OR CreditAccNr_acc_nr LIKE ''HAG%'') THEN ''HAG''
																	 WHEN (DebitAccNr_acc_nr LIKE ''EXP%'' OR CreditAccNr_acc_nr LIKE ''EXP%'') THEN ''DBL''
																	 WHEN (DebitAccNr_acc_nr LIKE ''FGMB%'' OR CreditAccNr_acc_nr LIKE ''FGMB%'') THEN ''FGMB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CEL%'' OR CreditAccNr_acc_nr LIKE ''CEL%'') THEN ''CEL''
																	 WHEN (DebitAccNr_acc_nr LIKE ''RDY%'' OR CreditAccNr_acc_nr LIKE ''RDY%'') THEN ''RDY''
																	 WHEN (DebitAccNr_acc_nr LIKE ''AMJ%'' OR CreditAccNr_acc_nr LIKE ''AMJ%'') THEN ''AMJU''
																	 WHEN (DebitAccNr_acc_nr LIKE ''CAP%'' OR CreditAccNr_acc_nr LIKE ''CAP%'') THEN ''O3CAP''
																	 WHEN (DebitAccNr_acc_nr LIKE ''VER%'' OR CreditAccNr_acc_nr LIKE ''VER%'') THEN ''VER_GLOBAL''
																	 WHEN (DebitAccNr_acc_nr LIKE ''SMF%'' OR CreditAccNr_acc_nr LIKE ''SMF%'') THEN ''SMFB''
																	 WHEN (DebitAccNr_acc_nr LIKE ''SLT%'' OR CreditAccNr_acc_nr LIKE ''SLT%'') THEN ''SLTD''
																	 WHEN (DebitAccNr_acc_nr LIKE ''JES%'' OR CreditAccNr_acc_nr LIKE ''JES%'') THEN ''JES''
																				 WHEN (DebitAccNr_acc_nr LIKE ''MOU%'' OR CreditAccNr_acc_nr LIKE ''MOU%'') THEN ''MOUA''
																				 WHEN (DebitAccNr_acc_nr LIKE ''MUT%'' OR CreditAccNr_acc_nr LIKE ''MUT%'') THEN ''MUT''
																				 WHEN (DebitAccNr_acc_nr LIKE ''LAV%'' OR CreditAccNr_acc_nr LIKE ''LAV%'') THEN ''LAV''
																				 WHEN (DebitAccNr_acc_nr LIKE ''JUB%'' OR CreditAccNr_acc_nr LIKE ''JUB%'') THEN ''JUB''
																				 WHEN (DebitAccNr_acc_nr LIKE ''WET%'' OR CreditAccNr_acc_nr LIKE ''WET%'') THEN ''WET''
																				 WHEN (DebitAccNr_acc_nr LIKE ''AGH%'' OR CreditAccNr_acc_nr LIKE ''AGH%'') THEN ''AGH''
																				 WHEN (DebitAccNr_acc_nr LIKE ''TRU%'' OR CreditAccNr_acc_nr LIKE ''TRU%'') THEN ''TRU''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CON%'' OR CreditAccNr_acc_nr LIKE ''CON%'') THEN ''CON''
																				 WHEN (DebitAccNr_acc_nr LIKE ''CRU%'' OR CreditAccNr_acc_nr LIKE ''CRU%'') THEN ''CRU''
																				WHEN (DebitAccNr_acc_nr LIKE ''NPR%'' OR CreditAccNr_acc_nr LIKE ''NPR%'') THEN ''NPR''
																				WHEN (DebitAccNr_acc_nr LIKE ''OMO%'' OR CreditAccNr_acc_nr LIKE ''OMO%'') THEN ''OMO''
																				WHEN (DebitAccNr_acc_nr LIKE ''SUN%'' OR CreditAccNr_acc_nr LIKE ''SUN%'') THEN ''SUN''
																				WHEN (DebitAccNr_acc_nr LIKE ''NGB%'' OR CreditAccNr_acc_nr LIKE ''NGB%'') THEN ''NGB''
																				WHEN (DebitAccNr_acc_nr LIKE ''OSC%'' OR CreditAccNr_acc_nr LIKE ''OSC%'') THEN ''OSC''
																				WHEN (DebitAccNr_acc_nr LIKE ''OSP%'' OR CreditAccNr_acc_nr LIKE ''OSP%'') THEN ''OSP''
																				WHEN (DebitAccNr_acc_nr LIKE ''IFIS%'' OR CreditAccNr_acc_nr LIKE ''IFIS%'') THEN ''IFIS''
																				WHEN (DebitAccNr_acc_nr LIKE ''NPM%'' OR CreditAccNr_acc_nr LIKE ''NPM%'') THEN ''NPM''
																				WHEN (DebitAccNr_acc_nr LIKE ''POL%'' OR CreditAccNr_acc_nr LIKE ''POL%'') THEN ''POL''
																				WHEN (DebitAccNr_acc_nr LIKE ''ALV%'' OR CreditAccNr_acc_nr LIKE ''ALV%'') THEN ''ALV''
																				WHEN (DebitAccNr_acc_nr LIKE ''MAY%'' OR CreditAccNr_acc_nr LIKE ''MAY%'') THEN ''MAY''
																				WHEN (DebitAccNr_acc_nr LIKE ''PRO%'' OR CreditAccNr_acc_nr LIKE ''PRO%'') THEN ''PRO''
																				WHEN (DebitAccNr_acc_nr LIKE ''UNIL%'' OR CreditAccNr_acc_nr LIKE ''UNIL%'') THEN ''UNIL''
																				WHEN (DebitAccNr_acc_nr LIKE ''PAR%'' OR CreditAccNr_acc_nr LIKE ''PAR%'') THEN ''PAR''
																				WHEN (DebitAccNr_acc_nr LIKE ''FOR%'' OR CreditAccNr_acc_nr LIKE ''FOR%'') THEN ''FOR''
																					WHEN (DebitAccNr_acc_nr LIKE ''MON%'' OR CreditAccNr_acc_nr LIKE ''MON%'') THEN ''MON''
																					WHEN (DebitAccNr_acc_nr LIKE ''NDI%'' OR CreditAccNr_acc_nr LIKE ''NDI%'') THEN ''NDI''					
																				 WHEN (DebitAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'' OR CreditAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'') THEN ''SCB''
																	 WHEN ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) THEN ''ISW''
																	
																	 ELSE ''UNK''	
																
														END,
															trxn_category=CASE WHEN (PT.PT_tran_type =''01'')  
																					AND dbo.fn_rpt_CardGroup(PT.PTC_PAN) in (''1'',''4'')
																				   AND PT.PTC_source_node_name = ''SWTMEGAsrc''
																				   THEN ''ATM WITHDRAWAL (VERVE INTERNATIONAL)''
														                           
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''50''  then ''MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)''
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''00'' and PT.PTC_source_node_name = ''VTUsrc''  then ''MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)''
														                
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''00'' and PT.PTC_source_node_name <> ''VTUsrc''  and PT.PT_sink_node_name <> ''VTUsnk''
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in (''2'',''5'',''6'')
																				   then ''MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)''
																				   WHEN (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'')
																				   and PT.PT_tran_type =''00'' and PT.PTC_source_node_name <> ''VTUsrc''  and PT.PT_sink_node_name <> ''VTUsnk''
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in (''3'')
																				   then ''MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)''
																					WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
																				   and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
																				   THEN ''ATM WITHDRAWAL (Cardless:Paycode Verve Token)''
														                           
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
																				   and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
																				   THEN ''ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)''
														                           
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PT_sink_node_name = ''ESBCSOUTsnk''
																				   and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 3 
																				   THEN ''ATM WITHDRAWAL (Cardless:Non-Card Generated)''
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr  LIKE ''%ATM%ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%'')
																				   AND PT.PTC_source_node_name <> ''SWTMEGAsrc''
																				   AND PT.PTC_source_node_name <> ''ASPSPNOUsrc''                           
																				   THEN ''ATM WITHDRAWAL (MASTERCARD ISO)''
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PTC_source_node_name <> ''SWTMEGAsrc''
																				   AND PT.PTC_source_node_name <> ''ASPSPNOUsrc''
																				   THEN ''ATM WITHDRAWAL (REGULAR)''
														                           
														                                                                           
														                           
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr LIKE ''%V%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%V%BILLING%'')
																				   AND PT.PTC_source_node_name <> ''SWTMEGAsrc''
																				   THEN ''ATM WITHDRAWAL (VERVE BILLING)''
																				   WHEN (PT.PT_tran_type =''01''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)  IN (''0'',''1''))) 
																				   and (DebitAccNr_acc_nr not LIKE ''%V%BILLING%'' and CreditAccNr_acc_nr not LIKE ''%V%BILLING%'')
																				   AND PT.PTC_source_node_name = ''ASPSPNOUsrc''
																				   THEN ''ATM WITHDRAWAL (SMARTPOINT)''
														 
																				   WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' and 
																				   (DebitAccNr_acc_nr like ''%BILLPAYMENT MCARD%'' or CreditAccNr_acc_nr like ''%BILLPAYMENT MCARD%'') ) then ''BILLPAYMENT MASTERCARD BILLING''
																				   WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' 
																				   and (DebitAccNr_acc_nr like ''%SVA_FEE_RECEIVABLE'' or CreditAccNr_acc_nr like ''%SVA_FEE_RECEIVABLE'') ) 
																				   AND dbo.fn_rpt_isBillpayment_IFIS(PT.PTC_terminal_id) = 1  then ''BILLPAYMENT IFIS REMITTANCE''
														                          
																				   WHEN ( dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'')  then ''BILLPAYMENT''
																	   
																	
																				   WHEN (PT.PT_tran_type =''40''  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= ''1'' 
																				   or SUBSTRING(PT.PTC_terminal_id,1,1)= ''0'' or SUBSTRING(PT.PTC_terminal_id,1,1)= ''4'')) THEN ''CARD HOLDER ACCOUNT TRANSFER''
																				   WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   AND SUBSTRING(PT.PTC_terminal_id,1,1)IN (''2'',''5'',''6'')AND PT.PT_sink_node_name = ''ESBCSOUTsnk'' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
																				   THEN ''POS PURCHASE (Cardless:Paycode Verve Token)''
														                           
																				   WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   AND SUBSTRING(PT.PTC_terminal_id,1,1)IN (''2'',''5'',''6'')AND PT.PT_sink_node_name = ''ESBCSOUTsnk'' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
																				   THEN ''POS PURCHASE (Cardless:Paycode Non-Verve Token)''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''1''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					  or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(GENERAL MERCHANT)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''2''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(CHURCHES, FASTFOODS & NGOS)''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''3''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(CONCESSION)PURCHASE''
																				   WHEN ( dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''4''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(TRAVEL AGENCIES)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''5''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(HOTELS)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''6''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(WHOLESALE)PURCHASE''
														                    
																					WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''14''
																					and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''7''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(FUEL STATION)PURCHASE''
														 
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''8''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(EASYFUEL)PURCHASE''
														                           
																				   WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(TRAVEL AGENCIES-VISA)PURCHASE''
														                     
																				   WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(WHOLESALE CLUBS-VISA)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) =''3''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(GENERAL MERCHANT-VISA)PURCHASE''
														                         
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					  or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(VAS CLOSED SCHEME)PURCHASE''+''_''+PT.PTC_merchant_type
														                              
																					WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''29''
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1 OR PT.PT_tran_type = ''50'')
																					and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																					  or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) THEN ''POS(VAS CLOSED SCHEME)PURCHASE''+''_''+PT.PTC_merchant_type
														                              
														                              
																					  WHEN (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name IN (''SWTWEBEBNsnk'',''SWTWEBUBAsnk'',''SWTWEBGTBsnk'',''SWTWEBABPsnk''))
																					  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																					  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																					  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''
																					  THEN ''WEB(GENERIC)PURCHASE''
														                              
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''9''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) 
																				   THEN ''WEB(GENERIC)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''10''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N200)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''11''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N300)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''12''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N150)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''13''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1.5% CAPPED AT N300)PURCHASE''
														                       
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''15''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB COLLEGES ( 1.5% capped specially at 250)''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''16''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (PROFESSIONAL SERVICES)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''17''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (SECURITY BROKERS/DEALERS)PURCHASE''
														 
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''18''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB (COMMUNICATION)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''19''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N400)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''20''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N250)PURCHASE''
														                  
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''21''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N265)PURCHASE''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''22''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(FLAT FEE OF N550)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''23''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''Verify card – Ecash load''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''24''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''25''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''26''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Payment_Gateway_0.9%)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''27''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Payment_Gateway_1.25%)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''28''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(Verve_Add_Card)PURCHASE''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''30''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(0.75% CAPPED AT 1,000 CATEGORY)PURCHASE''
														                            
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= ''31''
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN ''WEB(1% CAPPED AT N50 CATEGORY)PURCHASE''                     
														                                                      
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')THEN ''POS(GENERAL MERCHANT)PURCHASE'' 
																					 WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')THEN ''POS PURCHASE WITH CASHBACK''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and not (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE''
																				   or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''POS CASHWITHDRAWAL''
														                           
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''14'')
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
																				   WHEN (PT.PT_tran_type = ''50'' and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'')) 
																				   THEN ''Fees collected for all Terminal_owners''
														                           
																				   WHEN (PT.PT_tran_type = ''50'' and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''Fees collected for all PTSPs''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in (''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''14'')
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
																				   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''1''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') 
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = ''2''
																				   and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 
																				   SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																				   and (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'' or CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')) 
																				   THEN ''FEES COLLECTED FOR ALL PTSPs''
																				   WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
																				   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																				   and SUBSTRING(PT.PTC_terminal_id,1,1)= ''3'' THEN ''WEB(GENERIC)PURCHASE''
																				  
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''313'' 
																						 and (DebitAccNr_acc_nr LIKE ''%fee%'' OR CreditAccNr_acc_nr LIKE ''%fee%'')
																						 AND PT.PT_tran_type in (''50'') or(dbo.fn_rpt_autopay_intra_sett (PT.PTC_source_node_name,PT.PT_tran_type,PT.PT_payee) = 1))
																						 and not (DebitAccNr_acc_nr like ''%PREPAIDLOAD%'' or CreditAccNr_acc_nr like ''%PREPAIDLOAD%'') THEN ''AUTOPAY TRANSFER FEES''
														                          
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''313'' 
																						 and (DebitAccNr_acc_nr NOT LIKE ''%fee%'' OR CreditAccNr_acc_nr NOT LIKE ''%fee%'')
																						 and PT.PT_tran_type in (''50'')
																						 and not (DebitAccNr_acc_nr like ''%PREPAIDLOAD%'' or CreditAccNr_acc_nr like ''%PREPAIDLOAD%'')) THEN ''AUTOPAY TRANSFERS''
														                                 
																				  WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																				   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'' and PT.PT_extended_tran_type = ''6011'') THEN ''ATM CARDLESS-TRANSFERS''     
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'') THEN ''ATM TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''2'' and PT.PT_tran_type = ''50'') THEN ''POS TRANSFERS''
														                           
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''4'' and PT.PT_tran_type = ''50'') THEN ''MOBILE TRANSFERS''
																				  WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''35'' and PT.PT_tran_type = ''50'') then ''REMITA TRANSFERS''
														       
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''31'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''32'' and PT.PT_tran_type = ''50'') then ''RELATIONAL TRANSFERS''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''33'' and PT.PT_tran_type = ''50'') then ''SEAMFIX TRANSFERS''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''34'' and PT.PT_tran_type = ''50'') then ''VERVE INTL TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''36'' and PT.PT_tran_type = ''50'') then ''PREPAID CARD UNLOAD''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''37'' and PT.PT_tran_type = ''50'' ) then ''QUICKTELLER TRANSFERS(BANK BRANCH)''
														 
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''38'' and PT.PT_tran_type = ''50'') then ''QUICKTELLER TRANSFERS(SVA)''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''39'' and PT.PT_tran_type = ''50'') then ''SOFTPAY TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''310'' and PT.PT_tran_type = ''50'') then ''OANDO S&T TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''311'' and PT.PT_tran_type = ''50'') then ''UPPERLINK TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''312''  and PT.PT_tran_type = ''50'') then ''QUICKTELLER WEB TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''314''  and PT.PT_tran_type = ''50'') then ''QUICKTELLER MOBILE TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''315'' and PT.PT_tran_type = ''50'') then ''WESTERN UNION MONEY TRANSFERS''
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''316'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS(NON GENERIC PLATFORM)''
														                           
																				   WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																						  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''317'' and PT.PT_tran_type = ''50'') then ''OTHER TRANSFERS(ACCESSBANK PORTAL)''
														                                  
																				   WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
																						 AND (DebitAccNr_acc_nr NOT LIKE ''%AMOUNT%RECEIVABLE'' AND CreditAccNr_acc_nr NOT LIKE ''%AMOUNT%RECEIVABLE'') then ''PREPAID MERCHANDISE''
														                           
																				   WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
																						 AND (DebitAccNr_acc_nr  LIKE ''%AMOUNT%RECEIVABLE'' or CreditAccNr_acc_nr  LIKE ''%AMOUNT%RECEIVABLE'') then ''PREPAID MERCHANDISE DUE ISW''--the unk% is excempted from the bank''s net
														                           
														                                                      
																				  WHEN (dbo.fn_rpt_isCardload (PT.PTC_source_node_name ,PT.PTC_pan, PT.PT_tran_type)= ''1'') then ''PREPAID CARDLOAD''
																				  when PT.PT_tran_type = ''21'' then ''DEPOSIT''
																				  ELSE ''UNK''		
														END,
														  Debit_account_type=CASE 
														                    
																			  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
														                      
																			  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                          
																			   WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''
														                          
																			 WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk''  AND
																			 (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																				THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			   PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                        
																				THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                          
																			   WHEN 
																			   PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																				  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''    
														                        
																			WHEN                      
																			(dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
																				AND  
																			(DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
																				 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
																				 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''     
														                        
																			  WHEN 
																			 PT.PT_sink_node_name = ''SWTWEBUBAsnk''  AND
																			(DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'')
																			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																			 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																			 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
																			 THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''
																			WHEN 
																			 PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
																			 (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
																			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																			 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																			 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
																			 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''    
														                           
														                          
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			 (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''     
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''   
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''   
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)''   
														                        
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)''  
														                      
														                       
														                      
																			  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Debit_Nr)''
																			  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%RECHARGE%FEE%PAYABLE'') THEN ''RECHARGE FEE PAYABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%CO%ACQUIRER%FEE%RECEIVABLE'') THEN ''CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)''   
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%CARDHOLDER%ISSUER%FEE%RECEIVABLE%'') THEN ''CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%SCH%ISSUER%FEE%RECEIVABLE'') THEN ''SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%PAYIN_INSTITUTION_FEE_RECEIVABLE'') THEN ''PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%PAYABLE'') THEN ''ISW FEE PAYABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_CARD_SCHEME%'') THEN ''ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ACQ_%'') THEN ''ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ISS_%'') THEN ''ISW ISSUER FEE RECEIVABLE (Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''1'')
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'')THEN ''ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''2'')
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''3'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''4'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)''
														                           
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''5'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW 3LCM FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''6'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''7'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''8'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)''
														               
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''10'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''9''
																				  AND NOT ((DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')OR (DebitAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN ''ISW FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'')THEN ''FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ATMC%FEE%PAYABLE'') THEN ''ATMC FEE PAYABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%ATMC%FEE%RECEIVABLE'') THEN ''ATMC FEE RECEIVABLE(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Debit_Nr)''  
																				  WHEN (DebitAccNr_acc_nr LIKE ''%EASYFUEL_ACCOUNT'') THEN ''EASYFUEL ACCOUNT(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%YPM%FEE%RECEIVABLE'') THEN ''YPM FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%FLEETTECH%FEE%RECEIVABLE'') THEN ''FLEETTECH FEE RECEIVABLE(Debit_Nr)'' 
																				  WHEN (DebitAccNr_acc_nr LIKE ''%LYSA%FEE%RECEIVABLE'') THEN ''LYSA FEE RECEIVABLE(Debit_Nr)''
														                         
																				  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_FEE_RECEIVABLE'') THEN ''SVA FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%UDIRECT_FEE_RECEIVABLE'') THEN ''UDIRECT FEE RECEIVABLE(Debit_Nr)''
																				  WHEN (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Debit_Nr)''
														                            
																				  WHEN (DebitAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Debit_Nr)''  
																	  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_PAYABLE'') THEN ''SVA SPONSOR FEE PAYABLE(Debit_Nr)''
																	  WHEN (DebitAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_RECEIVABLE'') THEN ''SVA SPONSOR FEE RECEIVABLE(Debit_Nr)''                      
																				  ELSE ''UNK''			
														END,
														  Credit_account_type=CASE  
														  
																			  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				  PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																			  PT.PT_acquiring_inst_id_code <> ''627787'')THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
																			  AND (PT.PTC_source_node_name = ''SWTNCS2src'' AND PT.PT_sink_node_name = ''ASPPOSVINsnk'' and 
																				   PT.PT_acquiring_inst_id_code <> ''627787'') THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''
														                           
																			 WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk''  AND
																			 (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  PT.PT_sink_node_name = ''ASPPOSVISsnk'' AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
														                      
																			  WHEN                      
																		   (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'') 
																				AND  
																			(CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
																				 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''                        
																				 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
														                      
																			  WHEN 
																			  PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'')
																			  and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																			 PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																			 AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
																			THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														        
														 
																		WHEN 
																		   PT.PT_sink_node_name = ''SWTWEBUBAsnk'' AND
																		  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'')
 																		   and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
																		   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = ''1'' and PT.PT_tran_type = ''50'')
																		   AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6''   
																		   THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			 WHEN 
																			 (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'')  AND
																			 (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																				  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                          
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			 THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																				WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPABPsrc'' AND PT.PT_sink_node_name = ''SWTWEBABPsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                       
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPGTBsrc'' AND PT.PT_sink_node_name = ''SWTWEBGTBsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)''    
														                      
																			  WHEN 
																			 (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'')  AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPEBNsrc'' AND PT.PT_sink_node_name = ''SWTWEBEBNsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'')  AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                      
																			  THEN ''VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)''
														                      
																			  WHEN 
																			  (PT.PTC_source_node_name = ''SWTASPWEBsrc'' AND PT.PT_sink_node_name = ''SWTWEBUBAsnk'') AND
																			  (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') 
																			  and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
																			  and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
																			  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = ''6'' 
														                     
																			  THEN ''VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'' 
														                                               
																				  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Credit_Nr)''
																			  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%RECHARGE%FEE%PAYABLE'') THEN ''RECHARGE FEE PAYABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%CO%ACQUIRER%FEE%RECEIVABLE'') THEN ''CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)''   
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%PAYABLE'') THEN ''ISW FEE PAYABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%CARDHOLDER%ISSUER%FEE%RECEIVABLE%'') THEN ''CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%SCH%ISSUER%FEE%RECEIVABLE'') THEN ''SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%PAYIN_INSTITUTION_FEE_RECEIVABLE'') THEN ''PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_CARD_SCHEME%'') THEN ''ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ACQ_%'') THEN ''ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW_ATM_FEE_ISS_%'') THEN ''ISW ISSUER FEE RECEIVABLE (Credit_Nr)''
																				   WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''1'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''2'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''3'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''4'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)''
														                           
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''5'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW 3LCM FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''6'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''7'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''8'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = ''10'') 
																				  and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''0'',''1'') THEN ''ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 
																				  AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= ''9''
																				  AND NOT ((CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN ''ISW FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'')THEN ''FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ATMC%FEE%PAYABLE'') THEN ''ATMC FEE PAYABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%ATMC%FEE%RECEIVABLE'') THEN ''ATMC FEE RECEIVABLE(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Credit_Nr)''  
																				  WHEN (CreditAccNr_acc_nr LIKE ''%EASYFUEL_ACCOUNT'') THEN ''EASYFUEL ACCOUNT(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%YPM%FEE%RECEIVABLE'') THEN ''YPM FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%FLEETTECH%FEE%RECEIVABLE'') THEN ''FLEETTECH FEE RECEIVABLE(Credit_Nr)'' 
																				  WHEN (CreditAccNr_acc_nr LIKE ''%LYSA%FEE%RECEIVABLE'') THEN ''LYSA FEE RECEIVABLE(Credit_Nr)''
														                         
																				  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_FEE_RECEIVABLE'') THEN ''SVA FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%UDIRECT_FEE_RECEIVABLE'') THEN ''UDIRECT FEE RECEIVABLE(Credit_Nr)''
																				  WHEN (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Credit_Nr)''
														                          
																				  WHEN (CreditAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Credit_Nr)'' 
																	  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_RECEIVABLE'') THEN ''SVA SPONSOR FEE RECEIVABLE(Credit_Nr)''
																	  WHEN (CreditAccNr_acc_nr LIKE ''%SVA_SPONSOR_FEE_PAYABLE'') THEN ''SVA SPONSOR FEE PAYABLE(Credit_Nr)''
																				  ELSE ''UNK''			
														END,
															   trxn_amount=ISNULL(J.amount,0),
															trxn_fee=ISNULL(J.fee,0),
															trxn_date=J.business_date,
																currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = ''1'' and 
																				   (DebitAccNr_acc_nr like ''%BILLPAYMENT MCARD%'' or CreditAccNr_acc_nr like ''%BILLPAYMENT MCARD%'') ) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTUBAsnk''))) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM%ISO%ACQUIRER%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%ACQUIRER%'') ) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM_FEE_ACQ_ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM_FEE_ACQ_ISO%'') ) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM%ISO%ISSUER%'' OR CreditAccNr_acc_nr LIKE ''%ATM%ISO%ISSUER%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTPLATsnk''))) THEN ''840''
																				WHEN ((DebitAccNr_acc_nr LIKE ''%ATM_FEE_ISS_ISO%'' OR CreditAccNr_acc_nr LIKE ''%ATM_FEE_ISS_ISO%'') and( PT.PT_sink_node_name not in (''SWTFBPsnk'',''SWTABPsnk'',''SWTIBPsnk'',''SWTPLATsnk''))) THEN ''840''
																				ELSE PT.PT_settle_currency_code END,
																late_reversal = CASE
														        
																				WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
																					   and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																					   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'')
																					   and PT.PTC_merchant_type in (''5371'',''2501'',''2504'',''2505'',''2506'',''2507'',''2508'',''2509'',''2510'',''2511'') THEN 0
														                               
																				WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
																					   and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
																					   and SUBSTRING(PT.PTC_terminal_id,1,1) in ( ''2'',''5'',''6'') THEN 1
																				ELSE 0
																					END,
																card_type =  dbo.fn_rpt_CardGroup(PT.PTC_pan),
																terminal_type = dbo.fn_rpt_terminal_type(PT.PTC_terminal_id),    
																source_node_name =   PT.PTC_source_node_name,
																Unique_key = PT.PT_retrieval_reference_nr+''_''+PT.PT_system_trace_audit_nr+''_''+PT.PTC_terminal_id+''_''+ cast((CONVERT(NUMERIC (15,2),isnull(PT.PT_settle_amount_impact,0))) as VARCHAR(20))+''_''+PT.PT_message_type,
																Acquirer = (case when (not ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) )) then ''''
																			  when ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) AND (pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5)) then acc.bank_code 
																			  else PT.PT_acquiring_inst_id_code END),
																Issuer = (case when (not ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) )) then ''''
																			  when ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) and (substring(PT.PTC_totals_group,1,3) = acc.bank_code1) then acc.bank_code
																			  else substring(PT.PTC_totals_group,1,3) END),
															   Volume = (case when PT.PT_message_type in (''0200'',''0220'') then 1
																			   else 0 end),  
																   Value_RequestedAmount = PT.PT_settle_amount_req,
																   Value_SettleAmount = PT.PT_settle_amount_impact,pt.pt_post_tran_id as ptid ,pt.pt_post_tran_cust_id as ptcid                  
															 ,       index_no = IDENTITY(INT,1,1)
															INTO  ##settle_tran_details 
														 
														 FROM 
														 (select  [adj_id]
															  ,[entry_id]
															  ,[config_set_id]
															  ,[session_id]
															  ,[post_tran_id]
															  ,[post_tran_cust_id]
															  ,[sdi_tran_id]
															  ,[acc_post_id]
															  ,[nt_fee_acc_post_id]
															  ,[coa_id]
															  ,[coa_se_id]
															  ,[se_id]
															  ,[amount]
															  ,[amount_id]
															  ,[amount_value_id]
															  ,[fee]
															  ,[fee_id]
															  ,[fee_value_id]
															  ,[nt_fee]
															  ,[nt_fee_id]
															  ,[nt_fee_value_id]
															  ,[debit_acc_nr_id]
															  ,[debit_acc_id]
															  ,[debit_cardholder_acc_id]
															  ,[debit_cardholder_acc_type]
															  ,[credit_acc_nr_id]
															  ,[credit_acc_id]
															  ,[credit_cardholder_acc_id]
															  ,[credit_cardholder_acc_type]
															  ,[business_date]
															  ,[granularity_element]
															  ,[tag]
															  ,[spay_session_id]
															  ,[spst_session_id]
															  ,[DebitAccNr_config_set_id]
															  ,[DebitAccNr_acc_nr_id]
															  ,[DebitAccNr_se_id]
															  ,[DebitAccNr_acc_id]
															  ,[DebitAccNr_acc_nr]
															  ,[DebitAccNr_aggregation_id]
															  ,[DebitAccNr_state]
															  ,[DebitAccNr_config_state]
															  ,[CreditAccNr_config_set_id]
															  ,[CreditAccNr_acc_nr_id]
															  ,[CreditAccNr_se_id]
															  ,[CreditAccNr_acc_id]
															  ,[CreditAccNr_acc_nr]
															  ,[CreditAccNr_aggregation_id]
															  ,[CreditAccNr_state]
															  ,[CreditAccNr_config_state]
															  ,[Amount_config_set_id]
															  ,[Amount_amount_id]
															  ,[Amount_se_id]
															  ,[Amount_name]
															  ,[Amount_description]
															  ,[Amount_config_state]
															  ,[Fee_config_set_id]
															  ,[Fee_fee_id]
															  ,[Fee_se_id]
															  ,[Fee_name]
															  ,[Fee_description]
															  ,[Fee_type]
															  ,[Fee_amount_id]
															  ,[Fee_config_state]
															  ,[coa_config_set_id]
															  ,[coa_coa_id]
															  ,[coa_name]
															  ,[coa_description]
															  ,[coa_type]
															  ,[coa_config_state] from  ##temp_journal_data_local (NOLOCK)   )J
																			 JOIN 
												 (SELECT * FROM ##temp_post_tran_data_local (NOLOCK) WHERE PT_tran_postilion_originated =0)   PT 
													ON (J.post_tran_id = PT.PT_post_tran_id   and substring(pt.ptc_terminal_id,1,1)!=''G'')
												
																 
																		 	and 
																			
															(
																  (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in (''0200'',''0220''))
															   or ((PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = ''0420'' 
															   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,  PT.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,PT.PTC_totals_group ,PT.ptc_pan) <> 1
																and PT.PT_tran_reversed <> 2)
															   or (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = ''0420'' 
															   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type, pt.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,pt.PTC_totals_group ,pt.PTC_pan) = 1 ))
															   or (PT.PT_settle_amount_rsp<> 0 and PT.PT_message_type   in (''0200'',''0220'') and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1) IN (''0'',''1'') ))
															   or (PT.PT_message_type = ''0420'' and PT.PT_tran_reversed <> 2 and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1)IN ( ''0'',''1'' ))))
														     
															  AND not (pt.PTC_merchant_type in (''4004'',''4722'') and PT.PT_tran_type = ''00'' and pt.PTC_source_node_name not in (''VTUsrc'',''CCLOADsrc'') and  abs(PT.PT_settle_amount_impact/100)< 200
															   and not (DebitAccNr_acc_nr LIKE ''%MCARD%BILLING%'' OR CreditAccNr_acc_nr LIKE ''%MCARD%BILLING%''))
															  AND pt.PTC_totals_group <>''CUPGroup''
															  and NOT (PT.PTC_totals_group in (''VISAGroup'') and PT.PT_acquiring_inst_id_code = ''627787'')
															  and NOT (PT.PTC_totals_group in (''VISAGroup'') and PT.PT_sink_node_name not in (''ASPPOSVINsnk'')
																		and not (pt.ptc_source_node_name in (''SWTFBPsrc'',''SWTUBAsrc'',''SWTZIBsrc'',''SWTPLATsrc'') and PT.PT_sink_node_name = ''ASPPOSVISsnk'') 
																	   )
															 and not (PT.ptc_source_node_name  = ''MEGATPPsrc'' and PT.PT_tran_type = ''00'' ) 														 
															  JOIN 
								  (SELECT  PT_post_tran_id,PT_post_tran_cust_id,ptc_terminal_id,PT_tran_nr, PT_retention_data FROM ##temp_post_tran_data_local (NOLOCK) WHERE PT_tran_postilion_originated =1)PTT 
																ON
																(PT.PT_post_tran_cust_id = PTT.PT_post_tran_cust_id and substring(ptT.ptc_terminal_id,1,1)!=''G'' and PT.PT_tran_nr = PTT.PT_tran_nr)  
														   LEFT OUTER JOIN aid_cbn_code acc ON
														  pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5)
														    OPTION (recompile,optimize for unknown,maxdop 8)
														 ')
															
															EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED IF (OBJECT_ID(''tempdb.dbo.#temp_table'') is not null )begin
														  DROP TABLE #temp_table
														end
														create table #temp_table
														(unique_key VARCHAR(200))
														create nonclustered index ix_temp_table ON #temp_table(
														unique_key
														)
														insert into #temp_table 
														select unique_key from ##settle_tran_details (NOLOCK) where source_node_name in (''SWTASPPOSsrc'',''SWTASGTVLsrc'')
														OPTION(RECOMPILE,optimize for unknown)

														DELETE FROM  ##settle_tran_details WHERE index_no IN (SELECT index_no FROM ##settle_tran_details (NOLOCK) where source_node_name 
						
														 IN (''SWTNCS2src'',''SWTSHOPRTsrc'',''SWTNCSKIMsrc'',''SWTNCSKI2src'',''SWTFBPsrc'',''SWTUBAsrc'',''SWTZIBsrc'',''SWTPLATsrc'') and unique_key IN (SELECT unique_key FROM #temp_table))
')
						EXEC(' SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED	CREATE INDEX ix_settle_tran_details  ON  ##settle_tran_details (
									PTID 
							)
					IF (OBJECT_ID(''tempdb.dbo.##final_results_tables'') IS NOT NULL) BEGIN
					DROP TABLE ##final_results_tables
					END
create index ix_post_tran_id on ##temp_post_tran_data_local(
PT_post_tran_id
)SELECT  report_results.bank_code,
			 report_results.trxn_category,
			 report_results.Debit_account_type,
			 report_results.Credit_account_type,
			 report_results.trxn_amount,
			 report_results.trxn_fee,
			 report_results.trxn_date,
			 report_results.currency,
			 report_results.late_reversal,
			 report_results.card_type,
			 terminal_type,
			 report_results.source_node_name,
			 report_results.Unique_key,
			 report_results.Acquirer,
			 report_results.Issuer,
			 report_results.Volume,
			 report_results.Value_RequestedAmount,
			 report_results.Value_SettleAmount,
			 report_results.ptid,
			 report_results.ptcid,
			 report_results.index_no
			 ,(SELECT  TOP  1   pt.[PT_post_tran_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID ) 		post_tran_id_1
			 ,(SELECT  TOP  1   pt.[PT_post_tran_cust_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )  		post_tran_cust_id_1
			 ,(SELECT  TOP  1   [PT_settle_entity_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_entity_id
			 ,(SELECT  TOP  1   [PT_batch_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_batch_nrS
			 ,(SELECT  TOP  1   [PT_prev_post_tran_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_prev_post_tran_id
			 ,(SELECT  TOP  1   [PT_next_post_tran_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_next_post_tran_id
			 ,(SELECT  TOP  1   [PT_sink_node_name]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_sink_node_name
			 ,(SELECT  TOP  1   [PT_tran_postilion_originated]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_tran_postilion_originated
			 ,(SELECT  TOP  1   [PT_tran_completed]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_completed
			 ,(SELECT  TOP  1   [PT_message_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_message_type
			 ,(SELECT  TOP  1   [PT_tran_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_type
			 ,(SELECT  TOP  1   [PT_tran_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )				PT_tran_nr
			 ,(SELECT  TOP  1   [PT_system_trace_audit_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_system_trace_audit_nr
			 ,(SELECT  TOP  1   [PT_rsp_code_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_rsp_code_req
			 ,(SELECT  TOP  1   [PT_rsp_code_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_rsp_code_rsp
			 ,(SELECT  TOP  1   [PT_abort_rsp_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_abort_rsp_code
			 ,(SELECT  TOP  1   [PT_auth_id_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_auth_id_rsp
			 ,(SELECT  TOP  1   [PT_auth_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_auth_type
			 ,(SELECT  TOP  1   [PT_auth_reason]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_auth_reason
			 ,(SELECT  TOP  1   [PT_retention_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_retention_data
			 ,(SELECT  TOP  1   [PT_acquiring_inst_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_acquiring_inst_id_code
			 ,(SELECT  TOP  1   [PT_message_reason_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_message_reason_code
			 ,(SELECT  TOP  1   [PT_sponsor_bank]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_sponsor_bank
			 ,(SELECT  TOP  1   [PT_retrieval_reference_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_retrieval_reference_nr
			 ,(SELECT  TOP  1   [PT_datetime_tran_gmt]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_datetime_tran_gmt
			 ,(SELECT  TOP  1   [PT_datetime_tran_local]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_datetime_tran_local
			 ,(SELECT  TOP  1   [PT_datetime_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_datetime_req
			 ,(SELECT  TOP  1   [PT_datetime_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_datetime_rsp
			 ,(SELECT  TOP  1   [PT_realtime_business_date]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_realtime_business_date
			 ,(SELECT  TOP  1   [PT_recon_business_date]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_recon_business_date
			 ,(SELECT  TOP  1   [PT_from_account_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_from_account_type
			 ,(SELECT  TOP  1   [PT_to_account_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_to_account_type
			 ,(SELECT  TOP  1   [PT_from_account_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_from_account_id
			 ,(SELECT  TOP  1   [PT_to_account_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_to_account_id
			 ,(SELECT  TOP  1   [PT_tran_amount_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_amount_req
			 ,(SELECT  TOP  1   [PT_tran_amount_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_amount_rsp
			 ,(SELECT  TOP  1   [PT_settle_amount_impact]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_amount_impact
			 ,(SELECT  TOP  1   [PT_tran_cash_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_cash_req
			 ,(SELECT  TOP  1   [PT_tran_cash_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_cash_rsp
			 ,(SELECT  TOP  1   [PT_tran_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_currency_code
			 ,(SELECT  TOP  1   [PT_tran_tran_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_tran_fee_req
			 ,(SELECT  TOP  1   [PT_tran_tran_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_tran_fee_rsp
			 ,(SELECT  TOP  1   [PT_tran_tran_fee_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_tran_tran_fee_currency_code
			 ,(SELECT  TOP  1   [PT_tran_proc_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_proc_fee_req
			 ,(SELECT  TOP  1   [PT_tran_proc_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_tran_proc_fee_rsp
			 ,(SELECT  TOP  1   [PT_tran_proc_fee_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_tran_proc_fee_currency_code
			 ,(SELECT  TOP  1   [PT_settle_amount_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_amount_req
			 ,(SELECT  TOP  1   [PT_settle_amount_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_amount_rsp
			 ,(SELECT  TOP  1   [PT_settle_cash_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_settle_cash_req
			 ,(SELECT  TOP  1   [PT_settle_cash_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_settle_cash_rsp
			 ,(SELECT  TOP  1   [PT_settle_tran_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_tran_fee_req
			 ,(SELECT  TOP  1   [PT_settle_tran_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_tran_fee_rsp
			 ,(SELECT  TOP  1   [PT_settle_proc_fee_req]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_proc_fee_req
			 ,(SELECT  TOP  1   [PT_settle_proc_fee_rsp]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_proc_fee_rsp
			 ,(SELECT  TOP  1   [PT_settle_currency_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_settle_currency_code
			 ,(SELECT  TOP  1   [PT_pos_entry_mode]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_pos_entry_mode
			 ,(SELECT  TOP  1   [PT_pos_condition_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_pos_condition_code
			 ,(SELECT  TOP  1   [PT_additional_rsp_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_additional_rsp_data
			 ,(SELECT  TOP  1   [PT_tran_reversed]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_tran_reversed
			 ,(SELECT  TOP  1   [PT_prev_tran_approved]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_prev_tran_approved
			 ,(SELECT  TOP  1   [PT_issuer_network_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_issuer_network_id
			 ,(SELECT  TOP  1   [PT_acquirer_network_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_acquirer_network_id
			 ,(SELECT  TOP  1   [PT_extended_tran_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_extended_tran_type
			 ,(SELECT  TOP  1   [PT_from_account_type_qualifier]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_from_account_type_qualifier
			 ,(SELECT  TOP  1   [PT_to_account_type_qualifier]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_to_account_type_qualifier
			 ,(SELECT  TOP  1   [PT_bank_details]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_bank_details
			 ,(SELECT  TOP  1   [PT_payee]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )				PT_payee
			 ,(SELECT  TOP  1   [PT_card_verification_result]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_card_verification_result
			 ,(SELECT  TOP  1   [PT_online_system_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_online_system_id
			 ,(SELECT  TOP  1   [PT_participant_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_participant_id
			 ,(SELECT  TOP  1   [PT_opp_participant_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_opp_participant_id
			 ,(SELECT  TOP  1   [PT_receiving_inst_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_receiving_inst_id_code
			 ,(SELECT  TOP  1   [PT_routing_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_routing_type
			 ,(SELECT  TOP  1   [PT_pt_pos_operating_environment]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_operating_environment
			 ,(SELECT  TOP  1   [PT_pt_pos_card_input_mode]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_pt_pos_card_input_mode
			 ,(SELECT  TOP  1   [PT_pt_pos_cardholder_auth_method]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_cardholder_auth_method
			 ,(SELECT  TOP  1   [PT_pt_pos_pin_capture_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_pin_capture_ability
			 ,(SELECT  TOP  1   [PT_pt_pos_terminal_operator]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PT_pt_pos_terminal_operator
			 ,(SELECT  TOP  1   [PT_source_node_key]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PT_source_node_key
			 ,(SELECT  TOP  1   [PT_proc_online_system_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PT_proc_online_system_id
			 ,(SELECT  TOP  1   [PTC_post_tran_cust_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_post_tran_cust_id
			 ,(SELECT  TOP  1   [PTC_source_node_name]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_source_node_name
			 ,(SELECT  TOP  1   [PTC_draft_capture]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_draft_capture
			 ,(SELECT  TOP  1   [PTC_pan]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )				PTC_pan
			 ,(SELECT  TOP  1   [PTC_card_seq_nr]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_card_seq_nr
			 ,(SELECT  TOP  1   [PTC_expiry_date]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_expiry_date
			 ,(SELECT  TOP  1   [PTC_service_restriction_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_service_restriction_code
			 ,(SELECT  TOP  1   [PTC_terminal_id]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_terminal_id
			 ,(SELECT  TOP  1   [PTC_terminal_owner]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_terminal_owner
			 ,(SELECT  TOP  1   [PTC_card_acceptor_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_card_acceptor_id_code
			 ,(SELECT  TOP  1   [PTC_mapped_card_acceptor_id_code]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_mapped_card_acceptor_id_code
			 ,(SELECT  TOP  1   [PTC_merchant_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_merchant_type
			 ,(SELECT  TOP  1   [PTC_card_acceptor_name_loc]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_card_acceptor_name_loc
			 ,(SELECT  TOP  1   [PTC_address_verification_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_address_verification_data
			 ,(SELECT  TOP  1   [PTC_address_verification_result]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_address_verification_result
			 ,(SELECT  TOP  1   [PTC_check_data]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_check_data
			 ,(SELECT  TOP  1   [PTC_totals_group]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_totals_group
			 ,(SELECT  TOP  1   [PTC_card_product]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_card_product
			 ,(SELECT  TOP  1   [PTC_pos_card_data_input_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_data_input_ability
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_auth_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_cardholder_auth_ability
			 ,(SELECT  TOP  1   [PTC_pos_card_capture_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_capture_ability
			 ,(SELECT  TOP  1   [PTC_pos_operating_environment]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_operating_environment
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_present]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_cardholder_present
			 ,(SELECT  TOP  1   [PTC_pos_card_present]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_card_present
			 ,(SELECT  TOP  1   [PTC_pos_card_data_input_mode]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_data_input_mode
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_auth_method]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_cardholder_auth_method
			 ,(SELECT  TOP  1   [PTC_pos_cardholder_auth_entity]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_cardholder_auth_entity
			 ,(SELECT  TOP  1   [PTC_pos_card_data_output_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_card_data_output_ability
			 ,(SELECT  TOP  1   [PTC_pos_terminal_output_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_terminal_output_ability
			 ,(SELECT  TOP  1   [PTC_pos_pin_capture_ability]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )	PTC_pos_pin_capture_ability
			 ,(SELECT  TOP  1   [PTC_pos_terminal_operator]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_terminal_operator
			 ,(SELECT  TOP  1   [PTC_pos_terminal_type]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )		PTC_pos_terminal_type
			 ,(SELECT  TOP  1   [PTC_pan_search]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_pan_search
			 ,(SELECT  TOP  1   [PTC_pan_encrypted]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_pan_encrypted
			 ,(SELECT  TOP  1   [PTC_pan_reference]  FROM   ##temp_post_tran_data_local PT  (nolock, INDEX(ix_post_tran_id)) WHERE  PT.PT_post_tran_id = report_results.PTID )			PTC_pan_reference
			   ,(SELECT TOP 1   PTSP_Account_Nr FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id)   PTSP_Account_Nr
			 ,(SELECT TOP 1   ptsp_code FROM  tbl_PTSP PTSP (nolock) where  PTT.PTC_terminal_id = PTSP.terminal_id)  ptsp_code
			 , (SELECT TOP 1   pa.PTSP_Code FROM  tbl_PTSP_Account PA(nolock) join  tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id )   account_PTSP_Code
			 ,(SELECT TOP 1   PTSP_Name FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id)    PTSP_Name
			 ,(SELECT TOP 1   rdm_amt FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)    rdm_amt
			 ,(SELECT TOP 1   Reward_Code FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)       Reward_Code
			 ,(SELECT TOP 1   Reward_discount FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     Reward_discount
			 ,(SELECT TOP 1   rr_number FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)  rr_number
			 ,(SELECT TOP  1 sdi_tran_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)     sdi_tran_id
			 ,(SELECT TOP  1 se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)        se_id
			 ,(SELECT TOP  1 session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id) session_id
			 ,(SELECT TOP 1   SORT_CODE FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PTT.PTC_terminal_id = PTSP.terminal_id)    Sort_Code
			 ,(SELECT TOP  1 spay_session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)  spay_session_id
			 ,(SELECT TOP  1 spst_session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			 
			  spst_session_id
			 ,(SELECT TOP 1   stan FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													) stan
			 ,(SELECT TOP  1 tag FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         tag
			 , (SELECT TOP 1   terminal_id FROM  tbl_PTSP PTSP (nolock) where  PTT.PTC_terminal_id = PTSP.terminal_id)      ptsp_terminal_id
			 ,(SELECT TOP 1   Y.terminal_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)	reward_terminal_id
			 	,(SELECT TOP 1   terminal_mode FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  ) terminal_mode
			 ,(SELECT TOP 1   Y.trans_date FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code) trans_date
			 ,(SELECT TOP 1   Y.txn_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     txn_id
			 ,(SELECT TOP 1   mer.category_code FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code)web_category_code
			 ,(SELECT TOP 1   mer.category_name FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code ) web_category_name
			 , (SELECT TOP 1   mer.fee_type FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )  web_fee_type
			 , (SELECT TOP 1   mer.merchant_disc FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )   web_merchant_disc
			 ,(SELECT TOP 1   mer.amount_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )    web_amount_cap
			 ,(SELECT TOP 1   mer.fee_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )     web_fee_cap
			 , (SELECT TOP 1   mer.bearer FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PTT.PTC_merchant_type = mer.category_code )     web_bearer
			 , (SELECT TOP 1   ow.terminal_id FROM  tbl_terminal_owner ow (nolock) WHERE PTT.PTC_terminal_id = ow.terminal_id  )   owner_terminal_id
			 ,(SELECT TOP 1   ow.Terminal_code FROM  tbl_terminal_owner ow (nolock) WHERE PTT.PTC_terminal_id = ow.terminal_id  )  owner_terminal_code
			 ,(SELECT TOP  1 acc_post_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			  acc_post_id
			 ,(SELECT TOP 1   Account_Name FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			       Account_Name
			 ,(SELECT TOP 1   account_nr FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			   account_nr
			 ,(SELECT TOP 1 acquirer_inst_id1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id1
			 ,(SELECT TOP 1 acquirer_inst_id2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id2
			 ,(SELECT TOP 1 acquirer_inst_id3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id3
			 ,(SELECT TOP 1 acquirer_inst_id4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id4
			 ,(SELECT TOP 1 acquirer_inst_id5 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id5
			 ,(SELECT TOP 1   Acquiring_bank FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			      Acquiring_bank
			 ,(SELECT TOP 1   acquiring_inst_id_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													) acquiring_inst_id_code
			 ,(SELECT TOP 1   Addit_charge FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     Addit_charge
			 ,(SELECT TOP 1   Addit_party FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)        Addit_party
			 ,(SELECT TOP  1 adj_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       adj_id
			 ,(SELECT TOP  1 amount FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      journal_amount
			 ,(SELECT TOP 1    amount FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)  xls_amount
			 ,(SELECT TOP  1 Amount_amount_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			     Amount_amount_id
			 ,(SELECT TOP 1   m.Amount_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)     merch_cat_amount_cap
			 ,(SELECT TOP 1   s.amount_cap FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )    merch_cat_visa_amount_cap
			 ,(SELECT TOP 1   r.amount_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)    reward_amount_cap
			 ,(SELECT TOP  1 Amount_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      Amount_config_set_id
			 ,(SELECT TOP  1 Amount_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         Amount_config_state
			 ,(SELECT TOP  1 Amount_description FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			             Amount_description
			 ,(SELECT TOP  1 amount_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			              amount_id
			 ,(SELECT TOP  1 Amount_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  Amount_name
			 ,(SELECT TOP  1 Amount_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                      Amount_se_id
			 ,(SELECT TOP  1 amount_value_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                      amount_value_id
			 ,(SELECT TOP 1   Authorized_Person FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			        Authorized_Person
			 ,(SELECT TOP 1 BANK_CODE FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						
			 	  ACC_BANK_CODE
			 ,(SELECT TOP 1 bank_code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       BANK_CODE1
			 ,(SELECT TOP 1 BANK_INSTITUTION_NAME FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)				  BANK_INSTITUTION_NAME
			 ,(SELECT TOP 1   m.bearer FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)  merch_cat_bearer
			 ,(SELECT TOP 1   s.bearer FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )  merch_cat_visa_bearer
			 ,(SELECT TOP  1 business_date FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       business_date
			 ,(SELECT TOP 1   card_acceptor_id_code FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			    card_acceptor_id_code
			 ,(SELECT TOP 1   PTc_card_acceptor_name_loc FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			     card_acceptor_name_loc
			 ,(SELECT TOP 1   cashier_acct FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)     cashier_acct
			 ,(SELECT TOP 1   cashier_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)       cashier_code
			 ,(SELECT TOP 1   cashier_ext_trans_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)   cashier_ext_trans_code
			 ,(SELECT TOP 1   cashier_name FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)      cashier_name
			 ,(SELECT TOP 1   s.category_code FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )   merch_cat_visa_category_code
			 , (SELECT TOP 1   m.Category_Code FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)  merch_cat_category_code
			 ,(SELECT TOP 1   s.category_name FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )  merch_cat_visa_category_name
			 ,(SELECT TOP 1   m.Category_name FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)   merch_cat_category_name
			 ,(SELECT TOP 1 CBN_Code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       CBN_Code1
			 ,(SELECT TOP 1 CBN_Code2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)			  CBN_Code2
			 ,(SELECT TOP 1 CBN_Code3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)  CBN_Code3
			 ,(SELECT TOP 1 CBN_Code4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PTT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)	  CBN_Code4
			 ,(SELECT TOP  1 coa_coa_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			   coa_coa_id
			 ,(SELECT TOP  1 coa_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      coa_config_set_id
			 ,(SELECT TOP  1 coa_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			     coa_config_state
			 ,(SELECT TOP  1 coa_description FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      coa_description
			 ,(SELECT TOP  1 coa_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         coa_id
			 ,(SELECT TOP  1 coa_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         coa_name
			 ,(SELECT TOP  1 coa_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       coa_se_id
			 ,(SELECT TOP  1 coa_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       coa_type
			 ,(SELECT TOP  1 config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			        config_set_id
			 ,(SELECT TOP  1 credit_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       credit_acc_id
			 ,(SELECT TOP  1 credit_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      credit_acc_nr_id
			 ,(SELECT TOP  1 credit_cardholder_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       credit_cardholder_acc_id
			 ,(SELECT TOP  1 credit_cardholder_acc_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       credit_cardholder_acc_type
			 ,(SELECT TOP  1 CreditAccNr_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			          CreditAccNr_acc_id
			 ,(SELECT TOP  1 CreditAccNr_acc_nr FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         CreditAccNr_acc_nr
			 ,(SELECT TOP  1 CreditAccNr_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			      CreditAccNr_acc_nr_id
			 ,(SELECT TOP  1 CreditAccNr_aggregation_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       CreditAccNr_aggregation_id
			 ,(SELECT TOP  1 CreditAccNr_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       CreditAccNr_config_set_id
			 ,(SELECT TOP  1 CreditAccNr_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			            CreditAccNr_config_state
			 ,(SELECT TOP  1 CreditAccNr_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			            CreditAccNr_se_id
			 ,(SELECT TOP  1 CreditAccNr_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			             CreditAccNr_state
			 ,(SELECT TOP 1   Date_Modified FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PTT.PTC_merchant_type  = s.category_code AND PTT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			      Date_Modified
			 ,(SELECT TOP  1 debit_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			               debit_acc_id
			 ,(SELECT TOP  1 debit_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			           debit_acc_nr_id
			 ,(SELECT TOP  1 debit_cardholder_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			             debit_cardholder_acc_id
			 ,(SELECT TOP  1 debit_cardholder_acc_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                debit_cardholder_acc_type
			 ,(SELECT TOP  1 DebitAccNr_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         DebitAccNr_acc_id
			 ,(SELECT TOP  1 DebitAccNr_acc_nr FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         DebitAccNr_acc_nr
			 ,(SELECT TOP  1 DebitAccNr_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			           DebitAccNr_acc_nr_id
			 ,(SELECT TOP  1 DebitAccNr_aggregation_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			              DebitAccNr_aggregation_id
			 ,(SELECT TOP  1 DebitAccNr_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_config_set_id
			 ,(SELECT TOP  1 DebitAccNr_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_config_state
			 ,(SELECT TOP  1 DebitAccNr_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_se_id
			 ,(SELECT TOP  1 DebitAccNr_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  DebitAccNr_state
			 ,(SELECT TOP  1 entry_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                   entry_id
			 ,(SELECT TOP 1   extended_trans_type FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)    extended_trans_type
			 ,(SELECT TOP  1 fee FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			               fee
			 ,(SELECT TOP  1 Fee_amount_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  Fee_amount_id
			 , (SELECT TOP 1   m.Fee_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code)   merch_cat_fee_cap
			 ,(SELECT TOP 1   s.Fee_Cap  FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code ) merch_cat_visa_fee_cap
			 ,(SELECT TOP 1   r.fee_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code) reward_fee_cap
			    ,        (SELECT TOP  1 Fee_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			 Fee_config_set_id
			 ,(SELECT TOP  1 Fee_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			  Fee_config_state
			 ,(SELECT TOP  1 Fee_description FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			    Fee_description
			 ,(SELECT TOP 1   Fee_Discount FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)     Fee_Discount
			 ,(SELECT TOP  1 Fee_fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			   Fee_fee_id
			 ,(SELECT TOP  1 fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			       fee_id
			 ,(SELECT TOP  1 Fee_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			         Fee_name
			 ,(SELECT TOP  1 Fee_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			          Fee_se_id
			 ,(SELECT TOP 1   m.fee_type FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code) merch_cat_category_fee_type
			 ,(SELECT TOP 1   s.fee_type FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code ) merch_cat_category_visa_fee_type
			 , (SELECT TOP  1 Fee_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			          journal_fee_type
			 ,(SELECT TOP  1 fee_value_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			              fee_value_id
			 ,(SELECT TOP  1 granularity_element FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			     granularity_element
			 ,(SELECT TOP 1   m.Merchant_Disc FROM tbl_merchant_category m (NOLOCK) WHERE PTT.PTC_merchant_type = m.category_code) merch_cat_category_merch_discount
			 ,(SELECT TOP 1   s.Merchant_Disc FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PTT.PTC_merchant_type  = s.category_code )  merch_cat_category_visa_merch_discount
			 ,(SELECT TOP 1   merchant_id FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)       merchant_id
			 ,(SELECT TOP 1   merchant_type FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)    merchant_type
			 ,(SELECT TOP  1 nt_fee FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			            nt_fee
			 ,(SELECT TOP  1 nt_fee_acc_post_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                nt_fee_acc_post_id
			 ,(SELECT TOP  1 nt_fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                 nt_fee_id
			 ,(SELECT TOP  1 nt_fee_value_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PTT.PT_post_tran_id AND J.post_tran_cust_id = PTT.PT_post_tran_cust_id)
			                  nt_fee_value_id
			 ,(SELECT TOP 1   pan FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PTT.PTC_terminal_id= y.terminal_id  AND PTT.PT_retrieval_reference_nr = y.rr_number   
			 													            AND (-1 * PTT.PT_settle_amount_impact)/100 = y.amount
			 																AND substring (CAST (PTT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			 																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
			 													)Y ON y.extended_trans_type = r.reward_code)  pan
			 INTO ##final_results_tables  
			   FROM 
			 						     ##settle_tran_details report_results 
										 (nolock) join ##temp_post_tran_data_local PTT (nolock)  ON   PTT.PT_post_tran_id = report_results.PTID
			 						OPTION(RECOMPILE,optimize for unknown, MAXDOP 8)
			 				
				
				INSERT INTO postilion_office.dbo.['+@table_name+'] SELECT DISTINCT *,post_tran_id_1,post_tran_cust_id_1 FROM  ##final_results_tables;											 
															 
															 ');
			EXEC('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED IF (OBJECT_ID(''tempdb.dbo.##settle_tran_details'') IS NOT NULL) BEGIN
					DROP TABLE ##settle_tran_details
					END
					
					IF (OBJECT_ID(''tempdb.dbo.##final_results_tables'') IS NOT NULL) BEGIN
					DROP TABLE ##final_results_tables
					END
					
					IF (OBJECT_ID(''tempdb.dbo.##temp_journal_data_local'') IS NOT NULL) BEGIN
					DROP TABLE ##temp_journal_data_local
					END
					
					IF (OBJECT_ID(''tempdb.dbo.##temp_post_tran_data_local'') IS NOT NULL) BEGIN
					DROP TABLE ##temp_post_tran_data_local
					END
			');
											
														
		END


