IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'smartpoint_monitor')
DROP LOGIN [smartpoint_monitor]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [smartpoint_monitor]    Script Date: 11/05/2013 12:15:37 ******/
CREATE LOGIN [smartpoint_monitor] WITH PASSWORD=N' 	fâ{  þ³LÌ7?`yÆå?ÂeÆ ø
B???\ÊÅ', DEFAULT_DATABASE=[postilion_smpt], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO

EXEC sys.sp_addsrvrolemember @loginame = N'smartpoint_monitor', @rolename = N'sysadmin'
GO

ALTER LOGIN [smartpoint_monitor] ENABLE
GO

--
USE postilion_smpt;

exec sp_change_users_login 'AUTO_FIX', 'smartpoint_monitor',NULL, 'Password123';




USE [postilion_office]
GO
EXEC sp_addlogin 'Onome.Areghan', 'Password123', 'postilion_office', 'us_english'
GO
USE [postilion_office]
GO
EXEC sp_adduser 'Onome.Areghan', 'Onome.Areghan'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datareader', N'Onome.Areghan'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postaudit', N'Onome.Areghan'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postcfg', N'Onome.Areghan'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postmon', N'Onome.Areghan'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postparticipant', N'Onome.Areghan'
GO