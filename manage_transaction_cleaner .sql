
CREATE PROCEDURE manage_transaction_cleaner (@default_retention_period INT, @throttle_factor  INT, @segment_size  INT,@offet_reduction_factor INT) AS

BEGIN

	DECLARE @transaction_period INT;
	DECLARE @period_offet INT;
	DECLARE @new_offet_period INT;
	DECLARE @new_retention_period INT;
	DECLARE @user_param_list  VARCHAR (30);
	
	SET @default_retention_period= ISNULL(@default_retention_period,120);
	SET @throttle_factor = ISNULL(@throttle_factor,90);
	SET @segment_size = ISNULL(@segment_size,8000);
        SET @offet_reduction_factor= ISNULL(@offet_reduction_factor,5);

	SELECT @transaction_period= DATEDIFF(D, MIN(datetime_req), MAX(datetime_req)) FROM post_tran(NOLOCK);
	SET @period_offet = @transaction_period - @default_retention_period
	SET @new_offet_period = @period_offet /@offet_reduction_factor;
	SET @new_retention_period = @transaction_period - @new_offet_period;

        SET @user_param_list =CONVERT(VARCHAR(10), @new_retention_period)+';'+CONVERT(VARCHAR(10),@throttle_factor)+';'+CONVERT(VARCHAR(10),@segment_size);

        IF ( @new_retention_period > @default_retention_period)
           BEGIN

		UPDATE cleaner_entity SET user_param_list=@user_param_list WHERE name='Transactions';
           END	
END


exec postilion_office.dbo.manage_transaction_cleaner 
@default_retention_period = 120, 
@throttle_factor=90,
@segment_size= 8000,
@offet_reduction_factor =5