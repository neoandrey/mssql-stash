USE [postilion_office]
GO
EXEC sp_addlogin 'ignite', 'Password12', 'postilion_office', 'us_english'
GO
USE [postilion_office]
GO
EXEC sp_adduser 'ignite', 'ignite'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datareader', N'ignite'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postaudit', N'ignite'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postcfg', N'ignite'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postmon', N'ignite'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postparticipant', N'ignite'
GO

EXEC sp_addrolemember N'db_owner', N'ignite'
GO


USE [postilion_office]
GO
EXEC sp_addlogin 'mdynamix', 'Dynam1x12!', 'postilion_office', 'us_english'
GO
USE [postilion_office]
GO
EXEC sp_adduser 'mdynamix', 'mdynamix'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datareader', N'mdynamix'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postaudit', N'mdynamix'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postcfg', N'mdynamix'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postmon', N'mdynamix'
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postparticipant', N'mdynamix'
GO

EXEC sp_addrolemember N'db_owner', N'mdynamix'
GO


