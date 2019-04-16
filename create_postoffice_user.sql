USE [master]
GO
CREATE LOGIN [oluwaseun.ogundele] WITH PASSWORD=N'Password12' MUST_CHANGE, DEFAULT_DATABASE=[postilion_office], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
USE [postilion_office]
GO
CREATE USER [oluwaseun.ogundele] FOR LOGIN [oluwaseun.ogundele]
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datareader', N'oluwaseun.ogundele'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datawriter', N'oluwaseun.ogundele'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postapp', N'oluwaseun.ogundele'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postaudit', N'oluwaseun.ogundele'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postcfg', N'oluwaseun.ogundele'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postmon', N'oluwaseun.ogundele'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postparticipant', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
CREATE USER [oluwaseun.ogundele] FOR LOGIN [oluwaseun.ogundele]
GO
USE [realtime]
GO
EXEC sp_addrolemember N'db_datareader', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'db_datawriter', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postapp', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postaud', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postcfg', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postmon', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postpart', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postsec', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postserv', N'oluwaseun.ogundele'
GO
USE [realtime]
GO
EXEC sp_addrolemember N'postweb', N'oluwaseun.ogundele'
GO
