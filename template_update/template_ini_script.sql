DECLARE @file_path VARCHAR(255)
DECLARE @ini_file VARCHAR(255)
DECLARE @user_params VARCHAR(MAX)

DECLARE @command  VARCHAR(MAX) 

SET @file_path = 'C:\TEMP\INI\';
DECLARE ini_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY  FOR SELECT REPLACE (SUBSTRING(template, LEN(template)-(CHARINDEX('\', REVERSE(template))-2), LEN(template)), 'rpt', 'ini'), user_params_defs  FROM REPORTS_CRYSTAL_TEMPLATE
OPEN ini_cursor;
FETCH NEXT FROM ini_cursor INTO @ini_file, @user_params
WHILE (@@FETCH_STATUS =0)BEGIN
set @command ='printf "%s ' + REPLACE(@user_params, CHAR(13)+CHAR(10),'\n')+'">"'+ @file_path+@ini_file+'"'
print @command+char(10)
--exec master.dbo.xp_cmdshell @command

FETCH NEXT FROM ini_cursor INTO @ini_file, @user_params
END
CLOSE ini_cursor
DEALLOCATE ini_cursor
