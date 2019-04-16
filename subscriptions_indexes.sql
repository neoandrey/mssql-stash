USE [ReportServer]
GO

ALTER TABLE [dbo].[Subscriptions] ADD  DEFAULT ((0)) FOR [ReportZone]
GO



USE [ReportServer]
GO

/****** Object:  Index [PK_Subscriptions]    Script Date: 03/31/2015 10:25:12 ******/
ALTER TABLE [dbo].[Subscriptions] ADD  CONSTRAINT [PK_Subscriptions] PRIMARY KEY CLUSTERED 
(
	[SubscriptionID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO


USE [ReportServer]
GO

ALTER TABLE [dbo].[Subscriptions]  WITH NOCHECK ADD  CONSTRAINT [FK_Subscriptions_Catalog] FOREIGN KEY([Report_OID])
REFERENCES [dbo].[Catalog] ([ItemID])
ON DELETE CASCADE
NOT FOR REPLICATION 
GO

ALTER TABLE [dbo].[Subscriptions] CHECK CONSTRAINT [FK_Subscriptions_Catalog]
GO


USE [ReportServer]
GO

ALTER TABLE [dbo].[Subscriptions]  WITH NOCHECK ADD  CONSTRAINT [FK_Subscriptions_ModifiedBy] FOREIGN KEY([ModifiedByID])
REFERENCES [dbo].[Users] ([UserID])
GO

ALTER TABLE [dbo].[Subscriptions] CHECK CONSTRAINT [FK_Subscriptions_ModifiedBy]
GO


USE [ReportServer]
GO

USE [ReportServer]
GO

ALTER TABLE [dbo].[Subscriptions]  WITH NOCHECK ADD  CONSTRAINT [FK_Subscriptions_Owner] FOREIGN KEY([OwnerID])
REFERENCES [dbo].[Users] ([UserID])
GO

ALTER TABLE [dbo].[Subscriptions] CHECK CONSTRAINT [FK_Subscriptions_Owner]
GO



