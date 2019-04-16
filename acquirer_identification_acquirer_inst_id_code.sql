CASE
	WHEN SUBSTRING(terminal_id, 2,3)='044'	THEN	'639139'	
	WHEN SUBSTRING(terminal_id, 2,3)='070'	THEN	'639138'	
	WHEN SUBSTRING(terminal_id, 2,3) in ('221','039')	THEN	'627858'	
	WHEN SUBSTRING(terminal_id, 2,3)='014'	THEN	'627819'	
	WHEN SUBSTRING(terminal_id, 2,3)='085'	THEN	'628009'	
	WHEN SUBSTRING(terminal_id, 2,3)='068'	THEN	'068068'	
	WHEN SUBSTRING(terminal_id, 2,3)='023'	THEN	'023023'	
	WHEN SUBSTRING(terminal_id, 2,3)='058'	THEN	'627787'	
	WHEN SUBSTRING(terminal_id, 2,3)='232'	THEN	'636092'	
	WHEN SUBSTRING(terminal_id, 2,3)='063'	THEN	'627168'	
	WHEN SUBSTRING(terminal_id, 2,3)='069'	THEN	'639139'	
	WHEN SUBSTRING(terminal_id, 2,3)='033'	THEN	'627480'	
	WHEN SUBSTRING(terminal_id, 2,3)='050'	THEN	'903708'	
	WHEN SUBSTRING(terminal_id, 2,3)='056'	THEN	'903708'	
	WHEN SUBSTRING(terminal_id, 2,3)='032'	THEN	'602980'	
	WHEN SUBSTRING(terminal_id, 2,3)='040'	THEN	'636092'	
	WHEN SUBSTRING(terminal_id, 2,3)='082'	THEN	'627955'	
	WHEN SUBSTRING(terminal_id, 2,3)='035'	THEN	'627821'	
	WHEN SUBSTRING(terminal_id, 2,3)='011'	THEN	'589019'	
	WHEN SUBSTRING(terminal_id, 2,3)='076'	THEN	'627805'	
	WHEN SUBSTRING(terminal_id, 2,3)='057'	THEN	'627629'	
	WHEN SUBSTRING(terminal_id, 2,3)='214'	THEN	'628009'	
	WHEN SUBSTRING(terminal_id, 2,3)='084'	THEN	'639563'	
	WHEN SUBSTRING(terminal_id, 2,3)='215'	THEN	'639609'	
ELSE 
   terminal_id
   
END  acquirer_inst_code
