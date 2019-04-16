USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_mega_pos_settlement]    Script Date: 10/5/2016 2:38:28 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER      PROCEDURE [dbo].[usp_mega_pos_settlement]
      
      @repordt_date_start DATETIME = NULL,
      @report_date_end DATETIME = NULL

AS
BEGIN

      --SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


      DECLARE @idx                                    INT
      DECLARE @node_list                        VARCHAR(255)
      
      DECLARE @warning VARCHAR(255)
      DECLARE @report_date_end_next DATETIME
      DECLARE @node_name_list VARCHAR(255)
      DECLARE @date_selection_mode              VARCHAR(50)
      DECLARE @date_check DATETIME
      declare @report_date_start  dATETIME
      -- Get the list of nodes that will be used in determining the last closed batch
      --SET @node_name_list = 'CCLOADsrc'
     SELECT @date_check =ISNULL (@report_date_start, GETDATE());
     
      SET @date_selection_mode = 'Last business day'


    
      DECLARE @current_code VARCHAR(10);
      DECLARE @first_post_tran_id BIGINT
      
      DECLARE @last_post_tran_id BIGINT
     
     SELECT @report_date_start = ISNULL(@report_date_start, convert(date, DATEADD(D,-1,getdate())));
      SELECT @report_date_end = ISNULL(@report_date_start, convert(date, DATEADD(D,0,getdate())));
      
      
      SELECT
                  t.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,t.recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank, system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id,
				  CASE 

WHEN source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup' THEN 'Intl Visa Transactions (Co-acquired)'
WHEN merchant_type NOT IN ('2002','1008','4002','4003','4004','8398','8661','4722','5300','5051','5001','5002','7011','1002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','5814','1111','8666')  AND  (merchant_type <3501 OR merchant_type > 4000) 
AND LEFT(terminal_id,1) IN ('2','5')
AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') ) 
then 'General Merchant and Airline (Operators)'

WHEN merchant_type  IN ('2002','4002','4003','8398','8661','5814','8666') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') ) THEN  'Churches, FastFoods and NGOs'
WHEN merchant_type ='1008' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') ) THEN 'Concession Category'
WHEN merchant_type  IN ('4004','4722') AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
 THEN 'Travel Agencies' 
 WHEN  merchant_type IN ('5001','5002','7011') AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') ) THEN 'Hotels & Guest Houses (T&E)'

WHEN  CONVERT(INT,merchant_type) >=  3501 AND CONVERT(INT,merchant_type) >= 4000
AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
THEN 'Hotels & Guest Houses (T&E)'

WHEN merchant_type IN ('1002','5300','5051') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
THEN 'WholeSale'

WHEN merchant_type =  '1111' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'WholeSale_Acquirer_Borne'
WHEN merchant_type IN ('4001','5541','9752') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
THEN 'FuelStations'

WHEN merchant_type =    '5542'  AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
THEN 'Easyfuel'

WHEN merchant_type =  '2010' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'Reward Money(5%)'

WHEN merchant_type = '2011'   AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'Reward Money(5.5%)'
WHEN merchant_type =  '2012'  AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'Reward Money(6%)'
WHEN merchant_type ='2013'    AND    NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'Reward Money(7%)'
when merchant_type ='2014'    AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'Reward Money(10%)'
when merchant_type ='2015'    AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'Reward Money(12.5%)'
WHEN merchant_type ='2016'    AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'Reward Money(15%)'
WHEN merchant_type IN ('9001','9002','9003','9004','9005','9006') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4') )
then 'WEBPAY Generic'
WHEN     (tran_type = '00' AND  merchant_type = '4722' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4') THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
WHEN     ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(terminal_id,1)  IN ( '2','5','6') AND  LEFT(pan,1) =  '4')  THEN 'POS(2% CATEGORY-VISA)PURCHASE'
WHEN    ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(terminal_id,1)  IN ( '2','5','6')AND  LEFT(pan,1) =  '4')  THEN 'POS(3% CATEGORY-VISA)PURCHASE'
ELSE  category_name +' '+ merchant_type
END as industry_segment,
(
(
CASE
WHEN (source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup')
THEN  (0.97)* (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END
)

 WHEN  LEFT(extended_tran_type_reward,1) IN  ('9', '8') AND Addit_Party in ('ISW','YPM','SAVER') AND tran_type  in ('00','50')
THEN (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
	  )- (
	  (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END)* Reward_Discount)
	  
WHEN
 merchant_type   NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT, merchant_type) < 3501  OR  CONVERT(INT, merchant_type) > 4000)
AND  (LEFT(terminal_id,1)  IN  ('2', '5','6')) AND message_type NOT IN ('0400','0420') AND Fee_type = 'P' AND  tran_type in ('00','50', '09')
THEN ((

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
) - ((CASE WHEN  isPurchaseTrx = 1 AND ABS( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>=amount_cap THEN  amount_cap
  ELSE ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
  END)* (
CASE 
WHEN  Fee_type = 'P' THEN merchant_disc 
WHEN  Fee_type = 'F' THEN fee_cap 
WHEN  Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
WHEN  Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
then 0.05
ELSE 0 END
)))+ tran_cash_rsp
WHEN  merchant_type NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT, merchant_type) < 3501  OR  CONVERT(INT, merchant_type) > 4000)
AND  (LEFT(terminal_id,1)  IN  ('2', '5','6'))
AND  Fee_type  = 'P'
AND message_type IN ('0400','0420')
and abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
)>=(amount_cap)
and tran_type  in ('00','50', '09')
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
) +((CASE WHEN  isPurchaseTrx = 1 AND ABS( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>=amount_cap THEN  amount_cap
  ELSE ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
  END)* (
		CASE 
		WHEN  Fee_type = 'P' THEN merchant_disc 
		WHEN  Fee_type = 'F' THEN fee_cap 
		WHEN  Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

)))+ (tran_cash_rsp)

WHEN merchant_type IN ('5001','5002','7011','2010','2011','2012','2013','2014','2015','2016') OR  (convert(int, merchant_type) >= 3501  AND convert(int, merchant_type)  <=4000)
AND  tran_type  IN ('00','50', '09')
THEN ( (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END) - ( (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)*(
		CASE 
		WHEN  Fee_type = 'P' THEN merchant_disc 
		WHEN  Fee_type = 'F' THEN fee_cap 
		WHEN  Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

))+ (tran_cash_rsp))

WHEN merchant_type  IN ('4001','5542','5541','9752','1111') AND  tran_type in ('00','50', '09')
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
  + (tran_cash_rsp)
WHEN  tran_type   =  '01'  THEN  (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
WHEN merchant_type  in ('4004','4722')
and message_type NOT IN ('0400','0420') AND  rsp_code_rsp  IN ('00','08','10','11','16')
and abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>= 200
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)-(fee_cap) + tran_cash_rsp)
WHEN merchant_type IN ('4004','4722') AND  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)< 200)
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
WHEN  merchant_type in ('4004','4722') AND message_type in ('0400','0420') and  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>= 200)
  THEN (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END
  - fee_cap +tran_cash_rsp)

  WHEN Fee_type = 'F' AND left(terminal_id,1) = '3' AND message_type in ('0200','0220') 
  and  rsp_code_rsp IN ('00','08','10','11','16')
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END+ tran_cash_rsp)
 WHEN Fee_type = 'F' AND left(terminal_id,1) = '3' AND message_type in ('0400','0420') and rsp_code_rsp IN ('00','08','10','11','16')
then (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
WHEN Fee_type = 'S' AND tran_type in ('00','50','09') and merchant_type = '9008' 
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END) - ( CASE WHEN Fee_type  = 'P' THEN  merchant_disc
	  WHEN  Fee_type = 'F' THEN fee_cap
	  WHEN Fee_type = 'S'  AND ABS(settle_amount_rsp)>= 5000 then 0.05
	  WHEN Fee_type  = 'S' AND ABS(settle_amount_rsp)< 5000 then 0.05
	  ELSE 0
	 END
))+ tran_cash_rsp

ELSE 0
END
)
 -(
CASE WHEN extended_tran_type  = '9001' THEN  0.01 * ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
ELSE 0
END)
) as 
 merchant_receivable
      FROM
                        post_tran t (NOLOCK, INDEX(IX_POST_TRAN_9))
                        JOIN
                        (SELECT [DATE] recon_business_date FROM dbo.get_dates_in_range(@report_date_start, @report_date_end)
                        
                        )r
                        on
                        r.recon_business_date = t.recon_business_date
                        and 
(t.message_type IN ('0220','0200', '0400', '0420')) 

and tran_completed=1
and 
tran_postilion_originated  = 0
                        
                        JOIN post_tran_cust c (NOLOCK,index( PK_POST_TRAN_CUST))
                        ON 
                         t.post_tran_cust_id = c.post_tran_cust_id
                         and left(terminal_id,1)='2'
						 JOIN
						 tbl_merchant_category m ON  c.merchant_type = m.category_code
						join tbl_merchant_account mrch(NOLOCK)
ON 
c.card_acceptor_id_code = mrch.card_acceptor_id_code

LEFT  JOIN 
tbl_PTSP psp (NOLOCK)
ON
c.terminal_id = psp.terminal_id
 LEFT  JOIN 
tbl_terminal_owner own (NOLOCK) 
ON
c.terminal_id= own.terminal_id
 JOIN tbl_merchant_category m (NOLOCK)
				ON t.merchant_type = m.category_code
                        wherE
                        (c.source_node_name = 'MGASPVLGTsrc' and t.sink_node_name = 'MEGGTBVB2snk')
						OR
                       ( c.source_node_name =  'MGASPUBVLsrC' and t.sink_node_name =  'MEGUBAVB2snk')
						OR 
						(c.source_node_name = 'MGASPUBVIsrc' and t.sink_node_name =  'MEGUBAVB2snk')
--						OR 
--( t.sink_node_name = 'MEGBANKMDSsnk' 

and   c.source_node_name in (
'MEGASPABPsrc'
,'MEGASPCHBsrc'
,'MEGASPEBNsrc'
,'MEGASPFBNsrc'
,'MEGASPFBPsrc'
,'MEGASPFCMsrc'
,'MEGASPGTBsrc'
,'MEGASPHBCsrc'
,'MEGASPKSBsrc'
,'MEGASPPRUsrc'
,'MEGASPSBPsrc'
,'MEGASPUBAsrc'
,'MEGASPUBNsrc'
,'MEGASPUBPsrc'
,'MEGASPWEMsrc'
)



end