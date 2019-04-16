ALTER TABLE [dbo].[extract_tran] DROP CONSTRAINT [fk_extract_tran_3] 
GO
ALTER TABLE [dbo].[extract_tran]  WITH CHECK ADD  CONSTRAINT [fk_extract_tran_3] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal] ([post_tran_id])
GO

ALTER TABLE [extract_tran] CHECK CONSTRAINT [fk_extract_tran_3]

GO

ALTER TABLE [dbo].[recon_match_equal] DROP CONSTRAINT [fk_recon_match_equal_2] 
GO
ALTER TABLE [dbo].[recon_match_equal]  WITH CHECK ADD  CONSTRAINT [fk_recon_match_equal_2] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal] ([post_tran_id])
GO

ALTER TABLE [recon_match_equal] CHECK CONSTRAINT [fk_recon_match_equal_2]
GO


ALTER TABLE [dbo].[recon_match_not_equal] DROP CONSTRAINT [fk_recon_match_not_equal_2]
GO

ALTER TABLE [dbo].[recon_match_not_equal]  WITH CHECK ADD  CONSTRAINT [fk_recon_match_not_equal_2] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal] ([post_tran_id])
GO

ALTER TABLE [dbo].[recon_match_not_equal] CHECK CONSTRAINT [fk_recon_match_not_equal_2]
GO





ALTER TABLE [dbo].[recon_post_only] DROP CONSTRAINT [fk_recon_post_only_3] 
GO
ALTER TABLE [dbo].[recon_post_only]  WITH CHECK ADD  CONSTRAINT [fk_recon_post_only_3] FOREIGN KEY([post_tran_id])
REFERENCES [dbo].[post_tran_leg_internal] ([post_tran_id])
GO
ALTER TABLE  [dbo].[recon_post_only] CHECK CONSTRAINT [fk_recon_post_only_3]

GO


USE [postilion_office]
GO

/****** Object:  Index [ix_post_tran_1]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_1] ON [dbo].[post_tran_leg_internal]
(
	[post_tran_id] ASC,
	[tran_postilion_originated] ASC,
	[sink_node_name] ASC,
	[source_node_name] ASC
)
INCLUDE ( 	[post_tran_cust_id],
	[message_type],
	[tran_type],
	[extended_tran_type],
	[rsp_code_rsp],
	[tran_reversed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_10]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_10] ON [dbo].[post_tran_leg_internal]
(
	[settle_entity_id] ASC,
	[batch_nr] ASC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_11]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_11] ON [dbo].[post_tran_leg_internal]
(
	[source_node_key] ASC,
	[tran_postilion_originated] ASC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[source_node_name],
	[tran_nr],
	[online_system_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_12]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_12] ON [dbo].[post_tran_leg_internal]
(
	[from_account_id] ASC,
	[datetime_tran_local] DESC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[datetime_req],
	[tran_postilion_originated],
	[message_type],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[card_acceptor_id_code],
	[terminal_id],
	[from_account_type],
	[network_program_id_actual]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_13]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_13] ON [dbo].[post_tran_leg_internal]
(
	[to_account_id] ASC,
	[datetime_tran_local] DESC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[datetime_req],
	[tran_postilion_originated],
	[message_type],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[card_acceptor_id_code],
	[terminal_id],
	[to_account_type],
	[network_program_id_actual]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_15]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_15] ON [dbo].[post_tran_leg_internal]
(
	[retrieval_reference_nr] ASC,
	[datetime_tran_local] ASC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[tran_postilion_originated],
	[message_type],
	[system_trace_audit_nr],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[sink_node_name],
	[card_acceptor_id_code],
	[terminal_id],
	[tran_type],
	[extended_tran_type],
	[rsp_code_rsp],
	[tran_reversed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_2]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_2] ON [dbo].[post_tran_leg_internal]
(
	[post_tran_cust_id] ASC,
	[settle_entity_id] ASC,
	[batch_nr] ASC,
	[post_tran_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_7]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_7] ON [dbo].[post_tran_leg_internal]
(
	[datetime_req] DESC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[tran_postilion_originated],
	[message_type],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[sink_node_name],
	[card_acceptor_id_code],
	[terminal_id],
	[datetime_rsp],
	[network_program_id_actual]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_8]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_8] ON [dbo].[post_tran_leg_internal]
(
	[tran_nr] ASC,
	[message_type] ASC,
	[tran_postilion_originated] ASC,
	[online_system_id] ASC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_9]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_9] ON [dbo].[post_tran_leg_internal]
(
	[recon_business_date] ASC,
	[tran_postilion_originated] ASC,
	[sink_node_name] ASC,
	[source_node_name] ASC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[message_type],
	[tran_type],
	[extended_tran_type],
	[rsp_code_rsp],
	[tran_reversed]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_cust_1]    Script Date: 8/25/2016 2:27:26 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_1] ON [dbo].[post_tran_leg_internal]
(
	[pan] ASC,
	[datetime_tran_local] DESC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[datetime_req],
	[tran_postilion_originated],
	[message_type],
	[system_trace_audit_nr],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[card_acceptor_id_code],
	[terminal_id],
	[network_program_id_actual]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_cust_2]    Script Date: 8/25/2016 2:27:27 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_2] ON [dbo].[post_tran_leg_internal]
(
	[terminal_id] ASC,
	[datetime_req] DESC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[tran_postilion_originated],
	[message_type],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[sink_node_name],
	[card_acceptor_id_code],
	[network_program_id_actual]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_cust_3]    Script Date: 8/25/2016 2:27:27 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_3] ON [dbo].[post_tran_leg_internal]
(
	[pan_search] ASC,
	[datetime_tran_local] DESC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[datetime_req],
	[tran_postilion_originated],
	[message_type],
	[system_trace_audit_nr],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[card_acceptor_id_code],
	[terminal_id],
	[network_program_id_actual]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [ix_post_tran_cust_4]    Script Date: 8/25/2016 2:27:27 PM ******/
CREATE NONCLUSTERED INDEX [ix_post_tran_cust_4] ON [dbo].[post_tran_leg_internal]
(
	[pan_reference] ASC,
	[datetime_tran_local] DESC
)
INCLUDE ( 	[post_tran_id],
	[post_tran_cust_id],
	[datetime_req],
	[tran_postilion_originated],
	[message_type],
	[system_trace_audit_nr],
	[online_system_id],
	[participant_id],
	[opp_participant_id],
	[source_node_name],
	[sink_node_name],
	[card_acceptor_id_code],
	[terminal_id],
	[network_program_id_actual]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


