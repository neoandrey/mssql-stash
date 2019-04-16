
 DECLARE @template_name VARCHAR(250)

 DECLARE template_name CURSOR  LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT NAME FROM reports_entity WHERE NAME NOT IN (SELECT entity_name FROM post_process_spawn_config )
 OPEN template_name;
 FETCH NEXT FROM template_name INTO @template_name;
 WHILE (@@FETCH_STATUS =0)
      BEGIN
	INSERT INTO post_process_spawn_config (process_name, entity_name, default_path, environment, jvm_dll, office_properties_file, class_path, vm_options)
	VALUES ('Reports',@template_name, 'C:\postilion\Office\Reports\Crystal\bin90', NULL,'msjava.dll', NULL, NULL,NULL)

 FETCH NEXT FROM template_name INTO @template_name;
END
CLOSE template_name;
DEALLOCATE template_name;
