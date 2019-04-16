USE [vtucare]
GO
/****** Object:  StoredProcedure [dbo].[psp_do_settlement]    Script Date: 4/17/2017 2:29:38 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
alter  PROCEDURE [dbo].[psp_do_settlement](
    @from_date DATETIME = null,
    @to_date DATETIME = null
)
AS
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
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
   SET @transactions = CURSOR FORWARD_ONLY READ_ONLY FOR 
   SELECT t.transaction_id
							  
								FROM tbl_transactions t  with(nolock, index(idx_product_code))
                                  INNER JOIN tbl_products p  with (nolock, index(products_idx1))
                                  ON p.product_code = t.product_code
                                  WHERE ((t.postilion_response_code = '00') OR (t.postilion_response_code IS NULL) OR
										(t.postilion_response_code = '09' AND t.vtu_response_code IN ('SA','11','00','0','200','0,0')) OR
										(t.postilion_response_code = '09' AND t.vtu_response_code IS NULL))
                                  AND  t.dealer_id > 0 
                                  AND t.txn_value > 0
                                  AND (t.settlement_status IS NULL OR t.settlement_status = 0)
								  AND (t.req_datetime >= @yesterday AND t.req_datetime < @today)								  
                                  AND (p.settle_in_system = 1)
                                  AND ((t.message_type IN ('0200','0201') OR (t.message_type = 'WS' AND t.system_settlement_enabled = 1 AND t.dealer_id = 1)))
								  OPTION (RECOMPILE, OPTIMIZE FOR UNKNOWN)
								 
   OPEN @transactions
   FETCH NEXT FROM @transactions INTO @transaction_id
   WHILE (@@FETCH_STATUS = 0)
   BEGIN  
   BEGIN TRANSACTION
   BEGIN TRY
        INSERT INTO tbl_settlement (settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,channel_id, product_group_id,domain_id,settlement_institution_bank_domain_id)
        SELECT settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,channel_id,product_group_id,domain_id,settlement_institution_bank_domain_id FROM dbo.fxn_get_settlement_position(@transaction_id)
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
			and dbo.DateOnly(req_datetime)>= dbo.DateOnly(getdate())-5 AND dbo.DateOnly(req_datetime)<=dbo.DateOnly(getdate()) --Added by Princess to see if it will improve settlement run time after partitioning
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
GO

USE [vtucare]
GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_settlement_position]    Script Date: 4/17/2017 2:32:41 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER   FUNCTION [dbo].[fxn_get_settlement_position](@transaction_id INT)
RETURNS @settlement_positions TABLE 
(
    settlement  MONEY NOT NULL, 
    settlement_type INT NOT NULL,
    settlement_date DATETIME NOT NULL,
    transaction_id  INT NOT NULL,
    settlement_institution VARCHAR(100) NULL,
    transaction_type INT NOT NULL,
    domain_id INT NOT NULL,
    product_group_id INT NOT NULL,
    channel_id INT NOT NULL,
    settlement_institution_bank_domain_id INT NOT NULL
)
BEGIN
  --SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
   DECLARE @postilion_response_code VARCHAR(10)
   DECLARE @terminal_id VARCHAR(8)
   DECLARE @dealer_id INT
   DECLARE @acquirer_id VARCHAR(16)
   DECLARE @issuer_domain_id INT
   DECLARE @contract_id INT
   DECLARE @dealer_domain_id INT
   DECLARE @terminal_owner_domain_id INT
   DECLARE @amount MONEY
   DECLARE @message_type VARCHAR(32)
   DECLARE @channel_id INT
   DECLARE @terminal_owner_id INT
   DECLARE @product_group_id INT
   DECLARE @product_code VARCHAR(32)
   DECLARE @card_association_id INT
   
   DECLARE @issuer_settlement_percent MONEY
   DECLARE @terminal_owner_settlement_percent MONEY
   DECLARE @dealer_settlement_percent MONEY
   DECLARE @processor_settlement_percent MONEY
   DECLARE @switch_settlement_percent MONEY
   DECLARE @service_agreement_settlement_percent MONEY
   DECLARE @acquirer_settlement_percent MONEY
   DECLARE @partner_payment_settlement_percent MONEY
   DECLARE @card_association_settlement_percent MONEY
   DECLARE @issuer_settlement MONEY
   DECLARE @terminal_owner_settlement MONEY
   DECLARE @dealer_settlement MONEY
   DECLARE @processor_settlement MONEY
   DECLARE @switch_settlement MONEY
   DECLARE @service_agreement_settlement MONEY
   DECLARE @acquirer_settlement MONEY
   DECLARE @partner_payment_settlement MONEY
   DECLARE @card_association_settlement MONEY
   
   DECLARE @issuer_name VARCHAR(100)
   DECLARE @terminal_owner_name VARCHAR(100)
   DECLARE @dealer_name VARCHAR(100)
   DECLARE @terminal_id_code VARCHAR(16)
   DECLARE @service_provider_name VARCHAR(100)
   DECLARE @card_association_name VARCHAR(100) = NULL
   DECLARE @card_association_domain_id INT = 0
   
   SET @service_provider_name = (SELECT domain_name FROM tbl_domains WHERE domain_id = 1)
   
   SELECT @dealer_id=dealer_id,
          @postilion_response_code=postilion_response_code,
          @terminal_id=terminal_id,
          @dealer_id=dealer_id,
          @acquirer_id=acquirer_id,
          @issuer_domain_id=issuer_domain_id,
          @amount=txn_value,
          @message_type=message_type,
          @product_code=product_code,
          @terminal_owner_domain_id = terminal_owner_domain_id,
          @card_association_id = card_association_id
   FROM tbl_transactions t (nolock)
   WHERE transaction_id = @transaction_id

   SET @product_group_id = (SELECT product_group_id FROM tbl_products (nolock) WHERE product_code = @product_code)
   
   DECLARE @tid_prefix CHAR(1)
   SET @tid_prefix = SUBSTRING(@terminal_id,1,1)
   SET @channel_id = (SELECT channel_id FROM tbl_channel (nolock) WHERE terminal_id_range = @tid_prefix)
   IF(@channel_id IS NULL AND LEFT(@terminal_id,4) = 'SKYE')
      SET @channel_id = 1
   
   SELECT      
     @dealer_domain_id=domain_id 
   FROM tbl_dealers (nolock) WHERE dealer_id = @dealer_id
   
   SELECT 
      @dealer_name=UPPER(domain_name)
   FROM tbl_domains (nolock) WHERE domain_id = @dealer_domain_id
   
   SELECT @issuer_name=UPPER(domain_name)          
   FROM tbl_domains (nolock) WHERE domain_id = @issuer_domain_id

    IF @card_association_id <> 0
   SELECT @card_association_name=UPPER(name)          
   FROM tbl_cardassociations (nolock) WHERE id = @card_association_id

    IF @card_association_id <> 0
   SELECT @card_association_domain_id=domain_id         
   FROM tbl_cardassociations (nolock) WHERE id = @card_association_id
   
   
   SET @terminal_id_code = (SUBSTRING(@terminal_id,2,3)) 
   IF @terminal_owner_domain_id IS NULL OR @terminal_owner_domain_id = 0
    SET @terminal_owner_domain_id = (SELECT domain_id FROM tbl_terminal_owner (nolock) WHERE terminal_identifier = @terminal_id_code)
   IF(@terminal_owner_domain_id IS NULL)
   	SET @terminal_owner_domain_id = (SELECT MIN(domain_id) FROM tbl_terminal_owner (nolock) WHERE acquirer_id  = @acquirer_id)
   IF(@terminal_owner_domain_id IS NULL AND LEFT(@terminal_id,4)= 'SKYE')
   	SET @terminal_owner_domain_id = 15
   SET @terminal_owner_name = (SELECT UPPER(domain_name) FROM tbl_domains (nolock) WHERE domain_id = @terminal_owner_domain_id)
   --SET @terminal_owner_id = (SELECT terminal_owner_id FROM tbl_terminal_owner WHERE terminal_identifier = @terminal_id_code)
       DECLARE @no_of_towners INT 
   SET @no_of_towners = (SELECT COUNT(terminal_owner_id) FROM tbl_terminal_owner (nolock)  WHERE domain_id = @terminal_owner_domain_id)
   IF(@no_of_towners>1 OR @terminal_owner_domain_id = 1) -- THE OR PART IS FOR A SEASON... SO WE CAN CORRECTLY SETTLE THE BACKLOG OF TRANSACTIONS WHERE ISW IS TERMINALOWNER BECAUSE ACQUIRERID THAT CAME IN WITH TRXN IS 111111
   BEGIN
      SET @terminal_owner_id = (SELECT terminal_owner_id FROM tbl_terminal_owner (nolock) WHERE terminal_identifier = @terminal_id_code)
   END 
   ELSE
   BEGIN
      SET @terminal_owner_id = (SELECT terminal_owner_id FROM tbl_terminal_owner (nolock) WHERE domain_id = @terminal_owner_domain_id)
   END
   SELECT @contract_id=dbo.fxn_get_contract(@dealer_id,@channel_id,@terminal_owner_id,@product_group_id,@card_association_id)

   SELECT 
	    @issuer_settlement_percent=issuer_settlement,
		@terminal_owner_settlement_percent=terminal_owner_settlement,
		@dealer_settlement_percent=dealer_settlement,
		@processor_settlement_percent=processor_settlement,
		@switch_settlement_percent=switch_settlement,
		@service_agreement_settlement_percent=service_agreement_settlement,
		@acquirer_settlement_percent=acquirer_settlement,
		@partner_payment_settlement_percent=partner_payment_settlement,
                @card_association_settlement_percent = card_association_settlement
	 FROM tbl_contractx (nolock)
	WHERE id = @contract_id

	SET @issuer_settlement = ((@issuer_settlement_percent/100) * @amount)
	SET @terminal_owner_settlement = ((@terminal_owner_settlement_percent/100) * @amount)
	SET @dealer_settlement = ((@dealer_settlement_percent/100) * @amount)
	SET @processor_settlement = ((@processor_settlement_percent/100) * @amount)
	SET @switch_settlement = ((@switch_settlement_percent/100) * @amount)
	SET @service_agreement_settlement = ((@service_agreement_settlement_percent/100) * @amount)
	SET @acquirer_settlement = ((@acquirer_settlement_percent/100) * @amount)
	SET @partner_payment_settlement = ((@partner_payment_settlement_percent/100) * @amount)  
        SET @card_association_settlement = ((@card_association_settlement_percent/100) * @amount) 

        BEGIN
        if @card_association_settlement > 0 AND @card_association_id = 0  
        RETURN 
        END 

        DECLARE @sp_settlement_bank_domain INT  
        DECLARE @issuer_settlement_bank_domain INT
        DECLARE @terminal_owner_settlement_bank_domain INT
        DECLARE @acquirer_settlement_bank_domain INT
        DECLARE @dealer_settlement_bank_domain INT
        DECLARE @card_association_settlement_bank_domain INT = 0 

        SET @sp_settlement_bank_domain = (SELECT settlement_domain_id FROM tbl_domains (nolock) WHERE domain_id = 1)
        SET @issuer_settlement_bank_domain = (SELECT settlement_domain_id FROM tbl_domains (nolock) WHERE domain_id = @issuer_domain_id)
        SET @terminal_owner_settlement_bank_domain = (SELECT settlement_domain_id FROM tbl_domains (nolock) WHERE domain_id = @terminal_owner_domain_id )
        SET @dealer_settlement_bank_domain = (SELECT settlement_domain_id FROM tbl_domains (nolock) WHERE domain_id = @dealer_domain_id)
        
        IF @card_association_domain_id <> 0
        SET @card_association_settlement_bank_domain = (SELECT settlement_domain_id FROM tbl_domains (nolock) WHERE domain_id = @card_association_domain_id)
	
	IF(@message_type IN ('0200','0221'))
        BEGIN
	--Debit Issuer Trxn Amount
	INSERT INTO @settlement_positions (settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,domain_id,product_group_id,channel_id,settlement_institution_bank_domain_id)
	         VALUES (-@amount,9,getdate(),@transaction_id, @issuer_name,1,@issuer_domain_id,@product_group_id,@channel_id,@issuer_settlement_bank_domain)
	END
        ELSE
        BEGIN
        --Debit Terminal Trxn Amount
        IF(@issuer_settlement_bank_domain IS NULL)
            SET @issuer_settlement_bank_domain = 0
	INSERT INTO @settlement_positions (settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,domain_id,product_group_id,channel_id,settlement_institution_bank_domain_id)
	         VALUES (-@amount,10,getdate(),@transaction_id, @terminal_owner_name,1,@terminal_owner_domain_id,@product_group_id,@channel_id,@terminal_owner_settlement_bank_domain)
	END

       IF(@message_type = 'WS')
       BEGIN
        INSERT INTO @settlement_positions (settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,domain_id,product_group_id,channel_id,settlement_institution_bank_domain_id)
	         VALUES (@service_agreement_settlement,1,getdate(),@transaction_id, @service_provider_name,1,1,@product_group_id,@channel_id,@sp_settlement_bank_domain),
	          (@terminal_owner_settlement,2,getdate(),@transaction_id, @terminal_owner_name,1,@terminal_owner_domain_id,@product_group_id,@channel_id,@terminal_owner_settlement_bank_domain),
	          (@dealer_settlement,4,getdate(),@transaction_id, @dealer_name,1,@dealer_domain_id,@product_group_id,@channel_id,@dealer_settlement_bank_domain),
	          (@switch_settlement,5,getdate(),@transaction_id, @service_provider_name,1,1,@product_group_id,@channel_id,@sp_settlement_bank_domain),
	          (@processor_settlement,6,getdate(),@transaction_id,@service_provider_name,1,1,@product_group_id,@channel_id,@sp_settlement_bank_domain),
	          (@acquirer_settlement,7,getdate(),@transaction_id,@terminal_owner_name,1,@terminal_owner_domain_id,@product_group_id,@channel_id,@terminal_owner_settlement_bank_domain),
	          (@partner_payment_settlement,8,getdate(),@transaction_id, @terminal_owner_name,1,@terminal_owner_domain_id,@product_group_id,@channel_id,@terminal_owner_settlement_bank_domain)
       END
       ELSE
        BEGIN
            INSERT INTO @settlement_positions (settlement,settlement_type,settlement_date,transaction_id,settlement_institution,transaction_type,domain_id,product_group_id,channel_id,settlement_institution_bank_domain_id)
	         VALUES (@service_agreement_settlement,1,getdate(),@transaction_id, @service_provider_name,1,1,@product_group_id,@channel_id,@sp_settlement_bank_domain),
	          (@terminal_owner_settlement,2,getdate(),@transaction_id, @terminal_owner_name,1,@terminal_owner_domain_id,@product_group_id,@channel_id,@terminal_owner_settlement_bank_domain),
	          (@issuer_settlement,3,getdate(),@transaction_id, @issuer_name,1,@issuer_domain_id,@product_group_id,@channel_id,@issuer_settlement_bank_domain),
	          (@dealer_settlement,4,getdate(),@transaction_id, @dealer_name,1,@dealer_domain_id,@product_group_id,@channel_id,@dealer_settlement_bank_domain),
	          (@switch_settlement,5,getdate(),@transaction_id, @service_provider_name,1,1,@product_group_id,@channel_id,@sp_settlement_bank_domain),
	          (@processor_settlement,6,getdate(),@transaction_id,@service_provider_name,1,1,@product_group_id,@channel_id,@sp_settlement_bank_domain),
	          (@acquirer_settlement,7,getdate(),@transaction_id,@terminal_owner_name,1,@terminal_owner_domain_id,@product_group_id,@channel_id,@terminal_owner_settlement_bank_domain),
	          (@partner_payment_settlement,8,getdate(),@transaction_id, @terminal_owner_name,1,@terminal_owner_domain_id,@product_group_id,@channel_id,@terminal_owner_settlement_bank_domain)
                  --(@card_association_settlement,11,getdate(),@transaction_id, @card_association_name,1,@card_association_domain_id,@product_group_id,@channel_id,@card_association_settlement_bank_domain)
        END
	
	
	
RETURN 
END

