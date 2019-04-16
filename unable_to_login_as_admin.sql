Stop SQL Service: on the command line type: net stop MSSQLServer
Start the SQL Server in Management mode: on the command line type: net start MSSQLServer /m
Open the SQL Server management studio, cancel the login dialog
Open new sql server engine query window: from the menu, Click file->new->Database engine query
Enable SA account if not enabled: in the query window type: Alter login sa enable
Set the password of the sa account: alter login sa with password=’my password’
Stop the SQL server from the command line: net stop MSSQlServer
Start SQL Service from the command line: net start mssqlserver
Start the SQL Management studio and connect to the server using sa account
Add you domain administrator as sysadmin
Disable the sa account when you finish



 Alter login sa enable

Alter login sa  with password='Passcode1$'

SELECT * FROM sys.sysusers
sp_helpuser


CREATE LOGIN reportadmin WITH PASSWORD = 'report.admin12';
GO

EXEC master..sp_addsrvrolemember @loginame = N'reportadmin', @rolename = N'sysadmin'
GO