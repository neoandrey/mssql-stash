USE [postilion_office]
GO
CREATE ROLE [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_ddladmin] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_mon] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_audit] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_office_com] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_cfg] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postparticipant] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postilion] TO [CoreTechnology]
GO
USE [postilion_office]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datawriter] TO [CoreTechnology]
GO
USE [postilion_office]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postcfg] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postapp] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postaudit] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [CoreTechnology]
GO
USE [postilion_office]
GO
GO
ALTER AUTHORIZATION ON SCHEMA::[db_securityadmin] TO [CoreTechnology]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[dbo] TO [CoreTechnology]
GO
USE [postilion_office]
GO
GRANT EXECUTE TO [CoreTechnology]
GO
USE [postilion_office]
GO
--GRANT CONTROL TO[CoreTechnology]
--GO
--USE [postilion_office]
--GO
--GRANT ALTER TO[CoreTechnology]
--GO

USE [msdb]
GO
CREATE ROLE [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[RSExecRole] TO [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentOperatorRole] TO [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datawriter] TO [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentUserRole] TO [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentReaderRole] TO [CoreTechnology]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[CoreTechnology] TO [ServerGroupAdministratorRole]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[CoreTechnology] TO [ServerGroupReaderRole]
GO
DENY EXECUTE ON sp_add_schedule to [CoreTechnology]
GO
GRANT EXECUTE ON    sp_update_job to [CoreTechnology]
GO
GRANT EXECUTE ON    sp_update_jobschedule to [CoreTechnology]
GO
GRANT EXECUTE ON    sp_update_jobstep to [CoreTechnology]
GO