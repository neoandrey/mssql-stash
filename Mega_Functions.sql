USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[currencyAlphaCode]    Script Date: 05/17/2016 16:51:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[currencyAlphaCode] (@currency_code CHAR (3))
RETURNS CHAR (3)
AS
BEGIN
	IF (@currency_code IS NULL)
	BEGIN
		SET @currency_code = '840'
	END

	IF (@currency_code = '000')
	BEGIN
		SET @currency_code = '840'
	END	


	DECLARE @c CHAR (3)
	
	SELECT @c = alpha_code
	FROM
		post_currencies WITH (NOLOCK)
	WHERE		
		currency_code = @currency_code

	IF (@c IS NULL)
	BEGIN
		SET @c = '???'
	END
	
	RETURN @c
END

GO

/****** Object:  UserDefinedFunction [dbo].[currencyName]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[currencyName] (@currency_code CHAR (3))
RETURNS VARCHAR (20)
AS
BEGIN
	IF (@currency_code IS NULL)
	BEGIN
		SET @currency_code = '840'
	END

	IF (@currency_code = '000')
	BEGIN
		SET @currency_code = '840'
	END	


	DECLARE @n VARCHAR (20)
	
	SELECT @n = name
	FROM
		post_currencies WITH (NOLOCK)
	WHERE		
		currency_code = @currency_code

	IF (@n IS NULL)
	BEGIN
		SET @n = 'Unknown'
	END
	
	RETURN @n
END

GO

/****** Object:  UserDefinedFunction [dbo].[currencyNrDecimals]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[currencyNrDecimals] (@currency_code CHAR (3))
RETURNS INT
AS
BEGIN
	IF (@currency_code IS NULL)
	BEGIN
		SET @currency_code = '840'
	END

	IF (@currency_code = '000')
	BEGIN
		SET @currency_code = '840'
	END	

	DECLARE @d int

	SELECT @d = nr_decimals
	FROM
		post_currencies WITH (NOLOCK)
	WHERE		
		currency_code = @currency_code
		
	IF (@d IS NULL)
	BEGIN
		SET @d = 2
	END

	RETURN @d
END

GO

/****** Object:  UserDefinedFunction [dbo].[DateOnly]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER FUNCTION [dbo].[DateOnly](@DateTime DateTime)
-- Returns @DateTime at midnight; i.e., it removes the time portion of a DateTime value.
RETURNS DATETIME
AS
BEGIN
RETURN dateadd(dd,0, datediff(dd,0,@DateTime))
END
 








GO

/****** Object:  UserDefinedFunction [dbo].[DecryptPan]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER FUNCTION [dbo].[DecryptPan](@pan VARCHAR (19), -- The pan to be decrypted
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

/****** Object:  UserDefinedFunction [dbo].[fn_ds_HasSubsequentReplacement]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION [dbo].[fn_ds_HasSubsequentReplacement]
(
	@snk_post_tran_id 		BIGINT, 
	@post_tran_cust_id 		BIGINT,
	@tran_nr 					BIGINT,
		@src_msg_type CHAR (4), 
	@snk_next_post_tran_id 	BIGINT
)
RETURNS BIT
AS
BEGIN
	DECLARE @result BIT
	SET @result = 0

	-- If the sink leg in question has a subsequent sink leg
	IF (@snk_next_post_tran_id > 0)
	BEGIN
		-- If there is a subsequent sink leg of the same message class
		IF EXISTS 
		(
			SELECT 
				1
			FROM
				post_tran
			WHERE
				tran_postilion_originated = 1
				AND tran_nr = @tran_nr
				AND post_tran_cust_id = @post_tran_cust_id
				AND LEFT(message_type, 2) = LEFT(@src_msg_type, 2)
				AND post_tran_id > @snk_post_tran_id
		)
			SET @result = 1
	END

	RETURN @result
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_ds_nodes_rsp_code]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[fn_ds_nodes_rsp_code] (
		@message_type CHAR (4), 
		@tran_postilion_originated INT, 
		@rsp_code_req CHAR (2), 
		@rsp_code_rsp CHAR (2))
	RETURNS CHAR (2)
AS
BEGIN

	IF (@message_type IN ('0120','0220') AND @tran_postilion_originated = 1)
	BEGIN

		IF (@rsp_code_req = '00' OR @rsp_code_req IS NULL)
			RETURN @rsp_code_rsp
		ELSE
			RETURN @rsp_code_req

	END

	RETURN @rsp_code_rsp
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_ext_batchisclosed]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_ext_batchisclosed] (@settle_entity_id INT, @batch_nr INT)
	RETURNS INT
AS
BEGIN
	RETURN dbo.fn_ext_batchisclosed_4200 (@settle_entity_id, @batch_nr, NULL)
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_ext_batchisclosed_4200]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_ext_batchisclosed_4200] (@settle_entity_id INT, @batch_nr INT, @cut_off_datetime DATETIME)
	RETURNS INT
AS
BEGIN
	DECLARE @datetime_end DATETIME
	SET @datetime_end = NULL
	
	IF (@cut_off_datetime IS NULL)
	BEGIN
		SELECT
			@datetime_end = datetime_end
		FROM
			post_batch WITH ( NOLOCK )
		WHERE
			settle_entity_id = @settle_entity_id
			AND
			batch_nr = @batch_nr
	END
	ELSE
	BEGIN
		SELECT
			@datetime_end = datetime_end
		FROM
			post_batch WITH ( NOLOCK )
		WHERE
			settle_entity_id = @settle_entity_id
			AND
			batch_nr = @batch_nr
			AND
			datetime_end <= @cut_off_datetime
	END

	IF (@datetime_end IS NOT NULL)
		RETURN 1
	
	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_ext_correspondingbatchisclosed]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_ext_correspondingbatchisclosed] (@post_tran_cust_id BIGINT, @tran_nr BIGINT, @tran_postilion_originated INT)
	RETURNS INT
AS
BEGIN
	RETURN dbo.fn_ext_correspondingbatchisclosed_4200 (@post_tran_cust_id, @tran_nr, @tran_postilion_originated, NULL)
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_ext_correspondingbatchisclosed_4200]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_ext_correspondingbatchisclosed_4200] (@post_tran_cust_id BIGINT, @tran_nr BIGINT, @tran_postilion_originated INT, @cut_off_datetime DATETIME)
	RETURNS INT
AS
BEGIN

	DECLARE @settle_entity_id INT
	DECLARE @batch_nr INT

	SET @settle_entity_id = NULL
	SET @batch_nr = NULL

	SELECT
		@settle_entity_id = settle_entity_id,
		@batch_nr = batch_nr
	FROM
		post_tran WITH ( NOLOCK )
	WHERE
		post_tran_cust_id = @post_tran_cust_id
		AND
		tran_nr = @tran_nr
		AND
		@tran_postilion_originated <> tran_postilion_originated
	
	IF ((@settle_entity_id IS NULL) OR (@batch_nr IS NULL))
		RETURN 1

	RETURN dbo.fn_ext_batchisclosed_4200 (@settle_entity_id, @batch_nr, @cut_off_datetime)

END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_gpext_bib]    Script Date: 05/17/2016 16:51:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION  [dbo].[fn_gpext_bib] (
	@settle_entity_id INT, 
	@batch_nr INT)
	RETURNS INT
AS
BEGIN
	DECLARE @settlement_code INT
	
	SELECT
		@settlement_code = settlement_code
	FROM
		post_batch WITH ( NOLOCK )
	WHERE
		settle_entity_id = @settle_entity_id
		AND
		batch_nr = @batch_nr
	
	IF (NOT @settlement_code IN (2,3))
		RETURN 1
	
	RETURN 0
END



GO

/****** Object:  UserDefinedFunction [dbo].[fn_gpext_bic]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION  [dbo].[fn_gpext_bic] (
	@settle_entity_id INT, 
	@batch_nr INT, 
	@cut_off_datetime DATETIME)
	RETURNS INT
AS
BEGIN
	DECLARE @datetime_end DATETIME

	SELECT
		@datetime_end = datetime_end
	FROM
		post_batch WITH ( NOLOCK )
	WHERE
		settle_entity_id = @settle_entity_id
		AND
		batch_nr = @batch_nr
		AND
		datetime_end <= @cut_off_datetime

	IF (@datetime_end IS NOT NULL)
		RETURN 1
	
	RETURN 0
END



GO

/****** Object:  UserDefinedFunction [dbo].[fn_gpext_cbib]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION  [dbo].[fn_gpext_cbib] (
	@post_tran_cust_id BIGINT, 
	@tran_nr BIGINT, 
	@tran_postilion_originated INT)
	RETURNS INT
AS
BEGIN
	DECLARE @settlement_code INT
	DECLARE @settle_entity_id INT
	DECLARE @batch_nr INT
	
	SELECT
		@settle_entity_id = settle_entity_id,
		@batch_nr = batch_nr
	FROM
		post_tran WITH ( NOLOCK )
	WHERE
		post_tran_cust_id = @post_tran_cust_id
		AND
		tran_nr = @tran_nr
		AND
		@tran_postilion_originated <> tran_postilion_originated
	
	IF (@settle_entity_id IS NULL OR @batch_nr IS NULL)
		RETURN 1
	
	SELECT
		@settlement_code = settlement_code
	FROM
		post_batch WITH ( NOLOCK )
	WHERE
		settle_entity_id = @settle_entity_id
		AND
		batch_nr = @batch_nr
	
	IF (NOT @settlement_code IN (2,3))
		RETURN 1
	
	RETURN 0
END



GO

/****** Object:  UserDefinedFunction [dbo].[fn_gpext_cbic]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION  [dbo].[fn_gpext_cbic] (
	@post_tran_cust_id BIGINT, 
	@tran_nr BIGINT, 
	@tran_postilion_originated INT,
	@cut_off_datetime DATETIME)
	RETURNS INT
AS
BEGIN
	DECLARE @settle_entity_id INT
	DECLARE @batch_nr INT
	DECLARE @datetime_end DATETIME
	
	SELECT
		@settle_entity_id = settle_entity_id,
		@batch_nr = batch_nr
	FROM
		post_tran WITH ( NOLOCK )
	WHERE
		post_tran_cust_id = @post_tran_cust_id
		AND
		tran_nr = @tran_nr
		AND
		@tran_postilion_originated <> tran_postilion_originated
	
	IF (@settle_entity_id IS NULL OR @batch_nr IS NULL)
		RETURN 1
	
	SELECT
		@datetime_end = datetime_end
	FROM
		post_batch WITH ( NOLOCK )
	WHERE
		settle_entity_id = @settle_entity_id
		AND
		batch_nr = @batch_nr
		AND
		datetime_end <= @cut_off_datetime

	IF (@datetime_end IS NOT NULL)
		RETURN 1
	
	RETURN 0
	
END



GO

/****** Object:  UserDefinedFunction [dbo].[fn_gpext_hbextr]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION  [dbo].[fn_gpext_hbextr] (@extract_entity_id INT, @post_tran_id BIGINT)
	RETURNS INT
AS
BEGIN
	IF EXISTS(
		SELECT post_tran_id 
		FROM extract_tran AS et WITH (NOLOCK)
		WHERE 
			post_tran_id = @post_tran_id
			AND
			EXISTS(
				SELECT * 
				FROM extract_session AS es WITH (NOLOCK)
				WHERE 
					es.session_id = et.session_id 
					AND
					es.entity_id = @extract_entity_id
			)
		)
		RETURN 1
	
	RETURN 0
END



GO

/****** Object:  UserDefinedFunction [dbo].[fn_isFinancialTran]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[fn_isFinancialTran](@message_type CHAR (4))
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	SET @result = 0

	IF (@message_type LIKE '01%' OR @message_type LIKE '02%' OR @message_type LIKE '04%')
	BEGIN
		SET @result = 1
	END

	RETURN @result
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_LenStructDataElem]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create function placeholder_fn_LenStructDataElem
--------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[fn_LenStructDataElem](@data TEXT, @key VARCHAR (200))
	RETURNS INT
AS
BEGIN
	IF (@data IS NULL OR @key IS NULL)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @len_data INT
	SET @len_data = DATALENGTH(@data)
	
	IF (@len_data <= 0)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @s_key_len_len VARCHAR(1)
	DECLARE @key_len_len INT
	DECLARE @s_key_len VARCHAR(9)
	DECLARE @key_len INT
	DECLARE @s_key VARCHAR(8000)
	
	DECLARE @s_value_len_len VARCHAR(1)
	DECLARE @value_len_len INT
	DECLARE @s_value_len VARCHAR(9)
	DECLARE @value_len INT
	
	DECLARE @pos INT
	SET @pos = 1
	
	WHILE (@pos <= @len_data)
	BEGIN
		-- Parse Key Length Length
		SET @s_key_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_key_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len_len = CAST(@s_key_len_len AS INT)
		IF LEN(@key_len_len) <= 0 -- Key Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Key Length
		SET @s_key_len = SUBSTRING(@data, @pos, @key_len_len)
		IF LEN(@s_key_len) < @key_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len = CAST(@s_key_len AS INT)
		IF LEN(@key_len) <= 0 -- Key Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @key_len_len
		
		-- Parse Key
		SET @s_key = SUBSTRING(@data, @pos, @key_len)
		SET @pos = @pos + @key_len
		
		-- Parse Value Length Length
		SET @s_value_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_value_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len_len = CAST(@s_value_len_len AS INT)
		IF LEN(@value_len_len) <= 0 -- Value Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Value Length
		SET @s_value_len = SUBSTRING(@data, @pos, @value_len_len)
		IF LEN(@s_value_len) < @value_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len = CAST(@s_value_len AS INT)
		IF LEN(@value_len) <= 0 -- Value Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @value_len_len
		
		-- Return Value Length
		IF @s_key = @key
		BEGIN
			-- If the Key matches, return the Value length immediately
			RETURN @value_len
		END
		SET @pos = @pos + @value_len
	END
	
	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_PostilionFolder]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[fn_PostilionFolder] ()
	RETURNS VARCHAR (100)
AS
BEGIN
	RETURN 'C:\postilion'
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_CardType]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER FUNCTION  [dbo].[fn_rpt_CardType] (@PAN VARCHAR (30),@SINK_NODE_NAME VARCHAR (30),@TRAN_TYPE CHAR (2),@TERMINAL_ID CHAR(8))
	
RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF @pan like '4%'--or @pan like '63958%' and @terminal_id not like '1ATM%' and @terminal_id not like '1085%')
	AND @TRAN_TYPE = 01
        AND @SINK_NODE_NAME IN( 'MEGFBPSMSsnk') 
           SET @r = 1

       
	ELSE
		SET @r = 9
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:36 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_getATMDepositType]    Script Date: 05/17/2016 16:51:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_getATMDepositType](
	@tran_type CHAR(2),
	@extended_tran_type CHAR(4)
	)
	RETURNS VARCHAR(8)
AS
BEGIN
	DECLARE @r VARCHAR(8)
	
	IF (@tran_type = '24' AND @extended_tran_type IN ('6100','6101','6102','6103'))
		SET @r = 'Check'
	ELSE IF (@tran_type = '21' AND @extended_tran_type = '6110')
		SET @r = 'Cash'
	ELSE IF (@tran_type IN ('21','50','51') AND @extended_tran_type IS NULL)
		SET @r = 'Envelope'
	ELSE
		SET @r = 'Unknown'
		
	RETURN @r
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_getDepositTokenType]    Script Date: 05/17/2016 16:51:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_getDepositTokenType]
(
	@tran_type				CHAR(2),
	@extended_tran_type	CHAR(4)
)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @result VARCHAR(10)
	SET @result = ''
	
	IF (dbo.fn_rpt_isEnvelopeDeposit(@tran_type, @extended_tran_type) = 1)
	BEGIN
		SET @result = 'Envelope'
	END

	IF (dbo.fn_rpt_isElectronicCheckDeposit(@tran_type, @extended_tran_type) = 1)
	BEGIN
		SET @result = 'Check'
	END

	IF (dbo.fn_rpt_isCashDepositBNA(@tran_type, @extended_tran_type) = 1)
	BEGIN
		SET @result = 'Cash'
	END

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_getRegion_Acquirer]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












ALTER FUNCTION  [dbo].[fn_rpt_getRegion_Acquirer] (@pan varchar (20))
	RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @c VARCHAR(10)
	IF left(@pan,6) in (select distinct left (issuer_acct_range_low,6)
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 'DOMESTIC'
	ELSE
		SET @c = 'FOREIGN'

	RETURN @c

END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_getRegion_Issuer]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO










ALTER FUNCTION  [dbo].[fn_rpt_getRegion_Issuer] (@card_acceptor_name_loc VARCHAR (40))
	RETURNS varchar(10)
AS
BEGIN
	DECLARE @c varchar(10)
	IF (right(@card_acceptor_name_loc,2) = 'NG')
	SET @c = 'DOMESTIC'

	ELSE IF (right (@card_acceptor_name_loc,2) = '')

	set @c = 'DOMESTIC'

	ELSE IF (right(@card_acceptor_name_loc,2) = ' ')
	
	SET @c = 'DOMESTIC'

	ELSE IF (right(@card_acceptor_name_loc,2) = '  ')
	SET @c = 'DOMESTIC'

	ELSE IF (right(@card_acceptor_name_loc,2) is null)
	SET @c = 'DOMESTIC'

	ELSE
		SET @c = 'FOREIGN'

	RETURN @c
END










GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isApprovedTrx]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isApprovedTrx] (@rsp_Code CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@rsp_Code IN ('00','08', '10', '11', '16') )
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isATMCustomerInquiryTrx]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[fn_rpt_isATMCustomerInquiryTrx](
	@tran_type CHAR(2)
	)
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type in ('30','31','35','38'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isAutomatedDeposit]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_isAutomatedDeposit]
(
	@tran_type				CHAR(2),
	@extended_tran_type	CHAR(4)
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	SET @result = 0
	
	-- Add up the results of each function, If at least one of them is true then 
	-- the transaction is an automated deposit.
	SET @result = (
							dbo.fn_rpt_isEnvelopeDeposit(@tran_type, @extended_tran_type) + 
							dbo.fn_rpt_isCashDepositBNA(@tran_type, @extended_tran_type) +
							dbo.fn_rpt_isElectronicCheckDeposit(@tran_type, @extended_tran_type)
						)
						
	-- In case there is an overlap in definitions and two functions return true.
	IF (@result > 1)
		SET @result = 1
		
	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isCashDepositBNA]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_isCashDepositBNA]
(
	@tran_type				CHAR(2),
	@extended_tran_type	CHAR(4)
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	
	IF (@tran_type = '21' AND @extended_tran_type = '6110')
		SET @result = 1
	ELSE
		SET @result = 0
		
	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isCashDepositCleanout]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_isCashDepositCleanout]
(
	@struct_data	VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT

	IF (CHARINDEX('<Function>CLEAR', @struct_data) > 0 )
	BEGIN

		IF (CHARINDEX('DEP_CASH', @struct_data) > 0 )
		BEGIN
			SET @result = 1
		END
		ELSE
		BEGIN
			SET @result = 0
		END

	END
	ELSE
	BEGIN
		SET @result = 0
	END

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isCheckCashTrx]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isCheckCashTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type IN ('03'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isCheckDepositCleanout]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_isCheckDepositCleanout]
(
	@struct_data	VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT

	IF (CHARINDEX('<Function>CLEAR', @struct_data) > 0 )
	BEGIN

		IF (CHARINDEX('DEP_CHECK', @struct_data) > 0 )
		BEGIN
			SET @result = 1
		END
		ELSE
		BEGIN
			SET @result = 0
		END

	END
	ELSE
	BEGIN
		SET @result = 0
	END

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isCreditTrx]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--
-- Returns 1 if the transaction type is a non-deposit credit transaction type
--

ALTER FUNCTION  [dbo].[fn_rpt_isCreditTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '20' AND '29') AND @tran_type NOT IN ('21', '23', '24'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isDepositTrx]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isDepositTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type IN ('21', '23', '24', '51'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isElectronicCheckDeposit]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_isElectronicCheckDeposit] 
(
	@tran_type 				CHAR(2),
	@extended_tran_type	CHAR(4)
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	IF (@tran_type = '24' AND @extended_tran_type IN ('6100','6101','6102','6103'))
		SET @result = 1
	ELSE
		SET @result = 0
	
	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isEnvelopeDeposit]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_isEnvelopeDeposit]
(
	@tran_type				CHAR(2),
	@extended_tran_type	CHAR(4)
)
RETURNS INT
AS
BEGIN
	DECLARE @result INT
	
	IF (@tran_type IN ('21', '50', '51') AND @extended_tran_type IS NULL)
		SET @result = 1
	ELSE
		SET @result = 0
		
	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isEnvelopeDepositCleanout]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[fn_rpt_isEnvelopeDepositCleanout]
(
	@struct_data	VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @result 			INT
	DECLARE @temp				VARCHAR(20)
	DECLARE @pos_begin_tag	INT
	DECLARE @pos_end_tag		INT
	SET @result = 0
	
	-- Check for early exit
	IF (CHARINDEX('<Function>CLEAR', @struct_data) > 0)
	BEGIN
		-- Loop through structured data looking for DEP<Currency Code>
		WHILE (CHARINDEX('<CassetteId>DEP', @struct_data) > 0 )
		BEGIN
			SET @pos_begin_tag = CHARINDEX('<CassetteId>', @struct_data)
			SET @pos_end_tag = CHARINDEX('</CassetteId>', @struct_data)
		
			SET @temp = SUBSTRING(@struct_data, @pos_begin_tag, @pos_end_tag - @pos_begin_tag)
			SET @temp = REPLACE(@temp, '<CassetteId>', '')
			SET @struct_data = STUFF(@struct_data, 1, @pos_end_tag, '')
			IF (@temp LIKE 'DEP[0-9]%')
			BEGIN
				SET @result = 1
			END
		END
	END
	RETURN @result	
END




GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isfinancial0100Trx]    Script Date: 05/17/2016 16:51:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER FUNCTION  [dbo].[fn_rpt_isfinancial0100Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0100'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isfinancial0200Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER FUNCTION  [dbo].[fn_rpt_isfinancial0200Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isfinancial0220Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER FUNCTION  [dbo].[fn_rpt_isfinancial0220Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(2),@rsp_code_req varchar(2))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0220'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and @rsp_code_req = '00'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeign0100AcqTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO













ALTER FUNCTION  [dbo].[fn_rpt_isforeign0100AcqTrx] (@message_type VARCHAR (40),@pan varchar (20))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0100'
	and left(@pan,6) not in (select distinct left (issuer_acct_range_low,6) 
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END













GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeign0100Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER FUNCTION  [dbo].[fn_rpt_isforeign0100Trx] (@message_type VARCHAR (40),@card_acceptor_name_loc varchar (40))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0100'
	and right(@card_acceptor_name_loc,2) != 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END









GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeign0200AcqTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO













ALTER FUNCTION  [dbo].[fn_rpt_isforeign0200AcqTrx] (@message_type VARCHAR (40),@pan varchar (20))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and left(@pan,6) not in (select distinct left (issuer_acct_range_low,6) 
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END













GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeign0200Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER FUNCTION  [dbo].[fn_rpt_isforeign0200Trx] (@message_type VARCHAR (40),@card_acceptor_name_loc varchar (40))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and right(@card_acceptor_name_loc,2) != 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END









GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeignfinancial0200Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO










ALTER FUNCTION  [dbo].[fn_rpt_isforeignfinancial0200Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4),@card_acceptor_name_loc varchar (40))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and right(@card_acceptor_name_loc,2) != 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END










GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeignfinancial0220AcqTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO











ALTER FUNCTION  [dbo].[fn_rpt_isforeignfinancial0220AcqTrx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(2),@rsp_code_req varchar(2),@pan varchar (20))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0220'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and @rsp_code_req = '00'
	and left(@pan,6) not in (select distinct left (issuer_acct_range_low,6) 
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END











GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeignfinancial0220Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER FUNCTION  [dbo].[fn_rpt_isforeignfinancial0220Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(2),@rsp_code_req varchar(2),@card_acceptor_name_loc varchar (40))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0220'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and @rsp_code_req = '00'
	and right(@card_acceptor_name_loc,2) != 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isforeignTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER FUNCTION  [dbo].[fn_rpt_isforeignTrx] (@card_acceptor_name_loc VARCHAR (40))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF (right(@card_acceptor_name_loc,2) != 'NG')
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isInquiryTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isInquiryTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type BETWEEN '30' AND '39')
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalAcqTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO











ALTER FUNCTION  [dbo].[fn_rpt_islocalAcqTrx] (@pan varchar (20))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF left(@pan,6) in (select distinct left (issuer_acct_range_low,6) 
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END











GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0100AcqTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO













ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0100AcqTrx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4),@pan varchar (20))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0100'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and left(@pan,6) in (select distinct left (issuer_acct_range_low,6) 
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END













GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0100Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0100Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4),@card_acceptor_name_loc varchar (40))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0100'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and right(@card_acceptor_name_loc,2) = 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END









GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0200AcqTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO













ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0200AcqTrx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4),@pan varchar (20))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and left(@pan,6) in (select distinct left (issuer_acct_range_low,6) 
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END













GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0200Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0200Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4),@card_acceptor_name_loc varchar (40))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and right(@card_acceptor_name_loc,2) = 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END









GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0200TrxCashWdrl]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO











ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0200TrxCashWdrl] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4),@card_acceptor_name_loc varchar (40),@tran_type varchar(2))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and @tran_type = '01'
	and right(@card_acceptor_name_loc,2) = 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END











GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0200TrxNOTCashWdrl]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0200TrxNOTCashWdrl] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(4),@card_acceptor_name_loc varchar (40),@tran_type varchar(2))
	
RETURNS INT

AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0200'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and @tran_type != '01'
	and right(@card_acceptor_name_loc,2) = 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END












GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0220AcqTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO












ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0220AcqTrx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(2),@rsp_code_req varchar(2),@pan varchar (20))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0220'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and @rsp_code_req = '00'
	and left(@pan,6) in (select distinct left (issuer_acct_range_low,6) 
				from mcipm_ip0040t1 (nolock)
				where country_numeric = '566')
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END












GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalfinancial0220Trx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER FUNCTION  [dbo].[fn_rpt_islocalfinancial0220Trx] (@message_type VARCHAR (40),@tran_amount_req VARCHAR (40),@rsp_code_rsp varchar(2),@rsp_code_req varchar(2),@card_acceptor_name_loc varchar (40))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF @message_type = '0220'
	and @tran_amount_req != '0'
	and @rsp_code_rsp = '00'
	and @rsp_code_req = '00'
	and right(@card_acceptor_name_loc,2) = 'NG'
		
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_islocalTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO








ALTER FUNCTION  [dbo].[fn_rpt_islocalTrx] (@card_acceptor_name_loc VARCHAR (40))
	RETURNS INT
AS
BEGIN
	DECLARE @c INT
	IF (right(@card_acceptor_name_loc,2) = 'NG')
		SET @c = 1
	ELSE
		SET @c = 0
	RETURN @c
END








GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isnairaTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO









ALTER FUNCTION  [dbo].[fn_rpt_isnairaTrx] (@tran_currency_code VARCHAR (3))
	RETURNS INT
AS
BEGIN
	DECLARE @d INT
	IF (@tran_currency_code = '566')
		SET @d = 1
	ELSE
		SET @d = 0
	RETURN @d
END









GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isOtherTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isOtherTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type BETWEEN '60' AND '99')
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isPurchaseTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isPurchaseTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '02' AND '19') OR @tran_type = '00' OR @tran_type = '50' OR (@tran_type BETWEEN '52' AND '59'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isRefundTrx]    Script Date: 05/17/2016 16:51:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isRefundTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF ((@tran_type BETWEEN '20' AND '29') AND @tran_type NOT IN ('21', '23', '24'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isTransferTrx]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isTransferTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type BETWEEN '40' AND '49')
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_isWithdrawTrx]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_isWithdrawTrx] (@tran_type CHAR (2))
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type IN ('01'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_nextelem]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_nextelem] ( @elements VARCHAR (2048) )
	RETURNS VARCHAR (2048)
AS
BEGIN
	DECLARE @pos 		INT
	DECLARE @r 			VARCHAR (2048)

	SELECT @pos = CHARINDEX(',', @elements)

	IF (@pos > 0)
	BEGIN
		SET @r = RTRIM(LTRIM(LEFT(@elements, @pos - 1)))
	END
	ELSE
	IF (LEN (@elements) > 0)
	BEGIN
		SET @r = @elements
	END
	ELSE	BEGIN
		SET @r = NULL
	END

	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_PanForDisplay]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


-- This function has been deprecated. Please update your SQL to use osp_rpt_format_pan
ALTER FUNCTION  [dbo].[fn_rpt_PanForDisplay] (@pan VARCHAR (19), @show_in_full BIT)
	RETURNS VARCHAR (19)
AS
BEGIN
	DECLARE @p VARCHAR (19)

	IF (@show_in_full = 1)
	BEGIN
		SELECT @p = @pan
	END
	ELSE
	BEGIN
		SELECT @p = LEFT(LTRIM(@pan), 6) + 'xxxx' + RIGHT (RTRIM(@pan), 4)
	END

	RETURN @p
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_rcn_EntityIdForName]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


-- SELECT dbo.fn_rpt_rcn_EntityIdForName('dummy_rolling')

ALTER FUNCTION  [dbo].[fn_rpt_rcn_EntityIdForName] (@name VARCHAR (100))
	RETURNS INT
AS
BEGIN
	DECLARE @id INT
	
	SELECT @id = entity_id
	FROM recon_entity
	WHERE name = @name
	
	RETURN @id
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_rcn_ResolutionStateName]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_rcn_ResolutionStateName] (@resolution_state_code INT)
	RETURNS VARCHAR (50)
AS
BEGIN
	DECLARE @s VARCHAR (50)
	
	SELECT @s = resolution_state_name
	FROM recon_resolution_state
	WHERE resolution_state_code = @resolution_state_code
	
	IF (@s IS NULL)
		SET @s = 'State ' + CAST(@resolution_state_code AS  VARCHAR)		
	
	RETURN @s
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_remainelem]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_remainelem] ( @elements VARCHAR (2048) )
	RETURNS VARCHAR (2048)
AS
BEGIN
	DECLARE @pos 		INT
	DECLARE @r 			VARCHAR (2048)

	SELECT @pos = CHARINDEX(',', @elements)

	IF (@pos > 0)
	BEGIN
		SET @r = RTRIM(LTRIM(SUBSTRING(@elements, @pos+1, 2048)))
	END
	ELSE
	BEGIN
		SET @r = NULL
	END

	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_TransferTrxImpact]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[fn_rpt_TransferTrxImpact] (
		@tran_type CHAR (2),
		@message_type CHAR (4),
		@rsp_code CHAR (2),
		@prev_tran_approved INT,
		@tran_reversed INT,
		@settle_amount_rsp FLOAT,
		@prev_post_tran_id 	BIGINT )
	RETURNS FLOAT
AS
BEGIN
	DECLARE @r INT
	IF (dbo.fn_rpt_isTransferTrx(@tran_type) = 1)
	BEGIN
		IF (@message_type in ('0200', '0220'))
		BEGIN
			SET @r = @settle_amount_rsp
		END
		ELSE
		IF (@message_type in ('0100', '0120'))
		BEGIN
			SET @r = 0
		END
		ELSE
		IF (@message_type in ('0420'))
		BEGIN
			-- if approved
			IF (@prev_tran_approved = 1)
			BEGIN
				DECLARE @final_amount FLOAT
				-- Full Reversal: get original and
				IF (@tran_reversed = 2)
				BEGIN
					-- get original message and negate the settle_amount_rsp
					SET @final_amount = (SELECT pt.settle_amount_rsp FROM post_tran pt WHERE
						post_tran_id = @prev_post_tran_id)

					SET @r = -1 * (@final_amount)
				END
				ELSE
				-- Partial Reversal: tran_reversed = 1
				BEGIN
					-- get the original message and calculate (settle_amount_rsp) values
					SET @final_amount = (SELECT pt.settle_amount_rsp FROM post_tran pt WHERE
						post_tran_id = @prev_post_tran_id)

					SET @r = @settle_amount_rsp - (@final_amount)

				END
			END
			ELSE
				SET @r = 0
		END
	END

	RETURN @r
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_sql_version]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[fn_StructDataElem]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create function placeholder_fn_StructDataElem
--------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[fn_StructDataElem](@data TEXT, @key VARCHAR (200))
	RETURNS VARCHAR(8000)
AS
BEGIN
	IF (@data IS NULL OR @key IS NULL)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @len_data INT
	SET @len_data = DATALENGTH(@data)
	
	IF (@len_data <= 0)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @s_key_len_len VARCHAR(1)
	DECLARE @key_len_len INT
	DECLARE @s_key_len VARCHAR(9)
	DECLARE @key_len INT
	DECLARE @s_key VARCHAR(8000)
	
	DECLARE @s_value_len_len VARCHAR(1)
	DECLARE @value_len_len INT
	DECLARE @s_value_len VARCHAR(9)
	DECLARE @value_len INT
	DECLARE @s_value VARCHAR(8000)
	
	DECLARE @pos INT
	SET @pos = 1
	
	WHILE (@pos <= @len_data)
	BEGIN
		-- Parse Key Length Length
		SET @s_key_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_key_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len_len = CAST(@s_key_len_len AS INT)
		IF LEN(@key_len_len) <= 0 -- Key Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Key Length
		SET @s_key_len = SUBSTRING(@data, @pos, @key_len_len)
		IF LEN(@s_key_len) < @key_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len = CAST(@s_key_len AS INT)
		IF LEN(@key_len) <= 0 -- Key Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @key_len_len
		
		-- Parse Key
		SET @s_key = SUBSTRING(@data, @pos, @key_len)
		SET @pos = @pos + @key_len
		
		-- Parse Value Length Length
		SET @s_value_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_value_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len_len = CAST(@s_value_len_len AS INT)
		IF LEN(@value_len_len) <= 0 -- Value Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Value Length
		SET @s_value_len = SUBSTRING(@data, @pos, @value_len_len)
		IF LEN(@s_value_len) < @value_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len = CAST(@s_value_len AS INT)
		IF LEN(@value_len) <= 0 -- Value Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @value_len_len
		
		-- Parse Value
		IF @s_key = @key
		BEGIN
			-- If the Key matches, return the Value immediately
			SET @s_value = SUBSTRING(@data, @pos, @value_len)
			RETURN @s_value
		END
		SET @pos = @pos + @value_len
	END
	
	RETURN NULL
END

GO

/****** Object:  UserDefinedFunction [dbo].[formatAmount]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[formatAmount] (@amount POST_MONEY, @currency_code CHAR (3))
	RETURNS FLOAT
AS
BEGIN
	IF (@currency_code IS NULL)
	BEGIN
		SET @currency_code = '840'
	END
		IF (@currency_code = '000')
	BEGIN
		SET @currency_code = '840'
	END	

	DECLARE @d INT

	SELECT @d = nr_decimals
	FROM
		post_currencies (NOLOCK)
	WHERE		
		currency_code = @currency_code
	IF (@d IS NULL)
	BEGIN
		SET @d = 2
	END
	
	RETURN (CAST ( (@amount / POWER (10, @d)) AS FLOAT))
END

GO

/****** Object:  UserDefinedFunction [dbo].[formatAmountStr]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION [dbo].[formatAmountStr] (@amount POST_MONEY, @currency_code CHAR (3))
RETURNS VARCHAR (13)
AS
BEGIN
	DECLARE @is_negative INT
	IF (@amount < 0)
	BEGIN
		SET @is_negative = 1
		SET @amount = ABS(@amount)
	END
	
	IF (@currency_code IS NULL)
	BEGIN
		SET @currency_code = '840'
	END

	IF (@currency_code = '000')
	BEGIN
		SET @currency_code = '840'
	END	


	DECLARE @d INT,
		@s	VARCHAR (13), 
		@t	VARCHAR (13)
	
	SELECT @d = nr_decimals
	FROM
		post_currencies WITH (NOLOCK)
	WHERE		
		currency_code = @currency_code

	IF (@d IS NULL)
	BEGIN
		SET @d = 2
	END

	DECLARE @s_amount VARCHAR (13),
		@l INT,
		@r INT

	SET @s_amount = CAST (@amount AS VARCHAR(13))
	
	IF (@d = 0)
	BEGIN
		SET @s = @s_amount
	END
	ELSE
	BEGIN
		SET @s = RIGHT (@s_amount, @d)
		IF (LEN(@s) < @d)
		BEGIN
			SET @s = LEFT('00000000', @d - LEN(@s)) + @s
		END
		
		SET @l = LEN(@s_amount) - @d
		IF (@l <0)
		BEGIN
			SET @s = '0.' + @s
		END
		ELSE
		BEGIN
			SET @t = LEFT (@s_amount,@l ) 
			IF (@t IS NULL OR @t = '')
				SET @t = '0'
			SET @s = @t + '.' + @s
		END
	END

	IF (@is_negative = 1)
	BEGIN
		SET @s = '-' + @s
	END

	RETURN @s

END

GO

/****** Object:  UserDefinedFunction [dbo].[formatMsgName]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION [dbo].[formatMsgName] (	@message_type CHAR (4))
RETURNS VARCHAR (30)
AS
BEGIN
		DECLARE @s		VARCHAR (30)
			
		SELECT @s =
				CASE
					WHEN @message_type = '0100' THEN 'Auth Request'
					WHEN @message_type = '0120' THEN 'Auth Advice'
					WHEN @message_type = '0200' THEN 'Financial Request'
					WHEN @message_type = '0220' THEN 'Financial Advice'
					WHEN @message_type = '0400' THEN 'Reversal Request'
					WHEN @message_type = '0420' THEN 'Reversal Advice'
					
					WHEN @message_type = '0520' THEN 'Cutover'
					
					WHEN @message_type = '0600' THEN 'Admin Request'
					WHEN @message_type = '0620' THEN 'Admin Advice'
			
					ELSE @message_type
			
				END
		
		RETURN @s
END

GO

/****** Object:  UserDefinedFunction [dbo].[formatRspCodeStr]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create function placeholder_formatRspCodeStr
--------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[formatRspCodeStr] (	@rsp_code CHAR (2))
RETURNS VARCHAR (30)
AS
BEGIN
		DECLARE @s		VARCHAR (30)
			
		SELECT @s =
				CASE
					WHEN @rsp_code = '00' THEN 'Approved'
					WHEN @rsp_code = '01' THEN 'Refer to card issuer'
					WHEN @rsp_code = '02' THEN 'Refer to card issuer, special condition'
					WHEN @rsp_code = '03' THEN 'Invalid merchant'
					WHEN @rsp_code = '04' THEN 'Pick-up card'
					WHEN @rsp_code = '05' THEN 'Do not honor'
					WHEN @rsp_code = '06' THEN 'Error'
					WHEN @rsp_code = '07' THEN 'Pick-up card, special condition'
					WHEN @rsp_code = '08' THEN 'Honor with identification'
					WHEN @rsp_code = '09' THEN 'Request in progress'
			
					WHEN @rsp_code = '10' THEN 'Approved, partial'
					WHEN @rsp_code = '11' THEN 'Approved, VIP'
					WHEN @rsp_code = '12' THEN 'Invalid transaction'
					WHEN @rsp_code = '13' THEN 'Invalid amount'
					WHEN @rsp_code = '14' THEN 'Invalid card number'
					WHEN @rsp_code = '15' THEN 'No such issuer'
					WHEN @rsp_code = '16' THEN 'Approved, update track 3'
					WHEN @rsp_code = '17' THEN 'Customer cancellation'
					WHEN @rsp_code = '18' THEN 'Customer dispute'
					WHEN @rsp_code = '19' THEN 'Re-enter transaction'
			
					WHEN @rsp_code = '20' THEN 'Invalid response'
					WHEN @rsp_code = '21' THEN 'No action taken'
					WHEN @rsp_code = '22' THEN 'Suspected malfunction'
					WHEN @rsp_code = '23' THEN 'Unacceptable transaction fee'
					WHEN @rsp_code = '24' THEN 'File update not supported'
					WHEN @rsp_code = '25' THEN 'Unable to locate record'
					WHEN @rsp_code = '26' THEN 'Duplicate record'
					WHEN @rsp_code = '27' THEN 'File update field edit error'
					WHEN @rsp_code = '28' THEN 'File update file locked'
					WHEN @rsp_code = '29' THEN 'File update failed'
			
					WHEN @rsp_code = '30' THEN 'Format error'
					WHEN @rsp_code = '31' THEN 'Bank not supported'
					WHEN @rsp_code = '32' THEN 'Completed partially'
					WHEN @rsp_code = '33' THEN 'Expired card, pick-up'
					WHEN @rsp_code = '34' THEN 'Suspected fraud, pick-up'
					WHEN @rsp_code = '35' THEN 'Contact acquirer, pick-up'
					WHEN @rsp_code = '36' THEN 'Restricted card, pick-up'
					WHEN @rsp_code = '37' THEN 'Call acquirer security, pick-up'
					WHEN @rsp_code = '38' THEN 'PIN tries exceeded, pick-up'
					WHEN @rsp_code = '39' THEN 'No credit account'
			
					WHEN @rsp_code = '40' THEN 'Function not supported'
					WHEN @rsp_code = '41' THEN 'Lost card, pick-up'
					WHEN @rsp_code = '42' THEN 'No universal account'
					WHEN @rsp_code = '43' THEN 'Stolen card, pick-up'
					WHEN @rsp_code = '44' THEN 'No investment account'
					WHEN @rsp_code = '45' THEN 'Account closed'
					WHEN @rsp_code = '46' THEN 'Identification required'
					WHEN @rsp_code = '47' THEN 'Identification cross-check required'
					WHEN @rsp_code = '48' THEN 'No customer record'
					WHEN @rsp_code = '49' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code = '50' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '51' THEN 'Not sufficient funds'
					WHEN @rsp_code = '52' THEN 'No check account'
					WHEN @rsp_code = '53' THEN 'No savings account'
					WHEN @rsp_code = '54' THEN 'Expired card'
					WHEN @rsp_code = '55' THEN 'Incorrect PIN'
					WHEN @rsp_code = '56' THEN 'No card record'
					WHEN @rsp_code = '57' THEN 'Transaction not permitted to cardholder'
					WHEN @rsp_code = '58' THEN 'Transaction not permitted on terminal'
					WHEN @rsp_code = '59' THEN 'Suspected fraud'
			
					WHEN @rsp_code = '60' THEN 'Contact acquirer'
					WHEN @rsp_code = '61' THEN 'Exceeds withdrawal limit'
					WHEN @rsp_code = '62' THEN 'Restricted card'
					WHEN @rsp_code = '63' THEN 'Security violation'
					WHEN @rsp_code = '64' THEN 'Original amount incorrect'
					WHEN @rsp_code = '65' THEN 'Exceeds withdrawal frequency'
					WHEN @rsp_code = '66' THEN 'Call acquirer security'
					WHEN @rsp_code = '67' THEN 'Hard capture'
					WHEN @rsp_code = '68' THEN 'Response received too late'
					WHEN @rsp_code = '69' THEN 'Advice received too late'
			
					WHEN @rsp_code = '70' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '71' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '72' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '73' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '74' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '75' THEN 'PIN tries exceeded'
					WHEN @rsp_code = '76' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '77' THEN 'Intervene, bank approval required'
					WHEN @rsp_code = '78' THEN 'Intervene, bank approval required for partial amount'
					WHEN @rsp_code = '79' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '80' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '81' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '82' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '83' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '84' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '85' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '86' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '87' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '88' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '89' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '90' THEN 'Cut-off in progress'
					WHEN @rsp_code = '91' THEN 'Issuer or switch inoperative'
					WHEN @rsp_code = '92' THEN 'Routing error'
					WHEN @rsp_code = '93' THEN 'Violation of law'
					WHEN @rsp_code = '94' THEN 'Duplicate transaction'
					WHEN @rsp_code = '95' THEN 'Reconcile error'
					WHEN @rsp_code = '96' THEN 'System malfunction'
					WHEN @rsp_code = '97' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '98' THEN 'Exceeds cash limit'
					WHEN @rsp_code = '99' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code BETWEEN '0A' AND 'A0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'A1' THEN 'ATC not incremented'
					WHEN @rsp_code = 'A2' THEN 'ATC limit exceeded'
					WHEN @rsp_code = 'A3' THEN 'ATC configuration error'
					WHEN @rsp_code = 'A4' THEN 'CVR check failure'
					WHEN @rsp_code = 'A5' THEN 'CVR configuration error'
					WHEN @rsp_code = 'A6' THEN 'TVR check failure'
					WHEN @rsp_code = 'A7' THEN 'TVR configuration error'
			
					WHEN @rsp_code BETWEEN 'A8' AND 'BZ' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'C0' THEN 'Unacceptable PIN'
					WHEN @rsp_code = 'C1' THEN 'PIN Change failed'
					WHEN @rsp_code = 'C2' THEN 'PIN Unblock failed'
			
					WHEN @rsp_code BETWEEN 'C3' AND 'D0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'D1' THEN 'MAC Error'
			
					WHEN @rsp_code BETWEEN 'D2' AND 'E0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'E1' THEN 'Prepay error'
			
					WHEN @rsp_code BETWEEN 'E2' AND 'MZ' THEN @rsp_code+'-Reserved for future Postilion use'
					WHEN @rsp_code BETWEEN 'N0' AND 'ZZ' THEN @rsp_code+'-Reserved for client use'
			
					ELSE @rsp_code+'-Unlisted Response Code'
			
				END
		
		RETURN @s
END

GO

/****** Object:  UserDefinedFunction [dbo].[formatTranTypeStr]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION [dbo].[formatTranTypeStr] (	@tran_type CHAR (2), 
										@extended_tran_type CHAR (4),
										@message_type CHAR (4))
RETURNS VARCHAR (60)
AS
BEGIN
		DECLARE @s		VARCHAR (60)			
		SET		@s 		= 	NULL
		
		DECLARE @msg VARCHAR (15)
		SET @msg = ''
		
		IF (@message_type IN ('0100', '0120'))
			SET @msg = ' (Auth)'
			
		IF (@message_type IN ('0400', '0420'))
			SET @msg = ' (Rev)'
		
		
		IF (@tran_type NOT IN ('12', '25', '32', '42', '52', '91'))
		BEGIN
		
			-- Transaction type which have no extended types
			
			SELECT
					@s = description
			FROM
					post_tran_types WITH (NOLOCK)
			WHERE
					code = @tran_type
					
			IF (@s IS NULL)
				SET @s = 'Unknown'
			
			RETURN (@s + @msg)
		END
		
		IF (@tran_type = '91')
		BEGIN
			SELECT
					@s = description
			FROM
					post_tran_types WITH (NOLOCK)
			WHERE
					code = @extended_tran_type
					
			IF (@s IS NULL)
				SET @s = 'General Admin'
			
			RETURN (@s + @msg)
		END
		
		
		DECLARE @s2		VARCHAR (60)			
		SET		@s2 		= 	NULL
		
		
		
		SELECT
				@s = description
		FROM
				post_tran_types WITH (NOLOCK)
		WHERE
				code = @tran_type
				
		
				
		SELECT
				@s2 = description
		FROM
				post_tran_types WITH (NOLOCK)
		WHERE
				code = @extended_tran_type
				
		
		
		IF (@s IS NULL)
		BEGIN
			SET @s = 'Unknown'
		END
		
		IF (@s2 IS NULL)
		BEGIN
			RETURN @s 
		END
		ELSE
		BEGIN
			RETURN (@s + ' - ' + @s2 + @msg)
		END
		
		RETURN NULL		
END

GO

/****** Object:  UserDefinedFunction [dbo].[GetIssuerCode]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER FUNCTION [dbo].[GetIssuerCode](@TotalsGroup VARCHAR(30))
-- Returns @DateTime at midnight; i.e., it removes the time portion of a DateTime value.
RETURNS VARCHAR(32)
AS
    BEGIN
    DECLARE @code VARCHAR(32)
    if @TotalsGroup IS NULL return 'XXX'
                        SET @code=substring (@TotalsGroup,1,3)

    RETURN @code
    END





GO

/****** Object:  UserDefinedFunction [dbo].[isApproveRspCode]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION  [dbo].[isApproveRspCode] (@rsp_code CHAR (2))
RETURNS BIT
AS
BEGIN
	IF (
		   @rsp_code = '00' --SUCCESSFUL
		OR @rsp_code = '08' --HONOUR_WITH_ID
		OR @rsp_code = '10' --APPROVED_PARTIAL
		OR @rsp_code = '11' --APPROVED_VIP
		OR @rsp_code = '16' --APPROVED_UPDATE_TRACK_3
		)
	BEGIN
		RETURN 1
	END

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[mc_stan]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER FUNCTION  [dbo].[mc_stan] (@tran_nr VARCHAR (30))
RETURNS VARCHAR (8)
AS
BEGIN

	DECLARE @ms VARCHAR (8)
	
	SELECT @ms = system_trace_audit_nr 
	from post_tran (nolock,INDEX(ix_post_tran_3))
	where tran_postilion_originated = 1
	and tran_nr = @tran_nr
	
	
	RETURN @ms
	
END






GO

/****** Object:  UserDefinedFunction [dbo].[ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_chk]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_col]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_def]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_fk]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_func]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_idx]    Script Date: 05/17/2016 16:51:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_obj]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_proc]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_tbl]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_exists_trig]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_get_def_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_part_view_tran]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_part_view_tran](@online_system_id INT, @participant_id INT)
RETURNS INT
AS
BEGIN

	IF EXISTS (
					SELECT *
					FROM
						post_part_user_rights
					WHERE
						online_system_id = @online_system_id
						AND
						participant_id = @participant_id
						AND
						IS_MEMBER (user_group) = 1
						AND
						(tran_rights & 1) = 1
					)

		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_patch_get_action]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_LenStructDataElem]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--------------------------------------------------------------------------------
-- Create function placeholder_fn_LenStructDataElem
--------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[placeholder_fn_LenStructDataElem](@data TEXT, @key VARCHAR (200))
	RETURNS INT
AS
BEGIN
	IF (@data IS NULL OR @key IS NULL)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @len_data INT
	SET @len_data = DATALENGTH(@data)
	
	IF (@len_data <= 0)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @s_key_len_len VARCHAR(1)
	DECLARE @key_len_len INT
	DECLARE @s_key_len VARCHAR(9)
	DECLARE @key_len INT
	DECLARE @s_key VARCHAR(8000)
	
	DECLARE @s_value_len_len VARCHAR(1)
	DECLARE @value_len_len INT
	DECLARE @s_value_len VARCHAR(9)
	DECLARE @value_len INT
	
	DECLARE @pos INT
	SET @pos = 1
	
	WHILE (@pos <= @len_data)
	BEGIN
		-- Parse Key Length Length
		SET @s_key_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_key_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len_len = CAST(@s_key_len_len AS INT)
		IF LEN(@key_len_len) <= 0 -- Key Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Key Length
		SET @s_key_len = SUBSTRING(@data, @pos, @key_len_len)
		IF LEN(@s_key_len) < @key_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len = CAST(@s_key_len AS INT)
		IF LEN(@key_len) <= 0 -- Key Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @key_len_len
		
		-- Parse Key
		SET @s_key = SUBSTRING(@data, @pos, @key_len)
		SET @pos = @pos + @key_len
		
		-- Parse Value Length Length
		SET @s_value_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_value_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len_len = CAST(@s_value_len_len AS INT)
		IF LEN(@value_len_len) <= 0 -- Value Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Value Length
		SET @s_value_len = SUBSTRING(@data, @pos, @value_len_len)
		IF LEN(@s_value_len) < @value_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len = CAST(@s_value_len AS INT)
		IF LEN(@value_len) <= 0 -- Value Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @value_len_len
		
		-- Return Value Length
		IF @s_key = @key
		BEGIN
			-- If the Key matches, return the Value length immediately
			RETURN @value_len
		END
		SET @pos = @pos + @value_len
	END
	
	RETURN 0
END



GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--------------------------------------------------------------------------------
-- ALTER FUNCTION placeholder_fn_rpt_changeSignForReversal
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN @amount * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END



GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_rpt_GetBeginCashForTerminal]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION  [dbo].[placeholder_fn_rpt_GetBeginCashForTerminal] 
(
	@terminal_id CHAR(8), 
	@recon_business_date DATETIME
)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @amount 					FLOAT
	DECLARE @settle_amount_impact 				FLOAT
	DECLARE @structured_data		VARCHAR(8000)
	DECLARE @media_totals			CHAR(50)
	DECLARE @cash_begin				FLOAT
	DECLARE @xml_value 				VARCHAR(8000)
	DECLARE @record_pos				INTEGER

	--Need to take into account <NetReplenishment> totals if replenishment was first
	--transaction of business date
	DECLARE @cash_added		FLOAT
	DECLARE @cash_removed		FLOAT

	--Flag to indicate whether there were transactions on the business date
	DECLARE @has_tran_on_bus_date			INT

	SET @amount = 0
	SET @cash_added = 0
	SET @cash_removed = 0

	SET @settle_amount_impact = 0
	SET @has_tran_on_bus_date = 1

	-- For this terminal: Get the first transaction of this business date. (That will tell us the Cash position at the start of the business day)
	SELECT TOP 1 @structured_data = structured_data_req
	FROM post_tran t WITH (NOLOCK)
			LEFT JOIN post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
	WHERE (t.recon_business_date = @recon_business_date) AND
			(c.terminal_id = @terminal_id) AND
			(t.tran_postilion_originated = 0)
	ORDER BY datetime_req

	IF (@@ROWCOUNT = 0)
	BEGIN
		--Get the last transaction before the current business date
		SELECT TOP 1 	@settle_amount_impact =
				CASE WHEN tran_type IN ('01','03') THEN settle_amount_impact ELSE 0 END,
				@structured_data = structured_data_req
		FROM post_tran t WITH (NOLOCK)
				LEFT JOIN post_tran_cust c WITH (NOLOCK) ON (t.post_tran_cust_id = c.post_tran_cust_id)
		WHERE (t.recon_business_date < @recon_business_date) AND
				(c.terminal_id = @terminal_id) AND
				(t.tran_postilion_originated = 0)
		ORDER BY datetime_req DESC

		IF (@@ROWCOUNT = 0)	-- It means we could not find a transaction for this terminal on this day. Then assume the balance has not changed since the previous day.
			RETURN NULL

		SET @has_tran_on_bus_date = 0
	END

	IF (LEN(@structured_data) = 0)	-- It means something is wrong. All transactions from ATMAPP 3.2 or later should have Cash Position information in Structured Data
		RETURN NULL

	-- Now pull the Begin Cash value from Structure Data
	SET @cash_begin 	= 0
	SET @media_totals = 'MediaTotals'

	IF (CHARINDEX('<MediaTotals>', @structured_data) > 0)	-- This is the Tag we are looking for
	BEGIN
		SET @record_pos = CHARINDEX('<MediaTotals>', @structured_data) + 11

		SET @xml_value = SUBSTRING(@structured_data, CHARINDEX('<MediaTotals>', @structured_data)+13, CHARINDEX('</MediaTotals>', @structured_data, @record_pos) - CHARINDEX('<MediaTotals>', @structured_data, @record_pos) - 11)

		IF (CHARINDEX('<Total>', @xml_value) > 0)
		BEGIN
			DECLARE @totals 		VARCHAR(4000)

			SET @record_pos = CHARINDEX('<Total>', @xml_value) + 7
			SET @totals = SUBSTRING(@xml_value, CHARINDEX('<Total>', @xml_value, @record_pos)+7, CHARINDEX('</Total>', @xml_value, @record_pos) - CHARINDEX('<Total>', @xml_value, @record_pos) - 7)

			--SET @record_pos = CHARINDEX('</Totals>', @xml_value, @record_pos)+7

			IF (CHARINDEX('<Amount>', @totals) > 0)
				SET @cash_begin = SUBSTRING(@totals, CHARINDEX('<Amount>', @totals)+8, CHARINDEX('</Amount>', @totals) - CHARINDEX('<Amount>', @totals) - 8)
		END

		--If this also happened to be a replenishment (on current business_date)
		IF (CHARINDEX('<NetReplenishment>', @structured_data) > 0 AND
			@has_tran_on_bus_date = 1)
		BEGIN
			SET @xml_value = SUBSTRING(@structured_data, CHARINDEX('<NetReplenishment>', @structured_data)+18, CHARINDEX('</NetReplenishment>', @structured_data) - CHARINDEX('<NetReplenishment>', @structured_data) - 18)

			IF (CHARINDEX('<CashAdded>', @xml_value) > 0)
			--PRINT 'Cash Added' + SUBSTRING(@xml_value, CHARINDEX('<CashAdded>', @xml_value)+11, CHARINDEX('</CashAdded>', @xml_value) - CHARINDEX('<CashAdded>', @xml_value) - 11)
				SET @cash_added = SUBSTRING(@xml_value, CHARINDEX('<CashAdded>', @xml_value)+11, CHARINDEX('</CashAdded>', @xml_value) - CHARINDEX('<CashAdded>', @xml_value) - 11)

			IF (CHARINDEX('<CashRemoved>', @xml_value) > 0)
			--PRINT 'Cash Removed' + SUBSTRING(@replenish_xml, CHARINDEX('<CashRemoved>', @replenish_xml)+13, CHARINDEX('</CashRemoved>', @replenish_xml) - CHARINDEX('<CashRemoved>', @replenish_xml) - 13)
				SET @cash_removed = SUBSTRING(@xml_value, CHARINDEX('<CashRemoved>', @xml_value)+13, CHARINDEX('</CashRemoved>', @xml_value) - CHARINDEX('<CashRemoved>', @xml_value) - 13)
		END
	END
	ELSE	-- It means something is wrong. All transactions from ATMAPP 3.2 or later should have Cash Position information in Structured Data
		RETURN NULL

	RETURN @cash_begin + @settle_amount_impact + @cash_added - @cash_removed
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_rpt_GetSuspectReason]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION  [dbo].[placeholder_fn_rpt_GetSuspectReason]
(
	@structured_data VARCHAR(4000)
)
	RETURNS VARCHAR(4000)
AS
BEGIN

	DECLARE @xml_value 			VARCHAR(4000)
	DECLARE @suspect_reason			CHAR(13)
	DECLARE @record_pos			INT
	DECLARE @length_char			CHAR(10)
	DECLARE @length_length			INT
	DECLARE @length_char2			CHAR(10)
	DECLARE @length			INT

	IF (LEN(@structured_data) = 0)
		RETURN -2

	SET @suspect_reason = 'SuspectReason'

	IF (CHARINDEX(@suspect_reason, @structured_data) > 0)
	BEGIN
		SET @record_pos = CHARINDEX(@suspect_reason, @structured_data) + 13
		SET @length_char = SUBSTRING(@structured_data, @record_pos, 1)
		SET @length_length = CAST(@length_char AS INT)
		SET @length_char2 = SUBSTRING(@structured_data, @record_pos + 1, @length_length)
		SET @length	 = CAST(@length_char2 AS INT)

		SET @xml_value = SUBSTRING(@structured_data, @record_pos + @length_length + 1, @length)

	END
	ELSE
		RETURN - 2

	RETURN @xml_value
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_rpt_isATMCustomerInquiryTrx]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[placeholder_fn_rpt_isATMCustomerInquiryTrx](
	@tran_type CHAR(2)
	)
	RETURNS INT
AS
BEGIN
	DECLARE @r INT
	IF (@tran_type in ('30','31','35','38'))
		SET @r = 1
	ELSE
		SET @r = 0
	RETURN @r
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sql_version]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




ALTER FUNCTION [dbo].[placeholder_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_acc_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_acc_name
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_acc_name]
(
	@acc_id				INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(100)
BEGIN
	DECLARE @result	VARCHAR(100)

	SET @result = (
	SELECT
		name
	FROM
		sstl_acc
	WHERE
		config_version = @config_version
		AND
		config_set_id = @config_set_id
		AND
		acc_id = @acc_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_acc_nr]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_acc_nr
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_acc_nr]
(
	@acc_nr_id			INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(40)
BEGIN
	DECLARE @result	VARCHAR(40)

	SET @result = (
	SELECT
		acc_nr
	FROM
		sstl_se_acc_nr
	WHERE
		acc_nr_id = @acc_nr_id
		AND
		config_version = @config_version
		AND
		config_set_id = @config_set_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_amount_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_amount_name
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_amount_name]
(
	@amount_id			INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(100)
BEGIN
	DECLARE @result VARCHAR(100)

	SET @result = (
	SELECT
		name
	FROM
		sstl_se_amount
	WHERE
		config_version = @config_version
		AND
		config_set_id = @config_set_id
		AND
		amount_id = @amount_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_amount_value]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_amount_value
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_amount_value]
(
	@amount_value_id	INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(255)
BEGIN
	DECLARE @result	VARCHAR(255)

	SET @result = (
	SELECT
		description
	FROM
		sstl_se_amount_value
	WHERE
		config_version = @config_version
		AND
		config_set_id	= @config_set_id
		AND
		amount_value_id = @amount_value_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_coa_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_coa_name
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_coa_name]
(
	@coa_id				INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(100)
BEGIN
	DECLARE @result	VARCHAR(100)

	SET @result = (
	SELECT
		name
	FROM
		sstl_coa
	WHERE
		config_version = @config_version
		AND
		config_set_id = @config_set_id
		AND
		coa_id = @coa_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_config_set_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_config_set_name
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_config_set_name]
(
	@config_set_id	INT
)
RETURNS	VARCHAR(100)
BEGIN
	DECLARE @result	VARCHAR(100)

	SET @result = (
	SELECT
		name
	FROM
		sstl_config_set
	WHERE
		config_set_id = @config_set_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_fee_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_fee_name
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_fee_name]
(
	@fee_id				INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(100)
BEGIN
	DECLARE @result	VARCHAR(100)

	SET @result = (
	SELECT
		name
	FROM
		sstl_se_fee
	WHERE
		config_version = @config_version
		AND
		config_set_id = @config_set_id
		AND
		fee_id = @fee_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_fee_value]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_fee_value
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_fee_value]
(
	@fee_value_id		INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(255)
BEGIN
	DECLARE @result	VARCHAR(255)

	SET @result = (
	SELECT
		description
	FROM
		sstl_se_fee_value
	WHERE
		config_version = @config_version
		AND
		config_set_id = @config_set_id
		AND
		fee_value_id = @fee_value_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_filter_string]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_filter_string
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_filter_string]
(
	@table_name		VARCHAR(20),
	@config_set_id	INT,
	@entity_name	VARCHAR(30),
	@CoA_id			INT,
	@acc_nr			VARCHAR(30),
	@gran_element	VARCHAR(30),
	@tag				VARCHAR(30)
)
RETURNS
	VARCHAR(1000)
AS
BEGIN

	DECLARE @filter_string 	VARCHAR(1000)
	SET @filter_string = ''

	IF (@entity_name IS NOT NULL)
	BEGIN
		SET @filter_string = @filter_string + CHAR(10) + 'AND' + CHAR(10) + @table_name + '.se_id '

		DECLARE @se_id INT
		DECLARE se_cursor CURSOR FAST_FORWARD
		FOR
		SELECT
			DISTINCT(se_id)
		FROM
			sstl_se_w
		WHERE
			sstl_se_w.name = @entity_name
			AND
			sstl_se_w.config_set_id = @config_set_id

		OPEN se_cursor

		FETCH NEXT FROM se_cursor
		INTO @se_id

		IF (@@FETCH_STATUS = 0)
		BEGIN
			SET @filter_string = @filter_string + ' IN (' + CONVERT(VARCHAR(10),@se_id)
			FETCH NEXT FROM se_cursor
			INTO @se_id

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				SET @filter_string = @filter_string + ',' + CONVERT(VARCHAR(10),@se_id)

				FETCH NEXT FROM se_cursor
				INTO @se_id
			END
			SET @filter_string = @filter_string + ') '
		END
		ELSE
		BEGIN
			SET @filter_string = @filter_string + ' = -1 '
		END

		CLOSE se_cursor
		DEALLOCATE se_cursor

	END

	IF (@acc_nr IS NOT NULL)
	BEGIN

		SET @filter_string = @filter_string + CHAR(10) + 'AND' + CHAR(10) + '('+@table_name + '.credit_acc_nr_id '

		DECLARE @acc_nr_id	INT
		DECLARE acc_nr_id_cursor CURSOR SCROLL READ_ONLY
		FOR
		SELECT
			DISTINCT(acc_nr_id)
		FROM
			sstl_se_acc_nr_w
		WHERE
			sstl_se_acc_nr_w.acc_nr = @acc_nr
			AND
			sstl_se_acc_nr_w.config_set_id = @config_set_id

		OPEN acc_nr_id_cursor

		FETCH NEXT FROM acc_nr_id_cursor
		INTO @acc_nr_id

		IF (@@FETCH_STATUS = 0)
		BEGIN

			SET @filter_string = @filter_string + ' IN (' + CONVERT(VARCHAR(10),@acc_nr_id)

			FETCH NEXT FROM acc_nr_id_cursor
			INTO @acc_nr_id

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				SET @filter_string = @filter_string + ' ,'+CONVERT(VARCHAR(10),@acc_nr_id)

				FETCH NEXT FROM acc_nr_id_cursor
				INTO @acc_nr_id
			END
			SET @filter_string = @filter_string + ')'
		END
		ELSE
		BEGIN
			SET @filter_string = @filter_string + ' = -1 '
		END

		SET @filter_string = @filter_string + CHAR(10) + ' OR ' + CHAR(10) + @table_name + '.debit_acc_nr_id '

		FETCH FIRST FROM acc_nr_id_cursor
		INTO @acc_nr_id

		IF (@@FETCH_STATUS = 0)
		BEGIN
			SET @filter_string = @filter_string + ' IN (' + CONVERT(VARCHAR(10),@acc_nr_id)

			FETCH NEXT FROM acc_nr_id_cursor
			INTO @acc_nr_id

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				SET @filter_string = @filter_string + ' , '+CONVERT(VARCHAR(10),@acc_nr_id)

				FETCH NEXT FROM acc_nr_id_cursor
				INTO @acc_nr_id
			END
			SET @filter_string = @filter_string + ')' + CHAR(10)
		END
		ELSE
		BEGIN
			SET @filter_string = @filter_string + ' = -1 '
		END

		CLOSE acc_nr_id_cursor
		DEALLOCATE acc_nr_id_cursor

		SET @filter_string = @filter_string + ') '

	END

	IF (@coa_id IS NOT NULL)
	BEGIN
		SET @filter_string = @filter_string + CHAR(10) + 'AND ' + CHAR(10) + @table_name + '.coa_id = ' + CONVERT(VARCHAR(2), @coa_id )
	END

	IF (@tag IS NOT NULL)
	BEGIN
		SET @filter_string = @filter_string + CHAR(10) + 'AND ' + CHAR(10) + @table_name + '.tag = ''' + @tag + ''''
	END

	IF (@gran_element IS NOT NULL)
	BEGIN
		SET @filter_string = @filter_string + CHAR(10) + 'AND ' + CHAR(10) + @table_name + '.granularity_element = ''' + @gran_element + ''''
	END

	RETURN @filter_string
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_sstl_get_se_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




--------------------------------------------------------------------------------
-- Create function :  placeholder_fn_sstl_get_se_name
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_fn_sstl_get_se_name]
(
	@se_id				INT,
	@config_version	INT,
	@config_set_id		INT
)
RETURNS VARCHAR(100)
BEGIN
	DECLARE @result	VARCHAR(100)

	SET @result = (
	SELECT
		name
	FROM
		sstl_se
	WHERE
		se_id = @se_id
		AND
		config_version = @config_version
		AND
		config_set_id = @config_set_id)

	RETURN @result
END




GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_fn_StructDataElem]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--------------------------------------------------------------------------------
-- Create function placeholder_fn_StructDataElem
--------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[placeholder_fn_StructDataElem](@data TEXT, @key VARCHAR (200))
	RETURNS VARCHAR(8000)
AS
BEGIN
	IF (@data IS NULL OR @key IS NULL)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @len_data INT
	SET @len_data = DATALENGTH(@data)
	
	IF (@len_data <= 0)
	BEGIN
		RETURN NULL
	END
	
	DECLARE @s_key_len_len VARCHAR(1)
	DECLARE @key_len_len INT
	DECLARE @s_key_len VARCHAR(9)
	DECLARE @key_len INT
	DECLARE @s_key VARCHAR(8000)
	
	DECLARE @s_value_len_len VARCHAR(1)
	DECLARE @value_len_len INT
	DECLARE @s_value_len VARCHAR(9)
	DECLARE @value_len INT
	DECLARE @s_value VARCHAR(8000)
	
	DECLARE @pos INT
	SET @pos = 1
	
	WHILE (@pos <= @len_data)
	BEGIN
		-- Parse Key Length Length
		SET @s_key_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_key_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len_len = CAST(@s_key_len_len AS INT)
		IF LEN(@key_len_len) <= 0 -- Key Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Key Length
		SET @s_key_len = SUBSTRING(@data, @pos, @key_len_len)
		IF LEN(@s_key_len) < @key_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @key_len = CAST(@s_key_len AS INT)
		IF LEN(@key_len) <= 0 -- Key Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @key_len_len
		
		-- Parse Key
		SET @s_key = SUBSTRING(@data, @pos, @key_len)
		SET @pos = @pos + @key_len
		
		-- Parse Value Length Length
		SET @s_value_len_len = SUBSTRING(@data, @pos, 1)
		IF LEN(@s_value_len_len) < 1 -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len_len = CAST(@s_value_len_len AS INT)
		IF LEN(@value_len_len) <= 0 -- Value Length Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + 1
		
		-- Parse Value Length
		SET @s_value_len = SUBSTRING(@data, @pos, @value_len_len)
		IF LEN(@s_value_len) < @value_len_len -- Stop if end of TEXT reached unexpectedly
		BEGIN
			RETURN NULL
		END
		SET @value_len = CAST(@s_value_len AS INT)
		IF LEN(@value_len) <= 0 -- Value Length may not be negative or zero
		BEGIN
			RETURN NULL
		END
		SET @pos = @pos + @value_len_len
		
		-- Parse Value
		IF @s_key = @key
		BEGIN
			-- If the Key matches, return the Value immediately
			SET @s_value = SUBSTRING(@data, @pos, @value_len)
			RETURN @s_value
		END
		SET @pos = @pos + @value_len
	END
	
	RETURN NULL
END



GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_formatRspCodeStr]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--------------------------------------------------------------------------------
-- Create function placeholder_formatRspCodeStr
--------------------------------------------------------------------------------

ALTER FUNCTION [dbo].[placeholder_formatRspCodeStr] (	@rsp_code CHAR (2))
RETURNS VARCHAR (30)
AS
BEGIN
		DECLARE @s		VARCHAR (30)
			
		SELECT @s =
				CASE
					WHEN @rsp_code = '00' THEN 'Approved'
					WHEN @rsp_code = '01' THEN 'Refer to card issuer'
					WHEN @rsp_code = '02' THEN 'Refer to card issuer, special condition'
					WHEN @rsp_code = '03' THEN 'Invalid merchant'
					WHEN @rsp_code = '04' THEN 'Pick-up card'
					WHEN @rsp_code = '05' THEN 'Do not honor'
					WHEN @rsp_code = '06' THEN 'Error'
					WHEN @rsp_code = '07' THEN 'Pick-up card, special condition'
					WHEN @rsp_code = '08' THEN 'Honor with identification'
					WHEN @rsp_code = '09' THEN 'Request in progress'
			
					WHEN @rsp_code = '10' THEN 'Approved, partial'
					WHEN @rsp_code = '11' THEN 'Approved, VIP'
					WHEN @rsp_code = '12' THEN 'Invalid transaction'
					WHEN @rsp_code = '13' THEN 'Invalid amount'
					WHEN @rsp_code = '14' THEN 'Invalid card number'
					WHEN @rsp_code = '15' THEN 'No such issuer'
					WHEN @rsp_code = '16' THEN 'Approved, update track 3'
					WHEN @rsp_code = '17' THEN 'Customer cancellation'
					WHEN @rsp_code = '18' THEN 'Customer dispute'
					WHEN @rsp_code = '19' THEN 'Re-enter transaction'
			
					WHEN @rsp_code = '20' THEN 'Invalid response'
					WHEN @rsp_code = '21' THEN 'No action taken'
					WHEN @rsp_code = '22' THEN 'Suspected malfunction'
					WHEN @rsp_code = '23' THEN 'Unacceptable transaction fee'
					WHEN @rsp_code = '24' THEN 'File update not supported'
					WHEN @rsp_code = '25' THEN 'Unable to locate record'
					WHEN @rsp_code = '26' THEN 'Duplicate record'
					WHEN @rsp_code = '27' THEN 'File update field edit error'
					WHEN @rsp_code = '28' THEN 'File update file locked'
					WHEN @rsp_code = '29' THEN 'File update failed'
			
					WHEN @rsp_code = '30' THEN 'Format error'
					WHEN @rsp_code = '31' THEN 'Bank not supported'
					WHEN @rsp_code = '32' THEN 'Completed partially'
					WHEN @rsp_code = '33' THEN 'Expired card, pick-up'
					WHEN @rsp_code = '34' THEN 'Suspected fraud, pick-up'
					WHEN @rsp_code = '35' THEN 'Contact acquirer, pick-up'
					WHEN @rsp_code = '36' THEN 'Restricted card, pick-up'
					WHEN @rsp_code = '37' THEN 'Call acquirer security, pick-up'
					WHEN @rsp_code = '38' THEN 'PIN tries exceeded, pick-up'
					WHEN @rsp_code = '39' THEN 'No credit account'
			
					WHEN @rsp_code = '40' THEN 'Function not supported'
					WHEN @rsp_code = '41' THEN 'Lost card, pick-up'
					WHEN @rsp_code = '42' THEN 'No universal account'
					WHEN @rsp_code = '43' THEN 'Stolen card, pick-up'
					WHEN @rsp_code = '44' THEN 'No investment account'
					WHEN @rsp_code = '45' THEN 'Account closed'
					WHEN @rsp_code = '46' THEN 'Identification required'
					WHEN @rsp_code = '47' THEN 'Identification cross-check required'
					WHEN @rsp_code = '48' THEN 'No customer record'
					WHEN @rsp_code = '49' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code = '50' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '51' THEN 'Not sufficient funds'
					WHEN @rsp_code = '52' THEN 'No check account'
					WHEN @rsp_code = '53' THEN 'No savings account'
					WHEN @rsp_code = '54' THEN 'Expired card'
					WHEN @rsp_code = '55' THEN 'Incorrect PIN'
					WHEN @rsp_code = '56' THEN 'No card record'
					WHEN @rsp_code = '57' THEN 'Transaction not permitted to cardholder'
					WHEN @rsp_code = '58' THEN 'Transaction not permitted on terminal'
					WHEN @rsp_code = '59' THEN 'Suspected fraud'
			
					WHEN @rsp_code = '60' THEN 'Contact acquirer'
					WHEN @rsp_code = '61' THEN 'Exceeds withdrawal limit'
					WHEN @rsp_code = '62' THEN 'Restricted card'
					WHEN @rsp_code = '63' THEN 'Security violation'
					WHEN @rsp_code = '64' THEN 'Original amount incorrect'
					WHEN @rsp_code = '65' THEN 'Exceeds withdrawal frequency'
					WHEN @rsp_code = '66' THEN 'Call acquirer security'
					WHEN @rsp_code = '67' THEN 'Hard capture'
					WHEN @rsp_code = '68' THEN 'Response received too late'
					WHEN @rsp_code = '69' THEN 'Advice received too late'
			
					WHEN @rsp_code = '70' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '71' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '72' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '73' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '74' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '75' THEN 'PIN tries exceeded'
					WHEN @rsp_code = '76' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '77' THEN 'Intervene, bank approval required'
					WHEN @rsp_code = '78' THEN 'Intervene, bank approval required for partial amount'
					WHEN @rsp_code = '79' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '80' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '81' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '82' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '83' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '84' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '85' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '86' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '87' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '88' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '89' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '90' THEN 'Cut-off in progress'
					WHEN @rsp_code = '91' THEN 'Issuer or switch inoperative'
					WHEN @rsp_code = '92' THEN 'Routing error'
					WHEN @rsp_code = '93' THEN 'Violation of law'
					WHEN @rsp_code = '94' THEN 'Duplicate transaction'
					WHEN @rsp_code = '95' THEN 'Reconcile error'
					WHEN @rsp_code = '96' THEN 'System malfunction'
					WHEN @rsp_code = '97' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '98' THEN 'Exceeds cash limit'
					WHEN @rsp_code = '99' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code BETWEEN '0A' AND 'A0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'A1' THEN 'ATC not incremented'
					WHEN @rsp_code = 'A2' THEN 'ATC limit exceeded'
					WHEN @rsp_code = 'A3' THEN 'ATC configuration error'
					WHEN @rsp_code = 'A4' THEN 'CVR check failure'
					WHEN @rsp_code = 'A5' THEN 'CVR configuration error'
					WHEN @rsp_code = 'A6' THEN 'TVR check failure'
					WHEN @rsp_code = 'A7' THEN 'TVR configuration error'
			
					WHEN @rsp_code BETWEEN 'A8' AND 'BZ' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'C0' THEN 'Unacceptable PIN'
					WHEN @rsp_code = 'C1' THEN 'PIN Change failed'
					WHEN @rsp_code = 'C2' THEN 'PIN Unblock failed'
			
					WHEN @rsp_code BETWEEN 'C3' AND 'D0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'D1' THEN 'MAC Error'
			
					WHEN @rsp_code BETWEEN 'D2' AND 'E0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'E1' THEN 'Prepay error'
			
					WHEN @rsp_code BETWEEN 'E2' AND 'MZ' THEN @rsp_code+'-Reserved for future Postilion use'
					WHEN @rsp_code BETWEEN 'N0' AND 'ZZ' THEN @rsp_code+'-Reserved for client use'
			
					ELSE @rsp_code+'-Unlisted Response Code'
			
				END
		
		RETURN @s
END



GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION [dbo].[placeholder_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists



GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION [dbo].[placeholder_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name



GO

/****** Object:  UserDefinedFunction [dbo].[placeholder_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



--------------------------------------------------------------------------------
-- ALTER FUNCTION placeholder_ofn_part_view_tran_2
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[placeholder_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END



GO

/****** Object:  UserDefinedFunction [dbo].[reversed_trns_tran_nr]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO







ALTER FUNCTION  [dbo].[reversed_trns_tran_nr] (@post_tran_cust_id bigint,@message_type varchar(4))
RETURNS bigint
AS
BEGIN

	DECLARE @rtn bigint
	
	SELECT @rtn = tran_nr 
	from post_tran (nolock)
	where post_tran_cust_id = @post_tran_cust_id
	and message_type = @message_type
	
	RETURN @rtn
	
END





GO

/****** Object:  UserDefinedFunction [dbo].[rollback_office_4_2_00_patch_027_fn_sql_version]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_office_4_2_00_patch_027_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_office_4_2_00_patch_034_fn_sql_version]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_office_4_2_00_patch_034_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_office_4_2_00_patch_042_fn_sql_version]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_office_4_2_00_patch_042_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_office_4_2_00_patch_32_formatRspCodeStr]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



ALTER FUNCTION [dbo].[rollback_office_4_2_00_patch_32_formatRspCodeStr] (	@rsp_code CHAR (2))
RETURNS VARCHAR (30)
AS
BEGIN
		DECLARE @s		VARCHAR (30)
			
		SELECT @s =
				CASE
					WHEN @rsp_code = '00' THEN 'Approved'
					WHEN @rsp_code = '01' THEN 'Refer to card issuer'
					WHEN @rsp_code = '02' THEN 'Refer to card issuer, special condition'
					WHEN @rsp_code = '03' THEN 'Invalid merchant'
					WHEN @rsp_code = '04' THEN 'Pick-up card'
					WHEN @rsp_code = '05' THEN 'Do not honor'
					WHEN @rsp_code = '06' THEN 'Error'
					WHEN @rsp_code = '07' THEN 'Pick-up card, special condition'
					WHEN @rsp_code = '08' THEN 'Honor with identification'
					WHEN @rsp_code = '09' THEN 'Request in progress'
			
					WHEN @rsp_code = '10' THEN 'Approved, partial'
					WHEN @rsp_code = '11' THEN 'Approved, VIP'
					WHEN @rsp_code = '12' THEN 'Invalid transaction'
					WHEN @rsp_code = '13' THEN 'Invalid amount'
					WHEN @rsp_code = '14' THEN 'Invalid card number'
					WHEN @rsp_code = '15' THEN 'No such issuer'
					WHEN @rsp_code = '16' THEN 'Approved, update track 3'
					WHEN @rsp_code = '17' THEN 'Customer cancellation'
					WHEN @rsp_code = '18' THEN 'Customer dispute'
					WHEN @rsp_code = '19' THEN 'Re-enter transaction'
			
					WHEN @rsp_code = '20' THEN 'Invalid response'
					WHEN @rsp_code = '21' THEN 'No action taken'
					WHEN @rsp_code = '22' THEN 'Suspected malfunction'
					WHEN @rsp_code = '23' THEN 'Unacceptable transaction fee'
					WHEN @rsp_code = '24' THEN 'File update not supported'
					WHEN @rsp_code = '25' THEN 'Unable to locate record'
					WHEN @rsp_code = '26' THEN 'Duplicate record'
					WHEN @rsp_code = '27' THEN 'File update field edit error'
					WHEN @rsp_code = '28' THEN 'File update file locked'
					WHEN @rsp_code = '29' THEN 'File update failed'
			
					WHEN @rsp_code = '30' THEN 'Format error'
					WHEN @rsp_code = '31' THEN 'Bank not supported'
					WHEN @rsp_code = '32' THEN 'Completed partially'
					WHEN @rsp_code = '33' THEN 'Expired card, pick-up'
					WHEN @rsp_code = '34' THEN 'Suspected fraud, pick-up'
					WHEN @rsp_code = '35' THEN 'Contact acquirer, pick-up'
					WHEN @rsp_code = '36' THEN 'Restricted card, pick-up'
					WHEN @rsp_code = '37' THEN 'Call acquirer security, pick-up'
					WHEN @rsp_code = '38' THEN 'PIN tries exceeded, pick-up'
					WHEN @rsp_code = '39' THEN 'No credit account'
			
					WHEN @rsp_code = '40' THEN 'Function not supported'
					WHEN @rsp_code = '41' THEN 'Lost card, pick-up'
					WHEN @rsp_code = '42' THEN 'No universal account'
					WHEN @rsp_code = '43' THEN 'Stolen card, pick-up'
					WHEN @rsp_code = '44' THEN 'No investment account'
					WHEN @rsp_code = '45' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '46' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '47' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '48' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '49' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code = '50' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '51' THEN 'Not sufficient funds'
					WHEN @rsp_code = '52' THEN 'No check account'
					WHEN @rsp_code = '53' THEN 'No savings account'
					WHEN @rsp_code = '54' THEN 'Expired card'
					WHEN @rsp_code = '55' THEN 'Incorrect PIN'
					WHEN @rsp_code = '56' THEN 'No card record'
					WHEN @rsp_code = '57' THEN 'Transaction not permitted to cardholder'
					WHEN @rsp_code = '58' THEN 'Transaction not permitted on terminal'
					WHEN @rsp_code = '59' THEN 'Suspected fraud'
			
					WHEN @rsp_code = '60' THEN 'Contact acquirer'
					WHEN @rsp_code = '61' THEN 'Exceeds withdrawal limit'
					WHEN @rsp_code = '62' THEN 'Restricted card'
					WHEN @rsp_code = '63' THEN 'Security violation'
					WHEN @rsp_code = '64' THEN 'Original amount incorrect'
					WHEN @rsp_code = '65' THEN 'Exceeds withdrawal frequency'
					WHEN @rsp_code = '66' THEN 'Call acquirer security'
					WHEN @rsp_code = '67' THEN 'Hard capture'
					WHEN @rsp_code = '68' THEN 'Response received too late'
					WHEN @rsp_code = '69' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code = '70' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '71' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '72' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '73' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '74' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '75' THEN 'PIN tries exceeded'
					WHEN @rsp_code = '76' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '77' THEN 'Intervene, bank approval required'
					WHEN @rsp_code = '78' THEN 'Intervene, bank approval required for partial amount'
					WHEN @rsp_code = '79' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '80' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '81' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '82' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '83' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '84' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '85' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '86' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '87' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '88' THEN 'Reserved for client-specific use (declined)'
					WHEN @rsp_code = '89' THEN 'Reserved for client-specific use (declined)'
			
					WHEN @rsp_code = '90' THEN 'Cut-off in progress'
					WHEN @rsp_code = '91' THEN 'Issuer or switch inoperative'
					WHEN @rsp_code = '92' THEN 'Routing error'
					WHEN @rsp_code = '93' THEN 'Violation of law'
					WHEN @rsp_code = '94' THEN 'Duplicate transaction'
					WHEN @rsp_code = '95' THEN 'Reconcile error'
					WHEN @rsp_code = '96' THEN 'System malfunction'
					WHEN @rsp_code = '97' THEN 'Reserved for future Postilion use'
					WHEN @rsp_code = '98' THEN 'Exceeds cash limit'
					WHEN @rsp_code = '99' THEN 'Reserved for future Postilion use'
			
					WHEN @rsp_code BETWEEN '0A' AND 'A0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'A1' THEN 'ATC not incremented'
					WHEN @rsp_code = 'A2' THEN 'ATC limit exceeded'
					WHEN @rsp_code = 'A3' THEN 'ATC configuration error'
					WHEN @rsp_code = 'A4' THEN 'CVR check failure'
					WHEN @rsp_code = 'A5' THEN 'CVR configuration error'
					WHEN @rsp_code = 'A6' THEN 'TVR check failure'
					WHEN @rsp_code = 'A7' THEN 'TVR configuration error'
			
					WHEN @rsp_code BETWEEN 'A8' AND 'BZ' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'C0' THEN 'Unacceptable PIN'
					WHEN @rsp_code = 'C1' THEN 'PIN Change failed'
					WHEN @rsp_code = 'C2' THEN 'PIN Unblock failed'
			
					WHEN @rsp_code BETWEEN 'C3' AND 'D0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'D1' THEN 'MAC Error'
			
					WHEN @rsp_code BETWEEN 'D2' AND 'E0' THEN @rsp_code+'-Reserved for future Postilion use'
			
					WHEN @rsp_code = 'E1' THEN 'Prepay error'
			
					WHEN @rsp_code BETWEEN 'E2' AND 'MZ' THEN @rsp_code+'-Reserved for future Postilion use'
					WHEN @rsp_code BETWEEN 'N0' AND 'ZZ' THEN @rsp_code+'-Reserved for client use'
			
					ELSE @rsp_code+'-Unlisted Response Code'
			
				END
		
		RETURN @s
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_office_4_2_00_patch_33_fn_StructDataElem]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_office_4_2_00_patch_33_fn_StructDataElem](@data TEXT, @key VARCHAR (200))
	RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @value VARCHAR(8000)
	SET @value = NULL

	IF (@data IS NULL OR @key IS NULL)
		RETURN NULL;

	DECLARE @key_search VARCHAR (20)
	DECLARE @pos_key INT
	DECLARE @pos_value_length INT
	DECLARE @s_len_indicator VARCHAR (100)
	DECLARE @len_indicator INT
	DECLARE @len INT
	DECLARE @s_len VARCHAR (100)

	SET @key_search = CAST(LEN(CAST(LEN(@key) AS VARCHAR)) AS VARCHAR) + CAST(LEN(@key) AS VARCHAR) + @key
	SET @pos_key = CHARINDEX (@key_search, @data)

	IF (@pos_key > 0)
	BEGIN
		SET @pos_value_length = @pos_key + LEN (@key_search)

		SET @s_len_indicator = SUBSTRING(@data, @pos_value_length, 1)

		IF (ISNUMERIC(@s_len_indicator) = 1)
			SET @len_indicator = CAST(@s_len_indicator AS INT)
		ELSE
			SET @len_indicator = NULL

		IF (@len_indicator IS NOT NULL)
		BEGIN
			SET @s_len = SUBSTRING(@data, @pos_value_length + 1, @len_indicator)
			IF (ISNUMERIC(@s_len) = 1)
				SET @len = CAST(@s_len AS INT)
			ELSE
				SET @len = NULL
		END

		SET @value = SUBSTRING (@data, @pos_value_length + 1 + @len_indicator, @len)
	END

	RETURN @value
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_office_4_2_00_patch_49_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

ALTER FUNCTION [dbo].[rollback_office_4_2_00_patch_49_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_fn_sql_version]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_chk]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_col]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_def]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_fk]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_func]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_idx]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_obj]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_proc]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_trig]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_get_def_name]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_fn_sql_version]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_chk]    Script Date: 05/17/2016 16:51:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_col]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_def]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_fk]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_func]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_idx]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_obj]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_proc]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_trig]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_get_def_name]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_chk]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_col]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_def]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_fk]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_func]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_idx]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_obj]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_proc]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_trig]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_get_def_name]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_fn_sql_version]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_chk]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_col]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_def]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_fk]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_func]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_idx]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_obj]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_proc]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_trig]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_get_def_name]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_fn_sql_version]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_chk]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_col]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_def]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_fk]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_func]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_idx]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_obj]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_proc]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_trig]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_get_def_name]    Script Date: 05/17/2016 16:51:44 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_fn_sql_version]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_chk]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_col]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_def]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_fk]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_func]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_idx]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_obj]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_proc]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_trig]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_get_def_name]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_fn_sql_version]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:45 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_chk]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_col]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_def]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_fk]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_func]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_idx]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_obj]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_proc]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_trig]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_get_def_name]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_fn_sql_version]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_chk]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_col]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_def]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_fk]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_func]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_idx]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_obj]    Script Date: 05/17/2016 16:51:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_proc]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_trig]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_get_def_name]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_109_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_fn_sql_version]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_chk]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_col]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_def]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_fk]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_func]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_idx]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_obj]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_proc]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_trig]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_get_def_name]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_fn_sql_version]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_chk]    Script Date: 05/17/2016 16:51:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_col]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_def]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_fk]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_func]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_idx]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_obj]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_proc]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_trig]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_get_def_name]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_fn_sql_version]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_chk]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_col]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_def]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_fk]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_func]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_idx]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_obj]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_proc]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_trig]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_get_def_name]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_112_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_chk]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_col]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_def]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_fk]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_func]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_idx]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_obj]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_proc]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_trig]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_get_def_name]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_fn_sql_version]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_chk]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_col]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_def]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_fk]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_func]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_idx]    Script Date: 05/17/2016 16:51:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_obj]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_proc]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_trig]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_get_def_name]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create function placeholder_fn_rpt_changeSignForReversal
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN @amount * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_fn_sql_version]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_chk]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_col]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_def]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_fk]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_func]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_idx]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_obj]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_proc]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_trig]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_get_def_name]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_fn_sql_version]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_chk]    Script Date: 05/17/2016 16:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_col]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_def]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_fk]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_func]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_idx]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_obj]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_proc]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_trig]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_get_def_name]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_chk]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_col]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_def]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_fk]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_func]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_idx]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_obj]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_proc]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_trig]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_get_def_name]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_fn_sql_version]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_chk]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_col]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_def]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_fk]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_func]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_idx]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_obj]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_proc]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_trig]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_get_def_name]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_fn_sql_version]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_chk]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_col]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_def]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_fk]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_func]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_idx]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_obj]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_proc]    Script Date: 05/17/2016 16:51:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_trig]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_get_def_name]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_fn_sql_version]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_chk]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_col]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_def]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_fk]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_func]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_idx]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_obj]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_proc]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_trig]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_get_def_name]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_fn_sql_version]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_chk]    Script Date: 05/17/2016 16:51:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_col]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_def]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_fk]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_func]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_idx]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_obj]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_proc]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_trig]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_get_def_name]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_fn_sql_version]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_chk]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_col]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_def]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_fk]    Script Date: 05/17/2016 16:51:54 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_func]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_idx]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_obj]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_proc]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_trig]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_get_def_name]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_132_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_fn_sql_version]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_chk]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_col]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_def]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_fk]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_func]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_idx]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_obj]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_proc]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_trig]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_get_def_name]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_133_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_fn_rpt_changeSignForReversal]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_fn_rpt_changeSignForReversal] (@msgType FLOAT, @amount POST_MONEY)
	RETURNS FLOAT
AS
BEGIN
	DECLARE @finalAmount POST_MONEY
	SELECT @finalAmount = CASE 
			WHEN @msgType in ('0400','0420') THEN ABS(@amount) * -1
			ELSE ABS(@amount)
		END	
	RETURN @finalAmount
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_fn_sql_version]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_chk]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_col]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_def]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_fk]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_func]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_idx]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_obj]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_proc]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_trig]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_get_def_name]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_134_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_70_fn_sql_version]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_70_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create function placeholder_ofn_part_view_tran_2
--------------------------------------------------------------------------------
ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_fn_sql_version]    Script Date: 05/17/2016 16:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_chk]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_col]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_def]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_fk]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_func]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_idx]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_obj]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_proc]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_trig]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_get_def_name]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_fn_sql_version]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_chk]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_col]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_def]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_fk]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_func]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_idx]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_obj]    Script Date: 05/17/2016 16:51:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_proc]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_trig]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_get_def_name]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_fn_sql_version]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_chk]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_col]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_def]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_fk]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_func]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_idx]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_obj]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_proc]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_trig]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_get_def_name]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_chk]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_col]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_def]    Script Date: 05/17/2016 16:51:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_fk]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_func]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_idx]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_obj]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_proc]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_trig]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_get_def_name]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_action]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_fn_sql_version]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_chk]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_col]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_def]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_fk]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_func]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_idx]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_obj]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_proc]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_tbl]    Script Date: 05/17/2016 16:51:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_trig]    Script Date: 05/17/2016 16:52:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_get_def_name]    Script Date: 05/17/2016 16:52:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_fn_sql_version]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_chk]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_col]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_def]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_fk]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_func]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_idx]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_obj]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_proc]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_trig]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_get_def_name]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_chk]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_col]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_def]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_fk]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_func]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_idx]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_obj]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_proc]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_trig]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_get_def_name]    Script Date: 05/17/2016 16:52:01 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_chk]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_col]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_def]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_fk]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_func]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_idx]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_obj]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_proc]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_trig]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_get_def_name]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_fn_sql_version]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_chk]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_col]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_def]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_fk]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_func]    Script Date: 05/17/2016 16:52:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_idx]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_obj]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_proc]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_trig]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_get_def_name]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_fn_sql_version]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_chk]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_col]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_def]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_fk]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_func]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_idx]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_obj]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_proc]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_trig]    Script Date: 05/17/2016 16:52:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_get_def_name]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_fn_sql_version]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_chk]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_col]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_def]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_fk]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_func]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_idx]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_obj]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_proc]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_trig]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_get_def_name]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_fn_sql_version]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_chk]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_col]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_def]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_fk]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_func]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_idx]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_obj]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_proc]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_trig]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_get_def_name]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_fn_sql_version]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_chk]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_col]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_def]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_fk]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_func]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_idx]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_obj]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_proc]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_trig]    Script Date: 05/17/2016 16:52:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_get_def_name]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_fn_sql_version]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_chk]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_col]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_def]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_fk]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_func]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_idx]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_obj]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_proc]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_trig]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_get_def_name]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_fn_sql_version]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_chk]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_col]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_def]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_fk]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_func]    Script Date: 05/17/2016 16:52:06 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_idx]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_obj]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_proc]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_trig]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_get_def_name]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_fn_sql_version]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_chk]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_col]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_def]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_fk]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_func]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_idx]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_obj]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_proc]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_trig]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_get_def_name]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_fn_sql_version]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:07 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_chk]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_col]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_def]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_fk]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_func]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_idx]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_obj]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_proc]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_trig]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_get_def_name]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_fn_sql_version]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_chk]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_col]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_def]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_fk]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_func]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_idx]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_obj]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_proc]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_trig]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_get_def_name]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_fn_sql_version]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_chk]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_col]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_def]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_fk]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_func]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_idx]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_obj]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_proc]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_trig]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_get_def_name]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_fn_sql_version]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_chk]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_col]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_def]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_fk]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_func]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_idx]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_obj]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_proc]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_trig]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_get_def_name]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_fn_sql_version]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_chk]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_col]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_def]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_fk]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_func]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_idx]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_obj]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_proc]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_trig]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_get_def_name]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_fn_sql_version]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_chk]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_col]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_def]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_fk]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_func]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_idx]    Script Date: 05/17/2016 16:52:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_obj]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_proc]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_trig]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_get_def_name]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_fn_sql_version]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_fn_sql_version] ()
RETURNS INT
AS
BEGIN
	IF (CHARINDEX ('SQL Server 2005', @@VERSION) > 0)
		RETURN 2005
	RETURN 2000
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_check_if_column_exists]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_check_if_column_exists]
(
	@table		VARCHAR (100),
	@column_name	VARCHAR (100))
	RETURNS INT
AS
BEGIN
	IF EXISTS
	(
		SELECT
			*
		FROM
			INFORMATION_SCHEMA.COLUMNS
		WHERE
			TABLE_NAME = @table AND
			COLUMN_NAME = @column_name
	)
	BEGIN
		RETURN 1
	END

	RETURN 0
END --ofn_backpop_check_if_column_exists

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_get_column_index_name]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_get_column_index_name]
(
	@table VARCHAR (100),
	@column_name VARCHAR (100))
	RETURNS VARCHAR (100)
AS
BEGIN
	DECLARE @index_name VARCHAR (100)
	SET @index_name = NULL

	SELECT
		@index_name = sysindexes.name
	FROM
		sysobjects
		INNER JOIN
			syscolumns
		ON
			sysobjects.id = syscolumns.id
		INNER JOIN
			sysindexkeys
		ON
			sysobjects.id = sysindexkeys.id AND
			sysindexkeys.colid = syscolumns.colid
		INNER JOIN
			sysindexes
		ON
			sysobjects.id = sysindexes.id AND
			sysindexes.indid = sysindexkeys.indid
	WHERE
		syscolumns.name=@column_name AND
		sysobjects.name=@table

	RETURN @index_name
END --ofn_backpop_get_column_index_name

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_chk]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_col]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_def]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_fk]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_func]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_idx]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_obj]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_proc]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_trig]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_get_def_name]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_part_view_tran_2]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_part_view_tran_2] (@online_system_id INT, @participant_id INT, @opp_participant_id INT)
	RETURNS INT
AS
BEGIN

	IF EXISTS
		(
			SELECT *
			FROM
				post_part_user_rights
			WHERE
				online_system_id = @online_system_id
				AND
				(
					participant_id = @participant_id
					OR
					participant_id = @opp_participant_id
				)
				AND
				IS_MEMBER (user_group) = 1
				AND
				(tran_rights & 1) = 1
		)
		RETURN 1

	RETURN 0
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_chk]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_chk]
(
	@tbl_name VARCHAR(8000),
	@chk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @chk_name AND [type] IN (N'C'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_col]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_col]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM syscolumns WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @col_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_def]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_def]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = dbo.ofn_get_def_name(@tbl_name, @col_name)
	
	IF @def_name IS NOT NULL
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_fk]    Script Date: 05/17/2016 16:52:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_fk]
(
	@tbl_name VARCHAR(8000),
	@fk_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE parent_obj = OBJECT_ID(@tbl_name) AND [name] = @fk_name AND [type] IN (N'F'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_func]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_func]
(
	@func_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@func_name) AND [type] IN (N'FN', N'IF', N'TF'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_idx]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_idx]
(
	@tbl_name VARCHAR(8000),
	@idx_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysindexes WHERE [id] = OBJECT_ID(@tbl_name) AND [name] = @idx_name)
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_obj]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_obj]
(
	@obj_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@obj_name))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_proc]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_proc]
(
	@proc_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@proc_name) AND [type] IN (N'P'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_tbl]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_tbl]
(
	@tbl_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@tbl_name) AND [type] IN (N'U'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_trig]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_trig]
(
	@trig_name VARCHAR(8000)
)
RETURNS INT
AS
BEGIN
	DECLARE @exists INT
	SET @exists = 0
	
	IF EXISTS (SELECT 1 FROM sysobjects WHERE [id] = OBJECT_ID(@trig_name) AND [type] IN (N'TR'))
	BEGIN
		SET @exists = 1
	END
	
	RETURN @exists
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_get_def_name]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_get_def_name]
(
	@tbl_name VARCHAR(8000),
	@col_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE @def_name VARCHAR(8000)
	SET @def_name = NULL
	
	SELECT @def_name = so_const.name 
	FROM sysobjects so_const 
	INNER JOIN sysobjects so_tab 
	ON so_tab.id = so_const.parent_obj
	INNER JOIN syscolumns so_col 
	ON so_col.cdefault = so_const.id
	WHERE so_const.xtype = 'D' 
	AND so_tab.name = @tbl_name
	AND so_col.name = @col_name
	
	RETURN @def_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_action]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN @object_type + ':' + @object_name
END

GO

/****** Object:  UserDefinedFunction [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_custom_action]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


ALTER FUNCTION [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_custom_action]
(
	@object_type VARCHAR(8000),
	@object_name VARCHAR(8000)
)
RETURNS VARCHAR(8000)
AS
BEGIN
	RETURN dbo.ofn_patch_get_action('CUSTOM:' + @object_type, @object_name)
END

GO

/****** Object:  UserDefinedFunction [dbo].[rpt_fxn_account_type]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS OFF
GO

SET QUOTED_IDENTIFIER OFF
GO






ALTER FUNCTION [dbo].[rpt_fxn_account_type] 
	(@account_type		char(3))  
RETURNS	varchar(128)
AS  
BEGIN 
	BEGIN
		SET @account_type = (SELECT  account_type_string
		FROM		rpt_account_types (NOLOCK)
		WHERE	account_type = @account_type)
	END
	IF 
		@account_type IS NULL
	BEGIN
		SET @account_type = 'UKN'
	END
	RETURN (@account_type)
END







GO

/****** Object:  UserDefinedFunction [dbo].[usf_decrypt_pan]    Script Date: 05/17/2016 16:52:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




ALTER FUNCTION [dbo].[usf_decrypt_pan]( @pan VARCHAR (19) , @pan_encrypted VARCHAR (50) )
RETURNS VARCHAR (19)
AS BEGIN
	DECLARE @pan_decrypted VARCHAR (20);
	DECLARE @process_descr VARCHAR (100);
	DECLARE @show_full_pan BIT;
	DECLARE @error INT;
	DECLARE @index INT;
	DECLARE @partial_unmask	INT;
	        
 	      				SET @process_descr = 'On-demand PAN Decryption Script';
	      				SET @show_full_pan=1;
	      				SET @pan_decrypted=null;  				
	      				SET @partial_unmask=0;
	       				 
	       				--EXEC osp_rpt_format_pan @pan, @pan_encrypted, @process_descr, @show_full_pan, @pan_decrypted OUTPUT, @error OUTPUT;
	                 SELECT @pan_decrypted = dbo.DecryptPan(@pan, @pan_encrypted, @process_descr);
	                  -- EXEC osp_decrypt_pan_com @pan, @pan_encrypted, @process_descr, @pan_decrypted OUTPUT, @error OUTPUT, @partial_unmask;
			RETURN	 @pan_decrypted 
               
         END    



GO



CREATE FUNCTION [dbo].[get_dates_in_range]
(
     @StartDate    VARCHAR(30)  
    ,@EndDate    VARCHAR(30)   
)
RETURNS
@DateList table
(
    Date datetime
)
AS
BEGIN


IF ISDATE(@StartDate)!=1 OR ISDATE(@EndDate)!=1
BEGIN
    RETURN
END

while (DATEDIFF(D,  @StartDate,@EndDate)>=0) BEGIN 

INSERT INTO @DateList
        (Date)
    SELECT
        @StartDate
SET  @StartDate = DATEADD(D, 1 ,@StartDate);
        END


RETURN
END


GO


