
select issuer_name,card_program, card_active_status,monthly_tran_active_status, sum(card_count) as 'card_count' from 
(
	SELECT distinct 
		a.issuer_nr,
		card_program,
	case  	when card_status in (0,2,4,6,8,10,12,14) then 'Inactive'
		when card_status in (1,3,5,7,9,11,13,15) then 'Active'
		else 'Inactive'
	END as 'card_active_status',
	case 	when (datediff(yy,tran_local_datetime,getdate())= 0 AND datediff(mm,tran_local_datetime,getdate())= 0) then 'Active'
		else 'Inactive' 
	end as 'monthly_tran_active_status', 
		tran_local_datetime,
		COUNT(a.pan+a.seq_nr)as 'card_count'
	FROM pc_cards a (nolock) 
	left outer join 
	(
		SELECT  issuer_nr, pan, seq_nr, max(tran_local_datetime) as 'tran_local_datetime'
		from 	pc_card_activity(nolock)
		group by issuer_nr, pan, seq_nr
	)DERIVEDTBL
	on a.issuer_nr = DERIVEDTBL.issuer_nr
		and a.seq_nr  	= DERIVEDTBL.seq_nr
		and a.pan 	= DERIVEDTBL.pan
	group by a.issuer_nr, card_program, card_status, tran_local_datetime 

)DERIVEDTBL inner join pc_issuers (nolock) on pc_issuers.issuer_nr = DERIVEDTBL.issuer_nr
	
group by issuer_name, card_program, card_active_status, monthly_tran_active_status


