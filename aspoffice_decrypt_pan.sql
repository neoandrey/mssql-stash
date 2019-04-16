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
               
               
                 -- INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('553442*********1518','01G10EEBJ2GT1G2OLJ',NULL);
	         --INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES    ('531002*********2554', '01G1078MA1MJPN5QUC',NULL);
	         --  INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('521841*********9718', '01G10EL3A408MJFPON',NULL);
	         -- INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('558721*********1929','01G103SKGGGL9PJPGC',NULL);
	         
	         
	         
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('517868******3099','01G1091GB62E5EOD91', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('519899******2090','01G10CBJ9OIIAOM3GP', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('519911******6353','01G10318B2BOKSHIEP', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539923******3665','01G105VIVM5U9U6APU', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539941******0078','01G10FH9H9GQHHE35I', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539945******7280','01G10AD9QF2SOA22N0', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******0604','01G10ELE9C9076DTBE', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******1603','01G1041RBVRPH4P9F8', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******3716','01G10DCG2S7SPIH274', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******6202','01G10ALEOCPK7L4CR7', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******7241','01G10CJ898GSS8GDM1', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******7624','01G10BMQTUG0DJT5GB', NULL) 
	   INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******9138','01G1050VRRE9018QTH', NULL) 
           INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('539983******9626','01G10DRRFJ45CFR0G2', NULL) 
	               
	       
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
	                 
	                   --EXEC osp_decrypt_pan_com @pan, @pan_encrypted, @process_descr, @pan_decrypted OUTPUT, @error OUTPUT, @partial_unmask;
	                   SELECT @pan_decrypted = dbo.DecryptPan(@pan, @pan_encrypted, @process_descr);
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
	       		
	       		SELECT * FROM #temp_pan_data;
	       		
		DROP TABLE  #temp_pan_data;
	       

               
               