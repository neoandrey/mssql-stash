USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[osp_rpt_Cardless_Reversals]    Script Date: 10/11/2017 10:58:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER                                       PROCEDURE [dbo].[osp_rpt_Cardless_Reversals]
     
 
@startdate        VARCHAR(30),     
@enddate          VARCHAR(30)
--@retention_data   VARCHAR(5)
 
 
 
 
AS
BEGIN

 
 
 declare @startdate        VARCHAR(30),     @enddate          VARCHAR(30)
 
IF (@startdate IS NULL OR @enddate IS NULL)  BEGIN
 
SET @startdate  = ISNULL( @startdate, CONVERT(VARCHAR(30),(DATEADD (dd, -1, GetDate())), 112))
SET @enddate = ISNULL( @enddate, CONVERT(VARCHAR(30),(DATEADD (dd, 0, GetDate())), 112))
 
 end

 insert  into tbl_cardless_reversals 
  SELECT  t.pan AS pan,
                  t.source_node_key,
                  t.terminal_id,
            t.source_node_name, 
                 t.card_acceptor_name_loc,
                  t.tran_type,
                  t.rsp_code_rsp,
                  t.message_type,
                  t.datetime_req,
                  t.settle_amount_req/100 AS 'settle_amount_req',
                  t.settle_currency_code,
                  t.settle_amount_rsp/100 AS 'settle_amount_rsp',
            t.settle_tran_fee_rsp, 
                  t.system_trace_audit_nr,
                  t.retrieval_reference_nr,
                  t.datetime_tran_local,                                                                                                                                                                                                                                           
                              CASE
            WHEN isnull(tt.retention_data,0) = '1046' THEN 'UBN'
WHEN isnull(tt.retention_data,0) IN ('9130','8130') THEN 'ABS'
WHEN isnull(tt.retention_data,0) IN ('9044','8044') THEN 'ABP'      
WHEN isnull(tt.retention_data,0) IN ('9023','8023') THEN 'CITI'     
WHEN isnull(tt.retention_data,0) IN ('9050','8050','1034') THEN 'EBN' 
WHEN isnull(tt.retention_data,0) IN ('9214','8214') THEN 'FCMB'           
WHEN isnull(tt.retention_data,0)IN ('9070','8070','1100') THEN 'FBP'       
WHEN isnull(tt.retention_data,0) IN ('9011','8011','1708') THEN 'FBN' 
WHEN isnull(tt.retention_data,0) IN ('9058','8058','1061','1006') THEN 'GTB'       
WHEN isnull(tt.retention_data,0) IN ('9082','8082') THEN 'KSB'
WHEN isnull(tt.retention_data,0) IN ('9076','8076','1027','1045','1081','1150') THEN 'SKYE'     
WHEN isnull(tt.retention_data,0) IN ('9084','8084') THEN 'ENT'
WHEN isnull(tt.retention_data,0) IN ('9030','8039','1037') THEN 'IBTC'
WHEN isnull(tt.retention_data,0) IN ('9068','8068') THEN 'SCB'
WHEN isnull(tt.retention_data,0) IN ('9232','8232','1105') THEN 'SBP' 
WHEN isnull(tt.retention_data,0) IN ('9032','8032') THEN 'UBN'
WHEN isnull(tt.retention_data,0) IN ('9033','8033') THEN 'UBA'
WHEN isnull(tt.retention_data,0) IN ('9215','8215') THEN 'UBP'
WHEN isnull(tt.retention_data,0) IN ('9035','8035','1131') THEN 'WEMA'
WHEN isnull(tt.retention_data,0) IN ('9057','8057') THEN 'ZIB'
WHEN isnull(tt.retention_data,0) IN ('9301','8301') THEN 'JBP'
WHEN isnull(tt.retention_data,0) IN ('9030','1411') THEN 'HBC'
 
END AS IssuingBankCode,
                 
                 
                  dbo.formatAmount(
                              CASE
                                    WHEN (t.tran_type = '51') THEN t.settle_amount_impact
                                    ELSE -1 * t.settle_amount_impact
                              END
                              , t.settle_currency_code) AS settle_amount_impact,
                 
                  isnull(tt.retention_data,0) AS retentiondata,
t.from_account_id,
                  t.to_account_id
                 
  FROM  post_tran_summary t (NOLOCK) LEFT  JOIN
            post_tran_summary tt (nolock) on (t.post_tran_id = tt.post_tran_cust_id and
                                          tt.post_tran_cust_id = 1
                                         )
  where     t.tran_completed = 1
                  AND
                  t.recon_business_date between '20171010' and '20171011'
                  AND
                  t.tran_postilion_originated = 0
                  AND
                  t.message_type IN ('0200','0220','0400','0420') 
                  AND
                  t.tran_completed = 1
                  AND
                  t.tran_type IN ('01')
                  AND
                  t.rsp_code_rsp IN ('00','11','08','10','16')
                  AND
                  LEFT(t.source_node_name,6) != 'SWTASP'
                  AND
                  LEFT( t.source_node_name,3)!= 'TSS'
                  AND
				  CHARINDEX('WEB', t.source_node_name) = 0 
                  AND
                  t.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc')
                  AND
                 LEFT(t.sink_node_name,3) != 'TSS'
				AND
            CHARINDEX('TPP', t.sink_node_name) = 0 
                   and     CHARINDEX('TPP', t.source_node_name) = 0 
                  AND
                  t.sink_node_name in ('ESBCSOUTsnk')
                  AND
                  (left(t.terminal_id,1) =  '2')
             AND
              LEFT(t.source_node_name,2) != 'SB'
             AND
             LEFT(t.sink_node_name,2) != 'SB'
             AND
             t.tran_reversed = '2'
             --AND 
             --t.retention_data = @retention_data
           /**
             UNION  all*** Script for SelectTopNRows command from SSMS  ******/
			 union all


SELECT  TOP  10 t.pan AS pan1,
t.source_node_key as source_node_key1,
                  t.terminal_id AS terminal_id1,
            t.source_node_name AS source_node_name1, 
                 t.card_acceptor_name_loc AS card_acceptor_name_loc1,
                  t.tran_type AS tran_type1,
                  t.rsp_code_rsp AS rsp_code_rsp1,
                  t.message_type AS message_type1,
                  t.datetime_req AS datetime_req1,
                  t.settle_amount_req/100 AS 'settle_amount_req1',
                  t.settle_currency_code AS 'settle_currency_code1',
                  t.settle_amount_rsp/100 AS 'settle_amount_rsp1',
            t.settle_tran_fee_rsp AS settle_tran_fee1, 
                  t.system_trace_audit_nr AS system_trace_audit_nr1,
                  t.retrieval_reference_nr AS retrieval_reference_nr1,
                  t.datetime_tran_local AS datetime_tran_local1,                                                                                                                                                                                                                                                                                           
           
                              CASE
            WHEN isnull(tt.retention_data,0) = '1046' THEN 'UBN'
WHEN isnull(tt.retention_data,0) IN ('9130','8130') THEN 'ABS'
WHEN isnull(tt.retention_data,0) IN ('9044','8044') THEN 'ABP'      
WHEN isnull(tt.retention_data,0) IN ('9023','8023') THEN 'CITI'     
WHEN isnull(tt.retention_data,0) IN ('9050','8050','1034') THEN 'EBN' 
WHEN isnull(tt.retention_data,0) IN ('9214','8214') THEN 'FCMB'           
WHEN isnull(tt.retention_data,0)IN ('9070','8070','1100') THEN 'FBP'       
WHEN isnull(tt.retention_data,0) IN ('9011','8011','1708') THEN 'FBN' 
WHEN isnull(tt.retention_data,0) IN ('9058','8058','1061','1006') THEN 'GTB'       
WHEN isnull(tt.retention_data,0) IN ('9082','8082') THEN 'KSB'
WHEN isnull(tt.retention_data,0) IN ('9076','8076','1027','1045','1081','1150') THEN 'SKYE'     
WHEN isnull(tt.retention_data,0) IN ('9084','8084') THEN 'ENT'
WHEN isnull(tt.retention_data,0) IN ('9030','8039','1037') THEN 'IBTC'
WHEN isnull(tt.retention_data,0) IN ('9068','8068') THEN 'SCB'
WHEN isnull(tt.retention_data,0) IN ('9232','8232','1105') THEN 'SBP' 
WHEN isnull(tt.retention_data,0) IN ('9032','8032') THEN 'UBN'
WHEN isnull(tt.retention_data,0) IN ('9033','8033') THEN 'UBA'
WHEN isnull(tt.retention_data,0) IN ('9215','8215') THEN 'UBP'
WHEN isnull(tt.retention_data,0) IN ('9035','8035','1131') THEN 'WEMA'
WHEN isnull(tt.retention_data,0) IN ('9057','8057') THEN 'ZIB'
WHEN isnull(tt.retention_data,0) IN ('9301','8301') THEN 'JBP'
WHEN isnull(tt.retention_data,0) IN ('9030','1411') THEN 'HBC'
 
END AS IssuingBankCode1,
                 
                 
                  dbo.formatAmount(
                              CASE
                                    WHEN (t.tran_type = '51') THEN t.settle_amount_impact
                                    ELSE -1 * t.settle_amount_impact
                              END
                              , t.settle_currency_code) AS settle_amount_impact1,
                 
                  isnull(tt.retention_data,0) AS retentiondata1,
t.from_account_id AS from_account_id1,
                  t.to_account_id AS to_account_id1
                 
  FROM  post_tran_summary t (NOLOCK)
                   join
            post_tran_summary tt (nolock) on (t.post_tran_cust_id = tt.post_tran_cust_id and
                                          tt.tran_postilion_originated = 1
                                         )
  where     t.tran_completed = 1
                --AND
                --t.datetime_req between @startdate and @enddate
                  AND
                  t.tran_postilion_originated = 0
                  AND
                  t.message_type IN ('0200','0220','0400','0420') 

                  AND
                  t.tran_type IN ('01')
                  AND
                  t.rsp_code_rsp IN ('00','11','08','10','16')
                  AND
                  LEFT(t.source_node_name,6) != 'SWTASP'
                  AND
                  LEFT( t.source_node_name,3)!= 'TSS'
                  AND
				  CHARINDEX('WEB', t.source_node_name) = 0 
                  AND
                  t.source_node_name not in ('CCLOADsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTFUELsrc','GPRsrc','SWTMEGAsrc','SWTSMPsrc')
                  AND
                  LEFT(t.sink_node_name,3) != 'TSS'
				AND
            CHARINDEX('TPP', t.sink_node_name) = 0 
             and     CHARINDEX('TPP', t.source_node_name) = 0 
                  AND
                  t.sink_node_name in ('ESBCSOUTsnk')
                  AND
               (   left(t.terminal_id,1) != '2')
             AND
             LEFT( t.source_node_name,2)  !=  'SB'
             AND
             LEFT(t.sink_node_name,2) != 'SB'
             AND
             t.message_reason_code = '9601'
   OPTION (RECOMPILE, OPTIMIZE FOR UNKNOWN)
             
END
 
