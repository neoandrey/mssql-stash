


USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[custom_transaction_cleaner]    Script Date: 11/17/2015 15:07:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

  
  
  
  
create PROCEDURE [dbo].[custom_transaction_cleaner] @retention_period INT, @period_interval int , @batch_size int AS  
BEGIN   
  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
  
	DECLARE @startDate DATETIME;  
	DECLARE @endDate DATETIME;  
	DECLARE @retention_period_reduction  INT;   
	DECLARE @retention_period_minutes BIGINT;   
	DECLARE @min_date_time DATETIME,@max_date_time  DATETIME;  
	DECLARE @first_post_tran_id  BIGINT;  
	DECLARE @last_post_tran_id  BIGINT;  
	DECLARE @first_post_tran_cust_id  BIGINT;  
	DECLARE @last_post_tran_cust_id  BIGINT; 
	SET @batch_size = ISNULL(@batch_size,2500);
	SELECT @min_date_time =  MIN(datetime_req), @max_date_time  =  MAX(datetime_req)  FROM post_tran WITH(NOLOCK,INDEX(ix_post_tran_7));  	
	
	IF (DATEDIFF(D,@min_date_time,@max_date_time )> @retention_period)
	BEGIN 

			  IF(@retention_period IS NOT NULL)  
			  BEGIN  
			  SET @retention_period_minutes = @retention_period * 24*60;  

			SELECT @min_date_time =  MIN(datetime_req) FROM post_tran WITH(NOLOCK,INDEX(ix_post_tran_7));  
			SET @startDate = @min_date_time;  
			IF(DATEDIFF(MINUTE, @min_date_time, GETDATE()) >@retention_period_minutes)BEGIN  


			   DECLARE @datetime_start VARCHAR(30);  
			   DECLARE @datetime_stop VARCHAR(30);  
			   DECLARE @datetime_temp VARCHAR(30);  
			   DECLARE @num_of_runs INT;  
			   DECLARE @counter INT;  

				    SET @retention_period_reduction= DATEDIFF(MINUTE, @min_date_time, GETDATE())  
			   SET @endDate   =  DATEADD (DAY, 1, DATEDIFF(DAY, 0, @startDate));  
			   SET @datetime_start = @startDate;  
			   SET @datetime_stop  = @endDate;  
			   --SET @datetime_start=DATEADD(MINUTE, @period_interval, @datetime_temp);  
				    --SET @datetime_start = @startDate+' '+CONVERT(VARCHAR(10), DATEADD(minute, @period_interval, @datetime_temp),108);  

				    IF(DATEDIFF(MINUTE,@datetime_start, @datetime_stop)<=0) BEGIN  
			    SET @datetime_temp=@datetime_stop;  
			   END  

			    PRINT  'Start Date: '+@datetime_start+CHAR(10)  
			    PRINT  'End Date:   '+ @datetime_stop+CHAR(10)  

			    WHILE (DATEDIFF(MINUTE,@datetime_start, @datetime_stop)>0)   
			     BEGIN  

			      SELECT @datetime_start = MIN(datetime_req) FROM post_tran WITH(NOLOCK,INDEX(ix_post_tran_7));  
			      SET @datetime_start= DATEADD(MINUTE,@period_interval,@datetime_start);  

			      SET   @last_post_tran_id =  (select top 1 post_tran_id FROM  post_tran trans WITH(NOLOCK, INDEX(ix_post_tran_7))  WHERE  datetime_req <=@datetime_stop ORDER BY datetime_req desc)    
			      --SET @last_post_tran_cust_id  =  (SELECT TOP 1 post_tran_cust_id FROM post_tran(NOLOCK, INDEX(ix_post_tran_2)) WHERE  post_tran_cust_id <= (SELECT post_tran_cust_id  FROM  post_tran (NOLOCK) WHERE post_tran_id = 88706554) ORDER BY post_tran_cust_id DESC )  
			      PRINT 'Cleaning post_tran records older than: '+@datetime_stop  


			      DELETE FROM extract_tran WHERE post_tran_id <=  @last_post_tran_id OPTION(MAXDOP 12);  

			      SET ROWCOUNT @batch_size  
			      DELETE_POST_TRAN:  
			      DELETE FROM post_tran  WHERE  datetime_req  <= @datetime_start OPTION(MAXDOP 12);  
			      IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN  
			      SET ROWCOUNT 0  

			      SET ROWCOUNT @batch_size  
			      DELETE_POST_TRAN_CUST:  
			      DELETE post_tran_cust FROM post_tran WITH(NOLOCK, INDEX(ix_post_tran_7)) INNER JOIN post_tran_cust ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id WHERE datetime_req < CONVERT(DATETIME, @datetime_start);  
			      --DELETE FROM post_tran_cust  WHERE  post_tran_cust_id <= @last_post_tran_cust_id OPTION(MAXDOP 12);  
			      IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST  
			      SET ROWCOUNT 0  


			      --SET @datetime_temp=CONVERT(VARCHAR(10), DATEADD(minute, @period_interval, @datetime_temp),108)  

			      IF(DATEDIFF(D,@datetime_start,@datetime_stop)=0)  
			      BEGIN  
				SET @datetime_start=DATEADD(D, 1, DATEDIFF(D,0, @datetime_start));  
			      END  

			      DBCC SHRINKFILE (post_office_log,0);
DBCC SHRINKFILE (post_office_log_2,0);
DBCC SHRINKFILE (post_office_log_3,0);

			      --PRINT  CONVERT(VARCHAR(20),CONVERT(FLOAT,@post_tran_cust_id_temp)/CONVERT(FLOAT,@post_tran_cust_id_stop)*100.0)+'% done...'  
			     --COMMIT TRANSACTION  
			     END  
				 PRINT 'Running final clean up for transactions older than: '+CHAR(10)  
			      PRINT 'Cleaning post_tran records older than: '+@datetime_stop   
			      SET @datetime_stop = DATEADD(D,0, DATEDIFF(D,0,@datetime_stop))  
			      SET @last_post_tran_id  = (SELECT TOP 1 trans.post_tran_id FROM post_tran trans WITH(NOLOCK, INDEX(ix_post_tran_7)) INNER JOIN post_tran_cust cust ON trans.post_tran_cust_id = cust.post_tran_cust_id WHERE datetime_req < CONVERT(DATETIME, @datetime_stop) ORDER BY datetime_req DESC)  
				 DELETE FROM extract_tran WHERE post_tran_id <=  @last_post_tran_id OPTION(MAXDOP 12);  


			      SET ROWCOUNT @batch_size  
			      DELETE_POST_TRAN_ALL:  
			      DELETE FROM post_tran   WHERE datetime_req < CONVERT(DATETIME, @datetime_stop)option(MAXDOP 12);  
			      IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_ALL  
			      SET ROWCOUNT 0  

			      SET ROWCOUNT @batch_size  
			      DELETE_POST_TRAN_CUST_ALL:  
			      DELETE post_tran_cust FROM post_tran WITH(NOLOCK) INNER JOIN post_tran_cust ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id WHERE datetime_req < CONVERT(DATETIME, @datetime_stop) OPTION(MAXDOP 12);  
			      IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST_ALL  
			      SET ROWCOUNT 0  

				DBCC SHRINKFILE (post_office_log,0);
				DBCC SHRINKFILE (post_office_log_2,0);
				DBCC SHRINKFILE (post_office_log_3,0);

				      END   
			     ELSE BEGIN  
					 PRINT CHAR(10)+'Transactions have not exceeded the specified retention period.';  

			     END  

			   END  
			   ELSE   
			   BEGIN  
			     RAISERROR ('No retention period specified. Cannot clean transactions without a retention period', 16,  1 );  
			   END  
	END
END

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
