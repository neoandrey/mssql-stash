
select Tx_hist.tc_txn_iid, Tx_hist.attribute_value, Tx_hist.account_id, Tx_hist.account_details,  
CASE Tx_hist.TXN_TYPE WHEN 1 THEN 'AWARD' WHEN 2 THEN 'Burn' WHEN 3 THEN 'Adjustment' WHEN 5 THEN 'Discount' END "TXN_TYPE",   
sum(quantity), Tx_hist.txn_date, Tx_hist.txn_ext_ref,Tx_hist.entity_iid, Tx_hist.entity_name,    
Tx_hist.tbf_channel, Tx_hist.tbf_amount   
from   
(WITH CustName AS     
(     
select distinct mdb_attr.md_bucket_iid, m.MD_BUCKET_IID_HOST, mdb_attr.ATTRIBUTE_VALUE      
from md_bucket_attribute  mdb_attr, md_media m     
where      
mdb_attr.md_bucket_iid = m.MD_BUCKET_IID_HOST     
and mdb_attr.attribute_iid = 63     
)     
select distinct md.md_media_iid, cn.ATTRIBUTE_VALUE, md.MD_BUCKET_IID_HOST, tt.TC_TXN_IID, md.account_id,        
(        
  select ENCRYPTION_API.FNC_UMI_GETPLAIN(MD_UMI) from MD_MEDIA           
  WHERE MD_MEDIA_IID = MD.MD_MEDIA_IID        
) ACCOUNT_DETAILS,        
AB.TERMINAL_NO, DEF.MERCHANT_NO, DEF.ADDR, DEF.MERCHANT_NAME, TT.TXN_EXT_REF,        
TT.DISC_AMT, TT.ORIG_PURCH_AMT, TT.RDM_AMT, TT.USER_IID, TTA.TXN_TYPE, TTA.QUANTITY, TTA.AMOUNT,TTA.TXN_DATE, TTA.ENTITY_IID, TTA.ENTITY_VER,        
TTA.AUX_ENTITY_TYPE, TTA.AUX_ENTITY_IID, TTA.AUX_ENTITY_VER,ENT.ENTITY_TYPE AS ENTITY_TYPE,ENT.ENTITY_NAME AS ENTITY_NAME ,       
AUX.ENTITY_TYPE AS ENTITY_TYPE_2,AUX.ENTITY_NAME AS ENTITY_NAME_2,      
(select new_value from tc_txn_attribute ttattr where tc_txn_iid = tt.tc_txn_iid and ttattr.attribute_iid=82) "TBF_CHANNEL",    
(select new_value from tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (322)) "TBF_AMOUNT"    
FROM TC_TXN TT       
INNER JOIN TC_TXN_AMOUNT TTA         
ON TT.TC_TXN_IID = TTA.TC_TXN_IID        
INNER JOIN MD_MEDIA MD        
ON MD.MD_MEDIA_IID = TT.MD_MEDIA_IID        
INNER JOIN TC_SETTLEMENT T        
ON TT.TC_SETTLEMENT_IID = T.TC_SETTLEMENT_IID        
INNER JOIN CustName cn     
ON TT.MD_BUCKET_IID = cn.MD_BUCKET_IID_HOST      
LEFT OUTER JOIN TERMINAL AB        
on TT.terminal_id = ab.terminal_id        
LEFT OUTER JOIN MERCHANT DEF       
on TT.merchant_ID = def.merchant_ID       
LEFT JOIN V_XLS_ENTITY_EXP ENT        
ON (ENT.ENTITY_IID = TTA.ENTITY_IID AND ent.entity_type = tta.entity_type)        
LEFT JOIN  V_XLS_ENTITY_EXP AUX        
ON (AUX.ENTITY_IID = TTA.AUX_ENTITY_IID AND AUX.ENTITY_TYPE = TTA.AUX_ENTITY_TYPE)        
WHERE   TT.TXN_DATE BETWEEN TO_DATE('01-jun-2015 00:00:00','DD-MM-YYYY HH24:MI:SS') AND TO_DATE('31-aug-2016 23:59:59','DD-MM-YYYY HH24:MI:SS')    
and tta.entity_iid IN (162)      
AND MD.md_type in ('EID','XM')     
AND TTA.TXN_TYPE <> 4     
ORDER BY MD.MD_MEDIA_IID,TT.TC_TXN_IID)Tx_hist   
group by Tx_hist.tc_txn_iid, Tx_hist.attribute_value, Tx_hist.account_id, Tx_hist.account_details, Tx_hist.txn_type, Tx_hist.txn_date,  Tx_hist.txn_ext_ref,Tx_hist.entity_iid, Tx_hist.entity_name,    
Tx_hist.tbf_channel, Tx_hist.tbf_amount   
order by Tx_hist.tc_txn_iid 
