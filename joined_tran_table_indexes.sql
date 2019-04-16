USE [postilion_office]
GO
CREATE UNIQUE CLUSTERED INDEX [post_tran_idx] ON [dbo].[joined_transaction_table] 
(
	[post_tran_id] DESC,
	[post_tran_cust_id] DESC,
	[online_system_id] DESC
) ON [SECONDARY]
GO


CREATE NONCLUSTERED INDEX [tran_nr_idx] ON [dbo].[joined_transaction_table] 
(
	[tran_nr] DESC
) ON [SECONDARY]
GO


CREATE NONCLUSTERED INDEX [datetime_tran_local_idx] ON [dbo].[joined_transaction_table] 
(
	[datetime_tran_local] DESC
) ON [SECONDARY]
GO


CREATE NONCLUSTERED INDEX [datetime_req_idx] ON [dbo].[joined_transaction_table] 
(
	[datetime_req] DESC
) ON [SECONDARY]
GO




CREATE NONCLUSTERED INDEX [system_trace_audit_nr_idx] ON [dbo].[joined_transaction_table] 
(
	[system_trace_audit_nr] DESC
) ON [SECONDARY]
GO



CREATE NONCLUSTERED INDEX [settle_n_batch_nr_idx] ON [dbo].[joined_transaction_table] 
(
	settle_entity_id DESC, 
	batch_nr DESC

) ON [SECONDARY]
GO

CREATE NONCLUSTERED INDEX [source_node_key_idx] ON [dbo].[joined_transaction_table] 
(
	source_node_key DESC
	
) ON [SECONDARY]
GO


CREATE NONCLUSTERED INDEX [retrieval_reference_nr_idx] ON [dbo].[joined_transaction_table] 
(
	retrieval_reference_nr DESC
	
) ON [SECONDARY]
GO

CREATE NONCLUSTERED INDEX [to_account_id_idx] ON [dbo].[joined_transaction_table] 
(
	to_account_id_cs DESC, 
	datetime_req DESC
) ON [SECONDARY]
GO
CREATE NONCLUSTERED INDEX [from_account_id_idx] ON [dbo].[joined_transaction_table] 
(
	from_account_id_idx DESC, 
	datetime_req DESC
) ON [SECONDARY]
GO



CREATE NONCLUSTERED INDEX [recon_business_date_idx] ON [dbo].[joined_transaction_table] 
(
	recon_business_date DESC
	
) ON [SECONDARY]
GO




