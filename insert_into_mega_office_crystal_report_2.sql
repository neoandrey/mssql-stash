/****** Script for SelectTopNRows command from SSMS  ******/



select   (99+entity_id) ,name,plugin_id,user_param_list
     
  FROM [172.25.10.8].[postilion_office].[dbo].[reports_entity])
      
      
   DECLARE @template VARCHAR(100)
 DECLARE @output_format VARCHAR (50)
  DECLARE @output_params VARCHAR (50)
   DECLARE @destination VARCHAR (150)
    DECLARE @report_params VARCHAR (50)
     DECLARE @crystal_version VARCHAR (50)

 DECLARE report_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT  DISTINCT [entity_id],[name] ,[plugin_id],[user_param_list] FROM [reports_entity]
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
      ) VALUES (
      @entity,
      @name, 
      @plugin_id,
      @user_param_list
      )
    END
     FETCH NEXT FROM report_cursor INTO @entity, @name, @plugin_id, @user_param_list, @template_id
  END
  
  CLOSE report_cursor;
  DEALLOCATE report_cursor;    
      
DECLARE @entity int
DECLARE @template VARCHAR(4000)
DECLARE @destination INT
DECLARE @output_format INT
DECLARE @output_params VARCHAR(4000)
DECLARE @report_params VARCHAR(4000)
DECLARE @crystal_version INT
DECLARE @retention_period INT
DECLARE @dsn_list VARCHAR(255)
DECLARE @visible_in_portal INT


 
 DECLARE report_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT  [entity],[template],[destination] ,[output_format],[output_params] ,[report_params],[crystal_version] ,[retention_period],[dsn_list],[visible_in_portal] FROM #reports_crystal
 OPEN report_cursor;
 FETCH NEXT FROM report_cursor INTO @entity,@template,@destination ,@output_format,@output_params ,@report_params,@crystal_version ,@retention_period,@dsn_list,@visible_in_portal
 WHILE (@@FETCH_STATUS=0)
 BEGIN
 IF NOT EXISTS (SELECT [entity] FROM [reports_crystal] WHERE [entity] = @entity)
 BEGIN
  INSERT INTO  [reports_crystal](
       [entity],[template],[destination] ,[output_format],[output_params] ,[report_params],[crystal_version] ,[retention_period],[dsn_list],[visible_in_portal]
      ) VALUES 
      ( @entity,@template,@destination ,@output_format,@output_params ,@report_params,@crystal_version ,@retention_period,@dsn_list,@visible_in_portal
      )
    END
 FETCH NEXT FROM report_cursor INTO @entity,@template,@destination ,@output_format,@output_params ,@report_params,@crystal_version ,@retention_period,@dsn_list,@visible_in_portal
  END
  
  CLOSE report_cursor;
  DEALLOCATE report_cursor;
  
  
  /****** Script for SelectTopNRows command from SSMS  ******/
SELECT [template_id]
      ,[plugin_id]
      ,[template_name]
      ,[category] 
  FROM [postilion_office].[dbo].[reports_template] ORDER BY [template_id]
  SELECT * FROM dbo.reports_ondemand
 DELETE FROM [postilion_office].[dbo].[reports_template] WHERE template_id NOT IN (SELECT DISTINCT template_id FROM reports_crystal_template) AND 
 template_id NOT IN(SELECT template_id FROM dbo.reports_ondemand)
  
  
    