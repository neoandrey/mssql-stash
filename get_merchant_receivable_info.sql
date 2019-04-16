SELECT 
	pan,
	card_acceptor_id_code,
	card_acceptor_name_loc,
	merchant_type,
	tran_date_time,
	terminal_id,
	system_trace_audit_nr,
	tran_amt_req,
	tran_amt_rsp,
	retrieval_reference_nr,
	dbo.calculate_msc(merchant_type,tran_amt_req,settle_currency_code) msc, 
	tran_amt_req - msc merchant_receivable,
	tran_type_description,
	approval_code_description,
	card_brand,
	authorization_id_code,
	terminal_owner
FROM 

	isw_data_switchoffice isw(nolock)

