USE [realtime]
GO

/****** Object:  Table [dbo].[term_history]    Script Date: 10/23/2017 2:16:18 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[term_history](
[id] [char](8) NOT NULL,
[short_name] [varchar](20) NOT NULL,
[term_type] [int] NOT NULL,
[term_active] [int] NOT NULL,
[support_team] [int] NULL,
[worst_event_severity] [int] NOT NULL,
[card_acceptor] [char](15) NOT NULL,
[participant_id] [int] NOT NULL,
[pos_geographic_data] [char](17) NOT NULL,
[sponsor_bank] [char](8) NOT NULL,
[pos_data_code] [char](15) NOT NULL,
[serial_nr] [varchar](30) NULL,
[date_deployed] [datetime] NULL,
[last_message_type] [varchar](20) NULL,
[last_message_time] [datetime] NULL,
[status] [varchar](200) NULL,
[hardware_config] [varchar](100) NULL,
[value_bars] [varchar](600) NULL,
[miscellaneous] [varchar](250) NULL,
[security_team] [int] NULL,
[media_team] [int] NULL,
[supplies_team] [int] NULL,
[term_mode] [int] NULL,
[last_tran_msg_time] [datetime] NULL,
[changed_column] VARCHAR(30),
[last_change_datetime] datetime DEFAULT GETDATE()
)


/****** Object:  Trigger [dbo].[trg_filter_non_stanbic_nodes]    Script Date: 07/14/2016 07:51:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER  [dbo].[trg_misc_status_term_1] ON [dbo].[term]
INSTEAD OF INSERT 
AS BEGIN 

DECLARE @miscellaneous VARCHAR(255)
DECLARE @status VARCHAR(255)
DECLARE @id VARCHAR(10)
DECLARE @current_misc VARCHAR(255)
DECLARE @current_status VARCHAR(255)


SELECT @id = id, @miscellaneous=miscellaneous, @status=status FROM  inserted
SELECT   @current_misc=miscellaneous, @current_status =status FROM [realtime].[dbo].[term]  (NOLOCK) WHERE id = @id

IF ((@current_misc!=@miscellaneous )  OR (@current_status!= @status) ) BEGIN
INSERT INTO  term_history SELECT *, changed_column =  CASE 
 WHEN (@current_misc!=@miscellaneous)  THEN 'Miscellaneous'
WHEN (@current_status!= @status)  THEN 'Status'
WHEN (@current_status!= @status)  AND  (@current_misc!=@miscellaneous) THEN 'Misc. and Status'
  END
 FROM inserted
 INSERT INTO [realtime].[dbo].[term] SELECT * FROM  inserted
END
 
 END
 
 
CREATE TRIGGER  [dbo].[trg_misc_status_term_2] ON [dbo].[term]
INSTEAD OF update 
AS BEGIN 

DECLARE @miscellaneous VARCHAR(255)
DECLARE @status VARCHAR(255)
DECLARE @id VARCHAR(10)
DECLARE @current_misc VARCHAR(255)
DECLARE @current_status VARCHAR(255)


SELECT @id = id, @miscellaneous=miscellaneous, @status=status FROM  inserted
SELECT   @current_misc=miscellaneous, @current_status =status FROM [realtime].[dbo].[term] (NOLOCK) WHERE id = @id

IF ((@current_misc!=@miscellaneous )  OR (@current_status!= @status) ) BEGIN
INSERT INTO  term_history SELECT *, changed_column =  CASE 
														WHEN (@current_misc!=@miscellaneous)  THEN 'Miscellaneous'
														WHEN (@current_status!= @status)  THEN 'Status'
														WHEN (@current_status!= @status)  AND  (@current_misc!=@miscellaneous) THEN 'Misc. and Status'
													 END
													FROM inserted
 END
 
 UPDATE  term SET   
[short_name] = i.[short_name],
[term_type]  = i.[term_type] ,
[term_active] = i.[term_active],
[support_team] = i.[support_team],
[worst_event_severity] = i.[worst_event_severity],
[card_acceptor]  = i.[card_acceptor] ,
[participant_id]  = i.[participant_id] ,
[pos_geographic_data]  = i.[pos_geographic_data] ,
[sponsor_bank]  = i.[sponsor_bank] ,
[pos_data_code]  = i.[pos_data_code] ,
[serial_nr]  = i.[serial_nr] ,
[date_deployed]  = i.[date_deployed] ,
[last_message_type]  = i.[last_message_type] ,
[last_message_time] = i.[last_message_time],
[status] = i.[status],
[hardware_config] = i.[hardware_config],
[value_bars]  = i.[value_bars] ,
[miscellaneous] = i.[miscellaneous],
[security_team]  = i.[security_team] ,
[media_team]  = i.[media_team] ,
[supplies_team]  = i.[supplies_team] ,
[term_mode] = i.[term_mode],
[last_tran_msg_time]  = i.[last_tran_msg_time] 
FROM  
term t JOIN inserted i
on t.id = i.id

END

 
CREATE TRIGGER  [dbo].[trg_misc_status_term_3] ON [dbo].[term]
AFTER DELETE
AS BEGIN 

DECLARE @miscellaneous VARCHAR(255)
DECLARE @status VARCHAR(255)
DECLARE @id VARCHAR(10)
DECLARE @current_misc VARCHAR(255)
DECLARE @current_status VARCHAR(255)

INSERT INTO  term_history SELECT *, changed_column = 'Misc. and Status' FROM deleted

END