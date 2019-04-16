SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

   SELECT    t.[Id], t.[PaymentRefNum], t.[BankId], t.[BankCode], t.[BankCBNCode], t.[BankName], t.[TerminalOwnerCode], t.[TerminalOwnerName], t.[CurrencyCode], t.[CurrencyName], ISNULL(PaymentDate,'1970-01-01') PaymentDate, t.[ResponseCode],
 t.[TransactionAmount], t.[ApprovedAmount], t.[Surcharge], t.[SurchargeCurrencyCode], t.[TransactionType], t.[TerminalId], t.[RetrievalReferenceNumber], t.[EncryptedPAN], t.[HashedPAN], t.[MaskedPAN], t.[CustomerName], t.[CustomerEmail], 
 t.[CustomerMobile], t.[PaymentChannelId], t.[PaymentChannelName], t.[DepositSlip], t.[TransactionSetId], t.[TransactionSetName], t.[TerminalOwnerId], t.[CountryCode], t.[CountryName], t.[PaymentMethodId], t.[PaymentMethodName], t.[Destination],
 t.[MiscData], t.[RequestReference], t.[ProcessingResponseCode], t.[ProcessingResponseDescription], t.[IsInjected], t.[ServiceProviderId], t.[ServiceCode], t.[ServiceName], t.[TransactionStatusId], t.[ServiceProviderCode], t.[AdviceSuccessfullyProcessed],
 t.[Narration], t.[ReceiptNumber], t.[MerchantSiteDomain], t.[IsInjectProcessing], t.[InjectProcessingCount], t.[RemoteClientName], t.[RemoteClientToken], t.[DeviceTerminalId], t.[RechargePin], t.[PaymentCode], t.[AdditionalResponseData], t.[ValueTokenInfo],
 t.[ThirdPartyData], t.[STAN], t.[Bin], t.[IsSvaTransaction]  

 FROM
  transactions t (NOLOCK)  
 
  WHERE ID  >=83622071 and id <=104338949
and
