

DECLARE @start_date DATETIME;
DECLARE @date_cursor DATETIME;
DECLARE @end_date DATETIME;

SET @start_date = '20140306';
SET @end_date = '20140316'

SET @date_cursor =  DATEADD(D, 1, DATEDIFF(D, 0,@start_date))

WHILE (@date_cursor <= @end_date) 
	BEGIN

		EXEC osp_swtrpt_fep_all_channels_report
		@StartDate =@start_date
		,@EndDate =@date_cursor
		,@Period= 'Daily'

            SET @date_cursor =  DATEADD(D, 1, DATEDIFF(D, 0,@start_date))
    END
 