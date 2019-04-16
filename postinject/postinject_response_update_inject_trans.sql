USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_response_update_inject_trans]    Script Date: 06/04/2014 13:44:02 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[postinject_response_update_inject_trans]
	@id				BIGINT,
	@rsp_fields			VARCHAR(3500),
	@rsp_struct_data		TEXT,
	@rsp_icc  			TEXT,
	@time_rsp			DATETIME,
	@rsp_code			CHAR(2)

AS
BEGIN
	
	UPDATE 	inject_trans
	SET 	rsp_fields = @rsp_fields,
		rsp_struct_data = @rsp_struct_data,
		rsp_icc	= @rsp_icc,	
		state = 1, 
		time_rsp = @time_rsp,
		rsp_code = @rsp_code
	WHERE 	id = @id
	
END

GO


