USE [master]
GO
CREATE LOGIN [imiemike.ameh] WITH PASSWORD=N'Password123', DEFAULT_DATABASE=[ReportServer], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
EXEC master..sp_addsrvrolemember @loginame = N'imiemike.ameh', @rolename = N'sysadmin'
GO
USE [master]
GO
CREATE USER [imiemike.ameh] FOR LOGIN [imiemike.ameh]
GO
USE [master]
GO
EXEC sp_addrolemember N'db_owner', N'imiemike.ameh'
GO
USE [ReportServer]
GO
CREATE USER [imiemike.ameh] FOR LOGIN [imiemike.ameh]
GO
USE [ReportServer]
GO
EXEC sp_addrolemember N'db_owner', N'imiemike.ameh'
GO
USE [ReportServerTempDB]
GO
CREATE USER [imiemike.ameh] FOR LOGIN [imiemike.ameh]
GO
USE [ReportServerTempDB]
GO
EXEC sp_addrolemember N'db_owner', N'imiemike.ameh'
GO
