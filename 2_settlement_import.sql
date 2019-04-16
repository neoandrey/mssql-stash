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
SET IDENTITY_INSERT sstl_acc_w ON
INSERT INTO sstl_acc_w (config_set_id,acc_id,coa_id,name,description,config_state) SELECT config_set_id,acc_id,coa_id,name,description,config_state FROM [172.25.10.69].[postilion_office].[dbo].[sstl_acc_w]
SET IDENTITY_INSERT sstl_acc_w OFF

DELETE FROM  sstl_coa_w
SET IDENTITY_INSERT sstl_coa_w ON
INSERT INTO sstl_coa_w (config_set_id,coa_id,name,[description],[type],config_state) SELECT config_set_id,coa_id,name,[description],[type],config_state FROM [172.25.10.69].[postilion_office].[dbo].[sstl_coa_w]
SET IDENTITY_INSERT sstl_coa_w OFF

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
SET IDENTITY_INSERT sstl_se_acc_nr_w ON
INSERT INTO sstl_se_acc_nr_w (config_set_id,acc_nr_id,se_id,acc_id,acc_nr,state,config_state,aggregation_id) SELECT config_set_id,acc_nr_id,se_id,acc_id,acc_nr,state,config_state,aggregation_id FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_acc_nr_w]
SET IDENTITY_INSERT sstl_se_acc_nr_w OFF

DELETE FROM  sstl_se_amount_value_int
INSERT INTO sstl_se_amount_value_int SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_amount_value_int]

DELETE FROM  sstl_se_amount_w
SET IDENTITY_INSERT sstl_se_amount_w ON
INSERT INTO  sstl_se_amount_w (config_set_id,amount_id,se_id,name,[description],config_state)  SELECT config_set_id,amount_id,se_id,name,description,config_state FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_amount_w]
SET IDENTITY_INSERT sstl_se_amount_w OFF

DELETE FROM  sstl_se_fee_value_w
SET IDENTITY_INSERT sstl_se_fee_value_w ON
INSERT INTO sstl_se_fee_value_w (config_set_id,fee_value_id,se_id,description,fee_id,pred_id,min_value,max_value,cal_id,percentage,fixed_amount,fee_calc_strat_id,modified_fee_value_id,[state],config_state,tax_indicator) SELECT config_set_id,fee_value_id,se_id,description,fee_id,pred_id,min_value,max_value,cal_id,percentage,fixed_amount,fee_calc_strat_id,modified_fee_value_id,[state],config_state,tax_indicator FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_fee_value_w]
SET IDENTITY_INSERT sstl_se_fee_value_w OFF

DELETE FROM sstl_se_fee_w
SET IDENTITY_INSERT sstl_se_fee_w ON
INSERT INTO sstl_se_fee_w (config_set_id,fee_id,se_id,name,description,type,amount_id,config_state) SELECT config_set_id,fee_id,se_id,name,description,type,amount_id,config_state FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_fee_w]
SET IDENTITY_INSERT sstl_se_fee_w OFF

DELETE FROM sstl_se_rule_acc_post_w
SET IDENTITY_INSERT sstl_se_rule_acc_post_w ON
INSERT INTO sstl_se_rule_acc_post_w (config_set_id,acc_post_id,rule_id,amount_id,fee_id,coa_id,debit_acc_id,debit_cardholder_acc,credit_acc_id,credit_cardholder_acc,expr_granularity_element,expr_tag,config_state,tax_id,tax_indicator) SELECT config_set_id,acc_post_id,rule_id,amount_id,fee_id,coa_id,debit_acc_id,debit_cardholder_acc,credit_acc_id,credit_cardholder_acc,expr_granularity_element,expr_tag,config_state,tax_id,tax_indicator FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_rule_acc_post_w]
SET IDENTITY_INSERT sstl_se_rule_acc_post_w OFF

DELETE FROM sstl_se_w
SET IDENTITY_INSERT sstl_se_w ON
INSERT INTO sstl_se_w (config_set_id,se_id,name,description,parent_id,coa_id,se_type_id,rel_type,config_state,additional_info) SELECT config_set_id,se_id,name,description,parent_id,coa_id,se_type_id,rel_type,config_state,additional_info FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se_w]
SET IDENTITY_INSERT sstl_se_w OFF

DELETE FROM sstl_tran_field
INSERT INTO sstl_tran_field (config_version,config_set_id,tran_field_id,tran_field,expr_tran_field,data_type,config_state)  SELECT config_version,config_set_id,tran_field_id,tran_field,expr_tran_field,data_type,config_state FROM [172.25.10.69].[postilion_office].[dbo].[sstl_tran_field]

DELETE FROM sstl_tran_ident_def
INSERT INTO sstl_tran_ident_def (config_version,config_set_id,tran_ident_id,tran_ident_def_id,tran_field_id,field_value,config_state)  SELECT config_version,config_set_id,tran_ident_id,tran_ident_def_id,tran_field_id,field_value,config_state FROM [172.25.10.69].[postilion_office].[dbo].[sstl_tran_ident_def]

INSERT INTO sstl_journal_fltr_param SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_journal_fltr_param]	
INSERT INTO sstl_journal_part_info SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_journal_part_info]
INSERT INTO sstl_se	 SELECT * FROM [172.25.10.69].[postilion_office].[dbo].[sstl_se]
