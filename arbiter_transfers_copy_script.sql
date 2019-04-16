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
--and  post_tran_id> (   select   ISNULL( min ( post_tran_id ),0)FROM  post_tran (NOLOCK, index = ix_post_tran_7)  WHERE	CONVERT(DATE, datetime_req) = CONVERT(DATE,start_date)   )
) pp
JOIN post_tran_cust cc with (NOLOCK) 
            ON pp.post_tran_cust_id = cc.post_tran_cust_id
            and  (pp.tran_completed = 1) 
            AND (pp.tran_reversed = 0) 
            AND (pp.tran_type = '50') 
            AND (pp.message_type IN ('0200', '0220')) 
            AND (pp.tran_postilion_originated = 0) 
  AND ( SUBSTRING(cc.terminal_id, 1, 1) in ('0', '1')
  or  terminal_id in ('3BOL0001', '4QTL0001')   )
             AND (cc.source_node_name like 'TSS%')
            and  left(cc.source_node_name,2 )  != 'SB'
            
            and  left(pp.sink_node_name,2) != 'SB'
            and CHARINDEX ('TPP', pp.sink_node_name)=0
            AND (pp.rsp_code_rsp in ('00','91','68','09','05') )
            and settle_amount_impact != 0
option (recompile)