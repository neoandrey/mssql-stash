USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[manage_normalization_freeze]    Script Date: 07/15/2015 11:22:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[manage_normalization_freeze] (@norm_freeze_period BIGINT)

  AS
  
  BEGIN

			DECLARE @last_post_tran_id  BIGINT;
			DECLARE @last_post_tran_cust_id  BIGINT;
			DECLARE @last_check_time   DATETIME;
			DECLARE @norm_start_time   DATETIME;
			DECLARE @norm_run_duration   VARCHAR(30);
			DECLARE @norm_status   VARCHAR(30);
			DECLARE @norm_action  VARCHAR(30);
			DECLARE @norm_process_run_id BIGINT;
			DECLARE @norm_cutover BIT;
			DECLARE @norm_end_time DATETIME;
			DECLARE @last_norm_id BIGINT;
			DECLARE @max_post_tran_id BIGINT;
			DECLARE @max_post_tran_cust_id BIGINT;
			DECLARE @max_tran_Time DATETIME;
  

 
	        SELECT  TOP 1 @max_post_tran_id =  last_post_tran_id , @max_post_tran_cust_id=last_post_tran_cust_id , @last_norm_id=norm_index fROM normalization_history ORDER BY last_check_time DESC
			SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran (nolock) ORDER BY post_tran_id DESC)
			SET  @last_post_tran_cust_id =(SELECT TOP 1 post_tran_cust_id FROM post_tran_cust (nolock) ORDER BY post_tran_cust_id DESC)
			SET  @max_tran_Time =(SELECT TOP 1 datetime_req FROM post_tran (nolock) ORDER BY datetime_req DESC)
			
			SET  @last_check_time= GETDATE();
			SELECT TOP 1* INTO #TEMP_NORM_HISTORY  FROM post_process_run (NOLOCK) WHERE process_name='Normalization' ORDER BY process_run_id DESC;
			SELECT @norm_process_run_id= process_run_id, @norm_start_time=datetime_begin, @norm_end_time= datetime_end FROM #TEMP_NORM_HISTORY (NOLOCK) WHERE process_name='Normalization' ORDER BY process_run_id DESC;
			SELECT @norm_status =  CASE WHEN @norm_end_time IS NULL THEN 'RUNNING'
										 ELSE 'NOT RUNNING'
									    END 
			
					 
			SELECT @norm_cutover = CASE WHEN DATEDIFF(D,DATEADD(D, 0, DATEDIFF(D, 0, @norm_start_time)) ,DATEADD(D, 0, DATEDIFF(D, 0, @max_tran_Time)))=1 THEN 1
										 WHEN DATEDIFF(D,DATEADD(D, 0, DATEDIFF(D, 0, @norm_start_time)) ,DATEADD(D, 0, DATEDIFF(D, 0, @max_tran_Time)))=1 THEN 0
									     ELSE 0
									END
			   
		   --SELECT @last_norm_id=COUNT(last_post_tran_id) FROM normalization_history;
		   
		   IF (@norm_cutover=1)
			   BEGIN
			    UPDATE 
                      normalization_history 
                  SET
					   norm_cutover=  1
               WHERE 
                   norm_index=@last_norm_id 
		    END
			 
			
			 
 IF(@last_norm_id=0 OR @last_norm_id IS NULL)
    BEGIN
    
    INSERT INTO normalization_history(
               last_post_tran_id,
               last_post_tran_cust_id,
               last_check_time,
               norm_start_time, 
               norm_run_duration,
               norm_status,
               norm_action,
               norm_process_run_id,
               norm_cutover, 
               norm_end_time
         )  VALUES (
				@last_post_tran_id,
				@last_post_tran_cust_id,
				@last_check_time,
				@norm_start_time,
				DATEDIFF(mi, @norm_start_time,@norm_end_time),
				@norm_status,
				'INSERT',
				@norm_process_run_id,
				@norm_cutover,
				@norm_end_time
    );
    
    
    END
   
    
     IF (@norm_end_time IS NULL OR (@norm_end_time  =(SELECT MAX(norm_end_time) FROM normalization_history)))
    BEGIN
    
    	SET @norm_end_time =ISNULL(@norm_end_time, GETDATE());
   --  SELECT @max_post_tran_id,@last_post_tran_id,@last_post_tran_cust_id,@max_post_tran_cust_id
            IF(@max_post_tran_id <> @last_post_tran_id AND  @last_post_tran_cust_id <>@max_post_tran_cust_id)
               BEGIN
               
                  UPDATE 
                      normalization_history 
                  SET 
                       norm_start_time =@norm_start_time,
					   last_post_tran_id = @last_post_tran_id,
					   last_post_tran_cust_id =@last_post_tran_cust_id,
					   last_check_time= @last_check_time,
					   norm_run_duration= DATEDIFF(mi, @norm_start_time,@norm_end_time),
					   norm_status=@norm_status,
					   norm_action='UPDATE',
					   norm_process_run_id=@norm_process_run_id,
					   norm_end_time=@norm_end_time
               WHERE 
                   last_post_tran_id =@max_post_tran_id 
and
               last_post_tran_cust_id =@max_post_tran_cust_id
               END
            ELSE  IF(@max_post_tran_id = @last_post_tran_id AND  @last_post_tran_cust_id = @max_post_tran_cust_id)
               BEGIN

                SELECT @norm_start_time AS start_time, @norm_end_time AS end_time, MAX(norm_end_time) FROM normalization_history
					IF ( DATEDIFF(mi, @norm_start_time,@norm_end_time) >= @norm_freeze_period OR @norm_end_time =(SELECT MAX(norm_end_time)FROM normalization_history )) 
				BEGIN
					        EXEC master.dbo.xp_cmdshell 'taskkill /im PONormaliza.exe /f /t';			        
							INSERT INTO normalization_history(
									   last_post_tran_id,
									   last_post_tran_cust_id,
									   last_check_time,
									   norm_start_time, 
									   norm_run_duration,
									   norm_status,
									   norm_action,
									   norm_process_run_id,
									   norm_cutover,
									    norm_end_time
								 )  VALUES (
										@last_post_tran_id,
										@last_post_tran_cust_id,
										@last_check_time,
										@norm_start_time,
										DATEDIFF(mi, @norm_start_time,@norm_end_time),
										@norm_status,
										'TERMINATED',
										@norm_process_run_id,
										@norm_cutover,
										@norm_end_time
							);
						    
					    
					
				     END
               
               
               
               END
 
    END
    ELSE 
    
    BEGIN
    
    	SET @norm_end_time =ISNULL(@norm_end_time, GETDATE());
    
                      UPDATE 
                      normalization_history 
                  SET 
					   last_post_tran_id = @last_post_tran_id,
					   last_post_tran_cust_id =@last_post_tran_cust_id,
					   last_check_time= @last_check_time,
					   norm_start_time =@norm_start_time,
					   norm_run_duration= DATEDIFF(mi, @norm_start_time,@norm_end_time),
					   norm_status=@norm_status,
					   norm_action='UPDATE',
					   norm_process_run_id=@norm_process_run_id,
					   norm_end_time=@norm_end_time
               WHERE 
                   norm_index=@last_norm_id 
    
    END
    
    END
    




