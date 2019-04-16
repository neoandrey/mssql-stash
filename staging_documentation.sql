DECLARE @tran_date CHAR (8) ;
DECLARE @server_name VARCHAR(255) ;

SET @tran_date   = '20161201'
SET @server_name = '172.75.75.10'

DELETE FROM [post_tran_summary_staging_info] 
INSERT INTO [post_tran_summary_staging_info] (serverName,tableName,reportDate)
VALUES(@server_name, 'post_tran_summary_'+@tran_date,@tran_date );

EXEC msdb.dbo.sp_start_job @job_name = 'stage_post_tran_4rm_post_tran_staging_info_table';

USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran_summary_staging_info]    Script Date: 12/20/2016 11:06:03 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_tran_summary_staging_info]') AND type in (N'U'))
DROP TABLE [dbo].[post_tran_summary_staging_info]
GO

USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran_summary_staging_info]    Script Date: 12/20/2016 11:06:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[post_tran_summary_staging_info](
	[info_id] [int] IDENTITY(1,1) NOT NULL,
	[serverName] [varchar](255) NOT NULL,
	[tableName] [varchar](255) NOT NULL,
	[reportDate] [datetime] NULL,
 CONSTRAINT [pk_post_tran_summary_staging_info] PRIMARY KEY CLUSTERED 
(
	[info_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 92) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


 USE [postilion_office]
 GO
 /****** Object:  StoredProcedure [dbo].[usp_stage_post_tran_summary]    Script Date: 12/20/2016 10:25:52 ******/
 SET ANSI_NULLS ON
 GO
 SET QUOTED_IDENTIFIER ON
 GO
 CREATE PROCEDURE [dbo].[usp_stage_post_tran_summary]  AS BEGIN
 
 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
 
  DECLARE @report_date VARCHAR (30)
  DECLARE @report_table VARCHAR(255)
  DECLARE @server_name VARCHAR(255)
   
  SELECT @report_date = CONVERT(varchar(10), [reportDate],112), @report_table =[tableName],   @server_name = [serverName] FROM [postilion_office].[dbo].[post_tran_summary_staging_info]  (nolock)
  
  IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(@report_table) AND type in (N'U')) BEGIN
     EXEC ( 'DROP TABLE '+@report_table);
  
  END
  
  EXEC('CREATE TABLE '+@report_table+' (
  	[post_tran_id] [bigint] NOT NULL,[post_tran_cust_id] [bigint] NOT NULL,[prev_post_tran_id] [bigint] NULL,[sink_node_name] [dbo].[POST_NAME] NULL,[tran_postilion_originated] [dbo].[POST_BOOL] NOT NULL,[tran_completed] [dbo].[POST_BOOL] NOT NULL,[message_type] [char](4) NOT NULL,[tran_type] [char](2) NULL,[tran_nr] [bigint] NOT NULL,[system_trace_audit_nr] [char](6) NULL, '+
  	'[rsp_code_req] [char](2) NULL,[rsp_code_rsp] [char](2) NULL,[abort_rsp_code] [char](2) NULL,[auth_id_rsp] [char](6) NULL,[retention_data] [varchar](999) NULL,[acquiring_inst_id_code] [varchar](11) NULL,[message_reason_code] [char](4) NULL,[retrieval_reference_nr] [char](12) NULL,[datetime_tran_gmt] [datetime] NULL,[datetime_tran_local] [datetime] NOT NULL,[datetime_req] [datetime] NOT NULL,[datetime_rsp] [datetime] NULL,[realtime_business_date] [datetime] NOT NULL,[recon_business_date] [datetime] NOT NULL,[from_account_type] [char](2) NULL,[to_account_type] [char](2) NULL,[from_account_id] [varchar](28) NULL,[to_account_id] [varchar](28) NULL,[tran_amount_req] [dbo].[POST_MONEY] NULL,[tran_amount_rsp] [dbo].[POST_MONEY] NULL,[settle_amount_impact] [dbo].[POST_MONEY] NULL,[tran_cash_req] [dbo].[POST_MONEY] NULL,[tran_cash_rsp] [dbo].[POST_MONEY] NULL,[tran_currency_code] [dbo].[POST_CURRENCY] NULL,[tran_tran_fee_req] [dbo].[POST_MONEY] NULL,[tran_tran_fee_rsp] [dbo].[POST_MONEY] NULL,[tran_tran_fee_currency_code] [dbo].[POST_CURRENCY] NULL,[settle_amount_req] [dbo].[POST_MONEY] NULL,[settle_amount_rsp] [dbo].[POST_MONEY] NULL,[settle_tran_fee_req] [dbo].[POST_MONEY] NULL,[settle_tran_fee_rsp] [dbo].[POST_MONEY] NULL,[settle_currency_code] [dbo].[POST_CURRENCY] NULL,[tran_reversed] [char](1) NULL,[prev_tran_approved] [dbo].[POST_BOOL] NULL,[extended_tran_type] [char](4) NULL,[payee] [char](25) NULL,[online_system_id] [int] NULL,[receiving_inst_id_code] [varchar](11) NULL,[routing_type] [int] NULL,[source_node_name] [dbo].[POST_NAME] NOT NULL,[pan] [varchar](19) NULL,[card_seq_nr] [varchar](3) NULL,[expiry_date] [char](4) NULL,[terminal_id] [dbo].[POST_TERMINAL_ID] NULL,[terminal_owner] [varchar](25) NULL,[card_acceptor_id_code] [char](15) NULL,[merchant_type] [char](4) NULL,[card_acceptor_name_loc] [char](40) NULL,[address_verification_data] [varchar](29) NULL,[totals_group] [varchar](12) NULL,[pan_encrypted] [char](18) NULL, pos_entry_mode VARCHAR(3) ) ON [PRIMARY]
 ')
 
 
 exec('INSERT INTO '+@report_table +' SELECT * FROM  OPENQUERY(['+@server_name +'],  ''SELECT  [post_tran_id],t.[post_tran_cust_id],[prev_post_tran_id],[sink_node_name],[tran_postilion_originated],[tran_completed],[message_type],[tran_type],[tran_nr],[system_trace_audit_nr],[rsp_code_req],[rsp_code_rsp],[abort_rsp_code],[auth_id_rsp],[retention_data],[acquiring_inst_id_code],[message_reason_code],[retrieval_reference_nr],[datetime_tran_gmt],[datetime_tran_local],[datetime_req],[datetime_rsp],[realtime_business_date],[recon_business_date],[from_account_type],[to_account_type],[from_account_id],[to_account_id],[tran_amount_req],[tran_amount_rsp],[settle_amount_impact],[tran_cash_req],[tran_cash_rsp],[tran_currency_code],[tran_tran_fee_req],[tran_tran_fee_rsp],[tran_tran_fee_currency_code],[settle_amount_req],[settle_amount_rsp],[settle_tran_fee_req],[settle_tran_fee_rsp],[settle_currency_code],[tran_reversed],[prev_tran_approved],[extended_tran_type],[payee],[online_system_id],[receiving_inst_id_code],[routing_type],[source_node_name],[pan],[card_seq_nr],[expiry_date],[terminal_id],[terminal_owner],[card_acceptor_id_code],[merchant_type],[card_acceptor_name_loc],[address_verification_data],[totals_group],[pan_encrypted],[pos_entry_mode] 
 FROM 
 (  SELECT * FROM postilion_office.dbo.post_tran pt WITH (NOLOCK, index (ix_post_tran_9))   JOIN 
  (SELECT [date] rec_business_date FROM postilion_office.dbo.[get_dates_in_range]('''''+ @report_date + ''''','''''+@report_date+'''''))r ON r.rec_business_date = pt.recon_business_date 
  ) t 
 
   JOIN postilion_office.dbo.POST_TRAN_CUST c  WITH (NOLOCK, INDEX(pk_post_tran_cust)) 
  ON  t.post_tran_cust_id = c.post_tran_cust_id
 
 OPTION (recompile)'')' );
 
 
 exec ('ALTER VIEW  postilion_office.dbo.post_tran_summary AS SELECT * FROM  postilion_office.dbo.'+@report_table+' WITH (nolock)');
 
 exec(' USE postilion_office;
 CREATE NONCLUSTERED INDEX ix_'+@report_table+'_3 ON '+@report_table+'
 (
 	[sink_node_name] ASC,
 	[tran_postilion_originated] ASC,
 	[tran_completed] ASC,
 	[message_type] ASC,
 	[tran_type] ASC,
 	[rsp_code_rsp] ASC,
 	[message_reason_code] ASC,
 	[datetime_req] ASC,
 	[recon_business_date] ASC,
 	[tran_reversed] ASC,
 	[extended_tran_type] ASC,
 	[source_node_name] ASC,
 	[terminal_id] ASC,
 	[terminal_owner] ASC,
 	[merchant_type] ASC,
 	[totals_group] ASC
 )
 INCLUDE ( [post_tran_cust_id],
 [system_trace_audit_nr],
 [auth_id_rsp],
 [from_account_type],
 [to_account_type],
 [from_account_id],
 [to_account_id],
 [tran_amount_req],
 [tran_amount_rsp],
 [settle_amount_impact],
 [tran_cash_req],
 [tran_cash_rsp],
 [tran_currency_code],
 [tran_tran_fee_req],
 [tran_tran_fee_rsp],
 [tran_tran_fee_currency_code],
 [settle_amount_req],
 [settle_amount_rsp],
 [settle_tran_fee_req],
 [settle_tran_fee_rsp],
 [settle_currency_code],
 [online_system_id],
 [card_seq_nr],
 [expiry_date],
 [card_acceptor_id_code],
 [card_acceptor_name_loc],
 [pan_encrypted]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 GO
 
 CREATE NONCLUSTERED INDEX  ix_'+@report_table+'_10 ON '+@report_table+'
 (
 	[datetime_tran_local] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 CREATE CLUSTERED INDEX  ix_'+@report_table+'_2 ON '+@report_table+'
 (
 	[post_tran_id] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 CREATE NONCLUSTERED INDEX  ix_'+@report_table+'_4 ON '+@report_table+'
 (
 	[tran_nr] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 
 CREATE NONCLUSTERED INDEX  ix_'+@report_table+'_5 ON '+@report_table+' 
 (
 	[retrieval_reference_nr] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 CREATE NONCLUSTERED INDEX ix_'+@report_table+'_6 ON '+@report_table+'
 (
 	[pan] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 CREATE NONCLUSTERED INDEX  ix_'+@report_table+'_7 ON '+@report_table+'
 (
 	[receiving_inst_id_code] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 GO
 CREATE NONCLUSTERED INDEX  ix_'+@report_table+'_8 ON '+@report_table+'
 (
 	[message_reason_code] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 GO
 CREATE NONCLUSTERED INDEX  ix_'+@report_table+'_9 ON '+@report_table+'
 (
 	[payee] ASC
 )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
 GO')
 
 
END




USE [msdb]
GO

/****** Object:  Job [stage_post_tran_4rm_post_tran_staging_info_table]    Script Date: 12/20/2016 11:07:29 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 12/20/2016 11:07:29 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'stage_post_tran_4rm_post_tran_staging_info_table', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'officeadmin', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [stage_report_data]    Script Date: 12/20/2016 11:07:29 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'stage_report_data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

EXEC postilion_office.dbo.[usp_stage_post_tran_summary]', 
		@database_name=N'postilion_office', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO



