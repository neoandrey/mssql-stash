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
DECLARE @first_post_tran_id BIGINT;
DECLARE @last_post_tran_cust_id BIGINT;
DECLARE @last_post_tran_id INT
DECLARE @last_tran_nr  BIGINT
DECLARE @last_retrieval_reference_nr VARCHAR(15)
DECLARE @last_system_trace_audit_nr  VARCHAR(15)
DECLARE @last_recon_business_date DATETIME
DECLARE @last_online_system_id  INT
DECLARE @last_tran_postilion_originated INT
DECLARE @session_id INT
DECLARE @month CHAR(2);
DECLARE @archive_id INT;
DECLARE @table_month_suffix_current VARCHAR(10)
DECLARE @table_month_suffix_final VARCHAR(10);


		SELECT TOP 1
			 @archive_id  = id
			,@serverName      = server_name
			,@database_name	  = database_name
			,@startDate       = start_date
			,@endDate		  = end_date
			,@last_tran_date  = ISNULL(last_tran_date, start_date)
			,@batchSize		  = batch_size
		FROM post_tran_archive_sources  (nolock)
		WHERE  
			copy_complete =0 and is_table_created = 1
		ORDER BY id;

IF(@archive_id  IS NOT NULL ) BEGIN

			SELECT @table_month_suffix_start = REPLACE(CONVERT(VARCHAR(6), @startDate,112),'/', '');
			SELECT @table_month_suffix_end = REPLACE(CONVERT(VARCHAR(6), @endDate,112),'/', '');	
			DECLARE @table_name_table TABLE (tableName VARCHAR(255), table_month VARCHAR(6));
			PRINT '@table_month_suffix_start: '+@table_month_suffix_start;
			PRINT '@table_month_suffix_end: '+@table_month_suffix_end;

			IF (@table_month_suffix_start = @table_month_suffix_end) BEGIN 	
				SET   @tableName     = 'post_tran_arch_'+@table_month_suffix_start;
				PRINT 'Inserting '+@tableName+' into table list'
				INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , @table_month_suffix_start)	
			END
			ELSE BEGIN

				SET @table_month_suffix_current =@table_month_suffix_start+'01';
				SET @table_month_suffix_final = @table_month_suffix_end+'01';
				PRINT '@table_month_suffix_current: '+@table_month_suffix_current;
				PRINT '@table_month_suffix_final: '+@table_month_suffix_final;

			    WHILE (DATEDIFF(MONTH,@table_month_suffix_current,@table_month_suffix_final ) >0) BEGIN 
				    SET   @tableName  = 'post_tran_arch_'+LEFT(@table_month_suffix_start,6);

				PRINT 'Inserting '+@tableName+' into table list'
				INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , LEFT(@table_month_suffix_start,6));
				SET @month = RIGHT(@table_month_suffix_start,2)
				SET 	@table_month_suffix_current  = REPLACE(CONVERT(varchar(10),DATEADD(MONTH, 1,@table_month_suffix_current ), 112)		,'/', '');
			END	
			END

			DECLARE @session_completed INT 
				SELECT   
					@session_id                      = ISNULL([session_id],1)
				   ,@last_datetime_req               = ISNULL([last_datetime_req],@startDate)
				   ,@last_post_tran_id               = ISNULL([last_post_tran_id],0)
				   ,@last_post_tran_cust_id          = ISNULL([last_post_tran_cust_id],0)
				   ,@last_tran_nr                    = ISNULL([last_tran_nr],0)
				   ,@last_retrieval_reference_nr     = ISNULL([last_retrieval_reference_nr],'')
				   ,@last_system_trace_audit_nr      = ISNULL([last_system_trace_audit_nr],'')
				   ,@last_recon_business_date        = ISNULL([last_recon_business_date],@startDate)
				   ,@last_online_system_id	         = ISNULL([last_online_system_id],0)
				   ,@last_tran_postilion_originated  = ISNULL([last_tran_postilion_originated],0)
				   ,@session_completed = session_completed 
			  FROM [postilion_office].[dbo].[post_tran_archive_session] (NOLOCK)
			  WHERE session_completed = 0  
			  ORDER BY [session_id]

			  DECLARE table_cursor CURSOR LOCAL FORWARD_ONLY  STATIC READ_ONLY  FOR SELECT tableName FROM @table_name_table 
			  OPEN table_cursor
			  FETCH NEXT FROM table_cursor INTO @tableName
			  PRINT 'Fetching  '+@tableName+' from table list'
			  WHILE (@@FETCH_STATUS=0) BEGIN

				SET  @table_month_suffix_current  = RIGHT(@tableName,6);
  				SET  @startDate =  @table_month_suffix_current+'01';
				SET  @endDate   =   DATEADD(MONTH,1,@startDate);
			    
				WHILE (DATEDIFF(D,@startDate, @endDate)>0) BEGIN
				                PRINT 'Copying data for '+CONVERT(VARCHAR(30), 		@startDate)	
												
								set @sqlQuery= ('SELECT post_tran_id, post_tran_cust_id  INTO ##temp_post_tran_id FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  WHERE recon_business_date ='+ CONVERT(VARCHAR(30),@last_recon_business_date, 112)+' AND tran_nr='+CONVERT(VARCHAR(30),@last_tran_nr)+' AND retrieval_reference_nr ='+CONVERT(VARCHAR(30),@last_retrieval_reference_nr)+' AND system_trace_audit_nr ='+CONVERT(VARCHAR(30),@last_system_trace_audit_nr)+' AND tran_postilion_originated ='+CONVERT(VARCHAR(30), @last_tran_postilion_originated))
								PRINT @sqlQuery;
								EXEC (@sqlQuery);
								SET  @first_post_tran_id =0
							  IF(OBJECT_ID('tempdb.dbo.##temp_post_tran_id') IS  NULL) BEGIN
								
									IF (@first_post_tran_id IS NULL OR @first_post_tran_id =0) BEGIN
									 			   		  SET @sqlQuery= '
								                               INSERT INTO  [postilion_office].[dbo].[post_tran_archive_session](  [last_datetime_req]
															  ,[last_post_tran_id]
															  ,[last_post_tran_cust_id]
															  ,[last_tran_nr]
															  ,[last_retrieval_reference_nr]
															  ,[last_system_trace_audit_nr]
															  ,[last_recon_business_date]
															  ,[last_online_system_id]
															  ,[last_tran_postilion_originated]
															  ,[session_completed]
															  ) VALUES ('''+ CONVERT(VARCHAR(30),@startDate, 112)+''',0, 0, 0, '''', '''','''+ CONVERT(VARCHAR(30),@startDate, 112)+''',0,0,0 );';
			                         print @sqlQuery
									 exec( @sqlQuery)

									END
									ELSE BEGIN
										SELECT  @first_post_tran_id = ISNULL(post_tran_id,@first_post_tran_id) FROM  ##temp_post_tran_id;
										DROP TABLE ##temp_post_tran_id; 
									END
									
								END
								/*
								print ('DECLARE @max_post_tran_id BIGINT
									    SELECT MAX(post_tran_id)  post_tran_id INTO ##temp_post_tran_id_2 FROM   ['+@serverName+'].['+@database_name+'].[dbo].[post_tran] WHERE recon_business_date = '''+ CONVERT(VARCHAR(30),@startDate, 112)+''' ;
									   ');
								
								EXEC ('DECLARE @max_post_tran_id BIGINT
									    SELECT MAX(post_tran_id) post_tran_id INTO ##temp_post_tran_id_2 FROM   ['+@serverName+'].['+@database_name+'].[dbo].[post_tran] WHERE recon_business_date ='''+ @startDate+''' ;
									   ');

								IF(OBJECT_ID('tempdb.dbo.##temp_post_tran_id_2') IS NOT NULL) BEGIN
									SELECT  @last_post_tran_id = ISNULL(post_tran_id,@last_post_tran_id) FROM  ##temp_post_tran_id_2;
									DROP TABLE ##temp_post_tran_id;
								END
								*/

								print  '@startDate: '+ CONVERT( VARCHAR(30), @startDate , 112)
								print  '@first_post_tran_id: '+CONVERT( VARCHAR(30),@first_post_tran_id)
								print  '@last_post_tran_id: '+CONVERT( VARCHAR(30),@last_post_tran_id)
								print  '@last_post_tran_cust_id: '+CONVERT( VARCHAR(30),@last_post_tran_cust_id)
								print  '@last_tran_postilion_originated: '+CONVERT( VARCHAR(30),@last_tran_postilion_originated)


								PRINT 'inserting data into '+@tableName+CHAR(10)
							    SET @sqlQuery = ' SET ROWCOUNT '+ CONVERT(VARCHAR(15),@batchSize)+'
								COPY_POST_TRAN:
								INSERT INTO ['+@tableName+'] (
											[post_tran_id]
											,[post_tran_cust_id]
											,[settle_entity_id]
											,[batch_nr]
											,[prev_post_tran_id]
											,[next_post_tran_id]
											,[sink_node_name]
											,[tran_postilion_originated]
											,[tran_completed]
											,[message_type]
											,[tran_type]
											,[tran_nr]
											,[system_trace_audit_nr]
											,[rsp_code_req]
											,[rsp_code_rsp]
											,[abort_rsp_code]
											,[auth_id_rsp]
											,[auth_type]
											,[auth_reason]
											,[retention_data]
											,[acquiring_inst_id_code]
											,[message_reason_code]
											,[sponsor_bank]
											,[retrieval_reference_nr]
											,[datetime_tran_gmt]
											,[datetime_tran_local]
											,[datetime_req]
											,[datetime_rsp]
											,[realtime_business_date]
											,[recon_business_date]
											,[from_account_type]
											,[to_account_type]
											,[from_account_id]
											,[to_account_id]
											,[tran_amount_req]
											,[tran_amount_rsp]
											,[settle_amount_impact]
											,[tran_cash_req]
											,[tran_cash_rsp]
											,[tran_currency_code]
											,[tran_tran_fee_req]
											,[tran_tran_fee_rsp]
											,[tran_tran_fee_currency_code]
											,[tran_proc_fee_req]
											,[tran_proc_fee_rsp]
											,[tran_proc_fee_currency_code]
											,[settle_amount_req]
											,[settle_amount_rsp]
											,[settle_cash_req]
											,[settle_cash_rsp]
											,[settle_tran_fee_req]
											,[settle_tran_fee_rsp]
											,[settle_proc_fee_req]
											,[settle_proc_fee_rsp]
											,[settle_currency_code]
											,[pos_entry_mode]
											,[pos_condition_code]
											,[additional_rsp_data]
											,[tran_reversed]
											,[prev_tran_approved]
											,[issuer_network_id]
											,[acquirer_network_id]
											,[extended_tran_type]
											,[ucaf_data]
											,[from_account_type_qualifier]
											,[to_account_type_qualifier]
											,[bank_details]
											,[payee]
											,[card_verification_result]
											,[online_system_id]
											,[participant_id]
											,[receiving_inst_id_code]
											,[routing_type]
											,[pt_pos_operating_environment]
											,[pt_pos_card_input_mode]
											,[pt_pos_cardholder_auth_method]
											,[pt_pos_pin_capture_ability]
											,[pt_pos_terminal_operator]
											,[source_node_key]
											,[proc_online_system_id]
											,[opp_participant_id]
											,[pos_geographic_data]
											,[payer_account_id]
								)
								SELECT [post_tran_id]
										,[post_tran_cust_id]
										,[settle_entity_id]
										,[batch_nr]
										,[prev_post_tran_id]
										,[next_post_tran_id]
										,[sink_node_name]
										,[tran_postilion_originated]
										,[tran_completed]
										,[message_type]
										,[tran_type]
										,[tran_nr]
										,[system_trace_audit_nr]
										,[rsp_code_req]
										,[rsp_code_rsp]
										,[abort_rsp_code]
										,[auth_id_rsp]
										,[auth_type]
										,[auth_reason]
										,[retention_data]
										,[acquiring_inst_id_code]
										,[message_reason_code]
										,[sponsor_bank]
										,[retrieval_reference_nr]
										,[datetime_tran_gmt]
										,[datetime_tran_local]
										,[datetime_req]
										,[datetime_rsp]
										,[realtime_business_date]
										,[recon_business_date]
										,[from_account_type]
										,[to_account_type]
										,[from_account_id]
										,[to_account_id]
										,[tran_amount_req]
										,[tran_amount_rsp]
										,[settle_amount_impact]
										,[tran_cash_req]
										,[tran_cash_rsp]
										,[tran_currency_code]
										,[tran_tran_fee_req]
										,[tran_tran_fee_rsp]
										,[tran_tran_fee_currency_code]
										,[tran_proc_fee_req]
										,[tran_proc_fee_rsp]
										,[tran_proc_fee_currency_code]
										,[settle_amount_req]
										,[settle_amount_rsp]
										,[settle_cash_req]
										,[settle_cash_rsp]
										,[settle_tran_fee_req]
										,[settle_tran_fee_rsp]
										,[settle_proc_fee_req]
										,[settle_proc_fee_rsp]
										,[settle_currency_code]
										,[pos_entry_mode]
										,[pos_condition_code]
										,[additional_rsp_data]
										,[tran_reversed]
										,[prev_tran_approved]
										,[issuer_network_id]
										,[acquirer_network_id]
										,[extended_tran_type]
										,[ucaf_data]
										,[from_account_type_qualifier]
										,[to_account_type_qualifier]
										,[bank_details]
										,[payee]
										,[card_verification_result]
										,[online_system_id]
										,[participant_id]
										,[receiving_inst_id_code]
										,[routing_type]
										,[pt_pos_operating_environment]
										,[pt_pos_card_input_mode]
										,[pt_pos_cardholder_auth_method]
										,[pt_pos_pin_capture_ability]
										,[pt_pos_terminal_operator]
										,[source_node_key]
										,[proc_online_system_id]
										,[opp_participant_id]
										,[pos_geographic_data]
										,[payer_account_id]
									   FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  t
									   WHERE  recon_business_date =  CONVERT(DATETIME,'''+CONVERT(VARCHAR(30),@startDate, 112)+''') AND  post_tran_id > (SELECT MAX(post_tran_id) FROM ['+@tableName+'])
									   AND ( post_tran_id > '+CONVERT(VARCHAR(30),@first_post_tran_id)+'
									  -- AND  post_tran_id <= '+CONVERT(VARCHAR(30),@last_post_tran_id)+'
									    )
									   ORDER BY post_tran_id;
									IF @@ROWCOUNT >0 GOTO COPY_POST_TRAN
									SET ROWCOUNT 0
										 ';
										print @sqlQuery;
										exec (@sqlQuery);

									EXEC ('SELECT COUNT(recon_business_date) rec_count  INTO ##remote_day_count FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  WHERE recon_business_date ='''+@startDate+'''')
									IF(OBJECT_ID('tempdb.dbo.##remote_day_count') IS NOT NULL) BEGIN
										SELECT @remote_day_count = ISNULL(rec_count,0)  FROM  ##remote_day_count;
										DROP TABLE ##remote_day_count;
									END

									EXEC ('SELECT COUNT(recon_business_date) rec_count  INTO ##archive_day_count FROM [postilion_office].[dbo].['+@tableName+']  WHERE recon_business_date  ='''+@startDate+'''')
									IF(OBJECT_ID('tempdb.dbo.##archive_day_count') IS NOT NULL) BEGIN
										SELECT @archive_day_count = ISNULL(rec_count,0)  FROM  ##archive_day_count;
										DROP TABLE ##archive_day_count;
									END
									
									IF(@remote_day_count =@archive_day_count) BEGIN
									 
									set @sqlQuery = ('DECLARE @max_post_tran_id BIGINT;
													  SELECT @max_post_tran_id  = MAX(post_tran_id) FROM [postilion_office].[dbo].['+@tableName+'] (NOLOCK);
													  SELECT   
															last_datetime_req            
															,last_post_tran_id     
															,last_post_tran_cust_id      
															,last_tran_nr                    
															,last_retrieval_reference_nr     
															,last_system_trace_audit_nr      
															,last_recon_business_date        
															,last_online_system_id	     
															,last_tran_postilion_originated  
															,'+@session_id+' session_id
															INTO ##session_update_table
													 FROM  ['+@tableName+'] (NOLOCK)
													 WHERE post_tran_id =@max_post_tran_id;

													UPDATE  [postilion_office].[dbo].[post_tran_archive_session] SET 
													last_datetime_req   =upd.last_datetime_req           
													,last_post_tran_id =upd.last_post_tran_id     
													,last_post_tran_cust_id  =    upd.last_post_tran_cust_id  
													,last_tran_nr       =     upd.last_tran_nr          
													,last_retrieval_reference_nr    =  upd.last_retrieval_reference_nr  
													,last_system_trace_audit_nr    =  upd.last_system_trace_audit_nr  
													,last_recon_business_date    =  upd.last_recon_business_date  
													,last_online_system_id	  =  upd.last_online_system_id  
													,last_tran_postilion_originated   =upd.last_tran_postilion_originated
													FROM 
													   [postilion_office].[dbo].[post_tran_archive_session] sess
													JOIN
													##session_update_table upd
													ON
													sess.session_id = upd.session_id 
													WHERE sess.session_id = '+CONVERT(VARCHAR(20),@session_id)+';
													DROP TABLE ##session_update_table
													');
													PRINT (@sqlQuery);
													EXEC (@sqlQuery);
									END
									ELSE IF (@archive_day_count < @remote_day_count) BEGIN
								 PRINT 'Inserting into '+@tableName+CHAR(10)	
								    SET @sqlQuery = ' SET ROWCOUNT '+ CONVERT(VARCHAR(15),@batchSize)+'
								COPY_POST_TRAN:
								    INSERT INTO ['+@tableName+'] (
											[post_tran_id]
											,[post_tran_cust_id]
											,[settle_entity_id]
											,[batch_nr]
											,[prev_post_tran_id]
											,[next_post_tran_id]
											,[sink_node_name]
											,[tran_postilion_originated]
											,[tran_completed]
											,[message_type]
											,[tran_type]
											,[tran_nr]
											,[system_trace_audit_nr]
											,[rsp_code_req]
											,[rsp_code_rsp]
											,[abort_rsp_code]
											,[auth_id_rsp]
											,[auth_type]
											,[auth_reason]
											,[retention_data]
											,[acquiring_inst_id_code]
											,[message_reason_code]
											,[sponsor_bank]
											,[retrieval_reference_nr]
											,[datetime_tran_gmt]
											,[datetime_tran_local]
											,[datetime_req]
											,[datetime_rsp]
											,[realtime_business_date]
											,[recon_business_date]
											,[from_account_type]
											,[to_account_type]
											,[from_account_id]
											,[to_account_id]
											,[tran_amount_req]
											,[tran_amount_rsp]
											,[settle_amount_impact]
											,[tran_cash_req]
											,[tran_cash_rsp]
											,[tran_currency_code]
											,[tran_tran_fee_req]
											,[tran_tran_fee_rsp]
											,[tran_tran_fee_currency_code]
											,[tran_proc_fee_req]
											,[tran_proc_fee_rsp]
											,[tran_proc_fee_currency_code]
											,[settle_amount_req]
											,[settle_amount_rsp]
											,[settle_cash_req]
											,[settle_cash_rsp]
											,[settle_tran_fee_req]
											,[settle_tran_fee_rsp]
											,[settle_proc_fee_req]
											,[settle_proc_fee_rsp]
											,[settle_currency_code]
											,[pos_entry_mode]
											,[pos_condition_code]
											,[additional_rsp_data]
											,[tran_reversed]
											,[prev_tran_approved]
											,[issuer_network_id]
											,[acquirer_network_id]
											,[extended_tran_type]
											,[ucaf_data]
											,[from_account_type_qualifier]
											,[to_account_type_qualifier]
											,[bank_details]
											,[payee]
											,[card_verification_result]
											,[online_system_id]
											,[participant_id]
											,[receiving_inst_id_code]
											,[routing_type]
											,[pt_pos_operating_environment]
											,[pt_pos_card_input_mode]
											,[pt_pos_cardholder_auth_method]
											,[pt_pos_pin_capture_ability]
											,[pt_pos_terminal_operator]
											,[source_node_key]
											,[proc_online_system_id]
											,[opp_participant_id]
											,[pos_geographic_data]
											,[payer_account_id]
								)
								SELECT [post_tran_id]
										,[post_tran_cust_id]
										,[settle_entity_id]
										,[batch_nr]
										,[prev_post_tran_id]
										,[next_post_tran_id]
										,[sink_node_name]
										,[tran_postilion_originated]
										,[tran_completed]
										,[message_type]
										,[tran_type]
										,[tran_nr]
										,[system_trace_audit_nr]
										,[rsp_code_req]
										,[rsp_code_rsp]
										,[abort_rsp_code]
										,[auth_id_rsp]
										,[auth_type]
										,[auth_reason]
										,[retention_data]
										,[acquiring_inst_id_code]
										,[message_reason_code]
										,[sponsor_bank]
										,[retrieval_reference_nr]
										,[datetime_tran_gmt]
										,[datetime_tran_local]
										,[datetime_req]
										,[datetime_rsp]
										,[realtime_business_date]
										,[recon_business_date]
										,[from_account_type]
										,[to_account_type]
										,[from_account_id]
										,[to_account_id]
										,[tran_amount_req]
										,[tran_amount_rsp]
										,[settle_amount_impact]
										,[tran_cash_req]
										,[tran_cash_rsp]
										,[tran_currency_code]
										,[tran_tran_fee_req]
										,[tran_tran_fee_rsp]
										,[tran_tran_fee_currency_code]
										,[tran_proc_fee_req]
										,[tran_proc_fee_rsp]
										,[tran_proc_fee_currency_code]
										,[settle_amount_req]
										,[settle_amount_rsp]
										,[settle_cash_req]
										,[settle_cash_rsp]
										,[settle_tran_fee_req]
										,[settle_tran_fee_rsp]
										,[settle_proc_fee_req]
										,[settle_proc_fee_rsp]
										,[settle_currency_code]
										,[pos_entry_mode]
										,[pos_condition_code]
										,[additional_rsp_data]
										,[tran_reversed]
										,[prev_tran_approved]
										,[issuer_network_id]
										,[acquirer_network_id]
										,[extended_tran_type]
										,[ucaf_data]
										,[from_account_type_qualifier]
										,[to_account_type_qualifier]
										,[bank_details]
										,[payee]
										,[card_verification_result]
										,[online_system_id]
										,[participant_id]
										,[receiving_inst_id_code]
										,[routing_type]
										,[pt_pos_operating_environment]
										,[pt_pos_card_input_mode]
										,[pt_pos_cardholder_auth_method]
										,[pt_pos_pin_capture_ability]
										,[pt_pos_terminal_operator]
										,[source_node_key]
										,[proc_online_system_id]
										,[opp_participant_id]
										,[pos_geographic_data]
										,[payer_account_id]
									   FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  t
									   WHERE  recon_business_date =  CONVERT(DATETIME,'''+CONVERT(VARCHAR(30),@startDate, 112)+''') AND
										post_tran_id NOT IN  (SELECT post_tran_id FROM ['+@tableName+'] (NOLOCK)  WHERE recon_business_date = '''+CONVERT(VARCHAR(30),@startDate, 112)+''');
										
										IF @@ROWCOUNT >0 GOTO COPY_POST_TRAN
								   SET ROWCOUNT 0
										 ';
										PRINT @sqlQuery;
										EXEC (@sqlQuery);
			            
							 END
									  set  @startDate  =DATEADD(D,1, @startDate); 
								   END
								   		  SET @sqlQuery= ' UPDATE  [postilion_office].[dbo].[post_tran_archive_session] SET session_completed =1 WHERE  [session_id]='+@session_id+';
								                 INSERT INTO  [postilion_office].[dbo].[post_tran_archive_session] (  [last_datetime_req]
															  ,[last_post_tran_id]
															  ,[last_post_tran_cust_id]
															  ,[last_tran_nr]
															  ,[last_retrieval_reference_nr]
															  ,[last_system_trace_audit_nr]
															  ,[last_recon_business_date]
															  ,[last_online_system_id]
															  ,[last_tran_postilion_originated]
															  ,[session_completed]
															  ) VALUES ('''+ CONVERT(VARCHAR(30),@startDate, 112)+''',0, 0, 0, '''', '''','''+ CONVERT(VARCHAR(30),@startDate, 112)+''',0,0,0 );';
			                         print @sqlQuery
									 exec( @sqlQuery)

				END
			CLOSE table_cursor
			DEALLOCATE table_cursor
			set @sqlQuery = 'DECLARE @remote_total_post_tran_id BIGINT
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