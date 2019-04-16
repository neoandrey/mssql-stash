USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isCreditTrx]    Script Date: 04/29/2015 17:16:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

--
-- Returns 1 if the transaction type is a non-deposit credit transaction type
--

ALTER  FUNCTION  [dbo].[fn_rpt_isCreditTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '20' AND '29') AND @tran_type NOT IN ('21', '23', '24'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END
