CREATE NONCLUSTERED INDEX [ix_sstl_journal_1]
ON [dbo].[sstl_journal_7] 

([business_date]) INCLUDE ([post_tran_id],[post_tran_cust_id])



CREATE NONCLUSTERED INDEX [ix_sstl_journal_7]
ON [dbo].[sstl_journal_7] ([business_date])
INCLUDE ([post_tran_cust_id])