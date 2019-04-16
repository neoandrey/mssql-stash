SELECT *  INTO reports_entity_20160616_backup FROM reports_entity  (NOLOCK) 
SELECT *  INTO reports_crystal_20160616_backup  FROM reports_crystal  (NOLOCK) 
SELECT *  INTO reports_crytal_template_20160616_backup  FROM reports_crystal_template  (NOLOCK)
SELECT *  INTO reports_template_20160616_backup  FROM  reports_template (NOLOCK)

DELETE FROM reports_crystal_ondemand
DELETE FROM reports_template
DELETE FROM reports_crystal
DELETE FROM reports_crystal_template 
DELETE FROM reports_entity
 
insert into reports_template SELECT * FROM  [172.25.10.94].[postilion_OFfice].dbo.reports_template 
insert into reports_crystal_template SELECT * FROM  [172.25.10.94].[postilion_OFfice].dbo.reports_crystal_template 
insert into reports_entity SELECT * FROM  [172.25.10.94].[postilion_OFfice].dbo.reports_entity
insert into reports_crystal SELECT * FROM  [172.25.10.94].[postilion_OFfice].dbo.reports_crystal