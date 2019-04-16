USE [postilion_office]
GO
/****** Object:  Trigger [dbo].[ot_post_tran_update]    Script Date: 08/02/2016 17:02:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER   TRIGGER  [dbo].[ot_post_tran_update]
ON [dbo].[post_tran]
FOR UPDATE
AS
	DECLARE @next_post_tran_id BIGINT
	DECLARE @rsp_code_rsp 	CHAR(2)
	DECLARE @sink_node_name VARCHAR(50)
DECLARE @post_tran_cust_id BIGINT

	SELECT 	
			@next_post_tran_id = next_post_tran_id,
			@rsp_code_rsp = rsp_code_rsp,
			@sink_node_name = sink_node_name
	FROM 
			inserted				
	 IF(@sink_node_name like '%CHB%')
	 BEGIN
	IF (@next_post_tran_id > 0 AND (dbo.isApproveRspCode(@rsp_code_rsp) = 1) )
	BEGIN
		
		-- Update the next transaction
	
		UPDATE 
				post_tran
		SET	
				prev_tran_approved = 1
		FROM
				post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
		WHERE 
				post_tran_id = @next_post_tran_id
		END
	END
	
