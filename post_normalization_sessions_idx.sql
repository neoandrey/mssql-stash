USE [postilion_office]
GO
ALTER INDEX [post_normalization_session_idx] ON [dbo].[post_normalization_session] REBUILD WITH ( PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, ALLOW_ROW_LOCKS  = OFF, ALLOW_PAGE_LOCKS  = OFF, SORT_IN_TEMPDB = OFF, ONLINE = ON )
GO
