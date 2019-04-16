USE [quickteller]
GO
/****** Object:  StoredProcedure [dbo].[usp_fundstransferlog_get_customer_payments]    Script Date: 4/12/2017 4:05:20 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_fundstransferlog_get_customer_payments]
(
  @pageNum int = 1,
  @pageSize int = 10,
  @startDate DATETIME,
  @endDate DATETIME,
  @customerEmail NVARCHAR(100),
  @serviceProviderId int = 0,
  @customerId varchar(100)=null
) WITH RECOMPILE
AS
Select Top(@PageSize) * from 
(
       SELECT 
              RowID=ROW_NUMBER() OVER (ORDER BY t.Id) 
                     ,t.Id
                     ,t.TransactionAmount
                     ,t.CustomerEmail
                     ,t.PaymentChannelName
                     ,t.PaymentDate
                     ,t.TransactionSetName
                     ,t.PaymentRefNum
                     ,t.ResponseCode
                     ,t.ServiceProviderId
                     ,f.BeneficiaryEmail
                     ,f.BeneficiaryPhone
                     ,f.BeneficiaryName
                     ,f.TerminatingAccountNumber
                     ,f.TerminatingAccountType
                     ,f.TerminatingBankCode
                     ,f.TerminatingBankCBNCode
                     ,f.TerminatingBankId
                     ,f.TerminatingBankName    
					 ,f.TerminatingChannel 
                     ,TotalRows = 100  FROM    ( SELECT   t1.Id
                     ,t1.TransactionAmount
                     ,t1.CustomerEmail
                     ,t1.PaymentChannelName
                     ,t1.PaymentDate
                     ,t1.TransactionSetName
                     ,t1.PaymentRefNum
                     ,t1.ResponseCode
                     ,t1.ServiceProviderId FROM dbo.Transactions t1 (NOLOCK)
					 where   t1.ResponseCode='00'
              AND
              t1.TransactionSetId NOT IN (4,5)
              AND
   t1.PaymentDate >= @startDate
              AND
              t1.PaymentDate <= @endDate
              AND
              t1.CustomerEmail = @customerEmail
              AND
              t1.ServiceProviderId = CASE WHEN @serviceProviderId=0 THEN T1.ServiceProviderId ELSE @serviceProviderId END
					 
					  )	t
       INNER JOIN 
              dbo.FundsTransferLog f (NOLOCK) ON t.Id = f.TransactionId
              AND           
          ( f.TerminatingAccountNumber=CASE WHEN @customerId IS NULL THEN F.TerminatingAccountNumber ELSE @customerId END
              OR
              f.InitiatingAccountNumber= CASE WHEN @customerId IS NULL THEN f.InitiatingAccountNumber ELSE @customerId END)
)A 
WHERE A.RowId > (((@pageNum) - 1) * @pageSize)



USE [quickteller]
GO
/****** Object:  StoredProcedure [dbo].[usp_billpaymentlog_get_customer_bill_payment_history]    Script Date: 4/12/2017 4:19:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[usp_billpaymentlog_get_customer_bill_payment_history]
(
  @startDate DATETIME,
  @endDate DATETIME,
  @username nvarchar(256),
  @billerId INT = 0,
  @consumerId VARCHAR(50) =NULL,
  @allTransactions Bit = 0 
)
AS
	
		SELECT 
				t.CustomerEmail as SubscriberID --sa.SubscriberID
				,t.ApprovedAmount
				,t.Id
				,b.CustomerPriId
				,t.PaymentChannelName
				,t.PaymentDate
				,t.ServiceName
				,t.ServiceProviderId
				,t.PaymentRefNum
				,t.ResponseCode
				,t.ServiceCode
				,t.ServiceProviderId as BillerId --.BillerID
				FROM
	       (SELECT 
		   CustomerEmail 
				,ApprovedAmount
				,Id
				,PaymentChannelName
				,PaymentDate
				,ServiceName
				,ServiceProviderId
				,PaymentRefNum
				,ResponseCode
				,ServiceCode
				
		    FROM dbo.Transactions (NOLOCK) 
		      WHERE 
		   			CustomerEmail= @username		
			AND
			PaymentDate >= @startDate
			AND
		  PaymentDate <= @endDate
		  AND 
		   ServiceProviderId=CASE WHEN @billerId=0 THEN ServiceProviderId ELSE @billerId END
			AND
			ResponseCode = CASE WHEN (@allTransactions=1) THEN ResponseCode ELSE '00' END			
			
			) t
		    INNER JOIN 
		  BillPaymentLog b with (NOLOCK, index(pk_BillPaymentLog_Part)) ON
			 t.Id = b.TransactionId
		and 

			
			b.CustomerPriId = CASE WHEN  (@consumerId IS NULL OR @consumerId='')  THEN b.CustomerPriId ELSE @consumerId 
			
			END 
			
			OPTION(RECOMPILE, optimize for unknown)


