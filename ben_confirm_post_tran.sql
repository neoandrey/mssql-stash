USE [postilion_office]
GO

/****** Object:  StoredProcedure [dbo].[osp_rpt_b06_Beneficiary_Confirmation_value]    Script Date: 01/23/2017 23:40:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- [osp_rpt_b06_Beneficiary_Confirmation] null, null, 'TSSFBPsnk',null, null, null,null, null, null

CREATE         PROCEDURE [dbo].[osp_rpt_b06_Beneficiary_Confirmation_value]
      @StartDate        VARCHAR(30),    -- yyyymmdd
      @EndDate                VARCHAR(30),    -- yyyymmdd
      @SinkNode         VARCHAR(40),
      @terminalID       VARCHAR(40),      
      @show_full_pan    BIT,
      @TotalsGroup    VARCHAR (512),
      @report_date_start DATETIME = NULL,
      @report_date_end DATETIME = NULL,
      @rpt_tran_id INT = NULL
      
AS
BEGIN
 
      SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
      SET NOCOUNT ON


      --SET @StartDate = '20071122'
      --SET @EndDate = '20071125'   

      CREATE TABLE #report_result
      (
            Warning                                   VARCHAR (255),    
            StartDate                           CHAR (8),  
            EndDate                                   CHAR (8),
            recon_business_date                       DATETIME, 
            pan                                       VARCHAR (19), 
            terminal_id                     CHAR (8), -- oremeyi added this
            source_node_name        VARCHAR (40), --- oremeyi added this
            card_acceptor_id_code         CHAR (15), 
            card_acceptor_name_loc        CHAR (40), 
            sink_node_name                      VARCHAR (40), 
            tran_type                           CHAR (2), 
            rsp_code_rsp                        CHAR (2), 
            message_type                        CHAR (4), 
            datetime_req                        DATETIME,         
            settle_amount_req             FLOAT, 
            settle_amount_rsp             FLOAT, 
            settle_tran_fee_rsp                 FLOAT,            
            TranID                                    BIGINT, 
            prev_post_tran_id             BIGINT, 
            system_trace_audit_nr         CHAR (6), 
            message_reason_code                 CHAR (4), 
            retrieval_reference_nr        CHAR (12), 
            datetime_tran_local                 DATETIME, 
            from_account_type             CHAR (2), 
            to_account_type                     CHAR (2),               
            settle_currency_code          CHAR (3),   
            settle_amount_impact          FLOAT,      
            rsp_code_description          VARCHAR (60),
            settle_nr_decimals                  BIGINT,
            currency_alpha_code                 CHAR (3),
            currency_name                       VARCHAR (20),
            tran_type_description         VARCHAR (60),     
            tran_reversed                       INT,  
            isPurchaseTrx                       INT,
            isWithdrawTrx                       INT,
            isRefundTrx                         INT,
            isDepositTrx                        INT,
            isInquiryTrx                        INT,
            isTransferTrx                       INT,
            isOtherTrx                          INT,
            retention_data                      Varchar(999),
            totals_group                        Varchar(40),
            payee                               VARCHAR(50),
            from_account_id               VARCHAR(28),
            to_account_id                 VARCHAR(28)
            --Beneficiary_Account         VARCHAR (60)
      )     
      CREATE TABLE #report_result_2
      (
            retrieval_reference_nr        CHAR (12), 
            settle_amount_impact          FLOAT,
            system_trace_audit_nr         CHAR (6)    
            
            )     

      IF (@SinkNode IS NULL or Len(@SinkNode)=0)
      BEGIN
            INSERT INTO #report_result (Warning) VALUES ('Please supply the Network Name parameter.')
            SELECT * FROM #report_result
            RETURN 1
      END
      
      

      DECLARE @warning VARCHAR(255)
      DECLARE @report_date_end_next DATETIME
      DECLARE @node_name_list VARCHAR(255)
      DECLARE @date_selection_mode              VARCHAR(50)
      
      -- Get the list of nodes that will be used in determining the last closed batch
      SET @node_name_list = 'CCLOADsrc'
      SET @date_selection_mode = 'Last business day'
                  
      -- Calculate the report dates
      EXECUTE osp_rpt_get_dates @date_selection_mode, @node_name_list, @StartDate, @EndDate, @report_date_start OUTPUT, @report_date_end OUTPUT, @report_date_end_next OUTPUT, @warning OUTPUT

      IF (@warning is not null)
      BEGIN
            INSERT INTO #report_result (Warning) VALUES (@warning)
            
            SELECT * FROM #report_result
            
            RETURN 1
      END

      SET @StartDate = CONVERT(VARCHAR(30), @report_date_start, 112)
      SET @EndDate = CONVERT(VARCHAR(30), @report_date_end, 112)

      EXEC psp_get_rpt_post_tran_cust_id @report_date_start,@report_date_end,@rpt_tran_id OUTPUT 
      

      IF (@report_date_end < @report_date_start)
      BEGIN
            INSERT INTO #report_result (Warning) VALUES ('The End Date must be AFTER the Starting Date.')
            SELECT * FROM #report_result
            RETURN 1
      END

      IF (DATEDIFF(dd, @report_date_start, @report_date_end) > 31)
      BEGIN
            INSERT INTO #report_result (Warning) VALUES ('The Start and End Dates must be within 31 days from one another.')
            SELECT * FROM #report_result
            RETURN 1
      END


        CREATE TABLE #list_of_sink_nodes (sink_node   VARCHAR(30)) 
      
      INSERT INTO  #list_of_sink_nodes EXEC osp_rpt_util_split_nodenames @SinkNode
      
      CREATE TABLE #list_of_terminalIds (terminalID   VARCHAR(30)) 
      
      INSERT INTO  #list_of_terminalIds EXEC osp_rpt_util_split_nodenames @terminalID
       
  
  
  
  ;WITH  temp_results_1 AS 
(
 SELECT      
                  NULL AS Warning,
                  @StartDate as StartDate,  
                  @EndDate as EndDate,
                  t.recon_business_date,--oremeyi added this 24/02/2009
                  c.pan , --  dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
                  c.terminal_id, -- oremeyi added this
                  c.source_node_name, --oremeyi added this
                  c.card_acceptor_id_code, 
                  c.card_acceptor_name_loc, 
                  t.sink_node_name, 
                  t.tran_type, 
                  t.rsp_code_rsp, 
                  t.message_type, 
                  t.datetime_req, 
                  
                 settle_amount_req, --dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

                 settle_amount_rsp,  -- dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
                  settle_tran_fee_rsp,  --, t.settle_currency_code  dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
                  
                  t.post_tran_id as TranID, 
                  t.prev_post_tran_id, 
                  t.system_trace_audit_nr, 
                  t.message_reason_code, 
                  t.retrieval_reference_nr, 
                  t.datetime_tran_local, 
                  t.from_account_type, 
                  t.to_account_type, 
                  t.settle_currency_code, 
                  settle_amount_impact,
                  t.rsp_code_rsp rsp_code_description,   --dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
                  t.settle_currency_code settle_nr_decimals,  --dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
                  t.settle_currency_code  currency_alpha_code, --dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
                  t.settle_currency_code currency_name , --dbo.currencyName(t.settle_currency_code) AS currency_name,
                  t.extended_tran_type tran_type_description, -- dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
                  
                  t.tran_reversed,
                  t.tran_type isPurchaseTrx,--dbo.fn_rpt_isPurchaseTrx(t.tran_type)       AS isPurchaseTrx,
                  t.tran_type isWithdrawTrx,--dbo.fn_rpt_isWithdrawTrx(t.tran_type)       AS isWithdrawTrx,
                  t.tran_type isRefundTrx,--dbo.fn_rpt_isRefundTrx(t.tran_type)           AS isRefundTrx,
                  t.tran_type isDepositTrx,--dbo.fn_rpt_isDepositTrx(t.tran_type)         AS isDepositTrx,
                  t.tran_type isInquiryTrx,--dbo.fn_rpt_isInquiryTrx(t.tran_type)         AS isInquiryTrx,
                  t.tran_type isTransferTrx,--dbo.fn_rpt_isTransferTrx(t.tran_type)       AS isTransferTrx,
                  t.tran_type isOtherTrx,--dbo.fn_rpt_isOtherTrx(t.tran_type)             AS isOtherTrx,
                  t.retention_data,
                   totals_group,
                  payee,
                 from_account_id,
                  t.to_account_id
				  
      FROM
                ( 
				     (select 
post_tran_id ,
				post_tran.post_tran_cust_id ,
				prev_post_tran_id,
				sink_node_name,
				tran_postilion_originated,
				tran_completed,
				message_type,
				tran_type,
				tran_nr ,
				system_trace_audit_nr,
				rsp_code_req,
				rsp_code_rsp,
				abort_rsp_code,
				auth_id_rsp,
				retention_data,
				acquiring_inst_id_code,
				message_reason_code,
				retrieval_reference_nr,
				datetime_tran_gmt,
				datetime_tran_local ,
				datetime_req ,
				datetime_rsp,
				realtime_business_date ,
				recon_business_date ,
				from_account_type,
				to_account_type,
				from_account_id,
				to_account_id,
				tran_amount_req,
				tran_amount_rsp,
				settle_amount_impact,
				tran_cash_req,
				tran_cash_rsp,
				tran_currency_code,
				tran_tran_fee_req,
				tran_tran_fee_rsp,
				tran_tran_fee_currency_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_req,
				settle_tran_fee_rsp,
				settle_currency_code,
				structured_data_req,
				tran_reversed,
				prev_tran_approved,
				extended_tran_type,
				payee,
				online_system_id,
				receiving_inst_id_code,
				routing_type ,from_account_id
				 FROM post_tran  WITH (NOLOCK, INDEX(ix_post_tran_9)) where RECON_business_date   >=@report_date_start 
				  and
				  RECON_business_date   <=@report_date_end
				  and
							  tran_postilion_originated = 0
                  AND
                  tran_type = '50' 
                  AND
                  message_type in ('0200','0220')
                  AND
                  rsp_code_rsp  = '00'
                 AND
                  LEFT(sink_node_name, 3) ='SWT' and  sink_node_name not like '%CC%' ) 
				 t JOIN
				
				(select 
				post_tran_cust_id,
				 source_node_name ,
				pan,
				card_seq_nr,
				expiry_date,
				terminal_id,
				terminal_owner,
				card_acceptor_id_code,
				merchant_type,
				card_acceptor_name_loc,
				address_verification_data,
				totals_group,
				pan_encrypted 
				 FROM 
				 post_tran_cust (NOLOCK)
				 WHERE substring (terminal_id,1,1) = '1'  and LEFT(source_node_name, 3) = 'TSS' 
				 )
                 c
                 ON
                 t.post_tran_cust_id = c.post_tran_cust_id 
				      
				 )

),
    temp_results_2 AS 
(
 SELECT      
                  NULL AS Warning,
                  @StartDate as StartDate,  
                  @EndDate as EndDate,
                  t.recon_business_date,--oremeyi added this 24/02/2009
                  pan , --  dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
                  terminal_id, -- oremeyi added this
                  source_node_name, --oremeyi added this
                  card_acceptor_id_code, 
                  card_acceptor_name_loc, 
                  t.sink_node_name, 
                  t.tran_type, 
                  t.rsp_code_rsp, 
                  t.message_type, 
                  t.datetime_req, 
                  
                   settle_amount_req, --dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

                  settle_amount_rsp,  -- dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
                  settle_tran_fee_rsp,  --, t.settle_currency_code  dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
                  
                  t.post_tran_id as TranID, 
                  t.prev_post_tran_id, 
                  t.system_trace_audit_nr, 
                  t.message_reason_code, 
                  t.retrieval_reference_nr, 
                  t.datetime_tran_local, 
                  t.from_account_type, 
                  t.to_account_type, 
                  t.settle_currency_code, 
                  settle_amount_impact,
                  t.rsp_code_rsp rsp_code_description,   --dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
                  t.settle_currency_code settle_nr_decimals,  --dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
                  t.settle_currency_code  currency_alpha_code, --dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
                  t.settle_currency_code currency_name , --dbo.currencyName(t.settle_currency_code) AS currency_name,
                  t.extended_tran_type tran_type_description, -- dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
                  
                  t.tran_reversed,
                  t.tran_type isPurchaseTrx,--dbo.fn_rpt_isPurchaseTrx(t.tran_type)       AS isPurchaseTrx,
                  t.tran_type isWithdrawTrx,--dbo.fn_rpt_isWithdrawTrx(t.tran_type)       AS isWithdrawTrx,
                  t.tran_type isRefundTrx,--dbo.fn_rpt_isRefundTrx(t.tran_type)           AS isRefundTrx,
                  t.tran_type isDepositTrx,--dbo.fn_rpt_isDepositTrx(t.tran_type)         AS isDepositTrx,
                  t.tran_type isInquiryTrx,--dbo.fn_rpt_isInquiryTrx(t.tran_type)         AS isInquiryTrx,
                  t.tran_type isTransferTrx,--dbo.fn_rpt_isTransferTrx(t.tran_type)       AS isTransferTrx,
                  t.tran_type isOtherTrx,--dbo.fn_rpt_isOtherTrx(t.tran_type)             AS isOtherTrx,
                  t.retention_data,
                  c.totals_group,
                  payee,
                 from_account_id,
                  t.to_account_id
				  
      FROM
                ( 
				(select 
post_tran_id ,
				post_tran.post_tran_cust_id ,
				prev_post_tran_id,
				sink_node_name,
				tran_postilion_originated,
				tran_completed,
				message_type,
				tran_type,
				tran_nr ,
				system_trace_audit_nr,
				rsp_code_req,
				rsp_code_rsp,
				abort_rsp_code,
				auth_id_rsp,
				retention_data,
				acquiring_inst_id_code,
				message_reason_code,
				retrieval_reference_nr,
				datetime_tran_gmt,
				datetime_tran_local ,
				datetime_req ,
				datetime_rsp,
				realtime_business_date ,
				recon_business_date ,
				from_account_type,
				to_account_type,
				from_account_id,
				to_account_id,
				tran_amount_req,
				tran_amount_rsp,
				settle_amount_impact,
				tran_cash_req,
				tran_cash_rsp,
				tran_currency_code,
				tran_tran_fee_req,
				tran_tran_fee_rsp,
				tran_tran_fee_currency_code,
				settle_amount_req,
				settle_amount_rsp,
				settle_tran_fee_req,
				settle_tran_fee_rsp,
				settle_currency_code,
				structured_data_req,
				tran_reversed,
				prev_tran_approved,
				extended_tran_type,
				payee,
				online_system_id,
				receiving_inst_id_code,
				routing_type ,from_account_id
				 FROM post_tran  WITH (NOLOCK, INDEX(ix_post_tran_9)) where 
				 RECON_business_date   >=@report_date_start 
				  and
				  RECON_business_date   <=@report_date_end
						and	tran_postilion_originated = 1
                  AND
                  tran_type = '50' 
                  AND 
                  message_type = ('0420')
                  AND
                  rsp_code_rsp  in ( '00','91','68','05') 
                  and
                  LEFT(sink_node_name, 3) ='TSS' 
						AND	  
							                 (
SUBSTRING(sink_node_name,4, 3)  in ( 

           SELECT SUBSTRING(sink_NODE,4,3) FROM #list_of_sink_nodes
)
and sink_node_name not like '%CC%')
                  )t
                                   
  JOIN			
				(select 
				post_tran_cust_id,
				 source_node_name ,
				pan,
				card_seq_nr,
				expiry_date,
				terminal_id,
				terminal_owner,
				card_acceptor_id_code,
				merchant_type,
				card_acceptor_name_loc,
				address_verification_data,
				totals_group,
				pan_encrypted 
				 FROM 
				 post_tran_cust (NOLOCK)
				 WHERE  (substring (terminal_id,1,1) = '1') 
                  and  LEFT (source_node_name, 3) = 'SWT'
                   ) c
                ON t.post_tran_cust_id = c.post_tran_cust_id       
                  
      ) 
      ) 
 	INSERT INTO #report_result  

SELECT 

NULL AS Warning,
                 t1.StartDate,  
                  t1.EndDate,
                  t1.recon_business_date,--oremeyi added this 24/02/2009
                  t1.pan , --  dbo.fn_rpt_PanForDisplay(c.pan, @show_full_pan) AS pan,
                  t1.terminal_id, -- oremeyi added this
                 t1.source_node_name, --oremeyi added this
                  t1.card_acceptor_id_code, 
                 t1.card_acceptor_name_loc, 
                 t1.sink_node_name, 
                  t1.tran_type, 
                  t1.rsp_code_rsp, 
                  t1.message_type, 
                  t1.datetime_req, 
                  
                   t1.settle_amount_req, --dbo.formatAmount(t.settle_amount_req, t.settle_currency_code) AS settle_amount_req, 

                  t1.settle_amount_rsp,  -- dbo.formatAmount(t.settle_amount_rsp, t.settle_currency_code) AS settle_amount_rsp, 
                  t1.settle_tran_fee_rsp,  --, t.settle_currency_code  dbo.formatAmount(t.settle_tran_fee_rsp, t.settle_currency_code) AS settle_tran_fee_rsp, 
                  
                   t1.TranID, 
                  t1.prev_post_tran_id, 
                  t1.system_trace_audit_nr, 
                  t1.message_reason_code, 
                  t1.retrieval_reference_nr, 
                  t1.datetime_tran_local, 
                  t1.from_account_type, 
                  t1.to_account_type, 
                  t1.settle_currency_code, 
                  t1.settle_amount_impact,
                  t1.rsp_code_description,   --dbo.formatRspCodeStr(t.rsp_code_rsp) as rsp_code_description,
                  t1.settle_nr_decimals,  --dbo.currencyNrDecimals(t.settle_currency_code) AS settle_nr_decimals,
                  t1.currency_alpha_code, --dbo.currencyAlphaCode(t.settle_currency_code) AS currency_alpha_code,
                  t1.currency_name , --dbo.currencyName(t.settle_currency_code) AS currency_name,
                  t1.tran_type_description, -- dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) AS tran_type_description,
                  
                  t1.tran_reversed,
                  t1.isPurchaseTrx,--dbo.fn_rpt_isPurchaseTrx(t.tran_type)       AS isPurchaseTrx,
                  t1.isWithdrawTrx,--dbo.fn_rpt_isWithdrawTrx(t.tran_type)       AS isWithdrawTrx,
                  t1.isRefundTrx,--dbo.fn_rpt_isRefundTrx(t.tran_type)           AS isRefundTrx,
                 t1.isDepositTrx,--dbo.fn_rpt_isDepositTrx(t.tran_type)         AS isDepositTrx,
                  t1.isInquiryTrx,--dbo.fn_rpt_isInquiryTrx(t.tran_type)         AS isInquiryTrx,
                  t1.isTransferTrx,--dbo.fn_rpt_isTransferTrx(t.tran_type)       AS isTransferTrx,
                   t1.isOtherTrx,--dbo.fn_rpt_isOtherTrx(t.tran_type)             AS isOtherTrx,
                  t1.retention_data,
                  t1.totals_group,
                  t1.payee,
                  t1.from_account_id,
                  t1.to_account_id

FROM 	  temp_results_1 t1 join temp_results_2  t2 on t1.retrieval_reference_nr = t2.retrieval_reference_nr AND t1.system_trace_audit_nr = t2.system_trace_audit_nr
  
END
IF ( OBJECT_ID('ben_confirm') IS NOT NULL)
		 BEGIN
				  DROP TABLE ben_confirm
		 END



select * into ben_confirm from #report_result 

select 
distinct 
,
source_node_name,
dbo.formatAmount(
                              CASE
                                    WHEN (tran_type = '51') THEN -1 * settle_amount_impact
                                    ELSE settle_amount_impact
           recon_business_date                         
                              END
                              , settle_currency_code) AS settle_amount_impact,



settle_amount_impact
from ben_confirm (NOLOCK)

--group by sink_node_name,tran_type,settle_amount_impact,settle_currency_code,source_node_name












  
				   
				 
       

GO

