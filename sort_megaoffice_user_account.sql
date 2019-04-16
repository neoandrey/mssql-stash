USE [postilion_office]
GO
EXEC dbo.sp_grantdbaccess @loginame = N'eloho.ogude', @name_in_db = N'eloho.ogude'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datareader', N'eloho.ogude'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datawriter', N'eloho.ogude'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_owner', N'eloho.ogude'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postaudit', N'eloho.ogude'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postcfg', N'eloho.ogude'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postmon', N'eloho.ogude'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postparticipant', N'eloho.ogude'
GO