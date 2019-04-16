USE [postilion_office]
GO

/****** Object:  Table [dbo].[tbl_late_reversals]    Script Date: 03/29/2016 11:48:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
drop table [tbl_late_reversals]
CREATE TABLE [dbo].[tbl_late_reversals](
	[post_tran_id] [bigint] NOT NULL,
	[rev_post_tran_cust_id] [bigint] NOT NULL,
	[trans_post_tran_cust_id] [bigint] NULL,
	[trans_datetime_req] [datetime] NOT NULL,
	[rev_datetime_req] [datetime] NOT NULL,
	[prev_post_tran_id] [bigint] NOT NULL,
	[rev_message_type] [char](4) NOT NULL,
	[rev_rsp_code_rsp] [char](2) NULL,
	[post_tran_message_type] [char](4) NULL,
	[trans_rsp_code_rsp] [char](2) NULL,
	[tran_nr] [bigint] NOT NULL,
	[settle_amount_impact] [numeric](16, 0) NULL,
	[settle_amount_req] [numeric](16, 0) NULL,
	[settle_amount_rsp] [numeric](16, 0) NULL,
	[settle_currency_code] [char](3) NULL,
	[sink_node_name] [varchar](30) NULL,
	[system_trace_audit_nr] [char](6) NULL,
	[tran_amount_req] [numeric](16, 0) NULL,
	[tran_amount_rsp] [numeric](16, 0) NULL,
	[tran_currency_code] [char](3) NULL,
	[reversal_type] [varchar](6) NULL,
	[terminal_id] [varchar](10) NULL,
	[retrieval_reference_nr] [varchar](20) NULL,
	[online_system_id] [varchar](20) NULL,
	[recon_business_date] [datetime] NOT NULL,
	[tran_type] [varchar](5) NULL,
 CONSTRAINT [pk_tbl_late_reversals_4] PRIMARY KEY  
(
	[post_tran_id] ASC,
	[prev_post_tran_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE  CLUSTERED INDEX ON [dbo].[tbl_late_reversals](post_tran_id)
SET ANSI_PADDING OFF
GO




SET ANSI_PADDING OFF
GO

create NONCLUSTERED INDEX ix_post_tran_cust_id_2 ON   tbl_late_reversals (
   trans_post_tran_cust_id
)

create NONCLUSTERED INDEX ix_datetime_req ON   tbl_late_reversals (
   trans_datetime_req
)

create NONCLUSTERED INDEX ix_recon_business_date ON   tbl_late_reversals (
   recon_business_date
)

create NONCLUSTERED INDEX ix_tran_nr ON   tbl_late_reversals (
   tran_nr
)

create NONCLUSTERED INDEX ix_sink_node_name ON   tbl_late_reversals (
   sink_node_name
)

create NONCLUSTERED INDEX ix_system_trace_audit_nr ON   tbl_late_reversals (
   system_trace_audit_nr
)

create NONCLUSTERED INDEX ix_retrieval_reference_nr ON   tbl_late_reversals (
   retrieval_reference_nr
)

create NONCLUSTERED INDEX ix_terminal_id ON   tbl_late_reversals (
   terminal_id
)
create NONCLUSTERED INDEX ix_tran_type ON   tbl_late_reversals (
   tran_type
)



