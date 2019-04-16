DECLARE  @count_table  TABLE (tran_date  VARCHAR(8), office_89_count   BIGINT, office_94_count BIGINT, big_difference BIGINT) 
DECLARE  @start_date   VARCHAR(8)
DECLARE  @end_date  VARCHAR(8)

SELECT  @start_date = '20180601', @end_date = convert(varchar(8), GETDATE(),112)

WHILE  (DATEDIFF(D, @start_date,@end_date)>=0) BEGIN
INSERT INTO @count_table 

select  tran_date, office_89_count,office_94_count, office_94_count - office_89_count FROM ( 
select tran_date =  @start_date,   office_89_count=(SELECT  count(datetime_req)  FROM  [172.25.10.89].[postilion_office].dbo.post_tran WITH(NOLOCK) WHERE CONVERT(DATE,datetime_req) =@start_date),  
office_94_count = (SELECT  count(datetime_req)  FROM  [172.25.10.94].[postilion_office].dbo.post_tran WITH(NOLOCK) WHERE CONVERT(DATE,datetime_req) =@start_date)
)S

SET   @start_date =convert(varchar(8),  DATEADD(DAY, 1, @start_date),112)
END


select  * from  @count_table