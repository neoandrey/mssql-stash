USE [postilion_office]
GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__transacti__next___173876EA]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[post_tran_report_data] DROP CONSTRAINT [DF__transacti__next___173876EA]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__transacti__tran___182C9B23]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[post_tran_report_data] DROP CONSTRAINT [DF__transacti__tran___182C9B23]
END

GO

IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__transacti__draft__1920BF5C]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[post_tran_report_data] DROP CONSTRAINT [DF__transacti__draft__1920BF5C]
END

GO

USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran_report_data]    Script Date: 12/07/2015 16:47:11 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[post_tran_report_data]') AND type in (N'U'))
DROP TABLE [dbo].[post_tran_report_data]
GO

USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran_report_data]    Script Date: 12/07/2015 16:47:11 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[post_tran_report_data](
	[post_tran_id] [bigint] NOT NULL,
	[post_tran_cust_id] [bigint] NOT NULL,
	[settle_entity_id] [varchar](1000) NULL,
	[batch_nr] [int] NULL,
	[prev_post_tran_id] [bigint] NULL,
	[next_post_tran_id] [bigint] NULL,
	[sink_node_name] [varchar](1000) NULL,
	[tran_postilion_originated] [bigint] NOT NULL,
	[tran_completed] [bigint] NOT NULL,
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
	[tran_amount_req] [decimal](25, 2) NULL,
	[tran_amount_rsp] [decimal](25, 2) NULL,
	[settle_amount_impact] [decimal](25, 2) NULL,
	[tran_cash_req] [decimal](25, 2) NULL,
	[tran_cash_rsp] [decimal](25, 2) NULL,
	[tran_currency_code] [varchar](80) NULL,
	[tran_tran_fee_req] [decimal](25, 2) NULL,
	[tran_tran_fee_rsp] [decimal](25, 2) NULL,
	[tran_tran_fee_currency_code] [varchar](80) NULL,
	[tran_proc_fee_req] [decimal](25, 2) NULL,
	[tran_proc_fee_rsp] [decimal](25, 2) NULL,
	[tran_proc_fee_currency_code] [varchar](80) NULL,
	[settle_amount_req] [decimal](25, 2) NULL,
	[settle_amount_rsp] [decimal](25, 2) NULL,
	[settle_cash_req] [decimal](25, 2) NULL,
	[settle_cash_rsp] [decimal](25, 2) NULL,
	[settle_tran_fee_req] [decimal](25, 2) NULL,
	[settle_tran_fee_rsp] [decimal](25, 2) NULL,
	[settle_proc_fee_req] [decimal](25, 2) NULL,
	[settle_proc_fee_rsp] [decimal](25, 2) NULL,
	[settle_currency_code] [varchar](80) NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[structured_data_req] [text] NULL,
	[tran_reversed] [char](1) NULL,
	[prev_tran_approved] [bigint] NULL,
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
	[source_node_name] [varchar](1000) NOT NULL,
	[draft_capture] [varchar](1000) NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[service_restriction_code] [char](3) NULL,
	[terminal_id] [varchar](255) NULL,
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
	[pan_reference] [varchar](1000) NULL,
 CONSTRAINT [pk_joined_trans_table] PRIMARY KEY CLUSTERED 
(
	[post_tran_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [SECONDARY],
 CONSTRAINT [online_system_constraint] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[tran_postilion_originated] ASC,
	[message_type] asc
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [SECONDARY]
) ON [SECONDARY] TEXTIMAGE_ON [SECONDARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[post_tran_report_data] ADD  CONSTRAINT [DF__transacti__next___173876EA]  DEFAULT ((0)) FOR [next_post_tran_id]
GO

ALTER TABLE [dbo].[post_tran_report_data] ADD  CONSTRAINT [DF__transacti__tran___182C9B23]  DEFAULT ((0)) FOR [tran_reversed]
GO

ALTER TABLE [dbo].[post_tran_report_data] ADD  CONSTRAINT [DF__transacti__draft__1920BF5C]  DEFAULT ((0)) FOR [draft_capture]
GO


