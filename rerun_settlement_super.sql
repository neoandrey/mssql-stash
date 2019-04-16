USE [postilion_office] 
GO 

delete FROM settlement_summary_breakdown  where trxn_date IN ('20170623','20170624','20170625','20170626')

delete  from settlement_summary_session 
 WHERE Business_Date IN  ('Jun 23 2017 12:00AM','Jun 24 2017 12:00AM','Jun 25 2017 12:00AM','Jun 26 2017 12:00AM')

go



EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170623', 
                @End_Date = N'20170623' 
                
exec psp_settlement_summary_breakdown  N'20170623', N'20170623',null,null,null,null 

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170624', 
                @End_Date = N'20170624' 
                
exec psp_settlement_summary_breakdown  N'20170624', N'20170624',null,null,null,null 


EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170625', 
                @End_Date = N'20170625' 
                
                go
                
exec psp_settlement_summary_breakdown  N'20170625', N'20170625',null,null,null,null 

go

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170626', 
                @End_Date = N'20170626' 
 go               
exec psp_settlement_summary_breakdown  N'20170626', N'20170626',null,null,null,null 

go