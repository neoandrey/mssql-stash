SELECT spid,DATEDIFF(mi, login_time,GETDATE()) AS 'period_in_mins', loginame,* from master.dbo.sysprocesses where blocked <> 0 and status = 'sleeping' AND SPID=BLOCKED