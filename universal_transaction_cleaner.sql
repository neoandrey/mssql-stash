	DECLARE @tran_date VARCHAR(12);
	SET  @tran_date =REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '');

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_tran_summary_staging_info]') AND type in (N'U')) BEGIN

	CREATE TABLE [dbo].[post_tran_summary_staging_info](
		[info_id]     INT NOT NULL IDENTITY(1,1),
		[serverName] [varchar](255) NOT NULL,
		[tableName] [varchar](255) NOT NULL,
		[reportDate] DATETIME
		CONSTRAINT [pk_post_tran_summary_staging_info] PRIMARY KEY CLUSTERED 
(
	[info_id] ASC
)
	WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 92) ON [PRIMARY]
	) ON [PRIMARY]

	INSERT INTO post_tran_summary_staging_info (serverName,tableName,reportDate) VALUES (@@SERVERNAME, 'post_tran_summary_'+@tran_date, @tran_date )

END



DECLARE @serverName  VARCHAR(100);
DECLARE @reportDate DATETIME;
DECLARE @tableName  VARCHAR(100);
DECLARE @sqlQuery  VARCHAR(max);
declare @err_message  varchar (500);


SELECT 
     @serverName  = serverName,
     @tableName=tableName,
     @reportDate =reportDate 
FROM   
   [post_tran_summary_staging_info] (NOLOCK)
WHERE info_id = 1;


IF NOT EXISTS (SELECT SRVID FROM sys.sysservers WHERE srvname =@serverName )
BEGIN
  set  @err_message  = 'There is no Linked Server for :'+@serverName+'. Please add the linked server and rerun the job.';
   RAISERROR(@err_message, 16,1);
   return
END

SET  @serverName = ISNULL (@serverName, @@SERVERNAME);

IF(@serverName ='.' OR @serverName=@@SERVERNAME) BEGIN
	SET  @serverName      =  @@SERVERNAME;
	IF (@reportDate IS NULL) BEGIN
		SET  @reportDate =  @tran_date;
		SET  @tableName   =  'post_tran_summary_'+@tran_date;
    END
END


IF (@reportDate IS NULL) BEGIN
	PRINT 'No date specified. Please specify a report date and retry';
	return
END


IF (@tableName IS NULL) BEGIN
	PRINT 'No target table specified. Please specify the name of the table to store data copied from '+@serverName;
	return
END

PRINT 'creating table  '+@tableName;

SET @sqlQuery='
DECLARE @err_message  VARCHAR(500);
IF EXISTS (select * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME='''+@tableName+''') BEGIN
    set  @err_message  = ''Table already exists. This job assumes that transactions for the whole day of:'+ convert(varchar(30),@reportDate,112)+''';
   RAISERROR(@err_message, 16,1);
END
ELSE BEGIN
       CREATE TABLE ['+@tableName+']
		(
			post_tran_id bigint NOT NULL,
			post_tran_cust_id bigint NOT NULL,
			prev_post_tran_id bigint NULL,
			sink_node_name dbo.POST_NAME NULL,
			tran_postilion_originated dbo.POST_BOOL NOT NULL,
			tran_completed dbo.POST_BOOL NOT NULL,
			message_type char(4) NOT NULL,
			tran_type char(2) NULL,
			tran_nr bigint NOT NULL,
			system_trace_audit_nr char(6) NULL,
			rsp_code_req char(2) NULL,
			rsp_code_rsp char(2) NULL,
			abort_rsp_code char(2) NULL,
			auth_id_rsp char(6) NULL,
			retention_data varchar(999) NULL,
			acquiring_inst_id_code varchar(11) NULL,
			message_reason_code char(4) NULL,
			retrieval_reference_nr char(12) NULL,
			datetime_tran_gmt datetime NULL,
			datetime_tran_local datetime NOT NULL,
			datetime_req datetime NOT NULL,
			datetime_rsp datetime NULL,
			realtime_business_date datetime NOT NULL,
			recon_business_date datetime NOT NULL,
			from_account_type char(2) NULL,
			to_account_type char(2) NULL,
			from_account_id varchar(28) NULL,
			to_account_id varchar(28) NULL,
			tran_amount_req dbo.POST_MONEY NULL,
			tran_amount_rsp dbo.POST_MONEY NULL,
			settle_amount_impact dbo.POST_MONEY NULL,
			tran_cash_req dbo.POST_MONEY NULL,
			tran_cash_rsp dbo.POST_MONEY NULL,
			tran_currency_code dbo.POST_CURRENCY NULL,
			tran_tran_fee_req dbo.POST_MONEY NULL,
			tran_tran_fee_rsp dbo.POST_MONEY NULL,
			tran_tran_fee_currency_code dbo.POST_CURRENCY NULL,
			settle_amount_req dbo.POST_MONEY NULL,
			settle_amount_rsp dbo.POST_MONEY NULL,
			settle_tran_fee_req dbo.POST_MONEY NULL,
			settle_tran_fee_rsp dbo.POST_MONEY NULL,
			settle_currency_code dbo.POST_CURRENCY NULL,
			structured_data_req text NULL,
			tran_reversed char(1) NULL,
			prev_tran_approved dbo.POST_BOOL NULL,
			extended_tran_type char(4) NULL,
			payee char(25) NULL,
			online_system_id int NULL,
			receiving_inst_id_code varchar(11) NULL,
			routing_type int NULL,
			source_node_name dbo.POST_NAME NOT NULL,
			pan varchar(19) NULL,
			card_seq_nr varchar(3) NULL,
			expiry_date char(4) NULL,
			terminal_id dbo.POST_TERMINAL_ID NULL,
			terminal_owner varchar(25) NULL,
			card_acceptor_id_code char(15) NULL,
			merchant_type char(4) NULL,
			card_acceptor_name_loc char(40) NULL,
			address_verification_data varchar(29) NULL,
			totals_group varchar(12) NULL,
			pan_encrypted char(18) NULL
		);
		
		CREATE CLUSTERED INDEX [ix_'+@tableName+'_1] ON [dbo].['+@tableName+'] 
		(
			[post_tran_id] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
		END'
		EXEC(@sqlQuery)
				
			print 'setting view to new post_tran_summary partition'
			if not exists (select top 1 * from sys.objects where name = 'post_tran_summary' and type ='V')
			begin
				set @sqlQuery ='CREATE VIEW dbo.post_tran_summary
									AS
		            SELECT tab.[post_tran_id]
      ,tab.[post_tran_cust_id]
      ,tab.[prev_post_tran_id]
      ,tab.[sink_node_name]
      ,tab.[tran_postilion_originated]
      ,tab.[tran_completed]
      ,tab.[message_type]
      ,tab.[tran_type]
      ,tab.[tran_nr]
      ,tab.[system_trace_audit_nr]
      ,tab.[rsp_code_req]
      ,tab.[rsp_code_rsp]
      ,tab.[abort_rsp_code]
      ,tab.[auth_id_rsp]
      ,tab.[retention_data]
      ,tab.[acquiring_inst_id_code]
      ,tab.[message_reason_code]
      ,tab.[retrieval_reference_nr]
      ,tab.[datetime_tran_gmt]
      ,tab.[datetime_tran_local]
      ,tab.[datetime_req]
      ,tab.[datetime_rsp]
      ,tab.[realtime_business_date]
      ,tab.[recon_business_date]
      ,tab.[from_account_type]
      ,tab.[to_account_type]
      ,tab.[from_account_id]
      ,tab.[to_account_id]
      ,tab.[tran_amount_req]
      ,tab.[tran_amount_rsp]
      ,tab.[settle_amount_impact]
      ,tab.[tran_cash_req]
      ,tab.[tran_cash_rsp]
      ,tab.[tran_currency_code]
      ,tab.[tran_tran_fee_req]
      ,tab.[tran_tran_fee_rsp]
      ,tab.[tran_tran_fee_currency_code]
      ,tab.[settle_amount_req]
      ,tab.[settle_amount_rsp]
      ,tab.[settle_tran_fee_req]
      ,tab.[settle_tran_fee_rsp]
      ,tab.[settle_currency_code]
      ,t.[structured_data_req]
      ,tab.[tran_reversed]
      ,tab.[prev_tran_approved]
      ,tab.[extended_tran_type]
      ,tab.[payee]
      ,tab.[online_system_id]
      ,tab.[receiving_inst_id_code]
      ,tab.[routing_type]
      ,tab.[source_node_name]
      ,tab.[pan]
      ,tab.[card_seq_nr]
      ,tab.[expiry_date]
      ,tab.[terminal_id]
      ,tab.[terminal_owner]
      ,tab.[card_acceptor_id_code]
      ,tab.[merchant_type]
      ,tab.[card_acceptor_name_loc]
      ,tab.[address_verification_data]
      ,tab.[totals_group]
      ,tab.[pan_encrypted]
  FROM [postilion_office].[dbo].['+@tableName+'] tab JOIN
  ['+@serverName+'].[postilion_office].[dbo].[post_tran] t (NOLOCK) 
   ON 
   tab.post_tran_id = t.post_tran_id';
			end;
			else
			begin
			set @sqlQuery ='ALTER VIEW dbo.post_tran_summary
				as
		SELECT 
		tab.[post_tran_id]
      ,tab.[post_tran_cust_id]
      ,tab.[prev_post_tran_id]
      ,tab.[sink_node_name]
      ,tab.[tran_postilion_originated]
      ,tab.[tran_completed]
      ,tab.[message_type]
      ,tab.[tran_type]
      ,tab.[tran_nr]
      ,tab.[system_trace_audit_nr]
      ,tab.[rsp_code_req]
      ,tab.[rsp_code_rsp]
      ,tab.[abort_rsp_code]
      ,tab.[auth_id_rsp]
      ,tab.[retention_data]
      ,tab.[acquiring_inst_id_code]
      ,tab.[message_reason_code]
      ,tab.[retrieval_reference_nr]
      ,tab.[datetime_tran_gmt]
      ,tab.[datetime_tran_local]
      ,tab.[datetime_req]
      ,tab.[datetime_rsp]
      ,tab.[realtime_business_date]
      ,tab.[recon_business_date]
      ,tab.[from_account_type]
      ,tab.[to_account_type]
      ,tab.[from_account_id]
      ,tab.[to_account_id]
      ,tab.[tran_amount_req]
      ,tab.[tran_amount_rsp]
      ,tab.[settle_amount_impact]
      ,tab.[tran_cash_req]
      ,tab.[tran_cash_rsp]
      ,tab.[tran_currency_code]
      ,tab.[tran_tran_fee_req]
      ,tab.[tran_tran_fee_rsp]
      ,tab.[tran_tran_fee_currency_code]
      ,tab.[settle_amount_req]
      ,tab.[settle_amount_rsp]
      ,tab.[settle_tran_fee_req]
      ,tab.[settle_tran_fee_rsp]
      ,tab.[settle_currency_code]
      ,t.[structured_data_req]
      ,tab.[tran_reversed]
      ,tab.[prev_tran_approved]
      ,tab.[extended_tran_type]
      ,tab.[payee]
      ,tab.[online_system_id]
      ,tab.[receiving_inst_id_code]
      ,tab.[routing_type]
      ,tab.[source_node_name]
      ,tab.[pan]
      ,tab.[card_seq_nr]
      ,tab.[expiry_date]
      ,tab.[terminal_id]
      ,tab.[terminal_owner]
      ,tab.[card_acceptor_id_code]
      ,tab.[merchant_type]
      ,tab.[card_acceptor_name_loc]
      ,tab.[address_verification_data]
      ,tab.[totals_group]
      ,tab.[pan_encrypted]
  FROM [postilion_office].[dbo].['+@tableName+'] tab JOIN
  ['+@serverName+'].[postilion_office].[dbo].[post_tran] t (NOLOCK) 
   ON 
   tab.post_tran_id = t.post_tran_id';
			END
EXEC(@sqlQuery)
				
IF (@serverName =@@servername) BEGIN
				
set @sqlQuery =' INSERT INTO ['+@tableName+'](
					post_tran_id ,
					post_tran_cust_id ,
					prev_post_tran_id,
					sink_node_name,
					tran_postilion_originated,
					tran_completed,
					message_type,
					tran_type,
					tran_nr ,
					system_trace_audit_nr,
					rsp_code_req,
					rsp_code_rsp,
					abort_rsp_code,
					auth_id_rsp,
					retention_data,
					acquiring_inst_id_code,
					message_reason_code,
					retrieval_reference_nr,
					datetime_tran_gmt,
					datetime_tran_local ,
					datetime_req ,
					datetime_rsp,
					realtime_business_date ,
					recon_business_date ,
					from_account_type,
					to_account_type,
					from_account_id,
					to_account_id,
					tran_amount_req,
					tran_amount_rsp,
					settle_amount_impact,
					tran_cash_req,
					tran_cash_rsp,
					tran_currency_code,
					tran_tran_fee_req,
					tran_tran_fee_rsp,
					tran_tran_fee_currency_code,
					settle_amount_req,
					settle_amount_rsp,
					settle_tran_fee_req,
					settle_tran_fee_rsp,
					settle_currency_code,
				    structured_data_req,
					tran_reversed,
					prev_tran_approved,
					extended_tran_type,
					payee,
					online_system_id,
					receiving_inst_id_code,
					routing_type,
					source_node_name ,
					pan,
					card_seq_nr,
					expiry_date,
					terminal_id,
					terminal_owner,
					card_acceptor_id_code,
					merchant_type,
					card_acceptor_name_loc,
					address_verification_data,
					totals_group,
					pan_encrypted
                )SELECT 
                    post_tran_id ,
					t.post_tran_cust_id ,
					prev_post_tran_id,
					sink_node_name,
					tran_postilion_originated,
					tran_completed,
					message_type,
					tran_type,
					tran_nr ,
					system_trace_audit_nr,
					rsp_code_req,
					rsp_code_rsp,
					abort_rsp_code,
					auth_id_rsp,
					retention_data,
					acquiring_inst_id_code,
					message_reason_code,
					retrieval_reference_nr,
					datetime_tran_gmt,
					datetime_tran_local ,
					datetime_req ,
					datetime_rsp,
					realtime_business_date ,
					t.recon_business_date ,
					from_account_type,
					to_account_type,
					from_account_id,
					to_account_id,
					tran_amount_req,
					tran_amount_rsp,
					settle_amount_impact,
					tran_cash_req,
					tran_cash_rsp,
					tran_currency_code,
					tran_tran_fee_req,
					tran_tran_fee_rsp,
					tran_tran_fee_currency_code,
					settle_amount_req,
					settle_amount_rsp,
					settle_tran_fee_req,
					settle_tran_fee_rsp,
					settle_currency_code,
				    structured_data_req,
					tran_reversed,
					prev_tran_approved,
					extended_tran_type,
					payee,
					online_system_id,
					receiving_inst_id_code,
					routing_type,
					source_node_name ,
					pan,
					card_seq_nr,
					expiry_date,
					terminal_id,
					terminal_owner,
					card_acceptor_id_code,
					merchant_type,
					card_acceptor_name_loc,
					address_verification_data,
					totals_group,
					pan_encrypted
				
				FROM	['+@serverName+'].[postilion_office].[dbo].[post_tran] t (NOLOCK, INDEX(ix_post_tran_9)) 
							INNER JOIN
						['+@serverName+'].[postilion_office].[dbo].[post_tran_cust] c (NOLOCK) 
				ON t.post_tran_cust_id = c.post_tran_cust_id
				JOIN
				  (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]('''+CONVERT(varchar(max) , @reportDate, 112)+''','''+CONVERT(varchar(max) , @reportDate, 112)+'''))r
				ON
			    t.recon_business_date = r.recon_business_date
			     OPTION (MAXDOP 8)';
END
ELSE
    BEGIN
	set @sqlQuery =' INSERT INTO ['+@tableName+'](
					post_tran_id ,
					post_tran_cust_id ,
					prev_post_tran_id,
					sink_node_name,
					tran_postilion_originated,
					tran_completed,
					message_type,
					tran_type,
					tran_nr ,
					system_trace_audit_nr,
					rsp_code_req,
					rsp_code_rsp,
					abort_rsp_code,
					auth_id_rsp,
					retention_data,
					acquiring_inst_id_code,
					message_reason_code,
					retrieval_reference_nr,
					datetime_tran_gmt,
					datetime_tran_local ,
					datetime_req ,
					datetime_rsp,
					realtime_business_date ,
					recon_business_date ,
					from_account_type,
					to_account_type,
					from_account_id,
					to_account_id,
					tran_amount_req,
					tran_amount_rsp,
					settle_amount_impact,
					tran_cash_req,
					tran_cash_rsp,
					tran_currency_code,
					tran_tran_fee_req,
					tran_tran_fee_rsp,
					tran_tran_fee_currency_code,
					settle_amount_req,
					settle_amount_rsp,
					settle_tran_fee_req,
					settle_tran_fee_rsp,
					settle_currency_code,
				    structured_data_req,
					tran_reversed,
					prev_tran_approved,
					extended_tran_type,
					payee,
					online_system_id,
					receiving_inst_id_code,
					routing_type,
					source_node_name ,
					pan,
					card_seq_nr,
					expiry_date,
					terminal_id,
					terminal_owner,
					card_acceptor_id_code,
					merchant_type,
					card_acceptor_name_loc,
					address_verification_data,
					totals_group,
					pan_encrypted
                )SELECT 
                    post_tran_id ,
					t.post_tran_cust_id ,
					prev_post_tran_id,
					sink_node_name,
					tran_postilion_originated,
					tran_completed,
					message_type,
					tran_type,
					tran_nr ,
					system_trace_audit_nr,
					rsp_code_req,
					rsp_code_rsp,
					abort_rsp_code,
					auth_id_rsp,
					retention_data,
					acquiring_inst_id_code,
					message_reason_code,
					retrieval_reference_nr,
					datetime_tran_gmt,
					datetime_tran_local ,
					datetime_req ,
					datetime_rsp,
					realtime_business_date ,
					t.recon_business_date ,
					from_account_type,
					to_account_type,
					from_account_id,
					to_account_id,
					tran_amount_req,
					tran_amount_rsp,
					settle_amount_impact,
					tran_cash_req,
					tran_cash_rsp,
					tran_currency_code,
					tran_tran_fee_req,
					tran_tran_fee_rsp,
					tran_tran_fee_currency_code,
					settle_amount_req,
					settle_amount_rsp,
					settle_tran_fee_req,
					settle_tran_fee_rsp,
					settle_currency_code,
				    structured_data_req,
					tran_reversed,
					prev_tran_approved,
					extended_tran_type,
					payee,
					online_system_id,
					receiving_inst_id_code,
					routing_type,
					source_node_name ,
					pan,
					card_seq_nr,
					expiry_date,
					terminal_id,
					terminal_owner,
					card_acceptor_id_code,
					merchant_type,
					card_acceptor_name_loc,
					address_verification_data,
					totals_group,
					pan_encrypted
				
				FROM	['+@serverName+'].[postilion_office].[dbo].[post_tran] t (NOLOCK) 
							INNER JOIN
						['+@serverName+'].[postilion_office].[dbo].[post_tran_cust] c (NOLOCK) 
				ON t.post_tran_cust_id = c.post_tran_cust_id
				JOIN
				  (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]('''+CONVERT(varchar(max) , @reportDate, 112)+''','''+CONVERT(varchar(max) , @reportDate, 112)+'''))r
				ON
			    t.recon_business_date = r.recon_business_date
			     OPTION (MAXDOP 8)';
	
	END
EXEC(@sqlQuery);
print  'Data Copy complete...'+CHAR(10)
PRINT  'Creating indexes...'+CHAR(10)
SET @sqlQuery = '
					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_4] ON [dbo].['+@tableName+'] 
					(
						[tran_nr] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_5] ON [dbo].['+@tableName+'] 
					(
						[retrieval_reference_nr] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_6] ON [dbo].['+@tableName+'] 
					(
						[pan] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_7] ON [dbo].['+@tableName+'] 
					(
						[receiving_inst_id_code] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_8] ON [dbo].['+@tableName+'] 
					(
						[message_reason_code] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_9] ON [dbo].['+@tableName+'] 
					(
						[payee] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]


					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_10] ON [dbo].['+@tableName+'] 
					(
						[datetime_tran_local] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]

				';
		exec(@sqlQuery);
		
		PRINT 'Indexes have been successfully created'
				
