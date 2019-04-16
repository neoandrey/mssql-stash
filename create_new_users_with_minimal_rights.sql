USE [master]


USE [postilion_office]
GO
EXEC sp_addrolemember N'db_datareader', N'Onome.Areghan'
GO
USE [postilion_office]
GO
USE [postilion_office]
GO
EXEC sp_addrolemember N'postapp', N'Onome.Areghan'
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





DECLARE @user_name VARCHAR (100);

SET @user_name =''

EXEC master.dbo.sp_addlogin @loginame = N'oyindamola.aina', @passwd = N'Password123', @defdb = N'postilion_office'

USE [postilion_office]

EXEC dbo.sp_grantdbaccess @loginame = N'oyindamola.aina', @name_in_db = N'oyindamola.aina'

USE [postilion_office]

EXEC sp_addrolemember N'db_datareader', N'oyindamola.aina'

USE [postilion_office]

EXEC sp_addrolemember N'postaudit', N'oyindamola.aina'

USE [postilion_office]

EXEC sp_addrolemember N'postcfg', N'oyindamola.aina'

USE [postilion_office]

EXEC sp_addrolemember N'postmon', N'oyindamola.aina'

USE [postilion_office]

--EXEC sp_addrolemember N'postmon_cashcard', N'oyindamola.aina'
--

USE [postilion_office]

EXEC sp_addrolemember N'postparticipant', N'oyindamola.aina'

