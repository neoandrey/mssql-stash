USE [quickteller]
GO

/****** Object:  Table [dbo].[Transactions]    Script Date: 12/29/2016 3:49:29 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO


CREATE TABLE [dbo].[Transactions_Part](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[PaymentRefNum] [varchar](100) NULL,
	[BankId] [bigint] NULL,
	[BankCode] [varchar](50) NULL,
	[BankCBNCode] [varchar](50) NULL,
	[BankName] [varchar](50) NULL,
	[TerminalOwnerCode] [nvarchar](50) NULL,
	[TerminalOwnerName] [nvarchar](50) NULL,
	[CurrencyCode] [varchar](50) NULL,
	[CurrencyName] [varchar](50) NULL,
	[PaymentDate] [datetime] not null,
	[ResponseCode] [varchar](50) NULL,
	[TransactionAmount] [bigint] NOT NULL CONSTRAINT [DF_Transactions_TransactionAmount_part]  DEFAULT ((0)),
	[ApprovedAmount] [bigint] NOT NULL CONSTRAINT [DF_Transactions_ApprovedAmount_part]  DEFAULT ((0)),
	[Surcharge] [bigint] NULL,
	[SurchargeCurrencyCode] [varchar](50) NULL,
	[TransactionType] [varchar](50) NULL,
	[TerminalId] [varchar](50) NULL,
	[RetrievalReferenceNumber] [varchar](50) NULL,
	[EncryptedPAN] [varchar](256) NULL CONSTRAINT [DF_Transactions_EncryptedPAN_part]  DEFAULT (''),
	[HashedPAN] [varchar](256) NULL CONSTRAINT [DF_Transactions_HashedPAN_part]  DEFAULT (''),
	[MaskedPAN] [varchar](25) NULL CONSTRAINT [DF_Transactions_MaskedPAN_part]  DEFAULT (''),
	[CustomerName] [varchar](50) NULL,
	[CustomerEmail] [nvarchar](100) NULL,
	[CustomerMobile] [nvarchar](50) NULL,
	[PaymentChannelId] [smallint] NULL,
	[PaymentChannelName] [varchar](50) NULL,
	[DepositSlip] [varchar](max) NULL CONSTRAINT [DF_Bills_PushContents_DepositSlip_part]  DEFAULT (''),
	[TransactionSetId] [smallint] NULL,
	[TransactionSetName] [varchar](50) NULL,
	[TerminalOwnerId] [int] NULL,
	[CountryCode] [char](2) NULL,
	[CountryName] [nvarchar](100) NULL,
	[PaymentMethodId] [smallint] NULL,
	[PaymentMethodName] [varchar](50) NULL,
	[Destination] [nvarchar](max) NULL,
	[MiscData] [nvarchar](max) NULL,
	[RequestReference] [varchar](100) NULL,
	[ProcessingResponseCode] [varchar](10) NULL,
	[ProcessingResponseDescription] [varchar](255) NULL,
	[IsInjected] [bit] NOT NULL CONSTRAINT [DF_Transactions_IsInjected_part]  DEFAULT ((0)),
	[ServiceProviderId] [int] NULL,
	[ServiceCode] [varchar](50) NULL,
	[ServiceName] [varchar](255) NULL,
	[TransactionStatusId] [smallint] NULL CONSTRAINT [DF_Transactions_TransactionStatusId_part]  DEFAULT ((5)),
	[ServiceProviderCode] [varchar](50) NULL,
	[AdviceSuccessfullyProcessed] [bit] NULL CONSTRAINT [DF_Transactions_AdviceSuccessfullyProcessd_part]  DEFAULT ((0)),
	[Narration] [varchar](50) NULL,
	[ReceiptNumber] [varchar](50) NULL,
	[MerchantSiteDomain] [varchar](100) NULL,
	[IsInjectProcessing] [bit] NULL,
	[InjectProcessingCount] [smallint] NULL,
	[RemoteClientName] [varchar](50) NULL,
	[RemoteClientToken] [varchar](50) NULL,
	[DeviceTerminalId] [varchar](50) NULL,
	[RechargePin] [varchar](300) NULL DEFAULT (NULL),
	[PaymentCode] [varchar](25) NULL,
	[AdditionalResponseData] [varchar](50) NULL,
	[ValueTokenInfo] [varchar](1000) NULL DEFAULT (NULL),
	[ThirdPartyData] [varchar](256) NULL DEFAULT (NULL),
	[STAN] [varchar](10) NULL DEFAULT (NULL),
	[Bin] [varchar](11) NULL,
	[IsSvaTransaction] [bit] NULL DEFAULT ((0)),
 CONSTRAINT [PK_Bills_PushContents_part] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
	,[PaymentDate]
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])
) ON [yearly_quickteller_db_partition_scheme] ([PaymentDate])

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[Transactions_part]  WITH NOCHECK ADD  CONSTRAINT [FK_Transactions_TransactionStatus_part] FOREIGN KEY([TransactionStatusId])
REFERENCES [dbo].[TransactionStatus] ([Id])
GO

ALTER TABLE [dbo].[Transactions_part] NOCHECK CONSTRAINT [FK_Transactions_TransactionStatus_part]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Stores info about where the money is going .i.e for a bill payment it would be the biller, for a funds transfer, it would be the beneficiary etc' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transactions_part', @level2type=N'COLUMN',@level2name=N'Destination'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains information about all transactions on quickteller' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transactions_part'
GO


