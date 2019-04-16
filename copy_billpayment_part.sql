SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

DECLARE @minID BIGINT
DECLARE @maxID BIGINT
DECLARE @counter BIGINT 
select @minID =    min ([TransactionId]) from   [BillPaymentLog_part]  (nolock)
SELECT @counter =   MAX([TransactionId]) from   [BillPaymentLog]   (nolock)
WHILE (@counter>=@minID) BEGIN
IF NOT EXISTS (SELECT TransactionId FROM  [BillPaymentLog_part]  (nolock) WHERE [TransactionId] = @counter)BEGIN
--SET IDENTITY_INSERT [BillPaymentLog_part] ON
INSERT INTO [BillPaymentLog_part](
 [TransactionId]
      ,[BillerId]
      ,[BillerCode]
      ,[CustomerPriId]
      ,[CustomerSecId]
      ,[PaymentTypeCode]
      ,[PaymentTypeName]
      ,[ISWFee]
      ,[BankFee]
      ,[LeadBankFee]
      ,[IsBillerNotified]
      ,[LeadBankCode]
      ,[LeadBankName]
      ,[LeadBankId]
      ,[LeadBankCBNCode]
      ,[IsoBankCode]
      ,[IsoBankName]
      ,[IsoBankId]
      ,[IsoBankCBNCode]
      ,[TransactionStatusId]
      ,[IsoBankIin]
      ,[LeadBankIin]
      ,[IsoBankAccountNumber]
      ,[LeadBankAccountNumber]
      ,[AlternateLeadBankCbnCode]
      ,[ThirdPartyCode]
      ,[HashedCustomerPriId]
      ,[EncryptedCustomerPriId])
SELECT  [TransactionId]
      ,[BillerId]
      ,[BillerCode]
      ,[CustomerPriId]
      ,[CustomerSecId]
      ,[PaymentTypeCode]
      ,[PaymentTypeName]
      ,[ISWFee]
      ,[BankFee]
      ,[LeadBankFee]
      ,[IsBillerNotified]
      ,[LeadBankCode]
      ,[LeadBankName]
      ,[LeadBankId]
      ,[LeadBankCBNCode]
      ,[IsoBankCode]
      ,[IsoBankName]
      ,[IsoBankId]
      ,[IsoBankCBNCode]
      ,[TransactionStatusId]
      ,[IsoBankIin]
      ,[LeadBankIin]
      ,[IsoBankAccountNumber]
      ,[LeadBankAccountNumber]
      ,[AlternateLeadBankCbnCode]
      ,[ThirdPartyCode]
      ,[HashedCustomerPriId]
      ,[EncryptedCustomerPriId]
  FROM [quickteller].[dbo].[BillPaymentLog] (nolock)
  WHERE TransactionId   =@counter
  PRINT   'TransactionId value: '+convert(VARCHAR(40),@counter)
END
SET @counter=@counter-1;
END 