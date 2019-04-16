USE appzone_temp;
GO

INSERT INTO [ASPOFFICE64].[appzone_temp].[dbo].[appzone_post_tran_temp](
     post_tran_id
	,post_tran_cust_id
	,tran_nr
	,datetime_req
	,rsp_code_req
	,rsp_code_rsp
	,sink_node_name
	,source_node_name
	,message_type
	,datetime_req
	,datetime_rsp
	,terminal_id
	,from_account_type
	,to_account_type
	,from_account_id
	,to_account_id
	,tran_amount_req
	,tran_amount_rsp
	,settle_amount_req
	,settle_amount_rsp
	,pan
	,tran_type
	,system_trace_audit_nr
	,from_account_id_cs
    ,to_account_id_cs
    ,from_account_type_qualifier
	,to_account_type_qualifier
	,bank_details)
SELECT 
	 trn.post_tran_id
	,trn.post_tran_cust_id
	,trn.tran_nr
	,trn.datetime_req
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
	,trn.from_account_id_cs
    ,trn.to_account_id_cs
    ,trn.from_account_type_qualifier
	,trn.to_account_type_qualifier
	,trn.bank_details
FROM [172.25.15.10].[postilion_office].dbo.post_tran trn  WITH (NOLOCK) 
JOIN [172.25.15.10].[postilion_office].dbo.post_tran_cust  cst WITH (NOLOCK) 
ON trn.post_tran_cust_id = cst.post_tran_cust_id
WHERE 
     trn.rsp_code_rsp =61
AND
    trn.message_type =200
AND 
     trn.datetime_req BETWEEN '2013-10-01' AND GETDATE()
AND 
    trn.sink_node_name= 'DBLAPZsnk'
 AND 
 trn.post_tran_id NOT IN (SELECT post_tran_id FROM  [ASPOFFICE64].[appzone_temp].[dbo].appzone_post_tran_temp)

