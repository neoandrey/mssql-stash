SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_settle_tran_details_20160911]') AND type in (N'U'))
	drop TABLE [dbo].[post_settle_tran_details_20160911]
GO



SELECT   

acc_post_id	acc_post_id
,Account_Name	Account_Name
,account_nr	account_nr
,acquirer_inst_id1	acquirer_inst_id1
,acquirer_inst_id2	acquirer_inst_id2
,acquirer_inst_id3	acquirer_inst_id3
,acquirer_inst_id4	acquirer_inst_id4
,acquirer_inst_id5	acquirer_inst_id5
,Acquiring_bank	Acquiring_bank
,acquiring_inst_id_code	acquiring_inst_id_code
,Addit_charge	Addit_charge
,Addit_party	Addit_party
,adj_id	adj_id
,j.amount	journal_amount
,y.amount	xls_amount
,Amount_amount_id	Amount_amount_id
,m.Amount_Cap	merch_cat_amount_cap
,s.Amount_Cap	merch_cat_visa_amount_cap
,R.Amount_Cap	reward_amount_cap
,Amount_config_set_id	Amount_config_set_id
,Amount_config_state	Amount_config_state
,Amount_description	Amount_description
,amount_id	amount_id
,Amount_name	Amount_name
,Amount_se_id	Amount_se_id
,amount_value_id	amount_value_id
,Authorized_Person	Authorized_Person
,BANK_CODE	BANK_CODE
,BANK_CODE1	BANK_CODE1
,BANK_INSTITUTION_NAME	BANK_INSTITUTION_NAME
,m.Bearer	merch_cat_bearer
,s.Bearer	merch_cat_visa_bearer
,business_date	business_date
,card_acceptor_id_code	card_acceptor_id_code
,card_acceptor_name_loc	card_acceptor_name_loc
,cashier_acct	cashier_acct
,cashier_code	cashier_code
,cashier_ext_trans_code	cashier_ext_trans_code
,cashier_name	cashier_name
,s.Category_Code    merch_cat_visa_category_code
,m.Category_Code	merch_cat_category_code
,s.Category_name	merch_cat_visa_category_name
,m.Category_name	merch_cat_category_name
,CBN_Code1	CBN_Code1
,CBN_Code2	CBN_Code2
,CBN_Code3	CBN_Code3
,CBN_Code4	CBN_Code4
,coa_coa_id	coa_coa_id
,coa_config_set_id	coa_config_set_id
,coa_config_state	coa_config_state
,coa_description	coa_description
,coa_id	coa_id
,coa_name	coa_name
,coa_se_id	coa_se_id
,coa_type	coa_type
,config_set_id	config_set_id
,credit_acc_id	credit_acc_id
,credit_acc_nr_id	credit_acc_nr_id
,credit_cardholder_acc_id	credit_cardholder_acc_id
,credit_cardholder_acc_type	credit_cardholder_acc_type
,CreditAccNr_acc_id	CreditAccNr_acc_id
,CreditAccNr_acc_nr	CreditAccNr_acc_nr
,CreditAccNr_acc_nr_id	CreditAccNr_acc_nr_id
,CreditAccNr_aggregation_id	CreditAccNr_aggregation_id
,CreditAccNr_config_set_id	CreditAccNr_config_set_id
,CreditAccNr_config_state	CreditAccNr_config_state
,CreditAccNr_se_id	CreditAccNr_se_id
,CreditAccNr_state	CreditAccNr_state
,Date_Modified	Date_Modified
,debit_acc_id	debit_acc_id
,debit_acc_nr_id	debit_acc_nr_id
,debit_cardholder_acc_id	debit_cardholder_acc_id
,debit_cardholder_acc_type	debit_cardholder_acc_type
,DebitAccNr_acc_id	DebitAccNr_acc_id
,DebitAccNr_acc_nr	DebitAccNr_acc_nr
,DebitAccNr_acc_nr_id	DebitAccNr_acc_nr_id
,DebitAccNr_aggregation_id	DebitAccNr_aggregation_id
,DebitAccNr_config_set_id	DebitAccNr_config_set_id
,DebitAccNr_config_state	DebitAccNr_config_state
,DebitAccNr_se_id	DebitAccNr_se_id
,DebitAccNr_state	DebitAccNr_state
,entry_id	entry_id
,extended_trans_type	extended_trans_type
,fee	fee
,Fee_amount_id	Fee_amount_id
,m.Fee_Cap	merch_cat_fee_cap
,s.Fee_Cap	merch_cat_visa_fee_cap
,r.Fee_Cap	reward_fee_cap
,Fee_config_set_id	Fee_config_set_id
,Fee_config_state	Fee_config_state
,Fee_description	Fee_description
,Fee_Discount	Fee_Discount
,Fee_fee_id	Fee_fee_id
,fee_id	fee_id
,Fee_name	Fee_name
,Fee_se_id	Fee_se_id
,m.Fee_type	merch_cat_category_fee_type
,s.Fee_type	merch_cat_category_visa_fee_type
,j.Fee_type	journal_fee_type
,fee_value_id	fee_value_id
,granularity_element	granularity_element
,m.Merchant_Disc	merch_cat_category_merch_discount
,s.Merchant_Disc	merch_cat_category_visa_merch_discount
,merchant_id	merchant_id
,merchant_type	merchant_type
,nt_fee	nt_fee
,nt_fee_acc_post_id	nt_fee_acc_post_id
,nt_fee_id	nt_fee_id
,nt_fee_value_id	nt_fee_value_id
,pan	pan
,post_tran_cust_id	post_tran_cust_id
,post_tran_id	post_tran_id
,PT_abort_rsp_code	PT_abort_rsp_code
,PT_acquirer_network_id	PT_acquirer_network_id
,PT_acquiring_inst_id_code	PT_acquiring_inst_id_code
,PT_additional_rsp_data	PT_additional_rsp_data
,PT_auth_id_rsp	PT_auth_id_rsp
,PT_auth_reason	PT_auth_reason
,PT_auth_type	PT_auth_type
,PT_bank_details	PT_bank_details
,PT_batch_nr	PT_batch_nr
,PT_card_verification_result	PT_card_verification_result
,PT_datetime_req	PT_datetime_req
,PT_datetime_rsp	PT_datetime_rsp
,PT_datetime_tran_gmt	PT_datetime_tran_gmt
,PT_datetime_tran_local	PT_datetime_tran_local
,PT_extended_tran_type	PT_extended_tran_type
,PT_from_account_id	PT_from_account_id
,PT_from_account_type	PT_from_account_type
,PT_from_account_type_qualifier	PT_from_account_type_qualifier
,PT_issuer_network_id	PT_issuer_network_id
,PT_message_reason_code	PT_message_reason_code
,PT_message_type	PT_message_type
,PT_next_post_tran_id	PT_next_post_tran_id
,PT_online_system_id	PT_online_system_id
,PT_opp_participant_id	PT_opp_participant_id
,PT_participant_id	PT_participant_id
,PT_payee	PT_payee
,PT_pos_condition_code	PT_pos_condition_code
,PT_pos_entry_mode	PT_pos_entry_mode
,PT_post_tran_cust_id	PT_post_tran_cust_id
,PT_post_tran_id	PT_post_tran_id
,PT_prev_post_tran_id	PT_prev_post_tran_id
,PT_prev_tran_approved	PT_prev_tran_approved
,PT_proc_online_system_id	PT_proc_online_system_id
,PT_pt_pos_card_input_mode	PT_pt_pos_card_input_mode
,PT_pt_pos_cardholder_auth_method	PT_pt_pos_cardholder_auth_method
,PT_pt_pos_operating_environment	PT_pt_pos_operating_environment
,PT_pt_pos_pin_capture_ability	PT_pt_pos_pin_capture_ability
,PT_pt_pos_terminal_operator	PT_pt_pos_terminal_operator
,PT_realtime_business_date	PT_realtime_business_date
,PT_receiving_inst_id_code	PT_receiving_inst_id_code
,PT_recon_business_date	PT_recon_business_date
,PT_retention_data	PT_retention_data
,PT_retrieval_reference_nr	PT_retrieval_reference_nr
,PT_routing_type	PT_routing_type
,PT_rsp_code_req	PT_rsp_code_req
,PT_rsp_code_rsp	PT_rsp_code_rsp
,PT_settle_amount_impact	PT_settle_amount_impact
,PT_settle_amount_req	PT_settle_amount_req
,PT_settle_amount_rsp	PT_settle_amount_rsp
,PT_settle_cash_req	PT_settle_cash_req
,PT_settle_cash_rsp	PT_settle_cash_rsp
,PT_settle_currency_code	PT_settle_currency_code
,PT_settle_entity_id	PT_settle_entity_id
,PT_settle_proc_fee_req	PT_settle_proc_fee_req
,PT_settle_proc_fee_rsp	PT_settle_proc_fee_rsp
,PT_settle_tran_fee_req	PT_settle_tran_fee_req
,PT_settle_tran_fee_rsp	PT_settle_tran_fee_rsp
,PT_sink_node_name	PT_sink_node_name
,PT_source_node_key	PT_source_node_key
,PT_sponsor_bank	PT_sponsor_bank
,PT_system_trace_audit_nr	PT_system_trace_audit_nr
,PT_to_account_id	PT_to_account_id
,PT_to_account_type	PT_to_account_type
,PT_to_account_type_qualifier	PT_to_account_type_qualifier
,PT_tran_amount_req	PT_tran_amount_req
,PT_tran_amount_rsp	PT_tran_amount_rsp
,PT_tran_cash_req	PT_tran_cash_req
,PT_tran_cash_rsp	PT_tran_cash_rsp
,PT_tran_completed	PT_tran_completed
,PT_tran_currency_code	PT_tran_currency_code
,PT_tran_nr	PT_tran_nr
,PT_tran_postilion_originated	PT_tran_postilion_originated
,PT_tran_proc_fee_currency_code	PT_tran_proc_fee_currency_code
,PT_tran_proc_fee_req	PT_tran_proc_fee_req
,PT_tran_proc_fee_rsp	PT_tran_proc_fee_rsp
,PT_tran_reversed	PT_tran_reversed
,PT_tran_tran_fee_currency_code	PT_tran_tran_fee_currency_code
,PT_tran_tran_fee_req	PT_tran_tran_fee_req
,PT_tran_tran_fee_rsp	PT_tran_tran_fee_rsp
,PT_tran_type	PT_tran_type
,PTC_address_verification_data	PTC_address_verification_data
,PTC_address_verification_result	PTC_address_verification_result
,PTC_card_acceptor_id_code	PTC_card_acceptor_id_code
,PTC_card_acceptor_name_loc	PTC_card_acceptor_name_loc
,PTC_card_product	PTC_card_product
,PTC_card_seq_nr	PTC_card_seq_nr
,PTC_check_data	PTC_check_data
,PTC_draft_capture	PTC_draft_capture
,PTC_expiry_date	PTC_expiry_date
,PTC_mapped_card_acceptor_id_code	PTC_mapped_card_acceptor_id_code
,PTC_merchant_type	PTC_merchant_type
,PTC_pan	PTC_pan
,PTC_pan_encrypted	PTC_pan_encrypted
,PTC_pan_reference	PTC_pan_reference
,PTC_pan_search	PTC_pan_search
,PTC_pos_card_capture_ability	PTC_pos_card_capture_ability
,PTC_pos_card_data_input_ability	PTC_pos_card_data_input_ability
,PTC_pos_card_data_input_mode	PTC_pos_card_data_input_mode
,PTC_pos_card_data_output_ability	PTC_pos_card_data_output_ability
,PTC_pos_card_present	PTC_pos_card_present
,PTC_pos_cardholder_auth_ability	PTC_pos_cardholder_auth_ability
,PTC_pos_cardholder_auth_entity	PTC_pos_cardholder_auth_entity
,PTC_pos_cardholder_auth_method	PTC_pos_cardholder_auth_method
,PTC_pos_cardholder_present	PTC_pos_cardholder_present
,PTC_pos_operating_environment	PTC_pos_operating_environment
,PTC_pos_pin_capture_ability	PTC_pos_pin_capture_ability
,PTC_pos_terminal_operator	PTC_pos_terminal_operator
,PTC_pos_terminal_output_ability	PTC_pos_terminal_output_ability
,PTC_pos_terminal_type	PTC_pos_terminal_type
,PTC_post_tran_cust_id	PTC_post_tran_cust_id
,PTC_service_restriction_code	PTC_service_restriction_code
,PTC_source_node_name	PTC_source_node_name
,PTC_terminal_id	PTC_terminal_id
,PTC_terminal_owner	PTC_terminal_owner
,PTC_totals_group	PTC_totals_group
,PTSP_Account_Nr	PTSP_Account_Nr
,PTSP.PTSP_code	ptsp_code
,PA.PTSP_Code	account_PTSP_Code
,PTSP_Name	PTSP_Name
,rdm_amt	rdm_amt
,Reward_Code	Reward_Code
,Reward_discount	Reward_discount
,rr_number	rr_number
,sdi_tran_id	sdi_tran_id
,se_id	se_id
,session_id	session_id
,Sort_Code	Sort_Code
,spay_session_id	spay_session_id
,spst_session_id	spst_session_id
,stan	stan
,tag	tag
, PTSP.terminal_id	ptsp_terminal_id
,  y.terminal_id	reward_terminal_id
,terminal_mode	terminal_mode
,trans_date	trans_date
,txn_id	txn_id
,mer.category_code web_category_code
,mer.category_name web_category_name
,mer.fee_type web_fee_type
,mer.merchant_disc web_merchant_disc
,mer.amount_cap web_amount_cap
,mer.fee_cap web_fee_cap
,mer.bearer  web_bearer
,ow.terminal_id owner_terminal_id
,ow.Terminal_code owner_terminal_code
, Debit_account_type=CASE 
                     
                      WHEN  (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and PT.PT_acquiring_inst_id_code <> '627787')
                      AND (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE')
                        AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'  
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      
                       
                       THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN
                        (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and  PT.PT_acquiring_inst_id_code <> '627787')
                       AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       AND (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                     
                          
                       WHEN 
                                              (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and PT.PT_acquiring_inst_id_code <> '627787')
                                             AND
(DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      
                      
                       THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
							and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2')
                          THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN ( SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')and DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 

                           THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (   SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') and DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                        THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (DebitAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (DebitAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (DebitAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (DebitAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (DebitAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
 
                         
                      WHEN (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') 
                          AND
                          (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                        THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                       (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                      PT.PT_acquiring_inst_id_code <> '627787')AND (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')  and dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN  
                       (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                           PT.PT_acquiring_inst_id_code <> '627787') AND (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                       THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                                               
                          WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr_acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN   SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') AND (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE'     
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1') 

                        THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN  SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') AND (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2') 
                          THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN  SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') AND (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE'  
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 
                           THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'


                          WHEN  SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')  and (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE'  
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                          THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN  SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') and (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE'  
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                         THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN  SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') and (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE'   
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN   SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') and (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                           THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN   SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') and (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN    SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')and (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr_acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'
                         
                          WHEN (CreditAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          
                          WHEN (CreditAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 
			  WHEN (CreditAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)'
			  WHEN (CreditAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'

                          ELSE 'UNK'			
END
,
trxn_category=CASE WHEN (PT.PT_tran_type ='01')   AND PT.PTC_source_node_name = 'SWTMEGAsrc'
							AND dbo.fn_rpt_CardGroup(PT.PTC_PAN) in ('1','4')
                          
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN ( PT.PT_tran_type ='50' and DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                             then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN ( PT.PT_tran_type ='00' and PT.PTC_source_node_name = 'VTUsrc' and DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                            then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN ( PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ('2','5','6') and DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN (  SUBSTRING(PT.PTC_terminal_id,1,1) in ('3')and  PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                            and DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                            WHEN PT.PT_sink_node_name = 'ESBCSOUTsnk'
                            AND
                            (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                             
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Verve Token)'
                           
                           WHEN PT.PT_sink_node_name = 'ESBCSOUTsnk' AND (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                               
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)'
                           
                           WHEN PT.PT_sink_node_name = 'ESBCSOUTsnk'AND  (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                            
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 3 
                           THEN 'ATM WITHDRAWAL (Cardless:Non-Card Generated)'

						   WHEN    PT.PTC_source_node_name NOT IN( 'SWTMEGAsrc', 'ASPSPNOUsrc')  AND (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr  LIKE '%ATM%ISO%' OR CreditAccNr_acc_nr LIKE '%ATM%ISO%')
                                                 
                           THEN 'ATM WITHDRAWAL (MASTERCARD ISO)'

                           WHEN PT.PTC_source_node_name NOT IN( 'SWTMEGAsrc', 'ASPSPNOUsrc')  AND (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
 
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                                                                           
                           
                           WHEN PT.PTC_source_node_name <> 'SWTMEGAsrc' and
                           (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 

                           and (DebitAccNr_acc_nr LIKE '%V%BILLING%' OR CreditAccNr_acc_nr LIKE '%V%BILLING%')
                            
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN   PT.PTC_source_node_name = 'ASPSPNOUsrc' AND (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			               WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' and 
                           (DebitAccNr_acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr_acc_nr like '%BILLPAYMENT MCARD%') ) then 'BILLPAYMENT MASTERCARD BILLING'

                           WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' 
                           and (DebitAccNr_acc_nr like '%SVA_FEE_RECEIVABLE' or CreditAccNr_acc_nr like '%SVA_FEE_RECEIVABLE') ) 
                           AND dbo.fn_rpt_isBillpayment_IFIS(PT.PTC_terminal_id) = 1  then 'BILLPAYMENT IFIS REMITTANCE'
                          
			               WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') then 'BILLPAYMENT'
			   
			
                           WHEN (  (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' and PT.PT_tran_type ='40' 

                           or SUBSTRING(PT.PTC_terminal_id,1,1)= '0' or SUBSTRING(PT.PTC_terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN  SUBSTRING(PT.PTC_terminal_id,1,1)IN ('2','5','6')AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           AND dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           AND
                           dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                             
                           THEN 'POS PURCHASE (Cardless:Paycode Verve Token)'
                           
                           WHEN
                              SUBSTRING(PT.PTC_terminal_id,1,1)IN ('2','5','6')AND PT.PT_sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                          AND
                           
                            dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                          THEN 'POS PURCHASE (Cardless:Paycode Non-Verve Token)'

                           WHEN not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and 
                            (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '1'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            ) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN    not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                          )
                           THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN    not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                          
                          )THEN 'POS(CONCESSION)PURCHASE'

                           WHEN 
                           
                            not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') 
                           and
                           ( dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                         )  THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN   not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           
                            AND (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           )
                           THEN 'POS(HOTELS)PURCHASE'

                           WHEN   not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           )THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN  not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                            or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                            and
                            (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           ) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN 
                            not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           ) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN   not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                            )THEN 'POS(EASYFUEL)PURCHASE'

                           WHEN 
                            not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') 
                           and
                            (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           )THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           WHEN 
                             not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') and
                           (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           )THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           WHEN 
                              not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') and
                            (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                          )
                          THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           
                           WHEN    not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') and
                              (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                           ) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.PTC_merchant_type
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '19'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '20'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '21'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '22'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '23'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'Verify card – Ecash load'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '24'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '25'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '26'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Payment_Gateway_0.9%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '27'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Payment_Gateway_1.25%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '28'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Add_Card)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '30'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(0.75% CAPPED AT 1,000 CATEGORY)PURCHASE'
                                                 
                                                      
                           WHEN 
                            SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN
                                SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                             and
                              (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                         THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN 
                            SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                            THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN  (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           )
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') 
                           and (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                          )
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN   SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') 
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                          )
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN 
                            SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           AND
                           dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1  


                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN ( SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')
                           
                           and
                           dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2  

                          ) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN    SUBSTRING(PT.PTC_terminal_id,1,1)= '3' 
                           and
                           (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                          THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (  (PT.PT_tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.PT_tran_type,PT.PTC_source_node_name) = 1))
                                 and not (DebitAccNr_acc_nr like '%PREPAIDLOAD%' or CreditAccNr_acc_nr like '%PREPAIDLOAD%')
                                 and
                                 dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and (DebitAccNr_acc_nr LIKE '%fee%' OR CreditAccNr_acc_nr LIKE '%fee%')
                                ) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (  PT.PT_tran_type  =  ('50')
                                 and not (DebitAccNr_acc_nr like '%PREPAIDLOAD%' or CreditAccNr_acc_nr like '%PREPAIDLOAD%') AND  dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and (DebitAccNr_acc_nr NOT LIKE '%fee%' OR CreditAccNr_acc_nr NOT LIKE '%fee%')

                                ) THEN 'AUTOPAY TRANSFERS'

                           WHEN (  PT.PT_tran_type = '50' and  dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1') THEN 'ATM TRANSFERS'

                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '2' ) THEN 'POS TRANSFERS'
                           
                           
                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '4' ) THEN 'MOBILE TRANSFERS'

                          WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '35' ) then 'REMITA TRANSFERS'

       
                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '31' ) then 'OTHER TRANSFERS'
                           
                           WHEN  PT.PT_tran_type = '50' and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '32' ) then 'RELATIONAL TRANSFERS'
                           
                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '33' ) then 'SEAMFIX TRANSFERS'
                           
                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '34' ) then 'VERVE INTL TRANSFERS'

                           WHEN (  PT.PT_tran_type = '50' and  dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '36') then 'PREPAID CARD UNLOAD'

                           WHEN (  PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '37' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (  PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '38' ) then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (  PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '39' ) then 'SOFTPAY TRANSFERS'

                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '310' ) then 'OANDO S&T TRANSFERS'

                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '311' ) then 'UPPERLINK TRANSFERS'

                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '312'  ) then 'QUICKTELLER WEB TRANSFERS'

                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '314'  ) then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '315' ) then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN ( PT.PT_tran_type = '50' and dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '316' ) then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr_acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr_acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PT.PTC_source_node_name ,PT.PTC_pan, PT.PT_tran_type)= '1') then 'PREPAID CARDLOAD'

                          when PT.PT_tran_type = '21' then 'DEPOSIT'

                           /*WHEN (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%ISO_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%ISO_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'*/
                           
                          ELSE 'UNK'		

END
INTO post_settle_tran_details_20160911
 
FROM   temp_post_tran_data PT (NOLOCK )    
                 LEFT    join 
                   temp_journal_data  J (NOLOCK)
                    ON (J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                     AND
                   
    (
          (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in ('0200','0220'))

       or ((PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 

       and (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 
       or
        dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,  PT.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,PT.PTC_totals_group ,PT.ptc_pan) <> 1 and PT.PT_tran_reversed <> 2)
        
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type, pt.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,pt.PTC_totals_group ,pt.PTC_pan) = 1 ))

       or (PT.PT_settle_amount_rsp<> 0 and PT.PT_message_type   in ('0200','0220') and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1) IN ('0','1') ))
       or (PT.PT_message_type = '0420' and PT.PT_tran_reversed <> 2 and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1)IN ( '0','1' ))))
     

      AND not (pt.PTC_merchant_type in ('4004','4722') and PT.PT_tran_type = '00' and pt.PTC_source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(PT.PT_settle_amount_impact/100)< 200
       and not (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%'))
      AND pt.PTC_totals_group <>'CUPGroup'
      and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_acquiring_inst_id_code = '627787')
	  and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_sink_node_name not in ('ASPPOSVINsnk')
	            and not (pt.ptc_source_node_name = 'SWTFBPsrc' and PT.PT_sink_node_name = 'ASPPOSVISsnk') 
	           )
     and not (PT.ptc_source_node_name  = 'MEGATPPsrc' and PT.PT_tran_type = '00')
                       and (j.DebitAccNr_acc_nr like '%_PTSP_FEE_RECEIVABLE' OR j.CreditAccNr_acc_nr like '%_PTSP_FEE_RECEIVABLE') 

LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.PT_acquiring_inst_id_code or 
acc.acquirer_inst_id3 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id5 
= PT.PT_acquiring_inst_id_code)
left join tbl_PTSP PTSP(nolock) on (PT.PTC_terminal_id = PTSP.terminal_id)
left join tbl_PTSP_Account PA(nolock) on (PTSP.PTSP_code = PA.PTSP_code)
left JOIN tbl_merchant_category m (NOLOCK)
				ON PT.PTC_merchant_type = m.category_code 
				left JOIN tbl_merchant_category_visa s (NOLOCK)
				ON PT.PTC_merchant_type = s.category_code 
				left JOIN tbl_merchant_account a (NOLOCK)
				ON PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code   
				left JOIN tbl_xls_settlement y (NOLOCK)

				ON (PT.PTC_terminal_id= y.terminal_id 
                                    AND PT.PT_retrieval_reference_nr = y.rr_number 
                                    AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand (NOLOCK)))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
                           left JOIN tbl_merchant_category_web mer (NOLOCK)
                                                ON PT.PTC_merchant_type = mer.category_code 
                                             LEFT JOIN tbl_terminal_owner ow ON PT.PTC_terminal_id = ow.terminal_id
        
option (RECOMPILE)