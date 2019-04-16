;WITH  entity_table AS 
(
	SELECT * FROM  [172.25.10.94].[postilion_office].dbo.reports_entity ent 
	JOIN  [172.25.10.94].[postilion_office].dbo.reports_crystal cry  ON
	ent.entity_id = cry.entity
	UNION  all
	SELECT * FROM  [172.25.10.89].[postilion_office].dbo.reports_entity ent 
	JOIN  [172.25.10.89].[postilion_office].dbo.reports_crystal cry  ON
	ent.entity_id = cry.entity
	UNION  all
	SELECT * FROM  [172.75.75.10].[postilion_office].dbo.reports_entity ent 
	JOIN  [172.75.75.10].[postilion_office].dbo.reports_crystal cry  ON
	ent.entity_id = cry.entity
)

SELECT  DISTINCT   name, plugin_id, null [user_param_list]
      , null [template_id]
 , CONVERT(VARCHAR(max),[template])template
      ,[destination]
      , CONVERT(VARCHAR(max),[output_format]) output_format
      , CONVERT(VARCHAR(max),[output_params])output_params
      , CONVERT(VARCHAR(max),[report_params])report_params
      ,[crystal_version]
      ,[retention_period]
      ,[dsn_list]
      ,[visible_in_portal] 
      INTO  #temp_table_1
      FROM entity_table
      