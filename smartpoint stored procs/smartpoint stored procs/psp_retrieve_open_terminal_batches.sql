USE [smartvu_staging]
GO
/****** Object:  StoredProcedure [dbo].[psp_retrieve_open_terminal_batches]    Script Date: 01/17/2014 09:10:07 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER PROCEDURE [dbo].[psp_retrieve_open_terminal_batches]
AS

BEGIN    

    SELECT [id]
      ,[terminal_id]
      ,[batch_number]
      ,[batch_position]
      ,[start_date]
      ,[end_date]
      ,[term_id]
	FROM [smartvu_staging].[dbo].[terminal_batches]
	where status = 'OPEN'
	AND [amount_loaded] IS NULL
    
END


