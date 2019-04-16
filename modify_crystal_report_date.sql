USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[modify_crystal_report_date]    Script Date: 06/22/2015 08:59:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[modify_crystal_report_date]  (@startDate CHAR(8), @endDate   CHAR(8),@reset INT )

  AS BEGIN
  
  DECLARE @dateUpdate  VARCHAR(30);
  DECLARE @newReportParams VARCHAR(1500);
  DECLARE @output_param_no   VARCHAR(2);
  DECLARE @template_path TABLE (template_name VARCHAR(500));
  DECLARE @template_name VARCHAR(500)

  SET @dateUpdate = '~'+@startDate+'~'+@endDate;
  SET @reset = ISNULL(@reset,0);
  
  IF(LEN(LTRIM(RTRIM(@startDate))) <>0 AND  LEN(LTRIM(RTRIM(@startDate))) <>0 ) 
  BEGIN
	DECLARE @table_name VARCHAR (1000);
	SET @table_name = 'reports_crystal_'+REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '-')+'_'+CONVERT(VARCHAR(10), GETDATE(),108);
	EXEC ('SELECT * INTO ['+@table_name+']  FROM reports_crystal');
	  IF(@reset =0 OR @reset IS NULL)BEGIN

			UPDATE reports_crystal SET report_params =  CASE WHEN SUBSTRING(CONVERT(VARCHAR(1000), report_params),7,4) ='NULL' THEN ( @dateUpdate +Substring(CONVERT(VARCHAR(1000),report_params),11, LEN(CONVERT(VARCHAR(1000),report_params))))
			ELSE report_params END
			

	  END
	  ELSE IF(@reset =1) BEGIN

			UPDATE reports_crystal SET report_params =
			CASE WHEN SUBSTRING(CONVERT(VARCHAR(1000), report_params),(LEN(@startDate)+3),LEN(@endDate)) =@endDate THEN ( '~NULL~NULL'+Substring(CONVERT(VARCHAR(1000),report_params),(LEN(@startDate) +LEN(@endDate)+3), LEN(CONVERT(VARCHAR(1000),report_params))))
			ELSE report_params END


	  END 
   
    
  INSERT INTO @template_path SELECT  SUBSTRING(SUBSTRING(CONVERT(VARCHAR(1000),output_params),2,  (CHARINDEX('~',CONVERT(VARCHAR(1000),output_params),2))), 0,CHARINDEX('~',SUBSTRING(CONVERT(VARCHAR(1000),output_params),2,  (CHARINDEX('~',CONVERT(VARCHAR(1000),output_params),2))) ) )FROM [reports_crystal]  
  
  UPDATE reports_crystal SET   output_params =LEFT(CONVERT(VARCHAR(1000),output_params),1)+( CASE WHEN @reset =0 or @reset IS NULL then SUBSTRING (template_name, 1, CHARINDEX('.', template_name))+'_'+@startDate+ RIGHT(template_name,3) +REPLACE(RIGHT(CONVERT(VARCHAR(1000),output_params),5),'3','0')
				WHEN @reset =1  THEN SUBSTRING (template_name, 1, CHARINDEX('.', template_name))+ RIGHT(template_name,3) +REPLACE(RIGHT(CONVERT(VARCHAR(1000),output_params),5),'0','3')
				END)
    FROM @template_path
  
  END
  ELSE BEGIN
  	PRINT 'startDate and endDate cannot be NULL or empty!'
  
  END
  
  
  END