	DROP TABLE #report_result;
	DROP TABLE #transaction_table;
	DROP TABLE #TEMP_RSP_CODES;
	
	DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SET @report_date_start = '2015-03-14'
	SET @report_date_end= '2015-03-22'
	
	CREATE TABLE #TEMP_RSP_CODES(

		tran_count  BIGINT,
		sink_node_name    VARCHAR (50),
		source_node_name    VARCHAR (50),
		message_type VARCHAR (50),
		tran_type VARCHAR (50),
		extended_tran_type VARCHAR (50),
		tran_postilion_originated INT,
		settle_currency_code VARCHAR (50)
       )
       
     CREATE TABLE  #transaction_table
      (tran_nr BIGINT ,
      sink_node_name VARCHAR (50),
      source_node_name VARCHAR (50),
      message_type VARCHAR (50),
      tran_type VARCHAR (50),
      extended_tran_type VARCHAR (50),
      tran_postilion_originated INT ,
      settle_currency_code VARCHAR (50),
      rsp_code_rsp VARCHAR (50),
      transaction_date DATETIME
      ) 
       
			  DECLARE @current_code VARCHAR(10);
		CREATE TABLE #report_result
	(	
			          calender_date   VARCHAR (50),
				      sink_node_name    VARCHAR (50),
				      source_node_name    VARCHAR (50), 
				      message_type    VARCHAR (50),
				      tran_type    VARCHAR (50),
				      extended_tran_type    VARCHAR (50),
				      rsp_code_rsp   VARCHAR (10),
				      recon_business_date    VARCHAR (50),
				      tran_postilion_originated    INT,
				      settle_currency_code    VARCHAR (50),
				      tran_count BIGINT,
				      rsp_code_description VARCHAR(250)
		
		)
			DECLARE @temp_response_codes TABLE( rsp_code_rsp VARCHAR(10))
       
    INSERT INTO @temp_response_codes select part as 'rsp_code_rsp'  FROM usf_split_string('00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,75,77,78,79,90,91,92,93,94,95,96,98,Zero,A1,A2,A3,A4,A5,A6,A7,C,C0,C1,C2,D1,E1', ',') 
	

	IF(@report_date_start<> @report_date_end) BEGIN
		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req >=  @report_date_start  AND recon_business_date >=  @report_date_start   ORDER BY datetime_req ASC)
		SET  @last_post_tran_cust_id  = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end ) ORDER BY datetime_req DESC)
		SET  @first_post_tran_id      = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >=  @report_date_start   AND recon_business_date >= @report_date_start     ORDER BY datetime_req ASC)
		SET  @last_post_tran_id       = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end AND (recon_business_date < @report_date_end) ORDER BY datetime_req DESC)
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
		SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 

		SET  @first_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req >= @report_date_start  AND (recon_business_date >= @report_date_start )  ORDER BY recon_business_date ASC)
		SET  @last_post_tran_cust_id = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_9)) WHERE datetime_req < @report_date_end  AND (recon_business_date < @report_date_end ) ORDER BY recon_business_date DESC)

		SET  @first_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE datetime_req >= @report_date_start AND (recon_business_date >= @report_date_start )  ORDER BY datetime_req ASC)
		SET  @last_post_tran_id = (SELECT TOP 1 post_tran_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE  datetime_req < @report_date_end AND (recon_business_date < @report_date_end  ) ORDER BY datetime_req DESC)
	END
	


		    INSERT INTO #transaction_table (tran_nr,sink_node_name,source_node_name,message_type,tran_type,extended_tran_type,tran_postilion_originated,settle_currency_code,rsp_code_rsp,transaction_date ) 
       	SELECT  
       	           DISTINCT
       	                                         tran_nr,
						sink_node_name,
						source_node_name,
						message_type,
						tran_type,
						extended_tran_type,
						tran_postilion_originated,
						settle_currency_code,
						rsp_code_rsp,
						datetime_req
					FROM
					 post_tran trans WITH(NOLOCK, INDEX(ix_post_tran_2)) 
			JOIN post_tran_cust cust WITH (NOLOCK, INDEX(pk_post_tran_cust)) ON
			trans.post_tran_cust_id = cust.post_tran_cust_id
		WHERE
				(trans.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(trans.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				(trans.post_tran_id >= @first_post_tran_id) 
				AND 
				(trans.post_tran_id <= @last_post_tran_id) 
				AND
				LEFT(terminal_id,1)='2'
				AND 
				tran_postilion_originated =0
				AND 
				LEFT(sink_node_name,2) <>'SB'
				AND 
				CHARINDEX('NCS',source_node_name )>0 
	 


	        DECLARE rsp_code_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT rsp_code_rsp FROM @temp_response_codes
	        OPEN rsp_code_cursor 
	        
	        FETCH NEXT FROM rsp_code_cursor INTO @current_code;
	   
	        WHILE (@@FETCH_STATUS =0)
	       	  BEGIN 
	       				                       
			INSERT INTO #report_result(
							calender_date,
							sink_node_name,
							source_node_name, 
							message_type,
							tran_type,
							extended_tran_type,
							rsp_code_rsp,
							recon_business_date,
							tran_postilion_originated,
							settle_currency_code,
							tran_count,
							rsp_code_description
						 )
						 SELECT	
						
						DATEADD (D,0, DATEDIFF(D,0,transaction_date)),
						sink_node_name,
						source_node_name, 
						message_type,
						tran_type,
						extended_tran_type,
						@current_code,
						DATEADD (D,0, DATEDIFF(D,0,transaction_date)),
						tran_postilion_originated,
						settle_currency_code,
						COUNT ( DISTINCT tran_nr),
						CONVERT(VARCHAR (250), dbo.formatRspCodeStr(@current_code))
                        FROM
                          #transaction_table (NOLOCK) 
		  			    WHERE rsp_code_rsp = @current_code
		  				GROUP BY
		  				DATEADD (D,0, DATEDIFF(D,0,transaction_date)),
		  				rsp_code_rsp,
  				       message_type,
  				       tran_type,
  				       sink_node_name,
				       source_node_name,
  				       extended_tran_type,
		               settle_currency_code,
		               tran_postilion_originated


		 FETCH NEXT FROM rsp_code_cursor INTO @current_code;			
		 END
		 
		 CLOSE rsp_code_cursor
		 DEALLOCATE rsp_code_cursor

	   
	
	SELECT * FROM #report_result ORDER BY calender_date ASC;