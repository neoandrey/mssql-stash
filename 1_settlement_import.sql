DELETE FROM  spay_aggregation
INSERT INTO spay_aggregation SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[spay_aggregation]

DELETE FROM  spst_aggregation
INSERT INTO spst_aggregation SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[spst_aggregation]


DELETE FROM  spst_proc_ent
INSERT INTO spst_proc_ent SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[spst_proc_ent]

DELETE FROM  spst_proc_ent_fltr_grp
INSERT INTO spst_proc_ent_fltr_grp SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[spst_proc_ent_fltr_grp]

DELETE FROM  sstl_acc
INSERT INTO sstl_acc SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_acc]

DELETE FROM  sstl_acc_w
INSERT INTO sstl_acc_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_acc_w]

DELETE FROM  sstl_coa_w
INSERT INTO sstl_coa_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_coa_w]

DELETE FROM  sstl_journal_fltr_grp
INSERT INTO sstl_journal_fltr_grp SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_journal_fltr_grp]

DELETE FROM  sstl_journal_fltr_param_w
INSERT INTO sstl_journal_fltr_param_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_journal_fltr_param_w]

DELETE FROM  sstl_pred_prop_value
INSERT INTO sstl_pred_prop_value SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_pred_prop_value]

DELETE FROM  sstl_prop_value
INSERT INTO sstl_prop_value SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_prop_value]



DELETE FROM  sstl_prop_value_node
INSERT INTO sstl_prop_value_node SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_prop_value_node]

DELETE FROM  sstl_prop_value_node_w
INSERT INTO sstl_prop_value_node_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_prop_value_node_w]

DELETE FROM  sstl_prop_w
INSERT INTO sstl_prop_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_prop_w]

DELETE FROM  sstl_se_acc_nr_w
INSERT INTO sstl_se_acc_nr_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_acc_nr_w]


DELETE FROM  sstl_se_amount_value_int
INSERT INTO sstl_se_amount_value_int SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_amount_value_int]

DELETE FROM  sstl_se_amount_w
INSERT INTO sstl_se_amount_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_amount_w]

DELETE FROM  sstl_se_fee_value_w
INSERT INTO sstl_se_fee_value_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_fee_value_w]


DELETE FROM sstl_se_fee_w
INSERT INTO sstl_se_fee_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_fee_w]

DELETE FROM sstl_se_rule_acc_post_w
INSERT INTO sstl_se_rule_acc_post_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_rule_acc_post_w]

DELETE FROM sstl_se_w
INSERT INTO sstl_se_w SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_w]

DELETE FROM sstl_tran_field
INSERT INTO sstl_tran_field SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_tran_field]


DELETE FROM sstl_tran_ident_def
INSERT INTO sstl_tran_ident_def SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_tran_ident_def]



sstl_tran_ident_def







