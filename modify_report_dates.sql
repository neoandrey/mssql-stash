DECLARE	@return_value int

EXEC	@return_value = [dbo].[modify_crystal_report_date]
		@startDate = N'20160826',
		@endDate = N'20160826',
		@reset = 1

SELECT	'Return Value' = @return_value

GO