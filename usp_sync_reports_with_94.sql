
CREATE  procedure usp_sync_reports_with_89 as begin

dELETE FRom reports_crystal_ondemand
dELETE FRom reports_ondemand
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reports_template_backup]') AND type in (N'U')) BEGIN  DROP TABLE [reports_template_backup] END
select * into reports_template_backup from reports_template (NOLOCK)
delete from reports_crystal_template
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reports_entity_backup]') AND type in (N'U')) BEGIN  DROP TABLE reports_entity_backup END
select * into reports_entity_backup from reports_entity (NOLOCK) 
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reports_crystal_backup]') AND type in (N'U')) BEGIN  DROP TABLE reports_crystal_backup END
select * into reports_crystal_backup from reports_crystal(NOLOCK)
delete from reports_crystal
delete from reports_entity 
delete from reports_template

INSERT INTO reports_template SELECT * FROM [172.25.10.89].[postilion_office].[dbo].reports_template
INSERT INTO reports_entity SELECT * FROM [172.25.10.89].[postilion_office].[dbo].reports_entity
INSERT INTO reports_crystal SELECT * FROM [172.25.10.89].[postilion_office].[dbo].[reports_crystal]
INSERT INTO reports_crystal_template SELECT * FROM [172.25.10.89].[postilion_office].[dbo].reports_crystal_template
UPDATE reports_crystal set output_params = REPLACE(CONVERT(VARCHAR(max),output_params ), 'K:', 'E:')

end