
INSERT INTO [172.25.15.92].XLS.dbo.CAMPAIGN 
SELECT * FROM  XLS_LIVE..XLS_ADMIN.CAMPAIGN
WHERE CAMPAIGN_ID NOT IN (SELECT CAMPAIGN_ID  FROM   [172.25.15.92].XLS.dbo.CAMPAIGN )

INSERT INTO [172.25.15.92].[xls].[dbo].[TC_SETTLEMENT]
SELECT * FROM  XLS_LIVE..XLS_ADMIN.[TC_SETTLEMENT]
WHERE [TC_SETTLEMENT_IID] NOT IN (
SELECT [TC_SETTLEMENT_IID]  
FROM [172.25.15.92].[xls].[dbo].[TC_SETTLEMENT]
)

INSERT INTO [172.25.15.92].[xls].[dbo].[V_XLS_ENTITY_EXP]
SELECT * FROM   XLS_LIVE..XLS_ADMIN.V_XLS_ENTITY_EXP
WHERE ENTITY_IID NOT IN(
SELECT ENTITY_IID FROM [172.25.15.92].[xls].[dbo].[V_XLS_ENTITY_EXP]
)

INSERT INTO [172.25.15.92].[xls].[dbo].[POOL]
SELECT * FROM    XLS_LIVE..XLS_ADMIN.POOL
WHERE POOL_ID NOT IN (
SELECT POOL_ID FROM [172.25.15.92].[xls].[dbo].[POOL]
)

DECLARE @MAX_TERMINAL_ID BIGINT
SELECT  @MAX_TERMINAL_ID = MAX(Terminal_Id) FROM  [172.25.15.92].[xls].[dbo].TERMINAL 
INSERT INTO [172.25.15.92].[xls].[dbo].TERMINAL 
SELECT * FROM   XLS_LIVE..XLS_ADMIN.TERMINAL
WHERE   Terminal_Id > @MAX_TERMINAL_ID


DECLARE @MAX_MD_BUCKET_TAG_IID BIGINT
SELECT  @MAX_MD_BUCKET_TAG_IID = MAX(MD_BUCKET_TAG_IID) FROM  [172.25.15.92].[xls].[dbo].[MD_BUCKET_ATTRIBUTE]
INSERT INTO [172.25.15.92].[xls].[dbo].[MD_BUCKET_ATTRIBUTE]
SELECT  * FROM   XLS_LIVE..XLS_ADMIN.MD_BUCKET_ATTRIBUTE 
WHERE MD_BUCKET_TAG_IID >@MAX_MD_BUCKET_TAG_IID

   
DECLARE @MAX_MERCHANT_ID BIGINT
SELECT @MAX_MERCHANT_ID = MAX(@MAX_MERCHANT_ID) FROM [172.25.15.92].[xls].[dbo].MERCHANT 
INSERT INTO [172.25.15.92].[xls].[dbo].MERCHANT 
SELECT * FROM   XLS_LIVE..XLS_ADMIN.MERCHANT  
WHERE MERCHANT_ID >@MAX_MERCHANT_ID


  INSERT INTO [172.25.15.92].[xls].[dbo].[V_XLS_ENTITY_EXP]
  SELECT * FROM   XLS_LIVE..XLS_ADMIN.V_XLS_ENTITY_EXP
   WHERE ENTITY_IID NOT IN(
   SELECT ENTITY_IID FROM [172.25.15.92].[xls].[dbo].[V_XLS_ENTITY_EXP]
   )
   
   
    DECLARE @MAX_TC_TXN_AMOUNT_IID BIGINT
  SELECT  @MAX_TC_TXN_AMOUNT_IID= MAX(TC_TXN_AMOUNT_IID) FROM [172.25.15.92].[xls].[dbo].TC_TXN_AMOUNT
  INSERT INTO [172.25.15.92].[xls].[dbo].TC_TXN_AMOUNT
   SELECT  * FROM   XLS_LIVE..XLS_ADMIN.TC_TXN_AMOUNT WHERE TC_TXN_AMOUNT_IID >@MAX_TC_TXN_AMOUNT_IID
   
 
DECLARE @MAX_TC_TXN_ATTRIBUTE_IID BIGINT
SELECT @MAX_TC_TXN_ATTRIBUTE_IID = MAX(TC_TXN_ATTRIBUTE_IID) FROM [172.25.15.92].[xls].[dbo].TC_TXN_ATTRIBUTE 
insert [172.25.15.92].[xls].[dbo].TC_TXN_ATTRIBUTE 
SELECT  * FROM  XLS_LIVE..XLS_ADMIN.TC_TXN_ATTRIBUTE WHERE TC_TXN_ATTRIBUTE_IID> @MAX_TC_TXN_ATTRIBUTE_IID



DECLARE @MAX_TC_TXN_IID  BIGINT
SELECT @MAX_TC_TXN_IID = MAX(TC_TXN_IID) FROM [172.25.15.92].[xls].[dbo].TC_TXN 
INSERT INTO [172.25.15.92].[xls].[dbo].TC_TXN 
SELECT * FROM   XLS_LIVE..XLS_ADMIN.TC_TXN  (nolock) WHERE TC_TXN_IID>@MAX_TC_TXN_IID

DECLARE @MAX_TC_TXN_IID  BIGINT
SELECT @MAX_TC_TXN_IID = MAX(TC_TXN_IID) FROM [172.25.15.92].[xls].[dbo].REPORT_TXN 
INSERT INTO [172.25.15.92].[xls].[dbo].REPORT_TXN 
SELECT  * FROM   XLS_LIVE..XLS_ADMIN.REPORT_TXN (NOLOCK) WHERE TC_TXN_IID>@MAX_TC_TXN_IID 
