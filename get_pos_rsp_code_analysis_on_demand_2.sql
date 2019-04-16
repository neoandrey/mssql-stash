USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[get_pos_rsp_code_analysis_on_demand]    Script Date: 05/19/2015 11:51:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[get_pos_rsp_code_analysis_on_demand] @report_date_start DATETIME, @report_date_end DATETIME, @source_nodes VARCHAR(200) AS

BEGIN

	IF (OBJECT_ID('#report_result') IS NOT NULL ) BEGIN
		DROP TABLE #report_result
	END
	IF (OBJECT_ID('#transaction_table') IS NOT NULL ) BEGIN
	DROP TABLE #transaction_table;
	END
	
	IF (OBJECT_ID('#TEMP_RSP_CODES') IS NOT NULL ) BEGIN
	DROP TABLE #TEMP_RSP_CODES;
	END
	
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	  DECLARE @current_code VARCHAR(10);
	  
	SET @report_date_start =  COALESCE(@report_date_start, DATEADD(D, -7, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-')));
	SET @report_date_end   =  COALESCE(@report_date_end,    DATEADD(D, 1, REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-')))
	SET @source_nodes=COALESCE(@source_nodes, 'SWTNCS2src');
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
      transaction_date DATETIME,
      bin   VARCHAR (6),
      terminal_id VARCHAR(15)
      ) 
       
	
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
				      rsp_code_description VARCHAR(250),
					  bin   VARCHAR (6),
					 terminal_id VARCHAR(15)
		
		)
			DECLARE @temp_response_codes TABLE( rsp_code_rsp VARCHAR(10))
       
    INSERT INTO @temp_response_codes select part as 'rsp_code_rsp'  FROM usf_split_string('00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,75,77,78,79,90,91,92,93,94,95,96,98,Zero,A1,A2,A3,A4,A5,A6,A7,C,C0,C1,C2,D1,E1', ',') 
	
 DECLARE   @list_of_source_nodes  TABLE (source_node	VARCHAR(30)) 
	INSERT INTO  @list_of_source_nodes SELECT part FROM  usf_split_string(@source_nodes,',') ORDER BY PART ASC
	
	IF(@report_date_start<> @report_date_end) BEGIN
		SELECT TOP (1) @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP (1) @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
	END
	ELSE IF(@report_date_start= @report_date_end) BEGIN
		SET  @report_date_start = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_start),111),'/', '-') 
		SET  @report_date_end = DATEADD(D, 1,@report_date_end)
		SET  @report_date_end = REPLACE(CONVERT(VARCHAR(30),  CONVERT(DATETIME, @report_date_end),111),'/', '-') 
	    SELECT TOP (1) @first_post_tran_id=post_tran_id, @first_post_tran_cust_id=post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE    recon_business_date = @report_date_start and datetime_req >= @report_date_start ORDER BY datetime_req ASC
		SELECT TOP (1) @last_post_tran_id=post_tran_id,@last_post_tran_cust_id = post_tran_cust_id FROM post_tran (NOLOCK,INDEX(ix_post_tran_9)) WHERE datetime_req >=  @report_date_start AND  recon_business_date < @report_date_end  order by recon_business_date DESC
END
	

		    INSERT INTO #transaction_table (tran_nr,sink_node_name,source_node_name,message_type,tran_type,extended_tran_type,tran_postilion_originated,settle_currency_code,rsp_code_rsp,transaction_date, bin, terminal_id ) 
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
						datetime_req,
						LEFT(pan,6) bin, 
						terminal_id
					FROM
					 post_tran trans WITH(NOLOCK) 
			JOIN post_tran_cust cust WITH (NOLOCK) ON
			trans.post_tran_cust_id = cust.post_tran_cust_id
		WHERE
				
				(trans.post_tran_id >= @first_post_tran_id) 
				AND 
				(trans.post_tran_id <= @last_post_tran_id) 
				AND
				(trans.post_tran_cust_id >= @first_post_tran_cust_id) 
				AND 
				(trans.post_tran_cust_id <= @last_post_tran_cust_id) 
				AND
				LEFT(terminal_id,1)='2'
				AND 
				tran_postilion_originated =0
				AND 
				LEFT(sink_node_name,2) <>'SB'
				AND 
				source_node_name IN (SELECT source_node FROM @list_of_source_nodes)
	 


	        DECLARE rsp_code_cursor CURSOR STATIC READ_ONLY LOCAL FORWARD_ONLY FOR SELECT rsp_code_rsp FROM @temp_response_codes
	        OPEN rsp_code_cursor 
	        
	        FETCH NEXT FROM rsp_code_cursor INTO @current_code;
	   
	        WHILE (@@FETCH_STATUS =0)
	       	  BEGIN 
	       				                       
			INSERT INTO #report_result(
							calender_date,
							bin,
							 terminal_id,
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
						 bin,
					    terminal_id,
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
		  											bin,
							 terminal_id,
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
	
	END