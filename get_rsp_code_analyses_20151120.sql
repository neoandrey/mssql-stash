USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[get_rsp_code_analyses]    Script Date: 11/20/2015 16:27:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[get_rsp_code_analyses] @report_date_start DATETIME, @report_date_end DATETIME, @source_node VARCHAR(200), @sink_node VARCHAR(200) AS

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
	

	  DECLARE @current_code VARCHAR(10);
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT

	
	CREATE TABLE #TEMP_RSP_CODES(

		tran_count  BIGINT,
		sink_node_name    VARCHAR (50),
		source_node_name    VARCHAR (50),
		message_type VARCHAR (50),
		tran_type VARCHAR (50),
		extended_tran_type VARCHAR (50),
		settle_currency_code VARCHAR (50)
       )
       
     CREATE TABLE  #transaction_table
      (
      tran_nr BIGINT ,
      sink_node_name VARCHAR (50),
      source_node_name VARCHAR (50),
      message_type VARCHAR (50),
      tran_type VARCHAR (50),
      extended_tran_type VARCHAR (50),
      settle_currency_code VARCHAR (50),
      rsp_code_rsp VARCHAR (50),
      transaction_date DATETIME,
      bin   VARCHAR (6),
      terminal_id VARCHAR(15),
	  acquirer	 VARCHAR(40),
		issuer VARCHAR(40),
		system_trace_audit_nr  VARCHAR(10),
		retrieval_reference_nr VARCHAR (20),
		tran_amount_req   BIGINT,
		tran_amount_rsp   BIGINT

      
      ) 
       
	
		CREATE TABLE #report_result
	(	
			          calender_date   VARCHAR (50),
			          acquirer  VARCHAR (50),
				      issuer  VARCHAR (50),
				      sink_node_name    VARCHAR (50),
				      source_node_name    VARCHAR (50), 
				      message_type    VARCHAR (50),
				      tran_type    VARCHAR (50),
				      extended_tran_type    VARCHAR (50),
				      rsp_code_rsp   VARCHAR (10),
				      recon_business_date    VARCHAR (50),
				      settle_currency_code    VARCHAR (50),
				      tran_count BIGINT,
				      rsp_code_description VARCHAR(250),
					  bin   VARCHAR (6),
					  terminal_id VARCHAR(15)
		
		)
			DECLARE @temp_response_codes TABLE( rsp_code_rsp VARCHAR(10))
       
    INSERT INTO @temp_response_codes select part as 'rsp_code_rsp'  FROM usf_split_string('00,01,02,03,04,05,06,07,08,09,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,75,77,78,79,90,91,92,93,94,95,96,98,Zero,A1,A2,A3,A4,A5,A6,A7,C,C0,C1,C2,D1,E1', ',') 
	

		INSERT INTO #transaction_table (tran_nr,sink_node_name,source_node_name,message_type,tran_type,extended_tran_type,settle_currency_code,rsp_code_rsp,transaction_date, bin, terminal_id,acquirer, issuer,system_trace_audit_nr,
  retrieval_reference_nr, tran_amount_req,tran_amount_rsp ) 
		SELECT  
			
			tran_nr,
			sink_node_name,
			source_node_name,
			message_type,
			tran_type,
			extended_tran_type,
			settle_currency_code,
			rsp_code_rsp,
			datetime_req,
			LEFT(pan,6) bin, 
			terminal_id,
			CASE
	WHEN SUBSTRING(terminal_id, 2,3)='044'	THEN	'Access Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='070'	THEN	'Fidelity Bank'	
	WHEN SUBSTRING(terminal_id, 2,3) in ('221','039')	THEN	'StanbicIBTC'	
	WHEN SUBSTRING(terminal_id, 2,3)='014'	THEN	'Afribank'	
	WHEN SUBSTRING(terminal_id, 2,3)='085'	THEN	'Finbank'	
	WHEN SUBSTRING(terminal_id, 2,3)='068'	THEN	'Standard Chartered Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='023'	THEN	'Citibank'	
	WHEN SUBSTRING(terminal_id, 2,3)='058'	THEN	'Guaranty Trust Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='232'	THEN	'Sterling Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='063'	THEN	'Diamond Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='069'	THEN	'Intercontinental Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='033'	THEN	'United Bank for Africa'	
	WHEN SUBSTRING(terminal_id, 2,3)='050'	THEN	'Ecobank'	
	WHEN SUBSTRING(terminal_id, 2,3)='056'	THEN	'Oceanic Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='032'	THEN	'Union Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='040'	THEN	'Equitorial Trust Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='082'	THEN	'BankPhb'	
	WHEN SUBSTRING(terminal_id, 2,3)='035'	THEN	'Wema bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='011'	THEN	'First Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='076'	THEN	'Skye Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='057'	THEN	'Zenith Bank'	
	WHEN SUBSTRING(terminal_id, 2,3)='214'	THEN	'FCMB'	
	WHEN SUBSTRING(terminal_id, 2,3)='084'	THEN	'SpringBank'	
	WHEN SUBSTRING(terminal_id, 2,3)='215'	THEN	'Unity bank'	
ELSE 
   terminal_id
   
END   acquirer,

CASE  
  WHEN CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN  CHARINDEX ( 'ZIB', card_product) > 0  THEN	'Zenith International Bank'
  WHEN  CHARINDEX ( 'PRU', card_product) > 0  THEN	'Skye Bank'
  WHEN  CHARINDEX ( 'PLAT', card_product) > 0  THEN	'PlatinumHabib Bank'
  WHEN  CHARINDEX ( 'CHB', card_product) > 0  THEN	'Stanbic IBTC Bank'
  WHEN  CHARINDEX ( 'GTB', card_product) > 0  THEN	'Guaranty Trust Bank'
  WHEN  CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN  CHARINDEX ( 'FBN', card_product) > 0  THEN	'First Bank of Nigeria'
  WHEN  CHARINDEX ( 'OBI', card_product) > 0  THEN	'Oceanic Bank'
  WHEN  CHARINDEX ( 'WEM', card_product) > 0  THEN	'WEMA Bank Plc'
  WHEN  CHARINDEX ( 'AFRI', card_product) > 0  THEN	'Main Street Bank'
  WHEN  CHARINDEX ( 'ETB', card_product) > 0  THEN	'Equitorial Trust Bank'
  WHEN  CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN  CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN  CHARINDEX ( 'UBN', card_product) > 0  THEN	'Union Bank of Nigeria'
  WHEN  CHARINDEX ( 'FCMB', card_product) > 0  THEN	'First City Monument Bank'
  WHEN  CHARINDEX ( 'DBL', card_product) > 0  THEN	'Diamond Bank'
  WHEN  CHARINDEX ( 'FIB', card_product) > 0  THEN	'First Inland Bank'
  WHEN  CHARINDEX ( 'EBN', card_product) > 0  THEN	'EcoBank Nigeria'
  WHEN  CHARINDEX ( 'ABP', card_product) > 0  THEN	'Access Bank Plc'
  WHEN  CHARINDEX ( 'UBP', card_product) > 0  THEN	'Unity Bank Plc'
  WHEN  CHARINDEX ( 'SPR', card_product) > 0  THEN	'Enterprise Bank'
  WHEN  CHARINDEX ( 'SBP', card_product) > 0  THEN	'Sterling Bank Plc'
  WHEN  CHARINDEX ( 'CITI', card_product) > 0  THEN	'Citi Bank '
  WHEN  CHARINDEX ( 'FD', card_product) > 0  THEN	'Cardless'
  WHEN  CHARINDEX ( 'FBP', card_product) > 0  THEN	'Fidelity Bank'
  WHEN  CHARINDEX ( 'SCB', card_product) > 0  THEN	'Standard Chartered Bank'
  WHEN  CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN  CHARINDEX ( 'ZIB', card_product) > 0  THEN	'Zenith International Bank'
  WHEN  CHARINDEX ( 'PRU', card_product) > 0  THEN	'Skye Bank'
  WHEN  CHARINDEX ( 'PLAT', card_product) > 0  THEN	'Keystone Bank'
  WHEN  CHARINDEX ( 'CHB', card_product) > 0  THEN	'Stanbic IBTC Bank'
  WHEN  CHARINDEX ( 'GTB', card_product) > 0  THEN	'Guaranty Trust Bank'
  WHEN  CHARINDEX ( 'UBA', card_product) > 0  THEN	'United Bank for Africa'
  WHEN CHARINDEX ( 'FBN', card_product) > 0  THEN	'First Bank of Nigeria'
  WHEN CHARINDEX ( 'OBI', card_product) > 0  THEN	'Oceanic Bank'
  WHEN CHARINDEX ( 'WEM', card_product) > 0  THEN	'WEMA Bank Plc'
  WHEN CHARINDEX ( 'AFRI', card_product) > 0  THEN	'Main Street Bank'
  WHEN CHARINDEX ( 'ETB', card_product) > 0  THEN	'Equitorial Trust Bank'
  WHEN CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN CHARINDEX ( 'IBP', card_product) > 0  THEN	'Intercontinental Bank'
  WHEN CHARINDEX ( 'UBN', card_product) > 0  THEN	'Union Bank of Nigeria'
  WHEN  CHARINDEX ( 'FCMB', card_product) > 0  THEN	'First City Monument Bank'
  WHEN CHARINDEX ( 'DBL', card_product) > 0  THEN	'Diamond Bank'
  WHEN CHARINDEX ( 'FIB', card_product) > 0  THEN	'First Inland Bank'
  WHEN CHARINDEX ( 'EBN', card_product) > 0  THEN	'EcoBank Nigeria'
  WHEN CHARINDEX ( 'ABP', card_product) > 0  THEN	'Access Bank Plc'
  WHEN CHARINDEX ( 'UBP', card_product) > 0  THEN	'Unity Bank Plc'
  WHEN CHARINDEX ( 'SPR', card_product) > 0  THEN	'Enterprise Bank'
  WHEN CHARINDEX ( 'SBP', card_product) > 0  THEN	'Sterling Bank'
  WHEN CHARINDEX ( 'CITI', card_product) > 0  THEN	'Citi Bank'
  WHEN CHARINDEX ( 'ABS', card_product) > 0  THEN	'Abbey'
  WHEN CHARINDEX ( 'OtherCards', card_product) > 0  THEN	'International Issuer'
  ELSE   card_product
  
  END 
issuer,
 system_trace_audit_nr,
  retrieval_reference_nr, 
   dbo.formatAmount(tran_amount_req, tran_currency_code) tran_amount_req , 
   dbo.formatAmount(tran_amount_rsp, tran_currency_code)  tran_amount_rsp 
			FROM
		post_tran trans WITH(NOLOCK) 
			JOIN post_tran_cust cust WITH (NOLOCK) ON
			trans.post_tran_cust_id = cust.post_tran_cust_id
			--	AND
			--	(trans.post_tran_id >= @first_post_tran_id) 
			--AND 
			--(trans.post_tran_id <= @last_post_tran_id) 
			--AND
			--(trans.post_tran_cust_id >= @first_post_tran_cust_id) 
			--AND 
			--(trans.post_tran_cust_id <= @last_post_tran_cust_id) 
			--AND 
			WHERE
						datetime_req>=@report_date_start
				AND
				post_tran_id >=@first_post_tran_id
				AND 
				post_tran_id <= @last_post_tran_id
				and
				sink_node_name =@sink_node
							AND 
							source_node_name =@source_node


			AND 
			LEFT(sink_node_name,2) <>'SB'
		--WHERE
			
	 


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
							settle_currency_code,
							tran_count,
							rsp_code_description,
							acquirer,
							issuer
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
						settle_currency_code,
						COUNT ( DISTINCT tran_nr),
						CONVERT(VARCHAR (250), dbo.formatRspCodeStr(@current_code)),
						acquirer,
							issuer
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
						acquirer,
						issuer


		 FETCH NEXT FROM rsp_code_cursor INTO @current_code;			
		 END
		 
		 CLOSE rsp_code_cursor
		 DEALLOCATE rsp_code_cursor

	   
	
	SELECT * FROM #report_result ORDER BY calender_date ASC;
	
	END
