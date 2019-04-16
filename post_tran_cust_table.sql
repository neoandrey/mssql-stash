USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_cust_1]    Script Date: 08/24/2017 11:49:18 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_1] ON [dbo].[post_tran_cust] 
(
	[pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO


USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_cust_2]    Script Date: 08/24/2017 11:49:24 ******/
USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran_cust]    Script Date: 08/24/2017 11:51:33 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[post_tran_cust](
	[post_tran_cust_id] [bigint] NOT NULL,
	[source_node_name] [dbo].[POST_NAME] NOT NULL,
	[draft_capture] [dbo].[POST_ID] NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[service_restriction_code] [char](3) NULL,
	[terminal_id] [dbo].[POST_TERMINAL_ID] NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[mapped_card_acceptor_id_code] [char](15) NULL,
	[merchant_type] [char](4) NULL,
	[card_acceptor_name_loc] [char](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [char](1) NULL,
	[check_data] [varchar](70) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [char](1) NULL,
	[pos_cardholder_auth_ability] [char](1) NULL,
	[pos_card_capture_ability] [char](1) NULL,
	[pos_operating_environment] [char](1) NULL,
	[pos_cardholder_present] [char](1) NULL,
	[pos_card_present] [char](1) NULL,
	[pos_card_data_input_mode] [char](1) NULL,
	[pos_cardholder_auth_method] [char](1) NULL,
	[pos_cardholder_auth_entity] [char](1) NULL,
	[pos_card_data_output_ability] [char](1) NULL,
	[pos_terminal_output_ability] [char](1) NULL,
	[pos_pin_capture_ability] [char](1) NULL,
	[pos_terminal_operator] [char](1) NULL,
	[pos_terminal_type] [char](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [char](18) NULL,
	[pan_reference] [char](42) NULL,
	[card_acceptor_id_code_cs] [int] NULL,
 CONSTRAINT [pk_post_tran_cust] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[post_tran_cust] ADD  DEFAULT ((0)) FOR [draft_capture]
GO




CREATE NONCLUSTERED INDEX [ix_post_tran_cust_2] ON [dbo].[post_tran_cust] 
(
	[terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO


USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_cust_4]    Script Date: 08/24/2017 11:49:31 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_4] ON [dbo].[post_tran_cust] 
(
	[pan_reference] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO


USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_cust_5]    Script Date: 08/24/2017 11:49:42 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_5] ON [dbo].[post_tran_cust] 
(
	[card_acceptor_id_code_cs] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [PRIMARY]
GO


DECLARE @retention_period INT = 7
DECLARE @running_date  DATETIME
DECLARE @final_date  DATETIME

set transaction isolation level read uncommitted

SET   @final_date    =GETDATE()
SET @running_date   =  CONVERT( DATE, DATEADD(D, -1 * @retention_period , @final_date    ))

WHILE  ( @running_date  <=@final_date    ) BEGIN
SELECT * FROM post_tran_cust_original WITH (NOLOCK, index=pk_post_tran_cust_orig) where post_tran_cust_id  IN (
select post_tran_cust_id from POST_TRAN_ORIGINAL WITH (NOLOCK, INDEX= IX_POST_TRAN_9) WHERE 
recon_business_date  = @running_date  
)
 SET @running_date   =  CONVERT (DATE,  DATEADD(D, 1, @running_date   ))

END
