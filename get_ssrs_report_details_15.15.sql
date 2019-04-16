USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[get_ssrs_report_details]    Script Date: 05/21/2015 10:22:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[get_ssrs_report_details]  (@reportName VARCHAR(255), @scheduleName VARCHAR(255), @reportStartDate DATETIME,@reportEndDate DATETIME,@sortOrder VARCHAR(10), @userName VARCHAR(255), @status VARCHAR(255), @format VARCHAR (255), @sortColumn VARCHAR (255))                    
AS
BEGIN 

 
		   DECLARE @diffTime DATETIME;
           DECLARE @tempScheduleID VARCHAR(50)

                   SELECT @reportName =ISNULL('%'+@reportName+'%' ,'%%');
                   SELECT @scheduleName =ISNULL('%'+@scheduleName+'%' ,'%%'); 
                   SELECT @userName =ISNULL('%'+@userName+'%' ,'%%') ;
                   SELECT @status =ISNULL(@status ,'%%') ;
                   SELECT @format =ISNULL('%'+@format+'%' ,'%%');
                   SELECT @reportStartDate =ISNULL(@reportStartDate,DATEADD(D, -1, DATEDIFF(D,0, GETDATE()))); 
                   SELECT @reportEndDate =ISNULL(@reportEndDate, DATEADD(D, 0, DATEDIFF(D,0, GETDATE()))) ;
                   SELECT @sortOrder =ISNULL(+@sortOrder+'%' ,'DESCENDING') ;
                   SELECT @sortColumn =ISNULL('%'+@sortColumn+'%' ,'REPORT_NAME') ;
                   
					IF OBJECT_ID('tempdb.dbo.#TEMP_RESULTS_TABLE') IS NOT NULL
					BEGIN
						DROP TABLE #TEMP_RESULTS_TABLE;
					END	
   
                   CREATE TABLE #TEMP_RESULTS_TABLE(
						REPORT_NAME VARCHAR(500),
						SCHEDULE_NAME VARCHAR(500),
						[USER_NAME] VARCHAR(500),
						REPORT_STATUS VARCHAR(500),
						STATUS_DETAILS VARCHAR(500),
						FORMAT VARCHAR(500),
						REPORT_START_TIME DATETIME, 
						REPORT_END_TIME DATETIME,
						DATA_RETRIEVAL_TIME VARCHAR(500),
						PROCESSING_TIME VARCHAR(500),
						RENDERING_TIME VARCHAR(500),
						LAST_SUBSCRIPTION_STATUS VARCHAR(500),
						SUBSCRIPTION_DESCRIPTION VARCHAR(500),
						SUBSCRIPTION_DELIVERY_EXTENSION VARCHAR(500), 
						REPORT_PATH VARCHAR(500),
						SCHEDULE_STATE VARCHAR(500),
						REPORT_ID VARCHAR(500),
						LAST_RUN_TIME DATETIME,
						LAST_SCHEDULE_STATE VARCHAR(500),
						SCHEDULE_CREATOR VARCHAR(500)
						)
                   
                   IF (@status IS NOT NULL AND @status !='%%')
					   BEGIN
	                   SELECT @status = CASE 
	                                      WHEN @status LIKE 'SUC%' THEN '%has been saved%'
	                                      WHEN @status LIKE 'Fail%' THEN '%Fail%'
	                                    END
					   END
					   
				   
					    SELECT @diffTime = DATEADD(D, 1, @reportStartDate);	   
					 WHILE (DATEDIFF(D, @diffTime, @reportEndDate)>=0) 
                       
					     BEGIN

					   INSERT  INTO #TEMP_RESULTS_TABLE (
							    REPORT_NAME,
								SCHEDULE_NAME,
								[USER_NAME] ,
								REPORT_STATUS,
								STATUS_DETAILS,
								FORMAT ,
								REPORT_START_TIME , 
								REPORT_END_TIME ,
								DATA_RETRIEVAL_TIME,
								PROCESSING_TIME ,
								RENDERING_TIME ,
								LAST_SUBSCRIPTION_STATUS ,
								SUBSCRIPTION_DESCRIPTION ,
								SUBSCRIPTION_DELIVERY_EXTENSION, 
								REPORT_PATH ,
								SCHEDULE_STATE ,
								REPORT_ID ,
								LAST_RUN_TIME ,
								LAST_SCHEDULE_STATE,
								SCHEDULE_CREATOR
					)
						SELECT  
								cat.Name AS REPORT_NAME,
								sch.name AS SCHEDULE_NAME,
								usr.UserName AS [USER_NAME],
								(CASE 
				                    WHEN subs.LastStatus  LIKE '%saved to%'  THEN 'SUCCESS'
									WHEN subs.LastStatus  LIKE '%pending%'   THEN 'PENDING'
									WHEN subs.LastStatus  LIKE '%fail%'      THEN 'FAILURE'
								END)  AS REPORT_STATUS,  
								subs.LastStatus AS 'STATUS_DETAILS',
								exlog.[FORMAT],
								exlog.TimeStart,
								exlog.TimeEnd,
									(CASE 
								WHEN (SUM(exlog.TimeDataRetrieval/1000.0)/60.0)<=1 THEN CONVERT(VARCHAR(25),(exlog.TimeDataRetrieval/1000.0))+' secs'
								WHEN (SUM(exlog.TimeDataRetrieval/1000.0) /60.0)>1 AND (SUM(exlog.TimeDataRetrieval/1000.0) /60.0)<=59 THEN CONVERT(VARCHAR(25),(SUM(exlog.TimeDataRetrieval/1000.0)/60))+' mins: '+CONVERT(VARCHAR(25),(SUM(exlog.TimeDataRetrieval/1000.0)% 60))+' secs '
								WHEN (SUM(exlog.TimeDataRetrieval/1000.0) /3600.0)>1 AND (SUM(exlog.TimeDataRetrieval/1000.0) /3600.0)<=24 THEN CONVERT(VARCHAR(25),(SUM(exlog.TimeDataRetrieval/1000.0)/3600))+' hr(s): '+(CONVERT(VARCHAR(25),(SUM(exlog.TimeDataRetrieval/1000.0) % 3600)/60))+' mins: '+(CONVERT(VARCHAR(25),(SUM(exlog.TimeDataRetrieval/1000.0)% 3600)/60 % 60))+' secs '
								END ) AS DATA_RETRIEVAL_TIME,
						(CASE 
								WHEN (SUM(TimeProcessing/1000.0)/60.0)<=1 THEN CONVERT(VARCHAR(25),(TimeProcessing/1000.0))+' secs'
								WHEN (SUM(TimeProcessing/1000.0) /60.0)>1 AND (SUM(TimeProcessing/1000.0) /60.0)<=59 THEN CONVERT(VARCHAR(25),(SUM(TimeProcessing/1000.0)/60))+' mins: '+CONVERT(VARCHAR(25),(SUM(TimeProcessing/1000.0)% 60))+' secs '
								WHEN (SUM(TimeProcessing/1000.0) /3600.0)>1 AND (SUM(TimeProcessing/1000.0) /3600.0)<=24 THEN CONVERT(VARCHAR(25),(SUM(TimeProcessing/1000.0)/3600))+' hr(s): '+(CONVERT(VARCHAR(25),(SUM(TimeProcessing/1000.0) % 3600)/60))+' mins: '+(CONVERT(VARCHAR(25),(SUM(TimeProcessing/1000.0)% 3600)/60 % 60))+' secs '
								END ) AS PROCESSING_TIME,
							(CASE 
								WHEN (SUM(TimeRendering/1000.0) /60.0)<=1 THEN CONVERT(VARCHAR(25),SUM(TimeRendering/1000.0) )+' secs'
								WHEN (SUM(TimeRendering/1000.0)  /60.0)>1 AND (SUM(TimeRendering/1000.0) /60.0)<=59 THEN CONVERT(VARCHAR(25),(SUM(TimeRendering/1000.0) /60))+' mins: '+CONVERT(VARCHAR(25),(SUM(TimeRendering/1000.0)  % 60))+' secs '
								WHEN (SUM(TimeRendering/1000.0)  /3600.0)>1 AND (SUM(TimeRendering/1000.0)  /3600.0)<=24 THEN CONVERT(VARCHAR(25),(SUM(TimeRendering/1000.0) /3600))+' hr(s): '+(CONVERT(VARCHAR(25),(SUM(TimeRendering/1000.0)  % 3600)/60))+' mins: '+(CONVERT(VARCHAR(25),(SUM(TimeRendering/1000.0)  % 3600)/60 % 60))+' secs '
								END ) AS RENDERING_TIME,
								subs.LastStatus AS LAST_SUBSCRIPTION_STATUS,
								subs.Description AS SUBSCRIPTION_DESCRIPTION, 
								subs.DeliveryExtension AS SUBSCRIPTION_DELIVERY_EXTENSION, 
								cat.Path AS REPORT_PATH,
								sch.[State] AS SCHEDULE_STATE,
								rpsch.ReportID AS REPORT_ID,
								subs.[LastRunTime] AS LAST_RUN_TIME,
								sch.[LastRunStatus] AS LAST_SCHEDULE_STATE,
								sch.[CreatedById] AS SCHEDULE_CREATOR 		
				   FROM Schedule sch WITH (NOLOCK)
						JOIN  ReportSchedule rpsch WITH (NOLOCK) ON sch.ScheduleID = rpsch.ScheduleID
						JOIN  [Catalog] cat WITH (NOLOCK) ON cat.ItemID = rpsch.ReportID 
					    JOIN Subscriptions subs WITH (NOLOCK) ON subs.SubscriptionID =rpsch.SubscriptionID AND   cat.ItemID = subs.Report_OID
		                LEFT OUTER JOIN ( SELECT ReportID,MAX(TimeStart) LastTimeStart FROM
														ReportServer.dbo.ExecutionLog exlog WITH (NOLOCK)
														WHERE 	  DATEADD(D,0, DATEDIFF(D,0,exlog.TimeStart))  >=@reportStartDate AND  DATEADD(D,0, DATEDIFF(D,0,exlog.TimeStart)) <=@diffTime
														GROUP BY
														ReportID
											) AS LatestExecution    ON  cat.ItemID = LatestExecution.ReportID
						LEFT OUTER JOIN  ( SELECT ReportID, COUNT(TimeStart) CountStart FROM
											ReportServer.dbo.ExecutionLog exlog WITH (NOLOCK)
											WHERE 	 DATEADD(D,0, DATEDIFF(D,0,exlog.TimeStart))  >=@reportStartDate AND  DATEADD(D,0, DATEDIFF(D,0,exlog.TimeStart)) <=@diffTime
											GROUP BY
											ReportID
							               ) AS CountExecution    ON cat.ItemID = CountExecution.ReportID
					JOIN ReportServer.dbo.Users usr WITH (NOLOCK) ON   usr.UserID = sch.CreatedById 
	      				LEFT OUTER JOIN ReportServer.dbo.ExecutionLog AS exlog ON  LatestExecution.ReportID = exlog.ReportID AND  LatestExecution.LastTimeStart = exlog.TimeStart
								  WHERE 
								( cat.Name  LIKE @reportName OR  cat.Name  IS NULL)
								  AND
								(sch.name LIKE @scheduleName OR 	sch.name  IS NULL)
								AND
								(usr.UserName LIKE @userName OR 	usr.UserName  IS NULL)
								 AND
								(subs.LastStatus  LIKE @status )
								AND
								exlog.[FORMAT]  !='RPL' AND exlog.[FORMAT] LIKE @format
								 AND
								 DATEADD(D,0, DATEDIFF(D,0,exlog.TimeStart))  >=@reportStartDate AND  DATEADD(D,0, DATEDIFF(D,0,exlog.TimeStart)) <=@diffTime
								--DATEDIFF(DAY,  exlog.TimeStart,@diffTime ) <=1
								 AND 
								 exlog.TimeStart IS NOT NULL
			                     GROUP BY cat.Name, sch.name, usr.UserName,subs.LastStatus, exlog.[FORMAT], exlog.TimeStart, exlog.TimeEnd, subs.LastStatus , subs.Description, subs.DeliveryExtension , cat.Path,sch.[State],TimeProcessing/1000.0, TimeRendering/1000.0, rpsch.ReportID, subs.[LastRunTime],	  sch.[LastRunStatus],exlog.TimeDataRetrieval, sch.[CreatedById] ORDER BY exlog.TimeStart 
		  
		  SELECT @reportStartDate = @diffTime;
		  SELECT @diffTime = DATEADD(D, 1, @reportStartDate);
         END
         
		IF (@sortOrder LIKE 'ASC%') 
		BEGIN   
		  SELECT * FROM #TEMP_RESULTS_TABLE ORDER BY (SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('dbo.#TEMP_RESULTS_TABLE')  AND name =@sortColumn)   ASC
		END
		   ELSE IF (@sortOrder LIKE 'DESC%') 
		      BEGIN
		  	    SELECT * FROM #TEMP_RESULTS_TABLE ORDER BY  (SELECT name FROM sys.columns WHERE object_id = OBJECT_ID('dbo.#TEMP_RESULTS_TABLE')  AND name =@sortColumn)  DESC
		   END
	
		IF  EXISTS(SELECT * FROM tempdb.dbo.sysobjects where id=OBJECT_ID('tempdb.dbo.#TEMP_STATUS_MAP'))
		BEGIN 
		DROP TABLE #TEMP_STATUS_MAP;
		END
		
		IF OBJECT_ID('tempdb.dbo.#TEMP_RESULTS_TABLE') IS NOT NULL
					     BEGIN
				DROP TABLE #TEMP_RESULTS_TABLE;
		END	
	
		END

