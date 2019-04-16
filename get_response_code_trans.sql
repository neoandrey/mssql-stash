

CREATE PROCEDURE [dbo].[get_response_code_trans] ( @SinkNode VARCHAR(40), @SourceNode VARCHAR(40), @StartDate DATETIME,  @EndDate DATETIME, @response_code VARCHAR(50))

AS 

BEGIN


DECLARE @response_code_index INT;

SET @StartDate =ISNULL( @StartDate,DATEADD(D,-1, DATEDIFF(D,0, GETDATE()))); 
SET @StartDate =  DATEADD(D,0, DATEDIFF(D,0, @StartDate))
SET @EndDate = ISNULL(@EndDate, getdate());
SET @EndDate =  DATEADD(D,0, DATEDIFF(D,0, @EndDate));
SET @SinkNode    = isnull(@SinkNode, '%%');
SET @SourceNode    = isnull(@SourceNode, '%%');
SELECT @StartDate  AS 'START_DATE',  @EndDate  AS 'END_DATE',DATEDIFF(DD, @StartDate,@EndDate) AS 'NUMBER_OF_DAYS'
SELECT @response_code  =ISNULL(@response_code, 'XX');

SELECT @response_code_index = CHARINDEX (@response_code, '41,42,43,51,52,53,54,62,63,94,96,05,07,15,30,91,93,04,06,57,92,00,01,12,14,59');

IF (@response_code_index >0) BEGIN

 SELECT  trans.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,
 batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id 
	 FROM post_tran trans (NOLOCK) LEFT JOIN post_tran_cust cust (NOLOCK) ON trans.post_tran_cust_id = cust.post_tran_cust_id
WHERE
  source_node_name LIKE @SourceNode
  AND 
  sink_node_name LIKE @SinkNode
  AND 
  datetime_req >= @StartDate
 AND 
 datetime_req <@EndDate
 AND
 rsp_code_rsp =@response_code;
 


END
ELSE BEGIN


SELECT 'Invalid Response Code provided'



END



END
