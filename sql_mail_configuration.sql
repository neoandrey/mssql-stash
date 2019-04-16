sp_configure 'show advanced', 1; 
GO
RECONFIGURE;
GO
sp_configure;
GO

sp_configure 'Database Mail XPs', 1; 
GO
RECONFIGURE;
GO


sp_configure 'show advanced', 0; 
GO
RECONFIGURE;
GO