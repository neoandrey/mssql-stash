USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_update_file_info]    Script Date: 06/04/2014 13:46:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_update_file_info]
	@file_name		VARCHAR(255),
	@file_date_time 	CHAR(12),
	@no_of_records		CHAR(10)
AS
BEGIN
	UPDATE	inject_incoming_files
	SET
		no_of_records 	= @no_of_records,
		end_time	= GETDATE()
	WHERE	file_name	= @file_name
	AND 	file_date_time 	= @file_date_time
		
END

GO


