USE master
go


CREATE SERVER AUDIT SQL_Server_Audit
    TO APPLICATION_LOG
    /* The Queue Delay is set to 1000, meaning one second 
         intervals to write to the target. */
    WITH ( QUEUE_DELAY = 1000,  ON_FAILURE = CONTINUE);
GO


USE librarian ;
GO
-- Create the database audit specification.
CREATE DATABASE AUDIT SPECIFICATION librarian_audit_for_lbr_roles
FOR SERVER AUDIT SQL_Server_Audit
ADD (SELECT , INSERT
     ON dbo.lbr_roles BY dbo )
WITH (STATE = ON) ;
GO



USE master ;
GO
-- Create the ser
-- Enable the server audit.
ALTER SERVER AUDIT SQL_Server_Audit 
WITH (STATE = ON) ;
GO
