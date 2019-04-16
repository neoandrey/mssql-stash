USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[usp_get_daily_pos_settlement_data_for_ceaser]    Script Date: 03/02/2017 12:10:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER  procedure [dbo].[usp_get_daily_pos_settlement_data_for_ceaser] AS

BEGIN

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET NOCOUNT ON;
;WITH  ceaser_table AS (
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
,ISNULL(t.card_acceptor_id_code, 'ISW_MERCHANT')card_acceptor_id_code
,t.card_acceptor_name_loc
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
,CONVERT(VARCHAR(8), isnull(PTSP_code, 'ISW_PTSP')) ptsp_code
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
--, isnull(nbs.terminal_owner, 'ISW_PTO') terminal_owner
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
,issuer = 

CASE 
WHEN SUBSTRING(t.pan, 1,6) = '506104' then 'Access Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506118' then 'EcoBank Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '506108' then 'First City Monument Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506115' then 'Fidelity Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506114' then 'First Inland Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506105' then 'First Bank of Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '506103' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506101' then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506110' then 'Keystone Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506106' then 'Skye Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506116' then 'Enterprise Bank Verve'
WHEN SUBSTRING(t.pan, 1,6) = '506107' then 'Sterling Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506102' then 'United Bank for Africa'
WHEN SUBSTRING(t.pan, 1,6) = '506117' then 'Unity Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506119' then 'Wema Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506109' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506120' then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506122' then 'Oceanic Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506123' then 'Union Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506121' then 'ASO Savings'
WHEN SUBSTRING(t.pan, 1,6) = '506127' then 'Hasal MFB'
WHEN SUBSTRING(t.pan, 1,6) = '506128' then 'Main Street Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506125' then 'Equitorial Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506111' then 'FBN Micro Finance'
WHEN SUBSTRING(t.pan, 1,6) = '506129' then 'Skye Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506133' then 'Resort MFB'
WHEN SUBSTRING(t.pan, 1,6) = '533853' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '541569' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '539983' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '533856' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '533853' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '539923' then 'FBN Naira Mastercard'
WHEN SUBSTRING(t.pan, 1,6) = '519878' then 'FBN Naira Mastercard' 
WHEN SUBSTRING(t.pan, 1,6) = '540761' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '520053' then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '521623' then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '557693' then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '526897' then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '531213' then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '557694' then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '512336' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '515803' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '530519' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '531525' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '533301' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '539941' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '547160' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '549970' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '559443' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '540884' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '542231' then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '536399' then 'Unity Bank'
WHEN SUBSTRING(t.pan, 1,6) = '551609' then 'Unity Bank'
WHEN SUBSTRING(t.pan, 1,6) = '521988' then 'Unity Bank'
WHEN SUBSTRING(t.pan, 1,6) = '539945' then 'Skye Bank'
WHEN SUBSTRING(t.pan, 1,6) = '555940' then 'Keystone Bank'
WHEN SUBSTRING(t.pan, 1,6) = '532732' then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '548712' then 'Ecobank Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '548458' then 'Ecobank Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '532968' then 'Ecobank Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '531667' then 'Ecobank Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '506138' then 'First Inland Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506135' then 'Sterling Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '528649' then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506136' then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '528650' then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '559424' then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '559432' then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '559453' then 'Wema Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506134' then 'Union Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506142' then 'Sterling Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506143' then 'Accion MFB'
WHEN SUBSTRING(t.pan, 1,6) = '506141' then 'Post Service Homes Limited'
WHEN SUBSTRING(t.pan, 1,6) = '506148' then 'Sterling Bank(Ohafia MFB)'
WHEN SUBSTRING(t.pan, 1,6) = '506137' then 'Jaiz Bank'
WHEN SUBSTRING(t.pan, 1,6) = '553813' then 'Jaiz Bank'
WHEN SUBSTRING(t.pan, 1,6) = '528668' then 'Enterprise Bank Non-Verve'
WHEN SUBSTRING(t.pan, 1,6) = '506140' then 'First Bank of Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '506150' then 'Heritage Bank'
WHEN SUBSTRING(t.pan, 1,6) = '514585' then 'Fidelity Bank Mastercard'
WHEN SUBSTRING(t.pan, 1,6) = '512934' then 'Heritage Bank Mastercard'
WHEN SUBSTRING(t.pan, 1,6) = '506147' then 'Sterling Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(sink_node_name,4,3)='ZIB' Then 'Zenith International Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='PRU' Then 'Skye Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='PLA' Then 'Keystone Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='CHB' Then 'Stanbic IBTCC Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='GTB' Then 'Guaranty Trust Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(sink_node_name,4,3)='FBN' and not(LEFT(t.pan, 1)= '4')Then 'First Bank of Nigeria'
WHEN  SUBSTRING(sink_node_name,4,3)='OBI' Then 'Oceanic Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='WEM' Then 'Wema Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,3)='AFRI' Then 'Main Street Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='ETB' Then 'Equitorial Trust Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='UBN' Then 'Union Bank of Nigeria'
WHEN  SUBSTRING(sink_node_name,4,4)='FCMB' Then 'First City Monument Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='DBL' Then 'Diamond Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='FIB' Then 'First Inland Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='EBN' Then 'EcoBank Nigeria'
WHEN  SUBSTRING(sink_node_name,4,3)='ABP' Then 'Access Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,3)='UBP' Then 'Unity Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,3)='SPR' Then 'Enterprise Bank Non-Verve'
WHEN  SUBSTRING(sink_node_name,4,3)='SBP' Then 'Sterling Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,4)='CITI' Then 'Citi Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(sink_node_name,4,3)='ZIB' Then 'Zenith International Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='PRU' Then 'Skye Bank'
WHEN  SUBSTRING(sink_node_name,4,4)='PLAT' Then 'Keystone Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='CHB' Then 'Stanbic IBTCC Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='GTB' Then 'Guaranty Trust Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(sink_node_name,4,3)='OBI' Then 'Oceanic Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='WEM' Then 'Wema Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,4)='AFRI' Then 'Main Street Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='ETB' Then 'Equitorial Trust Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='UBN' Then 'Union Bank of Nigeria'
WHEN  SUBSTRING(sink_node_name,4,4)='FCMB' Then 'First City Monument Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='DBL' Then 'Diamond Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='FIB' Then 'First Inland Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='EBN' Then 'EcoBank Nigeria'
WHEN  SUBSTRING(sink_node_name,4,3)='ABP' Then 'Access Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,3)='UBP' Then 'Unity Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,3)='SPR' Then 'Enterprise Bank Non-Verve'
WHEN  SUBSTRING(sink_node_name,4,3)='SBP' Then 'Sterling Bank Plc'
WHEN  SUBSTRING(sink_node_name,4,4)='CITI' Then 'Citi Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='ABS' Then 'Abbey Mortgage Bank'
WHEN  SUBSTRING(sink_node_name,4,6)='PAYCOM' Then 'Paycom'
WHEN  SUBSTRING(sink_node_name,4,6)='CELCMS' Then 'Cellulant MFB'
WHEN  SUBSTRING(sink_node_name,4,3)='ENT' Then 'Enterprise Bank Non-Verve'
WHEN  SUBSTRING(sink_node_name,4,3)='HBC' Then 'Heritage Bank Mastercard'
WHEN  SUBSTRING(sink_node_name,4,3)='CAP' Then '03 Capital MFB'
WHEN  SUBSTRING(sink_node_name,4,3)='FGM' Then 'First Generation Mortgage Bank'
WHEN  SUBSTRING(sink_node_name,4,3)='MOU' Then 'Michael Okapara University MFB'
WHEN  SUBSTRING(sink_node_name,4,4)='SMFB' Then 'Seedvest MFB'
WHEN  SUBSTRING(sink_node_name,4,3)='TRU' Then 'TrustBond MFB'
WHEN  SUBSTRING(sink_node_name,4,4)='NPMB' Then 'Nigerian Police'
WHEN  SUBSTRING(sink_node_name,4,4)='AMJU' Then 'AMJU'
WHEN  SUBSTRING(sink_node_name,4,3)='OMO'  Then 'OMOLUABI SAVINGS AND LOANS'
WHEN  SUBSTRING(totals_group,1,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(totals_group,1,3)='ZIB' Then 'Zenith International Bank'
WHEN  SUBSTRING(totals_group,1,3)='PRU' Then 'Skye Bank'
WHEN  SUBSTRING(totals_group,1,3)='PLA' Then 'Keystone Bank'
WHEN  SUBSTRING(totals_group,1,3)='CHB' Then 'Stanbic IBTCC Bank'
WHEN  SUBSTRING(totals_group,1,3)='GTB' Then 'Guaranty Trust Bank'
WHEN  SUBSTRING(totals_group,1,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(totals_group,1,3)='FBN' and not(left(t.pan, 1) = '4') Then 'First Bank of Nigeria'
WHEN  SUBSTRING(totals_group,1,3)='OBI' Then 'Oceanic Bank'
WHEN  SUBSTRING(totals_group,1,3)='WEM' Then 'Wema Bank Plc'
WHEN  SUBSTRING(totals_group,1,3)='AFR' Then 'Main Street Bank'
WHEN  SUBSTRING(totals_group,1,3)='ETB' Then 'Equitorial Trust Bank'
WHEN  SUBSTRING(totals_group,1,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(totals_group,1,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(totals_group,1,3)='UBN' Then 'Union Bank of Nigeria'
WHEN  SUBSTRING(totals_group,1,4)='FCMB' Then 'First City Monument Bank'
WHEN  SUBSTRING(totals_group,1,3)='DBL' Then 'Diamond Bank'
WHEN  SUBSTRING(totals_group,1,3)='FIB' Then 'First Inland Bank'
WHEN  SUBSTRING(totals_group,1,3)='EBN' Then 'EcoBank Nigeria'
WHEN  SUBSTRING(totals_group,1,3)='ABP' Then 'Access Bank Plc'
WHEN  SUBSTRING(totals_group,1,3)='UBP' Then 'Unity Bank Plc'
WHEN  SUBSTRING(totals_group,1,3)='SPR' Then 'Enterprise Bank Non-Verve'
WHEN  SUBSTRING(totals_group,1,3)='SBP' Then 'Sterling Bank Plc'
WHEN  SUBSTRING(totals_group,1,4)='CITI' Then 'Citi Bank'
WHEN  SUBSTRING(totals_group,1,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(totals_group,1,3)='ZIB' Then 'Zenith International Bank'
WHEN  SUBSTRING(totals_group,1,3)='PRU' Then 'Skye Bank'
WHEN  SUBSTRING(totals_group,1,3)='CHB' Then 'Stanbic IBTCC Bank'
WHEN  SUBSTRING(totals_group,1,3)='GTB' Then 'Guaranty Trust Bank'
WHEN  SUBSTRING(totals_group,1,3)='UBA' Then 'United Bank for Africa'
WHEN  SUBSTRING(totals_group,1,3)='FBN' and LEFT(t.pan, 1) = '4' Then 'FBN Visa'
WHEN  SUBSTRING(totals_group,1,3)='OBI' Then 'Oceanic Bank'
WHEN  SUBSTRING(totals_group,1,3)='WEM' Then 'Wema Bank Plc'
WHEN  SUBSTRING(totals_group,1,3)='ETB' Then 'Equitorial Trust Bank'
WHEN  SUBSTRING(totals_group,1,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(totals_group,1,3)='IBP' Then 'Intercontinental Bank'
WHEN  SUBSTRING(totals_group,1,3)='UBN' Then 'Union Bank of Nigeria'
WHEN  SUBSTRING(totals_group,1,3)='DBL' Then 'Diamond Bank'
WHEN  SUBSTRING(totals_group,1,3)='FIB' Then 'First Inland Bank'
WHEN  SUBSTRING(totals_group,1,3)='EBN' Then 'EcoBank Nigeria'
WHEN  SUBSTRING(totals_group,1,3)='ABP' Then 'Access Bank Plc'
WHEN  SUBSTRING(totals_group,1,3)='UBP' Then 'Unity Bank Plc'
WHEN  SUBSTRING(totals_group,1,3)='SPR' Then 'Enterprise Bank Non-Verve'
WHEN  SUBSTRING(totals_group,1,3)='SBP' Then 'Sterling Bank Plc'
WHEN  SUBSTRING(totals_group,1,4)='CITI' Then 'Citi Bank'
WHEN  SUBSTRING(totals_group,1,3)='ABS' Then 'Abbey Mortgage Bank'
WHEN  SUBSTRING(totals_group,1,6)='PAYCOM' Then 'Paycom'
WHEN  SUBSTRING(totals_group,1,3)='ENT' Then 'Enterprise Bank Non-Verve'
WHEN  SUBSTRING(totals_group,1,3)='FBP'  Then 'Fidelity Bank'
WHEN  SUBSTRING(totals_group,1,3)='SCB'  Then 'Standard Chartered Bank'
WHEN  SUBSTRING(totals_group,1,3)='HBC'  Then 'Heritage Bank Mastercard'
WHEN  SUBSTRING(totals_group,1,3)='UML'  Then 'United Mortgage Bank'
WHEN  SUBSTRING(totals_group,1,3)='OMO'  Then'OMOLUABI SAVINGS AND LOANS'
WHEN  SUBSTRING(totals_group,1,3)='SUN'  Then 'Suntrust Bank Limited'
WHEN  SUBSTRING(totals_group,1,4)='INFH'  Then 'Infinity Homes'
WHEN  SUBSTRING(totals_group,1,3)='NPM'  Then 'Nigeria Police'
WHEN  SUBSTRING(totals_group,1,3)='ALV'  Then 'ALVANA Bank'
WHEN  SUBSTRING(totals_group,1,3)='POL'  Then 'POLYUNWANA MICROFINANCE BANK'
WHEN  SUBSTRING(totals_group,1,3)='PRO'  Then 'PROVIDUS BANK'
WHEN  SUBSTRING(totals_group,1,3)='MAY'  Then 'MAYFRESH BANK'
WHEN  SUBSTRING(totals_group,1,3)='PAR'  Then 'PARALLEX BANK'
WHEN  SUBSTRING(totals_group,1,4)='UNIL'  Then 'UNILORIN BANK'
WHEN SUBSTRING(t.pan, 1,6) in ( '521090','519911','517868','519885','519863') then 'United Bank for Africa'
WHEN SUBSTRING(t.pan, 1,6) in ('519899','519905','559424') then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) in ('527699','524282','519830','521973','519615') then 'First City Monument Bank'
WHEN SUBSTRING(t.pan, 1,6) in ('537610','523776','518304','528668') then 'Enterprise Bank Non-Verve'
WHEN SUBSTRING(t.pan, 1,6) in ('539945','519909') then'Skye Bank'


WHEN  LEFT(extended_tran_type_reward ,4) =  '1000' THEN 'FBN First-Point'
 WHEN  LEFT(extended_tran_type_reward ,4) =  '3000' THEN 'FBN Forte Oil'
 WHEN   rdm_amount <> 0  AND NOT (LEFT(extended_tran_type_reward ,4) =  '1000')   AND NOT (LEFT(extended_tran_type_reward ,4) =  '3000') THEN 'InterSwitch'
 WHEN   payee = 'Verve' then 'InterSwitch'

WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '627821' then 'Wema TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '627480' then 'UBA TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '627805' then 'Skye TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '589019' then 'FBN TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '627858' then 'CHB TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '602980' then 'UBN TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code IN ('639563','512934','457714','506150') then 'HBC TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code IN ('627787','462526') then 'GTB TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code IN ('903708','603948') then 'EBN TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '627955' then 'KSB_TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '628009' then 'FCMB TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '639138' then 'FBP TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '639609' then 'UBP TempMcard'
WHEN  t.source_node_name IN ('SWTNCS2src','SWTNCSKIMsrc','SWTFBPsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '639139' then 'ABP TempMcard'
WHEN t.source_node_name IN  ('SWTNCS2src','SWTNCSKIMsrc','SWTSHOPRTsrc') and sink_node_name = 'ASPPOSLMCsnk' and acquiring_inst_id_code = '627481'  then 'UBA(For Citi) TempMcard'
WHEN t.source_node_name IN  ('SWTSHOPRTsrc') and sink_node_name = 'ASPPOSLMCsnk'  then 'UBA(For Citi) TempMcard'

WHEN SUBSTRING (extended_tran_type,2,3)='033' and sink_node_name = 'ESBCSOUTsnk' Then 'United Bank for Africa'
WHEN SUBSTRING (extended_tran_type,2,3)='057' and sink_node_name = 'ESBCSOUTsnk' Then 'Zenith International Bank'
WHEN SUBSTRING (extended_tran_type,2,3)='076' and sink_node_name = 'ESBCSOUTsnk' Then 'Skye Bank'
WHEN SUBSTRING (extended_tran_type,2,3)='082' and sink_node_name = 'ESBCSOUTsnk' Then 'Keystone Bank'
WHEN SUBSTRING (extended_tran_type,2,3) IN ('039','221') and sink_node_name = 'ESBCSOUTsnk' Then 'Stanbic IBTCC Bank'
WHEN SUBSTRING (extended_tran_type,2,3)='058' and sink_node_name = 'ESBCSOUTsnk' Then 'Guaranty Trust Bank'
WHEN SUBSTRING (extended_tran_type,2,3) IN ('701','011')  and sink_node_name = 'ESBCSOUTsnk' Then 'First Bank of Nigeria'
WHEN SUBSTRING (extended_tran_type,2,3)='035' and sink_node_name = 'ESBCSOUTsnk' Then 'Wema Bank Plc'
WHEN SUBSTRING (extended_tran_type,2,3)='014' and sink_node_name = 'ESBCSOUTsnk' Then 'Skye Bank'
WHEN SUBSTRING (extended_tran_type,2,3)='032' and sink_node_name = 'ESBCSOUTsnk' Then 'Union Bank of Nigeria'
WHEN SUBSTRING (extended_tran_type,2,3)='214' and sink_node_name = 'ESBCSOUTsnk' Then 'First City Monument Bank'
WHEN SUBSTRING (extended_tran_type,2,3)='063' and sink_node_name = 'ESBCSOUTsnk' Then 'Diamond Bank'
WHEN SUBSTRING (extended_tran_type,2,3)='050' and sink_node_name = 'ESBCSOUTsnk' Then 'EcoBank Nigeria'
WHEN SUBSTRING (extended_tran_type,2,3)='044' and sink_node_name = 'ESBCSOUTsnk' Then 'Access Bank Plc'
WHEN SUBSTRING (extended_tran_type,2,3)='215' and sink_node_name = 'ESBCSOUTsnk' Then 'Unity Bank Plc'
WHEN SUBSTRING (extended_tran_type,2,3)='030' and sink_node_name = 'ESBCSOUTsnk' Then 'Heritage Bank'
WHEN SUBSTRING (extended_tran_type,2,3)='232' and sink_node_name = 'ESBCSOUTsnk' Then 'Sterling Bank Plc'
WHEN SUBSTRING (extended_tran_type,2,3)='023' and sink_node_name = 'ESBCSOUTsnk' Then 'Citi Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '589019') Then 'FBN Magstrip'
WHEN  (SUBSTRING(t.pan, 1,6) = '627480') Then 'United Bank for Africa'
WHEN (SUBSTRING(t.pan, 1,6) = '627629')  Then 'Zenith International Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627752')  Then 'United Bank for Africa'
WHEN (SUBSTRING(t.pan, 1,6) = '627787')  Then 'Guaranty Trust Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627805')  Then 'Skye Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627975')  Then 'Skye Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '628027')  Then 'Skye Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '603948')  Then 'Oceanic Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627821')  Then 'Wema Bank Plc'
WHEN (SUBSTRING(t.pan, 1,6) = '628016')  Then 'Wema Bank Plc'
WHEN (SUBSTRING(t.pan, 1,6) = '627819')  Then 'Main Street Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627858')  Then 'Stanbic IBTCC Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627955')  Then 'Keystone Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '628009')  Then 'First City Monument Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '628027')  Then 'EIB International Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '639138')  Then 'Fidelity Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '639276')  Then 'Fidelity Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '636088')  Then 'Intercontinental Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '602980')  Then 'Union Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627681')  Then 'Union Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '627168')  Then 'Diamond Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '639203')  Then 'First Inland Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '639249')  Then 'Equitorial Trust Bank'
WHEN (SUBSTRING(t.pan, 1,6) = '639139')  Then 'Access Bank Plc'
WHEN (SUBSTRING(t.pan, 1,6) = '636092')  Then 'Sterling Bank Plc'
WHEN (SUBSTRING(t.pan, 1,6) = '903708')  Then 'EcoBank Nigeria'
WHEN (SUBSTRING(t.pan, 1,6) = '639609')  Then 'Unity Bank Plc'
WHEN (SUBSTRING(t.pan, 1,6) = '639563')  Then 'Enterprise Bank Non-Verve'
WHEN (SUBSTRING(t.pan, 1,6) = '606079')  Then 'Aso Savings'
WHEN (SUBSTRING(t.pan, 1,6) = '639587')  Then '3LINE'
WHEN SUBSTRING(t.pan, 1,6) = '521988' then 'Unity Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506140' then 'First Bank of Nigeria'

WHEN SUBSTRING(t.pan, 1,6) = '628051' AND SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN SUBSTRING(t.pan, 1,6) = '628051' AND SUBSTRING(sink_node_name,4,3)='ZIB' Then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' AND SUBSTRING(sink_node_name,4,3)='PRU' Then 'Skye Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' AND SUBSTRING(sink_node_name,4,3)='PLAT' Then 'Keystone Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' AND SUBSTRING(sink_node_name,4,3)='CHB' Then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' AND SUBSTRING(sink_node_name,4,3)='GTB' Then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='FBN' Then 'First Bank of Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='OBI' Then 'Oceanic Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='WEM' Then 'Wema Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='AFRI' Then 'Main Street Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='ETB' Then 'Equitorial Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='UBN' Then 'Union Bank of Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,4)='FCMB' Then 'First City Monument Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='DBL' Then 'Diamond Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='FIB' Then 'First Inland Bank'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='EBN' Then 'EcoBank Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='ABP' Then 'Access Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='UBP' Then 'Unity Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='SPR' Then 'Enterprise Bank Non-Verve'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,3)='SBP' Then 'Sterling Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '628051' and SUBSTRING(sink_node_name,4,4)='CITI' Then 'Citi Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='ZIB' Then 'Zenith International Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='PRU' Then 'Skye Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,4)='PLAT' Then 'Keystone Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='CHB' Then 'Stanbic IBTCC Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='GTB' Then 'Guaranty Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='UBA' Then 'United Bank for Africa'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='FBN' Then 'FBN CashCard'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='OBI' Then 'Oceanic Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='WEM' Then 'Wema Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,4)='AFRI' Then 'Main Street Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='ETB' Then 'Equitorial Trust Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='IBP' Then 'Intercontinental Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='UBN' Then 'Union Bank of Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,4)='FCMB' Then 'First City Monument Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='DBL' Then 'Diamond Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='FIB' Then 'First Inland Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='EBN' Then 'EcoBank Nigeria'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='ABP' Then 'Access Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='UBP' Then 'Unity Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='SPR' Then 'Enterprise Bank Verve'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='SBP' Then 'Sterling Bank Plc'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,4)='CITI' Then 'Citi Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,3)='ABS' Then 'Abbey Mortgage Bank'
WHEN SUBSTRING(t.pan, 1,6) = '506100' and SUBSTRING(sink_node_name,4,6)='PAYCOM' Then 'Paycom'
WHEN SUBSTRING(t.pan, 1,6) = '782427' and SUBSTRING(sink_node_name,4,3)='CHB' Then 'Stanbic Easyfuel'
WHEN SUBSTRING(t.pan, 1,6) = '782427' and SUBSTRING(sink_node_name,4,3)='EBN' Then 'EcoBank EasyFuel'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='RDY' Then 'Readycash'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='UNI' Then 'UNICAL MFB'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='CON' Then 'Covenant MFB'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='NPR' Then 'NPR'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='AGH' Then 'AGHomes'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='NPM' Then 'Nigerian Police'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='WET' Then 'Wetland MFB'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='MUT' Then 'Mutual Alliance'
WHEN SUBSTRING(t.pan, 1,6) = '506124' and SUBSTRING(sink_node_name,4,3)='OMO' Then 'OMOLUABI SAVINGS AND LOANS'
WHEN (CASE
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
when   (             tran_type = '92'
              AND
              (
              nbs.merchant_type  =  '4511'OR  CONVERT(INT, nbs.merchant_type)  >=3000  and CONVERT(INT, nbs.merchant_type) <= 3299)
              AND
              LEFT (nbs.terminal_id,1) IN ('2','5','6') AND LEFT(nbs.pan, 1 ) = '4')

              then 'POS(3% CATEGORY-VISA)PURCHASE'
else nbs.Category_name+' '+nbs.merchant_type
END) = 'Intl Visa Transactions (Co-acquired)' then 'UBA Visa Intl'

else SUBSTRING(t.pan, 1,6) END

,issuer_alpha_code=
  
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
  		WHEN ( t.totals_group LIKE 'FGMB%' OR card_product LIKE 'FGMB%')THEN 'FGMB'
		WHEN ( t.totals_group LIKE 'CEL%' OR card_product LIKE 'CEL%') THEN 'CEL'
		WHEN ( t.totals_group LIKE 'RDY%' OR card_product LIKE 'RDY%') THEN 'RDY'
		WHEN ( t.totals_group LIKE 'AMJ%' OR card_product LIKE 'AMJ%') THEN 'AMJU'
		WHEN ( t.totals_group LIKE 'CAP%' OR card_product LIKE 'CAP%') THEN 'O3CAP'
		WHEN ( t.totals_group LIKE 'VER%' OR card_product LIKE 'VER%') THEN 'VER_GLOBAL'
		WHEN ( t.totals_group LIKE 'SMF%' OR card_product LIKE 'SMF%') THEN 'SMFB'
		WHEN ( t.totals_group LIKE 'SLT%' OR card_product LIKE 'SLT%') THEN 'SLTD'
		WHEN ( t.totals_group LIKE 'JES%' OR card_product LIKE 'JES%') THEN 'JES'
		WHEN ( t.totals_group LIKE 'MOU%' OR card_product LIKE 'MOU%') THEN 'MOUA'
		WHEN ( t.totals_group LIKE 'MUT%' OR card_product LIKE 'MUT%') THEN 'MUT'
		WHEN ( t.totals_group LIKE 'LAV%' OR card_product LIKE 'LAV%') THEN 'LAV'
		WHEN ( t.totals_group LIKE 'JUB%' OR card_product LIKE 'JUB%') THEN 'JUB'
		WHEN ( t.totals_group LIKE 'WET%' OR card_product LIKE 'WET%') THEN 'WET'
		WHEN ( t.totals_group LIKE 'AGH%' OR card_product LIKE 'AGH%') THEN 'AGH'
		WHEN ( t.totals_group LIKE 'TRU%' OR card_product LIKE 'TRU%') THEN 'TRU'
		WHEN ( t.totals_group LIKE 'CON%' OR card_product LIKE 'CON%') THEN 'CON'
		WHEN ( t.totals_group LIKE 'CRU%' OR card_product LIKE 'CRU%') THEN 'CRU'
		WHEN ( t.totals_group LIKE 'NPR%' OR card_product LIKE 'NPR%') THEN 'NPR'
		WHEN ( t.totals_group LIKE 'OMO%' OR card_product LIKE 'OMO%') THEN 'OMO'
		WHEN ( t.totals_group LIKE 'SUN%' OR card_product LIKE 'SUN%') THEN 'SUN'
		WHEN ( t.totals_group LIKE 'NGB%' OR card_product LIKE 'NGB%') THEN 'NGB'
		WHEN ( t.totals_group LIKE 'OSC%' OR card_product LIKE 'OSC%') THEN 'OSC'
		WHEN ( t.totals_group LIKE 'OSP%' OR card_product LIKE 'OSP%') THEN 'OSP'
		WHEN ( t.totals_group LIKE 'IFIS%' OR card_product LIKE 'IFIS%') THEN 'IFIS'
		WHEN ( t.totals_group LIKE 'NPM%' OR card_product LIKE 'NPM%') THEN 'NPM'
		WHEN ( t.totals_group LIKE 'POL%' OR card_product LIKE 'POL%') THEN 'POL'
		WHEN ( t.totals_group LIKE 'ALV%' OR card_product LIKE 'ALV%') THEN 'ALV'
		WHEN ( t.totals_group LIKE 'MAY%' OR card_product LIKE 'MAY%') THEN 'MAY'
		WHEN ( t.totals_group LIKE 'PRO%' OR card_product LIKE 'PRO%') THEN 'PRO'
		WHEN ( t.totals_group LIKE 'UNIL%' OR card_product LIKE 'UNIL%') THEN 'UNIL'
		WHEN ( t.totals_group LIKE 'PAR%' OR card_product LIKE 'PAR%') THEN 'PAR'
		WHEN ( t.totals_group LIKE 'FOR%' OR card_product LIKE 'FOR%') THEN 'FOR'
		WHEN ( t.totals_group LIKE 'MON%' OR card_product LIKE 'MON%') THEN 'MON'

  
  WHEN  CHARINDEX ( 'OtherCards', t.totals_group) > 0  THEn 'International'
  ELSE   'ISW_ISSUER'					
  
  END
  ,issuer_bank_code=
CASE  
  WHEN CHARINDEX (  'UBA', t.totals_group) > 0  THEN   '033'
  WHEN  CHARINDEX ( 'ZIB', t.totals_group) > 0  THEN   '057'
  WHEN  CHARINDEX ( 'PRU', t.totals_group) > 0  THEN   '076'
  WHEN  CHARINDEX ( 'PLAT', t.totals_group) > 0  THEN  '082'
  WHEN  CHARINDEX ( 'KSB', t.totals_group) > 0  THEN  '082'
  WHEN  CHARINDEX ( 'CHB', t.totals_group) > 0  THEN   '221'
  WHEN  CHARINDEX ( 'GTB', t.totals_group) > 0  THEN   '058'
  WHEN  CHARINDEX ( 'FBN', t.totals_group) > 0  THEN   '011'
  WHEN  CHARINDEX ( 'OBI', t.totals_group) > 0  THEN   '056'
  WHEN  CHARINDEX ( 'WEM', t.totals_group) > 0  THEN   '035'
  WHEN  CHARINDEX ( 'AFRI', t.totals_group) > 0  THEN  '076'
  WHEN  CHARINDEX ( 'IBP', t.totals_group) > 0  THEN   '044'
  WHEN  CHARINDEX ( 'UBN', t.totals_group) > 0  THEN   '032'
  WHEN  CHARINDEX ( 'FCMB', t.totals_group) > 0  THEN  '214'
  WHEN  CHARINDEX ( 'DBL', t.totals_group) > 0  THEN   '063'
  WHEN  CHARINDEX ( 'FIB', t.totals_group) > 0  THEN   '214'
  WHEN  CHARINDEX ( 'EBN', t.totals_group) > 0  THEN   '050'
  WHEN  CHARINDEX ( 'ABP', t.totals_group) > 0  THEN   '044'
  WHEN  CHARINDEX ( 'UBP', t.totals_group) > 0  THEN   '215'
  WHEN  CHARINDEX ( 'SPR', t.totals_group) > 0  THEN   'SPR'
  WHEN  CHARINDEX ( 'SBP', t.totals_group) > 0  THEN   '232'
  WHEN  CHARINDEX ( 'CITI', t.totals_group) > 0  THEN  '023'
  --WHEN  CHARINDEX ( 'FD', t.totals_group) > 0  THEN    'FD'
  WHEN  CHARINDEX ( 'FBP', t.totals_group) > 0  THEN   '070'
  WHEN  CHARINDEX ( 'SCB', t.totals_group) > 0  THEN   '068' 
  WHEN  CHARINDEX ( 'ABS', t.totals_group) > 0  THEN   'ABS'
  WHEN  CHARINDEX ( 'OtherCards', t.totals_group) > 0  THEN'International'
  ELSE   '111' end ,
  
  acquirer_alpha_code =CASE
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
  ELSE  'ISW_ACQUIRER'
 END,
 
 acquirer_bank_code = 
CASE 
	WHEN  SUBSTRING(t.terminal_id,2,3)  = '033' THEN '033'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '701' THEN '011'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '011' THEN '011'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '057' THEN '057'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '058' THEN '058'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '076' THEN '076'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '056' THEN '050'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '039' THEN '221'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '221' THEN '221'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '014' THEN '076'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '035' THEN '035'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '082' THEN '082'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '214' THEN '214'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '063' THEN '063'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '032' THEN '032'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '040' THEN '232'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '070' THEN '070'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '069' THEN '044'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '085' THEN '214'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '044' THEN '044'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '232' THEN '232'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '050' AND acquiring_inst_id_code <> '903709' THEN '050'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '050' AND acquiring_inst_id_code = '903709' THEN '068'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '215' THEN '215'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '084' THEN '030'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '023' THEN '023'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  'HSL' THEN '214'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '068' THEN '068'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  'ACC' THEN '050'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '301' THEN '301'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '030' THEN '030'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  'RSL' THEN '082'
	WHEN  SUBSTRING(t.terminal_id,2,3)  =  '100' THEN '100'
	ELSE 'UNKNOWN TERMINAL'
END,
acquirer = aid.[BANK_INSTITUTION_NAME],
t.totals_group,
terminal_code  = CASE WHEN ( own.terminal_code  is NULL) OR  LEN(LTRIM(RTRIM(own.terminal_code ))) =0 THEN 'ISW_PTO' 
      ELSE own.terminal_code   END,
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
when   (             tran_type = '92'
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
)
SELECT *, iss.account_no issuer_account_no, acq.account_no acquirer_account_no FROM ceaser_table c  
JOIN tbl_participant_account iss (nolock) ON
c.issuer  = iss.participant AND ISS.role ='ISSUER'
JOIN tbl_participant_account acq (nolock) ON 
c.acquirer = acq.participant AND acq.role  ='ACQUIRER'



OPTION (RECOMPILE, MAXDOP 8)

END
