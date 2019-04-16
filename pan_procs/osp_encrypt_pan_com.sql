USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_encrypt_pan_com]    Script Date: 08/30/2016 10:24:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_encrypt_pan_com]
	@pan		VARCHAR (19),		-- The pan field to be encrypted. From post_tran_cust.pan
	@process_descr	VARCHAR (100), 		-- A description of the process that is calling this procedure (for error handling purposes)
	@pan_encrypted	CHAR (18)	OUTPUT,
	@error		INT		OUTPUT	-- If > 0, an error has occurred
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

	IF @@ERROR <> 0
	BEGIN
		SET @error = @@ERROR
		RETURN
	END

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

		SET @error_msg = 'COM error ' + ISNULL(CAST(@hr AS VARCHAR), '?') + ' occurred trying to create the legacy CardholderData COM object: ' + ISNULL(@src, '') + ', ' + ISNULL(@desc, '') + '.' + CHAR(13) + CHAR(10) +
				+ 'Please ensure that the legacy Microsoft JVM is installed. The error occurred whilst attempting to run ' + ISNULL(@process_descr, '[Unknown]')

		RAISERROR (@error_msg, 16, 1)

		SET @error = @@ERROR

		RETURN
	END

	--
	-- Encrypt PAN
	--

	EXEC @hr = sp_OAMethod @object,
		'encryptPan',
		@pan_encrypted OUTPUT,
		@pan,
		@process_descr

	IF @@ERROR <> 0
	BEGIN
		SET @error = @@ERROR
		RETURN
	END

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

		SET @error_msg = 'COM error ' + ISNULL(CAST(@hr AS VARCHAR), '?') + ' occurred trying to encrypt the PAN: ' + ISNULL(@src, '') + ', ' + ISNULL(@desc, '') + '.' + CHAR(13) + CHAR(10) +
				+ 'Please contact your primary support provider. The error occurred whilst attempting to run ' + ISNULL(@process_descr, '[Unknown]')

		RAISERROR (@error_msg, 16, 1)

		SET @error = @@ERROR

		RETURN
	END
	ELSE IF (@pan_encrypted = 'EXCEPTION')
	BEGIN
		--
		-- There was some exception encrypting the PAN. Raise an error.
		--

		SET @error_msg = 'An error occurred trying to encrypt the PAN.' + '.' + CHAR(13) + CHAR(10) +
				'See the Windows Event Log on the Postilion Office server for more information on the error that occurred.'

		RAISERROR (@error_msg, 16, 1)

		SET @error = @@ERROR

		RETURN
	END

	--
	-- Destroy object
	--

	EXEC @hr = sp_OADestroy @object

	IF @@ERROR <> 0
	BEGIN
		SET @error = @@ERROR
		RETURN
	END

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

		SET @error_msg = 'COM error ' + ISNULL(CAST(@hr AS VARCHAR), '?') + ' occurred trying to destroy the CardholderData COM object: ' + ISNULL(@src, '') + ', ' + ISNULL(@desc, '') + '.' + CHAR(13) + CHAR(10) +
				+ 'Please contact your primary support provider. The error occurred whilst attempting to run ' + ISNULL(@process_descr, '[Unknown]')

		RAISERROR (@error_msg, 16, 1)

		SET @error = @@ERROR

		RETURN
	END
	
END

GO


