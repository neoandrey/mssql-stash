CASE
	WHEN SUBSTRING(terminal_id, 2,3)='044'	THEN	'Access Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='070'	THEN	'Fidelity Bank'	
	WHEN SUBSTRING(terminal_id, 2,3) in ('221','039')	THEN	'StanbicIBTC'	
	WHEN SUBSTRING(terminal_id, 2,3)='014'	THEN	'Afribank'	
	WHEN SUBSTRING(terminal_id, 2,3)='085'	THEN	'Finbank'	
	WHEN SUBSTRING(terminal_id, 2,3)='068'	THEN	'Standard Chartered Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='023'	THEN	'Citibank'	
	WHEN SUBSTRING(terminal_id, 2,3)='058'	THEN	'Guaranty Trust Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='232'	THEN	'Sterling Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='063'	THEN	'Diamond Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='069'	THEN	'Intercontinental Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='033'	THEN	'United Bank for Africa'	
	WHEN SUBSTRING(terminal_id, 2,3)='050'	THEN	'Ecobank'	
	WHEN SUBSTRING(terminal_id, 2,3)='056'	THEN	'Oceanic Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='032'	THEN	'Union Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='040'	THEN	'Equitorial Trust Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='082'	THEN	'BankPhb'	
	WHEN SUBSTRING(terminal_id, 2,3)='035'	THEN	'Wema bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='011'	THEN	'First Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='076'	THEN	'Skye Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='057'	THEN	'Zenith Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='214'	THEN	'FCMB'	
	WHEN SUBSTRING(terminal_id, 2,3)='084'	THEN	'SpringBank'	
	WHEN SUBSTRING(terminal_id, 2,3)='215'	THEN	'Unity bank'	
ELSE 
   terminal_id
   
END  acquirer
