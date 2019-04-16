USE [msdb]
GO
CREATE ROLE [CoreOperations]
GO
USE [msdb]
GO
--ALTER AUTHORIZATION ON SCHEMA::[RSExecRole] TO [CoreOperations]
--GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentOperatorRole] TO [CoreOperations]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentUserRole] TO [CoreOperations]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [CoreOperations]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_owner] TO [CoreOperations]
GO
USE [msdb]
GO
ALTER AUTHORIZATION ON SCHEMA::[SQLAgentReaderRole] TO [CoreOperations]
GO

USE [msdb]
GO
EXEC sp_addrolemember N'SQLAgentOperatorRole', N'CoreOperations'
GO
EXEC sp_addrolemember N'SQLAgentReaderRole', N'CoreOperations'
GO
EXEC sp_addrolemember N'SQLAgentUserRole', N'CoreOperations'
GO

USE [postilion_office]
GO
CREATE ROLE [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_mon] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_audit] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_office_com] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[post_cfg] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postmon] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_datareader] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postcfg] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postapp] TO [CoreOperations]
GO
USE [postilion_office]
GO
ALTER AUTHORIZATION ON SCHEMA::[postaudit] TO [CoreOperations]
GO
USE [postilion_office]
GO
--ALTER AUTHORIZATION ON SCHEMA::[dbo] TO [CoreOperations]
--GO

GRANT EXECUTE TO CoreOperations

GO