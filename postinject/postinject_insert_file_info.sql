USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_insert_file_info]    Script Date: 06/04/2014 13:40:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_insert_file_info]
	@file_name		VARCHAR(255),
	@file_date_time 	CHAR(12)
AS
BEGIN
	IF EXISTS (SELECT * FROM inject_incoming_files WHERE file_name = @file_name AND file_date_time  = @file_date_time)
	
	BEGIN
	
		UPDATE 	inject_incoming_files
		SET	begin_time 	= GETDATE()
		WHERE	file_name	= @file_name
		AND 	file_date_time 	= @file_date_time
	
	END

	ELSE
	
	BEGIN

		INSERT INTO
			inject_incoming_files(file_name, file_date_time, begin_time)
		VALUES
			(@file_name, @file_date_time, GETDATE())
			
	END
END

GO


