select * from  (
SELECT [database_name], restore_command= 'RESTORE DATABASE ['+[database_name]+'] FROM DISK ='''+[physical_device_name]+''' WITH NORECOVERY,REPLACE' FROM 
(SELECT TOP  20
 [database_name],
 physical_device_name
 ,[backup_finish_date]
     
  FROM [msdb].[dbo].[backupset]a WITH (NOLOCK)
  JOIN 
  [msdb].[dbo].[backupmediafamily] b WITH (NOLOCK)
  ON a.media_set_id = b.media_set_id
  Where database_name  IN (select   name FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )
  and physical_device_name  LIKE '%full%'
) order by b.[media_set_id] desc

)B
UNION ALL
SELECT  [database_name], restore_command='RESTORE LOG ['+[database_name]+'] FROM DISK ='''+[physical_device_name]+''' WITH NORECOVERY,REPLACE' FROM 
(SELECT TOP  20
 [database_name],
 physical_device_name
 ,[backup_finish_date]
     
  FROM [msdb].[dbo].[backupset]a WITH (NOLOCK)
  JOIN 
  [msdb].[dbo].[backupmediafamily] b WITH (NOLOCK)
  ON a.media_set_id = b.media_set_id
  Where database_name  IN (select   name FROM sys.sysdatabases where name not in  (
 'master', 'tempdb','model','msdb'
 )
  and physical_device_name  LIKE '%log%'
) order by b.[media_set_id] desc

)c ) d ORDER BY [database_name] DESC

RESTORE DATABASE [webpay] FROM DISK ='\\172.38.1.195\backup2\DB14\weekly_full\webpay_20180127000120.bak' WITH NORECOVERY,REPLACE
RESTORE LOG [webpay] FROM DISK ='\\172.38.1.195\backup2\DB14\transaction_logs\webpay_backup_2018_01_31_090014.trn' WITH NORECOVERY,REPLACE
RESTORE LOG [webpay] FROM DISK ='\\172.38.1.195\backup2\DB14\transaction_logs\webpay_backup_2018_01_31_080023.trn' WITH NORECOVERY,REPLACE