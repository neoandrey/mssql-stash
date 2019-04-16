USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_update_transmit_state]    Script Date: 06/04/2014 13:54:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_update_transmit_state]
	@id 			BIGINT,
	@time_sent		DATETIME,
	@nr_sent		INT
AS
BEGIN
	UPDATE 	inject_trans
	SET	state = 0,
		time_sent = @time_sent,
		nr_sent = @nr_sent
	WHERE	id = @id
	
END

GO


