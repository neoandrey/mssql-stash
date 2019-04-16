USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran]    Script Date: 05/16/2016 12:32:39 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[post_tran_summary](
	[post_tran_id] [bigint] NOT NULL,
	[post_tran_cust_id] [bigint] NOT NULL,
	[settle_entity_id] [dbo].[POST_ID] NULL,
	[batch_nr] [int] NULL,
	[prev_post_tran_id] [bigint] NULL,
	[next_post_tran_id] [bigint] NULL,
	[sink_node_name] [dbo].[POST_NAME] NULL,
	[tran_postilion_originated] [dbo].[POST_BOOL] NOT NULL,
	[tran_completed] [dbo].[POST_BOOL] NOT NULL,
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
	[tran_amount_req] [dbo].[POST_MONEY] NULL,
	[tran_amount_rsp] [dbo].[POST_MONEY] NULL,
	[settle_amount_impact] [dbo].[POST_MONEY] NULL,
	[tran_cash_req] [dbo].[POST_MONEY] NULL,
	[tran_cash_rsp] [dbo].[POST_MONEY] NULL,
	[tran_currency_code] [dbo].[POST_CURRENCY] NULL,
	[tran_tran_fee_req] [dbo].[POST_MONEY] NULL,
	[tran_tran_fee_rsp] [dbo].[POST_MONEY] NULL,
	[tran_tran_fee_currency_code] [dbo].[POST_CURRENCY] NULL,
	[tran_proc_fee_req] [dbo].[POST_MONEY] NULL,
	[tran_proc_fee_rsp] [dbo].[POST_MONEY] NULL,
	[tran_proc_fee_currency_code] [dbo].[POST_CURRENCY] NULL,
	[settle_amount_req] [dbo].[POST_MONEY] NULL,
	[settle_amount_rsp] [dbo].[POST_MONEY] NULL,
	[settle_cash_req] [dbo].[POST_MONEY] NULL,
	[settle_cash_rsp] [dbo].[POST_MONEY] NULL,
	[settle_tran_fee_req] [dbo].[POST_MONEY] NULL,
	[settle_tran_fee_rsp] [dbo].[POST_MONEY] NULL,
	[settle_proc_fee_req] [dbo].[POST_MONEY] NULL,
	[settle_proc_fee_rsp] [dbo].[POST_MONEY] NULL,
	[settle_currency_code] [dbo].[POST_CURRENCY] NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[tran_reversed] [char](1) NULL,
	[prev_tran_approved] [dbo].[POST_BOOL] NULL,
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
	[opp_participant_id] [int] NULL,
	[receiving_inst_id_code] [varchar](11) NULL,
	[routing_type] [int] NULL,
	[pt_pos_operating_environment] [char](1) NULL,
	[pt_pos_card_input_mode] [char](1) NULL,
	[pt_pos_cardholder_auth_method] [char](1) NULL,
	[pt_pos_pin_capture_ability] [char](1) NULL,
	[pt_pos_terminal_operator] [char](1) NULL,
	[source_node_key] [varchar](32) NULL,
	[proc_online_system_id] [int] NULL,
	[from_account_id_cs] [int] NULL,
	[to_account_id_cs] [int] NULL,
	[pos_geographic_data] [char](17) NULL,
	[payer_account_id] [varchar](28) NULL,
	[cvv_available_at_auth] [char](1) NULL,
	[cvv2_available_at_auth] [char](1) NULL,
	[mapped_terminal_id] [char](8) NULL,
	[mapped_extd_ca_term_id] [varchar](25) NULL,
	[mapped_extd_ca_id_code] [varchar](25) NULL,
	[network_program_id_actual] [varchar](8) NULL,
	[network_program_id_min] [varchar](8) NULL,
	[network_fee_actual] [numeric](16, 4) NULL,
	[network_fee_min] [numeric](16, 4) NULL,
	[network_fee_max] [numeric](16, 4) NULL,
	[credit_debit_conversion] [tinyint] NULL,
	[secure_3d_result] [char](1) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

--ALTER TABLE [dbo].[post_tran]  WITH CHECK ADD  CONSTRAINT [fk_post_tran_1] FOREIGN KEY([post_tran_cust_id])
--REFERENCES [dbo].[post_tran_cust] ([post_tran_cust_id])
--GO

ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_1]
GO

ALTER TABLE [dbo].[post_tran]  WITH CHECK ADD  CONSTRAINT [fk_post_tran_2] FOREIGN KEY([settle_entity_id], [batch_nr])
REFERENCES [dbo].[post_batch] ([settle_entity_id], [batch_nr])
GO

ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_2]
GO

ALTER TABLE [dbo].[post_tran] ADD  DEFAULT ((0)) FOR [next_post_tran_id]
GO

ALTER TABLE [dbo].[post_tran] ADD  DEFAULT ((0)) FOR [tran_reversed]
GO


