SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @importSQL  VARCHAR(MAX);
DECLARE @sqlQuery   VARCHAR(MAX);
DECLARE @startDate DATETIME;
DECLARE @endDate    DATETIME;
DECLARE @database_name VARCHAR(255)
DECLARE @serverName VARCHAR(50);
DECLARE @tableName VARCHAR(50);
DECLARE @tableNameTwo VARCHAR(50);
DECLARE @last_tran_date DATETIME;
DECLARE @table_month_suffix_start VARCHAR(50);
DECLARE @table_month_suffix_end VARCHAR(50);
DECLARE @fileGroup VARCHAR(5);
DECLARE @batchSize VARCHAR(50);
DECLARE @archive_day_count INT;
DECLARE @remote_day_count INT;
DECLARE @last_datetime_req DATETIME;
DECLARE @last_post_tran_id BIGINT;
DECLARE @last_post_tran_cust_id BIGINT;
DECLARE @last_tran_nr  BIGINT;
DECLARE @last_retrieval_reference_nr VARCHAR(15);
DECLARE @last_system_trace_audit_nr  VARCHAR(15);
DECLARE @last_recon_business_date DATETIME;
DECLARE @last_online_system_id  INT;
DECLARE @last_tran_postilion_originated INT;
DECLARE @session_id INT;
DECLARE @month CHAR(2);
DECLARE @archive_id INT;
DECLARE @table_month_suffix_current VARCHAR(10);
DECLARE @table_month_suffix_final VARCHAR(10);
DECLARE @last_sync_time datetime

		  SELECT TOP 1
			 @archive_id  = id
			,@serverName      = server_name
			,@database_name	  = database_name
			,@startDate       = start_date
			,@endDate		  = end_date
			,@last_tran_date  = ISNULL(last_tran_date, start_date)
			,@batchSize		  = batch_size
		FROM post_tran_archive_sources 
		WHERE  
			copy_complete =0
		ORDER BY id;

IF(@archive_id  IS NOT NULL ) BEGIN

			SELECT @table_month_suffix_start = REPLACE(CONVERT(VARCHAR(6), @startDate,112),'/', '');
			SELECT @table_month_suffix_end = REPLACE(CONVERT(VARCHAR(6), @endDate,112),'/', '');
			
			DECLARE @table_name_table TABLE (tableName VARCHAR(255), table_month VARCHAR(6));
			
			PRINT '@table_month_suffix_start: '+@table_month_suffix_start;
			PRINT '@table_month_suffix_end: '+@table_month_suffix_end;

			IF (@table_month_suffix_start = @table_month_suffix_end) BEGIN 	
				SET   @tableName     = 'post_tran_cust_arch_'+@table_month_suffix_start;
			    PRINT 'Inserting '+@tableName+' into table list'
				INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , @table_month_suffix_start)	
			END
			ELSE BEGIN
			
			SET @table_month_suffix_current=@table_month_suffix_start+'01';
			SET @table_month_suffix_final = @table_month_suffix_end+'01';
			PRINT '@table_month_suffix_current: '+@table_month_suffix_current;
			PRINT '@table_month_suffix_final: '+@table_month_suffix_final;
				
				WHILE (DATEDIFF(MONTH,@table_month_suffix_current,@table_month_suffix_final ) >0) BEGIN 
					SET   @tableName  = 'post_tran_cust_arch_'+LEFT(@table_month_suffix_start,6);
					PRINT 'Inserting '+@tableName+' into table list'
					
					INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , LEFT(@table_month_suffix_start,6));
					SET @month = RIGHT(@table_month_suffix_start,2)
					SET 	@table_month_suffix_current  = REPLACE(CONVERT(varchar(10),DATEADD(MONTH, 1,@table_month_suffix_current ), 112)		,'/', '');
				END	
			END

			DECLARE @session_completed INT 
			SELECT   
					@session_id                        = ISNULL([session_id],1)
					,@last_sync_time                   = ISNULL([last_sync_time],@startDate)
					,@last_post_tran_cust_id           = ISNULL([last_post_tran_cust_id],0)
					,@session_completed                = session_completed 
					FROM [postilion_office].[dbo].[post_tran_cust_archive_session] (NOLOCK)
			  WHERE session_completed = 0  
			  ORDER BY [session_id]

			  DECLARE table_cursor CURSOR LOCAL FORWARD_ONLY  STATIC READ_ONLY  FOR SELECT tableName FROM @table_name_table 
			  OPEN table_cursor
			  FETCH NEXT FROM table_cursor INTO @tableName
			  WHILE (@@FETCH_STATUS=0) BEGIN
				SET  @table_month_suffix_current  = RIGHT(@tableName,6);
  				SET  @startDate =  @table_month_suffix_current+'01';
				SET  @endDate   =   DATEADD(MONTH,1,@startDate);
			     PRINT '@startDate: '+convert(VARCHAR(30),@startDate, 112)
				 PRINT '@endDate: '+convert(VARCHAR(30),@endDate, 112)
				WHILE (DATEDIFF(D,@startDate, @endDate)>0) BEGIN
				   PRINT 'Copying data for '+CONVERT(VARCHAR(30), @startDate)												
								--EXEC ('SELECT post_tran_id, post_tran_cust_id  INTO ##temp_post_tran_id FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  WHERE recon_business_date ='+@last_recon_business_date+' AND tran_nr='+@last_tran_nr+' AND retrieval_reference_nr ='+@last_retrieval_reference_nr+' AND system_trace_audit_nr ='+@last_system_trace_audit_nr+' AND tran_postilion_originated ='+@last_tran_postilion_originated)
								set @sqlQuery=  ('DECLARE @max_post_tran_cust_id BIGINT;
									   SELECT  MAX(post_tran_cust_id) post_tran_cust_id  INTO   ##temp_post_tran_cust_id  FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  WHERE  recon_business_date = '''+CONVERT(VARCHAR(30),@startDate, 112)+''';
									
									   ');
								     print  @sqlQuery
									 exec (@sqlQuery)
								IF(OBJECT_ID('tempdb.dbo.##temp_post_tran_cust_id') IS NOT NULL) BEGIN
									SELECT  @last_post_tran_cust_id = ISNULL(post_tran_cust_id,@last_post_tran_cust_id) FROM  ##temp_post_tran_cust_id;
									DROP TABLE ##temp_post_tran_cust_id;
								END
								
								PRINT 'inserting data into '+@tableName+CHAR(10)
							    SET @sqlQuery = ' SET ROWCOUNT '+ CONVERT(VARCHAR(15),@batchSize)+'
								COPY_POST_TRAN_CUST:
								INSERT INTO ['+@tableName+'] (
													[post_tran_cust_id]
													,[source_node_name]
													,[draft_capture]
													,[pan]
													,[card_seq_nr]
													,[expiry_date]
													,[service_restriction_code]
													,[terminal_id]
													,[terminal_owner]
													,[card_acceptor_id_code]
													,[mapped_card_acceptor_id_code]
													,[merchant_type]
													,[card_acceptor_name_loc]
													,[address_verification_data]
													,[address_verification_result]
													,[check_data]
													,[totals_group]
													,[card_product]
													,[pos_card_data_input_ability]
													,[pos_cardholder_auth_ability]
													,[pos_card_capture_ability]
													,[pos_operating_environment]
													,[pos_cardholder_present]
													,[pos_card_present]
													,[pos_card_data_input_mode]
													,[pos_cardholder_auth_method]
													,[pos_cardholder_auth_entity]
													,[pos_card_data_output_ability]
													,[pos_terminal_output_ability]
													,[pos_pin_capture_ability]
													,[pos_terminal_operator]
													,[pos_terminal_type]
													,[pan_search]
													,[pan_encrypted]
													,[pan_reference]
													,[card_acceptor_id_code_cs]
								)
								SELECT 
												   [post_tran_cust_id]
												  ,[source_node_name]
												  ,[draft_capture]
												  ,[pan]
												  ,[card_seq_nr]
												  ,[expiry_date]
												  ,[service_restriction_code]
												  ,[terminal_id]
												  ,[terminal_owner]
												  ,[card_acceptor_id_code]
												  ,[mapped_card_acceptor_id_code]
												  ,[merchant_type]
												  ,[card_acceptor_name_loc]
												  ,[address_verification_data]
												  ,[address_verification_result]
												  ,[check_data]
												  ,[totals_group]
												  ,[card_product]
												  ,[pos_card_data_input_ability]
												  ,[pos_cardholder_auth_ability]
												  ,[pos_card_capture_ability]
												  ,[pos_operating_environment]
												  ,[pos_cardholder_present]
												  ,[pos_card_present]
												  ,[pos_card_data_input_mode]
												  ,[pos_cardholder_auth_method]
												  ,[pos_cardholder_auth_entity]
												  ,[pos_card_data_output_ability]
												  ,[pos_terminal_output_ability]
												  ,[pos_pin_capture_ability]
												  ,[pos_terminal_operator]
												  ,[pos_terminal_type]
												  ,[pan_search]
												  ,[pan_encrypted]
												  ,[pan_reference]
												  ,[card_acceptor_id_code_cs]
									   FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran_cust]  c
									   WHERE 
										post_tran_cust_id> (SELECT isnull(MAX(post_tran_cust_id ),0)  FROM ['+@tableName+'] ) 
										and
										 post_tran_cust_id <= '+ convert(VARCHAR(50),@last_post_tran_cust_id)+'
										ORDER BY post_tran_cust_id;
										IF @@ROWCOUNT >0 GOTO COPY_POST_TRAN_CUST
									     SET ROWCOUNT 0
										';
										print @sqlQuery
										 exec (@sqlQuery)

									set @sqlQuery = ('SELECT COUNT(post_tran_cust_id) rec_count  INTO ##remote_day_count FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  WHERE recon_business_date ='''+CONVERT(VARCHAR(30),@startDate, 112)+'''')
									print @sqlQuery
									 exec (@sqlQuery)
									IF(OBJECT_ID('tempdb.dbo.##remote_day_count') IS NOT NULL) BEGIN
										SELECT @remote_day_count = ISNULL(rec_count,0)  FROM  ##remote_day_count;
										DROP TABLE ##remote_day_count;
									END

									SET @sqlQuery = ('SELECT COUNT(post_tran_cust_id) rec_count  INTO ##archive_day_count FROM ['+@tableName+']  WHERE post_tran_cust_id   > (SELECT MIN(post_tran_cust_id) FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran] WHERE recon_business_date = '''+CONVERT(VARCHAR(30),@startDate, 112)+''') AND  post_tran_cust_id <= '+convert(VARCHAR(50),@last_post_tran_cust_id)+';')
									PRINT @sqlQuery
									 exec (@sqlQuery)

									IF(OBJECT_ID('tempdb.dbo.##archive_day_count') IS NOT NULL) BEGIN
										SELECT @archive_day_count = ISNULL(rec_count,0)  FROM  ##archive_day_count;
										DROP TABLE ##archive_day_count;
									END

									IF(@remote_day_count =@archive_day_count) BEGIN
									 
										Exec('DECLARE @max_post_tran_cust_id BIGINT;
											  SELECT @max_post_tran_cust_id  = MAX(post_tran_cust_id) FROM  ['+@tableName+'] (NOLOCK);
											  UPDATE  [postilion_office].[dbo].[post_tran_cust_archive_session] SET last_post_tran_cust_id = @max_post_tran_cust_id  
											  WHERE  session_id = '+ @session_id
											);
									END
									ELSE IF (@archive_day_count < @remote_day_count) BEGIN
									PRINT 'inserting data into '+@tableName+CHAR(10)
							        SET @sqlQuery = ' SET ROWCOUNT '+ CONVERT(VARCHAR(15),@batchSize)+'
								   COPY_POST_TRAN_CUST:
								   INSERT INTO ['+@tableName+'] (
																[post_tran_cust_id]
																,[source_node_name]
																,[draft_capture]
																,[pan]
																,[card_seq_nr]
																,[expiry_date]
																,[service_restriction_code]
																,[terminal_id]
																,[terminal_owner]
																,[card_acceptor_id_code]
																,[mapped_card_acceptor_id_code]
																,[merchant_type]
																,[card_acceptor_name_loc]
																,[address_verification_data]
																,[address_verification_result]
																,[check_data]
																,[totals_group]
																,[card_product]
																,[pos_card_data_input_ability]
																,[pos_cardholder_auth_ability]
																,[pos_card_capture_ability]
																,[pos_operating_environment]
																,[pos_cardholder_present]
																,[pos_card_present]
																,[pos_card_data_input_mode]
																,[pos_cardholder_auth_method]
																,[pos_cardholder_auth_entity]
																,[pos_card_data_output_ability]
																,[pos_terminal_output_ability]
																,[pos_pin_capture_ability]
																,[pos_terminal_operator]
																,[pos_terminal_type]
																,[pan_search]
																,[pan_encrypted]
																,[pan_reference]
																,[card_acceptor_id_code_cs]
											)
											SELECT 
															   [post_tran_cust_id]
															  ,[source_node_name]
															  ,[draft_capture]
															  ,[pan]
															  ,[card_seq_nr]
															  ,[expiry_date]
															  ,[service_restriction_code]
															  ,[terminal_id]
															  ,[terminal_owner]
															  ,[card_acceptor_id_code]
															  ,[mapped_card_acceptor_id_code]
															  ,[merchant_type]
															  ,[card_acceptor_name_loc]
															  ,[address_verification_data]
															  ,[address_verification_result]
															  ,[check_data]
															  ,[totals_group]
															  ,[card_product]
															  ,[pos_card_data_input_ability]
															  ,[pos_cardholder_auth_ability]
															  ,[pos_card_capture_ability]
															  ,[pos_operating_environment]
															  ,[pos_cardholder_present]
															  ,[pos_card_present]
															  ,[pos_card_data_input_mode]
															  ,[pos_cardholder_auth_method]
															  ,[pos_cardholder_auth_entity]
															  ,[pos_card_data_output_ability]
															  ,[pos_terminal_output_ability]
															  ,[pos_pin_capture_ability]
															  ,[pos_terminal_operator]
															  ,[pos_terminal_type]
															  ,[pan_search]
															  ,[pan_encrypted]
															  ,[pan_reference]
															  ,[card_acceptor_id_code_cs]
												   FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran_cust]  c
												   
												   WHERE  
												   post_tran_cust_id  NOT IN  (SELECT post_tran_cust_id FROM [dbo].['+@tableName+']  (nolock) )
												 and  post_tran_cust_id < '+  convert(VARCHAR(50),@last_post_tran_cust_id) +' AND
													post_tran_cust_id >( SELECT  MIN(post_tran_cust_id)  FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran] (NOLOCK)  WHERE recon_business_date = '''+CONVERT(VARCHAR(30),@startDate, 112)+''');
												IF @@ROWCOUNT >0 GOTO COPY_POST_TRAN_CUST
												SET ROWCOUNT 0
													'
													print @sqlQuery
													 exec (@sqlQuery)

			      END
									 
								   END
								   
								  EXEC( ' UPDATE [dbo].[post_tran_cust_archive_session] SET session_completed =1 WHERE  [session_id]='+@session_id+';
								          INSERT INTO [dbo].[post_tran_cust_archive_session](last_sync_time, last_post_tran_cust_id,session_completed ) VALUES (getdate(), 0, 0);');
			                      
				END
			CLOSE table_cursor
			DEALLOCATE table_cursor
		    SET @sqlQuery = 'DECLARE @remote_total_post_tran_id BIGINT
			DECLARE @remote_total_post_tran_cust_id BIGINT
			DECLARE @local_total_post_tran_id BIGINT
			DECLARE @local_total_post_tran_cust_id BIGINT
			SELECT  @remote_total_post_tran_id = COUNT(post_tran_id)  FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran] WHERE recon_business_date BETWEEN  '''+ CONVERT(varchar(10), @startDate, 112)+''' AND    '''+  CONVERT(varchar(10), @endDate, 112) +''';
			SELECT  @remote_total_post_tran_cust_id = COUNT(post_tran_cust_id)  FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran] WHERE recon_business_date BETWEEN  '''+ CONVERT(varchar(10), @startDate, 112)+''' AND    '''+CONVERT(varchar(10), @endDate, 112)+''';
			SELECT  @local_total_post_tran_id = COUNT (post_tran_id) FROM post_tran (NOLOCK) WHERE recon_business_date BETWEEN  '''+ CONVERT(varchar(10), @startDate, 112)+''' AND    '''+CONVERT(varchar(10), @endDate, 112)+''';
			SELECT  @local_total_post_tran_cust_id = COUNT (post_tran_cust_id) FROM post_tran (NOLOCK) WHERE recon_business_date BETWEEN  '''+ CONVERT(varchar(10), @startDate, 112)+''' AND    '''+CONVERT(varchar(10), @endDate, 112)+''';
		    IF(
		      (@local_total_post_tran_id = @remote_total_post_tran_id) 
		         AND 
		      (@local_total_post_tran_cust_id = @remote_total_post_tran_cust_id) 
		    ) BEGIN
		    UPDATE post_tran_archive_sources SET copy_complete =1 WHERE  id ='+ convert(varchar(100), @archive_id)+';
			END';
			print(@sqlQuery);
		   EXEC(  @sqlQuery);
		  END

