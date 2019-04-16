exec sp_helpfile 
--note all  file names and locations


--2008

USE master 
SELECT name, physical_name  FROM sys.master_files  WHERE database_id = DB_ID("postilion_office"); 

 ALTER DATABASE postilion_office  SET offline  GO
 
--Move one file at a time to the new location by typing the following:
 
 
 ALTER DATABASE postilion_office  MODIFY FILE ( NAME = USER_DATA1, FILENAME = "J:\postilion_office\post_office9_db.ndf") 
 ALTER DATABASE postilion_office  MODIFY FILE ( NAME = USER_DATA2, FILENAME = "J:\postilion_office\post_office10_db.ndf") 
 ALTER DATABASE postilion_office  MODIFY FILE ( NAME = post_office_ext, FILENAME = "J:\postilion_office\post_office_ext_Data.NDF") 

 ALTER DATABASE postilion_office SET online GO 
 
 
 
 --2000
 
 EXEC sp_attach_db @dbname = N'postilion_office', 
	@filename1 = N'F:\sqldata\MSSQL\data\post_office_db.mdf', 
	@filename2 = N'E:\sql_data\post_office_log_.ldf',
	@filename3 = N'J:\postilion_office\post_office9_db.ndf',
	@filename4 = N'J:\postilion_office\post_office10_db.ndf',
	@filename5 = N'H:\post_office11_db.ndf',
	@filename6 = N'D:\sqldata\MSSQL\data\USER_DATA4_Data.NDF',
	@filename7 = N'J:\postilion_office\post_office_ext_Data.NDF',
	@filename8 = N'F:\sqldata\MSSQL\log\postilion_office_log_2.ldf',
	@filename9 = N'I:\postilion_log_file\postilion_office_2_log.ldf'
	
	
	10.60
	
	
 EXEC sp_attach_db @dbname = N'postilion_office'
,@filename1  =N'E:\Program Files\Microsoft SQL Server\MSSQL\data\post_office_db.mdf'
,@filename2  =N'F:\Program Files\Microsoft SQL Server\MSSQL\data\post_office_log.ldf'
,@filename3  =N'f:\post_office_db1.ndf'
,@filename4  =N'g:\post_office_db2.ndf'
,@filename5  =N'H:\Office Data File\postilion_office_5_Data.ndf'
,@filename6  =N'g:\post_office_db3.ndf'
,@filename7  =N'J:\user_data5_Data.NDF'
,@filename8  =N'H:\Office Data File\postilion_office_6_Data.ndf'
,@filename9  =N'I:\Program Files\Microsoft SQL Server\MSSQL\data\user_data_7_Data.NDF'
,@filename10 =N'J:\Program Files\MSSQL\postilion_office\post_office_log_2_Log.LDF' 