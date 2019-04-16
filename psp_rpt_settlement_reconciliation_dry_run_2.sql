USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_rpt_settlement_reconciliation]    Script Date: 07/13/2016 11:14:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF

	create        PROCEDURE [dbo].[psp_rpt_settlement_reconciliation_dry_run]
      @Start_Date DATETIME=NULL,    -- yyyymmdd
      @End_Date DATETIME=NULL,      -- yyyymmdd
      @report_date_start DATETIME = NULL,
      @report_date_end DATETIME = NULL,
      @rpt_tran_id INT = NULL

AS
BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

      
      SET NOCOUNT ON

      CREATE TABLE #report_result
      ( 
                  --post_tran_cust_id  VARCHAR (19),
                  --tran_type   CHAR (2),
                  
                        business_date VARCHAR (40),
                        --datetime_rsp datetime,
                        Terminal_id CHAR (8),
                        PAN  VARCHAR (19),
                        --message_type CHAR (4),
                        rsp_code_rsp CHAR (2),
                        --PTC_source_node_name VARCHAR (40),
                        card_acceptor_id_code VARCHAR (25),
                       -- PT_merchant_type CHAR (4),
                        terminal_owner VARCHAR(20),
                        totals_group VARCHAR (19),
                        --PT_sink_node_name VARCHAR (20),
                        system_trace_audit_nr CHAR (6),
                        acquiring_inst_id_code VARCHAR(12),
                        retrieval_reference_nr CHAR (12),
                        --settle_amount_rsp FLOAT,
                        --settle_tran_fee_rsp FLOAT,
                        --tran_reversed INT,
                        extended_tran_type CHAR (4),
                        --payee VARCHAR(50),
                        --receiving_inst_id_code VARCHAR(50),
                        Amount_payable  FLOAT,
                        Amount_receivable FLOAT,
                        Issuer_fee_payable  FLOAT,
                        Acquirer_fee_payable  FLOAT,
                        Acquirer_fee_receivable  FLOAT,
                        Issuer_fee_receivable  FLOAT,
                        ISW_fee_receivable  FLOAT,
                        Processor_fee_receivable  FLOAT,
                        NCS_fee_receivable  FLOAT,
                        Terminal_owner_fee_receivable  FLOAT, 
                        Easyfuel_account  FLOAT,
                        ISO_fee_receivable  FLOAT,
                        PTSP_fee_receivable  FLOAT,
                        Recharge_fee_payable  FLOAT,
                        PAYIN_Institution_fee_receivable  FLOAT,
                        Fleettech_fee_receivable  FLOAT,
                        LYSA_fee_receivable  FLOAT,
                        SVA_fee_receivable  FLOAT,
                        udirect_fee_receivable  FLOAT,
                        Merchant_fee_receivable FLOAT,
                        ATMC_Fee_Payable FLOAT,
                        ATMC_Fee_Receivable FLOAT,
                        Currency_code char (3)
                  
                       
                                       
      )
      
    


DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,REPLACE(CONVERT(VARCHAR(10),  DATEADD(D, -1,GETDATE()),111),'/', ''))
SET @to_date = ISNULL(@end_date,REPLACE(CONVERT(VARCHAR(10),  DATEADD(D, -1,GETDATE()),111),'/', ''))

DECLARE @temp_late_reversal  TABLE(post_tran_id BIGINT)

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[temp_post_tran_data]') AND name = N'temp_post_tran_data_recon') BEGIN

CREATE NONCLUSTERED INDEX [temp_post_tran_data_recon] ON [dbo].[temp_post_tran_data] 
(
	[PT_tran_postilion_originated] ASC,
	[PT_settle_currency_code] ASC,
	[PT_sink_node_name] ASC,
	[PT_tran_type] ASC,
	[PT_rsp_code_rsp] ASC,
	[PTC_source_node_name] ASC,
	[PTC_card_acceptor_id_code] ASC,
	[PTC_totals_group] ASC
)
	INCLUDE (
	
	 [PT_post_tran_id],
	[PT_post_tran_cust_id],
	[PT_message_type],
	[PT_system_trace_audit_nr],
	[PT_acquiring_inst_id_code],
	[PT_retrieval_reference_nr],
	[PT_settle_amount_impact],
	[PT_settle_amount_rsp],
	[PT_tran_reversed],
	[PT_extended_tran_type],
	[PT_payee],
	[PTC_pan],
	[PTC_terminal_id],
	[PTC_terminal_owner],
	[PTC_merchant_type]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]

END

            
INSERT
                        INTO #report_result
SELECT
      --PT_post_tran_cust_id ,
                  --PT_tran_type,         
                        j.business_date ,
                        --PT_datetime_rsp ,
                        PTC_Terminal_id ,
                        PTC_PAN ,
                        --PT_message_type ,
                        PT_rsp_code_rsp ,
                        --PTC_source_node_name VARCHAR (40),
                        PTC_card_acceptor_id_code ,
                        --PT_merchant_type ,
                        PTC_terminal_owner ,
                        PTC_totals_group ,
                        --PT_sink_node_name VARCHAR (20),
                       
                        PT_system_trace_audit_nr,

                        PT_acquiring_inst_id_code,
                        PT_retrieval_reference_nr,
                        --PT_settle_amount_rsp,
                        --PT_settle_tran_fee_rsp,

                        --PT_tran_reversed,
                        PT_extended_tran_type,
                        --PT_payee,
                        --PT_receiving_inst_id_code,
                        Amount_payable  = Sum ( CASE 
                             WHEN (PTC_source_node_name = 'CCLOADsrc' and PTC_terminal_id like '3IAP%') then 0
                             WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE')then J.amount
                             WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') then J.amount*-1
                             WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE')then J.amount
                       ELSE 0 END)/100,   

                        Amount_receivable = Sum ( CASE
                             WHEN (PTC_source_node_name = 'CCLOADsrc' and PTC_terminal_id like '3IAP%') then 0
                             WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') then J.amount*-1
                             WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE')then J.amount
                       ELSE 0 END)/100,   
                        Issuer_fee_payable = Sum ( CASE 
                             WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') then J.fee*-1
                             WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')then J.fee
                             WHEN (DebitAccNr_acc_nr LIKE '%SPONSOR%FEE%PAYABLE') then J.fee*-1
                             WHEN (CreditAccNr_acc_nr LIKE '%SPONSOR%FEE%PAYABLE')then J.fee
                             
                       ELSE 0 END)/100,   
                        Acquirer_fee_payable = Sum ( CASE
                             WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE' and DebitAccNr_acc_nr NOT LIKE '%ISW%') then J.fee*-1
                             WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE' and CreditAccNr_acc_nr NOT LIKE '%ISW%')then J.fee
                       ELSE 0 END)/100,   

                        Acquirer_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE' and DebitAccNr_acc_nr NOT LIKE '%ISW%') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE' and CreditAccNr_acc_nr NOT LIKE '%ISW%')then J.fee
                        ELSE 0 END)/100,  
                        Issuer_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE')then J.fee
                              WHEN (DebitAccNr_acc_nr LIKE '%SPONSOR%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%SPONSOR%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  

                        ISW_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' and DebitAccNr_acc_nr NOT LIKE '%PROCESSOR%' and DebitAccNr_acc_nr NOT LIKE '%PTSP%'and DebitAccNr_acc_nr NOT LIKE '%ISO%' and DebitAccNr_acc_nr NOT LIKE '%PAYIN%' and DebitAccNr_acc_nr NOT LIKE '%NCS%') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE'and CreditAccNr_acc_nr NOT LIKE '%PROCESSOR%' and CreditAccNr_acc_nr NOT LIKE '%PTSP%' and CreditAccNr_acc_nr NOT LIKE '%ISO%' and CreditAccNr_acc_nr NOT LIKE '%PAYIN%' and CreditAccNr_acc_nr NOT LIKE '%NCS%')then J.fee
                        ELSE 0 END)/100,  
                        Processor_fee_receivable= Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  

                        NCS_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  

                        Terminal_owner_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEI%' and DebitAccNr_acc_nr NOT LIKE '%ISW%') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEI%' and CreditAccNr_acc_nr NOT LIKE '%ISW%')then J.fee
                        ELSE 0 END)/100,  
                        Easyfuel_account = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT')then J.fee
                        ELSE 0 END)/100,  
                        ISO_fee_receivable  = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,  
                        PTSP_fee_receivable  = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')then J.fee

                        ELSE 0 END)/100,  
                        Recharge_fee_payable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE')then J.fee
                        ELSE 0 END)/100,
                        PAYIN_Institution_fee_receivable   = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        Fleettech_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        LYSA_fee_receivable  = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        SVA_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        udirect_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE')then J.fee
                        ELSE 0 END)/100,
                        Merchant_fee_receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100, 

                        ATMC_Fee_PAYABLE = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE')then J.fee
                        ELSE 0 END)/100, 

                        ATMC_Fee_Receivable = Sum ( CASE
                              WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE') then J.fee*-1
                              WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE')then J.fee
                        ELSE 0 END)/100,

                         Currency_code = CASE WHEN (dbo.fn_rpt_isBillpayment (PTC_terminal_id,PT_extended_tran_type,PT_message_type,PT_sink_node_name,PT_payee,PTC_card_acceptor_id_code ,PTC_source_node_name,pt_tran_type,PTC_PAN) = '1' and 
                           dbo.fn_rpt_account_type_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 'BILLPAYMENT MCARD') THEN '840'
                                              WHEN (dbo.fn_rpt_account_type_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 'MCARD BILLING') THEN '840'
                        ELSE pt_settle_currency_code END



      FROM
                        temp_journal_data  J (NOLOCK)
                     join 
                     temp_post_tran_data PT (NOLOCK )
                    ON (J.post_tran_id = PT_post_tran_id AND J.post_tran_cust_id = PT_post_tran_cust_id)
                 

WHERE 

      PT_tran_postilion_originated = 0
     
      AND PT_rsp_code_rsp in ('00','11','09')
      
      AND (
          (PT_settle_amount_impact<> 0 and PT_message_type   in ('0200','0220'))

       or ((PT_settle_amount_impact<> 0 and PT_message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT_tran_type, PTC_source_node_name, PT_sink_node_name, PTC_terminal_id ,PTC_totals_group ,PTC_pan) <> 1 and PT_tran_reversed <> 2)
       or (PT_settle_amount_impact<> 0 and PT_message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT_tran_type, PTC_source_node_name, PT_sink_node_name, PTC_terminal_id ,PTC_totals_group ,PTC_pan) = 1 ))

       or (PT_settle_amount_rsp<> 0 and PT_message_type   in ('0200','0220') and PT_tran_type = 40 and (SUBSTRING(PTC_terminal_id,1,1)= '1' or SUBSTRING(PTC_terminal_id,1,1)= '0'))
       or (PT_message_type = '0420' and PT_tran_reversed <> 2 and PT_tran_type = 40 and (SUBSTRING(PTC_terminal_id,1,1)= '1' or SUBSTRING(PTC_terminal_id,1,1)= '0')))
      
      

      AND not (PTC_merchant_type in ('4004','4722') and PT_tran_type = '00' and PTC_source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(PT_settle_amount_impact/100)< 200
          AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 'MCARD BILLING'))

      --AND not (PT_merchant_type in ('5371') and PT_tran_type = '00' and 
      --          (dbo.fn_rpt_isPurchaseTrx_sett(PT_tran_type, PTC_source_node_name, PT_sink_node_name, PTC_terminal_id ,PT_totals_group ,PT_pan) <> 2) 
      --         AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 'MCARD BILLING'))
      --AND PT_post_tran_cust_id >= @rpt_tran_id
	     
      AND NOT (dbo.fn_rpt_isBillpayment (PTC_terminal_id,PT_extended_tran_type,PT_message_type,PT_sink_node_name,PT_payee,PTC_card_acceptor_id_code ,PTC_source_node_name,PT_tran_type,PTC_pan) = '1' and (DebitAccNr_acc_nr like '%amount%'
               or CreditAccNr_acc_nr like '%amount%')) 
      AND NOT (dbo.fn_rpt_isPurchaseTrx_sett(PT_tran_type, PTC_source_node_name, PT_sink_node_name, PTC_terminal_id ,PTC_totals_group ,PTC_pan) = 2
               AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 'MCARD BILLING'))
      --AND NOT (dbo.fn_rpt_isCardload (PTC_source_node_name ,PT_pan, PT_tran_type)= '1' and terminal_id not like  '3IAP%')
      --AND NOT (dbo.fn_rpt_transfers_sett(PTC_terminal_id,PT_payee,PT_card_acceptor_name_loc,
                                  --PT_extended_tran_type ,PTC_source_node_name) = '1' and PT_tran_type = '50')
      AND NOT (PTC_terminal_id like '3IGW%' and PT_Tran_type = '00' and PT_acquiring_inst_id_code = '111111')
      AND NOT (PTC_terminal_id = '3VRV0001' and PT_Tran_type = '00' and PT_sink_node_name = 'CCLOADsnk')
      --AND NOT (dbo.fn_rpt_account_type_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 'MCARD BILLING')
      --AND NOT (dbo.fn_rpt_transfers_sett(PTC_terminal_id,PT_payee,PT_card_acceptor_name_loc,
                                  --PT_extended_tran_type ,PTC_source_node_name) = '314' AND PT_tran_type= '50')
      AND PTC_totals_group not in ('CUPGroup')
      
	  and NOT (PTC_totals_group in ('VISAGroup') and PT_acquiring_inst_id_code = '627787')
	  and NOT (PTC_totals_group in ('VISAGroup') and PT_sink_node_name not in ('ASPPOSVINsnk'))
      and PT_tran_type <> '21'
      and PT_settle_currency_code = '566'
      and PTC_source_node_name  NOT LIKE 'SB%'
      and PT_sink_node_name  NOT LIKE 'SB%'
      and not(PTC_source_node_name  LIKE '%TPP%')
       and not(PT_sink_node_name  LIKE '%TPP%' )
        and not (PTC_source_node_name  = 'MEGATPPsrc' and PT_tran_type = '00')
        and not (PT_tran_type = '00' and substring(PTC_terminal_id,1,1) in ('0','1') and PT_sink_node_name = 'CCLOADsnk')
        and PTC_source_node_name not in ('ASPSPNTFsrc', 'ASPSPONUSsrc') 
        and not (PTC_source_node_name in ('SWTNCS2src','SWTFBPsrc') and PT_sink_node_name in ('ASPPOSLMCsnk'))
         and PTC_card_acceptor_id_code not in ('IPG000000000001')
          and PT_sink_node_name not in ('WUESBPBsnk')
group by PT_retrieval_reference_nr,J.business_date,
         PTC_terminal_id,PTC_pan,
         PT_rsp_code_rsp,PTC_card_acceptor_id_code,
         PTC_terminal_owner,PTC_totals_group,PT_system_trace_audit_nr,
         PT_acquiring_inst_id_code,
         PT_extended_tran_type,
         PT_settle_currency_code,
         dbo.fn_rpt_isBillpayment (PTC_terminal_id,PT_extended_tran_type,PT_message_type,PT_sink_node_name,PT_payee,PTC_card_acceptor_id_code ,PTC_source_node_name,PT_tran_type,PTC_pan),
         dbo.fn_rpt_account_type_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr)
         --PT_tran_type,PT_message_type,PT_settle_amount_rsp,PT_settle_tran_fee_rsp,PT_tran_reversed,
        
         --PT_payee,PT_receiving_inst_id_code,
         --PT_post_tran_cust_id,PT_datetime_rsp,PT_merchant_type,
         
        OPTION (recompile, maxdop 8)

select * from #report_result 

where  (ROUND((Amount_payable + Amount_receivable + Issuer_fee_payable +  Acquirer_fee_payable + 
       Acquirer_fee_receivable + Issuer_fee_receivable + ISW_fee_receivable + Processor_fee_receivable + 
       NCS_fee_receivable + Terminal_owner_fee_receivable + Easyfuel_account + ISO_fee_receivable + 
       PTSP_fee_receivable + Recharge_fee_payable + PAYIN_Institution_fee_receivable + 
       Fleettech_fee_receivable + LYSA_fee_receivable +  SVA_fee_receivable + udirect_fee_receivable + 
       Merchant_fee_receivable + ATMC_Fee_PAYABLE + ATMC_Fee_Receivable),2)
       
       > 0) or 

      (ROUND((Amount_payable + Amount_receivable + Issuer_fee_payable +  Acquirer_fee_payable + 
       Acquirer_fee_receivable + Issuer_fee_receivable + ISW_fee_receivable + Processor_fee_receivable + 
       NCS_fee_receivable + Terminal_owner_fee_receivable + Easyfuel_account + ISO_fee_receivable + 
       PTSP_fee_receivable + Recharge_fee_payable + PAYIN_Institution_fee_receivable + 
       Fleettech_fee_receivable + LYSA_fee_receivable +  SVA_fee_receivable + udirect_fee_receivable + 
       Merchant_fee_receivable + ATMC_Fee_PAYABLE + ATMC_Fee_Receivable),2)
       
       < 0)

   OPTION (recompile, maxdop 8)


END




