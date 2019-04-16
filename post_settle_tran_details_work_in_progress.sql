IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_settle_tran_details]') AND type in (N'U'))
	TRUNCATE TABLE [dbo].[post_settle_tran_details]
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

INTO post_settle_tran_details
 
FROM
                     temp_journal_data  J (NOLOCK)
                     join 
                     temp_post_tran_data PT (NOLOCK )
                    ON (J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                     AND
                     
   -- PT.PT_tran_postilion_originated= 0 AND 
    (
          (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in ('0200','0220'))

       or ((PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 

       and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,  PT.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,PT.PTC_totals_group ,PT.ptc_pan) <> 1 and PT.PT_tran_reversed <> 2)
       or (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 
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
                                    --AND t.system_trace_audit_nr = y.stan
                                    AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
                                    AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
                                    = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand (NOLOCK)))
				left JOIN Reward_Category r (NOLOCK)
                                ON y.extended_trans_type = r.reward_code
        
option (RECOMPILE)