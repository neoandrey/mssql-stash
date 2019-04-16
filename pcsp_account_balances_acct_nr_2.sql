USE [postcard]
GO
/****** Object:  StoredProcedure [dbo].[pcsp_account_balances_acct_nr]    Script Date: 04/16/2014 10:24:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE      PROCEDURE [dbo].[pcsp_account_balances_acct_nr_2]
 @issuer   VARCHAR(50), 
 @date	   DATETIME--yyyy-mm-dd

AS
BEGIN

/*CREATE TABLE #query_result
 (
 cutoffdate			DATETIME,
 issuer_name 			VARCHAR(50),
 account_id			VARCHAR(50),
 card_program			VARCHAR(50),
 ledger_balance_delta		FLOAT,
 available_balance_delta	FLOAT,
 ledger_balance			FLOAT,
 available_balance		FLOAT
 
  )
*/
	IF (@date IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @date = CONVERT(VARCHAR(30),GETDATE(), 112)
	END


 
 SELECT
	((LEFT(c.pan,6))+ (left('************', (len (c.pan) - 10))) + (RIGHT (c.pan,4))) as pan,
	substring(d.account_id,7,19) account_id,
	@date as Expr1002,
	issuer_name,
	pc.card_program,
	--(select top 1 e.card_program from pc_cards e (nolock) where c.pan = e.pan) as card_program,
	--card_status,
	--expiry_date,
	--(select ISNULL(SUM(u.ledger_balance/100),0) from pc_account_balance_deltas u (nolock) where d.account_id = u.account_id  AND u.last_updated_date < @date) as ledger_balance_delta,
	--(select ISNULL(SUM(v.available_balance/100),0) from pc_account_balance_deltas v (nolock) where d.account_id = v.account_id  AND v.last_updated_date < @date) as available_balance_delta,
	ISNULL((l.ledger_balance/100),0) as ledger_balance_delta,
	ISNULL(SUM(l.available_balance/100),0) as available_balance_delta,
	ISNULL((d.ledger_balance/100),0) as ledger_balance,
	ISNULL((d.available_balance/100),0)as available_balance		
FROM
	pc_issuers b (NOLOCK),
	pc_account_balances d (NOLOCK),pc_card_accounts c (nolock), pc_cards pc, (select ledger_balance,available_balance,account_id,last_updated_date from pc_account_balance_deltas u (nolock) where last_updated_date < @date) l
WHERE 
	
	b.issuer_name = @issuer
	and b.issuer_nr = d.issuer_nr
	and c.account_id = d.account_id
	and c.pan =pc.pan
	and d.account_id = l.account_id
	
GROUP BY c.pan,d.account_id,b.issuer_name,pc.card_program,l.ledger_balance,d.ledger_balance,d.available_balance

END