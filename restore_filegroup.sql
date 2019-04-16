USE master;
GO

RESTORE DATABASE postilion_office FILEGROUP='PRIMARY' FROM disk = 'N:\postilion_office_primary.bak'
   WITH  PARTIAL,NORECOVERY,
   MOVE 'post_office_db_jan_c' TO 'N:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLSERVER\MSSQL\DATA\postilion_office.mdf'
GO
RESTORE DATABASE postilion_office FILEGROUP='JAN_2015C' FROM disk = 'N:\postilion_office_jan_c_backup.bak'
   WITH  NORECOVERY,
   MOVE 'post_office_db_jan_c' TO 'N:\Program Files\Microsoft SQL Server\MSSQL10_50.SQLSERVER\MSSQL\DATA\postilion_office_3.ndf'
GO
