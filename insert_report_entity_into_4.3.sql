/****** Script for SelectTopNRows command from SSMS  ******/

DECLARE @max_template_id BIGINT;
DECLARE @current_template_id BIGINT;
DECLARE @template VARCHAR(250)

SELECT @max_template_id = (SELECT TOP 1 template_id FROM [reports_template] ORDER BY template_id DESC)

SELECT @current_template_id =  @max_template_id+10;
SELECT @current_template_id = ISNULL(@current_template_id,13421412)
DECLARE template_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT  REPLACE(RTRIM(LTRIM(SUBSTRING(template, LEN(template)-(CHARINDEX('\',REVERSE(template))-2),LEN(template)))), '.rpt', '') FROM [172.25.10.7].[postilion_office].dbo.[reports_crystal];
OPEN template_cursor;
FETCH NEXT FROM template_cursor INTO @templatE;
WHILE (@@FETCH_STATUS=0)BEGIN
		INSERT INTO [postilion_office].[dbo].[reports_template](template_id,plugin_id, template_name, category)
		VALUES(@current_template_id, 'Crystal', @template, 'Balancing');
		SELECT @current_template_id =  @current_template_id+20;
		FETCH NEXT FROM template_cursor INTO @template;
END
CLOSE template_cursor;
DEALLOCATE template_cursor;


;WITH entity (entity_id,name,plugin_id,user_param_list) AS(
SELECT 
 (entity_id) as 'entity_id',name,plugin_id,user_param_list
  FROM [172.25.10.7].[postilion_office].[dbo].[reports_entity]),
 templates (entity,template,destination, output_format, output_params, report_params,crystal_version,retention_period,dsn_list ) AS(
SELECT entity,template,destination, output_format, output_params, report_params,crystal_version,retention_period,dsn_list FROM [172.25.10.7].[postilion_office].dbo.[reports_crystal]),
report_template ([template_id] ,[plugin_id],[template_name],[category]) AS (
SELECT [template_id] ,[plugin_id],[template_name],[category]  FROM [postilion_office].[dbo].[reports_template]
)

select  DISTINCT entity.[entity_id]
      , entity.[name]
      , entity.[plugin_id]
      , entity.[user_param_list]
      ,report_template.[template_id] 
      INTO #reports_entity
       FROM entity , templates, report_template WHERE entity.entity_id = templates.entity AND templates.template like '%'+report_template.template_name+'%'
      
 DECLARE @entity INT;
 DECLARE @name VARCHAR(50)
 DECLARE @plugin_id VARCHAR (20)
 DECLARE @user_param_list VARCHAR(500)
 DECLARE @template_id BIGINT;
 
 DECLARE report_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT  DISTINCT [entity_id], [name], [plugin_id] , [user_param_list],[template_id] FROM #reports_entity
 OPEN report_cursor;
 FETCH NEXT FROM report_cursor INTO @entity, @name, @plugin_id, @user_param_list, @template_id
 WHILE (@@FETCH_STATUS=0)
 BEGIN
 IF NOT EXISTS (SELECT name FROM [reports_entity] WHERE [entity_id] = @entity)
 BEGIN
  INSERT INTO  [reports_entity](
        [entity_id]
      ,[name]
      ,[plugin_id]
      ,[user_param_list]
      ,[template_id]
      ) VALUES (
      @entity,
      @name, 
      @plugin_id,
      @user_param_list,
      @template_id
      )
    END
     FETCH NEXT FROM report_cursor INTO @entity, @name, @plugin_id, @user_param_list, @template_id
  END
  
  CLOSE report_cursor;
  DEALLOCATE report_cursor;
  

  DECLARE @entity_id BIGINT;
DECLARE @name VARCHAR(30)

DECLARE entity_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT entity_id, name FROM reports_entity WHERE entity_id>8;
OPEN entity_cursor;
FETCH NEXT FROM entity_cursor INTO @entity_id, @name;
WHILE (@@FETCH_STATUS=0)BEGIN
INSERT INTO reports_crystal(
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
SELECT @entity_id
      ,[template]
      ,[destination]
      ,[output_format]
      ,[output_params]
      ,[report_params]
      ,[crystal_version]
      ,[retention_period]
      ,[dsn_list]
      ,1
  FROM [172.25.10.7].[postilion_office].[dbo].[reports_crystal] cry
  JOIN 
	[172.25.10.7].[postilion_office].[dbo].[reports_entity] ent
	ON 
    cry.entity = ent.entity_id
    WHERE ent.name=@name

FETCH NEXT FROM entity_cursor INTO @entity_id, @name;
END
CLOSE entity_cursor;
DEALLOCATE entity_cursor;


SELECT * FROM [reports_crystal]

  
  
  DECLARE @entity_id BIGINT;
  DECLARE @template_id BIGINT;
  DECLARE @template_name VARCHAR(250)
  
  DECLARE entity_id_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT entity_id FROM  [postilion_office].[dbo].[reports_entity];
  OPEN  entity_id_cursor;
  FETCH NEXT FROM entity_id_cursor INTO @entity_id;
  
  WHILE (@@FETCH_STATUS=0)BEGIN
   SELECT @template_name = RTRIM(LTRIM(SUBSTRING(template, LEN(template)-(CHARINDEX('\',REVERSE(template))-2),LEN(template)))) FROM reports_crystal WHERE entity =  @entity_id
   SELECT @template_id = template_id FROM reports_crystal_template WHERE template LIKE '%'+@template_name+'%';
   UPDATE reports_entity SET template_id=@template_id where entity_id =@entity_id;
   FETCH NEXT FROM entity_id_cursor INTO @entity_id;
  END
  CLOSE entity_id_cursor;
  DEALLOCATE entity_id_cursor;
  

  

