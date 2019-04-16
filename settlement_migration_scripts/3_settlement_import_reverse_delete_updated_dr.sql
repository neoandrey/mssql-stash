INSERT INTO  sstl_config_set SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_config_set]
INSERT INTO  dbo.sstl_config_version SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_config_version]
INSERT INTO  sstl_tran_set  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_set]
INSERT INTO  sstl_tran_ident  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_ident]
INSERT INTO  sstl_table_meta_data  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_table_meta_data]
INSERT INTO  sstl_statement_output_method SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_statement_output_method]

DELETE FROM  sstl_coa_w
SET IDENTITY_INSERT sstl_coa_w ON
INSERT INTO sstl_coa_w (config_set_id,coa_id,name,[description],[type],config_state) SELECT config_set_id,coa_id,name,[description],[type],config_state FROM [192.168.15.65].[postilion_office].[dbo].[sstl_coa_w]
SET IDENTITY_INSERT sstl_coa_w OFF


INSERT INTO  sstl_se_type   SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_type]

DELETE FROM sstl_se_w
SET IDENTITY_INSERT sstl_se_w ON
INSERT INTO sstl_se_w (config_set_id,se_id,name,description,parent_id,coa_id,se_type_id,rel_type,config_state,additional_info) SELECT config_set_id,se_id,name,description,parent_id,coa_id,se_type_id,rel_type,config_state,additional_info FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_w]
SET IDENTITY_INSERT sstl_se_w OFF

DELETE FROM  sstl_se_amount_w
SET IDENTITY_INSERT sstl_se_amount_w ON
INSERT INTO  sstl_se_amount_w (config_set_id,amount_id,se_id,name,[description],config_state)  SELECT config_set_id,amount_id,se_id,name,description,config_state FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_amount_w]
SET IDENTITY_INSERT sstl_se_amount_w OFF





INSERT INTO   sstl_se_rule_acc_post (
config_version
,config_set_id
,acc_post_id
,rule_id
,amount_id
,fee_id
,tax_id
,tax_indicator
,coa_id
,debit_acc_id
,debit_cardholder_acc
,credit_acc_id
,credit_cardholder_acc
,expr_granularity_element
,expr_tag
,config_state
)   SELECT 
config_version
,config_set_id
,acc_post_id
,rule_id
,amount_id
,fee_id
,tax_id
,tax_indicator
,coa_id
,debit_acc_id
,debit_cardholder_acc
,credit_acc_id
,credit_cardholder_acc
,expr_granularity_element
,expr_tag
,config_state

 FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_rule_acc_post]

INSERT INTO  sstl_se_rule SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_rule]
INSERT INTO   sstl_se_fee_value (
config_version
,config_set_id
,fee_value_id
,se_id
,description
,fee_id
,pred_id
,min_value
,max_value
,cal_id
,percentage
,fixed_amount
,tax_indicator
,fee_calc_strat_id
,modified_fee_value_id
,state
,config_state
)
 SELECT config_version
,config_set_id
,fee_value_id
,se_id
,description
,fee_id
,pred_id
,min_value
,max_value
,cal_id
,percentage
,fixed_amount
,tax_indicator
,fee_calc_strat_id
,modified_fee_value_id
,state
,config_state FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_fee_value]
INSERT INTO  sstl_se_fee  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_fee]
INSERT INTO  sstl_se_amount_value_int  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_amount_value_int]
INSERT INTO  sstl_se_amount_value
(
config_version
,config_set_id
,amount_value_id
,se_id
,amount_id
,description
,pred_id
,tax_indicator
,tiered
,expr_domain
,modified_amount_value_id
,state
,config_state

)
 SELECT config_version
,config_set_id
,amount_value_id
,se_id
,amount_id
,description
,pred_id
,tax_indicator
,tiered
,expr_domain
,modified_amount_value_id
,state
,config_state FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_amount_value]

INSERT INTO  sstl_se_amount SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_amount]
INSERT INTO  sstl_prop SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_prop]

INSERT INTO  sstl_proc_ent_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_proc_ent_w]

INSERT INTO  dbo.sstl_coa  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_coa]
INSERT INTO  dbo.sstl_tran_ident_def  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_ident_def]
INSERT INTO  dbo.sstl_journal_fltr_grp_elem  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_journal_fltr_grp_elem]


INSERT INTO spay_aggregation SELECT * FROM [192.168.15.65].[postilion_office].[dbo].[spay_aggregation]

INSERT INTO spst_aggregation SELECT * FROM [192.168.15.65].[postilion_office].[dbo].[spst_aggregation]

INSERT INTO  dbo.spay_aggregation_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[spay_aggregation_w]

INSERT INTO spst_proc_ent SELECT * FROM [192.168.15.65].[postilion_office].[dbo].[spst_proc_ent]

INSERT INTO spst_plugin SELECT * FROM [192.168.15.65].[postilion_office].[dbo].spst_plugin
INSERT INTO  dbo.sstl_pred SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_pred]
INSERT INTO  dbo.sstl_pred_w  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_pred_w]

--DELETE FROM sstl_se_amount_value_w
--SET IDENTITY_INSERT sstl_se_amount_value_w ON
--INSERT INTO sstl_se_amount_value_w (config_set_id,amount_value_id,se_id,amount_id,description,pred_id,tiered,expr_domain,modified_amount_value_id,state,config_state,tax_indicator) SELECT config_set_id,amount_value_id,se_id,amount_id,description,pred_id,tiered,expr_domain,modified_amount_value_id,state,config_state,tax_indicator FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_amount_value_w]
--SET IDENTITY_INSERT sstl_se_amount_value_w OFF

INSERT INTO  dbo.sstl_exception SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_exception]

INSERT INTO  dbo.sstl_prop_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_prop_w]

INSERT INTO spst_residue_strategy SELECT * FROM [192.168.15.65].[postilion_office].[dbo].[spst_residue_strategy]

INSERT INTO  dbo.sstl_prop_value_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_prop_value_w]

INSERT INTO  sstl_pred_prop_value_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_pred_prop_value_w]

INSERT INTO  sstl_prop_value_node_w  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_prop_value_node_w]


INSERT INTO  sstl_tran_field_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_field_w]
INSERT INTO  sstl_tran_ident_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_ident_w]
INSERT INTO  dbo.sstl_tran_ident_def_w  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_ident_def_w]
INSERT INTO  dbo.sstl_session SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_session]



DELETE FROM sstl_se_amount_value_w
SET IDENTITY_INSERT sstl_se_amount_value_w ON
INSERT INTO sstl_se_amount_value_w (config_set_id,amount_value_id,se_id,amount_id,description,pred_id,tiered,expr_domain,modified_amount_value_id,state,config_state,tax_indicator) SELECT config_set_id,amount_value_id,se_id,amount_id,description,pred_id,tiered,expr_domain,modified_amount_value_id,state,config_state,tax_indicator FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_amount_value_w]
SET IDENTITY_INSERT sstl_se_amount_value_w OFF

INSERT INTO  dbo.sstl_se_amount_value_int_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_amount_value_int_w]

INSERT INTO  dbo.spst_aggregation_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[spst_aggregation_w]


DELETE FROM sstl_se_fee_w
SET IDENTITY_INSERT sstl_se_fee_w ON
INSERT INTO sstl_se_fee_w (config_set_id,fee_id,se_id,name,description,type,amount_id,config_state) SELECT config_set_id,fee_id,se_id,name,description,type,amount_id,config_state FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_fee_w]
SET IDENTITY_INSERT sstl_se_fee_w OFF


DELETE FROM  sstl_se_fee_value_w
SET IDENTITY_INSERT sstl_se_fee_value_w ON
INSERT INTO sstl_se_fee_value_w (config_set_id,fee_value_id,se_id,description,fee_id,pred_id,min_value,max_value,cal_id,percentage,fixed_amount,fee_calc_strat_id,modified_fee_value_id,[state],config_state,tax_indicator) SELECT config_set_id,fee_value_id,se_id,description,fee_id,pred_id,min_value,max_value,cal_id,percentage,fixed_amount,fee_calc_strat_id,modified_fee_value_id,[state],config_state,tax_indicator FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_fee_value_w]
SET IDENTITY_INSERT sstl_se_fee_value_w OFF


INSERT INTO  spst_proc_ent_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[spst_proc_ent_w]
INSERT INTO  sstl_journal_fltr_grp_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_journal_fltr_grp_w]
INSERT INTO  spst_proc_ent_fltr_grp_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[spst_proc_ent_fltr_grp_w]


INSERT INTO  sstl_journal_part_info SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_journal_part_info]

INSERT INTO  sstl_se_rule_w SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_rule_w]
DELETE FROM  sstl_acc_w
SET IDENTITY_INSERT sstl_acc_w ON
INSERT INTO sstl_acc_w (config_set_id,acc_id,coa_id,name,description,config_state) SELECT config_set_id,acc_id,coa_id,name,description,config_state FROM [192.168.15.65].[postilion_office].[dbo].[sstl_acc_w]
SET IDENTITY_INSERT sstl_acc_w OFF

DELETE FROM sstl_se_rule_acc_post_w
SET IDENTITY_INSERT sstl_se_rule_acc_post_w ON
INSERT INTO sstl_se_rule_acc_post_w (config_set_id,acc_post_id,rule_id,amount_id,fee_id,coa_id,debit_acc_id,debit_cardholder_acc,credit_acc_id,credit_cardholder_acc,expr_granularity_element,expr_tag,config_state,tax_id,tax_indicator) SELECT config_set_id,acc_post_id,rule_id,amount_id,fee_id,coa_id,debit_acc_id,debit_cardholder_acc,credit_acc_id,credit_cardholder_acc,expr_granularity_element,expr_tag,config_state,tax_id,tax_indicator FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_rule_acc_post_w]
SET IDENTITY_INSERT sstl_se_rule_acc_post_w OFF

--INSERT INTO  sstl_se_type SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_type]

INSERT INTO  dbo.sstl_acc SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_acc]

DELETE FROM  sstl_se_acc_nr_w
SET IDENTITY_INSERT sstl_se_acc_nr_w ON
INSERT INTO sstl_se_acc_nr_w (config_set_id,acc_nr_id,se_id,acc_id,acc_nr,state,config_state,aggregation_id) SELECT config_set_id,acc_nr_id,se_id,acc_id,acc_nr,state,config_state,aggregation_id FROM [192.168.15.65].[postilion_office].[dbo].[sstl_se_acc_nr_w]
SET IDENTITY_INSERT sstl_se_acc_nr_w OFF

INSERT INTO   sstl_se_acc_nr
(

config_version
,config_set_id
,acc_nr_id
,se_id
,acc_id
,acc_nr
,aggregation_id
,state
,config_state
) SELECT config_version
,config_set_id
,acc_nr_id
,se_id
,acc_id
,acc_nr
,aggregation_id
,state
,config_state FROM [192.168.15.65].[postilion_office].dbo.[sstl_se_acc_nr]
--INSERT INTO  sstl_config_version SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_config_version]
--INSERT INTO   dbo.sstl_coa SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_coa]
INSERT INTO  dbo.sstl_journal_fltr_param SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_journal_fltr_param]
--INSERT INTO  dbo.sstl_tran_ident_def SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_ident_def]
INSERT INTO  dbo.sstl_prop_value_node   SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_prop_value_node]
INSERT INTO  dbo.sstl_tran_field    SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_tran_field]
INSERT INTO  dbo.sstl_prop_value    SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_prop_value]
INSERT INTO  dbo.sstl_journal_fltr_grp   SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_journal_fltr_grp]
INSERT INTO  dbo.sstl_proc_ent SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_proc_ent]
--INSERT INTO  dbo.sstl_journal_fltr_grp_elem SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_journal_fltr_grp_elem]
INSERT INTO  dbo.sstl_journal_1  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_journal_1]
INSERT INTO  dbo.sstl_pred_prop_value  SELECT * FROM [192.168.15.65].[postilion_office].dbo.[sstl_pred_prop_value]
INSERT INTO  dbo.spst_proc_ent_fltr_grp SELECT * FROM [192.168.15.65].[postilion_office].dbo.[spst_proc_ent_fltr_grp]
INSERT INTO  sstl_se(
config_version
,config_set_id
,se_id
,name
,description
,parent_id
,coa_id
,se_type_id
,rel_type
,additional_info
,config_state



) SELECT config_version
,config_set_id
,se_id
,name
,description
,parent_id
,coa_id
,se_type_id
,rel_type
,additional_info
,config_state
 FROM [192.168.15.65].[postilion_office].dbo.[sstl_se]
EXEC sp_MSForEachTable 'ALTER TABLE ? CHECK CONSTRAINT ALL'