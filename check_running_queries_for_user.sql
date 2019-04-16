SELECT 
					  procs.spid
					, procs.blocked AS BLOCKING_PROCESS
					, DB_NAME(procs.dbid) AS DATABASE_NAME
					, right(convert(varchar, dateadd(ms, datediff(ms, procs.last_batch, getdate()), '1900-01-01'),121), 12) AS 'CONNECTION_DURATION'
					, procs.loginame AS LOGIN_NAME
					, procs.waittime AS WAIT_TIME
					, procs.memusage AS MEMORY_USAGE
					, procs.status   AS STATUS
					, CAST(text AS VARCHAR(1000)) AS SQL_QUERY

				FROM sys.sysprocesses  as procs 
				CROSS APPLY sys.dm_exec_sql_text(procs.sql_handle) AS query WHERE LOGINAME='reportadmin';