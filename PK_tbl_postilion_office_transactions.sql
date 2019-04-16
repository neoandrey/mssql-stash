USE [arbiter]
GO

ALTER TABLE [tbl_postilion_office_transactions] ADD  [online_system_id] INT DEFAULT 1;

UPDATE [tbl_postilion_office_transactions] SET [online_system_id] =1

/****** Object:  Index [PK_tbl_postilion_office_transactions]    Script Date: 03/31/2014 18:25:14 ******/

CREATE CLUSTERED INDEX [PK_tbl_postilion_office_transactions]
ON [dbo].[tbl_postilion_office_transactions]
( 
	[postilion_office_transactions_id] ASC, [online_system_id] ASC
)WITH (DROP_EXISTING = ON,PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = ON, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)  ON [arbiter_filegroup_1]
GO