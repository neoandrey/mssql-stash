DECLARE @startDate DATETIME;
SET     @startDate =  '2013-04-10 23:59:48.287';
DECLARE @endDate DATETIME; 
SET     @endDate ='2014-09-15 13:10:31.247';
DECLARE @currentDate DATETIME;
DECLARE @transDayCount INT;
SET     @transDayCount= 0;
DECLARE @missingDate VARCHAR(1000);

SET @currentDate = '2013-04-10';
SET @missingDate = ''

WHILE (DATEDIFF(D,@currentDate,@endDate )>=0) BEGIN
	IF EXISTS (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK) WHERE recon_business_date =@currentDate)
	BEGIN
		PRINT CHAR(10)+'Transactions exist for: '+CONVERT(VARCHAR(100),@currentDate);
		SET @transDayCount= @transDayCount+1;
	END
	ELSE BEGIN
	SET @missingDate =CONVERT(VARCHAR(100),@missingDate)+','+CONVERT(VARCHAR(100),@currentDate);
	END
	SET @currentDate = DATEADD(D,1, @currentDate);
END
SELECT @missingDate =SUBSTRING(@missingDate,2, LEN(@missingDate));

SELECT @missingDate as 'missing_dates', @transDayCount as 'transaction_days_count';