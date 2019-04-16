
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @report_date_start DATETIME

	DECLARE @report_date_end   DATETIME
	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT
	
	SELECT  @first_post_tran_cust_id = MAX(post_tran_cust_id) from [172.25.15.99].[postilion_office].dbo.[post_tran] (nolock) 
	SELECT  @report_date_start =datetime_req FROM [172.25.15.99].[postilion_office].dbo.[post_tran] (nolock)  WHERE post_tran_id =@first_post_tran_cust_id 
	SELECT  @report_date_end=  DATEADD(HOUR, 12, @report_date_start)
	
	
	IF(@report_date_start<> @report_date_end) BEGIN
	
		SET  @last_post_tran_cust_id  = (SELECT TOP 1 post_tran_cust_id FROM post_tran WITH (NOLOCK, INDEX(ix_post_tran_7)) WHERE   datetime_req < @report_date_end ORDER BY datetime_req DESC)

	END



SELECT  [post_tran_cust_id], [source_node_name], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [totals_group], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference]  FROM [postilion_office].[dbo].[post_tran_cust]  (NOLOCK, INDEX(ix_post_tran_cust_2)) 

WHERE  post_tran_cust_id >@first_post_tran_cust_id AND post_tran_cust_id <=@last_post_tran_cust_id ORDER BY post_tran_cust_id ASC
