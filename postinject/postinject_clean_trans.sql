USE [postilion]
GO

/****** Object:  StoredProcedure [dbo].[postinject_clean_trans]    Script Date: 06/04/2014 13:37:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


--------------------------------------------------------------------------------
-- Create placeholder_postinject_clean_trans                       
-------------------------------------------------------------------------------- 

CREATE PROCEDURE [dbo].[postinject_clean_trans]
	@nr_of_days			INT,
	@throttle			INT
AS
BEGIN

	-- Local variables
	DECLARE @time_string CHAR(12)
	DECLARE @last_wait DATETIME	
	DECLARE @id_count INT

	-- Set throttle variables: 
	SELECT @time_string = '00:00:00.' + convert(CHAR(3), ((100-@throttle)*10))
	-- Multiply by 10 to give us a reasonable millisecond order of magnitude value
	SELECT @throttle = @throttle*10
	SELECT @last_wait = getdate()	

	CREATE TABLE #temp_ids
	(
		id	INT
	)

	INSERT 	INTO #temp_ids (id)
	SELECT 	TOP 100 id
	FROM
		inject_trans (NOLOCK)
	WHERE
	DATEDIFF(dayofyear, inject_trans.time_sent, GETDATE()) > @nr_of_days
	AND	state != 0
	
	SELECT @id_count = count(*) from #temp_ids
	
	
	WHILE @id_count > 0
	BEGIN
			
		DELETE inject_trans
		FROM inject_trans INNER JOIN #temp_ids
		    ON inject_trans.id = #temp_ids.id		    

		-- Every @throttle millis, we'll backoff 
		-- for (1000-@throttle) millis to avoid swamping the system 
		IF (DATEDIFF(millisecond, @last_wait, getdate()) > @throttle) 
		BEGIN 
			IF @throttle < 1000
			BEGIN
				WAITFOR DELAY @time_string 
			END
			SELECT @last_wait = getdate() 
		END			

		TRUNCATE TABLE #temp_ids		

		INSERT 	INTO #temp_ids (id)
		SELECT 	TOP 100 id
		FROM
			inject_trans (NOLOCK)
		WHERE
		DATEDIFF(dayofyear, inject_trans.time_sent, GETDATE()) > @nr_of_days
		AND	state != 0

		SELECT @id_count = count(*) from #temp_ids

	END
	
	
	DROP TABLE #temp_ids

END

GO


