USE [postilion_office]
GO
/****** Object:  Trigger [dbo].[ot_post_tran_insert_2]    Script Date: 08/02/2016 17:02:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER TRIGGER [dbo].[ot_post_tran_insert_2]
ON [dbo].[post_tran]
INSTEAD OF INSERT
AS
	DECLARE @prev_post_tran_id	BIGINT
	DECLARE @post_tran_id 		BIGINT
	DECLARE @message_type 	INT
	DECLARE @tran_amount_req 	POST_MONEY
	DECLARE @rsp_code_rsp 	CHAR(2)
	DECLARE @settle_amount_impact	POST_MONEY
	DECLARE @post_tran_cust_id BIGINT
	DECLARE @sink_node_name varchar(50)
 set nocount on
	
	-- The BIGINT-Background-Copy job sets the context_info up with this value
	-- so that we do not execute the trigger when it does the inserting:
	IF EXISTS (
		SELECT context_info FROM master..sysprocesses 
		WHERE spid = @@spid
			AND context_info = 0x424947494E542D4261636B67726F756E642D436F7079)
	BEGIN
		RETURN
	END

	SELECT 	
		@prev_post_tran_id = prev_post_tran_id,
		@post_tran_id = post_tran_id,
		@message_type = message_type,
		@tran_amount_req = tran_amount_req,
		@rsp_code_rsp = rsp_code_rsp,
		@settle_amount_impact = settle_amount_impact,
		@post_tran_cust_id =  post_tran_cust_id, 
		@sink_node_name = sink_node_name 
	FROM 
		inserted



	IF((@sink_node_name not LIKE '%CHB%') ) begin
    IF EXISTS (SELECT TOP 1 post_tran_id FROM post_tran (NOLOCK)WHERE post_tran_cust_id = @post_tran_cust_id) BEGIN
	    DELETE FROM post_tran WHERE sink_node_name  = @sink_node_name  and tran_completed = 1  
		DELETE FROM post_tran_cust WHERE post_tran_cust_id = @post_tran_cust_id   
	END
  END
  ELSE BEGIN
  
	IF (@prev_post_tran_id > 0 )
	BEGIN
		DECLARE @tran_reversed INT
		SET @tran_reversed = 0
		
		IF (@message_type = '0420' OR @message_type = '0400')
		BEGIN
			SET @tran_reversed = 1		-- Partial Reversal
				
			IF (@tran_amount_req = 0 AND (dbo.isApproveRspCode(@rsp_code_rsp) = 1))
			BEGIN
				SET @tran_reversed = 2  -- Full Reversal
			END
			ELSE IF (dbo.isApproveRspCode(@rsp_code_rsp) = 0)
			BEGIN
				SET @tran_reversed = 0 -- Transaction not Approved
			END
		END
		ELSE IF (@message_type = '0202')
		BEGIN
			-- If the settle_amount_impact of the 0202 is zero, it means either the original 0100/0200
			-- transaction was declined or the 0202 has no effect. Either way we should not update the 
			-- tran_reversed flag.
			IF (@settle_amount_impact <> 0)
			BEGIN
				IF (@tran_amount_req = 0 AND (dbo.isApproveRspCode(@rsp_code_rsp) = 1))
				BEGIN
					SET @tran_reversed = 2  -- Full Reversal
				END
				ELSE IF (@tran_amount_req <> 0)
				BEGIN
					SET @tran_reversed = 1	-- Partial Reversal
				END
			END
		END		
		
		-- Heat 760678
		DECLARE @prev_fin_post_tran_id BIGINT
		EXEC osp_norm_find_prev_fin_tran @prev_post_tran_id, @prev_fin_post_tran_id OUTPUT
	
		-- (The following separation of updates is done for performance purposes)
		-- If the previous transaction was the previous financial transaction
		IF (@prev_post_tran_id = @prev_fin_post_tran_id)
		BEGIN
			-- Merely update the previous transaction
			-- Only update the tran_reversed field if this is actually a reversal (Heat 763301)
			UPDATE 
				post_tran
			SET	
				next_post_tran_id = @post_tran_id,
				tran_reversed = 
				CASE 
					WHEN @message_type IN ('0420', '0400') OR (@message_type IN ('0202') AND @tran_reversed IS NOT NULL)
					THEN @tran_reversed	
					ELSE tran_reversed
				END
			FROM 
				post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
			WHERE 
				post_tran_id = @prev_post_tran_id
		END
		ELSE
		BEGIN
			-- Update the previous transaction's next_post_tran_id
			UPDATE
				post_tran
			SET
				next_post_tran_id = @post_tran_id
			FROM 
				post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
			WHERE
				post_tran_id = @prev_post_tran_id
					
			-- Update the previous financial transaction's tran_reversed flag if this was a reversal (Heat 763301)
			
			IF (@message_type IN ('0420', '0400')) OR (@message_type IN ('0202') AND @tran_reversed IS NOT NULL)
			BEGIN
				UPDATE
					post_tran
				SET
					tran_reversed = @tran_reversed
				FROM
					post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
				WHERE
					post_tran_id = @prev_fin_post_tran_id
			END
		END
	END
	 ELSE  INSERT INTO post_tran  SELECT * FROM inserted
	END
	

