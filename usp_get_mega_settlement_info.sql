
CREATE PROCEDURE usp_get_mega_settlement_info (@settlement_date DATETIME)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SET @settlement_date = ISNULL(@settlement_date, CONVERT(DATE, DATEADD(D, -1, GETDATE())))
SELECT  * FROM settlement_summary_breakdown_Mega  (nolock) where trxn_date = @settlement_date
 AND
  trxn_category <> 'unk' 
  OPTION (RECOMPILE)

END