select substr(v.card_number,1,6)||'******'||substr(v.card_number,13,16) PAN, c.embossed_name as Cardholder_Name,(select account_number from accounts_link where entity_id = (select account_number from accounts_link where entity_id = v.card_number)) as account_number, to_char(transmission_date_and_time,'Month DD, YYYY HH:MIAM') as "Date and Time",external_stan as STAN,
decode (processing_code, 00, 'PURCHASE',01,'WITHDRAWAL', 20,'REFUND',31,'INQUIRY',90,'PIN_CHANGE','37','CARD VERIFICATION REQUEST') as TRAN_TYPE,
decode(event_code, 607, 'Invalid Expiry Date', 005, 'Invalid Expiry Date', 606, 'Invalid Expiry Date',900,'Incorrect Account Selected',564, 'Card Has Been Replaced',411,'Deactivated Card', 001,'Card has not been Activated',000,'Approved',318,'Not Sufficient Funds',106,'Exceeds Daily Total Withdrawal Amount',023,'Incorrect Pin',502,'Transaction Limits Not Defined',406,'Original Transaction Already Reversed',024,'Wrong Cryptogram',003,'Pin Tries Count Exceeded',004,'Pin Entry Tries Already Exceeded',105,'Transaction Amount Exceeds Withdrawal Limit',409,'Invalid Reversal as Original Transaction was Declined',998,'System Malfunction',-01,'System Malfunction') as RESPONSE,
card_acc_name_address as LOCATION, transaction_amount, substr ((currency_alpha_code(transaction_currency)),1,3) as TRAN_CURRENCY, a.phone_1,a.phone_2,a.email,reference_number tran_reference_number
FROM V_autho_activity_view v, card c,addresses_table a
where c.card_number = v.card_number
--and v.source_account_number = b.entity_id
and function_code not in ('400')
and v.card_number = a.entity_id
and event_code not in ('000')
and issuing_bank = 8
--and transaction_currency != billing_currency
and transmission_date_and_time  >= trunc(sysdate) -3
and transmission_date_and_time  < trunc(sysdate)
--AND billing_amount-cr_available_balance <= 25
order by account_number, transmission_date_and_time;
