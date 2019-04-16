SELECT * INTO #reports_crystal FROM [172.25.10.8].[postilion_office].dbo.[reports_crystal];

SELECT * INTO #reports_entity FROM [172.25.10.8].[postilion_office].dbo.[reports_entity];

SELECT * FROM #reports_entity WHERE name NOT IN (SELECT name FROM  #reports_entity)

DECLARE @entity_id BIGINT;
DECLARE @name VARCHAR(250);
DECLARE @report_params VARCHAR(1000);
DECLARE @output_format VARCHAR(1000);
DECLARE @template VARCHAR(1000);

DECLARE name_cursor CURSOR STATIC READ_ONLY   LOCAL FORWARD_ONLY  FOR SELECT name, report_params, template, output_format FROM #reports_entity ent, #reports_crystal cry WHERE ent.entity_id = cry.entity ;
OPEN name_cursor;
FETCH NEXT FROM name_cursor INTO @name, @report_params,@template, @output_format;

WHILE (@@FETCH_STATUS=0)BEGIN
	SELECT @entity_id = entity_id FROM reports_entity WHERE name =@name;
	UPDATE reports_crystal SET report_params=@report_params, output_format =@output_format, template = @template WHERE entity= @entity_id 

FETCH NEXT FROM name_cursor INTO @name, @report_params,@template, @output_format;

END
CLOSE name_cursor;
DEALLOCATE name_cursor;
