USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_insert_transmission]    Script Date: 06/04/2014 13:42:15 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

---------------------------- Stored Procedures ---------------------------- 

--------------------------------------------------------------------------------
-- Create placeholder_postinject_insert_transmission.                          
-------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[postinject_insert_transmission]
	@interchange_name		VARCHAR(20)

AS
BEGIN
	
	INSERT INTO inject_transmission 
	(
		interchange_name,
		start_time
	)
	VALUES
	(
		@interchange_name,
		GETDATE()
	)
	
	DECLARE @l_next_transmission_id AS BIGINT
	SET @l_next_transmission_id = SCOPE_IDENTITY()
	
	SELECT @l_next_transmission_id
	
END

GO


