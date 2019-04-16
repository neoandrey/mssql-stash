USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_get_settlement_transaction_details]    Script Date: 05/15/2017 21:15:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_get_settlement_transaction_details]  (@currentDate VARCHAR(10))  AS 
BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @server1Date  DATETIME
DECLARE @server2Date  DATETIME
DECLARE @server3Date  DATETIME
DECLARE @serverSettlementDate DATETIME
DECLARE @settlementSourceServer VARCHAR(255)
DECLARE @settlementStatus  int
DECLARE @hasSettlementDataBeenFetched BIT


SELECT @currentDate = isnull(@currentDate, CONVERT(varchar(10),  DATEADD(D, -1, getdate()),112))


BEGIN TRY
SELECT @server1Date= MAX(business_date) FROM [postilion_office].dbo.sstl_journal_temp WHERE business_date  = @currentDate
END TRY
BEGIN CATCH

END CATCH
BEGIN TRY
SELECT @server2Date = MAX(business_date) FROM [172.25.10.89].[postilion_office].dbo.sstl_journal_temp  WHERE business_date  = @currentDate

END TRY
BEGIN CATCH

END CATCH
BEGIN TRY
SELECT @server3Date = MAX(business_date) FROM [172.75.75.19].[postilion_office].dbo.sstl_journal_temp WHERE business_date  = @currentDate
END TRY
BEGIN CATCH
END CATCH

IF (DATEDIFF(D, @currentDate,@server1Date )=0)BEGIN
set @serverSettlementDate = ( select   TOP 1  datetime_started from sstl_session(nolock) where completed = 1  and datetime_started =  @currentDate order by session_id  desc)
set @settlementSourceServer  = @@SERVERNAME;
END 
ELSE IF (DATEDIFF(D,@currentDate,@server2Date )=0)BEGIN
set @serverSettlementDate = (select  TOP 1  datetime_started  from [172.25.10.89].[postilion_office].dbo.sstl_session(nolock) where completed = 1 and datetime_started =  @currentDate  order by session_id  desc)
set @settlementSourceServer  = '[172.25.10.89]';
END 
ELSE IF (DATEDIFF(D, @currentDate,@server3Date )=0)BEGIN
set @serverSettlementDate = (select  TOP 1  datetime_started  from [172.75.75.19].[postilion_office].dbo.sstl_session(nolock) where completed = 1  and datetime_started =  @currentDate  order by session_id  desc)
set @settlementSourceServer  = '[172.75.75.19]';
END 

 IF (@settlementSourceServer IS NOT NULL ) BEGIN
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sstl_summary_details_session]') AND type in (N'U'))begin

		CREATE TABLE sstl_summary_details_session (session_id INT NOT NULL IDENTITY (1,1), settlement_date DATETIME, source_server varchar(255), status INT )
			CREATE CLUSTERED INDEX ix_sstl_summary_details_session_1 ON sstl_summary_details_session (
			session_id
			)
			CREATE NONCLUSTERED INDEX ix_sstl_summary_details_session_2 ON sstl_summary_details_session (
			settlement_date
			)
END
		SELECT @settlementStatus = STATUS FROM  sstl_summary_details_session (NOLOCK) WHERE  settlement_date = @currentDate
		IF  ( @settlementStatus is null ) BEGIN
		
			INSERT INTO  sstl_summary_details_session(settlement_date,source_server,status ) VALUES (@currentDate,@settlementSourceServer, 0) ;
		END
		ELSE IF  ( @settlementStatus = 1) BEGIN
			  PRINT  'Settlement details already fetched for '+@currentDate;
			  return
		END

		
		
IF  (@currentDate = CONVERT(varchar(10), getdate()-1,112)) BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
DECLARE @server_one_count BIGINT
DECLARE @server_two_count BIGINT
DECLARE @server_three_count BIGINT
 
select @server_one_count   = count(*) FROM   [postilion_office].dbo.temp_journal_data (NOLOCK)
select @server_two_count   = count(*) FROM   [172.25.10.89].[postilion_office].dbo.temp_journal_data  
select @server_three_count = count(*) FROM   [172.75.75.19].[postilion_office].dbo.temp_journal_data
	 			 									
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp_journal_data_staging]') AND type in (N'U'))begin
DROP TABLE [dbo].[temp_journal_data_staging]
end
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp_post_tran_data_staging]') AND type in (N'U'))begin
DROP TABLE [dbo].[temp_post_tran_data_staging]
end

	IF (@server_one_count>=@server_two_count  AND @server_one_count>=@server_three_count) BEGIN

			SELECT * into temp_journal_data_staging FROM  [postilion_office].dbo.temp_journal_data (NOLOCK)
			SELECT * into temp_post_tran_data_staging FROM  [postilion_office].dbo.temp_post_tran_data (NOLOCK)
			set @hasSettlementDataBeenFetched   = 1
		END
			ELSE IF (@server_two_count>@server_one_count  AND @server_two_count>=@server_three_count) BEGIN

			SELECT * into temp_journal_data_staging FROM  [172.25.10.89].[postilion_office].dbo.temp_journal_data 
			SELECT * into temp_post_tran_data_staging FROM  [172.25.10.89].[postilion_office].dbo.temp_post_tran_data
			set @hasSettlementDataBeenFetched   = 1
			END
		ELSE IF (@server_three_count>@server_one_count  AND @server_three_count>=@server_two_count) BEGIN

			SELECT * into temp_journal_data_staging FROM  [172.75.75.19].[postilion_office].dbo.temp_journal_data 
			SELECT * into temp_post_tran_data_staging FROM  [172.75.75.19].[postilion_office].dbo.temp_post_tran_data 
			
		END
				
END

		IF  ( @hasSettlementDataBeenFetched   != 1 )BEGIN
		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp_journal_data_staging]') AND type in (N'U'))begin
DROP TABLE [dbo].[temp_journal_data_staging]
end
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp_post_tran_data_staging]') AND type in (N'U'))begin
DROP TABLE [dbo].[temp_post_tran_data_staging]
end
		 
		 DECLARE @sql VARCHAR (MAX)
set @sql = ( replace(replace('SELECT *  into temp_post_tran_data_staging  FROM  OPENQUERY( @settlementSourceServer, 
''SELECT PT.[post_tran_id]	PT_post_tran_id	,PT.[post_tran_cust_id]	PT_post_tran_cust_id	,PT.[settle_entity_id]	PT_settle_entity_id	,PT.[batch_nr]	PT_batch_nr	,PT.[prev_post_tran_id]	PT_prev_post_tran_id	,PT.[next_post_tran_id]	PT_next_post_tran_id	,PT.[sink_node_name]	PT_sink_node_name	,PT.[tran_postilion_originated]	PT_tran_postilion_originated	,PT.[tran_completed]	PT_tran_completed	,PT.[message_type]	PT_message_type	,PT.[tran_type]	PT_tran_type	,PT.[tran_nr]	PT_tran_nr	,PT.[system_trace_audit_nr]	PT_system_trace_audit_nr	,PT.[rsp_code_req]	PT_rsp_code_req	,PT.[rsp_code_rsp]	PT_rsp_code_rsp	,PT.[abort_rsp_code]	PT_abort_rsp_code	,PT.[auth_id_rsp]	PT_auth_id_rsp	,PT.[auth_type]	PT_auth_type	,PT.[auth_reason]	PT_auth_reason	,PT.[retention_data]	PT_retention_data	,PT.[acquiring_inst_id_code]	PT_acquiring_inst_id_code	,PT.[message_reason_code]	PT_message_reason_code	,PT.[sponsor_bank]	PT_sponsor_bank	,PT.[retrieval_reference_nr]	PT_retrieval_reference_nr	,PT.[datetime_tran_gmt]	PT_datetime_tran_gmt	,PT.[datetime_tran_local]	PT_datetime_tran_local	,PT.[datetime_req]	PT_datetime_req	,PT.[datetime_rsp]	PT_datetime_rsp	,PT.[realtime_business_date]	PT_realtime_business_date	,PT.[recon_business_date]	PT_recon_business_date	,PT.[from_account_type]	PT_from_account_type	,PT.[to_account_type]	PT_to_account_type	,PT.[from_account_id]	PT_from_account_id	,PT.[to_account_id]	PT_to_account_id	,PT.[tran_amount_req]	PT_tran_amount_req	,PT.[tran_amount_rsp]	PT_tran_amount_rsp	,PT.[settle_amount_impact]	PT_settle_amount_impact	,PT.[tran_cash_req]	PT_tran_cash_req	,PT.[tran_cash_rsp]	PT_tran_cash_rsp	,PT.[tran_currency_code]	PT_tran_currency_code	,PT.[tran_tran_fee_req]	PT_tran_tran_fee_req	,PT.[tran_tran_fee_rsp]	PT_tran_tran_fee_rsp	,PT.[tran_tran_fee_currency_code]	PT_tran_tran_fee_currency_code	,PT.[tran_proc_fee_req]	PT_tran_proc_fee_req	,PT.[tran_proc_fee_rsp]	PT_tran_proc_fee_rsp	,PT.[tran_proc_fee_currency_code]	PT_tran_proc_fee_currency_code	,PT.[settle_amount_req]	PT_settle_amount_req	,PT.[settle_amount_rsp]	PT_settle_amount_rsp	,PT.[settle_cash_req]	PT_settle_cash_req	,PT.[settle_cash_rsp]	PT_settle_cash_rsp	,PT.[settle_tran_fee_req]	PT_settle_tran_fee_req	,PT.[settle_tran_fee_rsp]	PT_settle_tran_fee_rsp	,PT.[settle_proc_fee_req]	PT_settle_proc_fee_req	,PT.[settle_proc_fee_rsp]	PT_settle_proc_fee_rsp	,PT.[settle_currency_code]	PT_settle_currency_code	,PT.[pos_entry_mode]	PT_pos_entry_mode	,PT.[pos_condition_code]	PT_pos_condition_code	,PT.[additional_rsp_data]	PT_additional_rsp_data	,PT.[tran_reversed]	PT_tran_reversed	,PT.[prev_tran_approved]	PT_prev_tran_approved	,PT.[issuer_network_id]	PT_issuer_network_id	,PT.[acquirer_network_id]	PT_acquirer_network_id	,PT.[extended_tran_type]	PT_extended_tran_type	,PT.[from_account_type_qualifier]	PT_from_account_type_qualifier	,PT.[to_account_type_qualifier]	PT_to_account_type_qualifier	,PT.[bank_details]	PT_bank_details	,PT.[payee]	PT_payee	,PT.[card_verification_result]	PT_card_verification_result	,PT.[online_system_id]	PT_online_system_id	,PT.[participant_id]	PT_participant_id	,PT.[opp_participant_id]	PT_opp_participant_id	,PT.[receiving_inst_id_code]	PT_receiving_inst_id_code	,PT.[routing_type]	PT_routing_type	,PT.[pt_pos_operating_environment]	PT_pt_pos_operating_environment	,PT.[pt_pos_card_input_mode]	PT_pt_pos_card_input_mode	,PT.[pt_pos_cardholder_auth_method]	PT_pt_pos_cardholder_auth_method	,PT.[pt_pos_pin_capture_ability]	PT_pt_pos_pin_capture_ability	,PT.[pt_pos_terminal_operator]	PT_pt_pos_terminal_operator	,PT.[source_node_key]	PT_source_node_key	,PT.[proc_online_system_id]	PT_proc_online_system_id	,PTC.[post_tran_cust_id]	PTC_post_tran_cust_id	,PTC.[source_node_name]	PTC_source_node_name	,PTC.[draft_capture]	PTC_draft_capture	,PTC.[pan]	PTC_pan	,PTC.[card_seq_nr]	PTC_card_seq_nr	,PTC.[expiry_date]	PTC_expiry_date	,PTC.[service_restriction_code]	PTC_service_restriction_code	,PTC.[terminal_id]	PTC_terminal_id	,PTC.[terminal_owner]	PTC_terminal_owner	,PTC.[card_acceptor_id_code]	PTC_card_acceptor_id_code	,PTC.[mapped_card_acceptor_id_code]	PTC_mapped_card_acceptor_id_code	,PTC.[merchant_type]	PTC_merchant_type	,PTC.[card_acceptor_name_loc]	PTC_card_acceptor_name_loc	,PTC.[address_verification_data]	PTC_address_verification_data	,PTC.[address_verification_result]	PTC_address_verification_result	,PTC.[check_data]	PTC_check_data	,PTC.[totals_group]	PTC_totals_group	,PTC.[card_product]	PTC_card_product	,PTC.[pos_card_data_input_ability]	PTC_pos_card_data_input_ability	,PTC.[pos_cardholder_auth_ability]	PTC_pos_cardholder_auth_ability	,PTC.[pos_card_capture_ability]	PTC_pos_card_capture_ability	,PTC.[pos_operating_environment]	PTC_pos_operating_environment	,PTC.[pos_cardholder_present]	PTC_pos_cardholder_present	,PTC.[pos_card_present]	PTC_pos_card_present	,PTC.[pos_card_data_input_mode]	PTC_pos_card_data_input_mode	,PTC.[pos_cardholder_auth_method]	PTC_pos_cardholder_auth_method	,PTC.[pos_cardholder_auth_entity]	PTC_pos_cardholder_auth_entity	,PTC.[pos_card_data_output_ability]	PTC_pos_card_data_output_ability	,PTC.[pos_terminal_output_ability]	PTC_pos_terminal_output_ability	,PTC.[pos_pin_capture_ability]	PTC_pos_pin_capture_ability	,PTC.[pos_terminal_operator]	PTC_pos_terminal_operator	,PTC.[pos_terminal_type]	PTC_pos_terminal_type	,PTC.[pan_search]	PTC_pan_search	,PTC.[pan_encrypted]	PTC_pan_encrypted	,PTC.[pan_reference]	PTC_pan_reference
FROM  (select * from  postilion_office.dbo.post_tran AS t  WITH (NOLOCK)
JOIN (SELECT  [DATE] recon_business_date_2 FROM  postilion_office.dbo.[get_dates_in_range](''''SETTLE_START_DATE'''', ''''SETTLE_END_DATE'''' ))rdate
ON (rdate.recon_business_date_2 = t.recon_business_date)
AND post_tran_id NOT IN (
					SELECT  post_tran_id  FROM postilion_office.dbo.tbl_late_reversals ll (NOLOCK) 
		WHERE ll.recon_business_date >= ''''SETTLE_START_DATE''''
		and (datepart(D,ll.rev_datetime_req) - datepart(D, ll.trans_datetime_req ))>1 
					) AND
					rsp_code_rsp IN (''''00'''',''''11'''',''''09''''))PT
 LEFT JOIN  postilion_office.dbo.Post_tran_cust AS PTC WITH  (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id
 AND  LEFT( source_node_name,2 ) <> ''''SB''''
AND  CHARINDEX(''''TPP'''',source_node_name )<1
AND source_node_name <> ''''SWTMEGADSsrc'''' )
AND LEFT(card_acceptor_id_code,3) <>''''IPG''''
WHERE
 LEFT(sink_node_name,2)<> ''''SB''''
				 and  sink_node_name <> ''''WUESBPBsnk''''
	   and CHARINDEX(''''TPP'''', sink_node_name) < 1 OPTION(RECOMPILE,optimize for unknown ) '')','@settlementSourceServer',@settlementSourceServer
	   ), 'SETTLE_START_DATE', @currentDate)
	   )
	   
	   EXEC (@sql)
set @sql = ( replace(replace('SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SELECT *  INTO temp_journal_data_staging  FROM  OPENQUERY(  [172.25.10.89], 
''SELECT  J.adj_id,J.entry_id,J.config_set_id,J.session_id,J.post_tran_id,J.post_tran_cust_id,J.sdi_tran_id,J.acc_post_id,J.nt_fee_acc_post_id,J.coa_id,J.coa_se_id,J.se_id,J.amount,J.amount_id,J.amount_value_id,J.fee,J.fee_id,J.fee_value_id,J.nt_fee,J.nt_fee_id,J.nt_fee_value_id,J.debit_acc_nr_id,J.debit_acc_id,J.debit_cardholder_acc_id,J.debit_cardholder_acc_type,J.credit_acc_nr_id,J.credit_acc_id,J.credit_cardholder_acc_id,J.credit_cardholder_acc_type,J.business_date,J.granularity_element,J.tag,J.spay_session_id,J.spst_session_id,DebitAccNr.config_set_id DebitAccNr_config_set_id,DebitAccNr.acc_nr_id  DebitAccNr_acc_nr_id,DebitAccNr.se_id	DebitAccNr_se_id,DebitAccNr.acc_id	DebitAccNr_acc_id,DebitAccNr.acc_nr	DebitAccNr_acc_nr,DebitAccNr.aggregation_id DebitAccNr_aggregation_id,DebitAccNr.state	DebitAccNr_state,DebitAccNr.config_state DebitAccNr_config_state,CreditAccNr.config_set_id CreditAccNr_config_set_id,CreditAccNr.acc_nr_id  CreditAccNr_acc_nr_id,CreditAccNr.se_id	CreditAccNr_se_id,CreditAccNr.acc_id	CreditAccNr_acc_id,CreditAccNr.acc_nr	CreditAccNr_acc_nr,CreditAccNr.aggregation_id CreditAccNr_aggregation_id,CreditAccNr.state	CreditAccNr_state,CreditAccNr.config_state CreditAccNr_config_state,Amount.config_set_id	Amount_config_set_id,Amount.amount_id	Amount_amount_id,Amount.se_id	Amount_se_id,Amount.name	Amount_name,Amount.description	Amount_description,Amount.config_state	Amount_config_state,Fee.config_set_id Fee_config_set_id,Fee.fee_id	Fee_fee_id,Fee.se_id	Fee_se_id,Fee.name	Fee_name,Fee.description Fee_description,Fee.type	Fee_type,Fee.amount_id Fee_amount_id,Fee.config_state Fee_config_state,coa.config_set_id coa_config_set_id,coa.coa_id	coa_coa_id,coa.name	coa_name,coa.description	coa_description,coa.type	coa_type,coa.config_state	coa_config_state
FROM
 (SELECT *   FROM postilion_office.dbo.[sstl_journal_temp] j1 (NOLOCK)
 JOIN (SELECT  [DATE] recon_business_date_2 FROM  postilion_office.dbo.[get_dates_in_range](''''SETTLE_START_DATE'''', ''''SETTLE_END_DATE'''' ))rdate
ON (rdate.recon_business_date_2 = j1.business_date))J
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
OPTION (RECOMPILE, OPTIMIZE FOR UNKNOWN)'')
','@settlementSourceServer',@settlementSourceServer
	   ), 'SETTLE_START_DATE', @currentDate)
	   )
	   
	   EXEC (@sql)

 END
 
 
 
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_staging_1]
ON [dbo].temp_journal_data_staging ([post_tran_id])
INCLUDE ([adj_id],[entry_id],[config_set_id],[session_id],[sdi_tran_id],[acc_post_id],[nt_fee_acc_post_id],[coa_id],[coa_se_id],[se_id],[amount],[amount_id],[amount_value_id],[fee],[nt_fee],[nt_fee_id],[nt_fee_value_id],[debit_acc_nr_id],[debit_acc_id],[debit_cardholder_acc_id],[debit_cardholder_acc_type],[credit_acc_nr_id],[credit_acc_id],[credit_cardholder_acc_id],[credit_cardholder_acc_type],
[business_date],[granularity_element],[tag],[spay_session_id],[spst_session_id],[DebitAccNr_config_set_id],[DebitAccNr_acc_nr_id],[DebitAccNr_se_id],[DebitAccNr_acc_id],[DebitAccNr_acc_nr],[DebitAccNr_aggregation_id],[DebitAccNr_state],[DebitAccNr_config_state],[CreditAccNr_config_set_id],[CreditAccNr_acc_nr_id],[CreditAccNr_se_id],[CreditAccNr_acc_id],[CreditAccNr_acc_nr],[CreditAccNr_aggregation_id],[CreditAccNr_state],[CreditAccNr_config_state],[Amount_config_set_id],[Amount_amount_id],[Amount_se_id],[Amount_name],[Amount_description],[Amount_config_state]
,[Fee_config_set_id],[Fee_fee_id],[Fee_se_id],[Fee_name],[Fee_description],[Fee_type],[Fee_amount_id],[Fee_config_state],[coa_config_set_id],
[coa_coa_id],[coa_name],[coa_description],[coa_type],[coa_config_state])WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]

CREATE NONCLUSTERED INDEX ix_temp_journal_data_staging_2 ON [dbo].temp_journal_data_staging ([post_tran_id])
INCLUDE ([adj_id],[entry_id],[config_set_id],[session_id],[sdi_tran_id],[acc_post_id],[nt_fee_acc_post_id],[coa_id],
[coa_se_id],[se_id],[amount],[amount_id],[amount_value_id],[fee],[nt_fee],[nt_fee_id],[nt_fee_value_id],[debit_acc_nr_id],[debit_acc_id],
[debit_cardholder_acc_id],[debit_cardholder_acc_type],[credit_acc_nr_id],[credit_acc_id],[credit_cardholder_acc_id],[credit_cardholder_acc_type],
[business_date],[granularity_element],[tag],[spay_session_id],[spst_session_id],[DebitAccNr_config_set_id],[DebitAccNr_acc_nr_id],[DebitAccNr_se_id],
[DebitAccNr_acc_id],[DebitAccNr_acc_nr],[DebitAccNr_aggregation_id],[DebitAccNr_state],[DebitAccNr_config_state],[CreditAccNr_config_set_id],
[CreditAccNr_acc_nr_id],[CreditAccNr_se_id],[CreditAccNr_acc_id],[CreditAccNr_acc_nr],[CreditAccNr_aggregation_id],[CreditAccNr_state],
[CreditAccNr_config_state],[Amount_config_set_id],[Amount_amount_id],[Amount_se_id],[Amount_name],[Amount_description],[Amount_config_state]
,[Fee_config_set_id],[Fee_fee_id],[Fee_se_id],[Fee_name],[Fee_description],[Fee_type],[Fee_amount_id],[Fee_config_state],[coa_config_set_id],
[coa_coa_id],[coa_name],[coa_description],[coa_type],[coa_config_state])WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [ix_temp_journal_data_staging_3] ON temp_journal_data_staging 
(
	[DebitAccNr_acc_nr] ASC
)
INCLUDE ( [CreditAccNr_acc_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_staging_4] ON temp_journal_data_staging 
(
	[CreditAccNr_acc_nr] ASC
)
INCLUDE ( [DebitAccNr_acc_nr]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [ix_temp_journal_data_staging_5] ON temp_journal_data_staging 
(
	[business_date] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

CREATE index ix_temp_journal_data_staging_6 on temp_journal_data_staging(
post_tran_id
)INCLUDE(post_tran_cust_id)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 95) ON [PRIMARY]




SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_1]
ON [dbo].[temp_post_tran_data_staging] ([PT_tran_postilion_originated])
INCLUDE ([PT_post_tran_cust_id],[PT_tran_nr],[PT_retention_data],[PTC_terminal_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_2] ON [temp_post_tran_data_staging] 
(
	[PT_message_type] ASC,
	[PT_tran_type] ASC,
	[PTC_source_node_name] ASC,
	[PT_sink_node_name] ASC,
	[PTC_terminal_id] ASC,
	[PTC_totals_group] ASC,
	[PTC_pan] ASC,
	[PT_settle_amount_impact] ASC,
	[PT_acquiring_inst_id_code] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_3] ON [temp_post_tran_data_staging] 
(
	[PT_post_tran_cust_id] ASC,
	[PT_tran_postilion_originated] ASC,
	[PT_tran_nr] ASC
)
INCLUDE ( [PT_retention_data])
 WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]


CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_4] ON [temp_post_tran_data_staging] 
(
	[PT_tran_postilion_originated] ASC,
	[PTC_totals_group] ASC
)
INCLUDE ( [PT_post_tran_id],
[PT_post_tran_cust_id],
[PT_sink_node_name],
[PT_message_type],
[PT_tran_type],
[PT_tran_nr],
[PT_system_trace_audit_nr],
[PT_acquiring_inst_id_code],
[PT_retrieval_reference_nr],
[PT_settle_amount_impact],
[PT_settle_amount_rsp],
[PT_settle_currency_code],
[PT_tran_reversed],
[PT_extended_tran_type],
[PT_payee],
[PTC_source_node_name],
[PTC_pan],
[PTC_terminal_id],
[PTC_card_acceptor_id_code],
[PTC_merchant_type],
[PTC_card_acceptor_name_loc]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_5] ON [temp_post_tran_data_staging] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_message_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PT_settle_amount_impact] ASC
)
INCLUDE ( [PT_sink_node_name],
[PT_system_trace_audit_nr],
[PT_retrieval_reference_nr],
[PT_to_account_id],
[PT_payee],
[PTC_source_node_name],
[PTC_pan],
[PTC_terminal_id]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_6] ON [temp_post_tran_data_staging] 
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
INCLUDE ( [PT_post_tran_id],
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
[PTC_merchant_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]

CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_7] ON [temp_post_tran_data_staging] 
(   
    
	[PT_post_tran_id]
)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]


CREATE NONCLUSTERED INDEX  [Ix_temp_post_tran_data_staging_8]  ON [dbo]. [temp_post_tran_data_staging]  ([PT_tran_postilion_originated])
INCLUDE ([PT_post_tran_cust_id],[PT_tran_nr],[PT_retention_data],[PTC_terminal_id])

CREATE NONCLUSTERED INDEX [IX_temp_post_tran_data_staging_9] ON [temp_post_tran_data_staging] 
(
	[PT_post_tran_id] ASC,
	[PT_tran_postilion_originated] ASC,
	[PTC_terminal_id] ASC
)

 WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 98) ON [PRIMARY]



 IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[settlement_breakdown_details_staging]') AND type in (N'U'))begin
	DROP TABLE [dbo].[settlement_breakdown_details_staging]
end


			 SELECT   
							   	bank_code = CASE 
                          
WHEN					(dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and  (DebitAccNr_acc_nr LIKE '%FEE_PAYABLE' or CreditAccNr_acc_nr LIKE '%FEE_PAYABLE')) THEN 'ISW' 

WHEN                      
			           (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			           (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'     
                             
                          
                          
WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                          AND ((PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') 
                                OR (PT.PTC_source_node_name = 'SWTFBPsrc' AND PT.PT_sink_node_name = 'ASPPOSVISsnk' 
                                 AND PT.PTC_totals_group = 'VISAGroup')
                               )
                          THEN 'UBA'
                          
                          
WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                          AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code = '627787')
                          THEN 'UNK'
                          
                          --AND (PT.PT_acquiring_inst_id_code <> '627480' or 
                          --(PT.PT_acquiring_inst_id_code = '627480'
                          --and dbo.fn_rpt_terminal_type(PT.PTC_terminal_id) ='3'))
                          
WHEN                      
			(PT.PT_sink_node_name = 'SWTWEBUBAsnk')  
                        AND  
			(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                         OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
  			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                         PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'                             
                          
WHEN                      
			(PT.PT_sink_node_name = 'SWTWEBUBAsnk')  
                        AND  
			(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                         OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
  			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                         PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '312' and PT.PT_tran_type = '50')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'   
                          
                          
  WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                        AND  PT.PT_acquiring_inst_id_code <> '627787' 
                              AND PT.PT_sink_node_name = 'ASPPOSVISsnk'    
                          THEN 'UBA'     
                          
                                                    
 WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                        AND  PT.PT_acquiring_inst_id_code = '627787'  
                        AND PT.PT_sink_node_name = 'ASPPOSVISsnk'   
                          THEN 'GTB'       
                          
                           
                                                      
 WHEN                      
						(PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  
                           AND  
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                          THEN 'ABP'   
                          
    WHEN                     
					 (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
					 (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                                   
                          THEN 'GTB'                                                                        
                           
   WHEN                     
						 (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk')  AND
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                                  
                          THEN 'EBN'  
                          
   WHEN                   
						(PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                                   
                          THEN 'UBA'                                             
                           
 /* WHEN                     (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                          AND PT.PT_acquiring_inst_id_code = '627480' 
                           THEN 'UBA' */
                           
 /*WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                           OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                          --AND PT.PT_acquiring_inst_id_code <> '627480' 
                           THEN 'GTB'*/


WHEN PTT.PT_Retention_data = '1046' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'UBN'
WHEN PTT.PT_Retention_data in ('9130','8130') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABS'
WHEN PTT.PT_Retention_data in ('9044','8044') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABP'
WHEN PTT.PT_Retention_data in ('9023','8023')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'CITI'
WHEN PTT.PT_Retention_data in ('9050','8050') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'EBN'
WHEN PTT.PT_Retention_data in ('9214','8214') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FCMB'
WHEN PTT.PT_Retention_data in ('9070','8070','1100') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBP'
WHEN PTT.PT_Retention_data in ('9011','8011') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBN'
WHEN PTT.PT_Retention_data in ('9058','8058')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'GTB'
WHEN PTT.PT_Retention_data in ('9082','8082') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'KSB'
WHEN PTT.PT_Retention_data in ('9076','8076') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SKYE'
WHEN PTT.PT_Retention_data in ('9084','8084') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ENT'
WHEN PTT.PT_Retention_data in ('9039','8039') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'IBTC'
WHEN PTT.PT_Retention_data in ('9068','8068') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SCB'
WHEN PTT.PT_Retention_data in ('9232','8232','1105') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SBP'
WHEN PTT.PT_Retention_data in ('9032','8032')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBN'
WHEN PTT.PT_Retention_data in ('9033','8033')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBA'
WHEN PTT.PT_Retention_data in ('9215','8215')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBP'
WHEN PTT.PT_Retention_data in ('9035','8035') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'WEMA'
WHEN PTT.PT_Retention_data in ('9057','8057') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ZIB'
WHEN PTT.PT_Retention_data in ('9301','8301') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'JBP'
WHEN PTT.PT_Retention_data in ('9030') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'HBC'
						  
WHEN PTT.PT_Retention_data = '1411' and 
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
						OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
						OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'HBC'
                          						                     	                                       
			
			
			WHEN PTT.PT_Retention_data = '1131' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'WEMA'
                         WHEN PTT.PT_Retention_data in ('1061','1006') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'

                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'GTB'
                         WHEN PTT.PT_Retention_data = '1708' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'FBN'
                         WHEN PTT.PT_Retention_data in ('1027','1045','1081','1015') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'SKYE'
                         WHEN PTT.PT_Retention_data = '1037' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'IBTC'
                         WHEN PTT.PT_Retention_data = '1034' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'EBN'
                         -- WHEN PTT.Retention_data = '1006' and 
                         --(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                         -- OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                         -- OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'DBL'
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
						WHEN (DebitAccNr_acc_nr LIKE 'OMO%' OR CreditAccNr_acc_nr LIKE 'OMO%') THEN 'OMO'
						WHEN (DebitAccNr_acc_nr LIKE 'SUN%' OR CreditAccNr_acc_nr LIKE 'SUN%') THEN 'SUN'
						WHEN (DebitAccNr_acc_nr LIKE 'NGB%' OR CreditAccNr_acc_nr LIKE 'NGB%') THEN 'NGB'
						WHEN (DebitAccNr_acc_nr LIKE 'OSC%' OR CreditAccNr_acc_nr LIKE 'OSC%') THEN 'OSC'
						WHEN (DebitAccNr_acc_nr LIKE 'OSP%' OR CreditAccNr_acc_nr LIKE 'OSP%') THEN 'OSP'
						WHEN (DebitAccNr_acc_nr LIKE 'IFIS%' OR CreditAccNr_acc_nr LIKE 'IFIS%') THEN 'IFIS'
						WHEN (DebitAccNr_acc_nr LIKE 'NPM%' OR CreditAccNr_acc_nr LIKE 'NPM%') THEN 'NPM'
						WHEN (DebitAccNr_acc_nr LIKE 'POL%' OR CreditAccNr_acc_nr LIKE 'POL%') THEN 'POL'
						WHEN (DebitAccNr_acc_nr LIKE 'ALV%' OR CreditAccNr_acc_nr LIKE 'ALV%') THEN 'ALV'
						WHEN (DebitAccNr_acc_nr LIKE 'MAY%' OR CreditAccNr_acc_nr LIKE 'MAY%') THEN 'MAY'
						WHEN (DebitAccNr_acc_nr LIKE 'PRO%' OR CreditAccNr_acc_nr LIKE 'PRO%') THEN 'PRO'
						WHEN (DebitAccNr_acc_nr LIKE 'UNIL%' OR CreditAccNr_acc_nr LIKE 'UNIL%') THEN 'UNIL'
						WHEN (DebitAccNr_acc_nr LIKE 'PAR%' OR CreditAccNr_acc_nr LIKE 'PAR%') THEN 'PAR'
						WHEN (DebitAccNr_acc_nr LIKE 'FOR%' OR CreditAccNr_acc_nr LIKE 'FOR%') THEN 'FOR'
							WHEN (DebitAccNr_acc_nr LIKE 'MON%' OR CreditAccNr_acc_nr LIKE 'MON%') THEN 'MON'
							WHEN (DebitAccNr_acc_nr LIKE 'NDI%' OR CreditAccNr_acc_nr LIKE 'NDI%') THEN 'NDI'
							WHEN (DebitAccNr_acc_nr LIKE 'ARM%' OR CreditAccNr_acc_nr LIKE 'ARM%') THEN 'ARM'	
							WHEN (DebitAccNr_acc_nr LIKE 'OKW%' OR CreditAccNr_acc_nr LIKE 'OKW%') THEN 'OKW'						
                         WHEN (DebitAccNr_acc_nr LIKE 'POS_FOODCONCEPT%' OR CreditAccNr_acc_nr LIKE 'POS_FOODCONCEPT%') THEN 'SCB'
			 WHEN ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.PT_tran_type ='01')  
							AND dbo.fn_rpt_CardGroup(PT.PTC_PAN) in ('1','4')
                           AND PT.PTC_source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                            WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Verve Token)'
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)'
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 3 
                           THEN 'ATM WITHDRAWAL (Cardless:Non-Card Generated)'

						   WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr  LIKE '%ATM%ISO%' OR CreditAccNr_acc_nr LIKE '%ATM%ISO%')
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           AND PT.PTC_source_node_name <> 'ASPSPNOUsrc'                           
                           THEN 'ATM WITHDRAWAL (MASTERCARD ISO)'


                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           AND PT.PTC_source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                                                                           
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 

                           and (DebitAccNr_acc_nr LIKE '%V%BILLING%' OR CreditAccNr_acc_nr LIKE '%V%BILLING%')
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PTC_source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			               WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' and 
                           (DebitAccNr_acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr_acc_nr like '%BILLPAYMENT MCARD%') ) then 'BILLPAYMENT MASTERCARD BILLING'

                           WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' 
                           and (DebitAccNr_acc_nr like '%SVA_FEE_RECEIVABLE' or CreditAccNr_acc_nr like '%SVA_FEE_RECEIVABLE') ) 
                           AND dbo.fn_rpt_isBillpayment_IFIS(PT.PTC_terminal_id) = 1  then 'BILLPAYMENT IFIS REMITTANCE'
                          
			               WHEN ( dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1')  then 'BILLPAYMENT'
			   
			
                           WHEN (PT.PT_tran_type ='40'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' 

                           or SUBSTRING(PT.PTC_terminal_id,1,1)= '0' or SUBSTRING(PT.PTC_terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           AND SUBSTRING(PT.PTC_terminal_id,1,1)IN ('2','5','6')AND PT.PT_sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN 'POS PURCHASE (Cardless:Paycode Verve Token)'
                           
                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           AND SUBSTRING(PT.PTC_terminal_id,1,1)IN ('2','5','6')AND PT.PT_sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN 'POS PURCHASE (Cardless:Paycode Non-Verve Token)'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '1'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                            or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(EASYFUEL)PURCHASE'
                           
                           WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES-VISA)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE CLUBS-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                           

                           --WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='1'
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           --or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           --WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='2'
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           --or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           --WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='3'
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           --or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.PTC_merchant_type
                              
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1 OR PT.PT_tran_type = '50')
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.PTC_merchant_type
                              
                              
                              WHEN (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name IN ('SWTWEBEBNsnk','SWTWEBUBAsnk','SWTWEBGTBsnk','SWTWEBABPsnk'))
                              and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                              and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                              AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                              THEN 'WEB(GENERIC)PURCHASE'
                              
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) 
                           THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '19'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '20'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '21'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '22'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '23'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'Verify card � Ecash load'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '24'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '25'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '26'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Payment_Gateway_0.9%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '27'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Payment_Gateway_1.25%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '28'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Add_Card)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '30'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(0.75% CAPPED AT 1,000 CATEGORY)PURCHASE'
                            
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '31'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1% CAPPED AT N50 CATEGORY)PURCHASE'                     
                                                      
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and (DebitAccNr_acc_nr LIKE '%fee%' OR CreditAccNr_acc_nr LIKE '%fee%')
                                 and (PT.PT_tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.PTC_source_node_name,PT.PT_tran_type,PT.PT_payee) = 1))
                                 and not (DebitAccNr_acc_nr like '%PREPAIDLOAD%' or CreditAccNr_acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and (DebitAccNr_acc_nr NOT LIKE '%fee%' OR CreditAccNr_acc_nr NOT LIKE '%fee%')

                                 and PT.PT_tran_type in ('50')
                                 and not (DebitAccNr_acc_nr like '%PREPAIDLOAD%' or CreditAccNr_acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFERS'
                                 
                          WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                           PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50' and PT.PT_extended_tran_type = '6011') THEN 'ATM CARDLESS-TRANSFERS'     

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '2' and PT.PT_tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '4' and PT.PT_tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '35' and PT.PT_tran_type = '50') then 'REMITA TRANSFERS'

       
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '31' and PT.PT_tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '32' and PT.PT_tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '33' and PT.PT_tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '34' and PT.PT_tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '36' and PT.PT_tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '37' and PT.PT_tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '38' and PT.PT_tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '39' and PT.PT_tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '310' and PT.PT_tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '311' and PT.PT_tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '312'  and PT.PT_tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '314'  and PT.PT_tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '315' and PT.PT_tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '316' and PT.PT_tran_type = '50') then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '317' and PT.PT_tran_type = '50') then 'OTHER TRANSFERS(ACCESSBANK PORTAL)'
                                  
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr_acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr_acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PT.PTC_source_node_name ,PT.PTC_pan, PT.PT_tran_type)= '1') then 'PREPAID CARDLOAD'

                          when PT.PT_tran_type = '21' then 'DEPOSIT'

                           /*WHEN (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%ISO_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%ISO_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'*/
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE 
                     /* WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'*/
                      
                      /*WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'*/
                      
                     /* WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'*/ 
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'
                          
                     WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk'  AND
                     (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                        THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                        
                        THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                          THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'    
                        
                    WHEN                      
			        (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			        (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'     
                        
                      WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk'  AND
                    (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE')
		             and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                     THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'

					WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
                     (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
					 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'   
		             THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'    
                           
                          
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                     (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'     
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'  
                      
                       
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (DebitAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (DebitAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (DebitAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (DebitAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (DebitAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
  
  
                     
                      /*WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'*/
                      
                       /* WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)' */
                         
                         
                      WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                      PT.PT_acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                           PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                           
                     WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk'  AND
                     (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)' 
                      
                      WHEN                      
			       (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			        (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      
                      WHEN 
                      PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE')
		              and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'   
		            THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'

        
 
				WHEN 
                   PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
		          (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
 		           and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                   AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'   
		           THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                     WHEN 
                     (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  AND
                     (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                          THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                          
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                     THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                        WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'    
                      
                      WHEN 
                     (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk')  AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)' 
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk')  AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)' 
                                               
                          WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr_acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr_acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'
                         
                          WHEN (CreditAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          
                          WHEN (CreditAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 
			  WHEN (CreditAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)'
			  WHEN (CreditAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'

                          ELSE 'UNK'			
END,

       trxn_amount=ISNULL(J.amount,0),
	trxn_fee=ISNULL(J.fee,0),
	trxn_date=j.business_date,
        currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' and 
                           (DebitAccNr_acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr_acc_nr like '%BILLPAYMENT MCARD%') ) THEN '840'
                        WHEN ((DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%') and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTUBAsnk','SWTJBPsnk','SWTJAIZsnk','SWTFCMBsnk'))) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM%ISO%ACQUIRER%' OR CreditAccNr_acc_nr LIKE '%ATM%ISO%ACQUIRER%') ) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM_FEE_ACQ_ISO%' OR CreditAccNr_acc_nr LIKE '%ATM_FEE_ACQ_ISO%') ) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM%ISO%ISSUER%' OR CreditAccNr_acc_nr LIKE '%ATM%ISO%ISSUER%') and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTPLATsnk'))) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM_FEE_ISS_ISO%' OR CreditAccNr_acc_nr LIKE '%ATM_FEE_ISS_ISO%') and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTPLATsnk'))) THEN '840'
					    ELSE PT.PT_settle_currency_code END,
        late_reversal = CASE
        
                        WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                               and PT.PTC_merchant_type in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511') THEN 0
                               
						WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
        card_type =  dbo.fn_rpt_CardGroup(PT.PTC_pan),
        terminal_type = dbo.fn_rpt_terminal_type(PT.PTC_terminal_id),    
        source_node_name =   PT.PTC_source_node_name,
        Unique_key = PT.PT_retrieval_reference_nr+'_'+PT.PT_system_trace_audit_nr+'_'+PT.PTC_terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(PT.PT_settle_amount_impact,0))) as VARCHAR(20))+'_'+PT.PT_message_type,
        Acquirer = (case when (not ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.PT_acquiring_inst_id_code oR acc.acquirer_inst_id4 = PT.PT_acquiring_inst_id_code oR acc.acquirer_inst_id5 = PT.PT_acquiring_inst_id_code) then acc.bank_code 
                      else PT.PT_acquiring_inst_id_code END),
        Issuer = (case when (not ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) and (substring(PT.PTC_totals_group,1,3) = acc.bank_code1) then acc.bank_code
                      else substring(PT.PTC_totals_group,1,3) END),
       Volume = (case when PT.PT_message_type in ('0200','0220') then 1
	                   else 0 end),  
           Value_RequestedAmount = PT.PT_settle_amount_req,
           Value_SettleAmount = PT.PT_settle_amount_impact,
          index_no = null	  ,[adj_id],[entry_id],[config_set_id],[session_id],[sdi_tran_id],[acc_post_id],[nt_fee_acc_post_id],[coa_id],[coa_se_id],[se_id],[amount],[amount_id],[amount_value_id],[fee], [fee_id], [fee_value_id],[nt_fee],[nt_fee_id],[nt_fee_value_id],[debit_acc_nr_id],[debit_acc_id],[debit_cardholder_acc_id],[debit_cardholder_acc_type],[credit_acc_nr_id],[credit_acc_id],[credit_cardholder_acc_id],[credit_cardholder_acc_type],[business_date],[granularity_element],[tag],[spay_session_id],[spst_session_id],[DebitAccNr_config_set_id],[DebitAccNr_acc_nr_id],[DebitAccNr_se_id],[DebitAccNr_acc_id],[DebitAccNr_acc_nr],[DebitAccNr_aggregation_id],[DebitAccNr_state],[DebitAccNr_config_state],[CreditAccNr_config_set_id],[CreditAccNr_acc_nr_id],[CreditAccNr_se_id],[CreditAccNr_acc_id],[CreditAccNr_acc_nr],[CreditAccNr_aggregation_id],[CreditAccNr_state],[CreditAccNr_config_state],[Amount_config_set_id],[Amount_amount_id],[Amount_se_id],[Amount_name],[Amount_description],[Amount_config_state],[Fee_config_set_id],[Fee_fee_id],[Fee_se_id],[Fee_name],[Fee_description],[Fee_type],[Fee_amount_id],[Fee_config_state],[coa_config_set_id],[coa_coa_id],[coa_name],[coa_description],[coa_type],[coa_config_state],pt.[pt_batch_nr],pt.[PT_post_tran_id] ,pt.[PT_post_tran_cust_id]  ,pt.[PT_settle_entity_id],pt.[PT_prev_post_tran_id],pt.[PT_next_post_tran_id],pt.[PT_sink_node_name],pt.[PT_tran_postilion_originated],pt.[PT_tran_completed],pt.[PT_message_type],pt.[PT_tran_type],pt.[PT_tran_nr],pt.[PT_system_trace_audit_nr],pt.[PT_rsp_code_req],pt.[PT_rsp_code_rsp],pt.[PT_abort_rsp_code],pt.[PT_auth_id_rsp],pt.[PT_auth_type],pt.[PT_auth_reason],pt.[PT_retention_data],pt.[PT_acquiring_inst_id_code],pt.[PT_message_reason_code],pt.[PT_sponsor_bank],pt.[PT_retrieval_reference_nr],pt.[PT_datetime_tran_gmt],pt.[PT_datetime_tran_local],pt.[PT_datetime_req],pt.[PT_datetime_rsp],pt.[PT_realtime_business_date],pt.[PT_recon_business_date],pt.[PT_from_account_type],pt.[PT_to_account_type],pt.[PT_from_account_id],pt.[PT_to_account_id],pt.[PT_tran_amount_req],pt.[PT_tran_amount_rsp],pt.[PT_settle_amount_impact],pt.[PT_tran_cash_req],pt.[PT_tran_cash_rsp],pt.[PT_tran_currency_code],pt.[PT_tran_tran_fee_req],pt.[PT_tran_tran_fee_rsp],pt.[PT_tran_tran_fee_currency_code],pt.[PT_tran_proc_fee_req],pt.[PT_tran_proc_fee_rsp],pt.[PT_tran_proc_fee_currency_code],pt.[PT_settle_amount_req],pt.[PT_settle_amount_rsp],pt.[PT_settle_cash_req],pt.[PT_settle_cash_rsp],pt.[PT_settle_tran_fee_req],pt.[PT_settle_tran_fee_rsp],pt.[PT_settle_proc_fee_req],pt.[PT_settle_proc_fee_rsp],pt.[PT_settle_currency_code],pt.[PT_pos_entry_mode],pt.[PT_pos_condition_code],pt.[PT_additional_rsp_data],pt.[PT_tran_reversed],pt.[PT_prev_tran_approved],pt.[PT_issuer_network_id],pt.[PT_acquirer_network_id],pt.[PT_extended_tran_type],pt.[PT_from_account_type_qualifier],pt.[PT_to_account_type_qualifier],pt.[PT_bank_details],pt.[PT_payee],pt.[PT_card_verification_result],pt.[PT_online_system_id],pt.[PT_participant_id],pt.[PT_opp_participant_id],pt.[PT_receiving_inst_id_code],pt.[PT_routing_type],pt.[PT_pt_pos_operating_environment],pt.[PT_pt_pos_card_input_mode],pt.[PT_pt_pos_cardholder_auth_method],pt.[PT_pt_pos_pin_capture_ability],pt.[PT_pt_pos_terminal_operator],pt.[PT_source_node_key],pt.[PT_proc_online_system_id],pt.[PTC_post_tran_cust_id],pt.[PTC_source_node_name],pt.[PTC_draft_capture],pt.[PTC_pan],pt.[PTC_card_seq_nr],pt.[PTC_expiry_date],pt.[PTC_service_restriction_code],pt.[PTC_terminal_id],pt.[PTC_terminal_owner],pt.[PTC_card_acceptor_id_code],pt.[PTC_mapped_card_acceptor_id_code],pt.[PTC_merchant_type],pt.[PTC_card_acceptor_name_loc],pt.[PTC_address_verification_data],pt.[PTC_address_verification_result],pt.[PTC_check_data],pt.[PTC_totals_group],pt.[PTC_card_product],pt.[PTC_pos_card_data_input_ability],pt.[PTC_pos_cardholder_auth_ability],pt.[PTC_pos_card_capture_ability],pt.[PTC_pos_operating_environment],pt.[PTC_pos_cardholder_present],pt.[PTC_pos_card_present],pt.[PTC_pos_card_data_input_mode],pt.[PTC_pos_cardholder_auth_method],pt.[PTC_pos_cardholder_auth_entity],pt.[PTC_pos_card_data_output_ability],pt.[PTC_pos_terminal_output_ability],pt.[PTC_pos_pin_capture_ability],pt.[PTC_pos_terminal_operator],pt.[PTC_pos_terminal_type],pt.[PTC_pan_search],pt.[PTC_pan_encrypted],pt.[PTC_pan_reference]

			 													INTO settlement_breakdown_details_staging
			 														 
			 														 FROM 
			 														 (select  
[adj_id],[entry_id],[config_set_id],[session_id],[post_tran_id],[post_tran_cust_id],[sdi_tran_id],[acc_post_id],[nt_fee_acc_post_id],[coa_id],[coa_se_id],[se_id],[amount],[amount_id],[amount_value_id],[fee],[fee_id],[fee_value_id],[nt_fee],[nt_fee_id],[nt_fee_value_id],[debit_acc_nr_id],[debit_acc_id],[debit_cardholder_acc_id],[debit_cardholder_acc_type],[credit_acc_nr_id],[credit_acc_id],[credit_cardholder_acc_id],[credit_cardholder_acc_type],[business_date],[granularity_element],[tag],[spay_session_id],[spst_session_id],[DebitAccNr_config_set_id],[DebitAccNr_acc_nr_id],[DebitAccNr_se_id],[DebitAccNr_acc_id],[DebitAccNr_acc_nr],[DebitAccNr_aggregation_id],[DebitAccNr_state],[DebitAccNr_config_state],[CreditAccNr_config_set_id],[CreditAccNr_acc_nr_id],[CreditAccNr_se_id],[CreditAccNr_acc_id],[CreditAccNr_acc_nr],[CreditAccNr_aggregation_id],[CreditAccNr_state],[CreditAccNr_config_state],[Amount_config_set_id],[Amount_amount_id],[Amount_se_id],[Amount_name],[Amount_description],[Amount_config_state],[Fee_config_set_id],[Fee_fee_id],[Fee_se_id],[Fee_name],[Fee_description],[Fee_type],[Fee_amount_id],[Fee_config_state],[coa_config_set_id],[coa_coa_id],[coa_name],[coa_description],[coa_type],[coa_config_state]
																	 from  temp_journal_data_staging  with(NOLOCK, INDEX =ix_temp_journal_data_staging_6)   )J
			 																			 JOIN 
			 												 (SELECT * FROM temp_post_tran_data_staging with  (NOLOCK, index =IX_temp_post_tran_data_staging_7) WHERE PT_tran_postilion_originated =0)   PT 
			 													ON (J.post_tran_id = PT.PT_post_tran_id   and substring(pt.ptc_terminal_id,1,1)!='G')
			 												LEFT   JOIN 
			 								  (SELECT  PT_post_tran_id,PT_post_tran_cust_id,ptc_terminal_id,PT_tran_nr, PT_retention_data FROM temp_post_tran_data_staging with(NOLOCK, index =IX_temp_post_tran_data_staging_3) WHERE PT_tran_postilion_originated =1)PTT 
			 																ON
			 																(PT.PT_post_tran_cust_id = PTT.PT_post_tran_cust_id and substring(ptT.ptc_terminal_id,1,1)!='G' and PT.PT_tran_nr = PTT.PT_tran_nr)  
			 																   LEFT OUTER JOIN aid_cbn_code acc ON
			 														  pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5)
			 														   
			 																		 	and 
			 																			
			 															(
			 																  (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in ('0200','0220'))
			 															   or ((PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 
			 															   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,  PT.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,PT.PTC_totals_group ,PT.ptc_pan) <> 1
			 																and PT.PT_tran_reversed <> 2)
			 															   or (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 
			 															   and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type, pt.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,pt.PTC_totals_group ,pt.PTC_pan) = 1 ))
			 															   or (PT.PT_settle_amount_rsp<> 0 and PT.PT_message_type   in ('0200','0220') and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1) IN ('0','1') ))
			 															   or (PT.PT_message_type = '0420' and PT.PT_tran_reversed <> 2 and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1)IN ( '0','1' ))))
			 														     
			 															  AND not (pt.PTC_merchant_type in ('4004',' 4722') and PT.PT_tran_type = '00' and pt.PTC_source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(PT.PT_settle_amount_impact/100)< 200
			 															   and not (CHARINDEX( 'Mcard', DebitAccNr_acc_nr) > 0  and CHARINDEX( 'Billing',  DebitAccNr_acc_nr) > 0 OR  ( CHARINDEX( 'Mcard', CreditAccNr_acc_nr) > 0  and CHARINDEX( 'Billing',  CreditAccNr_acc_nr) > 0 )
																		   ))
			 															  AND pt.PTC_totals_group <>'CUPGroup'
			 															  and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_acquiring_inst_id_code = '627787')
			 															  and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_sink_node_name not  in ('ASPPOSVINsnk')
			 																		and not (pt.ptc_source_node_name in ('SWTFBPsrc','SWTUBAsrc','SWTZIBsrc','SWTPLATsrc') and PT.PT_sink_node_name = 'ASPPOSVISsnk') 
			 																	   )
			 															 and not (PT.ptc_source_node_name  = 'MEGATPPsrc' and PT.PT_tran_type = '00' ) 														 
			 	
			 														  OPTION (RECOMPILE,optimize for unknown)			  
			
--CREATE TABLE [dbo].[settlement_breakdown_details_staging](	[bank_code] [varchar](10) NOT NULL,	[trxn_category] [varchar](49) NULL,	[Debit_account_type] [varchar](55) NOT NULL,	[Credit_account_type] [varchar](56) NOT NULL,	[trxn_amount] [float] NOT NULL,	[trxn_fee] [float] NOT NULL,	[trxn_date] [datetime] NOT NULL,	[currency] [char](3) NULL,	[late_reversal] [int] NOT NULL,	[card_type] [int] NULL,	[terminal_type] [int] NULL,	[source_node_name] [dbo].[POST_NAME] NULL,	[Unique_key] [varchar](54) NULL,	[Acquirer] [varchar](50) NULL,	[Issuer] [varchar](50) NULL,	[Volume] [int] NOT NULL,	[Value_RequestedAmount] [dbo].[POST_MONEY] NULL,	[Value_SettleAmount] [dbo].[POST_MONEY] NULL,	[index_no] [int] IDENTITY(1,1) NOT NULL,	[adj_id] [bigint] NULL,	[entry_id] [bigint] NULL,	[config_set_id] [int] NOT NULL,	[session_id] [int] NULL,	[sdi_tran_id] [bigint] NULL,	[acc_post_id] [int] NULL,	[nt_fee_acc_post_id] [int] NULL,	[coa_id] [int] NOT NULL,	[coa_se_id] [int] NOT NULL,	[se_id] [int] NOT NULL,	[amount] [float] NULL,	[amount_id] [int] NULL,	[amount_value_id] [int] NULL,	[fee] [float] NULL,	[fee_id] [int] NULL,	[fee_value_id] [int] NULL,	[nt_fee] [float] NULL,	[nt_fee_id] [int] NULL,	[nt_fee_value_id] [int] NULL,	[debit_acc_nr_id] [int] NULL,	[debit_acc_id] [int] NULL,	[debit_cardholder_acc_id] [varchar](28) NULL,	[debit_cardholder_acc_type] [char](2) NULL,	[credit_acc_nr_id] [int] NULL,	[credit_acc_id] [int] NULL,	[credit_cardholder_acc_id] [varchar](28) NULL,	[credit_cardholder_acc_type] [char](2) NULL,	[business_date] [datetime] NOT NULL,	[granularity_element] [varchar](100) NULL,	[tag] [varchar](4000) NULL,	[spay_session_id] [int] NULL,	[spst_session_id] [int] NULL,	[DebitAccNr_config_set_id] [int] NULL,	[DebitAccNr_acc_nr_id] [int] NULL,	[DebitAccNr_se_id] [int] NULL,	[DebitAccNr_acc_id] [int] NULL,	[DebitAccNr_acc_nr] [varchar](40) NULL,	[DebitAccNr_aggregation_id] [int] NULL,	[DebitAccNr_state] [int] NULL,	[DebitAccNr_config_state] [int] NULL,	[CreditAccNr_config_set_id] [int] NULL,	[CreditAccNr_acc_nr_id] [int] NULL,	[CreditAccNr_se_id] [int] NULL,	[CreditAccNr_acc_id] [int] NULL,	[CreditAccNr_acc_nr] [varchar](40) NULL,	[CreditAccNr_aggregation_id] [int] NULL,	[CreditAccNr_state] [int] NULL,	[CreditAccNr_config_state] [int] NULL,	[Amount_config_set_id] [int] NULL,	[Amount_amount_id] [int] NULL,	[Amount_se_id] [int] NULL,	[Amount_name] [varchar](100) NULL,	[Amount_description] [varchar](255) NULL,	[Amount_config_state] [int] NULL,	[Fee_config_set_id] [int] NULL,	[Fee_fee_id] [int] NULL,	[Fee_se_id] [int] NULL,	[Fee_name] [varchar](100) NULL,	[Fee_description] [varchar](255) NULL,	[Fee_type] [int] NULL,	[Fee_amount_id] [int] NULL,	[Fee_config_state] [int] NULL,	[coa_config_set_id] [int] NULL,	[coa_coa_id] [int] NULL,	[coa_name] [varchar](100) NULL,	[coa_description] [varchar](255) NULL,	[coa_type] [int] NULL,	[coa_config_state] [int] NULL,	[pt_batch_nr] [int] NULL,	[PT_post_tran_id] [bigint] NOT NULL,	[PT_post_tran_cust_id] [bigint] NOT NULL,	[PT_settle_entity_id] [dbo].[POST_ID] NULL,	[PT_prev_post_tran_id] [bigint] NULL,	[PT_next_post_tran_id] [bigint] NULL,	[PT_sink_node_name] [dbo].[POST_NAME] NULL,	[PT_tran_postilion_originated] [dbo].[POST_BOOL] NOT NULL,	[PT_tran_completed] [dbo].[POST_BOOL] NOT NULL,	[PT_message_type] [char](4) NOT NULL,	[PT_tran_type] [char](2) NULL,	[PT_tran_nr] [bigint] NOT NULL,	[PT_system_trace_audit_nr] [char](6) NULL,	[PT_rsp_code_req] [char](2) NULL,	[PT_rsp_code_rsp] [char](2) NULL,	[PT_abort_rsp_code] [char](2) NULL,	[PT_auth_id_rsp] [varchar](10) NULL,	[PT_auth_type] [numeric](1, 0) NULL,	[PT_auth_reason] [numeric](1, 0) NULL,	[PT_retention_data] [varchar](999) NULL,	[PT_acquiring_inst_id_code] [varchar](11) NULL,	[PT_message_reason_code] [char](4) NULL,	[PT_sponsor_bank] [char](8) NULL,	[PT_retrieval_reference_nr] [char](12) NULL,	[PT_datetime_tran_gmt] [datetime] NULL,	[PT_datetime_tran_local] [datetime] NOT NULL,	[PT_datetime_req] [datetime] NOT NULL,	[PT_datetime_rsp] [datetime] NULL,	[PT_realtime_business_date] [datetime] NOT NULL,	[PT_recon_business_date] [datetime] NOT NULL,	[PT_from_account_type] [char](2) NULL,	[PT_to_account_type] [char](2) NULL,	[PT_from_account_id] [varchar](28) NULL,	[PT_to_account_id] [varchar](28) NULL,	[PT_tran_amount_req] [dbo].[POST_MONEY] NULL,	[PT_tran_amount_rsp] [dbo].[POST_MONEY] NULL,	[PT_settle_amount_impact] [dbo].[POST_MONEY] NULL,	[PT_tran_cash_req] [dbo].[POST_MONEY] NULL,	[PT_tran_cash_rsp] [dbo].[POST_MONEY] NULL,	[PT_tran_currency_code] [dbo].[POST_CURRENCY] NULL,	[PT_tran_tran_fee_req] [dbo].[POST_MONEY] NULL,	[PT_tran_tran_fee_rsp] [dbo].[POST_MONEY] NULL,	[PT_tran_tran_fee_currency_code] [dbo].[POST_CURRENCY] NULL,	[PT_tran_proc_fee_req] [dbo].[POST_MONEY] NULL,	[PT_tran_proc_fee_rsp] [dbo].[POST_MONEY] NULL,	[PT_tran_proc_fee_currency_code] [dbo].[POST_CURRENCY] NULL,	[PT_settle_amount_req] [dbo].[POST_MONEY] NULL,	[PT_settle_amount_rsp] [dbo].[POST_MONEY] NULL,	[PT_settle_cash_req] [dbo].[POST_MONEY] NULL,	[PT_settle_cash_rsp] [dbo].[POST_MONEY] NULL,	[PT_settle_tran_fee_req] [dbo].[POST_MONEY] NULL,	[PT_settle_tran_fee_rsp] [dbo].[POST_MONEY] NULL,	[PT_settle_proc_fee_req] [dbo].[POST_MONEY] NULL,	[PT_settle_proc_fee_rsp] [dbo].[POST_MONEY] NULL,	[PT_settle_currency_code] [dbo].[POST_CURRENCY] NULL,	[PT_pos_entry_mode] [char](3) NULL,	[PT_pos_condition_code] [char](2) NULL,	[PT_additional_rsp_data] [varchar](25) NULL,	[PT_tran_reversed] [char](1) NULL,	[PT_prev_tran_approved] [dbo].[POST_BOOL] NULL,	[PT_issuer_network_id] [varchar](11) NULL,	[PT_acquirer_network_id] [varchar](11) NULL,	[PT_extended_tran_type] [char](4) NULL,	[PT_from_account_type_qualifier] [char](1) NULL,	[PT_to_account_type_qualifier] [char](1) NULL,	[PT_bank_details] [varchar](31) NULL,	[PT_payee] [char](25) NULL,	[PT_card_verification_result] [char](1) NULL,	[PT_online_system_id] [int] NULL,	[PT_participant_id] [int] NULL,	[PT_opp_participant_id] [int] NULL,	[PT_receiving_inst_id_code] [varchar](11) NULL,	[PT_routing_type] [int] NULL,	[PT_pt_pos_operating_environment] [char](1) NULL,	[PT_pt_pos_card_input_mode] [char](1) NULL,	[PT_pt_pos_cardholder_auth_method] [char](1) NULL,	[PT_pt_pos_pin_capture_ability] [char](1) NULL,	[PT_pt_pos_terminal_operator] [char](1) NULL,	[PT_source_node_key] [varchar](32) NULL,	[PT_proc_online_system_id] [int] NULL,	[PTC_post_tran_cust_id] [bigint] NULL,	[PTC_source_node_name] [dbo].[POST_NAME] NULL,	[PTC_draft_capture] [dbo].[POST_ID] NULL,	[PTC_pan] [varchar](19) NULL,	[PTC_card_seq_nr] [varchar](3) NULL,	[PTC_expiry_date] [char](4) NULL,	[PTC_service_restriction_code] [char](3) NULL,	[PTC_terminal_id] [dbo].[POST_TERMINAL_ID] NULL,	[PTC_terminal_owner] [varchar](25) NULL,	[PTC_card_acceptor_id_code] [char](15) NULL,	[PTC_mapped_card_acceptor_id_code] [char](15) NULL,	[PTC_merchant_type] [char](4) NULL,	[PTC_card_acceptor_name_loc] [char](40) NULL,	[PTC_address_verification_data] [varchar](29) NULL,	[PTC_address_verification_result] [char](1) NULL,	[PTC_check_data] [varchar](70) NULL,	[PTC_totals_group] [varchar](12) NULL,	[PTC_card_product] [varchar](20) NULL,	[PTC_pos_card_data_input_ability] [char](1) NULL,	[PTC_pos_cardholder_auth_ability] [char](1) NULL,	[PTC_pos_card_capture_ability] [char](1) NULL,	[PTC_pos_operating_environment] [char](1) NULL,	[PTC_pos_cardholder_present] [char](1) NULL,	[PTC_pos_card_present] [char](1) NULL,	[PTC_pos_card_data_input_mode] [char](1) NULL,	[PTC_pos_cardholder_auth_method] [char](1) NULL,	[PTC_pos_cardholder_auth_entity] [char](1) NULL,	[PTC_pos_card_data_output_ability] [char](1) NULL,	[PTC_pos_terminal_output_ability] [char](1) NULL,	[PTC_pos_pin_capture_ability] [char](1) NULL,	[PTC_pos_terminal_operator] [char](1) NULL,	[PTC_pos_terminal_type] [char](2) NULL,	[PTC_pan_search] [int] NULL,	[PTC_pan_encrypted] [char](18) NULL,	[PTC_pan_reference] [char](42) NULL) ON [PRIMARY]
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_1] ON [dbo].[settlement_breakdown_details_staging]([index_no]);
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_2] ON [dbo].[settlement_breakdown_details_staging] ([Unique_key],[source_node_name])INCLUDE ([index_no])	;	
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_3] ON [dbo].[settlement_breakdown_details_staging]  ([Unique_key])INCLUDE ([source_node_name]);
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_4] ON [dbo].[settlement_breakdown_details_staging] ([source_node_name])INCLUDE ([Unique_key]);
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_5] ON [dbo].[settlement_breakdown_details_staging] ([source_node_name])INCLUDE (PT_post_tran_id);
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_6] ON [dbo].[settlement_breakdown_details_staging]  ( PT_acquiring_inst_id_code	);
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_7] ON [dbo].[settlement_breakdown_details_staging] ( ptc_card_acceptor_id_code) include(	PTC_merchant_type,PTC_terminal_id,PT_retrieval_reference_nr,PT_datetime_req)
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_8] ON [dbo].[settlement_breakdown_details_staging] ( PTC_terminal_id) 
CREATE NONCLUSTERED INDEX [IX_settlement_breakdown_details_staging_9] ON [dbo].[settlement_breakdown_details_staging] ( PTC_merchant_type) 
				 
			 			 				
			 
			 														DELETE FROM [settlement_breakdown_details_staging]
			 														  WHERE index_no IN (SELECT index_no FROM [settlement_breakdown_details_staging] (NOLOCK) where  (source_node_name 
			 														 IN ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src','SWTFBPsrc','SWTUBAsrc'
			 														 ,'SWTZIBsrc','SWTPLATsrc') and PT_post_tran_id IN (select PT_post_tran_id from [settlement_breakdown_details_staging]  (NOLOCK) where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')
			 														)))
			 
			 

			 
			 	 		IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[settlement_breakdown_details_staging_table]') AND type in (N'U'))begin
						DROP TABLE [dbo].settlement_breakdown_details_staging_table
						end										  
			 SELEct   
			Acquirer,PT.bank_code,card_type,Credit_account_type,currency,Debit_account_type,index_no,Issuer,late_reversal,PT_batch_nr,PTc_post_tran_cust_id ptcid,pt.PT_post_tran_id ptid,source_node_name,terminal_type,trxn_amount,trxn_category,trxn_date,trxn_fee,Unique_key,Value_RequestedAmount,Value_SettleAmount,Volume,pt.PT_post_tran_id as post_tran_id_1,pt. PTc_post_tran_cust_id as post_tran_cust_id_1,[PT_settle_entity_id],[PT_prev_post_tran_id],[PT_next_post_tran_id],[PT_sink_node_name],[PT_tran_postilion_originated],[PT_tran_completed],[PT_message_type],[PT_tran_type],[PT_tran_nr],[PT_system_trace_audit_nr],[PT_rsp_code_req],[PT_rsp_code_rsp],[PT_abort_rsp_code],[PT_auth_id_rsp],[PT_auth_type],[PT_auth_reason],[PT_retention_data],[PT_acquiring_inst_id_code],[PT_message_reason_code],[PT_sponsor_bank],[PT_retrieval_reference_nr],[PT_datetime_tran_gmt],[PT_datetime_tran_local],[PT_datetime_req],[PT_datetime_rsp],[PT_realtime_business_date],[PT_recon_business_date],[PT_from_account_type],[PT_to_account_type],[PT_from_account_id],[PT_to_account_id],[PT_tran_amount_req],[PT_tran_amount_rsp],[PT_settle_amount_impact],[PT_tran_cash_req],[PT_tran_cash_rsp],[PT_tran_currency_code],[PT_tran_tran_fee_req],[PT_tran_tran_fee_rsp],[PT_tran_tran_fee_currency_code],[PT_tran_proc_fee_req],[PT_tran_proc_fee_rsp],[PT_tran_proc_fee_currency_code],[PT_settle_amount_req],[PT_settle_amount_rsp],[PT_settle_cash_req],[PT_settle_cash_rsp],[PT_settle_tran_fee_req],[PT_settle_tran_fee_rsp],[PT_settle_proc_fee_req],[PT_settle_proc_fee_rsp],[PT_settle_currency_code],[PT_pos_entry_mode],[PT_pos_condition_code],[PT_additional_rsp_data],[PT_tran_reversed],[PT_prev_tran_approved],[PT_issuer_network_id],[PT_acquirer_network_id],[PT_extended_tran_type],[PT_from_account_type_qualifier],[PT_to_account_type_qualifier],[PT_bank_details],[PT_payee],[PT_card_verification_result],[PT_online_system_id],[PT_participant_id],[PT_opp_participant_id],[PT_receiving_inst_id_code],[PT_routing_type],[PT_pt_pos_operating_environment],[PT_pt_pos_card_input_mode],[PT_pt_pos_cardholder_auth_method],[PT_pt_pos_pin_capture_ability],[PT_pt_pos_terminal_operator],[PT_source_node_key],[PT_proc_online_system_id],[PTC_post_tran_cust_id],[PTC_source_node_name],[PTC_draft_capture],[PTC_pan],[PTC_card_seq_nr],[PTC_expiry_date],[PTC_service_restriction_code],[PTC_terminal_id],[PTC_terminal_owner],[PTC_card_acceptor_id_code],[PTC_mapped_card_acceptor_id_code],[PTC_merchant_type],[PTC_card_acceptor_name_loc],[PTC_address_verification_data],[PTC_address_verification_result],[PTC_check_data],[PTC_totals_group],[PTC_card_product],[PTC_pos_card_data_input_ability],[PTC_pos_cardholder_auth_ability],[PTC_pos_card_capture_ability],[PTC_pos_operating_environment],[PTC_pos_cardholder_present],[PTC_pos_card_present],[PTC_pos_card_data_input_mode],[PTC_pos_cardholder_auth_method],[PTC_pos_cardholder_auth_entity],[PTC_pos_card_data_output_ability],[PTC_pos_terminal_output_ability],[PTC_pos_pin_capture_ability],[PTC_pos_terminal_operator],[PTC_pos_terminal_type],[PTC_pan_search],[PTC_pan_encrypted],[PTC_pan_reference]
			           ,(SELECT top 1 PTSP_Account_Nr  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code AND  PT.PTC_terminal_id = PTSP.terminal_id) PTSP_Account_Nr
			 ,(SELECT  TOP 1 ptsp.PTSP_code FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code  AND  PT.PTC_terminal_id = PTSP.terminal_id)  ptsp_code
			 ,(SELECT  TOP 1 PA.PTSP_code  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code AND  PT.PTC_terminal_id = PTSP.terminal_id )    account_PTSP_Code
			 ,(SELECT  TOP 1  PTSP_Name  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code AND PT.PTC_terminal_id = PTSP.terminal_id) PTSP_Name
			 ,rdm_amt    rdm_amt
			 ,Reward_Code      Reward_Code
			 ,Reward_discount  Reward_discount
			 ,rr_number  rr_number
			 ,sdi_tran_id      sdi_tran_id
			 ,se_id      se_id
			 ,session_id session_id
			  ,(SELECT top 1 Sort_Code  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on PTSP.PTSP_code = PA.PTSP_code AND  PT.PTC_terminal_id = PTSP.terminal_id)   Sort_Code
			 ,spay_session_id  spay_session_id
			 ,spst_session_id  spst_session_id
			 ,stan stan
			 ,tag  tag
			 , (SELECT  TOP 1   ptsp.terminal_id  FROM  tbl_PTSP PTSP(nolock)  join tbl_PTSP_Account PA(nolock) on (PTSP.PTSP_code = PA.PTSP_code)  AND PT.PTC_terminal_id = PTSP.terminal_id)      ptsp_terminal_id
			 ,  y.terminal_id  reward_terminal_id
			 ,mrch.terminal_mode    terminal_mode
			 ,trans_date trans_date
			 ,txn_id     txn_id
			 ,mer.category_code web_category_code
			 ,mer.category_name web_category_name
			 ,mer.fee_type web_fee_type
			 ,mer.merchant_disc web_merchant_disc
			 ,mer.amount_cap web_amount_cap
			 ,mer.fee_cap web_fee_cap
			 ,mer.bearer  web_bearer
			 ,ow.terminal_id owner_terminal_id
			 ,ow.Terminal_code owner_terminal_code
			 ,acc_post_id acc_post_id
			 ,mrch.Account_Name     Account_Name
			 ,mrch.account_nr account_nr
			  ,(SELECT TOP 1 acquirer_inst_id1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id1
			 			 ,(SELECT TOP 1 acquirer_inst_id2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id2
			 			 ,(SELECT TOP 1 acquirer_inst_id3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id3
			 			 ,(SELECT TOP 1 acquirer_inst_id4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id4
			 			 ,(SELECT TOP 1 acquirer_inst_id5 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						      acquirer_inst_id5
			 			 ,(SELECT TOP 1   Acquiring_bank FROM  tbl_merchant_account a (NOLOCK) JOIN tbl_merchant_category_visa s (NOLOCK) ON PT.PTC_merchant_type  = s.category_code AND PT.PTC_card_acceptor_id_code = a.card_acceptor_id_code  ) Acquiring_bank
			 			 
			 ,acquiring_inst_id_code acquiring_inst_id_code
			 ,Addit_charge     Addit_charge
			 ,Addit_party      Addit_party
			 ,adj_id     adj_id
			 ,pt.amount   journal_amount
			 ,y.amount   xls_amount
			 ,Amount_amount_id Amount_amount_id
			  ,(SELECT TOP 1   m.Amount_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type= m.category_code)     merch_cat_amount_cap
			 			 ,(SELECT TOP 1   s.amount_cap FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )    merch_cat_visa_amount_cap
			 			
			 ,R.Amount_Cap     reward_amount_cap
			 ,Amount_config_set_id   Amount_config_set_id
			 ,Amount_config_state    Amount_config_state
			 ,Amount_description     Amount_description
			 ,amount_id  amount_id
			 ,Amount_name      Amount_name
			 ,Amount_se_id     Amount_se_id
			 ,amount_value_id  amount_value_id
			 ,mrch.Authorized_Person      Authorized_Person
			 ,(SELECT TOP 1 BANK_CODE FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						
			 			 	  ACC_BANK_CODE
			 			 ,(SELECT TOP 1 bank_code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       BANK_CODE1
			 			 ,(SELECT TOP 1 BANK_INSTITUTION_NAME FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)				  BANK_INSTITUTION_NAME
			 			 ,(SELECT TOP 1   m.bearer FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_bearer
			 			 ,(SELECT TOP 1   s.bearer FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_bearer
			 			 ,business_date    business_date
			 ,ptc_card_acceptor_id_code  card_acceptor_id_code
			 ,card_acceptor_name_loc card_acceptor_name_loc
			 ,cashier_acct     cashier_acct
			 ,cashier_code     cashier_code
			 ,cashier_ext_trans_code cashier_ext_trans_code
			 ,cashier_name     cashier_name
			  ,(SELECT TOP 1   s.category_code FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )   merch_cat_visa_category_code
			 			 , (SELECT TOP 1   m.Category_Code FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)  merch_cat_category_code
			 			 ,(SELECT TOP 1   s.category_name FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_visa_category_name
			 			 ,(SELECT TOP 1   m.Category_name FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_category_name
			 			 ,(SELECT TOP 1 CBN_Code1 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)						       CBN_Code1
			 			 ,(SELECT TOP 1 CBN_Code2 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)			  CBN_Code2
			 			 ,(SELECT TOP 1 CBN_Code3 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)  CBN_Code3
			 			 ,(SELECT TOP 1 CBN_Code4 FROM aid_cbn_code acc (NOLOCK) WHERE	(PT.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5))	)	  CBN_Code4
			       ,[coa_coa_id]
			       ,[coa_config_set_id]
			 ,coa_config_state coa_config_state
			 ,coa_description  coa_description
			 ,coa_id     coa_id
			 ,coa_name   coa_name
			 ,coa_se_id  coa_se_id
			 ,coa_type   coa_type
			 ,config_set_id    config_set_id
			 ,credit_acc_id    credit_acc_id
			 ,credit_acc_nr_id credit_acc_nr_id
			 ,credit_cardholder_acc_id     credit_cardholder_acc_id
			 ,credit_cardholder_acc_type   credit_cardholder_acc_type
			 ,CreditAccNr_acc_id     CreditAccNr_acc_id
			 ,CreditAccNr_acc_nr     CreditAccNr_acc_nr
			 ,CreditAccNr_acc_nr_id  CreditAccNr_acc_nr_id
			 ,CreditAccNr_aggregation_id   CreditAccNr_aggregation_id
			 ,CreditAccNr_config_set_id    CreditAccNr_config_set_id
			 ,CreditAccNr_config_state     CreditAccNr_config_state
			 ,CreditAccNr_se_id      CreditAccNr_se_id
			 ,CreditAccNr_state      CreditAccNr_state
			 ,mrch.Date_Modified    Date_Modified
			 ,debit_acc_id     debit_acc_id
			 ,debit_acc_nr_id  debit_acc_nr_id
			 ,debit_cardholder_acc_id      debit_cardholder_acc_id
			 ,debit_cardholder_acc_type    debit_cardholder_acc_type
			 ,DebitAccNr_acc_id      DebitAccNr_acc_id
			 ,DebitAccNr_acc_nr      DebitAccNr_acc_nr
			 ,DebitAccNr_acc_nr_id   DebitAccNr_acc_nr_id
			 ,DebitAccNr_aggregation_id    DebitAccNr_aggregation_id
			 ,DebitAccNr_config_set_id     DebitAccNr_config_set_id
			 ,DebitAccNr_config_state      DebitAccNr_config_state
			 ,DebitAccNr_se_id DebitAccNr_se_id
			 ,DebitAccNr_state DebitAccNr_state
			 ,entry_id   entry_id
			 ,extended_trans_type    extended_trans_type
			 ,fee  fee
			 ,Fee_amount_id    Fee_amount_id
			 , (SELECT TOP 1   m.Fee_Cap FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code)   merch_cat_fee_cap
			 			 ,(SELECT TOP 1   s.Fee_Cap  FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_visa_fee_cap
			 ,r.Fee_Cap  reward_fee_cap
			 ,Fee_config_set_id      Fee_config_set_id
			 ,Fee_config_state Fee_config_state
			 ,Fee_description  Fee_description
			 ,Fee_Discount     Fee_Discount
			 ,Fee_fee_id Fee_fee_id
			 ,fee_id     fee_id
			 ,Fee_name   Fee_name
			 ,Fee_se_id  Fee_se_id
			 ,(SELECT TOP 1   m.fee_type FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_fee_type
			 			 ,(SELECT TOP 1   s.fee_type FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code ) merch_cat_category_visa_fee_type
			 			 
			 ,pt.Fee_type journal_fee_type
			 ,fee_value_id     fee_value_id
			 ,granularity_element    granularity_element
			 ,(SELECT TOP 1   m.Merchant_Disc FROM tbl_merchant_category m (NOLOCK) WHERE PT.PTC_merchant_type = m.category_code) merch_cat_category_merch_discount
			 			 ,(SELECT TOP 1   s.Merchant_Disc FROM  tbl_merchant_category_visa s (NOLOCK) WHERE PT.PTC_merchant_type  = s.category_code )  merch_cat_category_visa_merch_discount
			 			 
			 ,merchant_id      merchant_id
			 ,merchant_type    merchant_type
			 ,nt_fee     nt_fee
			 ,nt_fee_acc_post_id     nt_fee_acc_post_id
			 ,nt_fee_id  nt_fee_id
			 ,nt_fee_value_id  nt_fee_value_id
			 ,pan  pan
			 into  settlement_breakdown_details_staging_table
			    FROM      settlement_breakdown_details_staging  pt with (nolock, index(ix_settlement_breakdown_details_staging_7))  
									 LEFT JOIN  tbl_merchant_account mrch WITH (NOLOCK, INDEX (PK_tbl_merchant_account_1))
			 ON 
			 pt.ptc_card_acceptor_id_code = mrch.card_acceptor_id_code
			 
			 left JOIN  tbl_merchant_category m  with (NOLOCK, index(PK_tbl_merchant_category))
			                         ON PT.PTC_merchant_type = m.category_code   
			  
			                         left JOIN  tbl_xls_settlement y with (NOLOCK, index(indx_terminal_id))
			 
			                         ON (PT.PTC_terminal_id= y.terminal_id 
			                                     AND PT.PT_retrieval_reference_nr = y.rr_number 
			                                     AND (-1 * PT.PT_settle_amount_impact)/100 = y.amount
			                                     AND substring (CAST (PT.PT_datetime_req AS VARCHAR(8000)), 1, 10)
			                                     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)
			                                 and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand (NOLOCK)))
			                         left JOIN  Reward_Category r  with (NOLOCK, INDEX(PK_Reward_Category))
			                                 ON y.extended_trans_type = r.reward_code
			                            left JOIN  tbl_merchant_category_web mer  with(NOLOCK, index(PK_tbl_merchant_category_Web))
			                                                 ON PT.PTC_merchant_type = mer.category_code 
			                                              LEFT JOIN tbl_terminal_owner ow ON PT.PTC_terminal_id = ow.terminal_id       
												     
			 			 				OPTION(recompile,optimize for unknown)						
						IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp_journal_data_staging]') AND type in (N'U'))begin
							DROP TABLE [dbo].[temp_journal_data_staging]
						end
						IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp_post_tran_data_staging]') AND type in (N'U'))begin
							DROP TABLE [dbo].[temp_post_tran_data_staging]
						end
						IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[settlement_breakdown_details_staging]') AND type in (N'U'))begin
							DROP TABLE [dbo].[settlement_breakdown_details_staging]
						end
			 		DECLARE @detailsTable VARCHAR(500)
					SET @detailsTable = 'sstl_summary_breakdown_details_'+@currentDate
					
					EXEC ('IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].'+ @detailsTable+''') AND type in (N''U''))begin '+
							' DROP TABLE [dbo].['+ @detailsTable+']'+
						' end');
					exec('EXEC sp_rename ''settlement_breakdown_details_staging_table'','''+@detailsTable+'''');	
					
					IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[settlement_summary_breakdown_details]')) BEGIN
						
						 
						EXEC('ALTER VIEW dbo.settlement_summary_breakdown_details AS SELECT * FROM  ['+@detailsTable+'] (NOLOCK)')
					END
					ELSE  BEGIN
						
						EXEC('CREATE VIEW dbo.settlement_summary_breakdown_details AS SELECT * FROM  ['+@detailsTable+'](NOLOCK)')
						update  sstl_summary_details_session SET STATUS  = 1  WHERE settlement_date = @currentDate;
					END

		END
ELSE 
 PRINT 'No Settlement data in servers'

END
