DECLARE @startDate DATETIME
DECLARE @endDate DATETIME
DECLARE @interval INT
DECLARE @days_from_beg INT
DECLARE @intervalCheckTable TABLE (fileDate DATETIME, daysFromBeg INT)


SET @startDate ='20150101';
SET @endDate ='20151231';
SET @interval = 12;
set @days_from_beg = 0
WHILE DATEDIFF (D,@startDate,@endDate)>0 BEGIN

INSERT INTO @intervalCheckTable (fileDate,daysFromBeg ) VALUES(@startDate,@days_from_beg);


SET  @startDate= DATEADD(D,@interval ,@startDate);
SET @days_from_beg =@days_from_beg+12;
END

SELECT * FROM @intervalCheckTable