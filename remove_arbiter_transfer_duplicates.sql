


WITH CTE AS
(
SELECT  postilion_office_transactions_id,tran_nr,ROW_NUMBER() OVER (PARTITION BY tran_nr ORDER BY postilion_office_transactions_id) AS RN
FROM temp_dup_transfers_details_20170907 WITH  (NOLOCK)
)
SELECT *  into temp_dup_transfers_details_20170907_2 FROM   temp_dup_transfers_details_20170907  WITH (NOLOCK)
WHERE  postilion_office_transactions_id not in (
select postilion_office_transactions_id
   FROM CTE 
WHERE RN <> 1 
)

CREATE INDEX ix_temp_dup_transfers_details_20170907_1 on temp_dup_transfers_details_20170907_2 (
postilion_office_transactions_id

)

SELECT * FROM temp_dup_transfers_details_20170907_2 (nolock) where tran_nr 
NOT IN (
 select  tran_nr FROM  temp_dup_transfers_details_20170907 WITH (NOLOCK)
)


DELETE FROM  tbl_postilion_office_transactions_staging_transfers
WHERE 
tran_nr IN (
select tran_nr from temp_dup_transfers_20170907 with  (NOLOCK)
)

/****** Object:  Index [indx_tran_nr_intermediate_3]    Script Date: 09/07/2017 07:01:04 ******/
ALTER TABLE [dbo].tbl_postilion_office_transactions_staging_transfers ADD  CONSTRAINT [indx_tran_nr_intermediate_3] UNIQUE NONCLUSTERED 
(
	[tran_nr] ASC,
	[online_system_id] ASC,
	[server_id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = OFF) ON [arbiter_filegroup_2]
GO

SET IDENTITY_INSERT   tbl_postilion_office_transactions_staging_transfers ON
INSERT INTO  tbl_postilion_office_transactions_staging_transfers(
[postilion_office_transactions_id],[issuer_code],[post_tran_id],[post_tran_cust_id],[tran_nr],[masked_pan],[terminal_id],[card_acceptor_id_code],[card_acceptor_name_loc],[tran_type_description],[tran_amount_req],[tran_fee_req],[currency_alpha_code],[system_trace_audit_nr],[datetime_req],[retrieval_reference_nr],[acquirer_code],[rsp_code_rsp],[terminal_owner],[sink_node_name],[merchant_type],[source_node_name],[from_account_id],[tran_tran_fee_req],[auth_id_rsp],[settle_amount_rsp],[settle_amount_impact],[pos_terminal_type],[settle_currency_code],[tran_currency_code],[tran_currency_alpha_code],[online_system_id],[server_id],[tran_reversed],[Logged],[Type],[to_account],[extended_tran_type]
)
SELECT 
[postilion_office_transactions_id],[issuer_code],[post_tran_id],[post_tran_cust_id],[tran_nr],[masked_pan],[terminal_id],[card_acceptor_id_code],[card_acceptor_name_loc],[tran_type_description],[tran_amount_req],[tran_fee_req],[currency_alpha_code],[system_trace_audit_nr],[datetime_req],[retrieval_reference_nr],[acquirer_code],[rsp_code_rsp],[terminal_owner],[sink_node_name],[merchant_type],[source_node_name],[from_account_id],[tran_tran_fee_req],[auth_id_rsp],[settle_amount_rsp],[settle_amount_impact],[pos_terminal_type],[settle_currency_code],[tran_currency_code],[tran_currency_alpha_code],[online_system_id],[server_id],[tran_reversed],[Logged],[Type],[to_account],[extended_tran_type]
FROM 
temp_dup_transfers_details_20170907_2
WITH (nolock)

SET IDENTITY_INSERT   tbl_postilion_office_transactions_staging_transfers Off