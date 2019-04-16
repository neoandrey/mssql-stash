USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[get_dates_in_range]    Script Date: 04/10/2016 11:44:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[get_dates_in_range]
(
     @StartDate    VARCHAR(30)  
    ,@EndDate    VARCHAR(30)   
)
RETURNS
@DateList table
(
    Date datetime
)
AS
BEGIN


IF ISDATE(@StartDate)!=1 OR ISDATE(@EndDate)!=1
BEGIN
    RETURN
END

while (DATEDIFF(D,  @StartDate,@EndDate)>=0) BEGIN 

INSERT INTO @DateList
        (Date)
    SELECT
        @StartDate
SET  @StartDate = DATEADD(D, 1 ,@StartDate);
        END


RETURN
END
GO


