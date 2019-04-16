USE [arbiter]
GO

/****** Object:  Table [dbo].[tbl_postilion_office_transactions_staging_copy]    Script Date: 07/19/2017 15:54:41 ******/
SET ANSI_NULLS ON
GO


CREATE TABLE [dbo].[tbl_postilion_office_transactions_staging_copy](
	[postilion_office_transactions_id] [bigint] IDENTITY(2148000000,1) NOT NULL,
	[issuer_code] [varchar](60) NULL,
	[post_tran_id] [bigint] NULL,
	[post_tran_cust_id] [bigint] NULL,
	[tran_nr] [bigint] NULL,
	[masked_pan] [varchar](19) NULL,
	[terminal_id] [char](8) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[card_acceptor_name_loc] [varchar](50) NULL,
	[tran_type_description] [varchar](60) NULL,
	[tran_amount_req] [float] NULL,
	[tran_fee_req] [float] NULL,
	[currency_alpha_code] [varchar](20) NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[datetime_req] [datetime] NOT NULL,
	[retrieval_reference_nr] [varchar](30) NULL,
	[acquirer_code] [varchar](11) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[terminal_owner] [varchar](25) NULL,
	[sink_node_name] [varchar](64) NULL,
	[merchant_type] [varchar](10) NULL,
	[source_node_name] [varchar](64) NULL,
	[from_account_id] [varchar](30) NULL,
	[tran_tran_fee_req] [float] NULL,
	[auth_id_rsp] [varchar](15) NULL,
	[settle_amount_rsp] [float] NULL,
	[settle_amount_impact] [float] NULL,
	[pos_terminal_type] [varchar](2) NULL,
	[settle_currency_code] [char](3) NULL,
	[tran_currency_code] [char](3) NULL,
	[tran_currency_alpha_code] [varchar](20) NULL,
	[online_system_id] [int] NULL,
	[server_id] [int] NULL,
	[tran_reversed] [char](1) NULL,
	[Logged] [bit] NULL,
	[Type] [char](1) NULL,
	[to_account] [varchar](30) NULL,
	[extended_tran_type] [char](6) NULL,
 CONSTRAINT [PK_tbl_postilion_office_transactions_staging_copy_new_2] PRIMARY KEY NONCLUSTERED 
(
	[postilion_office_transactions_id] ASC,
	[datetime_req] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON),
 CONSTRAINT [indx_tran_nr_intermediate_staging_copy_3] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON  [arbiter_filegroup_2]
)

GO