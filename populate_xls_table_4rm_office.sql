SET IDENTITY_INSERT  [tbl_xls_settlement] ON
INSERT INTO  [postilion_office].[dbo].[tbl_xls_settlement](

[txn_id]
      ,[terminal_id]
      ,[pan]
      ,[trans_date]
      ,[extended_trans_type]
      ,[amount]
      ,[rr_number]
      ,[stan]
      ,[rdm_amt]
      ,[merchant_id]
      ,[cashier_name]
      ,[cashier_code]
      ,[cashier_acct]
      ,[cashier_ext_trans_code]
  )

SELECT [txn_id]
      ,[terminal_id]
      ,[pan]
      ,[trans_date]
      ,[extended_trans_type]
      ,[amount]
      ,[rr_number]
      ,[stan]
      ,[rdm_amt]
      ,[merchant_id]
      ,[cashier_name]
      ,[cashier_code]
      ,[cashier_acct]
      ,[cashier_ext_trans_code]
  FROM [172.25.10.69].[postilion_office].[dbo].[tbl_xls_settlement] tbl where (tbl.trans_date >= '2014-10-13' AND tbl.trans_date < '2014-10-14') 
GO

SET IDENTITY_INSERT [tbl_xls_settlement] OFF
