
WITH CTE AS
(
SELECT email_id,customer_email,ROW_NUMBER() OVER (PARTITION BY customer_email ORDER BY email_id) AS RN
FROM tbl_customer_email
)
SELECT FROM CTE 
WHERE RN <> 1 

