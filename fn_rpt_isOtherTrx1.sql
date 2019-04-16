USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isOtherTrx]    Script Date: 04/29/2015 20:47:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER    FUNCTION  [dbo].[fn_rpt_isOtherTrx] (@tran_type CHAR (2))
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










