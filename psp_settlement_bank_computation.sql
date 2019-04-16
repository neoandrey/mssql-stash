USE [postilion_office]
GO
/****** Object:  StoredProcedure [dbo].[psp_settlement_bank_computation]    Script Date: 07/09/2016 07:51:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





	CREATE PROCEDURE [dbo].[psp_settlement_bank_computation](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @bank_code varchar (30)
)
AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

If @start_date is null 
set @start_date =   REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()) ,111),'/', '');

If @end_date is null 
set @end_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),111),'/', '');
END

BEGIN
DECLARE @from_date DATETIME
DECLARE @to_date DATETIME
SET @from_date = REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),111),'/', '');
SET @to_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),111),'/', '');

SELECT
         StartDate=@start_date, 
 
         EndDate=@end_date,

	trxn_category,
        
        Account_type = CASE 
        
        
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'VISA CO-ACQUIRER AMOUNT PAYABLE' THEN 'VISA CO-ACQUIRER AMOUNT PAYABLE'
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'VISA CO-ACQUIRER FEE PAYABLE' THEN 'VISA CO-ACQUIRER FEE PAYABLE'
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE' THEN 'VISA CO-ACQUIRER ISSUER FEE REFUND RECEIVABLE'
        WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISSUER FEE PAYABLE' and trxn_category = 'REWARD MONEY (BURN) POS FEE SETTLEMENT'THEN 'ISSUER FEE PAYABLE_ISW SUNDRY (Acc 2017896339)'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'AMOUNT PAYABLE' and trxn_category = 'REWARD MONEY (BURN) WEB FEE SETTLEMENT'THEN 'AMOUNT PAYABLE_ISW SUNDRY (Acc 2017896339)'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'AMOUNT PAYABLE' THEN 'AMOUNT PAYABLE'
			    WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'AMOUNT RECEIVABLE'THEN 'AMOUNT RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'RECHARGE FEE PAYABLE' THEN  'RECHARGE FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ACQUIRER FEE PAYABLE' THEN 'ACQUIRER FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'CO-ACQUIRER FEE RECEIVABLE' THEN 'CO-ACQUIRER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ACQUIRER FEE RECEIVABLE' THEN 'ACQUIRER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISSUER FEE PAYABLE' THEN 'ISSUER FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'CARDHOLDER_ISSUER FEE RECEIVABLE' THEN 'CARDHOLDER_ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SCHEME OWNER ISSUER FEE RECEIVABLE' THEN 'SCHEME OWNER ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISSUER FEE RECEIVABLE' THEN 'ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW ACQUIRER FEE RECEIVABLE' THEN 'ISW ACQUIRER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW ISSUER FEE RECEIVABLE' THEN 'ISW ISSUER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE GENERIC FEE RECEIVABLE' THEN 'ISW VERVE GENERIC FEE RECEIVABLE' 
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE ECOBANK FEE RECEIVABLE' THEN 'ISW VERVE ECOBANK FEE RECEIVABLE' 
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE SKYEBANK FEE RECEIVABLE' THEN 'ISW VERVE SKYEBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW VERVE FIRSTBANK FEE RECEIVABLE' THEN 'ISW VERVE FIRSTBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE GENERIC FEE RECEIVABLE' THEN 'ISW NON-VERVE GENERIC FEE RECEIVABLE'

                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW 3LCM FEE RECEIVABLE' THEN 'ISW 3LCM FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE' THEN 'ISW NON-VERVE FIRSTBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE GTBANK FEE RECEIVABLE' THEN 'ISW NON-VERVE GTBANK FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW NON-VERVE UBA FEE RECEIVABLE' THEN 'ISW NON-VERVE UBA FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW FEE RECEIVABLE' THEN 'ISW FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISO FEE RECEIVABLE' THEN 'ISO FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'TERMINAL_OWNER FEE RECEIVABLE' THEN 'TERMINAL_OWNER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'PROCESSOR FEE RECEIVABLE' THEN 'PROCESSOR FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ATMC FEE PAYABLE' THEN 'ATMC FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ATMC FEE RECEIVABLE' THEN 'ATMC FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'EASYFUEL FEE RECEIVABLE' THEN 'EASYFUEL FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'MERCHANT FEE RECEIVABLE' THEN 'MERCHANT FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'YPM FEE RECEIVABLE' THEN 'YPM FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'FLEETTECH FEE RECEIVABLE' THEN 'FLEETTECH FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'LYSA FEE RECEIVABLE' THEN 'LYSA FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'PAYIN INSTITUTION FEE RECEIVABLE' THEN 'PAYIN INSTITUTION FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA FEE RECEIVABLE' THEN 'SVA FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'UDIRECT FEE RECEIVABLE' THEN 'UDIRECT FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'PTSP FEE RECEIVABLE' THEN 'PTSP FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'CARDHOLDER_NCS FEE RECEIVABLE' THEN 'CARDHOLDER_NCS FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'NCS FEE RECEIVABLE' THEN 'NCS FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'REWARD_SUNDRY_AMOUNT_RECEIVABLE' THEN  'REWARD_SUNDRY_AMOUNT_RECEIVABLE(Acc 2017896339)'                                                                        
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'TOUCHPOINT FEE RECEIVABLE' THEN  'TOUCHPOINT FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'YPM FEE RECEIVABLE' THEN  'YPM FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SAVER FEE RECEIVABLE' THEN  'SAVER FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW FEE RECEIVABLE' THEN  'ISW FEE RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW_REWARD_FEE_RECEIVABLE' THEN  'ISW_REWARD_FEE_RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'MERCHANT ADDITIONAL REWARD FEE PAYABLE' THEN  'MERCHANT ADDITIONAL REWARD FEE PAYABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE' THEN  'FOODCONCEPT_TERMINAL_OWNER_FEE_RECEIVABLE'
                            WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'ISW CARD SCHEME FEE RECEIVABLE' THEN  'ISW CARD SCHEME FEE RECEIVABLE' 
			    WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA SPONSOR FEE RECEIVABLE' THEN  'SVA SPONSOR FEE RECEIVABLE' 
			    WHEN dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type) = 'SVA SPONSOR FEE PAYABLE' THEN  'SVA SPONSOR FEE PAYABLE'




         ELSE 'UNK' END,

        total_Amount = (SUM(CASE WHEN (CHARINDEX ('pool' ,Debit_account_type) = 0 ) THEN -trxn_amount
 			 ElSE trxn_amount END)/100),
	total_fee = (SUM(CASE WHEN (CHARINDEX ('pool' ,Debit_account_type) = 0 ) THEN -trxn_fee
 			 ELSE trxn_fee END)/100),
    currency,
    Rate = case  when sett.currency = '566' then 1
          else (SELECT cbn.Rate
          FROM cbn_currency AS cbn
          WHERE  sett.currency = cbn.currency_code 
          and cbn.date = (select max(date) from cbn_currency)) end, 
     late_reversal--,
    -- card_type
	 

FROM  settlement_summary_breakdown as sett (nolock)
 JOIN (
						SELECT [date] recon_business_date FROM [get_dates_in_range](@from_date,@from_date)
					)r
				ON
					sett.trxn_date = r.recon_business_date

WHERE bank_code = @bank_code

     AND trxn_category NOT LIKE  'UNK%'
      and not (trxn_category like 'POS%' and trxn_category not like '%transfer%' and ((debit_account_type like '%amount%'
               or credit_account_type like '%amount%') and late_reversal =0))
     -- and not (trxn_category LIKE 'PREPAID CARDLOAD%')
       and not (trxn_category LIKE 'BILLPAYMENT%' and (debit_account_type like '%amount%'
               or credit_account_type like '%amount%'))
       and not (trxn_category LIKE 'PREPAID MERCHANDISE%')
       --and not (trxn_category like '%MASTERCARD LOCAL PROCESSING BILLING%')
       and  (sett.currency = '566' or (sett.currency = '840' and (trxn_category in ('QUICKTELLER TRANSFERS(SVA)','WESTERN UNION MONEY TRANSFERS','BILLPAYMENT MASTERCARD BILLING','ATM WITHDRAWAL (MASTERCARD ISO)') or trxn_category like '%MASTERCARD LOCAL PROCESSING BILLING%')))
       and trxn_category <> 'DEPOSIT'
       
group by trxn_category,dbo.fn_rpt_account_type (Debit_account_type,Credit_account_type),currency,late_reversal--,card_type
OPTION(RECOMPILE, MAXDOP 8)

END






















































































































