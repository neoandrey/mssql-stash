
DECLARE @first_post_tran_cust_id BIGINT
DECLARE @last_post_tran_cust_id BIGINT

SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE recon_business_date >='20150201'  ORDER BY recon_business_date ASC)

SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE recon_business_date < '20150301'   ORDER BY recon_business_date DESC)

SELECT  
  
    recon_business_date,
    tran_nr,
    CASE 
	WHEN CHARINDEX('FBN', source_node_name) >0 THEN  'First Bank of Nigeria'
	WHEN CHARINDEX('UBA', source_node_name) >0 THEN  'United Bank for Africa'
	WHEN CHARINDEX('ZIB', source_node_name) >0 THEN  'Zenith International Bank'
	WHEN CHARINDEX('UTB', source_node_name) >0 THEN  'Universal Trust Bank'
	WHEN CHARINDEX('STB', source_node_name) >0 THEN  'Standard Trust Bank'
	WHEN CHARINDEX('GTB', source_node_name) >0 THEN  'Guaranty Trust Bank'
	WHEN CHARINDEX('PRU', source_node_name) >0 THEN  'Skye Bank'
	WHEN CHARINDEX('OBI', source_node_name) >0 THEN  'Oceanic Bank'
	WHEN CHARINDEX('WEM', source_node_name) >0 THEN  'WEMA Bank Plc'
	WHEN CHARINDEX('AFRI', source_node_name) >0 THEN   'Afri Bank Plc'
	WHEN CHARINDEX('CHB', source_node_name) >0 THEN  'Stanbic IBTC'
	WHEN CHARINDEX('EIB', source_node_name) >0 THEN  'EIB International Bank'
	WHEN CHARINDEX('PLAT', source_node_name) >0 THEN  'Bank PHB'
	WHEN CHARINDEX('FCMB', source_node_name) >0 THEN  'First City Monument Bank'
	WHEN CHARINDEX('BOND', source_node_name) >0 THEN  'Bond Bank'
	WHEN CHARINDEX('GULF', source_node_name) >0 THEN  'Gulf Bank'
	WHEN CHARINDEX('HBP', source_node_name) >0 THEN  'Hallmark Bank'  
        WHEN	CHARINDEX('IBP', source_node_name) >0 THEN  'Intercontinental Bank'
        WHEN	CHARINDEX('FBP', source_node_name) >0 THEN  'Fidelity Bank'
        WHEN	CHARINDEX('NAT', source_node_name) >0 THEN  'National Bank'
        WHEN	CHARINDEX('UBN', source_node_name) >0 THEN  'Union Bank'
        WHEN	CHARINDEX('ETB', source_node_name) >0 THEN  'Equitorial Trust Bank'
        WHEN	CHARINDEX('DBL', source_node_name) >0 THEN  'Diamond Bank'
        WHEN	CHARINDEX('FAB', source_node_name) >0 THEN  'First Inland Bank'
        WHEN	CHARINDEX('ABP', source_node_name) >0 THEN  'Access Bank Plc'
        WHEN	CHARINDEX('SBP', source_node_name) >0 THEN  'Sterling Bank Plc'
        WHEN	CHARINDEX('PRUCC', source_node_name) >0 THEN  'Skye Bank (CashCard)'
        WHEN	CHARINDEX('UBACC', source_node_name) >0 THEN  'United Bank for Africa (CashCard)'
        WHEN	CHARINDEX('IBPCC', source_node_name) >0 THEN  'InterContinental Bank (CashCard)'
        WHEN	CHARINDEX('WEMCC', source_node_name) >0 THEN  'WEMA Bank (CashCard)'
        WHEN	CHARINDEX('ZIBCC', source_node_name) >0 THEN  'Zenith Bank (CashCard)'
        WHEN	CHARINDEX('SBPCC', source_node_name) >0 THEN  'Sterling Bank Plc (CashCard)'
        WHEN	CHARINDEX('FBNCC', source_node_name) >0 THEN  'First Bank of Nigeria (CashCard)'
        WHEN	CHARINDEX('GTBCC', source_node_name) >0 THEN  'Guaranty Trust Bank (CashCard)'
        WHEN	CHARINDEX('FCMBCC', source_node_name) >0 THEN  'First City Monument Bank (CashCard)'
        WHEN	CHARINDEX('OBICC', source_node_name) >0 THEN  'Oceanic Bank (CashCard)'
        WHEN	CHARINDEX('FAB', source_node_name) >0 THEN  'First Inland Bank'
        WHEN	CHARINDEX('EBN', source_node_name) >0 THEN  'EcoBank Nigeria'
        WHEN	CHARINDEX('UBP', source_node_name) >0 THEN  'Unity Bank Plc'
        WHEN	CHARINDEX('SPR', source_node_name) >0 THEN  'Spring Bank Plc'
        WHEN	CHARINDEX('CITICC', source_node_name) >0 THEN  'Citi Bank (CashCard)'
        WHEN	CHARINDEX('ACCION', source_node_name) >0 THEN  'Accion MFB'
        WHEN	CHARINDEX('PSH', source_node_name) >0 THEN  'Post Service Homes Limited'
        	ELSE
        	source_node_name
       END
   as initiating_bank,
       CASE 
   	WHEN CHARINDEX('FBN', sink_node_name) >0 THEN  'First Bank of Nigeria'
   	WHEN CHARINDEX('UBA', sink_node_name) >0 THEN  'United Bank for Africa'
   	WHEN CHARINDEX('ZIB', sink_node_name) >0 THEN  'Zenith International Bank'
   	WHEN CHARINDEX('UTB', sink_node_name) >0 THEN  'Universal Trust Bank'
   	WHEN CHARINDEX('STB', sink_node_name) >0 THEN  'Standard Trust Bank'
   	WHEN CHARINDEX('GTB', sink_node_name) >0 THEN  'Guaranty Trust Bank'
   	WHEN CHARINDEX('PRU', sink_node_name) >0 THEN  'Skye Bank'
   	WHEN CHARINDEX('OBI', sink_node_name) >0 THEN  'Oceanic Bank'
   	WHEN CHARINDEX('WEM', sink_node_name) >0 THEN  'WEMA Bank Plc'
   	WHEN CHARINDEX('AFRI', sink_node_name) >0 THEN   'Afri Bank Plc'
   	WHEN CHARINDEX('CHB', sink_node_name) >0 THEN  'Stanbic IBTC'
   	WHEN CHARINDEX('EIB', sink_node_name) >0 THEN  'EIB International Bank'
   	WHEN CHARINDEX('PLAT', sink_node_name) >0 THEN  'Bank PHB'
   	WHEN CHARINDEX('FCMB', sink_node_name) >0 THEN  'First City Monument Bank'
   	WHEN CHARINDEX('BOND', sink_node_name) >0 THEN  'Bond Bank'
   	WHEN CHARINDEX('GULF', sink_node_name) >0 THEN  'Gulf Bank'
   	WHEN CHARINDEX('HBP', sink_node_name) >0 THEN  'Hallmark Bank'  
           WHEN	CHARINDEX('IBP', sink_node_name) >0 THEN  'Intercontinental Bank'
           WHEN	CHARINDEX('FBP', sink_node_name) >0 THEN  'Fidelity Bank'
           WHEN	CHARINDEX('NAT', sink_node_name) >0 THEN  'National Bank'
           WHEN	CHARINDEX('UBN', sink_node_name) >0 THEN  'Union Bank'
           WHEN	CHARINDEX('ETB', sink_node_name) >0 THEN  'Equitorial Trust Bank'
           WHEN	CHARINDEX('DBL', sink_node_name) >0 THEN  'Diamond Bank'
           WHEN	CHARINDEX('FAB', sink_node_name) >0 THEN  'First Inland Bank'
           WHEN	CHARINDEX('ABP', sink_node_name) >0 THEN  'Access Bank Plc'
           WHEN	CHARINDEX('SBP', sink_node_name) >0 THEN  'Sterling Bank Plc'
           WHEN	CHARINDEX('PRUCC', sink_node_name) >0 THEN  'Skye Bank (CashCard)'
           WHEN	CHARINDEX('UBACC', sink_node_name) >0 THEN  'United Bank for Africa (CashCard)'
           WHEN	CHARINDEX('IBPCC', sink_node_name) >0 THEN  'InterContinental Bank (CashCard)'
           WHEN	CHARINDEX('WEMCC', sink_node_name) >0 THEN  'WEMA Bank (CashCard)'
           WHEN	CHARINDEX('ZIBCC', sink_node_name) >0 THEN  'Zenith Bank (CashCard)'
           WHEN	CHARINDEX('SBPCC', sink_node_name) >0 THEN  'Sterling Bank Plc (CashCard)'
           WHEN	CHARINDEX('FBNCC', sink_node_name) >0 THEN  'First Bank of Nigeria (CashCard)'
           WHEN	CHARINDEX('GTBCC', sink_node_name) >0 THEN  'Guaranty Trust Bank (CashCard)'
           WHEN	CHARINDEX('FCMBCC', sink_node_name) >0 THEN  'First City Monument Bank (CashCard)'
           WHEN	CHARINDEX('OBICC', sink_node_name) >0 THEN  'Oceanic Bank (CashCard)'
           WHEN	CHARINDEX('FAB', sink_node_name) >0 THEN  'First Inland Bank'
           WHEN	CHARINDEX('EBN', sink_node_name) >0 THEN  'EcoBank Nigeria'
           WHEN	CHARINDEX('UBP', sink_node_name) >0 THEN  'Unity Bank Plc'
           WHEN	CHARINDEX('SPR', sink_node_name) >0 THEN  'Spring Bank Plc'
           WHEN	CHARINDEX('CITICC', sink_node_name) >0 THEN  'Citi Bank (CashCard)'
           WHEN	CHARINDEX('ACCION', sink_node_name) >0 THEN  'Accion MFB'
           WHEN	CHARINDEX('PSH', sink_node_name) >0 THEN  'Post Service Homes Limited'
           	ELSE
           sink_node_name
       END
   as receiving_bank,

 CASE
 WHEN  acquiring_inst_id_code='639139'	 THEN  'Access Bank'
 WHEN  acquiring_inst_id_code='627819'	 THEN  'Afri Bank'
 WHEN  acquiring_inst_id_code='606079'	 THEN  'ASO Savings and Loans'
 WHEN  acquiring_inst_id_code='6280512'	 THEN  'Cashcard'
 WHEN  acquiring_inst_id_code='627168'	 THEN  'Diamond Bank'
 WHEN  acquiring_inst_id_code='903708'	 THEN  'Ecobank'
 WHEN  acquiring_inst_id_code='639249'	 THEN  'Equitorial Trust Bank'
 WHEN  acquiring_inst_id_code='628009'	 THEN  'FCMB'
 WHEN  acquiring_inst_id_code='639138'	 THEN  'Fidelity Bank'
 WHEN  acquiring_inst_id_code='639276'	 THEN  'Fidelity Bank( Old FSB)'
 WHEN  acquiring_inst_id_code='639203'	 THEN  'FinBank (First Inland Bank)'
 WHEN  acquiring_inst_id_code='639203'	 THEN  'FinBank_FLASHWALLET (First Inland Bank)'
 WHEN  acquiring_inst_id_code='589019'	 THEN  'First Bank of Nigeria'	 
 WHEN  acquiring_inst_id_code='506127'	 THEN  'Hasal'
 WHEN  acquiring_inst_id_code='627787'	 THEN  'Guaranty Trust Bank'
 WHEN  acquiring_inst_id_code='636088'	 THEN  'Intercontinental Bank'
 WHEN  acquiring_inst_id_code='603948'	 THEN  'Oceanic Bank'
 WHEN  acquiring_inst_id_code='627955'	 THEN  'Platinum Habib Bank'
 WHEN  acquiring_inst_id_code='627805'	 THEN  'Skye Bank( Old Prudent Bank)'
 WHEN  acquiring_inst_id_code='627975'	 THEN  'Skye Bank(former Bond Bank)'
 WHEN  acquiring_inst_id_code='628027'	 THEN  'Skye Bank(Old EIB international Bank)'
 WHEN  acquiring_inst_id_code='639563'	 THEN  'Enterprise Bank'
 WHEN  acquiring_inst_id_code='627858'	 THEN  'Stanbic IBTC Bank ( former IBTC Chartered Bank)'
 WHEN  acquiring_inst_id_code='627858'	 THEN  'stanbic ibtc bank(mobile wallet cards)'
 WHEN  acquiring_inst_id_code='068068'	 THEN  'Standard chartered'
 WHEN  acquiring_inst_id_code='636092'	 THEN  'Sterling Bank'
 WHEN  acquiring_inst_id_code='602980'	 THEN  'Union Bank'
 WHEN  acquiring_inst_id_code='627681'	 THEN  'Union Bank(former Universal Trust Bank)'
 WHEN  acquiring_inst_id_code='627480'	 THEN  'United Bank for Africa'
 WHEN  acquiring_inst_id_code='627752'	 THEN  'United Bank For Africa (former Standard Trust Bank)'
 WHEN  acquiring_inst_id_code='639609'	 THEN  'Unity Bank'
 WHEN  acquiring_inst_id_code='627821'	 THEN  'Wema Bank'
 WHEN  acquiring_inst_id_code='628016'	 THEN  'Wema Bank(former National Bank)'
 WHEN  acquiring_inst_id_code='627629'	 THEN  'Zenith International Bank'
 WHEN  acquiring_inst_id_code='639587'	 THEN  '3 Line Card Management Limited'
 ELSE 
 acquiring_inst_id_code
 END
 as 
 terminal_owner ,

 CASE 
   WHEN CHARINDEX(source_node_name, 'GPRsrc,VTUsrc,VTUSTOCKsrc')> 0 THEN 'Recharge Transactions'
   WHEN tran_type='40' THEN 'Cardholder Account Transfer Transactions'
   WHEN CHARINDEX(source_node_name, 'GPRsrc,VTUsrc,VTUSTOCKsrc') <1 AND tran_type = '00' THEN 'Purchases'
   WHEN LEFT(source_node_name,3)='SWT' AND LEFT(sink_node_name, 3)='TSS' AND LEFT(terminal_id, 1) ='1' THEN 'ATM InterBank Payment'
   WHEN LEFT(source_node_name,3)='SWT' AND LEFT(sink_node_name, 3)='TSS' AND LEFT(terminal_id, 1) ='4' THEN 'Mobile InterBank Payment'
   WHEN LEFT(source_node_name,3)='SWT' AND LEFT(terminal_id, 1) ='1' THEN 'ATM IntraBank Payment'
   WHEN LEFT(source_node_name,3)='SWT' AND LEFT(terminal_id, 1) ='4' THEN 'Mobile IntraBank Payment'
   WHEN LEFT(terminal_id, 1) ='1' THEN 'ATM Transfer Transactions'
   WHEN LEFT(terminal_id, 1) ='2' THEN 'InstantPOS Transfer Transactions' 
   WHEN terminal_id IN ('3BOL0001','3NQT0001') THEN 'Web Transactions'
   
  ELSE
  	'Mobile Transfer Transactions'
  END
  AS channel,
  
  rsp_code_rsp as response_code,
  
  0 AS count
  
 INTO
  #temp_funds_transfer
  FROM
	 post_tran trans (nolock, INDEX(ix_post_tran_2 ))
	JOIN post_tran_cust cust (nolock,INDEX(pk_post_tran_cust))
	ON trans.post_tran_cust_id = cust.post_tran_cust_id

WHERE 
trans.post_tran_cust_id >=@first_post_tran_cust_id
AND trans.post_tran_cust_id <= @last_post_tran_cust_id
AND 
LEFT(sink_node_name, 3)= 'TSS'
AND
tran_postilion_originated = 0

  
 SELECT initiating_bank,receiving_bank, terminal_owner,channel,response_code, count(tran_nr) response_count FROM  #temp_funds_transfer
 GROUP BY 
initiating_bank,receiving_bank, terminal_owner,channel,response_code

