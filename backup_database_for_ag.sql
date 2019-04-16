 SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB3\'+name+'full_20170608.bak''  WITH  INIT' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

 SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB3\'+name+'_diff_20180413_'+ REPLACE(REPLACE(CONVERT(VARCHAR(30), GETDATE(), 108), ' ', '_'),':', '')+'.bak''  WITH  DIFFERENTIAL' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

  SELECT 'BACKUP LOG ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB3\'+name+'_log_full_20170608.trn''  WITH NOFORMAT, NOINIT,  NAME = N'''+NAME+'-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD, COMPRESSION,  STATS = 10' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 ) 

 
 SELECT   distinct  'RESTORE DATABASE ['+[database_name]+'] FROM DISK ='''+[physical_device_name]+''' WITH  REPLACE, NORECOVERY' FROM  OPENQUERY([ISWLOS-DB-22A],'SELECT TOP  12
 [database_name],
 physical_device_name
 ,[backup_finish_date]
     
  FROM [msdb].[dbo].[backupset]a WITH (NOLOCK)
  JOIN 
  [msdb].[dbo].[backupmediafamily] b WITH (NOLOCK)
  ON a.media_set_id = b.media_set_id
  Where database_name  IN (select   name FROM sys.sysdatabases where name not in  (
 ''master'', ''tempdb'',''model'',''msdb''
 )
  and physical_device_name  LIKE ''%diff_20180312%''
) order by b.[media_set_id] desc')

