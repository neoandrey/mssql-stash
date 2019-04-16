USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isTransferTrx]    Script Date: 04/29/2015 21:01:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER    FUNCTION  [dbo].[fn_rpt_isTransferTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type BETWEEN '40' AND '49')
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END










