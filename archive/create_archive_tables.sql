
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @startDate DATETIME;
DECLARE @endDate DATETIME;
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
DECLARE @last_tran_nr  BIGINT
DECLARE @last_retrieval_reference_nr VARCHAR(15)
DECLARE @last_system_trace_audit_nr  VARCHAR(15)
DECLARE @last_recon_business_date DATETIME
DECLARE @last_online_system_id  INT
DECLARE @last_tran_postilion_originated INT
DECLARE @session_id INT
DECLARE @month CHAR(2);
DECLARE @archive_id INT;
DECLARE @is_table_created INT


	SELECT TOP 1
		 @archive_id       = id
		,@serverName       = server_name
		,@database_name	   = database_name
		,@startDate        = start_date
		,@endDate		   = end_date
		,@last_tran_date   = ISNULL(last_tran_date, start_date)
		,@batchSize		   = batch_size
		,@is_table_created =is_table_created 
	FROM  [postilion_office_old].dbo.post_tran_archive_sources 
	WHERE  
		copy_complete =0
	ORDER BY id;
IF NOT EXISTS (SELECT SRVID FROM sys.sysservers WHERE srvname =@serverName )
BEGIN
DECLARE @errorMessage VARCHAR(MAX)
  
   set @errorMessage ='There is no linked server for: '+@serverName+'. Please add a linked server for '+@serverName+' and rerun the job. Setting  server to '+@@servername; 
    print(@errorMessage);
  RAISERROR (@errorMessage, 16,  1 );
END
DECLARE @table_name_table TABLE (tableName VARCHAR(255), table_month VARCHAR(6));

IF(@archive_id  IS NOT NULL  AND (@is_table_created IS NULL  OR @is_table_created =0) ) BEGIN

	SELECT @table_month_suffix_start = REPLACE(CONVERT(VARCHAR(6), @startDate,112),'/', '');
	SELECT @table_month_suffix_end = REPLACE(CONVERT(VARCHAR(6), @endDate,112),'/', '')	

	IF (@table_month_suffix_start = @table_month_suffix_end) BEGIN 
			
			SET   @tableName     = 'post_tran_arch_'+@table_month_suffix_start;
			SET   @tableNameTwo  = 'post_tran_arch_cust_'+@table_month_suffix_start;
			
			SET @month = SUBSTRING(@table_month_suffix_current,5,2)
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

        PRINT 'Creating table '+@tableName+char(10);
		PRINT 'Creating table '+@tableNameTwo+char(10);

		EXEC('IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableName+']'') AND type in (N''U''))BEGIN
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
										[pos_geographic_data] [varchar](20) NULL,
										[payer_account_id] [varchar](30) NULL,
										[cvv_available_at_auth] [varchar](30) NULL,
										[cvv2_available_at_auth] [varchar](30) NULL,
										[mapped_terminal_id] [char](8) NULL,
										[mapped_extd_ca_term_id] [varchar](25) NULL,
										[mapped_extd_ca_id_code] [varchar](25) NULL,
										[network_program_id_actual] [varchar](8) NULL,
										[network_program_id_min] [varchar](8) NULL,
										[network_fee_actual] [numeric](9, 0) NULL,
										[network_fee_min] [numeric](9, 0) NULL,
										[network_fee_max] [numeric](9, 0) NULL,
										[credit_debit_conversion] [tinyint] NULL
							) ON ['+@fileGroup+']
							
							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [next_post_tran_id]

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [tran_reversed]

							CREATE  CLUSTERED INDEX pk_'+@tableName+' ON ['+@tableName+'](
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


					/****** Object:  Index [ix_'+@tableName+'_4]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_4] ON [dbo].['+@tableName+'] 
					(
					 post_tran_cust_id, post_tran_id, datetime_req, retrieval_reference_nr, system_trace_audit_nr, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


					/****** Object:  Index [ix_'+@tableName+'_5]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
					(
						[datetime_req] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					/****** Object:  Index [ix_'+@tableName+'_6]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_6] ON [dbo].['+@tableName+'] 
					(
						[retrieval_reference_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_7] ON [dbo].['+@tableName+'] 
					(
						[system_trace_audit_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_8] ON [dbo].['+@tableName+'] 
					(
						[sink_node_name] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_9] ON [dbo].['+@tableName+'] 
					(
						[acquiring_inst_id_code] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_10] ON [dbo].['+@tableName+'] 
					(
						[from_account_id] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
				 CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_11] ON [dbo].['+@tableName+'] 
					(
						[to_account_id] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
									
					/****** Object:  Index [ix_'+@tableName+'_12]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_12] ON [dbo].['+@tableName+'] 
					(
					 post_tran_cust_id, post_tran_id, datetime_req, retrieval_reference_nr, system_trace_audit_nr, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']




END

IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableNameTwo+']'') AND type in (N''U'')) BEGIN

CREATE TABLE [dbo].['+@tableNameTwo+'](
	[post_tran_cust_id] [bigint] NOT NULL,
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
	[check_data] [varchar](50) NULL,
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
	[card_acceptor_id_code_cs] VARCHAR(255)
) ON ['+@fileGroup+']

ALTER TABLE [dbo].['+@tableNameTwo+'] ADD  DEFAULT ((0)) FOR [draft_capture]


/****** Object:  Index [ix_post_tran_cust_src_node]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_src_node] ON [dbo].['+@tableNameTwo+'] 
(
	[source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



/****** Object:  Index [ix_post_tran_cust_1]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_1] ON [dbo].['+@tableNameTwo+'] 
(
	[pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_post_tran_cust_2]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_2] ON [dbo].['+@tableNameTwo+'] 
(
	[terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_post_tran_cust_3]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_3] ON [dbo].['+@tableNameTwo+'] 
(
	[pan_search] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



/****** Object:  Index [ix_post_tran_cust_4]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_4] ON [dbo].['+@tableNameTwo+'] 
(
	[card_acceptor_name_loc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_post_tran_cust_5]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_5] ON [dbo].['+@tableNameTwo+'] 
(
	[card_acceptor_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
/****** Object:  Index [ix_post_tran_cust_6]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_6] ON [dbo].['+@tableNameTwo+'] 
(
	[card_product] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_7] ON [dbo].['+@tableNameTwo+'] 
(
	[totals_group] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

/****** Object:  Index [pk_post_tran_cust]    Script Date: 06/01/2016 15:00:06 ******/
ALTER TABLE [dbo].['+@tableNameTwo+'] ADD  CONSTRAINT [pk_'+@tableNameTwo+'] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

END');
			
	 END
	 ELSE BEGIN
	 
		 DECLARE @table_month_suffix_current VARCHAR(10)
		 DECLARE @table_month_suffix_final VARCHAR(10)
		 SET @table_month_suffix_current = @table_month_suffix_start;
		 SET @table_month_suffix_current=@table_month_suffix_current+'01';
		 SET @table_month_suffix_final = @table_month_suffix_end+'01';



	 WHILE (DATEDIFF(MONTH,@table_month_suffix_current,@table_month_suffix_final ) >=0) BEGIN
	 
			SET   @tableName  = 'post_tran_arch_'+LEFT(@table_month_suffix_current,6);
		    SET   @tableNameTwo  = 'post_tran_cust_arch_'+LEFT(@table_month_suffix_current,6);
			INSERT INTO @table_name_table (tableName, table_month) VALUES (@tableName , LEFT(@table_month_suffix_current,6));
	SET @month = SUBSTRING(@table_month_suffix_current,5,2)
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

        PRINT 'Creating table '+@tableName+char(10);
		PRINT 'Creating table '+@tableNameTwo+char(10);
			
					EXEC('IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableName+']'') AND type in (N''U''))BEGIN
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
										[pos_geographic_data] [varchar](20) NULL,
										[payer_account_id] [varchar](30) NULL,
										[cvv_available_at_auth] [varchar](30) NULL,
										[cvv2_available_at_auth] [varchar](30) NULL,
										[mapped_terminal_id] [char](8) NULL,
										[mapped_extd_ca_term_id] [varchar](25) NULL,
										[mapped_extd_ca_id_code] [varchar](25) NULL,
										[network_program_id_actual] [varchar](8) NULL,
										[network_program_id_min] [varchar](8) NULL,
										[network_fee_actual] [numeric](9, 0) NULL,
										[network_fee_min] [numeric](9, 0) NULL,
										[network_fee_max] [numeric](9, 0) NULL,
										[credit_debit_conversion] [tinyint] NULL
							) ON ['+@fileGroup+']
							
							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [next_post_tran_id]

							ALTER TABLE [dbo].['+@tableName+'] ADD  DEFAULT ((0)) FOR [tran_reversed]

							CREATE  CLUSTERED INDEX pk_'+@tableName+' ON ['+@tableName+'](
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


					/****** Object:  Index [ix_'+@tableName+'_4]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_4] ON [dbo].['+@tableName+'] 
					(
					 post_tran_cust_id, post_tran_id, datetime_req, retrieval_reference_nr, system_trace_audit_nr, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


					/****** Object:  Index [ix_'+@tableName+'_5]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
					(
						[datetime_req] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					/****** Object:  Index [ix_'+@tableName+'_6]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_6] ON [dbo].['+@tableName+'] 
					(
						[retrieval_reference_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_7] ON [dbo].['+@tableName+'] 
					(
						[system_trace_audit_nr] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_8] ON [dbo].['+@tableName+'] 
					(
						[sink_node_name] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_9] ON [dbo].['+@tableName+'] 
					(
						[acquiring_inst_id_code] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_10] ON [dbo].['+@tableName+'] 
					(
						[from_account_id] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
				 CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_11] ON [dbo].['+@tableName+'] 
					(
						[to_account_id] ASC, recon_business_date
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


					/****** Object:  Index [ix_'+@tableName+'_12]    Script Date: 05/16/2016 16:30:06 ******/
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_12] ON [dbo].['+@tableName+'] 
					(
					 post_tran_cust_id, post_tran_id, datetime_req, retrieval_reference_nr, system_trace_audit_nr, recon_business_date ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


					
END

IF NOT  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableNameTwo+']'') AND type in (N''U'')) BEGIN

CREATE TABLE [dbo].['+@tableNameTwo+'](
	[post_tran_cust_id] [bigint] NOT NULL,
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
	[check_data] [varchar](50) NULL,
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
    [card_acceptor_id_code_cs] VARCHAR(255)
) ON ['+@fileGroup+']

ALTER TABLE [dbo].['+@tableNameTwo+'] ADD  DEFAULT ((0)) FOR [draft_capture]

/****** Object:  Index [ix_post_tran_cust_src_node]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_src_node] ON [dbo].['+@tableNameTwo+'] 
(
	[source_node_name] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



/****** Object:  Index [ix_post_tran_cust_1]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_1] ON [dbo].['+@tableNameTwo+'] 
(
	[pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_post_tran_cust_2]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_2] ON [dbo].['+@tableNameTwo+'] 
(
	[terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_post_tran_cust_3]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_3] ON [dbo].['+@tableNameTwo+'] 
(
	[pan_search] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']



/****** Object:  Index [ix_post_tran_cust_4]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_4] ON [dbo].['+@tableNameTwo+'] 
(
	[card_acceptor_name_loc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [ix_post_tran_cust_5]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_5] ON [dbo].['+@tableNameTwo+'] 
(
	[card_acceptor_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
/****** Object:  Index [ix_post_tran_cust_6]    Script Date: 06/01/2016 15:00:06 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_6] ON [dbo].['+@tableNameTwo+'] 
(
	[card_product] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_7] ON [dbo].['+@tableNameTwo+'] 
(
	[totals_group] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']


/****** Object:  Index [pk_post_tran_cust]    Script Date: 06/01/2016 15:00:06 ******/
ALTER TABLE [dbo].['+@tableNameTwo+'] ADD  CONSTRAINT [pk_'+@tableNameTwo+'] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON ['+@fileGroup+']

END');
			
SET 	@table_month_suffix_current  = REPLACE(CONVERT(varchar(10),DATEADD(MONTH, 1,@table_month_suffix_current ), 111)		,'/', '');
END	
	UPDATE [postilion_office_old].dbo.post_tran_archive_sources  SET is_table_created =1;		 
END
end