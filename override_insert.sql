INSERT INTO [postilion_office].[dbo].[mcipm_override_ird]
           ([issuer_acct_range_low]
           ,[issuer_acct_range_high]
           ,[override_ird]
           ,[original_ird]
           ,[cab_program]
           ,[enabled])
     VALUES
           (<issuer_acct_range_low, char(19),>
           ,<issuer_acct_range_high, char(19),>
           ,<override_ird, char(2),>
           ,<original_ird, char(2),>
           ,<cab_program, char(4),>
           ,<enabled, char(1),>)
GO

INSERT INTO [postilion_office].[dbo].[mcipm_override_ird]
           ([issuer_acct_range_low]
           ,[issuer_acct_range_high]
           ,[override_ird]
           ,[original_ird]
           ,[cab_program]
           ,[enabled])
     VALUES

--('5178680000000000000','5178689999999999999', 75 ,NULL,NULL,1),
('5248860000000000000','5248869999999999999', 85 ,NULL,NULL,1),
('5525540000000000000','5525549999999999999', 61 ,NULL,NULL,1),
('5399830000000000000','5399839999999999999',  75 ,NULL,NULL,1),
('5399230000000000000','5399239999999999999', 75 ,NULL,NULL,1),
('5401680000000000000','5401689999999999999', 83 ,NULL,NULL,1),
('5582940000000000000','5582949999999999999', 61 ,NULL,NULL,1),
('5178680000000000000','5178689999999999999', 75 ,NULL,NULL,1),
('5568220000000000000','5568229999999999999',63,NULL,NULL,1)

INSERT INTO [postilion_office].[dbo].[mcipm_override_ird]
           ([issuer_acct_range_low]
           ,[issuer_acct_range_high]
           ,[override_ird]
           ,[original_ird]
           ,[cab_program]
           ,[enabled])
     VALUES
     ('5248866000000000000','5248869999999999999', 85,NULL,NULL,1)
     ,('5178680000000000000','5178609999999999999', 75 ,NULL,NULL,1)
     
--5178680000000000000     CIR     5178680999999999999    

--('5401680000000000000','5401689999999999999', 83 ,NULL,NULL,1),
--('5248860000000000000','5248869999999999999', 85,NULL,NULL,1),
,
--, 75,NULL,NULL,1)

SELECT * FROM [postilion_office].[dbo].[mcipm_override_ird]

