SELECT report_results.bank_code,
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
report_results.index_no,
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
  ,(SELECT PTSP_Account_Nr FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PT.PTC_terminal_id = PTSP.terminal_id)   PTSP_Account_Nr
,(SELECT ptsp_code FROM  tbl_PTSP PTSP (nolock) where  PT.PTC_terminal_id = PTSP.terminal_id)  ptsp_code
, (SELECT pa.PTSP_Code FROM  tbl_PTSP_Account PA(nolock) join  tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PT.PTC_terminal_id = PTSP.terminal_id )   account_PTSP_Code
,(SELECT PTSP_Name FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PT.PTC_terminal_id = PTSP.terminal_id)    PTSP_Name
,(SELECT rdm_amt FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)    rdm_amt
,(SELECT Reward_Code FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)       Reward_Code
,(SELECT Reward_discount FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)     Reward_discount
,(SELECT rr_number FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)  rr_number
,sdi_tran_id      sdi_tran_id
,se_id      se_id
,session_id session_id
,(SELECT SORT_CODE FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PT.PTC_terminal_id = PTSP.terminal_id)    Sort_Code
,spay_session_id  spay_session_id
,spst_session_id  spst_session_id
,(SELECT stan FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													) stan
,tag  tag
, (SELECT terminal_id FROM  tbl_PTSP PTSP (nolock) where  PT.PTC_terminal_id = PTSP.terminal_id)      ptsp_terminal_id
,(SELECT Y.terminal_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)	reward_terminal_id
																,
(SELECT terminal_mode FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  ) terminal_mode
,(SELECT Y.trans_date FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code) trans_date
,(SELECT Y.txn_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)     txn_id
,(SELECT mer.category_code FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code)web_category_code
,(SELECT mer.category_name FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code ) web_category_name
, (SELECT mer.fee_type FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )  web_fee_type
, (SELECT mer.merchant_disc FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )   web_merchant_disc
,(SELECT mer.amount_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )    web_amount_cap
,(SELECT mer.fee_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )     web_fee_cap
, (SELECT mer.bearer FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )     web_bearer
, (SELECT ow.terminal_id FROM  tbl_terminal_owner ow (nolock) WHERE PT.PTC_terminal_id = ow.terminal_id  )   owner_terminal_id
,(SELECT ow.Terminal_code FROM  tbl_terminal_owner ow (nolock) WHERE PT.PTC_terminal_id = ow.terminal_id  )  owner_terminal_code
,acc_post_id acc_post_id
,
(SELECT Account_Name FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
      Account_Name
,(SELECT account_nr FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
  account_nr
,acquirer_inst_id1      acquirer_inst_id1
,acquirer_inst_id2      acquirer_inst_id2
,acquirer_inst_id3      acquirer_inst_id3
,acquirer_inst_id4      acquirer_inst_id4
,acquirer_inst_id5      acquirer_inst_id5
,(SELECT Acquiring_bank FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
     Acquiring_bank
,acquiring_inst_id_code acquiring_inst_id_code
,Addit_charge     Addit_charge
,Addit_party      Addit_party
,adj_id     adj_id
,j.amount   journal_amount
,(SELECT  amount FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)  xls_amount
,Amount_amount_id Amount_amount_id
,(SELECT m.Amount_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)     merch_cat_amount_cap
,(SELECT s.amount_cap FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )    merch_cat_visa_amount_cap
,(SELECT r.amount_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)    reward_amount_cap
,Amount_config_set_id   Amount_config_set_id
,Amount_config_state    Amount_config_state
,Amount_description     Amount_description
,amount_id  amount_id
,Amount_name      Amount_name
,Amount_se_id     Amount_se_id
,amount_value_id  amount_value_id
,Authorized_Person      Authorized_Person
,ACC.BANK_CODE  ACC_BANK_CODE
,BANK_CODE1 BANK_CODE1
,BANK_INSTITUTION_NAME  BANK_INSTITUTION_NAME
,(SELECT m.bearer FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_bearer
,(SELECT s.bearer FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_bearer
,business_date    business_date
,card_acceptor_id_code  card_acceptor_id_code
,card_acceptor_name_loc card_acceptor_name_loc
,cashier_acct     cashier_acct
,cashier_code     cashier_code
,cashier_ext_trans_code cashier_ext_trans_code
,cashier_name     cashier_name
,(SELECT s.category_code FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )   merch_cat_visa_category_code
, (SELECT m.Category_Code FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_category_code
,(SELECT s.categoty_name FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_category_name
,(SELECT m.Category_name FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_category_name
,CBN_Code1  CBN_Code1
,CBN_Code2  CBN_Code2
,CBN_Code3  CBN_Code3
,CBN_Code4  CBN_Code4
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
, (SELECT m.Fee_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_fee_cap
,(SELECT s.Fee_Cap  FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_visa_fee_cap
,(SELECT r.fee_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code) reward_fee_cap
,Fee_config_set_id      Fee_config_set_id
,Fee_config_state Fee_config_state
,Fee_description  Fee_description
,Fee_Discount     Fee_Discount
,Fee_fee_id Fee_fee_id
,fee_id     fee_id
,Fee_name   Fee_name
,Fee_se_id  Fee_se_id
,(SELECT m.fee_type FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_fee_type
,(SELECT s.fee_type FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_category_visa_fee_type
,j.Fee_type journal_fee_type
,fee_value_id     fee_value_id
,granularity_element    granularity_element
,(SELECT m.Merchant_Disc FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_merch_discount
,(SELECT s.Merchant_Disc FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_category_visa_merch_discount
,merchant_id      merchant_id
,merchant_type    merchant_type
,nt_fee     nt_fee
,nt_fee_acc_post_id     nt_fee_acc_post_id
,nt_fee_id  nt_fee_id
,nt_fee_value_id  nt_fee_value_id
,(SELECT pan FROM Reward_Category r (NOLOCK) JOIN  (SELECT * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)  pan
,post_tran_cust_id      post_tran_cust_id
,post_tran_id     post_tran_id       FROM 
						     ##settle_tran_details report_results (nolock)
							 JOIN ##temp_post_tran_data_local PT 
							on PT.PT_post_tran_id = report_results.PTID 
							    join ##temp_journal_data_local  J (NOLOCK) ON ( J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)   
							LEFT OUTER JOIN aid_cbn_code acc ON
							(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))							
							--left join tbl_PTSP PTSP(nolock) on (PT.PTC_terminal_id = PTSP.terminal_id)
							--left join tbl_PTSP_Account PA(nolock) on (PTSP.PTSP_code = PA.PTSP_code)
							--left JOIN tbl_merchant_category m (NOLOCK)
							--						ON PT.PTC_merchant_type = m.category_code 
							--						left JOIN tbl_merchant_category_visa s (NOLOCK)
							--						ON PT.PTC_merchant_type = s.category_code 
							--						left JOIN tbl_merchant_account a (NOLOCK)
							--						ON PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code   
							--						left JOIN  (SELECT * FROM tbl_xls_settlement a (NOLOCK) WHERE a.terminal_id
							--						 NOT IN(select terminal_id from tbl_reward_OutOfBand (NOLOCK)))y
							--						ON (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
							--						            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
							--									AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
							--									= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
							--						left JOIN Reward_Category r (NOLOCK)
							--								ON y.extended_trans_type = r.reward_code
							--						   left JOIN tbl_merchant_category_web mer (NOLOCK)
							--												ON PT.PTC_merchant_type = mer.category_code 
							--											 LEFT JOIN tbl_terminal_owner ow ON PT.PTC_terminal_id = ow.terminal_id  
																		 OPTION(RECOMPILE, MAXDOP 8)