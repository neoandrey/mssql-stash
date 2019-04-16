USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_update_abort_state]    Script Date: 06/04/2014 13:46:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_update_abort_state]
	@id 			BIGINT
AS
BEGIN
	UPDATE 	inject_trans
	SET	state = 2
	WHERE	id = @id	
END

GO


