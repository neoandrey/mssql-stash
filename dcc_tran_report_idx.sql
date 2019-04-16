

USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [dcc_tran_report_idx]
ON [dbo].[post_tran] ([sink_node_name],[tran_postilion_originated],[rsp_code_rsp],[post_tran_id],[post_tran_cust_id],[message_type],[tran_currency_code])
INCLUDE ([tran_type],[retrieval_reference_nr],[datetime_req],[tran_amount_req],[settle_amount_impact],[settle_amount_req],[settle_currency_code],[pos_entry_mode],[tran_reversed])
GO

