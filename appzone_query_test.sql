SELECT 
	 trn.post_tran_id
	,trn.post_tran_cust_id
	,trn.tran_nr
	,trn.datetime_req
	,trn.datetime_rsp
	,trn.rsp_code_req
	,trn.rsp_code_rsp
	,trn.sink_node_name
	,cst.source_node_name
	,trn.message_type
	,trn.datetime_req
	,trn.datetime_rsp
	,cst.terminal_id
	,trn.from_account_type
	,trn.to_account_type
	,trn.from_account_id
	,trn.to_account_id
	,trn.tran_amount_req
	,trn.tran_amount_rsp
	,trn.settle_amount_req
	,trn.settle_amount_rsp
	,cst.pan
	,trn.tran_type
	,trn.system_trace_audit_nr
	,NULL  --trn.from_account_id_cs
    ,NULL --trn.to_account_id_cs
    ,trn.from_account_type_qualifier
	,trn.to_account_type_qualifier
	,trn.bank_details
FROM [postilion_office].dbo.post_tran trn  WITH (NOLOCK) 
JOIN [postilion_office].dbo.post_tran_cust  cst WITH (NOLOCK) 
ON trn.post_tran_cust_id = cst.post_tran_cust_id
WHERE 
     trn.rsp_code_rsp =61
AND
    trn.message_type =200
AND 
     trn.datetime_req BETWEEN '2013-10-01' AND GETDATE()
AND 
    trn.sink_node_name= 'DBLAPZsnk'