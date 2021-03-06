USE [powercard]
GO
/****** Object:  StoredProcedure [dbo].[usp_get_credit_business_data]    Script Date: 10/7/2016 2:14:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE  [dbo].[usp_get_credit_business_data] 
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[crd_bus_response_code_anayses]') AND type in (N'U'))
DROP TABLE [dbo].[crd_bus_response_code_anayses];

SELECT  b.bank_name,
case  when card_number like '506%' then 'Verve' 
	 when card_number like '5%' then 'Mastercard' 
	 when card_number like '4%' then 'Visa' 
	 else 'Others' end as Card_Brand,

case card_acceptor_activity when '6011' then 'ATM' else 'POS/WEB' end as channel,
processing_code,
CASE WHEN  processing_code =  '00' THEN 'PURCHASE'
     WHEN  processing_code =  '01' THEN 'WITHDRAWAL'
     WHEN  processing_code    =  '20' THEN 'REFUND' 
     WHEN  processing_code    =  '31' THEN 'INQUIRY'
     WHEN  processing_code    =  '90' THEN 'PIN_CHANGE'
     WHEN  processing_code    =  '37' THEN  'CARD VERIFICATION INQUIRY'
     WHEN  processing_code    =  '50' THEN  'PAYMENT FROM ACCOUNT'
     ELSE '' END  as tran_type,
 RIGHT(CONVERT(varchar(20),transmission_date_and_time,106),8)as mth, 
 Wording as RESPONSE_DESCRIPTION,
  av.action_code,count(*) as Tran_count,
sum(billing_amount) as billing_amount, billing_currency FROM
[172.25.15.15].[powercard].dbo.v_autho_activity_view_kpi av (NOLOCK) join 
  [172.25.15.15].[powercard].dbo.action_LIST_kpi al (NOLOCK)
on av.action_code = al.code_action
join  [172.25.15.15].[powercard].dbo.bank_kpi b (NOLOCK) 
on av.issuing_bank = b.bank_code
and message_type !='1420'
group by b.bank_name, 
case  when card_number like '506%' then 'Verve' when card_number like '5%' then 'Mastercard' when card_number like '4%' then 'Visa' else 'Others' end, case card_acceptor_activity when '6011' then 'ATM' else 'POS/WEB' end, processing_code,
 (CASE WHEN processing_code =  '00' THEN 'PURCHASE'
       WHEN processing_code =  '01' THEN 'WITHDRAWAL'
       WHEN processing_code = '20'  THEN  'REFUND'
       WHEN processing_code = '31'  THEN 'INQUIRY'
       WHEN processing_code = '90'  THEN 'PIN_CHANGE'
       WHEN processing_code = '37'  THEN  'CARD VERIFICATION INQUIRY'
       WHEN processing_code = '50'  THEN  'PAYMENT FROM ACCOUNT'
       ELSE '' END), transmission_date_and_time, Wording, av.action_code, billing_currency
order by mth,Tran_count DESC
OPTION (RECOMPILE)



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[crd_bus_active_issuer_data]') AND type in (N'U'))
DROP TABLE [dbo].[crd_bus_active_issuer_data];


SELECT
 b.bank_name,
 RIGHT(CONVERT(varchar(20),last_prod_date,106),8)
  as mth,
case  when card_number like '506%'then 'Verve'
 when card_number like '5%' then 'Mastercard'
  when card_number like '4%' then 'Visa' 
  else 'Others' end as Card_Brand,
ct.card_product_code,cp.wording, 
COUNT (*) as  Issued,
SUM (case delivery_card_flag+activation_flag when 'YY' then 1 else 0 end) as Active,
SUM (case when DATEDIFF(D,expiry_date, GETDATE()) > 1 then 1 else 0 end) AS   Expired
INTO 
crd_bus_active_issuer_data 
FROM  [172.25.15.15].[powercard].dbo.pwcsp_card_view_kpi ct (NOLOCK) join
 [172.25.15.15].[powercard].dbo. card_product_kpi cp (NOLOCK)
on ct.card_product_code = cp.product_code
join [172.25.15.15].[powercard].dbo.bank_kpi b (NOLOCK) on ct.bank_code = b.bank_code
Where status_code = 'N'
--and last_prod_date < '01-MAR-2016'
and expiry_date >= DATEADD(MONTH, -1, GETDATE()) 
group by b.bank_name, last_prod_date, 
case  when card_number like '506%' then 'Verve'
 when card_number like '5%' then 'Mastercard' 
 when card_number like '4%' then 'Visa' else 'Others' end
 , ct.card_product_code, cp.wording
order by mth,card_product_code
OPTION (RECOMPILE)



IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[crd_bus_card_usage_data]') AND type in (N'U'))
DROP TABLE [dbo].[crd_bus_card_usage_data];


SELECT b.bank_name,
 RIGHT(CONVERT(varchar(20),transmission_date_and_time,106),8) as mth,
case  when card_number like '506%' then 'Verve' 
when card_number like '5%' then 'Mastercard' 
when card_number like '4%' then 'Visa'
 else 'Others' end 
 as
  Card_Brand,
ct.product_code,cp.wording, 
count(distinct(source_account_number)) as cards_used
--sum (billing_amount) as  billing_amount,currency_alpha_code(billing_currency)as billing_currency 
INTO crd_bus_card_usage_data 
FROM  [172.25.15.15].[powercard].dbo.v_autho_activity_view_kpi ct (NOLOCK)
 join 
  [172.25.15.15].[powercard].dbo.card_product_kpi cp (NOLOCK) 
on ct.product_code = cp.product_code
join 
 [172.25.15.15].[powercard].dbo.bank_kpi b (NOLOCK)  on ct.issuing_bank = b.bank_code
--Where transmission_date_and_time >= '2016-01-01'
--and last_prod_date < '01-MAR-2016'
group by b.bank_name, RIGHT(CONVERT(varchar(20),transmission_date_and_time,106),8),
 case  when card_number like '506%' then 'Verve' 
 when card_number like '5%' then 'Mastercard'
  when card_number like '4%' then 'Visa' 
  else 'Others' end, 
  ct.product_code,
  cp.wording
order by mth,product_code
OPTION (RECOMPILE)

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[crd_bus_customer_info_data]') AND type in (N'U'))
DROP TABLE [dbo].[crd_bus_customer_info_data];

Select b.bank_name,
l.account_number,
s.shadow_account_nbr,
c.card_number,
c.date_create,
c.embossed_name,
c.expiry_date,
a.current_profile_code,
cp.wording,
s.credit_limit,
s.credit_balance,
(s.credit_limit-s.credit_balance) as available_credit, 
unpaid_status+' unpaid' as unpaid_status,
closing_day_a as cycle_end_day
, closing_day_a +1 as cycle_start_day,
 case when cc.method_flag like 'D%' then 'Monthly'
  when cc.method_flag like 'W%' then 'Weekly'
   else 'Custom' end as Cycle_period
   INTO crd_bus_customer_info_data
from  [172.25.15.15].[powercard].dbo.shadow_account_activity s  (NOLOCK)
join  [172.25.15.15].[powercard].dbo.accounts_link l (NOLOCK) on l.entity_id = s.shadow_account_nbr

join  [172.25.15.15].[powercard].dbo.shadow_account_kpi a  (NOLOCK) on s.shadow_account_nbr = a.shadow_account_nbr
join  [172.25.15.15].[powercard].dbo.PWCSP_card_VIEW_kpi c (NOLOCK) on c.client_code = a.client_code
join  [172.25.15.15].[powercard].dbo.cr_profile_kpi cp on a.current_profile_code=cp.profile_code 
join  [172.25.15.15].[powercard].dbo.bank_kpi b on c.bank_code = b.bank_code 
join  [172.25.15.15].[powercard].dbo.cycle_cutoff_parameters_kpi cc on a.cycle_cutoff_code = cc.cycle_code

where c. status_code != 'R'
and s.bank_code = 10
and a.bank_code = cc.bank_code 
order by s.shadow_account_nbr
option (recompile)

SELECT
bank_name,
 RIGHT(CONVERT(varchar(20),transmission_date_and_time,106),8) as Month, 
((SUBSTRING(card_number,1,6))+(SUBSTRING('************',1,(len (card_number) - 10)))+ (SUBSTRING (card_number,len (card_number) - 4,len (card_number)) ))AS masked_pan,
case  when card_number like '506%' then 'Verve' 
when card_number like '5%' then 'Mastercard'
 when card_number like '4%' then 'Visa' 
 else 'Others' end as Card_Brand,
case card_acceptor_activity when '6011' then 'ATM' 
else 'POS/WEB' end as channel,
processing_code,
CASE WHEN  processing_code =  '00' THEN 'PURCHASE'
     WHEN  processing_code =  '01' THEN 'WITHDRAWAL'
     WHEN  processing_code    =  '20' THEN 'REFUND' 
     WHEN  processing_code    =  '31' THEN 'INQUIRY'
     WHEN  processing_code    =  '90' THEN 'PIN_CHANGE'
     WHEN  processing_code    =  '37' THEN  'CARD VERIFICATION INQUIRY'
     WHEN  processing_code    =  '50' THEN  'PAYMENT FROM ACCOUNT'
     ELSE '' END  as tran_type,
     Wording as RESPONSE_DESCRIPTION, av.action_code
     ,count(*) as Tran_count,
sum(billing_amount) as billing_amount,
 billing_currency
into
crd_bus_unique_cards
FROM [172.25.15.15].[powercard].dbo.v_autho_activity_view_kpi av 
join [172.25.15.15].[powercard].dbo.action_LIST_kpi al
on av.action_code = al.code_action
join [172.25.15.15].[powercard].dbo.bank_kpi b on av.issuing_bank = b.bank_code
--where issuing_bank = 8
and message_type !='1420'
--where transmission_date_and_time  >= '01-JUN-2016'
--and transmission_date_and_time  < '01-JAN-2015'


group by b.bank_name,
RIGHT(CONVERT(varchar(20),transmission_date_and_time,106),8) ,
 card_number,
case  when card_number like '506%' then 'Verve' when card_number like '5%' then 'Mastercard' when card_number like '4%' then 'Visa' else 'Others' end, 
(case card_acceptor_activity when '6011' then 'ATM' else 'POS/WEB' end), 
processing_code, 
(CASE WHEN  processing_code =  '00' THEN 'PURCHASE'
     WHEN  processing_code =  '01' THEN 'WITHDRAWAL'
     WHEN  processing_code    =  '20' THEN 'REFUND' 
     WHEN  processing_code    =  '31' THEN 'INQUIRY'
     WHEN  processing_code    =  '90' THEN 'PIN_CHANGE'
     WHEN  processing_code    =  '37' THEN  'CARD VERIFICATION INQUIRY'
     WHEN  processing_code    =  '50' THEN  'PAYMENT FROM ACCOUNT'
     ELSE '' END),
Wording, av.action_code, billing_currency
order by RIGHT(CONVERT(varchar(20),transmission_date_and_time,106),8),Tran_count DESC
option (recompile)
END
