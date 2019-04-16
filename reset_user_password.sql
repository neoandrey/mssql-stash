ALTER LOGIN reportadmin WITH DEFAULT_DATABASE=ReportServer
GO
USE [master]
GO
ALTER LOGIN reportadmin WITH PASSWORD=N'report.admin12' 
GO