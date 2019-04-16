use postcard

declare @issuer_nr int
declare @issuer_name varchar(30)
declare @exec_str varchar(8000)
declare @add_str varchar(1000)

declare issuer_cursor CURSOR for
select issuer_nr, issuer_name
from pc_issuers(nolock)

open issuer_cursor

fetch next from issuer_cursor
into @issuer_nr,@issuer_name

set @exec_str = 'case issuer_nr'

while @@FETCH_STATUS = 0
begin 
set @exec_str = @exec_str + ' when '+QUOTENAME(cast(@issuer_nr as varchar(3)),'''')+ ' then '+QUOTENAME(cast(@issuer_name as varchar(30)),'''')

fetch next from issuer_cursor
into @issuer_nr,@issuer_name
end

deallocate issuer_cursor

set @exec_str = @exec_str + ' end'
set @add_str = ' when card_status in (0,2,4,6,8,10,12,14) then '+ QUOTENAME('Not Active','''')+ '
when card_status in (1,3,5,7,9,11,13,15) then '+ QUOTENAME('Active','''')

exec(N'SELECT distinct '+@exec_str + ',
card_program,
CASE ' +
@add_str + '
END card_status,
COUNT(distinct pan)as card_status_count
FROM pc_cards (nolock) 
group by issuer_nr, card_program, card_status')