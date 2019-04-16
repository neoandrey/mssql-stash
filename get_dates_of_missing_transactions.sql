DECLARE @start_date DATETIME;
DECLARE @end_date DATETIME;
DECLARE @date_diff INT;
DECLARE @trans_count INT;

DECLARE @missing_dates TABLE (transaction_date DATETIME);

WHILE (@start_date <= @end_date)
	BEGIN
	 select @trans_count = COUNT(post_tran_id) FROM post_tran (NOLOCK) WHERE datetime_req BETWEEN  DATEADD(D, 0, DATEDIFF(D, 0, @start_date)) AND DATEADD(D, 1, DATEDIFF(D, 0, @start_date))
	 
	 IF(@trans_count=0)
	  BEGIN
	     INSERT INTO @missing_dates VALUES (@start_date)
	     
	     SELECT @start_date=DATEADD(D, 1, DATEDIFF(D, 0, @start_date));
	  
	  END
	
	
	
	END