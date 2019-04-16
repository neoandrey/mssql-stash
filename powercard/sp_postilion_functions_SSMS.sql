
select s.shadow_account_nbr, SUBSTRING(l.entity_id, 1,6)+'******'+SUBSTRING(l.entity_id,13,16)PAN, 
c.embossed_name,
 (select account_number from accounts_link where entity_id = s.shadow_account_nbr and rownum = 1) as Account_Nbr,
 credit_limit + (credit_limit * 0 / 100) -- MAW20030527
- ( credit_balance + pending_aut_credit) as available_balance,pending_aut_credit as held_amount, (credit_limit + (credit_limit * 0 / 100) 
- ( credit_balance + pending_aut_credit)+pending_aut_credit) as ledger_balance
from shadow_account_activity s (NOLOCK) 
JOIN
 accounts_link l (NOLOCK) ON
 s.shadow_account_nbr = l.account_number
 JOIN
 card c 
 ON
 l.entity_id = c.card_number 
where 
 s.bank_code = 8
and c. status_code != 'R'
order by s.shadow_account_nbr

