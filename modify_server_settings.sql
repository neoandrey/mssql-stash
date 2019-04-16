EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'min memory per query (KB)', N'684'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'5824'
GO
EXEC sys.sp_configure N'awe enabled', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'remote query timeout (s)', N'0'
GO
EXEC sys.sp_configure N'min memory per query (KB)', N'684'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'5824'
GO
EXEC sys.sp_configure N'awe enabled', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'fill factor (%)', N'95'
GO
EXEC sys.sp_configure N'remote query timeout (s)', N'0'
GO
EXEC sys.sp_configure N'min memory per query (KB)', N'684'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'5824'
GO
EXEC sys.sp_configure N'awe enabled', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'1'  RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'fill factor (%)', N'95'
GO
EXEC sys.sp_configure N'remote query timeout (s)', N'0'
GO
EXEC sys.sp_configure N'max degree of parallelism', N'6'
GO
EXEC sys.sp_configure N'min memory per query (KB)', N'684'
GO
EXEC sys.sp_configure N'max server memory (MB)', N'5824'
GO
EXEC sys.sp_configure N'awe enabled', N'1'
GO
EXEC sys.sp_configure N'filestream access level', N'1'
GO
RECONFIGURE WITH OVERRIDE
GO
EXEC sys.sp_configure N'show advanced options', N'0'  RECONFIGURE WITH OVERRIDE
GO
