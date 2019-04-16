
CREATE FUNCTION  [dbo].[fn_rpt_late_reversal] 

  (@tran_nr bigint,@message_type char (4),@retrieval_reference_nr varchar(20))
	RETURNS varchar
AS
BEGIN
	DECLARE @r varchar
	SET @r = 0
	IF(@message_type = '0420') begin
	IF EXISTS (SELECT TOP 1 post_tran_id from tbl_late_reversals (NOLOCK) WHERE tran_nr =@tran_nr AND retrieval_reference_nr =@retrieval_reference_nr  ) BEGIN
		--SET @r = 1
		SET @r = 1

     END

	end
		RETURN @r
END

 