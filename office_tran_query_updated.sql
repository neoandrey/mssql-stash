


	DECLARE @report_date_start DATETIME
	DECLARE @report_date_end   DATETIME
	
	SET @report_date_start = '2016-02-11'
	SET @report_date_end= '2016-02-11 12:00:00'

	DECLARE @first_post_tran_cust_id BIGINT
	DECLARE @last_post_tran_cust_id BIGINT
	DECLARE @first_post_tran_id BIGINT
	DECLARE @last_post_tran_id BIGINT

		DECLARE @first_post_tran_cust_id BIGINT
		DECLARE @last_post_tran_cust_id BIGINT
		DECLARE @first_post_tran_id BIGINT
		DECLARE @last_post_tran_id BIGINT
		DECLARE @SinkNode  VARCHAR(MAX)
		DECLARE @SourceNodes  VARCHAR(MAX)
		DECLARE @terminal_IDs  VARCHAR(MAX)
		
	CREATE TABLE #list_of_source_nodes (source_node	VARCHAR(30)) 
	INSERT INTO  #list_of_source_nodes EXEC osp_rpt_util_split_nodenames @SourceNodes
			
	CREATE TABLE #list_of_terminal_IDs (terminal_ID	VARCHAR(30)) 

	INSERT INTO  #list_of_terminal_IDs EXEC osp_rpt_util_split_nodenames @terminal_IDs

	CREATE TABLE #list_of_BINs (BIN	VARCHAR(30)) 
	INSERT INTO  #list_of_BINs EXEC osp_rpt_util_split_nodenames @BINs

        CREATE TABLE #list_of_sink_nodes (SinkNode	VARCHAR(30)) 
	INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode

	EXEC usp_rpt_get_post_tran_id_range @report_date_start, @report_date_end, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT;
	select  @first_post_tran_cust_id = MIN (post_tran_cust_id),@last_post_tran_cust_id = max (post_tran_cust_id) FROM post_tran (nolock)


SELECT   t.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id 
FROM 
POST_TRAN t (NOLOCK) LEFT JOIN POST_TRAN_CUST c (NOLOCK) 
ON 
t.post_tran_cust_id = cust.post_tran_cust_id
WHERE
retrieval_reference_nr ='000021526660'
and system_trace_audit_nr ='009938'
AND 

	(t..post_tran_cust_id >= @first_post_tran_cust_id) 
	AND 
	(t..post_tran_cust_id <= @last_post_tran_cust_id) 
	AND
	(t..post_tran_id >= @first_post_tran_id) 
	AND 
	(t..post_tran_id <= @last_post_tran_id)
 --	and LEFT(pan,1) ='4'
and
	
	((
			tran_type = '50'
			and message_type in ('0200','0420')
             and source_node_name <>'VTUsrc'
			AND
			sink_node_name NOT IN (SELECT part FROM dbo.usf_split_string('CCLOADsnk,GPRsnk',','))
			AND
			source_node_name NOT IN (SELECT part FROM dbo.usf_split_string('CCLOADsrc,ASPSPNTFsrc,ASPSPONUSsrc',','))
			
			AND
           		(
            (terminal_id IN ( SELECT part FROM dbo.usf_split_string('3EPY0701,3UIB0001,3IPD0010,3IPDTROT, 3VRV0001, 3IGW0010, 3SFX0014', ',')
				or
 			LEFT(terminal_id, 4)  IN  (SELECT part FROM dbo.usf_split_string('3IGW, 3CCW,3IBH, 3CPD,3011,3SFA', ',') )OR   LEFT(terminal_id, 5)   = '3ADPS'
			)
                        OR 
		        (terminal_id = '3BOL0001' and extended_tran_type = '8502')

			)
			)OR
			 (left(terminal_id,4)= '3CPD' and t.tran_type = '00')
			OR
			(LEFT (terminal_id,7)= '3IPDFDT' OR LEFT (terminal_id,7)= '3QTL002') 
            
			
			)
			AND 
			( 
			   (@SinkNode IS NULL OR LEN(@SinkNode) = 0)
			OR (t.sink_node_name in (SELECT SinkNode FROM #list_of_sink_nodes)) 
			OR (substring(t.sink_node_name,4,3) in (select substring (SinkNode,4,3) from #list_of_sink_nodes))--and source_node_name NOT IN (SELECT source_node FROM #list_of_source_nodes))
			OR (
              LEFT(pan,6)IN (SELECT BIN FROM #list_of_BINs)
			  and source_node_name
			NOT IN (SELECT source_node FROM #list_of_source_nodes))
			  OR LEFT(pan,6) = '628051' and (substring(c.totals_group,1,3)in (
select substring (SinkNode,4,3) from #list_of_sink_nodes)) 
and source_node_name 
NOT IN (SELECT source_node FROM #list_of_source_nodes)
			)