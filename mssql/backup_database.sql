USE [master];
GO

DECLARE @databaseName VARCHAR(255);
DECLARE @backupLocation VARCHAR(255);
DECLARE @dbBackupParams VARCHAR(255);
DECLARE @dbLogBackupParams VARCHAR(255);
DECLARE @dateSuffix VARCHAR(255);


SELECT @databaseName = 'AdventureWorksDW2008R2';
SELECT @backupLocation = 'F:\database_backup\mssql';
SELECT @dateSuffix = REPLACE(SYSUTCDATETIME(), ':', '_');
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name =N''+@databaseName+'')
 BEGIN
   PRINT CHAR(13);
   PRINT 'The database you selected does not exist. Please check the database name and try again'
   PRINT CHAR(13);
 END
ELSE 
	BEGIN
		PRINT CHAR(13);
		PRINT 'Backing up database: '+@databaseName+' to: '+ @backupLocation;	
		BACKUP DATABASE @databaseName  TO DISK= @backupLocation WITH INIT;
		
		BACKUP LOG @databaseName  TO DISK= @backupLocation WITH INIT;
	
	END