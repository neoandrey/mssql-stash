
USE [arbiter]
GO

/****** Object:  Table [dbo].[tbl_postilion_office_transactions]    Script Date: 07/03/2014 10:32:10 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[tbl_postilion_office_transactions_new](
	[postilion_office_transactions_id] [int] IDENTITY(1,1) NOT NULL,
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
	[datetime_req] [datetime] NULL,
	[retrieval_reference_nr] [varchar](30) NULL,
	[acquirer_code] [varchar](11) NULL,
	[rsp_code_rsp] [char](2) NULL,
	[terminal_owner] [varchar](25) NULL,
	[sink_node_name] [varchar](64) NULL,
	[merchant_type] [varchar](10) NULL,
	[source_node_name] [varchar](64) NULL,
	[from_account_id] [varchar](30) NULL,
	[tran_tran_fee_req] [float] NULL,
	auth_id_rsp  VARCHAR (15),
    settle_amount_rsp [float] NULL,
    settle_amount_impact [float] NULL,
    terminal_type VARCHAR (30), 
    settlement_currency  VARCHAR (20), 
	online_system_id INT NULL,
	server_id VARCHAR (150)
 CONSTRAINT [PK_tbl_postilion_office_transactions_new] PRIMARY KEY CLUSTERED 
(
	[postilion_office_transactions_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
 CONSTRAINT [indx_tran_nr_intermediate_new] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,online_system_id ASC, server_id ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY] 

GO

SET ANSI_PADDING OFF
GO


