

--Verve_ATM_Transfers_Issuer
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Issuer Transfers - ATM'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and (payee not like '62805150%' OR payee is null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '1%'
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)

--Verve_ATM_Transfers_Acquirer
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Acquirer Transfers - ATM'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and (payee not like '62805150%' OR payee is null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '1%'
and to_account_id not like '6280512%'
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)


--Verve_POS_Transfers_Issuer
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Issuer Transfers - POS'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and (payee not like '62805150%' OR payee is null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '2%'
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)


--Verve_POS_Transfers_Acquirer 
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Acquirer Transfers - POS'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and (payee not like '62805150%' OR payee is null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '2%'
AND terminal_id not like '200%'     
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)


--Verve_Mobile_Transfers_Issuer
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Issuer Transfers - Mobile'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc','SWTMOBILEsrc','BILLSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and (payee not like '62805150%' OR payee is null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '4qtl%'
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)



--Verve_Mobile_Transfers_Acquirer
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Acquirer Transfers - Mobile'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc','SWTMOBILEsrc','BILLSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and (payee not like '62805150%' OR payee is null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '4qtl%'
and totals_group not like '%ccgroup' 
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)


--Verve_Web_Transfers_Issuer
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Issuer Transfers - Web'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc','SWTASPWEBsrc','BILLSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and ( payee is not null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '3bol%'  
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)


--Verve_Web_Transfers_Acquirer
select substring(source_node_name,4,3)as Acquirer, substring(sink_node_name,4,3)as Issuer
,Channel = 'Acquirer Transfers - Web'  
,Revenue_Type = 'Transfers'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
inner join [postilion_office].[dbo].[post_tran_cust]   b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id    
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc','SWTASPWEBsrc','BILLSsrc')
AND message_type IN ('0200','0420')
and sink_node_name not like 'SB%'
AND rsp_code_rsp = '00'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
and tran_type = ('50')
and sink_node_name like 'swt%'
and ( payee is not null)
and (extended_tran_type <> '8234' or extended_tran_type is null)     
and tran_completed= 1
and tran_postilion_originated = 0
and settle_amount_impact != 0
AND sink_node_name NOT IN ('CCLOADsnk','GPRsnk')
AND    source_node_name NOT IN ('CCLOADsrc')
and terminal_id like '3bol%'
and totals_group not like '%ccgroup' 
GROUP BY substring(source_node_name,4,3), substring(sink_node_name,4,3),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END   
ORDER BY substring(source_node_name,4,3), substring(sink_node_name,4,3)

