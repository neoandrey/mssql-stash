USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown]    Script Date: 01/17/2014 17:05:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



ALTER                                                                                                 PROCEDURE [dbo].[psp_settlement_summary_breakdown](
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
SET @from_date = ISNULL(@start_date,CONVERT(VARCHAR(10),DATEADD(DAY, -1, GETDATE())))
SET @to_date   = ISNULL(@end_date, CONVERT(VARCHAR(10),GETDATE(),105))


DECLARE @new_date   DATETIME 
DECLARE @number_of_days   INT 
DECLARE @day_counter   INT  
DECLARE @temp_date_store TABLE (REPORT_DATE DATETIME) 

SELECT @number_of_days = DATEDIFF(d, @from_date, @to_date) ;
set @day_counter=0 ;
SET @new_date = @from_date; 

       
WHILE (@day_counter <=@number_of_days) 
        BEGIN 
                
                SELECT @new_date = CONVERT( VARCHAR(40), @new_date,100); 
                INSERT INTO @temp_date_store VALUES(@new_date); 
                SELECT @new_date = DATEADD(d,1, @new_date); 
                
        SET @day_counter =@day_counter+1 
        
        END 
     INSERT  INTO settlement_summary_session   SELECT * FROM @temp_date_store 


          
IF(@@ERROR <>0)
RETURN


EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 
EXEC psp_get_rpt_post_tran_cust_id_NIBSS @from_date,@to_date,@rpt_tran_id1 OUTPUT 


INSERT INTO settlement_summary_breakdown
   (bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal)
SELECT		         
	bank_code = CASE 
                         WHEN (DebitAccNr.acc_nr LIKE 'UBA%' OR CreditAccNr.acc_nr LIKE 'UBA%') THEN 'UBA'
			 WHEN (DebitAccNr.acc_nr LIKE 'FBN%' OR CreditAccNr.acc_nr LIKE 'FBN%') THEN 'FBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ZIB%' OR CreditAccNr.acc_nr LIKE 'ZIB%') THEN 'ZIB' 
                         WHEN (DebitAccNr.acc_nr LIKE 'SPR%' OR CreditAccNr.acc_nr LIKE 'SPR%') THEN 'ENT'
                         WHEN (DebitAccNr.acc_nr LIKE 'GTB%' OR CreditAccNr.acc_nr LIKE 'GTB%') THEN 'GTB'
                         WHEN (DebitAccNr.acc_nr LIKE 'PRU%' OR CreditAccNr.acc_nr LIKE 'PRU%') THEN 'SKYE'
                         WHEN (DebitAccNr.acc_nr LIKE 'OBI%' OR CreditAccNr.acc_nr LIKE 'OBI%') THEN 'EBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'WEM%' OR CreditAccNr.acc_nr LIKE 'WEM%') THEN 'WEMA'
                         WHEN (DebitAccNr.acc_nr LIKE 'AFR%' OR CreditAccNr.acc_nr LIKE 'AFR%') THEN 'MSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBTC%' OR CreditAccNr.acc_nr LIKE 'IBTC%') THEN 'IBTC'
                         WHEN (DebitAccNr.acc_nr LIKE 'PLAT%' OR CreditAccNr.acc_nr LIKE 'PLAT%') THEN 'KSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBP%' OR CreditAccNr.acc_nr LIKE 'UBP%') THEN 'UBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'DBL%' OR CreditAccNr.acc_nr LIKE 'DBL%') THEN 'DBL'
                         WHEN (DebitAccNr.acc_nr LIKE 'FCMB%' OR CreditAccNr.acc_nr LIKE 'FCMB%') THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBP%' OR CreditAccNr.acc_nr LIKE 'IBP%') THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBN%' OR CreditAccNr.acc_nr LIKE 'UBN%') THEN 'UBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ETB%' OR CreditAccNr.acc_nr LIKE 'ETB%') THEN 'ETB'
                         WHEN (DebitAccNr.acc_nr LIKE 'FBP%' OR CreditAccNr.acc_nr LIKE 'FBP%') THEN 'FBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'SBP%' OR CreditAccNr.acc_nr LIKE 'SBP%') THEN 'SBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABP%' OR CreditAccNr.acc_nr LIKE 'ABP%') THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'EBN%' OR CreditAccNr.acc_nr LIKE 'EBN%') THEN 'EBN'

                         WHEN (DebitAccNr.acc_nr LIKE 'CITI%' OR CreditAccNr.acc_nr LIKE 'CITI%') THEN 'CITI'
                         WHEN (DebitAccNr.acc_nr LIKE 'FIN%' OR CreditAccNr.acc_nr LIKE 'FIN%') THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'ASO%' OR CreditAccNr.acc_nr LIKE 'ASO%') THEN 'ASO'
                         WHEN (DebitAccNr.acc_nr LIKE 'OLI%' OR CreditAccNr.acc_nr LIKE 'OLI%') THEN 'OLI'
                         WHEN (DebitAccNr.acc_nr LIKE 'HSL%' OR CreditAccNr.acc_nr LIKE 'HSL%') THEN 'HSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABS%' OR CreditAccNr.acc_nr LIKE 'ABS%') THEN 'ABS'
                         WHEN (DebitAccNr.acc_nr LIKE 'PAY%' OR CreditAccNr.acc_nr LIKE 'PAY%') THEN 'PAY'
                         WHEN (DebitAccNr.acc_nr LIKE 'SAT%' OR CreditAccNr.acc_nr LIKE 'SAT%') THEN 'SAT'
                         WHEN (DebitAccNr.acc_nr LIKE '3LCM%' OR CreditAccNr.acc_nr LIKE '3LCM%') THEN '3LCM'
                         WHEN (DebitAccNr.acc_nr LIKE 'SCB%' OR CreditAccNr.acc_nr LIKE 'SCB%') THEN 'SCB'
                         WHEN (DebitAccNr.acc_nr LIKE 'JBP%' OR CreditAccNr.acc_nr LIKE 'JBP%') THEN 'JBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'RSL%' OR CreditAccNr.acc_nr LIKE 'RSL%') THEN 'RSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'PSH%' OR CreditAccNr.acc_nr LIKE 'PSH%') THEN 'PSH'
                         WHEN (DebitAccNr.acc_nr LIKE 'INF%' OR CreditAccNr.acc_nr LIKE 'INF%') THEN 'INF'
                         WHEN (DebitAccNr.acc_nr LIKE 'UML%' OR CreditAccNr.acc_nr LIKE 'UML%') THEN 'UML'

                         WHEN (DebitAccNr.acc_nr LIKE 'ACCI%' OR CreditAccNr.acc_nr LIKE 'ACCI%') THEN 'ACCI'
                         WHEN (DebitAccNr.acc_nr LIKE 'EKON%' OR CreditAccNr.acc_nr LIKE 'EKON%') THEN 'EKON'
                         WHEN (DebitAccNr.acc_nr LIKE 'ATMC%' OR CreditAccNr.acc_nr LIKE 'ATMC%') THEN 'ATMC'
                         WHEN (DebitAccNr.acc_nr LIKE 'HBC%' OR CreditAccNr.acc_nr LIKE 'HBC%') THEN 'HBC'
			 WHEN (DebitAccNr.acc_nr LIKE 'UNI%' OR CreditAccNr.acc_nr LIKE 'UNI%') THEN 'UNI'
                         WHEN (DebitAccNr.acc_nr LIKE 'UNC%' OR CreditAccNr.acc_nr LIKE 'UNC%') THEN 'UNC'
                         WHEN (DebitAccNr.acc_nr LIKE 'NCS%' OR CreditAccNr.acc_nr LIKE 'NCS%') THEN 'NCS' 
                         WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCEPT%' OR CreditAccNr.acc_nr LIKE 'POS_FOODCONCEPT%') THEN 'SCB'
                         WHEN (DebitAccNr.acc_nr LIKE 'ISW%' OR CreditAccNr.acc_nr LIKE 'ISW%') THEN 'ISW'
                         WHEN PT.Retention_data = '1061' and (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
				OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
				OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'GTB'
			 WHEN PT.Retention_data = '1028' and 
				(DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
				OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
				OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'FBN'
			 WHEN PT.Retention_data = '1027' and 
				(DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
				OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
				OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'SKYE'
			 WHEN PT.Retention_data = '1037' and 
				(DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
				OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
				OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'IBTC'
			 WHEN PT.Retention_data = '1034' and 
				(DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
				OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
				OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'EBN'
			 WHEN PT.Retention_data = '1006' and 
				(DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
				OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
				OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'DBL'
                          
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '1'
                           AND PTC.source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'


                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%' and CreditAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                           WHEN (PT.tran_type ='01'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr LIKE '%V%BILLING%' OR CreditAccNr.acc_nr LIKE '%V%BILLING%')
                           AND PTC.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'
			   
                           WHEN (PT.tran_type ='40'  AND (SUBSTRING(PTC.Terminal_id,1,1)= '1' 
                           or SUBSTRING(PTC.Terminal_id,1,1)= '0' or SUBSTRING(PTC.Terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '4'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '5'

                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '6'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '14'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '7'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '8'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'POS(EASYFUEL)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') THEN 'POS(GENERAL MERCHANT)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1)
                           and SUBSTRING(PTC.Terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr LIKE '%fee%' OR CreditAccNr.acc_nr LIKE '%fee%')
                                 and (PT.tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name) = 1))) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr NOT LIKE '%fee%' OR CreditAccNr.acc_nr NOT LIKE '%fee%')
                                 and PT.tran_type in ('50')) THEN 'AUTOPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '1' and PT.tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '2' and PT.tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '4' and PT.tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '35' and PT.tran_type = '50') then 'REMITA TRANSFERS'
       
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '31' and PT.tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '32' and PT.tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '33' and PT.tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '34' and PT.tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '36' and PT.tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '37' and PT.tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '38' and PT.tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '39' and PT.tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '310' and PT.tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '311' and PT.tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '312'  and PT.tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '314'  and PT.tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name) = '315' and PT.tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 2)
                                 AND (DebitAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 2)
                                 AND (DebitAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net

                           WHEN (dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name) = '1' and  PT.tran_type = '50') then 'BILLPAYMENT'

                          WHEN (dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type)= '1') then 'PREPAID CARDLOAD'

                          when tran_type = '21' then 'DEPOSIT'
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT ((DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (DebitAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
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
                          WHEN (DebitAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'                          

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE                       
                          WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (CreditAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '2') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '3') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '4') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '5') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '6') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '7') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '8') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME,PT.TRAN_TYPE,PTC.TERMINAL_ID) = '10') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PTC.PAN ,PT.SINK_NODE_NAME ,PT.TRAN_TYPE,PTC.TERMINAL_ID)= '9'
                          AND NOT ((CreditAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
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
                          WHEN (CreditAccNr.acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 

                          ELSE 'UNK'			
END,

        amt=SUM(ISNULL(J.amount,0)),
	fee=SUM(ISNULL(J.fee,0)),
	j.business_date,
        pt.settle_currency_code,
        Late_Reversal_id = CASE
						WHEN ( dbo.fn_rpt_late_reversal(pt.post_tran_cust_id,pt.message_type,@rpt_tran_id1) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1)
                               and SUBSTRING(PTC.Terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END

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
RIGHT OUTER JOIN dbo.post_tran AS PT (NOLOCK)
ON (J.post_tran_id = PT.post_tran_id AND J.post_tran_cust_id = PT.post_tran_cust_id)
RIGHT OUTER JOIN dbo.post_tran_cust AS PTC (NOLOCK)
ON (J.post_tran_cust_id = PTC.post_tran_cust_id AND J.post_tran_cust_id = PTC.post_tran_cust_id)

WHERE 

      PT.tran_postilion_originated = 0
     
      AND PT.rsp_code_rsp in ('00','11','09')
      
      AND (
          (PT.settle_amount_impact<> 0 and PT.message_type   in ('0200','0220'))

       or ((PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) <> 1 and PT.tran_reversed <> 2)
       or (PT.settle_amount_impact<> 0 and PT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) = 1 ))

       or (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0'))
       or (PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 and (SUBSTRING(PTC.Terminal_id,1,1)= '1' or SUBSTRING(PTC.Terminal_id,1,1)= '0')))
      
      AND (PT.recon_business_date >= @from_date AND PT.recon_business_date < (@to_date))

      AND not (merchant_type in ('4004','4722') and tran_type = '00' and source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(settle_amount_impact/100)< 200)

      AND not (merchant_type in ('5371') and pt.tran_type = '00' and 
                (dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name) <> 2) 
               )
      AND PTC.post_tran_cust_id >= @rpt_tran_id
      AND PTC.totals_group not in ('CUPGroup','VISAGroup')
      AND
             ptc.source_node_name  NOT LIKE 'SB%'
             AND
             pt.sink_node_name  NOT LIKE 'SB%'
      --and source_node_name not in ('SWTWMASBsrc','SWTWEMSBsrc')

GROUP BY 
j.business_date,
 DebitAccNr.acc_nr,
 CreditAccNr.acc_nr,
 PT.tran_type,
PT.Retention_data,
pt.settle_currency_code,
PTC.source_node_name,
PTC.Terminal_id,
PTC.merchant_type,
PTC.pan ,
PTC.source_node_name, 
PT.sink_node_name,
PTC.terminal_id,
PT.payee,PTC.card_acceptor_name_loc,
extended_tran_type,
PT.message_type,
ptc.card_acceptor_id_code,
pt.post_tran_cust_id
 /*    
GROUP BY 
 j.business_date,
 DebitAccNr.acc_nr,
 CreditAccNr.acc_nr,
 PT.tran_type,
 dbo.fn_rpt_MCC (PTC.merchant_type,PTC.terminal_id),
 SUBSTRING(PTC.Terminal_id,1,1),
 dbo.fn_rpt_isPurchaseTrx_sett(PT.tran_type, PTC.source_node_name, PT.sink_node_name),
dbo.fn_rpt_transfers_sett(PTC.terminal_id,PT.payee,PTC.card_acceptor_name_loc,
                                  PT.extended_tran_type ,PTC.source_node_name),
dbo.fn_rpt_isBillpayment (PTC.terminal_id,PT.extended_tran_type,PT.message_type,PT.sink_node_name,PT.payee,ptc.card_acceptor_id_code ,ptc.source_node_name),
dbo.fn_rpt_isCardload (PTC.source_node_name ,PTC.pan, PT.tran_type),
dbo.fn_rpt_CardType (PTC.pan ,PT.sink_node_name ,PT.tran_type,PTC.TERMINAL_ID),
dbo.fn_rpt_autopay_intra_sett (PT.tran_type,PTC.source_node_name),
PT.Retention_data,
pt.settle_currency_code,
PTC.source_node_name,
dbo.fn_rpt_late_reversal(pt.post_tran_cust_id,pt.message_type,@rpt_tran_id1)

*/
END  






























































































































































