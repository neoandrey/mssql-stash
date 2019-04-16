DECLARE @config_version INT;

SET @config_version = 0


DELETE FROM dbo.sstl_se WHERE config_version>=@config_version
DELETE FROM dbo.spst_proc_ent_fltr_grp WHERE config_version>=@config_version
DELETE FROM dbo.spay_aggregation WHERE config_version>=@config_version
DELETE FROM dbo.spst_aggregation WHERE config_version>=@config_version
DELETE FROM dbo.sstl_pred_prop_value  WHERE config_version>=@config_version
DELETE FROM dbo.sstl_acc WHERE config_version>=@config_version
DELETE FROM dbo.sstl_journal_fltr_grp_elem WHERE config_version>=@config_version
DELETE FROM dbo.sstl_proc_ent WHERE config_version>=@config_version
DELETE FROM dbo.sstl_journal_fltr_grp	WHERE config_version>=@config_version
DELETE FROM dbo.sstl_prop_value	WHERE config_version>=@config_version
DELETE FROM dbo.sstl_tran_field	WHERE config_version>=@config_version
DELETE FROM dbo.sstl_prop_value_node	WHERE config_version>=@config_version
DELETE FROM dbo.sstl_tran_ident_def	WHERE config_version>=@config_version
DELETE FROM dbo.sstl_journal_fltr_param
DELETE FROM sstl_exception
DELETE FROM sstl_journal_1
DELETE FROM sstl_journal_fltr_grp_elem
DELETE FROM sstl_prop_value_node_w
DELETE FROM sstl_tran_ident_def
DELETE FROM  dbo.sstl_coa WHERE config_version>=@config_version
ALTER TABLE   sstl_prop NOCHECK CONSTRAINT ALL
DELETE FROM sstl_prop

delete from spst_proc_ent_fltr_grp_w
DELETE FROM dbo.spst_proc_ent_w
DELETE FROM spst_plugin
ALTER TABLE   sstl_tran_ident_def_w NOCHECK CONSTRAINT ALL
ALTER TABLE   sstl_tran_ident_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_tran_ident_w


DELETE FROM sstl_tran_ident_def_w
DELETE FROM sstl_se_amount
DELETE FROM sstl_tran_ident
DELETE FROM spst_proc_ent
DELETE FROM sstl_se_amount_value_int
delete from sstl_se_fee_value
--DELETE FROM sstl_config_version	WHERE config_version>=@config_version

 

ALTER TABLE    sstl_se_acc_nr_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_acc_nr_w

ALTER TABLE    sstl_se_acc_nr NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_acc_nr
ALTER TABLE    sstl_se_acc_nr_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_acc_nr

ALTER TABLE    sstl_se_acc_nr_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_acc_nr_w

ALTER TABLE sstl_se_rule_acc_post_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_rule_acc_post_w
DELETE FROM sstl_se_amount_value_int_w
DELETE FROM sstl_se_amount_value_w
DELETE FROM .sstl_se_fee_value_w
DELETE FROM sstl_se_fee_w
DELETE FROM sstl_se_amount_w
ALTER TABLE sstl_acc_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_acc_w
ALTER TABLE sstl_se_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_w

ALTER TABLE   sstl_se_type NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_type

ALTER TABLE   sstl_se_rule_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_rule_w



ALTER TABLE   sstl_se_fee_value_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_fee_value_w

ALTER TABLE   spst_proc_ent_fltr_grp_w NOCHECK CONSTRAINT ALL
DELETE FROM spst_proc_ent_fltr_grp_w
ALTER TABLE   spst_proc_ent_w NOCHECK CONSTRAINT ALL
DELETE FROM spst_proc_ent_w


ALTER TABLE   sstl_se_fee_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_fee_w

ALTER TABLE   dbo.spst_aggregation_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.spst_aggregation_w

ALTER TABLE   dbo.sstl_se_amount_value_int_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_se_amount_value_int_w

ALTER TABLE sstl_se_amount_value_w NOCHECK CONSTRAINT ALL
delete from sstl_se_amount_value_w

ALTER TABLE sstl_se_amount_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_amount_w

ALTER TABLE dbo.sstl_session NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_session

ALTER TABLE dbo.sstl_tran_ident_def_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_tran_ident_def_w 

ALTER TABLE sstl_tran_field_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_tran_field_w 
ALTER TABLE dbo.sstl_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_prop_value_node_w 
ALTER TABLE dbo.sstl_pred_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_pred_prop_value_w
ALTER TABLE dbo.sstl_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_prop_value_w
ALTER TABLE sstl_pred_prop_value_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_pred_prop_value_w
ALTER TABLE dbo.sstl_prop_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_prop_w


ALTER TABLE dbo.sstl_se_amount_value_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_se_amount_value_w

ALTER TABLE dbo.sstl_pred_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_pred_w 

ALTER TABLE dbo.sstl_pred NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_pred

ALTER TABLE dbo.spay_aggregation_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.spay_aggregation_w 

ALTER TABLE dbo.sstl_coa_w NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_coa_w 
ALTER TABLE dbo.sstl_journal_fltr_grp_elem NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_journal_fltr_grp_elem 

ALTER TABLE dbo.sstl_tran_ident_def NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_tran_ident_def 

ALTER TABLE dbo.sstl_coa NOCHECK CONSTRAINT ALL


DELETE FROM sstl_coa 
ALTER TABLE   sstl_proc_ent_w NOCHECK CONSTRAINT ALL
DELETE FROM sstl_proc_ent_w

ALTER TABLE   sstl_se_amount NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_amount
ALTER TABLE   sstl_se_amount_value NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_amount_value
ALTER TABLE sstl_se_amount_value_int NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_amount_value_int
ALTER TABLE sstl_se_fee NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_fee
ALTER TABLE sstl_se_fee_value NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_fee_value
ALTER TABLE sstl_se_rule NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_rule
ALTER TABLE sstl_se_rule_acc_post NOCHECK CONSTRAINT ALL
DELETE FROM sstl_se_rule_acc_post

ALTER TABLE sstl_coa NOCHECK CONSTRAINT ALL
DELETE FROM sstl_coa

ALTER TABLE sstl_journal_fltr_grp_elem NOCHECK CONSTRAINT ALL

DELETE FROM sstl_journal_fltr_grp_elem
DELETE FROM sstl_journal_part_info
DELETE FROM sstl_session

ALTER TABLE sstl_tran_ident_def NOCHECK CONSTRAINT ALL
DELETE FROM sstl_tran_ident_def
DELETE FROM sstl_journal_fltr_grp_elem
DELETE FROM sstl_coa 


ALTER TABLE sstl_statement_output_method NOCHECK CONSTRAINT ALL
DELETE FROM sstl_statement_output_method
ALTER TABLE sstl_table_meta_data NOCHECK CONSTRAINT ALL
DELETE FROM sstl_table_meta_data
DELETE FROM dbo.spst_proc_ent
ALTER TABLE sstl_tran_ident NOCHECK CONSTRAINT ALL
DELETE FROM sstl_tran_ident
ALTER TABLE sstl_tran_set NOCHECK CONSTRAINT ALL
DELETE FROM sstl_tran_set
ALTER TABLE dbo.sstl_config_version NOCHECK CONSTRAINT ALL
DELETE FROM dbo.sstl_config_version 
ALTER TABLE sstl_config_set NOCHECK CONSTRAINT ALL
DELETE FROM sstl_config_set 


EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL'