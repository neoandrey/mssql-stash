select substring(v.card_number,1,6)+'******'+substring(v.card_number,13,16) PAN, c.embossed_name as Cardholder_Name,
(select account_number from accounts_link where entity_id = (select account_number from accounts_link where entity_id = v.card_number)) as account_number, 
CONVERT( VARCHAR(MAX), transmission_date_and_time,107) as 'Date and Time',
external_stan as STAN,
CASE 
WHEN processing_code= '00' THEN 'PURCHASE'
WHEN processing_code='01' THEN 'WITHDRAWAL'
WHEN processing_code='20' THEN 'REFUND'
WHEN processing_code= '31' THEN 'INQUIRY'
WHEN processing_code= '90' THEN 'PIN_CHANGE'
WHEN processing_code= '37' THEN 'REFUND'
WHEN processing_code= '20' THEN 'REFUND'
WHEN processing_code= '20' THEN 'CARD VERIFICATION REQUEST'
END
as TRAN_TYPE,
CASE 
	WHEN event_code = 607 OR event_code = 005 OR event_code = 606 THEN 'Invalid Expiry Date'
	WHEN event_code = 900 THEN 'Incorrect Account Selected'
	WHEN event_code = 564 THEN 'Card Has Been Replaced'
	WHEN event_code = 411 THEN 'Deactivated Card'
	WHEN event_code = '001' THEN 'Card has not been Activated'
	WHEN event_code = '000' THEN 'Approved'
	WHEN event_code = 318 THEN 'Not Sufficient Funds'
	WHEN event_code = 106 THEN 'Exceeds Daily Total Withdrawal Amount'
	WHEN event_code = '023' THEN 'Incorrect Pin'
	WHEN event_code = 502 THEN 'Transaction Limits Not Defined'
	WHEN event_code = 406 THEN 'Original Transaction Already Reversed'
	WHEN event_code = '024' THEN 'Wrong Cryptogram'
	WHEN event_code = '003' THEN 'Pin Tries Count Exceeded'
	WHEN event_code = '004' THEN 'Pin Entry Tries Already Exceeded'
	WHEN event_code = 409 THEN 'Invalid Reversal as Original Transaction was Declined'
	WHEN event_code = 998 OR event_code =  '-01' THEN 'System Malfunction'
END AS RESPONSE,
card_acc_name_address as LOCATION,
 transaction_amount, substring ((currency_alpha_code(transaction_currency)),1,3) as TRAN_CURRENCY, 
a.phone_1,a.phone_2,a.email,reference_number tran_reference_number
FROM V_autho_activity_view v join card c

ON
c.card_number = v.card_number
join 
addresses_table a
 v.card_number = a.entity_id
where 
--and v.source_account_number = b.entity_id
 function_code != '400'

and event_code != '000'
and issuing_bank = 8
--and transaction_currency != billing_currency
and transmission_date_and_time  >= DATEADD(D,-1,REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', ''))
and transmission_date_and_time  < REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '')
--AND billing_amount-cr_available_balance <= 25
order by account_number, transmission_date_and_time;
