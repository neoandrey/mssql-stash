USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_populate_late_reversal_table]    Script Date: 03/29/2016 13:49:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER  PROCEDURE [dbo].[usp_populate_late_reversal_table]  @start_date DATETIME , @end_date DATETIME

AS

BEGIN

		IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversals
		 END
		 
				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversal_categories
		 END
		 
		  IF ( OBJECT_ID('tempdb.dbo.#late_rev_details') IS NOT NULL)
		 BEGIN
				  DROP TABLE #late_rev_details
				  
			
		 END
		SET @start_date  = ISNULL (@start_date,REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '') )
		
		SET @end_date    = ISNULL (@end_date,REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '') )
		 
		SELECT   post_tran_id, trans.post_tran_cust_id,datetime_req, tran_nr, prev_post_tran_id, rsp_code_rsp, message_type,settle_amount_impact ,settle_amount_req ,settle_amount_rsp  ,settle_currency_code, sink_node_name,system_trace_audit_nr,tran_amount_req ,tran_amount_rsp  ,tran_currency_code, terminal_id,retrieval_reference_nr,recon_business_date,online_system_id,tran_type INTO #reversals FROM 
		POST_TRAN trans (NOLOCK) LEFT JOIN POST_TRAN_CUST cust (NOLOCK) 
		ON 
		trans.post_tran_cust_id = cust.post_tran_cust_id
		WHERE
		datetime_req>=@start_date  and datetime_req <@end_date AND message_type ='0420'
		AND tran_postilion_originated = 0
		DECLARE @min_post_tran_id BIGINT
		
		SELECT @min_post_tran_id = MIN(prev_post_tran_id) FROM  #reversals
		 
		select 
	post_tran_id,post_tran_cust_id rev_post_tran_cust_id, post_tran_cust_id  trans_post_tran_cust_id,  '1970-01-01' trans_datetime_req , datetime_req  rev_datetime_req, prev_post_tran_id,message_type rev_message_type, rsp_code_rsp rev_rsp_code_rsp,  '0200' post_tran_message_type,'xx' trans_rsp_code_rsp, tran_nr,settle_amount_impact ,settle_amount_req ,rev.settle_amount_rsp  ,rev.settle_currency_code, rev.sink_node_name,rev.system_trace_audit_nr,rev.tran_amount_req ,rev.tran_amount_rsp  ,rev.tran_currency_code ,  terminal_id,rev.retrieval_reference_nr, rev.recon_business_date, rev.online_system_id, tran_type,'LATE' reversal_type
		  into #late_rev_details from  #reversals  rev WHERE prev_post_tran_id NOT IN (SELECT post_tran_id FROM  post_tran (NOLOCK) WHERE post_tran_id>=@min_post_tran_id )
 
		select rev.post_tran_id,rev.post_tran_cust_id rev_post_tran_cust_id,trans.post_tran_cust_id trans_post_tran_cust_id, trans.datetime_req trans_datetime_req, rev.datetime_req  rev_datetime_req, rev.prev_post_tran_id, rev.message_type rev_message_type, rev.rsp_code_rsp rev_rsp_code_rsp,  trans.message_type post_tran_message_type,trans.rsp_code_rsp trans_rsp_code_rsp, rev.tran_nr,rev.settle_amount_impact ,rev.settle_amount_req ,rev.settle_amount_rsp  ,rev.settle_currency_code, rev.sink_node_name,rev.system_trace_audit_nr,rev.tran_amount_req ,rev.tran_amount_rsp  ,rev.tran_currency_code ,  terminal_id,rev.retrieval_reference_nr, rev.recon_business_date, rev.online_system_id, rev.tran_type,
		 case
             
                  when (rev.datetime_req is not  null  and  trans.datetime_req is NULL)  THEN 'LATE'
             when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )>0  THEN 'LATE'
                 when datepart(D,rev.datetime_req) - datepart(D, trans.datetime_req )=0 then  'TIMELY'
		END as reversal_type
		INTO #reversal_categories
		from #reversals rev 
		LEFT JOIN post_tran trans (NOLOCK) 
		on trans.post_tran_id = rev.prev_post_tran_id
		where trans.tran_postilion_originated = 0  and trans.post_tran_id>=@min_post_tran_id
	
		 
		INSERT  INTO  tbl_late_reversals ([post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr],  [recon_business_date],[online_system_id], [tran_type]) 
		
		 SELECT [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type] 
		 FROM  #reversal_categories WHERE reversal_type = 'LATE'
		 UNION ALL 
		 SELECT [post_tran_id],[rev_post_tran_cust_id],[trans_post_tran_cust_id],[trans_datetime_req],[rev_datetime_req],[prev_post_tran_id],[rev_message_type],[rev_rsp_code_rsp],[post_tran_message_type],[trans_rsp_code_rsp],[tran_nr],[settle_amount_impact],[settle_amount_req],[settle_amount_rsp],[settle_currency_code],[sink_node_name],[system_trace_audit_nr],[tran_amount_req],[tran_amount_rsp],[tran_currency_code],[reversal_type],[terminal_id],[retrieval_reference_nr], [recon_business_date],[online_system_id],[tran_type] 
		 FROM #late_rev_details
		
				IF ( OBJECT_ID('tempdb.dbo.#reversals') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversals
		 END
		 
				IF ( OBJECT_ID('tempdb.dbo.#reversal_categories') IS NOT NULL)
		 BEGIN
				  DROP TABLE #reversal_categories
				  
			
		 END
		 
		 IF ( OBJECT_ID('tempdb.dbo.#late_rev_details') IS NOT NULL)
		 BEGIN
				  DROP TABLE #late_rev_details
				  
			
		 END
		 

END



/****** Object:  StoredProcedure [dbo].[usp_sync_terminal_owner_table]    Script Date: 03/29/2016 13:49:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_sync_terminal_owner_table] as
begin
set transaction isolation level  read uncommitteD
DECLARE @local_count int;
DECLARE @expected_count int;

SELECT   @local_count = COUNT (terminal_id) FROM tbl_terminal_owner;
SELECT   @expected_count = COUNT (terminal_id) FROM [172.25.15.15].[postilion_office].dbo.post_terminal (NOLOCK);

IF(@local_count!= @expected_count )BEGIN
DELETE FROM tbl_terminal_owner;
  INSERT  INTO tbl_terminal_owner (terminal_id, terminal_code) 
select distinct terminal_id, comms_info  from [172.25.15.15].[postilion_office].dbo.post_terminal (NOLOCK)
END
ELSE BEGIN

PRINT 'Tables are in sync. There is nothing to copy'
END


end
GO




USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[usp_sync_tbl_xls_settlement_table]    Script Date: 03/29/2016 13:47:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/
/****** Script for SelectTopNRows command from SSMS  ******/


CREATE  PROCEDURE [dbo].[usp_sync_tbl_xls_settlement_table]  

AS

BEGIN
  
DECLARE @max_txn_id BIGINT
DECLARE @max_trans_date datetime

SELECT @max_txn_id = max(txn_id), @max_trans_date=MAX(trans_date) FROM tbl_xls_settlement WHERE acquiring_inst_id_code is not null and terminal_id like '2%'
set @max_txn_id = ISNULL(@max_txn_id,0)
set @max_trans_date = ISNULL(@max_trans_date,0)
INSERT INTO [tbl_xls_settlement](

 
 [terminal_id]
           ,[pan]
           ,[trans_date]
           ,[extended_trans_type]
           ,[amount]
           ,[rr_number]
           ,[stan]
           ,[rdm_amt]
           ,[merchant_id]
           ,[cashier_name]
           ,[cashier_code]
           ,[cashier_acct]
           ,[cashier_ext_trans_code]
           ,[acquiring_inst_id_code]
           ,[merchant_type]
           ,[card_acceptor_name_loc]

)

SELECT  [terminal_id]
           ,[pan]
           ,[trans_date]
           ,[extended_trans_type]
           ,[amount]
           ,[rr_number]
           ,[stan]
           ,[rdm_amt]
           ,[merchant_id]
           ,[cashier_name]
           ,[cashier_code]
           ,[cashier_acct]
           ,[cashier_ext_trans_code]
           ,[acquiring_inst_id_code]
           ,[merchant_type]
           ,[card_acceptor_name_loc]
  FROM [172.25.15.15].[postilion_office].[dbo].[tbl_xls_settlement]
   WHERE acquiring_inst_id_code is not null
   AND 
  (txn_id > @max_txn_id AND [trans_date] > @max_trans_date)
and terminal_id like '2%';


declare @max_date datetime

set @max_date = (select top 1 trans_date from  [tbl_xls_settlement]  where terminal_id like '3%' order by trans_date desc)
INSERT INTO [tbl_xls_settlement](
[terminal_id]
           ,[pan]
           ,[trans_date]
           ,[extended_trans_type]
           ,[amount]
           ,[rr_number]
           ,[stan]
           ,[rdm_amt]
           ,[merchant_id]
           ,[cashier_name]
           ,[cashier_code]
           ,[cashier_acct]
           ,[cashier_ext_trans_code]
           ,[acquiring_inst_id_code]
           ,[merchant_type]
           ,[card_acceptor_name_loc]
	  )
select [terminal_id]
           ,[pan]
           ,[trans_date]
           ,[extended_trans_type]
           ,[amount]
           ,[rr_number]
           ,[stan]
           ,[rdm_amt]
           ,[merchant_id]
           ,[cashier_name]
           ,[cashier_code]
           ,[cashier_acct]
           ,[cashier_ext_trans_code]
           ,[acquiring_inst_id_code]
           ,[merchant_type]
           ,[card_acceptor_name_loc]
       from [192.168.15.66].[postilion_office].[dbo].[tbl_xls_settlement] where trans_date > @max_date and  terminal_id like '3%'
END

GO


USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[usp_sync_ptsp_table]    Script Date: 03/29/2016 13:47:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[usp_sync_ptsp_table] as
begin
set transaction isolation level  read uncommitteD
DECLARE @local_count int;
DECLARE @expected_count int;

SELECT   @local_count = COUNT (terminal_id) FROM tbl_ptsp;
SELECT   @expected_count = COUNT (terminal_id) FROM [172.25.15.15].[postilion_office].dbo.post_terminal_has_client (NOLOCK);

IF(@local_count!= @expected_count )BEGIN
DELETE FROM tbl_ptsp;
  INSERT  INTO tbl_ptsp (terminal_id, PTSP_Code) 
select distinct terminal_id, participant_client_id  from [172.25.15.15].[postilion_office].dbo.post_terminal_has_client (NOLOCK)
END
ELSE BEGIN

PRINT 'Tables are in sync. There is nothing to copy'
END


end
GO



USE [msdb]
GO

/****** Object:  Job [sync_tbl_xls_tables_from15_15_n_66]    Script Date: 03/29/2016 14:03:08 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/29/2016 14:03:09 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'sync_tbl_xls_tables_from15_15_n_66', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sync_step]    Script Date: 03/29/2016 14:03:09 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sync_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'usp_sync_tbl_xls_settlement_table', 
		@database_name=N'postilion_office', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160326, 
		@active_end_date=99991231, 
		@active_start_time=120000, 
		@active_end_time=3059, 
		@schedule_uid=N'f0ad24e2-e98f-4ad4-97aa-35c5056a98f6'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




/****** Object:  Job [sync_ptsp_table]    Script Date: 03/29/2016 14:03:14 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/29/2016 14:03:14 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'sync_ptsp_table', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sync_step]    Script Date: 03/29/2016 14:03:14 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sync_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'usp_sync_ptsp_table', 
		@database_name=N'postilion_office', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daiy', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160326, 
		@active_end_date=99991231, 
		@active_start_time=120000, 
		@active_end_time=3000, 
		@schedule_uid=N'95127dff-ec0e-4066-a4f2-454c2075434c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO




/****** Object:  Job [fetch_late_reversals]    Script Date: 03/29/2016 14:03:32 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/29/2016 14:03:32 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'fetch_late_reversals', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [get_reversals]    Script Date: 03/29/2016 14:03:32 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'get_reversals', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'postilion_office.dbo.usp_populate_late_reversal_table null, null ', 
		@database_name=N'postilion_office', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'earlu_morning', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160305, 
		@active_end_date=99991231, 
		@active_start_time=500, 
		@active_end_time=235959, 
		@schedule_uid=N'f26d0119-e892-4590-aedc-4d8175278719'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO



/****** Object:  Job [sync_terminal_owner_tables]    Script Date: 03/29/2016 14:03:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 03/29/2016 14:03:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'sync_terminal_owner_tables', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [sync_step]    Script Date: 03/29/2016 14:03:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'sync_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec usp_sync_terminal_owner_table;', 
		@database_name=N'postilion_office', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160326, 
		@active_end_date=99991231, 
		@active_start_time=120000, 
		@active_end_time=3059, 
		@schedule_uid=N'65bc9d7a-2c16-497b-90f9-9f0619bf2d0c'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


