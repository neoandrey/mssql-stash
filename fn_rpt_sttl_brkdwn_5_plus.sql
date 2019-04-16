
 CREATE  FUNCTION [dbo].[fn_rpt_sttl_brkdwn_5_plus] (@PTC_merchant_type VARCHAR(30),@PTC_terminal_id VARCHAR(30), @PT_tran_type VARCHAR(50),@PTC_PAN VARCHAR(50),@PTC_source_node_name VARCHAR(100),@PT_sink_node_name VARCHAR(100),@PTC_totals_group VARCHAR(20),  @DebitAccNr_acc_nr  VARCHAR(500), @CreditAccNr_acc_nr VARCHAR(500) ) 
      RETURNS BIT
      AS
      BEGIN
      DECLARE @return_bit BIT  = 0 
      IF(
				dbo.fn_rpt_MCC_Visa (@PTC_merchant_type,@PTC_terminal_id,@PT_tran_type,@PTC_PAN) is NULL
                and dbo.fn_rpt_isPurchaseTrx_sett(@PT_tran_type,@PTC_source_node_name, @PT_sink_node_name,@PTC_terminal_id ,@PTC_totals_group ,@PTC_pan) = 1 
                and not ([dbo].[fn_rpt_sttl_brkdwn_5](@DebitAccNr_acc_nr,@CreditAccNr_acc_nr) =1)) BEGIN
                 SET @return_bit  = 1
                             END
                    RETURN @return_bit
                 END
                 