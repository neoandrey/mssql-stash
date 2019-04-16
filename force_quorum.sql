C:\>Net stop clussvc
C:\>Net start clussvc /forcequorum

USE master
GO
PRINT @@SERVERNAME
GO
ALTER AVAILABILITY GROUP AGTest FORCE_FAILOVER_ALLOW_DATA_LOSS;
GO


select  'ALTER DATABASE ['+NAME+'] SET HADR RESUME;'+char(10)+char(13)+' GO' from sys.sysdatabases WHERE  name  not in ('master','tempdb','msdb','model')
