
ALTER DATABASE postilion_office SET RECOVERY FULL
GO


BACKUP DATABASE postilion_office TO DISK ='F:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\backup\postilion_office_data.bak'   --WITH READ_WRITE_FILEGROUPS

BACKUP LOG postilion_office TO DISK ='E:\Program Files\Microsoft SQL Server\MSSQL.1\MSSQL\backup\post_office_log.trn'
ALTER DATABASE postilion_office SET RECOVERY SIMPLE
GO

