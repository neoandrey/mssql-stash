USE [postilion_office]
GO

/****** Object:  View [dbo].[post_tran_summary]    Script Date: 05/24/2016 11:21:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER VIEW [dbo].[post_tran_summary]
				as
		SELECT 
		[post_tran_id]
      ,t.[post_tran_cust_id]
      ,[prev_post_tran_id]
      ,[sink_node_name]
      ,[tran_postilion_originated]
      ,[tran_completed]
      ,[message_type]
      ,[tran_type]
      ,[tran_nr]
      ,[system_trace_audit_nr]
      ,[rsp_code_req]
      ,[rsp_code_rsp]
      ,[abort_rsp_code]
      ,[auth_id_rsp]
      ,[retention_data]
      ,[acquiring_inst_id_code]
      ,[message_reason_code]
      ,[retrieval_reference_nr]
      ,[datetime_tran_gmt]
      ,[datetime_tran_local]
      ,[datetime_req]
      ,[datetime_rsp]
      ,[realtime_business_date]
      ,t.[recon_business_date]
      ,[from_account_type]
      ,[to_account_type]
      ,[from_account_id]
      ,[to_account_id]
      ,[tran_amount_req]
      ,[tran_amount_rsp]
      ,[settle_amount_impact]
      ,[tran_cash_req]
      ,[tran_cash_rsp]
      ,[tran_currency_code]
      ,[tran_tran_fee_req]
      ,[tran_tran_fee_rsp]
      ,[tran_tran_fee_currency_code]
      ,[settle_amount_req]
      ,[settle_amount_rsp]
      ,[settle_tran_fee_req]
      ,[settle_tran_fee_rsp]
      ,[settle_currency_code]
      ,[tran_reversed]
      ,[prev_tran_approved]
      ,[extended_tran_type]
      ,[payee]
      ,[online_system_id]
      ,[receiving_inst_id_code]
      ,[routing_type]
      ,[source_node_name]
      ,[pan]
      ,[card_seq_nr]
      ,[expiry_date]
      ,[terminal_id]
      ,[terminal_owner]
      ,[card_acceptor_id_code]
      ,[merchant_type]
      ,[card_acceptor_name_loc]
      ,[address_verification_data]
      ,[totals_group]
      ,[pan_encrypted]
      , CONVERT(VARCHAR(MAX), structured_data_rsp) structured_data_req
  FROM [postilion_office].[dbo].[post_tran] t (NOLOCK, index(ix_post_tran_9)) 
  JOIN
  [postilion_office].[dbo].[post_tran_cust] c (NOLOCK, index(pk_post_tran_cust)) 
  ON
  t.post_tran_cust_id = c.post_tran_cust_id
  JOIN
  (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range]('20160523','20160523'))r
	ON
	t.recon_business_date = r.recon_business_date
	--OPTION (MAXDOP 16)

GO

