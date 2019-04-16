SELECT  
    
    'JULY' AS month,
    
    CASE 
        WHEN        source_node_name  LIKE  '%FBN%'   THEN  'First Bank of Nigeria'
        WHEN	source_node_name  LIKE  '%UBA%'   THEN  'United Bank for Africa'
        WHEN	source_node_name  LIKE  '%ZIB%'   THEN  'Zenith International Bank'
        WHEN	source_node_name  LIKE  '%UTB%'   THEN  'Universal Trust Bank'
        WHEN	source_node_name  LIKE  '%STB%'   THEN  'Standard Trust Bank'
        WHEN	source_node_name  LIKE  '%GTB%'   THEN  'Guaranty Trust Bank'
        WHEN	source_node_name  LIKE  '%PRU%'   THEN  'Skye Bank'
        WHEN	source_node_name  LIKE  '%OBI%'   THEN  'Oceanic Bank'
        WHEN	source_node_name  LIKE  '%WEM%'   THEN  'WEMA Bank Plc'
        WHEN	source_node_name  LIKE  '%AFRI%'   THEN  'Afri Bank Plc'
        WHEN	source_node_name  LIKE  '%CHB%'   THEN  'Stanbic IBTC'
        WHEN	source_node_name  LIKE  '%EIB%'   THEN  'EIB International Bank'
        WHEN	source_node_name  LIKE  '%PLAT%'   THEN  'Bank PHB'
        WHEN	source_node_name  LIKE  '%FCMB%'   THEN  'First City Monument Bank'
        WHEN	source_node_name  LIKE  '%BOND%'   THEN  'Bond Bank'
        WHEN	source_node_name  LIKE  '%GULF%'   THEN  'Gulf Bank'
        WHEN	source_node_name  LIKE  '%HBP%'   THEN  'Hallmark Bank'
        WHEN	source_node_name  LIKE  '%IBP%'   THEN  'Intercontinental Bank'
        WHEN	source_node_name  LIKE  '%FBP%'   THEN  'Fidelity Bank'
        WHEN	source_node_name  LIKE  '%NAT%'   THEN  'National Bank'
        WHEN	source_node_name  LIKE  '%UBN%'   THEN  'Union Bank'
        WHEN	source_node_name  LIKE  '%ETB%'   THEN  'Equitorial Trust Bank'
        WHEN	source_node_name  LIKE  '%DBL%'   THEN  'Diamond Bank'
        WHEN	source_node_name  LIKE  '%FAB%'   THEN  'First Inland Bank'
        WHEN	source_node_name  LIKE  '%ABP%'   THEN  'Access Bank Plc'
        WHEN	source_node_name  LIKE  '%SBP%'   THEN  'Sterling Bank Plc'
        WHEN	source_node_name  LIKE  '%PRUCC%'   THEN  'Skye Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%UBACC%'   THEN  'United Bank for Africa (CashCard)'
        WHEN	source_node_name  LIKE  '%IBPCC%'   THEN  'InterContinental Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%WEMCC%'   THEN  'WEMA Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%ZIBCC%'   THEN  'Zenith Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%SBPCC%'   THEN  'Sterling Bank Plc (CashCard)'
        WHEN	source_node_name  LIKE  '%FBNCC%'   THEN  'First Bank of Nigeria (CashCard)'
        WHEN	source_node_name  LIKE  '%GTBCC%'   THEN  'Guaranty Trust Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%FCMBCC%'   THEN  'First City Monument Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%OBICC%'   THEN  'Oceanic Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%FAB%'   THEN  'First Inland Bank'
        WHEN	source_node_name  LIKE  '%EBN%'   THEN  'EcoBank Nigeria'
        WHEN	source_node_name  LIKE  '%UBP%'   THEN  'Unity Bank Plc'
        WHEN	source_node_name  LIKE  '%SPR%'   THEN  'Spring Bank Plc'
        WHEN	source_node_name  LIKE  '%CITICC%'   THEN  'Citi Bank (CashCard)'
        WHEN	source_node_name  LIKE  '%ACCION%'   THEN  'Accion MFB'
        WHEN	source_node_name  LIKE  '%PSH%'   THEN  'Post Service Homes Limited'
        	ELSE
        	'Unknown Bank'
       END
   as initiating_bank,


    CASE 
	    WHEN terminal_owner = '044' THEN 'ABP' 
	    WHEN terminal_owner = '014' THEN 'MSB' 
	    WHEN terminal_owner = '082' THEN 'KSB' 
	    WHEN terminal_owner = '023' THEN 'CITI' 
	    WHEN terminal_owner = '063' THEN 'DBL' 
	    WHEN terminal_owner = '050' THEN 'EBN' 
	    WHEN terminal_owner = '214' THEN 'FCMB' 
	    WHEN terminal_owner = '040' THEN 'SBP' 
	    WHEN terminal_owner = '070' THEN 'FBP' 
	    WHEN terminal_owner = '011' THEN 'FBN' 
	    WHEN terminal_owner = '085' THEN 'FCMB' 
	    WHEN terminal_owner = '058' THEN 'GTB' 
	    WHEN terminal_owner = '069' THEN 'ABP' 
	    WHEN terminal_owner = '056' THEN 'OBI' 
	    WHEN terminal_owner = '076' THEN 'SKYE' 
	    WHEN terminal_owner = '084' THEN 'ENT' 
	    WHEN terminal_owner = '221' THEN 'CHB' 
	    WHEN terminal_owner = '068' THEN 'SCB' 
	    WHEN terminal_owner = '232' THEN 'SBP' 
	    WHEN terminal_owner = '033' THEN 'UBA' 
	    WHEN terminal_owner = '032' THEN 'UBN' 
	    WHEN terminal_owner = '215' THEN 'UBP' 
	    WHEN terminal_owner = '035' THEN 'WEM' 
	    WHEN terminal_owner = '057' THEN 'ZIB' 
	    WHEN terminal_owner = '301' THEN 'JBP' 
	    WHEN terminal_owner = '503' THEN 'ITEX' 
	    WHEN terminal_owner = '501' THEN 'VALUCARD'
    ELSE
       terminal_owner
   END
   as terminal_owner
   ,

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
  count(tran_nr) AS count
  
  FROM
post_tran trans (nolock , INDEX(ix_post_tran_9))
			JOIN post_tran_cust cust (nolock , INDEX(pk_post_tran_cust))
				ON trans.post_tran_cust_id = cust.post_tran_cust_id

WHERE 
recon_business_date >='20140701' AND recon_business_date < '20140801' 
AND 
LEFT(sink_node_name, 3)= 'TSS'
AND
terminal_id IN ('3BOL0001','3FTH0001','3ZZZ0001','4ZZZ0001','3PLI0001','3FTL0001','3ASO0001','3PAG0001','3UDA0001','3FRM0001','3UMO0001','3FIN0001','3IRP0001','3OBT0001','3FET0001','3CTL0001','3APY0001','4NCH0001','3BOZ0001','4QIK0001','4SCT0001','3SCT0001','3OBI0001','3PMM0001','3HAL0001','4QTL0001','3FIP0001','4SMM0001','3TER0001','3EBM0001','3UTX0001','4ZNT0001','4FBI0001','3IAP0001','4RDC0001','4MQT0001','3MQT0001','3ZBI0001','3FIT0001','4MBX0001','3ORC0001','3EZT0001','3BET0001','4MIM0001','3FVR0001','3TRG0001','3ASI0001','3ISD0001','3TLG0001','3QGW0001','4BBX0001','3MQC0001','3WIB0001','3WRT0001','4WRT0001','4PWQ0001','3PWQ0001','3KIB0001','3FTB0001','3NBL0001','3EGO0001','3HLP0001','4HLP0001','3STD0001','3STN0001','4TSM0001','3GTI0001','4FMM0001','3FMI0001','4ONN0001','4CLT0001','3AQC0001','3ESB0001','3SCH0001','3VRV0001','3FNT0001','3SMX0001','4RBX0001','4GTM0001','3EVR0001','3V2N0001','30300001','40300001','3WMN0001','4FDM0001','3HIB0001','3PGL0001','3SIB0001','3AFB0001','3SMB0001','3OBM0001','3IMB0001','3ECH0001','3CDR0001','3PVR0001','3PPY0001','3UVR0001','3AMF0001','3SPL0001','4STM0001','3HPI0001','3SAZ0001','3MIB0001','3LUX0001','3NQT0001','4NQT0001','3PMB0001','3CMB0001','3WAP0001','3VIS0001','3UBI0001','3CMY0001','3PYE0001','3FID0001','3CHM0001','3RPT0001','3NDT0001','3TPG0001','4FFM0001','3BMB0001','3INT0001','3TTM0001','3WUC0001','3APK0001','3IKN0001','3CLB0001','3GRT0001','3BHP0001','3KCM0001','3MML0001','3PKB0001','3DIB0001','3IQP0001','3SVR0001','3CWW0001','3RCS0001','3HIT0001','3VLC0001','3SUL0001','3ONV0001','3ALS0001','3ODW0001','3SNB0001','3MCM0001','3AOS0001','3EFM0001','3RPD0001','3AMY0001','33AL0001','3JZB0001','3BRB0001','3APM0001','3SOV0001','3RIC0001','3BJD0001','3RRL0001','3FMF0001','3FLM0001','3KDK0001','3LVN0001','3FFS0001','3ICG0001','3ALH0001','3EMT0001','3MBA0001','3EGP0001','3RQP0001','3ESM0001','3NIP0001','3LFB0001','3UDM0001','3SRT0001','3UNB0001','3EKR0001','3EMR0001','3QTS0001','3SPR0001','3SEM0001','3KML0001','3EPG0001','3TYL0001','3PIM0001','3QAP0001','3SHP0001','3MBL0001','3NRB0001','3MPY0001','3GSE0001','3SUB0001','3MMF0001','3RSL0001','3VMB0001','3TPT0001','3CPB0001','3GMB0001','3PEX0001','4AQT0001','3VIB0001','3RBC0001','3ITL0001','3SWP0001','3AMM0001','3CMI0001','3EMM0001','3PRO0001','3EQU0001','3CPT0001','3MFM0001','3DIM0001','3ISM0001','3ETM0001')
AND
tran_postilion_originated = 0
GROUP BY 
  source_node_name,sink_node_name,terminal_id,terminal_owner, tran_type,tran_nr, rsp_code_rsp