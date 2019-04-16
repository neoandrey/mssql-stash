
CREATE PROCEDURE osp_normalization_resolve_tran_link
	@tran_nr							BIGINT,
	@online_system_id INT,
	@post_tran_cust_id			BIGINT OUTPUT,
	@last_source_post_tran_id	BIGINT OUTPUT,
	@last_sink_post_tran_id		BIGINT OUTPUT,
	@last_source_leg_approved	INT OUTPUT,
	@last_sink_leg_approved	INT OUTPUT,
	@max_sink_tran_nr				BIGINT	OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @t			BIGINT 					-- Current working tran_nr	
	DECLARE @prev_t	BIGINT	 				-- Last working tran_nr	
	
	DECLARE @last_source_rsp_code_rsp CHAR (2)
	DECLARE @last_sink_rsp_code_rsp CHAR (2)
	DECLARE @last_source_msg_type CHAR (4)
	DECLARE @last_sink_msg_type CHAR (4)

	SET @t = @tran_nr
	SET @post_tran_cust_id = NULL

	WHILE ((@t IS NOT NULL) AND (@post_tran_cust_id IS NULL))
	BEGIN
		SELECT 	
				@post_tran_cust_id = post_tran_cust_id
		FROM	
				post_tran WITH (NOLOCK)
		WHERE	
				tran_nr = @t
				AND 
				online_system_id = @online_system_id

		IF (@post_tran_cust_id IS NULL)
		BEGIN
			SET		@prev_t = @t
			SET 	@t = NULL

			SELECT 	
					@t = tran_nr_prev 
			FROM 	
					post_normalization_tran_nr_lookup WITH (NOLOCK)
			WHERE 	
					tran_nr = @prev_t
					AND
					online_system_id = @online_system_id		
		END
	END

	IF (@post_tran_cust_id IS NOT NULL)
	BEGIN
	
		-- Source leg info
		
		-- We will first attempt to find the post_tran entry with the next id set 0. If such
		--  one was not found, we will find the source node leg with the maximum post_tran_id
		
		SELECT 	
				@last_source_post_tran_id = post_tran_id,
				@last_source_rsp_code_rsp = rsp_code_rsp,
				@last_source_msg_type = message_type
				
		FROM	
				post_tran WITH (NOLOCK)
		WHERE					
				post_tran_cust_id = @post_tran_cust_id
				AND
				tran_postilion_originated = 0
				AND
				next_post_tran_id = 0	
		
		IF (@last_source_post_tran_id IS NULL)
		BEGIN		
			-- No source node leg found with a next_post_tran_id set 0. Use the maximum post_tran_id
			
			SELECT 	
				@last_source_post_tran_id = post_tran_id,
				@last_source_rsp_code_rsp = rsp_code_rsp,
				@last_source_msg_type = message_type
					
			FROM	
					post_tran WITH (NOLOCK)
			WHERE	
					post_tran_id = 
						(
							SELECT MAX (post_tran_id) 
						 	FROM post_tran WITH (NOLOCK)
						 	WHERE
								post_tran_cust_id = @post_tran_cust_id
								AND
								tran_postilion_originated = 0
						)
		END

		-- Heat 760678
		-- Find the last financial post_tran_id in the chain for the source leg

		DECLARE @prev_fin_post_tran_id_source BIGINT

		-- If the previous transaction was not a financial transaction

		IF (@last_source_msg_type NOT LIKE '01%') AND (@last_source_msg_type NOT LIKE '02%') AND (@last_source_msg_type NOT LIKE '04%')
		BEGIN
			EXEC osp_norm_find_prev_fin_tran @last_source_post_tran_id, @prev_fin_post_tran_id_source OUTPUT

			-- Get the previous financial transaction's response code

			SELECT @last_source_rsp_code_rsp = rsp_code_rsp
			FROM
				post_tran WITH (NOLOCK)
			WHERE
				post_tran_id = @prev_fin_post_tran_id_source
		END
		
		SET @last_source_leg_approved = 0

		IF (@last_source_rsp_code_rsp = '00' OR @last_source_rsp_code_rsp = '08' OR
			@last_source_rsp_code_rsp = '10' OR @last_source_rsp_code_rsp = '16' OR
			@last_source_rsp_code_rsp = '11')
		BEGIN
			SET @last_source_leg_approved = 1
		END
				
		-- Sink leg info
		
		-- We will first attempt to find the post_tran entry with the next id set 0. If such
		--  one was not found, we will find the sink node leg with the maximum post_tran_id
		
		SELECT 	
				@last_sink_post_tran_id = post_tran_id,
				@last_sink_rsp_code_rsp = rsp_code_rsp,
				@last_sink_msg_type = message_type
				
		FROM	
				post_tran WITH (NOLOCK)
		WHERE	
				post_tran_cust_id = @post_tran_cust_id
				AND
				tran_postilion_originated = 1
				AND
				next_post_tran_id = 0
		
		
		IF (@last_sink_post_tran_id IS NULL)
		BEGIN
		
			-- No sink node leg found with a next_post_tran_id set 0. Use the maximum post_tran_id
			
			SELECT 	
				@last_sink_post_tran_id = post_tran_id,
				@last_sink_rsp_code_rsp = rsp_code_rsp,
				@last_sink_msg_type = message_type
					
			FROM	
					post_tran WITH (NOLOCK)
			WHERE	
					post_tran_id = 
						(
							SELECT MAX (post_tran_id) 
						 	FROM post_tran WITH (NOLOCK)
						 	WHERE
								post_tran_cust_id = @post_tran_cust_id
								AND
								tran_postilion_originated = 1
						)
		END
		
		-- Get the maximum tran_nr in the sink node chain
		
		SELECT		
				@max_sink_tran_nr = MAX (tran_nr)
		FROM
				post_tran WITH (NOLOCK)
		WHERE
				post_tran_cust_id = @post_tran_cust_id
				AND
				tran_postilion_originated = 1
				
		
		-- Heat 760678
		-- Find the last financial post_tran_id in the chain for the sink leg

		DECLARE @prev_fin_post_tran_id_sink BIGINT
		
		-- If the previous transaction was not a financial transaction

		IF (@last_sink_msg_type NOT LIKE '01%') AND (@last_sink_msg_type NOT LIKE '02%') AND (@last_sink_msg_type NOT LIKE '04%')
		BEGIN
			EXEC osp_norm_find_prev_fin_tran @last_sink_post_tran_id, @prev_fin_post_tran_id_sink OUTPUT

			-- Get the previous financial transaction's response code

			SELECT @last_sink_rsp_code_rsp = rsp_code_rsp
			FROM
				post_tran WITH (NOLOCK)
			WHERE
				post_tran_id = @prev_fin_post_tran_id_sink
		END

		SET @last_sink_leg_approved = 0
		
		IF (@last_sink_rsp_code_rsp = '00' OR @last_sink_rsp_code_rsp = '08' OR
			@last_sink_rsp_code_rsp = '10' OR @last_sink_rsp_code_rsp = '16' OR
			@last_sink_rsp_code_rsp = '11')
		BEGIN
			SET @last_sink_leg_approved = 1
		END		
	END
END

GO
