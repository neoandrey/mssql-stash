USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_get_current_transmission]    Script Date: 06/04/2014 13:38:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_get_current_transmission]
	@interchange_name		VARCHAR(20)
AS
BEGIN
	
	SELECT	 transmission_id 
	FROM	 inject_transmission
	WHERE	 end_time IS NULL 
	AND	 interchange_name = @interchange_name
	
END

GO


