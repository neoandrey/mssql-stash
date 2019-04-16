DECLARE @config_version INT;

SET @config_version = 174

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
DELETE FROM  dbo.sstl_coa WHERE config_version>=@config_version
DELETE FROM sstl_config_version	WHERE config_version>=@config_version
