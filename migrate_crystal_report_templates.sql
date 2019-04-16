 UPDATE reports_crystal SET template = REPLACE(template, 'J:','C:')  
 
 UPDATE reports_crystal SET  output_format = 9   WHERE  output_format not  in (9,10,12)
 
 
 SELECT * FROM reports_crystal WHERE output_format not  in (9,10,12)
 
 UPDATE reports_crystal SET  output_params = CASE WHEN output_format = 9 THEN replace(convert(varchar(max),output_params),'.csv','')+'.csv~3~,~"~'
	     WHEN output_format = 10 THEN replace(convert(varchar(max),output_params),'.xls','')+'.xls~3~1'
	     WHEN output_format = 12 THEN  replace(convert(varchar(max),output_params),'.pdf','')+'.pdf~3~1~'
	     END 
  WHERE RIGHT(convert(VARCHAR(MAX),output_params),1)<> '~'
  
  
 update reports_crystal SET template =  rep.new_template
 FROM 
 reports_crystal cry 
 JOIN
 #reports rep 
 on
 cry.entity = rep.entity_id 
 where
 LEN(template)=0
 
 
 SELECT * FROM  reports_crystal WHERE LEFT(template,1) = 'j'
 
 UPDATE reports_crystal SET template = REPLACE(template, 'J:','C:')  
 
 UPDATE reports_crystal SET  output_format = 9   WHERE  output_format not  in (9,10,12)
 
 
 SELECT * FROM reports_crystal WHERE output_format not  in (9,10,12)
 
 UPDATE reports_crystal SET  output_params = CASE WHEN output_format = 9 THEN replace(convert(varchar(max),output_params),'.csv','')+'.csv~3~,~"~'
	     WHEN output_format = 10 THEN replace(convert(varchar(max),output_params),'.xls','')+'.xls~3~1'
	     WHEN output_format = 12 THEN  replace(convert(varchar(max),output_params),'.pdf','')+'.pdf~3~1~'
	     END 
  WHERE RIGHT(convert(VARCHAR(MAX),output_params),1)<> '~'
  
  select * from reports_crystal WHERE output_params LIKE '%XLS%'
 
 
 
 
 
 
 select max(ENTITY_ID) FROM [172.25.10.88].[postilion_office].[dbo].[reports_entity]  --3338

drop table #Computation_reports

SELECT 3338+ROW_NUMBER() OVER (ORDER BY ENTITY_id)new_entity_id, * into #Computation_reports FROM reports_entity ent  (NOLOCK) 
JOIN
 reports_crystal cry (NOLOCK)
 ON
 ent.entity_id = cry.entity

 WHERE name  LIKE '%computation%'
 AND   name NOT IN  (
 
  select name FROM [172.25.10.88].[postilion_office].dbo.reports_entity  WHERE name  LIKE '%computation%'  
 
 )
 

 
 INSERT INTO    [172.25.10.88].[postilion_office].[dbo].[reports_entity]
 (
 
 [entity_id]
      ,[name]
      ,[plugin_id]
      ,[user_param_list]
      ,[template_id]
      )
   SELECT
    new_entity_id  
   ,[name]
      ,[plugin_id]
      ,[user_param_list]
      ,NULL 
      from #Computation_reports
 
 
 INSERT INTO   [172.25.10.88].[postilion_office].DBO.REPORTS_CRYSTAL (
       [entity]
      ,[template]
      ,[destination]
      ,[output_format]
      ,[output_params]
      ,[report_params]
      ,[crystal_version]
      ,[retention_period]
      ,[dsn_list]
      ,[visible_in_portal]
      )
        
      
      select  new_entity_id
      ,[template]
      ,[destination]
      ,[output_format]
      ,[output_params]
      ,[report_params]
      ,[crystal_version]
      ,[retention_period]
      ,[dsn_list]
      ,1 FROM #Computation_reports
      
      