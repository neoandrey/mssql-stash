USE [postilion_office]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_settlement_breakdown_1]    Script Date: 04/06/2017 11:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

                   
         
   CREATE function [dbo].[fn_rpt_sttl_brkdwn_1] (@DebitAccNr_acc_nr VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500),@PT_tran_type VARCHAR(20),@PTC_source_node_name VARCHAR(30),@PT_sink_node_name VARCHAR(30),@PT_payee VARCHAR(100), @PTC_card_acceptor_id_code VARCHAR(500),@PTC_totals_group VARCHAR(30),@PTC_pan VARCHAR(30), @PTC_terminal_id VARCHAR(10),@PT_extended_tran_type VARCHAR(10),@PT_message_type  VARCHAR(10) ) RETURNS BIT
   AS
   BEGIN
    DECLARE @return_bit BIT = 0 
                
                
             IF ( @DebitAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE' 
                             OR   @DebitAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE' 
                              OR   @DebitAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' 
                            OR (@CreditAccNr_acc_nr LIKE '%ISSUER_FEE_PAYABLE'  )
                          OR ( @CreditAccNr_acc_nr LIKE '%ISSUER_FEE_RECEIVABLE'  )
                         OR ( @CreditAccNr_acc_nr LIKE '%AMOUNT_PAYABLE' )

                          and dbo.fn_rpt_isPurchaseTrx_sett(@PT_tran_type,@PTC_source_node_name, @PT_sink_node_name,@PTC_terminal_id ,@PTC_totals_group ,@PTC_pan ) = 1
                          and (dbo.fn_rpt_isBillpayment (@PTC_terminal_id,@PT_extended_tran_type,@PT_message_type,@PT_sink_node_name,@PT_payee,@PTC_card_acceptor_id_code ,@PTC_source_node_name,@PT_tran_type,@PTC_pan) = 0)
                          AND dbo.fn_rpt_CardGroup(@PTC_pan) = '6') BEGIN
                        
                         SET  @return_bit = 1;
                    
                   END
             RETURN @return_bit
      END 
      
      
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_settlement_breakdown_2]    Script Date: 04/06/2017 11:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


      
   
   
    CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_2] (@DebitAccNr_acc_nr  VARCHAR(500),@CreditAccNr_acc_nr VARCHAR(500) ) 
  
  RETURNS BIT
  
  AS BEGIN
     DECLARE @return_bit BIT  = 0 
  IF ( (@DebitAccNr_acc_nr like  '%ISSUER_FEE_PAYABLE'  OR @DebitAccNr_acc_nr like  '%ISSUER_FEE_RECEIVABLE'  OR @DebitAccNr_acc_nr like  '%AMOUNT_PAYABLE')  
       OR 
       ( @CreditAccNr_acc_nr like  '%ISSUER_FEE_PAYABLE'  OR @CreditAccNr_acc_nr like  '%ISSUER_FEE_RECEIVABLE'  OR @CreditAccNr_acc_nr like  '%AMOUNT_PAYABLE') 
        )
           
                          BEGIN                          
                          SET @return_bit = 1
                          
                          
                          END
                   RETURN @return_bit
            END
            
      
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_settlement_breakdown_3]    Script Date: 04/06/2017 11:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

      
       CREATE FUNCTION    [dbo].[fn_rpt_sttl_brkdwn_3] (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0
     
     IF(
        (@DebitAccNr_acc_nr LIKE '%MCARD%BILLING%')
                           OR 
           (@CreditAccNr_acc_nr LIKE '%MCARD%BILLING%')              
                            )
                   BEGIN
                   
                   SET @return_bit = 1 
                   END
            RETURN @return_bit
        END
      
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_settlement_breakdown_4]    Script Date: 04/06/2017 11:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

    CREATE FUNCTION    [dbo].[fn_rpt_sttl_brkdwn_4] (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0
     
     IF(
     (@DebitAccNr_acc_nr LIKE  '%V%BILLING%')
     or 
     (@CreditAccNr_acc_nr LIKE  '%V%BILLING%')
                          )
                   BEGIN
                   
                   SET @return_bit = 1 
                   END
            RETURN @return_bit
        END
        
        
      
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_settlement_breakdown_5]    Script Date: 04/06/2017 11:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

  CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_5] (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   (
				
					 @DebitAccNr_acc_nr  LIKE  '%TERMINAL_OWNER%FEE%RECEIVABLE'
				
							)
						   or  (
						     @CreditAccNr_acc_nr  LIKE  '%TERMINAL_OWNER%FEE%RECEIVABLE'
							)
                              or (@CreditAccNr_acc_nr  LIKE  '%PTSP_FEE_RECEIVABLE'   OR
                              @DebitAccNr_acc_nr  LIKE  '%PTSP_FEE_RECEIVABLE'  ))
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                 
                 
      
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_settlement_breakdown_6]    Script Date: 04/06/2017 11:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


        CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_6] (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) )
      RETURNS BIT
     
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   (
				
					 @DebitAccNr_acc_nr  LIKE  '%TERMINAL_OWNER%FEE%RECEIVABLE'
				
							)
						   or  (
						     @CreditAccNr_acc_nr  LIKE  '%TERMINAL_OWNER%FEE%RECEIVABLE'
							)
                    )
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
GO

/****** Object:  UserDefinedFunction [dbo].[fn_rpt_settlement_breakdown_7]    Script Date: 04/06/2017 11:41:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

             
        
        CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_7] (@DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (    (@CreditAccNr_acc_nr  LIKE  '%PTSP_FEE_RECEIVABLE'   OR
                              @DebitAccNr_acc_nr  LIKE  '%PTSP_FEE_RECEIVABLE'  ))
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                 
GO




        CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_amount_payable] (@AccNr_acc_nr  VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   @AccNr_acc_nr LIKE '%AMOUNT%PAYABLE')
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                 
                 
                 

        CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_issuer_fee_payable] (@AccNr_acc_nr  VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   @AccNr_acc_nr LIKE '%ISSUER%FEE%PAYABLE')
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                 
                 
        CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_issuer_fee_receivable] (@AccNr_acc_nr  VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   @AccNr_acc_nr LIKE '%ISSUER%FEE%RECEIVABLE')
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
                   
        CREATE FUNCTION [dbo].[fn_rpt_sttl_brkdwn_isw_fee_receivable] (@AccNr_acc_nr  VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
       IF  (   @AccNr_acc_nr LIKE '%ISW%FEE%RECEIVABLE')
                             BEGIN
                              SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 
         
