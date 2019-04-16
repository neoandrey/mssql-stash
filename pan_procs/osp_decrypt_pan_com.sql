USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_decrypt_pan_com]    Script Date: 08/30/2016 10:25:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_decrypt_pan_com]
	@pan		VARCHAR (19),		-- The pan to be decrypted
	@pan_encrypted	CHAR (18),		-- The pan_encrypted field. From post_tran_cust.pan_encrypted
	@process_descr	VARCHAR (100),		-- A description of the process that is calling this procedure (for error handling purposes)
	@pan_decrypted	VARCHAR (19)	OUTPUT,
	@error		INT		OUTPUT,	-- If > 0, an error has occurred
	@partial_unmask	INT = 0			-- Request that PAN only be partially unmasked
 WITH EXECUTE AS 'post_office_com'
AS
BEGIN
	DECLARE @hr INT
	DECLARE @src VARCHAR(255), @desc VARCHAR(4000)
	DECLARE @error_msg VARCHAR (4000)

	--
	-- Create object out of process, by setting the last parameter to 4
	--

	DECLARE @object INT

	EXEC @hr = sp_OACreate '{A1D87950-6452-49a6-8144-1BAD26703300}',
		@object OUT, 4

	-- check sql error
	IF @@ERROR <> 0
	BEGIN
		SET @error = @@ERROR
		RETURN
	END

	-- check COM error
	IF @hr <> 0
	BEGIN
		--
		-- There was some COM error. Raise an error.
		--

		EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT

		IF @@ERROR <> 0
		BEGIN
			SET @error = @@ERROR
			RETURN
		END

		SET @error_msg = 'COM error ' + ISNULL(CAST(@hr AS VARCHAR), '?') +
			' occurred trying to create the legacy CardholderData COM object: ' +
			ISNULL(@src, '') + ', ' + ISNULL(@desc, '') + '.' + CHAR(13) + CHAR(10) +
			'Please ensure that the legacy Microsoft JVM is installed. The error occurred whilst attempting to run ' +
			ISNULL(@process_descr, '[Unknown]')

		RAISERROR (@error_msg, 16, 1)
		SET @error = @@ERROR
		RETURN
	END

	--
	-- Decrypt PAN
	--

	-- We use a temporary variable to store decrypted PAN in case
	-- PAN is accidentally returned if we exit due to an error
	DECLARE @tmp_pan_decrypted VARCHAR(19)

	EXEC @hr = sp_OAMethod @object,
		'decryptPan',
		@tmp_pan_decrypted OUTPUT,
		@pan_encrypted,
		@process_descr

	-- check SQL error
	IF @@ERROR <> 0
	BEGIN
		SET @error = @@ERROR
		RETURN
	END

	-- check COM error
	IF @hr <> 0
	BEGIN
		--
		-- There was some COM error. Raise an error.
		--

		EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT

		IF @@ERROR <> 0
		BEGIN
			SET @error = @@ERROR
			RETURN
		END

		SET @error_msg = 'COM error ' + ISNULL(CAST(@hr AS VARCHAR), '?') +
			' occurred trying to decrypt the PAN: ' + ISNULL(@src, '') + ', ' +
			ISNULL(@desc, '') + '.' + CHAR(13) + CHAR(10) +
			'Please contact your primary support provider. The error occurred whilst attempting to run ' +
			ISNULL(@process_descr, '[Unknown]')

		RAISERROR (@error_msg, 16, 1)
		SET @error = @@ERROR
		RETURN
	END
	ELSE IF (@tmp_pan_decrypted = 'EXCEPTION')
	BEGIN
		--
		-- There was some exception decrypting the PAN. Raise an error.
		--

		SET @error_msg = 'An error occurred trying to decrypt the PAN.' + CHAR(13) + CHAR(10) +
				'See the Windows Event Log on the Postilion Office server for more information on the error that occurred.'

		RAISERROR (@error_msg, 16, 1)
		SET @error = @@ERROR
		RETURN
	END


	--
	-- Destroy object
	--

	EXEC @hr = sp_OADestroy @object

	-- check SQL error
	IF @@ERROR <> 0
	BEGIN
		SET @error = @@ERROR
		RETURN
	END

	-- check COM error
	IF @hr <> 0
	BEGIN
		--
		-- There was some COM error. Raise an error.
		--

		EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT

		IF @@ERROR <> 0
		BEGIN
			SET @error = @@ERROR
			RETURN
		END

		SET @error_msg = 'COM error ' + ISNULL(CAST(@hr AS VARCHAR), '?') +
			' occurred trying to destroy the CardholderData COM object: ' +
			ISNULL(@src, '') + ', ' + ISNULL(@desc, '') + '.' + CHAR(13) + CHAR(10) +
			'Please contact your primary support provider. The error occurred whilst attempting to run ' +
			ISNULL(@process_descr, '[Unknown]')

		RAISERROR (@error_msg, 16, 1)
		SET @error = @@ERROR
		RETURN
	END

	-- If the PAN has been decrypted, and the user only has partial access
	-- or the user only requested a partially unmasked PAN
	IF (
		(@tmp_pan_decrypted <> @pan)
		AND (@partial_unmask = 1)
	)
	BEGIN
		DECLARE @pan_masked VARCHAR(19)
		SET @pan_masked = '*'

		-- Mask the PAN
		EXEC osp_mask_pan
			@tmp_pan_decrypted,
			@process_descr,
			@pan_masked	OUTPUT,
			@error OUTPUT

		SET @pan_decrypted = @pan_masked
	END
	ELSE
	BEGIN

		-- Return our temporary decrypted PAN
		SET @pan_decrypted = @tmp_pan_decrypted
	END --audit
END

GO


