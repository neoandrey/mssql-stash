USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[custom_transaction_cleaner]    Script Date: 05/04/2016 20:16:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







ALTER     PROCEDURE [dbo].[custom_transaction_cleaner] @retention_period INT, @period_interval int , @batch_size int AS

BEGIN 

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON

		DECLARE @startDate DATETIME;
		DECLARE @endDate DATETIME;
		DECLARE @retention_period_reduction  INT; 
		DECLARE @retention_period_minutes BIGINT; 
        DECLARE @min_date_time  DATETIME;
        DECLARE @first_post_tran_id  BIGINT;
        DECLARE @last_post_tran_id  BIGINT;
        DECLARE @first_post_tran_cust_id  BIGINT;
        DECLARE @last_post_tran_cust_id  BIGINT;
        DECLARE @min_post_tran_cust_id BIGINT
		set @batch_size  = isnull(@batch_size, 2500)
		IF(@retention_period IS NOT NULL)
		BEGIN
		SET @retention_period_minutes = @retention_period * 24*60;

		
		
           	SELECT @min_date_time =  MIN(datetime_req) FROM dbo.post_tran WITH(NOLOCK,INDEX(ix_post_tran_7));
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
				
				WHILE (DATEDIFF(MINUTE,@datetime_start, @endDate)>0) 
					BEGIN
										
						SELECT @datetime_start = MIN(recon_business_date) FROM dbo.post_tran WITH(NOLOCK,INDEX(ix_post_tran_9));
						
						    IF(DATEDIFF(MINUTE, @datetime_start, GETDATE()) < @retention_period_minutes)BEGIN
						      return
						    
						    end
						SET @datetime_stop= DATEADD(day,@period_interval,@datetime_start);
						DELETE FROM #temp_post_tran_cust
						DELETE FROM #temp_post_tran 
						
						
						
						INSERT INTO #temp_post_tran (post_tran_id)  SELECT post_tran_id FROM dbo.post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE recon_business_date IN 
						
						 (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@datetime_start, @datetime_start)
									)  
	
						PRINT 'Cleaning extract_tran records older than: '+CONVERT(VARCHAR(30),@datetime_stop)
						BEGIN TRY
						
								DELETE FROM extract_tran WHERE post_tran_id  IN (SELECT post_tran_id  FROM #temp_post_tran) 
								
																
								PRINT 'Cleaning dbo.post_tran records older than: '+CONVERT(VARCHAR(30),@datetime_stop)
								SET ROWCOUNT @batch_size
								DELETE_POST_TRAN:
								DELETE FROM dbo.post_tran  WHERE   post_tran_id  IN (SELECT post_tran_id  FROM #temp_post_tran)  
								IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN
								SET ROWCOUNT 0
								
								PRINT 'Cleaning dbo.post_tran_cust records older than: '+CONVERT(VARCHAR(30),@datetime_stop)
								select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								
								WHILE EXISTS (SELECT TOP 1 post_tran_cust_id FROM dbo.post_tran_cust (nolock) WHERE post_tran_cust_id < @min_post_tran_cust_id ORDER BY post_tran_cust_id)
								 BEGIN
								  DELETE  FROM   dbo.post_tran_cust WHERE post_tran_cust_id IN( SELECT top 1000 post_tran_cust_id  from dbo.post_tran_cust (nolock) where post_tran_cust_id < @min_post_tran_cust_id ORDER BY post_tran_cust_id)
								  select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								end
								

								
								IF(DATEDIFF(D,@datetime_start,@datetime_stop)=0)
								BEGIN
										SET @datetime_start=DATEADD(D, 1, DATEDIFF(D,0, @datetime_start));
								END
								
								--dbcc shrinkfile(post_office_log, 0)
						END TRY 
						BEGIN CATCH
						PRINT 'Cleaning dbo.post_tran_cust records older than: '+CONVERT(VARCHAR(30),@datetime_stop)
															
					
								select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								
								WHILE EXISTS (SELECT TOP 1 post_tran_cust_id FROM dbo.post_tran_cust (nolock) WHERE post_tran_cust_id < @min_post_tran_cust_id ORDER BY post_tran_cust_id)
								 BEGIN
								  SET ROWCOUNT @batch_size
								  DELETE_POST_TRAN_CUST:
								  DELETE  FROM   dbo.post_tran_cust WHERE post_tran_cust_id IN( SELECT  post_tran_cust_id  from dbo.post_tran_cust (nolock) where post_tran_cust_id < @min_post_tran_cust_id) 
								  IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST
								  SET ROWCOUNT 0
								  select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								END
								
								
																PRINT 'Cleaning dbo.post_tran records older than: '+CONVERT(VARCHAR(30),@datetime_stop)
								SET ROWCOUNT @batch_size
								DELETE_POST_TRAN_CATCH:
								DELETE FROM dbo.post_tran  WHERE   post_tran_id  IN (SELECT post_tran_id  FROM #temp_post_tran)  
								IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CATCH
								SET ROWCOUNT 0
								
								--dbcc shrinkfile(post_office_log, 0)
						END CATCH

						
						--PRINT  CONVERT(VARCHAR(20),CONVERT(FLOAT,@post_tran_cust_id_temp)/CONVERT(FLOAT,@post_tran_cust_id_stop)*100.0)+'% done...'
					--COMMIT TRANSACTION
					END
					    PRINT 'Running final clean up for transactions older than: '+CHAR(10)
						
						SET @datetime_stop = DATEADD(D,0, DATEDIFF(D,0,@endDate))
						DELETE FROM #temp_post_tran_cust
						DELETE FROM #temp_post_tran 
											INSERT INTO #temp_post_tran (post_tran_id)  SELECT post_tran_id FROM dbo.post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE recon_business_date IN 
						
						 (	
										SELECT  [DATE] FROM  dbo.[get_dates_in_range](@datetime_start, @datetime_stop)
									)  
						
						PRINT 'Cleaning extract_tran records older than: '+CONVERT(VARCHAR(30),@endDate)	
						
						
						DELETE FROM extract_tran WHERE post_tran_id  IN (SELECT post_tran_id  FROM #temp_post_tran) 
						BEGIN TRY

						
							
														PRINT 'Cleaning dbo.post_tran records older than: '+CONVERT(VARCHAR(30),@endDate)	
							SET ROWCOUNT @batch_size
							DELETE_POST_TRAN_FINAL:
							DELETE FROM dbo.post_tran  WHERE   post_tran_id  IN (SELECT post_tran_id  FROM #temp_post_tran)  
							IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_FINAL
							SET ROWCOUNT 0
							
												
										select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								
								WHILE EXISTS (SELECT TOP 1 post_tran_cust_id FROM dbo.post_tran_cust (nolock) WHERE post_tran_cust_id < @min_post_tran_cust_id ORDER BY post_tran_cust_id)
								 BEGIN
								  SET ROWCOUNT @batch_size
								  DELETE_POST_TRAN_CUST_1:
								  DELETE  FROM   dbo.post_tran_cust WHERE post_tran_cust_id IN( SELECT  post_tran_cust_id  from dbo.post_tran_cust (nolock) where post_tran_cust_id < @min_post_tran_cust_id ) 
								  IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST_1
								  SET ROWCOUNT 0
								  select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								END
							--dbcc shrinkfile(post_office_log, 0)
						END TRY
						BEGIN CATCH
						PRINT 'Cleaning dbo.post_tran_cust records older than: '+CONVERT(VARCHAR(30),@endDate)
									
							     select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								 WHILE EXISTS (SELECT TOP 1 post_tran_cust_id FROM dbo.post_tran_cust (nolock) WHERE post_tran_cust_id < @min_post_tran_cust_id ORDER BY post_tran_cust_id)
								 BEGIN
								  SET ROWCOUNT @batch_size
								  DELETE_POST_TRAN_CUST_2:
								  DELETE  FROM   dbo.post_tran_cust WHERE post_tran_cust_id IN( SELECT  post_tran_cust_id  from dbo.post_tran_cust (nolock) where post_tran_cust_id < @min_post_tran_cust_id) 
								  IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_CUST_2
								  SET ROWCOUNT 0
								  select @min_post_tran_cust_id =MIN(post_tran_cust_id) from dbo.post_tran (nolock , INDEX(ix_post_tran_2));
								END
							
						   SET ROWCOUNT @batch_size
							DELETE_POST_TRAN_FINAL_CATCH:
							DELETE FROM dbo.post_tran  WHERE   post_tran_id  IN (SELECT post_tran_id  FROM #temp_post_tran)  
							IF @@ROWCOUNT >0 GOTO DELETE_POST_TRAN_FINAL_CATCH
							SET ROWCOUNT 0
							--dbcc shrinkfile(post_office_log, 0)
						
						
						
						END CATCH
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

















