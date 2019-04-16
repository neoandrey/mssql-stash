select
 substring(source_node_name,4,3)as Acquirer 
,substring(sink_node_name,4,3) as Issuer
,Channel = 'ATM Cash Withdrawal - Acquirer'  
,Revenue_Type = 'ATM Cash Withdrawal'  
,Revenue_Line = 'Verve Scheme Fees'   
,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'   END     as Location 
, count(*) as Volume
,convert(decimal(18,2), sum(settle_amount_impact/-100))  as Settled_Amount   
FROM [postilion_office].[dbo].[post_tran] a (nolock)
  inner join [postilion_office].[dbo].[post_tran_cust] b (nolock) 
on a.post_tran_cust_id = b.post_tran_cust_id
where pan like '506%' 
and settle_amount_impact ! = 0
       and tran_completed=1
       and tran_postilion_originated = 0
       AND tran_type = '01' 
       and convert(varchar(8), recon_business_date, 112) >= '20180101' and convert(varchar(8), recon_business_date, 112) < '20181102'              
group by substring(source_node_name,4,3), substring(sink_node_name,4,3) ,CASE WHEN   LEN(LTRIM(RTRIM(RIGHT(card_acceptor_name_loc,2))))!= 0  THEN RIGHT(card_acceptor_name_loc,2)  ELSE 'Not provided'       END
order by substring(source_node_name,4,3),substring(sink_node_name,4,3)

SELECT 
recon_business_date
,source_node_name
,sink_node_name
,card_acceptor_name_loc
,settle_amount_impact
,tran_completed
,tran_postilion_originated
,tran_type
,pan
FROM [postilion_office].[dbo].[post_tran] a (nolock)
 JOIN  (SELECT rdate= [date] FROM dbo.get_dates_in_range(@StartDate,@StartDate))  b
 on  a.recon_business_date = b.rdate
  inner join [postilion_office].[dbo].[post_tran_cust] b (nolock) 
  on
  a.post_tran_cust_id = b.post_tran_cust_id
