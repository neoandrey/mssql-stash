USE [postilion_office]
GO
GO
USE [master]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [APR]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_apr', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_apr.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [APR]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [AUG]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_aug', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_aug.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [AUG]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [DEC]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_dec', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_dec.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [DEC]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [FEB]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_feb', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_feb.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [FEB]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [JAN]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_jan', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_jan.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [JAN]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [JUL]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_july', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_july.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [JUL]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [JUN]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_june', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_june.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [JUN]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [MAR]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_mar', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_mar.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [MAR]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [MAY]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_may', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_may.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [MAY]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [NOV]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_nov', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_nov.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [NOV]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_oct', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_oct.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [PRIMARY]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [SEP]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_sep', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_sep.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [SEP]
GO
ALTER DATABASE [postilion_office] ADD FILEGROUP [OCT]
GO
ALTER DATABASE [postilion_office] ADD FILE ( NAME = N'post_office_db_oct', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\post_office_db_sep.ndf' , SIZE = 3072KB , FILEGROWTH = 1024KB ) TO FILEGROUP [OCT]
GO

USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[get_latest_tran_date]    Script Date: 01/23/2015 09:54:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[get_latest_tran_date]() RETURNS DATETIME AS
BEGIN
DECLARE @latest_datetime DATETIME;
 SET  @latest_datetime =(SELECT TOP 1 datetime_req FROM post_tran (NOLOCK) ORDER BY datetime_req DESC)
 SET @latest_datetime = ISNULL(@latest_datetime,GETDATE());
RETURN @latest_datetime;
END


ALTER TABLE dbo.post_tran_cust ADD datetime_req  DATETIME DEFAULT dbo.get_latest_tran_date();

CREATE PARTITION FUNCTION partition_by_month (DATETIME)  AS
  RANGE LEFT FOR VALUES 
  (  
  '20150131 23:59:59.997',
  '20150228 23:59:59.997',
  '20150331 23:59:59.997',
  '20150430 23:59:59.997',
  '20150531 23:59:59.997',
  '20150630 23:59:59.997',
  '20150731 23:59:59.997',
  '20150831 23:59:59.997',
  '20150930 23:59:59.997',
  '20151031 23:59:59.997',
  '20151130 23:59:59.997',
  '20151231 23:59:59.997'  
  )

CREATE PARTITION SCHEME MontlyPartitionScheme AS PARTITION
	partition_by_month TO
	(
	[JAN], 
	[FEB],
	[MAR],
	[APR],
	[MAY],
        [JUN],
	[JUL],
	[AUG],
	[SEP],
	[OCT],
	[NOV],
	[DEC]
	)
	
	
	
	
	USE [postilion_office]
	GO
	/****** Object:  Index [ix_post_tran_1]    Script Date: 09/25/2014 14:41:12 ******/
	CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_1] ON [dbo].[post_tran] 
	(
		[post_tran_id] ASC,
         datetime_req asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)

USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_10]    Script Date: 09/25/2014 14:42:27 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_10] ON [dbo].[post_tran] 
(
	[settle_entity_id] ASC,
	[batch_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)


USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_2]    Script Date: 09/25/2014 14:42:44 ******/
CREATE CLUSTERED INDEX [ix_post_tran_2] ON [dbo].[post_tran] 
(
	[post_tran_cust_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)



USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_3]    Script Date: 09/25/2014 14:43:05 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_3] ON [dbo].[post_tran] 
(
	[tran_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)


USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_4]    Script Date: 09/25/2014 14:53:36 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_4] ON [dbo].[post_tran] 
(
	[datetime_tran_local] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)

USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_5]    Script Date: 09/25/2014 14:54:30 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_5] ON [dbo].[post_tran] 
(
	[system_trace_audit_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)

USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_7]    Script Date: 09/25/2014 14:56:28 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_7] ON [dbo].[post_tran] 
(
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)


USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_8]    Script Date: 09/25/2014 14:56:50 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_8] ON [dbo].[post_tran] 
(
	[tran_nr] ASC,
	[message_type] ASC,
	[tran_postilion_originated] ASC,
	[online_system_id] ASC,
    [datetime_req]
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)



USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_9]    Script Date: 09/25/2014 14:57:10 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_9] ON [dbo].[post_tran] 
(
	[recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)

/****** Object:  Index [ix_post_tran_7]    Script Date: 09/25/2014 14:56:28 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_10] ON [dbo].[post_tran] 
(
	[from_account_id] ASC,
    [to_account_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)

/****** Object:  Index [ix_post_tran_7]    Script Date: 09/25/2014 14:56:28 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_11] ON [dbo].[post_tran] 
(
	[retrieval_reference_nr] ASC,
[system_trace_audit_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)


sp_rename 'post_tran', 'post_tran_old'

USE [postilion_office]
GO
/****** Object:  Table [dbo].[post_tran]    Script Date: 09/25/2014 15:09:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[post_tran](
		[post_tran_id] [bigint] NOT NULL,
		[post_tran_cust_id] [bigint] NOT NULL,
		[settle_entity_id] [POST_ID] NULL,
		[batch_nr] [int] NULL,
		[prev_post_tran_id] [bigint] NULL,
		[next_post_tran_id] [bigint] NULL,
		[sink_node_name] [POST_NAME] NULL,
		[tran_postilion_originated] [POST_BOOL] NOT NULL,
		[tran_completed] [POST_BOOL] NOT NULL,
		[message_type] [char](4) NOT NULL,
		[tran_type] [char](2) NULL,
		[tran_nr] [bigint] NOT NULL,
		[system_trace_audit_nr] [char](6) NULL,
		[rsp_code_req] [char](2) NULL,
		[rsp_code_rsp] [char](2) NULL,
		[abort_rsp_code] [char](2) NULL,
		[auth_id_rsp] [varchar](10) NULL,
		[auth_type] [numeric](1, 0) NULL,
		[auth_reason] [numeric](1, 0) NULL,
		[retention_data] [varchar](999) NULL,
		[acquiring_inst_id_code] [varchar](11) NULL,
		[message_reason_code] [char](4) NULL,
		[sponsor_bank] [char](8) NULL,
		[retrieval_reference_nr] [char](12) NULL,
		[datetime_tran_gmt] [datetime] NULL,
		[datetime_tran_local] [datetime] NOT NULL,
		[datetime_req] [datetime] NOT NULL,
		[datetime_rsp] [datetime] NULL,
		[realtime_business_date] [datetime] NOT NULL,
		[recon_business_date] [datetime] NOT NULL,
		[from_account_type] [char](2) NULL,
		[to_account_type] [char](2) NULL,
		[from_account_id] [varchar](28) NULL,
		[to_account_id] [varchar](28) NULL,
		[tran_amount_req] [POST_MONEY] NULL,
		[tran_amount_rsp] [POST_MONEY] NULL,
		[settle_amount_impact] [POST_MONEY] NULL,
		[tran_cash_req] [POST_MONEY] NULL,
		[tran_cash_rsp] [POST_MONEY] NULL,
		[tran_currency_code] [POST_CURRENCY] NULL,
		[tran_tran_fee_req] [POST_MONEY] NULL,
		[tran_tran_fee_rsp] [POST_MONEY] NULL,
		[tran_tran_fee_currency_code] [POST_CURRENCY] NULL,
		[tran_proc_fee_req] [POST_MONEY] NULL,
		[tran_proc_fee_rsp] [POST_MONEY] NULL,
		[tran_proc_fee_currency_code] [POST_CURRENCY] NULL,
		[settle_amount_req] [POST_MONEY] NULL,
		[settle_amount_rsp] [POST_MONEY] NULL,
		[settle_cash_req] [POST_MONEY] NULL,
		[settle_cash_rsp] [POST_MONEY] NULL,
		[settle_tran_fee_req] [POST_MONEY] NULL,
		[settle_tran_fee_rsp] [POST_MONEY] NULL,
		[settle_proc_fee_req] [POST_MONEY] NULL,
		[settle_proc_fee_rsp] [POST_MONEY] NULL,
		[settle_currency_code] [POST_CURRENCY] NULL,
		[icc_data_req] [text] NULL,
		[icc_data_rsp] [text] NULL,
		[pos_entry_mode] [char](3) NULL,
		[pos_condition_code] [char](2) NULL,
		[additional_rsp_data] [varchar](25) NULL,
		[structured_data_req] [text] NULL,
		[structured_data_rsp] [text] NULL,
		[tran_reversed] [char](1) NULL,
		[prev_tran_approved] [POST_BOOL] NULL,
		[issuer_network_id] [varchar](11) NULL,
		[acquirer_network_id] [varchar](11) NULL,
		[extended_tran_type] [char](4) NULL,
		[ucaf_data] [varchar](33) NULL,
		[from_account_type_qualifier] [char](1) NULL,
		[to_account_type_qualifier] [char](1) NULL,
		[bank_details] [varchar](31) NULL,
		[payee] [char](25) NULL,
		[card_verification_result] [char](1) NULL,
		[online_system_id] [int] NULL,
		[participant_id] [int] NULL,
		[receiving_inst_id_code] [varchar](11) NULL,
		[routing_type] [int] NULL,
		[pt_pos_operating_environment] [char](1) NULL,
		[pt_pos_card_input_mode] [char](1) NULL,
		[pt_pos_cardholder_auth_method] [char](1) NULL,
		[pt_pos_pin_capture_ability] [char](1) NULL,
		[pt_pos_terminal_operator] [char](1) NULL,
		[source_node_key] [varchar](32) NULL,
		[proc_online_system_id] [int] NULL,
		[opp_participant_id] [int] NULL,
		[pos_geographic_data] [char](17) NULL,
	[payer_account_id] [varchar](28) NULL
) ON [MontlyPartitionScheme](datetime_req)
 TEXTIMAGE_ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[post_tran]  WITH CHECK ADD  CONSTRAINT [fk_post_tran_1] FOREIGN KEY([post_tran_cust_id])
REFERENCES [dbo].[post_tran_cust] ([post_tran_cust_id])
GO
ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_1]
GO
ALTER TABLE [dbo].[post_tran]  WITH CHECK ADD  CONSTRAINT [fk_post_tran_2] FOREIGN KEY([settle_entity_id], [batch_nr])
REFERENCES [dbo].[post_batch] ([settle_entity_id], [batch_nr])
GO
ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_2]

USE [postilion_office]
GO
ALTER TABLE [dbo].[post_tran] ADD  DEFAULT ((0)) FOR [next_post_tran_id]

USE [postilion_office]
GO
ALTER TABLE [dbo].[post_tran] ADD  DEFAULT ((0)) FOR [tran_reversed]



ALTER TABLE dbo.extract_tran ADD datetime_req  DATETIME DEFAULT dbo.get_latest_tran_date();



USE [postilion_office]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_extract_tran_3]') AND parent_object_id = OBJECT_ID(N'[dbo].[extract_tran]'))
ALTER TABLE [dbo].[extract_tran] DROP CONSTRAINT [fk_extract_tran_3]

USE [postilion_office]
GO
ALTER TABLE [dbo].[extract_tran]  WITH CHECK ADD  CONSTRAINT [fk_extract_tran_3] FOREIGN KEY([post_tran_id],[DATETIME_REQ])
REFERENCES [dbo].[post_tran] ([post_tran_id], [DATETIME_REQ])
GO
ALTER TABLE [dbo].[extract_tran] CHECK CONSTRAINT [fk_extract_tran_3]



ALTER TABLE dbo.[recon_match_equal] ADD datetime_req  DATETIME DEFAULT dbo.get_latest_tran_date();

USE [postilion_office]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_recon_match_equal_2]') AND parent_object_id = OBJECT_ID(N'[dbo].[recon_match_equal]'))
ALTER TABLE [dbo].[recon_match_equal] DROP CONSTRAINT [fk_recon_match_equal_2]

USE [postilion_office]
GO
ALTER TABLE [dbo].[recon_match_equal]  WITH CHECK ADD  CONSTRAINT [fk_recon_match_equal_2] FOREIGN KEY([post_tran_id], [datetime_req])
REFERENCES [dbo].[post_tran] ([post_tran_id],datetime_req)
GO
ALTER TABLE [dbo].[recon_match_equal] CHECK CONSTRAINT [fk_recon_match_equal_2]



ALTER TABLE dbo.[recon_match_not_equal] ADD datetime_req  DATETIME DEFAULT dbo.get_latest_tran_date();

USE [postilion_office]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_recon_match_not_equal_2]') AND parent_object_id = OBJECT_ID(N'[dbo].[recon_match_not_equal]'))
ALTER TABLE [dbo].[recon_match_not_equal] DROP CONSTRAINT [fk_recon_match_not_equal_2]


USE [postilion_office]
GO
ALTER TABLE [dbo].[recon_match_not_equal]  WITH CHECK ADD  CONSTRAINT [fk_recon_match_not_equal_2] FOREIGN KEY([post_tran_id], datetime_req)
REFERENCES [dbo].[post_tran] ([post_tran_id], datetime_req)
GO
ALTER TABLE [dbo].[recon_match_not_equal] CHECK CONSTRAINT [fk_recon_match_not_equal_2]

ALTER TABLE dbo.[recon_post_only] ADD datetime_req  DATETIME DEFAULT dbo.get_latest_tran_date();

USE [postilion_office]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_recon_post_only_3]') AND parent_object_id = OBJECT_ID(N'[dbo].[recon_post_only]'))
ALTER TABLE [dbo].[recon_post_only] DROP CONSTRAINT [fk_recon_post_only_3]

USE [postilion_office]
GO
ALTER TABLE [dbo].[recon_post_only]  WITH CHECK ADD  CONSTRAINT [fk_recon_post_only_3] FOREIGN KEY([post_tran_id], datetime_req)
REFERENCES [dbo].[post_tran] ([post_tran_id], datetime_req)
GO
ALTER TABLE [dbo].[recon_post_only] CHECK CONSTRAINT [fk_recon_post_only_3]


USE [postilion_office]
GO
/****** Object:  Table [dbo].[post_tran_cust]    Script Date: 09/25/2014 16:00:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[post_tran_cust](
	[post_tran_cust_id] [bigint] NOT NULL,
	[source_node_name] [dbo].[POST_NAME] NOT NULL,
	[draft_capture] [dbo].[POST_ID] NULL DEFAULT ((0)),
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
	[check_data] [varchar](50) NULL,
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
	[datetime_req] [datetime] NULL DEFAULT ([dbo].[get_latest_tran_date]()),
 CONSTRAINT [pk_post_tran_cust] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id],[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_req)
ON [MontlyPartitionScheme](datetime_req)


GO
SET ANSI_PADDING OFF


exec sp_rename 'post_tran_cust', 'post_tran_cust_old'

USE [postilion_office]
GOCREATE TABLE [dbo].[post_tran_cust](
	[post_tran_cust_id] [bigint] NOT NULL,
	[source_node_name] [dbo].[POST_NAME] NOT NULL,
	[draft_capture] [dbo].[POST_ID] NULL DEFAULT ((0)),
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
	[check_data] [varchar](50) NULL,
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
	[datetime_rqt] [datetime] NOT NULL DEFAULT ([dbo].[get_latest_tran_date]()),
 CONSTRAINT [pk_post_tran_cust_2] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC,
	[datetime_rqt] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme]([datetime_rqt])
)

GO
SET ANSI_PADDING OFF

USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_cust_1]    Script Date: 09/25/2014 16:06:33 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_1] ON [dbo].[post_tran_cust] 
(
	[pan] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_rqt)
USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_cust_2]    Script Date: 09/25/2014 16:07:04 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_2] ON [dbo].[post_tran_cust] 
(
	[terminal_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_rqt)

USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_cust_3]    Script Date: 09/25/2014 16:07:48 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_3] ON [dbo].[post_tran_cust] 
(
	[pan_search] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_rqt)

USE [postilion_office]
GO
/****** Object:  Index [ix_post_tran_cust_4]    Script Date: 09/25/2014 16:08:25 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_4] ON [dbo].[post_tran_cust] 
(
	[pan_reference] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_rqt)

CREATE NONCLUSTERED INDEX [ix_post_tran_cust_5] ON [dbo].[post_tran_cust] 
(
	[card_acceptor_id_code] ASC,
[card_acceptor_name_loc] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_rqt)


CREATE NONCLUSTERED INDEX [ix_post_tran_cust_6] ON [dbo].[post_tran_cust] 
(
	[card_product] ASC,
[totals_group] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_rqt)

USE [postilion_office]
GO
/****** Object:  Index [pk_post_tran_cust]    Script Date: 09/25/2014 16:08:59 ******/
ALTER TABLE [dbo].[post_tran_cust] ADD  CONSTRAINT [pk_post_tran_cust] PRIMARY KEY CLUSTERED 
(
	[post_tran_cust_id] ASC,
	datetime_rqt asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [MontlyPartitionScheme](datetime_rqt)


USE [postilion_office]
GO
ALTER TABLE [dbo].[post_tran_cust] ADD  DEFAULT ([dbo].[get_latest_tran_date]()) FOR [datetime_req]

USE [postilion_office]
GO
ALTER TABLE [dbo].[post_tran_cust] ADD  DEFAULT ((0)) FOR [draft_capture]

#USE [postilion_office]
GO
IF  EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[fk_post_tran_1]') AND parent_object_id = OBJECT_ID(N'[dbo].[post_tran]'))
ALTER TABLE [dbo].[post_tran] DROP CONSTRAINT [fk_post_tran_1]

USE [postilion_office]
GO
ALTER TABLE [dbo].[post_tran]  WITH CHECK ADD  CONSTRAINT [fk_post_tran_1] FOREIGN KEY([post_tran_cust_id], datetime_req)
REFERENCES [dbo].[post_tran_cust] ([post_tran_cust_id],datetime_req)
GO
ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_1]

USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[reconcile_post_tran_cust_datetime]    Script Date: 01/23/2015 14:51:50 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[reconcile_post_tran_cust_datetime]  as
BEGIN

DECLARE @norm_process VARCHAR(30);

SELECT * FROM  post_process_queue  WHERE spawned_name ='PONormaliza.exe';

IF((@norm_process IS NULL) ) BEGIN

	UPDATE  [postilion_office].[dbo].[post_tran_cust] 
	SET 
			 datetime_rqt =trans.datetime_req
	         
	FROM   
			 [postilion_office].[dbo].[post_tran] trans (NOLOCK) ,  [postilion_office].[dbo].[post_tran_cust] cust (NOLOCK)
	WHERE 
			  trans.post_tran_cust_id = cust.post_tran_cust_id  AND cust.datetime_rqt <> trans.datetime_req


END

END


USE [msdb]
GO
/****** Object:  Job [reconcile_post_tran_cust_date]    Script Date: 01/23/2015 11:42:04 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 01/23/2015 11:42:04 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'reconcile_post_tran_cust_date', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DBPART\Administrator', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [recon_step]    Script Date: 01/23/2015 11:42:05 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'recon_step', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec reconcile_post_tran_cust_datetime;', 
		@database_name=N'postilion_office', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'2_mins_schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=2, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150123, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
USE [postilion_office]
GO
/****** Object:  UserDefinedFunction [dbo].[get_latest_tran_date]    Script Date: 01/23/2015 14:50:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[get_latest_tran_date]() RETURNS DATETIME AS
BEGIN
DECLARE @latest_datetime DATETIME;
 SET  @latest_datetime =(SELECT TOP 1 datetime_req FROM post_tran (NOLOCK) ORDER BY datetime_req DESC)
 SET @latest_datetime = ISNULL(@latest_datetime,GETDATE());
RETURN @latest_datetime;
END

datetime_req on post_tran_cust had to be renamed to datetime_rqt to avoid breaking existing queries

remove fk_post_tran_1 as it requires  the datetime_rqt column to be included in the foreign_key definition 

The script for renaming any column :
sp_RENAME 'TableName.[OldColumnName]' , '[NewColumnName]', 'COLUMN'

The script for renaming any object (table, sp etc) :
sp_RENAME '[OldTableName]' , '[NewTableName]'


The following example assumes the partition scheme MyRangePS1 and the filegroup test5fg exist in the current database.
ALTER PARTITION SCHEME MyRangePS1
NEXT USED test5fg;

