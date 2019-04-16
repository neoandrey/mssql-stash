USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_end_transmission]    Script Date: 06/04/2014 13:38:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_end_transmission]
	@interchange_name		VARCHAR(20),
	@transmission_id		INT
AS
BEGIN
	
	UPDATE 	inject_transmission 
	SET 	end_time = GETDATE()
	WHERE 	transmission_id = @transmission_id
	
END

GO


