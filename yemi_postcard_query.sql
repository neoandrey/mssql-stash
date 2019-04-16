SELECT active.Card_Product,  RIGHT (active.Card_Product,3) AS 'BRANCH CODE',

CASE  WHEN active.Card_Product='506121001'  THEN 'AREA 7'
	WHEN active.Card_Product='506121002'  THEN  'BWARI'
	WHEN active.Card_Product='506121003'  THEN  'FCDA'
	WHEN active.Card_Product='506121004'  THEN  'ZUBA'
	WHEN active.Card_Product='506121005'  THEN  'KUJE'
	WHEN active.Card_Product='506121006'  THEN  'KUBWA'
	WHEN active.Card_Product='506121007'  THEN  'Mararaba'
	WHEN active.Card_Product='506121009'  THEN  'Jikwoyi'
	WHEN active.Card_Product='506121010'  THEN  'WUSE'
	WHEN active.Card_Product='506121011'  THEN  'GUDU'
	WHEN active.Card_Product='506121012'  THEN  'EAGLE SQUARE'
	WHEN active.Card_Product='506121013'  THEN  'HEAD OFFICE'
	WHEN active.Card_Product='506121014'  THEN  'MINNA'
	WHEN active.Card_Product='506121015'  THEN  'NATIONAL ASSEMBLY'
	WHEN active.Card_Product='506121016'  THEN  'LAGOS V.I'
	WHEN active.Card_Product='506121017'  THEN  'KADUNA'
	WHEN active.Card_Product='506121018'  THEN  'KANO'
	WHEN active.Card_Product='506121019'  THEN  'PORT HARCOURT'
	WHEN active.Card_Product='506121020'  THEN  'AKURE'
	WHEN active.Card_Product='506121021'  THEN  'BENIN'
	WHEN active.Card_Product='506121026'  THEN  'IKEJA'
	WHEN active.Card_Product='506121027'  THEN  'GARKI 2'
	WHEN active.Card_Product='506121028'  THEN  'KADO'
	ELSE ''
END
AS 'BRANCH NAME', active.Pan_Count  AS 'ACTIVE', inactive.Pan_Count AS 'INACTIVE', (inactive.Pan_Count+active.Pan_Count)AS 'TOTAL' FROM 
(select left (pan,9) as Card_Product, count (distinct pan) AS Pan_Count, 'ACTIVE' AS card_status
from pc_cards(nolock)
where LEFT(pan,6) = '506121'
and card_status = 1
group by left (pan,9)) active,    
(select left (pan,9) as Card_Product, count (distinct pan) AS Pan_Count, 'INACTIVE' AS card_status
from pc_cards(nolock)
where LEFT(pan,6) = '506121'
and card_status = 0
group by left (pan,9)
) inactive
WHERE active.Card_Product= inactive.Card_Product
order by active.Card_Product