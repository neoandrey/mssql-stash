USE [vtucare]
GO

--/****** Object:  Index [pk_transactions_id]    Script Date: 2/27/2017 2:58:56 PM ******/
--ALTER TABLE [dbo].[tbl_transactions_temp] ADD  CONSTRAINT [pk_transactions_id] PRIMARY KEY CLUSTERED 
--(
--	[transaction_id] ASC
--)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
--GO

/****** Object:  Index [idx_alt_ref]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_alt_ref] ON [dbo].[tbl_transactions_temp]
(
	[alt_ref] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_batch_msisdn]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_batch_msisdn] ON [dbo].[tbl_transactions_temp]
(
	[batch_msisdn_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_customer_account_no]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_customer_account_no] ON [dbo].[tbl_transactions_temp]
(
	[customer_account_no] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_encrypted_pan]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_encrypted_pan] ON [dbo].[tbl_transactions_temp]
(
	[encrypted_pan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_fltred_settlement_date]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_fltred_settlement_date] ON [dbo].[tbl_transactions_temp]
(
	[settlement_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_issuer_domain_id]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_issuer_domain_id] ON [dbo].[tbl_transactions_temp]
(
	[issuer_domain_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_message_type]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_message_type] ON [dbo].[tbl_transactions_temp]
(
	[message_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_pan]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_pan] ON [dbo].[tbl_transactions_temp]
(
	[pan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_postilion_ref_id]    Script Date: 2/27/2017 2:58:56 PM ******/
CREATE NONCLUSTERED INDEX [idx_postilion_ref_id] ON [dbo].[tbl_transactions_temp]
(
	[postilion_ref_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [idx_product_code]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [idx_product_code] ON [dbo].[tbl_transactions_temp]
(
	[product_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [idx_res_code]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [idx_res_code] ON [dbo].[tbl_transactions_temp]
(
	[postilion_response_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [idx_res_code2]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [idx_res_code2] ON [dbo].[tbl_transactions_temp]
(
	[vtu_response_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

/****** Object:  Index [idx_stan]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [idx_stan] ON [dbo].[tbl_transactions_temp]
(
	[stan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_subscriber_msisdn]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [idx_subscriber_msisdn] ON [dbo].[tbl_transactions_temp]
(
	[subscriber_msisdn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [idx_terminal_id]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [idx_terminal_id] ON [dbo].[tbl_transactions_temp]
(
	[terminal_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [req_datetime_idx]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [req_datetime_idx] ON [dbo].[tbl_transactions_temp]
(
	[req_datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO

/****** Object:  Index [res_datetime_idx]    Script Date: 2/27/2017 2:58:57 PM ******/
CREATE NONCLUSTERED INDEX [res_datetime_idx] ON [dbo].[tbl_transactions_temp]
(
	[res_datetime] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
on monthly_quickteller_db_partition_scheme(PaymentDate)
GO



USE [quickteller]
GO
CREATE NONCLUSTERED INDEX [ix_Transaction_ON_PaymentRefNum]
ON [dbo].[Transactions] ([PaymentRefNum])
INCLUDE(
RequestReference ,
                    ResponseCode ,
                    TransactionSetName ,
                    ProcessingResponseCode ,
                    TransactionSetId ,
                    PaymentDate ,
                    TransactionAmount ,
                    Surcharge ,
                    CurrencyCode ,
                    CustomerName ,
                    CustomerEmail ,
                    CustomerMobile ,
                    MiscData ,
                    ServiceProviderCode ,
                    TerminalOwnerId ,
                    ServiceProviderId ,
                    RemoteClientName,
                    RemoteClientToken,
                    BankCBNCode,
                    EncryptedPAN,
                    MaskedPAN,
					RechargePin,
                    ServiceName ,
                    ServiceCode 
                   

)
on monthly_quickteller_db_partition_scheme(PaymentDate)



