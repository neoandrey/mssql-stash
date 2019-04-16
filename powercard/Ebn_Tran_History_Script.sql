select s.account_number,s.entity_id as shadow_account,substr(t.card_number, 1,6)||'******'||substr(t.card_number,13,16)PAN,case t.outlet_number  when 'VrtO000001' then 'POS' when 'VrtO000002' then 'ATM' else t.ACRONYM end || ' ' || case t.outlet_number  when 'VrtO000002' then t.CITY_CODE when 'VrtO000002' then t.CITY_CODE else t.CITY_NAME end || case t.country_code when '566' then 'NG' else '' end as LOCATION,
transaction_code,
(select distinct N_Wording from CR_TRANSACTION_PARAMETER where transaction_code = t.transaction_code)||' '||decode(reversal_flag,'R','REVERSAL') as Details, 

--transaction_description ||' '||case when transaction_code = '21' then 'CARD ISSUANCE FEE' when transaction_code = '65' then 'PAYMENT TO ACCOUNT' when transaction_code = '70' then 'DEBIT ORDER' when transaction_code = 'CR' then 'CARD REPLACEMENT FEES' when transaction_code = '10' then 'PIN RE-ISSUE FEES' when transaction_code = 'PF' then 'ANNUAL FEE' when transaction_code = 'C9' then 'CARD RENEWAL FEE' else '' end ||' '||decode(reversal_flag,'R','REVERSAL') as Details, 
transaction_date,authorization_number,transaction_sign,case transaction_sign when 'C' then transaction_amount  end as Credit, case transaction_sign when 'D' then transaction_amount end as Debit,transaction_amount, currency_alpha_code (transaction_currency) AS Tran_Currency,billing_amount, case transaction_sign when 'D' then -1*billing_amount else billing_amount end as Total_Billing_Impact,currency_alpha_code (billing_currency) AS Settle_Currency
from cr_transaction t, accounts_link s
where t.bank_code = '000008'
--and c.client_code = t.client_code
and t.shadow_account_nbr = s.entity_id
--and processing_step!='WM'
and transaction_date >= to_date('20150101','YYYYMMDD')
--and transaction_date < to_date('20130101','YYYYMMDD')
--and transaction_code = 'C9'
order by t.shadow_account_nbr,transaction_date;
