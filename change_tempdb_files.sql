ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev,FILENAME ='F:\tempdb\data\tempdb.mdf');
GO
ALTER DATABASE tempdb MODIFY FILE (NAME =templog,FILENAME ='F:\tempdb\log\templog.ldf');
GO
ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev_1,FILENAME ='F:\tempdb\data\tempdev_1_Data.NDF');
GO
ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev_2,FILENAME ='F:\tempdb\data\tempdev_2_Data.NDF');
GO
ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev_3,FILENAME ='F:\tempdb\data\tempdev_3_Data.NDF ');
GO


 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev ,FILENAME ='H:\tempdb\data\tempdb.mdf');  
 GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =templog ,FILENAME ='H:\tempdb\log\tempdb.ldf'); 
  GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdb1 ,FILENAME ='H:\tempdb\data\tempdb1_Data.NDF');
  GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdb2 ,FILENAME ='H:\tempdb\data\tempdb2_Data.NDF');
  GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdb3 ,FILENAME ='H:\tempdb\data\tempdb3_Data.NDF');
  GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdb4 ,FILENAME ='H:\tempdb\data\tempdb4_Data.NDF'); 
  GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdb5 ,FILENAME ='H:\tempdb\data\tempdb5_Data.NDF');
  GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdb6 ,FILENAME ='H:\tempdb\data\tempdb6_Data.NDF');
  GO
 ALTER DATABASE tempdb MODIFY FILE (NAME =tempdb7 ,FILENAME ='H:\tempdb\data\tempdb7_Data.NDF');
  GO
  
 
  File 'tempdev' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'templog' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'tempdb1' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'tempdb2' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'tempdb3' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'tempdb4' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'tempdb5' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'tempdb6' modified in sysaltfiles. Delete old file after restarting SQL Server.
  File 'tempdb7' modified in sysaltfiles. Delete old file after restarting SQL Server.
  
  
  
   ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev ,FILENAME ='J:\Program Files\MSSQL\tempdb.mdf');  
   GO
   ALTER DATABASE tempdb MODIFY FILE (NAME =templog ,FILENAME ='J:\Program Files\MSSQL\templog.ldf'); 
  GO
  
  
  ALTER DATABASE tempdb MODIFY FILE (NAME = tempdev,FILENAME ='H:\Program Files\Microsoft SQL Server\MSSQL\data\tempdb\tempdb.mdf');
  GO
  ALTER DATABASE tempdb MODIFY FILE (NAME =templog,FILENAME ='H:\Program Files\Microsoft SQL Server\MSSQL\data\tempdb\templog.ldf');
  GO
  ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev_1,FILENAME ='H:\Program Files\Microsoft SQL Server\MSSQL\data\tempdb\tempdev_1_Data.NDF');
  GO
  ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev_2,FILENAME ='H:\Program Files\Microsoft SQL Server\MSSQL\data\tempdb\tempdev_2_Data.NDF');
  GO
  ALTER DATABASE tempdb MODIFY FILE (NAME =tempdev_3,FILENAME ='H:\Program Files\Microsoft SQL Server\MSSQL\data\tempdb\tempdev_3_Data.NDF ');
  GO
