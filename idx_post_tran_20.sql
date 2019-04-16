/*
Missing Index Details from SQLQuery18.sql - ASPOFFICE380D64.postilion_office (ASPOFFICE380D64\Administrator (113))
The Query Processor estimates that implementing the following index could improve the query cost by 48.8872%.
*/

/*
USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [dbo].[post_tran_leg_internal] ([tran_postilion_originated],[acquiring_inst_id_code],[post_tran_id],[post_tran_cust_id],[sink_node_name],[tran_type])
INCLUDE ([prev_post_tran_id_fast],[message_type],[system_trace_audit_nr],[rsp_code_rsp],[message_reason_code],[retrieval_reference_nr],[datetime_tran_local],[datetime_req],[from_account_type],[to_account_type],[settle_amount_impact],[tran_cash_req],[tran_currency_code],[settle_amount_req],[settle_amount_rsp],[settle_tran_fee_rsp],[settle_currency_code],[tran_reversed],[extended_tran_type],[payee],[receiving_inst_id_code])
GO
*/


CREATE NONCLUSTERED INDEX [ix_post_tran_20]
ON [dbo].[post_tran_leg_internal] ([tran_postilion_originated],[acquiring_inst_id_code],[post_tran_id],[post_tran_cust_id],[sink_node_name],[tran_type])
INCLUDE ([prev_post_tran_id_fast],[message_type],[system_trace_audit_nr],[rsp_code_rsp],[message_reason_code],[retrieval_reference_nr],[datetime_tran_local],[datetime_req],[from_account_type],[to_account_type],[settle_amount_impact],[tran_cash_req],[tran_currency_code],[settle_amount_req],[settle_amount_rsp],[settle_tran_fee_rsp],[settle_currency_code],[tran_reversed],[extended_tran_type],[payee],[receiving_inst_id_code])
GO


USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [idx_tbl_merchant_account_1]
ON [dbo].[tbl_merchant_account] ([card_acceptor_id_code])
INCLUDE ([account_nr])
GO

USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [idx_tbl_terminal_owner_1]
ON [dbo].[tbl_terminal_owner] ([terminal_id])
INCLUDE ([Terminal_code])
GO
