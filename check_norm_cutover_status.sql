2
CREATE PROCEDURE check_norm_cutover_status @is_cutover_successful BIT OUTPUT

  AS BEGIN
		DECLARE @most_recent_tran_date  DATETIME;
		DECLARE @today DATETIME;
		DECLARE @time_diff INT;
				
		SELECT @most_recent_tran_date = (SELECT TOP 1 recon_business_date FROM post_tran (NOLOCK) ORDER BY recon_business_date DESC)
		SELECT @today= GETDATE();
		SELECT @time_diff = DATEDIFF(D,  @most_recent_tran_date, @today);
		IF(@time_diff=0) BEGIN
			SET @is_cutover_successful=1;
		END
		ELSE 
		BEGIN
			SET @is_cutover_successful=0;
		END
		
        RETURN 

END

----
DECLARE @norm_cutover BIT;

EXEC   dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;

SELECT @norm_cutover

DECLARE @norm_cutover BIT;

EXEC   postilion_office.dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;


WHILE (@norm_cutover=0) 
   BEGIN
   WAITFOR DELAY '00:10:00';
   	EXEC   postilion_office.dbo.check_norm_cutover_status  @is_cutover_successful= @norm_cutover OUTPUT;
  END

UPDATE msdb.dbo.sysjobs SET enabled = 0 WHERE NAME ='Postilion Office - Batch Process - Normalization'
EXEC postilion_office.dbo.migrate_transaction_data  @trans_server=NULL, @trans_date =NULL;
UPDATE msdb.dbo.sysjobs SET enabled = 1 WHERE NAME ='Postilion Office - Batch Process - Normalization'
