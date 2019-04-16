DECLARE  @username sysname, @query nvarchar(500)

DECLARE UserCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY for SELECT name FROM postilion_office.dbo.sysusers WHERE NAME NOT IN(SELECT name FROM master.dbo.sysusers) AND NAME NOT IN('yemi.sulaiman','obehi.timothy','emeka.awagu')
open UserCursor

fetch next from UserCursor
into @username

while @@fetch_status = 0
begin
    PRINT 'Removing access for: '+ @username+'....'
    PRINT CHAR(10)
    
     SET @query = 'sp_dropsrvrolemember @loginame = ['+@username+'], @rolename =sysadmin'
    exec(@query);
    

SET @query = N'DENY ALTER ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);

SET @query = N'DENY CONTROL ON [dbo].[tbl_merchant_account] TO ['+@username+']';

exec(@query);


SET @query = N'DENY DELETE ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);



SET @query = N'DENY INSERT ON [dbo].[tbl_merchant_account] TO ['+@username+']';

exec(@query);


--SET @query = N'DENY SELECT ON [dbo].[tbl_merchant_account] TO ['+@username+']';
--exec(@query);



SET @query = N'DENY TAKE OWNERSHIP ON [dbo].[tbl_merchant_account] TO ['+@username+']';

exec(@query);


SET @query = N'DENY UPDATE ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);



SET @query = N'DENY VIEW CHANGE TRACKING ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);



SET @query = N'DENY VIEW DEFINITION ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);

SET @query = 'sp_addrolemember N''db_owner'', ['+@username+']';
EXEC(@query);
SET @query = 'sp_addrolemember N''postapp'', ['+@username+']';
EXEC(@query);
SET @query = 'sp_addrolemember N''postaudit'', ['+@username+']';
EXEC(@query);
SET @query = 'sp_addrolemember N''postcfg'', ['+@username+']';
EXEC(@query);
SET @query = 'sp_addrolemember N''postmon'', ['+@username+']';
EXEC(@query);
SET @query = 'sp_addrolemember N''db_owner'', ['+@username+']';
EXEC(@query);
SET @query = 'sp_addrolemember N''postparticipant'', ['+@username+']';
EXEC(@query);
SET @query = 'sp_change_users_login ''Update_One'', ['+@username+'], ['+@username+']';
EXEC(@query);

PRINT 'Access removed.'
PRINT CHAR(10)

    fetch next from UserCursor
    into @username
end

CLOSE UserCursor
DEALLOCATE UserCursor