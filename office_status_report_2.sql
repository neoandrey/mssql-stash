SET TRANSACTION  ISOLATION LEVEL READ UNCOMMITTED 

DECLARE @server_table  TABLE (
SN int identity (1,1),
[SERVER] VARCHAR(50),
[SERVER_TYPE] VARCHAR(50),
[LAST_TRANSACTION_DATETIME] DATETIME,
[FIRST_TRANSACTION_DATETIME] DATETIME,
[FIRST_RECON_BUSINESS_DATE] DATETIME,
[FIRST_RECON_BUSINESS_DATE_TRAN_COUNT] BIGINT,
[FIRST_TRAN_DATETIME_TRAN_COUNT] BIGINT 
)
INSERT INTO @server_table

SELECT   'ASPOFFICE64 (172.25.15.15)' AS 'SERVER','ASP' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT


DECLARE @current_server VARCHAR(50)
DECLARE @server_type VARCHAR(50)

DECLARE server_cursor CURSOR LOCAL FORWARD_ONLY STATIC READ_ONLY FOR  SELECT PART FROM dbo.usf_split_string('172.25.10.9,172.25.10.71,172.25.10.85,172.25.10.88,172.25.10.89,172.25.10.94,172.19.75.71,172.19.75.18,172.75.75.28,172.75.75.19,172.25.15.99,172.25.10.95, 172.25.10.93',',')
OPEN server_cursor
FETCH NEXT FROM server_cursor  INTO  @current_server 
WHILE (@@FETCH_STATUS = 0) BEGIN

IF @current_server IN ('172.25.10.10','172.25.10.71','172.25.10.9', '172.19.75.71') BEGIN 
	SET @server_type = 'MEGA'
END
ELSE IF @current_server IN ('172.25.15.15','172.25.15.10', '172.19.75.18') BEGIN 

SET @server_type = 'ASP'
END
ELSE IF @current_server IN ('172.25.10.85','172.25.10.88','172.25.10.89','172.25.10.94','172.25.10.93','172.25.10.95','172.75.75.28','172.75.75.19') BEGIN 

SET @server_type = 'SUPER'
END


IF(@current_server  NOT IN ('172.25.10.10','172.25.10.95'))
BEGIN

insert into @server_table
exec
('SELECT * FROM OPENQUERY(['+@current_server+'], ''SELECT    ISNULL(@@servername,''''ASPOFFICE64DR'''') +''''('+@current_server+')'''' AS ''''SERVER'''','''''+@server_type+''''' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT'')')

END
ELSE BEGIN
insert into @server_table
exec
('SELECT * FROM OPENQUERY(['+@current_server+'], ''SELECT    @@servername +''''('+@current_server+')'''' AS ''''SERVER'''',''''SUPER'''' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count( CONVERT(VARCHAR(10),DATETIME_REQ,112)) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE    CONVERT(VARCHAR(10),DATETIME_REQ,112) = (SELECT
TOP 1   CONVERT(VARCHAR(10),DATETIME_REQ,112)FROM [postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT'')')

END

FETCH NEXT FROM server_cursor  INTO  @current_server 
END
CLOSE server_cursor
DEALLOCATE server_cursor

SELECT * from @server_table