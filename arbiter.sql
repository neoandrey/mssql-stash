USE [arbiter]
GO
  --DISABLE TRIGGER SCHEMA_AUDIT ON arbiter;
  
  --DISABLE TRIGGER SCHEMA_AUDIT ON ALL SERVER
  
 
/****** Object:  Index [idx_datetime_req_new]    Script Date: 07/04/2014 18:39:49 ******/
CREATE NONCLUSTERED INDEX [idx_datetime_req_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[datetime_req] ASC
) ON [arbiter_filegroup_2]
GO


/****** Object:  Index [idx_masked_pan_new]    Script Date: 07/04/2014 18:41:14 ******/
CREATE NONCLUSTERED INDEX [idx_masked_pan_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[masked_pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]
GO


/****** Object:  Index [idx_stan_new]    Script Date: 07/04/2014 18:42:11 ******/
CREATE NONCLUSTERED INDEX [idx_stan_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[system_trace_audit_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]





CREATE NONCLUSTERED INDEX [ix_all_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[system_trace_audit_nr] ASC,
	[masked_pan] ASC,
	[datetime_req] ASC
)
INCLUDE ( [postilion_office_transactions_id],
[issuer_code],
[post_tran_id],
[post_tran_cust_id],
[tran_nr],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[tran_type_description],
[tran_amount_req],
[tran_fee_req],
[currency_alpha_code],
[retrieval_reference_nr],
[acquirer_code],
[rsp_code_rsp],
[terminal_owner],
[sink_node_name],
[merchant_type],
[source_node_name],
[from_account_id],
[tran_tran_fee_req]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]
GO


USE [arbiter]
GO

/****** Object:  Index [idx_datetime_req_new]    Script Date: 07/04/2014 18:39:49 ******/
CREATE NONCLUSTERED INDEX [idx_datetime_req_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]
GO


/****** Object:  Index [idx_masked_pan_new]    Script Date: 07/04/2014 18:41:14 ******/
CREATE NONCLUSTERED INDEX [idx_masked_pan_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[masked_pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]
GO


/****** Object:  Index [idx_stan_new]    Script Date: 07/04/2014 18:42:11 ******/
CREATE NONCLUSTERED INDEX [idx_stan_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[system_trace_audit_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]




CREATE NONCLUSTERED INDEX [ix_all_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[system_trace_audit_nr] ASC,
	[masked_pan] ASC,
	[datetime_req] ASC
)
INCLUDE ( [postilion_office_transactions_id],
[issuer_code],
[post_tran_id],
[post_tran_cust_id],
[tran_nr],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[tran_type_description],
[tran_amount_req],
[tran_fee_req],
[currency_alpha_code],
[retrieval_reference_nr],
[acquirer_code],
[rsp_code_rsp],
[terminal_owner],
[sink_node_name],
[merchant_type],
[source_node_name],
[from_account_id],
[tran_tran_fee_req]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]
GO


/****** Object:  Index [ix_all_2_new]    Script Date: 07/04/2014 18:44:25 ******/
CREATE NONCLUSTERED INDEX [ix_all_2_new] ON [dbo].[tbl_postilion_office_transactions_new] 
(
	[masked_pan] ASC,
	[datetime_req] ASC
)
INCLUDE ( [postilion_office_transactions_id],
[issuer_code],
[post_tran_id],
[post_tran_cust_id],
[tran_nr],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[tran_type_description],
[tran_amount_req],
[tran_fee_req],
[currency_alpha_code],
[system_trace_audit_nr],
[retrieval_reference_nr],
[acquirer_code],
[rsp_code_rsp],
[terminal_owner],
[sink_node_name],
[merchant_type],
[source_node_name],
[from_account_id],
[tran_tran_fee_req]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]
GO


 --ENABLE TRIGGER SCHEMA_AUDIT ON arbiter;