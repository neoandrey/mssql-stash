USE [postilion_office]
GO

/****** Object:  Table [dbo].[Late_Reversal_log]    Script Date: 02/19/2016 16:18:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[Late_Reversal_log](
	[stan] [char](6) NOT NULL,
	[rrn] [char](12) NOT NULL,
	[pan] [varchar](19) NOT NULL,
	[tran_type] [char](2) NOT NULL,
	[tran_currency] [char](3) NOT NULL,
	[tran_amount] [char](12) NOT NULL,
	[terminal_id] [char](8) NOT NULL,
	[source_node] [char](12) NOT NULL,
	[tran_number] [varchar](32) NOT NULL,
	[transmission_date_time] [char](10) NOT NULL,
	[original_data_elements] [char](42) NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


CREATE NONCLUSTERED INDEX  ix_stan ON [Late_Reversal_log] (
stan

)

CREATE  NONCLUSTERED INDEX  ix_rrn ON [Late_Reversal_log] (
rrn

)

CREATE  NONCLUSTERED INDEX  ix_pan ON [Late_Reversal_log] (
pan

)

CREATE  NONCLUSTERED INDEX  ix_tran_type ON [Late_Reversal_log] (
tran_type

)


CREATE  NONCLUSTERED INDEX  ix_tran_currency ON [Late_Reversal_log] (
[tran_currency]

)


CREATE  NONCLUSTERED INDEX  ix_tran_amount ON [Late_Reversal_log] (
[tran_amount]

)

CREATE  NONCLUSTERED INDEX  ix_terminal_id ON [Late_Reversal_log] (
[terminal_id]

)


CREATE  NONCLUSTERED INDEX  ix_source_node ON [Late_Reversal_log] (
[source_node]

)


CREATE  NONCLUSTERED INDEX  ix_tran_number ON [Late_Reversal_log] (
[tran_number]

)

CREATE  NONCLUSTERED INDEX  ix_transmission_date_time ON [Late_Reversal_log] (
[transmission_date_time]

)