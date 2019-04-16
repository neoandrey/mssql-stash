ALTER AUTHORIZATION ON DATABASE::STANBICIBTC TO 'sa';
exec sp_repl

SELECT DB_NAME(7);

SELECT OBJECT_NAME(1640653188);
SELECT OBJECT_ID('employees');

USE  [STANBICIBTC];
GO
exec sp_lock;
GO

Alternatives to sp_lock:
=======================

sys.dm_tran_locks:

The following query will display lock information:

The value for <dbid> should be replaced with the database_id from sys.databases.

SELECT resource_type, resource_associated_entity_id,
    request_status, request_mode,request_session_id,
    resource_description 
    FROM sys.dm_tran_locks
    WHERE resource_database_id =<dbid> ;-- '1640653188';
    --------------------
    
    The following query returns object information by using resource_associated_entity_id from the previous query.
    This query must be executed while you are connected to the database that contains the object.
    
 SELECT object_name(object_id), *
        FROM sys.partitions
    WHERE hobt_id=<resource_associated_entity_id>
    -------------------------------------
    
    The following query will show blocking information:
    
    SELECT 
            t1.resource_type,
            t1.resource_database_id,
            t1.resource_associated_entity_id,
            t1.request_mode,
            t1.request_session_id,
            t2.blocking_session_id
        FROM sys.dm_tran_locks as t1
        INNER JOIN sys.dm_os_waiting_tasks as t2
        ON t1.lock_owner_address = t2.resource_address;
        
      ----------------
      
      Release the resources by rolling back the transactions.
      
      -- Session 1
      ROLLBACK;
      GO
      
      -- Session 2
      ROLLBACK;
      GO
      
-----------------


The following example returns information that associates a session ID with a Windows thread ID.
The performance of the thread can be monitored in the Windows Performance Monitor. 
This query does not return session IDs that are currently sleeping.

SELECT STasks.session_id, SThreads.os_thread_id
    FROM sys.dm_os_tasks AS STasks
    INNER JOIN sys.dm_os_threads AS SThreads
        ON STasks.worker_address = SThreads.worker_address
    WHERE STasks.session_id IS NOT NULL
    ORDER BY STasks.session_id;
GO

Displaying all active processes

USE master;
GO
EXEC sp_who 'active';
GO

Displaying a specific process identified by a session ID

USE master;
GO
EXEC sp_who '10' --specifies the process_id;
GO




