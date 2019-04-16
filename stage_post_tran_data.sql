

IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_tran_summary_staging_info]') AND type in (N'U')) BEGIN

	CREATE TABLE [dbo].[post_tran_summary_staging_info](
		[info_id]     INT NOT NULL,
		[serverName] [varchar](255) NOT NULL,
		[tableName] [varchar](255) NOT NULL,
		[reportDate] DATETIME
		CONSTRAINT [pk_post_tran_summary_staging_info] PRIMARY KEY CLUSTERED 
(
	[info_id] ASC
)
	WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 92) ON [PRIMARY]
	) ON [PRIMARY]

END


DECLARE @serverName  VARCHAR(100);
DECLARE @reportDate DATETIME;
DECLARE @tableName  VARCHAR(100);
DECLARE @tableName2  VARCHAR(100);
DECLARE @sqlQuery  VARCHAR(max);
declare @err_message  varchar (500);
DECLARE @tran_date VARCHAR(12);
SET  @tran_date =REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '');

SET  @tableName2 = 'post_tran_summary_'+@tran_date;

SELECT 
     @serverName  = serverName,
     @tableName   =  tableName,
     @reportDate  =  reportDate
FROM   
   [post_tran_summary_staging_info] (NOLOCK)
WHERE info_id = 1;

IF(@serverName IS NULL) begin
   SET @serverName = @@SERVERNAME;
  
   
END
IF(@tableName IS NULL) begin
 SET  @tableName = @tableName2;
end

 if (@reportDate IS NULL)BEGIN
 SET  @reportDate = @tran_date;
 end

SET   @sqlQuery = 'IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].['+@tableName+']'') AND type in (N''U''))BEGIN
DROP TABLE [dbo].['+@tableName+']
END'

exec(@sqlQuery);

SET  @sqlQuery = 'exec sp_rename  ''post_tran_summary_staging'','''+@tableName+''';';
exec(@sqlQuery);

SET  @sqlQuery = '
CREATE TABLE [dbo].[post_tran_summary_staging](
	[post_tran_id] [bigint] NOT NULL,
	[post_tran_cust_id] [bigint] NOT NULL,
	[prev_post_tran_id] [bigint] NULL,
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
	[auth_id_rsp] [char](6) NULL,
	[retention_data] [varchar](999) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[message_reason_code] [char](4) NULL,
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
	[settle_amount_req] [dbo].[POST_MONEY] NULL,
	[settle_amount_rsp] [dbo].[POST_MONEY] NULL,
	[settle_tran_fee_req] [dbo].[POST_MONEY] NULL,
	[settle_tran_fee_rsp] [dbo].[POST_MONEY] NULL,
	[settle_currency_code] [dbo].[POST_CURRENCY] NULL,
	[structured_data_req] [text] NULL,
	[tran_reversed] [char](1) NULL,
	[prev_tran_approved] [dbo].[POST_BOOL] NULL,
	[extended_tran_type] [char](4) NULL,
	[payee] [char](25) NULL,
	[online_system_id] [int] NULL,
	[receiving_inst_id_code] [varchar](11) NULL,
	[routing_type] [int] NULL,
	[source_node_name] [dbo].[POST_NAME] NOT NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[terminal_id] [dbo].[POST_TERMINAL_ID] NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[merchant_type] [char](4) NULL,
	[card_acceptor_name_loc] [char](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[totals_group] [varchar](12) NULL,
	[pan_encrypted] [char](18) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
;';
 exec(@SQLQUERY);



if not exists (select top 1 * from sys.objects where name = 'post_tran_summary' and type ='V')
			begin
set @sqlQuery ='CREATE VIEW dbo.post_tran_summary
									AS
	SELECT [post_tran_id]
      ,[post_tran_cust_id]
      ,[prev_post_tran_id]
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
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
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
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_currency_code]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[extended_tran_type]
      ,[payee]
      ,[online_system_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_name]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[totals_group]
      ,[pan_encrypted]
  FROM [postilion_office].[dbo].['+@tableName+'] tab (NOLOCK)';
			END;
			ELSE
			BEGIN
		SET @sqlQuery ='ALTER VIEW dbo.post_tran_summary
				as
		SELECT 
		[post_tran_id]
      ,[post_tran_cust_id]
      ,[prev_post_tran_id]
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
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
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
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_currency_code]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[extended_tran_type]
      ,[payee]
      ,[online_system_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_name]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[totals_group]
      ,[pan_encrypted]
  FROM [postilion_office].[dbo].['+@tableName+'] tab (NOLOCK)';
			END
EXEC(@sqlQuery)
set @sqlQuery='
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

CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_11]
ON [dbo].['+@tableName+'] ([tran_postilion_originated],[settle_currency_code],[sink_node_name],[tran_type],[rsp_code_rsp],[recon_business_date],[source_node_name],[card_acceptor_id_code],[totals_group])
INCLUDE ([post_tran_id],[post_tran_cust_id],[message_type],[tran_nr],[system_trace_audit_nr],[acquiring_inst_id_code],[retrieval_reference_nr],[settle_amount_impact],[settle_amount_rsp],[tran_reversed],[extended_tran_type],[payee],[pan],[terminal_id],[terminal_owner],[merchant_type])


					CREATE NONCLUSTERED INDEX [ix_'+@tableName+'_10] ON [dbo].['+@tableName+'] 
					(
						[datetime_tran_local] ASC
					)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
				';
		exec(@sqlQuery);
		
		PRINT 'Indexes have been successfully created'
