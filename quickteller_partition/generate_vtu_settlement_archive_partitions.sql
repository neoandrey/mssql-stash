SELECT TOP 10 * FROM tbl_settlement_archive(nolock)order by settlement_date

 DECLARE @startDate DATETIME ='2016-09-01'
 DECLARE @endDate DATETIME ='2025-12-31'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILEGROUP [transactions_partition_'+  CONVERT(VARCHAR(6), @startDate,112)+']' ) ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 select * from @dateTable
 

  DECLARE @startDate DATETIME ='2016-09-01'
 DECLARE @endDate DATETIME ='2025-12-31'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N''tbl_transactions_file_'+  CONVERT(VARCHAR(6), @startDate,112)+''', FILENAME = N''J:\SQLSERVER\DATA\Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [settlement_archive_'+  CONVERT(VARCHAR(6), @startDate,112)+']') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 select * from @dateTable




 
  DECLARE @startDate DATETIME ='2016-09-01'
 DECLARE @endDate DATETIME ='20251231 23:59:59.999'
 
 DECLARE @dateTable TABLE (DATESTR varchar(500))
 INSERT INTO @dateTable SELECT ' CREATE PARTITION FUNCTION partition_vtuvcare_transactions_db_by_month (DATETIME)  AS  RANGE LEFT FOR VALUES 
  (  '
 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values( ''''+replace(CONVERT(VARCHAR(10),@startDate,111),'/','-')+' 23:59:59.999'',') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 insert into @dateTable values(')');
 --select * from @dateTable

 
   DECLARE @startDate DATETIME ='2016-09-01'
  DECLARE @endDate DATETIME ='20251231 23:59:59.999'

 
 -- DECLARE @startDate DATETIME ='20150101'
 --DECLARE @endDate DATETIME ='20170306 23:59:59.999'
 
 --DECLARE @dateTable TABLE (DATESTR varchar(500))
 INSERT INTO @dateTable SELECT 'CREATE PARTITION SCHEME partition_vtucare_transactions_by_month_partition_scheme AS PARTITION partition_quickteller_db_by_month TO ('
 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values(  '[settlement_archive_'+  CONVERT(VARCHAR(6), @startDate,112)+'],') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 insert into @dateTable values(')');
 select * from @dateTable





 DECLARE @startDate DATETIME ='2016-09-01'
 DECLARE @endDate DATETIME ='2025-12-31'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILEGROUP [tbl_transactions_partition_'+  CONVERT(VARCHAR(6), @startDate,112)+']' ) ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 select * from @dateTable



 DECLARE @startDate DATETIME ='2016-09-01'
 DECLARE @endDate DATETIME ='2025-12-31'
 DECLARE @dateTable TABLE (DATESTR varchar(500))

 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values('ALTER DATABASE [VTUCARE] ADD FILE ( NAME = N''tbl_transactions_file_'+  CONVERT(VARCHAR(6), @startDate,112)+''', FILENAME = N''J:\SQLSERVER\DATA\Transaction_File_'+  CONVERT(VARCHAR(6), @startDate,112)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [settlement_archive_'+  CONVERT(VARCHAR(6), @startDate,112)+']') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 select * from @dateTable



   DECLARE @startDate DATETIME ='2016-09-01'
 DECLARE @endDate DATETIME ='20251231 23:59:59.999'
 
 DECLARE @dateTable TABLE (DATESTR varchar(500))
 INSERT INTO @dateTable SELECT ' CREATE PARTITION FUNCTION partition_vtuvcare_transactions_db_by_month (DATETIME)  AS  RANGE LEFT FOR VALUES 
  (  '
 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values( ''''+replace(CONVERT(VARCHAR(10),@startDate,111),'/','-')+' 23:59:59.999'',') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 insert into @dateTable values(')');
 select * from @dateTable


 
   DECLARE @startDate DATETIME ='2016-09-01'
  DECLARE @endDate DATETIME ='20251231 23:59:59.999'
  DECLARE @dateTable TABLE (DATESTR varchar(500))
 INSERT INTO @dateTable SELECT 'CREATE PARTITION SCHEME partition_vtucare_transactions_by_month_partition_scheme AS PARTITION partition_quickteller_db_by_month TO ('
 WHILE (datediff(d,@startDate,@endDate) >0 )BEGIN
  set @startDate = Dateadd(d, -1, dateadd(month,1,@startDate));
 INSERT INTO @dateTable values(  '[tbl_transactions_'+  CONVERT(VARCHAR(6), @startDate,112)+'],') ;
   set @startDate = Dateadd(d, 1,@startDate);
 end
 insert into @dateTable values(',[tbl_transactions_default])');
 select * from @dateTable
