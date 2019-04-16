SELECT MAX(entity_id)  from  postilion_office.dbo.reports_entity


SELECT * from  postilion_office.dbo.reports_entity


SELECT new_entity_id = identity (int, 492,1), * INTO #REPORTS FROM [172.25.10.10].postilion_office.dbo.reports_entity ent  (NOLOCK) 
JOIN
 [172.25.10.10].postilion_office.dbo.reports_crystal cry (NOLOCK)
 ON
 ent.entity_id = cry.entity

 WHERE name   not in (

SELECT name  from reports_entity (NOLOCK)  
)

INSERT INTO REPORTS_ENTITY SELECT 
 new_entity_id, NAME,plugin_id,user_param_list,  NULL FROM #REPORTS

 insert into  reports_crystal
 Select 

 [new_entity_id]
      ,[template]
      ,[destination]
      ,[output_format]
      ,[output_params]
      ,[report_params]
      ,[crystal_version]
      ,[retention_period]
      ,[dsn_list]
      ,1

	  FROM  #REPORTS
