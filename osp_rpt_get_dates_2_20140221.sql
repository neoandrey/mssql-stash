USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_get_dates_2]    Script Date: 02/21/2014 15:12:42 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER   PROCEDURE [dbo].[osp_rpt_get_dates_2]
	@default_date_method	VARCHAR (50),		-- 'Last business day', 'Yesterday', 'Today', 'Previous week', 'Previous month', 'Last closed batch end calendar day'
	@node_name_list		VARCHAR (255),
	@user_start_date	VARCHAR (8),
	@user_end_date		VARCHAR (8),
	@report_date_start	DATETIME OUTPUT,
	@report_date_end	DATETIME OUTPUT,
	@report_date_end_next	DATETIME OUTPUT,
	@warning		VARCHAR (255) OUTPUT
as
BEGIN

	CREATE TABLE #rpt_get_dates
	(
		node_name	VARCHAR (12)
	)

	DELETE FROM #rpt_get_dates

	DECLARE @yy INT
	DECLARE @mm INT
	DECLARE @dd INT

	SELECT @warning = NULL

	IF @default_date_method IS NULL
		SET @default_date_method = '<Not specified>'


	IF (@user_start_date IS NOT NULL OR @user_end_date IS NOT NULL)
	BEGIN

		--
		-- At least one date was specified, so use the specified dates
		--

		IF (@user_start_date IS NULL OR @user_end_date IS NULL)
		BEGIN
				SET @warning = 'Both the from- and to- dates should be specified.'
				RETURN
		END

		--
		-- Start date
		--

		EXECUTE osp_rpt_date_from_user @user_start_date, @report_date_start OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- End date
		--

		EXECUTE osp_rpt_date_from_user @user_end_date, @report_date_end OUTPUT, @warning OUTPUT

		IF (@warning IS NOT NULL)
		BEGIN
			RETURN
		END

		--
		-- Some validation
		--

		IF (@report_date_end < @report_date_start)
		BEGIN
			SET @warning = 'The End Date must be AFTER the Start Date.'
			RETURN
		END
	END -- use specified dates

	ELSE

	IF (@default_date_method = 'Last business day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list VARCHAR (2048)
		SET @tmp_node_list = @node_name_list

		WHILE (@tmp_node_list IS NOT NULL)
		BEGIN
				INSERT INTO #rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list))
				SET @tmp_node_list = dbo.fn_rpt_remainelem(@tmp_node_list)
		END

		--
		-- We need to get the business date of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.settle_date)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM #rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The last business date could not be determined.'

			RETURN
		END

		--IF (@report_date_start
		SET @report_date_end = @report_date_start

        DECLARE @yesterday VARCHAR(30)
        SET @yesterday = DATEADD(D, -1, DATEDIFF(D, 0, GETDATE()))

        IF( @report_date_start >= @yesterday)
           BEGIN
             SET @report_date_start = @yesterday
             SET @report_date_end = @yesterday
           END

        SELECT @report_date_end AS 'report_date_end';
        SELECT @report_date_start AS 'report_date_start';

	END -- Last business day


        ELSE

	IF (@default_date_method = 'Two Days Ago')
	BEGIN
		

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -2, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -2, @report_date_end)
	END


	ELSE

	IF (@default_date_method = 'Previous week')
	BEGIN
		--
		-- Previous week
		-- We do not know if the week should start on a Sun, or a Mon. We, for now, consider a week as the last 7 days - up to yesterday
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, -7, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Yesterday')
	BEGIN
		--
		-- Previous day
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Today')
	BEGIN
		--
		-- Today
		--

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_start = @report_date_end
	END

	ELSE

	IF (@default_date_method = 'Previous month')
	BEGIN

		-- Previous month

		EXECUTE osp_rpt_date_today @report_date_end OUTPUT

		SELECT @report_date_end = DATEADD (dd, -DATEPART(dd, @report_date_end), @report_date_end)

		SELECT @report_date_start = @report_date_end

		SELECT @report_date_start = DATEADD (dd, - DATEPART(dd, @report_date_start) + 1, @report_date_start)

		SELECT @report_date_end = DATEADD (dd, 1, @report_date_end)

		SELECT @report_date_end = DATEADD (dd, -1, @report_date_end)
	END

	ELSE

	IF (@default_date_method = 'Last closed batch end calendar day')
	BEGIN

		--
		-- Generate our list of source node names
		--

		DECLARE @tmp_node_list_2 VARCHAR (2048)
		SET @tmp_node_list_2 = @node_name_list

		WHILE (@tmp_node_list_2 IS NOT NULL)
		BEGIN
				INSERT INTO #rpt_get_dates (node_name) VALUES (dbo.fn_rpt_nextelem(@tmp_node_list_2))
				SET @tmp_node_list_2 = dbo.fn_rpt_remainelem(@tmp_node_list_2)
		END

		--
		-- We need to get the calendar date of the end of the last closed batch.
		--

		SET @report_date_start = NULL

		SELECT
				@report_date_start = MAX (b.datetime_end)

		FROM
				post_batch b WITH (NOLOCK)
				INNER JOIN
				post_settle_entity s WITH (NOLOCK)
					ON (b.settle_entity_id = s.settle_entity_id)

		WHERE
				s.node_name IN (SELECT node_name FROM #rpt_get_dates)
				AND
				b.datetime_end IS NOT NULL

		IF (@report_date_start IS NULL)
		BEGIN
			SELECT @warning = 'None of the nodes in the list ['+@node_name_list+'] have performed cutover yet. The calendar date of the last closed batch could not be determined.'

			RETURN
		END

		-- Get only the date portion of the datetime_begin
		SET @report_date_start = CONVERT(DATETIME, CONVERT(VARCHAR(10), @report_date_start, 101), 101)
		SET @report_date_end = @report_date_start

	END -- Last closed batch end calendar day

	ELSE

	BEGIN
		SET @warning = 'Invalid default date method specified: ' + @default_date_method
	END

	SET @report_date_end_next = DATEADD(dd, 1, @report_date_end)

	DROP TABLE #rpt_get_dates
END










