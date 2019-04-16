USE [master]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db7', FILENAME = N'K:\Program Files\Microsoft SQL Server\postilion_office\post_office_db7.ndf' , SIZE = 2009216KB , FILEGROWTH = 0) TO FILEGROUP [PRIMARY]
GO
