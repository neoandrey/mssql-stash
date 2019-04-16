/****** Script for SelectTopNRows command from SSMS  ******/


SELECT  distinct 'exec msdb.dbo.sp_start_job  @job_name = '''+convert(varchar(max),ScheduleID)+''''
      
  FROM [ReportServer].[dbo].[Catalog] cat
  JOIN
 [ReportServer].[dbo].ReportSchedule rep
 on
 cat.ItemID = rep.ReportID
  
  WHERE Name like '%card%activity%'