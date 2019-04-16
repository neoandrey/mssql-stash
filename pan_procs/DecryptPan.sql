USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[DecryptPan]    Script Date: 08/30/2016 10:26:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE FUNCTION [dbo].[DecryptPan](@pan VARCHAR (19), -- The pan to be decrypted
@pan_encrypted CHAR(18) , -- The pan_encrypted field. From post_tran_cust.pan_encrypted
@process_descr VARCHAR(100) ) -- A description of the process that is calling this procedure (for error handling purposes)
/*@pan_decrypted VARCHAR (19) OUTPUT,
@error INT OUTPUT, -- If > 0, an error has occurred
@partial_unmask INT = 0 -- Request that PAN only be partially unmasked)*/
-- Returns VARCHAR(32) Decrypted pan
RETURNS VARCHAR(32)
AS
BEGIN
DECLARE @pan_decrypted VARCHAR(19)
DECLARE @error VARCHAR(19)
DECLARE @partial_unmask INT 
SET @partial_unmask = 0

DECLARE @has_access INT
SET @has_access = 1
--EXEC osp_user_has_access @has_access OUTPUT

-- If user has permissions, PAN is not null and we need to decrypt, decrypt PAN
IF (((@has_access = 1) OR (@has_access = 2 AND @pan = '*')) AND (@pan IS NOT NULL) AND (@pan_encrypted IS NOT NULL))
BEGIN
DECLARE @hr INT
DECLARE @src VARCHAR(255), @desc VARCHAR(255)
DECLARE @error_msg VARCHAR (400)

--
-- Create object
--

DECLARE @object INT

EXEC @hr = sp_OACreate '{A1D87950-6452-49a6-8144-1BAD26703300}',
@object OUT
IF @hr <> 0
BEGIN
--
-- There was some COM error. Raise an error.
--

EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT

SET @error_msg = 'The following error occurred trying to create the CardholderData COM object: ' + @src + ', ' + @desc
+ '. Please contact your primary support provider. The error occurred whilst attempting to run ' + @process_descr

--RAISERROR (@error_msg, 16, 1)

SET @error = @@ERROR

RETURN @error
END

--
-- Decrypt PAN
--

EXEC @hr = sp_OAMethod @object,
'decryptPan',
@pan_decrypted OUTPUT,
@pan_encrypted,
@process_descr
IF @hr <> 0
BEGIN
--
-- There was some COM error. Raise an error.
--

EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT

SET @error_msg = 'The following COM error occurred trying to decrypt the PAN: ' + @src + ', ' + @desc
+ '. Please contact your primary support provider. The error occurred whilst attempting to run ' + @process_descr

--RAISERROR (@error_msg, 16, 1)

SET @error = @@ERROR

RETURN @error
END
ELSE IF (@pan_decrypted = 'EXCEPTION')
BEGIN
--
-- There was some exception connecting to the CMS. Raise an error.
--

SET @error_msg = 'An error occurred during an attempt to use the Postilion Certificate Management Service. ' +
'Please see the Windows Event Log for more information on the error that occurred.'

--RAISERROR (@error_msg, 16, 1)

SET @error = @@ERROR

RETURN @error
END

--
-- Destroy object
--

EXEC @hr = sp_OADestroy @object
IF @hr <> 0
BEGIN
--
-- There was some COM error. Raise an error.
--

EXEC sp_OAGetErrorInfo @object, @src OUT, @desc OUT

SET @error_msg = 'The following error occurred trying to destroy the CardholderData COM object: ' + @src + ', ' + @desc
+ '. Please contact your primary support provider. The error occurred whilst attempting to run ' + @process_descr

--RAISERROR (@error_msg, 16, 1)

SET @error = @@ERROR

RETURN @error
END

-- If the PAN has been decrypted, and the user only has partial access
-- or the user only requested a partially unmasked PAN
IF ((@pan_decrypted <> @pan) AND ((@has_access = 2) OR (@partial_unmask = 1)))
BEGIN
DECLARE @pan_masked VARCHAR(19)
SET @pan_masked = '*'

-- Mask the PAN
EXEC osp_mask_pan
@pan_decrypted,
@process_descr,
@pan_masked OUTPUT,
@error OUTPUT

SET @pan_decrypted = @pan_masked
END
END
ELSE
BEGIN
SET @pan_decrypted = @pan
END
RETURN @pan_decrypted
END







GO


