USE [postilion_office]
GO

/****** Object:  Table [dbo].[settlement_summary_breakdown]    Script Date: 12/11/2015 10:23:23 ******/
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


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_xls_settlement]    Script Date: 12/11/2015 10:24:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_xls_settlement](
	[txn_id] [int] IDENTITY(1,1) NOT NULL,
	[terminal_id] [varchar](10) NULL,
	[pan] [varchar](20) NULL,
	[trans_date] [datetime] NULL,
	[extended_trans_type] [varchar](100) NULL,
	[amount] [float] NULL,
	[rr_number] [varchar](20) NOT NULL,
	[stan] [varchar](20) NULL,
	[rdm_amt] [decimal](18, 2) NULL,
	[merchant_id] [varchar](20) NULL,
	[cashier_name] [varchar](20) NULL,
	[cashier_code] [varchar](12) NULL,
	[cashier_acct] [varchar](50) NULL,
	[cashier_ext_trans_code] [varchar](8) NULL,
	[acquiring_inst_id_code] [varchar](50) NULL,
	[merchant_type] [varchar](30) NULL,
	[card_acceptor_name_loc] [varchar](1000) NULL,
 CONSTRAINT [PK_tbl_xls_settlement] PRIMARY KEY CLUSTERED 
(
	[rr_number] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_PTSP]    Script Date: 12/11/2015 10:25:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_PTSP](
	[terminal_id] [varchar](15) NOT NULL,
	[PTSP_code] [varchar](4) NULL,
 CONSTRAINT [PK_tbl_PTSP] PRIMARY KEY CLUSTERED 
(
	[terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_reward_OutOfBand]    Script Date: 12/11/2015 10:26:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_reward_OutOfBand](
	[Terminal_id] [varchar](25) NOT NULL,
	[Card_Acceptor_Id_Code] [varchar](25) NOT NULL,
	[R_Code] [varchar](25) NULL,
	[is_kimono_term] [char](1) NULL,
 CONSTRAINT [PK_tbl_reward_OutOfBand_1] PRIMARY KEY CLUSTERED 
(
	[Terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[verve_discount]    Script Date: 12/11/2015 10:30:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[verve_discount](
	[Code] [varchar](10) NOT NULL,
	[Discount] [decimal](7, 6) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_merchant_account]    Script Date: 12/11/2015 10:30:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_merchant_account](
	[Acquiring_bank] [varchar](50) NOT NULL,
	[card_acceptor_id_code] [varchar](50) NOT NULL,
	[account_nr] [varchar](50) NOT NULL,
	[Account_Name] [varchar](50) NULL,
	[Date_Modified] [varchar](50) NULL,
	[Authorized_Person] [varchar](50) NULL,
 CONSTRAINT [PK_tbl_merchant_account] PRIMARY KEY CLUSTERED 
(
	[card_acceptor_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_merchant_category]    Script Date: 12/11/2015 10:31:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_merchant_category](
	[Category_Code] [char](4) NOT NULL,
	[Category_name] [varchar](50) NOT NULL,
	[Fee_type] [char](1) NOT NULL,
	[Merchant_Disc] [decimal](7, 6) NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [float] NOT NULL,
	[Bearer] [char](1) NOT NULL,
 CONSTRAINT [PK_tbl_merchant_category] PRIMARY KEY CLUSTERED 
(
	[Category_Code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_merchant_category_visa]    Script Date: 12/11/2015 10:31:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_merchant_category_visa](
	[Category_Code] [char](4) NOT NULL,
	[Category_name] [varchar](50) NOT NULL,
	[Fee_type] [char](1) NOT NULL,
	[Merchant_Disc] [decimal](7, 6) NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [float] NOT NULL,
	[Bearer] [char](1) NOT NULL,
 CONSTRAINT [PK_tbl_merchant_category_visa] PRIMARY KEY CLUSTERED 
(
	[Category_Code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_merchant_category_Web]    Script Date: 12/11/2015 10:32:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_merchant_category_Web](
	[Category_Code] [char](4) NOT NULL,
	[Category_name] [varchar](50) NOT NULL,
	[Fee_type] [char](1) NOT NULL,
	[Merchant_Disc] [decimal](7, 6) NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [float] NOT NULL,
	[Bearer] [char](1) NOT NULL,
 CONSTRAINT [PK_tbl_merchant_category_Web] PRIMARY KEY CLUSTERED 
(
	[Category_Code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_merchant_category_Web]    Script Date: 12/11/2015 10:32:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_merchant_category_Web](
	[Category_Code] [char](4) NOT NULL,
	[Category_name] [varchar](50) NOT NULL,
	[Fee_type] [char](1) NOT NULL,
	[Merchant_Disc] [decimal](7, 6) NULL,
	[Amount_Cap] [float] NULL,
	[Fee_Cap] [float] NOT NULL,
	[Bearer] [char](1) NOT NULL,
 CONSTRAINT [PK_tbl_merchant_category_Web] PRIMARY KEY CLUSTERED 
(
	[Category_Code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_office_file_size_details]    Script Date: 12/11/2015 10:48:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[post_office_file_size_details](
	[name] [varchar](250) NULL,
	[fileid] [smallint] NULL,
	[filename] [varchar](500) NULL,
	[filegroup] [varchar](30) NULL,
	[size] [varchar](50) NULL,
	[maxsize] [varchar](50) NULL,
	[growth] [varchar](50) NULL,
	[usage] [varchar](50) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


