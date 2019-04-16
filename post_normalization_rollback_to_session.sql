SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


CREATE PROCEDURE post_normalization_rollback_to_session (@normalization_session_id BIGINT)
AS
BEGIN
	SET NOCOUNT ON

	-- Hard-coded segment_size
	DECLARE @segment_size	INT
	SET @segment_size = 10000

	-- Get the previous normalization session id
	SELECT
		@normalization_session_id = normalization_session_id
	FROM
		post_normalization_session
	WHERE   
		normalization_session_id = @normalization_session_id 

	-- If there is no Normalization session to rollback, exit with success
	IF @normalization_session_id IS NULL
	BEGIN
		RETURN
	END

	-- find the tran_nr associated with the previous normalization session
	DECLARE
		@first_post_tran_id			BIGINT,
		@first_post_tran_cust_id	BIGINT

	DECLARE @error						INT

	SELECT
		@first_post_tran_id = first_post_tran_id,
		@first_post_tran_cust_id = first_post_tran_cust_id
	FROM
		post_normalization_session
	WHERE
		normalization_session_id = @normalization_session_id

	EXEC osp_norm_delete_tran @first_post_tran_cust_id,
			@first_post_tran_id,
			@normalization_session_id,
			@segment_size

	DELETE FROM
		post_norm_rtfw_session
	WHERE
		session_id >= @normalization_session_id


	DELETE FROM
		post_normalization_session
	WHERE
		normalization_session_id >= @normalization_session_id
END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

