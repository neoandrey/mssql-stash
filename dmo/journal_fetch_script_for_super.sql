

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
	INTO temp_journal_data
	FROM
	dbo.sstl_journal_all AS J (NOLOCK)
		JOIN (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@from_date, @to_date))rdate
	ON (rdate.recon_business_date = J.business_date) 
	OPTION(recompile)
	