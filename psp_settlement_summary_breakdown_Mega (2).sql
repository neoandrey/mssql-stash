USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown_Mega]    Script Date: 09/27/2016 17:13:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[psp_settlement_summary_breakdown_dry_run]  NULL,NULL,null,null,null,null






ALTER      PROCEDURE [dbo].[psp_settlement_summary_breakdown_Mega](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
    @rpt_tran_id1 INT = NULL
)
AS
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set NOCOUNT ON
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,-1,GETDATE()),111),'/',''))
SET @to_date   = ISNULL(@end_date,REPLACE(CONVERT(VARCHAR(MAX), DATEADD(D,-1,GETDATE()),111),'/',''))

IF((SELECT  COUNT(PT_post_tran_id) FROM temp_post_tran_data (nolock) WHERE PT_recon_business_date=@from_date)< 100 ) BEGIN


	IF (OBJECT_ID('postilion_office.dbo.temp_journal_data') is not null )begin
	  DROP TABLE temp_journal_data
	end

	IF (OBJECT_ID('postilion_office.dbo.temp_post_tran_data') is not null )begin
	  DROP TABLE temp_post_tran_data
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
	,fee.name	Fee_name
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
	,FeeValue.description FeeValue_description
	INTO temp_journal_data
	FROM
	dbo.sstl_journal_all AS J (NOLOCK)
	JOIN (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@from_date, @to_date))rdate
	ON (rdate.recon_business_date =  J.business_date)
	LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
	ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
	LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
	ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
	LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
	ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
	LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
	ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
	LEFT OUTER JOIN dbo.sstl_se_fee_value_w AS FeeValue (NOLOCK)
ON (J.fee_id = FeeValue.fee_id AND J.config_set_id = FeeValue.config_set_id)
	LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
	ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
	OPTION (recompile,maxdop 8)


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
	 INTO temp_post_tran_data
	FROM   post_tran AS PT  WITH (NOLOCK, INDEX(ix_post_tran_9))
	JOIN (SELECT  [DATE] recon_business_date FROM  dbo.[get_dates_in_range](@from_date, @to_date))rdate
	ON (rdate.recon_business_date = PT.recon_business_date) AND  PT.tran_postilion_originated = 0
	AND PT.post_tran_id NOT IN (
						SELECT  post_tran_id  FROM tbl_late_reversals ll (NOLOCK) 
			WHERE ll.recon_business_date >= @report_date_start
			and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
						) AND
						rsp_code_rsp IN ('00','11','09')
	 LEFT JOIN  Post_tran_cust AS PTC WITH  (NOLOCK, INDEX(pk_post_tran_cust))
	 on PT.post_tran_cust_id = PTC.post_tran_cust_id
	OPTION (RECOMPILE,maxdop 8)

	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_1 ON temp_post_tran_data (PT_message_type )
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_2 ON temp_post_tran_data (PT_tran_type);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_3 ON temp_post_tran_data (PTC_source_node_name);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_4 ON temp_post_tran_data (PT_sink_node_name);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_5 ON temp_post_tran_data (PTC_terminal_id);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_6 ON temp_post_tran_data (PTC_totals_group);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_7 ON temp_post_tran_data (PTC_pan);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_9 ON temp_post_tran_data (PT_acquiring_inst_id_code);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_10 ON temp_post_tran_data (PT_settle_amount_impact);

	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_11 ON temp_post_tran_data (

	PT_message_type,
	PT_tran_type,
	PTC_source_node_name,
	PT_sink_node_name,
	PTC_terminal_id,
	PTC_totals_group,
	PTC_pan,
	PT_settle_amount_impact,
	PT_acquiring_inst_id_code
	);

	CREATE INDEX [ix_temp_post_tran_data_12]    ON [dbo].[temp_post_tran_data]    ([PT_tran_postilion_originated])      INCLUDE ([PT_post_tran_cust_id], [PT_tran_nr], [PT_retention_data])      WITH (FILLFACTOR=90)
	CREATE INDEX [ix_temp_post_tran_data_13]    ON [dbo].[temp_post_tran_data]    ([PT_post_tran_cust_id], [PT_tran_postilion_originated], [PT_tran_nr])      INCLUDE ([PT_retention_data])      WITH (FILLFACTOR=90)
	CREATE INDEX [ix_temp_post_tran_data_14]    ON [dbo]    .[temp_post_tran_data]([PT_tran_postilion_originated], [PTC_totals_group])      INCLUDE ([PT_post_tran_id], [PT_post_tran_cust_id], [PT_sink_node_name], [PT_message_type], [PT_tran_type], [PT_tran_nr], [PT_system_trace_audit_nr], [PT_acquiring_inst_id_code], [PT_retrieval_reference_nr], [PT_settle_amount_impact], [PT_settle_amount_rsp], [PT_settle_currency_code], [PT_tran_reversed], [PT_extended_tran_type], [PT_payee], [PTC_source_node_name], [PTC_pan], [PTC_terminal_id], [PTC_card_acceptor_id_code], [PTC_merchant_type], [PTC_card_acceptor_name_loc])      WITH (FILLFACTOR=90)
	CREATE NONCLUSTERED INDEX [ix_temp_post_tran_data_15] ON [dbo].[temp_post_tran_data] ([PT_recon_business_date])

 CREATE INDEX [ix_temp_post_tran_data_16]    ON [dbo]    .[temp_post_tran_data]    ([PT_tran_postilion_originated], [PT_message_type], [PT_rsp_code_rsp], [PT_settle_amount_impact])      INCLUDE ([PT_sink_node_name], [PT_system_trace_audit_nr], [PT_retrieval_reference_nr], [PT_to_account_id], [PT_payee], [PTC_source_node_name], [PTC_pan], [PTC_terminal_id])      WITH (FILLFACTOR=70, ONLINE=ON)
	CREATE NONCLUSTERED INDEX [temp_post_tran_data_recon] ON [dbo].[temp_post_tran_data] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_settle_currency_code] ASC,
	[PT_sink_node_name] ASC,
	[PT_tran_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PTC_source_node_name] ASC,
	[PTC_card_acceptor_id_code] ASC,
	[PTC_totals_group] ASC
)
	INCLUDE (
	
	 [PT_post_tran_id],
	[PT_post_tran_cust_id],
	[PT_message_type],
	[PT_system_trace_audit_nr],
	[PT_acquiring_inst_id_code],
	[PT_retrieval_reference_nr],
	[PT_settle_amount_impact],
	[PT_settle_amount_rsp],
	[PT_tran_reversed],
	[PT_extended_tran_type],
	[PT_payee],
	[PTC_pan],
	[PTC_terminal_id],
	[PTC_terminal_owner],
	[PTC_merchant_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_17 ON temp_post_tran_data (PT_extended_tran_type);
	CREATE NONCLUSTERED INDEX ix_temp_post_tran_data_18 ON temp_post_tran_data (PT_retention_data);

	CREATE NONCLUSTERED INDEX ix_temp_journal_data_1 ON temp_journal_data (DebitAccNr_acc_nr) INCLUDE (CreditAccNr_acc_nr);
	CREATE NONCLUSTERED INDEX ix_temp_journal_data_2 ON temp_journal_data (CreditAccNr_acc_nr)INCLUDE (DebitAccNr_acc_nr);
	CREATE NONCLUSTERED INDEX ix_temp_journal_data_3 ON temp_journal_data (business_date);
	CREATE NONCLUSTERED INDEX ix_temp_journal_data_4 ON temp_journal_data (fee_name);
	CREATE NONCLUSTERED INDEX ix_temp_journal_data_5 ON temp_journal_data (feevalue_description);
	    CREATE NONCLUSTERED INDEX ix_temp_journal_data_6 ON temp_journal_data (post_tran_id);
    CREATE NONCLUSTERED INDEX ix_temp_journal_data_7 ON temp_journal_data (post_tran_cust_id);
	
END

DECLARE @settle_business_date   varchar(40)

	 SELECT TOP 1  @settle_business_date  =  (cast (J.business_date as varchar(40)))
	FROM   dbo.temp_journal_data AS J (NOLOCK) 
	JOIN temp_post_tran_data PT WITH  (NOLOCK)
	ON (( j.post_tran_id = PT.PT_post_tran_id)  and (J.business_date >= @from_date AND J.business_date <= @to_date) AND   PT.pt_tran_postilion_originated = 0)
	JOIN post_tran_cust PTC WITH (NOLOCK, index(pk_post_tran_cust))
	ON 
	J.post_tran_cust_id = PT.PTC_post_tran_cust_id
	where  
	PT.PT_rsp_code_rsp in ('00','11','09')

	  AND (
		 PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in ('0200','0220')
		 or  ((PT.PT_message_type = '0420' and PT.PT_tran_reversed <> 2 ) and ( (PT.PT_settle_amount_impact<> 0 )
		   or (PT.PT_settle_amount_rsp<> 0   and PT.PT_message_type = '0420' and PT.PT_tran_reversed <> 2 and PT.PT_tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))))
	  or (PT.PT_settle_amount_rsp<> 0 and PT.PT_message_type   in ('0200','0220') and PT.PT_tran_type = 40 and (LEFT(PTC.Terminal_id,1) in ('0','1')))

	   )
	   OPTION(RECOMPILE)
	   
IF (OBJECT_ID('tempdb.dbo.#report_result') is not null )begin
  DROP TABLE #report_result
end

IF (OBJECT_ID('tempdb.dbo.#temp_table') is not null )begin
  DROP TABLE #temp_table
end


	   
  IF (@settle_business_date IS NOT NULL) BEGIN
  
INSERT            INTO settlement_summary_session_mega VALUES (@settle_business_date)

IF (OBJECT_ID('tempdb.dbo.#report_result') is not null )begin
  DROP TABLE #report_result
end

IF (OBJECT_ID('tempdb.dbo.#temp_table') is not null )begin
  DROP TABLE #temp_table
end


SELECT		bank_code = case         
	
                         WHEN (DebitAccNr_acc_nr LIKE 'UBA%' OR CreditAccNr_acc_nr LIKE 'UBA%') THEN 'UBA'
			             WHEN (DebitAccNr_acc_nr LIKE 'FBN%' OR CreditAccNr_acc_nr LIKE 'FBN%') THEN 'FBN'
                         WHEN (DebitAccNr_acc_nr LIKE 'ZIB%' OR CreditAccNr_acc_nr LIKE 'ZIB%') THEN 'ZIB' 
                         WHEN (DebitAccNr_acc_nr LIKE 'SPR%' OR CreditAccNr_acc_nr LIKE 'SPR%') THEN 'ENT'
                         WHEN (DebitAccNr_acc_nr LIKE 'GTB%' OR CreditAccNr_acc_nr LIKE 'GTB%') THEN 'GTB'
                         WHEN (DebitAccNr_acc_nr LIKE 'PRU%' OR CreditAccNr_acc_nr LIKE 'PRU%') THEN 'SKYE'
                         WHEN (DebitAccNr_acc_nr LIKE 'OBI%' OR CreditAccNr_acc_nr LIKE 'OBI%') THEN 'EBN'
                         WHEN (DebitAccNr_acc_nr LIKE 'WEM%' OR CreditAccNr_acc_nr LIKE 'WEM%') THEN 'WEMA'
                         WHEN (DebitAccNr_acc_nr LIKE 'AFR%' OR CreditAccNr_acc_nr LIKE 'AFR%') THEN 'MSB'
                         WHEN (DebitAccNr_acc_nr LIKE 'IBTC%' OR CreditAccNr_acc_nr LIKE 'IBTC%') THEN 'IBTC'
                         WHEN (DebitAccNr_acc_nr LIKE 'PLAT%' OR CreditAccNr_acc_nr LIKE 'PLAT%') THEN 'KSB'
                         WHEN (DebitAccNr_acc_nr LIKE 'UBP%' OR CreditAccNr_acc_nr LIKE 'UBP%') THEN 'UBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'DBL%' OR CreditAccNr_acc_nr LIKE 'DBL%') THEN 'DBL'

                         WHEN (DebitAccNr_acc_nr LIKE 'FCMB%' OR CreditAccNr_acc_nr LIKE 'FCMB%') THEN 'FCMB'
                         WHEN (DebitAccNr_acc_nr LIKE 'IBP%' OR CreditAccNr_acc_nr LIKE 'IBP%') THEN 'ABP'
                         WHEN (DebitAccNr_acc_nr LIKE 'UBN%' OR CreditAccNr_acc_nr LIKE 'UBN%') THEN 'UBN'
                         WHEN (DebitAccNr_acc_nr LIKE 'ETB%' OR CreditAccNr_acc_nr LIKE 'ETB%') THEN 'ETB'
                         WHEN (DebitAccNr_acc_nr LIKE 'FBP%' OR CreditAccNr_acc_nr LIKE 'FBP%') THEN 'FBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'SBP%' OR CreditAccNr_acc_nr LIKE 'SBP%') THEN 'SBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'ABP%' OR CreditAccNr_acc_nr LIKE 'ABP%') THEN 'ABP'
                         WHEN (DebitAccNr_acc_nr LIKE 'EBN%' OR CreditAccNr_acc_nr LIKE 'EBN%') THEN 'EBN'

                         WHEN (DebitAccNr_acc_nr LIKE 'CITI%' OR CreditAccNr_acc_nr LIKE 'CITI%') THEN 'CITI'
                         WHEN (DebitAccNr_acc_nr LIKE 'FIN%' OR CreditAccNr_acc_nr LIKE 'FIN%') THEN 'FCMB'
                         WHEN (DebitAccNr_acc_nr LIKE 'ASO%' OR CreditAccNr_acc_nr LIKE 'ASO%') THEN 'ASO'
                         WHEN (DebitAccNr_acc_nr LIKE 'OLI%' OR CreditAccNr_acc_nr LIKE 'OLI%') THEN 'OLI'
                         WHEN (DebitAccNr_acc_nr LIKE 'HSL%' OR CreditAccNr_acc_nr LIKE 'HSL%') THEN 'HSL'
                         WHEN (DebitAccNr_acc_nr LIKE 'ABS%' OR CreditAccNr_acc_nr LIKE 'ABS%') THEN 'ABS'
                         WHEN (DebitAccNr_acc_nr LIKE 'PAY%' OR CreditAccNr_acc_nr LIKE 'PAY%') THEN 'PAY'
                         WHEN (DebitAccNr_acc_nr LIKE 'SAT%' OR CreditAccNr_acc_nr LIKE 'SAT%') THEN 'SAT'
                         WHEN (DebitAccNr_acc_nr LIKE '3LCM%' OR CreditAccNr_acc_nr LIKE '3LCM%') THEN '3LCM'
                         WHEN (DebitAccNr_acc_nr LIKE 'SCB%' OR CreditAccNr_acc_nr LIKE 'SCB%') THEN 'SCB'
                         WHEN (DebitAccNr_acc_nr LIKE 'JBP%' OR CreditAccNr_acc_nr LIKE 'JBP%') THEN 'JBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'RSL%' OR CreditAccNr_acc_nr LIKE 'RSL%') THEN 'RSL'
                         WHEN (DebitAccNr_acc_nr LIKE 'PSH%' OR CreditAccNr_acc_nr LIKE 'PSH%') THEN 'PSH'
                         WHEN (DebitAccNr_acc_nr LIKE 'INF%' OR CreditAccNr_acc_nr LIKE 'INF%') THEN 'INF'
                         WHEN (DebitAccNr_acc_nr LIKE 'UML%' OR CreditAccNr_acc_nr LIKE 'UML%') THEN 'UML'

                         WHEN (DebitAccNr_acc_nr LIKE 'ACCI%' OR CreditAccNr_acc_nr LIKE 'ACCI%') THEN 'ACCI'
                         WHEN (DebitAccNr_acc_nr LIKE 'EKON%' OR CreditAccNr_acc_nr LIKE 'EKON%') THEN 'EKON'
                         WHEN (DebitAccNr_acc_nr LIKE 'ATMC%' OR CreditAccNr_acc_nr LIKE 'ATMC%') THEN 'ATMC'
                         WHEN (DebitAccNr_acc_nr LIKE 'HBC%' OR CreditAccNr_acc_nr LIKE 'HBC%') THEN 'HBC'
			             WHEN (DebitAccNr_acc_nr LIKE 'UNI%' OR CreditAccNr_acc_nr LIKE 'UNI%') THEN 'UNI'
                         WHEN (DebitAccNr_acc_nr LIKE 'UNC%' OR CreditAccNr_acc_nr LIKE 'UNC%') THEN 'UNC'
                         WHEN (DebitAccNr_acc_nr LIKE 'NCS%' OR CreditAccNr_acc_nr LIKE 'NCS%') THEN 'NCS' 
			             WHEN (DebitAccNr_acc_nr LIKE 'HAG%' OR CreditAccNr_acc_nr LIKE 'HAG%') THEN 'HAG'
			             WHEN (DebitAccNr_acc_nr LIKE 'EXP%' OR CreditAccNr_acc_nr LIKE 'EXP%') THEN 'DBL'
			             WHEN (DebitAccNr_acc_nr LIKE 'FGMB%' OR CreditAccNr_acc_nr LIKE 'FGMB%') THEN 'FGMB'
                         WHEN (DebitAccNr_acc_nr LIKE 'CEL%' OR CreditAccNr_acc_nr LIKE 'CEL%') THEN 'CEL'
			             WHEN (DebitAccNr_acc_nr LIKE 'RDY%' OR CreditAccNr_acc_nr LIKE 'RDY%') THEN 'RDY'
			             WHEN (DebitAccNr_acc_nr LIKE 'AMJ%' OR CreditAccNr_acc_nr LIKE 'AMJ%') THEN 'AMJU'
			             WHEN (DebitAccNr_acc_nr LIKE 'CAP%' OR CreditAccNr_acc_nr LIKE 'CAP%') THEN 'O3CAP'
			             WHEN (DebitAccNr_acc_nr LIKE 'VER%' OR CreditAccNr_acc_nr LIKE 'VER%') THEN 'VER_GLOBAL'

			             WHEN (DebitAccNr_acc_nr LIKE 'SMF%' OR CreditAccNr_acc_nr LIKE 'SMF%') THEN 'SMFB'
			             WHEN (DebitAccNr_acc_nr LIKE 'SLT%' OR CreditAccNr_acc_nr LIKE 'SLT%') THEN 'SLTD'
			             WHEN (DebitAccNr_acc_nr LIKE 'JES%' OR CreditAccNr_acc_nr LIKE 'JES%') THEN 'JES'
                         WHEN (DebitAccNr_acc_nr LIKE 'MOU%' OR CreditAccNr_acc_nr LIKE 'MOU%') THEN 'MOUA'
                         WHEN (DebitAccNr_acc_nr LIKE 'MUT%' OR CreditAccNr_acc_nr LIKE 'MUT%') THEN 'MUT'
                         WHEN (DebitAccNr_acc_nr LIKE 'LAV%' OR CreditAccNr_acc_nr LIKE 'LAV%') THEN 'LAV'
                         WHEN (DebitAccNr_acc_nr LIKE 'JUB%' OR CreditAccNr_acc_nr LIKE 'JUB%') THEN 'JUB'
						 WHEN (DebitAccNr_acc_nr LIKE 'WET%' OR CreditAccNr_acc_nr LIKE 'WET%') THEN 'WET'
                         WHEN (DebitAccNr_acc_nr LIKE 'AGH%' OR CreditAccNr_acc_nr LIKE 'AGH%') THEN 'AGH'
                         WHEN (DebitAccNr_acc_nr LIKE 'TRU%' OR CreditAccNr_acc_nr LIKE 'TRU%') THEN 'TRU'
						 WHEN (DebitAccNr_acc_nr LIKE 'CON%' OR CreditAccNr_acc_nr LIKE 'CON%') THEN 'CON'
                         WHEN (DebitAccNr_acc_nr LIKE 'CRU%' OR CreditAccNr_acc_nr LIKE 'CRU%') THEN 'CRU'
                         WHEN (DebitAccNr_acc_nr LIKE 'NPR%' OR CreditAccNr_acc_nr LIKE 'NPR%') THEN 'NPR'
                         WHEN (DebitAccNr_acc_nr LIKE 'POS_FOODCONCEPT%' OR CreditAccNr_acc_nr LIKE 'POS_FOODCONCEPT%') THEN 'SCB'
			             WHEN ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		END,
	trxn_category= 
	
	CASE WHEN fee_name = 'Switched_In_Fee' AND PT.PT_message_type = '0100' THEN 'MasterCard Switched_In(Authorization)'
                       WHEN fee_name = 'Switched_In_Fee' AND PT.PT_message_type=  '0200' THEN 'MasterCard Switched_In(Request)'   
                       WHEN fee_name = 'Switched_In_Fee' AND PT.PT_message_type = '0220' THEN 'MasterCard Switched_In(Completion)'
                         ELSE 'UNK'
                         	END,
  Debit_account_type= 
  
  CASE 
                      
                      
                      
                          WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                      WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)'   
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_TERMINAL_ID)= '9'
                          AND NOT ((DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (DebitAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'                       

                          ELSE 'UNK'			
END,
  Credit_account_type= 
  CASE  
  
  WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                      WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'   
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_TERMINAL_ID)= '9'
                          AND NOT ((CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (CreditAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)'                       

                          ELSE 'UNK'		
END,

        amt= SUM(ISNULL(J.amount,0)),
	fee= SUM(ISNULL(J.fee,0)),
	business_date=j.business_date,
        currency = 
        CASE WHEN FeeValue_description like '%$'  THEN '840'
                        WHEN FeeValue_description like '%#'THEN '566'
          ELSE '566' END,
        Late_Reversal_id = '0',
        card_type =  dbo.fn_rpt_CardGroup(PT.PTC_PAN),
        terminal_type = PT.PTC_pos_terminal_type,--dbo.fn_rpt_terminal_type(PT.PTC_TERMINAL_ID),    
        source_node_name =   PT.PTC_source_node_name,
               Acquirer =   CASE WHEN(LEFT(DebitAccNr_acc_nr,3)!='ISW' OR  DebitAccNr_acc_nr LIKE '%POOL%') AND (LEFT(CreditAccNr_acc_nr,3)!='ISW' OR  CreditAccNr_acc_nr LIKE '%POOL%')  then ''
                       WHEN((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.PT_acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PT.PTC_TERMINAL_ID,2,3)= acc.cbn_code1 or SUBSTRING(PT.PTC_TERMINAL_ID,2,3)= acc.cbn_code2 or SUBSTRING(PT.PTC_TERMINAL_ID,2,3)= acc.cbn_code3 or SUBSTRING(PT.PTC_TERMINAL_ID,2,3) = acc.cbn_code4) THEN acc.bank_code
                     else PT.PT_acquiring_inst_id_code END,
                     
                     Issuer =      CASE WHEN(LEFT(DebitAccNr_acc_nr,3)!='ISW' OR  DebitAccNr_acc_nr LIKE '%POOL%') AND (LEFT(CreditAccNr_acc_nr,3)!='ISW' OR  CreditAccNr_acc_nr LIKE '%POOL%')  then ''
                       when ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) and (substring(PT.PTC_totals_group,1,3) = acc.bank_code1) then acc.bank_code
                     else PT.PT_acquiring_inst_id_code END,  
              index_no = IDENTITY (int, 1,1)
          INTO #report_result FROM
                     temp_journal_data  J (NOLOCK)
                     join 
                     temp_post_tran_data PT (NOLOCK )
                    ON (J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                    
LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.PT_acquiring_inst_id_code or 
acc.acquirer_inst_id3 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id5 
= PT.PT_acquiring_inst_id_code)
  

GROUP BY 

 j.business_date,
 DebitAccNr_acc_nr,
 CreditAccNr_acc_nr,
 PT.PT_tran_type,

PT.PTC_source_node_name,
PT.PT_sink_node_name,

dbo.fn_rpt_CardGroup(PT.PTC_PAN), PT.PTC_pos_terminal_type,--dbo.fn_rpt_terminal_type(PT.PTC_TERMINAL_ID),
dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_tran_type,PT.PTC_TERMINAL_ID),
 CASE WHEN(LEFT(DebitAccNr_acc_nr,3)!='ISW' OR  DebitAccNr_acc_nr LIKE '%POOL%') AND (LEFT(CreditAccNr_acc_nr,3)!='ISW' OR  CreditAccNr_acc_nr LIKE '%POOL%')  then ''
                       WHEN((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.PT_acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PT.PTC_TERMINAL_ID,2,3)= acc.cbn_code1 or SUBSTRING(PT.PTC_TERMINAL_ID,2,3)= acc.cbn_code2 or SUBSTRING(PT.PTC_TERMINAL_ID,2,3)= acc.cbn_code3 or SUBSTRING(PT.PTC_TERMINAL_ID,2,3) = acc.cbn_code4) THEN acc.bank_code
                     else PT.PT_acquiring_inst_id_code END,
     CASE WHEN(LEFT(DebitAccNr_acc_nr,3)!='ISW' OR  DebitAccNr_acc_nr LIKE '%POOL%') AND (LEFT(CreditAccNr_acc_nr,3)!='ISW' OR  CreditAccNr_acc_nr LIKE '%POOL%')  then ''
                       when ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) and (substring(PT.PTC_totals_group,1,3) = acc.bank_code1) then acc.bank_code
                     else PT.PT_acquiring_inst_id_code END,
acc.bank_code1, acc.bank_code, PT.PT_acquiring_inst_id_code,PT.pt_extended_tran_type, fee_name, PT.PT_message_type,FeeValue_description,
substring(PT.PTC_totals_group,1,3),PT.pt_settle_currency_code
OPTION(RECOMPILE, MAXDOP 8)

insert into settlement_summary_breakdown_Mega	
(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer)	
	SELECT 
			bank_code,trxn_category,Debit_Account_type,Credit_Account_type,sum(trxn_amount),sum(trxn_fee),trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer 
	FROM 
			#report_result        

GROUP BY bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_date,Currency,late_reversal,card_type,terminal_type,Acquirer, Issuer
OPTION(RECOMPILE)

END ELSE BEGIN
DECLARE @message varchar(1000)
SET @message = 'There is no Settlement data for '+@settle_business_date+' in the temp_post_tran_data and/or temp_journal_data tables';
print @message




END




END



