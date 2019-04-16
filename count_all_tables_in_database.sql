declare @query as Nvarchar(4000)
declare @dbname as Nvarchar(4000)
SET @query=''
SET @dbname ='postilion_office'
create table #temp_table (table_name VARCHAR(1000), row_count BIGINT)
SET @query =@query + @dbname + '..sp_msforeachtable ''INSERT INTO  #temp_table (table_name, row_count)select ''''?'''' as ''''Table'''', count(*) as ''''Rows'''' from ? '''
EXEC sp_executesql @query

SELECT * FROM #temp_table

DROP TABLE #temp_table