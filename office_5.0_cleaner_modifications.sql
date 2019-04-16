DECLARE @num_of_days INT 
DECLARE @max_post_tran_id BIGINT 
DECLARE @max_post_tran_cust_id BIGINT 
DECLARE @norm_session_id BIGINT 
DECLARE @norm_session_id_2 BIGINT 

SET @num_of_days =5
drop table #retain_ptcid
CREATE TABLE #retain_ptcid (post_tran_cust_id BIGINT PRIMARY KEY)

SELECT TOP 1 @norm_session_id =normalization_session_id,@max_post_tran_id = first_post_tran_id,@max_post_tran_cust_id =  first_post_tran_cust_id
FROM post_normalization_session
WHERE datetime_creation >= DATEADD(DAY, -(@num_of_days), GETDATE())
ORDER BY datetime_creation ASC

SELECT MAX(min_post_tran_id)
FROM ofn_pt_part_bounds()
WHERE min_post_tran_id <= @max_post_tran_id
 
AND min_post_tran_id > -9223372036854775808

SELECT TOP 1 @norm_session_id_2=normalization_session_id  
FROM post_normalization_session

WHERE datetime_creation < DATEADD(DAY, -(3), GETDATE())
 ORDER BY normalization_session_id DESC

INSERT INTO #retain_ptcid
SELECT ptli.post_tran_cust_id 
FROM extract_tran fkt WITH (TABLOCK)
INNER JOIN post_tran_leg_internal ptli 
ON fkt.post_tran_id = ptli.post_tran_id 
WHERE fkt.post_tran_id < @max_post_tran_id

 UNION 
SELECT ptli.post_tran_cust_id 
FROM recon_match_equal fkt WITH (TABLOCK)
INNER JOIN post_tran_leg_internal ptli 
ON fkt.post_tran_id = ptli.post_tran_id 
WHERE fkt.post_tran_id < @max_post_tran_id

 UNION 
SELECT ptli.post_tran_cust_id 
FROM recon_match_not_equal fkt WITH (TABLOCK)
INNER JOIN post_tran_leg_internal ptli 
ON fkt.post_tran_id = ptli.post_tran_id 
WHERE fkt.post_tran_id < @max_post_tran_id

 UNION 
SELECT ptli.post_tran_cust_id 
FROM recon_post_only fkt WITH (TABLOCK)
INNER JOIN post_tran_leg_internal ptli 
ON fkt.post_tran_id = ptli.post_tran_id 
WHERE fkt.post_tran_id < @max_post_tran_id

 UNION 
SELECT post_tran_cust_id 
FROM post_tran_leg_internal WITH (TABLOCK)
WHERE post_tran_cust_id < @max_post_tran_cust_id
AND post_tran_id >= @max_post_tran_id

 UNION 
SELECT post_tran_cust_id
FROM post_tran_leg_internal ptli WITH (TABLOCK)
INNER JOIN post_batch pb WITH (TABLOCK)
ON (pb.batch_nr = ptli.batch_nr AND pb.settle_entity_id = ptli.settle_entity_id)
WHERE (close_norm_session_id >= @norm_session_id

OR close_norm_session_id IS NULL)
AND insert_norm_session_id < @norm_session_id_2

--SELECT MAX(post_tran_id) FROM post_tran_leg_internal WHERE recon_business_date='20151015'
--SELECT post_tran_cust_id FROM post_tran_leg_internal where post_tran_id =169691855


DECLARE @rows_deleted BIGINT

exec [dbo].[osp_cleaner_post_tran_leg]
	@max_post_tran_id		=@max_post_tran_id,
	@max_post_tran_cust_id	=@max_post_tran_cust_id,
	@throttle			=90,
	@batch_size 		=25000,
	@rows_deleted	=0	 


SELECT @rows_deleted