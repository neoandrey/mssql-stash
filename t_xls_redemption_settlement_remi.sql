SELECT * INTO xls_redemption_settlement
  FROM [XLS]..[XLS_ADMIN].[t_xls_redemption_settlement]
oRDER BY TXN_DATE ASC

SELECT * FROM tbl_xls_redemption_settlement

sp_rename 'xls_redemption_settlement' , 'tbl_xls_redemption_settlement'

CREATE TABLE tbl_xls_stlmt_ext_tran_type_map(
    POOL_ID INT,
    extended_tran_type VARCHAR(10)
)

INSERT INTO tbl_xls_stlmt_ext_tran_type_map VALUES (42,'1000'),(122, '3000'), (12, '9000')

SELECT * FROM  tbl_xls_stlmt_ext_tran_type_map


SELECT
LEFT(SUBSTRING(PAN, 5,LEN(PAN)),6)+'*********'+RIGHT(SUBSTRING(PAN, 5,LEN(PAN)),4) PAN,
 * 
,CASE
	WHEN SUBSTRING(terminal_no, 2,3)='044'	THEN	'639139'	
	WHEN SUBSTRING(terminal_no, 2,3)='070'	THEN	'639138'	
	WHEN SUBSTRING(terminal_no, 2,3) in ('221','039')	THEN	'627858'	
	WHEN SUBSTRING(terminal_no, 2,3)='014'	THEN	'627819'	
	WHEN SUBSTRING(terminal_no, 2,3)='085'	THEN	'628009'	
	WHEN SUBSTRING(terminal_no, 2,3)='068'	THEN	'068068'	
	WHEN SUBSTRING(terminal_no, 2,3)='023'	THEN	'023023'	
	WHEN SUBSTRING(terminal_no, 2,3)='058'	THEN	'627787'	
	WHEN SUBSTRING(terminal_no, 2,3)='232'	THEN	'636092'	
	WHEN SUBSTRING(terminal_no, 2,3)='063'	THEN	'627168'	
	WHEN SUBSTRING(terminal_no, 2,3)='069'	THEN	'639139'	
	WHEN SUBSTRING(terminal_no, 2,3)='033'	THEN	'627480'	
	WHEN SUBSTRING(terminal_no, 2,3)='050'	THEN	'903708'	
	WHEN SUBSTRING(terminal_no, 2,3)='056'	THEN	'903708'	
	WHEN SUBSTRING(terminal_no, 2,3)='032'	THEN	'602980'	
	WHEN SUBSTRING(terminal_no, 2,3)='040'	THEN	'636092'	
	WHEN SUBSTRING(terminal_no, 2,3)='082'	THEN	'627955'	
	WHEN SUBSTRING(terminal_no, 2,3)='035'	THEN	'627821'	
	WHEN SUBSTRING(terminal_no, 2,3)='011'	THEN	'589019'	
	WHEN SUBSTRING(terminal_no, 2,3)='076'	THEN	'627805'	
	WHEN SUBSTRING(terminal_no, 2,3)='057'	THEN	'627629'	
	WHEN SUBSTRING(terminal_no, 2,3)='214'	THEN	'628009'	
	WHEN SUBSTRING(terminal_no, 2,3)='084'	THEN	'639563'	
	WHEN SUBSTRING(terminal_no, 2,3)='215'	THEN	'639609'	
ELSE 
   terminal_no
   
END  acquirer_inst_code

,CASE
	WHEN SUBSTRING(terminal_no, 2,3)='044'	THEN	'Access Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='070'	THEN	'Fidelity Bank'	
	WHEN SUBSTRING(terminal_no, 2,3) in ('221','039')	THEN	'StanbicIBTC'	
	WHEN SUBSTRING(terminal_no, 2,3)='014'	THEN	'Afribank'	
	WHEN SUBSTRING(terminal_no, 2,3)='085'	THEN	'Finbank'	
	WHEN SUBSTRING(terminal_no, 2,3)='068'	THEN	'Standard Chartered Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='023'	THEN	'Citibank'	
	WHEN SUBSTRING(terminal_no, 2,3)='058'	THEN	'Guaranty Trust Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='232'	THEN	'Sterling Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='063'	THEN	'Diamond Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='069'	THEN	'Intercontinental Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='033'	THEN	'United Bank for Africa'	
	WHEN SUBSTRING(terminal_no, 2,3)='050'	THEN	'Ecobank'	
	WHEN SUBSTRING(terminal_no, 2,3)='056'	THEN	'Oceanic Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='032'	THEN	'Union Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='040'	THEN	'Equitorial Trust Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='082'	THEN	'BankPhb'	
	WHEN SUBSTRING(terminal_no, 2,3)='035'	THEN	'Wema bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='011'	THEN	'First Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='076'	THEN	'Skye Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='057'	THEN	'Zenith Bank'	
	WHEN SUBSTRING(terminal_no, 2,3)='214'	THEN	'FCMB'	
	WHEN SUBSTRING(terminal_no, 2,3)='084'	THEN	'SpringBank'	
	WHEN SUBSTRING(terminal_no, 2,3)='215'	THEN	'Unity bank'	
ELSE 
   terminal_no
   
END  acquiring_bank


FROM tbl_xls_redemption_settlement tbl (NOLOCK)
 JOIN  
tbl_xls_stlmt_ext_tran_type_map map (NOLOCK) ON tbl.[POOL ID]= map.POOL_ID

and terminal_no is not null
and  terminal_no <> '3FVR0001'