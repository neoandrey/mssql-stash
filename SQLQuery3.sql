
CREATE TABLE [dbo].[card_transactions](
   [card_transactions_id] bigint identity (1,1),
	[Tran_nr] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[Pan] [varchar](19) NULL,
	[from_account] [varchar](28) NULL,
	[to_account] [varchar](28) NULL,
	[Date_Time] [datetime] NULL,
	[tran_type] [varchar](2) NULL,
	[tran_type_description] [varchar](60) NULL,
	[card_acceptor_id_code] [varchar](15) NULL,
	[card_acceptor_name_loc] [varchar](40) NULL,
	[terminal_id] [varchar](8) NULL,
	[stan] [varchar](6) NULL,
	[retrieval_reference_nr] [varchar](12) NULL,
	[message_type] [varchar](4) NULL,
	[datetime_req] [datetime] NULL,
	[response_code] [varchar](2) NULL,
	[Response_Code_description] [varchar](30) NULL,
	[tran_amount] [numeric](22, 6) NULL,
	[tran_currency] [varchar](3) NULL,
	[settle_amount] [float] NULL,
	[settle_tran_fee] [float] NULL,
	[Total_Impact] [float] NULL,
	[settle_currency] [varchar](3) NULL,
	[Auth_Id] [varchar](10) NULL,
	[sink_node_name] [varchar](30) NULL,
	[source_node_name] [varchar](30) NULL,
	[acquiring_inst_id_code] [varchar](11) NULL,
	[merchant_type] [varchar](4) NULL,
	[totals_group] [varchar](12) NULL,
	[issuer_code] [varchar](32) NULL
) ON [arbiter_filegroup_1]

GO

SET ANSI_PADDING OFF
GO



/****** Object:  Index [ix_post_tran_2]    Script Date: 12/15/2014 18:49:12 ******/
CREATE CLUSTERED INDEX [card_transactions_id_idx] ON [dbo].[card_transactions] 
(
	[card_transactions_id]  ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO

CREATE UNIQUE  NONCLUSTERED INDEX [post_tran_cust_id_idx] ON [dbo].[card_transactions] 
(
	post_tran_cust_id ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO
/****** Object:  Index [ix_post_tran_1]    Script Date: 12/15/2014 18:49:28 ******/
CREATE  NONCLUSTERED INDEX [Tran_nr_idx] ON [dbo].[card_transactions] 
(
	tran_nr ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO

CREATE  NONCLUSTERED INDEX [pan_idx] ON [dbo].[card_transactions] 
(
	pan ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO



CREATE  NONCLUSTERED INDEX [from_account_idx] ON [dbo].[card_transactions] 
(
	from_account ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO

CREATE  NONCLUSTERED INDEX [issuer_code_idx] ON [dbo].[card_transactions] 
(
	issuer_code ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO


CREATE  NONCLUSTERED INDEX [Date_time_idx] ON [dbo].[card_transactions] 
(
	Date_time ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO


CREATE  NONCLUSTERED INDEX [Date_time_idx] ON [dbo].[card_transactions] 
(
	Date_time ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO


CREATE  NONCLUSTERED INDEX [response_code_idx] ON [dbo].[card_transactions] 
(
	response_code ASC
)WITH (PAD_INDEX  = ON, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 85) ON [arbiter_filegroup_1]
GO


CREATE NONCLUSTERED INDEX [psp_retrieve_idx]
ON [dbo].[card_transactions] ([response_code],[Pan],[from_account],[issuer_code])

GO