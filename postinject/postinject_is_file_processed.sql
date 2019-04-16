USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_is_file_processed]    Script Date: 06/04/2014 13:42:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_is_file_processed]
	@file_name		VARCHAR(255),
	@file_date_time 	CHAR(12)
AS
BEGIN
	SELECT
		file_name, 
		file_date_time
	FROM
		inject_incoming_files
	WHERE	file_name	= @file_name
	AND 	file_date_time 	= @file_date_time
	AND	end_time 	IS NOT NULL
END

GO


