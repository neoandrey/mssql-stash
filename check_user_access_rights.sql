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
   end