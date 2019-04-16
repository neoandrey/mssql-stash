SELECT 
entity, user_params_defs , temp.template, report_params,template_id  INTO  #temp_template_info
FROM reports_crystal cry
 
   JOIN reports_crystal_template temp on REPLACE(CONVERT(VARCHAR(MAX), temp.template),'Office\reports\Balancing\', '') = SUBSTRING(cry.template, LEN(cry.template)-(CHARINDEX('\', REVERSE(cry.template))-2), LEN(cry.template)) 
 WHERE LEN(CONVERT(VARCHAR(MAX),temp.template)) > 0

   UPDATE reports_entity SET template_id = temp.template_id FROM reports_entity ent JOIN #temp_template_info temp ON ent.entity_id=temp.entity

 --  JOIN reports_entity ent on  cry.entity=ent.entity_id
 --ORDER BY ent.name

 cry
 
 --drop table #temp_template_info



SELECT * FROM #temp_template_info