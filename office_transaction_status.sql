SELECT 1 as 'SN',  'MEGAOFFICE (172.25.10.7)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.7].[postilion_office].dbo.post_tran 
UNION ALL
SELECT 2 as 'SN',  'MEGAOFFICE32 (172.25.10.8)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.8].[postilion_office].dbo.post_tran 
UNION ALL
SELECT 3 as 'SN',  'OFFICE-VISA32 (172.25.10.9)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.9].[postilion_office].dbo.post_tran 
UNION ALL
SELECT  4 as 'SN', 'ASPOFFICE (172.25.15.10)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.15.10].[postilion_office].dbo.post_tran 
UNION ALL
SELECT  5 as 'SN', 'ASPOFFICE64 (172.25.15.15)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [postilion_office].dbo.post_tran 
UNION ALL
SELECT  6 as 'SN', 'OFFICE1D (172.25.15.98)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.15.98].[postilion_office].dbo.post_tran --
UNION ALL
SELECT  7 as 'SN', 'OFFICE01_02 (172.25.10.62)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.62].[postilion_office].dbo.post_tran 
UNION ALL
SELECT  8 as 'SN', 'OFFICE5D32 (172.25.10.65)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.65].[postilion_office].dbo.post_tran 
UNION ALL
SELECT  9 as 'SN', 'OFFICE5D64 (172.25.10.66)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.66].[postilion_office].dbo.post_tran 
UNION ALL
SELECT  10 as 'SN', 'MEGAOFFICE64 (172.25.10.67)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.67].[postilion_office].dbo.post_tran 
UNION ALL
SELECT 11 as 'SN',  'OFFICEBEANS (172.25.10.69)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.69].[postilion_office].dbo.post_tran 
UNION ALL
SELECT 12 as 'SN', 'OFFICE3D (172.25.10.75)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.75].[postilion_office].dbo.post_tran 
UNION ALL
SELECT 13 as 'SN', 'OFFICE5D (172.25.10.166)' AS 'SERVER', MAX(datetime_req)AS 'LAST_TRANSACTION_TIME' ,MIN(datetime_req)AS 'FIRST_TRANSACTION_TIME', DATEDIFF(D, MIN(datetime_req),MAX(datetime_req)) AS 'NUMBER_OF_DAYS' FROM [172.25.10.166].[postilion_office].dbo.post_tran 
