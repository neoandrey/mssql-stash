USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[populate_daily_reporting_table]    Script Date: 12/15/2015 15:53:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[populate_daily_reporting_table] 		 @report_date_start DATETIME , @report_date_end DATETIME, @override  INT AS

BEGIN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

			--CHECK SESSION TABLE
			DECLARE @index_no BIGINT
			DECLARE @report_date DATETIME
			DECLARE @finished INT
			DECLARE @start_time DATETIME
			DECLARE @end_time DATETIME
			DECLARE @tran_count BIGINT
			DECLARE @first_post_tran_id BIGINT
			DECLARE @last_post_tran_id BIGINT
			DECLARE @first_post_tran_cust_id BIGINT  
			DECLARE @last_post_tran_cust_id BIGINT 

			SET @report_date_start = ISNULL(@report_date_start,REPLACE(CONVERT(VARCHAR(10), DATEADD(D, -1,GETDATE()),111),'/', ''));
			
			SET @report_date_start = ISNULL(@report_date_start,REPLACE(CONVERT(VARCHAR(10), DATEADD(D, 0,GETDATE()),111),'/', ''))
			
			SET @report_date=  @report_date_start 
			SET @override =ISNULL (@override,0);
			SELECT @finished =  finished,@index_no=index_no FROM post_tran_report_data_session (nolock) WHERE report_date = @report_date_start;
			SELECT @finished =  ISNULL(@finished,0),@index_no=ISNULL(@index_no,0)
			IF(@finished <> 1 OR @override=1) BEGIN
				SELECT @start_time=GETDATE(), @tran_count=0,@finished=0; 	
				--DELETE ALL RECORDS
				PRINT 'Deleting old records from post_tran_report_data';

				--SET ROWCOUNT 0
				DELETE FROM post_tran_report_data WHERE datetime_req <=  DATEADD(minute, -30, REPLACE(CONVERT(VARCHAR(10), DATEADD(D, 0,GETDATE()),111),'/', ''))
				--REBUILD ALL INDEXES
				PRINT 'Rebuilding indexes on post_tran_report_data';
				ALTER INDEX ALL ON post_tran_report_data REBUILD

					--INSERT DATA
				PRINT 'Inserting data into post_tran_report_data';

				EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT

				SET @start_time = GETDATE();
		INSERT INTO [postilion_office].[dbo].[post_tran_report_data]
		([post_tran_id]      ,[post_tran_cust_id]      ,[settle_entity_id]      ,[batch_nr]      ,[prev_post_tran_id]      ,[next_post_tran_id]      ,[sink_node_name]      ,[tran_postilion_originated]      ,[tran_completed]      ,[message_type]      ,[tran_type]      ,[tran_nr]      ,[system_trace_audit_nr]      ,[rsp_code_req]      ,[rsp_code_rsp]      ,[abort_rsp_code]      ,[auth_id_rsp]      ,[auth_type]      ,[auth_reason]      ,[retention_data]      ,[acquiring_inst_id_code]      ,[message_reason_code]      ,[sponsor_bank]      ,[retrieval_reference_nr]      ,[datetime_tran_gmt]      ,[datetime_tran_local]      ,[datetime_req]      ,[datetime_rsp]      ,[realtime_business_date]      ,[recon_business_date]      ,[from_account_type]      ,[to_account_type]      ,[from_account_id]      ,[to_account_id]      ,[tran_amount_req]      ,[tran_amount_rsp]      ,[settle_amount_impact]      ,[tran_cash_req]      ,[tran_cash_rsp]      ,[tran_currency_code]      ,[tran_tran_fee_req]      ,[tran_tran_fee_rsp]      ,[tran_tran_fee_currency_code]      ,[tran_proc_fee_req]      ,[tran_proc_fee_rsp]      ,[tran_proc_fee_currency_code]      ,[settle_amount_req]      ,[settle_amount_rsp]      ,[settle_cash_req]      ,[settle_cash_rsp]      ,[settle_tran_fee_req]      ,[settle_tran_fee_rsp]      ,[settle_proc_fee_req]      ,[settle_proc_fee_rsp]      ,[settle_currency_code]      ,[pos_entry_mode]      ,[pos_condition_code]      ,[additional_rsp_data]      ,[structured_data_req]      ,[tran_reversed]      ,[prev_tran_approved]      ,[issuer_network_id]      ,[acquirer_network_id]      ,[extended_tran_type]      ,[ucaf_data]      ,[from_account_type_qualifier]      ,[to_account_type_qualifier]      ,[bank_details]      ,[payee]      ,[card_verification_result]      ,[online_system_id]      ,[participant_id]      ,[receiving_inst_id_code]      ,[routing_type]      ,[pt_pos_operating_environment]      ,[pt_pos_card_input_mode]      ,[pt_pos_cardholder_auth_method]      ,[pt_pos_pin_capture_ability]      ,[pt_pos_terminal_operator]      ,[source_node_name]      ,[draft_capture]      ,[pan]      ,[card_seq_nr]      ,[expiry_date]      ,[service_restriction_code]      ,[terminal_id]      ,[terminal_owner]      ,[card_acceptor_id_code]      ,[mapped_card_acceptor_id_code]      ,[merchant_type]      ,[card_acceptor_name_loc]      ,[address_verification_data]      ,[address_verification_result]      ,[check_data]      ,[totals_group]      ,[card_product]      ,[pos_card_data_input_ability]      ,[pos_cardholder_auth_ability]      ,[pos_card_capture_ability]      ,[pos_operating_environment]      ,[pos_cardholder_present]      ,[pos_card_present]      ,[pos_card_data_input_mode]      ,[pos_cardholder_auth_method]      ,[pos_cardholder_auth_entity]      ,[pos_card_data_output_ability]      ,[pos_terminal_output_ability]      ,[pos_pin_capture_ability]      ,[pos_terminal_operator]      ,[pos_terminal_type]      ,[pan_search]      ,[pan_encrypted]      ,[pan_reference])		
		SELECT [post_tran_id]      ,trans.[post_tran_cust_id]      ,[settle_entity_id]      ,[batch_nr]      ,[prev_post_tran_id]      ,[next_post_tran_id]      ,[sink_node_name]      ,[tran_postilion_originated]      ,[tran_completed]      ,[message_type]      ,[tran_type]      ,[tran_nr]      ,[system_trace_audit_nr]      ,[rsp_code_req]      ,[rsp_code_rsp]      ,[abort_rsp_code]      ,[auth_id_rsp]      ,[auth_type]      ,[auth_reason]      ,[retention_data]      ,[acquiring_inst_id_code]      ,[message_reason_code]      ,[sponsor_bank]      ,[retrieval_reference_nr]      ,[datetime_tran_gmt]      ,[datetime_tran_local]      ,[datetime_req]      ,[datetime_rsp]      ,[realtime_business_date]      ,[recon_business_date]      ,[from_account_type]      ,[to_account_type]      ,[from_account_id]      ,[to_account_id]      ,[tran_amount_req]      ,[tran_amount_rsp]      ,[settle_amount_impact]      ,[tran_cash_req]      ,[tran_cash_rsp]      ,[tran_currency_code]      ,[tran_tran_fee_req]      ,[tran_tran_fee_rsp]      ,[tran_tran_fee_currency_code]      ,[tran_proc_fee_req]      ,[tran_proc_fee_rsp]      ,[tran_proc_fee_currency_code]      ,[settle_amount_req]      ,[settle_amount_rsp]      ,[settle_cash_req]      ,[settle_cash_rsp]      ,[settle_tran_fee_req]      ,[settle_tran_fee_rsp]      ,[settle_proc_fee_req]      ,[settle_proc_fee_rsp]      ,[settle_currency_code]      ,[pos_entry_mode]      ,[pos_condition_code]      ,[additional_rsp_data]      ,[structured_data_req]      ,[tran_reversed]      ,[prev_tran_approved]      ,[issuer_network_id]      ,[acquirer_network_id]      ,[extended_tran_type]      ,[ucaf_data]      ,[from_account_type_qualifier]      ,[to_account_type_qualifier]      ,[bank_details]      ,[payee]      ,[card_verification_result]      ,[online_system_id]      ,[participant_id]      ,[receiving_inst_id_code]      ,[routing_type]      ,[pt_pos_operating_environment]      ,[pt_pos_card_input_mode]      ,[pt_pos_cardholder_auth_method]      ,[pt_pos_pin_capture_ability]      ,[pt_pos_terminal_operator]      ,[source_node_name]      ,[draft_capture]      ,[pan]      ,[card_seq_nr]      ,[expiry_date]      ,[service_restriction_code]      ,[terminal_id]      ,[terminal_owner]      ,[card_acceptor_id_code]      ,[mapped_card_acceptor_id_code]      ,[merchant_type]      ,[card_acceptor_name_loc]      ,[address_verification_data]      ,[address_verification_result]      ,[check_data]      ,[totals_group]      ,[card_product]      ,[pos_card_data_input_ability]      ,[pos_cardholder_auth_ability]      ,[pos_card_capture_ability]      ,[pos_operating_environment]      ,[pos_cardholder_present]      ,[pos_card_present]      ,[pos_card_data_input_mode]      ,[pos_cardholder_auth_method]      ,[pos_cardholder_auth_entity]      ,[pos_card_data_output_ability]      ,[pos_terminal_output_ability]      ,[pos_pin_capture_ability]      ,[pos_terminal_operator]      ,[pos_terminal_type]      ,[pan_search]      ,[pan_encrypted]      ,[pan_reference] 
		FROM post_tran trans(NOLOCK, INDEX(ix_post_tran_7))
		  JOIN post_tran_cust cst (NOLOCK) ON
		  trans.post_tran_cust_id = cst.post_tran_cust_id
		  WHERE 
		  datetime_req>= @report_date_start  AND post_tran_id >=@first_post_tran_id
		  and datetime_req < @report_date_end      and    post_tran_id <=@last_post_tran_id
		  OPTION (MAXDOP 16)
		  SET @tran_count = @tran_count+ @@ROWCOUNT
		
	
		IF (@@ERROR<>0) BEGIN
		  RAISERROR ('A  error occurred during dta insertion', 16,  1 ); 
		  return
		END
	
					IF(@index_no=0  ) BEGIN
						INSERT INTO post_tran_report_data_session (report_date,start_date, tran_count, finished) VALUES(@report_date,@start_time,@tran_count, 1 );
					END 
					ELSE BEGIN
						UPDATE post_tran_report_data_session SET start_date=@report_date_start,tran_count =@tran_count, finished = 1 WHERE index_no= @index_no;
					END
		
		end
		ELSE BEGIN
		PRINT 'Transactions have already been copied for '+CONVERT(VARCHAR(30),@report_date_start)+'. No action performed.';
		END
		END
		
			

END
