/****** Script for SelectTopNRows command from SSMS  ******/
declare @max_req_datetime DATETIME 
declare @max_transaction_id BIGINT

declare @last_month_req_datetime DATETIME 
declare @last_month_transaction_id BIGINT

SELECT   @max_req_datetime = max(req_datetime)
  FROM [vtucare].[dbo].[tbl_transactions] (NOLOCK)

SELECT @max_transaction_id = transaction_id   FROM [vtucare].[dbo].[tbl_transactions] (NOLOCK)  WHERE req_datetime =@max_req_datetime 

SELECT @last_month_req_datetime  = CONVERT(DATE,DATEADD(m, -1, @max_req_datetime ))

Select top 1   @last_month_transaction_id  =transaction_id  from tbl_transactions (NOLOCK) WHERE req_datetime >= @last_month_req_datetime order by req_datetime


-- select @last_month_transaction_id, @max_transaction_id

SELECT * FROM [vtucare].[dbo].[tbl_transactions] (NOLOCK) WHERE transaction_id between 

 @last_month_transaction_id		and  @max_transaction_id