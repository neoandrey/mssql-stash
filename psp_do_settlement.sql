CREATE  PROCEDURE [dbo].[psp_do_settlement](
    @from_date DATETIME = null,
    @to_date DATETIME = null
)
AS
SET NOCOUNT ON
BEGIN
   if (@from_date IS NULL)
      set @from_date = dbo.DateOnly(getdate())
   if (@to_date IS NULL)
      set @to_date = dbo.DateOnly(getdate())
   DECLARE @yesterday DATETIME
   DECLARE @today DATETIME
   DECLARE @transactions CURSOR 
   DECLARE @transaction_id INT
   SET @yesterday = dbo.DateOnly(getdate())-5
   SET @today = dbo.DateOnly(getdate())
   SET @transactions = CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR 
   SELECT   t.transaction_id
							   FROM
								 (SELECT * FROM tbl_transactions tt (nolock) WHERE tt.req_datetime >= @yesterday AND tt.req_datetime < @today
								 and ((tt.postilion_response_code = '00') OR (tt.postilion_response_code IS NULL) OR
										(tt.postilion_response_code = '09' AND tt.vtu_response_code IN ('SA','11','00','0','200','0,0')) OR
										(tt.postilion_response_code = '09' AND tt.vtu_response_code IS NULL))
                                  AND  tt.dealer_id > 0 
                                  AND tt.txn_value > 0
                                  AND (tt.settlement_status IS NULL OR tt.settlement_status = 0)							  
                                  AND ((tt.message_type IN ('0200','0201') OR (tt.message_type = 'WS' AND tt.system_settlement_enabled = 1 AND tt.dealer_id = 1)))
								 ) t
                                   INNER JOIN
								   (SELECT * FROM tbl_products pp (nolock) WHERE pp.settle_in_system = 1) p
                                  ON p.product_code = t.product_code
								 
   OPEN @transactions
   FETCH NEXT FROM @transactions INTO @transaction_id
   WHILE (@@FETCH_STATUS = 0)
   BEGIN  
   BEGIN TRANSACTION
   BEGIN TRY
        INSERT INTO tbl_settlement (settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,channel_id, product_group_id,domain_id,settlement_institution_bank_domain_id)
        SELECT settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,channel_id,product_group_id,domain_id,settlement_institution_bank_domain_id 
        
        FROM dbo.fxn_get_settlement_position(@transaction_id)
	    IF(@@ERROR<>0)
	    BEGIN 
		 ROLLBACK TRANSACTION     
	    END
	    ELSE
		BEGIN
			UPDATE tbl_transactions
			SET settlement_status = 1,
			    settlement_date = dbo.DateOnly(getdate())
			WHERE transaction_id = @transaction_id
			IF(@@ERROR<>0)
			BEGIN 
			  ROLLBACK TRANSACTION     
			END
			ELSE
			BEGIN
			   COMMIT TRANSACTION
			END
     /*   INSERT INTO tbl_settlement_run_log(transaction_id,processing_status,error_desc)
            VALUES(@transaction_id,'Success',NULL)*/
         END
    END TRY
	BEGIN CATCH
	     IF(@@ERROR<>0)
		   BEGIN 
			 ROLLBACK TRANSACTION     
		   END
	     INSERT INTO tbl_settlement_run_log(transaction_id,processing_status,error_desc)
            VALUES(@transaction_id,'Failure',ERROR_MESSAGE())
	END CATCH
   FETCH NEXT FROM @transactions INTO @transaction_id
   END
   CLOSE @transactions
   DEALLOCATE @transactions
END
