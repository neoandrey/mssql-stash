USE [quickteller]
GO


EXEC sp_rename N'[Transactions].[ IX_transactions_ON_PaymentDate_2 ]', N'[IX_transactions_ON_PaymentDate_2]', N'INDEX';  
GO  


USE [quickteller]
GO

/****** Object:  Index [IX_transactions_ON_PaymentDate_2]    Script Date: 6/30/2017 3:08:15 PM ******/
CREATE NONCLUSTERED INDEX [IX_transactions_ON_PaymentDate_2] ON [dbo].[Transactions]
(
	[ResponseCode] ASC,
	[CustomerEmail] ASC,
	[PaymentDate] ASC,
	[TransactionSetId] ASC
)
INCLUDE ( 	[Id],
	[PaymentRefNum],
	[TransactionAmount],
	[PaymentChannelName],
	[TransactionSetName],
	[ServiceProviderId])

	WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
 on monthly_quickteller_db_partition_scheme (paymentDate)

	GO
--duration: 24 mins


/****** Object:  Index [INDEX_transactions_ON_RequestReference]    Script Date: 6/30/2017 12:47:30 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_transactions_ON_RequestReference] ON [dbo].[Transactions]
(
	[RequestReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = on, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
 on monthly_quickteller_db_partition_scheme (paymentDate)

--duration: 8 mins


USE [quickteller]
GO

/****** Object:  Index [INDEX_transactions_temp_ON_ResponseCode]    Script Date: 6/30/2017 12:59:35 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_transactions_temp_ON_ResponseCode] ON [dbo].[Transactions]
(
	[ResponseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = On, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)

 on monthly_quickteller_db_partition_scheme (paymentDate)
GO


--duration: 6 mins



USE [quickteller]
GO

/****** Object:  Index [ix_Transaction_ON_ID]    Script Date: 6/30/2017 1:41:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_Transaction_ON_ID] ON [dbo].[Transactions]
(
	[Id] ASC
)
WITH 
(PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = on, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
 on monthly_quickteller_db_partition_scheme 
 (paymentDate)
GO
duration: 11mins



 DROP INDEX indx_ResponseCode ON   Transactions
 DROP INDEX ix_Transaction_ON_PaymentRefNum ON   Transactions
 DROP INDEX UNIQUE_INDEX_Transaction_ON_RequestReference_TerminalOwnerId ON   Transactions
 DROP INDEX index_id_service_provider_id ON   Transactions


