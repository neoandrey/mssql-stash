USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown]    Script Date: 01/24/2014 07:57:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

ALTER      PROCEDURE [dbo].[psp_settlement_summary_breakdown](
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
DECLARE  @number_of_days DATETIME
DECLARE @day_counter INT
DECLARE @new_date DATETIME

SET @from_date = ISNULL(@start_date,dbo.DateOnly(DATEADD(DAY, -1, getdate())))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()))

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

/*
INSERT INTO settlement_summary_session
       SELECT (cast (J.business_date as varchar(40)))
       FROM   dbo.sstl_journal_all AS J (NOLOCK), post_tran AS TPT (NOLOCK),post_tran_cust as TTPT (NOLOCK)
        where TPT.rsp_code_rsp in ('00','11','09')
              AND  TPT.tran_postilion_originated = 0
     
              AND (TPT.settle_amount_impact<> 0 and TPT.message_type   in ('0200','0220')
              or (TPT.settle_amount_impact<> 0 and TPT.message_type = '0420' and TPT.tran_reversed <> 2 )
              or (TPT.settle_amount_rsp<> 0 and TPT.message_type   in ('0200','0220') and TPT.tran_type = 40 and (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0'))
              or (TPT.settle_amount_rsp<> 0 and TPT.message_type = '0420' and TPT.tran_reversed <> 2 and TPT.tran_type = 40 and (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0')) )
              AND (J.business_date >= @from_date AND J.business_date < (@to_date+1))
             

	Group by J.business_date
	
	*/
          
IF(@@ERROR <>0)
RETURN

EXEC psp_get_rpt_post_tran_cust_id @from_date,@to_date,@rpt_tran_id OUTPUT 

EXEC psp_get_rpt_post_tran_cust_id_NIBSS @from_date,@to_date,@rpt_tran_id1 OUTPUT 

SELECT  post_tran_id,post_tran_cust_id,settle_entity_id,batch_nr,prev_post_tran_id,next_post_tran_id,sink_node_name,tran_postilion_originated,tran_completed,message_type,tran_type,tran_nr,system_trace_audit_nr,rsp_code_req,rsp_code_rsp,abort_rsp_code,auth_id_rsp,auth_type,auth_reason,retention_data,acquiring_inst_id_code,message_reason_code,sponsor_bank,retrieval_reference_nr,datetime_tran_gmt,datetime_tran_local,datetime_req,datetime_rsp,realtime_business_date,recon_business_date,from_account_type,to_account_type,from_account_id,to_account_id,tran_amount_req,tran_amount_rsp,settle_amount_impact,tran_cash_req,tran_cash_rsp,tran_currency_code,tran_tran_fee_req,tran_tran_fee_rsp,tran_tran_fee_currency_code,tran_proc_fee_req,tran_proc_fee_rsp,tran_proc_fee_currency_code,settle_amount_req,settle_amount_rsp,settle_cash_req,settle_cash_rsp,settle_tran_fee_req,settle_tran_fee_rsp,settle_proc_fee_req,settle_proc_fee_rsp,settle_currency_code,icc_data_req,icc_data_rsp,pos_entry_mode,pos_condition_code,additional_rsp_data,structured_data_req,structured_data_rsp,tran_reversed,prev_tran_approved,issuer_network_id,acquirer_network_id,extended_tran_type,ucaf_data,from_account_type_qualifier,to_account_type_qualifier,bank_details,payee,card_verification_result,online_system_id,participant_id,receiving_inst_id_code,routing_type,pt_pos_operating_environment,pt_pos_card_input_mode,pt_pos_cardholder_auth_method,pt_pos_pin_capture_ability,pt_pos_terminal_operator INTO #TEMP_POST_TRAN FROM post_tran (NOLOCK) WHERE datetime_req BETWEEN @from_date AND @to_date;

SELECT post_tran_cust_id,source_node_name,draft_caTPTure,pan,card_seq_nr,expiry_date,service_restriction_code,terminal_id,terminal_owner,card_acceptor_id_code,mapped_card_acceptor_id_code,merchant_type,card_acceptor_name_loc,address_verification_data,address_verification_result,check_data,totals_group,card_product,pos_card_data_input_ability,pos_cardholder_auth_ability,pos_card_caTPTure_ability,pos_operating_environment,pos_cardholder_present,pos_card_present,pos_card_data_input_mode,pos_cardholder_auth_method,pos_cardholder_auth_entity,pos_card_data_output_ability,pos_terminal_output_ability,pos_pin_caTPTure_ability,pos_terminal_operator,pos_terminal_type,pan_search,pan_encryTPTed,pan_reference INTO #TEMP_POST_TRAN_CUST FROM post_tran_cust (NOLOCK) WHERE post_tran_cust_id IN (SELECT post_tran_cust_id FROM #TEMP_POST_TRAN );

SELECT  post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_caTPTure ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encryTPTed ,pan_reference ,pan_search ,pos_card_caTPTure_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_caTPTure_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id INTO #TEMP_TRANSACTIONS FROM #TEMP_POST_TRAN trans (NOLOCK) LEFT JOIN #TEMP_POST_TRAN_CUST cust (NOLOCK) ON trans.post_tran_cust_id = cust.post_tran_cust_id

INSERT INTO settlement_summary_breakdown
   (bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date, Currency,late_reversal)
SELECT		         
	bank_code = CASE WHEN TTPT.Retention_data = '1061' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' 
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' 
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' ) THEN 'GTB'
                          WHEN TTPT.Retention_data = '1708' and  (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' ) THEN 'FBN'
                         WHEN TTPT.Retention_data in ('1027','1045') and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' 
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'SKYE'
                         WHEN TTPT.Retention_data = '1037' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' 
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' 
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'IBTC'
                         WHEN TTPT.Retention_data = '1034' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' 
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE' ) THEN 'EBN'
                          WHEN TTPT.Retention_data = '1006' and 
                         (DebitAccNr.acc_nr LIKE '%ISSUER_FEE_PAYABLE' 
                          OR DebitAccNr.acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' 
                          OR DebitAccNr.acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'DBL'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBA%' ) THEN 'UBA'
			 WHEN (DebitAccNr.acc_nr LIKE 'FBN%' ) THEN 'FBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ZIB%' ) THEN 'ZIB' 
                         WHEN (DebitAccNr.acc_nr LIKE 'SPR%' ) THEN 'ENT'
                         WHEN (DebitAccNr.acc_nr LIKE 'GTB%' ) THEN 'GTB'
                         WHEN (DebitAccNr.acc_nr LIKE 'PRU%') THEN 'SKYE'
                         WHEN (DebitAccNr.acc_nr LIKE 'OBI%' ) THEN 'EBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'WEM%' ) THEN 'WEMA'
                         WHEN (DebitAccNr.acc_nr LIKE 'AFR%' ) THEN 'MSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBTC%' ) THEN 'IBTC'
                         WHEN (DebitAccNr.acc_nr LIKE 'PLAT%' ) THEN 'KSB'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBP%' ) THEN 'UBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'DBL%' ) THEN 'DBL'
                         WHEN (DebitAccNr.acc_nr LIKE 'FCMB%' ) THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'IBP%' ) THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'UBN%') THEN 'UBN'
                         WHEN (DebitAccNr.acc_nr LIKE 'ETB%') THEN 'ETB'
                         WHEN (DebitAccNr.acc_nr LIKE 'FBP%' ) THEN 'FBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'SBP%' ) THEN 'SBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABP%') THEN 'ABP'
                         WHEN (DebitAccNr.acc_nr LIKE 'EBN%' ) THEN 'EBN'

                         WHEN (DebitAccNr.acc_nr LIKE 'CITI%') THEN 'CITI'
                         WHEN (DebitAccNr.acc_nr LIKE 'FIN%') THEN 'FCMB'
                         WHEN (DebitAccNr.acc_nr LIKE 'ASO%') THEN 'ASO'
                         WHEN (DebitAccNr.acc_nr LIKE 'OLI%') THEN 'OLI'
                         WHEN (DebitAccNr.acc_nr LIKE 'HSL%') THEN 'HSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'ABS%' ) THEN 'ABS'
                         WHEN (DebitAccNr.acc_nr LIKE 'PAY%' ) THEN 'PAY'
                         WHEN (DebitAccNr.acc_nr LIKE 'SAT%' ) THEN 'SAT'
                         WHEN (DebitAccNr.acc_nr LIKE '3LCM%') THEN '3LCM'
                         WHEN (DebitAccNr.acc_nr LIKE 'SCB%' ) THEN 'SCB'
                         WHEN (DebitAccNr.acc_nr LIKE 'JBP%' ) THEN 'JBP'
                         WHEN (DebitAccNr.acc_nr LIKE 'RSL%' ) THEN 'RSL'
                         WHEN (DebitAccNr.acc_nr LIKE 'PSH%' ) THEN 'PSH'
                         WHEN (DebitAccNr.acc_nr LIKE 'INF%' ) THEN 'INF'
                         WHEN (DebitAccNr.acc_nr LIKE 'UML%' ) THEN 'UML'

                         WHEN (DebitAccNr.acc_nr LIKE 'ACCI%') THEN 'ACCI'
                         WHEN (DebitAccNr.acc_nr LIKE 'EKON%') THEN 'EKON'
                         WHEN (DebitAccNr.acc_nr LIKE 'ATMC%') THEN 'ATMC'
                         WHEN (DebitAccNr.acc_nr LIKE 'HBC%') THEN 'HBC'
			             WHEN (DebitAccNr.acc_nr LIKE 'UNI%') THEN 'UNI'
                         WHEN (DebitAccNr.acc_nr LIKE 'UNC%') THEN 'UNC'
                         WHEN (DebitAccNr.acc_nr LIKE 'NCS%') THEN 'NCS' 
                         WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCETPT%') THEN 'SCB'
                         WHEN (DebitAccNr.acc_nr LIKE 'ISW%')  THEN 'ISW'
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (TPT.tran_type ='01'  AND (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0')) 
                           AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME,TPT.TRAN_TYPE,TTPT.TERMINAL_ID) = '1'
                           AND TTPT.source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'

                           WHEN (TPT.tran_type ='01'  AND (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND TPT.sink_node_name = 'ESBCSOUTsnk'
                           THEN 'ATM WITHDRAWAL (CARDLESS)'


                           WHEN (TPT.tran_type ='01'  AND (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr not LIKE '%V%BILLING%')
                           AND TTPT.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                           WHEN (TPT.tran_type ='01'  AND (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0')) 
                           and (DebitAccNr.acc_nr LIKE '%V%BILLING%')
                           AND TTPT.source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'
			   
                           WHEN (TPT.tran_type ='40'  AND (SUBSTRING(TTPT.Terminal_id,1,1)= '1' 
                           or SUBSTRING(TTPT.Terminal_id,1,1)= '0' or SUBSTRING(TTPT.Terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '4'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '5'

                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '6'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '14'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '7'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '8'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'POS(EASYFUEL)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1)
                           and SUBSTRING(TTPT.Terminal_id,1,1) in ( '2','5','6') THEN 'POS(GENERAL MERCHANT)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1)
                           and SUBSTRING(TTPT.Terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr LIKE '%fee%' OR DebitAccNr.acc_nr LIKE '%fee%')
                                 and (TPT.tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (TPT.tran_type,TTPT.source_node_name) = 1))) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '313' 
                                 and (DebitAccNr.acc_nr NOT LIKE '%fee%' OR DebitAccNr.acc_nr NOT LIKE '%fee%')
                                 and TPT.tran_type in ('50')) THEN 'AUTOPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '1' and TPT.tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '2' and TPT.tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '4' and TPT.tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '35' and TPT.tran_type = '50') then 'REMITA TRANSFERS'
       
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '31' and TPT.tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '32' and TPT.tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '33' and TPT.tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '34' and TPT.tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '36' and TPT.tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '37' and TPT.tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '38' and TPT.tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '39' and TPT.tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '310' and TPT.tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '311' and TPT.tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '312'  and TPT.tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '314'  and TPT.tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
                                  TPT.extended_tran_type ,TTPT.source_node_name) = '315' and TPT.tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 2)
                                 AND (DebitAccNr.acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' ) then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 2)
                                 AND (DebitAccNr.acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excemTPTed from the bank's net

                           WHEN (dbo.fn_rpt_isBillpayment (TTPT.terminal_id,TPT.extended_tran_type,TPT.message_type,TPT.sink_node_name,TPT.payee,TTPT.card_acceptor_id_code ,TTPT.source_node_name) = '1' and  TPT.tran_type = '50') then 'BILLPAYMENT'

                          WHEN (dbo.fn_rpt_isCardload (TTPT.source_node_name ,TTPT.pan, TPT.tran_type)= '1') then 'PREPAID CARDLOAD'

                          when TPT.tran_type = '21' then 'DEPOSIT'
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME,TPT.TRAN_TYPE,TTPT.TERMINAL_ID) = '2') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '3') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '4') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '5') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '6') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '7') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '8') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME,TPT.TRAN_TYPE,TTPT.TERMINAL_ID) = '10') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '9'
                          AND NOT ((DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%TPTSP_FEE_RECEIVABLE')OR (DebitAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCETPT%')THEN 'FOODCONCETPT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
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
                          WHEN (DebitAccNr.acc_nr LIKE '%TPTSP_FEE_RECEIVABLE') THEN 'TPTSP FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'                          

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE                       
                          WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (DebitAccNr.acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME,TPT.TRAN_TYPE,TTPT.TERMINAL_ID) = '2') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '3') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '4') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '5') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '6') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '7') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '8') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME,TPT.TRAN_TYPE,TTPT.TERMINAL_ID) = '10') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (DebitAccNr.acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (TTPT.PAN ,TPT.SINK_NODE_NAME ,TPT.TRAN_TYPE,TTPT.TERMINAL_ID)= '9'
                          AND NOT ((DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%TPTSP_FEE_RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr.acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE 'POS_FOODCONCETPT%')THEN 'FOODCONCETPT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (DebitAccNr.acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (DebitAccNr.acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'
                         
                          WHEN (DebitAccNr.acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%TPTSP_FEE_RECEIVABLE') THEN 'TPTSP FEE RECEIVABLE(Credit_Nr)'
                          WHEN (DebitAccNr.acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 

                          ELSE 'UNK'			
END,

        amt=SUM(ISNULL(J.amount,0)),
	fee=SUM(ISNULL(J.fee,0)),
	business_date=j.business_date,
        TPT.settle_currency_code,
        Late_Reversal_id = CASE
						WHEN ( dbo.fn_rpt_late_reversal(TPT.post_tran_cust_id,TPT.message_type,@rpt_tran_id1) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1)
                               and SUBSTRING(TTPT.Terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END

                        --currency = CASE WHEN (TPT.settle_currency_code = '566') then 'Naira'
                        --WHEN (TPT.settle_currency_code = '840') then 'US DOLLAR'
                        --ELSE  TPT.settle_currency_code
                        --END

FROM  dbo.sstl_journal_all AS J (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_TRANSACTIONS AS TPT (NOLOCK)
ON (J.post_tran_cust_id = TTPT.post_tran_cust_id AND J.post_tran_cust_id = TTPT.post_tran_cust_id and TTPT.tran_postilion_originated = 1)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr (NOLOCK)
ON (J.debit_acc_nr_id = DebitAccNr.acc_nr_id AND J.config_set_id = DebitAccNr.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_acc_nr_w AS DebitAccNr  (NOLOCK)
ON (J.amount_id = Amount.amount_id AND J.config_set_id = Amount.config_set_id)
LEFT OUTER JOIN dbo.sstl_se_fee_w AS Fee (NOLOCK)
ON (J.fee_id = Fee.fee_id AND J.config_set_id = Fee.config_set_id)
LEFT OUTER JOIN dbo.sstl_coa_w AS Coa  (NOLOCK)
ON (J.coa_id = Coa.coa_id AND J.config_set_id = Coa.config_set_id)



WHERE 

      TPT.tran_postilion_originated = 0
     
      AND TPT.rsp_code_rsp in ('00','11','09')
      
      AND (
          (TPT.settle_amount_impact<> 0 and TPT.message_type   in ('0200','0220'))

       or ((TPT.settle_amount_impact<> 0 and TPT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) <> 1 and TPT.tran_reversed <> 2)
       or (TPT.settle_amount_impact<> 0 and TPT.message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) = 1 ))

       or (TPT.settle_amount_rsp<> 0 and TPT.message_type   in ('0200','0220') and TPT.tran_type = 40 and (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0'))
       or (TPT.message_type = '0420' and TPT.tran_reversed <> 2 and TPT.tran_type = 40 and (SUBSTRING(TTPT.Terminal_id,1,1)= '1' or SUBSTRING(TTPT.Terminal_id,1,1)= '0')))
      
      AND (TPT.recon_business_date >= @from_date AND TPT.recon_business_date < (@to_date+1))

      AND not (merchant_type in ('4004','4722') and TPT.tran_type = '00' and source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(TPT.settle_amount_impact/100)< 200)

      AND not (merchant_type in ('5371') and TPT.tran_type = '00' and 
                (dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name) <> 2) 
               )
      AND TTPT.post_tran_cust_id >= @rpt_tran_id
      AND TTPT.totals_group not in ('CUPGroup','VISAGroup')
      AND
             TTPT.source_node_name  NOT LIKE 'SB%'
             AND
             TPT.sink_node_name  NOT LIKE 'SB%'
      --and source_node_name not in ('SWTWMASBsrc','SWTWEMSBsrc')
      
GROUP BY 

	 j.business_date,
	 DebitAccNr.acc_nr,
	 DebitAccNr.acc_nr,
	 TPT.tran_type,
	 dbo.fn_rpt_MCC (TTPT.merchant_type,TTPT.terminal_id),
	 SUBSTRING(TTPT.Terminal_id,1,1),
	 dbo.fn_rpt_isPurchaseTrx_sett(TPT.tran_type, TTPT.source_node_name, TPT.sink_node_name),
	dbo.fn_rpt_transfers_sett(TTPT.terminal_id,TPT.payee,TTPT.card_acceptor_name_loc,
					  TPT.extended_tran_type ,TTPT.source_node_name),
	dbo.fn_rpt_isBillpayment (TTPT.terminal_id,TPT.extended_tran_type,TPT.message_type,TPT.sink_node_name,TPT.payee,TTPT.card_acceptor_id_code ,TTPT.source_node_name),
	dbo.fn_rpt_isCardload (TTPT.source_node_name ,TTPT.pan, TPT.tran_type),
	dbo.fn_rpt_CardType (TTPT.pan ,TPT.sink_node_name ,TPT.tran_type,TTPT.TERMINAL_ID),
	dbo.fn_rpt_autopay_intra_sett (TPT.tran_type,TTPT.source_node_name),
	TTPT.Retention_data,
	TPT.settle_currency_code,
	TTPT.source_node_name,
	TPT.sink_node_name,
	dbo.fn_rpt_late_reversal(TPT.post_tran_cust_id,TPT.message_type,@rpt_tran_id1)

DROP TABLE #TEMP_POST_TRAN;

DROP TABLE #TEMP_POST_TRAN_CUST;

DROP TABLE #TEMP_TRANSACTIONS;

END  














































































