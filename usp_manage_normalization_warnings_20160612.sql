USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_manage_normalization_warnings]    Script Date: 06/12/2016 17:50:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[usp_manage_normalization_warnings] AS

BEGIN

		IF EXISTs (select tran_nr from POST_TRAN_EXCEPTION WHERE STATE = 10) BEGIN
		
			UPDATE post_tran_exception SET  state = 50 WHERE  state =10 AND exception Like '%StaticDataGroup%';

			UPDATE post_tran_exception SET  state = 50 WHERE  state =10 AND exception  Like '%[postilion.office.reserved.message.bitmap.XHashtableMessageDataInconsistent]%';
   UPDATE post_tran_exception set state = 50 WHERE state =10 AND norm_retries > 10  AND norm_retries < 20
                  UPDATE post_tran_exception set state = 20 WHERE state =10 AND norm_retries > 20

                  UPDATE post_tran_exception set state = 40 WHERE state =10

			UPDATE post_tran_exception set state  = 20 WHERE state =10 AND exception LIKE  '%DUPLICATE%';

			UPDATE post_tran_exception SET state  = 20 WHERE state =10 AND exception LIKE  '%ALREADY%';
			
			UPDATE post_tran_exception SET state  = 20 WHERE state =10 AND exception LIKE  '%resubmitted for normalization but this transaction could not be found in the Realtime system%' ;
			 
			UPDATE post_tran_exception set state  = 40 WHERE state =10;

		END
END

