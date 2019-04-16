
  
  select  post_tran.post_tran_id,
 post_tran_cust.post_tran_cust_id,
  post_tran.message_type,
   post_tran_cust.pan,
    post_tran.tran_amount_rsp,
 post_tran_cust.expiry_date,
  post_tran.acquiring_inst_id_code, 
  post_tran.retrieval_reference_nr,
   post_tran.auth_id_rsp,
    post_tran_cust.terminal_id,
 post_tran_cust.card_acceptor_id_code,
  post_tran.tran_currency_code,
   post_tran.tran_cash_rsp,
    post_tran.tran_reversed,
     post_tran_cust.pos_card_data_input_ability, 
 post_tran_cust.pos_cardholder_auth_ability,
  post_tran_cust.pos_card_capture_ability, 
  post_tran_cust.pos_operating_environment,
 post_tran_cust.pos_cardholder_present, 
 post_tran_cust.pos_card_present,
  post_tran_cust.pos_card_data_input_mode, 
  post_tran_cust.pos_cardholder_auth_method,
   post_tran_cust.pos_cardholder_auth_entity, 
   post_tran_cust.pos_card_data_output_ability, 
   post_tran_cust.pos_terminal_output_ability,
    post_tran_cust.pos_pin_capture_ability,
     post_tran_cust.pos_terminal_operator, 
      post_tran_cust.pos_terminal_type,
       post_tran.tran_type, 
       post_tran.from_account_type, 
       post_tran.datetime_tran_local,
        post_tran_cust.merchant_type,
         post_tran.icc_data_req, 
         post_tran.settle_amount_req,
          post_tran.settle_tran_fee_rsp,
           post_tran.system_trace_audit_nr,
            post_tran.settle_currency_code, 
            post_tran_cust.card_acceptor_name_loc,
             post_tran_cust.source_node_name, post_tran.sink_node_name,
              post_tran_cust.card_seq_nr,
               post_tran_cust.service_restriction_code, 
               post_tran.retention_data, 
               post_tran.ucaf_data, post_tran.extended_tran_type, post_tran.message_reason_code, post_tran.structured_data_req, post_tran.structured_data_rsp, post_tran.tran_tran_fee_req, post_tran.prev_post_tran_id, 
 post_tran_prev.system_trace_audit_nr, post_tran_prev.tran_amount_rsp, post_tran_prev.tran_cash_rsp, post_tran_prev.settle_amount_req, 
 post_tran_prev.tran_currency_code, post_tran_prev.settle_currency_code, post_tran_prev.datetime_tran_local, post_tran_prev.message_type, post_tran_prev.retention_data, post_tran_prev.ucaf_data, post_tran_prev.auth_id_rsp, post_tran_prev.structured_data_req, post_tran_prev.structured_data_rsp, post_tran_prev.tran_tran_fee_req as prev_tran_tran_fee_req, post_tran.pos_geographic_data, dbo.DecryptPan(post_tran_cust.pan,post_tran_cust.pan_encrypted,'mastercardipmfile') as panDecrypted, CAST(NULL AS datetime) AS datetime_end 
FROM  (SELECT * FROM  post_tran with (NOLOCK, INDEX(ix_post_tran_9)) 
  WHERE  post_tran.tran_type  NOT IN ( '32' , '38', '39')  and post_tran.recon_business_date = '20170321' 
) post_tran
 INNER JOIN post_tran_cust with (NOLOCK) on  post_tran_cust.post_tran_cust_id = post_tran.post_tran_cust_id   and post_tran_cust.totals_group in ( 'PRUMCDebit','UBAMCDebit' )
  left join post_tran  post_tran_prev (nolock) on
    post_tran.prev_post_tran_id = post_tran_prev.post_tran_id and post_tran.post_tran_cust_id
  = post_tran_prev.post_tran_cust_id

 
