
DECLARE @month_ext VARCHAR(6)
DECLARE @start_date DATETIME = '20151101'
DECLARE @end_date DATETIME = '20160430'
DECLARE @base_date DATETIME
DECLARE @part_number INT 

SET @base_date = '20160430'


WHILE (DATEDIFF(MONTH, @start_date, @end_date)>1) 
BEGIN
SET @month_ext =  CONVERT(VARCHAR(6),@start_date,112);
SET @part_number  = 	 $PARTITION.monthly_quickteller_db_partition(@start_date)
PRINT char(10)+char(13)
exec('IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''Transactions_'+@month_ext+''') AND type in (N''U'')) BEGIN
DROP TABLE [Transactions_'+@month_ext+'];
END')


exec('
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

SET ANSI_PADDING ON

CREATE TABLE [dbo].[Transactions_'+@month_ext+'](
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
	[PaymentDate] [datetime] NOT NULL,
	[ResponseCode] [varchar](50) NULL,
	[TransactionAmount] [bigint] NOT NULL CONSTRAINT [DF_Transactions_TransactionAmount_'+@month_ext+']  DEFAULT ((0)),
	[ApprovedAmount] [bigint] NOT NULL CONSTRAINT [DF_Transactions_ApprovedAmount_'+@month_ext+']  DEFAULT ((0)),
	[Surcharge] [bigint] NULL,
	[SurchargeCurrencyCode] [varchar](50) NULL,
	[TransactionType] [varchar](50) NULL,
	[TerminalId] [varchar](50) NULL,
	[RetrievalReferenceNumber] [varchar](50) NULL,
	[EncryptedPAN] [varchar](256) NULL CONSTRAINT [DF_Transactions_EncryptedPAN_'+@month_ext+']  DEFAULT (''''),
	[HashedPAN] [varchar](256) NULL CONSTRAINT [DF_Transactions_HashedPAN_'+@month_ext+']  DEFAULT (''''),
	[MaskedPAN] [varchar](25) NULL CONSTRAINT [DF_Transactions_MaskedPAN_'+@month_ext+']  DEFAULT (''''),
	[CustomerName] [varchar](50) NULL,
	[CustomerEmail] [nvarchar](100) NULL,
	[CustomerMobile] [nvarchar](50) NULL,
	[PaymentChannelId] [smallint] NULL,
	[PaymentChannelName] [varchar](50) NULL,
	[DepositSlip] [varchar](max) NULL CONSTRAINT [DF_Bills_PushContents_DepositSlip_'+@month_ext+']  DEFAULT (''''),
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
	[IsInjected] [bit] NOT NULL CONSTRAINT [DF_Transactions_IsInjected_'+@month_ext+']  DEFAULT ((0)),
	[ServiceProviderId] [int] NULL,
	[ServiceCode] [varchar](50) NULL,
	[ServiceName] [varchar](255) NULL,
	[TransactionStatusId] [smallint] NULL CONSTRAINT [DF_Transactions_TransactionStatusId_'+@month_ext+']  DEFAULT ((5)),
	[ServiceProviderCode] [varchar](50) NULL,
	[AdviceSuccessfullyProcessed] [bit] NULL CONSTRAINT [DF_Transactions_AdviceSuccessfullyProcessd_'+@month_ext+']  DEFAULT ((0)),
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
	 CONSTRAINT [PK_Bills_PushContents_'+@month_ext+'] PRIMARY KEY CLUSTERED 
(
	[Id] ASC,
	[PaymentDate] ASC
)
)ON  [TRANSACTIONS_'+@month_ext+']
 ');
 DECLARE @part_index VARCHAR(255) = CONVERT(VARCHAR(MAX),@part_number)
 EXEC('ALTER TABLE TRANSACTIONS SWITCH PARTITION '+@part_index+' TO [TRANSACTIONS_'+@month_ext+']')
 
 SET @start_date = DATEADD(MONTH, 1, @start_date);
 
 END
