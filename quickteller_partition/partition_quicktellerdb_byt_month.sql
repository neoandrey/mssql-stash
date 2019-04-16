
 DECLARE @startDate DATETIME ='20080101'
 DECLARE @endDate DATETIME ='20251231'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [quickteller] ADD FILEGROUP [TRANSACTIONS_'+  CONVERT(VARCHAR(6), @startDate,112)+']' ) ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 select * from @dateTable



 DECLARE @startDate DATETIME ='20180401'
 DECLARE @endDate DATETIME ='20251231'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [quickteller] ADD FILE ( NAME = N''Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+''', FILENAME = N''H:\SQLSERVER\DATA\MONTHLY\Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP  [TRANSACTIONS_'+  CONVERT(VARCHAR(6), @startDate,112)+']' ) ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 select * from @dateTable


 DECLARE @startDate DATETIME ='20080101'
 DECLARE @endDate DATETIME ='20251231'
 DECLARE @dateTable TABLE (DATESTR varchar(500))
 DECLARE @dateTable TABLE (DATESTR varchar(500))
 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [quickteller] ADD FILE ( NAME = N''Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+'a'', FILENAME = N''D:\SQLSERVER\DATA\MONTHLY\Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+'a.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP  [TRANSACTIONS_'+  CONVERT(VARCHAR(6), @startDate,112)+']' ) ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 select * from @dateTable

 
 DECLARE @startDate DATETIME ='20080101'
 DECLARE @endDate DATETIME ='20251231 23:59:59.999'
 
 DECLARE @dateTable TABLE (DATESTR varchar(500))
 INSERT INTO @dateTable SELECT ' CREATE PARTITION FUNCTION partition_quickteller_db_by_month (DATETIME)  AS  RANGE LEFT FOR VALUES 
  (  '
 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values( ''''+replace(CONVERT(VARCHAR(10),@startDate,111),'/','-')+' 23:59:59.999'',') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 insert into @dateTable values(')');
 select * from @dateTable

 

   DECLARE @startDate DATETIME ='20080101'
 DECLARE @endDate DATETIME ='20251231 23:59:59.999'
 
 DECLARE @dateTable TABLE (DATESTR varchar(500))
 INSERT INTO @dateTable SELECT 'CREATE PARTITION SCHEME monthly_quickteller_db_partition_scheme AS PARTITION monthly_quickteller_db_partition TO ('
 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values( '[TRANSACTIONS_'+  CONVERT(VARCHAR(6), @startDate,112)+'],') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 insert into @dateTable values(', transactions_default_partition)');
 select * from @dateTable

BEG


 END