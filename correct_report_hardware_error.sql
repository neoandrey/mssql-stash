
/************MegaOffice*******************/
SELECT * FROM reports_entity WHERE NAME LIKE '%SKYE%'

SELECT * FROM reports_crystal WHERE entity =167

SELECT * FROM post_process_spawn_config WHERE entity_name LIKE '%SKYE%'

SELECT * FROM reports_crystal WHERE output_params  NOT LIKE '%E:%'

SELECT REPLACE(CONVERT(VARCHAR(2000),output_params),'G:', 'E:' ) FROM reports_crystal WHERE output_params LIKE '%G:%'

UPDATE reports_crystal SET output_params=REPLACE(CONVERT(VARCHAR(2000),output_params),'G:', 'E:' ) WHERE output_params LIKE '%G:%'




/************MegaOffice32*******************/

SELECT * FROM reports_crystal WHERE entity   IN (SELECT entity_id FROM reports_entity WHERE NAME LIKE '%UBP%')

SELECT * FROM post_process_spawn_config WHERE entity_name LIKE '%SKYE%'

SELECT * FROM reports_crystal WHERE output_params  LIKE  '%D:%'

SELECT REPLACE(CONVERT(VARCHAR(2000),output_params),'G:', 'E:' ) FROM reports_crystal WHERE output_params LIKE '%D:%'

UPDATE reports_crystal SET output_params=REPLACE(CONVERT(VARCHAR(2000),output_params),'D:', 'G:' ) WHERE output_params LIKE '%D:%'