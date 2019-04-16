if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DateOnly]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[DateOnly]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[DecryptPan]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[DecryptPan]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[GetIssuerCode]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[GetIssuerCode]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[currencyAlphaCode]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[currencyAlphaCode]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[currencyName]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[currencyName]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[currencyNrDecimals]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[currencyNrDecimals]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_LenStructDataElem]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_LenStructDataElem]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_PostilionFolder]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_PostilionFolder]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_StructDataElem]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_StructDataElem]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_ds_HasSubsequentReplacement]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_ds_HasSubsequentReplacement]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_ds_nodes_rsp_code]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_ds_nodes_rsp_code]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_ext_batchisclosed]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_ext_batchisclosed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_ext_batchisclosed_4200]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_ext_batchisclosed_4200]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_ext_correspondingbatchisclosed]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_ext_correspondingbatchisclosed]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_ext_correspondingbatchisclosed_4200]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_ext_correspondingbatchisclosed_4200]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_isFinancialTran]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_isFinancialTran]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_Above_limit]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_Above_limit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_CardGroup]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_CardGroup]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_CardGroup_Reward]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_CardGroup_Reward]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_CardType]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_CardType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_GetBeginCashForTerminal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_GetBeginCashForTerminal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_GetSuspectReason]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_GetSuspectReason]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_MCC]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_MCC]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_PanForDisplay]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_PanForDisplay]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_TransferTrxImpact]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_TransferTrxImpact]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_account_type]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_account_type]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_account_type_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_account_type_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_autopay_intra_sett]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_autopay_intra_sett]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_bin_update]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_bin_update]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_getATMDepositType]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_getATMDepositType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_getDepositTokenType]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_getDepositTokenType]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isATMCustomerInquiryTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isATMCustomerInquiryTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isApprovedTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isApprovedTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isAutomatedDeposit]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isAutomatedDeposit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isBillpayment]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isBillpayment]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isCardload]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isCardload]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isCashDepositBNA]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isCashDepositBNA]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isCashDepositCleanout]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isCashDepositCleanout]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isCheckCashTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isCheckCashTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isCheckDepositCleanout]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isCheckDepositCleanout]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isCreditTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isCreditTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isDepositTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isDepositTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isElectronicCheckDeposit]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isElectronicCheckDeposit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isEnvelopeDeposit]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isEnvelopeDeposit]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isEnvelopeDepositCleanout]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isEnvelopeDepositCleanout]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isInquiryTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isInquiryTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isOtherTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isOtherTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isPurchaseTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isPurchaseTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isPurchaseTrx_sett]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isPurchaseTrx_sett]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isRefundTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isRefundTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isTransferTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isTransferTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_isWithdrawTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_isWithdrawTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_late_reversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_late_reversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_nextelem]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_nextelem]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_rcn_EntityIdForName]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_rcn_EntityIdForName]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_rcn_ResolutionStateName]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_rcn_ResolutionStateName]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_remainelem]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_remainelem]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_transfers_sett]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_transfers_sett]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_rpt_transfers_vbills]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_rpt_transfers_vbills]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_acc_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_acc_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_acc_nr]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_acc_nr]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_amount_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_amount_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_amount_value]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_amount_value]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_coa_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_coa_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_config_set_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_config_set_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_fee_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_fee_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_fee_value]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_fee_value]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_filter_string]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_filter_string]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[fn_sstl_get_se_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[fn_sstl_get_se_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[formatAmount]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[formatAmount]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[formatAmountStr]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[formatAmountStr]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[formatMsgName]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[formatMsgName]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[formatRspCodeStr]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[formatRspCodeStr]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[formatTranTypeStr]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[formatTranTypeStr]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[isApproveRspCode]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[isApproveRspCode]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_part_view_tran]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_part_view_tran]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_atmbal_1_0_00_fn_rpt_isATMCustomerInquiryTrx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_atmbal_1_0_00_fn_rpt_isATMCustomerInquiryTrx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_027_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_027_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_034_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_034_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_042_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_042_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_32_formatRspCodeStr]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_32_formatRspCodeStr]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_33_fn_StructDataElem]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_33_fn_StructDataElem]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_49_fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_49_fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_56_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_56_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_56_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_56_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_office_4_2_00_patch_68_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_office_4_2_00_patch_68_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_100_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_100_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_102_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_102_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_103_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_104_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_104_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_105_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_105_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_106_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_106_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_107_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_107_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_110_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_110_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_111_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_111_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_113_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_114_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_114_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_115_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_115_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_117_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_117_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_118_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_119_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_119_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_120_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_120_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_125_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_125_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_fn_rpt_changeSignForReversal]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_fn_rpt_changeSignForReversal]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_129_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_129_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_70_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_70_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_72_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_72_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_73_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_73_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_74_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_74_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_75_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_76_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_76_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_77_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_77_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_78_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_79_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_80_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_80_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_82_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_82_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_83_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_83_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_84_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_84_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_86_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_86_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_87_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_87_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_89_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_89_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_90_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_90_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_91_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_91_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_92_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_92_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_93_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_93_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_94_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_94_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_95_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_95_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_96_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_96_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_fn_sql_version]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_fn_sql_version]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_check_if_column_exists]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_check_if_column_exists]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_get_column_index_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_backpop_get_column_index_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_part_view_tran_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_part_view_tran_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_split_list]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_split_list]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_97_ofn_split_list_2]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_97_ofn_split_list_2]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_chk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_chk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_col]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_col]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_def]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_def]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_fk]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_fk]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_func]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_func]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_idx]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_idx]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_obj]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_obj]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_proc]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_proc]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_tbl]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_tbl]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_trig]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_exists_trig]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_get_def_name]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_get_def_name]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_custom_action]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[rollback_officeframework_4_2_00_patch_98_ofn_patch_get_custom_action]
GO

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[usf_split_string]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[usf_split_string]
GO