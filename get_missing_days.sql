DECLARE @startDate DATETIME;
SET @startDate =  '2013-04-10 23:59:48.287';
DECLARE @endDate DATETIME; 
SET @endDate ='2014-09-15 10:03:32.463';
DECLARE @currentDate DATETIME;
DECLARE @transDayCount INT;
DECLARE @missingDate VARCHAR(1000);

SET @currentDate = '2013-04-10'

WHILE (DATEDIFF(D,@currentDate,@endDate )>=0) BEGIN

IF EXISTS (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK) WHERE recon_business_date =@currentDate)BEGIN
	SET @transDayCount= @transDayCount+1;
END
ELSE BEGIN

SET @missingDate =@missingDate+','+@currentDate;

END

SET @currentDate = DATEADD(D,1, @currentDate);

END


SELECT @missingDate missing_dates, @transDayCount transaction_days_count