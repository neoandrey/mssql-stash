USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[run_ssrs_report_on_demand]    Script Date: 07/31/2014 08:00:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[run_ssrs_report_on_demand]( @report_name VARCHAR (150),@subscription_type VARCHAR (120), @period_after_last_run BIGINT) AS
		BEGIN
		DECLARE @last_run_time VARCHAR(150);
		DECLARE @subscription_id VARCHAR (120);
		DECLARE @display_name VARCHAR (250);
	    DECLARE @brace_index int;

        SET  @period_after_last_run = ISNULL(@period_after_last_run,12);
        
		SELECT  @subscription_type=ISNULL('TimedSubscription', @subscription_type);
		IF  (OBJECT_ID('tempdb.dbo.#TEMP_REPORTS') IS NOT NULL)
		BEGIN
		DROP TABLE tempdb.dbo.#TEMP_REPORTS
		END

		IF ( @report_name IS NULL) BEGIN

				SELECT 
						S.[SubscriptionID]
						,C.[Name] + ' (' + S.[Description] + ')' AS [DISPLAY_NAME]
						,(CASE 
													WHEN S.LastStatus  LIKE '%saved to%'  THEN 'SUCCESS'
													WHEN S.LastStatus  LIKE '%pending%'   THEN 'PENDING'
													WHEN S.LastStatus  LIKE '%fail%'  OR S.LastStatus  LIKE '%Error%'      THEN 'FAILURE'
												END)  AS REPORT_STATUS,  
												S.LastStatus AS 'STATUS_DETAILS',
												S.[LastRunTime] AS LAST_RUN_TIME
					   INTO #TEMP_REPORTS
					FROM [dbo].[Subscriptions] S
					INNER JOIN [dbo].[Catalog] C ON S.[Report_OID] = C.[ItemID]
				ORDER BY [DISPLAY_NAME]

		DECLARE report_cursor CURSOR  LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT [SubscriptionID], [DISPLAY_NAME], LAST_RUN_TIME FROM #TEMP_REPORTS WHERE REPORT_STATUS= 'FAILURE' OR DATEDIFF(hour,LAST_RUN_TIME, GETDATE())>=@period_after_last_run;

		OPEN report_cursor;
		
	
		
		

		FETCH NEXT FROM report_cursor INTO @subscription_id, @display_name,@last_run_time;

			WHILE (@@FETCH_STATUS=0) 
			BEGIN
			SELECT @brace_index =CHARINDEX('(', @display_name);
			SELECT @display_name = LEFT(@display_name,@brace_index -1);
			PRINT 'Runnng report: '+ @display_name+ +'. With ID: '+ @subscription_id+'. Last runtime was: '+@last_run_time+CHAR(10); 
			EXEC [ReportServer].dbo.AddEvent  @EventType=@subscription_type,  @EventData=@subscription_id
				
				FETCH NEXT FROM report_cursor INTO @subscription_id, @display_name,@last_run_time;
			END
		
		CLOSE report_cursor;
		DEALLOCATE report_cursor;
END
ELSE BEGIN

IF  (OBJECT_ID('tempdb.dbo.#TEMP_REPORTS_2') IS NOT NULL)
BEGIN
DROP TABLE tempdb.dbo.#TEMP_REPORTS_2
END

CREATE TABLE #TEMP_REPORTS_2 (
REPORT_NAME VARCHAR(300)
)

IF (@report_name IS NOT NULL) BEGIN
	INSERT INTO #TEMP_REPORTS_2(REPORT_NAME)SELECT part FROM dbo.usf_split_string(@report_name,',');
END
  ELSE 
BEGIN
     INSERT INTO #TEMP_REPORTS_2 (REPORT_NAME) SELECT Name  FROM  dbo.Catalog
END

ALTER TABLE #TEMP_REPORTS_2 ADD DISPLAY_NAME VARCHAR(150); 

UPDATE #TEMP_REPORTS_2 SET DISPLAY_NAME = subs.DESCRIPTION COLLATE DATABASE_DEFAULT  FROM  #TEMP_REPORTS_2 rep, Subscriptions subs WHERE rep.REPORT_NAME COLLATE DATABASE_DEFAULT LIKE LEFT(subs.Description COLLATE DATABASE_DEFAULT, CHARINDEX('(', subs.Description COLLATE DATABASE_DEFAULT))  -- CHARINDEX(rep.REPORT_NAME, subs.Description) ;
DECLARE report_cursor_2 CURSOR  LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT [SubscriptionID], [DESCRIPTION] FROM [dbo].[Subscriptions] WHERE [Description] COLLATE DATABASE_DEFAULT IN (SELECT REPORT_NAME FROM #TEMP_REPORTS_2);

		OPEN report_cursor_2;

		FETCH NEXT FROM report_cursor_2 INTO @subscription_id,@display_name;


		WHILE (@@FETCH_STATUS=0) BEGIN
		--SELECT @brace_index =CHARINDEX('(', @display_name);
		--SELECT @display_name = LEFT(@display_name,@brace_index -1);
		PRINT 'Runnng report: '+ @display_name+'. With ID:'+ @subscription_id+CHAR(10); 
		EXEC [ReportServer].dbo.AddEvent  @EventType=@subscription_type,  @EventData=@subscription_id
			 
			
			FETCH NEXT FROM report_cursor_2 INTO @subscription_id,@display_name;
		END
		CLOSE report_cursor_2;
		DEALLOCATE report_cursor_2;
		


END
	
		IF  (OBJECT_ID('tempdb.dbo.#TEMP_REPORTS') IS NOT NULL)
		BEGIN
		DROP TABLE tempdb.dbo.#TEMP_REPORTS
		END

IF  (OBJECT_ID('tempdb.dbo.#TEMP_REPORTS_2') IS NOT NULL)
BEGIN
DROP TABLE tempdb.dbo.#TEMP_REPORTS_2
END

END