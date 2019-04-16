DECLARE @start_date DATETIME
DECLARE @end_time DATETIME

DECLARE @count_table TABLE (tran_date DATETIME , TRAN_COUNT INT)

SET @start_date = CONVERT(date, DATEADD(D,-10, GETDATE()))
SET @end_time = CONVERT(date,GETDATE())

WHILE (DATEDIFF(D, @start_date,@end_time) >=0)BEGIN
   INSERT INTO @count_table SELECT @start_date, COUNT(recon_business_date) FROM post_tran (NOLOCK, INDEX(ix_post_tran_9))
   WHERE 
recon_business_date = @start_date
	SET @start_date = DATEADD(D, 1,@start_date)
END

select * from  @count_table
