
/*
CREATE function fn_rpt_settlement_breakdown_1 (@DebitAccNr_acc_nr VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500),@PT_tran_type ,@PTC_source_node_name VARCHAR(30),@PT_sink_node_name VARCHAR(30),@PT_payee VARCHAR(100), @PTC_card_acceptor_id_code VARCHAR(500),@PTC_totals_group VARCHAR(30),@PTC_pan VARCHAR(30), @PTC_terminal_id VARCHAR(10),@PT_extended_tran_type VARCHAR(10),@PT_message_type  VARCHAR(10) ) RETURNS BIT
   AS
   BEGIN
    DECLARE @return_bit BIT = 0 
                
                
             IF (  (master.dbo.fn_rpt_ends_with (@DebitAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1 
                            OR (master.dbo.fn_rpt_ends_with (@DebitAccNr_acc_nr, 'ISSUER_FEE_RECEIVABLE')=1 
                             OR (master.dbo.fn_rpt_ends_with (@DebitAccNr_acc_nr, 'AMOUNT_PAYABLE')=1 
                            OR (master.dbo.fn_rpt_ends_with (@CreditAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1 ))
                          OR (master.dbo.fn_rpt_ends_with (@CreditAccNr_acc_nr, 'ISSUER_FEE_RECEIVABLE')=1 ))
                         OR (master.dbo.fn_rpt_ends_with (@CreditAccNr_acc_nr, 'AMOUNT_PAYABLE')=1 ))

                          and dbo.fn_rpt_isPurchaseTrx_sett(@PT_tran_type,@PTC_source_node_name, @PT_sink_node_name,@PTC_terminal_id ,@PTC_totals_group ,@PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (@PTC_terminal_id,@PT_extended_tran_type,@PT_message_type,@PT_sink_node_name,@PT_payee,@PTC_card_acceptor_id_code ,@PTC_source_node_name,@PT_tran_type,@PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(@PTC_pan) = '6') BEGIN
                        
                         SET  @return_bit = 1;
                    
                   END
             RETURN @return_bit
      END 
      
      
   
   
  go  CREATE FUNCTION fn_rpt_settlement_breakdown_2 (@DebitAccNr_acc_nr  VARCHAR(500),@CreditAccNr_acc_nr VARCHAR(500) ) 
  
  RETURNS BIT
  
  AS BEGIN
     DECLARE @return_bit BIT  = 0 
  IF ( ((master.dbo.fn_rpt_ends_with (@DebitAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1 OR (master.dbo.fn_rpt_ends_with (@CreditAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1 )))
                          OR (master.dbo.fn_rpt_ends_with (@DebitAccNr_acc_nr, 'ISSUER_FEE_RECEIVABLE')=1 OR (master.dbo.fn_rpt_ends_with (@CreditAccNr_acc_nr, 'ISSUER_FEE_RECEIVABLE')=1 ))
                          OR (master.dbo.fn_rpt_ends_with (@DebitAccNr_acc_nr, 'AMOUNT_PAYABLE')=1 OR (master.dbo.fn_rpt_ends_with (@CreditAccNr_acc_nr, 'AMOUNT_PAYABLE')=1 ))
                          ) 
                          BEGIN 
                          
                          SET @return_bit = 1
                          
                          
                          END
                   RETURN @return_bit
            END
            
            
     go  CREATE FUNCTION    fn_rpt_settlement_breakdown_3 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0
     
     IF(
     (master.dbo.fn_rpt_contains ( @DebitAccNr_acc_nr, 'Mcard') = 1  and 
                           master.dbo.fn_rpt_contains ( @DebitAccNr_acc_nr, 'Billing') =1 ) OR 
                            ( master.dbo.fn_rpt_contains ( @CreditAccNr_acc_nr, 'Mcard') = 1  and 
                            master.dbo.fn_rpt_contains ( @CreditAccNr_acc_nr, 'Billing') =1 )
                            )
                   BEGIN
                   
                   SET @return_bit = 1 
                   END
            RETURN @return_bit
        END
        
        go  CREATE FUNCTION    fn_rpt_settlement_breakdown_4 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0
     
     IF(
     (master.dbo.fn_rpt_contains ( @DebitAccNr_acc_nr, 'V') = 1  and 
                           master.dbo.fn_rpt_contains ( @DebitAccNr_acc_nr, 'Billing') =1 ) OR 
                            ( master.dbo.fn_rpt_contains ( @CreditAccNr_acc_nr, 'V') = 1  and 
                            master.dbo.fn_rpt_contains ( @CreditAccNr_acc_nr, 'Billing') =1 )
                            )
                   BEGIN
                   
                   SET @return_bit = 1 
                   END
            RETURN @return_bit
        END
        
        
      go  CREATE FUNCTION fn_rpt_settlement_breakdown_5 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   (
					master.dbo.fn_rpt_contains(@DebitAccNr_acc_nr,  'TERMINAL_OWNER') =1 
					 	    AND  master.dbo.fn_rpt_contains(@DebitAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(@DebitAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
						   or  (
						    master.dbo.fn_rpt_contains(@CreditAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(@CreditAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(@CreditAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
                              or master.dbo.fn_rpt_ends_with(@CreditAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') = 1 or 
                              master.dbo.fn_rpt_ends_with(@DebitAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') = 1)
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                 
                 
                 
                 
        
      go  CREATE FUNCTION fn_rpt_settlement_breakdown_6 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   (
					master.dbo.fn_rpt_contains(@DebitAccNr_acc_nr,  'TERMINAL_OWNER') =1 
					 	    AND  master.dbo.fn_rpt_contains(@DebitAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(@DebitAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
						   or  (
						    master.dbo.fn_rpt_contains(@CreditAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(@CreditAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(@CreditAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
                    
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                 
        
      go  CREATE FUNCTION fn_rpt_settlement_breakdown_7 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (    master.dbo.fn_rpt_ends_with(@CreditAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') = 1 or 
                              master.dbo.fn_rpt_ends_with(@DebitAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') = 1)
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
   */
SELECT   

  	bank_code = CASE 
	
                          
WHEN					(dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and  (master.dbo.fn_rpt_ends_with (DebitAccNr_acc_nr, 'FEE_PAYABLE') = 1 or master.dbo.fn_rpt_ends_with (CreditAccNr_acc_nr, 'FEE_PAYABLE') = 1 ))
                             then 'ISW' 

WHEN                      
			           (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			           (  (master.dbo.fn_rpt_ends_with (DebitAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1 OR (master.dbo.fn_rpt_ends_with (CreditAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1 )))
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'     
 
 WHEN

			(PT.PT_sink_node_name = 'SWTWEBUBAsnk')  
                        AND  
							((master.dbo.fn_rpt_ends_with (DebitAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1   ))
							OR (master.dbo.fn_rpt_ends_with (DebitAccNr_acc_nr, 'AMOUNT_PAYABLE')=1 
                        
                        OR (master.dbo.fn_rpt_ends_with (CreditAccNr_acc_nr, 'AMOUNT_PAYABLE')=1 OR
						(master.dbo.fn_rpt_ends_with (CreditAccNr_acc_nr, 'ISSUER_FEE_PAYABLE')=1))

						 )
					AND (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '312'  and PT.PT_tran_type = '50')
                                  
                                  AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'                            
                          
                          
WHEN                     dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1

                          AND ((PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') 
                                OR (PT.PTC_source_node_name = 'SWTFBPsrc' AND PT.PT_sink_node_name = 'ASPPOSVISsnk' 
                                 AND PT.PTC_totals_group = 'VISAGroup')
                               )
                          THEN 'UBA'
                          
                          
WHEN                       dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1

                          AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code = '627787')
                          THEN 'UNK'
                          
                          --AND (PT.PT_acquiring_inst_id_code <> '627480' or 
                          --(PT.PT_acquiring_inst_id_code = '627480'
                          --and dbo.fn_rpt_terminal_type(PT.PTC_terminal_id) ='3'))
                          
WHEN                      
			(PT.PT_sink_node_name = 'SWTWEBUBAsnk')  
                        AND  
			( master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,  'ISSUER_FEE_PAYABLE') = 1 
			 OR (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'AMOUNT_PAYABLE') = 1 
			   OR master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,  'ISSUER_FEE_PAYABLE') = 1   
                         OR  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'AMOUNT_PAYABLE') = 1))
  			 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                         PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'UBA'                             
                          
                          
                          
  WHEN                     dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1

                        AND  PT.PT_acquiring_inst_id_code <> '627787' 
                              AND PT.PT_sink_node_name = 'ASPPOSVISsnk'    
                          THEN 'UBA'     
                          
                                                    
 WHEN                     dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1

                        AND  PT.PT_acquiring_inst_id_code = '627787'  
                        AND PT.PT_sink_node_name = 'ASPPOSVISsnk'   
                          THEN 'GTB'       
                          
                           
                                                      
 WHEN                      
						(PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  
                           AND  
 dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1
                        
                          THEN 'ABP'   
                          
    WHEN                     
					 (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
 dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1

                                   
                          THEN 'GTB'                                                                        
                           
   WHEN                     
						 (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk')  AND
						 dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1

                                  
                          THEN 'EBN'  
                          
   WHEN                   
						(PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
						     dbo.fn_rpt_settlement_breakdown_1 (DebitAccNr_acc_nr , CreditAccNr_acc_nr ,PT.PT_tran_type ,PT.PTC_source_node_name ,PT.PT_sink_node_name ,PT.PT_payee , PT.PTC_card_acceptor_id_code ,PT.PTC_totals_group ,PT.PTC_pan , PT.PTC_terminal_id ,PT.PT_extended_tran_type,PT.PT_message_type   ) = 1

                                   
                          THEN 'UBA'                                             
WHEN PTT.PT_Retention_data = '1046' and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'UBN'
WHEN PTT.PT_Retention_data in ('9130','8130') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'ABS'
WHEN PTT.PT_Retention_data in ('9044','8044') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'ABP'
WHEN PTT.PT_Retention_data in ('9023','8023')  and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 then 'CITI'
WHEN PTT.PT_Retention_data in ('9050','8050') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'EBN'
WHEN PTT.PT_Retention_data in ('9214','8214') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'FCMB'
WHEN PTT.PT_Retention_data in ('9070','8070','1100') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'FBP'
WHEN PTT.PT_Retention_data in ('9011','8011') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'FBN'
WHEN PTT.PT_Retention_data in ('9058','8058')  and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 then 'GTB'
WHEN PTT.PT_Retention_data in ('9082','8082') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'KSB'
WHEN PTT.PT_Retention_data in ('9076','8076') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'SKYE'
WHEN PTT.PT_Retention_data in ('9084','8084') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'ENT'
WHEN PTT.PT_Retention_data in ('9039','8039') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 then 'IBTC'
WHEN PTT.PT_Retention_data in ('9068','8068') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'SCB'
WHEN PTT.PT_Retention_data in ('9232','8232','1105') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'SBP'
WHEN PTT.PT_Retention_data in ('9032','8032')  and 
                        dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 then 'UBN'
WHEN PTT.PT_Retention_data in ('9033','8033')  and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 then 'UBA'
WHEN PTT.PT_Retention_data in ('9215','8215')  and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 then 'UBP'
WHEN PTT.PT_Retention_data in ('9035','8035') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'WEMA'
WHEN PTT.PT_Retention_data in ('9057','8057') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'ZIB'
WHEN PTT.PT_Retention_data in ('9301','8301') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'JBP'
WHEN PTT.PT_Retention_data in ('9030') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1  then 'HBC'
						  
WHEN PTT.PT_Retention_data = '1411' and 
						    dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'HBC'
                          						                     	                                       
			
			
			WHEN PTT.PT_Retention_data = '1131' and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'WEMA'
                         WHEN PTT.PT_Retention_data in ('1061','1006') and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'GTB'
                         WHEN PTT.PT_Retention_data = '1708' and 
                            dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'FBN'
                         WHEN PTT.PT_Retention_data in ('1027','1045','1081','1015') and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'SKYE'
                         WHEN PTT.PT_Retention_data = '1037' and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'IBTC'
                         WHEN PTT.PT_Retention_data = '1034' and 
                             dbo.fn_rpt_settlement_breakdown_2 (DebitAccNr_acc_nr,CreditAccNr_acc_nr )  = 1 THEN 'EBN'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'UBA')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'UBA')= 1 ) THEN 'UBA'
			            WHEN ( master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'FBN')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'FBN')= 1 ) THEN 'FBN'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ZIB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ZIB')= 1 ) THEN 'ZIB' 
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'SPR')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'S')= 1 ) THEN 'ENT'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'GTB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'GTB')= 1 ) THEN 'GTB'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'PRU')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'PRU')= 1 ) THEN 'SKYE'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'OBI')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'OBI')= 1 ) THEN 'EBN'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'WEM')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'WEM')= 1 ) THEN 'WEMA'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'AFR')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'AFR')= 1 ) THEN 'MSB'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'IBTC')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'IBTC')= 1 ) THEN 'IBTC'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'PLAT')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'PLAT')= 1 ) THEN 'KSB'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'UBP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'UBP')= 1 ) THEN 'UBP'
                         WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'DBL')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'DBL')= 1 ) THEN 'DBL'

						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'FCMB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'FCMB')= 1 ) THEN 'FCMB'
						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'IBP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'IBP')= 1 ) THEN 'ABP'
						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'UBN')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'UBN')= 1 ) THEN 'UBN'
						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ETB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ETB')= 1 ) THEN 'ETB'
						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'FBP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'FBP')= 1 ) THEN 'FBP'
						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'SBP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'SBP')= 1 ) THEN 'SBP'
						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ABP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ABP')= 1 ) THEN 'ABP'
						WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'EBN')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'EBN')= 1 ) THEN 'EBN'

	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'CITI')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'CITI')= 1 )THEN 'CITI'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'FIN')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'FIN')= 1 ) THEN 'FCMB'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ASO')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ASO')= 1 ) THEN 'ASO'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'OLI')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'OLI')= 1 ) THEN 'OLI'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'HSL')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'HSL')= 1 ) THEN 'HSL'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ABS')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ABS')= 1 ) THEN 'ABS'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'PAY')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'PAY')= 1 ) THEN 'PAY'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ETB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'SAT')= 1 ) THEN 'SAT'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'SAT')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, '3LCM')= 1 ) THEN '3LCM'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'SCB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'SCB')= 1 ) THEN 'SCB'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'JBP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'JBP')= 1 ) THEN 'JBP'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'RSL')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'RSL')= 1 ) THEN 'RSL'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'PSH')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'PSH')= 1 ) THEN 'PSH'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'INF')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'INF')= 1 ) THEN 'INF'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'UML')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'UML')= 1 ) THEN 'UML'

	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ACCI')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ETB')= 1 ) THEN 'ACCI'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'EKON')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ekon')= 1 ) THEN 'EKON'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ATM')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ATM')= 1 ) THEN 'ATMC'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'HBC')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'HBC')= 1 ) THEN 'HBC'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'UNI')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'UNI')= 1 ) THEN 'UNI'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'UNC')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'UNC')= 1 ) THEN 'UNC'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'NCS')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'NCS')= 1 ) THEN 'NCS' 
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'HAG')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'HAG')= 1 ) THEN 'HAG'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'DBL')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'DBL')= 1 )THEN 'DBL'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'FGMB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'FGMB')= 1 ) THEN 'FGMB'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'CEL')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'CEL')= 1 ) THEN 'CEL'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'RDY')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'RDY')= 1 ) THEN 'RDY'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'AMJ')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'AMJ')= 1 ) THEN 'AMJU'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'CAP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'CAP')= 1 ) THEN 'O3CAP'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'VER')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'VER')= 1 ) THEN 'VER_GLOBAL'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'SMF')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'SMF')= 1 ) THEN 'SMFB'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'SLT')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'SLT')= 1 ) THEN 'SLTD'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'JES')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'JES')= 1 ) THEN 'JES'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'MOUA')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'MOUA')= 1 ) THEN 'MOUA'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'MUT')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'MUT')= 1 ) THEN 'MUT'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'LAV')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'LAV')= 1 ) THEN 'LAV'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'JUB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'JUB')= 1 ) THEN 'JUB'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'WET')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'WET')= 1 )THEN 'WET'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'AGH')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'AGH')= 1 ) THEN 'AGH'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'TRU')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'TRU')= 1 ) THEN 'TRU'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'CON')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'CON')= 1 ) THEN 'CON'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ETB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'CRU')= 1 ) THEN 'CRU'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'NPR')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'NPR')= 1 ) THEN 'NPR'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'OMO')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'OMO')= 1 ) THEN 'OMO'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'SUN')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'SUN')= 1 ) THEN 'SUN'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'NGB')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'NGB')= 1 ) THEN 'NGB'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'OSC')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'OSC')= 1 ) THEN 'OSC'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'OSP')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'OSP')= 1 ) THEN 'OSP'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'IFIS')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'IFIS')= 1 ) THEN 'IFIS'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'NPM')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'NPM')= 1 ) THEN 'NPM'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'POL')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'POL')= 1 ) THEN 'POL'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ALV')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ALV')= 1 ) THEN 'ALV'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'MAY')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'MAY')= 1 ) THEN 'MAY'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'PRO')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'PRO')= 1 ) THEN 'PRO'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'UNIL')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'UNIL')= 1 ) THEN 'UNIL'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'PAR')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'PAR')= 1 ) THEN 'PAR'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'FOR')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'FOR')= 1 ) THEN 'FOR'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'MON')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'MON')= 1 ) THEN 'MON'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'NDI')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'NDI')= 1 ) THEN 'NDI'
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ARM')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'ARM')= 1 ) THEN 'ARM'	
	WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'OKW')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'OKW')= 1 ) THEN 'OKW'										
    WHEN (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'POS_FOODCONCEPT')= 1 OR  master.dbo.fn_rpt_starts_with ( CreditAccNr_acc_nr, 'POS_FOODCONCEPT')= 1 ) THEN 'SCB'
    WHEN ((master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ISW')=1 and  master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'POOL')!=1 ) OR
   (master.dbo.fn_rpt_starts_with ( DebitAccNr_acc_nr, 'ISW')>0 and  master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'POOL') !=1) ) THEN 'ISW'

ELSE 'UNK'	
		
END,
	trxn_category=CASE WHEN (PT.PT_tran_type ='01')  
							AND dbo.fn_rpt_CardGroup(PT.PTC_PAN) in ('1','4')
                           AND PT.PTC_source_node_name = 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE INTERNATIONAL)'
                           
                           WHEN dbo.fn_rpt_settlement_breakdown_3 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1
                            
                           and PT.PT_tran_type ='50'  then 'MASTERCARD LOCAL PROCESSING BILLING(PAYMENTS)'

                           WHEN (master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'Mcard') = 1  and master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'Billing') =1 ) OR ( master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr, 'Mcard') = 1  and master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr, 'Billing') =1)
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name = 'VTUsrc'  then 'MASTERCARD LOCAL PROCESSING BILLING(RECHARGE)'
                
                           WHEN dbo.fn_rpt_settlement_breakdown_3 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1 
                           
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ('2','5','6')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(POS PURCHASE)'

                           WHEN dbo.fn_rpt_settlement_breakdown_3 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1 
                             
                           and PT.PT_tran_type ='00' and PT.PTC_source_node_name <> 'VTUsrc'  and PT.PT_sink_node_name <> 'VTUsnk'
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ('3')
                           then 'MASTERCARD LOCAL PROCESSING BILLING(WEB PURCHASE)'

                            WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                            
                           and dbo.fn_rpt_settlement_breakdown_4 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 1 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Verve Token)'
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                          and dbo.fn_rpt_settlement_breakdown_4 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 2 
                           THEN 'ATM WITHDRAWAL (Cardless:Paycode Non-Verve Token)'
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                          and dbo.fn_rpt_settlement_breakdown_4 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1
                           AND PT.PT_sink_node_name = 'ESBCSOUTsnk'
                           and dbo.fn_rpt_Cardless(PT.PT_extended_tran_type) = 3 
                           THEN 'ATM WITHDRAWAL (Cardless:Non-Card Generated)'

						   WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and (( master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'ATM') = 1  AND master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISO') = 1 )
                           OR  ( master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'ATM') = 1  AND master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISO') = 1 ))
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           AND PT.PTC_source_node_name <> 'ASPSPNOUsrc'                           
                           THEN 'ATM WITHDRAWAL (MASTERCARD ISO)'


                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                           and dbo.fn_rpt_settlement_breakdown_4 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           AND PT.PTC_source_node_name <> 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (REGULAR)'
                           
                                                                           
                           
                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 

                          and dbo.fn_rpt_settlement_breakdown_4 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1
                           AND PT.PTC_source_node_name <> 'SWTMEGAsrc'
                           THEN 'ATM WITHDRAWAL (VERVE BILLING)'

                           WHEN (PT.PT_tran_type ='01'  AND (SUBSTRING(PT.PTC_terminal_id,1,1)= '1' or SUBSTRING(PT.PTC_terminal_id,1,1)= '0')) 
                            and dbo.fn_rpt_settlement_breakdown_4 (DebitAccNr_acc_nr,CreditAccNr_acc_nr) = 1
                           AND PT.PTC_source_node_name = 'ASPSPNOUsrc'
                           THEN 'ATM WITHDRAWAL (SMARTPOINT)'
 
			               WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' and 
                           (master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'BILLPAYMENT MCARD')   =1  or  master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr, 'BILLPAYMENT MCARD')   =1 )) then 'BILLPAYMENT MASTERCARD BILLING'

                           WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' 
                           and ( master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr , 'SVA_FEE_RECEIVABLE') = 1  or  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr , 'SVA_FEE_RECEIVABLE') = 1  ) ) 
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
                            and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)
                              )
                              
                              THEN 'POS(GENERAL MERCHANT)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '2'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) THEN 'POS(CHURCHES, FASTFOODS & NGOS)'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '3'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1 ))THEN 'POS(CONCESSION)PURCHASE'

                           WHEN ( dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '4'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) THEN 'POS(TRAVEL AGENCIES)PURCHASE'
                           

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '5'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1 )) THEN 'POS(HOTELS)PURCHASE'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '6'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) THEN 'POS(WHOLESALE)PURCHASE'
                    
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '14'
                            and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                            and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1 )) THEN 'POS(WHOLESALE_ACQUIRER_BORNE)PURCHASE'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '7'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and not ((
						    master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
						   or  (
						    master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
                           or   master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') =1 OR 
							master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') =1
							)) THEN 'POS(FUEL STATION)PURCHASE'
 
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '8'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not ((
						    master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
						   or  (
						    master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
                           or     master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') =1  OR 
							master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE') =1  ) )THEN 'POS(EASYFUEL)PURCHASE'
                           
                           WHEN  (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='1'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1) ) THEN 'POS(TRAVEL AGENCIES-VISA)PURCHASE'
                     
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='2'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) THEN 'POS(WHOLESALE CLUBS-VISA)PURCHASE'
                           
                           WHEN (dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) ='3'
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
                           
                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                            and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.PTC_merchant_type
                              
                            WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type)= '29'
                           and dbo.fn_rpt_MCC_Visa (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type,PT.PTC_PAN) is NULL
                           and (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1 OR PT.PT_tran_type = '50')
                            and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) THEN 'POS(VAS CLOSED SCHEME)PURCHASE'+'_'+PT.PTC_merchant_type
                              
                              
                              WHEN (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name IN ('SWTWEBEBNsnk','SWTWEBUBAsnk','SWTWEBGTBsnk','SWTWEBABPsnk'))
                              and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                              and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee
                              ,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
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
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1) THEN 'Verify card ? Ecash load'

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
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1 )THEN 'POS(GENERAL MERCHANT)PURCHASE' 

                             WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)THEN 'POS PURCHASE WITH CASHBACK'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and not (dbo.fn_rpt_settlement_breakdown_5(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1) THEN 'POS CASHWITHDRAWAL'

                           
                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and ( (
						    master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
						   or  (
						    master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,  'RECEIVABLE') = 1 
							))) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and ((
						    master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,  'RECEIVABLE') = 1 
							)
						   or  (
						    master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'TERMINAL_OWNER') =1 
						    AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'FEE') =1
							AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,  'RECEIVABLE') = 1 
							))) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (dbo.fn_rpt_settlement_breakdown_6(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'Fees collected for all Terminal_owners'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (dbo.fn_rpt_settlement_breakdown_6(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'Fees collected for all Terminal_owners'


                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (dbo.fn_rpt_settlement_breakdown_6(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'Fees collected for all Terminal_owners'
                           
                           WHEN (PT.PT_tran_type = '50' and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (dbo.fn_rpt_settlement_breakdown_7(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'Fees collected for all PTSPs'


                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) in ('1','2','3','4','5','6','7','8','14')
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and ( dbo.fn_rpt_settlement_breakdown_7(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1
                           and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (dbo.fn_rpt_settlement_breakdown_7(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '1'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') 
                           and (dbo.fn_rpt_settlement_breakdown_7(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'

                           WHEN (dbo.fn_rpt_MCC_cashback (PT.PTC_terminal_id, PT.PT_tran_type) = '2'
                           and dbo.fn_rpt_isPurchaseTrx_sett_cashback(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2 and 

                           SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                           and (dbo.fn_rpt_settlement_breakdown_7(DebitAccNr_acc_nr,CreditAccNr_acc_nr ) = 1)) 
                           THEN 'FEES COLLECTED FOR ALL PTSPs'



                           WHEN (dbo.fn_rpt_MCC (PT.PTC_merchant_type,PT.PTC_terminal_id,PT.PT_tran_type) is NULL
                           and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                           and SUBSTRING(PT.PTC_terminal_id,1,1)= '3' THEN 'WEB(GENERIC)PURCHASE'

                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and ( master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'fee') =1 OR   master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'fee') =1)
                                 and (PT.PT_tran_type in ('50') or(dbo.fn_rpt_autopay_intra_sett (PT.PTC_source_node_name,PT.PT_tran_type,PT.PT_payee) = 1))
                                 and not (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'PREPAIDLOAD') =1 OR   master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'PREPAIDLOAD') =1)) THEN 'AUTOPAY TRANSFER FEES'
                          
                           
                           WHEN (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,

                                  PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '313' 
                                 and (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'fee') !=1 OR   master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'fee') !=1)

                                 and PT.PT_tran_type in ('50')
                                 and not (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,  'PREPAIDLOAD') =1 OR   master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,  'PREPAIDLOAD') =1)) THEN 'AUTOPAY TRANSFERS'
                                 
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
                                 AND ( NOT (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') = 1) AND NOT (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr,'RECEIVABLE') = 1)) then 'PREPAID MERCHANDISE'
                           
                           WHEN (dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 2)
                                 AND ((master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') = 1) or (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') = 1)) then 'PREPAID MERCHANDISE DUE ISW'--the unk% is excempted from the bank's net
                           
                                                      
                          WHEN (dbo.fn_rpt_isCardload (PT.PTC_source_node_name ,PT.PTC_pan, PT.PT_tran_type)= '1') then 'PREPAID CARDLOAD'

                          when PT.PT_tran_type = '21' then 'DEPOSIT'
                          ELSE 'UNK'		

END,
  Debit_account_type=CASE 
                    
                      WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE')  =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'
                          
                     WHEN 
                      PT.PT_sink_node_name = 'ASPPOSVISsnk'  AND
                     (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE')  =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                        THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'
                      
                      WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND
                        master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                        
                        THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                          
                       WHEN 
                       PT.PT_sink_node_name = 'ASPPOSVISsnk' AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND
                        master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                       
                          THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'    
                        
                    WHEN                      
			        (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1') 
                        AND  
			        (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND
			          master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1)
                         AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                         THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'     
                        
                      WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk'  AND
                    (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr , 'AMOUNT') =1  AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr , 'PAYABLE') =1)
		             and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6'                        
                     THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'

					WHEN 
                     PT.PT_sink_node_name = 'SWTWEBUBAsnk' AND
                     (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr , 'ISSUER') =  1 AND master.dbo.fn_rpt_contains(DebitAccNr_acc_nr , 'FEE') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr , 'PAYABLE') =1
					 and (dbo.fn_rpt_transfers_sett(PT.PTC_terminal_id,PT.PT_payee,PT.PTC_card_acceptor_name_loc,
                     PT.PT_extended_tran_type ,PT.PTC_source_node_name) = '1' and PT.PT_tran_type = '50')
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' )  
		             THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'    
                           
                          
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr,  'AMOUNT') =1 AND master.dbo.fn_rpt_ends_with (DebitAccNr_acc_nr,  'PAYABLE') = 1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                     (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1  ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPABPsrc' AND PT.PT_sink_node_name = 'SWTWEBABPsnk')  AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND 
                       master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'     
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1 )
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code 
                      ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1 
                       AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPGTBsrc' AND PT.PT_sink_node_name = 'SWTWEBGTBsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPEBNsrc' AND PT.PT_sink_node_name = 'SWTWEBEBNsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'   
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Debit_Nr)'   
                        
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      
                      THEN 'VISA CO-ACQUIRER FEE PAYABLE(Debit_Nr)'
                      
                      WHEN 
                      (PT.PTC_source_node_name = 'SWTASPWEBsrc' AND PT.PT_sink_node_name = 'SWTWEBUBAsnk') AND
                      (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                     
                      THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE(Debit_Nr)'  
                      
                       
                      
                      WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1 ) THEN 'AMOUNT PAYABLE(Debit_Nr)'
	                  WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1 ) THEN 'AMOUNT RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'RECHARGE') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1) THEN 'RECHARGE FEE PAYABLE(Debit_Nr)'  
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ACQUIRER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1) THEN 'ACQUIRER FEE PAYABLE(Debit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'CO') = 1 AND master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ACQUIRER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'CO-ACQUIRER FEE RECEIVABLE(Debit_Nr)'   
                          WHEN ( master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ACQUIRER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'ACQUIRER FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1) THEN 'ISSUER FEE PAYABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'CARDHOLDER') = 1 AND master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'SCH') = 1 AND master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN ( master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) THEN 'ISSUER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYIN_INSTITUTION_FEE_RECEIVABLE') =1) THEN 'PAYIN INSTITUTION FEE RECEIVABLE(Debit_Nr)'
                          WHEN ((master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISW') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PAYABLE') =1)) THEN 'ISW FEE PAYABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr,'ISW_ATM_FEE_CARD_SCHEME') =1) THEN 'ISW CARD SCHEME FEE RECEIVABLE (Debit_Nr)'
                          WHEN ( master.dbo.fn_rpt_contains (DebitAccNr_acc_nr,'ISW_ATM_FEE_ACQ_') =1) THEN 'ISW ACQUIRER FEE RECEIVABLE (Debit_Nr)'
                          WHEN ( master.dbo.fn_rpt_contains (DebitAccNr_acc_nr,'ISW_ATM_FEE_ISS_') =1) THEN 'ISW ISSUER FEE RECEIVABLE (Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '1')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1')THEN 'ISW VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'


                          WHEN ( master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '2')
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE ECOBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '3') 

                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '4') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE(Debit_Nr)'
                           
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '5') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW 3LCM FEE RECEIVABLE(Debit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '6') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '7') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '8') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW NON-VERVE UBA FEE RECEIVABLE(Debit_Nr)'
               
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 
                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME,PT.PT_TRAN_TYPE,PT.PTC_terminal_id) = '10') 
                          and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '0','1') THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE(Debit_Nr)'

                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISW') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 

                          AND dbo.fn_rpt_CardType (PT.PTC_PAN ,PT.PT_SINK_NODE_NAME ,PT.PT_TRAN_TYPE,PT.PTC_terminal_id)= '9'
                          AND NOT ((
						  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISO') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 
						  
						     ) OR master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'PTSP_FEE_RECEIVABLE')  =1)OR (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'TERMINAL') = 1 AND master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1) OR ((master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'PROCESSOR') = 1 AND master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1)) OR ((master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'NCS') = 1 AND master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'FEE') = 1  AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'RECEIVABLE') =1)))
						     
						     THEN 'ISW FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr , 'POS_FOODCONCEPT') = 1) THEN 'FOODCONCEPT.PT_TERMINAL_OWNER_FEE_RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISO') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'ISO FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'TERMINAL_OWNER') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'TERMINAL_OWNER FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'PROCESSOR') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'PROCESSOR FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'POOL_ACCOUNT')=1) THEN 'POOL ACCOUNT(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ATMC') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'PAYABLE') =1 ) THEN 'ATMC FEE PAYABLE(Debit_Nr)'  
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ATMC') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'ATMC FEE RECEIVABLE(Debit_Nr)'  
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'FEE_POOL') = 1 ) THEN 'FEE POOL(Debit_Nr)'  
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'EASYFUEL_ACCOUNT')= 1 ) THEN 'EASYFUEL ACCOUNT(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'MERCHANT') =1 
						  AND  
						  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1
						  AND
						  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 ) THEN 'MERCHANT FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'YPM') =1 AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1 AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1 )THEN 'YPM FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FLEETTECH') =1 AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1 AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1) THEN 'FLEETTECH FEE RECEIVABLE(Debit_Nr)' 
                          WHEN (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'LYSA') =1 AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'FEE') =1 AND  master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'RECEIVABLE') =1) THEN 'LYSA FEE RECEIVABLE(Debit_Nr)'

                         
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'SVA_FEE_RECEIVABLE') =1) THEN 'SVA FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'UDIRECT_FEE_RECEIVABLE') =1) THEN 'UDIRECT FEE RECEIVABLE(Debit_Nr)'
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr,'PTSP_FEE_RECEIVABLE') =1 ) THEN 'PTSP FEE RECEIVABLE(Debit_Nr)'
                            
                          WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'NCS_FEE_RECEIVABLE')=1 ) THEN 'NCS FEE RECEIVABLE(Debit_Nr)'  
			  WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'SVA_SPONSOR_FEE_PAYABLE')=1 ) THEN 'SVA SPONSOR FEE PAYABLE(Debit_Nr)'
			  WHEN (master.dbo.fn_rpt_ends_with(DebitAccNr_acc_nr, 'SVA_SPONSOR_FEE_RECEIVABLE')=1 ) THEN 'SVA SPONSOR FEE RECEIVABLE(Debit_Nr)'                      

                          ELSE 'UNK'			
END,
  Credit_account_type=CASE  
  
  
                       
                      WHEN (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'AMOUNT') = 1 AND master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE')  =1 ) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787') THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE(Credit_Nr)'
                      
                      WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  
                      AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'PAYABLE') =1) 
                      and dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan ) = 1
                      and (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = 0)
                      AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' 
                      AND (PT.PTC_source_node_name = 'SWTNCS2src' AND PT.PT_sink_node_name = 'ASPPOSVINsnk' and 
                          PT.PT_acquiring_inst_id_code <> '627787')THEN 'VISA CO-ACQUIRER FEE PAYABLE(Credit_Nr)'
                          
                       WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  
                       AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) 
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
                     AND dbo.fn_rpt_CardGroup(PT.PTC_pan) = '6' )  
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
                      (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'ISSUER') = 1 AND  master.dbo.fn_rpt_contains (CreditAccNr_acc_nr, 'FEE') = 1  
                      AND  master.dbo.fn_rpt_ends_with(CreditAccNr_acc_nr, 'RECEIVABLE') =1) 
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
                          WHEN (master.dbo.fn_rpt_contains (CreditAccNr_acc_nr,'ISW_ATM_FEE_CARD_SCHEME')=1) THEN 'ISW CARD SCHEME FEE RECEIVABLE (Credit_Nr)'
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
                          ELSE 'UNK'			
END,

       trxn_amount=ISNULL(J.amount,0),
	trxn_fee=ISNULL(J.fee,0),
	trxn_date=j.business_date,
        currency = CASE WHEN (dbo.fn_rpt_isBillpayment (PT.PTC_terminal_id,PT.PT_extended_tran_type,PT.PT_message_type,PT.PT_sink_node_name,PT.PT_payee,PT.PTC_card_acceptor_id_code ,PT.PTC_source_node_name,PT.PT_tran_type,PT.PTC_pan) = '1' and 
                           (master.dbo.fn_rpt_contains(DebitAccNr_acc_nr , 'BILLPAYMENT MCARD') = 1 or master.dbo.fn_rpt_contains(CreditAccNr_acc_nr , 'BILLPAYMENT MCARD') = 1 ) ) THEN '840'
                        WHEN ((master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'Mcard') = 1  and master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'Billing') =1 ) OR ( master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr, 'Mcard') = 1  and master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr, 'Billing') =1)  and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTUBAsnk','SWTJBPsnk','SWTJAIZsnk'))) THEN '840'
						WHEN ((master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr,'ATM') = 1 AND master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr,'ISO') = 1 AND master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr,'ACQUIRER') =1 OR master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr,'ATM') = 1 AND master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr,'ISO') = 1 AND master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr,'ACQUIRER') =1) ) THEN '840'
						WHEN ((master.dbo.fn_rpt_contains(DebitAccNr_acc_nr, 'ATM_FEE_ACQ_ISO') = 1  OR master.dbo.fn_rpt_contains(CreditAccNr_acc_nr, 'ATM_FEE_ACQ_ISO') = 1) ) THEN '840'
						WHEN ((master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ATM') = 1 AND master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISO') = 1  AND  master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ISSUER') = 1) OR (master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ATM') = 1 AND master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISO') = 1  AND  master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ISSUER') = 1)) and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTPLATsnk')) THEN '840'
						WHEN ((master.dbo.fn_rpt_contains(DebitAccNr_acc_nr,'ATM_FEE_ISS_ISO')  = 1 OR master.dbo.fn_rpt_contains(CreditAccNr_acc_nr,'ATM_FEE_ISS_ISO')  =1) and( PT.PT_sink_node_name not in ('SWTFBPsnk','SWTABPsnk','SWTIBPsnk','SWTPLATsnk'))) THEN '840'
					    ELSE PT.PT_settle_currency_code END,
        late_reversal = CASE
        
                        WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6')
                               and PT.PTC_merchant_type in ('5371','2501','2504','2505','2506','2507','2508','2509','2510','2511','4814','4812') THEN 0
                               
						WHEN ( dbo.fn_rpt_late_reversal(PT.PT_tran_nr,PT.PT_message_type,PT.PT_retrieval_reference_nr) = 1
                               and  dbo.fn_rpt_isPurchaseTrx_sett(PT.PT_tran_type,PT.PTC_source_node_name, PT.PT_sink_node_name,PT.PTC_terminal_id ,PT.PTC_totals_group ,PT.PTC_pan) = 1)
                               and SUBSTRING(PT.PTC_terminal_id,1,1) in ( '2','5','6') THEN 1
						ELSE 0
					        END,
        card_type =  dbo.fn_rpt_CardGroup(PT.PTC_pan),
        terminal_type = dbo.fn_rpt_terminal_type(PT.PTC_terminal_id),    
        source_node_name =   PT.PTC_source_node_name,
        Unique_key = PT.PT_retrieval_reference_nr+'_'+PT.PT_system_trace_audit_nr+'_'+PT.PTC_terminal_id+'_'+ cast((CONVERT(NUMERIC (15,2),isnull(PT.PT_settle_amount_impact,0))) as VARCHAR(30) )+'_'+PT.PT_message_type,
        Acquirer = (case when (not ((master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'ISW')  =1   and  master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'POOL')  !=1  ) OR 
        (master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,  'ISW')  =1   and  master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,'pool')!=1 ) ))then ''
                      when (master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'ISW')  =1   and  master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'POOL')  !=1 
                        OR (master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,  'ISW') ) =1   and  master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,  'POOL')!=1)
                       AND (acc.acquirer_inst_id1 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id2 = PT.PT_acquiring_inst_id_code or acc.acquirer_inst_id3 = PT.PT_acquiring_inst_id_code oR acc.acquirer_inst_id4 = PT.PT_acquiring_inst_id_code oR acc.acquirer_inst_id5 = PT.PT_acquiring_inst_id_code) then acc.bank_code 
                      else PT.PT_acquiring_inst_id_code END),
        Issuer = (case when (Not (master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'ISW')  =1   and  master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'POOL')  !=1 )
        OR ( master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,  'ISW')  =1   and  master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,'pool')!=1  )) then ''
                      when ((master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'ISW')  =1
                         and  master.dbo.fn_rpt_starts_with(DebitAccNr_acc_nr,  'POOL')  !=1  ) OR ( master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,  'ISW')  =1   
                         and  master.dbo.fn_rpt_starts_with(CreditAccNr_acc_nr,  'POOL')  !=1 ) and (substring(PT.PTC_totals_group,1,3) = acc.bank_code1) )
                      then acc.bank_code
                      else substring(PT.PTC_totals_group,1,3) END),
       Volume = (case when PT.PT_message_type in ('0200','0220') then 1
	                   else 0 end),  
           Value_RequestedAmount = PT.PT_settle_amount_req,
          Value_SettleAmount = PT.PT_settle_amount_impact,pt.pt_post_tran_id as ptid ,pt.pt_post_tran_cust_id as ptcid,
                index_no = IDENTITY(INT,1,1)     
		
		,[adj_id]
		,[entry_id]
		,[config_set_id]
		,[session_id]
		,[sdi_tran_id]
		,[acc_post_id]
		,[nt_fee_acc_post_id]
		,[coa_id]
		,[coa_se_id]
		,[se_id]
		,[amount]
		,[amount_id]
		,[amount_value_id]
		,[fee]
		, [fee_id]
		, [fee_value_id]
		,[nt_fee]
		,[nt_fee_id]
		,[nt_fee_value_id]
		,[debit_acc_nr_id]
		,[debit_acc_id]
		,[debit_cardholder_acc_id]
		,[debit_cardholder_acc_type]
		,[credit_acc_nr_id]
		,[credit_acc_id]
		,[credit_cardholder_acc_id]
		,[credit_cardholder_acc_type]
		,[business_date]
		,[granularity_element]
		,[tag]
		,[spay_session_id]
		,[spst_session_id]
		,[DebitAccNr_config_set_id]
		,[DebitAccNr_acc_nr_id]
		,[DebitAccNr_se_id]
		,[DebitAccNr_acc_id]
		,[DebitAccNr_acc_nr]
		,[DebitAccNr_aggregation_id]
		,[DebitAccNr_state]
		,[DebitAccNr_config_state]
		,[CreditAccNr_config_set_id]
		,[CreditAccNr_acc_nr_id]
		,[CreditAccNr_se_id]
		,[CreditAccNr_acc_id]
		,[CreditAccNr_acc_nr]
		,[CreditAccNr_aggregation_id]
		,[CreditAccNr_state]
		,[CreditAccNr_config_state]
		,[Amount_config_set_id]
		,[Amount_amount_id]
		,[Amount_se_id]
		,[Amount_name]
		,[Amount_description]
		,[Amount_config_state]
		,[Fee_config_set_id]
		,[Fee_fee_id]
		,[Fee_se_id]
		,[Fee_name]
		,[Fee_description]
		,[Fee_type]
		,[Fee_amount_id]
		,[Fee_config_state]
		,[coa_config_set_id]
		,[coa_coa_id]
		,[coa_name]
		,[coa_description]
		,[coa_type]
		,[coa_config_state]
		,pt.[pt_batch_nr]
		,pt.[PT_post_tran_id] 
		,pt.[PT_post_tran_cust_id]  
      ,pt.[PT_settle_entity_id]
      ,pt.[PT_prev_post_tran_id]
      ,pt.[PT_next_post_tran_id]
      ,pt.[PT_sink_node_name]
      ,pt.[PT_tran_postilion_originated]
      ,pt.[PT_tran_completed]
      ,pt.[PT_message_type]
      ,pt.[PT_tran_type]
      ,pt.[PT_tran_nr]
      ,pt.[PT_system_trace_audit_nr]
      ,pt.[PT_rsp_code_req]
      ,pt.[PT_rsp_code_rsp]
      ,pt.[PT_abort_rsp_code]
      ,pt.[PT_auth_id_rsp]
      ,pt.[PT_auth_type]
      ,pt.[PT_auth_reason]
      ,pt.[PT_retention_data]
      ,pt.[PT_acquiring_inst_id_code]
      ,pt.[PT_message_reason_code]
      ,pt.[PT_sponsor_bank]
      ,pt.[PT_retrieval_reference_nr]
      ,pt.[PT_datetime_tran_gmt]
      ,pt.[PT_datetime_tran_local]
      ,pt.[PT_datetime_req]
      ,pt.[PT_datetime_rsp]
      ,pt.[PT_realtime_business_date]
      ,pt.[PT_recon_business_date]
      ,pt.[PT_from_account_type]
      ,pt.[PT_to_account_type]
      ,pt.[PT_from_account_id]
      ,pt.[PT_to_account_id]
      ,pt.[PT_tran_amount_req]
      ,pt.[PT_tran_amount_rsp]
      ,pt.[PT_settle_amount_impact]
      ,pt.[PT_tran_cash_req]
      ,pt.[PT_tran_cash_rsp]
      ,pt.[PT_tran_currency_code]
      ,pt.[PT_tran_tran_fee_req]
      ,pt.[PT_tran_tran_fee_rsp]
      ,pt.[PT_tran_tran_fee_currency_code]
      ,pt.[PT_tran_proc_fee_req]
      ,pt.[PT_tran_proc_fee_rsp]
      ,pt.[PT_tran_proc_fee_currency_code]
      ,pt.[PT_settle_amount_req]
      ,pt.[PT_settle_amount_rsp]
      ,pt.[PT_settle_cash_req]
      ,pt.[PT_settle_cash_rsp]
      ,pt.[PT_settle_tran_fee_req]
      ,pt.[PT_settle_tran_fee_rsp]
      ,pt.[PT_settle_proc_fee_req]
      ,pt.[PT_settle_proc_fee_rsp]
      ,pt.[PT_settle_currency_code]
      ,pt.[PT_pos_entry_mode]
      ,pt.[PT_pos_condition_code]
      ,pt.[PT_additional_rsp_data]
      ,pt.[PT_tran_reversed]
      ,pt.[PT_prev_tran_approved]
      ,pt.[PT_issuer_network_id]
      ,pt.[PT_acquirer_network_id]
      ,pt.[PT_extended_tran_type]
      ,pt.[PT_from_account_type_qualifier]
      ,pt.[PT_to_account_type_qualifier]
      ,pt.[PT_bank_details]
      ,pt.[PT_payee]
      ,pt.[PT_card_verification_result]
      ,pt.[PT_online_system_id]
      ,pt.[PT_participant_id]
      ,pt.[PT_opp_participant_id]
      ,pt.[PT_receiving_inst_id_code]
      ,pt.[PT_routing_type]
      ,pt.[PT_pt_pos_operating_environment]
      ,pt.[PT_pt_pos_card_input_mode]
      ,pt.[PT_pt_pos_cardholder_auth_method]
      ,pt.[PT_pt_pos_pin_capture_ability]
      ,pt.[PT_pt_pos_terminal_operator]
      ,pt.[PT_source_node_key]
      ,pt.[PT_proc_online_system_id]
      ,pt.[PTC_post_tran_cust_id]
      ,pt.[PTC_source_node_name]
      ,pt.[PTC_draft_capture]
      ,pt.[PTC_pan]
      ,pt.[PTC_card_seq_nr]
      ,pt.[PTC_expiry_date]
      ,pt.[PTC_service_restriction_code]
      ,pt.[PTC_terminal_id]
      ,pt.[PTC_terminal_owner]
      ,pt.[PTC_card_acceptor_id_code]
      ,pt.[PTC_mapped_card_acceptor_id_code]
      ,pt.[PTC_merchant_type]
      ,pt.[PTC_card_acceptor_name_loc]
      ,pt.[PTC_address_verification_data]
      ,pt.[PTC_address_verification_result]
      ,pt.[PTC_check_data]
      ,pt.[PTC_totals_group]
      ,pt.[PTC_card_product]
      ,pt.[PTC_pos_card_data_input_ability]
      ,pt.[PTC_pos_cardholder_auth_ability]
      ,pt.[PTC_pos_card_capture_ability]
      ,pt.[PTC_pos_operating_environment]
      ,pt.[PTC_pos_cardholder_present]
      ,pt.[PTC_pos_card_present]
      ,pt.[PTC_pos_card_data_input_mode]
      ,pt.[PTC_pos_cardholder_auth_method]
      ,pt.[PTC_pos_cardholder_auth_entity]
      ,pt.[PTC_pos_card_data_output_ability]
      ,pt.[PTC_pos_terminal_output_ability]
      ,pt.[PTC_pos_pin_capture_ability]
      ,pt.[PTC_pos_terminal_operator]
      ,pt.[PTC_pos_terminal_type]
      ,pt.[PTC_pan_search]
      ,pt.[PTC_pan_encrypted]
      ,pt.[PTC_pan_reference]
													INTO settle_tran_details_tab_20170404
														 
														 FROM 
														 (select  [adj_id]
															  ,[entry_id]
															  ,[config_set_id]
															  ,[session_id]
															  ,[post_tran_id]
															  ,[post_tran_cust_id]
															  ,[sdi_tran_id]
															  ,[acc_post_id]
															  ,[nt_fee_acc_post_id]
															  ,[coa_id]
															  ,[coa_se_id]
															  ,[se_id]
															  ,[amount]
															  ,[amount_id]
															  ,[amount_value_id]
															  ,[fee]
															  ,[fee_id]
															  ,[fee_value_id]
															  ,[nt_fee]
															  ,[nt_fee_id]
															  ,[nt_fee_value_id]
															  ,[debit_acc_nr_id]
															  ,[debit_acc_id]
															  ,[debit_cardholder_acc_id]
															  ,[debit_cardholder_acc_type]
															  ,[credit_acc_nr_id]
															  ,[credit_acc_id]
															  ,[credit_cardholder_acc_id]
															  ,[credit_cardholder_acc_type]
															  ,[business_date]
															  ,[granularity_element]
															  ,[tag]
															  ,[spay_session_id]
															  ,[spst_session_id]
															  ,[DebitAccNr_config_set_id]
															  ,[DebitAccNr_acc_nr_id]
															  ,[DebitAccNr_se_id]
															  ,[DebitAccNr_acc_id]
															  ,[DebitAccNr_acc_nr]
															  ,[DebitAccNr_aggregation_id]
															  ,[DebitAccNr_state]
															  ,[DebitAccNr_config_state]
															  ,[CreditAccNr_config_set_id]
															  ,[CreditAccNr_acc_nr_id]
															  ,[CreditAccNr_se_id]
															  ,[CreditAccNr_acc_id]
															  ,[CreditAccNr_acc_nr]
															  ,[CreditAccNr_aggregation_id]
															  ,[CreditAccNr_state]
															  ,[CreditAccNr_config_state]
															  ,[Amount_config_set_id]
															  ,[Amount_amount_id]
															  ,[Amount_se_id]
															  ,[Amount_name]
															  ,[Amount_description]
															  ,[Amount_config_state]
															  ,[Fee_config_set_id]
															  ,[Fee_fee_id]
															  ,[Fee_se_id]
															  ,[Fee_name]
															  ,[Fee_description]
															  ,[Fee_type]
															  ,[Fee_amount_id]
															  ,[Fee_config_state]
															  ,[coa_config_set_id]
															  ,[coa_coa_id]
															  ,[coa_name]
															  ,[coa_description]
															  ,[coa_type]
															  ,[coa_config_state] from  temp_journal_data_test (NOLOCK)   )J
																			 JOIN 
												 (SELECT * FROM temp_post_tran_data_test (NOLOCK) WHERE PT_tran_postilion_originated =0)   PT 
													ON (J.post_tran_id = PT.PT_post_tran_id   and substring(pt.ptc_terminal_id,1,1)!='G')
												LEFT   JOIN 
								  (SELECT  PT_post_tran_id,PT_post_tran_cust_id,ptc_terminal_id,PT_tran_nr, PT_retention_data FROM temp_post_tran_data_test (NOLOCK) WHERE PT_tran_postilion_originated =1)PTT 
																ON
																(PT.PT_post_tran_cust_id = PTT.PT_post_tran_cust_id and substring(ptT.ptc_terminal_id,1,1)!='G' and PT.PT_tran_nr = PTT.PT_tran_nr)  
																   LEFT OUTER JOIN aid_cbn_code acc ON
														  pt.PT_acquiring_inst_id_code  = COALESCE(acc.acquirer_inst_id1,acc.acquirer_inst_id2,acc.acquirer_inst_id3,acc.acquirer_inst_id4,acc.acquirer_inst_id5)
														   
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
															   and not (master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'Mcard') = 1  and master.dbo.fn_rpt_contains ( DebitAccNr_acc_nr, 'Billing') =1 ) OR ( master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr, 'Mcard') = 1  and master.dbo.fn_rpt_contains ( CreditAccNr_acc_nr, 'Billing') =1) )
															  AND pt.PTC_totals_group <>'CUPGroup'
															  and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_acquiring_inst_id_code = '627787')
															  and NOT (PT.PTC_totals_group in ('VISAGroup') and PT.PT_sink_node_name not in ('ASPPOSVINsnk')
																		and not (pt.ptc_source_node_name in ('SWTFBPsrc','SWTUBAsrc','SWTZIBsrc','SWTPLATsrc') and PT.PT_sink_node_name = 'ASPPOSVISsnk') 
																	   )
															 and not (PT.ptc_source_node_name  = 'MEGATPPsrc' and PT.PT_tran_type = '00' ) 														 
	
														  OPTION (RECOMPILE,optimize for unknown,maxdop 8)