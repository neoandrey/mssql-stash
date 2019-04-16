DECLARE @no_of_days_behind INT
DECLARE @startDate DATETIME
DECLARE @endDate DATETIME
DECLARE @today DATETIME

SET @today = DATEADD(D,0, DATEDIFF(D,0,GETDATE()));

SET @no_of_days_behind =2;

SET @no_of_days_behind = -1 * @no_of_days_behind;

SET @startDate = DATEADD(D, @no_of_days_behind, @today);

SET @endDate = @startDate;

SET @startDate =DATEADD(HOUR,12, @startDate);

SET @endDate = DATEADD(D, 1,@endDate)

SET @endDate =DATEADD(HOUR,11, @endDate);
SET @endDate =DATEADD(MINUTE,59, @endDate);
SET @endDate =DATEADD(SECOND,59, @endDate);
