
sp_rename  'settlement_summary_breakdown', 'settlement_summary_breakdown_2'



USE [postilion_office]
GO

/****** Object:  Table [dbo].[settlement_summary_breakdown]    Script Date: 11/27/2015 8:10:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[settlement_summary_breakdown](
	[id] [bigint] IDENTITY(1,1) NOT NULL,
	[bank_code] [varchar](32) NOT NULL,
	[trxn_category] [varchar](64) NOT NULL,
	[Debit_Account_Type] [varchar](100) NOT NULL,
	[Credit_Account_Type] [varchar](100) NOT NULL,
	[trxn_amount] [money] NOT NULL,
	[trxn_fee] [money] NOT NULL,
	[trxn_date] [datetime] NOT NULL,
	[Currency] [varchar](50) NULL,
	[Late_reversal] [char](1) NULL,
	[card_type] [varchar](25) NULL,
	[terminal_type] [varchar](25) NULL,
	[Acquirer] [varchar](50) NULL,
	[Issuer] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


CREATE NONCLUSTERED INDEX [ix_trxn_date] ON [dbo].[settlement_summary_breakdown]
(
	[trxn_date] ASC
)
INCLUDE ( 	[id],
	[bank_code],
	[trxn_category],
	[Debit_Account_Type],
	[Credit_Account_Type],
	[trxn_amount],
	[trxn_fee],
	[Currency],
	[Late_reversal],
	[card_type],
	[terminal_type],
	[Acquirer],
	[Issuer]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX [ix_trxn_date_2] ON [dbo].[settlement_summary_breakdown]
(
	[id] ASC
)
INCLUDE ( 	
[trxn_date],
	[bank_code],
	[trxn_category],
	[Debit_Account_Type],
	[Credit_Account_Type],
	[trxn_amount],
	[trxn_fee],
	[Currency],
	[Late_reversal],
	[card_type],
	[terminal_type],
	[Acquirer],
	[Issuer]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 70) ON [PRIMARY]
GO


USE [postilion_office]
GO
INSERT INTO 
[dbo].[settlement_summary_breakdown](
 [bank_code]
      ,[trxn_category]
      ,[Debit_Account_Type]
      ,[Credit_Account_Type]
      ,[trxn_amount]
      ,[trxn_fee]
      ,[trxn_date]
      ,[Currency]
      ,[Late_reversal]
      ,[card_type]
      ,[terminal_type]
      ,[Acquirer]
      ,[Issuer])
SELECT
      [bank_code]
      ,[trxn_category]
      ,[Debit_Account_Type]
      ,[Credit_Account_Type]
      ,[trxn_amount]
      ,[trxn_fee]
      ,[trxn_date]
      ,[Currency]
      ,[Late_reversal]
      ,[card_type]
      ,[terminal_type]
      ,[Acquirer]
      ,[Issuer]
  FROM [dbo].settlement_summary_breakdown_2
GO

