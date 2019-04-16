USE [postilion_office]
GO

/****** Object:  Table [dbo].[post_tran]    Script Date: 08/24/2017 09:28:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[post_tran](
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
	[icc_data_req] [text] NULL,
	[icc_data_rsp] [text] NULL,
	[pos_entry_mode] [char](3) NULL,
	[pos_condition_code] [char](2) NULL,
	[additional_rsp_data] [varchar](25) NULL,
	[structured_data_req] [text] NULL,
	[structured_data_rsp] [text] NULL,
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
	[network_program_id_actual] [varchar](50) NULL,
	[network_program_id_min] [varchar](50) NULL,
	[network_fee_actual] [varchar](50) NULL,
	[network_fee_min] [varchar](50) NULL,
	[network_fee_max] [varchar](50) NULL,
	[credit_debit_conversion] [varchar](50) NULL,
	[mapped_terminal_id] [varchar](50) NULL,
	[mapped_extd_ca_term_id] [varchar](50) NULL,
	[mapped_extd_ca_id_code] [varchar](50) NULL
) ON [TRANSACTIONS] TEXTIMAGE_ON [PRIMARY]

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
GO

ALTER TABLE [dbo].[post_tran] ADD  DEFAULT ((0)) FOR [next_post_tran_id]
GO

ALTER TABLE [dbo].[post_tran] ADD  DEFAULT ((0)) FOR [tran_reversed]
GO



USE [postilion_office]
GO

/****** Object:  Index [indx_next_post_tran_id]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [indx_next_post_tran_id] ON [dbo].[post_tran] 
(
	[next_post_tran_id] ASC
)
INCLUDE ( [post_tran_cust_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [indx_post_tran_cust_id_next_post_tran_id_tran_postilion_originated]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [indx_post_tran_cust_id_next_post_tran_id_tran_postilion_originated] ON [dbo].[post_tran] 
(
	[post_tran_cust_id] ASC,
	[next_post_tran_id] ASC,
	[tran_postilion_originated] ASC
)
INCLUDE ( [post_tran_id],
[message_type],
[rsp_code_rsp]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [indx_tran_postilion_originated_message_typedatetime_req]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [indx_tran_postilion_originated_message_typedatetime_req] ON [dbo].[post_tran] 
(
	[post_tran_id] ASC,
	[message_type] ASC,
	[tran_postilion_originated] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [ix_post_tran_1]    Script Date: 08/24/2017 10:02:50 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_1] ON [dbo].[post_tran] 
(
	[post_tran_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [ix_post_tran_10]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_10] ON [dbo].[post_tran] 
(
	[settle_entity_id] ASC,
	[batch_nr] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [TRANSACTIONS]
GO

/****** Object:  Index [ix_post_tran_15]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_15] ON [dbo].[post_tran] 
(
	[tran_postilion_originated] ASC,
	[tran_completed] ASC,
	[recon_business_date] ASC,
	[sink_node_name] ASC,
	[message_type] ASC,
	[tran_type] ASC
)
INCLUDE ( [post_tran_id],
[post_tran_cust_id],
[prev_post_tran_id],
[system_trace_audit_nr],
[rsp_code_rsp],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_local],
[datetime_req],
[from_account_type],
[to_account_type],
[settle_amount_impact],
[tran_cash_req],
[tran_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[extended_tran_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [ix_post_tran_2]    Script Date: 08/24/2017 10:02:50 ******/
CREATE CLUSTERED INDEX [ix_post_tran_2] ON [dbo].[post_tran] 
(
	[post_tran_cust_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [ix_post_tran_7]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_7] ON [dbo].[post_tran] 
(
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [ix_post_tran_8]    Script Date: 08/24/2017 10:02:50 ******/
CREATE UNIQUE NONCLUSTERED INDEX [ix_post_tran_8] ON [dbo].[post_tran] 
(
	[tran_nr] ASC,
	[message_type] ASC,
	[tran_postilion_originated] ASC,
	[online_system_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 80) ON [TRANSACTIONS]
GO

/****** Object:  Index [ix_post_tran_9]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_9] ON [dbo].[post_tran] 
(
	[recon_business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [IX_post_tran_cust_id_tran_postilion_originated]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [IX_post_tran_cust_id_tran_postilion_originated] ON [dbo].[post_tran] 
(
	[post_tran_cust_id] ASC,
	[tran_postilion_originated] ASC
)
INCLUDE ( [tran_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [IX_recon_business_datepost_tran_id]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [IX_recon_business_datepost_tran_id] ON [dbo].[post_tran] 
(
	[recon_business_date] ASC,
	[post_tran_id] ASC
)
INCLUDE ( [post_tran_cust_id],
[prev_post_tran_id],
[sink_node_name],
[tran_postilion_originated],
[tran_completed],
[message_type],
[tran_type],
[tran_nr],
[system_trace_audit_nr],
[rsp_code_req],
[rsp_code_rsp],
[abort_rsp_code],
[auth_id_rsp],
[retention_data],
[acquiring_inst_id_code],
[message_reason_code],
[retrieval_reference_nr],
[datetime_tran_gmt],
[datetime_tran_local],
[datetime_req],
[datetime_rsp],
[realtime_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[tran_amount_req],
[tran_amount_rsp],
[settle_amount_impact],
[tran_cash_req],
[tran_cash_rsp],
[tran_currency_code],
[tran_tran_fee_req],
[tran_tran_fee_rsp],
[tran_tran_fee_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_tran_fee_req],
[settle_tran_fee_rsp],
[settle_currency_code],
[tran_reversed],
[prev_tran_approved],
[extended_tran_type],
[payee],
[online_system_id],
[receiving_inst_id_code],
[routing_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO

/****** Object:  Index [IX_recon_business_datepost_tran_id_sink_node_name_rsp_code_rsp]    Script Date: 08/24/2017 10:02:50 ******/
CREATE NONCLUSTERED INDEX [IX_recon_business_datepost_tran_id_sink_node_name_rsp_code_rsp] ON [dbo].[post_tran] 
(
	[recon_business_date] ASC,
	[post_tran_id] ASC,
	[sink_node_name] ASC,
	[rsp_code_rsp] ASC
)
INCLUDE ( [post_tran_cust_id],
[settle_entity_id],
[batch_nr],
[prev_post_tran_id],
[next_post_tran_id],
[tran_postilion_originated],
[tran_completed],
[message_type],
[tran_type],
[tran_nr],
[system_trace_audit_nr],
[rsp_code_req],
[abort_rsp_code],
[auth_id_rsp],
[auth_type],
[auth_reason],
[retention_data],
[acquiring_inst_id_code],
[message_reason_code],
[sponsor_bank],
[retrieval_reference_nr],
[datetime_tran_gmt],
[datetime_tran_local],
[datetime_req],
[datetime_rsp],
[realtime_business_date],
[from_account_type],
[to_account_type],
[from_account_id],
[to_account_id],
[tran_amount_req],
[tran_amount_rsp],
[settle_amount_impact],
[tran_cash_req],
[tran_cash_rsp],
[tran_currency_code],
[tran_tran_fee_req],
[tran_tran_fee_rsp],
[tran_tran_fee_currency_code],
[tran_proc_fee_req],
[tran_proc_fee_rsp],
[tran_proc_fee_currency_code],
[settle_amount_req],
[settle_amount_rsp],
[settle_cash_req],
[settle_cash_rsp],
[settle_tran_fee_req],
[settle_tran_fee_rsp],
[settle_proc_fee_req],
[settle_proc_fee_rsp],
[settle_currency_code],
[pos_entry_mode],
[pos_condition_code],
[additional_rsp_data],
[tran_reversed],
[prev_tran_approved],
[issuer_network_id],
[acquirer_network_id],
[extended_tran_type],
[from_account_type_qualifier],
[to_account_type_qualifier],
[bank_details],
[payee],
[card_verification_result],
[online_system_id],
[participant_id],
[opp_participant_id],
[receiving_inst_id_code],
[routing_type],
[pt_pos_operating_environment],
[pt_pos_card_input_mode],
[pt_pos_cardholder_auth_method],
[pt_pos_pin_capture_ability],
[pt_pos_terminal_operator],
[source_node_key],
[proc_online_system_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [TRANSACTIONS]
GO


USE [postilion_office]
GO

/****** Object:  Trigger [dbo].[ot_post_tran_insert]    Script Date: 08/24/2017 10:05:09 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE TRIGGER [dbo].[ot_post_tran_insert]
ON [dbo].[post_tran]
FOR INSERT
AS
	DECLARE @prev_post_tran_id	BIGINT
	DECLARE @post_tran_id 		BIGINT
	DECLARE @message_type 	INT
	DECLARE @tran_amount_req 	POST_MONEY
	DECLARE @rsp_code_rsp 	CHAR(2)
	DECLARE @settle_amount_impact	POST_MONEY
	
	-- The BIGINT-Background-Copy job sets the context_info up with this value
	-- so that we do not execute the trigger when it does the inserting:
	IF EXISTS (
		SELECT context_info FROM master..sysprocesses 
		WHERE spid = @@spid
			AND context_info = 0x424947494E542D4261636B67726F756E642D436F7079)
	BEGIN
		RETURN
	END

	SELECT 	
		@prev_post_tran_id = prev_post_tran_id,
		@post_tran_id = post_tran_id,
		@message_type = message_type,
		@tran_amount_req = tran_amount_req,
		@rsp_code_rsp = rsp_code_rsp,
		@settle_amount_impact = settle_amount_impact
	FROM 
		inserted				
	
	IF (@prev_post_tran_id > 0)
	BEGIN
		DECLARE @tran_reversed INT
		SET @tran_reversed = 0
		
		IF (@message_type = '0420' OR @message_type = '0400')
		BEGIN
			SET @tran_reversed = 1		-- Partial Reversal
				
			IF (@tran_amount_req = 0 AND (dbo.isApproveRspCode(@rsp_code_rsp) = 1))
			BEGIN
				SET @tran_reversed = 2  -- Full Reversal
			END
			ELSE IF (dbo.isApproveRspCode(@rsp_code_rsp) = 0)
			BEGIN
				SET @tran_reversed = 0 -- Transaction not Approved
			END
		END
		ELSE IF (@message_type = '0202')
		BEGIN
			-- If the settle_amount_impact of the 0202 is zero, it means either the original 0100/0200
			-- transaction was declined or the 0202 has no effect. Either way we should not update the 
			-- tran_reversed flag.
			IF (@settle_amount_impact <> 0)
			BEGIN
				IF (@tran_amount_req = 0 AND (dbo.isApproveRspCode(@rsp_code_rsp) = 1))
				BEGIN
					SET @tran_reversed = 2  -- Full Reversal
				END
				ELSE IF (@tran_amount_req <> 0)
				BEGIN
					SET @tran_reversed = 1	-- Partial Reversal
				END
			END
		END		
		
		-- Heat 760678
		DECLARE @prev_fin_post_tran_id BIGINT
		EXEC osp_norm_find_prev_fin_tran @prev_post_tran_id, @prev_fin_post_tran_id OUTPUT
	
		-- (The following separation of updates is done for performance purposes)
		-- If the previous transaction was the previous financial transaction
		IF (@prev_post_tran_id = @prev_fin_post_tran_id)
		BEGIN
			-- Merely update the previous transaction
			-- Only update the tran_reversed field if this is actually a reversal (Heat 763301)
			UPDATE 
				post_tran
			SET	
				next_post_tran_id = @post_tran_id,
				tran_reversed = 
				CASE 
					WHEN @message_type IN ('0420', '0400') OR (@message_type IN ('0202') AND @tran_reversed IS NOT NULL)
					THEN @tran_reversed	
					ELSE tran_reversed
				END
			FROM 
				post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
			WHERE 
				post_tran_id = @prev_post_tran_id
		END
		ELSE
		BEGIN
			-- Update the previous transaction's next_post_tran_id
			UPDATE
				post_tran
			SET
				next_post_tran_id = @post_tran_id
			FROM 
				post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
			WHERE
				post_tran_id = @prev_post_tran_id
					
			-- Update the previous financial transaction's tran_reversed flag if this was a reversal (Heat 763301)
			
			IF (@message_type IN ('0420', '0400')) OR (@message_type IN ('0202') AND @tran_reversed IS NOT NULL)
			BEGIN
				UPDATE
					post_tran
				SET
					tran_reversed = @tran_reversed
				FROM
					post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
				WHERE
					post_tran_id = @prev_fin_post_tran_id
			END
		END
	END
	

GO

/****** Object:  Trigger [dbo].[ot_post_tran_update]    Script Date: 08/24/2017 10:05:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO


CREATE   TRIGGER  [dbo].[ot_post_tran_update]
ON [dbo].[post_tran]
FOR UPDATE
AS
	DECLARE @next_post_tran_id BIGINT
	DECLARE @rsp_code_rsp 	CHAR(2)

	SELECT 	
			@next_post_tran_id = next_post_tran_id,
			@rsp_code_rsp = rsp_code_rsp
	FROM 
			inserted				
	
	
	IF (@next_post_tran_id > 0 AND (dbo.isApproveRspCode(@rsp_code_rsp) = 1))
	BEGIN
		
		-- Update the next transaction
	
		UPDATE 
				post_tran
		SET	
				prev_tran_approved = 1
		FROM
				post_tran WITH (INDEX(ix_post_tran_1), ROWLOCK)
		WHERE 
				post_tran_id = @next_post_tran_id
		END
	
	


	go
ALTER TABLE [dbo].[extract_tran] DROP CONSTRAINT [fk_extract_tran_3]
 
print 'extract_tran constraint dropped'
GO
ALTER TABLE [dbo].[recon_match_equal] DROP CONSTRAINT [fk_recon_match_equal_2]
 
print 'recon_match_equal constraint dropped'
GO
ALTER TABLE [dbo].[recon_match_not_equal] DROP CONSTRAINT [fk_recon_match_not_equal_2]
 
print 'recon_match_not_equal constraint dropped'
GO
ALTER TABLE [dbo].[recon_post_only] DROP CONSTRAINT [fk_recon_post_only_3]
 
	

ALTER TABLE [dbo].[post_tran] WITH CHECK ADD CONSTRAINT [fk_post_tran_1] FOREIGN KEY([post_tran_cust_id])
 
REFERENCES [dbo].[post_tran_cust] ([post_tran_cust_id])
GO
ALTER TABLE [dbo].[post_tran] CHECK CONSTRAINT [fk_post_tran_1]
GO
ALTER TABLE [dbo].[recon_post_only] WITH CHECK ADD CONSTRAINT [fk_recon_post_only_3] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[recon_post_only] CHECK CONSTRAINT [fk_recon_post_only_3]
 
print 'recon_post_only constraint recretaed'
GO
 
ALTER TABLE [dbo].[recon_match_not_equal] WITH CHECK ADD CONSTRAINT [fk_recon_match_not_equal_2] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[recon_match_not_equal] CHECK CONSTRAINT [fk_recon_match_not_equal_2]
 
print 'recon_match_not_equal constraint recreated'
GO
 
ALTER TABLE [dbo].[recon_match_equal] WITH CHECK ADD CONSTRAINT [fk_recon_match_equal_2] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[recon_match_equal] CHECK CONSTRAINT [fk_recon_match_equal_2]
 
print 'recon_match_equal constraint recreated'
GO
 
ALTER TABLE [dbo].[extract_tran] WITH CHECK ADD CONSTRAINT [fk_extract_tran_3] FOREIGN KEY([post_tran_id])
 
REFERENCES [dbo].[post_tran] ([post_tran_id])
GO
ALTER TABLE [dbo].[extract_tran] CHECK CONSTRAINT [fk_extract_tran_3]
 
print 'extract_tran constraint recreated'
GO


USE [postilion_office];  CREATE INDEX indx_Represented    ON [dbo]    .[NIBSS_T1_Returns_Table]    ([Represented])      INCLUDE ([Entry_id], [PDATE], [SerNo], [Account_nr], [SortCode], [Mer_Receivable_AMT], [Payee], [Narration], [Payer], [Card_Acceptor_id_Code], [Reason], [Date_Inserted])      WITH (FILLFACTOR=70, ONLINE=ON)
USE [postilion_office];  CREATE INDEX indx_source_node_name    ON [dbo]    .[post_tran_cust]    ([source_node_name])      INCLUDE ([post_tran_cust_id], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [totals_group], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference])      WITH (FILLFACTOR=70, ONLINE=ON)
USE [postilion_office];  CREATE INDEX indx_Date_Modified    ON [dbo]    .[tbl_merchant_account]    ([Date_Modified])      INCLUDE ([Acquiring_bank], [card_acceptor_id_code], [account_nr], [Account_Name], [Authorized_Person], [terminal_mode], [bank_code])      WITH (FILLFACTOR=70, ONLINE=ON)



DECLARE @retention_period INT = 7
DECLARE @running_date  DATETIME
DECLARE @final_date  DATETIME

set transaction isolation level read uncommitted

SET   @final_date    =GETDATE()
SET @running_date   =  CONVERT( DATE, DATEADD(D, -1 * @retention_period , @final_date    ))

WHILE  ( @running_date  <=@final_date    ) BEGIN

select * from POST_TRAN_ORIGINAL WITH (NOLOCK, INDEX= IX_POST_TRAN_9) WHERE 
recon_business_date  = @running_date  

 SET @running_date   =  CONVERT (DATE,  DATEADD(D, 1, @running_date   ))

END
