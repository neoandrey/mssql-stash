USE [master]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0001]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0002]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0003]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0004]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0005]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0006]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0007]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0008]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0009]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0010]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0011]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0012]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0013]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0014]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_0015]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_plus]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_Plus', FILENAME = N'G:\SQLSERVER\DATA\Transaction_plus.ndf' , SIZE = 1024KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_plus]
GO

USE [master]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0001', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0001.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0001]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0002', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0002.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0002]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0003', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0003.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0003]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0004', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0004.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0004]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0005', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0005.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0005]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0006', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0006.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0006]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0007', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0007.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0007]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0008', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0008.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0008]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0009', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0009.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0009]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0010', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0010.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0010]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0011', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0011.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0011]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0012', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0012.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0012]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0013', FILENAME = N'K:\SQLSERVER\DATA\Transaction_File_0013.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0013]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0014', FILENAME = N'G:\SQLSERVER\DATA\Transaction_File_0014.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0014]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_0015', FILENAME = N'G:\SQLSERVER\DATA\Transaction_File_0015.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_0015]
GO


use quickteller;
go

CREATE PARTITION FUNCTION partition_quickteller_db_by_id (BIGINT)  AS  RANGE LEFT FOR VALUES 
  (  
  20431111,
  41075672,
  61492516,
  81798198,
  101986297,
  122424727,
  142551415,
  243000000,
  343000000,
  443000000,
  543000000,
  643000000,
  743000000,
  843000000,
  943000000
  )

  
CREATE PARTITION SCHEME id_quickteller_db_partition_scheme AS PARTITION
	partition_quickteller_db_by_id TO
	(
			[Transaction_0001]
			,[Transaction_0002]
			,[Transaction_0003]
			,[Transaction_0004]
			,[Transaction_0005]
			,[Transaction_0006]
			,[Transaction_0007]
			,[Transaction_0008]
			,[Transaction_0009]
			,[Transaction_0010]
			,[Transaction_0011]
			,[Transaction_0012]
			,[Transaction_0013]
			,[Transaction_0014]
			,[Transaction_0015]
			,[Transaction_plus]
	)
	
	

	
	
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90)ON [id_quickteller_db_partition_scheme] ([Id])
) ON [id_quickteller_db_partition_scheme] ([id])

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

sqlmonitor

Alpha.03%

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT  [TransactionId]
      ,[BillerId]
      ,[BillerCode]
      ,[CustomerPriId]
      ,[CustomerSecId]
      ,[PaymentTypeCode]
      ,[PaymentTypeName]
      ,[ISWFee]
      ,[BankFee]
      ,[LeadBankFee]
      ,[IsBillerNotified]
      ,[LeadBankCode]
      ,[LeadBankName]
      ,[LeadBankId]
      ,[LeadBankCBNCode]
      ,[IsoBankCode]
      ,[IsoBankName]
      ,[IsoBankId]
      ,[IsoBankCBNCode]
      ,[TransactionStatusId]
      ,[IsoBankIin]
      ,[LeadBankIin]
      ,[IsoBankAccountNumber]
      ,[LeadBankAccountNumber]
      ,[AlternateLeadBankCbnCode]
      ,[ThirdPartyCode]
      ,[HashedCustomerPriId]
      ,[EncryptedCustomerPriId]
  FROM [quickteller].[dbo].[BillPaymentLog] (nolock)
	WHERE TransactionId >=1 AND  TransactionId<=20884509
  
  
iswlos-db-20a
iswlos-db-20b
isw-oj-db-20c

source:db7-ro

Destination:iswlos-db7-dag

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains information about all transactions on quickteller' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transactions_part'
GO



USE [quickteller]
GO

/****** Object:  Table [dbo].[BillPaymentLog_Part]    Script Date: 1/24/2017 9:53:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[BillPaymentLog_Part](
	[TransactionId] [bigint] NOT NULL,
	[BillerId] [int] NULL,
	[BillerCode] [varchar](50) NULL,
	[CustomerPriId] [varchar](50) NULL,
	[CustomerSecId] [varchar](50) NULL,
	[PaymentTypeCode] [varchar](50) NULL,
	[PaymentTypeName] [nvarchar](max) NULL,
	[ISWFee] [float] NULL,
	[BankFee] [float] NULL,
	[LeadBankFee] [float] NULL,
	[IsBillerNotified] [bit] NULL CONSTRAINT [DF_Transactions_IsBillerNotified_BillPaymentLog_Part]  DEFAULT ((0)),
	[LeadBankCode] [varchar](50) NULL,
	[LeadBankName] [varchar](50) NULL,
	[LeadBankId] [bigint] NULL,
	[LeadBankCBNCode] [varchar](50) NULL,
	[IsoBankCode] [varchar](50) NULL,
	[IsoBankName] [varchar](50) NULL,
	[IsoBankId] [bigint] NULL,
	[IsoBankCBNCode] [varchar](50) NULL,
	[TransactionStatusId] [smallint] NULL,
	[IsoBankIin] [varchar](50) NULL,
	[LeadBankIin] [varchar](50) NULL,
	[IsoBankAccountNumber] [varchar](50) NULL,
	[LeadBankAccountNumber] [varchar](50) NULL,
	[AlternateLeadBankCbnCode] [varchar](10) NULL,
	[ThirdPartyCode] [varchar](50) NULL,
	[HashedCustomerPriId] [varchar](256) NULL,
	[EncryptedCustomerPriId] [varchar](256) NULL,
 CONSTRAINT [pk_BillPaymentLog_Part] PRIMARY KEY CLUSTERED 
(
	[TransactionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)ON [id_quickteller_db_partition_scheme] ([TransactionId])
) ON [id_quickteller_db_partition_scheme] ([TransactionId])

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[BillPaymentLog_Part]  WITH CHECK ADD  CONSTRAINT [FK_BillPaymentLog_Part_Transactions] FOREIGN KEY([TransactionId])
REFERENCES [dbo].[Transactions] ([Id])
GOr

ALTER TABLE [dbo].[BillPaymentLog_Part] CHECK CONSTRAINT [FK_BillPaymentLog_Part_Transactions]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contains biller specific information about a transaction that will be pushed to the biller db' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'BillPaymentLog_Part'
GO



--SET ANSI_PADDING OFF
--GO

--ALTER TABLE [dbo].[FundsTransferLog]  WITH CHECK ADD  CONSTRAINT [FK_FundsTransferLog_PartFundsTransferLog] FOREIGN KEY([TransactionId])
--REFERENCES [dbo].[FundsTransferLog] ([TransactionId])
--GO

--ALTER TABLE [dbo].[FundsTransferLog] CHECK CONSTRAINT [FK_FundsTransferLog_PartFundsTransferLog]
--GO

--ALTER TABLE [dbo].[FundsTransferLog]  WITH CHECK ADD  CONSTRAINT [FK_FundsTransferLog_PartTransactions] FOREIGN KEY([TransactionId])
--REFERENCES [dbo].[Transactions_part] ([Id])
--GO

--ALTER TABLE [dbo].[FundsTransferLog] CHECK CONSTRAINT [FK_FundsTransferLog_PartTransactions]
--GO










