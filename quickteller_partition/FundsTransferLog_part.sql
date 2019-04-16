USE [quickteller]
GO

/****** Object:  Table [dbo].[FundsTransferLog_part]    Script Date: 1/16/2017 10:04:34 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[FundsTransferLog_part](
	[TransactionId] [bigint] NOT NULL,
	[TransferCode] [varchar](50) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_KeypadFriendlyReferenceNumber]  DEFAULT ((0)),
	[InitiatingAccountNumber] [varchar](50) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingAccountNumber]  DEFAULT (''),
	[InitiatingAccountName] [varchar](150) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingAccountName]  DEFAULT (''),
	[InitiatingAccountType] [char](2) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingAccountType]  DEFAULT (''),
	[InitiatingChequeNumber] [varchar](50) NOT NULL,
	[InitiatingEntityId] [int] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingEntityLocationId1]  DEFAULT ((0)),
	[InitiatingEntityCode] [varchar](50) NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingEntityLocationCode1]  DEFAULT (''),
	[InitiatingEntityName] [nvarchar](30) NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingEntityLocationName1]  DEFAULT (''),
	[InitiatingEntityLocationId] [int] NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingEntityLocationId]  DEFAULT ((0)),
	[InitiatingEntityLocationCode] [varchar](50) NULL CONSTRAINT [DF_FundsTransferLog_part_InititaingEntityLocationCode]  DEFAULT (''),
	[InitiatingEntityLocationFundsDirectCode] [varchar](50) NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingEntityLocationFundsDirectCode]  DEFAULT (''),
	[InitiatingEntityLocationName] [nvarchar](30) NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingEntityLocation]  DEFAULT (''),
	[InitiatingProcessorId] [bigint] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingProcessorId]  DEFAULT ((0)),
	[InitiatingProcessorLastName] [nvarchar](50) NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingProcessorLastName]  DEFAULT (''),
	[InitiatingProcessorOthernames] [nvarchar](100) NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingProcessorOthernames]  DEFAULT (''),
	[InitiatingProcessorUsername] [nvarchar](20) NULL CONSTRAINT [DF_FundsTransferLog_part_InitiatingProcessorUsername]  DEFAULT (''),
	[BeneficiaryName] [nvarchar](150) NOT NULL,
	[BeneficiaryPhone] [varchar](25) NOT NULL,
	[BeneficiaryEmail] [nvarchar](50) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_BeneficiaryPassportId]  DEFAULT (''),
	[TerminatingDateTime] [datetime] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingDateTime]  DEFAULT (getdate()),
	[TerminatingPaymentMethodId] [smallint] NOT NULL,
	[TerminatingPaymentMethod] [varchar](50) NOT NULL,
	[TerminatingChannelId] [smallint] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingChannelId]  DEFAULT ((0)),
	[TerminatingChannel] [varchar](25) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingChannelName]  DEFAULT (''),
	[TerminatingAmount] [bigint] NOT NULL,
	[TerminatingCurrencyCode] [char](3) NOT NULL,
	[TerminatingCurrencyName] [nvarchar](50) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingCurrencyName]  DEFAULT (''),
	[TerminatingAccountNumber] [varchar](50) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingAccountNumber]  DEFAULT (''),
	[TerminatingAccountType] [char](2) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingAccountType]  DEFAULT (''),
	[TerminatingAccountBankCBNCode] [varchar](10) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingAccountBankCBNCode]  DEFAULT (''),
	[TerminatingCountryCode] [char](2) NOT NULL,
	[TerminatingCountryName] [nvarchar](100) NOT NULL,
	[TerminatingEntityId] [int] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityId]  DEFAULT ((0)),
	[TerminatingEntityCode] [varchar](10) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityCode]  DEFAULT (''),
	[TerminatingEntityName] [nvarchar](256) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityName]  DEFAULT (''),
	[TerminatingEntityLocationId] [int] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityLocationId]  DEFAULT ((0)),
	[TerminatingEntityLocationCode] [varchar](50) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityLocationCode]  DEFAULT (''),
	[TerminatingEntityLocationFundsDirectCode] [varchar](50) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityLocationFundsDirectCode]  DEFAULT (''),
	[TerminatingEntityLocationName] [nvarchar](30) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityLocationName]  DEFAULT (''),
	[TerminatingEntityLocalAreaId] [bigint] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityLocalAreaId]  DEFAULT ((0)),
	[TerminatingEntityLocalAreaName] [nvarchar](256) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TerminatingEntityLocalAreaName]  DEFAULT (''),
	[TerminatingEntityStateId] [int] NOT NULL,
	[TerminatingEntityStateName] [varchar](50) NOT NULL,
	[TerminatingBankId] [int] NULL,
	[TerminatingBankCode] [varchar](10) NULL,
	[TerminatingBankCBNCode] [varchar](10) NULL,
	[TerminatingBankName] [varchar](50) NULL,
	[IsComplete] [bit] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_IsComplete]  DEFAULT ((1)),
	[IsAuthorised] [bit] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_IsAuthorised]  DEFAULT ((0)),
	[AuthorisationLimit] [bigint] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_AuthorisationLimit]  DEFAULT ((0)),
	[AuthorisingOfficerId] [bigint] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_AuthorisingOfficerId]  DEFAULT ((0)),
	[AuthorisingOfficerLastname] [nvarchar](50) NULL CONSTRAINT [DF_FundsTransferLog_part_AuthorisingOfficerLastname]  DEFAULT ((0)),
	[AuthorisingOfficerOthernames] [nvarchar](100) NULL CONSTRAINT [DF_FundsTransferLog_part_AuthorsingOfficerOthernames]  DEFAULT ((0)),
	[AuthorisingOfficerUsername] [nvarchar](20) NULL CONSTRAINT [DF_FundsTransferLog_part_AuthorisingOfficerUsername]  DEFAULT ((0)),
	[IPAddress] [varchar](30) NOT NULL,
	[CashReceivableTypeId] [smallint] NOT NULL,
	[CashReceivableTypeName] [varchar](50) NOT NULL,
	[IsTransactionApproved] [bit] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_IsTransactionApproved]  DEFAULT ((1)),
	[SettleInQTFT] [bit] NOT NULL CONSTRAINT [DF_FundsTransferLog_part_SettleInQTFT]  DEFAULT ((1)),
	[TransferReason] [varchar](max) NOT NULL CONSTRAINT [DF_FundsTransferLog_part_TransferReason]  DEFAULT (''),
	[TerminatingTerminalId] [varchar](50) NULL,
	[TerminatingStan] [varchar](50) NULL,
 CONSTRAINT [PK_FundsTransferLog_part_TransferLogId] PRIMARY KEY CLUSTERED 
(
	[TransactionId] ASC,
TerminatingDateTime
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, 
ALLOW_PAGE_LOCKS = ON) 
) ON [yearly_quickteller_db_partition_scheme] ([TerminatingDateTime])

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[FundsTransferLog_part]  WITH CHECK ADD  CONSTRAINT [FK_FundsTransferLog_part_FundsTransferLog_part] FOREIGN KEY(	[TransactionId] ,
TerminatingDateTime)
REFERENCES [dbo].[FundsTransferLog_part] (		[TransactionId] ,
TerminatingDateTime )
GO

ALTER TABLE [dbo].[FundsTransferLog_part] CHECK CONSTRAINT [FK_FundsTransferLog_part_FundsTransferLog_part]
GO

ALTER TABLE [dbo].[FundsTransferLog_part]  WITH CHECK ADD  CONSTRAINT [FK_FundsTransferLog_part_Transactions_part] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transactions_part] ([Id],paymentdate)
GO

ALTER TABLE [dbo].[FundsTransferLog_part] CHECK CONSTRAINT [FK_FundsTransferLog_part_Transactions_part]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Holds details about every funds transfer ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'FundsTransferLog_part'
GO


