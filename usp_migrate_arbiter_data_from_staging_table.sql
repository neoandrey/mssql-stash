CREATE PROCEDURE usp_migrate_arbiter_data_from_staging_table   @copy_start_date DATETIME , @copy_end_date DATETIME , @batch_size INT 

AS 
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

--DECLARE @batch_size INT
DECLARE @start_tran_id  BIGINT
DECLARE @end_tran_id  BIGINT
--DECLARE @copy_start_date DATETIME
--DECLARE @copy_end_date  DATETIME

--SET @copy_start_date =  '20170715'
--SET @copy_end_date   =  '20170718'

SET 	@batch_size = ISNULL(@batch_size,1000)

SELECT  @start_tran_id  = MIN([post_tran_id]) FROM  tbl_postilion_office_transactions_staging(nolock)
SELECT  @end_tran_id    = MAX([post_tran_id]) FROM  tbl_postilion_office_transactions_staging(nolock)

IF(@start_tran_id IS NOT NULL AND  @end_tran_id  IS NOT NULL AND @end_tran_id  >  @start_tran_id)
BEGIN
		INSERT INTO tbl_postilion_office_transactions_3 
		SELECT * FROM    tbl_postilion_office_transactions_staging_copy WITH  (NOLOCK) 
		WHERE  [post_tran_id]
		 NOT IN (
		 SELECT [post_tran_id] FROM tbl_postilion_office_transactions_3 with (nolock) where datetime_req>= @copy_start_date  AND   datetime_req< @copy_end_date
		 )
		DELETE FROM tbl_postilion_office_transactions_staging_copy

		WHILE  (@start_tran_id<=@end_tran_id  ) BEGIN

				INSERT INTO  tbl_postilion_office_transactions_staging_copy
				select * from tbl_postilion_office_transactions_staging(nolock) 
				WHERE [post_tran_id] >= (@start_tran_id) 
				AND   [post_tran_id]< (@start_tran_id +@batch_size)

				DELETE FROM tbl_postilion_office_transactions_staging    
				WHERE [post_tran_id] >= (@start_tran_id) 
				AND   [post_tran_id] < (@start_tran_id +@batch_size)

				INSERT INTO tbl_postilion_office_transactions_3 
				SELECT * FROM    tbl_postilion_office_transactions_staging_copy WITH  (NOLOCK) 
				WHERE  [post_tran_id]
				 NOT IN (
				 SELECT [post_tran_id] FROM tbl_postilion_office_transactions_3 with (nolock) where datetime_req>=@copy_start_date   AND   datetime_req< @copy_end_date  
				 )
				DELETE FROM tbl_postilion_office_transactions_staging_copy

				SELECT  @start_tran_id =  @start_tran_id+@batch_size;

				END 
	END
END