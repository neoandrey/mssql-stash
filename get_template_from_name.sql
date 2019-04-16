SELECT * FROM reports_crystal WHERE ENTITY IN(
	SELECT entity_id FROM reports_entity WHERE NAME ='Swt_Remote_ATM_Summary'
)  