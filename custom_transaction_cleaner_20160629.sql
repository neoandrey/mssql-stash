USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[custom_transaction_cleaner]    Script Date: 06/29/2016 15:31:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  
  
  
  
  
ALTER     PROCEDURE [dbo].[custom_transaction_cleaner] @retention_period INT, @period_interval int , @batch_size int AS  
  
BEGIN   
  
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
--SET NOCOUNT ON;  
  
   DECLARE @startDate DATETIME;  
    DECLARE @endDate DATETIME;  
    DECLARE @retention_period_reduction  INT;   
    DECLARE @retention_period_minutes BIGINT;   
	DECLARE @min_date_time  DATETIME;  
	DECLARE @first_post_tran_cust_id  BIGINT;  
	DECLARE @last_post_tran_cust_id  BIGINT;  
	DECLARE @min_post_tran_cust_id BIGINT  
  set @batch_size  = isnull(@batch_size, 2500)  
  IF(@retention_period IS NOT NULL)  
  BEGIN  
  SET @retention_period_minutes = @retention_period * 24*60;  
  
    
    
            SELECT @min_date_time =  REPLACE(CONVERT(VARCHAR(10), MIN(datetime_req),111),'/', '') FROM dbo.post_tran WITH(NOLOCK,INDEX(ix_post_tran_7));  
       SET @startDate = @min_date_time;  
    IF(DATEDIFF(MINUTE, @min_date_time, GETDATE()) >@retention_period_minutes)BEGIN  
   CREATE TABLE #temp_post_tran(post_tran_id BIGINT)  
   CREATE TABLE #temp_post_tran_cust (post_tran_cust_id BIGINT)  
CREATE CLUSTERED INDEX ix_post_tran_id ON #temp_post_tran(  
post_tran_id  
)  
CREATE NONCLUSTERED INDEX ix_post_tran_cust_id ON #temp_post_tran_cust(  
post_tran_cust_id  
)  
   DECLARE @datetime_start VARCHAR(30);  
   DECLARE @datetime_stop VARCHAR(30);  
   DECLARE @datetime_temp VARCHAR(30);  
   DECLARE @num_of_runs INT;  
   DECLARE @counter INT;  
            DECLARE @last_day_to_clean DATETIME;  
   DECLARE @current_clean_date DATETIME;  
     
      SET @last_day_to_clean = DATEDIFF(DAY, (-1*@retention_period ), GETDATE())  
   SET @last_day_to_clean =DATEADD(D,1, @last_day_to_clean)  
         SET @retention_period_reduction= DATEDIFF(MINUTE, @min_date_time, GETDATE())  
   SET @endDate   =  DATEADD (DAY, 1, DATEDIFF(DAY, 0, @startDate));  
   SET @datetime_start = @startDate;  
   SET @datetime_stop  = @endDate;  

   DECLARE @recon_business_date_table TABLE( recon_business_date datetime);  
   INSERT INTO @recon_business_date_table  SELECT [DATE] FROM dbo.get_dates_in_range(@datetime_start, @last_day_to_clean);  
     
	IF(DATEDIFF(MINUTE,@datetime_start, @datetime_stop)<=0) BEGIN  
		SET @datetime_temp=@datetime_stop;  
	END     
	PRINT  'Start Date: '+@datetime_start+CHAR(10)  
	PRINT  'End Date:   '+ @datetime_stop+CHAR(10)  

    SELECT @current_clean_date =@datetime_start  --- MIN(recon_business_date) FROM dbo.post_tran WITH(NOLOCK,INDEX(ix_post_tran_9));  
    IF (DATEDIFF(MINUTE,@datetime_start, @endDate)>0)   
     BEGIN  
          
    WHILE (DATEDIFF(day,@current_clean_date, @last_day_to_clean)>=0) BEGIN  
        
          IF(DATEDIFF(MINUTE, @current_clean_date, GETDATE()) < @retention_period_minutes)BEGIN  
            return  
          end  
  
     
      PRINT 'Cleaning extract_tran records older than: '+CONVERT(VARCHAR(30),@datetime_stop)  
      BEGIN TRY  
        
        --SELECT @first_post_tran_cust_id = MIN(post_tran_cust_id), @last_post_tran_cust_id = MAX(post_tran_cust_id) FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE recon_business_date =@current_clean_date ;  
        
        DELETE FROM extract_tran WHERE post_tran_id  IN (SELECT post_tran_id  FROM post_tran with (NOLOCK, INDEX(ix_post_tran_9)) WHERE recon_business_date =@current_clean_date) ;  
         
        PRINT 'Cleaning dbo.post_tran records older than: '+CONVERT(VARCHAR(30),@datetime_stop)  
        SET ROWCOUNT @batch_size  
        DELETE_POST_TRAN:  
        DELETE FROM dbo.post_tran   WHERE   post_tran_id in (SELECT  TOP (@batch_size)  post_tran_id FROM post_tran (NOLOCK, index(ix_post_tran_9)) WHERE datetime_req >= (SELECT MIN(datetime_req)  FROM post_tran ( NOLOCK, INDEX(ix_post_tran_7))) AND  recon_business_date<=@current_clean_date)  ;  
        IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN  
        SET ROWCOUNT 0  
          
        PRINT 'Cleaning post_tran_cust records older than: '+CONVERT(VARCHAR(30),@current_clean_date)  
          
        SET ROWCOUNT @batch_size  
        DELETE_POST_TRAN_CUST:  
        DELETE FROM dbo.post_tran_cust   WHERE   post_tran_cust_id IN (SELECT TOP (@batch_size) post_tran_cust_id FROM post_tran_cust (NOLOCK, INDEX(pk_post_tran_cust)) WHERE post_tran_cust_id NOT IN (select post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_2)) where  RECON_BUSINESS_DATE =@current_clean_date  ))   ;  
        IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST  
        SET ROWCOUNT 0  
		 DBCC SHRINKFILE(post_office_log, 0)  
      END TRY   
      BEGIN CATCH  
      PRINT 'Cleaning post_tran_cust records older than: '+CONVERT(VARCHAR(30),@current_clean_date)  
        
       -- select @first_post_tran_cust_id = MIN(post_tran_cust_id), @last_post_tran_cust_id = MAX(post_tran_cust_id) FROM post_tran (NOLOCK, INDEX(ix_post_tran_9)) WHERE recon_business_date =@current_clean_date ;  
        
        SET ROWCOUNT @batch_size  
        DELETE_POST_TRAN_CUST_2:  
        DELETE FROM dbo.post_tran_cust   WHERE   post_tran_cust_id IN (SELECT TOP (@batch_size) post_tran_cust_id FROM post_tran_cust (NOLOCK, INDEX(pk_post_tran_cust)) WHERE post_tran_cust_id NOT IN (select post_tran_cust_id FROM post_tran (NOLOCK, INDEX(ix_post_tran_2))))   ;  
        IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST_2  
        SET ROWCOUNT 0  
                
          
       PRINT 'Cleaning dbo.post_tran records older than: '+CONVERT(VARCHAR(30),@datetime_stop)  
         SET ROWCOUNT @batch_size  
        DELETE_POST_TRAN_NEW:  
        DELETE FROM dbo.post_tran   WHERE   post_tran_id in (SELECT  TOP (@batch_size)  post_tran_id FROM post_tran (NOLOCK, index(ix_post_tran_9)) WHERE datetime_req >= (SELECT MIN(datetime_req)  FROM post_tran ( NOLOCK, INDEX(ix_post_tran_7))) AND  recon_business_date<=@current_clean_date)  ;  
        IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_NEW 
        SET ROWCOUNT 0  
          
       dbcc shrinkfile(post_office_log, 0)  
      END CATCH  
       SET @current_clean_date= DATEADD(day,1,@current_clean_date);  
     END  
     END  
          
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
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  