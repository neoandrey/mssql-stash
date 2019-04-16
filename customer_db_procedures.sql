




	
GO
CREATE PROCEDURE [dbo].[Bank_Customer_Data](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @bank_name varchar (100)
)
AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

If (@start_date is null) begin  
set @start_date =   REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()) ,112),'/', '');
end

If (@end_date is null ) begin
set @end_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');
END

DECLARE @report_result TABLE(
	[Transaction Type] [varchar](58) NULL,
	[Retrieval Reference] [varchar](12) NULL,
	[Transaction_Time] [varchar](8) NULL,
	[Transaction Date] [date] NULL,
	[Account Number] [varchar](28) NULL,
	[PAN] [varchar](19) NULL,
	[PAN_Encrypted] [varchar](18) NULL,
	[Card_Brand] [varchar](20) NULL,
	[Merchant_Biller] [varchar](500) NULL,
	[Payment Item] [varchar](310) NULL,
	[Amount] [numeric](24, 6) NULL,
	[Channel] [varchar](16) NULL,
	[Username] [nvarchar](256) NULL,
	[CustomerName] [varchar](152) NULL,
	[MSISDN] [varchar](60) NULL,
	[Acquirer Bank] [varchar](150) NULL,
	[Issuer Bank] [varchar](150) NULL,
	[Response Code] [varchar](6) NULL,
	[ExtraData] [varchar](255) NULL)

insert into @report_result

SELECT *   FROM   [Customer All Transactions]


WHERE [Issuer Bank] = @bank_name
--and ([Transaction Date] >=@start_date and [Transaction Date] <@end_date+1)

and ([Account Number] in (select cust_ac_no from bank_customer_request )
      or [MSISDN] in (select telephone from bank_customer_request )
      or [MSISDN] in (select mobile_number from bank_customer_request )
      or [CustomerName] in (select Ac_Desc from bank_customer_request )
     )
     
 insert into Bank_Customer_Data_Log
 select [transaction date],[Issuer Bank],[Acquirer Bank],COUNT([Retrieval Reference]),SUM(amount)
 from @report_result
 group by [transaction date],[Issuer Bank],[Acquirer Bank]
 
select  '"' + REPLACE([Transaction Type]   , '"', '""') + '"' AS Transaction_Type                   
      ,'"' + REPLACE([Retrieval Reference], '"', '""') + '"' AS Retrieval_Reference                   
      ,'"' + REPLACE([Transaction_Time]   , '"', '""') + '"' AS Transaction_Time                   
      ,'"' + REPLACE([Transaction Date]   , '"', '""') + '"' AS Transaction_Date                   
      ,'"' + REPLACE([Account Number]     , '"', '""') + '"' AS Account_Number 
      ,'"' + REPLACE([PAN]                , '"', '""') + '"' AS PAN                   
      ,'"' + REPLACE([PAN_Encrypted]      , '"', '""') + '"' AS PAN_Encrypted                   
      ,'"' + REPLACE([Card_Brand]         , '"', '""') + '"' AS Card_Brand                   
      ,'"' + REPLACE([Merchant_Biller]    , '"', '""') + '"' AS Merchant_Biller                   
      ,'"' + REPLACE([Payment Item]       , '"', '""') + '"' AS Payment_Item                   
      ,[Amount] AS Amount                   
      ,'"' + REPLACE([Channel]            , '"', '""') + '"' AS Channel                   
      ,'"' + REPLACE([Username]           , '"', '""') + '"' AS Username                   
      ,'"' + REPLACE([CustomerName]       , '"', '""') + '"' AS CustomerName                   
      ,'"' + REPLACE([MSISDN]             , '"', '""') + '"' AS MSISDN                   
      ,'"' + REPLACE([Acquirer Bank]      , '"', '""') + '"' AS Acquirer_Bank                   
      ,'"' + REPLACE([Issuer Bank]        , '"', '""') + '"' AS Issuer_Bank                   
      ,[Response Code] AS Response_Code                   
      ,'"' + REPLACE([ExtraData]          , '"', '""') + '"' AS ExtraData  from @report_result  

OPTION(RECOMPILE, MAXDOP 8)

END






	
GO
CREATE PROCEDURE [dbo].[Bank_Data_Billing](
	@start_date DATETIME=NULL,
        @end_date DATETIME=NULL,
        @bank_name varchar (100)
)
AS
BEGIN

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

If (@start_date is null) begin  
set @start_date =   REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()) ,112),'/', '');
end

If (@end_date is null ) begin
set @end_date =REPLACE(CONVERT(VARCHAR(10),  dateadd(d, -1,GETDATE()),112),'/', '');
END



SELECT Transaction_date,Issuer,sum(volume) as Volume  FROM   Bank_Customer_Data_Log
where  issuer = @bank_name
and (Transaction_Date >=@start_date and Transaction_Date <@end_date+1)
group by Transaction_date,issuer

OPTION(RECOMPILE, MAXDOP 8)

END


-- =============================================
-- Author:		Joshua EJiofor
-- Create date: 2016-04-10
-- Description:	Fetch Customer Transactions By Phone No.
-- =============================================

GO
CREATE PROCEDURE [dbo].[fetchAllCustomerTransactions] 
	-- Add the parameters for the stored procedure here	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT * FROM
	(
		SELECT * FROM [dbo].[Customer CRM Transactions] (nolock)		
		UNION
		SELECT * FROM [dbo].[Customer Daily Transactions] (nolock)		
	) 
	AS CustomerTransactions
	ORDER BY [Transaction Date] DESC, [Transaction_Time] DESC
	
END


-- =============================================
-- Author:		Joshua EJiofor
-- Create date: 2016-04-10
-- Description:	Fetch Customer Transactions By Phone No.
-- =============================================

GO
CREATE PROCEDURE [dbo].[fetchAllCustomerTransactionsByPhoneNo] 
	-- Add the parameters for the stored procedure here
	@PhoneNo		VARCHAR (60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT * FROM
	(
		SELECT * FROM [dbo].[Customer CRM Transactions] (nolock)		
		UNION
		SELECT * FROM [dbo].[Customer Daily Transactions] (nolock)		
	) 
	AS CustomerTransactions
	WHERE MSISDN = @PhoneNo
	ORDER BY [Transaction Date] DESC, [Transaction_Time] DESC
	
END



-- =============================================
-- Author:		Joshua EJiofor
-- Create date: 2016-04-10
-- Description:	Fetch Customer Transactions By Phone No.
-- =============================================

GO
CREATE PROCEDURE [dbo].[fetchCustomerTopTransactionsByEmail] 
	-- Add the parameters for the stored procedure here
	@Email		VARCHAR (60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT TOP (20)	* FROM 
	(
		SELECT * FROM [dbo].[Customer CRM Transactions] (nolock)		
		UNION
		SELECT * FROM [dbo].[Customer Daily Transactions] (nolock)		
	) 
	AS CustomerTransactions
	WHERE Username = @Email
	ORDER BY [Transaction Date] DESC, [Transaction_Time] DESC
	
END




-- =============================================
-- Author:		Joshua EJiofor
-- Create date: 2016-04-10
-- Description:	Fetch Customer Transactions By Phone No.
-- =============================================

GO
CREATE PROCEDURE [dbo].[fetchCustomerTopTransactionsByPhone_Mobile_Email] 
	-- Add the parameters for the stored procedure here
	@Phone		VARCHAR (60),
	@Mobile		VARCHAR (60),
	@Email		VARCHAR (60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(LEN(@Phone) < 5) SET @Phone = '??.?.??' ELSE SET @Phone = LTRIM(RTRIM(@Phone))
	IF(LEN(@Mobile) < 5) SET @Mobile = '??.?.??' ELSE SET @Mobile = LTRIM(RTRIM(@Mobile))
	IF(LEN(@Email) < 5) SET @Email = '??.?.??' ELSE SET @Email = LTRIM(RTRIM(@Email))

    -- Insert statements for procedure here
	SELECT DISTINCT TOP (20)	* FROM 
	(
		SELECT * FROM [dbo].[Customer CRM Transactions] (nolock)		
		UNION
		SELECT * FROM [dbo].[Customer Daily Transactions] (nolock)		
	) 
	AS CustomerTransactions
	WHERE MSISDN = @Phone OR MSISDN = @Mobile OR Username = @Email
	ORDER BY [Transaction Date] DESC, [Transaction_Time] DESC
	
END



-- =============================================
-- Author:		Joshua EJiofor
-- Create date: 2016-04-10
-- Description:	Fetch Customer Transactions By Phone No.
-- =============================================

GO
CREATE PROCEDURE [dbo].[fetchCustomerTopTransactionsByPhoneNo] 
	-- Add the parameters for the stored procedure here
	@PhoneNo		VARCHAR (60)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT TOP (20)	* FROM 
	(
		SELECT * FROM [dbo].[Customer CRM Transactions] (nolock)		
		UNION
		SELECT * FROM [dbo].[Customer Daily Transactions] (nolock)		
	) 
	AS CustomerTransactions
	WHERE MSISDN = @PhoneNo
	ORDER BY [Transaction Date] DESC, [Transaction_Time] DESC
	
END



GO
CREATE PROCEDURE [dbo].[osp_mask_pan]
	@pan		VARCHAR (19),		-- The pan field to be masked. From post_tran_cust.pan
	@process_descr	VARCHAR (100), 		-- A description of the process that is calling this procedure (for error handling purposes)
	@pan_masked	VARCHAR (19)	OUTPUT,
	@error		INT		OUTPUT	-- If > 0, an error has occurred
AS
BEGIN
	-- Please do not use this stored procedure. It has been replaced by osp_mask_pan_2.

	EXEC osp_mask_pan_2
		@pan,
		@process_descr,
		0, -- Mask partially
		@pan_masked OUTPUT,
		@error OUTPUT
END



GO
CREATE PROCEDURE [dbo].[osp_mask_pan_2]
	@pan		VARCHAR (19),		-- The pan field to be masked. From post_tran_cust.pan
	@process_descr	VARCHAR (100), 		-- A description of the process that is calling this procedure (for error handling purposes)
	@mask_completely		INT,
	@pan_masked	VARCHAR (19)	OUTPUT,
	@error		INT		OUTPUT	-- If > 0, an error has occurred
AS
BEGIN	
	SET @error = 0
	
	IF (@pan IS NULL)
	BEGIN
		--
		-- Null PAN, no masking required
		--
		SET @pan_masked = NULL
	END
	ELSE IF (@mask_completely = 1)
	BEGIN
		--
		-- Fully masked PAN
		--
		SET @pan_masked = '*'
	END
	ELSE
	BEGIN
		--
		-- Partially masked PAN
		--
		DECLARE @pan_trim VARCHAR(19)
		SET @pan_trim = LTRIM(RTRIM(@pan))

		DECLARE @pan_length INT
		SET @pan_length = LEN(@pan_trim)
		
		IF @pan_length < 8
		BEGIN
			SET @pan_masked = REPLICATE('*', @pan_length)
			RETURN
		END
		
		DECLARE @suffix_len INT
		DECLARE @prefix_len INT

		SET @suffix_len = 4
		SET @prefix_len = @pan_length-@suffix_len-3
		IF @prefix_len > 6
		BEGIN
			SET @prefix_len = 6
		END
		
		SET @pan_masked = 
			LEFT(@pan_trim, @prefix_len) +
			REPLICATE('*', @pan_length - @prefix_len - @suffix_len) +
			RIGHT(@pan_trim, @suffix_len)
	END
END


/** @psPinData [VARCHAR] (512) , */


GO
CREATE PROCEDURE psp_retrieve_customer_transactions_by_pan_msisdn_email
(
	@pan VARCHAR (19) = NULL,
	@msisdn VARCHAR (60) = NULL,
	@email VARCHAR (100) = NULL,
	@startDate DATE = getdate,
	@endDate DATE = getdate,
	@size VARCHAR(10) = NULL
	
)
AS

BEGIN  
	
	IF (@size IS NULL)
	BEGIN
		SET @size=10
	END
	
	DECLARE @query as nvarchar(2000), @selectQuery as nvarchar(2000);
	
	SET @selectQuery = 'SELECT  TOP ' + @size +'
    [Transaction Type]
      ,[Retrieval Reference]
      ,[Transaction_Time]
      ,[Transaction Date]
      ,[Account Number]
      ,[PAN]
      ,[PAN_Encrypted]
      ,[Card_Brand]
      ,[Merchant_Biller]
      ,[Payment Item]
      ,[Amount]
      ,[Channel]
      ,[Username]
      ,[CustomerName]
      ,[MSISDN]
      ,[Acquirer Bank]
      ,[Issuer Bank]
      ,[Response Code]
      ,[ExtraData]
    FROM [Customer DB].[dbo].[Customer All Transactions]';

	IF(@pan IS NOT NULL AND @msisdn IS NOT NULL AND @email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + ''' AND [MSISDN] = ''' + @msisdn + ''' AND [username] = ''' + @email + 
		''' AND [Transaction Date] >= ''' + LEFT(CONVERT(VARCHAR, @startDate, 120), 10) + 
		''' AND [Transaction Date] <= ''' + LEFT(CONVERT(VARCHAR, @endDate, 120), 10) + ''' ORDER BY [Transaction Date] DESC'
		execute sp_executesql @query		
	END 
	ELSE IF(@pan IS NOT NULL AND @msisdn IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + ''' AND [MSISDN] = ''' + @msisdn + 
		''' AND [Transaction Date] >= ''' + LEFT(CONVERT(VARCHAR, @startDate, 120), 10) + 
		''' AND [Transaction Date] <= ''' + LEFT(CONVERT(VARCHAR, @endDate, 120), 10) + ''' ORDER BY [Transaction Date] DESC'
		execute sp_executesql @query
	END 
	ELSE IF(@pan IS NOT NULL AND @email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + ''' AND [username] = ''' + @email + 
		''' AND [Transaction Date] >= ''' + LEFT(CONVERT(VARCHAR, @startDate, 120), 10) + 
		''' AND [Transaction Date] <= ''' + LEFT(CONVERT(VARCHAR, @endDate, 120), 10) + ''' ORDER BY [Transaction Date] DESC'
		execute sp_executesql @query
	END 
	ELSE IF(@msisdn IS NOT NULL AND @email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [MSISDN] = ''' + @msisdn + ''' AND [username] = ''' + @email + 
		''' AND [Transaction Date] >= ''' + LEFT(CONVERT(VARCHAR, @startDate, 120), 10) + 
		''' AND [Transaction Date] <= ''' + LEFT(CONVERT(VARCHAR, @endDate, 120), 10) + ''' ORDER BY [Transaction Date] DESC'
		execute sp_executesql @query
	END 
	ELSE IF(@pan IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + 
		''' AND [Transaction Date] >= ''' + LEFT(CONVERT(VARCHAR, @startDate, 120), 10) + 
		''' AND [Transaction Date] <= ''' + LEFT(CONVERT(VARCHAR, @endDate, 120), 10) + ''' ORDER BY [Transaction Date] DESC'
		execute sp_executesql @query
	END 
	ELSE IF(@msisdn IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [MSISDN] = ''' + @msisdn + 
		''' AND [Transaction Date] >= ''' + LEFT(CONVERT(VARCHAR, @startDate, 120), 10) + 
		''' AND [Transaction Date] <= ''' + LEFT(CONVERT(VARCHAR, @endDate, 120), 10) + ''' ORDER BY [Transaction Date] DESC'
		execute sp_executesql @query
	END 
	ELSE IF(@email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [username] = ''' + @email + 
		''' AND [Transaction Date] >= ''' + LEFT(CONVERT(VARCHAR, @startDate, 120), 10) + 
		''' AND [Transaction Date] <= ''' + LEFT(CONVERT(VARCHAR, @endDate, 120), 10) + ''' ORDER BY [Transaction Date] DESC'
		execute sp_executesql @query
	END 
	    
END


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

GO
CREATE PROCEDURE report_result as
begin
CREATE TABLE #report_result

(Pan_Encrypted varchar (30), volume int, Month varchar (10),Year varchar (10))

insert into #report_result
SELECT PAN_Encrypted,COUNT([Retrieval Reference]) as volume,
       month(CAST([Transaction Date] as varchar(10))) as Month,
       year(CAST([Transaction Date] as varchar(10))) as Year 
      --into  [Customer_ATM_Summary]
  FROM [Customer DB].dbo.[Customer All Transactions]
  where [transaction type] = 'ATM Withdrawals' and [Response Code] = '00'
  
  group by PAN_Encrypted,month(CAST([Transaction Date] as varchar(10))),
       year(CAST([Transaction Date] as varchar(10)))
       
       select Count(PAN_Encrypted) as No_Customersless4,SUM(volume) as Total_Volume,Month,Year from #report_result where volume <4
       group by Month,Year
       select Count(PAN_Encrypted) as No_Customersgreat4,SUM(volume),Month,Year as Total_Volume from #report_result where volume >=4
       group by Month,Year 
       select Count(PAN_Encrypted) as No_Customersall,SUM(volume) ,Month,Year as Total_Volume from #report_result 
       group by Month,Year

END

GO
CREATE PROCEDURE [dbo].[UpdateCustomer]

@MSISDN varchar(150)

,@pan_encrypted varchar(150)

,@pan varchar(150)

,@CustomerName varchar(150)

,@Username nvarchar(150)

AS

BEGIN

SET NOCOUNT ON;

UPDATE [Customer DB].[dbo].[All Customers]

SET

[PAN_Encrypted] = @pan_encrypted

,CustomerName = @CustomerName

,[Username] = @Username

,pan = @pan

WHERE [MSISDN] = @MSISDN

END


GO
CREATE PROCEDURE [dbo].[UpdateCustomerECashDetails]

@MSISDN varchar(150)

,@haseCash bit

,@LastECashDate datetime

,@EcashBalance bigint
,@IsVerified bit

AS

BEGIN

SET NOCOUNT ON;

UPDATE [Customer DB].[dbo].[All Customers]

SET

[HasECash] = @haseCash

,[LastECashDate] = @LastECashDate

,[ECashBalance] = @EcashBalance

,IsVerified = @IsVerified

WHERE [MSISDN] = @MSISDN

END



GO
CREATE PROCEDURE [dbo].[UpdateCustomerEmail]

@MSISDN varchar(150)

,@Username nvarchar(150)

AS

BEGIN

SET NOCOUNT ON;

UPDATE [Customer DB].[dbo].[All Customers]

SET


[Username] = @Username



WHERE [MSISDN] = @MSISDN

END



GO
CREATE PROCEDURE [dbo].[UpdateCustomerFromPayPhone]

@MSISDN varchar(150)

,@pan_encrypted varchar(150)

,@pan varchar(150)

,@CustomerName varchar(150)

,@gender varchar(150)

AS

BEGIN

SET NOCOUNT ON;

UPDATE [Customer DB].[dbo].[All Customers]

SET

[PAN_Encrypted] = @pan_encrypted

,CustomerName = @CustomerName

,pan = @pan

,gender = @gender

WHERE [MSISDN] = @MSISDN

END



GO
CREATE PROCEDURE [dbo].[UpdateCustomerName]
@MSISDN varchar(150)


,@CustomerName varchar(150)



AS

BEGIN

SET NOCOUNT ON;

UPDATE [Customer DB].[dbo].[All Customers]

SET

CustomerName = @CustomerName


WHERE [MSISDN] = @MSISDN

END




GO
CREATE PROCEDURE [dbo].[UpdateCustomerPAN]
@MSISDN varchar(150)

,@pan_encrypted varchar(150)

,@pan varchar(150)


AS

BEGIN

SET NOCOUNT ON;

UPDATE [Customer DB].[dbo].[All Customers]

SET

[PAN_Encrypted] = @pan_encrypted


,pan = @pan


WHERE [MSISDN] = @MSISDN

END



GO
CREATE PROCEDURE [dbo].[usp_export_customer_data] 
as
begin

SELECT  
       '"' + REPLACE([Transaction Type]   , '"', '""') + '"' AS Transaction_Type                   
      ,'"' + REPLACE([Retrieval Reference], '"', '""') + '"' AS Retrieval_Reference                   
      ,'"' + REPLACE([Transaction_Time]   , '"', '""') + '"' AS Transaction_Time                   
      ,'"' + REPLACE([Transaction Date]   , '"', '""') + '"' AS Transaction_Date                   
      ,'"' + REPLACE([Account Number]     , '"', '""') + '"' AS Account_Number                   
      ,'"' + REPLACE([PAN_Encrypted]      , '"', '""') + '"' AS PAN_Encrypted                   
      ,'"' + REPLACE([Card_Brand]         , '"', '""') + '"' AS Card_Brand                   
      ,'"' + REPLACE([Merchant_Biller]    , '"', '""') + '"' AS Merchant_Biller                   
      ,'"' + REPLACE([Payment Item]       , '"', '""') + '"' AS Payment_Item                   
      ,[Amount] AS Amount                   
      ,'"' + REPLACE([Channel]            , '"', '""') + '"' AS Channel                   
      ,'"' + REPLACE([Username]           , '"', '""') + '"' AS Username                   
      ,'"' + REPLACE([CustomerName]       , '"', '""') + '"' AS CustomerName                   
      ,'"' + REPLACE([MSISDN]             , '"', '""') + '"' AS MSISDN                   
      ,'"' + REPLACE([Acquirer Bank]      , '"', '""') + '"' AS Acquirer_Bank                   
      ,'"' + REPLACE([Issuer Bank]        , '"', '""') + '"' AS Issuer_Bank                   
      ,[Response Code] AS Response_Code                   
      ,'"' + REPLACE([ExtraData]          , '"', '""') + '"' AS ExtraData  
from [Customer All Transactions]  (NOLOCK)
WHERE [Transaction Date]>= '20170301' AND [Transaction Date]<='20170331'

end

GO
CREATE PROCEDURE [dbo].[UspExportCustomerTransactionData]
AS

BEGIN

SELECT
[MSISDN]
,Pan_Encrypted  as PanEncrypted
,[Account Number] as AccountNumber
,[Amount]
,[Transaction Type] as TransactionType
,[Channel]
,[Payment Item] as PaymentItem
,[Merchant_Biller] as MerchantBiller
,[Card_Brand] as CardBrand
,[Acquirer Bank] as AcquirerBank
,[Issuer Bank] as IssuerBank
,[Transaction Date] as TransactionDate
,[Transaction_Time] as TransactionTime

FROM [Customer DB].[dbo].[Customer All Transactions] WITH(NOLOCK)
WHERE [Transaction Date] BETWEEN '2017-01-01' AND '2017-01-31'
AND MSISDN IS NOT NULL
AND MSISDN <> ''
AND  PAN_Encrypted IS NOT NULL
ORDER BY TransactionDate
END



GO
CREATE PROCEDURE [dbo].[UspExportHashedCustomerData]
AS

BEGIN

DECLARE @maxTraker VARCHAR(50)
  DECLARE @customers TABLE(
	PAN_Encrypted VARCHAR(50),
    PAN VARCHAR(50),    
	MSISDN VARCHAR(100),
	AccountNumber VARCHAR(152),
	Username VARCHAR(256),
	CustomerName VARCHAR(152),
	RecordTimeStamp datetime
)

SET NOCOUNT ON;

INSERT INTO @customers
SELECT 
PAN_Encrypted
,PAN
,MSISDN
,[Account Number]
,Username
,CustomerName
,GETDATE()

FROM [Customer DB].[dbo].[All Customers] WITH(NOLOCK)
where PAN is not null
and  PAN_Encrypted is not null
and MSISDN is not null
and MSISDN <> ''
and MSISDN LIKE '234%'
and DataSource = 'PayPhone'
order by PAN_Encrypted 


SELECT
PAN_Encrypted, 
CONVERT(VARCHAR, HASHBYTES('sha1',LTRIM(RTRIM(REPLACE(MSISDN,char(9),'')))),2) as MSISDN,
CASE
  WHEN (Username != 'null') THEN CONVERT(VARCHAR, HASHBYTES('sha1',LTRIM(RTRIM(REPLACE(Username,char(9),'')))),2)
END as Email,
'"' + REPLACE(LTRIM(RTRIM(REPLACE([CustomerName],char(9),''))), '"', '""') + '"' AS CustomerName,
'"' + REPLACE(LTRIM(RTRIM(REPLACE(AccountNumber,char(9),''))), '"', '""') + '"' AS AccountNumber,
RecordTimeStamp

FROM @customers

-- exec [UspExportHashedCustomerData]
END

GO
CREATE PROCEDURE [dbo].[UspExportHashedCustomerTransactionData]
AS

BEGIN

SELECT 
CASE
  WHEN (MSISDN IS NOT NULL) THEN CONVERT(VARCHAR, HASHBYTES('sha1',LTRIM(RTRIM(REPLACE(MSISDN,char(9),'')))),2)
END as MSISDN
,Pan_Encrypted  as PanEncrypted
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Account Number],char(9),''))), '"', '""') + '"' as AccountNumber
,[Amount]
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Transaction Type],char(9),''))), '"', '""') + '"' as TransactionType
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Channel],char(9),''))), '"', '""') + '"' as Channel
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Payment Item],char(9),''))), '"', '""') + '"' as PaymentItem
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Merchant_Biller],char(9),''))), '"', '""') + '"' as MerchantBiller
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Card_Brand],char(9),''))), '"', '""') + '"' as CardBrand
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Acquirer Bank],char(9),''))), '"', '""') + '"' as AcquirerBank
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([Issuer Bank],char(9),''))), '"', '""') + '"' as IssuerBank
,[Transaction Date] as TransactionDate
,[Transaction_Time] as TransactionTime
,[Response Code] as ResponseCode
,'"' + REPLACE(LTRIM(RTRIM(REPLACE([ExtraData],char(9),''))), '"', '""') + '"' as ExtraData

FROM [Customer DB].[dbo].[Customer All Transactions] WITH(NOLOCK)
--FROM [Customer DB].[temp].[Customer All Transactions] WITH(NOLOCK)
WHERE [Transaction Date] = FORMAT(GetDate()-1, 'yyyy-MM-dd')

END

-- exec [UspExportHashedCustomerTransactionData]

GO
CREATE PROCEDURE [dbo].[UspExportHashedCustomerTransactionMessageData]
AS

BEGIN

SELECT TOP 10
[ID]
,CONVERT(VARCHAR(40), HASHBYTES('sha1',MSISDN),2) as MSISDN
,[Key] as Identifier
,[Info]
,[additional_info] as AdditionalInfo
,[Date]

FROM [Customer DB].[dbo].[Vanso Data] WITH(NOLOCK)
WHERE [Date] BETWEEN '2017-01-01' AND '2017-01-31'
AND MSISDN IS NOT NULL
AND MSISDN <> ''
--ORDER BY [Date]
END




GO
CREATE PROCEDURE [dbo].[UspGetHashedCustomerByMSISDN]
(
 @msisdn VARCHAR(30)
)
AS
BEGIN

SELECT TOP 1
[PAN_Encrypted]
,CONVERT(VARCHAR, HASHBYTES('sha1',LTRIM(RTRIM(REPLACE(MSISDN,char(9),'')))),2) as MSISDN
,[Username] AS Email
,[CustomerName]
,[Account Number] AS AccountNumber

FROM [All Customers] WITH(NOLOCK)
WHERE MSISDN = @msisdn

END

/** @psPinData [VARCHAR] (512) , */


GO
CREATE PROCEDURE psp_retrieve_customer_by_pan_msisdn_email
(
	@pan VARCHAR (19) = NULL,
	@msisdn VARCHAR (60) = NULL,
	@email VARCHAR (100) = NULL
	
)
AS

BEGIN    
	
	DECLARE @query as nvarchar(2000), @selectQuery as nvarchar(2000);
	
	SET @selectQuery = 'SELECT TOP 1 [MSISDN]
      ,[Username]
      ,[CustomerName]
      ,[AddressCity]
      ,[AddressState]
      ,[CountryCode]
      ,[DateOfBirth]
      ,[Gender]
      ,[IsVerified]
  FROM [Customer DB].[dbo].[Customer]';

	IF(@pan IS NOT NULL AND @msisdn IS NOT NULL AND @email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + ''' AND [MSISDN] = ''' + @msisdn + ''' AND [username] = ''' + @email + ''''
		execute sp_executesql @query		
	END 
	ELSE IF(@pan IS NOT NULL AND @msisdn IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + ''' AND [MSISDN] = ''' + @msisdn + ''''
		execute sp_executesql @query
	END 
	ELSE IF(@pan IS NOT NULL AND @email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + ''' AND [username] = ''' + @email + ''''
		execute sp_executesql @query
	END 
	ELSE IF(@msisdn IS NOT NULL AND @email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [MSISDN] = ''' + @msisdn + ''' AND [username] = ''' + @email + ''''
		execute sp_executesql @query
	END 
	ELSE IF(@pan IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [PAN_ENCRYPTED] = ''' + @pan + ''''
		execute sp_executesql @query
	END 
	ELSE IF(@msisdn IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [MSISDN] = ''' + @msisdn + ''''
		execute sp_executesql @query
	END 
	ELSE IF(@email IS NOT NULL)
	BEGIN
		SET @query = @selectQuery + ' WHERE [username] = ''' + @email + ''''
		execute sp_executesql @query
	END 
	    
END


