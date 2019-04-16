
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @importSQL  VARCHAR(MAX);
DECLARE @sqlQuery   VARCHAR(MAX);
DECLARE @startDate VARCHAR(30);
DECLARE @endDate VARCHAR(30);
DECLARE @database_name VARCHAR(255)
DECLARE @serverName VARCHAR(50);
DECLARE @tableName VARCHAR(50);
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
DECLARE @last_tran_nr  BIGINT
DECLARE @last_retrieval_reference_nr VARCHAR(15)
DECLARE @last_system_trace_audit_nr  VARCHAR(15)
DECLARE @last_recon_business_date DATETIME
DECLARE @last_online_system_id  INT
DECLARE @last_tran_postilion_originated INT
DECLARE @session_id INT
DECLARE @month CHAR(2);
DECLARE @archive_id INT

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

	SELECT @table_month_suffix_start = REPLACE(CONVERT(VARCHAR(6), @startDate,111),'/', '');
	SELECT @table_month_suffix_end = REPLACE(CONVERT(VARCHAR(6), @endDate,111),'/', '');
	-- get server and date range
	-- get partitioned table to insert data into based on date range
	-- run insert
	-- update session table to prevent copying duplicates
	-- update archive source table to reflect transaction copy
	
	DECLARE @table_name_table TABLE (tableName VARCHAR(255), table_month VARCHAR(6));

	IF (@table_month_suffix_start = @table_month_suffix_end) BEGIN 
			
			SET   @tableName  = 'post_tran_summary_'+@table_month_suffix_start;
			INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , @table_month_suffix_start);
			
			SET @month = RIGHT(@table_month_suffix_start,2)
			SELECT @fileGroup = CASE
									 WHEN @month='01' THEN  'JAN'
									 WHEN @month='02' THEN  'FEB'
									 WHEN @month='03' THEN  'MAR'
									 WHEN @month='04' THEN  'APR'
									 WHEN @month='05' THEN  'MAY'
									 WHEN @month='06' THEN  'JUN'
									 WHEN @month='07' THEN  'JUL'
									 WHEN @month='08' THEN  'AUG'
									 WHEN @month='09' THEN  'SEP'
									 WHEN @month='10' THEN  'OCT'
									 WHEN @month='11' THEN  'NOV'
									 WHEN @month='12' THEN  'DEC'
								 END
			SET   @sqlQuery =   'IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableName+']'') AND type in (N''U''))BEGIN
								CREATE TABLE [dbo].['+@tableName+'](
								[post_tran_id] [bigint] NOT NULL,
								[post_tran_cust_id] [bigint] NOT NULL,
								[settle_entity_id] [dbo].[POST_ID] NULL,
								[batch_nr] [int] NULL,
								[prev_post_tran_id] [bigint] NULL,
								[next_post_tran_id] [bigint] NULL,
								[sink_node_name] [dbo].[POST_NAME] NULL,
								[tran_postilion_originated] [dbo].[POST_BOOL] NOT NULL,
								[tran_completed] [dbo].[POST_BOOL] NOT NULL,
								[message_type] [char](4) NOT NULL,
								[tran_type] [char](2) NULL,
								[tran_nr] [bigint] NOT NULL,
								[system_trace_audit_nr] [char](6) NULL,
								[rsp_code_req] [char](2) NULL,
								[rsp_code_rsp] [char](2) NULL,
								[abort_rsp_code] [char](2) NULL,
								[auth_id_rsp] [varchar](10) NULL,
								[auth_type] [numeric](1, 0) NULL,
								[auth_reason] [numeric](1, 0) NULL,
								[retention_data] [varchar](999) NULL,
								[acquiring_inst_id_code] [varchar](11) NULL,
								[message_reason_code] [char](4) NULL,
								[sponsor_bank] [char](8) NULL,
								[retrieval_reference_nr] [char](12) NULL,
								[datetime_tran_gmt] [datetime] NULL,
								[datetime_tran_local] [datetime] NOT NULL,
								[datetime_req] [datetime] NOT NULL,
								[datetime_rsp] [datetime] NULL,
								[realtime_business_date] [datetime] NOT NULL,
								[recon_business_date] [datetime] NOT NULL,
								[from_account_type] [char](2) NULL,
								[to_account_type] [char](2) NULL,
								[from_account_id] [varchar](28) NULL,
								[to_account_id] [varchar](28) NULL,
								[tran_amount_req] [dbo].[POST_MONEY] NULL,
								[tran_amount_rsp] [dbo].[POST_MONEY] NULL,
								[settle_amount_impact] [dbo].[POST_MONEY] NULL,
								[tran_cash_req] [dbo].[POST_MONEY] NULL,
								[tran_cash_rsp] [dbo].[POST_MONEY] NULL,
								[tran_currency_code] [dbo].[POST_CURRENCY] NULL,
								[tran_tran_fee_req] [dbo].[POST_MONEY] NULL,
								[tran_tran_fee_rsp] [dbo].[POST_MONEY] NULL,
								[tran_tran_fee_currency_code] [dbo].[POST_CURRENCY] NULL,
								[tran_proc_fee_req] [dbo].[POST_MONEY] NULL,
								[tran_proc_fee_rsp] [dbo].[POST_MONEY] NULL,
								[tran_proc_fee_currency_code] [dbo].[POST_CURRENCY] NULL,
								[settle_amount_req] [dbo].[POST_MONEY] NULL,
								[settle_amount_rsp] [dbo].[POST_MONEY] NULL,
								[settle_cash_req] [dbo].[POST_MONEY] NULL,
								[settle_cash_rsp] [dbo].[POST_MONEY] NULL,
								[settle_tran_fee_req] [dbo].[POST_MONEY] NULL,
								[settle_tran_fee_rsp] [dbo].[POST_MONEY] NULL,
								[settle_proc_fee_req] [dbo].[POST_MONEY] NULL,
								[settle_proc_fee_rsp] [dbo].[POST_MONEY] NULL,
								[settle_currency_code] [dbo].[POST_CURRENCY] NULL,
								[pos_entry_mode] [char](3) NULL,
								[pos_condition_code] [char](2) NULL,
								[additional_rsp_data] [varchar](25) NULL,
								[tran_reversed] [char](1) NULL,
								[prev_tran_approved] [dbo].[POST_BOOL] NULL,
								[issuer_network_id] [varchar](11) NULL,
								[acquirer_network_id] [varchar](11) NULL,
								[extended_tran_type] [char](4) NULL,
								[ucaf_data] [varchar](33) NULL,
								[from_account_type_qualifier] [char](1) NULL,
								[to_account_type_qualifier] [char](1) NULL,
								[bank_details] [varchar](31) NULL,
								[payee] [char](25) NULL,
								[card_verification_result] [char](1) NULL,
								[online_system_id] [int] NULL,
								[participant_id] [int] NULL,
								[opp_participant_id] [int] NULL,
								[receiving_inst_id_code] [varchar](11) NULL,
								[routing_type] [int] NULL,
								[pt_pos_operating_environment] [char](1) NULL,
								[pt_pos_card_input_mode] [char](1) NULL,
								[pt_pos_cardholder_auth_method] [char](1) NULL,
								[pt_pos_pin_capture_ability] [char](1) NULL,
								[pt_pos_terminal_operator] [char](1) NULL,
								[source_node_key] [varchar](32) NULL,
								[proc_online_system_id] [int] NULL,
								[from_account_id_cs] [int] NULL,
								[to_account_id_cs] [int] NULL,
								[pos_geographic_data] [char](17) NULL,
								[payer_account_id] [varchar](28) NULL,
								[cvv_available_at_auth] [char](1) NULL,
								[cvv2_available_at_auth] [char](1) NULL,
								[mapped_terminal_id] [char](8) NULL,
								[mapped_extd_ca_term_id] [varchar](25) NULL,
								[mapped_extd_ca_id_code] [varchar](25) NULL,
								[network_program_id_actual] [varchar](8) NULL,
								[network_program_id_min] [varchar](8) NULL,
								[network_fee_actual] [numeric](16, 4) NULL,
								[network_fee_min] [numeric](16, 4) NULL,
								[network_fee_max] [numeric](16, 4) NULL,
								[credit_debit_conversion] [tinyint] NULL,
								[source_node_name] [dbo].[POST_NAME] NOT NULL,
								[draft_capture] [dbo].[POST_ID] NULL,
								[pan] [varchar](19) NULL,
								[card_seq_nr] [varchar](3) NULL,
								[expiry_date] [char](4) NULL,
								[service_restriction_code] [char](3) NULL,
								[terminal_id] [dbo].[POST_TERMINAL_ID] NULL,
								[terminal_owner] [varchar](25) NULL,
								[card_acceptor_id_code] [char](15) NULL,
								[mapped_card_acceptor_id_code] [char](15) NULL,
								[merchant_type] [char](4) NULL,
								[card_acceptor_name_loc] [char](40) NULL,
								[address_verification_data] [varchar](29) NULL,
								[address_verification_result] [char](1) NULL,
								[check_data] [varchar](70) NULL,
								[totals_group] [varchar](12) NULL,
								[card_product] [varchar](20) NULL,
								[pos_card_data_input_ability] [char](1) NULL,
								[pos_cardholder_auth_ability] [char](1) NULL,
								[pos_card_capture_ability] [char](1) NULL,
								[pos_operating_environment] [char](1) NULL,
								[pos_cardholder_present] [char](1) NULL,
								[pos_card_present] [char](1) NULL,
								[pos_card_data_input_mode] [char](1) NULL,
								[pos_cardholder_auth_method] [char](1) NULL,
								[pos_cardholder_auth_entity] [char](1) NULL,
								[pos_card_data_output_ability] [char](1) NULL,
								[pos_terminal_output_ability] [char](1) NULL,
								[pos_pin_capture_ability] [char](1) NULL,
								[pos_terminal_operator] [char](1) NULL,
								[pos_terminal_type] [char](2) NULL,
								[pan_search] [int] NULL,
								[pan_encrypted] [char](18) NULL,
								[pan_reference] [char](42) NULL,
								[card_acceptor_id_code_cs] [int] NULL
							) ON ['+@fileGroup+']

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [next_post_tran_id]

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [tran_reversed]

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [draft_capture]

							CREATE  CLUSTERED INDEX pk_post_tran_id ON ['+@tableName+'](
								post_tran_id 
							)ON ['+@fileGroup+'];


					/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE UNIQUE  NONCLUSTERED INDEX [ix_'+@tableName+'_14] ON [dbo].['+@tableName+'] 
					(
						[post_tran_id] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']




					/****** Object:  Index [ix_'+@tableName+'_2]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_2] ON [dbo].['+@tableName+'] 
					(
						[post_tran_cust_id] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


					/****** Object:  Index [ix_'+@tableName+'_3]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_3] ON [dbo].['+@tableName+'] 
					(
						[tran_nr] ASC, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



					/****** Object:  Index [ix_'+@tableName+'_7]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
					(
						[datetime_req] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

							
			END';
			exec sp_executesql @sqlQuery;
			
	 END
	 ELSE BEGIN
	 
		 DECLARE @table_month_suffix_current VARCHAR(10)
		 DECLARE @table_month_suffix_final VARCHAR(10)
		 SET @table_month_suffix_current = @table_month_suffix_start;
		 SET @table_month_suffix_current=@table_month_suffix_current+'01';
		 SET @table_month_suffix_final = @table_month_suffix_end+'01';
		 
	 WHILE (DATEDIFF(MONTH,@table_month_suffix_current,@table_month_suffix_final ) >=0) BEGIN
	 
			SET   @tableName  = 'post_tran_summary_'+LEFT(@table_month_suffix_start,6);
				INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , LEFT(@table_month_suffix_start,6));
			SET @month = RIGHT(@table_month_suffix_start,2)
			SELECT @fileGroup = CASE
									 WHEN @month='01' THEN  'JAN'
									 WHEN @month='02' THEN  'FEB'
									 WHEN @month='03' THEN  'MAR'
									 WHEN @month='04' THEN  'APR'
									 WHEN @month='05' THEN  'MAY'
									 WHEN @month='06' THEN  'JUN'
									 WHEN @month='07' THEN  'JUL'
									 WHEN @month='08' THEN  'AUG'
									 WHEN @month='09' THEN  'SEP'
									 WHEN @month='10' THEN  'OCT'
									 WHEN @month='11' THEN  'NOV'
									 WHEN @month='12' THEN  'DEC'
								 END
			SET   @sqlQuery =   'IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableName+']'') AND type in (N''U''))BEGIN
								CREATE TABLE [dbo].['+@tableName+'](
								[post_tran_id] [bigint] NOT NULL,
								[post_tran_cust_id] [bigint] NOT NULL,
								[settle_entity_id] [dbo].[POST_ID] NULL,
								[batch_nr] [int] NULL,
								[prev_post_tran_id] [bigint] NULL,
								[next_post_tran_id] [bigint] NULL,
								[sink_node_name] [dbo].[POST_NAME] NULL,
								[tran_postilion_originated] [dbo].[POST_BOOL] NOT NULL,
								[tran_completed] [dbo].[POST_BOOL] NOT NULL,
								[message_type] [char](4) NOT NULL,
								[tran_type] [char](2) NULL,
								[tran_nr] [bigint] NOT NULL,
								[system_trace_audit_nr] [char](6) NULL,
								[rsp_code_req] [char](2) NULL,
								[rsp_code_rsp] [char](2) NULL,
								[abort_rsp_code] [char](2) NULL,
								[auth_id_rsp] [varchar](10) NULL,
								[auth_type] [numeric](1, 0) NULL,
								[auth_reason] [numeric](1, 0) NULL,
								[retention_data] [varchar](999) NULL,
								[acquiring_inst_id_code] [varchar](11) NULL,
								[message_reason_code] [char](4) NULL,
								[sponsor_bank] [char](8) NULL,
								[retrieval_reference_nr] [char](12) NULL,
								[datetime_tran_gmt] [datetime] NULL,
								[datetime_tran_local] [datetime] NOT NULL,
								[datetime_req] [datetime] NOT NULL,
								[datetime_rsp] [datetime] NULL,
								[realtime_business_date] [datetime] NOT NULL,
								[recon_business_date] [datetime] NOT NULL,
								[from_account_type] [char](2) NULL,
								[to_account_type] [char](2) NULL,
								[from_account_id] [varchar](28) NULL,
								[to_account_id] [varchar](28) NULL,
								[tran_amount_req] [dbo].[POST_MONEY] NULL,
								[tran_amount_rsp] [dbo].[POST_MONEY] NULL,
								[settle_amount_impact] [dbo].[POST_MONEY] NULL,
								[tran_cash_req] [dbo].[POST_MONEY] NULL,
								[tran_cash_rsp] [dbo].[POST_MONEY] NULL,
								[tran_currency_code] [dbo].[POST_CURRENCY] NULL,
								[tran_tran_fee_req] [dbo].[POST_MONEY] NULL,
								[tran_tran_fee_rsp] [dbo].[POST_MONEY] NULL,
								[tran_tran_fee_currency_code] [dbo].[POST_CURRENCY] NULL,
								[tran_proc_fee_req] [dbo].[POST_MONEY] NULL,
								[tran_proc_fee_rsp] [dbo].[POST_MONEY] NULL,
								[tran_proc_fee_currency_code] [dbo].[POST_CURRENCY] NULL,
								[settle_amount_req] [dbo].[POST_MONEY] NULL,
								[settle_amount_rsp] [dbo].[POST_MONEY] NULL,
								[settle_cash_req] [dbo].[POST_MONEY] NULL,
								[settle_cash_rsp] [dbo].[POST_MONEY] NULL,
								[settle_tran_fee_req] [dbo].[POST_MONEY] NULL,
								[settle_tran_fee_rsp] [dbo].[POST_MONEY] NULL,
								[settle_proc_fee_req] [dbo].[POST_MONEY] NULL,
								[settle_proc_fee_rsp] [dbo].[POST_MONEY] NULL,
								[settle_currency_code] [dbo].[POST_CURRENCY] NULL,
								[pos_entry_mode] [char](3) NULL,
								[pos_condition_code] [char](2) NULL,
								[additional_rsp_data] [varchar](25) NULL,
								[tran_reversed] [char](1) NULL,
								[prev_tran_approved] [dbo].[POST_BOOL] NULL,
								[issuer_network_id] [varchar](11) NULL,
								[acquirer_network_id] [varchar](11) NULL,
								[extended_tran_type] [char](4) NULL,
								[ucaf_data] [varchar](33) NULL,
								[from_account_type_qualifier] [char](1) NULL,
								[to_account_type_qualifier] [char](1) NULL,
								[bank_details] [varchar](31) NULL,
								[payee] [char](25) NULL,
								[card_verification_result] [char](1) NULL,
								[online_system_id] [int] NULL,
								[participant_id] [int] NULL,
								[opp_participant_id] [int] NULL,
								[receiving_inst_id_code] [varchar](11) NULL,
								[routing_type] [int] NULL,
								[pt_pos_operating_environment] [char](1) NULL,
								[pt_pos_card_input_mode] [char](1) NULL,
								[pt_pos_cardholder_auth_method] [char](1) NULL,
								[pt_pos_pin_capture_ability] [char](1) NULL,
								[pt_pos_terminal_operator] [char](1) NULL,
								[source_node_key] [varchar](32) NULL,
								[proc_online_system_id] [int] NULL,
								[from_account_id_cs] [int] NULL,
								[to_account_id_cs] [int] NULL,
								[pos_geographic_data] [char](17) NULL,
								[payer_account_id] [varchar](28) NULL,
								[cvv_available_at_auth] [char](1) NULL,
								[cvv2_available_at_auth] [char](1) NULL,
								[mapped_terminal_id] [char](8) NULL,
								[mapped_extd_ca_term_id] [varchar](25) NULL,
								[mapped_extd_ca_id_code] [varchar](25) NULL,
								[network_program_id_actual] [varchar](8) NULL,
								[network_program_id_min] [varchar](8) NULL,
								[network_fee_actual] [numeric](16, 4) NULL,
								[network_fee_min] [numeric](16, 4) NULL,
								[network_fee_max] [numeric](16, 4) NULL,
								[credit_debit_conversion] [tinyint] NULL,
								[source_node_name] [dbo].[POST_NAME] NOT NULL,
								[draft_capture] [dbo].[POST_ID] NULL,
								[pan] [varchar](19) NULL,
								[card_seq_nr] [varchar](3) NULL,
								[expiry_date] [char](4) NULL,
								[service_restriction_code] [char](3) NULL,
								[terminal_id] [dbo].[POST_TERMINAL_ID] NULL,
								[terminal_owner] [varchar](25) NULL,
								[card_acceptor_id_code] [char](15) NULL,
								[mapped_card_acceptor_id_code] [char](15) NULL,
								[merchant_type] [char](4) NULL,
								[card_acceptor_name_loc] [char](40) NULL,
								[address_verification_data] [varchar](29) NULL,
								[address_verification_result] [char](1) NULL,
								[check_data] [varchar](70) NULL,
								[totals_group] [varchar](12) NULL,
								[card_product] [varchar](20) NULL,
								[pos_card_data_input_ability] [char](1) NULL,
								[pos_cardholder_auth_ability] [char](1) NULL,
								[pos_card_capture_ability] [char](1) NULL,
								[pos_operating_environment] [char](1) NULL,
								[pos_cardholder_present] [char](1) NULL,
								[pos_card_present] [char](1) NULL,
								[pos_card_data_input_mode] [char](1) NULL,
								[pos_cardholder_auth_method] [char](1) NULL,
								[pos_cardholder_auth_entity] [char](1) NULL,
								[pos_card_data_output_ability] [char](1) NULL,
								[pos_terminal_output_ability] [char](1) NULL,
								[pos_pin_capture_ability] [char](1) NULL,
								[pos_terminal_operator] [char](1) NULL,
								[pos_terminal_type] [char](2) NULL,
								[pan_search] [int] NULL,
								[pan_encrypted] [char](18) NULL,
								[pan_reference] [char](42) NULL,
								[card_acceptor_id_code_cs] [int] NULL
							) ON ['+@fileGroup+']

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [next_post_tran_id]

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [tran_reversed]

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [draft_capture]

							CREATE  CLUSTERED INDEX pk_post_tran_id ON ['+@tableName+'](
								post_tran_id 
							)ON ['+@fileGroup+']

						
						/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE UNIQUE  NONCLUSTERED INDEX [ix_'+@tableName+'_14] ON [dbo].['+@tableName+'] 
						(
							[post_tran_id] ASC, recon_business_date ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

						/****** Object:  Index [ix_'+@tableName+'_2]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_2] ON [dbo].['+@tableName+'] 
						(
							[post_tran_cust_id] ASC, recon_business_date ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

						/****** Object:  Index [ix_'+@tableName+'_3]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_3] ON [dbo].['+@tableName+'] 
						(
							[tran_nr] ASC, recon_business_date ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

						/****** Object:  Index [ix_'+@tableName+'_7]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
						(
							[datetime_req] ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


			END';
			exec sp_executesql @sqlQuery;
			
		  SET 	@table_month_suffix_current  = REPLACE(CONVERT(varchar(10),DATEADD(MONTH, 1,@table_month_suffix_current ), 111)		,'/', '');
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
		  FROM [postilion_office].[dbo].[post_tran_summary_session] (NOLOCK)
		  WHERE session_completed = 0  
		  ORDER BY [session_id]

		 EXEC ('SELECT post_tran_id  INTO ##temp_post_tran_id FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  WHERE recon_business_date ='+@last_recon_business_date+' AND tran_nr='+@last_tran_nr+' AND retrieval_reference_nr ='+@last_retrieval_reference_nr+' AND system_trace_audit_nr ='+@last_system_trace_audit_nr+' AND tran_postilion_originated ='+@last_tran_postilion_originated)
		 IF(OBJECT_ID('tempdb.dbo.##temp_post_tran_id') IS NOT NULL) BEGIN
		     SELECT @last_post_tran_id = ISNULL(post_tran_id,@last_post_tran_id)  FROM  ##temp_post_tran_id;
			 DROP TABLE ##temp_post_tran_id;
		  END

			 WHILE (DATEDIFF(D,@startDate, @endDate)>=0) BEGIN
							SELECT @tableName =tableName FROM @table_name_table WHERE  REPLACE(REPLACE(CONVERT(VARCHAR(6),table_month,111),'/', ''),'-', '')  = REPLACE(REPLACE(CONVERT(VARCHAR(6), @startDate,111),'/', ''),'-', '');
							SET @importSQL = 'SET ROWCOUNT '+@batchSize+'
								 ARCHIVE_TRAN_DATA:
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
								  ,[opp_participant_id]
								  ,[receiving_inst_id_code]
								  ,[routing_type]
								  ,[pt_pos_operating_environment]
								  ,[pt_pos_card_input_mode]
								  ,[pt_pos_cardholder_auth_method]
								  ,[pt_pos_pin_capture_ability]
								  ,[pt_pos_terminal_operator]
								  ,[source_node_key]
								  ,[proc_online_system_id]
								  ,[from_account_id_cs]
								  ,[to_account_id_cs]
								  ,[pos_geographic_data]
								  ,[payer_account_id]
								  ,[cvv_available_at_auth]
								  ,[cvv2_available_at_auth]
								  ,[mapped_terminal_id]
								  ,[mapped_extd_ca_term_id]
								  ,[mapped_extd_ca_id_code]
								  ,[network_program_id_actual]
								  ,[network_program_id_min]
								  ,[network_fee_actual]
								  ,[network_fee_min]
								  ,[network_fee_max]
								  ,[credit_debit_conversion]
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
								  ,[opp_participant_id]
								  ,[receiving_inst_id_code]
								  ,[routing_type]
								  ,[pt_pos_operating_environment]
								  ,[pt_pos_card_input_mode]
								  ,[pt_pos_cardholder_auth_method]
								  ,[pt_pos_pin_capture_ability]
								  ,[pt_pos_terminal_operator]
								  ,[source_node_key]
								  ,[proc_online_system_id]
								  ,[from_account_id_cs]
								  ,[to_account_id_cs]
								  ,[pos_geographic_data]
								  ,[payer_account_id]
								  ,[cvv_available_at_auth]
								  ,[cvv2_available_at_auth]
								  ,[mapped_terminal_id]
								  ,[mapped_extd_ca_term_id]
								  ,[mapped_extd_ca_id_code]
								  ,[network_program_id_actual]
								  ,[network_program_id_min]
								  ,[network_fee_actual]
								  ,[network_fee_min]
								  ,[network_fee_max]
								  ,[credit_debit_conversion]
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
							  FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  t
								   JOIN 
								   ['+@serverName+'].['+@database_name+'].[dbo].[post_tran_cust] c 
								   ON 
								   t.post_tran_cust_id = c.post_tran_cust_id
								   JOIN 
								   (SELECT [date] recon_business_date  FROM dbo.get_dates_from_range('+@startDate+','+@endDate+')) r
								   t.recon_business_date = r.recon_business_date
								   WHERE  post_tran_id >'+@last_post_tran_id+'
								  IF @@ROWCOUNT >0 GOTO ARCHIVE_TRAN_DATA
								  SET ROWCOUNT 0';
								  exec sp_executesql @importSQL;
								 EXEC ('SELECT COUNT(recon_business_date) rec_count  INTO ##remote_day_count FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  WHERE recon_business_date ='+@startDate)
								IF(OBJECT_ID('tempdb.dbo.##remote_day_count') IS NOT NULL) BEGIN
									SELECT @remote_day_count = ISNULL(rec_count,0)  FROM  ##remote_day_count;
									DROP TABLE ##remote_day_count;
								END

								EXEC ('SELECT COUNT(recon_business_date) rec_count  INTO ##archive_day_count FROM [postilion_office].[dbo].[post_tran](NOLOCK, INDEX(ix_post_tran_9))  WHERE recon_business_date ='+@startDate)
								IF(OBJECT_ID('tempdb.dbo.##archive_day_count') IS NOT NULL) BEGIN
									SELECT @archive_day_count = ISNULL(rec_count,0)  FROM  ##archive_day_count;
									DROP TABLE ##archive_day_count;
								END

								IF(@remote_day_count =@archive_day_count) BEGIN
								 
									SET  @sqlQuery = 'DECLARE @max_post_tran_id BIGINT
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
												FROM [postilion_office].[dbo].['+@tableName+'] (NOLOCK)
												WHERE post_tran_id =@max_post_tran_id;
      
												UPDATE  [postilion_office].[dbo].[post_tran_summary_session] SET 
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
												[postilion_office].[dbo].[post_tran_summary_session] sess
												JOIN
												##session_update_table upd
												ON
												sess.session_id = upd.session_id';
    
									EXEC sp_executesql @sqlQuery;

								END
								ELSE IF (@archive_day_count < @remote_day_count) BEGIN
								SELECT @tableName =tableName FROM @table_name_table WHERE  REPLACE(REPLACE(CONVERT(VARCHAR(6),table_month,111),'/', ''),'-', '')  = REPLACE(REPLACE(CONVERT(VARCHAR(6), @startDate,111),'/', ''),'-', '');
								SET @importSQL = 'SET ROWCOUNT '+@batchSize+';
								 ARCHIVE_TRAN_DATA_2:
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
								  ,[opp_participant_id]
								  ,[receiving_inst_id_code]
								  ,[routing_type]
								  ,[pt_pos_operating_environment]
								  ,[pt_pos_card_input_mode]
								  ,[pt_pos_cardholder_auth_method]
								  ,[pt_pos_pin_capture_ability]
								  ,[pt_pos_terminal_operator]
								  ,[source_node_key]
								  ,[proc_online_system_id]
								  ,[from_account_id_cs]
								  ,[to_account_id_cs]
								  ,[pos_geographic_data]
								  ,[payer_account_id]
								  ,[cvv_available_at_auth]
								  ,[cvv2_available_at_auth]
								  ,[mapped_terminal_id]
								  ,[mapped_extd_ca_term_id]
								  ,[mapped_extd_ca_id_code]
								  ,[network_program_id_actual]
								  ,[network_program_id_min]
								  ,[network_fee_actual]
								  ,[network_fee_min]
								  ,[network_fee_max]
								  ,[credit_debit_conversion]
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
								  ,[opp_participant_id]
								  ,[receiving_inst_id_code]
								  ,[routing_type]
								  ,[pt_pos_operating_environment]
								  ,[pt_pos_card_input_mode]
								  ,[pt_pos_cardholder_auth_method]
								  ,[pt_pos_pin_capture_ability]
								  ,[pt_pos_terminal_operator]
								  ,[source_node_key]
								  ,[proc_online_system_id]
								  ,[from_account_id_cs]
								  ,[to_account_id_cs]
								  ,[pos_geographic_data]
								  ,[payer_account_id]
								  ,[cvv_available_at_auth]
								  ,[cvv2_available_at_auth]
								  ,[mapped_terminal_id]
								  ,[mapped_extd_ca_term_id]
								  ,[mapped_extd_ca_id_code]
								  ,[network_program_id_actual]
								  ,[network_program_id_min]
								  ,[network_fee_actual]
								  ,[network_fee_min]
								  ,[network_fee_max]
								  ,[credit_debit_conversion]
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
							  FROM ['+@serverName+'].['+@database_name+'].[dbo].[post_tran]  t
								   JOIN 
								   ['+@serverName+'].['+@database_name+'].[dbo].[post_tran_cust] c 
								   ON 
								   t.post_tran_cust_id = c.post_tran_cust_id
								   JOIN 
								   (SELECT [date] recon_business_date  FROM dbo.get_dates_from_range('+@startDate+','+@endDate+')) r
								   t.recon_business_date = r.recon_business_date
								   WHERE  post_tran_id NOT IN  (SELECT post_tran_id FROM FROM [postilion_office].[dbo].[post_tran](NOLOCK, INDEX(ix_post_tran_9))  WHERE recon_business_date = '+@startDate+')
								  IF @@ROWCOUNT >0 GOTO ARCHIVE_TRAN_DATA_2
								  SET ROWCOUNT 0';
								 exec sp_executesql @importSQL;

								END
						SET @sqlQuery ='
								 
						/****** Object:  Index [ix_'+@tableName+'_1]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE UNIQUE  NONCLUSTERED INDEX [ix_'+@tableName+'_1] ON [dbo].['+@tableName+'] 
						(
							[post_tran_id] ASC, post_tran_cust_id, tran_nr,retrieval_reference_nr, system_trace_audit_nr, recon_business_date,datetime_tran_local ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']




						/****** Object:  Index [ix_'+@tableName+'_5]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_4] ON [dbo].['+@tableName+'] 
						(
							[system_trace_audit_nr] ASC, recon_business_date ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


						/****** Object:  Index [ix_'+@tableName+'_8]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE UNIQUE NONCLUSTERED INDEX [ix_'+@tableName+'_6] ON [dbo].['+@tableName+'] 
						(
							[tran_nr] ASC,
							[message_type] ASC,
							[tran_postilion_originated] ASC,
							[online_system_id] ASC,
							[recon_business_date] ASC,
							[tran_type] ASC,
							[terminal_id] ASC,
							[sink_node_name],
							[source_node_name],
							[tran_completed],
							[acquiring_inst_id_code],
							[card_acceptor_id_code],
							[totals_group]
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


						/****** Object:  Index [ix_'+@tableName+'_7]    Script Date: 05/16/2016 16:30:06 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_7] ON [dbo].['+@tableName+'] 
						(
							[recon_business_date] ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

						/****** Object:  Index [ix_'+@tableName+'_8]    Script Date: 05/16/2016 16:30:49 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_8] ON [dbo].['+@tableName+'] 
						(
							[pan] ASC,[recon_business_date] 
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


						/****** Object:  Index [ix_'+@tableName+'_9]    Script Date: 05/16/2016 16:30:49 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_9] ON [dbo].['+@tableName+'] 
						(
							[terminal_id] ASC,[recon_business_date] 
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

						/****** Object:  Index [ix_'+@tableName+'_10]    Script Date: 05/16/2016 16:30:49 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_10] ON [dbo].['+@tableName+'] 
						(
						[card_acceptor_id_code] ASC,[recon_business_date] 
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



						/****** Object:  Index [ix_'+@tableName+'_11]    Script Date: 05/16/2016 16:30:49 ******/
						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_11] ON [dbo].['+@tableName+'] 
						(
						[card_acceptor_name_loc] ASC,[recon_business_date] 
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_12] ON [dbo].['+@tableName+'] 
						(
						[retrieval_reference_nr] ASC, recon_business_date ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


						CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_13] ON [dbo].['+@tableName+'] 
						(
						[payee] ASC, recon_business_date ASC
						)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
						'
						exec sp_executesql @sqlQuery;
						SET  @startDate =DATEADD(D, 1,@startDate);
			END

END


