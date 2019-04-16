USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_1]    Script Date: 04/11/2016 13:46:43 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_1] ON [dbo].[post_tran] 
(
	[post_tran_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_10]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_10] ON [dbo].[post_tran] 
(
	[settle_entity_id] ASC,
	[batch_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_11]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_11] ON [dbo].[post_tran] 
(
	[source_node_key] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_12]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_12] ON [dbo].[post_tran] 
(
	[from_account_id_cs] ASC,
	[datetime_tran_local] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_13]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_13] ON [dbo].[post_tran] 
(
	[to_account_id_cs] ASC,
	[datetime_tran_local] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_2]    Script Date: 04/11/2016 13:46:43 ******/
CREATE CLUSTERED INDEX [ix_post_tran_2] ON [dbo].[post_tran] 
(
	[post_tran_cust_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_3]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_3] ON [dbo].[post_tran] 
(
	[tran_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_4]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_4] ON [dbo].[post_tran] 
(
	[datetime_tran_local] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_5]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_5] ON [dbo].[post_tran] 
(
	[system_trace_audit_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_7]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_7] ON [dbo].[post_tran] 
(
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_8]    Script Date: 04/11/2016 13:46:43 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_8] ON [dbo].[post_tran] 
(
	[tran_nr] ASC,
	[message_type] ASC,
	[tran_postilion_originated] ASC,
	[online_system_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_9]    Script Date: 04/11/2016 13:46:43 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_9] ON [dbo].[post_tran] 
(
	[recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


