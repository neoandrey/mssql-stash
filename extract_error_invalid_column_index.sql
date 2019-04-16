USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_get_business_arrangements]    Script Date: 11/25/2016 16:22:52 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_get_business_arrangements]
	@acct_range_low		CHAR(19),		--must be right padded with zeros
	@acquirer_bin		CHAR(6),
	@card_program_id	CHAR(3),	
	@issuer_region		CHAR(1),
	@acquirer_region	CHAR(1),
	@product_type		CHAR(1),
	@product_class		CHAR(1),
	@mti			CHAR(4),		--message type identifier
	@function_code		CHAR(3),
	@message_reason_code	CHAR(4),
	@transaction_type	CHAR(2),
	@from_account_type	CHAR(2),
	@to_account_type	CHAR(2),		
	@reversal_ind		CHAR(1),
	@lifecyle_ind		CHAR(1),
	@mastercard_assigned_id	CHAR(6),
	@central_acquiring	CHAR(1)
AS
BEGIN
			
	DECLARE @row_count INT
	SET @row_count = 0
			
	IF(@central_acquiring = 'Y')
	BEGIN

		--For the central acquiring process, GCMS retrives the card program identifier and business
		--service arragement participation information for the issuer only (hence only the IP0090T1 table)

		--IP0090T1 ONLY
		EXEC mcipm_get_central_acquiring_business_arrangements 
		@acquirer_bin,
		@card_program_id,
		@product_type,
		@product_class,			
		@mti, 
		@acct_range_low, 				 
		@transaction_type, 
		@from_account_type,
		@to_account_type,
		@function_code,
		@reversal_ind,
		@lifecyle_ind,	
		@mastercard_assigned_id,
		@row_count OUTPUT

	END
	
	IF  (@central_acquiring <> 'Y' OR @row_count = 0)
	BEGIN

		--Check for arrangements between the issuing and acquiring members (IP0090T1 and IP0091T1)
		--If this yields no results, we must use the default arrangments for the region (IP0036T1)
		
		--IP0090T1 and IP0091T1
		EXEC mcipm_get_member_business_arrangements 
			@acquirer_bin,
			@card_program_id,
			@product_type,
			@product_class,			
			@mti, 
			@acct_range_low, 				 
			@transaction_type, 
			@from_account_type,
			@to_account_type,
			@function_code,
			@reversal_ind,
			@lifecyle_ind,	
			@mastercard_assigned_id	
			
		IF  (@@rowcount = 0)
		BEGIN
		
			--IP0036T1
			EXEC mcipm_get_default_business_arrangements 
				@card_program_id,	
				@issuer_region,
				@acquirer_region,
				@product_type,
				@product_class,			
				@mti, 		 
				@transaction_type, 
				@from_account_type,
				@to_account_type,
				@function_code,
				@reversal_ind,
				@lifecyle_ind,
				@mastercard_assigned_id	
		
		END

	END

END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_get_central_acquiring_business_arrangements]    Script Date: 11/25/2016 16:22:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[mcipm_get_central_acquiring_business_arrangements]
	@acquirer_bin				CHAR(6),
	@card_program_id			CHAR(3),
	@product_type				CHAR(1),
	@product_class				CHAR(1),		
	@mti							CHAR(4),		--message type identifier
	@acct_range_low			CHAR(19),	--must be right padded with zeros	
	@transaction_type			CHAR(2),
	@from_account_type		CHAR(2),
	@to_account_type			CHAR(2),
	@function_code				CHAR(3),
	@reversal_ind				CHAR(1),
	@lifecycle_ind				CHAR(1),
	@mastercard_assigned_id	CHAR(6),
	@row_count					INT OUTPUT
AS
BEGIN

	DECLARE	@l_masked_from_acct_type	CHAR(2)
	
	SELECT	@l_masked_from_acct_type 	= mcipm_ip2054t1.masked_from_acct_type 
	FROM	mcipm_ip2054t1
	WHERE	from_acct_type			= @from_account_type	


	--If this is a lifecycle transaction, set the 
	--@l_first_presentment_enforced in such a way 
	--that enforced relationships for first presentments
	--will NOT be returned; if this is NOT a lifecycle
	--transaction, set the @l_first_presentment_enforced in 
	--such a way that enforced relationships for first 
	--presentments will be returned
	DECLARE	@l_first_presentment_enforced 	CHAR(1)
	
	IF	(@lifecycle_ind = 'L')
	BEGIN
		SELECT @l_first_presentment_enforced = 'A'
	END
	ELSE
	BEGIN
		SELECT @l_first_presentment_enforced = 'F'
	END
	
	IF 	(@mastercard_assigned_id = '      ') 
	
	BEGIN

		SELECT
			mcipm_ip0090t1.buss_service_arrange_type,
			mcipm_ip0090t1.buss_service_id_code,
			mcipm_ip0090t1.buss_service_arrange_type_priority,
			mcipm_ip0142t1.ird,
			mcipm_ip0090t1.buss_service_enforcement_ind,
			mcipm_ip0052t1.fee_code_pointer,
			mcipm_ip0052t1.timeliness_auth_code_pointer,
			mcipm_ip0052t1.product_card_accept_pointer,
			mcipm_ip0052t1.paypass_indicator
		FROM	mcipm_ip0090t1, mcipm_ip0142t1, mcipm_ip0052t1, mcipm_ip0041t1
		WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
		AND	mcipm_ip0090t1.card_program_id			= @card_program_id	
		AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
		AND	mcipm_ip0041t1.card_program_id			= @card_program_id
		AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0090t1.buss_service_enforcement_ind	IN ('A',@l_first_presentment_enforced)							
		AND	mcipm_ip0142t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0142t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0142t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND  	mcipm_ip0142t1.mti			    	= @mti
		AND  	mcipm_ip0142t1.function_code		    	= @function_code
		AND  	mcipm_ip0142t1.transaction_type		 	= @transaction_type
		AND	mcipm_ip0052t1.card_program_id			= @card_program_id			
		AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND	mcipm_ip0052t1.ird				= mcipm_ip0142t1.ird
		AND  	mcipm_ip0052t1.mti			    	= @mti
		AND  	mcipm_ip0052t1.function_code		    	= @function_code
		AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
		AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
		AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
		AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
		AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
		AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
			 mcipm_ip0052t1.product_type_id			= '3')	

	END
	ELSE
	BEGIN
		SELECT
			mcipm_ip0090t1.buss_service_arrange_type,
			mcipm_ip0090t1.buss_service_id_code,
			mcipm_ip0090t1.buss_service_arrange_type_priority,
			mcipm_ip0142t1.ird,
			mcipm_ip0090t1.buss_service_enforcement_ind,
			mcipm_ip0052t1.fee_code_pointer,
			mcipm_ip0052t1.timeliness_auth_code_pointer,
			mcipm_ip0052t1.product_card_accept_pointer,
			mcipm_ip0052t1.paypass_indicator
		FROM	mcipm_ip0090t1, mcipm_ip0142t1, mcipm_ip0052t1, mcipm_ip0041t1
		WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
		AND	mcipm_ip0090t1.card_program_id			= @card_program_id
		AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
		AND	mcipm_ip0041t1.card_program_id			= @card_program_id
		AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0090t1.buss_service_enforcement_ind	IN ('A',@l_first_presentment_enforced)			
		AND	mcipm_ip0142t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0142t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0142t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND  	mcipm_ip0142t1.mti			    	= @mti
		AND  	mcipm_ip0142t1.function_code		    	= @function_code
		AND  	mcipm_ip0142t1.transaction_type		 	= @transaction_type
		AND	mcipm_ip0052t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND	mcipm_ip0052t1.ird				= mcipm_ip0142t1.ird
		AND  	mcipm_ip0052t1.mti			    	= @mti
		AND  	mcipm_ip0052t1.function_code		    	= @function_code
		AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
		AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
		AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
		AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
		AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
			 mcipm_ip0052t1.product_type_id			= '3')		
	END

	DECLARE @temp_row_count INT
	SELECT @temp_row_count = @@rowcount

	IF (@temp_row_count = 0)

	BEGIN	
		
		IF 	(@mastercard_assigned_id = '      ') 
		
		BEGIN
		
			SELECT
				mcipm_ip0090t1.buss_service_arrange_type,
				mcipm_ip0090t1.buss_service_id_code,
				mcipm_ip0090t1.buss_service_arrange_type_priority,
				mcipm_ip0052t1.ird,
				mcipm_ip0090t1.buss_service_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0090t1, mcipm_ip0052t1, mcipm_ip0041t1
			WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id
			AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
			AND	mcipm_ip0041t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)				
			AND	@card_program_id				= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
			AND  	mcipm_ip0052t1.mti			    	= @mti
			AND  	mcipm_ip0052t1.function_code		    	= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
			AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
			AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
			AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 mcipm_ip0052t1.product_type_id			= '3')
				 
		END
		
		ELSE
		
		BEGIN
		
			SELECT
				mcipm_ip0090t1.buss_service_arrange_type,
				mcipm_ip0090t1.buss_service_id_code,
				mcipm_ip0090t1.buss_service_arrange_type_priority,
				mcipm_ip0052t1.ird,
				mcipm_ip0090t1.buss_service_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0090t1, mcipm_ip0052t1, mcipm_ip0041t1
			WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id
			AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
			AND	mcipm_ip0041t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)				
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
			AND	mcipm_ip0052t1.card_program_id			= @card_program_id				
			AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
			AND  	mcipm_ip0052t1.mti			    	= @mti
			AND  	mcipm_ip0052t1.function_code		    	= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
			AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
			AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 mcipm_ip0052t1.product_type_id			= '3')
				 
		END		

		SELECT @row_count = @@rowcount

	END
	ELSE
	BEGIN
		SELECT @row_count = @temp_row_count
	END

END

-- Patch 022
--------------------------------------------------------------------------------
PRINT ''
PRINT 'Creating stored procedure: placeholder_mcipm_get_issuer'
PRINT ''
--------------------------------------------------------------------------------	


GO

/****** Object:  StoredProcedure [dbo].[mcipm_get_default_business_arrangements]    Script Date: 11/25/2016 16:22:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[mcipm_get_default_business_arrangements]
	@card_program_id			CHAR(3),
	@issuer_region				CHAR(1),
	@acquirer_region			CHAR(1),
	@product_type				CHAR(1),
	@product_class				CHAR(1),		
	@mti					CHAR(4),		--message type identifier
	@transaction_type			CHAR(2),
	@from_account_type			CHAR(2),
	@to_account_type			CHAR(2),
	@function_code				CHAR(3),
	@reversal_ind				CHAR(1),
	@lifecycle_ind				CHAR(1),
	@mastercard_assigned_id			CHAR(6)
AS
BEGIN

	DECLARE	@l_first_presentment_enforced 	CHAR(1)
		
	--If this is a lifecycle transaction, set the 
	--@l_first_presentment_enforced in such a way 
	--that enforced relationships for first presentments
	--will NOT be returned; if this is NOT a lifecycle
	--transaction, set the @l_first_presentment_enforced in 
	--such a way that enforced relationships for first 
	--presentments will be returned
	IF	(@lifecycle_ind = 'L')
	BEGIN
		SELECT @l_first_presentment_enforced = 'A'
	END
	ELSE
	BEGIN
		SELECT @l_first_presentment_enforced = 'F'
	END

    DECLARE @l_masked_from_acct_type CHAR(2)

    SELECT @l_masked_from_acct_type = mcipm_ip2054t1.masked_from_acct_type
    FROM mcipm_ip2054t1
    WHERE from_acct_type = @from_account_type

	IF (@issuer_region = @acquirer_region)
		
	BEGIN
	
		IF 	(@mastercard_assigned_id = '      ') 
		BEGIN
	
			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator				
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed				  IN ('B', @reversal_ind)
			AND 	mcipm_ip0052t1.mc_id_mandatory_indicator		= 'N'
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
			 	 mcipm_ip0052t1.product_type_id				= '3')			
 		
 		END
 		ELSE
 		BEGIN

			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator				
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed				  IN ('B', @reversal_ind)
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
				 mcipm_ip0052t1.product_type_id				= '3')					
							

 		END
 		
 		IF (@@rowcount = 0)
			
		BEGIN
		
			IF 	(@mastercard_assigned_id = '      ') 

			BEGIN
					
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator					
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind IN ('A',@lifecycle_ind)
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')
				
			END
			
			ELSE
			
				BEGIN
				
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator					
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind IN ('A',@lifecycle_ind)
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')					
							
			END

		END
	
	END
	
	ELSE
	
	BEGIN
	
		IF 	(@mastercard_assigned_id = '      ') 		
		BEGIN
	
			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.from_region
			AND	@issuer_region 						= mcipm_ip0036t1.to_region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			 	 IN ('B', @reversal_ind)
			AND 	mcipm_ip0052t1.mc_id_mandatory_indicator		= 'N'
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
			 	 mcipm_ip0052t1.product_type_id				= '3')				

 		END
 		ELSE
 		BEGIN
 		
			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.from_region
			AND	@issuer_region 						= mcipm_ip0036t1.to_region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			 	 IN ('B', @reversal_ind)
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
				 mcipm_ip0052t1.product_type_id				= '3')	
								
 		 		
 		END
 		
 		
 		IF (@@rowcount = 0)
			
		BEGIN
			IF 	(@mastercard_assigned_id = '      ') 
		
			BEGIN
						
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.from_region
				AND	@issuer_region 					= mcipm_ip0036t1.to_region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind NOT LIKE 'L'
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')	
				
			END
			
			ELSE
			
			BEGIN
						
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.from_region
				AND	@issuer_region 					= mcipm_ip0036t1.to_region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind NOT LIKE 'L'
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')	
					
			END			

		END	
	
	END

END


GO

/****** Object:  StoredProcedure [dbo].[mcipm_get_member_business_arrangements]    Script Date: 11/25/2016 16:22:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO




CREATE PROCEDURE [dbo].[mcipm_get_member_business_arrangements]
	@acquirer_bin				CHAR(6),
	@card_program_id			CHAR(3),
	@product_type				CHAR(1),
	@product_class				CHAR(1),		
	@mti					CHAR(4),		--message type identifier
	@acct_range_low				CHAR(19),		--must be right padded with zeros	
	@transaction_type			CHAR(2),
	@from_account_type			CHAR(2),
	@to_account_type			CHAR(2),
	@function_code				CHAR(3),
	@reversal_ind				CHAR(1),
	@lifecycle_ind				CHAR(1),
	@mastercard_assigned_id			CHAR(6)
AS
BEGIN

	DECLARE	@l_masked_from_acct_type	CHAR(2)
	
	SELECT	@l_masked_from_acct_type 	= mcipm_ip2054t1.masked_from_acct_type 
	FROM	mcipm_ip2054t1
	WHERE	from_acct_type			= @from_account_type	


	--If this is a lifecycle transaction, set the 
	--@l_first_presentment_enforced in such a way 
	--that enforced relationships for first presentments
	--will NOT be returned; if this is NOT a lifecycle
	--transaction, set the @l_first_presentment_enforced in 
	--such a way that enforced relationships for first 
	--presentments will be returned
	DECLARE	@l_first_presentment_enforced 	CHAR(1)
	
	IF	(@lifecycle_ind = 'L')
	BEGIN
		SELECT @l_first_presentment_enforced = 'A'
	END
	ELSE
	BEGIN
		SELECT @l_first_presentment_enforced = 'F'
	END
	
	IF 	(@mastercard_assigned_id = '      ') 
	
	BEGIN

		SELECT
			mcipm_ip0090t1.buss_service_arrange_type,
			mcipm_ip0090t1.buss_service_id_code,
			mcipm_ip0091t1.buss_service_arrange_type_priority,
			mcipm_ip0142t1.ird,
			mcipm_ip0090t1.buss_service_enforcement_ind,
			mcipm_ip0052t1.fee_code_pointer,
			mcipm_ip0052t1.timeliness_auth_code_pointer,
			mcipm_ip0052t1.product_card_accept_pointer,
			mcipm_ip0052t1.paypass_indicator
		FROM	mcipm_ip0090t1, mcipm_ip0091t1, mcipm_ip0142t1, mcipm_ip0052t1
		WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
		AND	mcipm_ip0090t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0090t1.buss_service_enforcement_ind	IN ('A',@l_first_presentment_enforced)
		AND	mcipm_ip0091t1.acquiring_bin			= @acquirer_bin					
		AND	mcipm_ip0091t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0090t1.buss_service_arrange_type	= mcipm_ip0091t1.buss_service_arrange_type
		AND	mcipm_ip0090t1.buss_service_id_code		= mcipm_ip0091t1.buss_service_id_code
		AND	mcipm_ip0091t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0142t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0142t1.buss_service_arrange_type      	= mcipm_ip0091t1.buss_service_arrange_type	
		AND	mcipm_ip0142t1.buss_service_id_code	      	= mcipm_ip0091t1.buss_service_id_code
		AND  	mcipm_ip0142t1.mti			    	= @mti
		AND  	mcipm_ip0142t1.function_code		    	= @function_code
		AND  	mcipm_ip0142t1.transaction_type		 	= @transaction_type
		AND	mcipm_ip0052t1.card_program_id			= @card_program_id			
		AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0091t1.buss_service_arrange_type	
		AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0091t1.buss_service_id_code
		AND	mcipm_ip0052t1.ird				= mcipm_ip0142t1.ird
		AND  	mcipm_ip0052t1.mti			    	= @mti
		AND  	mcipm_ip0052t1.function_code		    	= @function_code
		AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
		AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
		AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
		AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
		AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
		AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
			 mcipm_ip0052t1.product_type_id			= '3')	

	END
	ELSE
	BEGIN
		SELECT
			mcipm_ip0090t1.buss_service_arrange_type,
			mcipm_ip0090t1.buss_service_id_code,
			mcipm_ip0091t1.buss_service_arrange_type_priority,
			mcipm_ip0142t1.ird,
			mcipm_ip0090t1.buss_service_enforcement_ind,
			mcipm_ip0052t1.fee_code_pointer,
			mcipm_ip0052t1.timeliness_auth_code_pointer,
			mcipm_ip0052t1.product_card_accept_pointer,
			mcipm_ip0052t1.paypass_indicator
		FROM	mcipm_ip0090t1, mcipm_ip0091t1, mcipm_ip0142t1, mcipm_ip0052t1
		WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
		AND	mcipm_ip0090t1.card_program_id			= @card_program_id	
		AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0090t1.buss_service_enforcement_ind	IN ('A',@l_first_presentment_enforced)
		AND	mcipm_ip0091t1.acquiring_bin			= @acquirer_bin					
		AND	mcipm_ip0091t1.card_program_id			= @card_program_id
		AND	mcipm_ip0090t1.buss_service_arrange_type	= mcipm_ip0091t1.buss_service_arrange_type
		AND	mcipm_ip0090t1.buss_service_id_code		= mcipm_ip0091t1.buss_service_id_code
		AND	mcipm_ip0091t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0142t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0142t1.buss_service_arrange_type      	= mcipm_ip0091t1.buss_service_arrange_type	
		AND	mcipm_ip0142t1.buss_service_id_code	      	= mcipm_ip0091t1.buss_service_id_code
		AND  	mcipm_ip0142t1.mti			    	= @mti
		AND  	mcipm_ip0142t1.function_code		    	= @function_code
		AND  	mcipm_ip0142t1.transaction_type		 	= @transaction_type
		AND	mcipm_ip0052t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0091t1.buss_service_arrange_type	
		AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0091t1.buss_service_id_code
		AND	mcipm_ip0052t1.ird				= mcipm_ip0142t1.ird
		AND  	mcipm_ip0052t1.mti			    	= @mti
		AND  	mcipm_ip0052t1.function_code		    	= @function_code
		AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
		AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
		AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
		AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
		AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
			 mcipm_ip0052t1.product_type_id			= '3')		
	END


	IF (@@rowcount = 0)

	BEGIN	
		
		IF 	(@mastercard_assigned_id = '      ') 
		
		BEGIN
		
			SELECT
				mcipm_ip0090t1.buss_service_arrange_type,
				mcipm_ip0090t1.buss_service_id_code,
				mcipm_ip0091t1.buss_service_arrange_type_priority,
				mcipm_ip0052t1.ird,
				mcipm_ip0090t1.buss_service_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0090t1, mcipm_ip0091t1, mcipm_ip0052t1
			WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id	
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
			AND	mcipm_ip0091t1.acquiring_bin			= @acquirer_bin					
			AND	mcipm_ip0091t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrange_type	= mcipm_ip0091t1.buss_service_arrange_type
			AND	mcipm_ip0090t1.buss_service_id_code		= mcipm_ip0091t1.buss_service_id_code
			AND	mcipm_ip0091t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
			AND	@card_program_id				= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0091t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0091t1.buss_service_id_code
			AND  	mcipm_ip0052t1.mti			    	= @mti
			AND  	mcipm_ip0052t1.function_code		    	= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
			AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
			AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
			AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 mcipm_ip0052t1.product_type_id			= '3')
				 
		END
		
		ELSE
		
		BEGIN
		
			SELECT
				mcipm_ip0090t1.buss_service_arrange_type,
				mcipm_ip0090t1.buss_service_id_code,
				mcipm_ip0091t1.buss_service_arrange_type_priority,
				mcipm_ip0052t1.ird,
				mcipm_ip0090t1.buss_service_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0090t1, mcipm_ip0091t1, mcipm_ip0052t1
			WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
			AND	mcipm_ip0091t1.acquiring_bin			= @acquirer_bin					
			AND	mcipm_ip0091t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrange_type	= mcipm_ip0091t1.buss_service_arrange_type
			AND	mcipm_ip0090t1.buss_service_id_code		= mcipm_ip0091t1.buss_service_id_code
			AND	mcipm_ip0091t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
			AND	mcipm_ip0052t1.card_program_id			= @card_program_id				
			AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0091t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0091t1.buss_service_id_code
			AND  	mcipm_ip0052t1.mti			    	= @mti
			AND  	mcipm_ip0052t1.function_code		    	= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
			AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
			AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 mcipm_ip0052t1.product_type_id			= '3')
				 
		END		

	END
		
END


GO


USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[placeholder_mcipm_get_central_acquiring_business_arrangements]    Script Date: 11/25/2016 16:23:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[placeholder_mcipm_get_central_acquiring_business_arrangements]
	@acquirer_bin				CHAR(6),
	@card_program_id			CHAR(3),
	@product_type				CHAR(1),
	@product_class				CHAR(1),		
	@mti							CHAR(4),		--message type identifier
	@acct_range_low			CHAR(19),	--must be right padded with zeros	
	@transaction_type			CHAR(2),
	@from_account_type		CHAR(2),
	@to_account_type			CHAR(2),
	@function_code				CHAR(3),
	@reversal_ind				CHAR(1),
	@lifecycle_ind				CHAR(1),
	@mastercard_assigned_id	CHAR(6),
	@row_count					INT OUTPUT
AS
BEGIN

	DECLARE	@l_masked_from_acct_type	CHAR(2)
	
	SELECT	@l_masked_from_acct_type 	= mcipm_ip2054t1.masked_from_acct_type 
	FROM	mcipm_ip2054t1
	WHERE	from_acct_type			= @from_account_type	


	--If this is a lifecycle transaction, set the 
	--@l_first_presentment_enforced in such a way 
	--that enforced relationships for first presentments
	--will NOT be returned; if this is NOT a lifecycle
	--transaction, set the @l_first_presentment_enforced in 
	--such a way that enforced relationships for first 
	--presentments will be returned
	DECLARE	@l_first_presentment_enforced 	CHAR(1)
	
	IF	(@lifecycle_ind = 'L')
	BEGIN
		SELECT @l_first_presentment_enforced = 'A'
	END
	ELSE
	BEGIN
		SELECT @l_first_presentment_enforced = 'F'
	END
	
	IF 	(@mastercard_assigned_id = '      ') 
	
	BEGIN

		SELECT
			mcipm_ip0090t1.buss_service_arrange_type,
			mcipm_ip0090t1.buss_service_id_code,
			mcipm_ip0090t1.buss_service_arrange_type_priority,
			mcipm_ip0142t1.ird,
			mcipm_ip0090t1.buss_service_enforcement_ind,
			mcipm_ip0052t1.fee_code_pointer,
			mcipm_ip0052t1.timeliness_auth_code_pointer,
			mcipm_ip0052t1.product_card_accept_pointer,
			mcipm_ip0052t1.paypass_indicator
		FROM	mcipm_ip0090t1, mcipm_ip0142t1, mcipm_ip0052t1, mcipm_ip0041t1
		WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
		AND	mcipm_ip0090t1.card_program_id			= @card_program_id	
		AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
		AND	mcipm_ip0041t1.card_program_id			= @card_program_id
		AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0090t1.buss_service_enforcement_ind	IN ('A',@l_first_presentment_enforced)							
		AND	mcipm_ip0142t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0142t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0142t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND  	mcipm_ip0142t1.mti			    	= @mti
		AND  	mcipm_ip0142t1.function_code		    	= @function_code
		AND  	mcipm_ip0142t1.transaction_type		 	= @transaction_type
		AND	mcipm_ip0052t1.card_program_id			= @card_program_id			
		AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND	mcipm_ip0052t1.ird				= mcipm_ip0142t1.ird
		AND  	mcipm_ip0052t1.mti			    	= @mti
		AND  	mcipm_ip0052t1.function_code		    	= @function_code
		AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
		AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
		AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
		AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
		AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
		AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
			 mcipm_ip0052t1.product_type_id			= '3')	

	END
	ELSE
	BEGIN
		SELECT
			mcipm_ip0090t1.buss_service_arrange_type,
			mcipm_ip0090t1.buss_service_id_code,
			mcipm_ip0090t1.buss_service_arrange_type_priority,
			mcipm_ip0142t1.ird,
			mcipm_ip0090t1.buss_service_enforcement_ind,
			mcipm_ip0052t1.fee_code_pointer,
			mcipm_ip0052t1.timeliness_auth_code_pointer,
			mcipm_ip0052t1.product_card_accept_pointer,
			mcipm_ip0052t1.paypass_indicator
		FROM	mcipm_ip0090t1, mcipm_ip0142t1, mcipm_ip0052t1, mcipm_ip0041t1
		WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
		AND	mcipm_ip0090t1.card_program_id			= @card_program_id
		AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
		AND	mcipm_ip0041t1.card_program_id			= @card_program_id
		AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
		AND	mcipm_ip0090t1.buss_service_enforcement_ind	IN ('A',@l_first_presentment_enforced)			
		AND	mcipm_ip0142t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0142t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0142t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND  	mcipm_ip0142t1.mti			    	= @mti
		AND  	mcipm_ip0142t1.function_code		    	= @function_code
		AND  	mcipm_ip0142t1.transaction_type		 	= @transaction_type
		AND	mcipm_ip0052t1.card_program_id			= @card_program_id				
		AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
		AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
		AND	mcipm_ip0052t1.ird				= mcipm_ip0142t1.ird
		AND  	mcipm_ip0052t1.mti			    	= @mti
		AND  	mcipm_ip0052t1.function_code		    	= @function_code
		AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
		AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
		AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
		AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
		AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
			 mcipm_ip0052t1.product_type_id			= '3')		
	END

	DECLARE @temp_row_count INT
	SELECT @temp_row_count = @@rowcount

	IF (@temp_row_count = 0)

	BEGIN	
		
		IF 	(@mastercard_assigned_id = '      ') 
		
		BEGIN
		
			SELECT
				mcipm_ip0090t1.buss_service_arrange_type,
				mcipm_ip0090t1.buss_service_id_code,
				mcipm_ip0090t1.buss_service_arrange_type_priority,
				mcipm_ip0052t1.ird,
				mcipm_ip0090t1.buss_service_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0090t1, mcipm_ip0052t1, mcipm_ip0041t1
			WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id
			AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
			AND	mcipm_ip0041t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)				
			AND	@card_program_id				= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
			AND  	mcipm_ip0052t1.mti			    	= @mti
			AND  	mcipm_ip0052t1.function_code		    	= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
			AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
			AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
			AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 mcipm_ip0052t1.product_type_id			= '3')
				 
		END
		
		ELSE
		
		BEGIN
		
			SELECT
				mcipm_ip0090t1.buss_service_arrange_type,
				mcipm_ip0090t1.buss_service_id_code,
				mcipm_ip0090t1.buss_service_arrange_type_priority,
				mcipm_ip0052t1.ird,
				mcipm_ip0090t1.buss_service_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0090t1, mcipm_ip0052t1, mcipm_ip0041t1
			WHERE   mcipm_ip0090t1.issuer_acct_range_low		= @acct_range_low
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id
			AND	mcipm_ip0041t1.acquiring_bin_id			= @acquirer_bin
			AND	mcipm_ip0041t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)				
			AND	mcipm_ip0090t1.card_program_id			= @card_program_id
			AND	mcipm_ip0090t1.buss_service_arrangement_lifecycle IN ('A',@lifecycle_ind)
			AND	mcipm_ip0052t1.card_program_id			= @card_program_id				
			AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0090t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0090t1.buss_service_id_code
			AND  	mcipm_ip0052t1.mti			    	= @mti
			AND  	mcipm_ip0052t1.function_code		    	= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
			AND  	mcipm_ip0052t1.from_account_type		= @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
			AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 mcipm_ip0052t1.product_type_id			= '3')
				 
		END		

		SELECT @row_count = @@rowcount

	END
	ELSE
	BEGIN
		SELECT @row_count = @temp_row_count
	END

END

-- Patch 022
--------------------------------------------------------------------------------
PRINT ''
PRINT 'Creating stored procedure: placeholder_mcipm_get_issuer'
PRINT ''
--------------------------------------------------------------------------------	

GO

/****** Object:  StoredProcedure [dbo].[placeholder_mcipm_get_default_business_arrangements]    Script Date: 11/25/2016 16:23:32 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[placeholder_mcipm_get_default_business_arrangements]
	@card_program_id			CHAR(3),
	@issuer_region				CHAR(1),
	@acquirer_region			CHAR(1),
	@product_type				CHAR(1),
	@product_class				CHAR(1),		
	@mti					CHAR(4),		--message type identifier
	@transaction_type			CHAR(2),
	@from_account_type			CHAR(2),
	@to_account_type			CHAR(2),
	@function_code				CHAR(3),
	@reversal_ind				CHAR(1),
	@lifecycle_ind				CHAR(1),
	@mastercard_assigned_id			CHAR(6)
AS
BEGIN

	DECLARE	@l_first_presentment_enforced 	CHAR(1)
		
	--If this is a lifecycle transaction, set the 
	--@l_first_presentment_enforced in such a way 
	--that enforced relationships for first presentments
	--will NOT be returned; if this is NOT a lifecycle
	--transaction, set the @l_first_presentment_enforced in 
	--such a way that enforced relationships for first 
	--presentments will be returned
	IF	(@lifecycle_ind = 'L')
	BEGIN
		SELECT @l_first_presentment_enforced = 'A'
	END
	ELSE
	BEGIN
		SELECT @l_first_presentment_enforced = 'F'
	END

    DECLARE @l_masked_from_acct_type CHAR(2)

    SELECT @l_masked_from_acct_type = mcipm_ip2054t1.masked_from_acct_type
    FROM mcipm_ip2054t1
    WHERE from_acct_type = @from_account_type

	IF (@issuer_region = @acquirer_region)
		
	BEGIN
	
		IF 	(@mastercard_assigned_id = '      ') 
		BEGIN
	
			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator				
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed				  IN ('B', @reversal_ind)
			AND 	mcipm_ip0052t1.mc_id_mandatory_indicator		= 'N'
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
			 	 mcipm_ip0052t1.product_type_id				= '3')			
 		
 		END
 		ELSE
 		BEGIN

			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator				
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed				  IN ('B', @reversal_ind)
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
				 mcipm_ip0052t1.product_type_id				= '3')					
							

 		END
 		
 		IF (@@rowcount = 0)
			
		BEGIN
		
			IF 	(@mastercard_assigned_id = '      ') 

			BEGIN
					
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator					
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind IN ('A',@lifecycle_ind)
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')
				
			END
			
			ELSE
			
				BEGIN
				
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator					
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind IN ('A',@lifecycle_ind)
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')					
							
			END

		END
	
	END
	
	ELSE
	
	BEGIN
	
		IF 	(@mastercard_assigned_id = '      ') 		
		BEGIN
	
			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.from_region
			AND	@issuer_region 						= mcipm_ip0036t1.to_region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			 	 IN ('B', @reversal_ind)
			AND 	mcipm_ip0052t1.mc_id_mandatory_indicator		= 'N'
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
			 	 mcipm_ip0052t1.product_type_id				= '3')				

 		END
 		ELSE
 		BEGIN
 		
			SELECT
				mcipm_ip0036t1.buss_service_arrange_type,
				mcipm_ip0036t1.buss_service_id_code,
				mcipm_ip0036t1.buss_service_arrange_type_priority,
				mcipm_ip0142t1.ird,
				mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
				mcipm_ip0052t1.fee_code_pointer,
				mcipm_ip0052t1.timeliness_auth_code_pointer,
				mcipm_ip0052t1.product_card_accept_pointer,
				mcipm_ip0052t1.paypass_indicator
			FROM	mcipm_ip0036t1, mcipm_ip0142t1, mcipm_ip0052t1
			WHERE   @acquirer_region 					= mcipm_ip0036t1.from_region
			AND	@issuer_region 						= mcipm_ip0036t1.to_region
			AND	@card_program_id					= mcipm_ip0036t1.card_program_id
			AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind	IN ('A',@lifecycle_ind)
			AND	mcipm_ip0036t1.buss_service_arrange_enforcement_ind	IN ('A',@l_first_presentment_enforced)
			AND	@card_program_id					= mcipm_ip0142t1.card_program_id
			AND	mcipm_ip0142t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0142t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND  	mcipm_ip0142t1.mti			    		= @mti
			AND  	mcipm_ip0142t1.function_code		    		= @function_code
			AND  	mcipm_ip0142t1.transaction_type		 		= @transaction_type
			AND	@card_program_id					= mcipm_ip0052t1.card_program_id
			AND	mcipm_ip0052t1.buss_service_arrange_type      		= mcipm_ip0036t1.buss_service_arrange_type	
			AND	mcipm_ip0052t1.buss_service_id_code	      		= mcipm_ip0036t1.buss_service_id_code
			AND	mcipm_ip0052t1.ird					= mcipm_ip0142t1.ird
			AND  	mcipm_ip0052t1.mti			    		= @mti
			AND  	mcipm_ip0052t1.function_code		    		= @function_code
			AND  	mcipm_ip0052t1.transaction_type		 		= @transaction_type
			AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
			AND  	mcipm_ip0052t1.to_account_type		 		= @to_account_type
			AND	mcipm_ip0052t1.reversal_allowed			 	 IN ('B', @reversal_ind)
			AND     (mcipm_ip0052t1.product_type_id				= @product_type OR
				 mcipm_ip0052t1.product_type_id				= '3')	
								
 		 		
 		END
 		
 		
 		IF (@@rowcount = 0)
			
		BEGIN
			IF 	(@mastercard_assigned_id = '      ') 
		
			BEGIN
						
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.from_region
				AND	@issuer_region 					= mcipm_ip0036t1.to_region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind NOT LIKE 'L'
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND 	mcipm_ip0052t1.mc_id_mandatory_indicator	= 'N'
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')	
				
			END
			
			ELSE
			
			BEGIN
						
				SELECT
					mcipm_ip0036t1.buss_service_arrange_type,
					mcipm_ip0036t1.buss_service_id_code,
					mcipm_ip0036t1.buss_service_arrange_type_priority,
					mcipm_ip0052t1.ird,
					mcipm_ip0036t1.buss_service_arrange_enforcement_ind,
					mcipm_ip0052t1.fee_code_pointer,
					mcipm_ip0052t1.timeliness_auth_code_pointer,
					mcipm_ip0052t1.product_card_accept_pointer,
					mcipm_ip0052t1.paypass_indicator
				FROM	mcipm_ip0036t1, mcipm_ip0052t1
				WHERE   @acquirer_region 				= mcipm_ip0036t1.from_region
				AND	@issuer_region 					= mcipm_ip0036t1.to_region
				AND	@card_program_id				= mcipm_ip0036t1.card_program_id
				AND	mcipm_ip0036t1.buss_service_arrange_life_cycle_ind NOT LIKE 'L'
				AND	@card_program_id				= mcipm_ip0052t1.card_program_id
				AND	mcipm_ip0052t1.buss_service_arrange_type      	= mcipm_ip0036t1.buss_service_arrange_type	
				AND	mcipm_ip0052t1.buss_service_id_code	      	= mcipm_ip0036t1.buss_service_id_code
				AND  	mcipm_ip0052t1.mti			    	= @mti
				AND  	mcipm_ip0052t1.function_code		    	= @function_code
				AND  	mcipm_ip0052t1.transaction_type		 	= @transaction_type
				AND     mcipm_ip0052t1.from_account_type = @l_masked_from_acct_type
				AND  	mcipm_ip0052t1.to_account_type		 	= @to_account_type
				AND	mcipm_ip0052t1.reversal_allowed			  IN ('B', @reversal_ind)
				AND     (mcipm_ip0052t1.product_type_id			= @product_type OR
				 	 mcipm_ip0052t1.product_type_id			= '3')	
					
			END			

		END	
	
	END

END

GO





USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[mcipm_get_fees]    Script Date: 11/25/2016 16:30:03 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].[mcipm_get_fees]
	@fee_code_pointer		CHAR(11),
	@payment_party			CHAR(3),
	@tran_amount			CHAR(17)
AS
BEGIN
	IF EXISTS (
		SELECT TOP 1
			currency_code, 
			interchange_rate,
			rate_direction, 
			unit_fee, 
			fee_direction,
			min_fee_limit,
			max_fee_limit,
			min_max_direction,
			exponent,
			rate_type,
			no_of_fee_segments,
			tran_amount_range_low
		FROM mcipm_ip0053t1
		WHERE fee_code_pointer = @fee_code_pointer
		AND payment_party = @payment_party
		AND tran_amount_range_low >= @tran_amount
		AND rate_type='001'
		)
	BEGIN
		SELECT TOP 1
			currency_code, 
			interchange_rate,
			rate_direction, 
			unit_fee, 
			fee_direction,
			min_fee_limit,
			max_fee_limit,
			min_max_direction,
			exponent,
			rate_type,
			no_of_fee_segments,
			tran_amount_range_low
		FROM mcipm_ip0053t1
		WHERE fee_code_pointer = @fee_code_pointer
		AND payment_party = @payment_party
		AND tran_amount_range_low >= @tran_amount
		AND rate_type='001'
		ORDER BY tran_amount_range_low ASC
	END
	ELSE
	BEGIN
		SELECT
		currency_code, 
		interchange_rate,
		rate_direction, 
		unit_fee, 
		fee_direction,
		min_fee_limit,
		max_fee_limit,
		min_max_direction,
		exponent,
		rate_type,
		no_of_fee_segments,
		tran_amount_range_low
		FROM mcipm_ip0053t1
		WHERE fee_code_pointer = @fee_code_pointer AND payment_party = @payment_party
	END
END


GO


