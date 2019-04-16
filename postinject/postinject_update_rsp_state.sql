USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_update_rsp_state]    Script Date: 06/04/2014 13:53:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_update_rsp_state]
	@id 			BIGINT,
	@time_rsp		DATETIME,
	@rsp_code		CHAR(2)
AS
BEGIN
	UPDATE 	inject_trans
	SET	state = 1, 
		time_rsp = @time_rsp,
		rsp_code = @rsp_code
	WHERE	id = @id	
END

GO


