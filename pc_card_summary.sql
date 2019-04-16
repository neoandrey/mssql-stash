CREATE PROCEDURE pc_card_summary (@startDate VARCHAR(30), @endDate VARCHAR(30), @issuerName VARCHAR(30),@cardStatus VARCHAR(15))

AS

BEGIN

set @startDate = ISNULL(@startDate,DATEADD(D, -1, GETDATE()));
set @endDate = ISNULL(@startDate, GETDATE());

SET @cardStatus =ISNULL(@cardStatus,'3');

SET @cardStatus = CASE @cardStatus 
WHEN 'ACTIVE' THEN '1'
WHEN 'INACTIVE' THEN '0'
ELSE
  'ALL'
  END

IF (@cardStatus <> 'ALL') 
BEGIN


	SELECT DISTINCT LEFT(cards.pan,6)+REPLICATE('*', LEN(cards.pan) -10)+RIGHT(cards.pan,4) masked_pan , 	substring(deltas.account_id,7,19) account_id,expiry_date,card_status, card_program, 	ISNULL((deltas.ledger_balance/100),0) as ledger_balance,	ISNULL((deltas.available_balance/100),0)as available_balance	 FROM 
	pc_cards  cards (NOLOCK) LEFT JOIN pc_issuers issuers (NOLOCK) ON cards.issuer_nr = issuers.issuer_nr
	 LEFT JOIN pc_account_balances bal (NOLOCK) ON cards.pan = bal.account_id
	  LEFT JOIN pc_account_balance_deltas deltas ON bal.account_id =deltas.account_id  
	   LEFT JOIN pc_card_accounts accts ON accts.account_id =bal.account_id  WHERE card_status = @cardStatus
	AND  cards.last_updated_date >= @startDate AND  cards.last_updated_date < @endDate AND issuers.issuer_name =@issuerName

END
ELSE 
BEGIN

	SELECT DISTINCT LEFT(cards.pan,6)+REPLICATE('*', LEN(cards.pan) -10)+RIGHT(cards.pan,4) masked_pan , 	substring(deltas.account_id,7,19) account_id,expiry_date,card_status, card_program, 	ISNULL((deltas.ledger_balance/100),0) as ledger_balance,	ISNULL((deltas.available_balance/100),0)as available_balance	 FROM 
	pc_cards  cards (NOLOCK) LEFT JOIN pc_issuers issuers (NOLOCK) ON cards.issuer_nr = issuers.issuer_nr
	 LEFT JOIN pc_account_balances bal (NOLOCK) ON cards.pan = bal.account_id
	  LEFT JOIN pc_account_balance_deltas deltas ON bal.account_id =deltas.account_id  
	   LEFT JOIN pc_card_accounts accts ON accts.account_id =bal.account_id  WHERE cards.last_updated_date >= @startDate AND  cards.last_updated_date < @endDate AND issuers.issuer_name =@issuerName


END

END