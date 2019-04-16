USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_clear_settlement_data_quick]    Script Date: 6/20/2018 12:26:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[usp_clear_settlement_data_quick] AS

BEGIN

DECLARE @config_version INT;

SET @config_version = 0

TRUNCATE  TABLE dbo.sstl_journal_adj --WHERE config_version>=@config_version

TRUNCATE  TABLE dbo.spay_aggregation --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_proc_ent --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_proc_ent_fltr_grp --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_se_acc --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_se_acc_rel --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_se_acc_rel_param --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_se_amount_pay_freq --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_se_fee_pay_freq --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_statement_profile --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_aggregation --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_proc_ent --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_proc_ent_fltr_grp --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_se_amount_pst_freq --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_se_fee_pst_freq --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_statement_profile --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_acc --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_coa --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_journal_fltr_grp --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_journal_fltr_grp_elem --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_journal_fltr_param --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_pred --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_pred_prop_value --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_proc_ent --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_prop --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_prop_value --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_prop_value_node --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_acc_nr --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_amount --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_amount_value --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_amount_value_int --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_cal --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_cal_date_range --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_fee --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_fee_priority --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_fee_value --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_nt_fee --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_nt_fee_acc_post --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_nt_fee_value --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_rule --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_rule_acc_post --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_statement --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_tax --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_tax_rate --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_se_third_party --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_session --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_statement_profile --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_tran_field --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_tran_ident --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_tran_ident_def --WHERE config_version>=@config_version
DELETE FROM dbo.spay_session --WHERE config_version>=@config_version
DELETE FROM dbo.spst_session --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_exception --WHERE config_version>=@config_version

TRUNCATE  TABLE dbo.sstl_se --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_proc_ent_fltr_grp --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spay_aggregation --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.spst_aggregation --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_pred_prop_value  --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_acc --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_journal_fltr_grp_elem --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_proc_ent --WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_journal_fltr_grp	--WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_prop_value	--WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_tran_field	--WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_prop_value_node	--WHERE config_version>=@config_version
TRUNCATE  TABLE dbo.sstl_tran_ident_def	--WHERE config_version>=@config_version









TRUNCATE  TABLE dbo.sstl_journal_fltr_param
TRUNCATE  TABLE sstl_exception
TRUNCATE  TABLE sstl_journal_1
TRUNCATE  TABLE sstl_journal_fltr_grp_elem
TRUNCATE  TABLE sstl_prop_value_node_w
TRUNCATE  TABLE sstl_tran_ident_def
TRUNCATE  TABLE  dbo.sstl_coa --WHERE config_version>=@config_version
ALTER TABLE   sstl_prop NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_prop

TRUNCATE  TABLE spst_proc_ent_fltr_grp_w
DELETE FROM dbo.spst_proc_ent_w
DELETE FROM spst_plugin
ALTER TABLE   sstl_tran_ident_def_w NOCHECK CONSTRAINT ALL
ALTER TABLE   sstl_tran_ident_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_tran_ident_w


TRUNCATE  TABLE sstl_tran_ident_def_w
TRUNCATE  TABLE sstl_se_amount
TRUNCATE  TABLE sstl_tran_ident
DELETE FROM spst_proc_ent
TRUNCATE  TABLE sstl_se_amount_value_int
TRUNCATE  TABLE sstl_se_fee_value
--TRUNCATE  TABLE sstl_config_version	--WHERE config_version>=@config_version

 delete from dbo.sstl_se_rule_acc_post_w
 DELETE FROM dbo.sstl_se_rule_w
ALTER TABLE    sstl_se_acc_nr_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_acc_nr_w

ALTER TABLE    sstl_se_acc_nr NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_acc_nr
ALTER TABLE    sstl_se_acc_nr_w NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_acc_nr

ALTER TABLE    sstl_se_acc_nr_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_acc_nr_w

ALTER TABLE sstl_se_rule_acc_post_w NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_rule_acc_post_w
TRUNCATE  TABLE sstl_se_amount_value_int_w

delete from  sstl_se_amount_value_w
TRUNCATE  TABLE .sstl_se_fee_value_w
delete from sstl_se_fee_w
DELETE FROM  sstl_se_amount_w
ALTER TABLE sstl_acc_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_acc_w
delete from dbo.sstl_se_rule_acc_post_w
ALTER TABLE sstl_se_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_se_w

ALTER TABLE   sstl_se_type NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_se_type

ALTER TABLE   sstl_se_rule_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_se_rule_w



ALTER TABLE   sstl_se_fee_value_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_se_fee_value_w

ALTER TABLE    spst_proc_ent_fltr_grp_w NOCHECK CONSTRAINT ALL
DELETE FROM spst_proc_ent_fltr_grp_w
ALTER TABLE   spst_proc_ent_w NOCHECK CONSTRAINT ALL
DELETE FROM  spst_proc_ent_w


ALTER TABLE   sstl_se_fee_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_se_fee_w

ALTER TABLE   dbo.spst_aggregation_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.spst_aggregation_w

ALTER TABLE   dbo.sstl_se_amount_value_int_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_se_amount_value_int_w

ALTER TABLE sstl_se_amount_value_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_se_amount_value_w

ALTER TABLE sstl_se_amount_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_se_amount_w

ALTER TABLE dbo.sstl_session NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_session

ALTER TABLE dbo.sstl_tran_ident_def_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_tran_ident_def_w 

ALTER TABLE sstl_tran_field_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_tran_field_w 
ALTER TABLE dbo.sstl_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_prop_value_node_w 
ALTER TABLE dbo.sstl_pred_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_pred_prop_value_w
ALTER TABLE dbo.sstl_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_prop_value_w
ALTER TABLE sstl_pred_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM  sstl_pred_prop_value_w
ALTER TABLE dbo.sstl_prop_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_prop_w


ALTER TABLE dbo.sstl_se_amount_value_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_se_amount_value_w

ALTER TABLE dbo.sstl_pred_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_pred_w 

ALTER TABLE dbo.sstl_pred NOCHECK CONSTRAINT ALL
TRUNCATE TABLE  dbo.sstl_pred

ALTER TABLE dbo.spay_aggregation_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.spay_aggregation_w 

ALTER TABLE dbo.sstl_coa_w NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_coa_w 
ALTER TABLE dbo.sstl_journal_fltr_grp_elem NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE dbo.sstl_journal_fltr_grp_elem 

ALTER TABLE dbo.sstl_tran_ident_def NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE dbo.sstl_tran_ident_def 

ALTER TABLE dbo.sstl_coa NOCHECK CONSTRAINT ALL


TRUNCATE  TABLE sstl_coa 
ALTER TABLE   sstl_proc_ent_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_proc_ent_w

ALTER TABLE   sstl_se_amount NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_amount
ALTER TABLE   sstl_se_amount_value NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_amount_value
ALTER TABLE sstl_se_amount_value_int NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_amount_value_int
ALTER TABLE sstl_se_fee NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_fee
ALTER TABLE sstl_se_fee_value NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_fee_value
ALTER TABLE sstl_se_rule NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_rule
ALTER TABLE sstl_se_rule_acc_post NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_se_rule_acc_post

ALTER TABLE sstl_coa NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_coa

ALTER TABLE sstl_journal_fltr_grp_elem NOCHECK CONSTRAINT ALL

TRUNCATE  TABLE sstl_journal_fltr_grp_elem
TRUNCATE  TABLE sstl_journal_part_info
TRUNCATE  TABLE sstl_session

ALTER TABLE sstl_tran_ident_def NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_tran_ident_def
TRUNCATE  TABLE sstl_journal_fltr_grp_elem
TRUNCATE  TABLE sstl_coa 


ALTER TABLE sstl_statement_output_method NOCHECK CONSTRAINT ALL
DELETE FROM sstl_statement_output_method
ALTER TABLE sstl_table_meta_data NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_table_meta_data
TRUNCATE  TABLE dbo.spst_proc_ent
ALTER TABLE sstl_tran_ident NOCHECK CONSTRAINT ALL
TRUNCATE  TABLE sstl_tran_ident
ALTER TABLE sstl_tran_set NOCHECK CONSTRAINT ALL
DELETE FROM sstl_tran_set
TRUNCATE  TABLE dbo.sstl_se
TRUNCATE  TABLE dbo.spst_aggregation
TRUNCATE  TABLE dbo.sstl_pred_prop_value
TRUNCATE  TABLE dbo.sstl_acc
TRUNCATE  TABLE dbo.sstl_proc_ent
TRUNCATE  TABLE dbo.sstl_prop_value
TRUNCATE  TABLE dbo.sstl_tran_field
TRUNCATE  TABLE dbo.sstl_journal_fltr_grp
TRUNCATE  TABLE dbo.spay_aggregation
TRUNCATE  TABLE dbo.sstl_prop_value_node
TRUNCATE  TABLE dbo.spst_proc_ent_fltr_grp
ALTER TABLE dbo.sstl_config_version NOCHECK CONSTRAINT ALL
DELETE FROM  dbo.sstl_config_version 
ALTER TABLE sstl_config_set NOCHECK CONSTRAINT ALL
DELETE FROM sstl_config_set 

delete from spay_acc_rel_type
delete from  spay_aggr_strategy
delete from dbo.spay_plugin
delete from spay_residue_strategy
delete from spst_aggr_strategy
delete from dbo.spst_residue_strategy
delete from sstl_fee_calc_strat
delete from  dbo.sstl_func
delete from dbo.sstl_journal_entry_insert_fltr
delete from sstl_journal_fltr
delete from sstl_journal_fltr_grp_w
delete from sstl_method
DELETE FROM dbo.spay_acc_rel_type
DELETE FROM dbo.spay_aggr_strategy
DELETE FROM dbo.spay_plugin
DELETE FROM spay_residue_strategy
DELETE FROM dbo.spst_aggr_strategy
DELETE FROM  dbo.spst_residue_strategy
DELETE FROM dbo.sstl_fee_calc_strat
delete from dbo.sstl_journal_entry_insert_fltr
delete from sstl_se_type

--EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL'

 EXEC sp_msforeachtable
 @command1 ='ALTER TABLE ? CHECK CONSTRAINT ALL'
,@whereand = ' And Object_id In (Select Object_id From sys.objects
Where name like ''%SSTL%'' OR name  like ''%SPAY%'' OR name  like ''%SPST%'')'
DELETE FROM dbo.sstl_config_version --WHERE config_version>=@config_version

END

