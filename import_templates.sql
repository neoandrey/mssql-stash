
dELETE FRom reports_crystal_ondemand
dELETE FRom reports_ondemand
drop  table reports_template_backup 
select * into reports_template_backup from reports_template (NOLOCK)
delete from reports_entity 
delete from reports_template

delete from reports_crystal_template
drop table reports_entity_backup
select * into reports_entity_backup from reports_entity (NOLOCK)
delete from reports_entity 
DROP TABLE reports_crystal_backup
select * into reports_crystal_backup from reports_crystal(NOLOCK)
delete from reports_crystal

INSERT INTO reports_template SELECT * FROM [172.25.10.94].[postilion_office].[dbo].reports_template
INSERT INTO reports_entity SELECT * FROM [172.25.10.94].[postilion_office].[dbo].reports_entity
INSERT INTO reports_crystal SELECT * FROM [172.25.10.94].[postilion_office].[dbo].[reports_crystal]
INSERT INTO reports_crystal_template SELECT * FROM [172.25.10.94].[postilion_office].[dbo].reports_crystal_template

