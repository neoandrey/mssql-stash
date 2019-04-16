USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_check_load_err]    Script Date: 06/04/2014 13:36:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create placeholder_postinject_load_completed.                          
-------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[postinject_check_load_err]
	@interchange_name	VARCHAR(20),
	@transmission_id		INT
AS
BEGIN
	DECLARE @current_time		DATETIME
	SELECT	@current_time		= GETDATE()

	IF EXISTS(
		SELECT	* 
		FROM 	inject_transmission
		WHERE 	inject_transmission.load_end_time IS NULL
		AND	inject_transmission.transmission_id <> @transmission_id
		AND	inject_transmission.interchange_name = @interchange_name)
	BEGIN

		UPDATE 	inject_trans
		SET	inject_trans.state = 3
		FROM 	inject_trans, inject_transmission
		WHERE 	inject_trans.transmission_id = inject_transmission.transmission_id 
		AND 	inject_transmission.load_end_time IS NULL
		AND	inject_transmission.transmission_id <> @transmission_id
		AND	inject_transmission.interchange_name = @interchange_name
		
		UPDATE 	inject_transmission
		SET	load_end_time = @current_time,
			load_completed = 0
		WHERE 	inject_transmission.load_end_time IS NULL
		AND	inject_transmission.transmission_id <> @transmission_id
		AND	inject_transmission.interchange_name = @interchange_name
	
	END

	--Return a list of transmissions that did not complete the load process
	SELECT	inject_transmission.transmission_id
	FROM	inject_transmission
	WHERE	inject_transmission.load_completed = 0
	AND	inject_transmission.load_end_time = @current_time
	AND	transmission_id IN
		(SELECT transmission_id FROM inject_trans WHERE state = 3)
		
END

GO


