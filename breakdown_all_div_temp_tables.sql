
DECLARE @from_date  VARCHAR(30)
DECLARE @to_date VARCHAR(30)

set @from_date = '20160504';
set @to_date = '20160504';

IF (OBJECT_ID('tempdb.dbo.#temp_journal_data') is not null )begin
  DROP TABLE #temp_journal_data
end

IF (OBJECT_ID('tempdb.dbo.#post_tran_data') is not null )begin
  DROP TABLE #post_tran_data
end

SELECT  

J.adj_id
,J.entry_id
,J.config_set_id
,J.session_id
,J.post_tran_id
,J.post_tran_cust_id
,J.sdi_tran_id
,J.acc_post_id
,J.nt_fee_acc_post_id
,J.coa_id
,J.coa_se_id
,J.se_id
,J.amount
,J.amount_id
,J.amount_value_id
,J.fee
,J.fee_id
,J.fee_value_id
,J.nt_fee
,J.nt_fee_id
,J.nt_fee_value_id
,J.debit_acc_nr_id
,J.debit_acc_id
,J.debit_cardholder_acc_id
,J.debit_cardholder_acc_type
,J.credit_acc_nr_id
,J.credit_acc_id
,J.credit_cardholder_acc_id
,J.credit_cardholder_acc_type
,J.business_date
,J.granularity_element
,J.tag
,J.spay_session_id
,J.spst_session_id
,DebitAccNr.config_set_id DebitAccNr_config_set_id
,DebitAccNr.acc_nr_id  DebitAccNr_acc_nr_id
,DebitAccNr.se_id	DebitAccNr_se_id
,DebitAccNr.acc_id	DebitAccNr_acc_id
,DebitAccNr.acc_nr	DebitAccNr_acc_nr
,DebitAccNr.aggregation_id DebitAccNr_aggregation_id
,DebitAccNr.state	DebitAccNr_state
,DebitAccNr.config_state DebitAccNr_config_state
,CreditAccNr.config_set_id CreditAccNr_config_set_id
,CreditAccNr.acc_nr_id  CreditAccNr_acc_nr_id
,CreditAccNr.se_id	CreditAccNr_se_id
,CreditAccNr.acc_id	CreditAccNr_acc_id
,CreditAccNr.acc_nr	CreditAccNr_acc_nr
,CreditAccNr.aggregation_id CreditAccNr_aggregation_id
,CreditAccNr.state	CreditAccNr_state
,CreditAccNr.config_state CreditAccNr_config_state
,Amount.config_set_id	Amount_config_set_id
,Amount.amount_id	Amount_amount_id
,Amount.se_id	Amount_se_id
,Amount.name	Amount_name
,Amount.description	Amount_description
,Amount.config_state	Amount_config_state
,Fee.config_set_id Fee_config_set_id
,Fee.fee_id	Fee_fee_id
,Fee.se_id	Fee_se_id
,Fee.name	Fee_name
,Fee.description Fee_description
,Fee.type	Fee_type
,Fee.amount_id Fee_amount_id
,Fee.config_state Fee_config_state
,coa.config_set_id coa_config_set_id
,coa.coa_id	coa_coa_id
,coa.name	coa_name
,coa.description	coa_description
,coa.type	coa_type
,coa.config_state	coa_config_state
INTO #temp_journal_data
FROM
dbo.sstl_journal_all AS J (NOLOCK)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
where 
 J.business_date >= @from_date  AND  J.business_date <=@to_date
OPTION (maxdop 8)


SELECT
PT.[post_tran_id]	PT_post_tran_id
,PT.[post_tran_cust_id]	PT_post_tran_cust_id
,PT.[settle_entity_id]	PT_settle_entity_id
,PT.[batch_nr]	PT_batch_nr
,PT.[prev_post_tran_id]	PT_prev_post_tran_id
,PT.[next_post_tran_id]	PT_next_post_tran_id
,PT.[sink_node_name]	PT_sink_node_name
,PT.[tran_postilion_originated]	PT_tran_postilion_originated
,PT.[tran_completed]	PT_tran_completed
,PT.[message_type]	PT_message_type
,PT.[tran_type]	PT_tran_type
,PT.[tran_nr]	PT_tran_nr
,PT.[system_trace_audit_nr]	PT_system_trace_audit_nr
,PT.[rsp_code_req]	PT_rsp_code_req
,PT.[rsp_code_rsp]	PT_rsp_code_rsp
,PT.[abort_rsp_code]	PT_abort_rsp_code
,PT.[auth_id_rsp]	PT_auth_id_rsp
,PT.[auth_type]	PT_auth_type
,PT.[auth_reason]	PT_auth_reason
,PT.[retention_data]	PT_retention_data
,PT.[acquiring_inst_id_code]	PT_acquiring_inst_id_code
,PT.[message_reason_code]	PT_message_reason_code
,PT.[sponsor_bank]	PT_sponsor_bank
,PT.[retrieval_reference_nr]	PT_retrieval_reference_nr
,PT.[datetime_tran_gmt]	PT_datetime_tran_gmt
,PT.[datetime_tran_local]	PT_datetime_tran_local
,PT.[datetime_req]	PT_datetime_req
,PT.[datetime_rsp]	PT_datetime_rsp
,PT.[realtime_business_date]	PT_realtime_business_date
,PT.[recon_business_date]	PT_recon_business_date
,PT.[from_account_type]	PT_from_account_type
,PT.[to_account_type]	PT_to_account_type
,PT.[from_account_id]	PT_from_account_id
,PT.[to_account_id]	PT_to_account_id
,PT.[tran_amount_req]	PT_tran_amount_req
,PT.[tran_amount_rsp]	PT_tran_amount_rsp
,PT.[settle_amount_impact]	PT_settle_amount_impact
,PT.[tran_cash_req]	PT_tran_cash_req
,PT.[tran_cash_rsp]	PT_tran_cash_rsp
,PT.[tran_currency_code]	PT_tran_currency_code
,PT.[tran_tran_fee_req]	PT_tran_tran_fee_req
,PT.[tran_tran_fee_rsp]	PT_tran_tran_fee_rsp
,PT.[tran_tran_fee_currency_code]	PT_tran_tran_fee_currency_code
,PT.[tran_proc_fee_req]	PT_tran_proc_fee_req
,PT.[tran_proc_fee_rsp]	PT_tran_proc_fee_rsp
,PT.[tran_proc_fee_currency_code]	PT_tran_proc_fee_currency_code
,PT.[settle_amount_req]	PT_settle_amount_req
,PT.[settle_amount_rsp]	PT_settle_amount_rsp
,PT.[settle_cash_req]	PT_settle_cash_req
,PT.[settle_cash_rsp]	PT_settle_cash_rsp
,PT.[settle_tran_fee_req]	PT_settle_tran_fee_req
,PT.[settle_tran_fee_rsp]	PT_settle_tran_fee_rsp
,PT.[settle_proc_fee_req]	PT_settle_proc_fee_req
,PT.[settle_proc_fee_rsp]	PT_settle_proc_fee_rsp
,PT.[settle_currency_code]	PT_settle_currency_code
,PT.[pos_entry_mode]	PT_pos_entry_mode
,PT.[pos_condition_code]	PT_pos_condition_code
,PT.[additional_rsp_data]	PT_additional_rsp_data
,PT.[tran_reversed]	PT_tran_reversed
,PT.[prev_tran_approved]	PT_prev_tran_approved
,PT.[issuer_network_id]	PT_issuer_network_id
,PT.[acquirer_network_id]	PT_acquirer_network_id
,PT.[extended_tran_type]	PT_extended_tran_type
,PT.[from_account_type_qualifier]	PT_from_account_type_qualifier
,PT.[to_account_type_qualifier]	PT_to_account_type_qualifier
,PT.[bank_details]	PT_bank_details
,PT.[payee]	PT_payee
,PT.[card_verification_result]	PT_card_verification_result
,PT.[online_system_id]	PT_online_system_id
,PT.[participant_id]	PT_participant_id
,PT.[opp_participant_id]	PT_opp_participant_id
,PT.[receiving_inst_id_code]	PT_receiving_inst_id_code
,PT.[routing_type]	PT_routing_type
,PT.[pt_pos_operating_environment]	PT_pt_pos_operating_environment
,PT.[pt_pos_card_input_mode]	PT_pt_pos_card_input_mode
,PT.[pt_pos_cardholder_auth_method]	PT_pt_pos_cardholder_auth_method
,PT.[pt_pos_pin_capture_ability]	PT_pt_pos_pin_capture_ability
,PT.[pt_pos_terminal_operator]	PT_pt_pos_terminal_operator
,PT.[source_node_key]	PT_source_node_key
,PT.[proc_online_system_id]	PT_proc_online_system_id
,PTC.[post_tran_cust_id]	PTC_post_tran_cust_id
,PTC.[source_node_name]	PTC_source_node_name
,PTC.[draft_capture]	PTC_draft_capture
,PTC.[pan]	PTC_pan
,PTC.[card_seq_nr]	PTC_card_seq_nr
,PTC.[expiry_date]	PTC_expiry_date
,PTC.[service_restriction_code]	PTC_service_restriction_code
,PTC.[terminal_id]	PTC_terminal_id
,PTC.[terminal_owner]	PTC_terminal_owner
,PTC.[card_acceptor_id_code]	PTC_card_acceptor_id_code
,PTC.[mapped_card_acceptor_id_code]	PTC_mapped_card_acceptor_id_code
,PTC.[merchant_type]	PTC_merchant_type
,PTC.[card_acceptor_name_loc]	PTC_card_acceptor_name_loc
,PTC.[address_verification_data]	PTC_address_verification_data
,PTC.[address_verification_result]	PTC_address_verification_result
,PTC.[check_data]	PTC_check_data
,PTC.[totals_group]	PTC_totals_group
,PTC.[card_product]	PTC_card_product
,PTC.[pos_card_data_input_ability]	PTC_pos_card_data_input_ability
,PTC.[pos_cardholder_auth_ability]	PTC_pos_cardholder_auth_ability
,PTC.[pos_card_capture_ability]	PTC_pos_card_capture_ability
,PTC.[pos_operating_environment]	PTC_pos_operating_environment
,PTC.[pos_cardholder_present]	PTC_pos_cardholder_present
,PTC.[pos_card_present]	PTC_pos_card_present
,PTC.[pos_card_data_input_mode]	PTC_pos_card_data_input_mode
,PTC.[pos_cardholder_auth_method]	PTC_pos_cardholder_auth_method
,PTC.[pos_cardholder_auth_entity]	PTC_pos_cardholder_auth_entity
,PTC.[pos_card_data_output_ability]	PTC_pos_card_data_output_ability
,PTC.[pos_terminal_output_ability]	PTC_pos_terminal_output_ability
,PTC.[pos_pin_capture_ability]	PTC_pos_pin_capture_ability
,PTC.[pos_terminal_operator]	PTC_pos_terminal_operator
,PTC.[pos_terminal_type]	PTC_pos_terminal_type
,PTC.[pan_search]	PTC_pan_search
,PTC.[pan_encrypted]	PTC_pan_encrypted
,PTC.[pan_reference]	PTC_pan_reference
,acc.acquirer_inst_id1	acc_acquirer_inst_id1
,acc.acquirer_inst_id2 acc_acquirer_inst_id2 
,acc.acquirer_inst_id3	acc_acquirer_inst_id3 
,acc.acquirer_inst_id4 acc_acquirer_inst_id4
,acc.acquirer_inst_id5  acc_acquirer_inst_id5
,acc.bank_code1 acc_bank_code1 
,acc.bank_code acc_bank_code

 INTO #post_tran_data
FROM   post_tran AS PT (NOLOCK, INDEX(ix_post_tran_9))
  JOIN Post_tran_cust AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id)
JOIN (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@from_date, @to_date))rdate
ON (rdate.recon_business_date = PT.recon_business_date)
LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or 
acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 
= PT.acquiring_inst_id_code)
OPTION (maxdop 8)


--SELECT TOP 20 * FROM dbo.sstl_journal_all AS J (NOLOCK)
--LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
--ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
--LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
--ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
--LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
--ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
--LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
--ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
--LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
--ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)

--WHERE business_date >= '20160504' and business_date <= '20160504'
