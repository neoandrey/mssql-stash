CREATE  PROCEDURE usp_suspicious_trx  (@StartDate DATETIME , @EndDate DATETIME)
AS 
BEGIN 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

SET @StartDate = ISNULL (@StartDate, CONVERT(VARCHAR(10), DATEADD(d, -1, getdate()) ,112));
SET @EndDate = ISNULL (@EndDate, CONVERT(VARCHAR(10), DATEADD(d,  0, getdate()) ,112));

;With q As
( SELECT * 
FROM(( SELECT  PaymentDate
,MaskedPAN
,RetrievalReferenceNumber
,BankName
,CustomerName
,CustomerMobile
,PaymentRefNum
,TransactionAmount/100 as 'Amount'
,CustomerEmail
,ResponseCode
,TransactionSetName as 'TransactionType'
,Destination 
,id FROM [db7-ro].quickteller.dbo.TRANSACTIONS a (NOLOCK)
where PaymentDate between @StartDate and @EndDate
and MaskedPAN is not null AND  MaskedPAN ! = 'n/a' AND  LTRIM(RTRIM(RetrievalReferenceNumber)) !='' AND 
CustomerEmail in ( select customer_email from tbl_customer_email (nolock)
) )    )a
left join  [db7-ro].[quickteller].[dbo].[FundsTransferLog]b (NOLOCK)
  on a.id = b.TransactionId 
 )
Select distinct q.PaymentDate
,q.MaskedPAN
,q.RetrievalReferenceNumber
,q.BankName
,q.CustomerName
,q.CustomerMobile
,q.PaymentRefNum
,q.Amount
,q.CustomerEmail
,q.ResponseCode
,q.TransactionType
,q.Destination
,q.TerminatingAccountNumber
,t.from_account_id
from q
 join post_tran_cust c (nolock) on  LTRIM(RTRIM(left(q.MaskedPAN,6))) = LTRIM(RTRIM(Left(c.pan,6))) and  LTRIM(RTRIM(right(q.MaskedPAN,4))) = LTRIM(RTRIM(right(c.pan,4)))
join  post_tran t (NOLOCK) ON c.post_tran_cust_id = t.post_tran_cust_id 
and recon_business_date between @StartDate and @EndDate
--and recon_business_date between @StartDate and @EndDate 
AND q.RetrievalReferenceNumber = T.retrieval_reference_nr
and t.from_account_id is not null
OPTION(RECOMPILE, OPTIMIZE FOR UNKNOWN)
END
--and PaymentDate between @start_date and @end_date +1
--and PaymentDate between '09-APR-2017' and '10-Apr-2017'