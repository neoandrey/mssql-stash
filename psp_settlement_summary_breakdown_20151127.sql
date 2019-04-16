USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown]    Script Date: 11/27/2015 4:41:09 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER                                                                                                                     PROCEDURE [dbo].[psp_settlement_summary_breakdown](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @report_date_start DATETIME = NULL,
	@report_date_end DATETIME = NULL,
	@rpt_tran_id INT = NULL,
    @rpt_tran_id1 INT = NULL
)
AS
BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,REPLACE(CONVERT(VARCHAR(10), DATEADD(D,-1,GETDATE()),111),'/', '') )
SET @to_date = ISNULL(@end_date,REPLACE(CONVERT(VARCHAR(10), GETDATE(),111),'/', '') )


DECLARE @first_post_tran_id BIGINT
DECLARE @last_post_tran_id BIGINT
EXEC usp_rpt_get_post_tran_id_range @from_date, @to_date, @first_post_tran_id OUTPUT, @last_post_tran_id OUTPUT

INSERT 
           INTO settlement_summary_session
       SELECT (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK),post_tran_leg_internal PT (NOLOCK)

        where PT.rsp_code_rsp in ('00','11','09')
              AND  PT.tran_postilion_originated = 0
     
              AND (PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220')
              or (PT.settle_amount_impact<> 0 and PT.message_type = '0420' and PT.tran_reversed <> 2 )
              or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1)= '1' or LEFT(PT.Terminal_id,1)= '0'))
              or (PT.settle_amount_rsp<> 0 and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1)= '1' or LEFT(PT.Terminal_id,1)= '0')) )
              AND (J.business_date >= @from_date AND J.business_date < (@to_date))
		AND PT.post_tran_id >=@first_post_tran_id AND PT.post_tran_id<=@last_post_tran_id	
             

	Group by J.business_date
        OPTION (MAXDOP 16)    
IF(@@ERROR <>0)
RETURN


        
	

--EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 
--EXEC psp_get_rpt_post_tran_cust_id_NIBSS @from_date,@to_date,@rpt_tran_id1 OUTPUT 


--INSERT INTO settlement_summary_breakdown
--(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type)

CREATE TABLE #report_result
	(
		bank_code				VARCHAR (32),
		trxn_category				VARCHAR (64),  
		Debit_Account_type		        VARCHAR (100), 
		Credit_Account_type 		        VARCHAR (100),
		trxn_amount				money, 
		trxn_fee 				money, 
                trxn_date                               Datetime,
                currency                                VARCHAR (50),
                late_reversal                           CHAR    (1),
                Card_Type                               VARCHAR (25),
                Terminal_type                           VARCHAR (25),
                source_node_name                        VARCHAR (100),
                Unique_key                              VARCHAR (200),
                Acquirer                                VARCHAR (50),
                Issuer                                  VARCHAR (50),
							         )

INSERT INTO  #report_result

SELECT		         
	bank_code = CASE 
	
/*WHEN                     (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480'
                          and dbo.fn_rpt_terminal_type(PT.terminal_id) <>'3' 
                           THEN 'UBA'
                           
WHEN                      (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND (PT.acquiring_inst_id_code <> '627480' or 
                          (PT.acquiring_inst_id_code = '627480'
                          and dbo.fn_rpt_terminal_type(PT.terminal_id) ='3')
                          ) 
                           THEN 'GTB'*/
                           
 /* WHEN                     (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                           OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          AND PT.acquiring_inst_id_code = '627480' 
                           THEN 'UBA' */
                           
 /*WHEN                      (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                           OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')
                           and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                          AND dbo.fn_rpt_CardGroup(PT.pan) = '6'
                          --AND PT.acquiring_inst_id_code <> '627480' 
                           THEN 'GTB'*/

WHEN PTT.Retention_data = '1046' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'UBN'
WHEN PTT.Retention_data ='9130' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'ABS'
WHEN PTT.Retention_data ='9044' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'ABP'
WHEN PTT.Retention_data ='9023'  and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') then 'CITI'
WHEN PTT.Retention_data ='9050' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'EBN'
WHEN PTT.Retention_data ='9214' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'FCMB'
WHEN PTT.Retention_data ='9070' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'FBP'
WHEN PTT.Retention_data ='9011' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'FBN'
WHEN PTT.Retention_data ='9058'  and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') then 'GTB'
WHEN PTT.Retention_data ='9082' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'KSB'
WHEN PTT.Retention_data ='9076' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'SKYE'
WHEN PTT.Retention_data ='9084' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'ENT'
WHEN PTT.Retention_data ='9039' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'IBTC'
WHEN PTT.Retention_data ='9068' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'SCB'
WHEN PTT.Retention_data ='9232' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'SBP'
WHEN PTT.Retention_data ='9032'  and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') then 'UBN'
WHEN PTT.Retention_data ='9033'  and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') then 'UBA'
WHEN PTT.Retention_data ='9215'  and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') then 'UBP'
WHEN PTT.Retention_data ='9035' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'WEMA'
WHEN PTT.Retention_data ='9057' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'ZIB'
WHEN PTT.Retention_data ='9301' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE')  then 'JBP'
			
			
			WHEN PTT.Retention_data = '1131' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'WEMA'
                         WHEN PTT.Retention_data in ('1061','1006') and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'

                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'GTB'
                         WHEN PTT.Retention_data = '1708' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'FBN'
                         WHEN PTT.Retention_data in ('1027','1045','1081','1015') and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'SKYE'
                         WHEN PTT.Retention_data = '1037' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'IBTC'
                         WHEN PTT.Retention_data = '1034' and 
                         (RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                          OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                          OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'EBN'
                         -- WHEN PTT.Retention_data = '1006' and 
                         --(RIGHT(DebitAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE' OR RIGHT(CreditAccNr.acc_nr, 18)='ISSUER_FEE_PAYABLE'
                         -- OR RIGHT(DebitAccNr.acc_nr , 21) = 'ISSUER_FEE_RECEIVABLE' OR RIGHT(CreditAccNr.acc_nr, 21) = 'ISSUER_FEE_RECEIVABLE'
                         -- OR RIGHT(DebitAccNr.acc_nr ,14) = 'AMOUNT_PAYABLE' OR RIGHT(CreditAccNr.acc_nr,14) = 'AMOUNT_PAYABLE') THEN 'DBL' 
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='UBA' OR LEFT(CreditAccNr.acc_nr,3 )='UBA') THEN 'UBA'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='FBN' OR LEFT(CreditAccNr.acc_nr,3 )='FBN') THEN 'FBN'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='ZIB' OR LEFT(CreditAccNr.acc_nr,3 )='ZIB') THEN 'ZIB' 
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='SPR' OR LEFT(CreditAccNr.acc_nr,3 )='SPR') THEN 'ENT'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='GTB' OR LEFT(CreditAccNr.acc_nr,3 )='GTB') THEN 'GTB'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='PRU' OR LEFT(CreditAccNr.acc_nr,3 )='PRU') THEN 'SKYE'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='OBI' OR LEFT(CreditAccNr.acc_nr,3 )='OBI') THEN 'EBN'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='WEM' OR LEFT(CreditAccNr.acc_nr,3 )='WEM') THEN 'WEMA'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='AFR' OR LEFT(CreditAccNr.acc_nr,3 )='AFR') THEN 'MSB'
                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='IBTC' OR LEFT(CreditAccNr.acc_nr,4)='IBTC') THEN 'IBTC'
                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='PLAT' OR LEFT(CreditAccNr.acc_nr,4)='PLAT') THEN 'KSB'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='UBP' OR LEFT(CreditAccNr.acc_nr,3 )='UBP') THEN 'UBP'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='DBL' OR LEFT(CreditAccNr.acc_nr,3 )='DBL') THEN 'DBL'

                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='FCMB' OR LEFT(CreditAccNr.acc_nr,4 )='FCMB') THEN 'FCMB'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='IBP' OR LEFT(CreditAccNr.acc_nr,3 )='IBP') THEN 'ABP'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='UBN' OR LEFT(CreditAccNr.acc_nr,3 )='UBN') THEN 'UBN'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='ETB' OR LEFT(CreditAccNr.acc_nr,3 )='ETB') THEN 'ETB'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='FBP' OR LEFT(CreditAccNr.acc_nr,3 )='FBP') THEN 'FBP'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='SBP' OR LEFT(CreditAccNr.acc_nr,3 )='SBP') THEN 'SBP'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='ABP' OR LEFT(CreditAccNr.acc_nr,3 )='ABP') THEN 'ABP'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='EBN' OR LEFT(CreditAccNr.acc_nr,3 )='EBN') THEN 'EBN'

                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='CITI' OR LEFT(CreditAccNr.acc_nr,4 )='CITI') THEN 'CITI'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='FIN' OR LEFT(CreditAccNr.acc_nr,3 )='FIN') THEN 'FCMB'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='ASO' OR LEFT(CreditAccNr.acc_nr,3 )='ASO') THEN 'ASO'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='OLI' OR LEFT(CreditAccNr.acc_nr,3 )='OLI') THEN 'OLI'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='HSL' OR LEFT(CreditAccNr.acc_nr,3 )='HSL') THEN 'HSL'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='ABS' OR LEFT(CreditAccNr.acc_nr,3 )='ABS') THEN 'ABS'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='PAY' OR LEFT(CreditAccNr.acc_nr,3 )='PAY') THEN 'PAY'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='SAT' OR LEFT(CreditAccNr.acc_nr,3 )='SAT') THEN 'SAT'
                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='3LCM' OR LEFT(CreditAccNr.acc_nr,4 )='3LCM') THEN '3LCM'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='SCB' OR LEFT(CreditAccNr.acc_nr,3 )='SCB') THEN 'SCB'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='JBP' OR LEFT(CreditAccNr.acc_nr,3 )='JBP') THEN 'JBP'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='RSL' OR LEFT(CreditAccNr.acc_nr,3 )='RSL') THEN 'RSL'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='PSH' OR LEFT(CreditAccNr.acc_nr,3 )='PSH') THEN 'PSH'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='INF' OR LEFT(CreditAccNr.acc_nr,3 )='INF') THEN 'INF'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='UML' OR LEFT(CreditAccNr.acc_nr,3 )='UML') THEN 'UML'

                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='ACCI' OR LEFT(CreditAccNr.acc_nr,4 )='ACCI') THEN 'ACCI'
                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='EKON' OR LEFT(CreditAccNr.acc_nr,4 )='EKON') THEN 'EKON'
                         WHEN (LEFT(DebitAccNr.acc_nr,4 )='ATMC' OR LEFT(CreditAccNr.acc_nr,4 )='ATMC') THEN 'ATMC'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='HBC' OR LEFT(CreditAccNr.acc_nr,3 )='HBC') THEN 'HBC'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='UNI' OR LEFT(CreditAccNr.acc_nr,3 )='UNI') THEN 'UNI'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='UNC' OR LEFT(CreditAccNr.acc_nr,3 )='UNC') THEN 'UNC'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='NCS' OR LEFT(CreditAccNr.acc_nr,3 )='NCS') THEN 'NCS' 
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='HAG' OR LEFT(CreditAccNr.acc_nr,3 )='HAG') THEN 'HAG'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='EXP' OR LEFT(CreditAccNr.acc_nr,3 )='EXP') THEN 'DBL'
			 WHEN (LEFT(DebitAccNr.acc_nr,4 )='FGMB' OR LEFT(CreditAccNr.acc_nr,4 )='FGMB') THEN 'FGMB'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='CEL' OR LEFT(CreditAccNr.acc_nr,3 )='CEL') THEN 'CEL'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='RDY' OR LEFT(CreditAccNr.acc_nr,3 )='RDY') THEN 'RDY'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='AMJ' OR LEFT(CreditAccNr.acc_nr,3 )='AMJ') THEN 'AMJU'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='CAP' OR LEFT(CreditAccNr.acc_nr,3 )='CAP') THEN 'O3CAP'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='VER' OR LEFT(CreditAccNr.acc_nr,3 )='VER') THEN 'VER_GLOBAL'

			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='SMF' OR LEFT(CreditAccNr.acc_nr,3 )='SMF') THEN 'SMFB'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='SLT' OR LEFT(CreditAccNr.acc_nr,3 )='SLT') THEN 'SLTD'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='JES' OR LEFT(CreditAccNr.acc_nr,3 )='JES') THEN 'JES'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='MOU' OR LEFT(CreditAccNr.acc_nr,3 )='MOU')  THEN 'MOUA'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='MUT' OR LEFT(CreditAccNr.acc_nr,3 )='MUT')  THEN 'MUT'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='LAV' OR LEFT(CreditAccNr.acc_nr,3 )='LAV')  THEN 'LAV'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='JUB' OR LEFT(CreditAccNr.acc_nr,3 )='JUB')  THEN 'JUB'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='WET' OR LEFT(CreditAccNr.acc_nr,3 )='WET')  THEN 'WET'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='AGH' OR LEFT(CreditAccNr.acc_nr,3 )= 'AGH') THEN 'AGH'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='TRU' OR LEFT(CreditAccNr.acc_nr,3 )=  'TRU') THEN 'TRU'
			 WHEN (LEFT(DebitAccNr.acc_nr,3 )='CON' OR LEFT(CreditAccNr.acc_nr,3 )=  'CON') THEN 'CON'
                         WHEN (LEFT(DebitAccNr.acc_nr,3 )='CRU' OR LEFT(CreditAccNr.acc_nr,3 )=  'CRU') THEN 'CRU'
                         WHEN (LEFT(DebitAccNr.acc_nr,15 )= 'POS_FOODCONCEPT' OR LEFT(CreditAccNr.acc_nr,15 )='POS_FOODCONCEPT') THEN 'SCB'
			 WHEN ((LEFT(DebitAccNr.acc_nr,3 )= 'ISW' and CHARINDEX('POOL', DebitAccNr.acc_nr )<1) OR (LEFT(CreditAccNr.acc_nr,3 )=  'ISW' and CHARINDEX('POOL', CreditAccNr.acc_nr )<1 ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.tran_type ='01'  AND (LEFT(PT.Terminal_id,1) IN  ('0','1'))) 
                           AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '1'
                           AND PT.source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PT.source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PT.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and LEFT(PT.Terminal_id,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%')
                           and PT.tran_type ='00' and PT.source_node_name <> 'VTUsrc'  and PT.sink_node_name <> 'VTUsnk'
                           and LEFT(PT.Terminal_id,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                           WHEN (PT.tran_type ='01'  AND (LEFT(PT.Terminal_id,1) IN  ('0','1'))) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.sink_node_name = 'ESBCSOUTsnk'
                           THEN 'ATM WITHDRAWAL (CARDLESS)'


                           WHEN (PT.tran_type ='01'  AND (LEFT(PT.Terminal_id,1) IN  ('0','1'))) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.source_node_name <> 'SWTMEGAsrc'
                           AND PT.source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                           WHEN (PT.tran_type ='01'  AND (LEFT(PT.Terminal_id,1) IN  ('0','1'))) 

                           and (DebitAccNr.acc_nr LIKE '%V%BILLING%' OR CreditAccNr.acc_nr LIKE '%V%BILLING%')
                           AND PT.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.tran_type ='01'  AND (LEFT(PT.Terminal_id,1) IN  ('0','1'))) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PT.source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			   WHEN (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = '1' and 
                           (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) then 'BILLPAYMENT MASTERCARD BILLING'

                          
			   WHEN (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = '1') then 'BILLPAYMENT'
			   
			
                           WHEN (PT.tran_type ='40'  AND (LEFT(PT.Terminal_id,1) IN  ('0','1','4'))) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '1'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                            and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                            or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(EASYFUEL)PURCHASE'

                           WHEN  (dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')) THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '19'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '20'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '21'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '22'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '23'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'Verify card – Ecash load'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '24'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)= '25'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                           and LEFT(PT.Terminal_id,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE' )THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                           and LEFT(PT.Terminal_id,1) in ( '2','5','6') 
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2)
                           and LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and not (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE' or RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE') THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and LEFT(PT.Terminal_id,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 and 

                           LEFT(PT.Terminal_id,1) in ( '2','5','6') 
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2 and 

                           LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (pt.tran_type = '50' and 

                           LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (pt.tran_type = '50' and 

                           LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE' or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE')) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE' or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
                           and LEFT(PT.Terminal_id,1) in ( '2','5','6') 
                           and (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE' or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 and 

                           LEFT(PT.Terminal_id,1) in ( '2','5','6') 
                           and (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE' or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2 and 

                           LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE' or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                           and LEFT(PT.Terminal_id,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '313' 
                                 and ( CHARINDEX('fee', DebitAccNr.acc_nr )>0 OR CHARINDEX('fee', CreditAccNr.acc_nr )>0 )
                                 and (PT.tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PT.source_node_name) = 1))
                                 and not (CHARINDEX('PREPAIDLOAD', DebitAccNr.acc_nr )>0 or CHARINDEX('PREPAIDLOAD', CreditAccNr.acc_nr )>0)) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PT.source_node_name) = '313' 
                                 and (CHARINDEX('fee', DebitAccNr.acc_nr )<1 OR CHARINDEX('fee',CreditAccNr.acc_nr )<1)

                                 and PT.tran_type in ('50')
                                 and not (CHARINDEX('PREPAIDLOAD', DebitAccNr.acc_nr )>0 or CHARINDEX('PREPAIDLOAD', CreditAccNr.acc_nr )>0)) THEN 'AUTOPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '1' and PT.tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '2' and PT.tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '4' and PT.tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '35' and PT.tran_type = '50') then 'REMITA TRANSFERS'

       
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '31' and PT.tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,

                                  PT.extended_tran_type ,PT.source_node_name) = '32' and PT.tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '33' and PT.tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '34' and PT.tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '36' and PT.tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '37' and PT.tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '38' and PT.tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '39' and PT.tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '310' and PT.tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '311' and PT.tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '312'  and PT.tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '314'  and PT.tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '315' and PT.tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name) = '316' and PT.tran_type = '50') then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2)
                                 AND (DebitAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 2)
                                 AND (DebitAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PT.source_node_name ,PT.pan, PT.tran_type)= '1') then 'PREPAID CARDLOAD'

                          when pt.tran_type = '21' then 'DEPOSIT'

                           /*WHEN (LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  (LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE' or RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN  (LEFT(PT.Terminal_id,1) in ( '2','5','6')
                           and (DebitAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE' or CreditAccNr.acc_nr LIKE '%ISO_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'*/
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE 
                      /*WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)' */
                      
                      
                      WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '1')
                          and LEFT(PT.Terminal_id,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '2')
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '3') 

                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '4') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '5') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '6') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '7') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '8') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '10') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '9'
                          AND NOT ((DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE')OR (DebitAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (DebitAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (RIGHT(DebitAccNr.acc_nr,19)='PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (DebitAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (DebitAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (DebitAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
  
  
                     
                      /*WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan ) = 1
                     and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)' */
                                           
                          WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '1') 

                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '2') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '3') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '4') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '5') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '6') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '7') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '8') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PT.TERMINAL_ID) = '10') 
                          and LEFT(PT.Terminal_id,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PT.TERMINAL_ID)= '9'
                          AND NOT ((CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr.acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'
                         
                          WHEN (CreditAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (RIGHT(CreditAccNr.acc_nr,19) ='PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          
                          WHEN (CreditAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 
			  WHEN (CreditAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)'
			  WHEN (CreditAccNr.acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'

                          ELSE 'UNK'			
END,

        amt=SUM(ISNULL(J.amount,0)),
	fee=SUM(ISNULL(J.fee,0)),
	business_date=j.business_date,
        currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan) = '1' and 
                           (DebitAccNr.acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr.acc_nr like '%BILLPAYMENT MCARD%') ) THEN '840'
                        WHEN (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%') THEN '840'
          ELSE pt.settle_currency_code END,
        Late_Reversal_id = CASE
						WHEN ( dbo.fn_rpt_late_reversal(pt.post_tran_cust_id,pt.message_type,@rpt_tran_id1) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1)
                               and LEFT(PT.Terminal_id,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
        card_type =  dbo.fn_rpt_CardGroup(PT.pan),
        terminal_type = dbo.fn_rpt_terminal_type(PT.terminal_id),    
        source_node_name =   PT.source_node_name,
        Unique_key = pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+PT.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
        Acquirer = (case when ((  LEFT(DebitAccNr.acc_nr,3)  <> 'ISW' and  CHARINDEX( 'POOL', DebitAccNr.acc_nr) >0  ) OR  ( LEFT(CreditAccNr.acc_nr,3)<> 'ISW' and  CHARINDEX( 'POOL', CreditAccNr.acc_nr) >0  )) then ''
                      when (( LEFT(DebitAccNr.acc_nr ,3)= 'ISW' and CHARINDEX( 'POOL', DebitAccNr.acc_nr) <1  ) OR ( LEFT(CreditAccNr.acc_nr ,3)= 'ISW'   and CHARINDEX( 'POOL', CreditAccNr.acc_nr) <1  ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PT.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
        Issuer = (case when ((  LEFT(DebitAccNr.acc_nr,3)  <> 'ISW' and  CHARINDEX( 'POOL', DebitAccNr.acc_nr) >0  ) OR  ( LEFT(CreditAccNr.acc_nr,3)<> 'ISW' and  CHARINDEX( 'POOL', CreditAccNr.acc_nr) >0  )) then ''
                      when (( LEFT(DebitAccNr.acc_nr ,3)= 'ISW' and CHARINDEX( 'POOL', DebitAccNr.acc_nr) <1  ) OR ( LEFT(CreditAccNr.acc_nr ,3)= 'ISW'   and CHARINDEX( 'POOL', CreditAccNr.acc_nr) <1  ) )
					  and (LEFT(PT.totals_group,3) = acc.bank_code1) then acc.bank_code1
                      else LEFT(PT.totals_group,3) END)
                     

                        --currency = CASE WHEN (pt.settle_currency_code = '566') then 'Naira'
                        --WHEN (pt.settle_currency_code = '840') then 'US DOLLAR'
                        --ELSE  pt.settle_currency_code
                        --END

FROM  dbo.sstl_journal_all AS J (NOLOCK)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS CreditAccNr  (NOLOCK)
ON (J.credit_acc_nr_id = CreditAccNr.acc_nr_id AND J.config_set_id = CreditAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_amount_w AS Amount  (NOLOCK)
ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)
RIGHT OUTER JOIN dbo.post_tran_leg_internal AS PT (NOLOCK)
ON (J.post_tran_id = PT.post_tran_id AND J.post_tran_cust_id = PT.post_tran_cust_id)
left join post_tran_leg_internal ptt (nolock) 
on (pt.post_tran_cust_id = ptt.post_tran_cust_id and ptt.tran_postilion_originated = 1
    and pt.tran_nr = ptt.tran_nr)
LEFT OUTER JOIN aid_cbn_code acc ON
(acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code)

WHERE 

      PT.tran_postilion_originated = 0
     	 AND PT.post_tran_id >=@first_post_tran_id 
          AND
     PT.recon_business_date >= @from_date 
     AND PT.post_tran_id<=@last_post_tran_id
     and PT.recon_business_date <= @to_date 
      AND PT.rsp_code_rsp in ('00','11','09')
      
      AND (
          (PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220'))

       or ((PT.settle_amount_impact<> 0 and PT.message_type = '0420' 

       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) <> 1 and PT.tran_reversed <> 2)
       or (PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1 ))

       or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1)= '1' or LEFT(PT.Terminal_id,1)= '0'))
       or (PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (LEFT(PT.Terminal_id,1)= '1' or LEFT(PT.Terminal_id,1)= '0')))
      
  

      AND
	  not (PT.merchant_type in ('4004','4722') and pt.tran_type = '00' and PT.source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(pt.settle_amount_impact/100)< 200
       and not (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%'))

      AND not (PT.merchant_type in ('5371') and pt.tran_type = '00' and 

                (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) <> 2) 
               and not (DebitAccNr.acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr.acc_nr LIKE '%MCARD%BILLING%'))
      AND PT.post_tran_cust_id >= @rpt_tran_id
      AND PT.totals_group not in ('CUPGroup','VISAGroup')
      AND
             LEFT(PT.source_node_name,2)  <> 'SB'
             AND
             LEFT(pt.sink_node_name,2)  <> 'SB'

      and ( CHARINDEX('TPP',PT.source_node_name )<1 )
       and (CHARINDEX('TPP',PT.sink_node_name )<1 )
       and  (PT.source_node_name  <> 'MEGATPPsrc' and pt.tran_type <> '00')
      --and source_node_name not in ('SWTWMASBsrc','SWTWEMSBsrc')
      and PT.source_node_name <> 'SWTMEGADSsrc'
      --and not (PT.tran_type in ('01','09') or (PT.tran_type = '00' and 
      --dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan) = 1
      --and (dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)in ('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15'
                                                                             -- ,'16','17','18','19','20','21','22','23') 
      --or dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type)is null))
      --and(pt.datetime_req > '2015-08-05 09:20:00.000' and pt.datetime_req < '2015-08-05 10:40:00.000'))

GROUP BY 

 j.business_date,
 DebitAccNr.acc_nr,
 CreditAccNr.acc_nr,
 PT.tran_type,

 dbo.fn_rpt_MCC (PT.merchant_type,PT.terminal_id,PT.tran_type),
 dbo.fn_rpt_MCC_Visa (PT.merchant_type,PT.terminal_id,PT.tran_type,PT.PAN),pt.acquiring_inst_id_code,

 PT.totals_group, LEFT(PT.Terminal_id,1),
 dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan),
dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.tran_type, PT.source_node_name, PT.sink_node_name, PT.terminal_id ,PT.totals_group ,PT.pan),
dbo.fn_rpt_transfers_sett(PT.terminal_id,PT.payee,PT.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PT.source_node_name),
dbo.fn_rpt_isBillpayment (PT.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,PT.card_acceptor_id_code ,PT.source_node_name,pt.tran_type,PT.pan),
dbo.fn_rpt_isCardload (PT.source_node_name ,PT.pan, PT.tran_type),
dbo.fn_rpt_CardType (PT.pan ,PT.sink_node_name ,PT.tran_type,PT.TERMINAL_ID),
dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PT.source_node_name),
PTT.Retention_data,
pt.settle_currency_code,
PT.source_node_name,
PT.sink_node_name,
dbo.fn_rpt_late_reversal(pt.post_tran_cust_id,pt.message_type,@rpt_tran_id1),
dbo.fn_rpt_CardGroup(PT.pan), dbo.fn_rpt_terminal_type(PT.terminal_id),
pt.retrieval_reference_nr+'_'+pt.system_trace_audit_nr+'_'+PT.terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(pt.settle_amount_impact,0))) as VARCHAR(20))+'_'+pt.message_type,
dbo.fn_rpt_MCC_cashback (PT.terminal_id, PT.tran_type),
(case when ((  LEFT(DebitAccNr.acc_nr,3)  <> 'ISW' and  CHARINDEX( 'POOL', DebitAccNr.acc_nr) >0  ) OR  ( LEFT(CreditAccNr.acc_nr,3)<> 'ISW' and  CHARINDEX( 'POOL', CreditAccNr.acc_nr) >0  )) then ''
                      when (( LEFT(DebitAccNr.acc_nr ,3)= 'ISW' and CHARINDEX( 'POOL', DebitAccNr.acc_nr) <1  ) OR ( LEFT(CreditAccNr.acc_nr ,3)= 'ISW'   and CHARINDEX( 'POOL', CreditAccNr.acc_nr) <1  ) ) AND (acc.acquirer_inst_id1 = PT.acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.acquiring_inst_id_code or acc.acquirer_inst_id4 = PT.acquiring_inst_id_code or acc.acquirer_inst_id5 = PT.acquiring_inst_id_code) then acc.bank_code --or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code1 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code2 or SUBSTRING(PT.terminal_id,2,3)= acc.cbn_code3 or SUBSTRING(PT.terminal_id,2,3) = acc.cbn_code4) THEN acc.bank_code
                      else PT.acquiring_inst_id_code END),
(case when ((  LEFT(DebitAccNr.acc_nr,3)  <> 'ISW' and  CHARINDEX( 'POOL', DebitAccNr.acc_nr) >0  ) OR  ( LEFT(CreditAccNr.acc_nr,3)<> 'ISW' and  CHARINDEX( 'POOL', CreditAccNr.acc_nr) >0  )) then ''
                      when (( LEFT(DebitAccNr.acc_nr ,3)= 'ISW' and CHARINDEX( 'POOL', DebitAccNr.acc_nr) <1  ) OR ( LEFT(CreditAccNr.acc_nr ,3)= 'ISW'   and CHARINDEX( 'POOL', CreditAccNr.acc_nr) <1  ) )
					  and (LEFT(PT.totals_group,3) = acc.bank_code1) then acc.bank_code1
                      else LEFT(PT.totals_group,3) END),
acc.bank_code1, acc.bank_code, PT.acquiring_inst_id_code
OPTION (RECOMPILE, MAXDOP 16)
create table #temp_table
(unique_key varchar(200))

insert into #temp_table 
select unique_key from #report_result where source_node_name in ('SWTASPPOSsrc','SWTASGTVLsrc')


insert into settlement_summary_breakdown	
(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer)	
	SELECT 
			bank_code,trxn_category,Debit_Account_type,Credit_Account_type,sum(trxn_amount),sum(trxn_fee),trxn_date, Currency,late_reversal,card_type,terminal_type, Acquirer, Issuer 
	FROM 
			#report_result 
where     not(source_node_name in ('SWTNCS2src','SWTSHOPRTsrc','SWTNCSKIMsrc','SWTNCSKI2src') 
          and unique_key  IN (SELECT unique_key FROM #temp_table))
          

GROUP BY bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_date,Currency,late_reversal,card_type,terminal_type,Acquirer, Issuer
OPTION (RECOMPILE, MAXDOP 16)
END  


































































































































































































































































































