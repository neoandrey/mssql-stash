

select top 10 RecID ='0000999999',PTC_card_acceptor_id_code as PayeeID,account_nr as PayeeAccount, 

case 
when bank_code ='ABP' then '044'
when bank_code ='AMJU' then '070'
when bank_code ='CITI' then '023'
when bank_code ='DBL' then '063'
when bank_code ='EBN' then '050'
when bank_code ='FBN' then '011'
when bank_code ='FBP' then '070'
when bank_code ='FCMB' then '214'
when bank_code ='GTB' then '058'
when bank_code ='HBC' then '030'
when bank_code ='IBTC' then '221'
when bank_code ='JBP' then '011'
when bank_code ='KSB' then '082'
when bank_code ='PRO' then '101'
when bank_code ='SBP' then '232'
when bank_code ='SCB' then '068'
when bank_code ='SKYE' then '076'
when bank_code ='SUN' then '050'
when bank_code ='UBA' then '033'
when bank_code ='UBN' then '032'
when bank_code ='UBP' then '215'
when bank_code ='WEMA' then '035'
when bank_code ='ZIB' then '057'
else '150000'
end as
PayeeBankCode,

sum(p.merchant_receivable) as Amount, Account_Name as PayeeName, PayerName ='INTERSWITCHNG',

'Goodsandservices' + CONVERT(VARCHAR(10), DATEADD(DAY, -1, GETDATE()), 111) as Narration

into #NIBSS_POS_Regular

FROM [dbo].[report_results_rj] r (NOLOCK)
INNER JOIN [postilion_settlement].[dbo].[pos_extended_settlement] p (NOLOCK)
ON r.post_tran_id = p.post_tran_id
  where ((Debit_Account_Type like '%AMOUNT%RECEIVABLE%' and trxn_fee ='0') or  (Credit_Account_Type like '%AMOUNT%RECEIVABLE%' and trxn_fee ='0'))
 and left(PTC_terminal_id,1) ='2'
 and trxn_category <>'POS TRANSFERS'
and PTC_totals_group not in ('VisaGroup','MCGroup') 
group by PTC_card_acceptor_id_code,account_nr,Account_Name,
case 
when bank_code ='ABP' then '044'
when bank_code ='AMJU' then '070'
when bank_code ='CITI' then '023'
when bank_code ='DBL' then '063'
when bank_code ='EBN' then '050'
when bank_code ='FBN' then '011'
when bank_code ='FBP' then '070'
when bank_code ='FCMB' then '214'
when bank_code ='GTB' then '058'
when bank_code ='HBC' then '030'
when bank_code ='IBTC' then '221'
when bank_code ='JBP' then '011'
when bank_code ='KSB' then '082'
when bank_code ='PRO' then '101'
when bank_code ='SBP' then '232'
when bank_code ='SCB' then '068'
when bank_code ='SKYE' then '076'
when bank_code ='SUN' then '050'
when bank_code ='UBA' then '033'
when bank_code ='UBN' then '032'
when bank_code ='UBP' then '215'
when bank_code ='WEMA' then '035'
when bank_code ='ZIB' then '057'
else '150000'
end 


Union 



select top 10 RecID ='0000999999',PTC_card_acceptor_id_code as PayeeID,account_nr as PayeeAccount, 

case 
when bank_code ='ABP' then '044'
when bank_code ='AMJU' then '070'
when bank_code ='CITI' then '023'
when bank_code ='DBL' then '063'
when bank_code ='EBN' then '050'
when bank_code ='FBN' then '011'
when bank_code ='FBP' then '070'
when bank_code ='FCMB' then '214'
when bank_code ='GTB' then '058'
when bank_code ='HBC' then '030'
when bank_code ='IBTC' then '221'
when bank_code ='JBP' then '011'
when bank_code ='KSB' then '082'
when bank_code ='PRO' then '101'
when bank_code ='SBP' then '232'
when bank_code ='SCB' then '068'
when bank_code ='SKYE' then '076'
when bank_code ='SUN' then '050'
when bank_code ='UBA' then '033'
when bank_code ='UBN' then '032'
when bank_code ='UBP' then '215'
when bank_code ='WEMA' then '035'
when bank_code ='ZIB' then '057'
else '150000'
end as
PayeeBankCode,

sum(-(PT_settle_amount_impact/100)) as Amount, Account_Name as PayeeName, PayerName ='INTERSWITCHNG',

'Goodsandservices' + CONVERT(VARCHAR(10), DATEADD(DAY, -1, GETDATE()), 111) as Narration

---into #NIBSS_POS_Cashwithdrawal

FROM [dbo].[report_results_rj] r (NOLOCK)
where ((Debit_Account_Type like '%AMOUNT%RECEIVABLE%' and trxn_fee ='0') or  (Credit_Account_Type like '%AMOUNT%RECEIVABLE%' and trxn_fee ='0'))
 and left(PTC_terminal_id,1) ='2'
 and trxn_category <>'POS TRANSFERS'
and PT_tran_type ='01'
	  and left(PTC_terminal_id,1) ='2'
      and PTC_totals_group not in ('VisaGroup','MCGroup')
group by PTC_card_acceptor_id_code,account_nr,Account_Name,
case 
when bank_code ='ABP' then '044'
when bank_code ='AMJU' then '070'
when bank_code ='CITI' then '023'
when bank_code ='DBL' then '063'
when bank_code ='EBN' then '050'
when bank_code ='FBN' then '011'
when bank_code ='FBP' then '070'
when bank_code ='FCMB' then '214'
when bank_code ='GTB' then '058'
when bank_code ='HBC' then '030'
when bank_code ='IBTC' then '221'
when bank_code ='JBP' then '011'
when bank_code ='KSB' then '082'
when bank_code ='PRO' then '101'
when bank_code ='SBP' then '232'
when bank_code ='SCB' then '068'
when bank_code ='SKYE' then '076'
when bank_code ='SUN' then '050'
when bank_code ='UBA' then '033'
when bank_code ='UBN' then '032'
when bank_code ='UBP' then '215'
when bank_code ='WEMA' then '035'
when bank_code ='ZIB' then '057'
else '150000'
end 


DECLARE  @acquiring_inst  VARCHAR(255)=''
DECLARE  @batch_number  VARCHAR(255)=''
DECLARE  @batch_total  VARCHAR(255)=''
DECLARE  @pos_tran_date  VARCHAR(255)=''
DECLARE  @num_of_records  VARCHAR(255)=''

SELECT 
'<Debit>'
+char(10)+char(13)+' <Header>'
 +char(10)+char(13)+'<AcquiringInstitutionID>'+@acquiring_inst+'</AcquiringInstitutionID>'
+char(10)+char(13)+'<BatchNumber>'+@batch_number+'</BatchNumber>'
 +char(10)+char(13)+'<BatchTotal>'+@batch_total+'</BatchTotal>'
+char(10)+char(13)+'<POSTransactionDate>'+@pos_tran_date+'</POSTransactionDate>'
+char(10)+char(13)+'<NumberOfRecords>'+@num_of_records+'</NumberOfRecords>'
 +char(10)+char(13)+'</Header>'
+char(10)+char(13)+'<Record>'+char(10)+char(13)+'<RecID>'+RecID+'</RecID>'
+char(10)+char(13)+'<PayeeID>'+PayeeID+'</PayeeID>'
+char(10)+char(13)+'<PayeeAccount>'+PayeeAccount+'</PayeeAccount>'
+char(10)+char(13)+'<PayerBankCode>'+PayerBankCode+'</PayerBankCode>'
+char(10)+char(13)+'<Amount>'+Amount+'</Amount>'
+char(10)+char(13)+'<PayeeName>'+PayeeName+'</PayeeName>'
+char(10)+char(13)+'<PayeeName>'+PayerName+'</PayerName>'
+char(10)+char(13)+'<Narration>'+Narration+'</Narration>'
+char(10)+char(13)+'</Record>'
+char(10)+char(13)+'</Debit>'

FROM #NIBSS_POS_Regular WITH (NOLOCK)




Credit Format

<?xml version="1.0" encoding="utf-8"?>
<Credit>
  <Header>
    <AcquiringInstitutionID>628051</AcquiringInstitutionID>
    <BatchNumber>140320190750</BatchNumber>
    <BatchTotal>2712295656.44</BatchTotal>
    <POSTransactionDate>14032019</POSTransactionDate>
    <NumberOfRecords>32175</NumberOfRecords>
  </Header>
  <Record>
    <RecID>000000000001</RecID>
    <PayeeID>20100014MC00468</PayeeID>
    <PayeeAccount>2016500369</PayeeAccount>
    <PayeeBankCode>011</PayeeBankCode>
    <Amount>31106.25</Amount>
    <PayeeName>HOTEL SOLITUDE </PayeeName>
    <PayerName>INTERSWITCHNG</PayerName>
    <Narration>Goodsandservices14032019</Narration>
  </Record>
  <Record>
    <RecID>000000000002</RecID>
    <PayeeID>2011AB010119490</PayeeID>
    <PayeeAccount>2032437276</PayeeAccount>
    <PayeeBankCode>011</PayeeBankCode>
    <Amount>23700.00</Amount>
    <PayeeName>GRAND LOTTE WORLD HO</PayeeName>
   <PayerName>INTERSWITCHNG</PayerName>
    <Narration>Goodsandservices14032019</Narration>
  </Record>
</Credit>


Debit Format

<?xml version="1.0" encoding="utf-8"?>
<Debit>
  <Header>
    <AcquiringInstitutionID>628051</AcquiringInstitutionID>
    <BatchNumber>140320190750</BatchNumber>
    <BatchTotal>2712295656.44</BatchTotal>
    <POSTransactionDate>14032019</POSTransactionDate>
    <NumberOfRecords>35</NumberOfRecords>
  </Header>
  <Record>
    <RecID>000000000001</RecID>
    <MerchantID>628051000000000</MerchantID>
    <PayerAccount>2025204368</PayerAccount>
    <PayerBankCode>011</PayerBankCode>
    <Amount>339257757.67</Amount>
    <MerchantName>INTERSWITCHNG</MerchantName>
    <PayerName>First Bank of Nigeri</PayerName>
    <Narration>Goodsandservices14032019</Narration>
  </Record>
  <Record>
    <RecID>000000000002</RecID>
    <MerchantID>628051000000000</MerchantID>
    <PayerAccount>1005624787</PayerAccount>
    <PayerBankCode>082</PayerBankCode>
    <Amount>25431077.59</Amount>
    <MerchantName>INTERSWITCHNG</MerchantName>
    <PayerName>Keystone Bank</PayerName>
    <Narration>Goodsandservices14032019</Narration>
  </Record>
</Debit>



RecID	    PayeeID     	PayeeAccount	PayeeBankCode	Amount			PayeeName								      PayerName	Narration
0000999999	07610000000M213	1770064505		076				987.5			LATTER RAIN DOMINION PARTNERS				INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610000000M214	1770064505		076				28837.5			LATTER RAIN DOMINION PARTNERS				INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610000000M216	1770072357		076				426678			LATTER RAIN ASS(TITHE AND OFFERING			INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610000000N300	1770467962		076				10270			LUGBE REST HOUSE NIG						INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610000000N901	1771311385		076				10476.78	    GLORIOUS ASSEMBLY MINISTRIES INC			INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610000000O030	1770671884		076				397		        VINE BRANCH MISSION MATERNITY				INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610100000C885	1771392436		076				14172.9	    	SAVE MART GLOBAL ST3   ETI OSA      LANG	INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610200000AM66	1770039420		076				2765	        BALCOM ROYAL SUITES							INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610300000AX61	1770072357		076				193203.75	    LATTER RAIN ASS TITHE AND OFFERING			INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	07610600000BB60	4010018908		076				1588	        DEMANTA NIGERIA LIMITED-EVENTS HALL A C		INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	203315000007583	2091441678		033				5000			SABI IBRAHIM  AZEEZ AYOMIKUN				INTERSWITCHNG	Goodsandservices2019/03/17
0000999999	203317000008447	1020917798		033				900				CUCSICL-HEAD OFFICE							INTERSWITCHNG	Goodsandservices2019/03/17