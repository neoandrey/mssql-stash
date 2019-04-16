USE [postilion_office]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[osp_rpt_card_activity_speed_dated]
		@MaskedPAN = N'628051*********2487',
		@fullpan = N'6280512307620002487',
		@StartDate = N'20170901',
		@EndDate = N'20171222'

SELECT	'Return Value' = @return_value

GO 