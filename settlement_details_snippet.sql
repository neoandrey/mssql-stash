


,  (SELECT TOP  1 sdi_tran_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)     sdi_tran_id
,(SELECT TOP  1 se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)        se_id
,(SELECT TOP  1 session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id) session_id
,(SELECT TOP 1   SORT_CODE FROM  tbl_PTSP_Account PA(nolock) join tbl_PTSP ptsp (NOLOCK) on  PTSP.PTSP_code = PA.PTSP_code and  PT.PTC_terminal_id = PTSP.terminal_id)    Sort_Code
,(SELECT TOP  1 spay_session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)  spay_session_id
,(SELECT TOP  1 spst_session_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)

  spst_session_id
,(SELECT TOP 1   stan FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													) stan
,tag  tag
, (SELECT TOP 1   terminal_id FROM  tbl_PTSP PTSP (nolock) where  PT.PTC_terminal_id = PTSP.terminal_id)      ptsp_terminal_id
,(SELECT TOP 1   Y.terminal_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)	reward_terminal_id
																,
(SELECT TOP 1   terminal_mode FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  ) terminal_mode
,(SELECT TOP 1   Y.trans_date FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code) trans_date
,(SELECT TOP 1   Y.txn_id FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)     txn_id
,(SELECT TOP 1   mer.category_code FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code)web_category_code
,(SELECT TOP 1   mer.category_name FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code ) web_category_name
, (SELECT TOP 1   mer.fee_type FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )  web_fee_type
, (SELECT TOP 1   mer.merchant_disc FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )   web_merchant_disc
,(SELECT TOP 1   mer.amount_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )    web_amount_cap
,(SELECT TOP 1   mer.fee_cap FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )     web_fee_cap
, (SELECT TOP 1   mer.bearer FROM  tbl_merchant_category_web mer (NOLOCK) WHERE PT.PTC_merchant_type = mer.category_code )     web_bearer
, (SELECT TOP 1   ow.terminal_id FROM  tbl_terminal_owner ow (nolock) WHERE PT.PTC_terminal_id = ow.terminal_id  )   owner_terminal_id
,(SELECT TOP 1   ow.Terminal_code FROM  tbl_terminal_owner ow (nolock) WHERE PT.PTC_terminal_id = ow.terminal_id  )  owner_terminal_code
,(SELECT TOP  1 acc_post_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
 acc_post_id
,
(SELECT TOP 1   Account_Name FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
      Account_Name
,(SELECT TOP 1   account_nr FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
  account_nr
,(SELECT TOP 1 acquirer_inst_id1 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id1
,(SELECT TOP 1 acquirer_inst_id2 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id2
,(SELECT TOP 1 acquirer_inst_id3 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id3
,(SELECT TOP 1 acquirer_inst_id4 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id4
,(SELECT TOP 1 acquirer_inst_id5 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id5
,(SELECT TOP 1   Acquiring_bank FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
     Acquiring_bank
,(SELECT TOP 1   acquiring_inst_id_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													) acquiring_inst_id_code
,(SELECT TOP 1   Addit_charge FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)     Addit_charge
,(SELECT TOP 1   Addit_party FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)        Addit_party
,adj_id     adj_id
,j.amount   journal_amount
,(SELECT TOP 1    amount FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)  xls_amount
,Amount_amount_id Amount_amount_id
,(SELECT TOP 1   m.Amount_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)     merch_cat_amount_cap
,(SELECT TOP 1   s.amount_cap FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )    merch_cat_visa_amount_cap
,(SELECT TOP 1   r.amount_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
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
,(SELECT TOP 1   Authorized_Person FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
       Authorized_Person
,(SELECT TOP 1 BANK_CODE FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						
	  ACC_BANK_CODE
,(SELECT TOP 1 bank_code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       BANK_CODE1
,(SELECT TOP 1 BANK_INSTITUTION_NAME FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)				  BANK_INSTITUTION_NAME
,(SELECT TOP 1   m.bearer FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_bearer
,(SELECT TOP 1   s.bearer FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_bearer
,business_date    business_date
,(SELECT TOP 1   card_acceptor_id_code FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
   card_acceptor_id_code
,PTc_card_acceptor_name_loc card_acceptor_name_loc
,(SELECT TOP 1   cashier_acct FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)     cashier_acct
,(SELECT TOP 1   cashier_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)       cashier_code
,(SELECT TOP 1   cashier_ext_trans_code FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)   cashier_ext_trans_code
,(SELECT TOP 1   cashier_name FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)      cashier_name
,(SELECT TOP 1   s.category_code FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )   merch_cat_visa_category_code
, (SELECT TOP 1   m.Category_Code FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_category_code
,(SELECT TOP 1   s.category_name FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_category_name
,(SELECT TOP 1   m.Category_name FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_category_name
,(SELECT TOP 1 CBN_Code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       CBN_Code1
,(SELECT TOP 1 CBN_Code2 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)			  CBN_Code2
,(SELECT TOP 1 CBN_Code3 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)  CBN_Code3
,(SELECT TOP 1 CBN_Code4 FROM aid_cbn_code acc (NOLOCK) WHERE	(pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)	  CBN_Code4
,(SELECT TOP  1 coa_coa_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
  coa_coa_id
,    coa_config_set_id
,(SELECT TOP  1 coa_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
    coa_config_state
,(SELECT TOP  1 coa_description FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
     coa_description
,(SELECT TOP  1 coa_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
        coa_id
,(SELECT TOP  1 coa_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
        coa_name
,(SELECT TOP  1 coa_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      coa_se_id
,(SELECT TOP  1 coa_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      coa_type
,(SELECT TOP  1 config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
       config_set_id
,(SELECT TOP  1 credit_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      credit_acc_id
,(SELECT TOP  1 credit_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
     credit_acc_nr_id
,(SELECT TOP  1 credit_cardholder_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      credit_cardholder_acc_id
,(SELECT TOP  1 credit_cardholder_acc_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      credit_cardholder_acc_type
,(SELECT TOP  1 CreditAccNr_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
         CreditAccNr_acc_id
,(SELECT TOP  1 CreditAccNr_acc_nr FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
        CreditAccNr_acc_nr
,(SELECT TOP  1 CreditAccNr_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
     CreditAccNr_acc_nr_id
,(SELECT TOP  1 CreditAccNr_aggregation_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      CreditAccNr_aggregation_id
,(SELECT TOP  1 CreditAccNr_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      CreditAccNr_config_set_id
,(SELECT TOP  1 CreditAccNr_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
           CreditAccNr_config_state
,(SELECT TOP  1 CreditAccNr_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
           CreditAccNr_se_id
,(SELECT TOP  1 CreditAccNr_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
            CreditAccNr_state
,(SELECT TOP 1   Date_Modified FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  )
     Date_Modified
,(SELECT TOP  1 debit_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
              debit_acc_id
,(SELECT TOP  1 debit_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
          debit_acc_nr_id
,(SELECT TOP  1 debit_cardholder_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
            debit_cardholder_acc_id
,(SELECT TOP  1 debit_cardholder_acc_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
               debit_cardholder_acc_type
,(SELECT TOP  1 DebitAccNr_acc_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
        DebitAccNr_acc_id
,(SELECT TOP  1 DebitAccNr_acc_nr FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
        DebitAccNr_acc_nr
,(SELECT TOP  1 DebitAccNr_acc_nr_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
          DebitAccNr_acc_nr_id
,(SELECT TOP  1 DebitAccNr_aggregation_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
             DebitAccNr_aggregation_id
,(SELECT TOP  1 DebitAccNr_config_set_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                 DebitAccNr_config_set_id
,(SELECT TOP  1 DebitAccNr_config_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                 DebitAccNr_config_state
,(SELECT TOP  1 DebitAccNr_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                 DebitAccNr_se_id
,(SELECT TOP  1 DebitAccNr_state FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                 DebitAccNr_state
,(SELECT TOP  1 entry_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                  entry_id
,(SELECT TOP 1   extended_trans_type FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)    extended_trans_type
,(SELECT TOP  1 fee FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
              fee
,(SELECT TOP  1 Fee_amount_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                 Fee_amount_id
, (SELECT TOP 1   m.Fee_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_fee_cap
,(SELECT TOP 1   s.Fee_Cap  FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_visa_fee_cap
,(SELECT TOP 1   r.fee_cap FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code) reward_fee_cap
,Fee_config_set_id      Fee_config_set_id
,Fee_config_state Fee_config_state
,Fee_description  Fee_description
,(SELECT TOP 1   Fee_Discount FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)     Fee_Discount
,(SELECT TOP  1 Fee_fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
  Fee_fee_id
,(SELECT TOP  1 fee_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
      fee_id
,(SELECT TOP  1 Fee_name FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
        Fee_name
,(SELECT TOP  1 Fee_se_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
         Fee_se_id
,(SELECT TOP 1   m.fee_type FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_fee_type
,(SELECT TOP 1   s.fee_type FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_category_visa_fee_type
, (SELECT TOP  1 Fee_type FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
         journal_fee_type
,(SELECT TOP  1 fee_value_id FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
             fee_value_id
,(SELECT TOP  1 granularity_element FROM  ##temp_journal_data_local  J (NOLOCK) WHERE  J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
    granularity_element
,(SELECT TOP 1   m.Merchant_Disc FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_merch_discount
,(SELECT TOP 1   s.Merchant_Disc FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_category_visa_merch_discount
,(SELECT TOP 1   merchant_id FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)       merchant_id
,(SELECT TOP 1   merchant_type FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)    merchant_type
,nt_fee     nt_fee
,nt_fee_acc_post_id     nt_fee_acc_post_id
,nt_fee_id  nt_fee_id
,nt_fee_value_id  nt_fee_value_id
,(SELECT TOP 1   pan FROM Reward_Category r (NOLOCK) JOIN  (SELECT TOP 1   * FROM tbl_xls_settlement y (NOLOCK) WHERE y.terminal_id  NOT IN(SELECT TOP 1   terminal_id from tbl_reward_OutOfBand (NOLOCK)) AND (PT.PTC_terminal_id= y.terminal_id  AND PT.PT_retrieval_reference_nr = y.rr_number   
													            AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
																AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
																= substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))
													)Y ON y.extended_trans_type = r.reward_code)  pan
,post_tran_cust_id      
,post_tran_id   INTO ##final_results_tables    FROM 
						     ##settle_tran_details report_results (nolock)
							 JOIN ##temp_post_tran_data_local PT 
							on PT.PT_post_tran_id = report_results.PTID 
							   