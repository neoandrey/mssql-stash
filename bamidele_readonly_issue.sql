use  master;
go

EXEC  sp_MSforeachdb 'ALTER DATABASE  ? SET  HADR OFF'
--EXEC  sp_MSforeachdb  ' RESTORE DATABASE   ? WITH  RECOVERY; '

SELECT 'RESTORE DATABASE  '+NAME+' WITH RECOVERY ' FROM sysdatabases where  name  not  in ('master', 'tempdb',  'msdb',  'model')