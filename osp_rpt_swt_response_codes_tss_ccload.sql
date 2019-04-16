USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_swt_response_codes_tss_ccload]    Script Date: 05/24/2016 09:32:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE         PROCEDURE [dbo].[osp_rpt_swt_response_codes_tss_ccload]--oremeyi modified the previous. this is v7
	@StartDate		DATETIME,	-- yyyymmdd
	@EndDate		DATETIME
AS
BEGIN
	-- The B06 report uses this stored proc.
	
	DECLARE  @report_result TABLE
	(
		Warning						VARCHAR (255),	
		StartDate					CHAR (8),  
		EndDate						CHAR (8),
		Scheme_type                     INT,
		switch_fee                  FLOAT 		NULL,		
        	NrTrans 			INT,
		sink_node_name				VARCHAR (40), 
		tran_type					CHAR (2), 
		rsp_code_rsp				CHAR (2), 
		rsp_code_description		VARCHAR (60),
				 
		NrResponses			INT,
		RevenueImpact		FLOAT NULL	
		
		)			

	
	
	DECLARE @def_date					DATETIME
	DECLARE @yy 						INT
	DECLARE @mm 						INT
	DECLARE @dd 						INT
	DECLARE @report_date_start		DATETIME
	DECLARE @report_date_end		DATETIME
	
	IF (@StartDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(week,-1,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @StartDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the StartDate parameter to DateTime
		-- The TIME portion of the StartDate should be 00:00:00
		SET @StartDate  =REPLACE(CONVERT(VARCHAR(10), @StartDate,111),'/', '')
		SET @EndDate  =REPLACE(CONVERT(VARCHAR(10), @EndDate,111),'/', '')
		
		SET @yy = CAST(SubString(REPLACE(CONVERT(VARCHAR(10), @StartDate,111),'/', ''), 1, 4) AS INT)
		SET @mm = CAST(SubString(REPLACE(CONVERT(VARCHAR(10), @StartDate,111),'/', ''), 5, 2) AS INT)
		SET @dd = CAST(SubString(REPLACE(CONVERT(VARCHAR(10), @StartDate,111),'/', ''), 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM @report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM @report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	SET @report_date_start = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_start = DateAdd(m, @mm - 1, @report_date_start) 
	SET @report_date_start = DateAdd(d, @dd - 1, @report_date_start) 
			
	IF (@EndDate IS NULL)		-- Then use yesterday the default value
	BEGIN
		SET @def_date = GETDATE()
		SET @def_date = DATEADD(dd,-0,@def_date) -- oremeyi changed this to get today's date
		SET @yy = DATEPART(yy,@def_date)
		SET @mm = DATEPART(mm,@def_date)
		SET @dd = DATEPART(dd,@def_date)

		-- Still have to set this parameter, because we return it in the SELECT statement to ensure parameter is available on the Crystal Report
		SET @EndDate = CONVERT(CHAR(4),@yy) +  Right('0' + CONVERT(VARCHAR(2),@mm),2) +  Right('0' + CONVERT(VARCHAR(2),@dd),2)
	END
	ELSE
	BEGIN
		-- Convert the EndDate parameter to DateTime
		-- The TIME portion of the EndDate should be 23:59:59
		SET @yy = CAST(SubString(REPLACE(CONVERT(VARCHAR(10), @EndDate,111),'/', ''), 1, 4) AS INT)
		SET @mm = CAST(SubString(REPLACE(CONVERT(VARCHAR(10), @EndDate,111),'/', ''), 5, 2) AS INT)
		SET @dd = CAST(SubString(REPLACE(CONVERT(VARCHAR(10), @EndDate,111),'/', ''), 7, 2) AS INT)
	END

	IF NOT (@yy BETWEEN 1970 AND 2099)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('Invalid year specified.')
		SELECT * FROM @report_result
		RETURN 1
	END
	IF NOT (@mm BETWEEN 0 AND 13)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('Invalid month specified.')
		SELECT * FROM @report_result
		RETURN 1
	END
	IF NOT (@dd BETWEEN 0 AND 32)
	BEGIN
	   	INSERT INTO @report_result (Warning) VALUES ('Invalid day specified.')
		SELECT * FROM @report_result
		RETURN 1
	END
	
	SET @report_date_end = DateAdd(yyyy, @yy - 1900, 0) 
	SET @report_date_end = DateAdd(m, @mm - 1, @report_date_end) 
	SET @report_date_end = DateAdd(d, @dd - 1, @report_date_end) 
	SET @report_date_end = DateAdd(ss,-1,DateAdd(d,1,@report_date_end)) 

	IF (@report_date_end < @report_date_start)
	BEGIN
		INSERT INTO @report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
		SELECT * FROM @report_result
		RETURN 1
	END

	
	INSERT
			INTO @report_result

	SELECT	
			NULL AS Warning,
			@StartDate as StartDate,  
			@EndDate as EndDate,
			
			0 as Scheme_type,
 
			0 as switch_fee,		
        		nr_trans as NrTrans,
			sink_node_name, 
			tran_type, 
			rsp_code, 
			dbo.formatRspCodeStr(rsp_code) as rsp_code_description,
			0,
			0
	FROM
			post_ds_nodes (NOLOCK , INDEX(ix_post_ds_nodes_1))
	WHERE 
			(calendar_date >= @report_date_start) 
			AND 
			(calendar_date <= @report_date_end) 
			and
				(LEFT(sink_node_name,3) ='TSS'
				
				 OR
				 
				  sink_node_name  IN ('CCLOADsnk','SWT3LCMsnk', 'BILLSsnk','VTUsnk') 
				)
				AND
		        tran_postilion_originated = 1
			AND 
			LEFT(source_node_name,2) <>'SB'
--LEN('MEGAGTBsnk') = 0 or sink_node_name = 'MEGAGTBsnk'
			

	
	IF @@ROWCOUNT = 0	
			INSERT INTO @report_result (Warning, StartDate, EndDate) VALUES ('No transactions.', @StartDate, @EndDate)
			
	SELECT 
		 '' as Warning,
		 @StartDate as StartDate,
		 @EndDate as EndDate,
		 rsp_code_description,
		 rsp_code_rsp,
		 sink_node_name, 
		 sum(NrTrans) as NrResponses,
		 SUM(switch_fee) as RevenueImpact
		 
		 
	
		 
	 FROM
		@report_result
	--WHERE
	--	 sink_node_name like 'SWT%'

	GROUP BY
		 sink_node_name, rsp_code_rsp, rsp_code_description
	ORDER BY 
		sink_node_name, rsp_code_rsp
	
 
 
END


GO


