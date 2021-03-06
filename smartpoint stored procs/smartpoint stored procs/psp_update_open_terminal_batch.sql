USE [smartvu_staging]
GO
/****** Object:  StoredProcedure [dbo].[psp_update_open_terminal_batch]    Script Date: 01/17/2014 09:10:44 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[psp_update_open_terminal_batch]
(
	@psId VARCHAR (50),
	@psAmountLoaded decimal(18, 0),
	@psCurrentTransactionsAmount decimal(18, 0),
	@psBatchBeginCheckId [VARCHAR] (100) = NULL 
)
AS

BEGIN    
	DECLARE @nID INT

	IF EXISTS(SELECT 1 FROM [smartvu_staging].[dbo].[terminal_batches] WHERE  [id] = @psId)
	BEGIN
		UPDATE [smartvu_staging].[dbo].[terminal_batches]
		SET
		[amount_loaded] = @psAmountLoaded,
		[current_transactions_value] = @psCurrentTransactionsAmount,
		[batch_begin_check_id] = @psBatchBeginCheckId
		
		
	    WHERE   id = @psId
	END
    
    IF @@error <> 0
        RETURN -1000
    
    SELECT @nID = scope_identity()
    
    RETURN @nID
    
END




