/****** Script for SelectTopNRows command from SSMS  ******/
DECLARE @MAX_TC_TXN_IID bigint =0
SELECT @MAX_TC_TXN_IID = isnull (max([TC_TXN_IID]),  0)  FROM [xls].[dbo].[xls_product_service_loyalty] (NOLOCK)
  
  ;WITH
 Tx_hist AS
 (SELECT DISTINCT PL.POOL_NAME, PL.POOL_ID, md.md_media_iid, cn.ATTRIBUTE_VALUE, md.MD_BUCKET_IID_HOST, tt.TC_TXN_IID, md.account_id,
                                                  (SELECT    MD_UMI
                                                    FROM          MD_MEDIA
                                                    (NOLOCK) WHERE      MD_MEDIA_IID = MD.MD_MEDIA_IID) ACCOUNT_DETAILS, AB.TERMINAL_NO, DEF.MERCHANT_NO, DEF.ADDR, DEF.MERCHANT_NAME, 
                                              TT.TXN_EXT_REF, TT.DISC_AMT, TT.ORIG_PURCH_AMT, TT.RDM_AMT, TT.USER_IID, TTA.TXN_TYPE, TTA.QUANTITY, TTA.AMOUNT, TTA.TXN_DATE, 
                                              ENT.ENTITY_IID, TTA.ENTITY_VER, TTA.AUX_ENTITY_TYPE, TTA.AUX_ENTITY_IID, TTA.AUX_ENTITY_VER, ENT.ENTITY_TYPE AS ENTITY_TYPE, 
                                              ENT.ENTITY_NAME AS ENTITY_NAME, AUX.ENTITY_TYPE AS ENTITY_TYPE_2, AUX.ENTITY_NAME AS ENTITY_NAME_2,
                                             (SELECT     new_value FROM          tc_txn_attribute ttattr (NOLOCK) WHERE      tc_txn_iid = tt.tc_txn_iid AND ttattr.attribute_iid = 82) "TBF_CHANNEL",    
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (322) AND new_value !='NULL') TBF_AMOUNT,   
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (141)AND new_value !='NULL') TBF_AMOUNT2,  
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (102)AND new_value !='NULL') TBF_AMOUNT3, 
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (301)AND new_value !='NULL') TBF_AMOUNT4 , 
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (145)AND new_value !='NULL') TBF_AMOUNT5 , 
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (144)AND new_value !='NULL') TBF_AMOUNT6 , 
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (143)AND new_value !='NULL') TBF_AMOUNT7 , 
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (142)AND new_value !='NULL') TBF_AMOUNT8 , 
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (103)AND new_value !='NULL') TBF_AMOUNT9 , 
(select COALESCE(new_value,'0') from tc_txn_attribute TTATTR (NOLOCK) WHERE tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (101)AND new_value !='NULL') TBF_AMOUNT10  

  FROM          TC_TXN TT INNER JOIN
				TC_TXN_AMOUNT TTA (NOLOCK) ON TT.TC_TXN_IID = TTA.TC_TXN_IID and TT.TC_TXN_IID > @MAX_TC_TXN_IID
				LEFT OUTER JOIN
				TERMINAL AB (NOLOCK) ON TT.terminal_id = ab.terminal_id LEFT OUTER JOIN
				MERCHANT DEF (NOLOCK) ON TT.merchant_ID = def.merchant_ID LEFT JOIN
				V_XLS_ENTITY_EXP ENT (NOLOCK) ON (ENT.ENTITY_IID = TTA.ENTITY_IID AND ent.entity_type = tta.entity_type) LEFT JOIN
				V_XLS_ENTITY_EXP AUX (NOLOCK) ON (AUX.ENTITY_IID = TTA.AUX_ENTITY_IID AND AUX.ENTITY_TYPE = TTA.AUX_ENTITY_TYPE)
				LEFT OUTER JOIN POOL PL (NOLOCK) ON PL.POOL_ID = TTA.ENTITY_IID
				INNER JOIN
				MD_MEDIA MD (NOLOCK) ON MD.MD_MEDIA_IID = TT.MD_MEDIA_IID INNER JOIN
				TC_SETTLEMENT T (NOLOCK) ON TT.TC_SETTLEMENT_IID = T .TC_SETTLEMENT_IID 
				INNER JOIN
(SELECT DISTINCT  mdb_attr.md_bucket_iid, m.MD_BUCKET_IID_HOST, mdb_attr.ATTRIBUTE_VALUE FROM         
md_bucket_attribute mdb_attr (NOLOCK) join  md_media m (NOLOCK) 
  ON      mdb_attr.md_bucket_iid = m.MD_BUCKET_IID_HOST AND mdb_attr.attribute_iid = 63)CN  
  ON  TT.MD_BUCKET_IID = CN.MD_BUCKET_IID_HOST 

 AND
 TT.TXN_SOURCE IN(13,14) AND

 MD.md_type IN ('EID', 'XM') AND TTA.TXN_TYPE <> 4
                      )
  INSERT INTO      [xls].[dbo].prod_service_loyalty              
SELECT   
 Tx_hist.POOL_ID,Tx_hist.POOL_NAME, 
Tx_hist.tc_txn_iid, Tx_hist.attribute_value,
 Tx_hist.account_id, Tx_hist.account_details, 
                      CASE Tx_hist.TXN_TYPE WHEN 1 THEN 'AWARD' WHEN 2 THEN 'Burn' WHEN 3 THEN 'Adjustment' WHEN 5 THEN 'Discount' END "TXN_TYPE", SUM(quantity), 
                      Tx_hist.txn_date, Tx_hist.txn_ext_ref, Tx_hist.entity_iid, Tx_hist.entity_name, 
                      Tx_hist.tbf_channel, Tx_hist.TBF_AMOUNT,Tx_hist.TBF_AMOUNT2,Tx_hist.TBF_AMOUNT3,Tx_hist.TBF_AMOUNT4,Tx_hist.TBF_AMOUNT5,Tx_hist.TBF_AMOUNT6,Tx_hist.TBF_AMOUNT7,Tx_hist.TBF_AMOUNT8,Tx_hist.TBF_AMOUNT9,Tx_hist.TBF_AMOUNT10
FROM        Tx_hist
GROUP BY Tx_hist.POOL_ID,Tx_hist.POOL_NAME,Tx_hist.tc_txn_iid, Tx_hist.attribute_value, Tx_hist.account_id, Tx_hist.account_details, Tx_hist.txn_type, Tx_hist.txn_date, Tx_hist.txn_ext_ref, Tx_hist.entity_iid, 
                      Tx_hist.entity_name, Tx_hist.tbf_channel,
                      Tx_hist.TBF_AMOUNT,Tx_hist.TBF_AMOUNT2,Tx_hist.TBF_AMOUNT3,Tx_hist.TBF_AMOUNT4,Tx_hist.TBF_AMOUNT5,Tx_hist.TBF_AMOUNT6,Tx_hist.TBF_AMOUNT7,Tx_hist.TBF_AMOUNT8,Tx_hist.TBF_AMOUNT9,Tx_hist.TBF_AMOUNT10
ORDER BY Tx_hist.tc_txn_iid
option (recompile)

INSERT INTO dbo.xls_product_service_loyalty
SELECT  [POOL_ID]
      ,[POOL_NAME]
      ,[TC_TXN_IID]
      ,[ATTRIBUTE_VALUE]
      ,[ACCOUNT_ID]
      ,[ACCOUNT_DETAILS]
      ,[TXN_TYPE]
      ,[SUM(QUANTITY)]
      ,[TXN_DATE]
      ,[TXN_EXT_REF]
      ,[ENTITY_IID]
      ,[ENTITY_NAME]
      ,[TBF_CHANNEL]
      , (CASE WHEN [TBF_AMOUNT] IS NULL OR [TBF_AMOUNT]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT]) 
          END)+
          (CASE WHEN [TBF_AMOUNT2] IS NULL OR [TBF_AMOUNT2]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT2]) 
          END)+ (CASE WHEN [TBF_AMOUNT3] IS NULL OR [TBF_AMOUNT3]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT3]) 
          END)+ (CASE WHEN [TBF_AMOUNT4] IS NULL OR [TBF_AMOUNT4]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT4]) 
          END)+
           (CASE WHEN [TBF_AMOUNT5] IS NULL OR [TBF_AMOUNT5]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT5]) 
          END)+ (CASE WHEN [TBF_AMOUNT6] IS NULL OR [TBF_AMOUNT6]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT6]) 
          END)+ (CASE WHEN [TBF_AMOUNT7] IS NULL OR [TBF_AMOUNT7]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT7]) 
          END)+
           (CASE WHEN [TBF_AMOUNT8] IS NULL OR [TBF_AMOUNT8]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT8]) 
          END)+
           (CASE WHEN [TBF_AMOUNT9] IS NULL OR [TBF_AMOUNT9]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT9]) 
          END)+
           (CASE WHEN [TBF_AMOUNT10] IS NULL OR [TBF_AMOUNT10]= 'NULL' THEN 0
         ELSE  CONVERT(FLOAT,[TBF_AMOUNT10]) 
          END) 
          AS TBF_AMOUNT
          
    
  FROM [xls].[dbo].[prod_service_loyalty](nolock)
  WHERE TC_TXN_IID > @MAX_TC_TXN_IID
  