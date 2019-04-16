SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT [post_tran_id]
      ,pp.[post_tran_cust_id]
      ,[tran_nr]
      ,[terminal_id]
      ,[card_acceptor_id_code]
      ,[card_acceptor_name_loc]
      ,[tran_amount_req]
      ,[system_trace_audit_nr]
      ,[datetime_req]
      ,[retrieval_reference_nr]
      ,[tran_tran_fee_req]
      ,[rsp_code_rsp]
      ,[terminal_owner]
      ,[sink_node_name]
      ,[merchant_type]
      ,[source_node_name]
      ,[from_account_id]
      ,[online_system_id]
      ,[settle_currency_code]
      ,[tran_currency_code]
      ,[pos_terminal_type]
      ,[settle_amount_impact]
      ,[settle_amount_rsp]
      ,[auth_id_rsp]
      ,[extended_tran_type]
      ,[pan]
      ,[totals_group]
      ,[tran_type]
      ,[message_type]
      ,[acquiring_inst_id_code]
      ,[payee]
,[tran_reversed]
 FROM 
	(    select * from post_tran t  with(nolock)  JOIN 
	
	(
	SELECT   rdate =[date] FROM dbo.get_dates_in_range(@StartDate, @StartDate)
	) r
       ON
       r.rdate =	 CONVERT(DATE, recon_business_date)
	              and  (tran_completed = 1) 
	              AND (tran_reversed = 0) 
	              AND (tran_type = '50') 
	              AND (message_type IN ('0200', '0220')) 
            AND (tran_postilion_originated = 0)
                   and  left(sink_node_name,2) != 'SB'
and CHARINDEX ('TPP', sink_node_name)=0
AND (rsp_code_rsp in ('00','91','68','09','05') )
and settle_amount_impact != 0
 ) pp
	inner JOIN 
	 post_tran_cust cc WITH (nolock) ON
	  pp.post_tran_cust_id = cc.post_tran_cust_id    
	  AND
    ( SUBSTRING(terminal_id, 1, 1) in ('0', '1','2')
   or  terminal_id in ('3BOL0001', '4QTL0001','3QTL002')   )
   AND (source_node_name like 'TSS%')
   and  left(source_node_name,2 )  != 'SB'
   AND left(pan,1)  != '4'
	  
	 
option (recompile)