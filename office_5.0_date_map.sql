
	DECLARE @min_date DATETIME 
DECLARE @recon_date_check INT
			IF(@report_date_start<> @report_date_end) BEGIN
			SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '') 
			SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '') 
			SELECT @first_post_tran_id= MIN(post_tran_id)		FROM post_tran_leg_internal WITH (NOLOCK) WHERE    recon_business_date = @report_date_start
			SELECT @last_post_tran_id=MIN(post_tran_id) FROM post_tran_leg_internal WITH(NOLOCK) WHERE  recon_business_date = @report_date_end  
			SELECT @min_date = datetime_req FROM post_tran_leg_internal WITH (NOLOCK) WHERE post_tran_id = @first_post_tran_id
			SELECT  @recon_date_check = DATEDIFF(D, @min_date, @report_date_start)
			IF(@recon_date_check=1) BEGIN
					SELECT @first_post_tran_id= MIN(post_tran_id)		FROM post_tran_leg_internal WITH (NOLOCK) WHERE    recon_business_date =DATEADD(D,1,@report_date_start)
					SELECT @last_post_tran_id=MIN(post_tran_id) FROM post_tran_leg_internal WITH(NOLOCK) WHERE  recon_business_date = DATEADD(D,1,@report_date_end  )
			END

		END
		ELSE IF(@report_date_start= @report_date_end) BEGIN

						SET  @report_date_start = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_start),111),'/', '') 
						SET  @report_date_end = DATEADD(D, 1,@report_date_end)
						SET  @report_date_end = REPLACE(CONVERT(VARCHAR(10),  CONVERT(DATETIME, @report_date_end),111),'/', '') 
						SELECT @first_post_tran_id= MIN(post_tran_id)		FROM post_tran_leg_internal WITH (NOLOCK) WHERE    recon_business_date = @report_date_start
						SELECT @last_post_tran_id=MIN(post_tran_id) FROM post_tran_leg_internal WITH(NOLOCK) WHERE  recon_business_date = @report_date_end  
						SELECT @min_date = datetime_req FROM post_tran_leg_internal WITH (NOLOCK) WHERE post_tran_id = @first_post_tran_id
						SELECT  @recon_date_check = DATEDIFF(D, @min_date, @report_date_start) 
						IF(@recon_date_check=1) BEGIN
								SELECT @first_post_tran_id= MIN(post_tran_id)		FROM post_tran_leg_internal WITH (NOLOCK) WHERE    recon_business_date =DATEADD(D,1,@report_date_start)
								SELECT @last_post_tran_id=MIN(post_tran_id) FROM post_tran_leg_internal WITH(NOLOCK) WHERE  recon_business_date = DATEADD(D,1,@report_date_end  )
						END
		END