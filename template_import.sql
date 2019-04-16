--drop table #temp_table_1
--drop table #temp_table_2
--drop table #temp_table_3
--drop table #temp_table_4

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
      
      where name not in 
      
      (SELECT NAME  FROM 
      #temp_table_2)
     
      
     -- SELECT * FROM #temp_table_2 where name = '234LIVE'
     
      
 UPDATE #temp_table_1 SET  output_params = REPLACE(CONVERT(varchar(max), output_params), 'F:', 'E:')
 UPDATE #temp_table_1 SET  template = REPLACE(CONVERT(varchar(max), template), 'J:', 'C:')
 UPDATE #temp_table_1 SET  template = REPLACE(CONVERT(varchar(max), template), '\Office\reports\', '\Office\base\reports\')
 
 SELECT * FROM #temp_table_1 WHERE name = 'Acq_Proc_Pospay'
  
  SELECT *  INTO  #temp_table_2 FROM #temp_table_1 where name in (
 SELECT name FROM #temp_table_1 WHERE template is not null
 GROUP BY name 
  HAVING COUNT(NAME)>1 
)

 UPDATE #temp_table_4 SET  output_params = REPLACE(REPLACE(CONVERT(varchar(max), output_params), 'F:', 'E:'), 'G:', 'E:')
 UPDATE #temp_table_4 SET  template = REPLACE(CONVERT(varchar(max), template), 'J:', 'C:')
 UPDATE #temp_table_4 SET  template = REPLACE(CONVERT(varchar(max), template), '\Office\reports\', '\Office\base\reports\')
 
 SELECT * FROM #temp_table_4
 
 

 
 select top 1 * INTO  #temp_table_2 FROM #temp_table_1
 
 alter table #temp_table_2 alter column name varchar(5000) not null
 go
 ALTER TABLE #temp_table_2 ADD constraint pk_entity_name   PRIMARY KEY (
  name 
 )
 go
 ALTER TABLE #temp_table_2 ADD entity_id INT IDENTITY(1,1)
 
 
 
DECLARE @report_name VARCHAR(500)
DECLARE report_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT  NAME FROM #temp_table_1 where  LEN(template) != 0 ORDER BY name
OPEN report_cursor 
FETCH NEXT FROM report_cursor INTO  @report_name
WHILE (@@FETCH_STATUS=0)BEGIN
INSERT INTO #temp_table_2
SELECT  top 1 * FROM #temp_table_1 WHERE name = @report_name 
FETCH NEXT FROM report_cursor INTO  @report_name
END
DEALLOCATE report_cursor
CLOSE report_cursor

 
SELECT * FROM  #temp_table_2 WHERE name  ='UBA_PrepaidCardLoad_csv' 

  select *  INTO #temp_table_3 from #temp_table_1  where  LEN(template) = 0 
	
	select  * INTO #temp_table_4  from  (
	SELECT name,	plugin_id,	user_param_list, NULL	template_id, 'C:\postilion\'+tem.template template,	destination, output_format,output_params,	report_params,	crystal_version,	retention_period,	dsn_list,	visible_in_portal,	entity_id FROM  [172.25.10.89].[postilion_office].dbo.reports_entity ent 
	JOIN  [172.25.10.89].[postilion_office].dbo.reports_crystal cry  ON 
	ent.entity_id = cry.entity
	JOIN [172.25.10.89].[postilion_office].dbo.reports_crystal_template tem 
	ON ent.template_id = tem.template_id
	 WHERE name IN (
	SELECT name FROM #temp_table_3
	)
	and ent.template_id is not null 
	UNION ALL
	SELECT name,	plugin_id,	user_param_list, NULL	template_id, 'C:\postilion\'+tem.template template,	destination, output_format,output_params,	report_params,	crystal_version,	retention_period,	dsn_list,	visible_in_portal,	entity_id
	 FROM  [172.25.10.94].[postilion_office].dbo.reports_entity ent 
	JOIN  [172.25.10.94].[postilion_office].dbo.reports_crystal cry  ON
	ent.entity_id = cry.entity
	JOIN [172.25.10.94].[postilion_office].dbo.reports_crystal_template tem 
	ON ent.template_id = tem.template_id
	 WHERE name IN (
	SELECT name FROM #temp_table_3
	)
	and ent.template_id is not null  
	UNION ALL
	SELECT name,	plugin_id,	user_param_list, NULL	template_id, 'C:\postilion\'+tem.template template,	destination, output_format,output_params,	report_params,	crystal_version,	retention_period,	dsn_list,	visible_in_portal,	entity_id 
	FROM  [172.75.75.10].[postilion_office].dbo.reports_entity ent 
	JOIN  [172.75.75.10].[postilion_office].dbo.reports_crystal cry  ON
	ent.entity_id = cry.entity
	JOIN [172.75.75.10].[postilion_office].dbo.reports_crystal_template tem 
	ON ent.template_id = tem.template_id
	 WHERE name IN (
	SELECT name FROM #temp_table_3
	)
	and ent.template_id is not null  ) tab
	

	

DECLARE @report_name VARCHAR(500)
DECLARE report_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT DISTINCT NAME FROM #temp_table_4
 where  LEN(template) != 0 ORDER BY name
OPEN report_cursor 
FETCH NEXT FROM report_cursor INTO  @report_name
WHILE (@@FETCH_STATUS=0)BEGIN
INSERT INTO #temp_table_2
SELECT 
 name, plugin_id, null [user_param_list]
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
 FROM #temp_table_4 WHERE name = @report_name 
 
FETCH NEXT FROM report_cursor INTO  @report_name
END
DEALLOCATE report_cursor
CLOSE report_cursor

	select * from #temp_table_1
	 where name not in(
		SELECT  NAME from #temp_table_2
	)	
	
SELECT * FROM #temp_table_2


INSERT INTO #temp_table_2
select  TOP 1 name, plugin_id, null [user_param_list]
      , null [template_id]
 , CONVERT(VARCHAR(max),[template])template
      ,[destination]
      , CONVERT(VARCHAR(max),[output_format]) output_format
      , CONVERT(VARCHAR(max),[output_params])output_params
      , CONVERT(VARCHAR(max),[report_params])report_params
      ,[crystal_version]
      ,[retention_period]
      ,[dsn_list]
      ,[visible_in_portal] from #temp_table_4 where name not in (
	select name  from #temp_table_2
	)


SELECT * FROM  [172.25.10.94].[postilion_office].dbo.reports_entity ent 
	JOIN  [172.25.10.94].[postilion_office].dbo.reports_crystal cry  ON
	ent.entity_id = cry.entity WHERE name  = 'UBA_PrepaidCardLoad_csv'
	
	SELECT * FROM [172.25.10.94].[postilion_office].dbo.reports_crystal_TEMPLATE where TEMPLATE_ID = -618768440
	
	SELECT * FROM #temp_table_4 where  name=  'UBA_PrepaidCardLoad_csv' and 
	 LEN(template) != 0 
	
	
	
	 
