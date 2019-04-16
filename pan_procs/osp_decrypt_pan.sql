USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_decrypt_pan]    Script Date: 08/30/2016 10:25:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[osp_decrypt_pan]
	@pan		VARCHAR (19),		-- The pan to be decrypted
	@pan_encrypted	CHAR (18),		-- The pan_encrypted field. From post_tran_cust.pan_encrypted
	@process_descr	VARCHAR (100),		-- A description of the process that is calling this procedure (for error handling purposes)
	@pan_decrypted	VARCHAR (19)	OUTPUT,
	@error		INT		OUTPUT,	-- If > 0, an error has occurred
	@partial_unmask	INT = 0			-- Request that PAN only be partially unmasked
AS
BEGIN
	DECLARE @has_access INT
	DECLARE @error_msg VARCHAR(MAX)
	EXEC osp_user_has_access @has_access OUTPUT

	-- If user has permissions, PAN is not null and we need to decrypt, decrypt PAN
	IF (
		((@has_access = 1) OR (@has_access = 2 AND @pan = '*'))
		AND (@pan IS NOT NULL)
		AND (@pan_encrypted IS NOT NULL)
	)
	BEGIN
		--
		-- From Office 4.3, only regular normal SQL Logins may get access to
		-- sensitive cardholder data via the database (e.g. via osp_decrypt_pan).
		--
		-- This is because on-demand reports are now generated through the 
		-- Portal Office plug-in, via the Office Sentinel Service,
		-- making it impossible for the calling stored procedure to identify
		-- the user who accessed the sensitive data.
		--
		-- This makes it impossible to enforce the correct permissions for the user
		-- and to identify them in the audit trail entry. Therefore, we do not
		-- allow dbowner members to access sensitive cardholder data via the database.
		--
		DECLARE @this_user_name sysname
		SET @this_user_name = lower(user_name())
		
		IF ((IS_MEMBER('db_owner') = 1) OR (@this_user_name = 'postilion'))
		BEGIN
			SET @error_msg = 'The legacy stored procedure osp_decrypt_pan is only provided ' +
				'for backwards compatibility with the Office Adjustment Component console. ' +
				'Crystal Reports templates must use the new PAN formatting function instead.'
			
			RAISERROR (@error_msg, 16, 1)
			SET @error = @@ERROR
			RETURN
		END
		
		IF @has_access = 2
		BEGIN
			SET @partial_unmask = 1
		END

		DECLARE @tmp_pan_decrypted	VARCHAR (19)
		
		IF EXISTS (SELECT * FROM sys.sysobjects WHERE type = 'PC' and name = 'osp_decrypt_pan_clr')
		BEGIN
			EXEC osp_decrypt_pan_clr 
				@pan_encrypted,
				@process_descr,
				@tmp_pan_decrypted OUTPUT, 
				@error_msg OUTPUT
			
			IF @error_msg IS NOT NULL
			BEGIN
				SET @error = 1
				SET @error_msg = 'An error occurred whilst attempting to decrypt a PAN using the Office Encryption Extension during the ' + @process_descr + ' process. The error that occurred was ' + @error_msg
				RAISERROR (@error_msg, 16, 1)
				RETURN
			END
			
			-- If the PAN has been decrypted, and the user only has partial access
			-- or the user only requested a partially unmasked PAN, mask the PAN
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
			
				SET @tmp_pan_decrypted = @pan_masked
			END
		END
		ELSE
		BEGIN
			EXEC osp_decrypt_pan_com
				@pan,
				@pan_encrypted,
				@process_descr,
				@tmp_pan_decrypted OUTPUT,
				@error OUTPUT,
				@partial_unmask
		END

		-- If a decrypted PAN is to be returned, then audit the operation
		IF @partial_unmask <> 1
		BEGIN

			-- No need to audit admin users
			IF LOWER(USER_NAME()) NOT IN ('postilion', 'dbo', 'sa')
			BEGIN
				DECLARE @pan_hashed VARCHAR(66)
				SET @pan_hashed = NULL
				
				EXEC osp_hash_pan_2
					@tmp_pan_decrypted,
					NULL,
					@process_descr,
					NULL,
					@pan_hashed OUTPUT,
					@error OUTPUT
				
				INSERT INTO at_log
				(
					user_login,
					date_time,
					action_type,
					db_table,
					deleted,
					inserted
				)
				VALUES
				(
					LOWER(USER_NAME()),
					GETDATE(),
					3, -- Read
					'(PCI-DSS)osp_decrypt_pan',
					NULL,
					'A PAN was decrypted. PAN Reference [' + ISNULL(@pan_hashed,'NULL') + '].'
				)
			END
		END
		
		-- Return our temporary decrypted PAN
		SET @pan_decrypted = @tmp_pan_decrypted
	END
	ELSE
	BEGIN
		SET @pan_decrypted = @pan
	END
END

GO


