
delete FROM settlement_summary_breakdown  where trxn_date IN ('20170930') AND trxn_category not like '%reward%'

delete  from settlement_summary_session  WHERE Business_Date IN  ('sep 30 2017 12:00AM')  ---'Jun 24 2017 12:00AM','Jun 25 2017 12:00AM','Jun 26 2017 12:00AM')

exec  postilion_office.dbo.usp_populate_late_reversal_table null, null 

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170930', 
                @End_Date = N'20170930' 
                
exec psp_settlement_summary_breakdown  N'20170930', N'20170930',null,null,null,null 
delete FROM settlement_summary_breakdown_Mega  where trxn_date IN ('20170623','20170624','20170625','20170626')

delete  from settlement_summary_session_Mega  WHERE Business_Date IN  ('Jun 23 2017 12:00AM','Jun 24 2017 12:00AM','Jun 25 2017 12:00AM','Jun 26 2017 12:00AM')

go



EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170930', 
                @End_Date = N'20170930' 
                
exec psp_settlement_summary_breakdown  N'20170930', N'20170930',null,null,null,null 

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170624', 
                @End_Date = N'20170624' 
                
exec psp_settlement_summary_breakdown_Mega  N'20170624', N'20170624',null,null,null,null 


EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170625', 
                @End_Date = N'20170625' 
                
                go
                
exec psp_settlement_summary_breakdown_Mega  N'20170625', N'20170625',null,null,null,null 

go

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20170626', 
                @End_Date = N'20170626' 
 go               
exec psp_settlement_summary_breakdown_Mega  N'20170626', N'20170626',null,null,null,null 

go