USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran_leg_internal]    Script Date: 8/25/2016 12:39:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

DROP PARTITION SCHEME  quarterly_partition_scheme
DROP PARTITION FUNCTION partition_by_quarter 

CREATE PARTITION FUNCTION partition_by_quarter (DATETIME)  AS  RANGE LEFT FOR VALUES 
  (  
  '20160930 23:59:59.999',
  '20161231 23:59:59.999'
  )



CREATE PARTITION SCHEME quarterly_partition_scheme AS PARTITION
	partition_by_quarter TO
	(
	[Q3]
,[Q4]
, 
  [SECONDARY] 
	)

CREATE TABLE [dbo].[post_tran_leg_internal](
	[post_tran_id] [bigint] NOT NULL,
	[post_tran_cust_id] [bigint] NOT NULL,
	[settle_entity_id] [int] NULL,
	[batch_nr] [int] NULL,
	[prev_post_tran_id_fast] [bigint] NULL,
	[next_post_tran_id_fast] [bigint] NULL,
	[sink_node_name] [varchar](30) NULL,
	[tran_postilion_originated] [numeric](1, 0) NOT NULL,
	[message_type] [char](4) NOT NULL,
	[tran_type] [char](2) NULL,
	[tran_nr] [bigint] NOT NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[rsp_code_req] [char](2) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[abort_rsp_code] [char](2) NULL,
	[auth_id_rsp] [varchar](10) NULL,
	[auth_type] [char](1) NULL,
	[auth_reason_char] [char](1) NULL,
	[retention_data] [varchar](max) NULL,
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
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[tran_cash_req] [numeric](16, 0) NULL,
	[tran_cash_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [char](3) NULL,
	[tran_tran_fee_req] [numeric](16, 0) NULL,
	[tran_tran_fee_rsp] [numeric](16, 0) NULL,
	[tran_tran_fee_currency_code] [char](3) NULL,
	[tran_proc_fee_req] [numeric](16, 0) NULL,
	[tran_proc_fee_rsp] [numeric](16, 0) NULL,
	[tran_proc_fee_currency_code] [char](3) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_cash_req] [numeric](16, 0) NULL,
	[settle_cash_rsp] [numeric](16, 0) NULL,
	[settle_tran_fee_req] [numeric](16, 0) NULL,
	[settle_tran_fee_rsp] [numeric](16, 0) NULL,
	[settle_proc_fee_req] [numeric](16, 0) NULL,
	[settle_proc_fee_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [char](3) NULL,
	[icc_data_req] [varchar](max) NULL,
	[icc_data_rsp] [varchar](max) NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[structured_data_req] [varchar](max) NULL,
	[structured_data_rsp] [varchar](max) NULL,
	[tran_reversed] [char](1) NOT NULL,
	[prev_tran_approved] [numeric](1, 0) NOT NULL,
	[issuer_network_id] [varchar](11) NULL,
	[acquirer_network_id] [varchar](11) NULL,
	[extended_tran_type] [char](4) NULL,
	[ucaf_data] [varchar](33) NULL,
	[from_account_type_qualifier] [char](1) NULL,
	[to_account_type_qualifier] [char](1) NULL,
	[bank_details] [varchar](31) NULL,
	[payee] [char](25) NULL,
	[card_verification_result] [char](1) NULL,
	[online_system_id] [int] NOT NULL,
	[participant_id] [int] NULL,
	[opp_participant_id] [int] NULL,
	[receiving_inst_id_code] [varchar](11) NULL,
	[routing_type] [char](1) NULL,
	[source_node_key] [varchar](32) NULL,
	[proc_online_system_id] [int] NOT NULL,
	[pos_geographic_data] [char](17) NULL,
	[payer_account_id] [varchar](28) NULL,
	[cvv_available_at_auth] [char](1) NULL,
	[cvv2_available_at_auth] [char](1) NULL,
	[network_program_id_actual] [varchar](8) NULL,
	[network_program_id_min] [varchar](8) NULL,
	[network_fee_actual] [numeric](16, 4) NULL,
	[network_fee_min] [numeric](16, 4) NULL,
	[network_fee_max] [numeric](16, 4) NULL,
	[credit_debit_conversion] [tinyint] NULL,
	[tran_nr_prev] [bigint] NULL,
	[source_node_name] [varchar](30) NOT NULL,
	[draft_capture] [int] NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[service_restriction_code] [char](3) NULL,
	[terminal_id] [char](8) NULL,
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
	[mapped_terminal_id] [char](8) NULL,
	[mapped_extd_ca_term_id] [varchar](25) NULL,
	[mapped_extd_ca_id_code] [varchar](25) NULL,
	[ion_orig_post_tran_id] [bigint] NULL,
	[ion_orig_post_tran_cust_id] [bigint] NULL,
 CONSTRAINT [pk_post_tran_a] PRIMARY KEY CLUSTERED 
(
	recon_business_date ASC
	, [post_tran_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
) ON [quarterly_partition_scheme](recon_business_date)  
GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[post_tran_leg_internal] ADD  DEFAULT ('0') FOR [tran_reversed]
GO

ALTER TABLE [dbo].[post_tran_leg_internal] ADD  DEFAULT ((0)) FOR [prev_tran_approved]
GO

ALTER TABLE [dbo].[post_tran_leg_internal] ADD  DEFAULT ((0)) FOR [draft_capture]
GO

ALTER TABLE [dbo].[post_tran_leg_internal]  WITH CHECK ADD  CONSTRAINT [fk_post_tran_2a] FOREIGN KEY([settle_entity_id], [batch_nr])
REFERENCES [dbo].[post_batch] ([settle_entity_id], [batch_nr])
GO

ALTER TABLE [dbo].[post_tran_leg_internal] CHECK CONSTRAINT [fk_post_tran_2a]
GO

ALTER TABLE [dbo].[post_tran_leg_internal]  WITH CHECK ADD  CONSTRAINT [ck_post_tran_leg_1a] CHECK  (([next_post_tran_id_fast]>(0) OR [next_post_tran_id_fast] IS NULL))
GO

ALTER TABLE [dbo].[post_tran_leg_internal] CHECK CONSTRAINT [ck_post_tran_leg_1a]
GO

ALTER TABLE [dbo].[post_tran_leg_internal]  WITH CHECK ADD  CONSTRAINT [ck_post_tran_leg_2a] CHECK  (([prev_post_tran_id_fast]>(0) OR [prev_post_tran_id_fast] IS NULL))
GO

ALTER TABLE [dbo].[post_tran_leg_internal] CHECK CONSTRAINT [ck_post_tran_leg_2a]
GO


sp_help [post_tran_leg_internal]

ALTER TABLE [dbo].[extract_tran]  WITH CHECK ADD  CONSTRAINT [fk_extract_tran_3] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal] ([post_tran_id])


ALTER TABLE [dbo].[recon_match_equal]  WITH CHECK ADD  CONSTRAINT [fk_recon_match_equal_2] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal] ([post_tran_id])


ALTER TABLE [dbo].[recon_match_equal]  WITH CHECK ADD  CONSTRAINT [fk_recon_match_equal_2] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal_old] ([post_tran_id])
GO

ALTER TABLE [dbo].[recon_post_only]  WITH CHECK ADD  CONSTRAINT [fk_recon_post_only_3] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal_old] ([post_tran_id])
GO
