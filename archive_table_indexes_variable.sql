
/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:06 ******/
CREATE UNIQUE  NONCLUSTERED INDEX [ix_'+@tableName+'_1] ON [dbo].['+@tableName+'] 
(
	[post_tran_id] ASC, post_tran_cust_id, tran_nr,retrieval_reference_nr, system_trace_audit_nr, recon_business_date,datetime_tran_local ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:06 ******/
CREATE UNIQUE  NONCLUSTERED INDEX [ix_'+@tableName+'_14] ON [dbo].['+@tableName+'] 
(
	[post_tran_id] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']




/****** Object:  Index [ix_'+@tableName+'_2]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_2] ON [dbo].['+@tableName+'] 
(
	[post_tran_cust_id] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_'+@tableName+'_3]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_3] ON [dbo].['+@tableName+'] 
(
	[tran_nr] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



/****** Object:  Index [ix_'+@tableName+'_5]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_4] ON [dbo].['+@tableName+'] 
(
	[system_trace_audit_nr] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_'+@tableName+'_7]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
(
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_'+@tableName+'_8]    Script Date: 05/16/2016 16:30:06 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_'+@tableName+'_6] ON [dbo].['+@tableName+'] 
(
	[tran_nr] ASC,
	[message_type] ASC,
	[tran_postilion_originated] ASC,
	[online_system_id] ASC,
	[recon_business_date] ASC,
	[tran_type] ASC,
	[terminal_id] ASC,
	[sink_node_name],
	[source_node_name],
	[tran_completed],
	[acquiring_inst_id_code],
	[card_acceptor_id_code],
	[totals_group]
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_'+@tableName+'_9]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_7] ON [dbo].['+@tableName+'] 
(
	[recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']




USE [postilion_office]


/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_8] ON [dbo].['+@tableName+'] 
(
	[pan] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_'+@tableName+'_2]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_9] ON [dbo].['+@tableName+'] 
(
	[terminal_id] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

/****** Object:  Index [ix_'+@tableName+'_5]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_10] ON [dbo].['+@tableName+'] 
(
	[card_acceptor_id_code] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



/****** Object:  Index [ix_'+@tableName+'_5]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_11] ON [dbo].['+@tableName+'] 
(
	[card_acceptor_name_loc] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_12] ON [dbo].['+@tableName+'] 
(
	[retrieval_reference_nr] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_13] ON [dbo].['+@tableName+'] 
(
	[payee] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


