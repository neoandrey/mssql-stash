--BEGIN TRAN
exec postilion_office.dbo.reset_settlement_to_yesterday;
exec msdb.dbo.sp_update_job @job_name = 'Postilion Office - Settlement - Run InterSwitch',@enabled = 1
exec msdb.dbo.sp_start_job @JOB_NAME = 'Postilion Office - Settlement - Run InterSwitch'
--COMMIT TRAN