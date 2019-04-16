SELECT TOP 10 * FROM tbl_settlement_archive(nolock)order by settlement_date

 DECLARE @startDate DATETIME ='2014-08-01 00:00.000'
 DECLARE @endDate DATETIME ='2019-12-31'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_'+  CONVERT(VARCHAR(6), @startDate,112)+']' ) ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_default]' ) ;
 select * from @dateTable
 


 

 DECLARE @startDate DATETIME ='2014-08-01 00:00.000'
 DECLARE @endDate DATETIME ='2019-12-31'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N''tbl_transactions_file_'+  CONVERT(VARCHAR(6), @startDate,112)+''', FILENAME = N''F:\SQLSERVER\DATA\Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_'+  CONVERT(VARCHAR(6), @startDate,112)+']') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
  INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N''tbl_transactions_default_file'', FILENAME = N''F:\SQLSERVER\DATA\Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [tbl_transactions_partition_'+  CONVERT(VARCHAR(6), @startDate,112)+']') ;

 select * from @dateTable
