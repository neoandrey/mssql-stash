USE [postilion_office] 
GO 

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161223', 
                @End_Date = N'20161223' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161223', N'20161223',null,null,null,null 

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161224', 
                @End_Date = N'20161224' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161224', N'20161224',null,null,null,null 
EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161225', 
                @End_Date = N'20161225' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161225', N'20161225',null,null,null,null 

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161226', 
                @End_Date = N'20161226' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161226', N'20161226',null,null,null,null 


EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161004', 
                @End_Date = N'20161004' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161004', N'20161004',null,null,null,null 

EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161005', 
                @End_Date = N'20161005' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161005', N'20161005',null,null,null,null 


EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161006', 
                @End_Date = N'20161006' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161006', N'20161006',null,null,null,null 


EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161007', 
                @End_Date = N'20161007' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161007', N'20161007',null,null,null,null 



EXEC    [dbo].[usp_get_settlement_data_for_period] 
                @Start_Date = N'20161008', 
                @End_Date = N'20161008' 
                
exec psp_settlement_summary_breakdown_Mega  N'20161008', N'20161008',null,null,null,null 