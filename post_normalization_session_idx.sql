USE [postilion_office]
GO

/****** Object:  Index [post_normalization_session_idx]    Script Date: 10/28/2014 09:43:33 ******/
CREATE NONCLUSTERED INDEX [post_normalization_session_idx] ON [dbo].[post_normalization_session] 
(
	[datetime_creation] ASC
)
INCLUDE ( [first_post_tran_cust_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = OFF, ALLOW_PAGE_LOCKS  = OFF) ON [PRIMARY]
GO


