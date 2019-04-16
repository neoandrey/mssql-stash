DECLARE @current_user VARCHAR(250)

DECLARE user_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT name FROM master.dbo.syslogins ;

OPEN user_cursor;

FETCH NEXT FROM user_cursor INTO @current_user;

WHILE (@@FETCH_STATUS=0) BEGIN

exec sp_change_users_login 'AUTO_FIX',  @current_user ,NULL, NULL;

FETCH NEXT FROM user_cursor INTO @current_user;

END

CLOSE user_cursor;

DEALLOCATE user_cursor;