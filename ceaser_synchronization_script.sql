SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
SELECT 
Account_Name
,account_nr
,Acquiring_bank
,nbs.acquiring_inst_id_code
,nbs.Addit_Charge
,nbs.Addit_Party
,nbs.aggregate_column
,nbs.amount_cap
,nbs.Amount_Cap_RD
,Authorized_Person
,nbs.bank_code
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
,PTSP_code
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
,nbs.terminal_owner
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
  ELSE  t.totals_group					
  
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
  ELSE  acquiring_inst_id_code
 END,
 t.totals_group,
own.terminal_code,
m.category_code
FROM tbl_web_pos_acquirer_nibss  nbs (NOLOCK) LEFT JOIN  tbl_merchant_account mrch(NOLOCK)
ON 
nbs.card_acceptor_id_code = mrch.card_acceptor_id_code
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
				ON t.merchant_type = m.category_code
JOIN post_currencies cur (NOLOCK) on
nbs.currency_alpha_code = cur.alpha_code


OPTION (RECOMPILE, MAXDOP 8)