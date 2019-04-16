DECLARE @start_date DATETIME
declare @end_date DATETIME
SET   @start_date = '20160801'
SET  @end_date ='20160901';

DECLARE @SQL varchar(MAX)


WHILE   (@start_date <=@end_date)  BEGIN
set @SQL = 'INSERT INTO  [tpp_processing].[dbo].[switched_out]
            SELECT * FROM  OPENQUERY([172.25.10.9], ''[dbo].[tpp_switched_out] @start_date ='''''+CONVERT(varchar(12), @start_date, 112)+''''', @end_date ='''''+CONVERT(varchar(12),@start_date,112)+''''';'')';
PRINT @SQL
exec(@SQL);

SET  @start_date= DATEADD(d,1, @start_date)
END 
