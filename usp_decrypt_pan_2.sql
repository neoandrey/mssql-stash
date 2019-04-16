ALTER  PROCEDURE usp_decrypt_pan @pan_list VARCHAR (8000) , @pan_encrypted_list VARCHAR (8000) 
AS BEGIN
	DECLARE @pan VARCHAR (20);
	DECLARE @pan_encrypted CHAR (20);
	DECLARE @pan_decrypted VARCHAR (20);
	DECLARE @process_descr VARCHAR (100);
	DECLARE @terminal_id VARCHAR (100);
	DECLARE @show_full_pan BIT;
	DECLARE @error INT;
	DECLARE @index INT;
	DECLARE @partial_unmask	INT;
	        
        IF ( OBJECT_ID('tempdb.dbo.#temp_pan_data') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_pan_data
		 END
               CREATE TABLE #temp_pan_data (
                         
                         pan_index INT IDENTITY,
                         pan VARCHAR (20),
	       		 pan_encrypted CHAR (20),
	       		 pan_decrypted VARCHAR (20)
               
               );
               
               
	DECLARE @masked_pan_table TABLE (serial_number INT IDENTITY(1,1), pan VARCHAR(100), left_pan_six CHAR(6), right_pan_four CHAR(4));
	DECLARE @pan_encrypyted_table TABLE ( pan_encypted VARCHAR(20));
	
	INSERT INTO @masked_pan_table (pan) SELECT part FROM usf_split_string(@pan_list, ',')

	DECLARE pan_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT pan FROM  @masked_pan_table
	OPEN pan_cursor
	FETCH NEXT FROM pan_cursor INTO @pan

	WHILE (@@FETCH_STATUS =0) BEGIN

		INSERT INTO @masked_pan_table (left_pan_six, right_pan_four) VALUES (LEFT(@pan, 6), RIGHT(@pan,4))
		FETCH NEXT FROM pan_cursor INTO @pan
	END

	CLOSE pan_cursor;
	DEALLOCATE pan_cursor
	
		DECLARE pan_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT pan FROM  @masked_pan_table
		OPEN pan_cursor
		FETCH NEXT FROM pan_cursor INTO @pan
	
		WHILE (@@FETCH_STATUS =0) BEGIN
				IF(@pan_encrypted_list IS NOT NULL  OR LTRIM(RTRIM(@pan_encrypted_list)) <>'')
	       		BEGIN
			       INSERT INTO #temp_pan_data(pan,pan_encrypted, pan_decrypted) SELECT DISTINCT @pan,pan_encrypted,NULL FROM post_tran_cust (NOLOCK) WHERE pan =@pan AND pan_encrypted IN (SELECT part FROM usf_split_string(@pan_encrypted_list, ','))	
	            END
	            ELSE
					BEGIN
			       INSERT INTO #temp_pan_data(pan,pan_encrypted, pan_decrypted) SELECT DISTINCT @pan,pan_encrypted,NULL FROM post_tran_cust (NOLOCK) WHERE pan =@pan	
					END
			INSERT INTO @masked_pan_table (left_pan_six, right_pan_four) VALUES (LEFT(@pan, 6), RIGHT(@pan,4))
			FETCH NEXT FROM pan_cursor INTO @pan
		END
	
		CLOSE pan_cursor;
	DEALLOCATE pan_cursor

	       
	       DECLARE pan_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT pan,pan_encrypted,pan_index FROM #temp_pan_data;
	       		
	       		OPEN pan_cursor
	       
	       		
	       		SET @error = 0
	       
	       		IF (@@CURSOR_ROWS <> 0)
	       		BEGIN
	       			FETCH pan_cursor INTO @pan, @pan_encrypted, @index
	       			
	       			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
	       			BEGIN
	       				-- Handle the decrypting of PANs
	       				
	      				SET @process_descr = 'On-demand PAN Decryption Script';
	      				SET @show_full_pan=1;
	      				SET @pan_decrypted=null;
	      				
	      				SET @partial_unmask=0;
	       				 
	       				--EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_decrypted OUTPUT, @error OUTPUT;
	                 
	                   EXEC osp_decrypt_pan_com @pan, @pan_encrypted, @process_descr, @pan_decrypted OUTPUT, @error OUTPUT, @partial_unmask;
	                   --SELECT @pan_decrypted = dbo.DecryptPan(@pan, @pan_encrypted, @process_descr);
	                  -- SELECT @pan, @pan_encrypted,  @pan_decrypted;
	                   
	       				-- Update the row if its different
	       				IF ((@pan IS  NOT NULL) AND (@pan_decrypted != @pan))
	       				BEGIN
	       				
	       				    UPDATE 
	       						#temp_pan_data
							SET 
								pan_decrypted = @pan_decrypted       				
	       					WHERE
	       						pan_index=@index;
	       						
	       				END
	       
	       				FETCH pan_cursor INTO @pan, @pan_encrypted,@index
	       			END
	       		END
	       
	       		CLOSE pan_cursor;
	       		DEALLOCATE pan_cursor;       		

				SELECT * FROM #temp_pan_data

		DROP TABLE  #temp_pan_data;
	       

               
         END    