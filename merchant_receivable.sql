

SELECT 
(
CASE
WHEN (source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup')
THEN  (0.97)* (

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END
)

 WHEN  LEFT(extended_tran_type_reward,1) IN  ('9', '8') AND Addit_Party in ('ISW','YPM','SAVER') AND tran_type  in ('00','50')
THEN (

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
	  )- (
	  (

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END)* Reward_Discount)
	  
WHEN
 merchant_type   NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT, merchant_type) < 3501  OR  CONVERT(INT, merchant_type) > 4000)
AND  (LEFT(terminal_id,1)  IN  ('2', '5','6')) AND message_type NOT IN ('0400','0420') AND Fee_type = 'P' AND  tran_type in ('00','50', '09')
THEN ((

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
) - ((CASE WHEN  isPurchaseTrx = 1 AND ABS( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>=amount_cap THEN  amount_cap
  ELSE ( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
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
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
)>=(amount_cap)
and tran_type  in ('00','50', '09')
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
) +((CASE WHEN  isPurchaseTrx = 1 AND ABS( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>=amount_cap THEN  amount_cap
  ELSE ( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
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
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END) - ( (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
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
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
  + (tran_cash_rsp)
WHEN  tran_type   =  '01'  THEN  (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
WHEN merchant_type  in ('4004','4722')
and message_type NOT IN ('0400','0420') AND  rsp_code_rsp  IN ('00','08','10','11','16')
and abs(
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>= 200
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)-(fee_cap) + tran_cash_rsp)
WHEN merchant_type IN ('4004','4722') AND  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)< 200)
THEN (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
WHEN  merchant_type in ('4004','4722') AND message_type in ('0400','0420') and  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>= 200)
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+fee_cap)+ (-1*tran_cash_rsp)
  
  WHEN Fee_type = 'F' AND left(terminal_id,1) = '3' AND message_type in ('0200','0220') and  rsp_code_rsp IN ('00','08','10','11','16')
THEN (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
 WHEN Fee_type = 'F' AND left(terminal_id,1) = '3' AND message_type in ('0400','0420') and rsp_code_rsp IN ('00','08','10','11','16')
then (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
WHEN Fee_type = 'S' AND tran_type in ('00','50','09') and merchant_type = '9008' 
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
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
CASE WHEN extended_tran_type  = '9001' THEN  0.01 * ( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
ELSE 0
END)