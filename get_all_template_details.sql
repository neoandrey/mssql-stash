SELECT * FROM reports_entity ent  (NOLOCK) 
JOIN
 reports_crystal cry (NOLOCK)
 ON
 ent.entity_id = cry.entity

 WHERE name  LIKE '%participating%'
 
~NULL~NULL~SWTFBNsrc~3IAP0001~SWTFBNsnk,SWTFBN1snk~NULL~NULL~NULL~NULL~
~NULL~NULL~SWTFBNsrc~3IAP0001~SWTFBNsnk,SWTFBN1snk~NULL~NULL~NULL~NULL~
~NULL~NULL~SWTFBNsrc~3IAP0001~SWTFBNsnk,SWTFBN1snk~NULL~NULL~NULL~NULL~




SELECT 
 id = IDENTITY(INT,1,1) ,
 name, plugin_id, null [user_param_list]
      , null [template_id]
      ,'C:\postilion\'+tmp.template template
      ,[destination]
      , CONVERT(VARCHAR(max),[output_format]) output_format
      , CONVERT(VARCHAR(max),[output_params])output_params
      , CONVERT(VARCHAR(max),[report_params])report_params
      ,[crystal_version]
      ,[retention_period]
      ,[dsn_list]
      ,[visible_in_portal]
      INTO #reports_crystal_migration
       FROM  [172.25.10.9].postilion_office.dbo.reports_entity ent  (NOLOCK) 
JOIN
 [172.25.10.9].postilion_office.dbo.reports_crystal cry (NOLOCK)
 ON
 ent.entity_id = cry.entity
 JOIN
 [172.25.10.9].postilion_office.dbo.reports_crystal_template tmp
 on
 ent.template_id = tmp.template_id

 ===Investigate template errors=======
SELECT 'exec master.dbo.xp_cmdshell ''C:\postilion\Office\base\bin\run_office_process.cmd Reports '+ process_entity+''';  WHILE ((SELECT COUNT(*) FROM post_process_queue)>10)  WAITFOR DELAY ''00:00:10''; WAITFOR DELAY ''00:00:05'';'  command, * FROM reports_entity ent  (NOLOCK) 
JOIN
 reports_crystal cry (NOLOCK)
 ON
 ent.entity_id = cry.entity
 join
   (
     SELECT  distinct process_name, process_entity FROM post_process_run (NOLOCK) WHERE process_name  =  'Reports' 
     AND result_value  = 30
     ) pro
   ON
   pro.process_entity  = ent.name 
   JOIN reports_crystal_template tmp
   on ent.template_id = tmp.template_id
