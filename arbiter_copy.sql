; WITH  post_tran_table as (
SELECT    
            pp.post_tran_id, 
            pp.post_tran_cust_id,
            pp.tran_nr,
            dbo.formatTranTypeStr(pp.tran_type, pp.extended_tran_type, pp.message_type) AS tran_type_description, 
            dbo.formatAmount(pp.tran_amount_req,  pp.tran_currency_code) AS tran_amount_req, 
            dbo.formatAmount(pp.tran_tran_fee_req, pp.tran_currency_code) * - 1 AS tran_fee_req, 
            dbo.currencyAlphaCode(pp.settle_currency_code) AS currency_alpha_code, 
            pp.system_trace_audit_nr, pp.datetime_req, pp.retrieval_reference_nr, 
            pp.tran_tran_fee_req * - 1 AS tran_tran_fee_req, 
            pp.acquiring_inst_id_code AS acquirer_code, 
            pp.rsp_code_rsp, 
           pp.tran_type,
            pp.sink_node_name, 
            pp.from_account_id,
            pp.online_system_id,
            settle_currency_code,
            tran_currency_code,
            dbo.formatAmount(pp.settle_amount_impact,pp.settle_currency_code) AS settle_amount_impact, 
            dbo.formatAmount(pp.settle_amount_rsp,pp.settle_currency_code) AS settle_amount_rsp, 
            auth_id_rsp,
    dbo.currencyAlphaCode(pp.tran_currency_code) AS tran_currency_alpha_code 
FROM dbo.post_tran pp(NOLOCK, INDEX(ix_post_tran_9))   JOIN (
    SELECT DATE recon_business_date FROM dbo.get_dates_in_range('20160525','20160526')
    ) r
    ON 
    pp.recon_business_date = r.recon_business_date    AND pp.tran_postilion_originated = 0
                and settle_amount_impact != 0
             and  (pp.tran_completed = 1) 
            AND (pp.tran_reversed = 0)
            AND (pp.rsp_code_rsp = '00') 
             and CHARINDEX('TPP',pp.sink_node_name  )<1
                          where
      pp.post_tran_cust_id NOT  IN(
            SELECT     trn.post_tran_cust_id     post_tran_cust_id FROM arbiter_transactions_cust_id (nolock)
            ) 

            AND (pp.tran_type IN ( '01','00','09')) 
            AND (pp.message_type IN ('0200', '0220')) 
         
            AND (pp.sink_node_name NOT IN ('GPRsnk', 'VTUsnk','SWTASPPOSsnk','ASPPOSIMCsnk','ASPPOSLMCsnk')) 
            and left(pp.sink_node_name ,2) <> 'SB'
           
)  ,
 post_tran_cust_table AS(
 
 SELECT     cc.post_tran_cust_id,
           cc.pan AS masked_pan, 
            cc.terminal_id, 
            cc.card_acceptor_id_code, 
            cc.card_acceptor_name_loc, 
            dbo.GetIssuerCode(cc.totals_group) AS issuer_code,       
            cc.terminal_owner,   
    cc.merchant_type, 
            cc.source_node_name, 
            pos_terminal_type
       

FROM
     dbo.post_tran_cust cc (NOLOCK)  WHERE
        
    (SUBSTRING(cc.terminal_id, 1, 4) != '3ICP') 
            AND (SUBSTRING(cc.terminal_id, 1, 4) != '3BOL') 
           
            AND (cc.source_node_name NOT IN ('VTUsrc','MEGATPPsrc','MEGTPPHBCsrc')) 
            and left(cc.source_node_name,2) <> 'SB'
            and (merchant_type != '5371')
            AND post_tran_cust_id> 52421521 and  post_tran_cust_id < 57123860
 
 )

 SELECT 
         post_tran_id, 
            t.post_tran_cust_id,
            tran_nr,
			 masked_pan, 
            terminal_id, 
            card_acceptor_id_code, 
            card_acceptor_name_loc, 
             issuer_code, 
             tran_type_description, 
            tran_amount_req, 
             tran_fee_req, 
            currency_alpha_code, 
            system_trace_audit_nr,
			datetime_req, 
			retrieval_reference_nr, 
              tran_tran_fee_req, 
           acquirer_code, 
            rsp_code_rsp, 
            terminal_owner, 
            sink_node_name, 
            merchant_type, 
            source_node_name, 
            from_account_id,
            online_system_id,
            settle_currency_code,
            tran_currency_code,
            pos_terminal_type,
            settle_amount_impact, 
             settle_amount_rsp, 
            auth_id_rsp,
     tran_currency_alpha_code 
 FROM 
 post_tran_table t JOIN post_tran_cust_table c
 ON
 t.post_tran_cust_id = c.post_tran_cust_id 
  AND (left(terminal_id,1)+tran_type) not in ('000','100')
 OPTION(MAXDOP 4)