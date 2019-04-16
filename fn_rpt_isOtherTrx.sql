if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isOtherTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isOtherTrx]
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE  FUNCTION  dbo.fn_rpt_isOtherTrx (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type BETWEEN '60' AND '99')
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO