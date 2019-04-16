USE master;
GO
ALTER DATABASE postilion_office
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE postilion_office
SET AUTO_SHRINK OFF
GO

ALTER DATABASE postilion_office
SET MULTI_USER;
GO 

USE postilion_office;
go

checkpoint

exec sp_configure 'max server memory (MB)', 2000
reconfigure with override

waitfor delay '00:00:45'

exec sp_configure 'max server memory (MB)', 22000
reconfigure with override



USE master;
GO
ALTER DATABASE ReportServer
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE;
GO

ALTER DATABASE ReportServer
SET AUTO_SHRINK OFF
GO

ALTER DATABASE ReportServer
SET MULTI_USER;
GO 
