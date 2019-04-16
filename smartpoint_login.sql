USE [master]
GO
CREATE LOGIN [smartpoint_monitor] WITH PASSWORD=N'Smartp01nt12', DEFAULT_DATABASE=[postilion_smpt], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
EXEC master..sp_addsrvrolemember @loginame = N'smartpoint_monitor', @rolename = N'sysadmin'
GO
USE [postilion_smpt]
GO
CREATE USER [smartpoint_monitor] FOR LOGIN [smartpoint_monitor]
GO
USE [postilion_smpt]
GO
EXEC sp_addrolemember N'db_datareader', N'smartpoint_monitor'
GO
USE [postilion_smpt]
GO
EXEC sp_addrolemember N'db_datawriter', N'smartpoint_monitor'
GO
