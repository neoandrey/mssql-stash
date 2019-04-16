drop table  #missing_transactions_table
--drop table #temp_results

--SELECT * INTO #missing_withdrawals_transactions_table FROM #missing_transactions_table 
create  table  #missing_transactions_table  (datetime_req DATETIME,  terminal_id VARCHAR(20), masked_pan VARCHAR(30))


  BULK INSERT #missing_transactions_table  FROM 'C:\temp\arbiter_others.txt' WITH(
     FIELDTERMINATOR ='\t', ROWTERMINATOR ='\n',KEEPNULLS
  )
 

  SELECT  
   post_tran_id, cc.post_tran_cust_id,tran_nr,pan AS masked_pan, cc.terminal_id, card_acceptor_id_code, card_acceptor_name_loc, 
            dbo.GetIssuerCode(totals_group) AS issuer_code, 
            dbo.formatTranTypeStr(tran_type, extended_tran_type, message_type) AS tran_type_description, 
            dbo.formatAmount(tran_amount_req, 
    tran_currency_code) AS tran_amount_req, 
            dbo.formatAmount(tran_tran_fee_req, tran_currency_code) * - 1 AS tran_fee_req, 
    dbo.currencyAlphaCode(settle_currency_code) AS currency_alpha_code, 
            system_trace_audit_nr, pp.datetime_req, retrieval_reference_nr, 
    tran_tran_fee_req * - 1 AS tran_tran_fee_req, 
            acquiring_inst_id_code AS acquirer_code, 
            rsp_code_rsp, 
            terminal_owner, 
            sink_node_name, 
    merchant_type, 
            source_node_name, 
            from_account_id,
         1 as online_system_id,
            settle_currency_code,
            tran_currency_code,
            pos_terminal_type,
            dbo.formatAmount(settle_amount_impact,settle_currency_code) AS settle_amount_impact, 
            dbo.formatAmount(settle_amount_rsp,settle_currency_code) AS settle_amount_rsp, 
            auth_id_rsp,
    dbo.currencyAlphaCode(tran_currency_code) AS tran_currency_alpha_code ,
payee as to_account,
extended_tran_type, 1 as server_id, 0 tran_reversed

into  #temp_results
FROM   (SELECT  *  FROM   dbo.post_tran t WITH  (NOLOCK, index = ix_post_tran_7)  where

 datetime_req >= '2017-08-30' and datetime_req < '2017-09-07'
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
     dbo.post_tran_cust cc  with (NOLOCK, INDEX(PK_POST_TRAN_CUST)) 
            ON pp.post_tran_cust_id = cc.post_tran_cust_id
         
   AND (SUBSTRING(cc.terminal_id, 1, 4) NOT IN ( '3ICP' , '3BOL') 
           AND (cc.source_node_name NOT IN ('VTUsrc','MEGATPPsrc','MEGTPPHBCsrc')) 
            and  LEFT(cc.source_node_name,2) <>'SB')

            and (merchant_type != '5371')
            and (left(terminal_id,1)+tran_type) not in ('000','100')
        --    and terminal_id NOT like '4QT%'
and terminal_id !=  ('3IWPDJMB') 
JOIN  #missing_transactions_table  t on 
 --convert(date, t.datetime_req)   = convert(date, pp.datetime_req)
 --and
 cc.terminal_id = t.terminal_id
 AND
 LEFT(cc.pan ,6) = LEFT(t.masked_pan,6)
 AND
 RIGHT(cc.pan ,4) = RIGHT(t.masked_pan,4)
 
 
option (recompile)


insert into [172.25.15.14].[arbiter].dbo.tbl_postilion_office_transactions_staging
([issuer_code]
      ,[post_tran_id]
      ,[post_tran_cust_id]
      ,[tran_nr]
      ,[masked_pan]
      ,[terminal_id]
      ,[card_acceptor_id_code]
      ,[card_acceptor_name_loc]
      ,[tran_type_description]
      ,[tran_amount_req]
      ,[tran_fee_req]
      ,[currency_alpha_code]
      ,[system_trace_audit_nr]
      ,[datetime_req]
      ,[retrieval_reference_nr]
      ,[acquirer_code]
      ,[rsp_code_rsp]
      ,[terminal_owner]
      ,[sink_node_name]
      ,[merchant_type]
      ,[source_node_name]
      ,[from_account_id]
      ,[tran_tran_fee_req]
      ,[auth_id_rsp]
      ,[settle_amount_rsp]
      ,[settle_amount_impact]
      ,[pos_terminal_type]
      ,[settle_currency_code]
      ,[tran_currency_code]
      ,[tran_currency_alpha_code]
      ,[online_system_id]
      ,[server_id]
      ,[tran_reversed]
      ,[Logged]
      ,[Type]
      ,[to_account]
      ,[extended_tran_type])

SELECT  DISTINCT [issuer_code]
      ,[post_tran_id]
      ,[post_tran_cust_id]
      ,[tran_nr]
      ,[masked_pan]
      ,[terminal_id]
      ,[card_acceptor_id_code]
      ,[card_acceptor_name_loc]
      ,[tran_type_description]
      ,[tran_amount_req]
      ,[tran_fee_req]
      ,[currency_alpha_code]
      ,[system_trace_audit_nr]
      ,[datetime_req]
      ,[retrieval_reference_nr]
      ,[acquirer_code]
      ,[rsp_code_rsp]
      ,[terminal_owner]
      ,[sink_node_name]
      ,[merchant_type]
      ,[source_node_name]
      ,[from_account_id]
      ,[tran_tran_fee_req]
      ,[auth_id_rsp]
      ,[settle_amount_rsp]
      ,[settle_amount_impact]
      ,[pos_terminal_type]
      ,[settle_currency_code]
      ,[tran_currency_code]
      ,[tran_currency_alpha_code]
      ,[online_system_id]
      ,[server_id]
      ,[tran_reversed]
      ,null [Logged]
      ,null [Type]
      ,[to_account]
      ,[extended_tran_type] FROM #temp_results
      where tran_nr  NOT in  
      
      (SELECT tran_nr FROM   [172.25.15.14].[arbiter].dbo.tbl_postilion_office_transactions_staging WITH (NOLOCK))
