USE [ReportServer]
GO
/****** Object:  StoredProcedure [dbo].[set_report_config_for_specific_date]    Script Date: 07/14/2014 16:02:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[set_report_config_for_specific_date](@report_date VARCHAR(50), @reset_date  BIT) AS
BEGIN

		DECLARE @start_date_params VARCHAR (300);
		DECLARE @end_date_params  VARCHAR (300); 
		DECLARE @date_params  VARCHAR (300);
		DECLARE @new_date_params  VARCHAR (300);
		DECLARE @new_start_date_params VARCHAR (300);
		DECLARE @new_end_date_params  VARCHAR (300);
		DECLARE @file_name_suffix  VARCHAR (150);
		DECLARE @new_file_name_suffix  VARCHAR (150);
		

		--SET @report_date = REPLACE(@report_date,'-', '');
		--SET @report_date = REPLACE(@report_date,'/', '');

		IF(@reset_date=1)BEGIN
			SET @start_date_params='<ParameterValue><Name>StartDate</Name><Value>'+CONVERT(VARCHAR(MAX), DATEADD(D,-1, DATEDIFF(D,0, @report_date)))+'</Value></ParameterValue>';
			SET @end_date_params='<ParameterValue><Name>EndDate</Name><Value>'+CONVERT(VARCHAR(MAX),DATEADD(D,0, DATEDIFF(D,0, @report_date)))+'</Value></ParameterValue>';
			SET @date_params='<ParameterValue><Name>date</Name><Value>'+CONVERT(VARCHAR(MAX),DATEADD(D,0, DATEDIFF(D,0, @report_date)))+'</Value></ParameterValue>';
			SET @file_name_suffix ='_'+REPLACE(@report_date,'-', '_');
		END
		ELSE BEGIN
			SET @start_date_params='<ParameterValue><Name>StartDate</Name></ParameterValue>';
			SET @end_date_params='<ParameterValue><Name>EndDate</Name></ParameterValue>';
			SET @date_params='<ParameterValue><Name>date</Name></ParameterValue>';
			SET @file_name_suffix ='_@timestamp';
		END

		IF(@report_date IS NULL OR @reset_date=1) BEGIN

			SET @new_start_date_params='<ParameterValue><Name>StartDate</Name></ParameterValue>';
			SET @new_end_date_params='<ParameterValue><Name>EndDate</Name></ParameterValue>';
			SET @new_date_params='<ParameterValue><Name>date</Name></ParameterValue>';
            SET @new_file_name_suffix ='_@timestamp';
		END
		ELSE BEGIN

			SET @new_start_date_params='<ParameterValue><Name>StartDate</Name><Value>'+CONVERT(VARCHAR(MAX), DATEADD(D,-1, DATEDIFF(D,0, @report_date)))+'</Value></ParameterValue>';
			SET @new_end_date_params='<ParameterValue><Name>EndDate</Name><Value>'+CONVERT(VARCHAR(MAX),DATEADD(D,0, DATEDIFF(D,0, @report_date)))+'</Value></ParameterValue>';
			SET @new_date_params='<ParameterValue><Name>date</Name><Value>'+CONVERT(VARCHAR(MAX),DATEADD(D,0, DATEDIFF(D,0, @report_date)))+'</Value></ParameterValue>';
			SET @new_file_name_suffix ='_'+REPLACE(@report_date,'-', '_');

		END

		UPDATE Subscriptions SET [Parameters] =  REPLACE(REPLACE(REPLACE(CONVERT(varchar(max),[parameters]), @start_date_params, @new_start_date_params), @end_date_params, @new_end_date_params),@date_params, @new_date_params) ,ExtensionSettings = REPLACE(CONVERT(VARCHAR(MAX), ExtensionSettings), @file_name_suffix,@new_file_name_suffix )  FROM Subscriptions


END