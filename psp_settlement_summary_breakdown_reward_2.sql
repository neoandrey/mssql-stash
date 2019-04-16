USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_summary_breakdown_reward_2]    Script Date: 04/15/2014 08:20:16 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


ALTER     PROCEDURE [dbo].[psp_settlement_summary_breakdown_reward_2](
	@start_date DATETIME=NULL,
    @end_date DATETIME=NULL
)
AS
BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME

SET @from_date = ISNULL(@start_date, DATEADD(D, -1, DATEDIFF(D, 0, GETDATE())))
SET @to_date = ISNULL(@end_date, DATEADD(D, -1, DATEDIFF(D, 0, GETDATE())))

PRINT CHAR(10)+' Fetching data from post_tran...';

SELECT * INTO #TEMP_POST_TRAN FROM post_tran PT (NOLOCK) WHERE 
  PT.recon_business_date >= ( DATEADD(D, 1, DATEDIFF(D, 0,@from_date))) AND PT.recon_business_date < ( DATEADD(D, 1, DATEDIFF(D, 0,@to_date)) )
      AND
      PT.tran_postilion_originated = 0    
      AND PT.rsp_code_rsp in ('00','11','09')
      AND (PT.settle_amount_impact<> 0
      AND PT.message_type   in ('0200','0220')
      OR (PT.settle_amount_impact<> 0 and PT.message_type = '0420' and PT.tran_reversed <> 2 )
      OR (PT.settle_amount_rsp<> 0 and PT.message_type   in ('0200','0220') and PT.tran_type = 40)
      OR (PT.settle_amount_rsp<> 0 and PT.message_type = '0420' and PT.tran_reversed <> 2 and PT.tran_type = 40 ) 

)
    -- AND PT.tran_type = '00'  
DECLARE @min_post_tran_cust_id BIGINT;

DECLARE @max_post_tran_cust_id BIGINT

SELECT @min_post_tran_cust_id= MIN (post_tran_cust_id),@max_post_tran_cust_id = MAX (post_tran_cust_id) FROM  #TEMP_POST_TRAN 

PRINT CHAR(10)+' Fetching data from post_tran_cust...';

SELECT * INTO #TEMP_POST_TRAN_CUST FROM post_tran_cust PTC (NOLOCK)  WHERE PTC.post_tran_cust_id >= @min_post_tran_cust_id AND PTC.post_tran_cust_id <=@max_post_tran_cust_id
								AND
									(LEFT(PTC.Terminal_id,1)='1' OR  LEFT(PTC.Terminal_id,1)='0')
								AND 
									 LEFT(PTC.pan,1) <> '4'
	   -- AND
	   -- PTC.merchant_type <> '5371'


print(cast(getdate() as varchar(255)) + ': inserting distinct date into settlement_summary_session')

--INSERT 
                --               INTO settlement_summary_session
       SELECT 
       
         distinct (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)) + '_Reward' 
       
       INTO #settlement_summary_session
       
       FROM   tbl_xls_settlement AS Y (NOLOCK), #TEMP_POST_TRAN AS PT (NOLOCK),#TEMP_POST_TRAN_CUST  as PTC (NOLOCK)

       WHERE
               (Y.trans_date >= @from_date AND Y.trans_date <DATEADD(D, 1, DATEDIFF(D, 0,@to_date)))
	ORDER BY Y.trans_date
	
print(cast(getdate() as varchar(255)) + ': inserted distinct date')

IF(@@ERROR <>0)
RETURN

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

print(cast(getdate() as varchar(255)) + ': insert into report_result 1')
INSERT INTO #report_result
   --(bank_code,trxn_category,Debit_Account_type,Credit_Account_type,trxn_amount,trxn_fee,trxn_date)




SELECT  
	bank_code = CASE  WHEN (substring(pt.sink_node_name,4,3) = 'UBA') THEN 'UBA'
	                  WHEN (substring(pt.sink_node_name,4,3) = 'FBN') THEN 'FBN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ZIB') THEN 'ZIB' 
                          WHEN (substring(pt.sink_node_name,4,3) = 'SPR') THEN 'ENT'
                          WHEN (substring(pt.sink_node_name,4,3) = 'GTB') THEN 'GTB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'PRU') THEN 'SKYE'
                          WHEN (substring(pt.sink_node_name,4,3) = 'OBI') THEN 'EBN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'WEM') THEN 'WEMA'
                          WHEN (substring(pt.sink_node_name,4,3) = 'AFR') THEN 'MSB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'CHB') THEN 'IBTC'
                          WHEN (substring(pt.sink_node_name,4,3) = 'PLA') THEN 'KSB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'UBP') THEN 'UBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'DBL') THEN 'DBL'
                          WHEN (substring(pt.sink_node_name,4,3) = 'FCM') THEN 'FCMB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'IBP') THEN 'IBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'UBN') THEN 'UBN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ETB') THEN 'ETB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'FBP') THEN 'FBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'SBP') THEN 'SBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ABP') THEN 'ABP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'EBN') THEN 'EBN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'CIT') THEN 'CITI'


                          WHEN (substring(pt.sink_node_name,4,3) = 'FIN') THEN 'FIN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ASO') THEN 'ASO'
                          WHEN (substring(pt.sink_node_name,4,3) = 'OLI') THEN 'OLI'
                          WHEN (substring(pt.sink_node_name,4,3) = 'HSL') THEN 'HSL'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ABS') THEN 'ABS'

                          WHEN (substring(pt.sink_node_name,4,3) = 'PAY') THEN 'PAY'
                          WHEN (substring(pt.sink_node_name,4,3) = 'SAT') THEN 'SAT'
                          WHEN (substring(pt.sink_node_name,4,3) = '3LC') THEN '3LCM'
                          WHEN (substring(pt.sink_node_name,4,3) = 'SCB') THEN 'SCB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'JBP') THEN 'JBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'RSL') THEN 'RSL'
                          WHEN (substring(pt.sink_node_name,4,3) = 'PSH') THEN 'PSH'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ACC') THEN 'ACCI'
                          WHEN (substring(pt.sink_node_name,4,3) = 'EKO') THEN 'EKON'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ATM') THEN 'ATMC'
						  WHEN (substring(pt.sink_node_name,4,3) = 'HBC') THEN 'HBC'
						  WHEN (substring(pt.sink_node_name,4,3) = 'UNI') THEN 'UNI'
						  WHEN (substring(pt.sink_node_name,4,3) = 'UnC') THEN 'UnC'
						WHEN (substring(pt.sink_node_name,4,3) = 'HAG') THEN 'HAG'
						WHEN (substring(pt.sink_node_name,4,3) = 'EXP') THEN 'DBL'

			 ELSE 'UNK'			
END,
	trxn_category= Case when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME'
                            --when (substring(y.extended_trans_type,1,1) = '7') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT'
                            when (substring(y.extended_trans_type,1,1) = '9') then 'REWARD MONEY (SPEND) POS FEE SETTLEMENT'
                           else substring(y.extended_trans_type,1,1)
                            end,

        Debit_account_type=    ISNULL('ISSUER FEE PAYABLE(Debit_Nr)','na'),
                          
        Credit_account_type= ISNULL('FEE POOL(Credit_Nr)','na') ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 1) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact))))

	          WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 2) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100)
                  END,0),
       (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount
   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'	
   
     and (LEFT(y.extended_trans_type,4) like '9%' or LEFT(y.extended_trans_type,4) like '8%')

ORDER BY 
 substring(pt.sink_node_name,4,3),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap)
,y.extended_trans_type

print(cast(getdate() as varchar(255)) + ': insert 2')
INSERT INTO #report_result

SELECT  
	bank_code = CASE  WHEN (substring(pt.sink_node_name,4,3) = 'UBA') THEN 'UBA'
	                  WHEN (substring(pt.sink_node_name,4,3) = 'FBN') THEN 'FBN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ZIB') THEN 'ZIB' 
                          WHEN (substring(pt.sink_node_name,4,3) = 'SPR') THEN 'ENT'
                          WHEN (substring(pt.sink_node_name,4,3) = 'GTB') THEN 'GTB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'PRU') THEN 'SKYE'
                          WHEN (substring(pt.sink_node_name,4,3) = 'OBI') THEN 'OBI'
                          WHEN (substring(pt.sink_node_name,4,3) = 'WEM') THEN 'WEMA'
                          WHEN (substring(pt.sink_node_name,4,3) = 'AFR') THEN 'MSB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'CHB') THEN 'IBTC'
                          WHEN (substring(pt.sink_node_name,4,3) = 'PLA') THEN 'KSB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'UBP') THEN 'UBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'DBL') THEN 'DBL'
                          WHEN (substring(pt.sink_node_name,4,3) = 'FCM') THEN 'FCMB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'IBP') THEN 'IBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'UBN') THEN 'UBN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ETB') THEN 'ETB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'FBP') THEN 'FBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'SBP') THEN 'SBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ABP') THEN 'ABP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'EBN') THEN 'EBN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'CIT') THEN 'CITI'

                          WHEN (substring(pt.sink_node_name,4,3) = 'FIN') THEN 'FIN'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ASO') THEN 'ASO'
                          WHEN (substring(pt.sink_node_name,4,3) = 'OLI') THEN 'OLI'
                          WHEN (substring(pt.sink_node_name,4,3) = 'HSL') THEN 'HSL'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ABS') THEN 'ABS'

                          WHEN (substring(pt.sink_node_name,4,3) = 'PAY') THEN 'PAY'
                          WHEN (substring(pt.sink_node_name,4,3) = 'SAT') THEN 'SAT'
                          WHEN (substring(pt.sink_node_name,4,3) = '3LC') THEN '3LCM'
                          WHEN (substring(pt.sink_node_name,4,3) = 'SCB') THEN 'SCB'
                          WHEN (substring(pt.sink_node_name,4,3) = 'JBP') THEN 'JBP'
                          WHEN (substring(pt.sink_node_name,4,3) = 'RSL') THEN 'RSL'
                          WHEN (substring(pt.sink_node_name,4,3) = 'PSH') THEN 'PSH'
                          WHEN (substring(pt.sink_node_name,4,3) = 'ACC') THEN 'ACCI'
                          WHEN (substring(pt.sink_node_name,4,3) = 'EKO') THEN 'EKON'

                          WHEN (substring(pt.sink_node_name,4,3) = 'ATM') THEN 'ATMC'
                          WHEN (substring(pt.sink_node_name,4,3) = 'HBC') THEN 'HBC'
                          WHEN (substring(pt.sink_node_name,4,3) = 'UNI') THEN 'UNI'
                          WHEN (substring(pt.sink_node_name,4,3) = 'UnC') THEN 'UnC'
			 WHEN (substring(pt.sink_node_name,4,3) = 'HAG') THEN 'HAG'
			 WHEN (substring(pt.sink_node_name,4,3) = 'EXP') THEN 'DBL'


			 ELSE 'UNK'			
END,
	trxn_category= Case when (LEFT(o.r_code, 1) = '8') then 'SAVERSCARD REWARD SCHEME'
                            else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT'
                            end,

        Debit_account_type=    isnull('ISSUER FEE PAYABLE(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('FEE POOL(Credit_Nr)','na') ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 1) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact))))

	          WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 2) 
                  THEN sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100)
                  END,0),



       (substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
                              
       left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)                           
   
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
    

     and ptc.merchant_type <> '5371'	
   

    and ((LEFT(o.r_code, 1)='9' or LEFT(o.r_code, 1)='8') and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))

ORDER BY 
 substring(pt.sink_node_name,4,3),
o.r_code,


dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap),

(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))

print(cast(getdate() as varchar(255)) + ': insert 3')
INSERT INTO #report_result

SELECT  
	bank_code = CASE  WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FBN'
			  ELSE 'FBN'
                          END,			

	trxn_category= CASE WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=   isnull( 'ISSUER FEE PAYABLE(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('FEE POOL(Credit_Nr)','na') ,
                          



        amt= 0,

	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount
   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     and ptc.merchant_type <> '5371'	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     
ORDER BY 
 --pt.sink_node_name,
-- y.trans_date,

dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap),
(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

INSERT INTO #report_result

SELECT  
	bank_code = 'FBN',			

	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',
                       

        Debit_account_type=   isnull( 'ISSUER AMOUNT PAYABLE(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('FEE POOL(Credit_Nr)','na') ,
                          

        amt= isnull(sum(y.rdm_amt*100),0),
	fee= 0,

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount
   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category_web c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     --and ptc.merchant_type <> '5371'	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     

ORDER BY 
 --pt.sink_node_name,
-- y.trans_date,


(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type


print(cast(getdate() as varchar(255)) + ': insert 4')

INSERT INTO #report_result

SELECT  
	bank_code = CASE  WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FBN'
			  ELSE 'ISW'
                          END,			

	trxn_category= CASE WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'

                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('ISSUER FEE RECEIVABLE(Credit_Nr)','na') ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.3*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.3*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount

   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     and ptc.merchant_type <> '5371'	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


ORDER BY 
 --pt.sink_node_name,
-- y.trans_date,

dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

print(cast(getdate() as varchar(255)) + ': insert 5')

INSERT INTO #report_result

SELECT  
	bank_code =  'ISW',		

	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('ISSUER and SWT FEE RECEIVABLE(Credit_Nr)','na') ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.625*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.625*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
  -- AND (-1 * pt.settle_amount_impact)/100 = y.amount

   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category_web c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


ORDER BY 
 --pt.sink_node_name,
-- y.trans_date,

dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

print(cast(getdate() as varchar(255)) + ': insert 6')

INSERT INTO #report_result

SELECT  
	bank_code = 'ISW',			
	

	trxn_category= CASE WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('ISW FEE RECEIVABLE(Credit_Nr)','na') ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.05*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.05*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount
   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                                                
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')


     and ptc.merchant_type <> '5371'	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     

ORDER BY 
-- pt.sink_node_name,
-- y.trans_date,

dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

print(cast(getdate() as varchar(255)) + ': insert 7')

INSERT INTO #report_result

SELECT  
	bank_code = 'ISW',

        
	trxn_category= CASE WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME PTSO'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT PTSO'
                       END,


        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('ISW FEE RECEIVABLE(Credit_Nr)','na') ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.25*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.25*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount
   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
     
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')


     and ptc.merchant_type <> '5371'	

   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


ORDER BY 
-- pt.sink_node_name,
-- y.trans_date,

dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

print(cast(getdate() as varchar(255)) + ': insert 8')

INSERT INTO #report_result

SELECT  
	bank_code = 'ISW',		

	trxn_category= CASE WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME PTSP'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT PTSP'
                       END,

        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('ISW FEE RECEIVABLE(Credit_Nr)','na') ,
                          


        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.25*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.25*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)

   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount
   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')


     and ptc.merchant_type <> '5371'	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


ORDER BY 
-- pt.sink_node_name,
-- y.trans_date,

dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type


print(cast(getdate() as varchar(255)) + ': insert 9')

INSERT INTO #report_result

SELECT  
	bank_code = 'NCS',

	trxn_category= CASE WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,


        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('NCS FEE RECEIVABLE(Credit_Nr)','na') ,
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.075*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.075*c.fee_cap*100)
                  END,0),

	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))

FROM  
   dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
   RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
   ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
   LEFT OUTER JOIN tbl_xls_settlement y
ON 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   --AND (-1 * pt.settle_amount_impact)/100 = y.amount
   AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
   = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
   left JOIN Reward_Category r (NOLOCK)
   ON LEFT(y.extended_trans_type,4) = r.reward_code
   left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'	
   

     and (y.rdm_amt < 0 or y.rdm_amt > 0)
     


ORDER BY 
 --pt.sink_node_name,
-- y.trans_date,

dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), y.extended_trans_type

INSERT INTO #report_result

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Reward_Sundry_Amount_Receivable (Credit_Nr)','na'),  
                          

        amt= 0,

	fee= isnull(CASE  WHEN (substring(y.extended_trans_type,1,1) = '9' 
                   and LEFT(y.extended_trans_type,4) not in ('9080')
                   and substring(y.extended_trans_type,4,1) <> '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.025 * (-1 * pt.settle_amount_impact)))

                   WHEN (substring(y.extended_trans_type,1,1) = '9'
                    and LEFT(y.extended_trans_type,4) not in ('9080') 
                   and substring(y.extended_trans_type,4,1) = '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.03 * (-1 * pt.settle_amount_impact)))   

                   WHEN (LEFT(y.extended_trans_type,4) in ('9080'))
 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * pt.settle_amount_impact)))             
             		
END,0),
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and LEFT(y.extended_trans_type,4) like '9%'

ORDER BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
 y.extended_trans_type



INSERT INTO #report_result

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=    isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Reward_Sundry_Amount_Receivable (Credit_Nr)','na'),  
                          

        amt= 0,

	fee= isnull(CASE  WHEN (LEFT(o.r_code, 1) = '9' 
                   and substring(o.r_code,1,4) not in ('9080')
                   and substring(o.r_code,4,1) <> '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.025 * (-1 * pt.settle_amount_impact)))

                   WHEN (LEFT(o.r_code, 1) = '9'
                    and substring(o.r_code,1,4) not in ('9080') 
                   and substring(o.r_code,4,1) = '3') 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.03 * (-1 * pt.settle_amount_impact)))   

                   WHEN (substring(o.r_code,1,4) in ('9080'))
 
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * pt.settle_amount_impact)))             
             		
END,0),





	(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )                          
	left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     AND ptc.pan not like '4%'

     and ptc.merchant_type <> '5371'
	
    and ((LEFT(o.r_code, 1)='9' ) and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))

ORDER BY 
-- y.trans_date,
o.r_code,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))


INSERT INTO #report_result



SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN pt.extended_tran_type not in ('7080','7090','7100')
                  
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * pt.settle_amount_impact)))

                    WHEN pt.extended_tran_type in ('7080')
                  
                   THEN sum((0.01 * (-1 * pt.settle_amount_impact)))

                   WHEN pt.extended_tran_type in ('7090','7100')
                  
                   THEN sum((0.02 * (-1 * pt.settle_amount_impact))) END,0),


	(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
             		

	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    AND (-1 * pt.settle_amount_impact/100) = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               
                                 

	left JOIN Reward_Category r (NOLOCK)
        ON (pt.extended_tran_type = r.reward_code )

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and pt.extended_tran_type like '7%'


ORDER BY 
-- y.trans_date,
 pt.extended_tran_type,

(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
             		



INSERT INTO #report_result

SELECT		
	bank_code = 'FBN',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type=    'FEE POOL(Debit_Nr)',
                          
        Credit_account_type= 'Reward_Sundry_Amount_Receivable (Credit_Nr)',  
                          

        amt= 0,

	fee= isnull(CASE  WHEN substring(o.r_code,1,4) not in ('7080','7090','7100')
                  
                   THEN sum((R.Reward_Discount*(-1*(settle_amount_impact))) - (0.02 * (-1 * pt.settle_amount_impact)))

                    WHEN substring(o.r_code,1,4) in ('7080')
                  
                   THEN sum((0.01 * (-1 * pt.settle_amount_impact)))

                   WHEN substring(o.r_code,1,4) in ('7090','7100')
                  
                   THEN sum((0.02 * (-1 * pt.settle_amount_impact)))
             		
END,0),

(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )                          
	left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
       
     AND 
     ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     and ptc.merchant_type <> '5371'
	
    and ((LEFT(o.r_code, 1)='7' ) and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))


ORDER BY 
-- y.trans_date,
o.r_code,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))




INSERT INTO #report_result




SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'

                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'


                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  PT.acquiring_inst_id_code = '506150' THEN 'HBC'
               

			 ELSE 'UNK'			
END,
	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Acquirer Fee Receivable(Credit_Nr)','na'),  
                          

        amt= 0,
	fee=  isnull(Case when(LEFT(y.extended_trans_type,4) in ('9080')) then 
             SUM(0.15*(0.0075*(-1 * (pt.settle_amount_impact))))
             else 
             SUM(0.15*(0.0125*(-1 * (pt.settle_amount_impact)))) end,0),
        (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
       
     AND 
     ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     and ptc.merchant_type <> '5371'
	
     and LEFT(y.extended_trans_type,4) like '9%'

ORDER BY 
 PT.acquiring_inst_id_code,
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),y.extended_trans_type

INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
			
               

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Acquirer Fee Receivable(Credit_Nr)','na'),  
                          

        amt= 0,
	fee=  isnull(Case when(substring(o.r_code,1,4) in ('9080')) then 
             SUM(0.15*(0.0075*(-1 * (pt.settle_amount_impact))))
             else 
             SUM(0.15*(0.0125*(-1 * (pt.settle_amount_impact)))) end,0),

	(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
             
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
       
     AND 
     ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     and ptc.merchant_type <> '5371'
	
     and ((LEFT(o.r_code, 1)='9' ) and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))

ORDER BY 
 PT.acquiring_inst_id_code,o.r_code,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
 --y.trans_date

--

INSERT INTO #report_result



SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
               

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Merchant Additional Reward Fee Payable(Debit_Nr)',

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
          
                          

        amt= 0,
	fee= --CASE WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact),c.amount_cap ) = 1) 
                  --THEN 
                   isnull(sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))),0)

	         -- WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact),c.amount_cap ) = 2) 
                 --THEN -sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap)
                  --END
                     ,
         

	business_date = (substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
             
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    AND (-1 * pt.settle_amount_impact/100) = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               
                                  
	left JOIN Reward_Category r (NOLOCK)
        ON (pt.extended_tran_type = r.reward_code)
left JOIN tbl_merchant_category_web c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and pt.extended_tran_type like '7%'
    

ORDER BY 
 PT.acquiring_inst_id_code,pt.extended_tran_type,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11)),
dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact),c.amount_cap )
 --y.trans_date

INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'OBI'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'
                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
               

			 ELSE 'UNK'			

END,
	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Merchant Additional Reward Fee Payable(Debit_Nr)',  

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
        
                          

        amt= 0,
	fee= --CASE WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact),c.amount_cap ) = 1) 
                  --THEN 
                   isnull(sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))),0)

	          --WHEN (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact),c.amount_cap ) = 2) 
                  --THEN -sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap) END
                  ,
         

	(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
                  
             
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)
left JOIN tbl_merchant_category_web c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and ((LEFT(o.r_code, 1)='7' ) and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))


ORDER BY 
 PT.acquiring_inst_id_code,o.r_code,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11)),
dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact),c.amount_cap ) 
 --y.trans_date
--

INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  PT.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= CASE WHEN (LEFT(y.extended_trans_type,4) = '1000') THEN 'FIRSTPOINT REWARD SCHEME'
                       ELSE 'REWARD MONEY (BURN) POS FEE SETTLEMENT'
                       END,

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Acquirer Fee Receivable(Credit_Nr)','na'),  
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.075*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.075*c.fee_cap*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code
 left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     and ptc.merchant_type <> '5371'
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

ORDER BY 
 PT.acquiring_inst_id_code,
dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), LEFT(y.extended_trans_type,4),y.extended_trans_type

INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  PT.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category='REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Acquirer and ISO Fee Receivable(Credit_Nr)','na'),  
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((0.375*c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(0.375*c.fee_cap*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount

    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code
 left JOIN tbl_merchant_category_web c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND 
       
       PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

ORDER BY 
 PT.acquiring_inst_id_code,
dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), LEFT(y.extended_trans_type,4),y.extended_trans_type


INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  PT.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',
                       

        Debit_account_type=  isnull('Acquirer Fee Payable(Debit_Nr)','na'), 
                          
        Credit_account_type= isnull('FEE POOL(Credit_Nr)','na'), 
                          

        amt= 0,
	fee= isnull(CASE WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 1) 
                  THEN sum((c.merchant_disc* y.rdm_amt*100))

	          WHEN (dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ) = 2) 
                  THEN sum(c.fee_cap*100)
                  END,0),
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code
 left JOIN tbl_merchant_category_web c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     and ptc.merchant_type <> '5371'
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

ORDER BY 
 PT.acquiring_inst_id_code,
dbo.fn_rpt_Above_limit (abs(y.rdm_amt),c.amount_cap ),

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), LEFT(y.extended_trans_type,4),y.extended_trans_type

INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN  PT.acquiring_inst_id_code in ( '627480','627752') THEN 'UBA'
                          WHEN  PT.acquiring_inst_id_code = '589019' THEN 'FBN'
                          WHEN  PT.acquiring_inst_id_code = '627629' THEN 'ZIB' 
                          WHEN  PT.acquiring_inst_id_code = '639563' THEN 'ENT'
                          WHEN  PT.acquiring_inst_id_code = '627787' THEN 'GTB'
                          WHEN  PT.acquiring_inst_id_code = '627805' THEN 'SKYE'
                          WHEN  PT.acquiring_inst_id_code = '603948' THEN 'EBN'
                          WHEN  PT.acquiring_inst_id_code in ('627821','628016') THEN 'WEMA'
                          WHEN  PT.acquiring_inst_id_code = '627819' THEN 'MSB'
                          WHEN  PT.acquiring_inst_id_code = '627858' THEN 'IBTC'
                          WHEN  PT.acquiring_inst_id_code = '627955' THEN 'KSB'
                          WHEN  PT.acquiring_inst_id_code = '639609' THEN 'UBP'
                          WHEN  PT.acquiring_inst_id_code in ('627168','000000','506163') THEN 'DBL'
                          WHEN  PT.acquiring_inst_id_code = '628009' THEN 'FCMB'
                          WHEN  PT.acquiring_inst_id_code = '636088' THEN 'IBP'

                          WHEN  PT.acquiring_inst_id_code = '602980' THEN 'UBN'
                          WHEN  PT.acquiring_inst_id_code = '639249' THEN 'ETB'
                          WHEN  PT.acquiring_inst_id_code = '639138' THEN 'FBP'
                          WHEN  PT.acquiring_inst_id_code = '636092' THEN 'SBP'

                          WHEN  PT.acquiring_inst_id_code = '639139' THEN 'ABP'
                          WHEN  PT.acquiring_inst_id_code in ('903709','903708')THEN 'EBN' 
                          WHEN  PT.acquiring_inst_id_code = '023023' THEN 'CITI'
                          WHEN  PT.acquiring_inst_id_code = '639203' THEN 'FIN'
                          WHEN  PT.acquiring_inst_id_code = '606079' THEN 'ASO'
                          WHEN  PT.acquiring_inst_id_code = '506127' THEN 'HSL'
                          WHEN  PT.acquiring_inst_id_code in ('424465','068068') THEN 'SCB'

                          WHEN  PT.acquiring_inst_id_code = '506137' THEN 'JBP'
                          WHEN  PT.acquiring_inst_id_code = '506143' THEN 'ACCION'
						  WHEN  PT.acquiring_inst_id_code = '506150' THEN 'HBC'

			 ELSE 'UNK'			
END,
	
	trxn_category= 'REWARD MONEY (BURN) WEB FEE SETTLEMENT',

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Acquirer Amount Receivable(Credit_Nr)','na'),  
                          

        amt= isnull(sum(y.rdm_amt*100),0),
	fee=  0,
	(substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11))	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
   -- AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code
 left JOIN tbl_merchant_category_web c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE 
 PT.tran_type = '00'
      
       AND PT.tran_completed = 1 
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
													
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and (y.rdm_amt < 0 or y.rdm_amt > 0)

ORDER BY 
 PT.acquiring_inst_id_code,

(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)), LEFT(y.extended_trans_type,4),y.extended_trans_type

INSERT INTO #report_result



SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Touchpoint Fee Receivable(Credit_Nr)','na'),  
                          

        amt= 0,
	fee=  isnull(Case when(LEFT(y.extended_trans_type,4) in ('9080')) then 
             SUM(0.10*(0.0075*(-1 * (pt.settle_amount_impact))))

             else 
             SUM(0.10*(0.0125*(-1 * (pt.settle_amount_impact)))) end,0),

        (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y

on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code

WHERE 
      PT.tran_type = '00'
           
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     
     and ptc.merchant_type <> '5371'
	
     and LEFT(y.extended_trans_type,4) like '9%'

ORDER BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),LEFT(y.extended_trans_type,4),y.extended_trans_type


INSERT INTO #report_result

SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) POS FEE SETTLEMENT',

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('Touchpoint Fee Receivable(Credit_Nr)','na'),  
                          

        amt= 0,
	fee=  isnull(Case when(substring(o.r_code,1,4) in ('9080')) then 
             SUM(0.10*(0.0075*(-1 * (pt.settle_amount_impact))))
             else 
             SUM(0.10*(0.0125*(-1 * (pt.settle_amount_impact)))) end,0),

	(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code) 

WHERE  PT.tran_type = '00'
      
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and ((LEFT(o.r_code, 1)='9' ) and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))

ORDER BY o.r_code,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
-- y.trans_date

--

INSERT INTO #report_result


SELECT		
	bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Verve additional Fee Payable(Debit_Nr)',

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
          
                          

        amt= 0,
	fee= isnull(CASE  
                    WHEN pt.extended_tran_type in ('7090')
                  
                   THEN sum((0.02 * (-1 * pt.settle_amount_impact)))

                   WHEN pt.extended_tran_type in ('7080','7100')
                  
                   THEN sum((0.01 * (-1 * pt.settle_amount_impact))) end,0),
	business_date= substring (CAST (pt.recon_business_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
/*LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10)) */                               
                                 
	left JOIN Reward_Category r (NOLOCK)
        ON (pt.extended_tran_type = r.reward_code )

WHERE 
      PT.tran_type = '00'
           
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     and ptc.merchant_type <> '5371'
	
     and pt.extended_tran_type like '7%'


ORDER BY pt.extended_tran_type,
substring (CAST (pt.recon_business_date AS VARCHAR(8000)), 1, 11)	
-- y.trans_date


INSERT INTO #report_result

select bank_code = 'ISW',

	trxn_category= 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT',

        Debit_account_type= 'Verve additional Fee Payable(Debit_Nr)',

        Credit_account_type=  'FEE POOL(Credit_Nr)',
                          
          
                          

        amt= 0,
	fee= isnull(CASE  
                    WHEN substring(o.r_code,1,4) in ('7090')
                  
                   THEN sum((0.02 * (-1 * pt.settle_amount_impact)))

                   WHEN substring(o.r_code,1,4) in ('7080','7100')
                  
                   THEN sum((0.01 * (-1 * pt.settle_amount_impact))) end,0),
         business_date = (substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
left JOIN tbl_reward_OutOfBand O (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code) 

WHERE 
      
       PT.tran_type = '00'
            
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
     and ((LEFT(o.r_code, 1)='7' ) and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))


ORDER BY o.r_code,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
-- y.trans_date




INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN (r.addit_party like '%YPM%') THEN 'GTB'
	                  WHEN (r.addit_party like '%SAVER%') THEN 'ZIB'
                          WHEN (r.addit_party like '%ISW%') THEN 'ISW'

        ELSE 'UNK'
        END,

	trxn_category= CASE when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull(r.addit_party + '_Reward_Fee_Receivable (Credit_Nr)','na'),  
                          
        amt= 0,

	fee=  isnull(CASE WHEN (substring(y.extended_trans_type,1,1) = '8') 
              AND (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 1) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(y.extended_trans_type,1,1) = '8') 
                  AND (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 2) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  ELSE  
               SUM(r.addit_charge*(-1 * (pt.settle_amount_impact))) END,0),
             (substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))


FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code
left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE 

      PT.tran_type = '00'
           
       AND PT.tran_completed = 1
    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     and ptc.merchant_type <> '5371'
	
    and (LEFT(y.extended_trans_type,4) like '9%' or LEFT(y.extended_trans_type,4) like '8%')

ORDER BY 
(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11)),
r.addit_party,
dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap),
LEFT(y.extended_trans_type,4),y.extended_trans_type


INSERT INTO #report_result

SELECT		
	bank_code = CASE  WHEN (r.addit_party like '%YPM%') THEN 'GTB'
	                  WHEN (r.addit_party like '%SAVER%') THEN 'ZIB'

                          WHEN (r.addit_party like '%ISW%') THEN 'ISW'

        ELSE 'UNK'
        END,


	trxn_category= CASE when (LEFT(o.r_code, 1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull(r.addit_party + '_Reward_Fee_Receivable (Credit_Nr)','na'),  
                          
        amt= 0,

	fee=  isnull(CASE WHEN (LEFT(o.r_code, 1) = '8') 
              AND (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 1) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (LEFT(o.r_code, 1) = '8') 
                  AND (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 2) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  ELSE  
               SUM(r.addit_charge*(-1 * (pt.settle_amount_impact))) END,0),

	(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))
	--business_date= substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )
left JOIN tbl_reward_OutOfBand o (NOLOCK)
        ON ptc.card_acceptor_id_code = o.card_acceptor_id_code 
	left JOIN Reward_Category r (NOLOCK)
        ON ( substring(o.r_code,1,4) = r.reward_code)  
left JOIN tbl_merchant_category c (NOLOCK)
   on ptc.merchant_type = c.category_code 

WHERE 

      PT.tran_type = '00'
           
       AND PT.tran_completed = 1

    
     AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')

     AND ptc.merchant_type <> '5371'
	
     AND ((LEFT(o.r_code, 1)='9' or LEFT(o.r_code, 1)='8') and dbo.fn_rpt_CardGroup (ptc.PAN) in ('1','4'))

ORDER BY 
-- y.trans_date,
r.addit_party,
dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap),
o.r_code,
(substring (CAST (PT.recon_business_date AS VARCHAR(8000)), 1, 11))


Declare @fee_1 money

--where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'
set @fee_1=( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type = 'ISSUER FEE PAYABLE(Debit_Nr)' and 
             trxn_category not like '%WEB%')-
            ( select sum(isnull(trxn_fee,0)) from #report_result 
             where debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'and 
             trxn_category not like '%WEB%')


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




INSERT INTO settlement_summary_breakdown



SELECT 
			* ,'566','0'
	FROM 
			#report_result





--INSERT INTO settlement_summary_breakdown

SELECT		distinct
	bank_code = 'ISW',

	trxn_category= CASE when (substring(y.extended_trans_type,1,1) = '8') then 'SAVERSCARD REWARD SCHEME' 
                       --when (substring(pt.extended_tran_type,1,1) = '7') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT' 
                       WHEN ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT'
                       --when (LEFT(o.r_code, 1) = '7') then 'REWARD MONEY (SPEND) WEB FEE SETTLEMENT'
                       else 'REWARD MONEY (SPEND) POS FEE SETTLEMENT' end,

        Debit_account_type=  isnull('FEE POOL(Debit_Nr)','na'),
                          
        Credit_account_type= isnull('ISW_Reward_Fee_Receivable (Credit_Nr)','na'),  
                          
        Amt = 0,

	 Fee = isnull(CASE WHEN (substring(y.extended_trans_type,1,1) = '8') 
              AND (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 1) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-(c.merchant_disc*(-1*(settle_amount_impact)))))*0.5

	          WHEN (substring(y.extended_trans_type,1,1) = '8') 
                  AND (dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap ) = 2) 
                  THEN (sum((r.reward_discount*(-1*(settle_amount_impact)))-c.fee_cap*100))*0.5
                  WHEN ptc.source_node_name IN ('SWTASPWEBsrc','SWTASPIPDsrc','SWTWEBFEEsrc') then @fee_2 
                  else @fee_1 END,0),
         @to_date,
         '566','0'

	 --substring (CAST (Y.trans_date AS VARCHAR(8000)), 1, 11)	
	 
	 INTO #settlement_summary_breakdown

FROM  
 dbo.#TEMP_POST_TRAN AS PT (NOLOCK)
RIGHT OUTER JOIN dbo.#TEMP_POST_TRAN_CUST  AS PTC (NOLOCK)
ON (PT.post_tran_cust_id = PTC.post_tran_cust_id )

LEFT OUTER JOIN tbl_xls_settlement y
on 
   (ptc.terminal_id= y.terminal_id 
   AND pt.retrieval_reference_nr = y.rr_number 
    --AND (-1 * pt.settle_amount_impact)/100 = y.amount
    AND substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 10)
     = substring(CAST (y.trans_date AS VARCHAR(8000)), 1, 10))                                
                                 
 left JOIN Reward_Category r (NOLOCK)
 ON LEFT(y.extended_trans_type,4) = r.reward_code
 left JOIN tbl_merchant_category c (NOLOCK)
     on ptc.merchant_type = c.category_code 
 --LEFT JOIN #report_result AS Z (NOLOCK)
--on #report_result.business_date = substring (CAST (pt.datetime_req AS VARCHAR(8000)), 1, 11)



WHERE   PT.tran_type = '00'
           
       AND PT.tran_completed = 1
    
     --AND ptc.source_node_name IN ('SWTASPKIMsrc','SWTASPPOSsrc','SWTFUELsrc','SWTTRAVELsrc','SWTTELCOsrc','SWTASPKSKsrc','SWTASPPCPsrc','SWTEASYFLsrc','SWTZIBsrc','SWTUBAsrc','SWTFBNsrc','SWTASPZIBsrc')
				
										
     AND pt.sink_node_name NOT IN ('CCLOADsnk','GPRsnk','PAYDIRECTsnk','SWTMEGAsnk','VTUsnk','VTUSTOCKsnk')
     

     and ptc.merchant_type <> '5371'

    AND
             LEFT(ptc.source_node_name,2) <> 'SB'
             AND
             LEFT( pt.sink_node_name ,2) <> 'SB'
	
     --and  (y.extended_trans_type like '9%' or y.extended_trans_type like '8%')



     --and debit_account_type <> 'ISSUER FEE PAYABLE(Debit_Nr)'


ORDER BY 
 dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap),
LEFT(y.extended_trans_type,4),y.extended_trans_type,
ptc.source_node_name

--(substring (CAST (y.trans_date AS VARCHAR(8000)), 1, 11))
 --dbo.fn_rpt_Above_limit (abs(pt.settle_amount_impact/100),c.amount_cap)


SELECT * FROM #settlement_summary_breakdown;

DROP TABLE #TEMP_POST_TRAN;

DROP TABLE #TEMP_POST_TRAN_CUST;

DROP TABLE #report_result;

DROP TABLE #settlement_summary_breakdown;


END  





