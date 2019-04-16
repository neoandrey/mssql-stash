
USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_test_1]
ON [dbo].[temp_journal_data_test] ([post_tran_id])
INCLUDE ([adj_id],[entry_id],[config_set_id],[session_id],[sdi_tran_id],[acc_post_id],[nt_fee_acc_post_id],[coa_id],
[coa_se_id],[se_id],[amount],[amount_id],[amount_value_id],[fee],[nt_fee],[nt_fee_id],[nt_fee_value_id],[debit_acc_nr_id],[debit_acc_id],
[debit_cardholder_acc_id],[debit_cardholder_acc_type],[credit_acc_nr_id],[credit_acc_id],[credit_cardholder_acc_id],[credit_cardholder_acc_type],
[business_date],[granularity_element],[tag],[spay_session_id],[spst_session_id],[DebitAccNr_config_set_id],[DebitAccNr_acc_nr_id],[DebitAccNr_se_id],
[DebitAccNr_acc_id],[DebitAccNr_acc_nr],[DebitAccNr_aggregation_id],[DebitAccNr_state],[DebitAccNr_config_state],[CreditAccNr_config_set_id],
[CreditAccNr_acc_nr_id],[CreditAccNr_se_id],[CreditAccNr_acc_id],[CreditAccNr_acc_nr],[CreditAccNr_aggregation_id],[CreditAccNr_state],
[CreditAccNr_config_state],[Amount_config_set_id],[Amount_amount_id],[Amount_se_id],[Amount_name],[Amount_description],[Amount_config_state]
,[Fee_config_set_id],[Fee_fee_id],[Fee_se_id],[Fee_name],[Fee_description],[Fee_type],[Fee_amount_id],[Fee_config_state],[coa_config_set_id],
[coa_coa_id],[coa_name],[coa_description],[coa_type],[coa_config_state])
GO

/*

CREATE NONCLUSTERED INDEX [ix_settle_tran_details_tab_20170404_1]
ON [dbo].[settle_tran_details_tab_20170404] ([source_node_name])
INCLUDE ([Unique_key])
GO




USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [ix_settle_tran_details_tab_20170404_6]
ON [dbo].[settle_tran_details_tab_20170404] ([index_no])

GO



USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [ix_settle_tran_details_tab_20170404_5]
ON [dbo].[settle_tran_details_tab_20170404] ([Unique_key],[source_node_name])
INCLUDE ([index_no])

USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [ix_settle_tran_details_tab_20170404_5]
ON [dbo].[settle_tran_details_tab_20170404] ([Unique_key],[source_node_name])
INCLUDE ([index_no])
*/

USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [ix_post_tran_22]
ON [dbo].[temp_post_tran_data_test] ([PT_tran_postilion_originated])
INCLUDE ([PT_post_tran_cust_id],[PT_tran_nr],[PT_retention_data],[PTC_terminal_id])





USE [postilion_office]
GO
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_test_1]
ON [dbo].[temp_journal_data_test] ([post_tran_id])
INCLUDE ([adj_id],[entry_id],[config_set_id],[session_id],[sdi_tran_id],[acc_post_id],[nt_fee_acc_post_id],[coa_id],
[coa_se_id],[se_id],[amount],[amount_id],[amount_value_id],[fee],[nt_fee],[nt_fee_id],[nt_fee_value_id],[debit_acc_nr_id],[debit_acc_id],
[debit_cardholder_acc_id],[debit_cardholder_acc_type],[credit_acc_nr_id],[credit_acc_id],[credit_cardholder_acc_id],[credit_cardholder_acc_type],
[business_date],[granularity_element],[tag],[spay_session_id],[spst_session_id],[DebitAccNr_config_set_id],[DebitAccNr_acc_nr_id],[DebitAccNr_se_id],
[DebitAccNr_acc_id],[DebitAccNr_acc_nr],[DebitAccNr_aggregation_id],[DebitAccNr_state],[DebitAccNr_config_state],[CreditAccNr_config_set_id],
[CreditAccNr_acc_nr_id],[CreditAccNr_se_id],[CreditAccNr_acc_id],[CreditAccNr_acc_nr],[CreditAccNr_aggregation_id],[CreditAccNr_state],
[CreditAccNr_config_state],[Amount_config_set_id],[Amount_amount_id],[Amount_se_id],[Amount_name],[Amount_description],[Amount_config_state]
,[Fee_config_set_id],[Fee_fee_id],[Fee_se_id],[Fee_name],[Fee_description],[Fee_type],[Fee_amount_id],[Fee_config_state],[coa_config_set_id],
[coa_coa_id],[coa_name],[coa_description],[coa_type],[coa_config_state])
GO


