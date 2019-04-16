USE [postilion_office]
GO


/****** Object:  Index [ix_post_tran_summary_201601_1]    Script Date: 05/16/2016 16:30:06 ******/
CREATE UNIQUE  NONCLUSTERED INDEX [ix_post_tran_summary_201601_1] ON [dbo].[post_tran_summary_201601] 
(
	[post_tran_id] ASC, post_tran_cust_id, tran_nr,retrieval_reference_nr, system_trace_audit_nr, recon_business_date,datetime_tran_local ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO


/****** Object:  Index [ix_post_tran_summary_201601_1]    Script Date: 05/16/2016 16:30:06 ******/
CREATE UNIQUE  NONCLUSTERED INDEX [ix_post_tran_summary_201601_14] ON [dbo].[post_tran_summary_201601] 
(
	[post_tran_id] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO



/****** Object:  Index [ix_post_tran_summary_201601_2]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_2] ON [dbo].[post_tran_summary_201601] 
(
	[post_tran_cust_id] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

/****** Object:  Index [ix_post_tran_summary_201601_3]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_3] ON [dbo].[post_tran_summary_201601] 
(
	[tran_nr] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO


/****** Object:  Index [ix_post_tran_summary_201601_5]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_4] ON [dbo].[post_tran_summary_201601] 
(
	[system_trace_audit_nr] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

/****** Object:  Index [ix_post_tran_summary_201601_7]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_5] ON [dbo].[post_tran_summary_201601] 
(
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

/****** Object:  Index [ix_post_tran_summary_201601_8]    Script Date: 05/16/2016 16:30:06 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_summary_201601_6] ON [dbo].[post_tran_summary_201601] 
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
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

/****** Object:  Index [ix_post_tran_summary_201601_9]    Script Date: 05/16/2016 16:30:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_7] ON [dbo].[post_tran_summary_201601] 
(
	[recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO



USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_summary_201601_1]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_8] ON [dbo].[post_tran_summary_201601] 
(
	[pan] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

/****** Object:  Index [ix_post_tran_summary_201601_2]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_9] ON [dbo].[post_tran_summary_201601] 
(
	[terminal_id] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO
/****** Object:  Index [ix_post_tran_summary_201601_5]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_10] ON [dbo].[post_tran_summary_201601] 
(
	[card_acceptor_id_code] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO


/****** Object:  Index [ix_post_tran_summary_201601_5]    Script Date: 05/16/2016 16:30:49 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_11] ON [dbo].[post_tran_summary_201601] 
(
	[card_acceptor_name_loc] ASC,[recon_business_date] 
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_12] ON [dbo].[post_tran_summary_201601] 
(
	[retrieval_reference_nr] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

CREATE NONCLUSTERED INDEX [ix_post_tran_summary_201601_13] ON [dbo].[post_tran_summary_201601] 
(
	[payee] ASC, recon_business_date ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [JAN]
GO

