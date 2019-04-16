DECLARE @startDate VARCHAR(25);
DECLARE @endDate VARCHAR(25);

SET @startDate = '2017-09-17';
SET @endDate   = '2017-09-17';

exec psp_settlement_summary_breakdown
	@start_date =@startDate,
        @end_date =@endDate,
        @report_date_start = NULL,
	@report_date_end = NULL,
	@rpt_tran_id = NULL,
    @rpt_tran_id1 = NULL

exec [dbo].[psp_settlement_summary_breakdown_reward]
	@start_date =@startDate,
        @end_date =@endDate;