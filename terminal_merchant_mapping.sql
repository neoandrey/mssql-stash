	DECLARE @terminal_id_list VARCHAR (2000);
	DECLARE @terminal_id_count BIGINT;
        DECLARE @terminal_id_cursor BIGINT;
	DECLARE @current_terminal_id VARCHAR(30);


	SET @terminal_id_list = '20352598,20352597,20352599,20352595,20352601,20352600,20352596,20352850,20352415,20352587,20352590,20352591,2063Q061,2063Q060,2063QT62,20352849,20352369,20352851,20634114,2063Q062,20634830,20579334,2057R328,2057V126,20580631,20581432,20581430,2033F855';

	SELECT part AS 'terminal_id' INTO #TEMP_TERMINAL_ID_TABLE FROM usf_split_string(@terminal_id_list,',');

	SELECT @terminal_id_count = COUNT(terminal_id) FROM #TEMP_TERMINAL_ID_TABLE;

	SET @terminal_id_cursor =1;
	
	CREATE TABLE #TEMP_MERCHANT_ID_TERMINAL_OWNER (terminal_id VARCHAR (50),merchant_id VARCHAR (1000),  merchant_address VARCHAR (5000) )

	WHILE (@terminal_id_cursor <= @terminal_id_count) 

	BEGIN
	
	  SET @current_terminal_id = (SELECT TOP 1  terminal_id FROM #TEMP_TERMINAL_ID_TABLE)
	  
	  	INSERT INTO #TEMP_MERCHANT_ID_TERMINAL_OWNER(terminal_id, merchant_id,merchant_address) SELECT DISTINCT terminal_id, card_acceptor_id_code,card_acceptor_name_loc FROM post_tran_cust (NOLOCK) WHERE terminal_id =@current_terminal_id;
	  	
	  	DELETE FROM #TEMP_TERMINAL_ID_TABLE WHERE terminal_id =@current_terminal_id;
	     
	        SET @terminal_id_cursor =@terminal_id_cursor+1;
	
	END
	
  	SELECT * FROM   #TEMP_MERCHANT_ID_TERMINAL_OWNER;
  	
  	DROP TABLE #TEMP_MERCHANT_ID_TERMINAL_OWNER;
  	
  	DROP TABLE #TEMP_TERMINAL_ID_TABLE;


