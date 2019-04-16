USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_cust_1]    Script Date: 04/11/2016 13:47:53 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_1] ON [dbo].[post_tran_cust] 
(
	[pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_cust_2]    Script Date: 04/11/2016 13:47:53 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_2] ON [dbo].[post_tran_cust] 
(
	[terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_cust_3]    Script Date: 04/11/2016 13:47:53 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_3] ON [dbo].[post_tran_cust] 
(
	[pan_search] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_cust_4]    Script Date: 04/11/2016 13:47:53 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_4] ON [dbo].[post_tran_cust] 
(
	[pan_reference] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [ix_post_tran_cust_5]    Script Date: 04/11/2016 13:47:53 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_5] ON [dbo].[post_tran_cust] 
(
	[card_acceptor_id_code_cs] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO

/****** Object:  Index [pk_post_tran_cust]    Script Date: 04/11/2016 13:47:53 ******/
ALTER TABLE [dbo].[post_tran_cust] ADD  CONSTRAINT [pk_post_tran_cust] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


