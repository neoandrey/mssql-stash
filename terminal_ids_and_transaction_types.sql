case left (terminal_id,1)when '1' then 'Atm' when '2' then 'Pos' when '3' then 'Web' when '4' then 'Mobile' when '5' then 'Kiosk' when '6' then 'RetailPay' else terminal_id end as Channel