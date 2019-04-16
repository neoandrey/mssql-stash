SELECT blocked_query.session_id AS blocked_session_id,

blocking_query.session_id AS blocking_session_id,

sql_text.text AS blocked_text,

sql_btext.text AS blocking_text,

waits.wait_type AS blocking_resource

FROM sys.dm_exec_requests AS blocked_query

INNER JOIN sys.dm_exec_requests AS blocking_query

ON blocked_query.blocking_session_id = blocking_query.session_id

CROSS APPLY

(SELECT *

FROM sys.dm_exec_sql_text(blocking_query.sql_handle)

) sql_btext

CROSS APPLY

(SELECT *

FROM sys.dm_exec_sql_text(blocked_query.sql_handle)

) sql_text

INNER JOIN sys.dm_os_waiting_tasks AS waits

ON waits.session_id = blocking_query.session_id