SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

























ALTER                    PROCEDURE [dbo].[psp_settlement_summary_breakdown_reward_test](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL
)
AS
BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = ISNULL(@start_date,dbo.DateOnly(getdate()-1))
SET @to_date = ISNULL(@end_date,dbo.DateOnly(getdate()-1))


print(cast(getdate() as varchar(255)) + ': inserting distinct date into settlement_summary_session')

INSERT 
                               INTO settlement_summary_session
       SELECT distinct (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)) + '_Reward'
       FROM   tbl_xls_settlement AS Y (NOLOCK)

        where 
             (Y.trans_date >= @from_date AND Y.trans_date < (@to_date+1))
             

	Group by Y.trans_date

IF(@@ERROR <>0)
RETURN

print(cast(getdate() as varchar(255)) + ': inserted distinct date')





SELECT pt.post_tran_cust_id ,abort_rsp_code ,acquirer_network_id ,payee ,pos_condition_code ,pos_entry_mode ,post_tran_id ,prev_post_tran_id ,prev_tran_approved ,pt_pos_card_input_mode ,pt_pos_cardholder_auth_method ,pt_pos_operating_environment ,pt_pos_pin_capture_ability ,pt_pos_terminal_operator ,realtime_business_date ,receiving_inst_id_code ,recon_business_date ,retention_data ,retrieval_reference_nr ,routing_type ,rsp_code_req ,rsp_code_rsp ,settle_amount_impact ,settle_amount_req ,settle_amount_rsp ,settle_cash_req ,settle_cash_rsp ,settle_currency_code ,settle_entity_id ,settle_proc_fee_req ,settle_proc_fee_rsp ,settle_tran_fee_req ,settle_tran_fee_rsp ,sink_node_name ,sponsor_bank ,structured_data_req ,structured_data_rsp ,system_trace_audit_nr ,to_account_id ,to_account_type ,to_account_type_qualifier ,tran_amount_req ,tran_amount_rsp ,tran_cash_req ,tran_cash_rsp ,tran_completed ,tran_currency_code ,tran_nr ,tran_postilion_originated ,tran_proc_fee_currency_code ,tran_proc_fee_req ,tran_proc_fee_rsp ,tran_reversed ,tran_tran_fee_currency_code ,tran_tran_fee_req ,tran_tran_fee_rsp ,tran_type ,ucaf_data ,address_verification_data ,address_verification_result ,card_acceptor_id_code ,card_acceptor_name_loc ,card_product ,card_seq_nr ,check_data ,draft_capture ,expiry_date ,mapped_card_acceptor_id_code ,merchant_type ,pan ,pan_encrypted ,pan_reference ,pan_search ,pos_card_capture_ability ,pos_card_data_input_ability ,pos_card_data_input_mode ,pos_card_data_output_ability ,pos_card_present ,pos_cardholder_auth_ability ,pos_cardholder_auth_entity ,pos_cardholder_auth_method ,pos_cardholder_present ,pos_operating_environment ,pos_pin_capture_ability ,pos_terminal_operator ,pos_terminal_output_ability ,pos_terminal_type ,service_restriction_code ,source_node_name ,terminal_id ,terminal_owner ,totals_group ,acquiring_inst_id_code ,additional_rsp_data ,auth_id_rsp ,auth_reason ,auth_type ,bank_details ,batch_nr ,card_verification_result ,datetime_req ,datetime_rsp ,datetime_tran_gmt ,datetime_tran_local ,extended_tran_type ,from_account_id ,from_account_type ,from_account_type_qualifier ,icc_data_req ,icc_data_rsp ,issuer_network_id ,message_reason_code ,message_type ,next_post_tran_id ,online_system_id ,participant_id
INTO ##TEMP_TRANSACTIONS_REWARD FROM post_tran PT (NOLOCK) JOIN post_tran_cust PTC (NOLOCK) ON
PT.post_tran_cust_id = PTC.post_tran_cust_id
WHERE PT.tran_postilion_originated = 0
      AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc','SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
      AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
      AND PT.tran_type = '00'
      AND PT.rsp_code_rsp in ('00','11','09')
      
      AND (pt.recon_business_date >= @from_date AND pt.recon_business_date < (@to_date+1))
      AND PT.tran_completed = 1
      and not  (ptc.merchant_type in ('5371') and left(ptc.terminal_id,1) in ('2','5','6'))


print(cast(getdate() as varchar(255)) + ': create temp_trxn')


CREATE TABLE #report_result
	(
		bank_code				VARCHAR (10),
		trxn_category				VARCHAR (50),  
		Debit_Account_type		        VARCHAR (50), 
		Credit_Account_type 		        VARCHAR (50),
		trxn_amount				float, 
		trxn_fee 				float, 
                trxn_date                               VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result')
INSERT INTO #report_result
   --(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date)




SELECT  
	bank_code = CASE  WHEN (substring(t.sink_node_name,4,3) = 'UBA') THEN 'UBA'
	                  WHEN (substring(t.sink_node_name,4,3) = 'FBN') THEN 'FBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ZIB') THEN 'ZIB' 
                          WHEN (substring(t.sink_node_name,4,3) = 'SPR') THEN 'ENT'
                          WHEN (substring(t.sink_node_name,4,3) = 'GTB') THEN 'GTB'
                          WHEN (substring(t.sink_node_name,4,3) = 'PRU') THEN 'SKYE'
                          WHEN (substring(t.sink_node_name,4,3) = 'OBI') THEN 'EBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'WEM') THEN 'WEMA'
                          WHEN (substring(t.sink_node_name,4,3) = 'AFR') THEN 'MSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'CHB') THEN 'IBTC'
                          WHEN (substring(t.sink_node_name,4,3) = 'PLA') THEN 'KSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBP') THEN 'UBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'DBL') THEN 'DBL'
                          WHEN (substring(t.sink_node_name,4,3) = 'FCM') THEN 'FCMB'
                          WHEN (substring(t.sink_node_name,4,3) = 'IBP') THEN 'IBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBN') THEN 'UBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ETB') THEN 'ETB'
                          WHEN (substring(t.sink_node_name,4,3) = 'FBP') THEN 'FBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'SBP') THEN 'SBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABP') THEN 'ABP'
                          WHEN (substring(t.sink_node_name,4,3) = 'EBN') THEN 'EBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'CIT') THEN 'CITI'


                          WHEN (substring(t.sink_node_name,4,3) = 'FIN') THEN 'FIN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ASO') THEN 'ASO'
                          WHEN (substring(t.sink_node_name,4,3) = 'OLI') THEN 'OLI'
                          WHEN (substring(t.sink_node_name,4,3) = 'HSL') THEN 'HSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABS') THEN 'ABS'

                          WHEN (substring(t.sink_node_name,4,3) = 'PAY') THEN 'PAY'
                          WHEN (substring(t.sink_node_name,4,3) = 'SAT') THEN 'SAT'
                          WHEN (substring(t.sink_node_name,4,3) = '3LC') THEN '3LCM'
                          WHEN (substring(t.sink_node_name,4,3) = 'SCB') THEN 'SCB'
                          WHEN (substring(t.sink_node_name,4,3) = 'JBP') THEN 'JBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'RSL') THEN 'RSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'PSH') THEN 'PSH'
                          WHEN (substring(t.sink_node_name,4,3) = 'ACC') THEN 'ACCI'
                          WHEN (substring(t.sink_node_name,4,3) = 'EKO') THEN 'EKON'
                          WHEN (substring(t.sink_node_name,4,3) = 'ATM') THEN 'ATMC'
						  WHEN (substring(t.sink_node_name,4,3) = 'HBC') THEN 'HBC'
						  WHEN (substring(t.sink_node_name,4,3) = 'UNI') THEN 'UNI'
						  WHEN (substring(t.sink_node_name,4,3) = 'UnC') THEN 'UnC'
						  WHEN (substring(t.sink_node_name,4,3) = 'HAG') THEN 'HAG'
						  WHEN (substring(t.sink_node_name,4,3) = 'EXP') THEN 'DBL'
						  WHEN (substring(t.sink_node_name,4,3) = 'FGM') THEN 'FGM'
                                                  WHEN (substring(t.sink_node_name,4,3) = 'CEL') THEN 'CEL'

			 ELSE 'UNK'			
END,
	trxn_category= Case when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME'
                            --when (substring(y.extended_trans_type,1,1) = '7') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT'
                            when (substring(y.extended_trans_type,1,1) = '9') then 'REWARD MONEY (SPEND) POS FEE SETTLEMENT'
                           else substring(y.extended_trans_type,1,1)
                            end,

        Debit_account_type=    'ISSUER FEE PAYABLE(Debit_Nr)',
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)' ,
                          

        amt= 0,
	fee= isnull(CASE WHEN  (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact))))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100)
                  END,0),
       (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (NOLOCK)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
     -- or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (SUBSTRING(t.Terminal_id,1,1)= '1' or SUBSTRING(t.Terminal_id,1,1)= '0'))
     -- or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (SUBSTRING(t.Terminal_id,1,1)= '1' or SUBSTRING(t.Terminal_id,1,1)= '0')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    

     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'



     and t.merchant_type not in ('5371')	
   

     and substring(y.extended_trans_type,1,1) in ('9','8') 

GROUP BY 
 substring(t.sink_node_name,4,3),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
--t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
y.extended_trans_type,
t.retrieval_reference_nr,
t.settle_amount_impact,
c.amount_cap


CREATE TABLE #report_result1
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 1')
INSERT INTO #report_result1

SELECT  
	bank_code = CASE  WHEN (substring(t.sink_node_name,4,3) = 'UBA') THEN 'UBA'
	                  WHEN (substring(t.sink_node_name,4,3) = 'FBN') THEN 'FBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ZIB') THEN 'ZIB' 
                          WHEN (substring(t.sink_node_name,4,3) = 'SPR') THEN 'ENT'
                          WHEN (substring(t.sink_node_name,4,3) = 'GTB') THEN 'GTB'
                          WHEN (substring(t.sink_node_name,4,3) = 'PRU') THEN 'SKYE'
                          WHEN (substring(t.sink_node_name,4,3) = 'OBI') THEN 'OBI'
                          WHEN (substring(t.sink_node_name,4,3) = 'WEM') THEN 'WEMA'
                          WHEN (substring(t.sink_node_name,4,3) = 'AFR') THEN 'MSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'CHB') THEN 'IBTC'
                          WHEN (substring(t.sink_node_name,4,3) = 'PLA') THEN 'KSB'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBP') THEN 'UBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'DBL') THEN 'DBL'
                          WHEN (substring(t.sink_node_name,4,3) = 'FCM') THEN 'FCMB'
                          WHEN (substring(t.sink_node_name,4,3) = 'IBP') THEN 'IBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'UBN') THEN 'UBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ETB') THEN 'ETB'
                          WHEN (substring(t.sink_node_name,4,3) = 'FBP') THEN 'FBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'SBP') THEN 'SBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABP') THEN 'ABP'
                          WHEN (substring(t.sink_node_name,4,3) = 'EBN') THEN 'EBN'
                          WHEN (substring(t.sink_node_name,4,3) = 'CIT') THEN 'CITI'

                          WHEN (substring(t.sink_node_name,4,3) = 'FIN') THEN 'FIN'
                          WHEN (substring(t.sink_node_name,4,3) = 'ASO') THEN 'ASO'
                          WHEN (substring(t.sink_node_name,4,3) = 'OLI') THEN 'OLI'
                          WHEN (substring(t.sink_node_name,4,3) = 'HSL') THEN 'HSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'ABS') THEN 'ABS'

                          WHEN (substring(t.sink_node_name,4,3) = 'PAY') THEN 'PAY'
                          WHEN (substring(t.sink_node_name,4,3) = 'SAT') THEN 'SAT'
                          WHEN (substring(t.sink_node_name,4,3) = '3LC') THEN '3LCM'
                          WHEN (substring(t.sink_node_name,4,3) = 'SCB') THEN 'SCB'
                          WHEN (substring(t.sink_node_name,4,3) = 'JBP') THEN 'JBP'
                          WHEN (substring(t.sink_node_name,4,3) = 'RSL') THEN 'RSL'
                          WHEN (substring(t.sink_node_name,4,3) = 'PSH') THEN 'PSH'
                          WHEN (substring(t.sink_node_name,4,3) = 'ACC') THEN 'ACCI'
                          WHEN (substring(t.sink_node_name,4,3) = 'EKO') THEN 'EKON'

                          WHEN (substring(t.sink_node_name,4,3) = 'ATM') THEN 'ATMC'
                          WHEN (substring(t.sink_node_name,4,3) = 'HBC') THEN 'HBC'
                          WHEN (substring(t.sink_node_name,4,3) = 'UNI') THEN 'UNI'
                          WHEN (substring(t.sink_node_name,4,3) = 'UnC') THEN 'UnC'
			  WHEN (substring(t.sink_node_name,4,3) = 'HAG') THEN 'HAG'
			  WHEN (substring(t.sink_node_name,4,3) = 'EXP') THEN 'DBL'
			  WHEN (substring(t.sink_node_name,4,3) = 'FGM') THEN 'FGM'
                          WHEN (substring(t.sink_node_name,4,3) = 'CEL') THEN 'CEL'


			 ELSE 'UNK'			
END,
	trxn_category= Case when (substring(o.r_code,1,1) = '8') then 'SAVERSCARD REWARD SCHEME'
                            else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT'
                            end,

        Debit_account_type=    'ISSUER FEE PAYABLE(Debit_Nr)',
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)' ,
                          

        amt= 0,
	fee= isnull(CASE WHEN  (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact))))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap)
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100)
                  END,0),



       (substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
                              
       left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)                           
   
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	
   

    and (substring(o.r_code,1,1) in ('9','8') and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY 
 substring(t.sink_node_name,4,3),
o.r_code,


--t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11)),
t.retrieval_reference_nr,
t.settle_amount_impact,
c.amount_cap


CREATE TABLE #report_result2
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 2')
INSERT INTO #report_result2

SELECT  
	bank_code = CASE  WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FBN'
			  ELSE 'FBN'
                          END,			

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    'ISSUER FEE PAYABLE(Debit_Nr)',
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)',
                          



        amt= 0,

	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((c.merchant_disc* y.rdm_amt*100))

	          WHEN  (abs(t.settle_amount_impact/100) >= c.amount_cap)
                  THEN sum(c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
  
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     

GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

--dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap),
(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type,
t.retrieval_reference_nr,
t.settle_amount_impact,
c.amount_cap


CREATE TABLE #report_result3
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 3')
INSERT INTO #report_result3

SELECT  
	bank_code = 'FBN',			

	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',
                       

        Debit_account_type=   'ISSUER AMOUNT PAYABLE(Debit_Nr)',
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)' ,
                          

        amt= sum(y.rdm_amt*100),
	fee= 0,

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0

      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
     -- or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     --and t.merchant_type not in ('5371')	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     

GROUP BY 
 --t.sink_node_name,
-- y.trans_date,


(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type


CREATE TABLE #report_result4
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 4')
INSERT INTO #report_result4

SELECT  
	bank_code = CASE  WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FBN'
			  ELSE 'ISW'
                          END,			

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'

                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISSUER FEE RECEIVABLE(Credit_Nr)' ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.3*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.3*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount

   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'



     and t.merchant_type not in ('5371')	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result5
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 5')
INSERT INTO #report_result5

SELECT  
	bank_code =  'ISW',		

	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISSUER and SWT FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.625*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.625*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
  -- AND (-1 * t.settle_amount_impact)/100 = y.amount

   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'



     and t.merchant_type not in ('5371')	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result6
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 6')
INSERT INTO #report_result6

SELECT  
	bank_code = 'ISW',			
	

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.05*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.05*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 

   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0  and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0  and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


GROUP BY 
-- t.sink_node_name,
-- y.trans_date,

t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,


(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result7
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 7')
INSERT INTO #report_result7

SELECT  
	bank_code = 'ISW',

        

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME PTSO'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT PTSO'
                       END,


        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.25*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.25*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'

      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))

      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	

   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


GROUP BY 
-- t.sink_node_name,
-- y.trans_date,

t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result8
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 8')
INSERT INTO #report_result8

SELECT  
	bank_code = 'ISW',		

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME PTSP'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT PTSP'
                       END,

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW FEE RECEIVABLE(Credit_Nr)',
                          


        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.25*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.25*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
     -- or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	

   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


GROUP BY 
-- t.sink_node_name,
-- y.trans_date,

t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type


CREATE TABLE #report_result10
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 10')
INSERT INTO #report_result10

SELECT  
	bank_code = 'NCS',

	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,


        Debit_account_type=   'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'NCS FEE RECEIVABLE(Credit_Nr)',
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.075*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.075*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
   LEFT OUTER JOIN tbl_xls_settlement y (nolock)
ON 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   --AND (-1 * t.settle_amount_impact)/100 = y.amount
   AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON substring(y.extended_trans_type,1,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0 and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


GROUP BY 
 --t.sink_node_name,
-- y.trans_date,

t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), y.extended_trans_type

CREATE TABLE #report_result11
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 11')
INSERT INTO #report_result11

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN (substring(y.extended_trans_type,1,1) = '9' 
                   and substring(y.extended_trans_type,1,4) not in ('9080')
                   and substring(y.extended_trans_type,4,1) <> '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.025 * (-1 * t.settle_amount_impact)))

                   WHEN (substring(y.extended_trans_type,1,1) = '9'
                    and substring(y.extended_trans_type,1,4) not in ('9080') 
                   and substring(y.extended_trans_type,4,1) = '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.03 * (-1 * t.settle_amount_impact)))   

                   WHEN (substring(y.extended_trans_type,1,4) in ('9080'))
 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact)))             
             		
END,0),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)

     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(y.extended_trans_type,1,4) = '9'

GROUP BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
 y.extended_trans_type



CREATE TABLE #report_result12
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 12')
INSERT INTO #report_result12

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN (substring(o.r_code,1,1) = '9' 
                   and substring(o.r_code,1,4) not in ('9080')
                   and substring(o.r_code,4,1) <> '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.025 * (-1 * t.settle_amount_impact)))

                   WHEN (substring(o.r_code,1,1) = '9'
                    and substring(o.r_code,1,4) not in ('9080') 

                   and substring(o.r_code,4,1) = '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.03 * (-1 * t.settle_amount_impact)))   

                   WHEN (substring(o.r_code,1,4) in ('9080'))
 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact)))             
             		
END,0),





	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)                          
	left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))

     -- or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and (substring(o.r_code,1,1) = '9'and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY 
-- y.trans_date,
o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))


CREATE TABLE #report_result13
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 13')
INSERT INTO #report_result13



SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN t.extended_tran_type not in ('7080','7090','7100')
                  
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact)))

                    WHEN t.extended_tran_type in ('7080')
                  
                   THEN sum((0.01 * (-1 * t.settle_amount_impact)))

                   WHEN t.extended_tran_type in ('7090','7100')
                  
                   THEN sum((0.02 * (-1 * t.settle_amount_impact))) END,0),


	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             		

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    AND (-1 * t.settle_amount_impact/100) = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               

                                 

	left JOIN Reward_Category r (NOLOCK)
        ON (t.extended_tran_type = r.reward_code )

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(t.extended_tran_type,1,1) = '7'


GROUP BY 
-- y.trans_date,
 t.extended_tran_type,

(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             		



CREATE TABLE #report_result14
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 14')
INSERT INTO #report_result14

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN substring(o.r_code,1,4) not in ('7080','7090','7100')
                  
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * t.settle_amount_impact)))

                    WHEN substring(o.r_code,1,4) in ('7080')
                  
                   THEN sum((0.01 * (-1 * t.settle_amount_impact)))

                   WHEN substring(o.r_code,1,4) in ('7090','7100')
                  
                   THEN sum((0.02 * (-1 * t.settle_amount_impact)))
             		
END,0),

(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 ##TEMP_TRANSACTIONS_REWARD T(NOLOCK)                          
	left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				

										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and (substring(o.r_code,1,1) = '7' and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))


GROUP BY 
-- y.trans_date,
o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))




CREATE TABLE #report_result15
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 15')
INSERT INTO #report_result15




SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'

                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'


                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'
               

			 ELSE 'UNK'			
END,
	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee=  isnull(Case when(substring(y.extended_trans_type,1,4) in ('9080')) then 
             SUM(0.15*(0.0075*(-1 * (t.settle_amount_impact))))
             else 
             SUM(0.15*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),
        (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(y.extended_trans_type,1,1) = '9'

GROUP BY 
 t.acquiring_inst_id_code,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

CREATE TABLE #report_result16
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 16')
INSERT INTO #report_result16

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
			  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'
			
               

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee=  isnull(Case when(substring(o.r_code,1,4) in ('9080')) then 
             SUM(0.15*(0.0075*(-1 * (t.settle_amount_impact))))
             else 
             SUM(0.15*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and (substring(o.r_code,1,1) = '9' and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY 
 t.acquiring_inst_id_code,o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
 --y.trans_date

--

CREATE TABLE #report_result17
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 17')
INSERT INTO #report_result17



SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
               		  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Merchant Additional Reward Fee Payable(Debit_Nr)',

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
          
                          

        amt= 0,
	fee= --CASE WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 1) 
                  --THEN 
                   isnull(sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))),0)

	         -- WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 2) 
                 --THEN -sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap)
                  --END
                     ,
         

	business_date = (substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
             
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    AND (-1 * t.settle_amount_impact/100) = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               
                                  
	left JOIN Reward_Category r (NOLOCK)
        ON (t.extended_tran_type = r.reward_code)
left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )

      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and left(t.extended_tran_type,1) = '7'
    

GROUP BY 
 t.acquiring_inst_id_code,t.extended_tran_type,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
--dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap )
 --y.trans_date

CREATE TABLE #report_result18
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)

         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 18')
INSERT INTO #report_result18

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
			  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'
               

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Merchant Additional Reward Fee Payable(Debit_Nr)',  

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
        
                          

        amt= 0,
	fee= --CASE WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 1) 
                  --THEN 
                   isnull(sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))),0)

	          --WHEN (dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) = 2) 
                  --THEN -sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap) END
                  ,
         

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
                  
             
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)
left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0

      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'


     and t.merchant_type not in ('5371')
	
     and (substring(o.r_code,1,1) = '7' and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))


GROUP BY 
 t.acquiring_inst_id_code,o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
--dbo.fn_rpt_Above_limit (abs(t.settle_amount_impact),c.amount_cap ) 
 --y.trans_date
--

CREATE TABLE #report_result19
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 19')
INSERT INTO #report_result19

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= CASE WHEN (substring(y.extended_trans_type,1,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.075*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.075*c.fee_cap*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
 left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0  and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

GROUP BY 
 t.acquiring_inst_id_code,
t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), substring(y.extended_trans_type,1,4),y.extended_trans_type

CREATE TABLE #report_result20
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 20')
INSERT INTO #report_result20

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'

                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category='REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer and ISO Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((0.375*c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(0.375*c.fee_cap*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount

    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
 left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0  and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

GROUP BY 
 t.acquiring_inst_id_code,
t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), substring(y.extended_trans_type,1,4),y.extended_trans_type

CREATE TABLE #report_result21
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 21')
INSERT INTO #report_result21

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',
                       

        Debit_account_type=  'Acquirer Fee Payable(Debit_Nr)', 
                          
        Credit_account_type= 'FEE POOL(Credit_Nr)', 
                          

        amt= 0,
	fee= isnull(CASE WHEN (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0)  
                  THEN sum((c.merchant_disc* y.rdm_amt*100))

	          WHEN (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN sum(c.fee_cap*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
 left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0  and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 ))
     -- or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

GROUP BY 
 t.acquiring_inst_id_code,
t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), substring(y.extended_trans_type,1,4),y.extended_trans_type

CREATE TABLE #report_result22
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 22')
INSERT INTO #report_result22

SELECT		
	bank_code = CASE  WHEN  t.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  t.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  t.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  t.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  t.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  t.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  t.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  t.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  t.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  t.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  t.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  t.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  t.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  t.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  t.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  t.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  t.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  t.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  t.acquiring_inst_id_code = '636092' THEN 'SBP'


                          WHEN  t.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  t.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  t.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  t.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  t.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  t.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  t.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  t.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  t.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  t.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type= 'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Acquirer Amount Receivable(Credit_Nr)',  
                          

        amt= sum(y.rdm_amt*100),
	fee=  0,
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
   -- AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
 left JOIN tbl_merchant_category_web c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (y.rdm_amt<> 0  and t.message_type   in ('0200','0220')
      or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (y.rdm_amt<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (y.rdm_amt<> 0  and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

GROUP BY 
 t.acquiring_inst_id_code,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), substring(y.extended_trans_type,1,4),y.extended_trans_type

CREATE TABLE #report_result23
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 23')
INSERT INTO #report_result23



SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Touchpoint Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee=  isnull(Case when(substring(y.extended_trans_type,1,4) in ('9080')) then 

             SUM(0.10*(0.0075*(-1 * (t.settle_amount_impact))))

             else 
             SUM(0.10*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),

        (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)

on 
   (t.terminal_id= y.terminal_id 

   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(y.extended_trans_type,1,1)= '9'

GROUP BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),substring(y.extended_trans_type,1,4),y.extended_trans_type


CREATE TABLE #report_result24
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 24')
INSERT INTO #report_result24

SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Touchpoint Fee Receivable(Credit_Nr)',  
                          

        amt= 0,
	fee=  isnull(Case when(substring(o.r_code,1,4) in ('9080')) then 
             SUM(0.10*(0.0075*(-1 * (t.settle_amount_impact))))
             else 
             SUM(0.10*(0.0125*(-1 * (t.settle_amount_impact)))) end,0),

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code) 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))

      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and (substring(o.r_code,1,1) = '9'  and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))

GROUP BY o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
-- y.trans_date

--

CREATE TABLE #report_result25
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 25')
INSERT INTO #report_result25


SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Verve additional Fee Payable(Debit_Nr)',

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
          
                          

        amt= 0,
	fee= isnull(CASE  
                    WHEN t.extended_tran_type in ('7090')
                  
                   THEN sum((0.02 * (-1 * t.settle_amount_impact)))

                   WHEN t.extended_tran_type in ('7080','7100')
                  
                   THEN sum((0.01 * (-1 * t.settle_amount_impact))) end,0),
	business_date= substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               
                                 
	left JOIN Reward_Category r (NOLOCK)
        ON (t.extended_tran_type = r.reward_code )

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
     --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(t.extended_tran_type,1,1) = '7'


GROUP BY t.extended_tran_type,
substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11)	
-- y.trans_date


CREATE TABLE #report_result26
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 26')
INSERT INTO #report_result26

select bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Verve additional Fee Payable(Debit_Nr)',

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
          
                          

        amt= 0,
	fee= isnull(CASE  
                    WHEN left(o.r_code,4) in ('7090')
                  
                   THEN sum((0.02 * (-1 * t.settle_amount_impact)))

                   WHEN left(o.r_code,4) in ('7080','7100')
                  
                   THEN sum((0.01 * (-1 * t.settle_amount_impact))) end,0),
         business_date = (substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code) 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and (substring(o.r_code,1,1) = '7'  and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506'))


GROUP BY o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
-- y.trans_date




CREATE TABLE #report_result27
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 27')
INSERT INTO #report_result27

SELECT		
	bank_code = CASE  WHEN (r.addit_party ='YPM') THEN 'GTB'
	                  WHEN (r.addit_party = 'SAVER') THEN 'ZIB'
                          WHEN (r.addit_party = 'ISW') THEN 'ISW'

        ELSE 'UNK'
        END,

	trxn_category= CASE when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= r.addit_party + '_Reward_Fee_Receivable (Credit_Nr)',  
                          
        amt= 0,

	fee=  isnull(CASE WHEN (substring(y.extended_trans_type,1,1) = '8') 
              AND (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(y.extended_trans_type,1,1) = '8') 
                  AND (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  ELSE  
               SUM(r.addit_charge*(-1 * (t.settle_amount_impact))) END,0),
             (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))


FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'

      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
    and substring(y.extended_trans_type,1,1) in ('9','8') 

GROUP BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
r.addit_party,
t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
substring(y.extended_trans_type,1,4),y.extended_trans_type


CREATE TABLE #report_result28
	(bank_code VARCHAR (10),trxn_category VARCHAR (50), Debit_Account_type VARCHAR (50), Credit_Account_type VARCHAR (50),trxn_amount float, 
	trxn_fee float, trxn_date VARCHAR (20)
         )

print(cast(getdate() as varchar(255)) + ': insert into report_result 28')
INSERT INTO #report_result28

SELECT		
	bank_code = CASE  WHEN (r.addit_party = 'YPM') THEN 'GTB'
	                  WHEN (r.addit_party = 'SAVER') THEN 'ZIB'

                          WHEN (r.addit_party = 'ISW') THEN 'ISW'

        ELSE 'UNK'
        END,


	trxn_category= CASE when (substring(o.r_code,1,1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= r.addit_party + '_Reward_Fee_Receivable (Credit_Nr)',  
                          
        amt= 0,

	fee=  isnull(CASE WHEN (substring(o.r_code,1,1) = '8') 
              AND (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(o.r_code,1,1) = '8') 
                  AND (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  ELSE  
               SUM(r.addit_charge*(-1 * (t.settle_amount_impact))) END,0),

	(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)
left JOIN tbl_reward_OutOfBand o (NOLOCK)
        ON t.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)  
left JOIN tbl_merchant_category c (NOLOCK)
   on t.merchant_type = c.category_code 

WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'

      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')

				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
    -- AND t.pan not like '4%'

     and t.merchant_type not in ('5371')
	
     and substring(o.r_code,1,1) in ('9','8') and (left(t.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
    or left (t.pan,3) = '506')

GROUP BY 
-- y.trans_date,
r.addit_party,
t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
o.r_code,
(substring (CAST (t.recon_business_date AS VARCHAR(8000)), 1, 11))

print(cast(getdate() as varchar(255)) + ': insert into report_result 29')

insert into #report_result
select * from #report_result1
union all select * from #report_result2 union all select * from #report_result3
union all select * from #report_result4 union all select * from #report_result5
union all select * from #report_result6 union all select * from #report_result7
union all select * from #report_result8 --union all select * from #report_result9
union all select * from #report_result10 union all select * from #report_result11
union all select * from #report_result12 union all select * from #report_result13
union all select * from #report_result14 union all select * from #report_result15
union all select * from #report_result16 union all select * from #report_result17
union all select * from #report_result18 union all select * from #report_result19
union all select * from #report_result20 union all select * from #report_result21
union all select * from #report_result22 union all select * from #report_result23
union all select * from #report_result24 union all select * from #report_result25
union all select * from #report_result26 union all select * from #report_result27
union all select * from #report_result28

print(cast(getdate() as varchar(255)) + ': insert into report_result 30')
Declare @fee_1 money

--where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'

set @fee_1=( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type = 'ISSUER FEE PAYABLE(Debit_Nr)' and 
             trxn_category not like '%WEB%')-
            ( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'and 
             trxn_category not like '%WEB%')

print(cast(getdate() as varchar(255)) + ': insert into report_result 31')

Declare @fee_2 money
set @fee_2=( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type in 
            ('Verve additional Fee Payable(Debit_Nr)', 'Merchant Additional Reward Fee Payable(Debit_Nr)') and 
             trxn_category like '%WEB%')-
            ( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type not in
             ('Verve additional Fee Payable(Debit_Nr)', 'Merchant Additional Reward Fee Payable(Debit_Nr)') and 
             trxn_category  like '%WEB%')
--where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'

print(cast(getdate() as varchar(255)) + ': insert into report_result 32')


INSERT INTO settlement_summary_breakdown



SELECT 
			* ,'566','0'
	FROM 
			#report_result


print(cast(getdate() as varchar(255)) + ': insert into report_result 33')



INSERT INTO settlement_summary_breakdown

SELECT		distinct
	bank_code = 'ISW',

	trxn_category= CASE when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       --when (substring(t.extended_tran_type,1,1) = '7') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT' 
                       WHEN t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT'
                       --when (substring(o.r_code,1,1) = '7') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT'
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'ISW_Reward_Fee_Receivable (Credit_Nr)',  
                          
        Amt = 0,

	 Fee = isnull(CASE WHEN (substring(y.extended_trans_type,1,1) = '8') 
              AND (abs(t.settle_amount_impact/100) < c.amount_cap) or (isnull(c.amount_cap,0)=0) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(y.extended_trans_type,1,1) = '8') 
                  AND (abs(t.settle_amount_impact/100) >= c.amount_cap) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  WHEN t.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc') then @fee_2 
                  else @fee_1 END,0),
         @to_date,
         '566','0'

	 --substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
##TEMP_TRANSACTIONS_REWARD T(NOLOCK)

LEFT OUTER JOIN tbl_xls_settlement y (nolock)
on 
   (t.terminal_id= y.terminal_id 
   AND t.retrieval_reference_nr = y.rr_number 
    --AND (-1 * t.settle_amount_impact)/100 = y.amount
    AND substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON substring(y.extended_trans_type,1,4) = r.reward_code
 left JOIN tbl_merchant_category c (NOLOCK)
     on t.merchant_type = c.category_code 
 --LEFT JOIN #report_result AS Z (NOLOCK)
--on #report_result.business_date = substring (CAST (t.datetime_req AS VARCHAR(8000)), 1, 11)



WHERE t.tran_postilion_originated = 0
      AND t.tran_type = '00'
      AND t.rsp_code_rsp in ('00','11','09')

      AND (t.settle_amount_impact<> 0 and t.message_type   in ('0200','0220')
      or (t.settle_amount_impact<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 ))
      --or (t.settle_amount_rsp<> 0 and t.message_type   in ('0200','0220') and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%'))
      --or (t.settle_amount_rsp<> 0 and t.message_type = '0420' and t.tran_reversed <> 2 and t.tran_type = 40 and (t.Terminal_id like '1%' or t.Terminal_id like '0%')) )
      AND (t.recon_business_date >= @from_date AND t.recon_business_date < (@to_date+1))
      
     AND t.tran_completed = 1
    
     --AND t.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND t.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     --AND t.pan not like '4%'

     and t.merchant_type not in ('5371')

    AND
             t.source_node_name  NOT LIKE 'SB%'
             AND
             t.sink_node_name  NOT LIKE 'SB%'
	
     --and  (y.extended_trans_type like '9%' or y.extended_trans_type like '8%')



     --and debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'


GROUP BY 
 t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap,
substring(y.extended_trans_type,1,4),y.extended_trans_type,
t.source_node_name

--(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
 --t.settle_amount_impact,t.retrieval_reference_nr,c.amount_cap


print(cast(getdate() as varchar(255)) + ': insert into report_result 34')

update ##TEMP_TRANSACTIONS_REWARD set retention_data = 
(select distinct y.extended_trans_type from tbl_xls_settlement y
 where ##TEMP_TRANSACTIONS_REWARD.terminal_id= y.terminal_id 
   AND ##TEMP_TRANSACTIONS_REWARD.retrieval_reference_nr = y.rr_number 
and isnumeric(left(y.extended_trans_type,4)) = 1
  
   AND substring (CAST (##TEMP_TRANSACTIONS_REWARD.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) 


update ##TEMP_TRANSACTIONS_REWARD set settle_cash_rsp = 0
update ##TEMP_TRANSACTIONS_REWARD set settle_cash_rsp = 
(select distinct y.rdm_amt from tbl_xls_settlement y
 where ##TEMP_TRANSACTIONS_REWARD.terminal_id= y.terminal_id 
   AND ##TEMP_TRANSACTIONS_REWARD.retrieval_reference_nr = y.rr_number 
and isnumeric(y.rdm_amt) = 1
  
   AND substring (CAST (##TEMP_TRANSACTIONS_REWARD.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) 

update ##TEMP_TRANSACTIONS_REWARD set auth_id_rsp = 
(select distinct o.r_code from tbl_reward_outofband o
 where  ##TEMP_TRANSACTIONS_REWARD.card_acceptor_id_code = o.card_acceptor_id_code
   and (left(##TEMP_TRANSACTIONS_REWARD.pan,6) in ('519615','528668','519909','559453','551609','521090','528649','539945')
 or left (##TEMP_TRANSACTIONS_REWARD.pan,3) = '506') 
and isnumeric(left(o.r_code,4)) = 1)


--select * from ##TEMP_TRANSACTIONS_REWARD where isnull(retention_data,0) <> 0 or isnull(settle_cash_rsp,0) <> 0
--or isnull(auth_id_rsp,0) <> 0 or isnull(extended_tran_type,0) <> 0

DECLARE @sql VARCHAR (4000);
DECLARE @report_file VARCHAR (1000);

SET @report_file ='H:\BANK REPORTS\SWT\Daily Summary\POS\Reward_Details_'+REPLACE(REPLACE(REPLACE(REPLACE(getdate(),'-','_'), ' ', '_'), ' ', '_'), ':', '_')+'.csv';

SELECT @sql ='bcp "SELECT * FROM ##TEMP_TRANSACTIONS_REWARD where isnull(retention_data,0) <> 0 or isnull(settle_cash_rsp,0) <> 0 or isnull(auth_id_rsp,0) <> 0 or isnull(extended_tran_type,0) <> 0;", queryout "'+@report_file+'" -c -t, -T -S';

EXEC master..xp_cmdshell @sql;

DROP TABLE ##TEMP_TRANSACTIONS_REWARD;

print(cast(getdate() as varchar(255)) + ': insert into report_result 35')
END  

































GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

