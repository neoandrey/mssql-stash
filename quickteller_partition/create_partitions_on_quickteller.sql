USE [master]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2008]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2009]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2010]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2011]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2012]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2013]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2014]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2015]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2016]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2017]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2018]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2019]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2020]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2021]
GO
ALTER DATABASE [quickteller] ADD FILEGROUP [Transaction_2022]
GO
USE [master]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2008', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2008.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2008]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2009', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2009.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2009]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2010', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2010.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2010]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2011', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2011.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2011]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2012', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2012.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2012]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2013', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2013.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2013]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2014', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2014.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2014]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2015', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2015.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2015]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2016', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2016.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2016]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2017', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2017.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2017]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2018', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2018.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2018]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2019', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2019.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2019]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2020', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2020.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2020]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2021', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2021.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2021]
GO
ALTER DATABASE [quickteller] ADD FILE ( NAME = N'Transaction_File_2022', FILENAME = N'F:\SQLSERVER\DATA\Transaction_File_2022.ndf' , SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [Transaction_2022]
GO

use quickteller;
go

CREATE PARTITION FUNCTION partition_quickteller_db_by_year (DATETIME)  AS  RANGE LEFT FOR VALUES 
  (  
  '20081231 23:59:59.999',
  '20091231 23:59:59.999',
  '20101231 23:59:59.999',
  '20111231 23:59:59.999',
  '20121231 23:59:59.999',
  '20131231 23:59:59.999',
  '20141231 23:59:59.999',
  '20151231 23:59:59.999',
  '20161231 23:59:59.999',
  '20171231 23:59:59.999',
  '20181231 23:59:59.999',
  '20191231 23:59:59.999',
  '20201231 23:59:59.999',
  '20211231 23:59:59.999',
  '20221231 23:59:59.999'
  )

  
CREATE PARTITION SCHEME yearly_quickteller_db_partition_scheme AS PARTITION
	partition_quickteller_db_by_year TO
	(
[Transaction_2008]
,[Transaction_2009]
, [Transaction_2010]
,[Transaction_2011]
,[Transaction_2012]
,[Transaction_2013]
,[Transaction_2014]
,[Transaction_2015]
,[Transaction_2016]
,[Transaction_2017]
,[Transaction_2018]
,[Transaction_2019]
,[Transaction_2020]
,[Transaction_2021]
,[Transaction_2022]
,[Transaction]
	)
	
	











