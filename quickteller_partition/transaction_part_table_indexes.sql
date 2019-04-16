--172.26.40.149

USE [quickteller]
GO



/****** Object:  Index [INDEX_Transactions_part_ON_CustomerEmail]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_CustomerEmail] ON [dbo].[Transactions_part]
(    [PaymentDate] ASC,
	[CustomerEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [INDEX_Transactions_part_ON_CustomerMobile]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_CustomerMobile] ON [dbo].[Transactions_part]
(
[PaymentDate] ASC,
	[CustomerMobile] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [INDEX_Transactions_part_ON_IsInjectProcessing]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_IsInjectProcessing] ON [dbo].[Transactions_part]
(  [PaymentDate] ASC,
	[IsInjectProcessing] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [INDEX_Transactions_part_ON_MaskedPAN]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_MaskedPAN] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[MaskedPAN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [INDEX_Transactions_part_ON_PaymentChannelId]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_PaymentChannelId] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[PaymentChannelId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [INDEX_Transactions_part_ON_RemoteClientToken]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_RemoteClientToken] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[RemoteClientToken] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [INDEX_Transactions_part_ON_RequestReference]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_RequestReference] ON [dbo].[Transactions_part]
(
	[RequestReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [INDEX_Transactions_part_ON_ResponseCode]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_ResponseCode] ON [dbo].[Transactions_part]
(
	[ResponseCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [INDEX_Transactions_part_ON_ServiceProviderId]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_ServiceProviderId] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[ServiceProviderId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [INDEX_Transactions_part_ON_TerminalOwnerCode]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_TerminalOwnerCode] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[TerminalOwnerCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [INDEX_Transactions_part_ON_TransactionSetId]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_TransactionSetId] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[TransactionSetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [INDEX_Transactions_part_ON_Transactions_parttatusId]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON_Transactions_parttatusId] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[TransactionStatusId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [INDEX_Transactions_part_ON-RemoteClientName]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [INDEX_Transactions_part_ON-RemoteClientName] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[RemoteClientName] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [IX_Transactions_part_ON_PaymentDate]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Transactions_part_ON_PaymentDate] ON [dbo].[Transactions_part]
(
	[PaymentDate] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [IX_Transactions_part_ON_TerminalOwnerId]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Transactions_part_ON_TerminalOwnerId] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[TerminalOwnerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [IX_Transactions_part_ON_TransactionSetId]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE NONCLUSTERED INDEX [IX_Transactions_part_ON_TransactionSetId] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[TransactionSetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
 GO

/****** Object:  Index [UNIQUE_INDEX_Transaction_ON_PaymentRefNum]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UNIQUE_INDEX_Transaction_ON_PaymentRefNum] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[PaymentRefNum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO

/****** Object:  Index [UNIQUE_INDEX_Transaction_ON_RequestReference_TerminalOwnerId]    Script Date: 12/29/2016 3:55:55 PM ******/
CREATE UNIQUE NONCLUSTERED INDEX [UNIQUE_INDEX_Transaction_ON_RequestReference_TerminalOwnerId] ON [dbo].[Transactions_part]
([PaymentDate] ASC,
	[RequestReference] ASC,
	[TerminalOwnerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
ON [yearly_quickteller_db_partition_scheme] ([PaymentDate]) 
GO


