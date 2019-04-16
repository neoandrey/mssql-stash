EXEC sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'min memory per query (KB)', N'512'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'max worker threads', N'1024'
GO
EXEC sp_configure N'min memory per query (KB)', N'512'
GO
RECONFIGURE
GO
EXEC sp_configure N'max worker threads', N'712'
GO
RECONFIGURE
EXEC sp_configure N'remote query timeout (s)', N'0'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'fill factor (%)', N'90'
GO
EXEC sp_configure N'remote query timeout (s)', N'0'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'fill factor (%)', N'90'
GO
EXEC sp_configure N'max degree of parallelism', N'1'
GO
EXEC sp_configure N'optimize for ad hoc workloads', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sp_configure N'awe enabled', N'1'
GO
EXEC sp_configure N'show advanced options', N'1' 
GO
 RECONFIGURE WITH OVERRIDE
GO
