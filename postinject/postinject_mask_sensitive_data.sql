USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_mask_sensitive_data]    Script Date: 06/04/2014 13:44:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create placeholder_postinject_mask_sensitive_data.                          
-------------------------------------------------------------------------------- 
CREATE PROCEDURE [dbo].[postinject_mask_sensitive_data]
	@id	 			BIGINT,
        @req_fields                     VARCHAR(3500),
        @req_struct_data                TEXT,
        @req_icc                        TEXT
AS
BEGIN


	BEGIN
		UPDATE	inject_trans
		SET	req_fields = @req_fields,
			req_struct_data   = @req_struct_data,  
			req_icc = @req_icc 
		WHERE	id = @id		
	END
		
END

GO


