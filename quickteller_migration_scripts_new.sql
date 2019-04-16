 SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 


 select 'Transactions'  TableName,  (SELECT COUNT(ID) from  Transactions WITH (NOLOCK, INDEX(PK_Bills_PushContents ))) 'Original', (SELECT COUNT(ID) from Transactions_part WITH (NOLOCK, INDEX(PK_Bills_PushContents_part ))) 'Partitioned'
UNION ALL 
select 'BillPaymentLog' TableName,  (SELECT COUNT(TransactionId) from BillPaymentLog with (nolock, INDEX(pk_BillPaymentLog))) 'Original', (SELECT COUNT(TransactionId) from BillPaymentLog_Part with (nolock, INDEX(pk_BillPaymentLog_Part)) ) 'Partitioned'
UNION ALL 
select 'fundstransferlog' TableName,  (SELECT COUNT(TransactionId) from fundstransferlog WITH (nolock, index(PK_FundsTransferLog_TransferLogId))) 'Original', (SELECT COUNT(TransactionId) from fundstransferlog_Part with (nolock, index(PK_FundsTransferLog_Par_TransferLogId))) 'Partitioned'



  SET IDENTITY_INSERT TRANSACTIONS_PART ON
  INSERT INTO TRANSACTIONS_TEMP(
  
   [Id],[PaymentRefNum],[BankId],[BankCode],[BankCBNCode],[BankName],[TerminalOwnerCode],[TerminalOwnerName],[CurrencyCode],[CurrencyName], [PaymentDate],[ResponseCode],
[TransactionAmount],[ApprovedAmount],[Surcharge],[SurchargeCurrencyCode],[TransactionType],[TerminalId],[RetrievalReferenceNumber],[EncryptedPAN],[HashedPAN],[MaskedPAN],[CustomerName],[CustomerEmail], 
[CustomerMobile],[PaymentChannelId],[PaymentChannelName],[DepositSlip],[TransactionSetId],[TransactionSetName],[TerminalOwnerId],[CountryCode],[CountryName],[PaymentMethodId],[PaymentMethodName],[Destination],
[MiscData],[RequestReference],[ProcessingResponseCode],[ProcessingResponseDescription],[IsInjected],[ServiceProviderId],[ServiceCode],[ServiceName],[TransactionStatusId],[ServiceProviderCode],[AdviceSuccessfullyProcessed],
[Narration],[ReceiptNumber],[MerchantSiteDomain],[IsInjectProcessing],[InjectProcessingCount],[RemoteClientName],[RemoteClientToken],[DeviceTerminalId],[RechargePin],[PaymentCode],[AdditionalResponseData],[ValueTokenInfo],
[ThirdPartyData],[STAN],[Bin],[IsSvaTransaction]  
  )

   SELECT    t.[Id], t.[PaymentRefNum], t.[BankId], t.[BankCode], t.[BankCBNCode], t.[BankName], t.[TerminalOwnerCode], t.[TerminalOwnerName], t.[CurrencyCode], t.[CurrencyName], ISNULL(PaymentDate,'1970-01-01') PaymentDate, t.[ResponseCode],
 t.[TransactionAmount], t.[ApprovedAmount], t.[Surcharge], t.[SurchargeCurrencyCode], t.[TransactionType], t.[TerminalId], t.[RetrievalReferenceNumber], t.[EncryptedPAN], t.[HashedPAN], t.[MaskedPAN], t.[CustomerName], t.[CustomerEmail], 
 t.[CustomerMobile], t.[PaymentChannelId], t.[PaymentChannelName], t.[DepositSlip], t.[TransactionSetId], t.[TransactionSetName], t.[TerminalOwnerId], t.[CountryCode], t.[CountryName], t.[PaymentMethodId], t.[PaymentMethodName], t.[Destination],
 t.[MiscData], t.[RequestReference], t.[ProcessingResponseCode], t.[ProcessingResponseDescription], t.[IsInjected], t.[ServiceProviderId], t.[ServiceCode], t.[ServiceName], t.[TransactionStatusId], t.[ServiceProviderCode], t.[AdviceSuccessfullyProcessed],
 t.[Narration], t.[ReceiptNumber], t.[MerchantSiteDomain], t.[IsInjectProcessing], t.[InjectProcessingCount], t.[RemoteClientName], t.[RemoteClientToken], t.[DeviceTerminalId], t.[RechargePin], t.[PaymentCode], t.[AdditionalResponseData], t.[ValueTokenInfo],
 t.[ThirdPartyData], t.[STAN], t.[Bin], t.[IsSvaTransaction]  

 FROM
  transactions t WITH (NOLOCK, INDEX(PK_Bills_PushContents ) ) 
 
  WHERE ID  not in (
  SELECT ID FROM transactions_temp  WITH (NOLOCK, INDEX( ))
  )



INSERT INTO 
BillPaymentLog_Part 
select * from  BillPaymentLog with (nolock, INDEX(pk_BillPaymentLog)) WHERE TransactionId  
NOT IN (
 select  TransactionId  FROM  BillPaymentLog_Part with (nolock, INDEX(pk_BillPaymentLog_Part))
)


insert into fundstransferlog_Part select * from  fundstransferlog WITH (nolock, index(PK_FundsTransferLog_TransferLogId)) WHERE TransactionId 
NOT IN (
select transactionid FROM fundstransferlog_Part with (nolock, index(PK_FundsTransferLog_Par_TransferLogId) ) 

)



 select 'Transactions'  TableName,  (SELECT COUNT(ID) from  Transactions WITH (NOLOCK, INDEX(PK_Bills_PushContents ))) 'Original', (SELECT COUNT(ID) from Transactions_part WITH (NOLOCK, INDEX(PK_Bills_PushContents_part ))) 'Partitioned'
UNION ALL 
select 'BillPaymentLog' TableName,  (SELECT COUNT(TransactionId) from BillPaymentLog with (nolock, INDEX(pk_BillPaymentLog))) 'Original', (SELECT COUNT(TransactionId) from BillPaymentLog_Part with (nolock, INDEX(pk_BillPaymentLog_Part)) ) 'Partitioned'
UNION ALL 
select 'fundstransferlog' TableName,  (SELECT COUNT(TransactionId) from fundstransferlog WITH (nolock, index(PK_FundsTransferLog_TransferLogId))) 'Original', (SELECT COUNT(TransactionId) from fundstransferlog_Part with (nolock, index(PK_FundsTransferLog_Par_TransferLogId))) 'Partitioned'

