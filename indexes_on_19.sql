USE [postilion_office]
GO

/****** Object:  Index [indx_post_tran_10]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_post_tran_10] ON [dbo].[post_tran_summary_20160605] 
(
	[post_tran_cust_id] ASC
)INCLUDE ( [post_tran_id],
[recon_business_date],
[source_node_name],
[pan],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_post_tran_12]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_post_tran_12] ON [dbo].[post_tran_summary_20160605] 
(
	[post_tran_cust_id] ASC,
	[tran_postilion_originated] ASC,
	[tran_completed] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_15]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_15] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_16]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_16] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[prev_tran_approved],
[extended_tran_type],
[payee]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO
/****** Object:  Index [indx_tran_post_18]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_18] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_post_19]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_post_19] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postmessage_t_7]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postmessage_t_7] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[acquiring_inst_id_code] ASC,
	[message_type] ASC,
	[terminal_id] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[auth_id_rsp],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[tran_cash_req],
[tran_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_owner],
[card_acceptor_id_code],
[merchant_type],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO


/****** Object:  Index [indx_tran_postrecon_bus_23]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postrecon_bus_23] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[terminal_id] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[source_node_name],
[pan],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_1]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_1] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[sink_node_name] ASC,
	[message_type] ASC,
	[tran_type] ASC,
	[source_node_name] ASC,
	[terminal_id] ASC,
	[totals_group] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[system_trace_audit_nr],
[rsp_code_rsp],
[auth_id_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[tran_cash_req],
[tran_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee],
[pan],
[terminal_owner],
[card_acceptor_id_code],
[merchant_type],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_2]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_2] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[acquiring_inst_id_code] ASC,
	[sink_node_name] ASC,
	[message_type] ASC,
	[tran_type] ASC,
	[merchant_type] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[system_trace_audit_nr],
[rsp_code_rsp],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee],
[receiving_inst_id_code],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_3]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_3] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[sink_node_name] ASC,
	[message_type] ASC,
	[tran_type] ASC,
	[merchant_type] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee],
[receiving_inst_id_code],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_4]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_4] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[sink_node_name] ASC,
	[tran_type] ASC,
	[source_node_name] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[message_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_5]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_5] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[sink_node_name] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[prev_tran_approved],
[extended_tran_type],
[payee]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_postsink_node_6]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postsink_node_6] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[sink_node_name] ASC,
	[tran_type] ASC,
	[source_node_name] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[message_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_posttran_type_20]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_posttran_type_20] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type],
[payee]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_posttran_type_21]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_posttran_type_21] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC,
	[source_node_name] ASC
)
INCLUDE ( [post_tran_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[recon_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[extended_tran_type],
[payee],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [indx_tran_posttran_type_22]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [indx_tran_posttran_type_22] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC,
	[source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [is_post_tran_20160606_summary_3]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [is_post_tran_20160606_summary_3] ON [dbo].[post_tran_summary_20160605] 
(
	[sink_node_name] ASC,
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[message_type] ASC,
	[tran_type] ASC,
	[rsp_code_rsp] ASC,
	[message_reason_code] ASC,
	[datetime_req] ASC,
	[recon_business_date] ASC,
	[tran_reversed] ASC,
	[extended_tran_type] ASC,
	[source_node_name] ASC,
	[terminal_id] ASC,
	[terminal_owner] ASC,
	[merchant_type] ASC,
	[totals_group] ASC
)
INCLUDE ( [post_tran_cust_id],
[system_trace_audit_nr],
[auth_id_rsp],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[tran_amount_req],
[tran_amount_rsp],
[settle_amount_impact],
[tran_cash_req],
[tran_cash_rsp],
[tran_currency_code],
[tran_tran_fee_req],
[tran_tran_fee_rsp],
[tran_tran_fee_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_req],
[settle_tran_fee_rsp],
[settle_currency_code],
[online_system_id],
[card_seq_nr],
[expiry_date],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_10]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_20160606_summary_10] ON [dbo].[post_tran_summary_20160605] 
(
	[datetime_tran_local] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_2]    Script Date: 06/06/2016 12:41:18 ******/
CREATE CLUSTERED INDEX [ix_post_tran_20160606_summary_2] ON [dbo].[post_tran_summary_20160605] 
(
	[post_tran_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_4]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_20160606_summary_4] ON [dbo].[post_tran_summary_20160605] 
(
	[tran_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_5]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_20160606_summary_5] ON [dbo].[post_tran_summary_20160605] 
(
	[retrieval_reference_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_6]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_20160606_summary_6] ON [dbo].[post_tran_summary_20160605] 
(
	[pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_7]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_20160606_summary_7] ON [dbo].[post_tran_summary_20160605] 
(
	[receiving_inst_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_8]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_20160606_summary_8] ON [dbo].[post_tran_summary_20160605] 
(
	[message_reason_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_20160606_summary_9]    Script Date: 06/06/2016 12:41:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_20160606_summary_9] ON [dbo].[post_tran_summary_20160605] 
(
	[payee] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
GO


