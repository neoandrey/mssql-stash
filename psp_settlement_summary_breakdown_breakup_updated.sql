IF( OBJECT_ID('TEMPDB.DBO.##report_result ') IS NOT NULL ) BEGIN

 DROP TABLE TEMPDB.DBO.##report_result 
END

SELECT	 	         
	bank_code = CASE 
	                      
WHEN					(dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and  (DebitAccNr_acc_nr LIKE '%FEE_PAYABLE' or CreditAccNr_acc_nr LIKE '%FEE_PAYABLE')) THEN 'ISW' 

WHEN                      
			           (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			           (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'     
                             
WHEN
				(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                        
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
					AND (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '312'  and PT.PT_tran_type = '50')
                                  
                                  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'                            
                          
WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                          AND ((PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') 
                                OR (PT.PTC_source_node_name = 'SWTFBPsrc' AND PT.PT_sink_node_name = 'ASPPOSVISsnk' 
                                 AND PT.PTC_totals_group = 'VISAGroup')
                               )
                          THEN 'UBA'
                          
                          
WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                          AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code = '627787')
                          THEN 'UNK'
                          
WHEN                      
			(PT.PT_sink_node_name = 'SWTWEBUBAsnk')  
                        AND  
			(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                         OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
  			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                         PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'                             
                          
                          
                          
  WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                        AND  PT.PT_acquiring_inst_id_code <> '627787' 
                              AND PT.PT_sink_node_name = 'ASPPOSVISsnk'    
                          THEN 'UBA'     
                          
                                                    
 WHEN                      (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                        AND  PT.PT_acquiring_inst_id_code = '627787'  
                        AND PT.PT_sink_node_name = 'ASPPOSVISsnk'   
                          THEN 'GTB'       
                          
                           
                                                      
 WHEN                      
						(PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  
                           AND  
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                          THEN 'ABP'   
                          
    WHEN                     
					 (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
					 (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                                   
                          THEN 'GTB'                                                                        
                           
   WHEN                     
						 (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk')  AND
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                                  
                          THEN 'EBN'  
                          
   WHEN                   
						(PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')
                          and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                                   
                          THEN 'UBA'                                             
      
WHEN PT.PT_Retention_data = '1046' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'UBN'
WHEN PT.PT_Retention_data in ('9130','8130') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABS'
WHEN PT.PT_Retention_data in ('9044','8044') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ABP'
WHEN PT.PT_Retention_data in ('9023','8023')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'CITI'
WHEN PT.PT_Retention_data in ('9050','8050') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'EBN'
WHEN PT.PT_Retention_data in ('9214','8214') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FCMB'
WHEN PT.PT_Retention_data in ('9070','8070','1100') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBP'
WHEN PT.PT_Retention_data in ('9011','8011') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'FBN'
WHEN PT.PT_Retention_data in ('9058','8058')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'GTB'
WHEN PT.PT_Retention_data in ('9082','8082') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'KSB'
WHEN PT.PT_Retention_data in ('9076','8076') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SKYE'
WHEN PT.PT_Retention_data in ('9084','8084') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ENT'
WHEN PT.PT_Retention_data in ('9039','8039') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'IBTC'
WHEN PT.PT_Retention_data in ('9068','8068') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SCB'
WHEN PT.PT_Retention_data in ('9232','8232','1105') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'SBP'
WHEN PT.PT_Retention_data in ('9032','8032')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBN'
WHEN PT.PT_Retention_data in ('9033','8033')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBA'
WHEN PT.PT_Retention_data in ('9215','8215')  and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') then 'UBP'
WHEN PT.PT_Retention_data in ('9035','8035') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'WEMA'
WHEN PT.PT_Retention_data in ('9057','8057') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'ZIB'
WHEN PT.PT_Retention_data in ('9301','8301') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'JBP'
WHEN PT.PT_Retention_data in ('9030') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE')  then 'HBC'
						  
WHEN PT.PT_Retention_data = '1411' and 
						(DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
						OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
						OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'HBC'
                          						                     	                                       
			
			
			WHEN PT.PT_Retention_data = '1131' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'WEMA'
                         WHEN PT.PT_Retention_data in ('1061','1006') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'

                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'GTB'
                         WHEN PT.PT_Retention_data = '1708' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'FBN'
                         WHEN PT.PT_Retention_data in ('1027','1045','1081','1015') and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'SKYE'
                         WHEN PT.PT_Retention_data = '1037' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'IBTC'
                         WHEN PT.PT_Retention_data = '1034' and 
                         (DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'
                          OR DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' OR CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'
                          OR DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' OR CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE') THEN 'EBN'
                     
                         WHEN (DebitAccNr_acc_nr LIKE 'UBA%' OR CreditAccNr_acc_nr LIKE 'UBA%') THEN 'UBA'
			 WHEN (DebitAccNr_acc_nr LIKE 'FBN%' OR CreditAccNr_acc_nr LIKE 'FBN%') THEN 'FBN'
                         WHEN (DebitAccNr_acc_nr LIKE 'ZIB%' OR CreditAccNr_acc_nr LIKE 'ZIB%') THEN 'ZIB' 
                         WHEN (DebitAccNr_acc_nr LIKE 'SPR%' OR CreditAccNr_acc_nr LIKE 'SPR%') THEN 'ENT'
                         WHEN (DebitAccNr_acc_nr LIKE 'GTB%' OR CreditAccNr_acc_nr LIKE 'GTB%') THEN 'GTB'
                         WHEN (DebitAccNr_acc_nr LIKE 'PRU%' OR CreditAccNr_acc_nr LIKE 'PRU%') THEN 'SKYE'
                         WHEN (DebitAccNr_acc_nr LIKE 'OBI%' OR CreditAccNr_acc_nr LIKE 'OBI%') THEN 'EBN'
                         WHEN (DebitAccNr_acc_nr LIKE 'WEM%' OR CreditAccNr_acc_nr LIKE 'WEM%') THEN 'WEMA'
                         WHEN (DebitAccNr_acc_nr LIKE 'AFR%' OR CreditAccNr_acc_nr LIKE 'AFR%') THEN 'MSB'
                         WHEN (DebitAccNr_acc_nr LIKE 'IBTC%' OR CreditAccNr_acc_nr LIKE 'IBTC%') THEN 'IBTC'
                         WHEN (DebitAccNr_acc_nr LIKE 'PLAT%' OR CreditAccNr_acc_nr LIKE 'PLAT%') THEN 'KSB'
                         WHEN (DebitAccNr_acc_nr LIKE 'UBP%' OR CreditAccNr_acc_nr LIKE 'UBP%') THEN 'UBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'DBL%' OR CreditAccNr_acc_nr LIKE 'DBL%') THEN 'DBL'

                         WHEN (DebitAccNr_acc_nr LIKE 'FCMB%' OR CreditAccNr_acc_nr LIKE 'FCMB%') THEN 'FCMB'
                         WHEN (DebitAccNr_acc_nr LIKE 'IBP%' OR CreditAccNr_acc_nr LIKE 'IBP%') THEN 'ABP'
                         WHEN (DebitAccNr_acc_nr LIKE 'UBN%' OR CreditAccNr_acc_nr LIKE 'UBN%') THEN 'UBN'
                         WHEN (DebitAccNr_acc_nr LIKE 'ETB%' OR CreditAccNr_acc_nr LIKE 'ETB%') THEN 'ETB'
                         WHEN (DebitAccNr_acc_nr LIKE 'FBP%' OR CreditAccNr_acc_nr LIKE 'FBP%') THEN 'FBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'SBP%' OR CreditAccNr_acc_nr LIKE 'SBP%') THEN 'SBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'ABP%' OR CreditAccNr_acc_nr LIKE 'ABP%') THEN 'ABP'
                         WHEN (DebitAccNr_acc_nr LIKE 'EBN%' OR CreditAccNr_acc_nr LIKE 'EBN%') THEN 'EBN'

                         WHEN (DebitAccNr_acc_nr LIKE 'CITI%' OR CreditAccNr_acc_nr LIKE 'CITI%') THEN 'CITI'
                         WHEN (DebitAccNr_acc_nr LIKE 'FIN%' OR CreditAccNr_acc_nr LIKE 'FIN%') THEN 'FCMB'
                         WHEN (DebitAccNr_acc_nr LIKE 'ASO%' OR CreditAccNr_acc_nr LIKE 'ASO%') THEN 'ASO'
                         WHEN (DebitAccNr_acc_nr LIKE 'OLI%' OR CreditAccNr_acc_nr LIKE 'OLI%') THEN 'OLI'
                         WHEN (DebitAccNr_acc_nr LIKE 'HSL%' OR CreditAccNr_acc_nr LIKE 'HSL%') THEN 'HSL'
                         WHEN (DebitAccNr_acc_nr LIKE 'ABS%' OR CreditAccNr_acc_nr LIKE 'ABS%') THEN 'ABS'
                         WHEN (DebitAccNr_acc_nr LIKE 'PAY%' OR CreditAccNr_acc_nr LIKE 'PAY%') THEN 'PAY'
                         WHEN (DebitAccNr_acc_nr LIKE 'SAT%' OR CreditAccNr_acc_nr LIKE 'SAT%') THEN 'SAT'
                         WHEN (DebitAccNr_acc_nr LIKE '3LCM%' OR CreditAccNr_acc_nr LIKE '3LCM%') THEN '3LCM'
                         WHEN (DebitAccNr_acc_nr LIKE 'SCB%' OR CreditAccNr_acc_nr LIKE 'SCB%') THEN 'SCB'
                         WHEN (DebitAccNr_acc_nr LIKE 'JBP%' OR CreditAccNr_acc_nr LIKE 'JBP%') THEN 'JBP'
                         WHEN (DebitAccNr_acc_nr LIKE 'RSL%' OR CreditAccNr_acc_nr LIKE 'RSL%') THEN 'RSL'
                         WHEN (DebitAccNr_acc_nr LIKE 'PSH%' OR CreditAccNr_acc_nr LIKE 'PSH%') THEN 'PSH'
                         WHEN (DebitAccNr_acc_nr LIKE 'INF%' OR CreditAccNr_acc_nr LIKE 'INF%') THEN 'INF'
                         WHEN (DebitAccNr_acc_nr LIKE 'UML%' OR CreditAccNr_acc_nr LIKE 'UML%') THEN 'UML'

                         WHEN (DebitAccNr_acc_nr LIKE 'ACCI%' OR CreditAccNr_acc_nr LIKE 'ACCI%') THEN 'ACCI'
                         WHEN (DebitAccNr_acc_nr LIKE 'EKON%' OR CreditAccNr_acc_nr LIKE 'EKON%') THEN 'EKON'
                         WHEN (DebitAccNr_acc_nr LIKE 'ATMC%' OR CreditAccNr_acc_nr LIKE 'ATMC%') THEN 'ATMC'
                         WHEN (DebitAccNr_acc_nr LIKE 'HBC%' OR CreditAccNr_acc_nr LIKE 'HBC%') THEN 'HBC'
			 WHEN (DebitAccNr_acc_nr LIKE 'UNI%' OR CreditAccNr_acc_nr LIKE 'UNI%') THEN 'UNI'
                         WHEN (DebitAccNr_acc_nr LIKE 'UNC%' OR CreditAccNr_acc_nr LIKE 'UNC%') THEN 'UNC'
                         WHEN (DebitAccNr_acc_nr LIKE 'NCS%' OR CreditAccNr_acc_nr LIKE 'NCS%') THEN 'NCS' 
			 WHEN (DebitAccNr_acc_nr LIKE 'HAG%' OR CreditAccNr_acc_nr LIKE 'HAG%') THEN 'HAG'
			 WHEN (DebitAccNr_acc_nr LIKE 'EXP%' OR CreditAccNr_acc_nr LIKE 'EXP%') THEN 'DBL'
			 WHEN (DebitAccNr_acc_nr LIKE 'FGMB%' OR CreditAccNr_acc_nr LIKE 'FGMB%') THEN 'FGMB'
                         WHEN (DebitAccNr_acc_nr LIKE 'CEL%' OR CreditAccNr_acc_nr LIKE 'CEL%') THEN 'CEL'
			 WHEN (DebitAccNr_acc_nr LIKE 'RDY%' OR CreditAccNr_acc_nr LIKE 'RDY%') THEN 'RDY'
			 WHEN (DebitAccNr_acc_nr LIKE 'AMJ%' OR CreditAccNr_acc_nr LIKE 'AMJ%') THEN 'AMJU'
			 WHEN (DebitAccNr_acc_nr LIKE 'CAP%' OR CreditAccNr_acc_nr LIKE 'CAP%') THEN 'O3CAP'
			 WHEN (DebitAccNr_acc_nr LIKE 'VER%' OR CreditAccNr_acc_nr LIKE 'VER%') THEN 'VER_GLOBAL'

			 WHEN (DebitAccNr_acc_nr LIKE 'SMF%' OR CreditAccNr_acc_nr LIKE 'SMF%') THEN 'SMFB'
			 WHEN (DebitAccNr_acc_nr LIKE 'SLT%' OR CreditAccNr_acc_nr LIKE 'SLT%') THEN 'SLTD'
			 WHEN (DebitAccNr_acc_nr LIKE 'JES%' OR CreditAccNr_acc_nr LIKE 'JES%') THEN 'JES'
                         WHEN (DebitAccNr_acc_nr LIKE 'MOU%' OR CreditAccNr_acc_nr LIKE 'MOU%') THEN 'MOUA'
                         WHEN (DebitAccNr_acc_nr LIKE 'MUT%' OR CreditAccNr_acc_nr LIKE 'MUT%') THEN 'MUT'
                         WHEN (DebitAccNr_acc_nr LIKE 'LAV%' OR CreditAccNr_acc_nr LIKE 'LAV%') THEN 'LAV'
                         WHEN (DebitAccNr_acc_nr LIKE 'JUB%' OR CreditAccNr_acc_nr LIKE 'JUB%') THEN 'JUB'
						 WHEN (DebitAccNr_acc_nr LIKE 'WET%' OR CreditAccNr_acc_nr LIKE 'WET%') THEN 'WET'
                         WHEN (DebitAccNr_acc_nr LIKE 'AGH%' OR CreditAccNr_acc_nr LIKE 'AGH%') THEN 'AGH'
                         WHEN (DebitAccNr_acc_nr LIKE 'TRU%' OR CreditAccNr_acc_nr LIKE 'TRU%') THEN 'TRU'
						 WHEN (DebitAccNr_acc_nr LIKE 'CON%' OR CreditAccNr_acc_nr LIKE 'CON%') THEN 'CON'
                         WHEN (DebitAccNr_acc_nr LIKE 'CRU%' OR CreditAccNr_acc_nr LIKE 'CRU%') THEN 'CRU'
						WHEN (DebitAccNr_acc_nr LIKE 'NPR%' OR CreditAccNr_acc_nr LIKE 'NPR%') THEN 'NPR'
						WHEN (DebitAccNr_acc_nr LIKE 'OMO%' OR CreditAccNr_acc_nr LIKE 'OMO%') THEN 'OMO'
						WHEN (DebitAccNr_acc_nr LIKE 'SUN%' OR CreditAccNr_acc_nr LIKE 'SUN%') THEN 'SUN'
						WHEN (DebitAccNr_acc_nr LIKE 'NGB%' OR CreditAccNr_acc_nr LIKE 'NGB%') THEN 'NGB'
						WHEN (DebitAccNr_acc_nr LIKE 'OSC%' OR CreditAccNr_acc_nr LIKE 'OSC%') THEN 'OSC'
						WHEN (DebitAccNr_acc_nr LIKE 'OSP%' OR CreditAccNr_acc_nr LIKE 'OSP%') THEN 'OSP'
						WHEN (DebitAccNr_acc_nr LIKE 'IFIS%' OR CreditAccNr_acc_nr LIKE 'IFIS%') THEN 'IFIS'
						WHEN (DebitAccNr_acc_nr LIKE 'NPM%' OR CreditAccNr_acc_nr LIKE 'NPM%') THEN 'NPM'
						WHEN (DebitAccNr_acc_nr LIKE 'POL%' OR CreditAccNr_acc_nr LIKE 'POL%') THEN 'POL'
						WHEN (DebitAccNr_acc_nr LIKE 'ALV%' OR CreditAccNr_acc_nr LIKE 'ALV%') THEN 'ALV'
						WHEN (DebitAccNr_acc_nr LIKE 'MAY%' OR CreditAccNr_acc_nr LIKE 'MAY%') THEN 'MAY'
						WHEN (DebitAccNr_acc_nr LIKE 'PRO%' OR CreditAccNr_acc_nr LIKE 'PRO%') THEN 'PRO'
						WHEN (DebitAccNr_acc_nr LIKE 'UNIL%' OR CreditAccNr_acc_nr LIKE 'UNIL%') THEN 'UNIL'
						WHEN (DebitAccNr_acc_nr LIKE 'PAR%' OR CreditAccNr_acc_nr LIKE 'PAR%') THEN 'PAR'
						WHEN (DebitAccNr_acc_nr LIKE 'FOR%' OR CreditAccNr_acc_nr LIKE 'FOR%') THEN 'FOR'
							WHEN (DebitAccNr_acc_nr LIKE 'MON%' OR CreditAccNr_acc_nr LIKE 'MON%') THEN 'MON'
							WHEN (DebitAccNr_acc_nr LIKE 'NDI%' OR CreditAccNr_acc_nr LIKE 'NDI%') THEN 'NDI'					
                         WHEN (DebitAccNr_acc_nr LIKE 'POS_FOODCONCEPT%' OR CreditAccNr_acc_nr LIKE 'POS_FOODCONCEPT%') THEN 'SCB'
			 WHEN ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) THEN 'ISW'
			
			 ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.PT_tran_type ='01')  
							AND dbo.fn_rpt_CardGroup(PT.PTC_PAN) in ('1','4')
                           AND PT.PTC_source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                            WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Verve Token)'
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)'
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 3 
                           THEN 'ATM WITHDRAWAL (Cardless:Non-Card Generated)'

						   WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr  LIKE '%ATM%ISO%' OR CreditAccNr_acc_nr LIKE '%ATM%ISO%')
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           AND PT.PTC_source_node_name <> 'ASPSPNOUsrc'                           
                           THEN 'ATM WITHDRAWAL (MASTERCARD ISO)'


                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           AND PT.PTC_source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                                                                           
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 

                           and (DebitAccNr_acc_nr LIKE '%V%BILLING%' OR CreditAccNr_acc_nr LIKE '%V%BILLING%')
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (DebitAccNr_acc_nr not LIKE '%V%BILLING%' and CreditAccNr_acc_nr not LIKE '%V%BILLING%')
                           AND PT.PTC_source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			               WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' and 
                           (DebitAccNr_acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr_acc_nr like '%BILLPAYMENT MCARD%') ) then 'BILLPAYMENT MASTERCARD BILLING'

                           WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' 
                           and (DebitAccNr_acc_nr like '%SVA_FEE_RECEIVABLE' or CreditAccNr_acc_nr like '%SVA_FEE_RECEIVABLE') ) 
                           AND dbo.fn_rpt_isBillpayment_IFIS(PT.PTC_terminal_id) = 1  then 'BILLPAYMENT IFIS REMITTANCE'
                          
			               WHEN ( dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1')  then 'BILLPAYMENT'
			   
			
                           WHEN (PT.PT_tran_type ='40'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' 

                           or SUBSTRING(PT.PTC_terminal_id,1,1)= '0' or SUBSTRING(PT.PTC_terminal_id,1,1)= '4')) THEN 'CARD HOLDER ACCOUNT TRANSFER'

                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           AND SUBSTRING(PT.PTC_terminal_id,1,1)IN ('2','5','6')AND PT.PT_sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN 'POS PURCHASE (Cardless:Paycode Verve Token)'
                           
                           WHEN dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           AND SUBSTRING(PT.PTC_terminal_id,1,1)IN ('2','5','6')AND PT.PT_sink_node_name = 'ESBCSOUTsnk' and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN 'POS PURCHASE (Cardless:Paycode Non-Verve Token)'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '1'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                            or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(EASYFUEL)PURCHASE'
                           
                           WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(TRAVEL AGENCIES-VISA)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(WHOLESALE CLUBS-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                           

                           --WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='1'
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           --or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                     
                           --WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='2'
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           --or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(2% CATEGORY-VISA)PURCHASE'
                           
                           --WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='3'
                           --and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           --and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           --or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(3% CATEGORY-VISA)PURCHASE'
                           
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.PTC_merchant_type
                              
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1 OR PT.PT_tran_type = '50')
                            and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                              or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.PTC_merchant_type
                              
                              
                              WHEN (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name IN ('SWTWEBEBNsnk','SWTWEBUBAsnk','SWTWEBGTBsnk','SWTWEBABPsnk'))
                              and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                              and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                              AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'
                              THEN 'WEB(GENERIC)PURCHASE'
                              
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '9'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) 
                           THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '10'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N200)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '11'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N300)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '12'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N150)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '13'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1.5% CAPPED AT N300)PURCHASE'
                       
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '15'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB COLLEGES ( 1.5% capped specially at 250)'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '16'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (PROFESSIONAL SERVICES)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '17'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (SECURITY BROKERS/DEALERS)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '18'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB (COMMUNICATION)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '19'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N400)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '20'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N250)PURCHASE'
                  
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '21'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N265)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '22'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(FLAT FEE OF N550)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '23'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'Verify card – Ecash load'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '24'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1% CAPPED AT 1,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '25'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(0.75% CAPPED AT 2,000 CATEGORY)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '26'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Payment_Gateway_0.9%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '27'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Payment_Gateway_1.25%)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '28'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(Verve_Add_Card)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '30'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(0.75% CAPPED AT 1,000 CATEGORY)PURCHASE'
                            
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '31'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'WEB(1% CAPPED AT N50 CATEGORY)PURCHASE'                     
                                                      
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and not (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE'
                           or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and (DebitAccNr_acc_nr LIKE '%fee%' OR CreditAccNr_acc_nr LIKE '%fee%')
                                 and (PT.PT_tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.PTC_source_node_name,PT.PT_tran_type,PT.PT_payee) = 1))
                                 and not (DebitAccNr_acc_nr like '%PREPAIDLOAD%' or CreditAccNr_acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and (DebitAccNr_acc_nr NOT LIKE '%fee%' OR CreditAccNr_acc_nr NOT LIKE '%fee%')

                                 and PT.PT_tran_type in ('50')
                                 and not (DebitAccNr_acc_nr like '%PREPAIDLOAD%' or CreditAccNr_acc_nr like '%PREPAIDLOAD%')) THEN 'AUTOPAY TRANSFERS'
                                 
                          WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                           PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50' and PT.PT_extended_tran_type = '6011') THEN 'ATM CARDLESS-TRANSFERS'     

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50') THEN 'ATM TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '2' and PT.PT_tran_type = '50') THEN 'POS TRANSFERS'
                           
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '4' and PT.PT_tran_type = '50') THEN 'MOBILE TRANSFERS'

                          WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '35' and PT.PT_tran_type = '50') then 'REMITA TRANSFERS'

       
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '31' and PT.PT_tran_type = '50') then 'OTHER TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '32' and PT.PT_tran_type = '50') then 'RELATIONAL TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '33' and PT.PT_tran_type = '50') then 'SEAMFIX TRANSFERS'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '34' and PT.PT_tran_type = '50') then 'VERVE INTL TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '36' and PT.PT_tran_type = '50') then 'PREPAID CARD UNLOAD'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '37' and PT.PT_tran_type = '50' ) then 'QUICKTELLER TRANSFERS(BANK BRANCH)'
 
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '38' and PT.PT_tran_type = '50') then 'QUICKTELLER TRANSFERS(SVA)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '39' and PT.PT_tran_type = '50') then 'SOFTPAY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '310' and PT.PT_tran_type = '50') then 'OANDO S&T TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '311' and PT.PT_tran_type = '50') then 'UPPERLINK TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '312'  and PT.PT_tran_type = '50') then 'QUICKTELLER WEB TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '314'  and PT.PT_tran_type = '50') then 'QUICKTELLER MOBILE TRANSFERS'
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '315' and PT.PT_tran_type = '50') then 'WESTERN UNION MONEY TRANSFERS'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '316' and PT.PT_tran_type = '50') then 'OTHER TRANSFERS(NON GENERIC PLATFORM)'
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '317' and PT.PT_tran_type = '50') then 'OTHER TRANSFERS(ACCESSBANK PORTAL)'
                                  
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr NOT LIKE '%AMOUNT%RECEIVABLE' AND CreditAccNr_acc_nr NOT LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND (DebitAccNr_acc_nr  LIKE '%AMOUNT%RECEIVABLE' or CreditAccNr_acc_nr  LIKE '%AMOUNT%RECEIVABLE') then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PT.PTC_source_node_name ,PT.PTC_pan, PT.PT_tran_type)= '1') then 'PREPAID CARDLOAD'

                          when PT.PT_tran_type = '21' then 'DEPOSIT'

                           /*WHEN (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE' or CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE')) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN  (SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (DebitAccNr_acc_nr LIKE '%ISO_FEE_RECEIVABLE' or CreditAccNr_acc_nr LIKE '%ISO_FEE_RECEIVABLE')) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'*/
                           
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE 
                     /* WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'*/
                      
                      /*WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'*/
                      
                     /* WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'*/ 
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'
                          
                     WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk'  AND
                     (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                        THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                        
                        THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                          THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'    
                        
                    WHEN                      
			        (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			        (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'     
                        
                      WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk'  AND
                    (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE')
		             and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                     THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'

					WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
                     (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
					 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'   
		             THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'    
                           
                          
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                     (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'     
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'  
                      
                       
                      
                      WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (DebitAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN (DebitAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (DebitAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE')OR (DebitAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (DebitAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Debit_Nr)'  
                          WHEN (DebitAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (DebitAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (DebitAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (DebitAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (DebitAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (DebitAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (DebitAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
  
  
                     
                      /*WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTASPUBAsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'*/
                      
                       /* WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 1)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)' */
                         
                         
                      WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                      PT.PT_acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                           PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                           
                     WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk'  AND
                     (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)' 
                      
                      WHEN                      
			       (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			        (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      
                      WHEN 
                      PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE')
		              and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'   
		            THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'

        
 
				WHEN 
                   PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
		          (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
 		           and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                   PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                   AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'   
		           THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                     WHEN 
                     (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  AND
                     (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                          THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                          
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                     THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                        WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'    
                      
                      WHEN 
                     (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk')  AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)' 
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk')  AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)' 
                                               
                          WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%PAYABLE') THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (CreditAccNr_acc_nr LIKE '%AMOUNT%RECEIVABLE') THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%RECHARGE%FEE%PAYABLE') THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%PAYABLE') THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%CO%ACQUIRER%FEE%RECEIVABLE') THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN (CreditAccNr_acc_nr LIKE '%ACQUIRER%FEE%RECEIVABLE') THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE') THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%PAYABLE') THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%CARDHOLDER%ISSUER%FEE%RECEIVABLE%') THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr_acc_nr LIKE '%SCH%ISSUER%FEE%RECEIVABLE') THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE') THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PAYIN_INSTITUTION_FEE_RECEIVABLE') THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_CARD_SCHEME%') THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_ACQ_%') THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW_ATM_FEE_ISS_%') THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                           WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'


                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (CreditAccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE' 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%TERMINAL%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') OR (CreditAccNr_acc_nr LIKE '%NCS%FEE%RECEIVABLE'))) THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE 'POS_FOODCONCEPT%')THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ISO%FEE%RECEIVABLE') THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%TERMINAL_OWNER%FEE%RECEIVABLE') THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PROCESSOR%FEE%RECEIVABLE') THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%POOL_ACCOUNT') THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%PAYABLE') THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%ATMC%FEE%RECEIVABLE') THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%FEE_POOL') THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (CreditAccNr_acc_nr LIKE '%EASYFUEL_ACCOUNT') THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%MERCHANT%FEE%RECEIVABLE') THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr_acc_nr LIKE '%YPM%FEE%RECEIVABLE') THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (CreditAccNr_acc_nr LIKE '%FLEETTECH%FEE%RECEIVABLE') THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 

                          WHEN (CreditAccNr_acc_nr LIKE '%LYSA%FEE%RECEIVABLE') THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'
                         
                          WHEN (CreditAccNr_acc_nr LIKE '%SVA_FEE_RECEIVABLE') THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%UDIRECT_FEE_RECEIVABLE') THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (CreditAccNr_acc_nr LIKE '%PTSP_FEE_RECEIVABLE') THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                          
                          WHEN (CreditAccNr_acc_nr LIKE '%NCS_FEE_RECEIVABLE') THEN 'NCS FEE RECEIVABLE(Credit_Nr)' 
			  WHEN (CreditAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_RECEIVABLE') THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)'
			  WHEN (CreditAccNr_acc_nr LIKE '%SVA_SPONSOR_FEE_PAYABLE') THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'

                          ELSE 'UNK'			
END,

       trxn_amount=ISNULL(PT.amount,0),
	trxn_fee=ISNULL(PT.fee,0),
	trxn_date=PT.business_date,
        currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' and 
                           (DebitAccNr_acc_nr like '%BILLPAYMENT MCARD%' or CreditAccNr_acc_nr like '%BILLPAYMENT MCARD%') ) THEN '840'
                        WHEN ((DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%') and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTUBAsnk'))) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM%ISO%ACQUIRER%' OR CreditAccNr_acc_nr LIKE '%ATM%ISO%ACQUIRER%') ) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM_FEE_ACQ_ISO%' OR CreditAccNr_acc_nr LIKE '%ATM_FEE_ACQ_ISO%') ) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM%ISO%ISSUER%' OR CreditAccNr_acc_nr LIKE '%ATM%ISO%ISSUER%') and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTPLATsnk'))) THEN '840'
						WHEN ((DebitAccNr_acc_nr LIKE '%ATM_FEE_ISS_ISO%' OR CreditAccNr_acc_nr LIKE '%ATM_FEE_ISS_ISO%') and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTPLATsnk'))) THEN '840'
					    ELSE PT.PT_settle_currency_code END,
        late_reversal = CASE
        
                        WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                               and PT.PTC_merchant_type in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511') THEN 0
                               
						WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
        card_type =  dbo.fn_rpt_CardGroup(PT.PTC_pan),
        terminal_type = dbo.fn_rpt_terminal_type(PT.PTC_terminal_id),    
        source_node_name =   PT.PTC_source_node_name,
        Unique_key = PT.PT_retrieval_reference_nr+'_'+PT.PT_system_trace_audit_nr+'_'+PT.PTC_terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(PT.PT_settle_amount_impact,0))) as VARCHAR(20))+'_'+PT.PT_message_type,
        Acquirer = (case when (not ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) AND (acc.acquirer_inst_id1 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.PT_acquiring_inst_id_code oR acc.acquirer_inst_id4 = PT.PT_acquiring_inst_id_code oR acc.acquirer_inst_id5 = PT.PT_acquiring_inst_id_code) then acc.bank_code 
                      else PT.PT_acquiring_inst_id_code END),
        Issuer = (case when (not ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) )) then ''
                      when ((DebitAccNr_acc_nr LIKE 'ISW%' and DebitAccNr_acc_nr not LIKE '%POOL%' ) OR (CreditAccNr_acc_nr LIKE 'ISW%' and CreditAccNr_acc_nr not LIKE '%POOL%' ) ) and (substring(PT.PTC_totals_group,1,3) = acc.bank_code1) then acc.bank_code
                      else substring(PT.PTC_totals_group,1,3) END),
       Volume = (case when PT.PT_message_type in ('0200','0220') then 1
	                   else 0 end),  
           Value_RequestedAmount = PT.PT_settle_amount_req,
           Value_SettleAmount = PT.PT_settle_amount_impact,pt.pt_post_tran_id as ptid ,pt.pt_post_tran_cust_id as ptcid,                   
                index_no = IDENTITY(INT,1,1)
        INTO  ##report_result 
           FROM
             (  SELECT PT.PT_post_tran_id
,PT.PT_post_tran_cust_id
,PT.PT_settle_entity_id
,PT.PT_batch_nr
,PT.PT_prev_post_tran_id
,PT.PT_next_post_tran_id
,PT.PT_sink_node_name
,PT.PT_tran_postilion_originated
,PT.PT_tran_completed
,PT.PT_message_type
,PT.PT_tran_type
,PT.PT_tran_nr
,PT.PT_system_trace_audit_nr
,PT.PT_rsp_code_req
,PT.PT_rsp_code_rsp
,PT.PT_abort_rsp_code
,PT.PT_auth_id_rsp
,PT.PT_auth_type
,PT.PT_auth_reason
, PTT.PT_retention_data
,PT.PT_acquiring_inst_id_code
,PT.PT_message_reason_code
,PT.PT_sponsor_bank
,PT.PT_retrieval_reference_nr
,PT.PT_datetime_tran_gmt
,PT.PT_datetime_tran_local
,PT.PT_datetime_req
,PT.PT_datetime_rsp
,PT.PT_realtime_business_date
,PT.PT_recon_business_date
,PT.PT_from_account_type
,PT.PT_to_account_type
,PT.PT_from_account_id
,PT.PT_to_account_id
,PT.PT_tran_amount_req
,PT.PT_tran_amount_rsp
,PT.PT_settle_amount_impact
,PT.PT_tran_cash_req
,PT.PT_tran_cash_rsp
,PT.PT_tran_currency_code
,PT.PT_tran_tran_fee_req
,PT.PT_tran_tran_fee_rsp
,PT.PT_tran_tran_fee_currency_code
,PT.PT_tran_proc_fee_req
,PT.PT_tran_proc_fee_rsp
,PT.PT_tran_proc_fee_currency_code
,PT.PT_settle_amount_req
,PT.PT_settle_amount_rsp
,PT.PT_settle_cash_req
,PT.PT_settle_cash_rsp
,PT.PT_settle_tran_fee_req
,PT.PT_settle_tran_fee_rsp
,PT.PT_settle_proc_fee_req
,PT.PT_settle_proc_fee_rsp
,PT.PT_settle_currency_code
,PT.PT_pos_entry_mode
,PT.PT_pos_condition_code
,PT.PT_additional_rsp_data
,PT.PT_tran_reversed
,PT.PT_prev_tran_approved
,PT.PT_issuer_network_id
,PT.PT_acquirer_network_id
,PT.PT_extended_tran_type
,PT.PT_from_account_type_qualifier
,PT.PT_to_account_type_qualifier
,PT.PT_bank_details
,PT.PT_payee
,PT.PT_card_verification_result
,PT.PT_online_system_id
,PT.PT_participant_id
,PT.PT_opp_participant_id
,PT.PT_receiving_inst_id_code
,PT.PT_routing_type
,PT.PT_pt_pos_operating_environment
,PT.PT_pt_pos_card_input_mode
,PT.PT_pt_pos_cardholder_auth_method
,PT.PT_pt_pos_pin_capture_ability
,PT.PT_pt_pos_terminal_operator
,PT.PT_source_node_key
,PT.PT_proc_online_system_id
,PT.PTC_post_tran_cust_id
,PT.PTC_source_node_name
,PT.PTC_draft_capture
,PT.PTC_pan
,PT.PTC_card_seq_nr
,PT.PTC_expiry_date
,PT.PTC_service_restriction_code
,PT.PTC_terminal_id
,PT.PTC_terminal_owner
,PT.PTC_card_acceptor_id_code
,PT.PTC_mapped_card_acceptor_id_code
,PT.PTC_merchant_type
,PT.PTC_card_acceptor_name_loc
,PT.PTC_address_verification_data
,PT.PTC_address_verification_result
,PT.PTC_check_data
,PT.PTC_totals_group
,PT.PTC_card_product
,PT.PTC_pos_card_data_input_ability
,PT.PTC_pos_cardholder_auth_ability
,PT.PTC_pos_card_capture_ability
,PT.PTC_pos_operating_environment
,PT.PTC_pos_cardholder_present
,PT.PTC_pos_card_present
,PT.PTC_pos_card_data_input_mode
,PT.PTC_pos_cardholder_auth_method
,PT.PTC_pos_cardholder_auth_entity
,PT.PTC_pos_card_data_output_ability
,PT.PTC_pos_terminal_output_ability
,PT.PTC_pos_pin_capture_ability
,PT.PTC_pos_terminal_operator
,PT.PTC_pos_terminal_type
,PT.PTC_pan_search
,PT.PTC_pan_encrypted
,PT.PTC_pan_reference
,J.adj_id
,J.entry_id
,J.config_set_id
,J.session_id
,J.post_tran_id
,J.post_tran_cust_id
,J.sdi_tran_id
,J.acc_post_id
,J.nt_fee_acc_post_id
,J.coa_id
,J.coa_se_id
,J.se_id
,J.amount
,J.amount_id
,J.amount_value_id
,J.fee
,J.fee_id
,J.fee_value_id
,J.nt_fee
,J.nt_fee_id
,J.nt_fee_value_id
,J.debit_acc_nr_id
,J.debit_acc_id
,J.debit_cardholder_acc_id
,J.debit_cardholder_acc_type
,J.credit_acc_nr_id
,J.credit_acc_id
,J.credit_cardholder_acc_id
,J.credit_cardholder_acc_type
,J.business_date
,J.granularity_element
,J.tag
,J.spay_session_id
,J.spst_session_id
,J.DebitAccNr_config_set_id
,J.DebitAccNr_acc_nr_id
,J.DebitAccNr_se_id
,J.DebitAccNr_acc_id
,J.DebitAccNr_acc_nr
,J.DebitAccNr_aggregation_id
,J.DebitAccNr_state
,J.DebitAccNr_config_state
,J.CreditAccNr_config_set_id
,J.CreditAccNr_acc_nr_id
,J.CreditAccNr_se_id
,J.CreditAccNr_acc_id
,J.CreditAccNr_acc_nr
,J.CreditAccNr_aggregation_id
,J.CreditAccNr_state
,J.CreditAccNr_config_state
,J.Amount_config_set_id
,J.Amount_amount_id
,J.Amount_se_id
,J.Amount_name
,J.Amount_description
,J.Amount_config_state
,J.Fee_config_set_id
,J.Fee_fee_id
,J.Fee_se_id
,J.Fee_name
,J.Fee_description
,J.Fee_type
,J.Fee_amount_id
,J.Fee_config_state
,J.coa_config_set_id
,J.coa_coa_id
,J.coa_name
,J.coa_description
,J.coa_type
,J.coa_config_state
 FROM  (select* from  temp_journal_data (NOLOCK) )  J 
                     join 
                 (SELECT * FROM temp_post_tran_data (NOLOCK) WHERE PT_tran_postilion_originated =0)   PT 
                    ON (J.post_tran_id = PT.PT_post_tran_id AND J.post_tran_cust_id = PT.PT_post_tran_cust_id)
                    left JOIN 
                 (SELECT * FROM temp_post_tran_data (NOLOCK) WHERE PT_tran_postilion_originated =1)PTT on (PT.PT_post_tran_cust_id = PTT.PT_post_tran_cust_id and PT.PT_tran_nr = PTT.PT_tran_nr) 
and 
    (
          (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type   in ('0200','0220'))

       or ((PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 

       and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,  PT.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,PT.PTC_totals_group ,PT.ptc_pan) <> 1
        and PT.PT_tran_reversed <> 2)
       or (PT.PT_settle_amount_impact<> 0 and PT.PT_message_type = '0420' 
       and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type, pt.PTC_source_node_name, PT.PT_sink_node_name, pt.PTC_terminal_id ,pt.PTC_totals_group ,pt.PTC_pan) = 1 ))

       or (PT.PT_settle_amount_rsp<> 0 and PT.PT_message_type   in ('0200','0220') and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1) IN ('0','1') ))
       or (PT.PT_message_type = '0420' and PT.PT_tran_reversed <> 2 and PT.PT_tran_type = 40 and (SUBSTRING(pt.PTC_Terminal_id,1,1)IN ( '0','1' ))))
     

      AND not (pt.PTC_merchant_type in ('4004','4722') and PT.PT_tran_type = '00' and pt.PTC_source_node_name not in ('VTUsrc','CCLOADsrc') and  abs(PT.PT_settle_amount_impact/100)< 200
       and not (DebitAccNr_acc_nr LIKE '%MCARD%BILLING%' OR CreditAccNr_acc_nr LIKE '%MCARD%BILLING%'))


      AND pt.PTC_totals_group <>'CUPGroup'
      and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_acquiring_inst_id_code = '627787')
	  and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_sink_node_name not in ('ASPPOSVINsnk')
	            and not (pt.ptc_source_node_name in ('SWTFBPsrc','SWTUBAsrc','SWTZIBsrc','SWTPLATsrc') and PT.PT_sink_node_name = 'ASPPOSVISsnk') 
	           )
     and not (PT.ptc_source_node_name  = 'MEGATPPsrc' and PT.PT_tran_type = '00'))pt
   
   LEFT OUTER JOIN aid_cbn_code acc ON
  pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5)

    
   

OPTION(RECOMPILE, MAXDOP 8)


