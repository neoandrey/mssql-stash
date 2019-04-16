		DECLARE @pan VARCHAR (20);
		DECLARE @pan_encrypted CHAR (20);
		DECLARE @pan_decrypted VARCHAR (20);
		DECLARE @process_descr VARCHAR (100);
		DECLARE @terminal_id VARCHAR (100);
		DECLARE @show_full_pan BIT;
                DECLARE @error INT;
                DECLARE @txn_id BIGINT;
		DECLARE @partial_unmask INT;
                
                SET @process_descr = 'XLS Settlement Pan Retrieval';
                
                SET @show_full_pan = 0;
                
		SET @partial_unmask =0;

		IF ( OBJECT_ID('tempdb.dbo.#temp_tbl_xls_settlement_new') IS NOT NULL)
		 BEGIN
		          DROP TABLE #temp_tbl_xls_settlement_new
		 END
		                
                CREATE TABLE  #temp_tbl_xls_settlement_new (
			[txn_id] [int] ,
			[terminal_id] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[pan] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[clear_pan] [varchar] (50),
			[trans_date] [datetime] NULL ,
			[extended_trans_type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[amount] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[rr_number] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[stan] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[rdm_amt] [decimal](18, 2) NULL ,
			[merchant_id] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[cashier_name] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[cashier_code] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[cashier_acct] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL ,
			[cashier_ext_trans_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL 
		) 
		

                --MODIFY the value '10' after 'Top'  to increase the number of results

		DECLARE pan_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT TOP 10 pan,terminal_id,txn_id FROM tbl_xls_settlement order by trans_date desc
		
		OPEN pan_cursor

		
		SET @error = 0

		IF (@@CURSOR_ROWS != 0)
		BEGIN
			FETCH pan_cursor INTO @pan, @terminal_id,@txn_id
			WHILE ((@@FETCH_STATUS = 0) AND (@error = 0))
			BEGIN
				-- Handle the decrypting of PANs
				SET    @pan_encrypted=  (SELECT top 1 pan_encrypted  FROM post_tran_cust WITH (NOLOCK) WHERE pan =@pan AND terminal_id =@terminal_id);
	
				--EXEC osp_decypt_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_decrypted OUTPUT, @error OUTPUT

				EXEC osp_decrypt_pan_com @pan, @pan_encrypted, @process_descr,  @pan_decrypted OUTPUT, @error OUTPUT, @partial_unmask
				
							-- Update the row if its different
				IF ((@pan IS  NOT NULL) AND (@pan_decrypted <> @pan))
				BEGIN
					
				INSERT	INTO   #temp_tbl_xls_settlement_new(
							[txn_id],
							[terminal_id] ,
							[pan]   ,
							[clear_pan] ,
							[trans_date]  ,
							[extended_trans_type],
							[amount] ,
							[rr_number] ,
							[stan]  ,
							[rdm_amt]  ,
							[merchant_id]  ,
							[cashier_name] ,
							[cashier_code]  ,
							[cashier_acct] ,
							[cashier_ext_trans_code]
						) 
					SELECT 
						[txn_id],
						[terminal_id] ,
						[pan]   ,
						[clear_pan] = @pan_decrypted,
						[trans_date]  ,
						[extended_trans_type],
						[amount] ,
						[rr_number] ,
						[stan]  ,
						[rdm_amt]  ,
						[merchant_id]  ,
						[cashier_name] ,
						[cashier_code]  ,
						[cashier_acct] ,
						[cashier_ext_trans_code] 
					FROM 
						tbl_xls_settlement
				
					WHERE
						txn_id=@txn_id;
						
				END

				FETCH pan_cursor INTO @pan, @terminal_id,@txn_id
			END
		END

		CLOSE pan_cursor;
		DEALLOCATE pan_cursor;
		
		SELECT * FROM #temp_tbl_xls_settlement_new;
		
		DROP TABLE  #temp_tbl_xls_settlement_new;
		