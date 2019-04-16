USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isDepositTrx]    Script Date: 04/29/2015 20:38:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





ALTER    FUNCTION  [dbo].[fn_rpt_isDepositTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type IN ('21', '23', '24', '51'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END
