CREATE  PROCEDURE ebn_transactions_on_hold AS
BEGIN

	select SUBSTRING(v.card_number,1,6)+'******'+SUBSTRING(v.card_number,13,16) PAN,
	 c.embossed_name as Cardholder_Name,
	 (select account_number from accounts_link (nolock) where entity_id = v.source_account_number) as account_number,
	  source_account_number as shadow_account_number,
	   transmission_date_and_time,
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
	END AS TRAN_TYPE,
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
	END
	as RESPONSE,
	card_acc_name_address as LOCATION, 
	transaction_amount,
	 SUBSTRING ((dbo.currency_alpha_code(transaction_currency)),1,3) as TRAN_CURRENCY,
	  reference_number tran_reference_number, 
	  matching_date_purge
	FROM
	 V_autho_activity_view v (NOLOCK)  JOIN  card c(NOLOCK) 
	 ON
	 c.card_number = v.card_number
	 JOIN 
	 addresses_table a
	  ON
	   v.card_number = a.entity_id
	where 
	 issuing_bank = 8
	and matching_date_purge is not null
	and transaction_amount != 0
	and current_table_indicator = 'MTH'
	order by account_number, transmission_date_and_time;

END

