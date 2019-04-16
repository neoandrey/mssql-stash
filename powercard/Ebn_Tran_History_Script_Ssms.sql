CREATE PROCEDURE Ebn_Tran_History_Script 
		AS
		BEGIN
     SELECT  s.account_number,s.entity_id as shadow_account,SUBSTRING(t.card_number, 1,6)+'******'+SUBSTRING(t.card_number,13,16)PAN,
	case t.outlet_number  when 'VrtO000001' then 'POS' when 'VrtO000002' then 'ATM' else t.ACRONYM end + ' ' + case t.outlet_number  when 'VrtO000002' then t.CITY_CODE when 'VrtO000002' then t.CITY_CODE else t.CITY_NAME end + case t.country_code when '566' then 'NG' else '' end as LOCATION,
	transaction_code,
	(select distinct N_Wording from CR_TRANSACTION_PARAMETER where transaction_code = t.transaction_code)+' '+(case  WHEN reversal_flag= 'R' THEN 'REVERSAL' ELSE '' END) as Details, 
	transaction_date,
	authorization_number,
	transaction_sign,
	case transaction_sign when 'C' then transaction_amount  end as Credit, 
	case transaction_sign when 'D' then transaction_amount end as Debit,
	transaction_amount, dbo.currency_alpha_code (transaction_currency) AS Tran_Currency,
	billing_amount, case transaction_sign when 'D' then -1*billing_amount else billing_amount end as Total_Billing_Impact,
	dbo.currency_alpha_code (billing_currency) AS Settle_Currency
FROM
 cr_transaction t (nolock) 
JOIN
accounts_link s (nolock)
ON 
t.shadow_account_nbr = s.entity_id
where t.bank_code = '000008' 
--and processing_step!='WM'
and transaction_date >= '20150101' and
transaction_date<=REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
--and transaction_date < to_date('20130101','YYYYMMDD')
--and transaction_code = 'C9'
order by t.shadow_account_nbr,transaction_date;

                                                                                                      END