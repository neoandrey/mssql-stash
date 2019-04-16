DECLARE  @start_id BIGINT =0
DECLARE @number_of_files INT  = 20
DECLARE @current_end_id BIGINT;
DECLARE @span   BIGINT  = 5000000
DECLARE  @end_id  BIGINT = @span* @number_of_files
DECLARE @dateTable TABLE (DATESTR varchar(750))

SET @current_end_id = 0;

 WHILE (@current_end_id<= @end_id)BEGIN
  set @current_end_id = @current_end_id + @span ;
 INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILEGROUP [dms_partition_'+ CONVERT(VARCHAR(100),@current_end_id)+']' ) ;
 
 end
 INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILEGROUP [dms_partition_default]' ) ;
 select * from @dateTable
 
 SET @current_end_id=0;
 
 DELETE FROM @dateTable 
 
 INSERT INTO @dateTable SELECT ' CREATE PARTITION FUNCTION retailpay_partition_transactions_by_id (BIGINT)  AS  RANGE LEFT FOR VALUES 
  (  '
 WHILE (@current_end_id<=@end_id)BEGIN
  set @current_end_id = @current_end_id + @span ;
 IF((@current_end_id) < (@end_id+ @span) ) BEGIN
      INSERT INTO @dateTable values(  CONVERT(VARCHAR(100), @current_end_id)+',') ;
 END
 ELSE BEGIN
  INSERT INTO @dateTable values(  @current_end_id) ;
 END
 END
 insert into @dateTable values(')');
 select * from @dateTable
 
  
 SET @current_end_id=0;
 
 DELETE FROM @dateTable
 
 DECLARE @dateTable2 TABLE (DATESTR varchar(750))
 
 DECLARE @drive_1 VARCHAR(5) = 'F:'
 DECLARE @drive_2 VARCHAR(5) = 'G:'
 DECLARE @counter  INT   =1
 WHILE (@current_end_id<= @end_id)BEGIN 
 set @current_end_id = @current_end_id + @span ;
  IF ( @counter %2 =0) BEGIN
     INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILE ( NAME = N''dms_partition_'+  CONVERT(VARCHAR(100), @current_end_id)+''', FILENAME = N'''+@drive_1+'\SQLSERVER\DATA\dms_partition_file_'+  CONVERT(VARCHAR(20),@current_end_id)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [dms_partition_'+ CONVERT(VARCHAR(20),@current_end_id)+']') ;
	insert into  @dateTable2 values('MKDIR "'+@drive_1+'\SQLSERVER\DATA\"')
  END
  ELSE BEGIN
  INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILE ( NAME = N''dms_partition_'+  CONVERT(VARCHAR(100), @current_end_id)+''', FILENAME = N'''+@drive_2+'\SQLSERVER\DATA\dms_partition_file_'+ CONVERT(VARCHAR(20),@current_end_id)+'.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [dms_partition_'+ CONVERT(VARCHAR(20),@current_end_id)+']') ;
  insert into  @dateTable2 values('MKDIR "'+@drive_2+'\SQLSERVER\DATA\"')
  END
  
   set @counter =@counter+1
 end
   INSERT INTO @dateTable values('ALTER DATABASE [dms] ADD FILE ( NAME = N''dms_partition_default'', FILENAME = N'''+@drive_2+'\SQLSERVER\DATA\dms_partition_file_default.ndf'', SIZE = 3072KB , FILEGROWTH = 262144KB ) TO FILEGROUP [dms_partition_default]') ;

 select * from @dateTable
 SELECT * FROM @dateTable2
 
 
 DELETE FROM @dateTable
  SET @current_end_id=0;
 
 INSERT INTO @dateTable SELECT 'CREATE PARTITION SCHEME retailpay_partition_transactions_by_id_scheme AS PARTITION retailpay_partition_transactions_by_id TO ('
 WHILE (@current_end_id<= @end_id)BEGIN 
   SET @current_end_id = @current_end_id + @span ;
		INSERT INTO @dateTable values('[dms_partition_'+ CONVERT(VARCHAR(100),@current_end_id)+'],') ;
				
 END
 insert into @dateTable values('[dms_partition_default])');
 select * from @dateTable



 
 
 
