USE postilion_office

DECLARE  @username sysname, @query nvarchar(500)

DECLARE UserCursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY for SELECT name FROM postilion_office.dbo.sysusers WHERE NAME NOT IN(SELECT name FROM master.dbo.sysusers) AND NAME NOT IN('yemi.sulaiman','obehi.timothy','emeka.awagu', 'chioma.odiaka','adeola.fadahunsi','ebun.reffell','eloho.ogude','frank.atashili','joseph.aka','mariam.olatunji','mobolaji.aina','uriri.ukrakpor','eseosa.osaikhuiwu', 'imiemike.ameh','xls_user')
OPEN UserCursor

fetch next from UserCursor
into @username

while @@fetch_status = 0
begin
    PRINT 'Removing access for: '+ @username+'....'
    PRINT CHAR(10)
    
    SET @query = 'master..sp_dropsrvrolemember @loginame = ['+@username+'], @rolename =''sysadmin''';
    EXEC(@query);
    

SET @query = N'DENY ALTER ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);

SET @query = N'DENY CONTROL ON [dbo].[tbl_merchant_account] TO ['+@username+']';

exec(@query);


SET @query = N'DENY DELETE ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);



SET @query = N'DENY INSERT ON [dbo].[tbl_merchant_account] TO ['+@username+']';

exec(@query);


SET @query = N'DENY TAKE OWNERSHIP ON [dbo].[tbl_merchant_account] TO ['+@username+']';

exec(@query);


SET @query = N'DENY UPDATE ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);



SET @query = N'DENY VIEW CHANGE TRACKING ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);



SET @query = N'DENY VIEW DEFINITION ON [dbo].[tbl_merchant_account] TO ['+@username+']';
exec(@query);


    PRINT 'Access removed.'
      PRINT CHAR(10)

    fetch next from UserCursor
    into @username
end

close UserCursor
deallocate UserCursor