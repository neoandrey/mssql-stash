SELECT substring(template, 44, ABS(len(template)-47)) TEMPLATE, name ENTITY_NAME,  SUBSTRING( 
SUBSTRING(output_params,2, CHARINDEX('.',output_params)-2),0,  (LEN(SUBSTRING(output_params,2, CHARINDEX('.',output_params)-2)) -CHARINDEX ('\', REVERSE(SUBSTRING(output_params,2, CHARINDEX('.',output_params)-2)))
)+1) PATH, 
SUBSTRING( 
SUBSTRING(output_params,2, CHARINDEX('.',output_params)-2),  (LEN(SUBSTRING(output_params,2, CHARINDEX('.',output_params)-2)) -CHARINDEX ('\', REVERSE(SUBSTRING(output_params,2, CHARINDEX('.',output_params)-2)))
)+2, LEN(SUBSTRING(output_params,2, CHARINDEX('.',output_params)-2)))+'_@timestamp' [FILE_NAME],

UPPER(SUBSTRING(output_params, CHARINDEX('.',output_params )+1, 3)) RENDER_FORMAT, report_params PARAMS FROM reports_entity ent JOIN reports_crystal cry ON ent.entity_id =cry.entity order BY template 