USE YourDatabase;
GO


CREATE TRIGGER DDLTrigger_Sample
    ON DATABASE
    FOR CREATE_PROCEDURE, ALTER_PROCEDURE, DROP_PROCEDURE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
        @EventData XML = EVENTDATA();
 
    DECLARE 
        @ip VARCHAR(32) =
        (
            SELECT client_net_address
                FROM sys.dm_exec_connections
                WHERE session_id = @@SPID
        );
 
    INSERT AuditDB.dbo.DDLEvents
    (
        EventType,
        EventDDL,
        EventXML,
        DatabaseName,
        SchemaName,
        ObjectName,
        HostName,
        IPAddress,
        ProgramName,
        LoginName
    )
    SELECT
        @EventData.value('(/EVENT_INSTANCE/EventType)[1]',   'NVARCHAR(100)'), 
        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]', 'NVARCHAR(MAX)'),
        @EventData,
        DB_NAME(),
        @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',  'NVARCHAR(255)'), 
        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',  'NVARCHAR(255)'),
        HOST_NAME(),
        @ip,
        PROGRAM_NAME(),
        SUSER_SNAME();
END
GO

USE YourDatabase;
GO


DISABLE TRIGGER [DDLTrigger_Sample] ON DATABASE;


USE YourDatabase;
GO


ENABLE TRIGGER [DDLTrigger_Sample] ON DATABASE;




-- ============================================= 
-- Create the DDL Trigger on the database on which you intend to capture the DDL Events. (In general all User DB’s)
--Author: Abdul Majeed
-- Create date: 
-- ============================================= 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

Create TRIGGER [Trg_LogDDLEvent] ON DATABASE 
FOR 
CREATE_TABLE,ALTER_TABLE,DROP_TABLE,
CREATE_VIEW,ALTER_VIEW,DROP_VIEW,
CREATE_TRIGGER,ALTER_TRIGGER,DROP_TRIGGER,
CREATE_PROCEDURE,ALTER_PROCEDURE,DROP_PROCEDURE,
CREATE_USER,ALTER_USER,DROP_USER, 
CREATE_FUNCTION,ALTER_FUNCTION,DROP_FUNCTION
AS 
begin 

DECLARE @xmlEventData XML,
@message varchar(2000)          
    
SET @xmlEventData = EVENTDATA()     
   INSERT INTO audit_db.dbo.DDLEventLog
   (
   EventTime,
   EventType,
   ObjectType,
   ObjectName,
   HostName,
   ServerName,
   DatabaseName,
   LoginName,
   Username,
   CommandText
   )

   SELECT 
   EventTime=getdate(),
   --EventTime =REPLACE(CONVERT(NVARCHAR(100), @xmlEventData.query('data(/EVENT_INSTANCE/PostTime)')),'T', ' '),
   EventType = CONVERT(VARCHAR(30), @xmlEventData.query('data(/EVENT_INSTANCE/EventType)')),
   ObjectType =CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectType)')),
   ObjectName =CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ObjectName)')),
   --HostName =CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ClientHost)')),
   HOST_NAME(),
   ServerName = CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/ServerName)')),
   DatabaseName =CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/DatabaseName)')),
   LoginName =CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/LoginName)')),
   UserName =CONVERT(VARCHAR(128), @xmlEventData.query('data(/EVENT_INSTANCE/UserName)')),
   CommandText =CONVERT(VARCHAR(MAX), @xmlEventData.query('data(/EVENT_INSTANCE/TSQLCommand/CommandText)')) 
   
end
GO
ENABLE TRIGGER [Trg_LogDDLEvent] ON DATABASE
GO

TRANSACTION_AMOUNT212
