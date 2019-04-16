
 SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backups\db1\'+name+'_diff_20180312_'+ REPLACE(REPLACE(CONVERT(VARCHAR(30), GETDATE(), 108), ' ', '_'),':', '')+'.bak''  WITH  DIFFERENTIAL' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

BACKUP DATABASE [cashcard] TO   DISK = '\\172.38.1.195\backups\db1\cashcard_diff_20180312_000340.bak'  WITH  DIFFERENTIAL
BACKUP DATABASE [college_paydirect] TO   DISK = '\\172.38.1.195\backups\db1\college_paydirect_diff_20180312_000340.bak'  WITH  DIFFERENTIAL
BACKUP DATABASE [new_payment_gateway] TO   DISK = '\\172.38.1.195\backups\db1\new_payment_gateway_diff_20180312_000340.bak'  WITH  DIFFERENTIAL
BACKUP DATABASE [paydirect_channels] TO   DISK = '\\172.38.1.195\backups\db1\paydirect_channels_diff_20180312_000340.bak'  WITH  DIFFERENTIAL
BACKUP DATABASE [paydirect_core] TO   DISK = '\\172.38.1.195\backups\db1\paydirect_core_diff_20180312_000340.bak'  WITH  DIFFERENTIAL
BACKUP DATABASE [verve_prepaid] TO   DISK = '\\172.38.1.195\backups\db1\verve_prepaid_diff_20180312_000340.bak'  WITH  DIFFERENTIAL



 SELECT   distinct  'RESTORE DATABASE ['+[database_name]+'] FROM DISK ='''+[physical_device_name]+''' WITH  REPLACE, NORECOVERY' FROM  OPENQUERY([ISWLOS-DB-1a],'SELECT TOP  12
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





 SELECT  'ALTER DATABASE ['+name+'] SET HADR AVAILABILITY GROUP = DB23_DAG; '  FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )
 
 
 
 
 
 
  SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backups\db1\'+name+'_diff_'+CONVERT(varchar(8), GETDATE(),112)+'_'+ REPLACE(REPLACE(CONVERT(VARCHAR(30), GETDATE(), 108), ' ', '_'),':', '')+'.bak''  WITH  DIFFERENTIAL' FROM sys.sysdatabases where name not in  (
  'master', 'tempdb','model','msdb'
 )
 
 
  SELECT   distinct  'RESTORE DATABASE ['+[database_name]+'] FROM DISK ='''+[physical_device_name]+''' WITH  REPLACE, NORECOVERY' FROM  OPENQUERY([ISWLOS-DB-2a],'SELECT TOP  12
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
   and physical_device_name  LIKE ''%diff_20180313%''
) order by b.[media_set_id] desc')

ADD TO AVAILABILITY GROUP (ON PRIMARY)
SELECT  'ALTER AVAILABILITY GROUP [DB23_DAG] ADD DATABASE ['+name+'] ;  '  FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )
 
 ADD TO AVAILABILITY GROUP (ON SECONDARY)