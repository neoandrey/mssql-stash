  
                      WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE')  =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                          
                       WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'
                          
                     WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk'  AND
                     (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE')  =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                        THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                        
                        THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                          
                       WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                          THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'    
                        
                    WHEN                      
			        (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			        (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1)
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'     
                        
                      WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk'  AND
                    (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr , 'AMOUNT') =1  AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr , 'PAYABLE') =1)
		             and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                     THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'

					WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
                     (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr , 'ISSUER') =  1 AND master.dbo.fn_rpt_contains(CreditAccNr_acc_nr , 'FEE') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr , 'PAYABLE') =1
					 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'   
		             THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'    
                           
                          
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr,  'AMOUNT') =1 AND master.dbo.fn_rpt_ends_with (CreditAccNr_acc_nr,  'PAYABLE') = 1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'   
                        
                      WHEN 
                     (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1  ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'     
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1 )
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Credit_Nr)'  
                      
                       
                      
                      WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1 ) THEN 'AMOUNT PAYABLE(Credit_Nr)'
	                  WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1 ) THEN 'AMOUNT RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'RECHARGE') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) THEN 'RECHARGE FEE PAYABLE(Credit_Nr)'  
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ACQUIRER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) THEN 'ACQUIRER FEE PAYABLE(Credit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'CO') = 1 AND master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ACQUIRER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'CO-ACQUIRER FEE RECEIVABLE(Credit_Nr)'   
                          WHEN ( master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ACQUIRER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'ACQUIRER FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) THEN 'ISSUER FEE PAYABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'CARDHOLDER') = 1 AND master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'SCH') = 1 AND master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN ( master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'ISSUER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYIN_INSTITUTION_FEE_RECEIVABLE') =1) THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Credit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISW') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1)) THEN 'ISW FEE PAYABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr,'ISW_ATM_FEE_CARD_SCHEME' =1) THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
                          WHEN ( master.dbo.fn_rpt_contains (CreditAccNr_acc_nr,'ISW_ATM_FEE_ACQ_') =1) THEN 'ISW ACQUIRER FEE RECEIVABLE (Credit_Nr)'
                          WHEN ( master.dbo.fn_rpt_contains (CreditAccNr_acc_nr,'ISW_ATM_FEE_ISS_') =1) THEN 'ISW ISSUER FEE RECEIVABLE (Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'


                          WHEN ( master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Credit_Nr)'
                           
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Credit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Credit_Nr)'
               
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Credit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((
						  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISO') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 
						  
						     ) OR master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE')  =1)OR (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'TERMINAL') = 1 AND master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) OR ((master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'PROCESSOR') = 1 AND master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1)) OR ((master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'NCS') = 1 AND master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1)))
						     
						     THEN 'ISW FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr , 'POS_FOODCONCEPT') = 1) THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISO') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'ISO FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'TERMINAL_OWNER') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'TERMINAL_OWNER FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'PROCESSOR') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'PROCESSOR FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'POOL_ACCOUNT')=1) THEN 'POOL ACCOUNT(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ATMC') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'PAYABLE') =1 ) THEN 'ATMC FEE PAYABLE(Credit_Nr)'  
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ATMC') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'ATMC FEE RECEIVABLE(Credit_Nr)'  
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'FEE_POOL') = 1 ) THEN 'FEE POOL(Credit_Nr)'  
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'EASYFUEL_ACCOUNT')= 1 ) THEN 'EASYFUEL ACCOUNT(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'MERCHANT') =1 
						  AND  
						  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'MERCHANT FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'YPM') =1 AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1 AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1 )THEN 'YPM FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FLEETTECH') =1 AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1 AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1) THEN 'FLEETTECH FEE RECEIVABLE(Credit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'LYSA') =1 AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'FEE') =1 AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') =1) THEN 'LYSA FEE RECEIVABLE(Credit_Nr)'

                         
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'SVA_FEE_RECEIVABLE') =1) THEN 'SVA FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'UDIRECT_FEE_RECEIVABLE') =1) THEN 'UDIRECT FEE RECEIVABLE(Credit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'PTSP_FEE_RECEIVABLE') =1 ) THEN 'PTSP FEE RECEIVABLE(Credit_Nr)'
                            
                          WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'NCS_FEE_RECEIVABLE')=1 ) THEN 'NCS FEE RECEIVABLE(Credit_Nr)'  
			  WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'SVA_SPONSOR_FEE_PAYABLE')=1 ) THEN 'SVA SPONSOR FEE PAYABLE(Credit_Nr)'
			  WHEN (master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'SVA_SPONSOR_FEE_RECEIVABLE')=1 ) THEN 'SVA SPONSOR FEE RECEIVABLE(Credit_Nr)' 