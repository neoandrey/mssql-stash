CREATE PROCEDURE joined_tran_table_cleaner(@retention_period INT,@date_to_clean DATETIME)
AS

BEGIN

	IF (@date_to_clean IS NULL) BEGIN

	SELECT @retention_period = -1 * @retention_period;

	  SELECT @date_to_clean = DATEDADD(D,@retention_period, DATEDIFF(D, 0, GETDATE());

	END
	ELSE 
	   BEGIN
	   @date_to_clean = DATEADD(D, 0, DATEDIFF(D, 0, @date_to_clean));  
	END

	IF (@date_to_clean IS NOT NULL) 

	BEGIN
		DELETE FROM postilion_office.dbo.joined_transaction_table WHERE DATEDIFF(D,recon_business_date,@date_to_clean) <=0; 

	END

END