USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_cleaner_post_tran_leg]    Script Date: 10/24/2015 12:39:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE [dbo].[usp_cleaner_post_tran_leg]
@num_of_days	INT,
	@throttle					INT,
	@batch_size 				INT,
	@rows_deleted				BIGINT OUT
AS
BEGIN
	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	DECLARE @throttle_reference			DATETIME
	DECLARE @percentage_complete			VARCHAR(3)
	DECLARE @del_range						BIGINT
 
	SELECT @rows_deleted = 0


DECLARE @max_post_tran_id BIGINT 
DECLARE @max_post_tran_cust_id BIGINT 
DECLARE @norm_session_id BIGINT 
DECLARE @norm_session_id_2 BIGINT 




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
 
	CREATE TABLE #retain_ptid (post_tran_id BIGINT PRIMARY KEY)
	INSERT INTO #retain_ptid
	SELECT post_tran_id
	FROM post_tran_leg_internal
	WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM #retain_ptcid)
	AND post_tran_id <= @max_post_tran_id
	AND post_tran_cust_id <= @max_post_tran_cust_id
 
	-- Get the number of rows that will be deleted for reporting % progress
	SELECT @del_range = COUNT_BIG(*)
	FROM post_tran_leg_internal WITH (NOLOCK)
	WHERE post_tran_id <= @max_post_tran_id
	AND post_tran_cust_id <= @max_post_tran_cust_id
	AND NOT EXISTS (SELECT 1 FROM #retain_ptcid rp WHERE rp.post_tran_cust_id = post_tran_leg_internal.post_tran_cust_id)
 
	SET @throttle_reference = NULL
	EXEC osp_throttle @throttle, @throttle_reference OUTPUT
 
	-- Perform batched deletes on the transaction table until all the rows in the delete range have been cleaned
	IF @del_range > 0
	BEGIN
		DECLARE @current_post_tran_id BIGINT
		SELECT @current_post_tran_id = MIN(post_tran_id) FROM post_tran_leg_internal
		WHILE @current_post_tran_id < @max_post_tran_id
		BEGIN
			DECLARE @upper_post_tran_id BIGINT
			SET @upper_post_tran_id = @current_post_tran_id + @batch_size - 1
			IF @upper_post_tran_id > @max_post_tran_id
				SET @upper_post_tran_id = @max_post_tran_id
 
	    BEGIN TRANSACTION
				DELETE TOP (@batch_size) post_tran_leg_internal
				FROM post_tran_leg_internal WITH (INDEX=ix_post_tran_1)
				WHERE post_tran_id BETWEEN @current_post_tran_id AND @upper_post_tran_id
				AND NOT EXISTS (
					SELECT 1
					FROM #retain_ptid rp
					WHERE rp.post_tran_id BETWEEN @current_post_tran_id AND @upper_post_tran_id
					AND rp.post_tran_id = post_tran_leg_internal.post_tran_id
				)
				OPTION (MAXDOP 10)
 
				SET @rows_deleted = @rows_deleted + @@ROWCOUNT
			COMMIT TRANSACTION
			SET @percentage_complete = CAST(ROUND(((CAST(@rows_deleted as FLOAT) / @del_range)*100),0) AS VARCHAR(30))
 
			DECLARE @activity VARCHAR(MAX)
			SET @activity = 'post_tran_leg: Deleted ' + CAST(@rows_deleted AS VARCHAR(30)) + ' entries. ' + @percentage_complete + '% Done'
			--EXEC osp_report_activity @activity

			PRINT @activity+CHAR(10);
 
			EXEC osp_throttle @throttle, @throttle_reference OUTPUT
 
			SET @current_post_tran_id = @upper_post_tran_id + 1
		END
	END
 
	SET NOCOUNT OFF
END
 
