SELECT  (SELECT MAX (datetime_req) FROM  post_tran (NOLOCK, INDEX=IX_POST_TRAN_7)) LAST_TRANSACTION_DATETIME, 
(SELECT MIN (datetime_req) FROM  post_tran (NOLOCK, INDEX=IX_POST_TRAN_7)) FIRST_TRANSACTION_DATETIME,
(SELECT MIN (recon_business_date) FROM  post_tran (NOLOCK, INDEX=IX_POST_TRAN_9)) FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM post_tran (NOLOCK, INDEX=IX_POST_TRAN_9)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM post_tran (NOLOCK, INDEX = IX_POST_TRAN_9)
) )


SELECT  1 as 'SN',  'OFFICE40D (172.25.10.94)' AS 'SERVER','SUPER' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.94].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.94].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.94].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.94].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.94].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.94].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.94].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL 
SELECT  2 as 'SN',  'SWITCHOFFICE64 (172.25.10.88)' AS 'SERVER','SUPER' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.88].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.88].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.88].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.88].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.88].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.88].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.88].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL
SELECT  3 as 'SN',  'SWITCHOFFICE5 (172.25.10.89)' AS 'SERVER','SUPER' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.89].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.89].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.89].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.89].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.89].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.89].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.89].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL 
SELECT  4 as 'SN',  'MEGAOFFICE5 (172.25.10.71)' AS 'SERVER','MEGA' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.71].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.71].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.71].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.71].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.71].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.71].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.71].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL
SELECT  5 as 'SN',  'MEGAPORTAL64 (172.25.10.9)' AS 'SERVER','MEGA' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.9].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.9].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.9].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.9].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.9].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.9].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.9].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL 
SELECT  6 as 'SN',  'MEGA-OFFICE (172.25.10.10)' AS 'SERVER','MEGA' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.10].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.10].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.10].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.10].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.10].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.10].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.10].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL 
SELECT  7 as 'SN',  'PORTAL5D64 (172.25.10.85)' AS 'SERVER','SUPER' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.85].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.85].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.85].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.85].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.85].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.85].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.85].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL
SELECT  8 as 'SN',  'MEGAOFFICE5DR (172.19.75.71)' AS 'SERVER','MEGA' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.19.75.71].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.19.75.71].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.19.75.71].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.19.75.71].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.19.75.71].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.19.75.71].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.19.75.71].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
SELECT  9 as 'SN',  'ASPOFFICE5DR (172.19.75.18)' AS 'SERVER','ASP' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.19.75.18].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.19.75.18].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.19.75.18].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.19.75.18].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.19.75.18].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.19.75.18].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.19.75.18].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL 
SELECT  10 as 'SN',  'OFFICE40DDR (172.75.75.28)' AS 'SERVER','SUPER' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.75.75.28].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.75.75.28].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.75.75.28].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.75.75.28].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.75.75.28].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.75.75.28].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.75.75.28].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL
SELECT  11 as 'SN',  'SWITCHOFFICE5DR (172.75.75.19)' AS 'SERVER','SUPER' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.75.75.19].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.75.75.19].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.75.75.19].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.75.75.19].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.75.75.19].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.75.75.19].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.75.75.19].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL
SELECT  12 as 'SN',  'ASPOFFICE64 (172.25.15.15)' AS 'SERVER','ASP' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL 
SELECT  13 as 'SN',  'ASPOFFICE (172.25.15.10)' AS 'SERVER','ASP' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.15.10].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.15.10].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.15.10].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.15.10].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.15.10].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.15.10].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.15.10].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL
SELECT  14 as 'SN',  'OFFICE40D64 (172.25.10.95)' AS 'SERVER','SUPER' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.10.95].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.10.95].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.10.95].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.10.95].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.10.95].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.10.95].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.10.95].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT
UNION ALL
SELECT  15 as 'SN',  'OFFICE-ARCHIVE (172.25.15.99)' AS 'SERVER','ASP' AS SERVER_TYPE,(SELECT MAX (datetime_req) FROM  [172.25.15.99].[postilion_office].dbo.post_tran WITH  (NOLOCK)) LAST_TRANSACTION_DATETIME, (SELECT MIN (datetime_req) FROM  [172.25.15.99].[postilion_office].dbo.post_tran WITH(NOLOCK) )FIRST_TRANSACTION_DATETIME,(SELECT MIN (recon_business_date) FROM  [172.25.15.99].[postilion_office].dbo.post_tran WITH (NOLOCK) )FIRST_RECON_BUSINESS_DATE,
(SELECT count(recon_business_date) FROM [172.25.15.99].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   recon_business_date = (SELECT
TOP 1  recon_business_date FROM [172.25.15.99].[postilion_office].dbo.post_tran WITH(NOLOCK)
) )FIRST_RECON_BUSINESS_DATE_TRAN_COUNT,
(SELECT count(convert(date,datetime_req)) FROM [172.25.15.99].[postilion_office].dbo.post_tran WITH (NOLOCK)  WHERE   convert(date,datetime_req) = (SELECT
TOP 1  convert(date,datetime_req) FROM [172.25.15.99].[postilion_office].dbo.post_tran WITH (NOLOCK)
) )FIRST_TRAN_DATETIME_TRAN_COUNT