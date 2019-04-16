Hello Bolaji,

Please, insert that data into tables named as follows;

1.	Verve_Recharge_Acquirer 
2.	Verve_Recharge_Issuer
Table names are at the beginning of each script.

Regards,

--Verve_Recharge_Issuer
select BANK_CODE as Acquirer, SUBSTRING(sink_node_name,4,3) as Issuer
,Left(Terminal_id,1) as Terminal
,Case When Left(Terminal_id,1)  = '1' Then 'Issuer Recharge - ATM' When Left(Terminal_id,1)  = '2' Then 'Issuer Recharge - POS'
When Left(Terminal_id,1)  = '3' Then 'Issuer Recharge - Web' When Left(Terminal_id,1)  = '4' Then 'Issuer Recharge - Mobile' end as Channel  
,Revenue_Type = 'Recharge'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
  inner join [postilion_office].[dbo].[post_tran_cust] b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id
full outer JOIN AID_CBN_CODE c
ON  c.acquirer_inst_id1 = a.acquiring_inst_id_code
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')
AND source_node_name IN ('GPRsrc','VTUsrc','VTUSTOCKsrc')
and sink_node_name not like 'SB%'
and message_type !='0420'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
AND tran_type IN ('00','09')
and tran_reversed = 0
and tran_completed= 1
and tran_postilion_originated =0  
and rsp_code_rsp = '00'
and settle_amount_impact != 0
group by BANK_CODE, SUBSTRING(sink_node_name,4,3),Left(Terminal_id,1),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END
order by BANK_CODE, SUBSTRING(sink_node_name,4,3)


-- Verve_Recharge_Acquirer
select BANK_CODE as Acquirer ,SUBSTRING(sink_node_name,4,3) as Issuer 
,Left(Terminal_id,1) as Terminal 
,Case When Left(Terminal_id,1)  = '1' Then 'Acquirer Recharge - ATM' When Left(Terminal_id,1)  = '2' Then 'Acquirer Recharge - POS'
When Left(Terminal_id,1)  = '3' Then 'Acquirer Recharge - Web' When Left(Terminal_id,1)  = '4' Then 'Acquirer Recharge - Mobile' end as Channel   
,Revenue_Type = 'Recharge'  
,Revenue_Line = 'VAS Scheme Fees' 
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location  
,count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount
from [postilion_office].[dbo].[post_tran] a (nolock)
  inner join [postilion_office].[dbo].[post_tran_cust] b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id
full outer JOIN AID_CBN_CODE c
ON  c.acquirer_inst_id1 = a.acquiring_inst_id_code
where source_node_name not in ('SWTMEGAsrc','SWTMEGADSsrc')
AND source_node_name IN ('GPRsrc','VTUsrc','VTUSTOCKsrc')
and sink_node_name not like 'SB%'
and message_type !='0420'
And ( pan like '506%'  or pan like '539945%'or pan like '521090%'or pan like '528649%'or pan like '559453%'or pan like '551609%' or pan like '519909%' or pan like '519615%' or pan like '528668%')                 
AND tran_type IN ('00','09')
and tran_reversed = 0
and tran_completed= 1
and tran_postilion_originated =0  
and rsp_code_rsp = '00'
and settle_amount_impact != 0
and BANK_CODE <> 'isw'
group by BANK_CODE,SUBSTRING(sink_node_name,4,3),Left(Terminal_id,1),CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END
order by BANK_CODE, SUBSTRING(sink_node_name,4,3)

