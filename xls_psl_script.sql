SELECT   
 Tx_hist.POOL_ID,Tx_hist.POOL_NAME, 
Tx_hist.tc_txn_iid, Tx_hist.attribute_value,
 Tx_hist.account_id, Tx_hist.account_details, 
                      CASE Tx_hist.TXN_TYPE WHEN 1 THEN 'AWARD' WHEN 2 THEN 'Burn' WHEN 3 THEN 'Adjustment' WHEN 5 THEN 'Discount' END "TXN_TYPE", SUM(quantity), 
                      Tx_hist.txn_date, Tx_hist.txn_ext_ref, Tx_hist.entity_iid, Tx_hist.entity_name, 
                      Tx_hist.tbf_channel, Tx_hist.TBF_AMOUNT,Tx_hist.TBF_AMOUNT2,Tx_hist.TBF_AMOUNT3,Tx_hist.TBF_AMOUNT4,Tx_hist.TBF_AMOUNT5,Tx_hist.TBF_AMOUNT6,Tx_hist.TBF_AMOUNT7,Tx_hist.TBF_AMOUNT8,Tx_hist.TBF_AMOUNT9,Tx_hist.TBF_AMOUNT10
FROM         (SELECT DISTINCT PL.POOL_NAME, PL.POOL_ID, md.md_media_iid, cn.ATTRIBUTE_VALUE, md.MD_BUCKET_IID_HOST, tt.TC_TXN_IID, md.account_id,
                                                  (SELECT    MD_UMI
                                                    FROM          XLS_ADMIN.MD_MEDIA
                                                    WHERE      MD_MEDIA_IID = MD.MD_MEDIA_IID) ACCOUNT_DETAILS, AB.TERMINAL_NO, DEF.MERCHANT_NO, DEF.ADDR, DEF.MERCHANT_NAME, 
                                              TT.TXN_EXT_REF, TT.DISC_AMT, TT.ORIG_PURCH_AMT, TT.RDM_AMT, TT.USER_IID, TTA.TXN_TYPE, TTA.QUANTITY, TTA.AMOUNT, TTA.TXN_DATE, 
                                              TTA.ENTITY_IID, TTA.ENTITY_VER, TTA.AUX_ENTITY_TYPE, TTA.AUX_ENTITY_IID, TTA.AUX_ENTITY_VER, ENT.ENTITY_TYPE AS ENTITY_TYPE, 
                                              ENT.ENTITY_NAME AS ENTITY_NAME, AUX.ENTITY_TYPE AS ENTITY_TYPE_2, AUX.ENTITY_NAME AS ENTITY_NAME_2,
                                             (SELECT     new_value FROM          xls_admin.tc_txn_attribute ttattr WHERE      tc_txn_iid = tt.tc_txn_iid AND ttattr.attribute_iid = 82) "TBF_CHANNEL",    
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (322) AND new_value !='NULL') TBF_AMOUNT,   
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (141)AND new_value !='NULL') TBF_AMOUNT2,  
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (102)AND new_value !='NULL') TBF_AMOUNT3, 
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (301)AND new_value !='NULL') TBF_AMOUNT4 , 
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (145)AND new_value !='NULL') TBF_AMOUNT5 , 
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (144)AND new_value !='NULL') TBF_AMOUNT6 , 
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (143)AND new_value !='NULL') TBF_AMOUNT7 , 
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (142)AND new_value !='NULL') TBF_AMOUNT8 , 
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (103)AND new_value !='NULL') TBF_AMOUNT9 , 
(select COALESCE(new_value,'0') from xls_admin.tc_txn_attribute TTATTR where tc_txN_iid = tt.tc_txn_iid and ttattr.attribute_iid in (101)AND new_value !='NULL') TBF_AMOUNT10  

  FROM          XLS_ADMIN.TC_TXN TT INNER JOIN
                                              XLS_ADMIN.TC_TXN_AMOUNT TTA ON TT.TC_TXN_IID = TTA.TC_TXN_IID INNER JOIN
                                              XLS_ADMIN.MD_MEDIA MD ON MD.MD_MEDIA_IID = TT.MD_MEDIA_IID INNER JOIN
                                              XLS_ADMIN.TC_SETTLEMENT T ON TT.TC_SETTLEMENT_IID = T .TC_SETTLEMENT_IID
 INNER JOIN XLS_ADMIN.POOL PL ON PL.POOL_ID = TTA.ENTITY_IID
											  INNER JOIN
                                                  (SELECT DISTINCT mdb_attr.md_bucket_iid, m.MD_BUCKET_IID_HOST, mdb_attr.ATTRIBUTE_VALUE FROM          XLS_ADMIN.md_bucket_attribute mdb_attr, XLS_ADMIN.md_media m
                                                    WHERE      mdb_attr.md_bucket_iid = m.MD_BUCKET_IID_HOST AND mdb_attr.attribute_iid = 63) cn ON 
                                              TT.MD_BUCKET_IID = cn.MD_BUCKET_IID_HOST LEFT OUTER JOIN
                                              XLS_ADMIN.TERMINAL AB ON TT.terminal_id = ab.terminal_id LEFT OUTER JOIN
                                              XLS_ADMIN.MERCHANT DEF ON TT.merchant_ID = def.merchant_ID LEFT JOIN
                                              XLS_ADMIN.V_XLS_ENTITY_EXP ENT ON (ENT.ENTITY_IID = TTA.ENTITY_IID AND ent.entity_type = tta.entity_type) LEFT JOIN
                                              XLS_ADMIN.V_XLS_ENTITY_EXP AUX ON (AUX.ENTITY_IID = TTA.AUX_ENTITY_IID AND AUX.ENTITY_TYPE = TTA.AUX_ENTITY_TYPE)
											  
                       WHERE    

 MD.md_type IN ('EID', 'XM') 
                       ORDER BY MD.MD_MEDIA_IID, TT.TC_TXN_IID
					   )
                       Tx_hist  WHERE ENTITY_IID IN  (42,162)
GROUP BY Tx_hist.POOL_ID,Tx_hist.POOL_NAME,Tx_hist.tc_txn_iid, Tx_hist.attribute_value, Tx_hist.account_id, Tx_hist.account_details, Tx_hist.txn_type, Tx_hist.txn_date, Tx_hist.txn_ext_ref, Tx_hist.entity_iid, 
                      Tx_hist.entity_name, Tx_hist.tbf_channel,
                      Tx_hist.TBF_AMOUNT,Tx_hist.TBF_AMOUNT2,Tx_hist.TBF_AMOUNT3,Tx_hist.TBF_AMOUNT4,Tx_hist.TBF_AMOUNT5,Tx_hist.TBF_AMOUNT6,Tx_hist.TBF_AMOUNT7,Tx_hist.TBF_AMOUNT8,Tx_hist.TBF_AMOUNT9,Tx_hist.TBF_AMOUNT10
ORDER BY Tx_hist.tc_txn_iid