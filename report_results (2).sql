CREATE TABLE #report_result
	(
		
		StartDate					VARCHAR(30),  
		EndDate						VARCHAR(30),  	
        	NrTrans 			INT,
		sink_node_name				VARCHAR (40), 
		rsp_code_rsp				CHAR (2), 
		rsp_code_description		VARCHAR (60)
		
		)	
	   DECLARE @temp_response_codes TABLE( rsp_code_rsp VARCHAR(10))
       
        INSERT INTO @temp_response_codes select part as 'rsp_code_rsp'  FROM usf_split_string('41,42,43,51,52,53,54,62,63,94,96,05,07,15,30,91,93,04,06,57,92,00,01,12,14,59', ',') 
	 
	DECLARE @SinkNode		VARCHAR(40)
	DECLARE @StartDate		DATETIME, @EndDate DATETIME
	DECLARE @time_interval INT   --months
	DECLARE @date_cursor DATETIME 
        DECLARE @current_code CHAR(2)
	
	SET @StartDate ='2014-01-31 23:59:59' 
	SET @EndDate = getdate()   --DATEADD(MM,1,getdate());
	SET @time_interval =1  -- day, months
	SET @SinkNode    ='MEGGTBVB2snk'
	SET @date_cursor = @StartDate
	SELECT @StartDate  AS 'START_DATE'
        SELECT @EndDate  AS 'END_DATE'
        SELECT DATEDIFF(DD, @EndDate,@date_cursor) AS 'NUMBER_OF_DAYS'
	  SELECT rsp_code_rsp FROM @temp_response_codes
	WHILE (@date_cursor <= @EndDate) 
	  
	    BEGIN

	        DECLARE rsp_code_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT rsp_code_rsp FROM @temp_response_codes
	        OPEN rsp_code_cursor
	        FETCH NEXT FROM rsp_code_cursor INTO @current_code;

	        WHILE (@@FETCH_STATUS =0)
	       	  BEGIN 
			INSERT
						INTO #report_result(StartDate,EndDate,NrTrans,sink_node_name, rsp_code_rsp,rsp_code_description )

				SELECT	
						
						@StartDate as 'StartDate',  
						@date_cursor AS 'EndDate',		
						count(tran_nr) AS 'NrTrans',
						sink_node_name, 
						rsp_code_rsp, 
						dbo.formatRspCodeStr(rsp_code_rsp) AS 'rsp_code_description'
				FROM
						post_tran trans (NOLOCK) JOIN post_tran_cust cust (NOLOCK)
                                                ON trans.post_tran_cust_id =cust.post_tran_cust_id
                                                 
				WHERE 
						(datetime_req >= @StartDate) 
						AND 
						(datetime_req <= @date_cursor) 
						AND 
						tran_postilion_originated = 1 
						AND
						sink_node_name= @SinkNode --LEN('MEGAGTBsnk') = 0 or sink_node_name = 'MEGAGTBsnk'
						and settle_currency_code = '566'
						AND rsp_code_rsp=@current_code
						AND source_node_name ='MEGWEBGTBsrc'
			       GROUP BY
			                 trans.sink_node_name,
			                 trans.rsp_code_rsp,
			                 trans.rsp_code_rsp

			FETCH NEXT FROM rsp_code_cursor INTO @current_code;			
		 END
		 CLOSE rsp_code_cursor
		 DEALLOCATE rsp_code_cursor

	         SET @StartDate = @date_cursor			
			SET @date_cursor = DATEADD(D, @time_interval, DATEDIFF(D, 0, @date_cursor))

	END
	
	SELECT * FROM #report_result;
	
	DROP TABLE #report_result;