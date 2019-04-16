DECLARE @current_user VARCHAR(250)

DECLARE user_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR SELECT name FROM  postilion_office.dbo.sysusers;

OPEN user_cursor;

FETCH NEXT FROM user_cursor INTO @current_user;

WHILE (@@FETCH_STATUS=0) BEGIN

IF NOT EXISTS (SELECT name FROM master.dbo.syslogins WHERE name=@current_user) BEGIN

EXEC sp_addlogin @current_user, 'Password123', 'postilion_office'

exec sp_change_users_login 'AUTO_FIX',  @current_user ,NULL, 'Password123';

END

FETCH NEXT FROM user_cursor INTO @current_user;

END

CLOSE user_cursor;

DEALLOCATE user_cursor;