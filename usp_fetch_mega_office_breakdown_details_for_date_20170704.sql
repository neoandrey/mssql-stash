USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_fetch_mega_office_breakdown_details_for_date]    Script Date: 07/04/2017 09:40:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_fetch_mega_office_breakdown_details_for_date]   (
@settlement_date VARCHAR(20)
)

as

	begin

		DECLARE @settle_date varchar(20)

		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		SET @settle_date   = ISNULL(@settlement_date, dateadd(d,-1, getdate()))

		SET @settle_date   =  replace(convert(varchar(10),@settle_date,112),'-','')

		DECLARE @retention_period INT 				
		DECLARE @delete_date NVARCHAR(MAX);
		DECLARE @delete_table_name VARCHAR(MAX);


		SELECT @retention_period = ISNULL(@retention_period,3)
		SET @retention_period = -1*@retention_period;
		SELECT @delete_date = CONVERT(VARCHAR(10),DATEADD(DAY, @retention_period, GETDATE()),112);

		SET @delete_table_name  = 'post_settle_tran_details_mega_'+ @delete_date;

		EXEC ('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'''+@delete_table_name+''') AND type in (N''U'')) BEGIN DROP TABLE [dbo].['+@delete_table_name+'] END');

		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_settle_tran_details_mega_'+@settle_date+']') AND type in (N'U')) begin
		declare @sql_statement varchar(2000)
		set @sql_statement = 'DROP TABLE [dbo].[post_settle_tran_details_mega_'+@settle_date+']'
		exec (@sql_statement)
		end



				EXEC('
				SELECT 
				acc_post_id acc_post_id
				,0 Account_Name
				,account_nr account_nr
				,(SELECT  TOP 1 acquirer_inst_id1  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) ) acquirer_inst_id1
				,(SELECT  TOP 1 acquirer_inst_id2  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )      acquirer_inst_id2
				,(SELECT  TOP 1 acquirer_inst_id3  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )      acquirer_inst_id3
				,(SELECT  TOP 1 acquirer_inst_id4  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )      acquirer_inst_id4
				,(SELECT  TOP 1 acquirer_inst_id5  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )      acquirer_inst_id5
				,Acquiring_bank   Acquiring_ban
				,0 acquiring_inst_id_code--acquiring_inst_id_code acquiring_inst_id_code
				,0 Addit_charge--Addit_charge     Addit_charge
				,0 Addit_party--Addit_party      Addit_party
				,adj_id     adj_id
				,j.amount   journal_amount
				,0  xls_amount--y.amount   xls_amount
				,Amount_amount_id Amount_amount_id
				,m.Amount_Cap     merch_cat_amount_cap
				,s.Amount_Cap     merch_cat_visa_amount_cap
				,0 reward_amount_cap--R.Amount_Cap     reward_amount_cap
				,Amount_config_set_id   Amount_config_set_id
				,Amount_config_state    Amount_config_state
				,Amount_description     Amount_description
				,amount_id  amount_id
				,Amount_name      Amount_name
				,Amount_se_id     Amount_se_id
				,amount_value_id  amount_value_id
				,0 Authorized_Person--Authorized_Person      Authorized_Person
				,(SELECT  TOP 1 bank_code  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )ACC_BANK_CODE
				,(SELECT  TOP 1 bank_code1  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) ) BANK_CODE1
				,(SELECT  TOP 1 BANK_INSTITUTION_NAME  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )  BANK_INSTITUTION_NAME
				,m.Bearer   merch_cat_bearer
				,s.Bearer   merch_cat_visa_bearer
				,business_date    business_date
				,card_acceptor_id_code  card_acceptor_id_code
				,0 card_acceptor_name_loc--card_acceptor_name_loc card_acceptor_name_loc
				,0 cashier_acct--cashier_acct     cashier_acct
				,0 cashier_code--cashier_code     cashier_code
				,0 cashier_ext_trans_code--cashier_ext_trans_code cashier_ext_trans_code
				,0 cashier_name--cashier_name     cashier_name
				,s.Category_Code    merch_cat_visa_category_code
				,m.Category_Code  merch_cat_category_code
				,s.Category_name  merch_cat_visa_category_name
				,m.Category_name  merch_cat_category_name
				,(SELECT  TOP 1 CBN_Code1  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )  CBN_Code1
				,(SELECT  TOP 1 CBN_Code2  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )  CBN_Code2
				,(SELECT  TOP 1 CBN_Code3  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )  CBN_Code3
				,(SELECT  TOP 1 CBN_Code4  FROM  aid_cbn_code (nolock) WHERE pt.PT_acquiring_inst_id_code  IN ( SELECT COALESCE(acquirer_inst_id1,acquirer_inst_id2,acquirer_inst_id3,acquirer_inst_id4,acquirer_inst_id5) from aid_cbn_code (nolock)) )  CBN_Code4
				,coa_coa_id coa_coa_id
				,coa_config_set_id      coa_config_set_id
				,coa_config_state coa_config_state
				,coa_description  coa_description
				,coa_id     coa_id
				,coa_name   coa_name
				,coa_se_id  coa_se_id
				,coa_type   coa_type
				,config_set_id    config_set_id
				,credit_acc_id    credit_acc_id
				,credit_acc_nr_id credit_acc_nr_id
				,credit_cardholder_acc_id     credit_cardholder_acc_id
				,credit_cardholder_acc_type   credit_cardholder_acc_type
				,CreditAccNr_acc_id     CreditAccNr_acc_id
				,CreditAccNr_acc_nr     CreditAccNr_acc_nr
				,CreditAccNr_acc_nr_id  CreditAccNr_acc_nr_id
				,CreditAccNr_aggregation_id   CreditAccNr_aggregation_id
				,CreditAccNr_config_set_id    CreditAccNr_config_set_id
				,CreditAccNr_config_state     CreditAccNr_config_state
				,CreditAccNr_se_id      CreditAccNr_se_id
				,CreditAccNr_state      CreditAccNr_state
				,0 Date_Modified--Date_Modified    Date_Modified
				,debit_acc_id     debit_acc_id
				,debit_acc_nr_id  debit_acc_nr_id
				,debit_cardholder_acc_id      debit_cardholder_acc_id
				,debit_cardholder_acc_type    debit_cardholder_acc_type
				,DebitAccNr_acc_id      DebitAccNr_acc_id
				,DebitAccNr_acc_nr      DebitAccNr_acc_nr
				,DebitAccNr_acc_nr_id   DebitAccNr_acc_nr_id
				,DebitAccNr_aggregation_id    DebitAccNr_aggregation_id
				,DebitAccNr_config_set_id     DebitAccNr_config_set_id
				,DebitAccNr_config_state      DebitAccNr_config_state
				,DebitAccNr_se_id DebitAccNr_se_id
				,DebitAccNr_state DebitAccNr_state
				,entry_id   entry_id
				,0 extended_trans_type--extended_trans_type    extended_trans_type
				,fee  fee
				,Fee_amount_id    Fee_amount_id
				,m.Fee_Cap  merch_cat_fee_cap
				,s.Fee_Cap  merch_cat_visa_fee_cap
				,0 reward_fee_cap--r.Fee_Cap  reward_fee_cap
				,Fee_config_set_id      Fee_config_set_id
				,Fee_config_state Fee_config_state
				,Fee_description  Fee_description
				,0 Fee_Discount--Fee_Discount     Fee_Discount
				,Fee_fee_id Fee_fee_id
				,fee_id     fee_id
				,Fee_name   Fee_name
				,Fee_se_id  Fee_se_id
				,m.Fee_type merch_cat_category_fee_type
				,s.Fee_type merch_cat_category_visa_fee_type
				,j.Fee_type journal_fee_type
				,fee_value_id     fee_value_id
				,granularity_element    granularity_element
				,m.Merchant_Disc  merch_cat_category_merch_discount
				,s.Merchant_Disc  merch_cat_category_visa_merch_discount
				,0 merchant_id--merchant_id      merchant_id
				,0 merchant_type--merchant_type    merchant_type
				,nt_fee     nt_fee
				,nt_fee_acc_post_id     nt_fee_acc_post_id
				,nt_fee_id  nt_fee_id
				,nt_fee_value_id  nt_fee_value_id
				,0 pan--pan  pan
				,post_tran_cust_id      post_tran_cust_id
				,post_tran_id     post_tran_id
				,PT_abort_rsp_code      PT_abort_rsp_code
				,PT_acquirer_network_id PT_acquirer_network_id
				,PT_acquiring_inst_id_code    PT_acquiring_inst_id_code
				,PT_additional_rsp_data PT_additional_rsp_data
				,PT_auth_id_rsp   PT_auth_id_rsp
				,PT_auth_reason   PT_auth_reason
				,PT_auth_type     PT_auth_type
				,PT_bank_details  PT_bank_details
				,PT_batch_nr      PT_batch_nr
				,PT_card_verification_result  PT_card_verification_result
				,PT_datetime_req  PT_datetime_req
				,PT_datetime_rsp  PT_datetime_rsp
				,PT_datetime_tran_gmt   PT_datetime_tran_gmt
				,PT_datetime_tran_local PT_datetime_tran_local
				,PT_extended_tran_type  PT_extended_tran_type
				,PT_from_account_id     PT_from_account_id
				,PT_from_account_type   PT_from_account_type
				,PT_from_account_type_qualifier     PT_from_account_type_qualifier
				,PT_issuer_network_id   PT_issuer_network_id
				,PT_message_reason_code PT_message_reason_code
				,PT_message_type  PT_message_type
				,PT_next_post_tran_id   PT_next_post_tran_id
				,PT_online_system_id    PT_online_system_id
				,PT_opp_participant_id  PT_opp_participant_id
				,PT_participant_id      PT_participant_id
				,PT_payee   PT_payee
				,PT_pos_condition_code  PT_pos_condition_code
				,PT_pos_entry_mode      PT_pos_entry_mode
				,PT_post_tran_cust_id   PT_post_tran_cust_id
				,PT_post_tran_id  PT_post_tran_id
				,PT_prev_post_tran_id   PT_prev_post_tran_id
				,PT_prev_tran_approved  PT_prev_tran_approved
				,PT_proc_online_system_id     PT_proc_online_system_id
				,PT_pt_pos_card_input_mode    PT_pt_pos_card_input_mode
				,PT_pt_pos_cardholder_auth_method   PT_pt_pos_cardholder_auth_method
				,PT_pt_pos_operating_environment    PT_pt_pos_operating_environment
				,PT_pt_pos_pin_capture_ability      PT_pt_pos_pin_capture_ability
				,PT_pt_pos_terminal_operator  PT_pt_pos_terminal_operator
				,PT_realtime_business_date    PT_realtime_business_date
				,PT_receiving_inst_id_code    PT_receiving_inst_id_code
				,PT_recon_business_date PT_recon_business_date
				,PT_retention_data      PT_retention_data
				,PT_retrieval_reference_nr    PT_retrieval_reference_nr
				,PT_routing_type  PT_routing_type
				,PT_rsp_code_req  PT_rsp_code_req
				,PT_rsp_code_rsp  PT_rsp_code_rsp
				,PT_settle_amount_impact      PT_settle_amount_impact
				,PT_settle_amount_req   PT_settle_amount_req
				,PT_settle_amount_rsp   PT_settle_amount_rsp
				,PT_settle_cash_req     PT_settle_cash_req
				,PT_settle_cash_rsp     PT_settle_cash_rsp
				,PT_settle_currency_code      PT_settle_currency_code
				,PT_settle_entity_id    PT_settle_entity_id
				,PT_settle_proc_fee_req PT_settle_proc_fee_req
				,PT_settle_proc_fee_rsp PT_settle_proc_fee_rsp
				,PT_settle_tran_fee_req PT_settle_tran_fee_req
				,PT_settle_tran_fee_rsp PT_settle_tran_fee_rsp
				,PT_sink_node_name      PT_sink_node_name
				,PT_source_node_key     PT_source_node_key
				,PT_sponsor_bank  PT_sponsor_bank
				,PT_system_trace_audit_nr     PT_system_trace_audit_nr
				,PT_to_account_id PT_to_account_id
				,PT_to_account_type     PT_to_account_type
				,PT_to_account_type_qualifier PT_to_account_type_qualifier
				,PT_tran_amount_req     PT_tran_amount_req
				,PT_tran_amount_rsp     PT_tran_amount_rsp
				,PT_tran_cash_req PT_tran_cash_req
				,PT_tran_cash_rsp PT_tran_cash_rsp
				,PT_tran_completed      PT_tran_completed
				,PT_tran_currency_code  PT_tran_currency_code
				,PT_tran_nr PT_tran_nr
				,PT_tran_postilion_originated PT_tran_postilion_originated
				,PT_tran_proc_fee_currency_code     PT_tran_proc_fee_currency_code
				,PT_tran_proc_fee_req   PT_tran_proc_fee_req
				,PT_tran_proc_fee_rsp   PT_tran_proc_fee_rsp
				,PT_tran_reversed PT_tran_reversed
				,PT_tran_tran_fee_currency_code     PT_tran_tran_fee_currency_code
				,PT_tran_tran_fee_req   PT_tran_tran_fee_req
				,PT_tran_tran_fee_rsp   PT_tran_tran_fee_rsp
				,PT_tran_type     PT_tran_type
				,PTC_address_verification_data      PTC_address_verification_data
				,PTC_address_verification_result    PTC_address_verification_result
				,PTC_card_acceptor_id_code    PTC_card_acceptor_id_code
				,PTC_card_acceptor_name_loc   PTC_card_acceptor_name_loc
				,PTC_card_product PTC_card_product
				,PTC_card_seq_nr  PTC_card_seq_nr
				,PTC_check_data   PTC_check_data
				,PTC_draft_capture      PTC_draft_capture
				,PTC_expiry_date  PTC_expiry_date
				,PTC_mapped_card_acceptor_id_code   PTC_mapped_card_acceptor_id_code
				,PTC_merchant_type      PTC_merchant_type
				,PTC_pan    PTC_pan
				,PTC_pan_encrypted      PTC_pan_encrypted
				,PTC_pan_reference      PTC_pan_reference
				,PTC_pan_search   PTC_pan_search
				,PTC_pos_card_capture_ability PTC_pos_card_capture_ability
				,PTC_pos_card_data_input_ability    PTC_pos_card_data_input_ability
				,PTC_pos_card_data_input_mode PTC_pos_card_data_input_mode
				,PTC_pos_card_data_output_ability   PTC_pos_card_data_output_ability
				,PTC_pos_card_present   PTC_pos_card_present
				,PTC_pos_cardholder_auth_ability    PTC_pos_cardholder_auth_ability
				,PTC_pos_cardholder_auth_entity     PTC_pos_cardholder_auth_entity
				,PTC_pos_cardholder_auth_method     PTC_pos_cardholder_auth_method
				,PTC_pos_cardholder_present   PTC_pos_cardholder_present
				,PTC_pos_operating_environment      PTC_pos_operating_environment
				,PTC_pos_pin_capture_ability  PTC_pos_pin_capture_ability
				,PTC_pos_terminal_operator    PTC_pos_terminal_operator
				,PTC_pos_terminal_output_ability    PTC_pos_terminal_output_ability
				,PTC_pos_terminal_type  PTC_pos_terminal_type
				,PTC_post_tran_cust_id  PTC_post_tran_cust_id
				,PTC_service_restriction_code PTC_service_restriction_code
				,PTC_source_node_name   PTC_source_node_name
				,PTC_terminal_id  PTC_terminal_id
				,PTC_terminal_owner     PTC_terminal_owner
				,PTC_totals_group PTC_totals_group
				,0 PTSP_Account_Nr--PTSP_Account_Nr  PTSP_Account_Nr
				,0 ptsp_code--PTSP.PTSP_code   ptsp_code
				,0 account_PTSP_Code--PA.PTSP_Code     account_PTSP_Code
				,0 PTSP_Name --PTSP_Name  PTSP_Name
				,0 rdm_amt--rdm_amt    rdm_amt
				,0 Reward_Code--Reward_Code      Reward_Code
				,0 Reward_discount--Reward_discount  Reward_discount
				,0 rr_number--rr_number  rr_number
				,sdi_tran_id      sdi_tran_id
				,se_id      se_id
				,session_id session_id
				,0 Sort_Code--Sort_Code  Sort_Code
				,spay_session_id  spay_session_id
				,spst_session_id  spst_session_id
				,0 stan--stan stan
				,tag  tag
				, 0 ptsp_terminal_id--PTSP.terminal_id      ptsp_terminal_id
				, 0 reward_terminal_id-- y.terminal_id  reward_terminal_id
				,0 terminal_mode--terminal_mode    terminal_mode
				,0 trans_date--trans_date trans_date
				,0 txn_id--txn_id     txn_id
				,mer.category_code web_category_code
				,mer.category_name web_category_name
				,mer.fee_type web_fee_type
				,mer.merchant_disc web_merchant_disc
				,mer.amount_cap web_amount_cap
				,mer.fee_cap web_fee_cap
				,mer.bearer  web_bearer
				,ow.terminal_id owner_terminal_id
				,ow.Terminal_code owner_terminal_code
				, bank_code = case         
					
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
										 WHEN (DebitAccNr_acc_nr LIKE ''CHB%'' OR CreditAccNr_acc_nr LIKE ''CHB%'') THEN ''IBTC''
										 WHEN (DebitAccNr_acc_nr LIKE ''PLAT%'' OR CreditAccNr_acc_nr LIKE ''PLAT%'') THEN ''KSB''
										  WHEN (DebitAccNr_acc_nr LIKE ''KSB%'' OR CreditAccNr_acc_nr LIKE ''KSB%'') THEN ''KSB''
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
										 WHEN (DebitAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'' OR CreditAccNr_acc_nr LIKE ''POS_FOODCONCEPT%'') THEN ''SCB''
										 WHEN ((DebitAccNr_acc_nr LIKE ''ISW%'' and DebitAccNr_acc_nr not LIKE ''%POOL%'' ) 
										 OR (CreditAccNr_acc_nr LIKE ''ISW%'' and CreditAccNr_acc_nr not LIKE ''%POOL%'' ) ) 
										 THEN ''ISW''
							
							 ELSE ''UNK''	
						END
				, 
				                         
										 Debit_account_type= 
				  
				  CASE 
				                      
				                      
				                      
										  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Debit_Nr)''  
										  WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Debit_Nr)''   
										  WHEN (DebitAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Debit_Nr)''  
										  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Debit_Nr)''


										  WHEN (DebitAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 

										  --AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_TERMINAL_ID)= ''9''
										  AND NOT ((DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')OR (DebitAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (DebitAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN ''ISW FEE RECEIVABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Debit_Nr)''  
										  WHEN (DebitAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Debit_Nr)''
										  WHEN (DebitAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Debit_Nr)''                       

										  ELSE ''UNK''			
				END,
				  Credit_account_type= 
				  CASE  
				  
				  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%PAYABLE'') THEN ''AMOUNT PAYABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%AMOUNT%RECEIVABLE'') THEN ''AMOUNT RECEIVABLE(Credit_Nr)''  
										  WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%PAYABLE'') THEN ''ACQUIRER FEE PAYABLE(Credit_Nr)''   
										  WHEN (CreditAccNr_acc_nr LIKE ''%ACQUIRER%FEE%RECEIVABLE'') THEN ''ACQUIRER FEE RECEIVABLE(Credit_Nr)''  
										  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%PAYABLE'') THEN ''ISSUER FEE PAYABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%ISSUER%FEE%RECEIVABLE'') THEN ''ISSUER FEE RECEIVABLE(Credit_Nr)''


										  WHEN (CreditAccNr_acc_nr LIKE ''%ISW%FEE%RECEIVABLE'' 

										  --AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_TERMINAL_ID)= ''9''
										  AND NOT ((CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'')OR (CreditAccNr_acc_nr LIKE ''%TERMINAL%FEE%RECEIVABLE'') 
										  OR (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') OR (CreditAccNr_acc_nr LIKE ''%NCS%FEE%RECEIVABLE''))) THEN 
										  ''ISW FEE RECEIVABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%ISO%FEE%RECEIVABLE'') THEN ''ISO FEE RECEIVABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%TERMINAL_OWNER%FEE%RECEIVABLE'') THEN ''TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%PROCESSOR%FEE%RECEIVABLE'') THEN ''PROCESSOR FEE RECEIVABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%POOL_ACCOUNT'') THEN ''POOL ACCOUNT(Credit_Nr)''  
										  WHEN (CreditAccNr_acc_nr LIKE ''%FEE_POOL'') THEN ''FEE POOL(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%MERCHANT%FEE%RECEIVABLE'') THEN ''MERCHANT FEE RECEIVABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%PTSP_FEE_RECEIVABLE'') THEN ''PTSP FEE RECEIVABLE(Credit_Nr)''
										  WHEN (CreditAccNr_acc_nr LIKE ''%NCS_FEE_RECEIVABLE'') THEN ''NCS FEE RECEIVABLE(Credit_Nr)''                       
									ELSE ''UNK''		
				END
				,
				trxn_category= 
					
					CASE WHEN feevalue_description like ''MasterCard Switched_In_Financial_Domestic_Authorization%'' THEN ''SWITCHED_IN_FINANCIAL_DOMESTIC_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_In_NonFinancial_Domestic_Authorization%'' THEN ''SWITCHED_IN_NONFINANCIAL_DOMESTIC_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_In_failed_Domestic_Authorization%'' THEN ''SWITCHED_IN_FAILED_DOMESTIC_AUTHORIZATION'' 
						 WHEN feevalue_description like ''MasterCard Switched_In_Financial_Domestic_Completion%'' THEN ''SWITCHED_IN_FINANCIAL_DOMESTIC_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_In_NonFinancial_Domestic_Completion%'' THEN ''SWITCHED_IN_NONFINANCIAL_DOMESTIC_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_In_failed_Domestic_Completion%'' THEN ''SWITCHED_IN_FAILED_DOMESTIC_COMPLETION'' 
						 WHEN feevalue_description like ''MasterCard Switched_In_Financial_Domestic_Request%'' THEN ''SWITCHED_IN_FINANCIAL_DOMESTIC_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_In_NonFinancial_Domestic_Request%'' THEN ''SWITCHED_IN_NONFINANCIAL_DOMESTIC_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_In_failed_Domestic_Request%'' THEN ''SWITCHED_IN_FAILED_DOMESTIC_REQUEST'' 
						 WHEN feevalue_description like ''MasterCard Switched_In_Financial_Foreign_Authorization%'' THEN ''SWITCHED_IN_FINANCIAL_FOREIGN_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_In_NonFinancial_Foreign_Authorization%'' THEN ''SWITCHED_IN_NONFINANCIAL_FOREIGN_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_In_failed_Foreign_Authorization%'' THEN ''SWITCHED_IN_FAILED_FOREIGN_AUTHORIZATION'' 
						 WHEN feevalue_description like ''MasterCard Switched_In_Financial_Foreign_Completion%'' THEN ''SWITCHED_IN_FINANCIAL_FOREIGN_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_In_NonFinancial_Foreign_Completion%'' THEN ''SWITCHED_IN_NONFINANCIAL_FOREIGN_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_In_failed_Foreign_Completion%'' THEN ''SWITCHED_IN_FAILED_FOREIGN_COMPLETION'' 
						 WHEN feevalue_description like ''MasterCard Switched_In_Financial_Foreign_Request%'' THEN ''SWITCHED_IN_FINANCIAL_FOREIGN_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_In_NonFinancial_Foreign_Request%'' THEN ''SWITCHED_IN_NONFINANCIAL_FOREIGN_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_In_failed_Foreign_Request%'' THEN ''SWITCHED_IN_FAILED_FOREIGN_REQUEST'' 
				         
						 WHEN feevalue_description like ''MasterCard Switched_out_Financial_Domestic_Authorization%'' THEN ''SWITCHED_OUT_FINANCIAL_DOMESTIC_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_out_NonFinancial_Domestic_Authorization%'' THEN ''SWITCHED_OUT_NONFINANCIAL_DOMESTIC_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_out_failed_Domestic_Authorization%'' THEN ''SWITCHED_OUT_FAILED_DOMESTIC_AUTHORIZATION'' 
						 WHEN feevalue_description like ''MasterCard Switched_out_Financial_Domestic_Completion%'' THEN ''SWITCHED_OUT_FINANCIAL_DOMESTIC_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_out_NonFinancial_Domestic_Completion%'' THEN ''SWITCHED_OUT_NONFINANCIAL_DOMESTIC_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_out_failed_Domestic_Completion%'' THEN ''SWITCHED_OUT_FAILED_DOMESTIC_COMPLETION'' 
						 WHEN feevalue_description like ''MasterCard Switched_out_Financial_Domestic_Request%'' THEN ''SWITCHED_OUT_FINANCIAL_DOMESTIC_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_out_NonFinancial_Domestic_Request%'' THEN ''SWITCHED_OUT_NONFINANCIAL_DOMESTIC_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_out_failed_Domestic_Request%'' THEN ''SWITCHED_OUT_FAILED_DOMESTIC_REQUEST'' 
						 WHEN feevalue_description like ''MasterCard Switched_out_Financial_Foreign_Authorization%'' THEN ''SWITCHED_OUT_FINANCIAL_FOREIGN_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_out_NonFinancial_Foreign_Authorization%'' THEN ''SWITCHED_OUT_NONFINANCIAL_FOREIGN_AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard Switched_out_failed_Foreign_Authorization%'' THEN ''SWITCHED_OUT_FAILED_FOREIGN_AUTHORIZATION'' 
						 WHEN feevalue_description like ''MasterCard Switched_out_Financial_Foreign_Completion%'' THEN ''SWITCHED_OUT_FINANCIAL_FOREIGN_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_out_NonFinancial_Foreign_Completion%'' THEN ''SWITCHED_OUT_NONFINANCIAL_FOREIGN_COMPLETION''
						 WHEN feevalue_description like ''MasterCard Switched_out_failed_Foreign_Completion%'' THEN ''SWITCHED_OUT_FAILED_FOREIGN_COMPLETION'' 
						 WHEN feevalue_description like ''MasterCard Switched_out_Financial_Foreign_Request%'' THEN ''SWITCHED_OUT_FINANCIAL_FOREIGN_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_out_NonFinancial_Foreign_Request%'' THEN ''SWITCHED_OUT_NONFINANCIAL_FOREIGN_REQUEST''
						 WHEN feevalue_description like ''MasterCard Switched_out_failed_Foreign_Request%'' THEN ''SWITCHED_OUT_FAILED_FOREIGN_REQUEST'' 
						 WHEN feevalue_description like ''MasterCard Voice Authorization%'' THEN ''MASTERCARD VOICE AUTHORIZATION''
						 WHEN feevalue_description like ''Visa Voice Authorization%'' THEN ''VISA VOICE AUTHORIZATION''
						 WHEN feevalue_description like ''MasterCard POS Purchase Billing_PTSP%'' THEN ''MASTERCARD POS PURCHASE PTSP BILLING''
						 WHEN feevalue_description like ''Visa POS Purchase Billing_PTSP%'' THEN ''VISA POS PURCHASE PTSP BILLING''
						 WHEN feevalue_description like ''MasterCard Web Purchase Billing_Authentication%'' THEN ''MASTERCARD WEB PURCHASE AUTHENTICATION BILLING''
						 WHEN feevalue_description like ''Visa Web Purchase Billing_Authentication%'' THEN ''VISA WEB PURCHASE AUTHENTICATION BILLING''
						 WHEN feevalue_description like ''MasterCard POS Purchase Billing%'' THEN ''MASTERCARD POS PURCHASE PROCESSOR BILLING''
						 WHEN feevalue_description like ''MasterCard Web Purchase Billing%'' THEN ''MASTERCARD WEB PURCHASE PROCESSOR BILLING''
						 WHEN feevalue_description like ''Visa POS Purchase Billing%'' THEN ''VISA POS PURCHASE PROCESSOR BILLING''
						 WHEN feevalue_description like ''Visa Web Purchase Billing%'' THEN ''VISA WEB PURCHASE PROCESSOR BILLING''
						 WHEN feevalue_description like ''MasterCard MIGS Purchase Billing%'' THEN ''MASTERCARD MIGS PURCHASE PROCESSOR BILLING''
						 WHEN feevalue_description like ''Visa MIGS Purchase Billing%'' THEN ''VISA MIGS PURCHASE PROCESSOR BILLING''
						 WHEN feevalue_description like ''Issuer fee Debit%'' THEN ''MASTERCARD ATM ROU BILLING''
						 WHEN feevalue_description like ''Visa Issuer Fee Debit'' THEN ''VISA ATM ROU BILLING''
				         
				ELSE ''unk'' END
				,

				  Acquirer =   PT.PTC_source_node_name,
				               
				                     
				  Issuer =    PT.PT_sink_node_name,
				  currency = 
						CASE WHEN FeeValue_description like ''%$''  THEN ''840''
										WHEN FeeValue_description like ''%#''THEN ''566''
						  ELSE ''566'' END,

				Rate = case  WHEN FeeValue_description like ''%$'' 
						  then(SELECT cbn.Rate
						  FROM cbn_currency AS cbn
						  WHERE  cbn.date = (select max(date) from cbn_currency)) 

						  ELSE 1 END


				INTO [post_settle_tran_details_mega_'+@settle_date+']

				FROM  (SELECT
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

					FROM (select * from   post_tran   WITH (NOLOCK, INDEX(ix_post_tran_9)) WHERE recon_business_date = '''+@settle_date+''')PT 
					
					 LEFT JOIN  Post_tran_cust AS PTC WITH  (NOLOCK, INDEX(pk_post_tran_cust))
					 on PT.post_tran_cust_id = PTC.post_tran_cust_id    ) PT  
									 join 
					(
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
					,(SELECT config_set_id FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)DebitAccNr_config_set_id
						,(SELECT acc_nr_id FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id) DebitAccNr_acc_nr_id
					,(SELECT se_id FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id) 	DebitAccNr_se_id
					,(SELECT acc_id FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)	DebitAccNr_acc_id
					,(SELECT acc_nr FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)	DebitAccNr_acc_nr
					,(SELECT state FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id) DebitAccNr_aggregation_id
					,(SELECT aggregation_id FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)	DebitAccNr_state
					,(SELECT config_state FROM sstl_se_acc_nr_w DebitAccNr (NOLOCK) WHERE J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)DebitAccNr_config_state
					,(SELECT config_set_id FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)CreditAccNr_config_set_id
					,(SELECT acc_nr_id FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id) CreditAccNr_acc_nr_id
				,(SELECT se_id FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id) 	CreditAccNr_se_id
				,(SELECT acc_id FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)	CreditAccNr_acc_id
				,(SELECT acc_nr FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)	CreditAccNr_acc_nr
				,(SELECT state FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id) CreditAccNr_aggregation_id
				,(SELECT aggregation_id FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)	CreditAccNr_state
				,(SELECT config_state FROM sstl_se_acc_nr_w CreditAccNr (NOLOCK) WHERE J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)CreditAccNr_config_state
					,(SELECT config_set_id FROM sstl_se_amount_w Amount (NOLOCK) WHERE J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)	Amount_config_set_id
					,(SELECT amount_id FROM sstl_se_amount_w Amount (NOLOCK) WHERE J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)	Amount_amount_id
					,(SELECT se_id FROM sstl_se_amount_w Amount (NOLOCK) WHERE J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)Amount_se_id
					,(SELECT name FROM sstl_se_amount_w Amount (NOLOCK) WHERE J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)	Amount_name
					,(SELECT description FROM sstl_se_amount_w Amount (NOLOCK) WHERE J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)	Amount_description
					,(SELECT config_state FROM sstl_se_amount_w Amount (NOLOCK) WHERE J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)	Amount_config_state
					,(SELECT config_set_id FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id )Fee_config_set_id
					,(SELECT Fee_id FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id )	Fee_fee_id
					,(SELECT se_id FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id )	Fee_se_id
					,(SELECT name FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id )Fee_name
					,(SELECT description FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id )Fee_description
					,(SELECT type FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id )Fee_type
					,(SELECT amount_id FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id ) Fee_amount_id
					,(SELECT config_state  FROM sstl_se_fee_w Fee (NOLOCK) WHERE J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id ) Fee_config_state
					,(SELECT config_set_id FROM sstl_coa_w coa (NOLOCK)  WHERE J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id )  coa_config_set_id
					,(SELECT coa_id FROM sstl_coa_w coa (NOLOCK)  WHERE J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id )	coa_coa_id
					,(SELECT name FROM sstl_coa_w coa (NOLOCK)  WHERE J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id )	coa_name
					,(SELECT description FROM sstl_coa_w coa (NOLOCK)  WHERE J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id )	coa_description
					,(SELECT type FROM sstl_coa_w coa (NOLOCK)  WHERE J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id )	coa_type
					,(SELECT config_state FROM sstl_coa_w coa (NOLOCK)  WHERE J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id )	coa_config_state
					,( SELECT  TOP 1 description FROM sstl_se_fee_value_w FeeValue (NOLOCK) WHERE description IS NOT NULL AND  J.fee_id = FeeValue.fee_id AND J.fee_value_id = FeeValue.fee_value_id AND J.config_set_id = FeeValue.config_set_id 	 ) FeeValue_description
					FROM
					dbo.sstl_journal_all J WITH (NOLOCK) where business_date= '''+@settle_date+'''
					
				                   
				                   
								   )  J
									ON (J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
				                     
				left JOIN tbl_merchant_category m (NOLOCK)
										ON PT.PTC_merchant_type = m.category_code 
										left JOIN tbl_merchant_category_visa s (NOLOCK)
										ON PT.PTC_merchant_type = s.category_code 
										left JOIN tbl_merchant_account a (NOLOCK)
										ON PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code   
				                       
										   left JOIN tbl_merchant_category_web mer (NOLOCK)
																ON PT.PTC_merchant_type = mer.category_code 
															 LEFT JOIN tbl_terminal_owner ow ON PT.PTC_terminal_id = ow.terminal_id      
				option (RECOMPILE,  OPTIMIZE FOR UNKNOWN, MAXDOP 6)
				')

end
