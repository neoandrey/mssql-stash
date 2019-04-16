USE [vtucare]
GO

/****** Object:  Table [dbo].[tbl_transactions_temp]    Script Date: 2/27/2017 2:56:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_transactions_temp](
	[transaction_id] [int] IDENTITY(1,1) NOT NULL,
	[tran_seq_id] [int] NULL,
	[account_id] [int] NULL,
	[dealer_id] [int] NULL,
	[telco_domain_id] [int] NULL,
	[issuer_domain_id] [int] NULL,
	[pan] [char](19) NULL,
	[terminal_id] [varchar](32) NULL,
	[stan] [char](6) NULL,
	[acquirer_id] [char](10) NULL,
	[merchant_id] [varchar](50) NULL,
	[location] [varchar](128) NULL,
	[network_id] [char](10) NULL,
	[message_type] [varchar](50) NULL,
	[txn_value] [decimal](14, 2) NULL,
	[postilion_ref_id] [char](12) NULL,
	[dealer_msisdn] [char](24) NULL,
	[subscriber_msisdn] [char](24) NULL,
	[req_datetime] [datetime] NULL,
	[res_datetime] [datetime] NULL,
	[account_balance] [numeric](12, 2) NULL,
	[transaction_type] [varchar](12) NULL,
	[tarrif_type_id] [char](10) NULL,
	[service_provider_id] [char](10) NULL,
	[host_sequence_nr] [varchar](36) NULL,
	[postilion_response_code] [char](10) NULL,
	[postilion_response_message] [varchar](1024) NULL,
	[vtu_reference_id] [char](15) NULL,
	[vtu_response_code] [char](10) NULL,
	[vtu_response_message] [varchar](1024) NULL,
	[status_id] [char](16) NULL,
	[product_item_id] [int] NULL
) ON [PRIMARY]
SET ANSI_PADDING OFF
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [exception_message] [varchar](1024) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [product_code] [varchar](16) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [payee_info] [varchar](25) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [payment_reference] [varchar](75) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [local_tran_datetime] [datetime] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [with_notification] [bit] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [notification_response_code] [varchar](6) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [notification_response_msg] [varchar](128) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [notification_response_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [notification_product_code] [varchar](32) NULL
SET ANSI_PADDING ON
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [e_product_data] [varchar](300) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [batch_msisdn_id] [int] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [settlement_status] [int] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [reverse] [int] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [encrypted_pan] [varchar](256) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [updated_by] [varchar](32) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [comments] [varchar](128) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [nr_retries] [int] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [alt_ref] [varchar](32) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [customer_account_no] [varchar](32) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [terminal_owner_domain_id] [int] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [settlement_date] [datetime] NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [system_settlement_enabled] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [card_association_id] [int] NULL DEFAULT ((0))
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [prev_postilion_response_code] [char](8) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [prev_postilion_response_message] [varchar](1024) NULL
ALTER TABLE [dbo].[tbl_transactions_temp] ADD [e_product_data_info] [varchar](1024) NULL
 CONSTRAINT [pk_transactions_temp_id] PRIMARY KEY CLUSTERED 
(
	[transaction_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


