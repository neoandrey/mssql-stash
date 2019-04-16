sp_configure 'Ad Hoc Distributed Queries',1
RECONFIGURE WITH OVERRIDE

exec sp_configure 'allow updates',1
RECONFIGURE WITH OVERRIDE

exec sp_configure 'awe enabled',1
RECONFIGURE WITH OVERRIDE

exec sp_configure 'max server memory (MB)',2000
RECONFIGURE WITH OVERRIDE

exec sp_configure 'max worker threads',1000
RECONFIGURE WITH OVERRIDE

exec sp_configure 'min memory per query (KB)',784
RECONFIGURE WITH OVERRIDE

exec sp_configure 'Ole Automation Procedures',1
RECONFIGURE WITH OVERRIDE

exec sp_configure 'optimize for ad hoc workloads',1
RECONFIGURE WITH OVERRIDE

exec sp_configure 'recovery interval (min)',15
RECONFIGURE WITH OVERRIDE

exec sp_configure 'xp_cmdshell',1
RECONFIGURE WITH OVERRIDE