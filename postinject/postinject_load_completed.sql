USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_load_completed]    Script Date: 06/04/2014 13:43:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--------------------------------------------------------------------------------
-- Create placeholder_postinject_load_completed.                          
-------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[postinject_load_completed]
	@transmission_id		INT
AS
BEGIN
	
	UPDATE 	inject_transmission 
	SET 	load_end_time = GETDATE(),
		load_completed = 1
	WHERE 	transmission_id = @transmission_id
	
END

GO

