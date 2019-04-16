 USE [ReportServer]
 GO
 
 
 --ReportServer.dbo.ActiveSubscriptions: sp-rename  FK_ActiveSubscriptions_Subscriptions
 --ReportServer.dbo.Notifications: FK_Notifications_Subscriptions
 --ReportServer.dbo.ReportSchedule: FK_ReportSchedule_Subscriptions
 
  exec  sp_rename 'FK_ActiveSubscriptions_Subscriptions','FK_ActiveSubscriptions_Subscriptions_old'
  exec  sp_rename 'FK_Notifications_Subscriptions','FK_Notifications_Subscriptions_old'
  exec  sp_rename 'FK_ReportSchedule_Subscriptions','FK_ReportSchedule_Subscriptions_old'
 
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
 
 ALTER TABLE [dbo].[Subscriptions]  WITH NOCHECK ADD  CONSTRAINT [FK_Subscriptions_ModifiedBy] FOREIGN KEY([ModifiedByID])
 REFERENCES [dbo].[Users] ([UserID])
 GO
 
 ALTER TABLE [dbo].[Subscriptions] CHECK CONSTRAINT [FK_Subscriptions_ModifiedBy]
 GO
 
 
 
 
 USE [ReportServer]
 GO
 
 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_ReportSchedule_Subscriptions]') AND parent_object_id = OBJECT_ID(N'[dbo].[ReportSchedule]'))
 ALTER TABLE [dbo].[ReportSchedule] DROP CONSTRAINT [FK_ReportSchedule_Subscriptions]
 GO
 
 USE [ReportServer]
 GO
 
 ALTER TABLE [dbo].[ReportSchedule]  WITH NOCHECK ADD  CONSTRAINT [FK_ReportSchedule_Subscriptions] FOREIGN KEY([SubscriptionID])
 REFERENCES [dbo].[Subscriptions] ([SubscriptionID])
 NOT FOR REPLICATION 
 GO
 
 ALTER TABLE [dbo].[ReportSchedule] NOCHECK CONSTRAINT [FK_ReportSchedule_Subscriptions]
 GO
 
 USE [ReportServer]
 GO
 
 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Notifications_Subscriptions]') AND parent_object_id = OBJECT_ID(N'[dbo].[Notifications]'))
 ALTER TABLE [dbo].[Notifications] DROP CONSTRAINT [FK_Notifications_Subscriptions]
 GO
 
 USE [ReportServer]
 GO
 
 ALTER TABLE [dbo].[Notifications]  WITH NOCHECK ADD  CONSTRAINT [FK_Notifications_Subscriptions] FOREIGN KEY([SubscriptionID])
 REFERENCES [dbo].[Subscriptions] ([SubscriptionID])
 ON DELETE CASCADE
 GO
 
 ALTER TABLE [dbo].[Notifications] CHECK CONSTRAINT [FK_Notifications_Subscriptions]
 GO
 
 USE [ReportServer]
 GO
 
 IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = aOBJECT_ID(N'[dbo].[FK_ActiveSubscriptions_Subscriptions]') AND parent_object_id = OBJECT_ID(N'[dbo].[ActiveSubscriptions]'))
 ALTER TABLE [dbo].[ActiveSubscriptions] DROP CONSTRAINT [FK_ActiveSubscriptions_Subscriptions]
 GO
 
 USE [ReportServer]
 GO
 
 ALTER TABLE [dbo].[ActiveSubscriptions]  WITH NOCHECK ADD  CONSTRAINT [FK_ActiveSubscriptions_Subscriptions] FOREIGN KEY([SubscriptionID])
 REFERENCES [dbo].[Subscriptions] ([SubscriptionID])
 ON DELETE CASCADE
 GO
 
 ALTER TABLE [dbo].[ActiveSubscriptions] CHECK CONSTRAINT [FK_ActiveSubscriptions_Subscriptions]
 GO
 
 
 
 
