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
               
               
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3813','01G10BPRTULFK0M6SF', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3813','01G10BPRTULFK0M6SF', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3813','01G10BPRTULFK0M6SF', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3813','01G10BPRTULFK0M6SF', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496009******1458','01G10CS9UTOJNL0BQO', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('468588******3105','01G108551NCJEIFIC ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2971','01G105CJI38S0IELFN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496026******2463','01G105E3KR4ELD24CU', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('470652******1918','01G10DMROE9CNUP6S4', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******7091','01G107IU25E467IJIG', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('420333******9150','01G104EQILLOKQQM18', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('427011******9301','01G1089MA2DQDD9VTN', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5415','01G105EIJH864KUTD ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******3180','01G10B2P6S1LVB3TN2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('499908******7354','01G106V7NVK11U51ED', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('499908******7354','01G106V7NVK11U51ED', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('499908******7354','01G106V7NVK11U51ED', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('499908******7354','01G106V7NVK11U51ED', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******9884','01G109T9HS0ECRSODR', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******5508','01G10DL7G0QUQUSBGQ', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('418742******7730','01G1043JTU4HGEMB71', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('496022******2890','01G10AIG2OQJVF0FBP', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
INSERT INTO #temp_pan_data (pan,pan_encrypted, pan_decrypted) VALUES ('484842******9412','01G109B3LVVSD6GKV2', NULL )
	       
	       
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
	       

               
               