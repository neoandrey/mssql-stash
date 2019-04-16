SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
SELECT  
ISNULL(Account_Name,'ISW')account_name
,account_nr
,Acquiring_bank
,nbs.acquiring_inst_id_code
,nbs.Addit_Charge
,nbs.Addit_Party
,nbs.aggregate_column
,nbs.amount_cap
,nbs.Amount_Cap_RD
,Authorized_Person
,aid.bank_code
,nbs.bearer
,mrch.card_acceptor_id_code
,nbs.card_acceptor_name_loc
,nbs.Category_name
,nbs.currency_alpha_code
,nbs.currency_name
,Date_Modified
,nbs.datetime_req
,nbs.datetime_tran_local
,nbs.EndDate
,nbs.extended_tran_type
,nbs.extended_tran_type_reward
,nbs.fee_cap
,nbs.Fee_Cap_RD
,nbs.Fee_Discount_RD
,nbs.Fee_type
,nbs.from_account_type
,nbs.isDepositTrx
,nbs.isInquiryTrx
,nbs.isOtherTrx
,nbs.isPurchaseTrx
,nbs.isRefundTrx
,nbs.isTransferTrx
,nbs.isWithdrawTrx
,nbs.merchant_acct_nr
,nbs.merchant_disc
,nbs.merchant_type
,nbs.message_reason_code
,nbs.message_type
,nbs.pan
,nbs.payee
,nbs.prev_post_tran_id
,isnull(PTSP_code, 'ISW')
,rdm_amount
,nbs.receiving_inst_id_code
,nbs.retrieval_reference_nr
,Reward_Discount
,nbs.rsp_code_description
,nbs.rsp_code_rsp
,nbs.settle_amount_impact
,nbs.settle_amount_req
,nbs.settle_amount_rsp
,nbs.settle_currency_code
,nbs.settle_nr_decimals
,nbs.settle_tran_fee_rsp
,nbs.sink_node_name
,nbs.source_node_name
,SourceNodeAlias
,nbs.StartDate
,nbs.structured_data_req
,nbs.system_trace_audit_nr
,nbs.terminal_id
,terminal_mode
, isnull(nbs.terminal_owner, 'ISW') terminal_owner
,nbs.to_account_type
,nbs.tran_cash_req
,nbs.tran_cash_rsp
, cur. currency_code tran_currency_code
,nbs.tran_reversed
,nbs.tran_tran_fee_rsp
,nbs.tran_type
,tran_type_desciption
,TranID
,Unique_key
,issuer=
  
CASE  
  WHEN CHARINDEX (  'UBA', t.totals_group) > 0  THEN	 'UBA'
  WHEN  CHARINDEX ( 'ZIB', t.totals_group) > 0  THEN	 'ZIB'
  WHEN  CHARINDEX ( 'PRU', t.totals_group) > 0  THEN	 'PRU'
  WHEN  CHARINDEX ( 'PLAT', t.totals_group) > 0  THEN	 'PLAT'
  WHEN  CHARINDEX ( 'CHB', t.totals_group) > 0  THEN	 'CHB'
  WHEN  CHARINDEX ( 'GTB', t.totals_group) > 0  THEN	 'GTB'
  WHEN  CHARINDEX ( 'UBA', t.totals_group) > 0  THEN	 'UBA'
  WHEN  CHARINDEX ( 'FBN', t.totals_group) > 0  THEN	 'FBN'
  WHEN  CHARINDEX ( 'OBI', t.totals_group) > 0  THEN	 'OBI'
  WHEN  CHARINDEX ( 'WEM', t.totals_group) > 0  THEN	 'WEM'
  WHEN  CHARINDEX ( 'AFRI', t.totals_group) > 0  THEN	 'AFRI'
  WHEN  CHARINDEX ( 'ETB', t.totals_group) > 0  THEN	 'ETB'
  WHEN  CHARINDEX ( 'IBP', t.totals_group) > 0  THEN	 'IBP'
  WHEN  CHARINDEX ( 'IBP', t.totals_group) > 0  THEN	 'IBP'
  WHEN  CHARINDEX ( 'UBN', t.totals_group) > 0  THEN	 'UBN'
  WHEN  CHARINDEX ( 'FCMB', t.totals_group) > 0  THEN	 'FCMB'
  WHEN  CHARINDEX ( 'DBL', t.totals_group) > 0  THEN	 'DBL'
  WHEN  CHARINDEX ( 'FIB', t.totals_group) > 0  THEN	 'FIB'
  WHEN  CHARINDEX ( 'EBN', t.totals_group) > 0  THEN	 'EBN'
  WHEN  CHARINDEX ( 'ABP', t.totals_group) > 0  THEN	 'ABP'
  WHEN  CHARINDEX ( 'UBP', t.totals_group) > 0  THEN	 'UBP'
  WHEN  CHARINDEX ( 'SPR', t.totals_group) > 0  THEN	 'SPR'
  WHEN  CHARINDEX ( 'SBP', t.totals_group) > 0  THEN	 'SBP'
  WHEN  CHARINDEX ( 'CITI', t.totals_group) > 0  THEN	 'CITI'
  WHEN  CHARINDEX ( 'FD', t.totals_group) > 0  THEN	 'FD'
  WHEN  CHARINDEX ( 'FBP', t.totals_group) > 0  THEN	 'FBP'
  WHEN  CHARINDEX ( 'SCB', t.totals_group) > 0  THEN	 'SCB'
  WHEN  CHARINDEX ( 'UBA', t.totals_group) > 0  THEN	 'UBA'
  WHEN  CHARINDEX ( 'ZIB', t.totals_group) > 0  THEN	 'ZIB'
  WHEN  CHARINDEX ( 'PRU', t.totals_group) > 0  THEN	 'PRU'
  WHEN  CHARINDEX ( 'PLAT', t.totals_group) > 0  THEN	 'PLAT'
  WHEN  CHARINDEX ( 'CHB', t.totals_group) > 0  THEN	 'CHB'
  WHEN  CHARINDEX ( 'GTB', t.totals_group) > 0  THEN	 'GTB'
  WHEN  CHARINDEX ( 'UBA', t.totals_group) > 0  THEN	 'UBA'
  WHEN CHARINDEX ( 'FBN', t.totals_group) > 0  THEN	'FBN'
  WHEN CHARINDEX ( 'OBI', t.totals_group) > 0  THEN	'OBI' 
  WHEN CHARINDEX ( 'WEM', t.totals_group) > 0  THEN	'WEM' 
  WHEN CHARINDEX ( 'AFRI', t.totals_group) > 0  THEN	'AFRI'
  WHEN CHARINDEX ( 'ETB', t.totals_group) > 0  THEN	'ETB'
  WHEN CHARINDEX ( 'IBP', t.totals_group) > 0  THEN	'IBP' 
  WHEN CHARINDEX ( 'IBP', t.totals_group) > 0  THEN	'IBP'
  WHEN CHARINDEX ( 'UBN', t.totals_group) > 0  THEN	'UBN'
  WHEN  CHARINDEX( 'FCMB', t.totals_group) > 0  THEN	'FCMB'
  WHEN CHARINDEX ( 'DBL', t.totals_group) > 0  THEN	'DBL'
  WHEN CHARINDEX ( 'FIB', t.totals_group) > 0  THEN	'FIB'
  WHEN CHARINDEX ( 'EBN', t.totals_group) > 0  THEN	'EBN' 
  WHEN CHARINDEX ( 'ABP', t.totals_group) > 0  THEN	'ABP' 
  WHEN CHARINDEX ( 'UBP', t.totals_group) > 0  THEN	'UBP'
  WHEN CHARINDEX ( 'SPR', t.totals_group) > 0  THEN	'SPR'
  WHEN CHARINDEX ( 'SBP', t.totals_group) > 0  THEN	'SBP'
  WHEN CHARINDEX ( 'CITI', t.totals_group) > 0  THEN	'CITI'
  WHEN  CHARINDEX ( 'ABS', t.totals_group) > 0  THEN	'ABS'
  WHEN  CHARINDEX ( 'OtherCards', t.totals_group) > 0  THEn 'International'
  ELSE   'ISW'				
  
  END,
  acquirer =CASE
  WHEN  acquiring_inst_id_code = '000000'    THEN 'DBL'
  WHEN  acquiring_inst_id_code = '000151182'    THEN 'UBAGH'
  WHEN  acquiring_inst_id_code = '000151593'    THEN 'UBATZA'
  WHEN  acquiring_inst_id_code = '000151616'    THEN 'UBASL'
  WHEN  acquiring_inst_id_code = '000151690'    THEN 'UBACAM'
  WHEN  acquiring_inst_id_code = '000151726'    THEN 'UBAKEN'
  WHEN  acquiring_inst_id_code = '000154396'    THEN 'UBAUGD'
  WHEN  acquiring_inst_id_code = '023023'    THEN    'CITI'
  WHEN  acquiring_inst_id_code = '068068'    THEN 'SCB'
  WHEN  acquiring_inst_id_code = '110011'    THEN 'ISW UGU'
  WHEN  acquiring_inst_id_code = '111111'    THEN 'ISW'
  WHEN  acquiring_inst_id_code = '111128'    THEN 'FBN'
  WHEN  acquiring_inst_id_code = '111129'    THEN 'JBP'
  WHEN  acquiring_inst_id_code = '120011'    THEN 'ABPGHANA'
  WHEN  acquiring_inst_id_code = '120012'    THEN 'FBGHANA'
  WHEN  acquiring_inst_id_code = '130011'    THEN 'GAMS'
  WHEN  acquiring_inst_id_code = '140011'    THEN 'UBASEN'
  WHEN  acquiring_inst_id_code = '150011'    THEN 'UBABENIN'
  WHEN  acquiring_inst_id_code = '151166'    THEN 'UBACH'
  WHEN  acquiring_inst_id_code = '160011'    THEN 'UBABF'
  WHEN  acquiring_inst_id_code = '200011'    THEN 'PNT'
  WHEN  acquiring_inst_id_code = '424367'    THEN 'SCB'
  WHEN  acquiring_inst_id_code = '424465'    THEN 'SCB'
  WHEN  acquiring_inst_id_code = '462526'    THEN 'GTB'
  WHEN  acquiring_inst_id_code = '50612402001'    THEN 'JESSIEFIELD'
  WHEN  acquiring_inst_id_code = '50612402003'    THEN 'SEE'
  WHEN  acquiring_inst_id_code = '50612402004'    THEN 'UNICAL'
  WHEN  acquiring_inst_id_code = '50612402015'    THEN 'AMJU'
  WHEN  acquiring_inst_id_code = '506127'    THEN 'HSL'
  WHEN  acquiring_inst_id_code = '506133'    THEN 'RSL'
  WHEN  acquiring_inst_id_code = '506137'    THEN 'JBP'
  WHEN  acquiring_inst_id_code = '506139'    THEN 'INF'
  WHEN  acquiring_inst_id_code = '506143'    THEN 'ACCMFB'
  WHEN  acquiring_inst_id_code = '506144'    THEN 'EKONDO'
  WHEN  acquiring_inst_id_code = '506146'    THEN 'UML'
  WHEN  acquiring_inst_id_code = '506150'    THEN 'HBC'
  WHEN  acquiring_inst_id_code = '539923'    THEN 'FBN'
  WHEN  acquiring_inst_id_code = '589019'    THEN 'FBN'
  WHEN  acquiring_inst_id_code = '602980'    THEN 'UBN'
  WHEN  acquiring_inst_id_code = '603948'    THEN 'EBN'
  WHEN  acquiring_inst_id_code = '606079'    THEN 'ASO'
  WHEN  acquiring_inst_id_code = '627168'    THEN 'DBL'
  WHEN  acquiring_inst_id_code = '627372'    THEN 'SCB'
  WHEN  acquiring_inst_id_code = '627480'    THEN 'UBA'
  WHEN  acquiring_inst_id_code = '627481'    THEN 'CITI'
  WHEN  acquiring_inst_id_code = '627489'    THEN 'FBP'
  WHEN  acquiring_inst_id_code = '627629'    THEN 'ZIB'
  WHEN  acquiring_inst_id_code = '627749030'    THEN 'HBC'
  WHEN  acquiring_inst_id_code = '627787'    THEN 'GTB'
  WHEN  acquiring_inst_id_code = '627805'    THEN 'PRU'
  WHEN  acquiring_inst_id_code = '627819'    THEN 'PRU'
  WHEN  acquiring_inst_id_code = '627821'    THEN 'WEM'
  WHEN  acquiring_inst_id_code = '627858'    THEN 'CHB'
  WHEN  acquiring_inst_id_code = '627955'    THEN 'KSB'
  WHEN  acquiring_inst_id_code = '628009'    THEN 'FCMB'
  WHEN  acquiring_inst_id_code = '62805102'    THEN 'ISW'
  WHEN  acquiring_inst_id_code = '62805102118'    THEN '62805102118'
  WHEN  acquiring_inst_id_code = '62805111'    THEN 'ISW'
  WHEN  acquiring_inst_id_code = '62805113'    THEN 'ISW'
  WHEN  acquiring_inst_id_code = '62805196118'    THEN '62805196118'
  WHEN  acquiring_inst_id_code = '62805198118'    THEN '62805198118'
  WHEN  acquiring_inst_id_code = '636088'    THEN 'ABP'
  WHEN  acquiring_inst_id_code = '636092'    THEN 'SBP'
  WHEN  acquiring_inst_id_code = '639138'    THEN 'FBP'
  WHEN  acquiring_inst_id_code = '639139'    THEN 'ABP'
  WHEN  acquiring_inst_id_code = '639203'    THEN 'FCMB'
  WHEN  acquiring_inst_id_code = '639249'    THEN 'SBP'
  WHEN  acquiring_inst_id_code = '639563'    THEN 'HBC'
  WHEN  acquiring_inst_id_code = '639609'    THEN 'UBP'
  WHEN  acquiring_inst_id_code = '782427057'    THEN 'ZIB'
  WHEN  acquiring_inst_id_code = '782427058'    THEN 'GTB'
  WHEN  acquiring_inst_id_code = '782427214'    THEN 'FCMB'
  WHEN  acquiring_inst_id_code = '903708'    THEN 'EBN'
  WHEN  acquiring_inst_id_code = '903709'    THEN 'SCB'
  WHEN  acquiring_inst_id_code = '956612924'    THEN 'UBAC'
  ELSE  'ISW'
 END,
 t.totals_group,
own.terminal_code,
m.category_code,
CASE
    WHEN  (nbs.source_node_name = 'SWTNCS2src' AND sink_node_name = 'ASPPOSVINsnk' AND acquiring_inst_id_code !='627787') 
	    OR 
		  (nbs.source_node_name ='SWTFBPsrc' AND  sink_node_name = 'ASPPOSVISsnk' AND totals_group  = 'VISAGroup')
		   THEN 'Intl Visa Transactions (Co-acquired)' 
     WHEN nbs.merchant_type NOT  IN ('2002','1008','4002','4003','4004','8398','8661','4722','5300','5051','5001','5002','7011','1002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','5814','1111','8666')
	       AND  ( nbs.merchant_type <3501 OR   nbs.merchant_type >4000)  AND  ( LEFT(nbs.terminal_id,1)  IN ('2','5')) and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			THEN 'General Merchant and Airline (Operators)'
	 WHEN nbs.merchant_type IN ('2002','4002','4003','8398','8661','5814','8666')  and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			THEN 'Churches, FastFoods and NGOs'
			
		WHEN  nbs.merchant_type = '1008' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			THEN    'Concession Category'
	   WHEN  nbs.merchant_type IN ('4004', '4722') AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Travel Agencies'
		  WHEN  nbs.merchant_type IN ('5001','5002','7011') AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Hotels & Guest Houses (T&E)'
		 WHEN  convert(int, nbs.merchant_type)  >= 3501   AND  convert(int, nbs.merchant_type)  <= 3501 and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			 THEN 'Hotels & Guest Houses (T&E)'
				 WHEN   nbs.merchant_type IN ('1002','5300','5051') and   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			 THEN 'Wholesale'
			 WHEN  nbs.merchant_type = '1111'  AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			    THEN  'WholeSale_Acquirer_Borne'
			WHEN  nbs.merchant_type IN ('4001','5541','9752') AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'FuelStations'
			 	WHEN  nbs.merchant_type ='5542' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Easyfuel'
			WHEN  nbs.merchant_type ='2010' AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5%)'
			 	WHEN  nbs.merchant_type ='2010' AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2011' AND  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5.5%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2011' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(5.5%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2012' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(6%)'
			 	  	 
					 	WHEN  nbs.merchant_type ='2013' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(7%)'
			 			 	WHEN  nbs.merchant_type ='2014' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) 
			 THEN 'Reward Money(10%)'
			 	  	 
				WHEN  nbs.merchant_type ='2015' AND NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(12.5%)'
					WHEN  nbs.merchant_type ='2016' AND   NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		))
			 THEN 'Reward Money(15%)'
			 WHEN   nbs.merchant_type IN ('9001','9002','9003','9004','9005','9006') and  NOT (
    (
    
		tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR 
		(
			tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4'
		)
		OR (
		 	tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR (
		CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828
		)
		
		)) then 'WEBPAY Generic'

			 when  (tran_type = '92'
		AND
		(nbs.merchant_type IN ('4001','9752','1002','1111','2002','4002','4003','4004','5001','5002','5051','5300','5542','5814','6001','8398','8661','8666','9752')
		OR
		CONVERT(INT, nbs.merchant_type)  >=3829  and CONVERT(INT, nbs.merchant_type) <= 4000)
		AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4') then 'POS(GENERAL MERCHANT-VISA)PURCHASE'
when  (tran_type = '92'
		AND ( nbs.merchant_type in ('7011','7512','4411','4722')
		OR 
		(CONVERT(INT, nbs.merchant_type)  >=3351  and CONVERT(INT, nbs.merchant_type) <= 3441)
		OR
		(CONVERT(INT, nbs.merchant_type)  >=3501  and CONVERT(INT, nbs.merchant_type) <= 3828) 
		))then 'POS(2% CATEGORY-VISA)PURCHASE'
when   (		tran_type = '92'
		AND
		(
		 nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
		 AND
		LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4')

		then 'POS(3% CATEGORY-VISA)PURCHASE'
else nbs.Category_name+' '+nbs.merchant_type
END industry_segment
,
(
CASE
WHEN (t.source_node_name ='MGASPUBVIsrc' AND sink_node_name = 'MEGUBAVB2snk' AND  totals_group =  'VISAGroup')
THEN  (0.97)* (

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END
)

 WHEN  LEFT(extended_tran_type_reward,1) IN  ('9', '8') AND Addit_Party in ('ISW','YPM','SAVER') AND tran_type  in ('00','50')
THEN (

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
	  )- (
	  (

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END)* Reward_Discount)
	  
WHEN
 nbs.merchant_type   NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT,nbs.merchant_type) < 3501  OR  CONVERT(INT, nbs.merchant_type) > 4000)
AND  (LEFT(nbs.terminal_id,1)  IN  ('2', '5','6')) AND nbs.message_type NOT IN ('0400','0420') AND nbs.Fee_type = 'P' AND  tran_type in ('00','50', '09')
THEN ((

 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
) - ((CASE WHEN  isPurchaseTrx = 1 AND ABS( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>=nbs.amount_cap THEN  nbs.amount_cap
  ELSE ( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
  END)* (
CASE 
WHEN  nbs.Fee_type = 'P' THEN nbs.merchant_disc 
WHEN  nbs.Fee_type = 'F' THEN nbs.fee_cap 
WHEN  nbs.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
WHEN  nbs.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
then 0.05
ELSE 0 END
)))+ tran_cash_rsp
WHEN  nbs.merchant_type NOT IN ('7011','5001','5002','4001','5542','2010','2011','2012','2013','2014','2015','2016','5541','9752','1111')
AND  (CONVERT(INT,  nbs.merchant_type) < 3501  OR  CONVERT(INT,  nbs.merchant_type) > 4000)
AND  (LEFT( nbs.terminal_id,1)  IN  ('2', '5','6'))
AND   nbs.Fee_type  = 'P'
AND nbs.message_type IN ('0400','0420')
and abs(
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
)>=(nbs.amount_cap)
and tran_type  in ('00','50', '09')
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
	  ELSE 0 END
) +((CASE WHEN  isPurchaseTrx = 1 AND ABS( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>=nbs.amount_cap THEN  nbs.amount_cap
  ELSE ( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
  END)* (
		CASE 
		WHEN  nbs.Fee_type = 'P' THEN nbs.merchant_disc 
		WHEN  nbs.Fee_type = 'F' THEN nbs.fee_cap 
		WHEN  nbs.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  nbs.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

)))+ (tran_cash_rsp)

WHEN nbs.merchant_type IN ('5001','5002','7011','2010','2011','2012','2013','2014','2015','2016') OR  (convert(int, nbs.merchant_type) >= 3501  AND convert(int, nbs.merchant_type)  <=4000)
AND  tran_type  IN ('00','50', '09')
THEN ( (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END) - ( (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)*(
		CASE 
		WHEN  nbs.Fee_type = 'P' THEN nbs.merchant_disc 
		WHEN  nbs.Fee_type = 'F' THEN nbs.fee_cap 
		WHEN  nbs.Fee_type = 'S' AND ABS(settle_amount_rsp)>= 5000 THEN 0.05
		WHEN  nbs.Fee_type = 'S' AND ABS(settle_amount_rsp)< 5000
		then 0.05
		ELSE 0 END

))+ (tran_cash_rsp))

WHEN nbs.merchant_type  IN ('4001','5542','5541','9752','1111') AND  tran_type in ('00','50', '09')
THEN (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
  + (tran_cash_rsp)
WHEN  tran_type   =  '01'  THEN  (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
WHEN nbs.merchant_type  in ('4004','4722')
and nbs.message_type NOT IN ('0400','0420') AND  rsp_code_rsp  IN ('00','08','10','11','16')
and abs(
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>= 200
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)-(nbs.fee_cap) + tran_cash_rsp)
WHEN nbs.merchant_type IN ('4004','4722') AND  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)< 200)
THEN (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
WHEN  nbs.merchant_type in ('4004','4722') AND nbs.message_type in ('0400','0420') and  rsp_code_rsp IN ('00','08','10','11','16')
and  (abs(
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)>= 200)
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+nbs.fee_cap)+ (-1*tran_cash_rsp)
  
  WHEN nbs.Fee_type = 'F' AND left(nbs.terminal_id,1) = '3' AND nbs.message_type in ('0200','0220') and  rsp_code_rsp IN ('00','08','10','11','16')
THEN (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
 WHEN nbs.Fee_type = 'F' AND left(nbs.terminal_id,1) = '3' AND nbs.message_type in ('0400','0420') and rsp_code_rsp IN ('00','08','10','11','16')
then (
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)+ tran_cash_rsp
WHEN nbs.Fee_type = 'S' AND tran_type in ('00','50','09') and nbs.merchant_type = '9008' 
THEN ((
 CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END) - ( CASE WHEN nbs.Fee_type  = 'P' THEN  nbs.merchant_disc
	  WHEN  nbs.Fee_type = 'F' THEN nbs.fee_cap
	  WHEN nbs.Fee_type = 'S'  AND ABS(settle_amount_rsp)>= 5000 then 0.05
	  WHEN nbs.Fee_type  = 'S' AND ABS(settle_amount_rsp)< 5000 then 0.05
	  ELSE 0
	 END
))+ tran_cash_rsp

ELSE 0
END
)
 -(
CASE WHEN extended_tran_type  = '9001' THEN  0.01 * ( CASE WHEN RIGHT(tran_type_desciption,2) = '_M' then 0
      WHEN nbs.message_type = '0100' AND sink_node_name <> 'VTUsnk' AND rdm_amount = 0  THEN settle_amount_rsp
      WHEN isDepositTrx <>1  AND rdm_amount = 0  and sink_node_name <> 'VTUsnk'then -1 * (settle_amount_impact) 
	  WHEN sink_node_name <> 'VTUsnk' AND rdm_amount <> 0  then rdm_amount
  ELSE 0 END)
ELSE 0
END) merchant_receivable

FROM tbl_web_pos_acquirer_nibss  nbs (NOLOCK) 

LEFT JOIN  tbl_merchant_account mrch(NOLOCK)
ON 
nbs.card_acceptor_id_code = mrch.card_acceptor_id_code
AND nbs.message_type IN ('0200','0220')
LEFT  JOIN 
tbl_PTSP psp (NOLOCK)
ON
nbs.terminal_id = psp.terminal_id
 LEFT  JOIN
 post_tran_cust t (NOLOCK, INDEX(pk_post_tran_cust)) ON

nbs.TranID  = t.post_tran_cust_id
 LEFT  JOIN 
tbl_terminal_owner own (NOLOCK) 
ON
nbs.terminal_id= own.terminal_id
 JOIN tbl_merchant_category m (NOLOCK)
				ON nbs.merchant_type = m.category_code
JOIN post_currencies cur (NOLOCK) on
nbs.currency_alpha_code = cur.alpha_code
JOIN 
AID_CBN_CODE aid (nolock)
on
aid.cbn_code1 = nbs.bank_code


OPTION (RECOMPILE, MAXDOP 8)