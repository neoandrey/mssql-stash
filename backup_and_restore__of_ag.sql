 SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backups\db1\daily_differential\'+name+'_full_20171129.bak''  WITH  INIT' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

 SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB3\'+name+'_diff_20170607_'+ REPLACE(REPLACE(CONVERT(VARCHAR(30), GETDATE(), 108), ' ', '_'),':', '')+'.bak''  WITH  DIFFERENTIAL' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

  SELECT 'BACKUP LOG ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB3\'+name+'_log_full_20170607.bak''  WITH FORMAT, NORECOVERY' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

 
  SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB19\'+name+'_full_20170621.bak''  WITH  INIT' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

 SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB19\'+name+'_diff_20170614_'+ REPLACE(REPLACE(CONVERT(VARCHAR(30), GETDATE(), 108), ' ', '_'),':', '')+'.bak''  WITH  DIFFERENTIAL' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

  SELECT 'BACKUP LOG ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB19\'+name+'_log_full_20170614.bak'  WITH FORMAT, NORECOVERY' FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )

 
SELECT * FROM  OPENQUERY([isw-oj-db-15c],'SELECT TOP  12
 [database_name],
 physical_device_name
 ,[backup_finish_date]
      , a.[media_set_id]
      ,[name]
      ,[description]
      ,[user_name]
      ,[database_creation_date]
      ,[backup_start_date]    
      ,[compatibility_level]
      ,[database_version]
      ,[backup_size]    
      ,[server_name]
      ,[machine_name]
      ,[is_damaged]
      ,[begins_log_chain]
      ,[has_incomplete_metadata]   
      ,[compressed_backup_size]
   
  FROM [msdb].[dbo].[backupset]a WITH (NOLOCK)
  JOIN 
  [msdb].[dbo].[backupmediafamily] b WITH (NOLOCK)
  ON a.media_set_id = b.media_set_id
  Where database_name  IN (select   name FROM sys.sysdatabases where name not in  (
 ''master'', ''tempdb'',''model'',''msdb''
 )
  and physical_device_name  LIKE ''%vtu%''
) order by [media_set_id] desc')



 SELECT 'BACKUP DATABASE ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB14\'+name+'_diff_'+CONVERT(VARCHAR(8), GETDATE(), 112)+'_'+ REPLACE(REPLACE(CONVERT(VARCHAR(30), GETDATE(), 108), ' ', '_'),':', '')+'.bak''  WITH  DIFFERENTIAL' FROM sys.sysdatabases where name  in  (
 'autopay_upgrade'
 )

 
  SELECT 'BACKUP LOG ['+name+'] TO   DISK = ''\\172.38.1.195\backup2\DB14\'+name+'_log_full_'+CONVERT(VARCHAR(8), GETDATE(), 112)+'.bak  WITH FORMAT, NORECOVERY''' FROM sys.sysdatabases where name  in  (
 'autopay_upgrade'
 )