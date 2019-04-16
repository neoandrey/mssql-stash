USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_encrypt_pan]    Script Date: 08/30/2016 10:24:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_encrypt_pan]
	@pan		VARCHAR (19),		-- The pan field to be encrypted. From post_tran_cust.pan
	@process_descr	VARCHAR (100), 		-- A description of the process that is calling this procedure (for error handling purposes)
	@pan_encrypted	CHAR (18)	OUTPUT,
	@error		INT		OUTPUT	-- If > 0, an error has occurred
AS
BEGIN
	-- If we need to encrypt, encrypt PAN
	IF ((@pan IS NOT NULL) AND (@pan_encrypted IS NULL))
	BEGIN
		DECLARE @error_msg VARCHAR(MAX)
		IF EXISTS(SELECT 1 FROM sys.sysobjects WHERE type = 'PC' AND name='osp_encrypt_pan_clr')
		BEGIN
			EXEC osp_encrypt_pan_clr
				@pan,
				@pan_encrypted OUTPUT,
				@error_msg OUTPUT
			
			IF @error_msg IS NOT NULL
			BEGIN
				SET @error = 1
				SET @error_msg = 'An error occurred during an encrypt operation for the ' + @process_descr + ' process. The error that occurred was: ' + @error_msg
				RAISERROR(@error_msg,16,1) 
			END
		END
		ELSE
		BEGIN
			EXEC osp_encrypt_pan_com
				@pan,
				@process_descr,
				@pan_encrypted OUTPUT,
				@error OUTPUT
		END
	END
	ELSE
	BEGIN
		SET @pan_encrypted = @pan
	END
END

GO


