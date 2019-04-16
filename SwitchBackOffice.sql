USE [postilion_office]
GO
CREATE ROLE [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_ddladmin] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_mon] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_audit] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_office_com] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_cfg] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postparticipant] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postilion] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datawriter] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postcfg] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postapp] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postaudit] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_securityadmin] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
--ALTER AUTHORIZATION ON SCHEMA::[dbo] TO [Switch BackOffice]
GO
USE [postilion_office]
GO
GRANT EXECUTE TO [Switch BackOffice]
GO
/*
USE [postilion_office]
GO
GRANT CONTROL TO[Switch BackOffice]
GO
USE [postilion_office]
GO
GRANT ALTER TO[Switch BackOffice]
GO
USE [postilion_office]
GO
*/

exec sp_MSForEachTable 'GRANT UPDATE ON ? TO [Switch BackOffice]'
GO


USE [msdb]
GO
CREATE ROLE [Switch BackOffice]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[RSExecRole] TO [Switch BackOffice]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentOperatorRole] TO [Switch BackOffice]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datawriter] TO [Switch BackOffice]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentUserRole] TO [Switch BackOffice]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [Switch BackOffice]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [Switch BackOffice]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentReaderRole] TO [Switch BackOffice]
GO
USE [msdb]
GO
--ALTER AUTHORIZATION ON SCHEMA::[Switch BackOffice] TO [ServerGroupAdministratorRole]
GO
USE [msdb]
GO
--ALTER AUTHORIZATION ON SCHEMA::[Switch BackOffice] TO [ServerGroupReaderRole]
GO
DENY EXECUTE ON sp_add_schedule to [INTERSWITCH\Switch BackOffice]
GO
GRANT EXECUTE ON    sp_update_job to [INTERSWITCH\Switch BackOffice]
GO
GRANT EXECUTE ON    sp_update_jobschedule to [INTERSWITCH\Switch BackOffice]
GO
GRANT EXECUTE ON    sp_update_jobstep to [INTERSWITCH\Switch BackOffice]
GO

