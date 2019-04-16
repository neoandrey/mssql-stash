DECLARE @path VARCHAR(255) ='F:\BACKUPS\Transaction_logs\surcharge_db_logs_'+CONVERT(VARCHAR(8), getdate(),112)+'_'+REPLACE(CONVERT(VARCHAR(20), getdate(),108),':','')+'.trn';

BACKUP LOG  surcharge_db TO DISK =@path

