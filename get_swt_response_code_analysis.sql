USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[get_swt_response_code_analysis]    Script Date: 06/06/2014 11:14:23 ******/

ALTER PROCEDURE [dbo].[get_swt_response_code_analysis] ( @SinkNode VARCHAR(40), @SourceNode VARCHAR(40), @StartDate		DATETIME,  @EndDate DATETIME, @time_interval INT, @report_type   VARCHAR(15) )
AS BEGIN
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
       
	DECLARE @temp_response_codes TABLE( rsp_code_rsp VARCHAR(10))
	--DECLARE @tran_count BIGINT
	--DECLARE @message_type VARCHAR (50)
	--DECLARE @tran_type VARCHAR (50)
	--DECLARE @extended_tran_type VARCHAR (50)
	--DECLARE @tran_postilion_originated INT
	--DECLARE @settle_currency_code VARCHAR (50)
	--DECLARE @sink_node_name    VARCHAR (50)
	--DECLARE @source_node_name    VARCHAR (50)
       
    INSERT INTO @temp_response_codes select part as 'rsp_code_rsp'  FROM usf_split_string('41,42,43,51,52,53,54,62,63,94,96,05,07,15,30,91,93,04,06,57,92,00,01,12,14,59', ',') 
	
	DECLARE @date_cursor VARCHAR(50) 
    DECLARE @current_code CHAR(2)
    DECLARE @currency   VARCHAR(15)  
	
	SET @StartDate =ISNULL( @StartDate,DATEADD(D,-1, DATEDIFF(D,0, GETDATE()))); 
	SET @StartDate =  DATEADD(D,0, DATEDIFF(D,0, @StartDate))
	SET @EndDate = ISNULL(@EndDate, getdate());
	SET @EndDate =  DATEADD(D,0, DATEDIFF(D,0, @EndDate));
	SET @time_interval = ISNULL(@time_interval,1)
	SET @SinkNode    = isnull(@SinkNode, '%%');
	SET @SourceNode    = isnull(@SourceNode, '%%');
	SET @date_cursor = @StartDate
	SELECT @StartDate  AS 'START_DATE',  @EndDate  AS 'END_DATE',DATEDIFF(DD, @date_cursor,@EndDate) AS 'NUMBER_OF_DAYS', @time_interval AS 'TIME_INTERVAL (DAYS)' 
    SET @report_type = ISNULL(@report_type,'LOCAL')
   -- SELECT rsp_code_rsp FROM @temp_response_codes;
    
    IF (@report_type='LOCAL')BEGIN
		SET @currency = '566'
	END
	ELSE IF (@report_type='INTERNATIONAL' OR @report_type='INTL'  )
	BEGIN
		SET @currency = '332,608,434,985,936,764,446,344,950,600,044,598,170,901,694,941,949,414,532,975,512,704,398,951,388,886,974,858,400,368,952,191,208,454,356,012,586,360,422,324,776,136,943,973,578,840,152,784,484,188,756,937,096,504,702,032,643,682,834,230,944,050,008,036,604,124,348,376,000,981,048,418,710,458,242,690,068,410,496,104,807,980,969,203,826,084,516,051,144,748,417,440,404,634,946,818,978,214,968,132,328,352,052,646,800,462,426,752,986,780,788,156,967,072,554,480,498,392';
	END
	ELSE 
	BEGIN
	    SET @currency = '332,608,434,985,936,764,446,344,950,600,044,598,170,901,694,941,949,414,532,975,512,704,398,951,388,886,974,858,400,368,952,191,208,454,356,012,586,360,422,324,776,136,943,973,578,840,152,784,484,188,756,937,096,504,702,032,643,682,834,230,944,050,008,036,604,566,124,348,376,000,981,048,418,710,458,242,690,068,410,496,104,807,980,969,203,826,084,516,051,144,748,417,440,404,634,946,818,978,214,968,132,328,352,052,646,800,462,426,752,986,780,788,156,967,072,554,480,498,392';	
	END 
	
    INSERT INTO #transaction_table
         (tran_nr,sink_node_name,source_node_name,message_type,tran_type,extended_tran_type,tran_postilion_originated,settle_currency_code,rsp_code_rsp,transaction_date ) 
       	SELECT  
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
       	       post_tran trans (NOLOCK)
       	       JOIN 
       	       post_tran_cust cust (NOLOCK)
       	       ON trans.post_tran_cust_id = cust.post_tran_cust_id
       	   WHERE      
						(recon_business_date >= @StartDate) 
						AND 
						(recon_business_date < @EndDate) 
						AND 
						tran_postilion_originated = 1 
						AND
						sink_node_name LIKE @SinkNode 
						AND
						sink_node_name LIKE @SourceNode
						AND  
						CHARINDEX (settle_currency_code, @currency) >=1

	WHILE (DATEDIFF(D, @date_cursor,@EndDate) >= 0)   
	    BEGIN
	    
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
						
						CONVERT (DATETIME,@StartDate),
						sink_node_name,
						source_node_name, 
						message_type,
						tran_type,
						extended_tran_type,
						@current_code,
						CONVERT (DATETIME,@StartDate),
						tran_postilion_originated,
						settle_currency_code,
						COUNT (tran_nr),
						CONVERT(VARCHAR (250), dbo.formatRspCodeStr(@current_code))
                        FROM  #transaction_table (NOLOCK) 
		  			    WHERE rsp_code_rsp = @current_code
		  			     AND 
		  			      (transaction_date >= @StartDate) 
						AND 
						  (transaction_date < @date_cursor) 
		  				GROUP BY 
		  				       message_type,
		  				       tran_type,
		  				       sink_node_name,
						       source_node_name,
		  				       extended_tran_type,
		  				       tran_postilion_originated,
				               settle_currency_code


		 FETCH NEXT FROM rsp_code_cursor INTO @current_code;			
		 END
		 
		 CLOSE rsp_code_cursor
		 DEALLOCATE rsp_code_cursor

	         SET @StartDate = @date_cursor			
	         SET @date_cursor = DATEADD(D,@time_interval,@date_cursor);
	END
	
	SELECT * FROM #report_result;
	
	DROP TABLE #report_result;
	DROP TABLE #transaction_table;
	DROP TABLE #TEMP_RSP_CODES;
	
END