set transaction isolation level read uncommitted
set nocount on
SELECT 
            pp.post_tran_id, pp.post_tran_cust_id,pp.tran_nr,cc.pan AS masked_pan, cc.terminal_id, cc.card_acceptor_id_code, cc.card_acceptor_name_loc, 
            dbo.GetIssuerCode(cc.totals_group) AS issuer_code, 
            dbo.formatTranTypeStr(pp.tran_type, pp.extended_tran_type, pp.message_type) AS tran_type_description, 
            dbo.formatAmount(pp.tran_amount_req, 
    pp.tran_currency_code) AS tran_amount_req, 
            dbo.formatAmount(pp.tran_tran_fee_req, pp.tran_currency_code) * - 1 AS tran_fee_req, 
    dbo.currencyAlphaCode(pp.settle_currency_code) AS currency_alpha_code, 
            pp.system_trace_audit_nr, pp.datetime_req, pp.retrieval_reference_nr, 
    pp.tran_tran_fee_req * - 1 AS tran_tran_fee_req, 
            pp.acquiring_inst_id_code AS acquirer_code, 
            pp.rsp_code_rsp, 
            cc.terminal_owner, 
            pp.sink_node_name, 
    cc.merchant_type, 
            cc.source_node_name, 
            pp.from_account_id,
         1 as online_system_id,
            settle_currency_code,
            tran_currency_code,
            pos_terminal_type,
            dbo.formatAmount(pp.settle_amount_impact,pp.settle_currency_code) AS settle_amount_impact, 
            dbo.formatAmount(pp.settle_amount_rsp,pp.settle_currency_code) AS settle_amount_rsp, 
            auth_id_rsp,
    dbo.currencyAlphaCode(pp.tran_currency_code) AS tran_currency_alpha_code ,
to_account_id,
extended_tran_type


FROM dbo.post_tran pp(NOLOCK) INNER JOIN
     dbo.post_tran_cust cc (NOLOCK) 
            ON pp.post_tran_cust_id = cc.post_tran_cust_id
            and  (pp.tran_completed = 1) 
            AND (pp.tran_reversed = 0) 
            AND (pp.tran_type IN ( '01','00','09')) 
            AND (pp.message_type IN ('0200', '0220')) 
            AND (pp.tran_postilion_originated = 0) 
   AND (SUBSTRING(cc.terminal_id, 1, 4) != '3ICP') 
            AND (SUBSTRING(cc.terminal_id, 1, 4) != '3BOL') 
            AND (pp.sink_node_name NOT IN ('GPRsnk', 'VTUsnk','SWTASPPOSsnk','ASPPOSIMCsnk','ASPPOSLMCsnk','ASPPOSVISsnk','ASPPOSVINsnk','SWTWEBABPsnk','SWTWEBGTBsnk','SWTWEBEBNsnk','SWTWEBUBAsnk')) 
            AND (cc.source_node_name NOT IN ('VTUsrc','MEGATPPsrc','MEGTPPHBCsrc')) 
            and (cc.source_node_name not like 'SB%')
            and (pp.sink_node_name not like 'SB%')
            and (pp.sink_node_name not like '%TPP%')
            AND (pp.rsp_code_rsp = '00') 
            and settle_amount_impact != 0
            and (merchant_type != '5371')
            and (left(terminal_id,1)+tran_type) not in ('000','100')
        --    and terminal_id NOT like '4QT%'
and (terminal_id not in  ('3IWPDJMB') )
and datetime_req >= '20170710'
and datetime_req <= '20170712'
and tran_nr not in (select tran_nr from tran_nr_arb)
option(recompile)