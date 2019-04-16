RESTORE DATABASE [kimono] FROM DISK ='\\172.38.1.195\backup2\DB19\kimono_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [lending-service] FROM DISK ='\\172.38.1.195\backup2\DB19\lending-service_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [kimonodb] FROM DISK ='\\172.38.1.195\backup2\DB19\kimonodb_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [verveaccess_jackrabbit_prod] FROM DISK ='\\172.38.1.195\backup2\DB19\verveaccess_jackrabbit_prod_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [paydirect_ncs] FROM DISK ='\\172.38.1.195\backup2\DB19\paydirect_ncs_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [nts] FROM DISK ='\\172.38.1.195\backup2\DB19\nts_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [kimono_csp] FROM DISK ='\\172.38.1.195\backup2\DB19\kimono_csp_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [verveaccess_prod] FROM DISK ='\\172.38.1.195\backup2\DB19\verveaccess_prod_full_20170614.bak' WITH  REPLACE, NORECOVERY
RESTORE DATABASE [smartmove] FROM DISK ='\\172.38.1.195\backup2\DB19\smartmove_full_20170614.bak' WITH  REPLACE, NORECOVERY

--drop table  transactions_logs
--create table transactions_logs ( id int identity(1,1),[backup_finish_date] datetime, sqlcommand VARCHAR(MAX) );
--ALTER TABLE transactions_logs ADD  CONSTRAINT   IX_SQL_COMMAND UNIQUE   (sqlcommand)
DECLARE @max_backup_date DATETIME 
DECLARE @sql_query  varchar(max)
 select @max_backup_date =  max([backup_finish_date]) FROM transactions_logs
 --SET @max_backup_date = '2017-06-14 12:31:29.000'; -- 
DECLARE @transaction_log_table TABLE ( [backup_finish_date] DATETIME, sqlcommand VARCHAR(MAX) )

INSERT INTO @transaction_log_table 
 
SELECT distinct [backup_finish_date], 'RESTORE log ['+[database_name]+'] FROM DISK ='''+[physical_device_name]+''' WITH  NORECOVERY' FROM  OPENQUERY([ISWLOS-DB6-DAG1],'SELECT 
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
  and  physical_device_name  LIKE ''%log%''
) order by [media_set_id] desc')
WHERE backup_finish_date >=@max_backup_date

INSERT INTO transactions_logs   
select * from @transaction_log_table  WHERE sqlcommand not  IN (select sqlcommand from  transactions_logs)

--DECLARE @max_backup_date DATETIME 
--DECLARE @sql_query  varchar(max)
--SET @max_backup_date = '2017-06-14 12:31:29.000';
declare tran_restore_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR select sqlcommand from  transactions_logs where backup_finish_date>=@max_backup_date
open tran_restore_cursor
fetch next from  tran_restore_cursor into @sql_query
WHILE (@@FETCH_STATUS=0)BEGIN

EXEC(@sql_query)
fetch next from  tran_restore_cursor into @sql_query
END
CLOSE tran_restore_cursor
DEALLOCATE tran_restore_cursor

--SELECT * FROM transactions_logs

RESTORE DATABASE verveaccess_jackrabbit_prod WITH  RECOVERY
RESTORE DATABASE verveaccess_prod WITH  RECOVERY
RESTORE DATABASE paydirect_ncs WITH  RECOVERY
RESTORE DATABASE smartmove WITH  RECOVERY
RESTORE DATABASE kimono WITH  RECOVERY
RESTORE DATABASE nts WITH  RECOVERY
RESTORE DATABASE kimono_csp WITH  RECOVERY
RESTORE DATABASE kimono_fuse_csp WITH  RECOVERY
RESTORE DATABASE kimonodb WITH  RECOVERY
RESTORE DATABASE lending-service WITH  RECOVERY