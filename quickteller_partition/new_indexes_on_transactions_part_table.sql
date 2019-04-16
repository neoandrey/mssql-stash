
USE [quickteller];
CREATE INDEX indx_ResponseCode
  ON [dbo]
  .[Transactions_part]
  ([ResponseCode], [PaymentDate])
    INCLUDE ([Id], [PaymentRefNum], [CustomerEmail], [CurrencyCode], [TransactionAmount], [MaskedPAN], [BankName], [TerminalOwnerId], [TerminalOwnerName],  [HashedPAN], [ApprovedAmount], [PaymentChannelName], [ServiceCode], [TransactionSetName], [Destination], [ServiceProviderId], [ServiceName], [TransactionSetId], [RequestReference],[TransactionStatusId], [AdviceSuccessfullyProcessed])
    WITH (FILLFACTOR=70, ONLINE=ON)

CREATE INDEX indx_PaymentDate
  ON [dbo]
  .[Transactions_part]
  ([PaymentDate])
    INCLUDE ([Id], [PaymentRefNum], [CurrencyCode], [ResponseCode], [TransactionAmount], [MaskedPAN], [TransactionSetId], [TerminalOwnerId], [RequestReference], [ServiceProviderId], [ServiceName], [TransactionStatusId], [AdviceSuccessfullyProcessed],[BankId])
    WITH (FILLFACTOR=70, ONLINE=ON)

USE [quickteller];
CREATE INDEX indx_ResponseCode
  ON [dbo]
  .[Transactions_part]
  ([ResponseCode])
    INCLUDE ([Id], [PaymentDate], [TransactionSetId], [TerminalOwnerName],  [ApprovedAmount], [PaymentChannelName], [TransactionSetName], [Destination], [BankName],  [HashedPAN])
    WITH (FILLFACTOR=70, ONLINE=ON)
