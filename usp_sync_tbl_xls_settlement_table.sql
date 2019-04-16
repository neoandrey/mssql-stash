/****** Script for SelectTopNRows command from SSMS  ******/
/****** Script for SelectTopNRows command from SSMS  ******/


CREATE  PROCEDURE usp_sync_tbl_xls_settlement_table  

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
      ,txn_id 
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
      ,[card_acceptor_name_loc])

SELECT  [terminal_id]
      ,[pan]
      ,[trans_date]
      ,[extended_trans_type]
      ,[amount]
      ,txn_id 
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
       from [172.25.10.66].[postilion_office].[dbo].[tbl_xls_settlement] where trans_date > @max_date and  terminal_id like '3%'
END
go
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'sync_tbl_xls_tables_from15_15_n_66', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'sync_tbl_xls_tables_from15_15_n_66', @server_name = @@SERVERNAME
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'sync_tbl_xls_tables_from15_15_n_66', @step_name=N'sync_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'usp_sync_tbl_xls_settlement_table', 
		@database_name=N'postilion_office', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'sync_tbl_xls_tables_from15_15_n_66', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'', 
		@notify_netsend_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'sync_tbl_xls_tables_from15_15_n_66', @name=N'daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20160326, 
		@active_end_date=99991231, 
		@active_start_time=120000, 
		@active_end_time=3059, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

®