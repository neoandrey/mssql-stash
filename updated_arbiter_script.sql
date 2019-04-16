set transaction isolation level read uncommitted

DECLARE @startDate  DATETIME 
DECLARE @endDate DATETIME 
DECLARE @start_post_tran_id  BIGINT
DECLARE @end_post_tran_id BIGINT

SET  @startDate = '20170715 00:00:00'

SET  @endDate =  '20170717 00:00:00'
SET  @endDate =  DATEADD(D,1, @endDate)

SELECT  @start_post_tran_id = post_tran_id FROM  POST_TRAN (nolock) where datetime_req = ( select  min (datetime_req) FROM post_tran ( NOLOCK, INDEX =ix_post_tran_7) WHERE  datetime_req >=@startDate  ) 
SELECT  @end_post_tran_id   = post_tran_id FROM  POST_TRAN (nolock) where datetime_req = ( select  MAX (datetime_req) FROM post_tran ( NOLOCK, INDEX =ix_post_tran_7) WHERE  datetime_req < @endDate )
  
			

SELECT  TOP 100
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


FROM  (SELECT * FROM  dbo.post_tran (NOLOCK, index = ix_post_tran_7) where 
 post_tran_id >=
 @start_post_tran_id 

and post_tran_id < @end_post_tran_id  
	 
	 AND datetime_req >= @startDate

	  AND datetime_req < @endDate
and tran_nr not in (select tran_nr from  tran_nr_arb (nolock, INDEX= IX_TRAN_NR) )
   and  (tran_completed = 1) 
            AND (tran_reversed = 0) 
            AND (tran_type IN ( '01','00','09')) 
            AND (message_type IN ('0200', '0220')) 
            AND (tran_postilion_originated = 0
                      and (left(sink_node_name,2) !='SB')
            and  charindex('TPP',sink_node_name )<1
            AND (rsp_code_rsp = '00') 
            and settle_amount_impact !=0   AND ( sink_node_name in   (SELECT online_node_name FROM  POST_ONLINE_NODE WHERE left(online_node_name,2) !='SB' and 
   online_node_name NOT IN ('GPRsnk', 'VTUsnk','SWTASPPOSsnk','ASPPOSIMCsnk','ASPPOSLMCsnk','ASPPOSVISsnk','ASPPOSVINsnk','SWTWEBABPsnk','SWTWEBGTBsnk','SWTWEBEBNsnk','SWTWEBUBAsnk')
   and right(online_node_name, 3) ='snk') 
			
			) 
            
            )

			
 )pp INNER JOIN
     dbo.post_tran_cust cc (NOLOCK, INDEX=PK_POST_TRAN_CUST) 
            ON pp.post_tran_cust_id = cc.post_tran_cust_id
         
   AND (SUBSTRING(cc.terminal_id, 1, 4) NOT IN ( '3ICP' , '3BOL') 
           AND (cc.source_node_name NOT IN ('VTUsrc','MEGATPPsrc','MEGTPPHBCsrc')) 
            and  LEFT(cc.source_node_name,2) !='SB')

            and (merchant_type != '5371')
			and terminal_id !=  ('3IWPDJMB') 
            and (left(terminal_id,1)+tran_type) not in ('000','100')
        --    and terminal_id NOT like '4QT%'

		and terminal_id !=  ('3IWPDJMB') 
option(recompile, MAXDOP 4)




----2715492103


----SELECT  top  10 datetime_req,* FROM post_tran (NOLOCK ) WHERE post_tran_id < 2689067398 order by post_tran_id desc


----SELECT  top  1 (post_tran_id ) FROM post_tran ( NOLOCK, INDEX =ix_post_tran_7) WHERE  datetime_req >= '20170718'  order by  datetime_req ASC


----select min (post_tran_id ) FROM post_tran ( NOLOCK, INDEX =ix_post_tran_7) WHERE   datetime_req,11>= '20170718'  