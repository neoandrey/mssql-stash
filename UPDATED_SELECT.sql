SELEct  
     PT.bank_code
     ,PT.trxn_category
     ,PT.Debit_account_type
     ,PT.Credit_account_type
     ,PT.trxn_amount
     ,PT.trxn_fee
     ,PT.trxn_date
     ,PT.currency
     ,PT.late_reversal
     ,PT.card_type
     ,terminal_type,PT.source_node_name,PT.Unique_key,PT.Acquirer,PT.Issuer,PT.Volume,PT.Value_RequestedAmount,PT.Value_SettleAmount,PT.ptid,PT.ptcid,PT.index_no,
pt.[PT_post_tran_id] as post_tran_id_1
      ,pt.[PT_post_tran_cust_id]  as post_tran_cust_id_1
      ,[PT_settle_entity_id]
      ,[PT_batch_nr]S
      ,[PT_prev_post_tran_id]
      ,[PT_next_post_tran_id]
      ,[PT_sink_node_name]
      ,[PT_tran_postilion_originated]
      ,[PT_tran_completed]
      ,[PT_message_type]
      ,[PT_tran_type]
      ,[PT_tran_nr]
      ,[PT_system_trace_audit_nr]
      ,[PT_rsp_code_req]
      ,[PT_rsp_code_rsp]
      ,[PT_abort_rsp_code]
      ,[PT_auth_id_rsp]
      ,[PT_auth_type]
      ,[PT_auth_reason]
      ,[PT_retention_data]
      ,[PT_acquiring_inst_id_code]
      ,[PT_message_reason_code]
      ,[PT_sponsor_bank]
      ,[PT_retrieval_reference_nr]
      ,[PT_datetime_tran_gmt]
      ,[PT_datetime_tran_local]
      ,[PT_datetime_req]
      ,[PT_datetime_rsp]
      ,[PT_realtime_business_date]
      ,[PT_recon_business_date]
      ,[PT_from_account_type]
      ,[PT_to_account_type]
      ,[PT_from_account_id]
      ,[PT_to_account_id]
      ,[PT_tran_amount_req]
      ,[PT_tran_amount_rsp]
      ,[PT_settle_amount_impact]
      ,[PT_tran_cash_req]
      ,[PT_tran_cash_rsp]
      ,[PT_tran_currency_code]
      ,[PT_tran_tran_fee_req]
      ,[PT_tran_tran_fee_rsp]
      ,[PT_tran_tran_fee_currency_code]
      ,[PT_tran_proc_fee_req]
      ,[PT_tran_proc_fee_rsp]
      ,[PT_tran_proc_fee_currency_code]
      ,[PT_settle_amount_req]
      ,[PT_settle_amount_rsp]
      ,[PT_settle_cash_req]
      ,[PT_settle_cash_rsp]
      ,[PT_settle_tran_fee_req]
      ,[PT_settle_tran_fee_rsp]
      ,[PT_settle_proc_fee_req]
      ,[PT_settle_proc_fee_rsp]
      ,[PT_settle_currency_code]
      ,[PT_pos_entry_mode]
      ,[PT_pos_condition_code]
      ,[PT_additional_rsp_data]
      ,[PT_tran_reversed]
      ,[PT_prev_tran_approved]
      ,[PT_issuer_network_id]
      ,[PT_acquirer_network_id]
      ,[PT_extended_tran_type]
      ,[PT_from_account_type_qualifier]
      ,[PT_to_account_type_qualifier]
      ,[PT_bank_details]
      ,[PT_payee]
      ,[PT_card_verification_result]
      ,[PT_online_system_id]
      ,[PT_participant_id]
      ,[PT_opp_participant_id]
      ,[PT_receiving_inst_id_code]
      ,[PT_routing_type]
      ,[PT_pt_pos_operating_environment]
      ,[PT_pt_pos_card_input_mode]
      ,[PT_pt_pos_cardholder_auth_method]
      ,[PT_pt_pos_pin_capture_ability]
      ,[PT_pt_pos_terminal_operator]
      ,[PT_source_node_key]
      ,[PT_proc_online_system_id]
      ,[PTC_post_tran_cust_id]
      ,[PTC_source_node_name]
      ,[PTC_draft_capture]
      ,[PTC_pan]
      ,[PTC_card_seq_nr]
      ,[PTC_expiry_date]
      ,[PTC_service_restriction_code]
      ,[PTC_terminal_id]
      ,[PTC_terminal_owner]
      ,[PTC_card_acceptor_id_code]
      ,[PTC_mapped_card_acceptor_id_code]
      ,[PTC_merchant_type]
      ,[PTC_card_acceptor_name_loc]
      ,[PTC_address_verification_data]
      ,[PTC_address_verification_result]
      ,[PTC_check_data]
      ,[PTC_totals_group]
      ,[PTC_card_product]
      ,[PTC_pos_card_data_input_ability]
      ,[PTC_pos_cardholder_auth_ability]
      ,[PTC_pos_card_capture_ability]
      ,[PTC_pos_operating_environment]
      ,[PTC_pos_cardholder_present]
      ,[PTC_pos_card_present]
      ,[PTC_pos_card_data_input_mode]
      ,[PTC_pos_cardholder_auth_method]
      ,[PTC_pos_cardholder_auth_entity]
      ,[PTC_pos_card_data_output_ability]
      ,[PTC_pos_terminal_output_ability]
      ,[PTC_pos_pin_capture_ability]
      ,[PTC_pos_terminal_operator]
      ,[PTC_pos_terminal_type]
      ,[PTC_pan_search]
      ,[PTC_pan_encrypted]
      ,[PTC_pan_reference]
          ,(SELECT top 1 PTSP_Account_Nr  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code AND  PT.PTC_terminal_id = PTSP.terminal_id) PTSP_Account_Nr
,(SELECT  TOP 1 ptsp.PTSP_code FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code  AND  PT.PTC_terminal_id = PTSP.terminal_id)  ptsp_code
,(SELECT  TOP 1 PA.PTSP_code  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code AND  PT.PTC_terminal_id = PTSP.terminal_id )    account_PTSP_Code
,(SELECT  TOP 1  PTSP_Name  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code AND PT.PTC_terminal_id = PTSP.terminal_id) PTSP_Name
,rdm_amt    rdm_amt
,Reward_Code      Reward_Code
,Reward_discount  Reward_discount
,rr_number  rr_number
,sdi_tran_id      sdi_tran_id
,se_id      se_id
,session_id session_id
,Sort_Code  Sort_Code
,spay_session_id  spay_session_id
,spst_session_id  spst_session_id
,stan stan
,tag  tag
, (SELECT  TOP 1   ptsp.terminal_id  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on (PTSP.PTSP_code = PA.PTSP_code)  AND PT.PTC_terminal_id = PTSP.terminal_id)      ptsp_terminal_id
,  y.terminal_id  reward_terminal_id
,terminal_mode    terminal_mode
,trans_date trans_date
,txn_id     txn_id
,mer.category_code web_category_code
,mer.category_name web_category_name
,mer.fee_type web_fee_type
,mer.merchant_disc web_merchant_disc
,mer.amount_cap web_amount_cap
,mer.fee_cap web_fee_cap
,mer.bearer  web_bearer
,ow.terminal_id owner_terminal_id
,ow.Terminal_code owner_terminal_code
,acc_post_id acc_post_id
,Account_Name     Account_Name
,account_nr account_nr
 ,(SELECT TOP 1 acquirer_inst_id1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id1
			 ,(SELECT TOP 1 acquirer_inst_id2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id2
			 ,(SELECT TOP 1 acquirer_inst_id3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id3
			 ,(SELECT TOP 1 acquirer_inst_id4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id4
			 ,(SELECT TOP 1 acquirer_inst_id5 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id5
			 ,(SELECT TOP 1   Acquiring_bank FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
			 
,acquiring_inst_id_code acquiring_inst_id_code
,Addit_charge     Addit_charge
,Addit_party      Addit_party
,adj_id     adj_id
,pt.amount   journal_amount
,y.amount   xls_amount
,Amount_amount_id Amount_amount_id
 ,(SELECT TOP 1   m.Amount_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type= m.category_code)     merch_cat_amount_cap
			 ,(SELECT TOP 1   s.amount_cap FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )    merch_cat_visa_amount_cap
			
,R.Amount_Cap     reward_amount_cap
,Amount_config_set_id   Amount_config_set_id
,Amount_config_state    Amount_config_state
,Amount_description     Amount_description
,amount_id  amount_id
,Amount_name      Amount_name
,Amount_se_id     Amount_se_id
,amount_value_id  amount_value_id
,Authorized_Person      Authorized_Person
,(SELECT TOP 1 BANK_CODE FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						
			 	  ACC_BANK_CODE
			 ,(SELECT TOP 1 bank_code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       BANK_CODE1
			 ,(SELECT TOP 1 BANK_INSTITUTION_NAME FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)				  BANK_INSTITUTION_NAME
			 ,(SELECT TOP 1   m.bearer FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_bearer
			 ,(SELECT TOP 1   s.bearer FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_bearer
			 ,business_date    business_date
,ptc_card_acceptor_id_code  card_acceptor_id_code
,card_acceptor_name_loc card_acceptor_name_loc
,cashier_acct     cashier_acct
,cashier_code     cashier_code
,cashier_ext_trans_code cashier_ext_trans_code
,cashier_name     cashier_name
 ,(SELECT TOP 1   s.category_code FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )   merch_cat_visa_category_code
			 , (SELECT TOP 1   m.Category_Code FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_category_code
			 ,(SELECT TOP 1   s.category_name FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_category_name
			 ,(SELECT TOP 1   m.Category_name FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_category_name
			 ,(SELECT TOP 1 CBN_Code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       CBN_Code1
			 ,(SELECT TOP 1 CBN_Code2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)			  CBN_Code2
			 ,(SELECT TOP 1 CBN_Code3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)  CBN_Code3
			 ,(SELECT TOP 1 CBN_Code4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)	  CBN_Code4
			 
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
,Date_Modified    Date_Modified
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
,extended_trans_type    extended_trans_type
,fee  fee
,Fee_amount_id    Fee_amount_id
, (SELECT TOP 1   m.Fee_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_fee_cap
			 ,(SELECT TOP 1   s.Fee_Cap  FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_visa_fee_cap
,r.Fee_Cap  reward_fee_cap
,Fee_config_set_id      Fee_config_set_id
,Fee_config_state Fee_config_state
,Fee_description  Fee_description
,Fee_Discount     Fee_Discount
,Fee_fee_id Fee_fee_id
,fee_id     fee_id
,Fee_name   Fee_name
,Fee_se_id  Fee_se_id
,(SELECT TOP 1   m.fee_type FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_fee_type
			 ,(SELECT TOP 1   s.fee_type FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_category_visa_fee_type
			 
,Fee_type journal_fee_type
,fee_value_id     fee_value_id
,granularity_element    granularity_element
,(SELECT TOP 1   m.Merchant_Disc FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_merch_discount
			 ,(SELECT TOP 1   s.Merchant_Disc FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_category_visa_merch_discount
			 
,merchant_id      merchant_id
,merchant_type    merchant_type
,nt_fee     nt_fee
,nt_fee_acc_post_id     nt_fee_acc_post_id
,nt_fee_id  nt_fee_id
,nt_fee_value_id  nt_fee_value_id
,pan  pan
,post_tran_cust_id      post_tran_cust_id
,post_tran_id     post_tran_id   
        from (SELECT * from ##TEMP_POST_TRAN_DATA_LOCAL PT (NOLOCK)  JOIN
##TEMP_JOURNAL_DATA_LOCAL J (nolock) on
pt.pt_post_tran_id = j.post_tran_id AND pt.pt_message_type IN ('0200','0220')
join
##settle_tran_details s (nolock) on s.ptid = pt.pt_post_tran_id) pt

LEFT JOIN  tbl_merchant_account mrch(NOLOCK)
ON 
pt.ptc_card_acceptor_id_code = mrch.card_acceptor_id_code

left JOIN tbl_merchant_category m (NOLOCK)
                        ON PT.PTC_merchant_type = m.category_code   
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
                                             