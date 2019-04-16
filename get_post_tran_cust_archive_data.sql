
CREATE procedure get_post_tran_cust_archive_data  as 

BEGIN

DECLARE @fist_post_tran_cust_id  BIGINT
DECLARE @batch_size  BIGINT

SELECT @fist_post_tran_cust_id   = max_post_tran_cust_id,@batch_size  =batch_size  FROM  post_tran_archive_info
DECLARE @sql VARCHAR(4000);



DECLARE  @temp_post_tran_cust_data  TABLE(
	[post_tran_cust_id] [bigint] NOT NULL,
	[source_node_name] [dbo].[POST_NAME] NOT NULL,
	[draft_capture] [dbo].[POST_ID] NULL,
	[pan] [varchar](19) NULL,
	[card_seq_nr] [varchar](3) NULL,
	[expiry_date] [char](4) NULL,
	[service_restriction_code] [char](3) NULL,
	[terminal_id] [dbo].[POST_TERMINAL_ID] NULL,
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
	[pan_reference] [char](42) NULL
)



SET @sql= 'SELECT top  '+CONVERT(VARCHAR(100),@batch_size)+'[post_tran_cust_id], [source_node_name], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [totals_group], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference]  FROM [post_tran_cust]  (NOLOCK) WHERE  post_tran_cust_id >'+CONVERT(VARCHAR(100),@fist_post_tran_cust_id )+' ORDER BY post_tran_cust_id asc '
insert into @temp_post_tran_cust_data([post_tran_cust_id], [source_node_name], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [totals_group], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference] ) Exec(@sql);

SELECT [post_tran_cust_id], [source_node_name], [draft_capture], [pan], [card_seq_nr], [expiry_date], [service_restriction_code], [terminal_id], [terminal_owner], [card_acceptor_id_code], [mapped_card_acceptor_id_code], [merchant_type], [card_acceptor_name_loc], [address_verification_data], [address_verification_result], [check_data], [totals_group], [card_product], [pos_card_data_input_ability], [pos_cardholder_auth_ability], [pos_card_capture_ability], [pos_operating_environment], [pos_cardholder_present], [pos_card_present], [pos_card_data_input_mode], [pos_cardholder_auth_method], [pos_cardholder_auth_entity], [pos_card_data_output_ability], [pos_terminal_output_ability], [pos_pin_capture_ability], [pos_terminal_operator], [pos_terminal_type], [pan_search], [pan_encrypted], [pan_reference] FROM @temp_post_tran_cust_data

END