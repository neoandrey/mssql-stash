DECLARE  @user_name sysname, @revoke_cmd  nvarchar(500) , @deny_cmd nvarchar(500) 

DECLARE UserCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY for SELECT name FROM postilion_office.dbo.sysusers WHERE NAME NOT IN(SELECT name FROM master.dbo.sysusers) AND NAME NOT IN('yemi.sulaiman','obehi.timothy')

open UserCursor 

fetch next from UserCursor INTO @user_name 

while @@fetch_status = 0 
begin 
    PRINT 'Removing access for: '+ @user_name+'....' 
    PRINT CHAR(10) 
    
        set @revoke_cmd ='REVOKE  SELECT, INSERT, UPDATE, DELETE ON tbl_merchant_account  TO [' + @user_name+']' 

    exec (@revoke_cmd)
    set @deny_cmd =   'DENY   SELECT, INSERT, UPDATE, DELETE ON tbl_merchant_account  TO [' + @user_name+']' 

    exec (@deny_cmd) 
    PRINT 'Access removed.' 
      PRINT CHAR(10) 

    fetch next from UserCursor 
    into @user_name 
end 

close UserCursor 
deallocate UserCursor 

