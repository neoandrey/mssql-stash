drop table #temp_sstl_count								
								
CREATE TABLE #temp_sstl_count(name varchar(500), count INT,expected_count int);								
								
INSERT INTO #temp_sstl_count (name, count, expected_count)								
SELECT	'spay_acc_rel_type' ,	COUNT(*)		,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_acc_rel_type	) expected_count	FROM	spay_acc_rel_type
UNION	SELECT	'spay_aggr_strategy',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_aggr_strategy	) expected_count	FROM	spay_aggr_strategy
UNION	SELECT	'spay_aggregation',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_aggregation	) expected_count	FROM	spay_aggregation
UNION	SELECT	'spay_aggregation_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_aggregation_w	) expected_count	FROM	spay_aggregation_w
UNION	SELECT	'spay_amount_pay_next_date',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_amount_pay_next_date	) expected_count	FROM	spay_amount_pay_next_date
UNION	SELECT	'spay_bdate_fltr_ssn',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_bdate_fltr_ssn	) expected_count	FROM	spay_bdate_fltr_ssn
UNION	SELECT	'spay_fee_pay_next_date',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_fee_pay_next_date	) expected_count	FROM	spay_fee_pay_next_date
UNION	SELECT	'spay_plugin',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_plugin	) expected_count	FROM	spay_plugin
UNION	SELECT	'spay_proc_ent',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_proc_ent	) expected_count	FROM	spay_proc_ent
UNION	SELECT	'spay_proc_ent_fltr_grp',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_proc_ent_fltr_grp	) expected_count	FROM	spay_proc_ent_fltr_grp
UNION	SELECT	'spay_proc_ent_fltr_grp_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_proc_ent_fltr_grp_w	) expected_count	FROM	spay_proc_ent_fltr_grp_w
UNION	SELECT	'spay_proc_ent_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_proc_ent_w	) expected_count	FROM	spay_proc_ent_w
UNION	SELECT	'spay_residue_ach',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_residue_ach	) expected_count	FROM	spay_residue_ach
UNION	SELECT	'spay_residue_strategy',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_residue_strategy	) expected_count	FROM	spay_residue_strategy
UNION	SELECT	'spay_se_acc',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_acc	) expected_count	FROM	spay_se_acc
UNION	SELECT	'spay_se_acc_rel',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_acc_rel	) expected_count	FROM	spay_se_acc_rel
UNION	SELECT	'spay_se_acc_rel_param',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_acc_rel_param	) expected_count	FROM	spay_se_acc_rel_param
UNION	SELECT	'spay_se_acc_rel_param_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_acc_rel_param_w	) expected_count	FROM	spay_se_acc_rel_param_w
UNION	SELECT	'spay_se_acc_rel_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_acc_rel_w	) expected_count	FROM	spay_se_acc_rel_w
UNION	SELECT	'spay_se_acc_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_acc_w	) expected_count	FROM	spay_se_acc_w
UNION	SELECT	'spay_se_amount_pay_freq',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_amount_pay_freq	) expected_count	FROM	spay_se_amount_pay_freq
UNION	SELECT	'spay_se_amount_pay_freq_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_amount_pay_freq_w	) expected_count	FROM	spay_se_amount_pay_freq_w
UNION	SELECT	'spay_se_fee_pay_freq',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_fee_pay_freq	) expected_count	FROM	spay_se_fee_pay_freq
UNION	SELECT	'spay_se_fee_pay_freq_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_se_fee_pay_freq_w	) expected_count	FROM	spay_se_fee_pay_freq_w
UNION	SELECT	'spay_session',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_session	) expected_count	FROM	spay_session
UNION	SELECT	'spay_statement_profile',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_statement_profile	) expected_count	FROM	spay_statement_profile
UNION	SELECT	'spay_statement_profile_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_statement_profile_w	) expected_count	FROM	spay_statement_profile_w
UNION	SELECT	'spay_unpaid_payments',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spay_unpaid_payments	) expected_count	FROM	spay_unpaid_payments
UNION	SELECT	'spst_aggr_strategy',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_aggr_strategy	) expected_count	FROM	spst_aggr_strategy
UNION	SELECT	'spst_aggregation',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_aggregation	) expected_count	FROM	spst_aggregation
UNION	SELECT	'spst_aggregation_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_aggregation_w	) expected_count	FROM	spst_aggregation_w
UNION	SELECT	'spst_amount_pst_next_date',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_amount_pst_next_date	) expected_count	FROM	spst_amount_pst_next_date
UNION	SELECT	'spst_bdate_fltr_ssn',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_bdate_fltr_ssn	) expected_count	FROM	spst_bdate_fltr_ssn
UNION	SELECT	'spst_fee_pst_next_date',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_fee_pst_next_date	) expected_count	FROM	spst_fee_pst_next_date
UNION	SELECT	'spst_plugin',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_plugin	) expected_count	FROM	spst_plugin
UNION	SELECT	'spst_proc_ent',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_proc_ent	) expected_count	FROM	spst_proc_ent
UNION	SELECT	'spst_proc_ent_fltr_grp',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_proc_ent_fltr_grp	) expected_count	FROM	spst_proc_ent_fltr_grp
UNION	SELECT	'spst_proc_ent_fltr_grp_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_proc_ent_fltr_grp_w	) expected_count	FROM	spst_proc_ent_fltr_grp_w
UNION	SELECT	'spst_proc_ent_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_proc_ent_w	) expected_count	FROM	spst_proc_ent_w
UNION	SELECT	'spst_residue_strategy',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_residue_strategy	) expected_count	FROM	spst_residue_strategy
UNION	SELECT	'spst_se_amount_pst_freq',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_se_amount_pst_freq	) expected_count	FROM	spst_se_amount_pst_freq
UNION	SELECT	'spst_se_amount_pst_freq_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_se_amount_pst_freq_w	) expected_count	FROM	spst_se_amount_pst_freq_w
UNION	SELECT	'spst_se_fee_pst_freq',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_se_fee_pst_freq	) expected_count	FROM	spst_se_fee_pst_freq
UNION	SELECT	'spst_se_fee_pst_freq_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_se_fee_pst_freq_w	) expected_count	FROM	spst_se_fee_pst_freq_w
UNION	SELECT	'spst_session',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_session	) expected_count	FROM	spst_session
UNION	SELECT	'spst_statement_profile',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_statement_profile	) expected_count	FROM	spst_statement_profile
UNION	SELECT	'spst_statement_profile_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.spst_statement_profile_w	) expected_count	FROM	spst_statement_profile_w
UNION	SELECT	'ssdi_plugin',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.ssdi_plugin	) expected_count	FROM	ssdi_plugin
UNION	SELECT	'ssdi_proc_ent',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.ssdi_proc_ent	) expected_count	FROM	ssdi_proc_ent
UNION	SELECT	'ssdi_proc_ent_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.ssdi_proc_ent_w	) expected_count	FROM	ssdi_proc_ent_w
UNION	SELECT	'ssdi_session',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.ssdi_session	) expected_count	FROM	ssdi_session
UNION	SELECT	'ssdi_tran',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.ssdi_tran	) expected_count	FROM	ssdi_tran
UNION	SELECT	'sstl_acc',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_acc	) expected_count	FROM	sstl_acc
UNION	SELECT	'sstl_acc_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_acc_w	) expected_count	FROM	sstl_acc_w
UNION	SELECT	'sstl_coa',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_coa	) expected_count	FROM	sstl_coa
UNION	SELECT	'sstl_coa_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_coa_w	) expected_count	FROM	sstl_coa_w
UNION	SELECT	'sstl_config_set',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_config_set	) expected_count	FROM	sstl_config_set
UNION	SELECT	'sstl_config_version',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_config_version	) expected_count	FROM	sstl_config_version
UNION	SELECT	'sstl_exception',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_exception	) expected_count	FROM	sstl_exception
UNION	SELECT	'sstl_fee_calc_strat',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_fee_calc_strat	) expected_count	FROM	sstl_fee_calc_strat
UNION	SELECT	'sstl_func',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_func	) expected_count	FROM	sstl_func
--UNION	SELECT	'sstl_journal_1',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_1	) expected_count	FROM	sstl_journal_1
UNION	SELECT	'sstl_journal_adj',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_adj	) expected_count	FROM	sstl_journal_adj
UNION	SELECT	'sstl_journal_entry_insert_fltr',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_entry_insert_fltr	) expected_count	FROM	sstl_journal_entry_insert_fltr
UNION	SELECT	'sstl_journal_fltr',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_fltr	) expected_count	FROM	sstl_journal_fltr
UNION	SELECT	'sstl_journal_fltr_grp',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_fltr_grp	) expected_count	FROM	sstl_journal_fltr_grp
UNION	SELECT	'sstl_journal_fltr_grp_elem',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_fltr_grp_elem	) expected_count	FROM	sstl_journal_fltr_grp_elem
UNION	SELECT	'sstl_journal_fltr_grp_elem_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_fltr_grp_elem_w	) expected_count	FROM	sstl_journal_fltr_grp_elem_w
UNION	SELECT	'sstl_journal_fltr_grp_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_fltr_grp_w	) expected_count	FROM	sstl_journal_fltr_grp_w
UNION	SELECT	'sstl_journal_fltr_param',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_fltr_param	) expected_count	FROM	sstl_journal_fltr_param
UNION	SELECT	'sstl_journal_fltr_param_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_fltr_param_w	) expected_count	FROM	sstl_journal_fltr_param_w
UNION	SELECT	'sstl_journal_part_info',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_journal_part_info	) expected_count	FROM	sstl_journal_part_info
UNION	SELECT	'sstl_method',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_method	) expected_count	FROM	sstl_method
UNION	SELECT	'sstl_nt_fee_calc_strat',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_nt_fee_calc_strat	) expected_count	FROM	sstl_nt_fee_calc_strat
UNION	SELECT	'sstl_nt_fee_levy_hist',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_nt_fee_levy_hist	) expected_count	FROM	sstl_nt_fee_levy_hist
UNION	SELECT	'sstl_pred',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_pred	) expected_count	FROM	sstl_pred
UNION	SELECT	'sstl_pred_prop_value',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_pred_prop_value	) expected_count	FROM	sstl_pred_prop_value
UNION	SELECT	'sstl_pred_prop_value_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_pred_prop_value_w	) expected_count	FROM	sstl_pred_prop_value_w
UNION	SELECT	'sstl_pred_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_pred_w	) expected_count	FROM	sstl_pred_w
UNION	SELECT	'sstl_proc_ent',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_proc_ent	) expected_count	FROM	sstl_proc_ent
UNION	SELECT	'sstl_proc_ent_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_proc_ent_w	) expected_count	FROM	sstl_proc_ent_w
UNION	SELECT	'sstl_prop',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_prop	) expected_count	FROM	sstl_prop
UNION	SELECT	'sstl_prop_value',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_prop_value	) expected_count	FROM	sstl_prop_value
UNION	SELECT	'sstl_prop_value_node',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_prop_value_node	) expected_count	FROM	sstl_prop_value_node
UNION	SELECT	'sstl_prop_value_node_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_prop_value_node_w	) expected_count	FROM	sstl_prop_value_node_w
UNION	SELECT	'sstl_prop_value_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_prop_value_w	) expected_count	FROM	sstl_prop_value_w
UNION	SELECT	'sstl_prop_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_prop_w	) expected_count	FROM	sstl_prop_w
UNION	SELECT	'sstl_se',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se	) expected_count	FROM	sstl_se
UNION	SELECT	'sstl_se_acc_nr',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_acc_nr	) expected_count	FROM	sstl_se_acc_nr
UNION	SELECT	'sstl_se_acc_nr_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_acc_nr_w	) expected_count	FROM	sstl_se_acc_nr_w
UNION	SELECT	'sstl_se_additional_info',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_additional_info	) expected_count	FROM	sstl_se_additional_info
UNION	SELECT	'sstl_se_amount',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_amount	) expected_count	FROM	sstl_se_amount
UNION	SELECT	'sstl_se_amount_value',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_amount_value	) expected_count	FROM	sstl_se_amount_value
UNION	SELECT	'sstl_se_amount_value_int',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_amount_value_int	) expected_count	FROM	sstl_se_amount_value_int
UNION	SELECT	'sstl_se_amount_value_int_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_amount_value_int_w	) expected_count	FROM	sstl_se_amount_value_int_w
UNION	SELECT	'sstl_se_amount_value_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_amount_value_w	) expected_count	FROM	sstl_se_amount_value_w
UNION	SELECT	'sstl_se_amount_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_amount_w	) expected_count	FROM	sstl_se_amount_w
UNION	SELECT	'sstl_se_cal',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_cal	) expected_count	FROM	sstl_se_cal
UNION	SELECT	'sstl_se_cal_date_range',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_cal_date_range	) expected_count	FROM	sstl_se_cal_date_range
UNION	SELECT	'sstl_se_cal_date_range_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_cal_date_range_w	) expected_count	FROM	sstl_se_cal_date_range_w
UNION	SELECT	'sstl_se_cal_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_cal_w	) expected_count	FROM	sstl_se_cal_w
UNION	SELECT	'sstl_se_fee',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_fee	) expected_count	FROM	sstl_se_fee
UNION	SELECT	'sstl_se_fee_priority',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_fee_priority	) expected_count	FROM	sstl_se_fee_priority
UNION	SELECT	'sstl_se_fee_priority_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_fee_priority_w	) expected_count	FROM	sstl_se_fee_priority_w
UNION	SELECT	'sstl_se_fee_value',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_fee_value	) expected_count	FROM	sstl_se_fee_value
UNION	SELECT	'sstl_se_fee_value_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_fee_value_w	) expected_count	FROM	sstl_se_fee_value_w
UNION	SELECT	'sstl_se_fee_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_fee_w	) expected_count	FROM	sstl_se_fee_w
UNION	SELECT	'sstl_se_nt_fee',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_nt_fee	) expected_count	FROM	sstl_se_nt_fee
UNION	SELECT	'sstl_se_nt_fee_acc_post',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_nt_fee_acc_post	) expected_count	FROM	sstl_se_nt_fee_acc_post
UNION	SELECT	'sstl_se_nt_fee_acc_post_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_nt_fee_acc_post_w	) expected_count	FROM	sstl_se_nt_fee_acc_post_w
UNION	SELECT	'sstl_se_nt_fee_value',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_nt_fee_value	) expected_count	FROM	sstl_se_nt_fee_value
UNION	SELECT	'sstl_se_nt_fee_value_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_nt_fee_value_w	) expected_count	FROM	sstl_se_nt_fee_value_w
UNION	SELECT	'sstl_se_nt_fee_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_nt_fee_w	) expected_count	FROM	sstl_se_nt_fee_w
UNION	SELECT	'sstl_se_rule',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_rule	) expected_count	FROM	sstl_se_rule
UNION	SELECT	'sstl_se_rule_acc_post',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_rule_acc_post	) expected_count	FROM	sstl_se_rule_acc_post
UNION	SELECT	'sstl_se_rule_acc_post_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_rule_acc_post_w	) expected_count	FROM	sstl_se_rule_acc_post_w
UNION	SELECT	'sstl_se_rule_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_rule_w	) expected_count	FROM	sstl_se_rule_w
UNION	SELECT	'sstl_se_statement',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_statement	) expected_count	FROM	sstl_se_statement
UNION	SELECT	'sstl_se_statement_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_statement_w	) expected_count	FROM	sstl_se_statement_w
UNION	SELECT	'sstl_se_tax',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_tax	) expected_count	FROM	sstl_se_tax
UNION	SELECT	'sstl_se_tax_rate',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_tax_rate	) expected_count	FROM	sstl_se_tax_rate
UNION	SELECT	'sstl_se_tax_rate_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_tax_rate_w	) expected_count	FROM	sstl_se_tax_rate_w
UNION	SELECT	'sstl_se_tax_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_tax_w	) expected_count	FROM	sstl_se_tax_w
UNION	SELECT	'sstl_se_third_party',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_third_party	) expected_count	FROM	sstl_se_third_party
UNION	SELECT	'sstl_se_third_party_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_third_party_w	) expected_count	FROM	sstl_se_third_party_w
UNION	SELECT	'sstl_se_type',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_type	) expected_count	FROM	sstl_se_type
UNION	SELECT	'sstl_se_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_se_w	) expected_count	FROM	sstl_se_w
UNION	SELECT	'sstl_session',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_session	) expected_count	FROM	sstl_session
UNION	SELECT	'sstl_statement_output_method',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_statement_output_method	) expected_count	FROM	sstl_statement_output_method
UNION	SELECT	'sstl_statement_plugin',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_statement_plugin	) expected_count	FROM	sstl_statement_plugin
UNION	SELECT	'sstl_statement_profile',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_statement_profile	) expected_count	FROM	sstl_statement_profile
UNION	SELECT	'sstl_statement_profile_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_statement_profile_w	) expected_count	FROM	sstl_statement_profile_w
UNION	SELECT	'sstl_statement_report',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_statement_report	) expected_count	FROM	sstl_statement_report
UNION	SELECT	'sstl_stmt_standard_session',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_stmt_standard_session	) expected_count	FROM	sstl_stmt_standard_session
UNION	SELECT	'sstl_stmt_standard_summary',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_stmt_standard_summary	) expected_count	FROM	sstl_stmt_standard_summary
UNION	SELECT	'sstl_table_meta_data',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_table_meta_data	) expected_count	FROM	sstl_table_meta_data
UNION	SELECT	'sstl_tran_field',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tran_field	) expected_count	FROM	sstl_tran_field
UNION	SELECT	'sstl_tran_field_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tran_field_w	) expected_count	FROM	sstl_tran_field_w
UNION	SELECT	'sstl_tran_ident',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tran_ident	) expected_count	FROM	sstl_tran_ident
UNION	SELECT	'sstl_tran_ident_def',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tran_ident_def	) expected_count	FROM	sstl_tran_ident_def
UNION	SELECT	'sstl_tran_ident_def_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tran_ident_def_w	) expected_count	FROM	sstl_tran_ident_def_w
UNION	SELECT	'sstl_tran_ident_w',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tran_ident_w	) expected_count	FROM	sstl_tran_ident_w
UNION	SELECT	'sstl_tran_set',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tran_set	) expected_count	FROM	sstl_tran_set
UNION	SELECT	'sstl_tt_amount_next_date',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tt_amount_next_date	) expected_count	FROM	sstl_tt_amount_next_date
UNION	SELECT	'sstl_tt_exclude',	COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tt_exclude	) expected_count	FROM	sstl_tt_exclude
UNION	SELECT	'sstl_tt_fee_next_date'	,COUNT(*)	,(	SELECT COUNT(*) FROM [192.168.15.9].postilion_office.dbo.sstl_tt_fee_next_date	) expected_count	FROM	sstl_tt_fee_next_date
								
								
--SELECT * FROM #temp_sstl_count ORDER BY name								

SELECT * FROM #temp_sstl_count WHERE [count] !=expected_count


