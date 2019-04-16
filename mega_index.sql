
/****** Object:  Index [indx_message_t_6]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_11] ON [dbo].['+@table_name+'] 
(
	[message_type] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]



/****** Object:  Index [indx_post_tran_11]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_12] ON [dbo].['+@table_name+'] 
(
	[post_tran_cust_id] ASC
)
INCLUDE ( [post_tran_id],
[tran_amount_req]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]


/****** Object:  Index [indx_post_tran_9]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_13] ON [dbo].['+@table_name+'] 
(
	[post_tran_cust_id] ASC,
	[tran_postilion_originated] ASC,
	[message_type] ASC
)
INCLUDE ( 
[post_tran_id],
[system_trace_audit_nr],
[datetime_req],
[tran_amount_req],
[tran_currency_code],
[settle_amount_req],
[settle_currency_code]
[tran_type],
[auth_id_rsp],
[retrieval_reference_nr],
[from_account_id],
[extended_tran_type],
[pan],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_14] ON [dbo].['+@table_name+'] 
(
	[rsp_code_rsp] ASC,
	[message_type] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[tran_reversed]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_15] ON [dbo].['+@table_name+'] 
(
	[sink_node_name] ASC,
	[message_type] ASC,
	[rsp_code_req] ASC,
	[abort_rsp_code] ASC,
	[recon_business_date] ASC,
	[tran_amount_req] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[tran_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_'+@table_name+_16] ON [dbo].['+@table_name+'] 
(
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[tran_currency_code] ASC,
	[tran_reversed] ASC,

)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[auth_id_rsp],
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
[merchant_type],
[card_acceptor_name_loc]


) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_17] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[message_type] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[tran_type],
[system_trace_audit_nr],
[auth_id_rsp],
[retrieval_reference_nr],
[datetime_req],
[from_account_id],
[tran_amount_req],
[tran_currency_code],
[settle_amount_req],
[settle_currency_code],
[extended_tran_type],
[pan],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

/****** Object:  Index [indx_tran_post_3]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_18] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[tran_currency_code] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[message_type],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[auth_id_rsp],
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
[tran_reversed],
[extended_tran_type],
[payee],
[source_node_name],
[pan],
[terminal_id],
[terminal_owner],
[card_acceptor_id_code],
[merchant_type],
[card_acceptor_name_loc]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]



/****** Object:  Index [indx_tran_postmessage_t_15]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_19] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[message_type] ASC,
	[source_node_name] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[tran_type],
[tran_nr],
[system_trace_audit_nr],
[rsp_code_rsp],
[auth_id_rsp],
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
[pan],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[pan_encrypted]
) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_20] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[tran_currency_code] ASC,
	[tran_reversed] ASC,
	[message_type] ASC,
	[tran_amount_rsp] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[tran_type],
[system_trace_audit_nr],
[rsp_code_rsp],
[auth_id_rsp],
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
[merchant_type],
[card_acceptor_name_loc]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]


/****** Object:  Index [indx_tran_postmessage_t_18]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_21] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[tran_type] ASC,
	[recon_business_date] ASC,
	[settle_currency_code] ASC,
	[message_type] ASC,
	[source_node_name] ASC,
	[pan] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[tran_nr],
[system_trace_audit_nr],
[rsp_code_rsp],
[auth_id_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[from_account_id],
[settle_amount_impact],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[extended_tran_type],
[terminal_id],
[card_acceptor_id_code],
[card_acceptor_name_loc],
[totals_group],
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]


/****** Object:  Index [indx_tran_postmessage_t_8]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_22] ON [dbo].['+@table_name+'] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[message_type] ASC,
	[source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]


/****** Object:  Index [is_post_tran_20160530_summary_3]    Script Date: 06/09/2016 13:28:01 ******/
CREATE NONCLUSTERED INDEX [ix_'+@table_name+'_23] ON [dbo].['+@table_name+'] 
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
[pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
