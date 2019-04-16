USE [postilion_office]
GO

/****** Object:  Schema [trans_pro]    Script Date: 02/28/2014 14:20:22 ******/
IF  EXISTS (SELECT * FROM sys.schemas WHERE name = N'trans_pro')
DROP SCHEMA [trans_pro]
GO

USE [postilion_office]
GO

/****** Object:  Schema [trans_pro]    Script Date: 02/28/2014 14:20:22 ******/
CREATE SCHEMA [trans_pro] AUTHORIZATION [dbo]
GO

CREATE VIEW [trans_pro].[tbl_merchant_account] AS
SELECT [Acquiring_bank]
      ,[card_acceptor_id_code]
      ,[account_nr]
      ,[Account_Name]
      ,[Date_Modified]
      ,[Authorized_Person]
  FROM [postilion_office].[dbo].[tbl_merchant_account]