 IF (OBJECT_ID('tempdb.dbo.#size_period_table') IS NOT NULL) BEGIN
	DROP TABLE #size_period_table
 END

SELECT  DBNAME = DB_NAME(database_id) ,  TOTAL_SIZE =(SUM(size)*8.0)/(1024.0) - (select SUM ( convert(decimal(12,2),round((a.size-fileproperty(a.name,'SpaceUsed'))/128.000,2))) FROM dbo.sysfiles a) ,
        NUMBER_OF_DAYS  =  DATEDIFF(D,(SELECT MIN(datetime_req) FROM post_tran (NOLOCK)),(SELECT MAX(datetime_req) FROM post_tran (NOLOCK)))
		into #size_period_table
 FROM sys.master_files WHERE  DB_NAME(database_id)  ='postilion_office'
GROUP BY database_id
select *,  SIZE_PER_DAY= convert(varchar(30), convert(decimal(12,2),TOTAL_SIZE/ NUMBER_OF_DAYS))+'MB' from  #size_period_table

