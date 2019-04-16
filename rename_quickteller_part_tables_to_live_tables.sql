ALTER TABLE [dbo].[Transactions_temp]  WITH NOCHECK ADD  CONSTRAINT [FK_Transactions_TransactionStatus_temp] FOREIGN KEY([TransactionStatusId])
REFERENCES [dbo].[TransactionStatus] ([Id])
GO



SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[FundsTransferLog_part]  WITH CHECK ADD  CONSTRAINT [FK_FundsTransferLog_PartFundsTransferLog] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[FundsTransferLog_temp] ([TransactionId])
GO

ALTER TABLE [dbo].[FundsTransferLog_part] CHECK CONSTRAINT [FK_FundsTransferLog_PartFundsTransferLog]
GO

ALTER TABLE [dbo].[FundsTransferLog_part]  WITH CHECK ADD  CONSTRAINT [FK_FundsTransferLog_PartTransactions] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transactions_temp] ([Id])
GO

ALTER TABLE [dbo].[FundsTransferLog_part] CHECK CONSTRAINT [FK_FundsTransferLog_PartTransactions]
GO


exec sp_rename 'Transactions', 'Transactions_20170330';
go

exec sp_rename 'Transactions_part', 'Transactions';
go

exec sp_rename 'BillPaymentLog', 'BillPaymentLog_20170330';
go

exec sp_rename 'BillPaymentLog_part', 'BillPaymentLog';
go

exec sp_rename 'FundsTransferLog', 'FundsTransferLog_20170330';
go

exec sp_rename 'FundsTransferLog_part', 'FundsTransferLog';
go



exec sp_rename  'Transactions', 'Transactions_part';
go
exec sp_rename  'Transactions_20170330', 'Transactions'
go

exec sp_rename  'BillPaymentLog','BillPaymentLog_part';
go

exec sp_rename  'BillPaymentLog_20170330', 'BillPaymentLog';
go


exec sp_rename  'FundsTransferLog','FundsTransferLog_part';
go

exec sp_rename 'FundsTransferLog_20170330', 'FundsTransferLog' ;
go




USE [quickteller]
GO

ALTER TABLE [dbo].[FundsTransferLog_part] DROP CONSTRAINT [FK_FundsTransferLog_PartTransactions]
GO

ALTER TABLE [dbo].[FundsTransferLog_part]  WITH NOCHECK ADD  CONSTRAINT [FK_FundsTransferLog_PartTransactions] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transactions_part] ([Id])
GO

ALTER TABLE [dbo].[FundsTransferLog_part] NOCHECK CONSTRAINT [FK_FundsTransferLog_PartTransactions]
GO

