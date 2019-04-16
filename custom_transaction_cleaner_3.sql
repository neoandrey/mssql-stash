USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[custom_transaction_cleaner]    Script Date: 04/02/2015 07:59:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






ALTER     PROCEDURE [dbo].[custom_transaction_cleaner] @retention_period INT, @period_interval int AS

BEGIN 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		DECLARE @startDate DATETIME;
		DECLARE @endDate DATETIME;
		DECLARE @retention_period_reduction  INT; 
        DECLARE @min_date_time  DATETIME;
        DECLARE @last_post_tran_id  BIGINT;
        DECLARE @first_post_tran_cust_id  BIGINT;
        DECLARE @last_post_tran_cust_id  BIGINT;
		IF(@retention_period IS NOT NULL)
		BEGIN
		
           	SELECT @min_date_time = (SELECT TOP 1 datetime_req  FROM post_tran WITH(NOLOCK,INDEX(ix_post_tran_7)) ORDER BY datetime_req ASC);
           
    IF(DATEDIFF(D, @min_date_time, GETDATE()) >@retention_period)BEGIN

			DECLARE @datetime_start VARCHAR(30);
			DECLARE @datetime_stop VARCHAR(30);
			DECLARE @datetime_temp VARCHAR(30);
			DECLARE @num_of_runs INT;
			DECLARE @counter INT;
            SET @retention_period= DATEDIFF(D, @min_date_time, GETDATE())
			SET @retention_period_reduction = -1 * @retention_period;
			SET @startDate =  DATEADD(D, @retention_period_reduction, GETDATE());
			SET @endDate   =  DATEADD(D, (@retention_period_reduction+1), GETDATE());
			SET @datetime_start = @startDate;
			SET @datetime_stop  = @endDate;
			SET @datetime_start=DATEADD(minute, @period_interval, @datetime_temp);
            --SET @datetime_start = @startDate+' '+CONVERT(VARCHAR(10), DATEADD(minute, @period_interval, @datetime_temp),108);
			
            IF(DATEDIFF(D,@datetime_start, @datetime_stop)<=0) BEGIN
				SET @datetime_temp=@datetime_stop;
			END
				PRINT  'Start Date: '+@datetime_start+CHAR(10)
				PRINT  'End Date:   '+ @datetime_stop+CHAR(10)
				WHILE (DATEDIFF(D,@datetime_start, @datetime_stop)>0) 
					BEGIN
					 -- BEGIN TRANSACTION
											
					PRINT 'Cleaning post_tran_cust records older than: '+@datetime_start;
						SET @datetime_start = (SELECT TOP 1 datetime_req  FROM post_tran WITH (NOLOCK,INDEX(ix_post_tran_7)) ORDER BY datetime_req ASC)
						SET @datetime_start= DATEADD(MINUTE,@period_interval,@datetime_start);
						SET @last_post_tran_cust_id   = (SELECT TOP 1 cust.post_tran_cust_id FROM post_tran trans WITH(NOLOCK, INDEX(ix_post_tran_7)) INNER JOIN post_tran_cust cust ON trans.post_tran_cust_id = cust.post_tran_cust_id WHERE datetime_req < CONVERT(DATETIME, @datetime_start) ORDER BY datetime_req DESC)
						SET @first_post_tran_cust_id  = (SELECT TOP 1 cust.post_tran_cust_id FROM post_tran trans WITH(NOLOCK, INDEX(ix_post_tran_7)) INNER JOIN post_tran_cust cust ON trans.post_tran_cust_id = cust.post_tran_cust_id WHERE datetime_req < CONVERT(DATETIME, @datetime_start) ORDER BY datetime_req ASC)
						PRINT 'Cleaning post_tran records older than: '+@datetime_start	
						
						SET  @last_post_tran_id  =(SELECT TOP 1 post_tran_id  FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req = @datetime_start) ;
						
						SET ROWCOUNT 20000
						DELETE_POST_TRAN:
						DELETE FROM post_tran WHERE post_tran_id<=@last_post_tran_id;
						IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN
						SET ROWCOUNT 0

						SET ROWCOUNT 20000
						DELETE_POST_TRAN_CUST:
						--DELETE post_tran_cust FROM post_tran WITH(NOLOCK, INDEX(ix_post_tran_7)) INNER JOIN post_tran_cust ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id WHERE datetime_req < CONVERT(DATETIME, @datetime_start);
						DELETE FROM post_tran_cust WHERE post_tran_cust_id >= @first_post_tran_cust_id AND post_tran_cust_id <= @last_post_tran_cust_id;
						IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST
						SET ROWCOUNT 0

						--SET @datetime_temp=CONVERT(VARCHAR(10), DATEADD(minute, @period_interval, @datetime_temp),108)
						
						IF(DATEDIFF(D,@datetime_start,@datetime_stop)=0)
						BEGIN
						SET @datetime_start=DATEADD(D, 1, DATEDIFF(D,0, @datetime_start));
						END
						
						
						--PRINT  CONVERT(VARCHAR(20),CONVERT(FLOAT,@post_tran_cust_id_temp)/CONVERT(FLOAT,@post_tran_cust_id_stop)*100.0)+'% done...'
					--COMMIT TRANSACTION
					END
					    PRINT 'Running final clean up: '+CHAR(10)
						PRINT 'Cleaning post_tran records older than: '+@datetime_stop	
						SET @datetime_stop = DATEADD(D,0, DATEDIFF(D,0,@datetime_stop))
						SET ROWCOUNT 20000
						DELETE_POST_TRAN_ALL:
						DELETE FROM post_tran WHERE datetime_req < CONVERT(DATETIME, @datetime_stop);
						IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_ALL
						SET ROWCOUNT 0

						SET ROWCOUNT 20000
						DELETE_POST_TRAN_CUST_ALL:
						DELETE post_tran_cust FROM post_tran WITH(NOLOCK, INDEX(ix_post_tran_7)) INNER JOIN post_tran_cust ON post_tran.post_tran_cust_id = post_tran_cust.post_tran_cust_id WHERE datetime_req < CONVERT(DATETIME, @datetime_stop);
						IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST_ALL
						SET ROWCOUNT 0
					
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












