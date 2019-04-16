

USE [powercard]
GO
/****** Object:  StoredProcedure [dbo].[pwcsp_card_statement]    Script Date: 12/18/2017 8:54:56 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER                                  PROCEDURE [dbo].[pwcsp_card_statement]  
 
 @phone varchar(15)


 AS

BEGIN


select s.account_number, s.entity_id as shadow_account,substring(t.card_number, 1,6)+'******'+substring(t.card_number,13,16) as PAN,
case when transaction_code = '65' then 'Repayment received with thanks' when transaction_code = '63' then 'Interest Charge' else a.card_acceptor_term_id +'/'+ substring(a.card_acc_name_address,24,35) +'/'+substring(a.card_acc_name_address,1,22) end as TERMINAL_DETAILS,
(select distinct N_Wording from CR_TRANSACTION_PARAMETER where transaction_code = t.transaction_code)+' '+ case t.reversal_flag when 'R' then'REVERSAL' else t.reversal_flag end as Details, 

  case t.outlet_number  when 'VrtO000001' then 'POS' when 'VrtO000002' then 'ATM' else t.ACRONYM end +' '+ case t.outlet_number  when 'VrtO000001' then t.CITY_CODE when 'VrtO000002' then t.CITY_CODE else t.CITY_NAME end + case t.country_code when '566' then 'NG' else ' ' end as LOCATION,

processing_date,authorization_number,case transaction_sign when 'C' then t.transaction_amount  end as Credit, case transaction_sign when 'D' then t.transaction_amount end as Debit, dbo.currency_alpha_code (t.transaction_currency) AS Tran_Currency,t.billing_amount, dbo.currency_alpha_code (t.billing_currency) AS Settle_Currency, case transaction_sign when 'D' then -1*t.billing_amount else t.billing_amount end as Total_Impact,

(select 
sum (case r.transaction_sign when 'D' then -1*r.billing_amount else r.billing_amount end) 

from cr_transaction r, accounts_link l 
where r.processing_date <= t.processing_date 
and t.bank_code = '000022'
and l.account_number = s.account_number
and r.shadow_account_nbr = l.entity_id
) as balance

from cr_transaction t 
join accounts_link s on t.shadow_account_nbr = s.entity_id

join addresses_table Ad on t.Client_Code = Ad.Entity_Id

left outer join v_autho_activity_view a on t.authorization_number = a.authorization_code and a.issuing_bank =22
where ad.PHONE_1 = @phone
and t.shadow_account_nbr = s.entity_id
and t.bank_code = '000022'

--and transaction_date >= to_date('20130101','YYYYMMDD')
order by t.shadow_account_nbr,processing_date
END;