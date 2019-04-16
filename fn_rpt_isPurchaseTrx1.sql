ALTER      FUNCTION  [dbo].[fn_rpt_isPurchaseTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '02' AND '19') OR @tran_type = '00')-- OR @tran_type = '50' OR (@tran_type BETWEEN '52' AND '59'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END
