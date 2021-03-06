USE [smartvu_staging]
GO
/****** Object:  StoredProcedure [dbo].[psp_update_closed_terminal_batch]    Script Date: 01/17/2014 09:10:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[psp_update_closed_terminal_batch]
(
	@psId VARCHAR (50),
	@psCalculatedBalance decimal(18, 0),
	@psBatchEndCheckId [VARCHAR] (100) = NULL 
)
AS

BEGIN    
	DECLARE @nID INT

	IF EXISTS(SELECT 1 FROM [smartvu_staging].[dbo].[terminal_batches] WHERE  [id] = @psId)
	BEGIN
		UPDATE [smartvu_staging].[dbo].[terminal_batches]
		SET
		[calculated_balance] = @psCalculatedBalance,
		[batch_end_check_id] = @psBatchEndCheckId
	    WHERE   id = @psId
	END
    
    IF @@error <> 0
        RETURN -1000
    
    SELECT @nID = scope_identity()
    
    RETURN @nID
    
END



