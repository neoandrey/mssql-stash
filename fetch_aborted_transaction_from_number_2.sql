USE [postilion_office]
GO

/****** Object:  Table [dbo].[aborted_transactions]    Script Date: 11/08/2014 08:35:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO
--IF NOT EXISTS (SELECT 

CREATE TABLE [dbo].[aborted_transactions](
	[serial_number] [bigint] IDENTITY(1,1) NOT NULL,
	[tran_nr] [bigint] NULL,
	[stan_desc] [text] NULL,
	[online_system_id] [int] NULL,
	[status] [varchar](50) NULL,
	[date_of_creation] [datetime] NULL,
 CONSTRAINT [serial_num_cons] PRIMARY KEY CLUSTERED 
(
	[serial_number] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO



GO
  
 ALTER PROCEDURE [dbo].[fetch_aborted_transaction_from_number](@aborted_tran_list VARCHAR(8000), @tran_number_delimiter VARCHAR(5))
 
 AS BEGIN
 
  Create table #transaction_table    
  (    
   tran_number BIGINT not null 
  )
  
  INSERT INTO #transaction_table  SELECT part AS 'tran_number' FROM dbo.usf_split_string(@aborted_tran_list,@tran_number_delimiter);

--select * from post_tran  WHERE tran_nr  IN (SELECT tran_number FROM #transaction_table)

INSERT INTO [postilion_office].[dbo].[aborted_transactions] (tran_nr,stan_desc,online_system_id,[status],date_of_creation)  
 SELECT 
 tran_number,
 null,
 0,
 'NOT TREATED',
 GETDATE()
   FROM #transaction_table

SELECT  'post_tran_cust_id' ,'abort_rsp_code' ,'acquirer_network_id' ,'payee' ,'pos_condition_code' ,'pos_entry_mode' ,'post_tran_id' ,'prev_post_tran_id' ,'prev_tran_approved' ,'pt_pos_card_input_mode' ,'pt_pos_cardholder_auth_method' ,'pt_pos_operating_environment' ,'pt_pos_pin_capture_ability' ,'pt_pos_terminal_operator' ,'realtime_business_date' ,'receiving_inst_id_code' ,'recon_business_date' ,'retention_data' ,'retrieval_reference_nr' ,'routing_type' ,'rsp_code_req' ,'rsp_code_rsp' ,'settle_amount_impact' ,'settle_amount_req' ,'settle_amount_rsp' ,'settle_cash_req' ,'settle_cash_rsp' ,'settle_currency_code' ,'settle_entity_id' ,'settle_proc_fee_req' ,'settle_proc_fee_rsp' ,'settle_tran_fee_req' ,'settle_tran_fee_rsp' ,'sink_node_name' ,'sponsor_bank' ,'structured_data_req' ,'structured_data_rsp' ,'system_trace_audit_nr' ,'to_account_id' ,'to_account_type' ,'to_account_type_qualifier' ,'tran_amount_req' ,'tran_amount_rsp' ,'tran_cash_req' ,'tran_cash_rsp' ,'tran_completed' ,'tran_currency_code' ,'tran_nr' ,'tran_postilion_originated' ,'tran_proc_fee_currency_code' ,'tran_proc_fee_req' ,'tran_proc_fee_rsp' ,'tran_reversed' ,'tran_tran_fee_currency_code' ,'tran_tran_fee_req' ,'tran_tran_fee_rsp' ,'tran_type' ,'ucaf_data' ,'address_verification_data' ,'address_verification_result' ,'card_acceptor_id_code' ,'card_acceptor_name_loc' ,'card_product' ,'card_seq_nr' ,'check_data' ,'draft_capture' ,'expiry_date' ,'mapped_card_acceptor_id_code' ,'merchant_type' ,'pan' ,'pan_encrypted' ,'pan_reference' ,'pan_search' ,'pos_card_capture_ability' ,'pos_card_data_input_ability' ,'pos_card_data_input_mode' ,'pos_card_data_output_ability' ,'pos_card_present' ,'pos_cardholder_auth_ability' ,'pos_cardholder_auth_entity' ,'pos_cardholder_auth_method' ,'pos_cardholder_present' ,'pos_operating_environment' ,'pos_pin_capture_ability' ,'pos_terminal_operator' ,'pos_terminal_output_ability' ,'pos_terminal_type' ,'service_restriction_code' ,'source_node_name' ,'terminal_id' ,'terminal_owner' ,'totals_group' ,'acquiring_inst_id_code' ,'additional_rsp_data' ,'auth_id_rsp' ,'auth_reason' ,'auth_type' ,'bank_details' ,'batch_nr' ,'card_verification_result' ,'datetime_req' ,'datetime_rsp' ,'datetime_tran_gmt' ,'datetime_tran_local' ,'extended_tran_type' ,'from_account_id' ,'from_account_type' ,'from_account_type_qualifier' ,'icc_data_req' ,'icc_data_rsp' ,'issuer_network_id' ,'message_reason_code' ,'message_type' ,'next_post_tran_id' ,'online_system_id' ,'participant_id'

SELECT  trans.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id 
--INTO #transient_table
FROM post_tran trans (NOLOCK) LEFT JOIN post_tran_cust cust (NOLOCK) ON trans.post_tran_cust_id = cust.post_tran_cust_id

WHERE  trans.tran_nr  IN (SELECT tran_number FROM #transaction_table) 
AND rsp_code_req <>'96'  
--AND system_trace_audit_nr= '999999'

--SELECT * FROM #transient_table

UPDATE [postilion_office].[dbo].[aborted_transactions] 
SET 
         [status] ='TREATED', 
         date_of_creation =GETDATE(),
         online_system_id = trans.online_system_id, 
         stan_desc = 
         CASE trans.system_trace_audit_nr 
			 WHEN '999999' THEN '999999' 
			 WHEN '0420'   THEN 'REVERSAL_ADVICE'
			 WHEN '0220'  THEN 'COMPLETION_ADVICE'
			 ELSE trans.system_trace_audit_nr
		 END  
FROM    [postilion_office].[dbo].[aborted_transactions] abrt, (SELECT  trans.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id 
--INTO #transient_table
FROM post_tran trans (NOLOCK) LEFT JOIN post_tran_cust cust (NOLOCK) ON trans.post_tran_cust_id = cust.post_tran_cust_id

WHERE  trans.tran_nr  IN (SELECT tran_number FROM #transaction_table) 
AND rsp_code_req <>'96'  ) trans      
WHERE abrt.tran_nr = trans.tran_nr 



DROP TABLE #transaction_table

--DROP TABLE #transient_table
END


--SELECT * FROM [postilion_office].[dbo].[aborted_transactions] 
