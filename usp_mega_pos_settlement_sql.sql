USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_mega_pos_settlement]    Script Date: 10/6/2016 3:34:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--[usp_mega_pos_settlement] NULL, NULL


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
                  t.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,t.recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank, system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,c.address_verification_data ,c.address_verification_result ,c.card_acceptor_id_code ,c.card_acceptor_name_loc ,c.card_product ,c.card_seq_nr ,c.check_data ,c.draft_capture ,c.expiry_date ,c.mapped_card_acceptor_id_code ,c.merchant_type ,c..pan ,c.pan_encrypted ,c.pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,c.terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id,
				  CASE 

WHEN source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup' THEN 'Intl Visa Transactions (Co-acquired)'
WHEN merchant_type NOT IN ('2002','1008','4002','4003','4004','8398','8661','4722','5300','5051','5001','5002','7011','1002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','5814','1111','8666')  AND  (merchant_type <3501 OR merchant_type > 4000) 
AND LEFT(c.terminal_id,1) IN ('2','5')
AND NOT(    (tran_type = '00' AND  c.merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c..pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) 
then 'General Merchant and Airline (Operators)'

WHEN merchant_type  IN ('2002','4002','4003','8398','8661','5814','8666') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) THEN  'Churches, FastFoods and NGOs'
WHEN merchant_type ='1008' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) THEN 'Concession Category'
WHEN merchant_type  IN ('4004','4722') AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
 THEN 'Travel Agencies' 
 WHEN  merchant_type IN ('5001','5002','7011') AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) THEN 'Hotels & Guest Houses (T&E)'

WHEN  CONVERT(INT,merchant_type) >=  3501 AND CONVERT(INT,merchant_type) >= 4000
AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'Hotels & Guest Houses (T&E)'

WHEN merchant_type IN ('1002','5300','5051') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'WholeSale'

WHEN merchant_type =  '1111' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'WholeSale_Acquirer_Borne'
WHEN merchant_type IN ('4001','5541','9752') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'FuelStations'

WHEN merchant_type =    '5542'  AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'Easyfuel'

WHEN merchant_type =  '2010' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(5%)'

WHEN merchant_type = '2011'   AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(5.5%)'
WHEN merchant_type =  '2012'  AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(6%)'
WHEN merchant_type ='2013'    AND    NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(7%)'
when merchant_type ='2014'    AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(10%)'
when merchant_type ='2015'    AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(12.5%)'
WHEN merchant_type ='2016'    AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(15%)'
WHEN merchant_type IN ('9001','9002','9003','9004','9005','9006') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'WEBPAY Generic'
WHEN     (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
WHEN     ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  THEN 'POS(2% CATEGORY-VISA)PURCHASE'
WHEN    ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4')  THEN 'POS(3% CATEGORY-VISA)PURCHASE'
ELSE  me.category_name +' '+ merchant_type
END as industry_segment,
(
(
CASE
WHEN (source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup')
THEN  (0.97)* (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END
)

 WHEN  LEFT((                                Case When c.terminal_id in 
                                (select c.terminal_id from tbl_reward_OutOfband (NOLOCK)) and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end),1) IN  ('9', '8') AND Addit_Party in ('ISW','YPM','SAVER') AND tran_type  in ('00','50')
THEN (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
	  )- (
	  (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END)* Reward_Discount)
	  
WHEN
 merchant_type   NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT, merchant_type) < 3501  OR  CONVERT(INT, merchant_type) > 4000)
AND  (LEFT(c.terminal_id,1)  IN  ('2', '5','6')) AND message_type NOT IN ('0400','0420') AND me.Fee_type = 'P' AND  tran_type in ('00','50', '09')
THEN ((

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
) - ((CASE WHEN  dbo.fn_rpt_isPurchaseTrx(tran_type)  = 1 AND ABS( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>=me.amount_cap THEN  me.amount_cap
  ELSE ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
  END)* (
CASE 
WHEN  me.Fee_type = 'P' THEN me.merchant_disc 
WHEN  me.Fee_type = 'F' THEN me.fee_cap 
WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
then 0.05
ELSE 0 END
)))+ tran_cash_rsp
WHEN  merchant_type NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT, merchant_type) < 3501  OR  CONVERT(INT, merchant_type) > 4000)
AND  (LEFT(c.terminal_id,1)  IN  ('2', '5','6'))
AND  me.Fee_type  = 'P'
AND message_type IN ('0400','0420')
and abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
)>=(me.amount_cap)
and tran_type  in ('00','50', '09')
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
) +((CASE WHEN  dbo.fn_rpt_isPurchaseTrx(tran_type)  = 1 AND ABS( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>=me.amount_cap THEN  me.amount_cap
  ELSE ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
  END)* (
		CASE 
		WHEN  me.Fee_type = 'P' THEN me.merchant_disc 
		WHEN  me.Fee_type = 'F' THEN me.fee_cap 
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

)))+ (tran_cash_rsp)

WHEN merchant_type IN ('5001','5002','7011','2010','2011','2012','2013','2014','2015','2016') OR  (convert(int, merchant_type) >= 3501  AND convert(int, merchant_type)  <=4000)
AND  tran_type  IN ('00','50', '09')
THEN ( (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END) - ( (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)*(
		CASE 
		WHEN  me.Fee_type = 'P' THEN me.merchant_disc 
		WHEN  me.Fee_type = 'F' THEN me.fee_cap 
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

))+ (tran_cash_rsp))

WHEN merchant_type  IN ('4001','5542','5541','9752','1111') AND  tran_type in ('00','50', '09')
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
  + (tran_cash_rsp)
WHEN  tran_type   =  '01'  THEN  (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
WHEN merchant_type  in ('4004','4722')
and message_type NOT IN ('0400','0420') AND  rsp_code_rsp  IN ('00','08','10','11','16')
and abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>= 200
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)-(me.fee_cap) + tran_cash_rsp)
WHEN merchant_type IN ('4004','4722') AND  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)< 200)
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)+ tran_cash_rsp
WHEN  merchant_type in ('4004','4722') AND message_type in ('0400','0420') and  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>= 200)
  THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type),2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END
  - me.fee_cap +tran_cash_rsp)

  WHEN me.Fee_type = 'F' AND left(c.terminal_id,1) = '3' AND message_type in ('0200','0220') 
  and  rsp_code_rsp IN ('00','08','10','11','16')
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END+ tran_cash_rsp)
 WHEN me.Fee_type = 'F' AND left(c.terminal_id,1) = '3' AND message_type in ('0400','0420') and rsp_code_rsp IN ('00','08','10','11','16')
then (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)+ tran_cash_rsp
WHEN me.Fee_type = 'S' AND tran_type in ('00','50','09') and merchant_type = '9008' 
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END) - ( CASE WHEN me.Fee_type  = 'P' THEN  me.merchant_disc
	  WHEN  me.Fee_type = 'F' THEN me.fee_cap
	  WHEN me.Fee_type = 'S'  AND ABS(settle_amount_rsp)>= 5000 then 0.05
	  WHEN me.Fee_type  = 'S' AND ABS(settle_amount_rsp)< 5000 then 0.05
	  ELSE 0
	 END
))+ tran_cash_rsp

ELSE 0
END
)
 -(
CASE WHEN extended_tran_type  = '9001' THEN  0.01 * ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
ELSE 0
END)
) as 
 merchant_receivable,
  (CASE 
WHEN  source_node_name = 'MGASPVLGTsrc' AND sink_node_name = 'MEGGTBVB2snk' THEN 'GTB'
WHEN  source_node_name IN ('MGASPUBVLsrc','MGASPUBVIsrc') AND sink_node_name = 'MEGGTBVB2snk' THEN 'UBA'
ELSE null
END )AS [co_acquirer]

	
      FROM
                     (  SELECT *  FROM   post_tran pt (NOLOCK, INDEX(IX_POST_TRAN_9))
                        JOIN
                        (SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start, @report_date_end)
                        
                        )rec
                        on
                        rec.rec_bus_date = pt.recon_business_date
                        and tran_completed=1
                                                and 
(pt.message_type IN ('0220','0200', '0400', '0420')) 
and 
tran_postilion_originated  = 0
                        )t
                      LEFT   JOIN post_tran_cust c (NOLOCK,index( PK_POST_TRAN_CUST))
                        ON 
                         t.post_tran_cust_id = c.post_tran_cust_id
                         and left(c.terminal_id,1)='2'
						LEFT JOIN
					 (SELECT * FROM tbl_merchant_category (NOLOCK)
								union all
								SELECT * FROM tbl_merchant_category_visa (NOLOCK)
										union all
											SELECT * FROM tbl_merchant_category_web (NOLOCK)) me ON  c.merchant_type = me.category_code
						join tbl_merchant_account mrch(NOLOCK)
ON 
c.card_acceptor_id_code = mrch.card_acceptor_id_code
 LEFT  JOIN 
tbl_terminal_owner own (NOLOCK) 
ON
c.terminal_id= own.terminal_id
left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    AND convert(date,t.datetime_req )
                                    = convert(date,y.trans_date)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand (NOLOCK)))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id 
				left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code and dbo.fn_rpt_CardGroup (c..pan) in ('1','4')))
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id
                        where
                        (c.source_node_name = 'MGASPVLGTsrc' and t.sink_node_name = 'MEGGTBVB2snk')
						OR
                       ( c.source_node_name =  'MGASPUBVLsrC' and t.sink_node_name =  'MEGUBAVB2snk')
						OR 
						(c.source_node_name = 'MGASPUBVIsrc' and t.sink_node_name =  'MEGUBAVB2snk')

                                
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

UNION ALL





SELECT 
				 t.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,t.recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank, system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,c.address_verification_data ,c.address_verification_result ,c.card_acceptor_id_code ,c.card_acceptor_name_loc ,c.card_product ,c.card_seq_nr ,c.check_data ,c.draft_capture ,c.expiry_date ,c.mapped_card_acceptor_id_code ,c.merchant_type ,c..pan ,c.pan_encrypted ,c.pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,c.terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id,
				  CASE 

WHEN source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup' THEN 'Intl Visa Transactions (Co-acquired)'
WHEN merchant_type NOT IN ('2002','1008','4002','4003','4004','8398','8661','4722','5300','5051','5001','5002','7011','1002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','5814','1111','8666')  AND  (merchant_type <3501 OR merchant_type > 4000) 
AND LEFT(c.terminal_id,1) IN ('2','5')
AND NOT(    (tran_type = '00' AND  c.merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c..pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) 
then 'General Merchant and Airline (Operators)'

WHEN merchant_type  IN ('2002','4002','4003','8398','8661','5814','8666') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) THEN  'Churches, FastFoods and NGOs'
WHEN merchant_type ='1008' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) THEN 'Concession Category'
WHEN merchant_type  IN ('4004','4722') AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
 THEN 'Travel Agencies' 
 WHEN  merchant_type IN ('5001','5002','7011') AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') ) THEN 'Hotels & Guest Houses (T&E)'

WHEN  CONVERT(INT,merchant_type) >=  3501 AND CONVERT(INT,merchant_type) >= 4000
AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'Hotels & Guest Houses (T&E)'

WHEN merchant_type IN ('1002','5300','5051') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'WholeSale'

WHEN merchant_type =  '1111' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'WholeSale_Acquirer_Borne'
WHEN merchant_type IN ('4001','5541','9752') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'FuelStations'

WHEN merchant_type =    '5542'  AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
THEN 'Easyfuel'

WHEN merchant_type =  '2010' AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(5%)'

WHEN merchant_type = '2011'   AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(5.5%)'
WHEN merchant_type =  '2012'  AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(6%)'
WHEN merchant_type ='2013'    AND    NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(7%)'
when merchant_type ='2014'    AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(10%)'
when merchant_type ='2015'    AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(12.5%)'
WHEN merchant_type ='2016'    AND  NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'Reward Money(15%)'
WHEN merchant_type IN ('9001','9002','9003','9004','9005','9006') AND NOT(    (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') OR ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  OR ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4') )
then 'WEBPAY Generic'
WHEN     (tran_type = '00' AND  merchant_type = '4722' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4') THEN 'POS(GENERAL MERCHANT-VISA)PURCHASE'
WHEN     ( tran_type = '00' AND merchant_type  = '5300' AND LEFT(c.terminal_id,1)  IN ( '2','5','6') AND  LEFT(c.pan,1) =  '4')  THEN 'POS(2% CATEGORY-VISA)PURCHASE'
WHEN    ( tran_type = '00' AND   merchant_type  NOT in ('5300','4722','5541') AND LEFT(c.terminal_id,1)  IN ( '2','5','6')AND  LEFT(c.pan,1) =  '4')  THEN 'POS(3% CATEGORY-VISA)PURCHASE'
ELSE  me.category_name +' '+ merchant_type
END as industry_segment,
(
(
CASE
WHEN (source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup')
THEN  (0.97)* (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END
)

 WHEN  LEFT((                                Case When c.terminal_id in 
                                (select c.terminal_id from tbl_reward_OutOfband (NOLOCK)) and dbo.fn_rpt_CardGroup (c.PAN) in ('1','4')
                                 then substring(o.r_code,1,4) 
                                  else ISNULL(substring(y.extended_trans_type,1,4),'0000')end),1) IN  ('9', '8') AND Addit_Party in ('ISW','YPM','SAVER') AND tran_type  in ('00','50')
THEN (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
	  )- (
	  (

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END)* Reward_Discount)
	  
WHEN
 merchant_type   NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT, merchant_type) < 3501  OR  CONVERT(INT, merchant_type) > 4000)
AND  (LEFT(c.terminal_id,1)  IN  ('2', '5','6')) AND message_type NOT IN ('0400','0420') AND me.Fee_type = 'P' AND  tran_type in ('00','50', '09')
THEN ((

 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
) - ((CASE WHEN  dbo.fn_rpt_isPurchaseTrx(tran_type)  = 1 AND ABS( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>=me.amount_cap THEN  me.amount_cap
  ELSE ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
  END)* (
CASE 
WHEN  me.Fee_type = 'P' THEN me.merchant_disc 
WHEN  me.Fee_type = 'F' THEN me.fee_cap 
WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
then 0.05
ELSE 0 END
)))+ tran_cash_rsp
WHEN  merchant_type NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT, merchant_type) < 3501  OR  CONVERT(INT, merchant_type) > 4000)
AND  (LEFT(c.terminal_id,1)  IN  ('2', '5','6'))
AND  me.Fee_type  = 'P'
AND message_type IN ('0400','0420')
and abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
)>=(me.amount_cap)
and tran_type  in ('00','50', '09')
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
	  ELSE 0 END
) +((CASE WHEN  dbo.fn_rpt_isPurchaseTrx(tran_type)  = 1 AND ABS( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>=me.amount_cap THEN  me.amount_cap
  ELSE ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
  END)* (
		CASE 
		WHEN  me.Fee_type = 'P' THEN me.merchant_disc 
		WHEN  me.Fee_type = 'F' THEN me.fee_cap 
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

)))+ (tran_cash_rsp)

WHEN merchant_type IN ('5001','5002','7011','2010','2011','2012','2013','2014','2015','2016') OR  (convert(int, merchant_type) >= 3501  AND convert(int, merchant_type)  <=4000)
AND  tran_type  IN ('00','50', '09')
THEN ( (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END) - ( (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)*(
		CASE 
		WHEN  me.Fee_type = 'P' THEN me.merchant_disc 
		WHEN  me.Fee_type = 'F' THEN me.fee_cap 
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  me.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

))+ (tran_cash_rsp))

WHEN merchant_type  IN ('4001','5542','5541','9752','1111') AND  tran_type in ('00','50', '09')
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
  + (tran_cash_rsp)
WHEN  tran_type   =  '01'  THEN  (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
WHEN merchant_type  in ('4004','4722')
and message_type NOT IN ('0400','0420') AND  rsp_code_rsp  IN ('00','08','10','11','16')
and abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>= 200
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)-(me.fee_cap) + tran_cash_rsp)
WHEN merchant_type IN ('4004','4722') AND  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)< 200)
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)+ tran_cash_rsp
WHEN  merchant_type in ('4004','4722') AND message_type in ('0400','0420') and  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)>= 200)
  THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type),2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END
  - me.fee_cap +tran_cash_rsp)

  WHEN me.Fee_type = 'F' AND left(c.terminal_id,1) = '3' AND message_type in ('0200','0220') 
  and  rsp_code_rsp IN ('00','08','10','11','16')
THEN (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END+ tran_cash_rsp)
 WHEN me.Fee_type = 'F' AND left(c.terminal_id,1) = '3' AND message_type in ('0400','0420') and rsp_code_rsp IN ('00','08','10','11','16')
then (
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)+ tran_cash_rsp
WHEN me.Fee_type = 'S' AND tran_type in ('00','50','09') and merchant_type = '9008' 
THEN ((
 CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END) - ( CASE WHEN me.Fee_type  = 'P' THEN  me.merchant_disc
	  WHEN  me.Fee_type = 'F' THEN me.fee_cap
	  WHEN me.Fee_type = 'S'  AND ABS(settle_amount_rsp)>= 5000 then 0.05
	  WHEN me.Fee_type  = 'S' AND ABS(settle_amount_rsp)< 5000 then 0.05
	  ELSE 0
	 END
))+ tran_cash_rsp

ELSE 0
END
)
 -(
CASE WHEN extended_tran_type  = '9001' THEN  0.01 * ( CASE WHEN RIGHT(dbo.formatTranTypeStr(t.tran_type, t.extended_tran_type, t.message_type) ,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND ISNULL(rdm_amt,0) = 0  THEN settle_amount_rsp
      WHEN dbo.fn_rpt_isDepositTrx(t.tran_type)  <>1  AND ISNULL(rdm_amt,0) = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amt <> 0  then rdm_amt
  ELSE 0 END)
ELSE 0
END)
) as 
 merchant_receivable,
 (CASE 
WHEN  source_node_name = 'MGASPVLGTsrc' AND sink_node_name = 'MEGGTBVB2snk' THEN 'GTB'
WHEN  source_node_name IN ('MGASPUBVLsrc','MGASPUBVIsrc') AND sink_node_name = 'MEGGTBVB2snk' THEN 'UBA'
ELSE null
END )AS [co_acquirer]

	
				
	FROM
		 (SELECT *  FROM   post_tran pt (NOLOCK, INDEX(IX_POST_TRAN_9))
                        JOIN
                        (SELECT [DATE] rec_bus_date FROM dbo.get_dates_in_range(@report_date_start, @report_date_end)
                        
                        )rec
                        on
                        rec.rec_bus_date = pt.recon_business_date and
                        				pt.tran_completed = 1
				AND
		
				pt.tran_postilion_originated = 0--oremeyi changed this from '1'- 04032009 
				AND
				(
				LEFT(pt.message_type,2) = '02' 
				)
				
			
				AND
				pt.tran_reversed = 0 
                        )t
	LEFT	 JOIN post_tran_cust c (nolock)
			ON t.post_tran_cust_id = c.post_tran_cust_id
		 and left(c.terminal_id,1)='2'
					LEFT	 JOIN
						  (SELECT * FROM tbl_merchant_category (NOLOCK)
								union all
								SELECT * FROM tbl_merchant_category_visa (NOLOCK)
										union all
											SELECT * FROM tbl_merchant_category_web (NOLOCK)) me ON  c.merchant_type = me.category_code
					LEFT	join tbl_merchant_account mrch(NOLOCK)
ON 
c.card_acceptor_id_code = mrch.card_acceptor_id_code
 LEFT  JOIN 
tbl_terminal_owner own (NOLOCK) 
ON
c.terminal_id= own.terminal_id
left JOIN tbl_xls_settlement y (NOLOCK)

				ON (c.terminal_id= y.terminal_id 
                                    AND t.retrieval_reference_nr = y.rr_number 
                                    AND convert(date,t.datetime_req )
                                    = convert(date,y.trans_date)
                                and y.terminal_id not in (select terminal_id from tbl_reward_OutOfBand (NOLOCK)))
                                left JOIN tbl_reward_OutOfBand O (NOLOCK)
                                ON c.terminal_id = o.terminal_id 
				left JOIN Reward_Category r (NOLOCK)
                                ON (substring(y.extended_trans_type,1,4) = r.reward_code or (substring(o.r_code,1,4) = r.reward_code and dbo.fn_rpt_CardGroup (c..pan) in ('1','4')))
                                left JOIN tbl_terminal_owner tt (NOLOCK)
                                ON c.terminal_id = tt.terminal_id	
				
END