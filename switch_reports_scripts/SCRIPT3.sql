use postilion
select t.id as 'Terminal ID', t.short_name, ca.name_location
from term t (nolock) inner join atm_data a (nolock) on t.id=a.atm_id
			inner join tm_card_acceptor ca on ca.card_acceptor = t.card_acceptor
where datediff(dy,last_message_time,getdate())<31