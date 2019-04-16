IF OBJECT_ID('dbo.AuditDBLogin', 'U') IS NULL
 
CREATE TABLE [dbo].[AuditDBLogin](
	[ServerName] [NVARCHAR](128) NULL,
	[LoginName] [sysname] NOT NULL,
	[LoginType] [VARCHAR](13) NOT NULL,
	[DatabaseName] [NVARCHAR](128) NULL,
	[SelectAccess] [INT] NULL,
	[InsertAccess] [INT] NULL,
	[UpdateAccess] [INT] NULL,
	[DeleteAccess] [INT] NULL,
	[DBOAccess] [INT] NULL,
	[SysadminAccess] [INT] NULL,
	[AuditDate] [DATETIME] NOT NULL DEFAULT ( GETDATE() )
) 

INSERT INTO SQLAudit.dbo.AuditDBLogin
 ( [ServerName] ,
  [LoginName] ,
  [LoginType] ,
  [DatabaseName] ,
  [SelectAccess] ,
  [InsertAccess] ,
  [UpdateAccess] ,
  [DeleteAccess] ,
  [DBOAccess] ,
  [SysadminAccess]
 )
 SELECT ServerName = @@SERVERNAME ,
  LoginName = AccessSummary.LoginName ,
  LoginType = CASE WHEN syslogins.isntuser = 1
     THEN 'WINDOWS_LOGIN'
     WHEN syslogins.isntgroup = 1
     THEN 'WINDOWS_GROUP'
     ELSE 'SQL_USER'
     END ,
  DatabaseName = DB_NAME() ,
  SelectAccess = MAX(AccessSummary.SelectAccess) ,
  InsertAccess = MAX(AccessSummary.InsertAccess) ,
  UpdateAccess = MAX(AccessSummary.UpdateAccess) ,
  DeleteAccess = MAX(AccessSummary.DeleteAccess) ,
  DBOAccess = MAX(AccessSummary.DBOAccess) ,
  SysadminAccess = MAX(AccessSummary.SysadminAccess)
 FROM (
  /* Get logins with permissions */ 
    SELECT LoginName = sysDatabasePrincipal.name ,
        SelectAccess = CASE
        WHEN permission_name = 'SELECT'
        THEN 1
        ELSE 0
        END ,
        InsertAccess = CASE
        WHEN permission_name = 'INSERT'
        THEN 1
        ELSE 0
        END ,
        UpdateAccess = CASE
        WHEN permission_name = 'UPDATE'
        THEN 1
        ELSE 0
        END ,
        DeleteAccess = CASE
        WHEN permission_name = 'DELETE'
        THEN 1
        ELSE 0
        END ,
        DBOAccess = 0 ,
        SysadminAccess = 0
       FROM sys.database_permissions
        AS sysDatabasePermission
        INNER JOIN sys.database_principals
        AS sysDatabasePrincipal ON sysDatabasePrincipal.principal_id = sysDatabasePermission.grantee_principal_id
        INNER JOIN sys.server_principals
        AS sysServerPrincipal ON sysServerPrincipal.sid = sysDatabasePrincipal.sid
       WHERE sysDatabasePermission.class_desc = 'OBJECT_OR_COLUMN'
        AND sysDatabasePrincipal.type_desc IN (
        'WINDOWS_LOGIN',
        'WINDOWS_GROUP',
        'SQL_USER' )
        AND sysServerPrincipal.is_disabled = 0
   UNION ALL
  /* Get group members with permissions */
   SELECT LoginName = sysDatabasePrincipalMember.name ,
    SelectAccess = CASE WHEN permission_name = 'SELECT'
      THEN 1
      ELSE 0
      END ,
    InsertAccess = CASE WHEN permission_name = 'INSERT'
      THEN 1
      ELSE 0
      END ,
    UpdateAccess = CASE WHEN permission_name = 'UPDATE'
      THEN 1
      ELSE 0
      END ,
    DeleteAccess = CASE WHEN permission_name = 'DELETE'
      THEN 1
      ELSE 0
      END ,
    DBOAccess = 0 ,
    SysadminAccess = 0
   FROM sys.database_permissions AS sysDatabasePermission
    INNER JOIN sys.database_principals AS sysDatabasePrincipalRole ON sysDatabasePrincipalRole.principal_id = sysDatabasePermission.grantee_principal_id
    INNER JOIN sys.database_role_members AS sysDatabaseRoleMember ON sysDatabaseRoleMember.role_principal_id = sysDatabasePrincipalRole.principal_id
    INNER JOIN sys.database_principals AS sysDatabasePrincipalMember ON sysDatabasePrincipalMember.principal_id = sysDatabaseRoleMember.member_principal_id
    INNER JOIN sys.server_principals AS sysServerPrincipal ON sysServerPrincipal.sid = sysDatabasePrincipalMember.sid
   WHERE sysDatabasePermission.class_desc = 'OBJECT_OR_COLUMN'
    AND sysDatabasePrincipalRole.type_desc = 'DATABASE_ROLE'
    AND sysDatabasePrincipalRole.name <> 'public'
    AND sysDatabasePrincipalMember.type_desc IN (
    'WINDOWS_LOGIN', 'WINDOWS_GROUP', 'SQL_USER' )
    AND sysServerPrincipal.is_disabled = 0
   UNION ALL
  /* Get users in db_owner, db_datareader and db_datawriter */
   SELECT LoginName = sysServerPrincipal.name ,
    SelectAccess = CASE WHEN sysDatabasePrincipalRole.name IN (
       'db_owner',
       'db_datareader' ) THEN 1
      ELSE 0
      END ,
    InsertAccess = CASE WHEN sysDatabasePrincipalRole.name IN (
       'db_owner',
       'db_datawriter' ) THEN 1
      ELSE 0
      END ,
    UpdateAccess = CASE WHEN sysDatabasePrincipalRole.name IN (
       'db_owner',
       'db_datawriter' ) THEN 1
      ELSE 0
      END ,
    DeleteAccess = CASE WHEN sysDatabasePrincipalRole.name IN (
       'db_owner',
       'db_datawriter' ) THEN 1
      ELSE 0
      END ,
    DBOAccess = CASE WHEN sysDatabasePrincipalRole.name = 'db_owner'
      THEN 1
      ELSE 0
     END ,
    SysadminAccess = 0
   FROM sys.database_principals AS sysDatabasePrincipalRole
    INNER JOIN sys.database_role_members AS sysDatabaseRoleMember ON sysDatabaseRoleMember.role_principal_id = sysDatabasePrincipalRole.principal_id
    INNER JOIN sys.database_principals AS sysDatabasePrincipalMember ON sysDatabasePrincipalMember.principal_id = sysDatabaseRoleMember.member_principal_id
    INNER JOIN sys.server_principals AS sysServerPrincipal ON sysServerPrincipal.sid = sysDatabasePrincipalMember.sid
   WHERE sysDatabasePrincipalRole.name IN ( 'db_owner',
        'db_datareader',
        'db_datawriter' )
    AND sysServerPrincipal.type_desc IN (
    'WINDOWS_LOGIN', 'WINDOWS_GROUP', 'SQL_LOGIN' )
    AND sysServerPrincipal.is_disabled = 0
   UNION ALL
  /* Get users in sysadmin */
   SELECT LoginName = sysServerPrincipalMember.name ,
    SelectAccess = 1 ,
    InsertAccess = 1 ,
    UpdateAccess = 1 ,
    DeleteAccess = 1 ,
    DBOAccess = 0 ,
    SysadminAccess = 1
   FROM sys.server_principals AS sysServerPrincipalRole
    INNER JOIN sys.server_role_members AS sysServerRoleMember ON sysServerRoleMember.role_principal_id = sysServerPrincipalRole.principal_id
    INNER JOIN sys.server_principals AS sysServerPrincipalMember ON sysServerPrincipalMember.principal_id = sysServerRoleMember.member_principal_id
   WHERE sysServerPrincipalMember.type_desc IN (
    'WINDOWS_LOGIN', 'WINDOWS_GROUP', 'SQL_LOGIN' )
    AND sysServerPrincipalMember.is_disabled = 0
  ) AS AccessSummary
  INNER JOIN master.dbo.syslogins AS syslogins ON syslogins.loginname = AccessSummary.LoginName
 WHERE AccessSummary.LoginName NOT IN ( 'NT SERVICE\MSSQLSERVER',
       'NT AUTHORITY\SYSTEM',
       'NT SERVICE\SQLSERVERAGENT' )
 GROUP BY AccessSummary.LoginName ,
  CASE WHEN syslogins.isntuser = 1 THEN 'WINDOWS_LOGIN'
   WHEN syslogins.isntgroup = 1 THEN 'WINDOWS_GROUP'
   ELSE 'SQL_USER'
  END;
  
  -- drop server audit
   
  USE [master]
  GO
  IF  EXISTS (SELECT * FROM sys.server_audits 
    WHERE name = N'MSSQL_Server_Audit')
  BEGIN
   ALTER SERVER AUDIT MSSQL_Server_Audit WITH (STATE = OFF) 
   DROP SERVER AUDIT [MSSQL_Server_Audit]
  END
  GO
   
   
  -- create server audit
   
  CREATE SERVER AUDIT [MSSQL_Server_Audit]
  TO FILE 
  (	FILEPATH = N'F:\\SQLAudit\'
  	,MAXSIZE = 200 MB
  	,MAX_ROLLOVER_FILES = 2
  	,RESERVE_DISK_SPACE = ON
  )
  WITH
  (	QUEUE_DELAY = 1000
  	,ON_FAILURE = CONTINUE
  )
  ALTER SERVER AUDIT [MSSQL_Server_Audit] WITH (STATE = ON)
GO

-- drop server audit specification
 
USE [master]
GO
 
IF  EXISTS (SELECT * FROM sys.server_audit_specifications 
  WHERE name = N'MSSQL_Server_Specification')
BEGIN
 ALTER SERVER AUDIT SPECIFICATION MSSQL_Server_Specification WITH (STATE = OFF) 
 DROP SERVER AUDIT SPECIFICATION [MSSQL_Server_Specification]
END
GO
 
 
 
/*
This section checks for the version of the SQL Server and creates the Server Audit Specification
*/
 
IF (SELECT cast(left(cast(serverproperty('productversion') as varchar), 4) as decimal(5, 3))) < 11 
BEGIN 
	--PRINT 'SQL 2008%'
 
	CREATE SERVER AUDIT SPECIFICATION [MSSQL_Server_Specification]
	FOR SERVER AUDIT [MSSQL_Server_Audit]
	ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP ),
	ADD (AUDIT_CHANGE_GROUP ),
	ADD (BACKUP_RESTORE_GROUP ),
	ADD (BROKER_LOGIN_GROUP ),
	ADD (DATABASE_CHANGE_GROUP),
	ADD (DATABASE_MIRRORING_LOGIN_GROUP ),
	ADD (DATABASE_OBJECT_ACCESS_GROUP ),
	ADD (DATABASE_OBJECT_CHANGE_GROUP ),
	ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP ),
	ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
	ADD (DATABASE_OPERATION_GROUP ),
	ADD (DATABASE_OWNERSHIP_CHANGE_GROUP),
	ADD (DATABASE_PERMISSION_CHANGE_GROUP ),
	ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
	ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP ),
	ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
	ADD (DBCC_GROUP ),
	ADD (FAILED_LOGIN_GROUP ),
	ADD (FULLTEXT_GROUP ),
	ADD (LOGIN_CHANGE_PASSWORD_GROUP),
	ADD (LOGOUT_GROUP ),
	ADD (SCHEMA_OBJECT_ACCESS_GROUP ),
	ADD (SCHEMA_OBJECT_CHANGE_GROUP ),
	ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP ),
	ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
	ADD (SERVER_OBJECT_CHANGE_GROUP ),
	ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP ),
	ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP),
	ADD (SERVER_OPERATION_GROUP ),
	ADD (SERVER_PERMISSION_CHANGE_GROUP ),
	ADD (SERVER_PRINCIPAL_CHANGE_GROUP),
	ADD (SERVER_PRINCIPAL_IMPERSONATION_GROUP ),
	ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
	ADD (SERVER_STATE_CHANGE_GROUP),
	ADD (SUCCESSFUL_LOGIN_GROUP ),
	ADD (TRACE_CHANGE_GROUP )
	WITH (STATE = ON)
	
	END 
 
ELSE 
 
	BEGIN 
 
	CREATE SERVER AUDIT SPECIFICATION [MSSQL_Server_Specification]
	FOR SERVER AUDIT [MSSQL_Server_Audit]
	ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP),
	ADD (AUDIT_CHANGE_GROUP),
	ADD (BACKUP_RESTORE_GROUP),
	ADD (BROKER_LOGIN_GROUP),
	ADD (DATABASE_CHANGE_GROUP ),
	ADD (DATABASE_LOGOUT_GROUP ),
	ADD (DATABASE_MIRRORING_LOGIN_GROUP),
	ADD (DATABASE_OBJECT_ACCESS_GROUP),
	ADD (DATABASE_OBJECT_CHANGE_GROUP),
	ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP),
	ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP ),
	ADD (DATABASE_OPERATION_GROUP),
	ADD (DATABASE_OWNERSHIP_CHANGE_GROUP ),
	ADD (DATABASE_PERMISSION_CHANGE_GROUP),
	ADD (DATABASE_PRINCIPAL_CHANGE_GROUP ),
	ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP),
	ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP ),
	ADD (DBCC_GROUP),
	ADD (FAILED_DATABASE_AUTHENTICATION_GROUP),
	ADD (FAILED_LOGIN_GROUP),
	ADD (FULLTEXT_GROUP),
	ADD (LOGIN_CHANGE_PASSWORD_GROUP ),
	ADD (LOGOUT_GROUP),
	ADD (SCHEMA_OBJECT_ACCESS_GROUP),
	ADD (SCHEMA_OBJECT_CHANGE_GROUP),
	ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP),
	ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP ),
	ADD (SERVER_OBJECT_CHANGE_GROUP),
	ADD (SERVER_OBJECT_OWNERSHIP_CHANGE_GROUP),
	ADD (SERVER_OBJECT_PERMISSION_CHANGE_GROUP ),
	ADD (SERVER_OPERATION_GROUP),
	ADD (SERVER_PERMISSION_CHANGE_GROUP),
	ADD (SERVER_PRINCIPAL_CHANGE_GROUP ),
	ADD (SERVER_PRINCIPAL_IMPERSONATION_GROUP),
	ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP ),
	ADD (SERVER_STATE_CHANGE_GROUP ),
	ADD (SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP),
	ADD (SUCCESSFUL_LOGIN_GROUP),
	ADD (TRACE_CHANGE_GROUP),
	ADD (USER_CHANGE_PASSWORD_GROUP),
	ADD (USER_DEFINED_AUDIT_GROUP)
	WITH (STATE = ON)
 
	
    END
    
    /*
    This section will iterate in every database and will create the database audit specifications 
     
    */
     
    IF (SELECT cast(left(cast(serverproperty('productversion') as varchar), 4) as decimal(5, 3))) < 11 
    BEGIN 
    	EXEC sp_MSforeachdb 'USE ? 
    	IF  EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = N''DatabaseAuditSpecification'')
    	BEGIN
    	 ALTER DATABASE AUDIT SPECIFICATION DatabaseAuditSpecification WITH (STATE = OFF)
    	 DROP DATABASE AUDIT SPECIFICATION DatabaseAuditSpecification
    	END
     
    	CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification]
    	FOR SERVER AUDIT [MSSQL_Server_Audit]
    	ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP ),
    	ADD (AUDIT_CHANGE_GROUP ),
    	ADD (BACKUP_RESTORE_GROUP ),
    	ADD (DATABASE_CHANGE_GROUP),
    	ADD (DATABASE_OBJECT_ACCESS_GROUP ),
    	ADD (DATABASE_OBJECT_CHANGE_GROUP ),
    	ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP ),
    	ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
    	ADD (DATABASE_OPERATION_GROUP ),
    	ADD (DATABASE_OWNERSHIP_CHANGE_GROUP),
    	ADD (DATABASE_PERMISSION_CHANGE_GROUP ),
    	ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
    	ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP ),
    	ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
    	ADD (DBCC_GROUP ),
    	ADD (SCHEMA_OBJECT_ACCESS_GROUP ),
    	ADD (SCHEMA_OBJECT_CHANGE_GROUP ),
    	ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP ),
    	ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP)
    	WITH (STATE = ON)'
    END
     
    ELSE 
     
    BEGIN
    	EXEC sp_MSforeachdb 'USE ? 
    	IF  EXISTS (SELECT * FROM sys.database_audit_specifications WHERE name = N''DatabaseAuditSpecification'')
    	BEGIN
    	 ALTER DATABASE AUDIT SPECIFICATION DatabaseAuditSpecification WITH (STATE = OFF)
    	 DROP DATABASE AUDIT SPECIFICATION DatabaseAuditSpecification
    	END
     
    	CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification]
    	FOR SERVER AUDIT [MSSQL_Server_Audit]
    	ADD (APPLICATION_ROLE_CHANGE_PASSWORD_GROUP ),
    	ADD (AUDIT_CHANGE_GROUP ),
    	ADD (BACKUP_RESTORE_GROUP ),
    	ADD (DATABASE_CHANGE_GROUP),
    	ADD (DATABASE_LOGOUT_GROUP),
    	ADD (DATABASE_OBJECT_ACCESS_GROUP ),
    	ADD (DATABASE_OBJECT_CHANGE_GROUP ),
    	ADD (DATABASE_OBJECT_OWNERSHIP_CHANGE_GROUP ),
    	ADD (DATABASE_OBJECT_PERMISSION_CHANGE_GROUP),
    	ADD (DATABASE_OPERATION_GROUP ),
    	ADD (DATABASE_OWNERSHIP_CHANGE_GROUP),
    	ADD (DATABASE_PERMISSION_CHANGE_GROUP ),
    	ADD (DATABASE_PRINCIPAL_CHANGE_GROUP),
    	ADD (DATABASE_PRINCIPAL_IMPERSONATION_GROUP ),
    	ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),
    	ADD (DBCC_GROUP ),
    	ADD (FAILED_DATABASE_AUTHENTICATION_GROUP ),
    	ADD (SCHEMA_OBJECT_ACCESS_GROUP ),
    	ADD (SCHEMA_OBJECT_CHANGE_GROUP ),
    	ADD (SCHEMA_OBJECT_OWNERSHIP_CHANGE_GROUP ),
    	ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP),
    	ADD (SUCCESSFUL_DATABASE_AUTHENTICATION_GROUP ),
    	ADD (USER_CHANGE_PASSWORD_GROUP ),
    	ADD (USER_DEFINED_AUDIT_GROUP )
    	WITH (STATE = ON)'
END


SELECT  TOP 100 *
FROM    sys.fn_get_audit_file('E:\\SQLAudit\MSSQL_Server_Audit*.sqlaudit',
                              DEFAULT, DEFAULT)
ORDER BY event_time DESC;

SELECT TOP 10
        action_id ,
        name
FROM    sys.dm_audit_actions;


SELECT  COUNT(*) ActionsCount ,
        f.action_id ,
        a.name ,
        a.class_desc
FROM    sys.fn_get_audit_file('E:\\SQLAudit\MSSQL_Server_Audit*.sqlaudit',
                              DEFAULT, DEFAULT) f
        JOIN sys.dm_audit_actions a ON a.action_id = f.action_id
GROUP BY f.action_id ,
        a.name ,
        a.class_desc;