	
	
	DECLARE @startDate DATETIME;
	DECLARE @endDate DATETIME;
	
	SET @startDate ='2013-12-01';
	
	SET @endDate =  '2013-12-31'
	
	SELECT  post_tran_id,post_tran_cust_id,settle_entity_id,batch_nr,prev_post_tran_id,next_post_tran_id,sink_node_name,tran_postilion_originated,tran_completed,message_type,tran_type,tran_nr,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,abort_rsp_code,auth_id_rsp,auth_type,auth_reason,retention_data,acquiring_inst_id_code,message_reason_code,sponsor_bank,retrieval_reference_nr,datetime_tran_gmt,datetime_tran_local,datetime_req,datetime_rsp,realtime_business_date,recon_business_date,from_account_type,to_account_type,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,settle_amount_impact,tran_cash_req,tran_cash_rsp,tran_currency_code,tran_tran_fee_req,tran_tran_fee_rsp,tran_tran_fee_currency_code,tran_proc_fee_req,tran_proc_fee_rsp,tran_proc_fee_currency_code,settle_amount_req,settle_amount_rsp,settle_cash_req,settle_cash_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_proc_fee_req,settle_proc_fee_rsp,settle_currency_code,icc_data_req,icc_data_rsp,pos_entry_mode,pos_condition_code,additional_rsp_data,structured_data_req,structured_data_rsp,tran_reversed,prev_tran_approved,issuer_network_id,acquirer_network_id,extended_tran_type,ucaf_data,from_account_type_qualifier,to_account_type_qualifier,bank_details,payee,card_verification_result,online_system_id,participant_id,receiving_inst_id_code,routing_type,pt_pos_operating_environment,pt_pos_card_input_mode,pt_pos_cardholder_auth_method,pt_pos_pin_capture_ability,pt_pos_terminal_operator INTO #TEMP_POST_TRAN FROM post_tran (NOLOCK) WHERE datetime_req BETWEEN @startDate AND @endDate;
	
	SELECT post_tran_cust_id,source_node_name,draft_capture,pan,card_seq_nr,expiry_date,service_restriction_code,terminal_id,terminal_owner,card_acceptor_id_code,mapped_card_acceptor_id_code,merchant_type,card_acceptor_name_loc,address_verification_data,address_verification_result,check_data,totals_group,card_product,pos_card_data_input_ability,pos_cardholder_auth_ability,pos_card_capture_ability,pos_operating_environment,pos_cardholder_present,pos_card_present,pos_card_data_input_mode,pos_cardholder_auth_method,pos_cardholder_auth_entity,pos_card_data_output_ability,pos_terminal_output_ability,pos_pin_capture_ability,pos_terminal_operator,pos_terminal_type,pan_search,pan_encrypted,pan_reference INTO #TEMP_POST_TRAN_CUST FROM post_tran_cust (NOLOCK) WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM #TEMP_POST_TRAN );
	
	SELECT  'post_tran_cust_id' ,'abort_rsp_code' ,'acquirer_network_id' ,'payee' ,'pos_condition_code' ,'pos_entry_mode' ,'post_tran_id' ,'prev_post_tran_id' ,'prev_tran_approved' ,'pt_pos_card_input_mode' ,'pt_pos_cardholder_auth_method' ,'pt_pos_operating_environment' ,'pt_pos_pin_capture_ability' ,'pt_pos_terminal_operator' ,'realtime_business_date' ,'receiving_inst_id_code' ,'recon_business_date' ,'retention_data' ,'retrieval_reference_nr' ,'routing_type' ,'rsp_code_req' ,'rsp_code_rsp' ,'settle_amount_impact' ,'settle_amount_req' ,'settle_amount_rsp' ,'settle_cash_req' ,'settle_cash_rsp' ,'settle_currency_code' ,'settle_entity_id' ,'settle_proc_fee_req' ,'settle_proc_fee_rsp' ,'settle_tran_fee_req' ,'settle_tran_fee_rsp' ,'sink_node_name' ,'sponsor_bank' ,'structured_data_req' ,'structured_data_rsp' ,'system_trace_audit_nr' ,'to_account_id' ,'to_account_type' ,'to_account_type_qualifier' ,'tran_amount_req' ,'tran_amount_rsp' ,'tran_cash_req' ,'tran_cash_rsp' ,'tran_completed' ,'tran_currency_code' ,'tran_nr' ,'tran_postilion_originated' ,'tran_proc_fee_currency_code' ,'tran_proc_fee_req' ,'tran_proc_fee_rsp' ,'tran_reversed' ,'tran_tran_fee_currency_code' ,'tran_tran_fee_req' ,'tran_tran_fee_rsp' ,'tran_type' ,'ucaf_data' ,'address_verification_data' ,'address_verification_result' ,'card_acceptor_id_code' ,'card_acceptor_name_loc' ,'card_product' ,'card_seq_nr' ,'check_data' ,'draft_capture' ,'expiry_date' ,'mapped_card_acceptor_id_code' ,'merchant_type' ,'pan' ,'pan_encrypted' ,'pan_reference' ,'pan_search' ,'pos_card_capture_ability' ,'pos_card_data_input_ability' ,'pos_card_data_input_mode' ,'pos_card_data_output_ability' ,'pos_card_present' ,'pos_cardholder_auth_ability' ,'pos_cardholder_auth_entity' ,'pos_cardholder_auth_method' ,'pos_cardholder_present' ,'pos_operating_environment' ,'pos_pin_capture_ability' ,'pos_terminal_operator' ,'pos_terminal_output_ability' ,'pos_terminal_type' ,'service_restriction_code' ,'source_node_name' ,'terminal_id' ,'terminal_owner' ,'totals_group' ,'acquiring_inst_id_code' ,'additional_rsp_data' ,'auth_id_rsp' ,'auth_reason' ,'auth_type' ,'bank_details' ,'batch_nr' ,'card_verification_result' ,'datetime_req' ,'datetime_rsp' ,'datetime_tran_gmt' ,'datetime_tran_local' ,'extended_tran_type' ,'from_account_id' ,'from_account_type' ,'from_account_type_qualifier' ,'icc_data_req' ,'icc_data_rsp' ,'issuer_network_id' ,'message_reason_code' ,'message_type' ,'next_post_tran_id' ,'online_system_id' ,'participant_id'
	
	 INSERT INTO data_inventory.dbo.transaction_table (post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id )SELECT  trans.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id FROM #TEMP_POST_TRAN trans (NOLOCK) LEFT JOIN #TEMP_POST_TRAN_CUST cust (NOLOCK) ON trans.post_tran_cust_id = cust.post_tran_cust_id

	USE [data_inventory]
	GO
	/****** Object:  Table [dbo].[transaction_table]    Script Date: 01/24/2014 09:42:37 ******/
	SET ANSI_NULLS ON
	GO
	SET QUOTED_IDENTIFIER ON
	GO
	SET ANSI_PADDING ON
	GO
	CREATE TABLE [dbo].[transaction_table](
		[post_tran_id] [bigint] NOT NULL,
		[post_tran_cust_id] [bigint] NOT NULL,
		[settle_entity_id] VARCHAR(1000) NULL,
		[batch_nr] [int] NULL,
		[prev_post_tran_id] [bigint] NULL,
		[next_post_tran_id] [bigint] NULL DEFAULT (0),
		[sink_node_name] VARCHAR(1000) NULL,
		[tran_postilion_originated] BIGINT NOT NULL,
		[tran_completed] BIGINT NOT NULL,
		[message_type] [char](4) NOT NULL,
		[tran_type] [char](2) NULL,
		[tran_nr] [bigint] NOT NULL,
		[system_trace_audit_nr] [char](6) NULL,
		[rsp_code_req] [char](2) NULL,
		[rsp_code_rsp] [char](2) NULL,
		[abort_rsp_code] [char](2) NULL,
		[auth_id_rsp] [varchar](10) NULL,
		[auth_type] [numeric](1, 0) NULL,
		[auth_reason] [numeric](1, 0) NULL,
		[retention_data] [varchar](999) NULL,
		[acquiring_inst_id_code] [varchar](11) NULL,
		[message_reason_code] [char](4) NULL,
		[sponsor_bank] [char](8) NULL,
		[retrieval_reference_nr] [char](12) NULL,
		[datetime_tran_gmt] [datetime] NULL,
		[datetime_tran_local] [datetime] NOT NULL,
		[datetime_req] [datetime] NOT NULL,
		[datetime_rsp] [datetime] NULL,
		[realtime_business_date] [datetime] NOT NULL,
		[recon_business_date] [datetime] NOT NULL,
		[from_account_type] [char](2) NULL,
		[to_account_type] [char](2) NULL,
		[from_account_id] [varchar](28) NULL,
		[to_account_id] [varchar](28) NULL,
		[tran_amount_req] DECIMAL(25,2) NULL,
		[tran_amount_rsp] DECIMAL(25,2) NULL,
		[settle_amount_impact] DECIMAL(25,2) NULL,
		[tran_cash_req] DECIMAL(25,2) NULL,
		[tran_cash_rsp] DECIMAL(25,2) NULL,
		[tran_currency_code] VARCHAR(80) NULL,
		[tran_tran_fee_req] DECIMAL(25,2) NULL,
		[tran_tran_fee_rsp] DECIMAL(25,2) NULL,
		[tran_tran_fee_currency_code] VARCHAR(80) NULL,
		[tran_proc_fee_req] DECIMAL(25,2) NULL,
		[tran_proc_fee_rsp] DECIMAL(25,2) NULL,
		[tran_proc_fee_currency_code] VARCHAR(80) NULL,
		[settle_amount_req] DECIMAL(25,2) NULL,
		[settle_amount_rsp] DECIMAL(25,2) NULL,
		[settle_cash_req] DECIMAL(25,2) NULL,
		[settle_cash_rsp] DECIMAL(25,2) NULL,
		[settle_tran_fee_req] DECIMAL(25,2) NULL,
		[settle_tran_fee_rsp] DECIMAL(25,2) NULL,
		[settle_proc_fee_req] DECIMAL(25,2) NULL,
		[settle_proc_fee_rsp] DECIMAL(25,2) NULL,
		[settle_currency_code] VARCHAR(80) NULL,
		[icc_data_req] [text] NULL,
		[icc_data_rsp] [text] NULL,
		[pos_entry_mode] [char](3) NULL,
		[pos_condition_code] [char](2) NULL,
		[additional_rsp_data] [varchar](25) NULL,
		[structured_data_req] [text] NULL,
		[structured_data_rsp] [text] NULL,
		[tran_reversed] [char](1) NULL DEFAULT (0),
		[prev_tran_approved] BIGINT NULL,
		[issuer_network_id] [varchar](11) NULL,
		[acquirer_network_id] [varchar](11) NULL,
		[extended_tran_type] [char](4) NULL,
		[ucaf_data] [varchar](33) NULL,
		[from_account_type_qualifier] [char](1) NULL,
		[to_account_type_qualifier] [char](1) NULL,
		[bank_details] [varchar](31) NULL,
		[payee] [char](25) NULL,
		[card_verification_result] [char](1) NULL,
		[online_system_id] [int] NULL,
		[participant_id] [int] NULL,
		[receiving_inst_id_code] [varchar](11) NULL,
		[routing_type] [int] NULL,
		[pt_pos_operating_environment] [char](1) NULL,
		[pt_pos_card_input_mode] [char](1) NULL,
		[pt_pos_cardholder_auth_method] [char](1) NULL,
		[pt_pos_pin_capture_ability] [char](1) NULL,
	[pt_pos_terminal_operator] [char](1) NULL,
	[source_node_name] VARCHAR(1000) NOT NULL,
	[draft_capture] VARCHAR(1000) NULL DEFAULT (0),
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[service_restriction_code] [char](3) NULL,
	[terminal_id] VARCHAR(255) NULL,
	[terminal_owner] [varchar](25) NULL,
	[card_acceptor_id_code] [char](15) NULL,
	[mapped_card_acceptor_id_code] [char](15) NULL,
	[merchant_type] [char](4) NULL,
	[card_acceptor_name_loc] [char](40) NULL,
	[address_verification_data] [varchar](29) NULL,
	[address_verification_result] [char](1) NULL,
	[check_data] [varchar](50) NULL,
	[totals_group] [varchar](12) NULL,
	[card_product] [varchar](20) NULL,
	[pos_card_data_input_ability] [char](1) NULL,
	[pos_cardholder_auth_ability] [char](1) NULL,
	[pos_card_capture_ability] [char](1) NULL,
	[pos_operating_environment] [char](1) NULL,
	[pos_cardholder_present] [char](1) NULL,
	[pos_card_present] [char](1) NULL,
	[pos_card_data_input_mode] [char](1) NULL,
	[pos_cardholder_auth_method] [char](1) NULL,
	[pos_cardholder_auth_entity] [char](1) NULL,
	[pos_card_data_output_ability] [char](1) NULL,
	[pos_terminal_output_ability] [char](1) NULL,
	[pos_pin_capture_ability] [char](1) NULL,
	[pos_terminal_operator] [char](1) NULL,
	[pos_terminal_type] [char](2) NULL,
	[pan_search] [int] NULL,
	[pan_encrypted] [char](18) NULL,
	[pan_reference] VARCHAR(1000) NULL
	
	)

--ALTER TABLE transaction_table ADD  pan_reference VARCHAR(1000) NULL;

SELECT * FROM transaction_table (NOLOCK)