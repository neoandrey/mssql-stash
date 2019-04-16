USE [arbiter]
GO
CREATE NONCLUSTERED INDEX [idx_post_tran_cust]
ON [dbo].[tbl_postilion_office_transactions] ([post_tran_cust_id])
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [arbiter_filegroup_2]

GO
