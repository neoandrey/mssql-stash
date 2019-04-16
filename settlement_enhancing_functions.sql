                   
         
   CREATE function fn_rpt_settlement_breakdown_1 (@DebitAccNr_acc_nr VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500),@PT_tran_type VARCHAR(20),@PTC_source_node_name VARCHAR(30),@PT_sink_node_name VARCHAR(30),@PT_payee VARCHAR(100), @PTC_card_acceptor_id_code VARCHAR(500),@PTC_totals_group VARCHAR(30),@PTC_pan VARCHAR(30), @PTC_terminal_id VARCHAR(10),@PT_extended_tran_type VARCHAR(10),@PT_message_type  VARCHAR(10) ) RETURNS BIT
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
      
      
   
   
    CREATE FUNCTION fn_rpt_settlement_breakdown_2 (@DebitAccNr_acc_nr  VARCHAR(500),@CreditAccNr_acc_nr VARCHAR(500) ) 
  
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
            
            
       CREATE FUNCTION    fn_rpt_settlement_breakdown_3 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
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
        
          CREATE FUNCTION    fn_rpt_settlement_breakdown_4 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
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
        
        
        CREATE FUNCTION fn_rpt_settlement_breakdown_5 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
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
                 
                 
                 
                 
                 
        
        CREATE FUNCTION dbo.fn_rpt_settlement_breakdown_6 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
      RETURNS BIT
     
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
                    )
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                 
        
        CREATE FUNCTION fn_rpt_settlement_breakdown_7 (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
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
                 
                 