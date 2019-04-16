
EXEC sp_configure 'show advanced options', 1;
GO
RECONFIGURE WITH OVERRIDE;
GO
EXEC sp_configure 'max degree of parallelism', 8;
GO
RECONFIGURE WITH OVERRIDE;
GO

 EXEC sp_configure 'show advanced options', 1

GO

RECONFIGURE

GO

EXEC sp_configure 'Ad Hoc Distributed Queries', 1

GO

 EXEC sp_configure 'show advanced options', 0

GO

RECONFIGURE