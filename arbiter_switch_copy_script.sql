SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


SELECT 
         post_tran_id, 
pp.post_tran_cust_id,
tran_nr,
pan , 
terminal_id, 
card_acceptor_id_code,
card_acceptor_name_loc, 
totals_group, 
tran_type, 
extended_tran_type, 
message_type, 
tran_amount_req, 
system_trace_audit_nr,
datetime_req, 
retrieval_reference_nr, 
tran_tran_fee_req , 
acquiring_inst_id_code,
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
payee 

FROM   (SELECT  *  FROM   dbo.post_tran t WITH  (NOLOCK, index = ix_post_tran_7) 

 JOIN  [arbiter_withdrawals_copy_dates] b with  (NOLOCK) ON
datetime_req > start_date   and  datetime_req <=  end_date
   and  (tran_completed = 1) 
            AND (tran_reversed = 0) 
            AND (tran_type IN ( '01','00','09')) 
            AND (message_type IN ('0200', '0220')) 
            AND (tran_postilion_originated = 0
                      and (left(sink_node_name,2) !='SB')
            and  charindex('TPP',sink_node_name )<1
            AND (rsp_code_rsp = '00') 
            and settle_amount_impact !=0   AND (sink_node_name NOT IN ('GPRsnk', 'VTUsnk','SWTASPPOSsnk','ASPPOSIMCsnk','ASPPOSLMCsnk','ASPPOSVISsnk','ASPPOSVINsnk','SWTWEBABPsnk','SWTWEBGTBsnk','SWTWEBEBNsnk','SWTWEBUBAsnk')) 
            
            ) 
 )pp INNER JOIN
     dbo.post_tran_cust cc (NOLOCK, INDEX(PK_POST_TRAN_CUST)) 
            ON pp.post_tran_cust_id = cc.post_tran_cust_id
         
   AND (SUBSTRING(cc.terminal_id, 1, 4) NOT IN ( '3ICP' , '3BOL') 
           AND (cc.source_node_name NOT IN ('VTUsrc','MEGATPPsrc','MEGTPPHBCsrc')) 
            and  LEFT(cc.source_node_name,2) <>'SB')

            and (merchant_type != '5371')
            and (left(terminal_id,1)+tran_type) not in ('000','100')
        --    and terminal_id NOT like '4QT%'
and terminal_id !=  ('3IWPDJMB') 
option (recompile)