USE [postilion_office]
GO

DECLARE	@return_value int

EXEC	@return_value = [dbo].[osp_sstl_jrnl_man_reset]

SELECT	'Return Value' = @return_value

GO
