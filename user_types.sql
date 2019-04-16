

/****** Object:  UserDefinedDataType [dbo].[POST_BOOL]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_BOOL] FROM [numeric](1, 0) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_CURRENCY]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_CURRENCY] FROM [char](3) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_FLOAT_MONEY]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_FLOAT_MONEY] FROM [numeric](20, 4) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_ID]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_ID] FROM [int] NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_MONEY]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_MONEY] FROM [numeric](16, 0) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_NAME]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_NAME] FROM [varchar](30) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_NOTES]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_NOTES] FROM [varchar](255) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_PLUGIN_ID]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_PLUGIN_ID] FROM [varchar](20) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[POST_TERMINAL_ID]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[POST_TERMINAL_ID] FROM [char](8) NULL
GO

/****** Object:  UserDefinedDataType [dbo].[RECON_TABLE_NAME_EXTENSION]    Script Date: 6/5/2016 10:54:37 PM ******/
CREATE TYPE [dbo].[RECON_TABLE_NAME_EXTENSION] FROM [varchar](50) NULL
GO


